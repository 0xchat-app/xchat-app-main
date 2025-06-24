import 'package:flutter/widgets.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_usercenter/page/settings/single_setting_page.dart';

class GroupNameSettingsPage extends StatelessWidget {
  const GroupNameSettingsPage({
    super.key,
    required this.groupInfo,
    this.previousPageTitle,
  });

  final GroupDBISAR groupInfo;
  final String? previousPageTitle;

  @override
  Widget build(BuildContext context) {
    return SingleSettingPage(
      previousPageTitle: previousPageTitle,
      title: Localized.text('ox_chat.edit_group_name'),
      initialValue: groupInfo.name,
      saveAction: (context, value) => _updateGroupName(context, value),
    );
  }

  void _updateGroupName(BuildContext context, String newGroupName) async {
    if (newGroupName.isEmpty) {
      CommonToast.instance.show(
        context, 
        Localized.text('ox_chat.edit_group_name_not_empty_toast'),
      );
      return;
    }

    // Check if the name is the same
    if (groupInfo.name == newGroupName) {
      OXNavigator.pop(context);
      return;
    }

    final currentUser = Account.sharedInstance.me;
    if (currentUser == null) {
      CommonToast.instance.show(context, 'Current user info is null.');
      return;
    }

    try {
      final result = await Groups.sharedInstance.updatePrivateGroupName(
        currentUser.pubKey,
        groupInfo.privateGroupId,
        newGroupName,
      );

      if (result.status) {
        // Trigger notifier update for all related pages
        final notifier = Groups.sharedInstance.getPrivateGroupNotifier(groupInfo.privateGroupId);
        final updatedGroup = GroupDBISAR(
          groupId: groupInfo.groupId,
          owner: groupInfo.owner,
          updateTime: DateTime.now().millisecondsSinceEpoch,
          mute: groupInfo.mute,
          name: newGroupName,
          members: groupInfo.members,
          pinned: groupInfo.pinned,
          about: groupInfo.about,
          picture: groupInfo.picture,
          relay: groupInfo.relay,
          isMLSGroup: groupInfo.isMLSGroup,
          isDirectMessage: groupInfo.isDirectMessage,
          mlsGroupId: groupInfo.mlsGroupId,
          epoch: groupInfo.epoch,
          adminPubkeys: groupInfo.adminPubkeys,
          welcomeWrapperEventId: groupInfo.welcomeWrapperEventId,
          welcomeEventString: groupInfo.welcomeEventString,
        );
        notifier.value = updatedGroup;
        
        OXNavigator.pop(context, true);
      } else {
        CommonToast.instance.show(context, result.message);
      }
    } catch (e) {
      CommonToast.instance.show(context, 'Update group name failed: $e');
    }
  }
} 