import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_chat/page/session/bitchat_channel_message_page.dart';
import 'package:ox_chat/page/session/chat_group_message_page.dart';
import 'package:ox_chat/utils/general_handler/chat_general_handler.dart';
import 'package:ox_chat/widget/session_longpress_menu_dialog.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';

class ChatMessagePage {
  static Future<T?> open<T>({
    required BuildContext? context,
    required ChatSessionModelISAR communityItem,
    String? anchorMsgId,
    int? unreadMessageCount,
    bool isPushWithReplace = false,
    bool isLongPressShow = false,
  }) async {
    final isSupportType = [
      ChatType.chatGroup,
      ChatType.bitchatChannel,
    ].contains(communityItem.chatType);
    if (!isSupportType) return null;

    final handlerCreator = () {
      final handler = ChatGeneralHandler(
        session: communityItem,
        anchorMsgId: anchorMsgId,
        unreadMessageCount: unreadMessageCount ?? 0,
      );
      handler.initializeMessage();
      return handler;
    };

    Widget pageWidget;
    ChatGeneralHandler handler;
    final chatType = communityItem.chatType;
    switch (chatType) {
      case ChatType.chatGroup:
        handler = handlerCreator();
        pageWidget = ChatGroupMessagePage(
          handler: handler,
        );
        break;
      case ChatType.bitchatChannel:
        handler = handlerCreator();
        pageWidget = BitchatChannelMessagePage(
          handler: handler,
        );
        break;
      default:
        return null;
    }

    context ??= OXNavigator.navigatorKey.currentContext!;
    if (isLongPressShow) {
      handler.isPreviewMode = true;
      return SessionLongPressMenuDialog.showDialog(context: context, communityItem: communityItem, pageWidget: pageWidget);
    }
    if (isPushWithReplace) {
      return OXNavigator.pushReplacement(context, pageWidget);
    }
    return OXNavigator.pushPage(context, (context) => pageWidget);
  }
}
