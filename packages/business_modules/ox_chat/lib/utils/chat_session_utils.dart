import 'package:flutter/material.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import '../page/session/chat_message_page.dart';

class ChatSessionUtils {
  static ValueNotifier? getChatValueNotifier(ChatSessionModelISAR model) {
    ValueNotifier? valueNotifier;

    switch (model.chatType) {
      case ChatType.chatSingle:
        valueNotifier = Account.sharedInstance.getUserNotifier(model.getOtherPubkey);
        break;
      case ChatType.chatGroup:
        valueNotifier = Groups.sharedInstance.getPrivateGroupNotifier(model.chatId);
        break;
      case ChatType.bitchatChannel:
        valueNotifier = ValueNotifier(model.chatId);
    }
    return valueNotifier;
  }

  static String getChatName(ChatSessionModelISAR model) {
    String showName = '';
    switch (model.chatType) {
      case ChatType.chatSingle:
        showName = Account.sharedInstance.userCache[model.getOtherPubkey]?.value.name ?? '';
        break;
      case ChatType.chatGroup:
        showName = Groups.sharedInstance.groups[model.chatId]?.value.name ?? '';
        if (showName.isEmpty) showName = Groups.encodeGroup(model.chatId, null, null);
        break;
      case ChatType.bitchatChannel:
      case ChatType.bitchatPrivate:
        showName = model.chatName ?? '';
        break;
    }
    return showName;
  }

  static String getChatIcon(ChatSessionModelISAR model) {
    String showPicUrl = '';
    switch (model.chatType) {
      case ChatType.chatSingle:
        showPicUrl = Account.sharedInstance.userCache[model.getOtherPubkey]?.value.picture ?? '';
        break;
      case ChatType.chatGroup:
        showPicUrl = Groups.sharedInstance.groups[model.chatId]?.value.picture ?? '';
        break;
    }
    return showPicUrl;
  }

  static String getChatDefaultIcon(ChatSessionModelISAR model) {
    String localAvatarPath = '';
    switch (model.chatType) {
      case ChatType.chatSingle:
        localAvatarPath = 'user_image.png';
        break;
      case ChatType.chatGroup:
        localAvatarPath = 'icon_group_default.png';
        break;
    }
    return localAvatarPath;
  }

  static bool getChatMute(ChatSessionModelISAR model) {
    bool isMute = false;
    switch (model.chatType) {
      case ChatType.chatSingle:
      UserDBISAR? tempUserDB = Account.sharedInstance.userCache[model.chatId]?.value;
        if (tempUserDB != null) {
          isMute = tempUserDB.mute ?? false;
        }
        break;
      case ChatType.chatGroup:
        GroupDBISAR? groupDB = Groups.sharedInstance.groups[model.chatId]?.value;
        if (groupDB != null) {
          isMute = groupDB.mute;
        }
        break;
    }
    return isMute;
  }

  static Widget getTypeSessionView(int chatType, String chatId){
    String? iconName;
    switch (chatType) {
      case ChatType.chatGroup:
        iconName = 'icon_type_private_group.png';
        break;
      default:
        break;
    }
    Widget typeSessionWidget = iconName != null ? CommonImage(iconName: iconName, size: 24.px, package: 'ox_chat',useTheme: true,) : SizedBox();
    return typeSessionWidget;
  }

  static bool checkIsMute(MessageDBISAR message, int type) {
    bool isMute = false;
    switch (type) {
      case ChatType.chatGroup:
        GroupDBISAR? groupDB = Groups.sharedInstance.myGroups[message.groupId]?.value;
        isMute = groupDB?.mute ?? false;
        return isMute;
      default:
        final tempUserDB = Account.sharedInstance.getUserInfo(message.sender);
        isMute = tempUserDB is UserDBISAR ? (tempUserDB.mute ?? false) : false;
        return isMute;
    }
  }

  static Future setChatMute(ChatSessionModelISAR model, bool muteValue) async {
    switch (model.chatType) {
      case ChatType.chatSingle:
        if (muteValue) {
          await Contacts.sharedInstance.muteFriend(model.chatId);
        } else {
          await Contacts.sharedInstance.unMuteFriend(model.chatId);
        }
        break;
      case ChatType.chatGroup:
        if (muteValue) {
          await Groups.sharedInstance.muteGroup(model.chatId);
        } else {
          await Groups.sharedInstance.unMuteGroup(model.chatId);
        }
        break;
    }
    OXUserInfoManager.sharedInstance.setNotification().then((value) {
      if (value) {
        OXChatBinding.sharedInstance.sessionUpdate();
      }
    });
  }

