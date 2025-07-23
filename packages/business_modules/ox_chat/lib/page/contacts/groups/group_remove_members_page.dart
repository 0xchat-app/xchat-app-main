import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/multi_user_selector.dart';
import 'package:ox_localizable/ox_localizable.dart';

class GroupRemoveMembersPage extends StatefulWidget {
  const GroupRemoveMembersPage({
    super.key,
    required this.groupInfo,
    this.previousPageTitle,
  });

  final GroupDBISAR groupInfo;
  final String? previousPageTitle;

  @override
  State<GroupRemoveMembersPage> createState() => _GroupRemoveMembersPageState();
}

class _GroupRemoveMembersPageState extends State<GroupRemoveMembersPage> {
  List<SelectableUser> _selectedUsers = [];
  late Future<List<String>> _removableMemberPubkeysFuture;

  @override
  void initState() {
    super.initState();
    _removableMemberPubkeysFuture = _loadRemovableMembers();
  }

  Future<List<String>> _loadRemovableMembers() async {
    // Get current group members
    final groupMembers = await Groups.sharedInstance.getAllGroupMembers(widget.groupInfo.privateGroupId);
    
    // Filter out users that cannot be removed:
    // 1. Group owner (can't remove owner)
    // 2. Current user (can't remove self)
    final currentUser = Account.sharedInstance.me;
    final removableMembers = groupMembers.where((user) => 
      user.pubKey != widget.groupInfo.owner && 
      user.pubKey != currentUser?.pubKey
    ).toList();
    
    return removableMembers.map((user) => user.pubKey).toList();
  }

  void _onSelectionChanged(List<SelectableUser> selectedUsers) {
    if (mounted) {
      setState(() {
        _selectedUsers = selectedUsers;
      });
    }
  }

  Future<void> _removeSelectedMembers() async {
    if (_selectedUsers.isEmpty) {
      if (!mounted) return;
      CommonToast.instance.show(context, Localized.text('ox_chat.select_at_least_one_member'));
      return;
    }

    // Show confirmation dialog
    final bool? confirmed = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_chat.remove_member_title'),
      content: Localized.text('ox_chat.remove_member_confirm_content')
          .replaceAll('{count}', _selectedUsers.length.toString()),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_common.confirm'),
          value: true,
          isDestructiveAction: true,
        ),
      ],
    );

    if (confirmed != true) return;

    await OXLoading.show();
    
    try {
      final memberPubkeys = _selectedUsers.map((user) => user.id).toList();
      final result = await Groups.sharedInstance.removeMembersFromPrivateGroup(
        widget.groupInfo.privateGroupId,
        memberPubkeys,
      );

      await OXLoading.dismiss();

      if (result != null) {
        // Trigger notifier update
        final notifier = Groups.sharedInstance.getPrivateGroupNotifier(widget.groupInfo.privateGroupId);
        notifier.value = result;
        
        if (!mounted) return;
        CommonToast.instance.show(context, Localized.text('ox_chat.remove_member_success_tips'));
        OXNavigator.pop(context, true);
      } else {
        if (!mounted) return;
        CommonToast.instance.show(context, Localized.text('ox_chat.remove_member_fail_tips'));
      }
    } catch (e) {
      await OXLoading.dismiss();
      if (!mounted) return;
      CommonToast.instance.show(context, 'Failed to remove members: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _removableMemberPubkeysFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CLScaffold(
            appBar: CLAppBar(
              title: Localized.text('ox_chat.remove_member_title'),
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
              title: Localized.text('ox_chat.remove_member_title'),
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
                      'Failed to load group members: ${snapshot.error}',
                      colorToken: ColorToken.error,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final removableMembers = snapshot.data ?? [];

        if (removableMembers.isEmpty) {
          return CLScaffold(
            appBar: CLAppBar(
              title: Localized.text('ox_chat.remove_member_title'),
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
                      Localized.text('ox_chat.no_removable_members'),
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
          userPubkeys: removableMembers,
          onChanged: _onSelectionChanged,
          title: '${Localized.text('ox_chat.remove_member_title')} ${_selectedUsers.isNotEmpty ? '(${_selectedUsers.length})' : ''}',
          actions: [
            if (_selectedUsers.isNotEmpty)
              CLButton.text(
                text: Localized.text('ox_common.confirm'),
                onTap: _removeSelectedMembers,
              ),
          ],
        );
      },
    );
  }
} 