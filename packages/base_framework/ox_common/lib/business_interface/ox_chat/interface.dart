
import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_common/utils/custom_uri_helper.dart';
import 'package:ox_module_service/ox_module_service.dart';

class OXChatInterface {

  static const moduleName = 'ox_chat';

  static void sendTemplateMessage(
    BuildContext? context, {
      String receiverPubkey = '',
      String title = '',
      String subTitle = '',
      String icon = '',
      String link = '',
      int chatType = ChatType.chatSingle,
    }) {
    OXModuleService.invoke(
      moduleName,
      'sendTemplateMessage',
      [context],
      {
        #receiverPubkey: receiverPubkey,
        #title: title,
        #subTitle: subTitle,
        #icon: icon,
        #link: link,
        #chatType: chatType,
      },
    );
  }

  static Future<String?> tryDecodeNostrScheme(String content) async {
    String? result = await OXModuleService.invoke<Future<String?>>(
      moduleName,
      'getTryDecodeNostrScheme',
      [content],
    );
    return result;
  }

  static void addContact(BuildContext context) {
    OXModuleService.invoke(
      moduleName,
      'addContact',
      [context],
    );
  }

  static void addGroup(BuildContext context) {
    OXModuleService.invoke(
      moduleName,
      'addGroup',
      [context],
    );
  }

  static Widget chatSessionListPageWidget(BuildContext context,) {
    return OXModuleService.invoke<Widget>(
      'ox_chat',
      'chatSessionListPageWidget',
      [context],
    ) ?? const SizedBox();
  }
}
