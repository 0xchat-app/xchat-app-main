import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ox_chat/utils/chat_session_utils.dart';
import 'package:ox_chat/utils/widget_tool.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/widgets/common_image.dart';

class SessionLongPressMenuDialog extends StatefulWidget{
  final ChatSessionModelISAR communityItem;
  SessionLongPressMenuDialog({required this.communityItem});

  static showDialog({
    required BuildContext context,
    required ChatSessionModelISAR communityItem,
    required Widget pageWidget,
    bool isPushWithReplace = false,
    bool isLongPressShow = false,
  }) {
    double screenHeight = MediaQuery.of(context).size.height;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      routeSettings: OXRouteSettings(isShortLived: true),
      transitionBuilder: (context, animation1, animation2, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            OXNavigator.pop(context);
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
              ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation1,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(
                      left: 20.px,
                      top: screenHeight * 0.15,
                      right: 20.px,
                      bottom: 44.px),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.px),
                          child: pageWidget,
                        ),
                      ),
                      SizedBox(height: 8.px),
                      SessionLongPressMenuDialog(communityItem: communityItem),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) => Container(),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _SessionLongPressMenuDialogState();
  }

}

class _SessionLongPressMenuDialogState extends State<SessionLongPressMenuDialog>{
  late List<SessionMenuOptionModel> _menulist = [];
  bool isMute = false;

  @override
  void initState() {
    super.initState();
    isMute = ChatSessionUtils.getChatMute(widget.communityItem);;
    _menulist = SessionMenuOptionModel.getOptionModelList(isMute: isMute, unreadCount: widget.communityItem.unreadCount);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 180.px, maxWidth: MediaQuery.of(context).size.width * 0.6),
      alignment: Alignment.bottomRight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.px),
        color: ThemeColor.color180.withOpacity(0.72),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        reverse: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _menulist.length,
        itemBuilder: (context, index) {
          SessionMenuOptionModel model = _menulist[index];
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              SessionMenuOptionModel.optionsOnTap(context, model.optionEnum, widget.communityItem, isMute: isMute);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 10.px),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    model.content,
                    style: TextStyle(
                      fontSize: 14.px,
                      color: model.optionEnum == LongPressOptionEnum.delete ? ThemeColor.red : ThemeColor.color100,
                    ),
                  ),
                  CommonImage(
                    iconName: model.iconName,
                    size: 24.px,
                    package: 'ox_chat',
                    color: model.optionEnum == LongPressOptionEnum.delete ? ThemeColor.red : ThemeColor.color100,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}


enum LongPressOptionEnum {
  markAsUnreadOrRead,
  muteOrUnmute,
  delete,
}

class SessionMenuOptionModel {
  LongPressOptionEnum optionEnum;
  String content;
  String iconName;

  SessionMenuOptionModel({
    this.optionEnum = LongPressOptionEnum.markAsUnreadOrRead,
    this.content = '',
    this.iconName = '',
  });

  static List<SessionMenuOptionModel> getOptionModelList({bool isMute = false, int unreadCount = 0}) {
    List<SessionMenuOptionModel> list = [];
    list.add(
      SessionMenuOptionModel(
        content: 'delete'.localized(),
        iconName: 'icon_chat_delete.png',
        optionEnum: LongPressOptionEnum.delete,
      ),
    );
    list.add(
      SessionMenuOptionModel(
        content: isMute ? 'un_mute_item'.localized() : 'mute_item'.localized(),
        iconName: isMute ? 'icon_unmute.png' : 'icon_mute.png',
        optionEnum: LongPressOptionEnum.muteOrUnmute,
      ),
    );
    list.add(
      SessionMenuOptionModel(
        content: unreadCount > 0 ? 'str_mark_as_read'.localized() : 'str_mark_as_unread'.localized(),
        iconName: unreadCount > 0 ? 'icon_chat_mark_as_read.png' : 'icon_chat_mark_as_unread.png',
        optionEnum: LongPressOptionEnum.markAsUnreadOrRead,
      ),
    );
    return list;
  }

  static void optionsOnTap(BuildContext context, LongPressOptionEnum optionModel, ChatSessionModelISAR sessionModelISAR, {bool isMute = false}) async {
    if (optionModel == LongPressOptionEnum.markAsUnreadOrRead) {
      var unreadCount = sessionModelISAR.unreadCount;
      if (unreadCount > 0) {
        unreadCount = 0;
      } else {
        unreadCount = 1;
      }
      OXChatBinding.sharedInstance.updateChatSession(sessionModelISAR.chatId, unreadCount: unreadCount);
    } else if (optionModel == LongPressOptionEnum.muteOrUnmute) {
      bool value = !isMute;
      ChatSessionUtils.setChatMute(sessionModelISAR, value);
    } else if (optionModel == LongPressOptionEnum.delete) {
      await OXChatBinding.sharedInstance.deleteSession([sessionModelISAR.chatId]);
    }
    OXNavigator.pop(context);
  }
}
