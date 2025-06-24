import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/multi_user_selector.dart';
import 'package:ox_localizable/ox_localizable.dart';

class GroupAddMembersPage extends StatefulWidget {
  const GroupAddMembersPage({
    super.key,
    required this.groupInfo,
    this.previousPageTitle,
  });

  final GroupDBISAR groupInfo;
  final String? previousPageTitle;

  @override
  State<GroupAddMembersPage> createState() => _GroupAddMembersPageState();
}

class _GroupAddMembersPageState extends State<GroupAddMembersPage> {
  List<SelectableUser> _selectedUsers = [];
  late Future<List<SelectableUser>> _availableUsersFuture;

  @override
  void initState() {
    super.initState();
    _availableUsersFuture = _loadAvailableUsers();
  }

  Future<List<SelectableUser>> _loadAvailableUsers() async {
    // Get all users from userCache and exclude current user
    final myPubkey = Account.sharedInstance.me?.pubKey;
    final allUsers = Account.sharedInstance.userCache.values
        .map((e) => e.value)
        .where((u) => myPubkey == null || u.pubKey != myPubkey)
        .toList();
    
    // Get current group members
    final groupMembers = await Groups.sharedInstance.getAllGroupMembers(widget.groupInfo.privateGroupId);
    final memberPubkeys = groupMembers.map((user) => user.pubKey).toSet();
    
    // Filter out users who are already in the group
    final availableUsers = allUsers.where((user) => !memberPubkeys.contains(user.pubKey)).toList();
    
    return availableUsers.map((user) => SelectableUser(
      id: user.pubKey,
      displayName: _getUserDisplayName(user),
      avatarUrl: user.picture ?? '',
    )).toList();
  }

  void _onSelectionChanged(List<SelectableUser> selectedUsers) {
    setState(() {
      _selectedUsers = selectedUsers;
    });
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
    return 'Unknown';
  }

  Future<void> _addSelectedMembers() async {
    if (_selectedUsers.isEmpty) {
      CommonToast.instance.show(context, Localized.text('ox_chat.create_group_select_toast'));
      return;
    }

    await OXLoading.show();
    
    try {
      final memberPubkeys = _selectedUsers.map((user) => user.id).toList();
      final result = await Groups.sharedInstance.addMembersToPrivateGroup(
        widget.groupInfo.privateGroupId,
        memberPubkeys,
      );

      await OXLoading.dismiss();

      if (result != null) {
        // Trigger notifier update
        final notifier = Groups.sharedInstance.getPrivateGroupNotifier(widget.groupInfo.privateGroupId);
        notifier.value = result;
        
        CommonToast.instance.show(context, Localized.text('ox_chat.add_member_success_tips'));
        OXNavigator.pop(context, true);
      } else {
        CommonToast.instance.show(context, Localized.text('ox_chat.add_member_fail_tips'));
      }
    } catch (e) {
      await OXLoading.dismiss();
      CommonToast.instance.show(context, 'Failed to add members: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SelectableUser>>(
      future: _availableUsersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CLScaffold(
            appBar: CLAppBar(
              title: Localized.text('ox_chat.add_member_title'),
              previousPageTitle: widget.previousPageTitle,
            ),
            body: Center(
              child: CLProgressIndicator.circular(),
            ),
          );
        }

        if (snapshot.hasError) {
          return CLScaffold(
            appBar: CLAppBar(
              title: Localized.text('ox_chat.add_member_title'),
              previousPageTitle: widget.previousPageTitle,
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(32.px),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.px,
                      color: ColorToken.error.of(context),
                    ),
                    SizedBox(height: 16.px),
                    CLText.bodyLarge(
                      'Failed to load contacts: ${snapshot.error}',
                      colorToken: ColorToken.error,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final availableUsers = snapshot.data ?? [];

        if (availableUsers.isEmpty) {
          return CLScaffold(
            appBar: CLAppBar(
              title: Localized.text('ox_chat.add_member_title'),
              previousPageTitle: widget.previousPageTitle,
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(32.px),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64.px,
                      color: ColorToken.onSurfaceVariant.of(context),
                    ),
                    SizedBox(height: 16.px),
                    CLText.bodyLarge(
                      Localized.text('ox_chat.no_contacts_added'),
                      colorToken: ColorToken.onSurfaceVariant,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return CLMultiUserSelector(
          users: availableUsers,
          onChanged: _onSelectionChanged,
          title: '${Localized.text('ox_chat.add_member_title')} ${_selectedUsers.isNotEmpty ? '(${_selectedUsers.length})' : ''}',
          actions: [
            if (_selectedUsers.isNotEmpty)
              CLButton.text(
                text: Localized.text('ox_common.confirm'),
                onTap: _addSelectedMembers,
              ),
          ],
        );
      },
    );
  }
} 