  static void leaveConfirmWidget(BuildContext context, int chatType, String groupId, {bool isGroupOwner = false, bool isGroupMember = false, bool hasDeleteGroupPermission = false}) {
    String title = '';
    String content = '';
    String actionText = '';
    
    if (chatType == ChatType.chatGroup) {
      if (isGroupOwner) {
        title = Localized.text('ox_chat.delete_group_confirm_title');
        content = Localized.text('ox_chat.delete_group_confirm_content');
        actionText = Localized.text('ox_chat.delete_and_leave_item');
      } else {
        title = Localized.text('ox_chat.leave_group_confirm_title');
        content = Localized.text('ox_chat.leave_group_confirm_content');
        actionText = Localized.text('ox_chat.str_leave_group');
      }
    }

    CLAlertDialog.show<bool>(
      context: context,
      title: title,
      content: content,
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: actionText,
          value: true,
          isDestructiveAction: true,
        ),
      ],
    ).then((result) {
      if (result == true) {
        if (chatType == ChatType.chatGroup) {
          leaveGroupFn(context, groupId, isGroupOwner);
        }
      }
    });
  }

  static void leaveRelayGroupFn(BuildContext context, bool hasDeleteGroupPermission, String groupId) async {
    OXLoading.show();
    if(hasDeleteGroupPermission){
      await RelayGroup.sharedInstance.deleteGroup(groupId, 'delete group');
    }
    OKEvent event = await RelayGroup.sharedInstance.leaveGroup(groupId, 'leave group');
    OXUserInfoManager.sharedInstance.setNotification();
    OXLoading.dismiss();
    if (!event.status) {
      CommonToast.instance.show(context, event.message);
      return;
    }
    CommonToast.instance.show(context, Localized.text('ox_chat.leave_group_success_toast'));
    OXNavigator.popToRoot(context);
  }

  // private group
  static void leaveGroupFn(BuildContext context, String groupId, bool isGroupOwner) async {
    UserDBISAR? userInfo = Account.sharedInstance.me;

    OXLoading.show();
    late OKEvent event;
    if (isGroupOwner){
      event = await Groups.sharedInstance
          .deleteAndLeave(groupId, Localized.text('ox_chat.disband_group_toast'));
    } else {
      event = await Groups.sharedInstance.leaveGroup(groupId,
          Localized.text('ox_chat.leave_group_system_message').replaceAll(
              r'${name}', '${userInfo?.name}'));
    }
    OXLoading.dismiss();
    if (!event.status) {
      CommonToast.instance.show(context, event.message);
      return;
    }
    CommonToast.instance.show(context, isGroupOwner ? Localized.text('ox_chat.disband_group_toast') : Localized.text('ox_chat.leave_group_success_toast'));
    OXNavigator.popToRoot(context);
  }

  /// Create a secret chat session with confirmation dialog
  /// Returns true if session was created successfully, false otherwise
  static Future<bool> createSecretChatWithConfirmation({
    required BuildContext context,
    required UserDBISAR user,
    bool isPushWithReplace = false,
  }) async {
    // Validate current account
    final myPubkey = Account.sharedInstance.me?.pubKey;
    if (myPubkey == null || myPubkey.isEmpty) {
      CommonToast.instance.show(context, 'Current account is null');
      return false;
    }

    // Validate current circle
    final circle = LoginManager.instance.currentCircle;
    if (circle == null) {
      CommonToast.instance.show(context, 'Current circle is null');
      return false;
    }

    // Show confirmation dialog
    final bool? confirmed = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_chat.create_secret_chat_confirm_title'),
      content: Localized.text('ox_chat.create_secret_chat_confirm_content'),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_common.confirm'),
          value: true,
          isDefaultAction: true,
        ),
      ],
    );

    // If user cancelled, return false
    if (confirmed != true) {
      return false;
    }

    // Show loading
    await OXLoading.show();

    try {
      // Create group name
      String groupName = '${user.name} & ${Account.sharedInstance.me!.name}';
      
      // Create MLS group
      GroupDBISAR? groupDB = await Groups.sharedInstance.createMLSGroup(
        groupName,
        '',
        [user.pubKey, myPubkey],
        [myPubkey],
        [circle.relayUrl],
      );

      if (groupDB == null) {
        await OXLoading.dismiss();
        CommonToast.instance.show(context, Localized.text('ox_chat.create_group_fail_tips'));
        return false;
      }

      await OXLoading.dismiss();

      // Navigate to chat page
      ChatMessagePage.open(
        context: null,
        communityItem: ChatSessionModelISAR(
          chatId: groupDB.privateGroupId,
          groupId: groupDB.privateGroupId,
          chatType: ChatType.chatGroup,
          chatName: groupDB.name,
          createTime: groupDB.updateTime,
          avatar: groupDB.picture,
        ),
        isPushWithReplace: isPushWithReplace,
      );

      return true;
    } catch (e) {
      await OXLoading.dismiss();
      CommonToast.instance.show(context, e.toString());
      return false;
    }
  }
}
