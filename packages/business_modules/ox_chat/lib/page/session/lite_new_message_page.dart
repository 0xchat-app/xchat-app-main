import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/mixin/common_state_view_mixin.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:chatcore/chat-core.dart';
import 'package:lpinyin/lpinyin.dart';

import 'chat_message_page.dart';
import 'select_group_members_page.dart';
import '../../utils/chat_session_utils.dart';

class CLNewMessagePage extends StatefulWidget {
  const CLNewMessagePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CLNewMessagePageState();
  }
}

class _CLNewMessagePageState extends State<CLNewMessagePage>
    with CommonStateViewMixin {
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool get isSearchOnFocus => _searchFocusNode.hasFocus;
  
  List<UserDBISAR> _allUsers = [];
  Map<String, List<UserDBISAR>> _groupedUsers = {};
  List<UserDBISAR> _searchResults = [];

  // True when a remote search has been requested and is still in progress.
  bool _waitingRemoteSearch = false;

  // True after user presses submit at least once for current query.
  bool _hasSubmitted = false;

  // For tracking scroll-based background color changes
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  void _loadData() {
    // Collect all users from cache and exclude current account.
    final myPubkey = Account.sharedInstance.me?.pubKey;
    _allUsers = Account.sharedInstance.userCache.values
        .map((e) => e.value)
        .where((u) => myPubkey == null || u.pubKey != myPubkey)
        .toList();
    _groupUsers();
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
      padding: EdgeInsets.all(16.px),
      controller: _searchController,
      focusNode: _searchFocusNode,
      placeholder: Localized.text('ox_chat.search'),
      showClearButton: true,
      onSubmitted: _onSubmittedHandler,
    );
  }

  Widget _buildUserList() {
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
      subtitleWidget: CLText.bodySmall(
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

    if (_searchResults.isEmpty) {
      final query = _searchController.text.trim();
      final potentialRemote = query.startsWith('npub') || query.contains('@');

      // Hide empty UI when:
      // • still waiting remote search, OR
      // • potential remote search AND input field is focused.
      if (_waitingRemoteSearch || (potentialRemote && isSearchOnFocus)) {
        return SizedBox.expand();
      }

      // Otherwise show empty UI only if the user has submitted, or it's not a remote pattern.
      if (_hasSubmitted || !potentialRemote) {
        return _buildEmptySearchResults();
      }

      return SizedBox.expand();
    }
    
    final sections = <SectionListViewItem>[
      SectionListViewItem(
        data: _searchResults.map((user) => CustomItemModel(
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
          subtitleWidget: CLText.bodySmall(
            user.encodedPubkey,
            colorToken: ColorToken.onSurfaceVariant,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _onUserTap(user),
        )).toList(),
      ),
    ];
    
    return CLSectionListView(
      items: sections,
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
    final name = user.name ?? '';
    final nickName = user.nickName ?? '';

    if (name.isNotEmpty && nickName.isNotEmpty) {
      return '$name($nickName)';
    } else if (name.isNotEmpty) {
      return name;
    } else if (nickName.isNotEmpty) {
      return nickName;
    }
    return 'Unknown';
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        _searchResults.clear();
        _waitingRemoteSearch = false; // Reset when search query cleared
        _hasSubmitted = false;
      }
    });
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _performSearch(String query) {
    final lowerQuery = query.toLowerCase();
    _searchResults = _allUsers.where((user) {
      final name = (user.name ?? '').toLowerCase();
      final nickName = (user.nickName ?? '').toLowerCase();
      final encodedPubkey = user.encodedPubkey.toLowerCase();

      return name.contains(lowerQuery) ||
          nickName.contains(lowerQuery) ||
          encodedPubkey.contains(lowerQuery);
    }).toList();
  }

  void _onScanQRCode() {

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

    final isPubkeyFormat = text.startsWith('npub');
    final isDnsFormat = text.contains('@');

    // If input doesn't meet remote-search formats, simply rely on local results.
    if (!isPubkeyFormat && !isDnsFormat) {
      // Non-remote search pattern; mark as submitted to allow empty UI.
      _waitingRemoteSearch = false;
      _hasSubmitted = true;
      setState(() {});
      return;
    }

    _waitingRemoteSearch = true;
    setState(() {}); // Refresh UI while waiting

    await OXLoading.show();

    String pubkey = '';
    if (isPubkeyFormat) {
      pubkey = UserDBISAR.decodePubkey(text) ?? '';
    } else if (isDnsFormat) {
      pubkey = await Account.getDNSPubkey(
        text.substring(0, text.indexOf('@')),
        text.substring(text.indexOf('@') + 1),
      ) ?? '';
    }

    UserDBISAR? user;
    if (pubkey.isNotEmpty) {
      user = await Account.sharedInstance.getUserInfo(pubkey);
    }

    await OXLoading.dismiss();

    _waitingRemoteSearch = false; // Remote search finished
    _hasSubmitted = true; // Search submitted

    if (user == null) {
      setState(() {}); // Update UI to possibly show empty results
      CommonToast.instance.show(context, 'User not found, please re-enter.');
      return;
    }

    final remoteUser = user;
    final existsInLocal = _allUsers.any((u) => u.pubKey == remoteUser.pubKey);
    final existsInResults = _searchResults.any((u) => u.pubKey == remoteUser.pubKey);

    // Add only if not already present.
    if (!existsInResults) {
      _searchResults.insert(0, user);
    }

    // If user is not in local contacts, optionally keep in _allUsers so future searches include it.
    if (!existsInLocal) {
      _allUsers.add(user);
    }

    setState(() {});
  }
}
