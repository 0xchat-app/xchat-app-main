import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/widgets/multi_user_selector.dart';
import 'package:ox_localizable/ox_localizable.dart';

import 'group_creation_page.dart';

class SelectGroupMembersPage extends StatefulWidget {
  const SelectGroupMembersPage({super.key});

  @override
  State<SelectGroupMembersPage> createState() => _SelectGroupMembersPageState();
}

class _SelectGroupMembersPageState extends State<SelectGroupMembersPage> {
  List<SelectableUser> _selectedUsers = [];


  @override
  Widget build(BuildContext context) {
    return CLMultiUserSelector(
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