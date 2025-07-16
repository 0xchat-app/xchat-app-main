import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/multi_user_selector.dart';
import 'package:ox_localizable/ox_localizable.dart';
import '../../../utils/selectable_user_search_manager.dart';

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
  late SelectableUserSearchManager _searchManager;

  @override
  void initState() {
    super.initState();
    _searchManager = SelectableUserSearchManager();
    _availableUsersFuture = _loadAvailableUsers();
  }

  @override
  void dispose() {
    _searchManager.dispose();
    super.dispose();
  }

  Future<List<SelectableUser>> _loadAvailableUsers() async {
    // Get current user pubkey
    final myPubkey = LoginManager.instance.currentPubkey;
    
    // Get current group members
    final groupMembers = await Groups.sharedInstance.getAllGroupMembers(widget.groupInfo.privateGroupId);
    final memberPubkeys = groupMembers.map((user) => user.pubKey).toSet();
    
    // Add current user to excluded list
    final excludedPubkeys = <String>{...memberPubkeys};
    excludedPubkeys.add(myPubkey);

    
    // Initialize search manager with excluded users
    await _searchManager.initialize(excludeUserPubkeys: excludedPubkeys.toList());
    
    return _searchManager.allUsers;
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

  void _onSelectionChanged(List<SelectableUser> selectedUsers) {
    if (mounted) {
      setState(() {
        _selectedUsers = selectedUsers;
      });
    }
  }



  Future<void> _addSelectedMembers() async {
    if (_selectedUsers.isEmpty) {
      if (!mounted) return;
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

        if (!mounted) return;
        CommonToast.instance.show(context, Localized.text('ox_chat.add_member_success_tips'));
        OXNavigator.pop(context, true);
      } else {
        if (!mounted) return;
        CommonToast.instance.show(context, Localized.text('ox_chat.add_member_fail_tips'));
      }
    } catch (e) {
      await OXLoading.dismiss();
      if (!mounted) return;
      CommonToast.instance.show(context, 'Failed to add members: $e');
    }
  }
} 