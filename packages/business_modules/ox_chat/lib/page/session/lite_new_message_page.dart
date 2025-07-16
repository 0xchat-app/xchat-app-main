import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/scan_utils.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/common_scan_page.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:chatcore/chat-core.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:permission_handler/permission_handler.dart';

import 'select_group_members_page.dart';
import '../../utils/chat_session_utils.dart';
import '../../utils/user_search_manager.dart';

class CLNewMessagePage extends StatefulWidget {
  const CLNewMessagePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CLNewMessagePageState();
  }
}

class _CLNewMessagePageState extends State<CLNewMessagePage> {

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool get isSearchOnFocus => _searchFocusNode.hasFocus;

  List<UserDBISAR> _allUsers = [];
  Map<String, List<UserDBISAR>> _groupedUsers = {};
  late final UserSearchManager _userSearchManager;

  // For tracking scroll-based background color changes
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _userSearchManager = UserSearchManager(
      debounceDelay: const Duration(milliseconds: 300),
      minSearchLength: 1,
      maxResults: 50,
    );

    // Add search result listener for immediate UI updates
    _userSearchManager.resultNotifier.addListener(_onSearchResultChanged);

    _loadData();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollOffset.dispose();
    _userSearchManager.resultNotifier.removeListener(_onSearchResultChanged);
    _userSearchManager.dispose();
    super.dispose();
  }

  void _loadData() async {
    try {
      await _userSearchManager.initialize();
      _allUsers = _userSearchManager.allUsers;
      _groupUsers();
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      setState(() {});
    }
  }

  void _groupUsers() {
    _groupedUsers.clear();

    for (final user in _allUsers) {
      final showName = _getUserShowName(user);
      String firstChar = '#';

      if (showName.isNotEmpty) {
        final firstCharacter = showName[0];
        if (RegExp(r'[a-zA-Z]').hasMatch(firstCharacter)) {
          firstChar = firstCharacter.toUpperCase();
        } else if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(firstCharacter)) {
          // Chinese character, get pinyin first letter
          final pinyin = PinyinHelper.getFirstWordPinyin(firstCharacter);
          if (pinyin.isNotEmpty && RegExp(r'[a-zA-Z]').hasMatch(pinyin[0])) {
            firstChar = pinyin[0].toUpperCase();
          }
        }
      }

      _groupedUsers.putIfAbsent(firstChar, () => []).add(user);
    }

    // Sort users within each group
    _groupedUsers.forEach((key, users) {
      users.sort((a, b) => _getUserShowName(a).compareTo(_getUserShowName(b)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_chat.str_title_new_message'),
        actions: [
          if (PlatformStyle.isUseMaterial)
            CLButton.icon(
              iconName: 'icon_scan_qr.png',
              package: 'ox_common',
              onTap: _onScanQRCode,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 80.px),
          child: _buildSearchBar(),
        ),
      ),
      isSectionListPage: true,
      body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _searchFocusNode.unfocus();
          },
          child: isSearchOnFocus || _searchController.text.isNotEmpty
              ? _buildSearchResults()
              : _buildUserList()
      ),
    );
  }

  Widget _buildSearchBar() {
    return CLSearch(
      padding: EdgeInsets.symmetric(
        vertical: 16.px,
        horizontal: CLLayout.horizontalPadding,
      ),
      controller: _searchController,
      focusNode: _searchFocusNode,
      placeholder: Localized.text('ox_common.search_npub_or_username'),
      showClearButton: true,
      onSubmitted: _onSubmittedHandler,
    );
  }

  Widget _buildUserList() {
    if (_userSearchManager.isLoading) {
      return SizedBox.expand();
    }

    return CLSectionListView(
      items: [
        menuSection(),
        ...userListSectionItems(),
      ],
    );
  }

  SectionListViewItem menuSection() {
    return SectionListViewItem(
      data: [
        if (!PlatformStyle.isUseMaterial)
          LabelItemModel(
            icon: ListViewIcon(
              iconName: 'icon_scan_qr.png',
              package: 'ox_common',
              size: 22.px,
            ),
            title: Localized.text('ox_common.str_scan'),
            onTap: _onScanQRCode,
          ),
        LabelItemModel(
          icon: ListViewIcon(
            iconName: 'icon_new_group.png',
            package: 'ox_common',
            size: 40.px,
          ),
          title: Localized.text('ox_chat.str_new_group'),
          onTap: _onNewGroup,
        ),
      ],
    );
  }

  List<SectionListViewItem> userListSectionItems() {
    final list = <SectionListViewItem>[];

    final sortedKeys = _groupedUsers.keys.toList()..sort((a, b) {
      if (a == '#') return 1;
      if (b == '#') return -1;
      return a.compareTo(b);
    });

    for (final key in sortedKeys) {
      final users = _groupedUsers[key]!;
      list.add(SectionListViewItem(
        header: key,
        data: users.map((user) => userListItem(user)).toList(),
      ));
    }

    return list;
  }

  ListViewItem userListItem(UserDBISAR user) {
    final circleType = LoginManager.instance.currentCircle?.type;
    return CustomItemModel(
      leading: OXUserAvatar(
        user: user,
        size: 40.px,
        isClickable: false,
      ),
      titleWidget: CLText.bodyMedium(
        _getUserShowName(user),
        colorToken: ColorToken.onSurface,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitleWidget: circleType == CircleType.bitchat ? null : CLText.bodySmall(
        user.encodedPubkey,
        colorToken: ColorToken.onSurfaceVariant,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _onUserTap(user),
    );
  }

  Widget _buildSearchResults() {
    if (isSearchOnFocus && _searchController.text.isEmpty) {
      return SizedBox.expand();
    }

    return ValueListenableBuilder<SearchResult<UserDBISAR>>(
      valueListenable: _userSearchManager.resultNotifier,
      builder: (context, searchResult, child) {
        // Show loading indicator when searching
        if (searchResult.state == SearchState.searching) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.px),
              child: CLProgressIndicator.circular(),
            ),
          );
        }

        // Show empty results
        if (searchResult.results.isEmpty) {
          final query = _searchController.text.trim();
          final potentialRemote = query.startsWith('npub') || query.contains('@');

          // Hide empty UI when typing or potential remote search
          if (searchResult.state == SearchState.typing ||
              (potentialRemote && isSearchOnFocus)) {
            return SizedBox.expand();
          }

          return _buildEmptySearchResults();
        }

        // Show search results
        final sections = <SectionListViewItem>[
          SectionListViewItem(
            data: searchResult.results.map((user) => userListItem(user)).toList(),
          ),
        ];

        return CLSectionListView(
          items: sections,
        );
      },
    );
  }

  Widget _buildEmptySearchResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.px),
        child: CLText.bodyLarge(
          'No "${_searchController.text}" results found',
          colorToken: ColorToken.onSurfaceVariant,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getUserShowName(UserDBISAR user) {
    return _userSearchManager.getUserDisplayName(user);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _userSearchManager.search(query);
  }

  void _onSearchResultChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocusChanged() {
    setState(() {});
  }



  void _onScanQRCode() async {
    // Check camera permission first
    if (await Permission.camera.request().isGranted) {
      // Navigate to scan page and get result
      String? result = await OXNavigator.pushPage(
        context,
            (context) => CommonScanPage(),
      );

      if (result != null && result.isNotEmpty) {
        // Use ScanUtils to analyze the scanned result
        // This will automatically handle npubkey and navigate to user detail page
        await ScanUtils.analysis(context, result);
      }
    } else {
      // Show permission dialog if camera permission is denied
      CLAlertDialog.show<bool>(
        context: context,
        content: Localized.text('ox_common.str_permission_camera_hint'),
        actions: [
          CLAlertAction.cancel(),
          CLAlertAction<bool>(
            label: Localized.text('ox_common.str_go_to_settings'),
            value: true,
            isDefaultAction: true,
          ),
        ],
      ).then((result) {
        if (result == true) {
          openAppSettings();
        }
      });
    }
  }

  void _onNewGroup() {
    OXNavigator.pushPage(context, (context) => const SelectGroupMembersPage());
  }

  void _onUserTap(UserDBISAR user) async {
    await ChatSessionUtils.createSecretChatWithConfirmation(
      context: context,
      user: user,
      isPushWithReplace: true,
    );
  }

  void _onSubmittedHandler(String text) async {
    text = text.trim();
    if (text.isEmpty) return;

    // Use immediate search for submit action
    await _userSearchManager.searchImmediate(text);
  }
}
