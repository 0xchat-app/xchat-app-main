import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/widgets/multi_user_selector.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:chatcore/chat-core.dart';

import 'group_creation_page.dart';
import '../../utils/chat_user_utils.dart';

class SelectGroupMembersPage extends StatefulWidget {
  const SelectGroupMembersPage({super.key});

  @override
  State<SelectGroupMembersPage> createState() => _SelectGroupMembersPageState();
}

class _SelectGroupMembersPageState extends State<SelectGroupMembersPage> {
  List<SelectableUser> _users = [];
  List<SelectableUser> _selectedUsers = [];
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    try {
      final allUsers = await ChatUserUtils.getAllUsers();

      // Convert to SelectableUser
      _users = allUsers.map((user) => SelectableUser(
        id: user.pubKey,
        displayName: _getUserShowName(user),
        avatarUrl: user.picture ?? '',
      )).toList();
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      setState(() {
        _isLoadingUsers = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return CLMultiUserSelector(
      users: _isLoadingUsers ? [] : _users,
      title: Localized.text('ox_chat.str_new_group'),
      onChanged: _onSelectionChanged,
      actions: [
        CLButton.text(
          text: Localized.text('ox_common.next'),
          onTap: _selectedUsers.isNotEmpty ? _onNextTapped : null,
        ),
      ],
    );
  }

  void _onSelectionChanged(List<SelectableUser> selectedUsers) {
    setState(() {
      _selectedUsers = selectedUsers;
    });
  }

  void _onNextTapped() {
    // Navigate to group creation page with selected users
    OXNavigator.pushPage(context, (context) => GroupCreationPage(selectedUsers: _selectedUsers));
  }
} 