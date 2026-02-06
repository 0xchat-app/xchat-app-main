import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/circle_join_utils.dart';
import 'package:ox_common/utils/user_search_manager.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:chatcore/chat-core.dart';
import 'package:lpinyin/lpinyin.dart';

import 'select_group_members_page.dart';
import 'find_people_page.dart';
import 'package:ox_usercenter/page/settings/qr_code_display_page.dart';
import '../contacts/contact_user_info_page.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/utils/session_helper.dart';
import '../../utils/chat_session_utils.dart';
import 'chat_message_page.dart';
import 'package:ox_usercenter/utils/invite_link_manager.dart';

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

  List<ValueNotifier<UserDBISAR>> _allUsers = [];
  Map<String, List<ValueNotifier<UserDBISAR>>> _groupedUsers = {};
  late final UserSearchManager<ValueNotifier<UserDBISAR>> _userSearchManager;

  // For tracking scroll-based background color changes
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0.0);

  // For paid relay: circle members and admin status
  bool _isPaidRelay = false;
  bool _isAdmin = false;
  List<ValueNotifier<UserDBISAR>> _circleMembers = [];

  @override
  void initState() {
    super.initState();
    _userSearchManager = UserSearchManager.defaultCreate(
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
      final circle = LoginManager.instance.currentCircle;
      if (circle != null) {
        _isPaidRelay = CircleApi.isPaidRelay(circle.relayUrl);
        
        if (_isPaidRelay) {
          // For paid relay: load circle members and check admin status
          await _loadCircleMembersAndCheckAdmin(circle);
        } else {
          // For regular relay: get all users who have local keypackages
          final pubkeysWithKeyPackages = await KeyPackageManager.getAllUsersWithLocalKeyPackages();
          
          // Convert pubkeys to ValueNotifier<UserDBISAR>
          final usersWithKeyPackages = pubkeysWithKeyPackages
              .map((pubkey) => Account.sharedInstance.getUserNotifier(pubkey))
              .toList();
          
          // Initialize UserSearchManager with users who have keypackages
          await _userSearchManager.initialize(
            externalUsers: usersWithKeyPackages,
          );
          
          _allUsers = _userSearchManager.allUsers;
          _groupUsers();
        }
      } else {
        // No circle: get all users who have local keypackages
        final pubkeysWithKeyPackages = await KeyPackageManager.getAllUsersWithLocalKeyPackages();
        
        // Convert pubkeys to ValueNotifier<UserDBISAR>
        final usersWithKeyPackages = pubkeysWithKeyPackages
            .map((pubkey) => Account.sharedInstance.getUserNotifier(pubkey))
            .toList();
        
        // Initialize UserSearchManager with users who have keypackages
        await _userSearchManager.initialize(
          externalUsers: usersWithKeyPackages,
        );
        
        _allUsers = _userSearchManager.allUsers;
        _groupUsers();
      }
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      setState(() {});
    }
  }

  /// Load circle members and check if current user is admin (for paid relay only)
  /// First loads from local cache, then requests network data to update
  Future<void> _loadCircleMembersAndCheckAdmin(Circle circle) async {
    try {
      final currentPubkey = LoginManager.instance.currentPubkey;
      bool hasLoadedFromCache = false;
      
      // Step 1: Load from local cache first
      final cachedTenantInfo = await Account.sharedInstance.loadTenantInfoFromCircleDB(circle.id);
      if (cachedTenantInfo != null) {
        // Update admin status from cache
        final tenantAdminPubkey = cachedTenantInfo['tenant_admin_pubkey'] as String?;
        if (tenantAdminPubkey != null && tenantAdminPubkey.isNotEmpty) {
          _isAdmin = tenantAdminPubkey.toLowerCase() == currentPubkey.toLowerCase();
        }
        
        // Load members from cache
        final membersData = cachedTenantInfo['members'] as List<dynamic>?;
        if (membersData != null && membersData.isNotEmpty) {
          _circleMembers = [];
          
          for (final memberData in membersData) {
            final memberMap = memberData as Map<String, dynamic>;
            final pubkey = memberMap['pubkey'] as String?;
            if (pubkey != null && pubkey.isNotEmpty) {
              final user = await Account.sharedInstance.getUserInfo(pubkey);
              if (user != null) {
                _circleMembers.add(Account.sharedInstance.getUserNotifier(pubkey));
              }
            }
          }
          
          // Initialize UserSearchManager with cached members
          await _userSearchManager.initialize(
            externalUsers: _circleMembers,
          );
          
          _allUsers = _userSearchManager.allUsers;
          _groupUsers();
          
          // Update UI immediately with cached data
          if (mounted) {
            setState(() {});
          }
          hasLoadedFromCache = true;
        }
      }
      
      // Step 1.5: Fallback - Load from CircleDBISAR.memberPubkeys if cache is empty
      if (!hasLoadedFromCache) {
        try {
          final circleDB = await Account.sharedInstance.getCircleById(circle.id);
          if (circleDB != null && circleDB.memberPubkeys.isNotEmpty) {
            _circleMembers = [];
            
            for (final pubkey in circleDB.memberPubkeys) {
              if (pubkey.isNotEmpty) {
                final user = await Account.sharedInstance.getUserInfo(pubkey);
                if (user != null) {
                  _circleMembers.add(Account.sharedInstance.getUserNotifier(pubkey));
                }
              }
            }
            
            // Initialize UserSearchManager with members from CircleDBISAR
            await _userSearchManager.initialize(
              externalUsers: _circleMembers,
            );
            
            _allUsers = _userSearchManager.allUsers;
            _groupUsers();
            
            // Update UI immediately with fallback data
            if (mounted) {
              setState(() {});
            }
            hasLoadedFromCache = true;
          }
        } catch (e) {
          print('Error loading members from CircleDBISAR fallback: $e');
        }
      }
      
      // Step 1.6: Last resort - Add current user (self) if still no data
      if (!hasLoadedFromCache && _circleMembers.isEmpty) {
        if (currentPubkey.isNotEmpty) {
          try {
            final user = await Account.sharedInstance.getUserInfo(currentPubkey);
            if (user != null) {
              _circleMembers.add(Account.sharedInstance.getUserNotifier(currentPubkey));
              
              // Initialize UserSearchManager with self only
              await _userSearchManager.initialize(
                externalUsers: _circleMembers,
              );
              
              _allUsers = _userSearchManager.allUsers;
              _groupUsers();
              
              // Update UI immediately with self
              if (mounted) {
                setState(() {});
              }
            }
          } catch (e) {
            print('Error adding current user as fallback: $e');
          }
        }
      }
      
      // Step 2: Request network data in background to update
      _loadCircleMembersFromNetwork(circle, currentPubkey);
    } catch (e) {
      print('Error in _loadCircleMembersAndCheckAdmin: $e');
      _isAdmin = false;
      // Don't clear _circleMembers here, keep any data we might have loaded
    }
  }

  /// Load circle members from network and update UI
  Future<void> _loadCircleMembersFromNetwork(Circle circle, String currentPubkey) async {
    try {
      // Check admin status: use unified API for current circle, otherwise fetch for this circle only
      try {
        bool isAdmin = false;
        if (LoginManager.instance.currentCircle?.id == circle.id) {
          final updated = await LoginManager.instance.fetchCircleFromRemote();
          isAdmin = updated?.isAdminFor(currentPubkey) ?? false;
        } else {
          final tenantInfo = await CircleMemberService.sharedInstance.getTenantInfoForRelay(
            circle.relayUrl,
            circleId: circle.id,
          );
          isAdmin = tenantInfo.tenantAdminPubkey.toLowerCase() == currentPubkey.toLowerCase();
        }
        if (_isAdmin != isAdmin && mounted) {
          _isAdmin = isAdmin;
          setState(() {});
        }
      } catch (e) {
        print('Error checking admin status from network: $e');
      }

      // Load circle members from network
      try {
        final membersList = await CircleMemberService.sharedInstance.listMembers();
        final newCircleMembers = <ValueNotifier<UserDBISAR>>[];
        
        for (final memberData in membersList) {
          final pubkey = memberData['pubkey'] as String?;
          if (pubkey != null && pubkey.isNotEmpty) {
            final user = await Account.sharedInstance.getUserInfo(pubkey);
            if (user != null) {
              newCircleMembers.add(Account.sharedInstance.getUserNotifier(pubkey));
            }
          }
        }
        
        // Update with network data only if we successfully got data
        if (newCircleMembers.isNotEmpty) {
          _circleMembers = newCircleMembers;
          
          // Initialize UserSearchManager with network members
          await _userSearchManager.initialize(
            externalUsers: _circleMembers,
          );
          
          _allUsers = _userSearchManager.allUsers;
          _groupUsers();
          
          // Update UI with network data
          if (mounted) {
            setState(() {});
          }
        }
        // If network request returns empty, keep existing local data
      } catch (e) {
        print('Error loading circle members from network: $e');
        // Keep existing local data if network request fails
        // If we have no local data, try fallback one more time
        if (_circleMembers.isEmpty) {
          try {
            final circleDB = await Account.sharedInstance.getCircleById(circle.id);
            if (circleDB != null && circleDB.memberPubkeys.isNotEmpty) {
              _circleMembers = [];
              
              for (final pubkey in circleDB.memberPubkeys) {
                if (pubkey.isNotEmpty) {
                  final user = await Account.sharedInstance.getUserInfo(pubkey);
                  if (user != null) {
                    _circleMembers.add(Account.sharedInstance.getUserNotifier(pubkey));
                  }
                }
              }
              
              // Initialize UserSearchManager with fallback members
              await _userSearchManager.initialize(
                externalUsers: _circleMembers,
              );
              
              _allUsers = _userSearchManager.allUsers;
              _groupUsers();
              
              // Update UI with fallback data
              if (mounted) {
                setState(() {});
              }
            } else if (_circleMembers.isEmpty && currentPubkey.isNotEmpty) {
              // Last resort: add current user (self)
              final user = await Account.sharedInstance.getUserInfo(currentPubkey);
              if (user != null) {
                _circleMembers.add(Account.sharedInstance.getUserNotifier(currentPubkey));
                
                await _userSearchManager.initialize(
                  externalUsers: _circleMembers,
                );
                
                _allUsers = _userSearchManager.allUsers;
                _groupUsers();
                
                if (mounted) {
                  setState(() {});
                }
              }
            }
          } catch (e2) {
            print('Error in network failure fallback: $e2');
          }
        }
      }
    } catch (e) {
      print('Error in _loadCircleMembersFromNetwork: $e');
      // Keep existing local data if any error occurs
    }
  }

  void _groupUsers() {
    _groupedUsers.clear();

    for (final user$ in _allUsers) {
      final showName = _getUserShowName(user$);
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

      _groupedUsers.putIfAbsent(firstChar, () => []).add(user$);
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
          // Only show add friends button for non-paid relay
          if (PlatformStyle.isUseMaterial && !_isPaidRelay)
            CLButton.icon(
              icon: PlatformStyle.isUseMaterial
                  ? Icons.person_add
                  : CupertinoIcons.person_add,
              onTap: _onAddFriends,
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
    final menuItems = <LabelItemModel>[
      LabelItemModel(
        icon: ListViewIcon(
          iconName: 'icon_new_group.png',
          package: 'ox_common',
        ),
        title: Localized.text('ox_chat.str_new_group'),
        onTap: _onNewGroup,
      ),
    ];

    // On Android, add user button is already in the app bar, so don't show it in the list
    // Only show add friends for non-paid relay
    if (!PlatformStyle.isUseMaterial && !_isPaidRelay) {
      menuItems.add(
        LabelItemModel(
          icon: ListViewIcon.data(
            CupertinoIcons.person_add,
          ),
          title: Localized.text('ox_chat.add_friends'),
          onTap: _onAddFriends,
        ),
      );
    }

    // Only show invite friends for paid relay and admin, or for non-paid relay
    if (_isPaidRelay) {
      if (_isAdmin) {
        menuItems.add(
          LabelItemModel(
            icon: ListViewIcon.data(
              Icons.share,
            ),
            title: Localized.text('ox_usercenter.invite_to_circle'),
            onTap: _onInviteFriends,
          ),
        );
      }
    } else {
      menuItems.add(
        LabelItemModel(
          icon: ListViewIcon.data(
            Icons.share,
          ),
          title: Localized.text('ox_usercenter.invite'),
          onTap: _onInviteFriends,
        ),
      );
    }

    return SectionListViewItem(
      data: menuItems,
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
        data: users.map((user$) => userListItem(user$)).toList(),
      ));
    }

    return list;
  }

  ListViewItem userListItem(ValueNotifier<UserDBISAR> user$) {
    final circleType = LoginManager.instance.currentCircle?.type;
    final currentPubkey = LoginManager.instance.currentPubkey;
    final isSelf = user$.value.pubKey == currentPubkey;
    
    if (isSelf) {
      // Special UI for self (file transfer assistant)
      return CustomItemModel(
        leading: ValueListenableBuilder(
          valueListenable: user$,
          builder: (context, user, _) {
            return _buildSelfAvatar(context);
          }
        ),
        titleWidget: ValueListenableBuilder(
          valueListenable: user$,
          builder: (context, user, _) {
            return Row(
              children: [
                CLText.bodyMedium(
                  '${Localized.text('ox_chat.file_transfer_assistant')}',
                  colorToken: ColorToken.onSurface,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: 8.px),
                _buildYourselfTag(context),
              ],
            );
          }
        ),
        subtitleWidget: null,
        onTap: () => _onUserTap(user$),
      );
    }
    
    // Normal user item
    return CustomItemModel(
      leading: ValueListenableBuilder(
        valueListenable: user$,
        builder: (context, user, _) {
          return OXUserAvatar(
            user: user,
            size: 40.px,
            isClickable: false,
          );
        }
      ),
      titleWidget: ValueListenableBuilder(
        valueListenable: user$,
        builder: (context, user, _) {
          return CLText.bodyMedium(
            _getUserShowName(user$),
            colorToken: ColorToken.onSurface,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
      ),
      subtitleWidget: circleType == CircleType.bitchat ? null : CLText.bodySmall(
        user$.value.encodedPubkey,
        colorToken: ColorToken.onSurfaceVariant,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _onUserTap(user$),
    );
  }

  Widget _buildSelfAvatar(BuildContext context) {
    final size = 40.px;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFE5E5), // Light pink background
      ),
      child: Center(
        child: Container(
          width: size * 0.4,
          height: size * 0.5,
          decoration: BoxDecoration(
            color: const Color(0xFFE53935), // Red color
            borderRadius: BorderRadius.circular(4.px),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.px, vertical: 2.5.px),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top line (shorter, like a title)
                Container(
                  width: size * 0.2,
                  height: 2.px,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.px),
                  ),
                ),
                SizedBox(height: 2.px),
                // Three lines below (body text)
                Container(
                  width: size * 0.28,
                  height: 2.px,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.px),
                  ),
                ),
                SizedBox(height: 2.px),
                Container(
                  width: size * 0.24,
                  height: 2.px,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.px),
                  ),
                ),
                SizedBox(height: 2.px),
                Container(
                  width: size * 0.26,
                  height: 2.px,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.px),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYourselfTag(BuildContext context) {
    return Icon(
      CupertinoIcons.checkmark_seal_fill,
      size: 16.px,
      color: ColorToken.primary.of(context),
    );
  }

  Widget _buildSearchResults() {
    if (isSearchOnFocus && _searchController.text.isEmpty) {
      return SizedBox.expand();
    }

    return ValueListenableBuilder<SearchResult<ValueNotifier<UserDBISAR>>>(
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

  static String _getUserShowName(ValueNotifier<UserDBISAR> user$) {
    final user = user$.value;
    final name = user.name ?? '';
    final nickName = user.nickName ?? '';

    if (name.isNotEmpty && nickName.isNotEmpty) {
      return '$name($nickName)';
    } else if (name.isNotEmpty) {
      return name;
    } else if (nickName.isNotEmpty) {
      return nickName;
    }
    return user.shortEncodedPubkey;
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _userSearchManager.search(query);
  }

  void _onSearchResultChanged() async {
    if (mounted) {
      // Update local users list with any new users from remote search
      final searchResults = _userSearchManager.results;
      bool hasNewUsers = false;
      
      // Get all users who have local keypackages
      final pubkeysWithKeyPackages = await KeyPackageManager.getAllUsersWithLocalKeyPackages();
      final pubkeysSet = pubkeysWithKeyPackages.toSet();
      
      for (final searchUser$ in searchResults) {
        // Only add users who have local keypackage
        if (!pubkeysSet.contains(searchUser$.value.pubKey)) {
          continue; // Skip users without local keypackage
        }
        // Check if this user is not in our local list
        if (!_allUsers.any((user$) => user$.value.pubKey == searchUser$.value.pubKey)) {
          _allUsers.add(searchUser$);
          hasNewUsers = true;
        }
      }
      
      // Re-group users only if we added new ones (performance optimization)
      if (hasNewUsers) {
        _groupUsers();
      }
      
      setState(() {});
    }
  }

  void _onFocusChanged() {
    setState(() {});
  }



  void _onAddFriends() {
    OXNavigator.pushPage(
      context,
      (context) => const FindPeoplePage(),
    );
  }

  void _onNewGroup() {
    OXNavigator.pushPage(context, (context) => const SelectGroupMembersPage());
  }

  void _onInviteFriends() {
    final circle = LoginManager.instance.currentCircle;
    if (circle == null) {
      CircleJoinUtils.showJoinCircleGuideDialog(context: OXNavigator.rootContext);
      return;
    }
    
    // For paid relay, show circle invite QR code
    if (_isPaidRelay) {
      OXNavigator.pushPage(
        context, 
        (context) => QRCodeDisplayPage(
          inviteType: InviteType.circle,
          circle: circle,
        ),
      );
    } else {
      // For regular relay, show keypackage invite QR code
      OXNavigator.pushPage(
        context, 
        (context) => const QRCodeDisplayPage(),
      );
    }
  }

  void _onUserTap(ValueNotifier<UserDBISAR> user$) async {
    final currentPubkey = LoginManager.instance.currentPubkey;
    final isSelf = user$.value.pubKey == currentPubkey;
    
    if (isSelf) {
      // For self (Note to Self), show confirmation dialog and create self chat directly
      final bool? confirmed = await CLAlertDialog.show<bool>(
        context: context,
        title: Localized.text('ox_chat.file_transfer_assistant'),
        content: Localized.text('ox_chat.create_self_chat_confirm_content'),
        actions: [
          CLAlertAction.cancel(),
          CLAlertAction<bool>(
            label: Localized.text('ox_common.confirm'),
            value: true,
            isDefaultAction: true,
          ),
        ],
      );
      
      if (confirmed == true) {
        _createSelfChat(user$);
      }
    } else {
      // Navigate to user detail page for other users
      await OXNavigator.pushPage(
        context,
        (context) => ContactUserInfoPage(
          user: user$.value,
        ),
      );
    }
  }

  void _onSubmittedHandler(String text) async {
    text = text.trim();
    if (text.isEmpty) return;

    // Use immediate search for submit action
    await _userSearchManager.searchImmediate(text);
  }

  void _createSelfChat(ValueNotifier<UserDBISAR> user$) async {
    final myPubkey = LoginManager.instance.currentPubkey;
    if (myPubkey.isEmpty) {
      CommonToast.instance.show(context, 'Current account is null');
      return;
    }

    final circle = LoginManager.instance.currentCircle;
    if (circle == null) {
      CommonToast.instance.show(context, 'Current circle is null');
      return;
    }

    OXLoading.show();

    try {
      // Create group name for self chat
      String groupName = Localized.text('ox_chat.file_transfer_assistant');
      
      // Create MLS group with only current user (self chat)
      GroupDBISAR? groupDB = await Groups.sharedInstance.createMLSGroup(
        groupName,
        '',
        [myPubkey], // Only current user
        [myPubkey],
        [circle.relayUrl],
        onKeyPackageSelection: (pubkey, availableKeyPackages) =>
            ChatSessionUtils.onKeyPackageSelection(
              context: context,
              pubkey: pubkey,
              availableKeyPackages: availableKeyPackages,
            ),
      );

      if (groupDB == null) {
        await OXLoading.dismiss();
        CommonToast.instance.show(context, 'Failed to create memo');
        return;
      }

      await OXLoading.dismiss();

      // Create session model using SessionHelper
      final params = SessionCreateParams.fromGroup(groupDB, user$.value);
      final sessionModel = await SessionHelper.createSessionModel(params);

      // Navigate to chat page
      ChatMessagePage.open(
        context: null,
        communityItem: sessionModel,
        isPushWithReplace: true,
      );
    } catch (e) {
      await OXLoading.dismiss();
      CommonToast.instance.show(context, e.toString());
    }
  }
}
