import 'package:chatcore/chat-core.dart';
import 'package:ox_chat/model/option_model.dart';
import 'package:ox_chat/utils/general_handler/chat_general_handler.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_common/utils/custom_uri_helper.dart';

class ChatSendInvitedTemplateHelper {
  static sendGroupInvitedTemplate(List<UserDBISAR> selectedUserList,String groupId, GroupType groupType){
    final inviterName = Account.sharedInstance.me?.name ?? Account.sharedInstance.me?.nickName ?? '';
    final inviterPubKey = Account.sharedInstance.me?.pubKey;
    String groupName = '';
    String groupOwner = '';
    String groupPic = '';
    if (groupType == GroupType.privateGroup) {
      GroupDBISAR? groupDB = Groups.sharedInstance.groups[groupId]?.value;
      groupName = groupDB?.name ?? '';
      groupOwner = groupDB?.owner ?? '';
      groupPic = groupDB?.picture ?? '';
      String link = CustomURIHelper.createModuleActionURI(module: 'ox_chat', action: 'groupSharePage', params: {
        'groupPic': groupPic,
        'groupName': groupName,
        'groupId': groupId,
        'inviterPubKey': inviterPubKey,
        'groupOwner': groupOwner,
        'groupTypeIndex': groupType.index,
      });
      selectedUserList.forEach((element) {
        ChatMessageSendEx.sendTemplateMessage(
          receiverPubkey: element.pubKey,
          icon: 'icon_group_default.png',
          title: 'Group Chat Invitation',
          subTitle: '${inviterName} invited you to join this Group "${groupName}"',
          link: link,
        );
      });
    } else if (groupType == GroupType.openGroup || groupType == GroupType.closeGroup) {
      RelayGroupDBISAR? groupDB = RelayGroup.sharedInstance.groups[groupId]?.value;
      groupName = groupDB?.name ?? '';
      groupOwner = groupDB?.author ?? '';
      groupPic = groupDB?.picture ?? '';
      String shareContent = RelayGroup.sharedInstance.encodeGroup(groupId) ?? '';
      selectedUserList.forEach((element) {
        ChatMessageSendEx.sendTextMessageHandler(
          element.pubKey,
          shareContent,
          chatType: ChatType.chatSingle,
        );
      });
    }
  }
}