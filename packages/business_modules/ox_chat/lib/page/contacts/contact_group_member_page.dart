import 'package:flutter/material.dart';
import 'package:ox_chat/model/option_model.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_chat/page/contacts/contact_user_info_page.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:lpinyin/lpinyin.dart';

class ContactGroupMemberPage extends StatefulWidget {
  final String groupId;
  final String? title;
  final GroupType? groupType;

  const ContactGroupMemberPage({
    super.key,
    required this.groupId,
    this.title,
    this.groupType,
  });

  @override
  _ContactGroupMemberPageState createState() => _ContactGroupMemberPageState();
}

class _ContactGroupMemberPageState extends State<ContactGroupMemberPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<UserDBISAR> _allMembers = [];
  List<UserDBISAR> _filteredMembers = [];
  Map<String, List<UserDBISAR>> _groupedMembers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadGroupMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadGroupMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<UserDBISAR> members;
      if (widget.groupType == null || widget.groupType == GroupType.privateGroup) {
        members = await Groups.sharedInstance.getAllGroupMembers(widget.groupId);
      } else {
        members = await RelayGroup.sharedInstance.getGroupMembersFromLocal(widget.groupId);
      }

      setState(() {
        _allMembers = members;
        _filteredMembers = members;
        _groupMembers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMembers = _allMembers;
      } else {
        _filteredMembers = _allMembers.where((user) {
          final name = (user.name ?? '').toLowerCase();
          final nickName = (user.nickName ?? '').toLowerCase();
          final pubkey = user.encodedPubkey.toLowerCase();
          return name.contains(query) || 
                 nickName.contains(query) || 
                 pubkey.contains(query);
        }).toList();
      }
      _groupMembers();
    });
  }

  void _groupMembers() {
    _groupedMembers.clear();
    
    for (final user in _filteredMembers) {
      String firstChar = '#';
      final name = user.name ?? '';
      if (name.isNotEmpty) {
        final pinyin = PinyinHelper.getFirstWordPinyin(name);
        if (pinyin.isNotEmpty && RegExp(r'^[A-Za-z]').hasMatch(pinyin)) {
          firstChar = pinyin[0].toUpperCase();
        }
      }
      
      _groupedMembers.putIfAbsent(firstChar, () => []).add(user);
    }

    // Sort each group
    _groupedMembers.forEach((key, users) {
      users.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    });
  }

  String get _pageTitle {
    if (widget.title != null) return widget.title!;
    final memberCount = _allMembers.length;
    return '${Localized.text('ox_chat.group_member')} ${memberCount > 0 ? '($memberCount)' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: _pageTitle,
      ),
      isSectionListPage: true,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildMemberList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return CLSearch(
      padding: EdgeInsets.all(16.px),
      controller: _searchController,
      focusNode: _searchFocusNode,
      placeholder: Localized.text('ox_chat.search_member'),
      showClearButton: true,
    );
  }

  Widget _buildMemberList() {
    if (_isLoading) {
      return Center(
        child: CLProgressIndicator.circular(),
      );
    }

    if (_filteredMembers.isEmpty) {
      return _buildEmptyState();
    }

    return CLSectionListView(
      items: _buildSectionItems(),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.px),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.people_outline,
              size: 64.px,
              color: ColorToken.onSurfaceVariant.of(context),
            ),
            SizedBox(height: 16.px),
            CLText.bodyLarge(
              isSearching 
                ? Localized.text('ox_chat.no_search_results')
                : Localized.text('ox_chat.no_members'),
              colorToken: ColorToken.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<SectionListViewItem> _buildSectionItems() {
    final sections = <SectionListViewItem>[];
    
    // Sort section keys
    final sortedKeys = _groupedMembers.keys.toList()..sort((a, b) {
      if (a == '#') return 1;
      if (b == '#') return -1;
      return a.compareTo(b);
    });

    for (final key in sortedKeys) {
      final users = _groupedMembers[key]!;
      sections.add(
        SectionListViewItem(
          header: key,
          data: users.map((user) => _buildMemberItem(user)).toList(),
        ),
      );
    }

    return sections;
  }

  CustomItemModel _buildMemberItem(UserDBISAR user) {
    return CustomItemModel(
      leading: OXUserAvatar(
        user: user,
        size: 40.px,
        isClickable: false,
      ),
      titleWidget: CLText.bodyLarge(
        _getUserDisplayName(user),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitleWidget: user.about?.isNotEmpty == true
          ? CLText.bodySmall(
              user.about!,
              colorToken: ColorToken.onSurfaceVariant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : CLText.bodySmall(
              user.encodedPubkey,
              colorToken: ColorToken.onSurfaceVariant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      onTap: () => _onMemberTap(user),
    );
  }

  String _getUserDisplayName(UserDBISAR user) {
    final name = user.name ?? '';
    final nickName = user.nickName ?? '';
    
    if (name.isNotEmpty && nickName.isNotEmpty) {
      return '$name($nickName)';
    } else if (name.isNotEmpty) {
      return name;
    } else if (nickName.isNotEmpty) {
      return nickName;
    }
    return 'Unknown User';
  }

  void _onMemberTap(UserDBISAR user) {
    OXNavigator.pushPage(context, (_) => ContactUserInfoPage(user: user));
  }
}
