
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_chat/widget/message_long_press_widget.dart';
import 'package:ox_chat_ui/ox_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ox_chat/utils/general_handler/chat_general_handler.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/platform_utils.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/widgets/common_image_gallery.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:photo_view/photo_view.dart' show PhotoViewComputedScale;

class ChatPageConfig {

  static const messagesPerPage = 15;

  /// New context menu builder using super_context_menu (preferred)
  Widget contextMenuBuilder({
    required BuildContext context,
    required types.Message message,
    required Widget child,
    required ChatGeneralHandler handler,
  }) {
    return MessageLongPressMenu.buildContextMenuWidget(
      context: context,
      message: message,
      handler: handler,
      child: child,
    );
  }

  ImageGalleryOptions get imageGalleryOptions =>
      ImageGalleryOptions(
        maxScale: PhotoViewComputedScale.covered,
        minScale: PhotoViewComputedScale.contained,
      );

  List<InputMoreItem> inputMoreItemsWithHandler(ChatGeneralHandler handler) {
    bool isMobile = PlatformUtils.isMobile;
    final items = [
      InputMoreItemEx.album(handler),
      if(isMobile) InputMoreItemEx.camera(handler),
      if(isMobile) InputMoreItemEx.video(handler),
      // InputMoreItemEx.ecash(handler),
    ];

    // final otherUser = handler.otherUser;
    // if (handler.session.chatType == ChatType.chatSingle && otherUser != null) {
    //   items.add(InputMoreItemEx.zaps(handler, otherUser));
    //   if(isMobile){
    //     items.add(InputMoreItemEx.call(handler, otherUser));
    //   }
    // }

    return items;
  }

  ChatTheme get pageTheme =>
      DefaultChatTheme(
        sentMessageBodyTextStyle: TextStyle(
          color: ThemeColor.white,
          fontSize: Adapt.sp(16),
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        receivedMessageBodyTextStyle: TextStyle(
          color: ThemeColor.color0,
          fontSize: Adapt.sp(16),
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        inputTextColor: ThemeColor.color0,
      );
}

extension InputMoreItemEx on InputMoreItem {

  static InputMoreItem album(ChatGeneralHandler handler) =>
      InputMoreItem(
        id: 'album',
        title: () => Localized.text('ox_chat_ui.input_more_album'),
        icon: CupertinoIcons.photo,
        action: (context) {
          handler.albumPressHandler(context, 1);
        },
      );

  static InputMoreItem camera(ChatGeneralHandler handler) =>
      InputMoreItem(
        id: 'camera',
        title: () => Localized.text('ox_chat_ui.input_more_camera'),
        icon: CupertinoIcons.camera,
        action: (context) {
          handler.cameraPressHandler(context);
        },
      );

  static InputMoreItem video(ChatGeneralHandler handler) =>
      InputMoreItem(
        id: 'video',
        title: () => Localized.text('ox_chat_ui.input_more_video'),
        icon: CupertinoIcons.video_camera,
        action: (context) {
          handler.albumPressHandler(context, 2);
        },
      );
}
