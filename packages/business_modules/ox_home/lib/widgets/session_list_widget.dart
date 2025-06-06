
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ox_chat/utils/chat_session_utils.dart';
import 'package:ox_common/business_interface/ox_chat/utils.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/widgets/common_hint_dialog.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_localizable/ox_localizable.dart';

import 'session_list_data_controller.dart';
import 'session_view_model.dart';

class SessionListWidget extends StatelessWidget {
  const SessionListWidget({
    super.key,
    required this.controller,
    required this.itemOnTap,
  });

  final SessionListDataController controller;
  final Function(SessionListViewModel item) itemOnTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.sessionList$,
      builder: (context, value, _) {
        return ListView.separated(
          padding: EdgeInsets.only(bottom: Adapt.bottomSafeAreaHeightByKeyboard),
          itemBuilder: (context, index) => itemBuilder(context, value[index]),
          separatorBuilder: separatorBuilder,
          itemCount: value.length,
        );
      },
    );
  }

  Widget? itemBuilder(BuildContext context, SessionListViewModel item) {
    return ValueListenableBuilder(
      valueListenable: item.build$,
      builder: (context, value, _) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => itemOnTap(item),
          child: buildSlidableWrapper(
            context: context,
            item: item,
            child: buildItemContent(context, item)
          ),
        );
      },
    );
  }

  Widget buildSlidableWrapper({
    required BuildContext context,
    required SessionListViewModel item,
    required Widget child,
  }) {
    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.44,
        motion: const ScrollMotion(),
        children:[
          buildMuteAction(
            context: context,
            item: item,
          ),
          buildDeleteAction(
            context: context,
            item: item,
          ),
        ],
      ),
      child: child,
    );
  }

  CustomSlidableAction buildMuteAction({
    required BuildContext context,
    required SessionListViewModel item,
  }) {
    bool isMute = item.isMute;
    return CustomSlidableAction(
      onPressed: (BuildContext _) async {
        await ChatSessionUtils.setChatMute(item.sessionModel, !isMute);
        item.rebuild();
      },
      backgroundColor: ColorToken.primaryContainer.of(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonImage(
            iconName: isMute ? 'icon_unmute.png' : 'icon_mute.png',
            size: 24.px,
            color: ColorToken.onPrimaryContainer.of(context),
            package: 'ox_chat',
          ).setPaddingOnly(bottom: 8.px),
          CLText.labelSmall(
            Localized.text(isMute ? 'ox_chat.un_mute_item' : 'ox_chat.mute_item'),
            colorToken: ColorToken.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  CustomSlidableAction buildDeleteAction({
    required BuildContext context,
    required SessionListViewModel item,
  }) {
    return CustomSlidableAction(
      onPressed: (BuildContext _) async {
        OXCommonHintDialog.show(context,
          content: Localized.text('ox_chat.message_delete_tips'),
          actionList: [
            OXCommonHintAction.cancel(onTap: () {
              OXNavigator.pop(context);
            }),
            OXCommonHintAction.sure(
              text: Localized.text('ox_common.confirm'),
              onTap: () async {
                OXNavigator.pop(context);
                controller.deleteSession(item);
              },
            ),
          ],
          isRowAction: true,
        );
      },
      backgroundColor: ColorToken.error.of(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonImage(
            iconName: 'icon_chat_delete.png',
            size: 24.px,
            color: ColorToken.onError.of(context),
            package: 'ox_chat',
          ).setPaddingOnly(bottom: 8.px),
          CLText.labelSmall(
            Localized.text('ox_chat.delete'),
            colorToken: ColorToken.onError,
          ),
        ],
      ),
    );
  }

  Widget buildItemContent(BuildContext context, SessionListViewModel item) {
    return ValueListenableBuilder(
      valueListenable: item.entity$,
      builder: (context, value, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 8.px),
          child: Row(
            children: [
              _buildItemIcon(item),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 6.px,
                    horizontal: 16.px,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CLText.bodyLarge(
                        _AdaptHelperEx(value).name,
                        customColor: ColorToken.onSurface.of(context),
                        maxLines: 1,
                      ),
                      _buildItemSubtitle(context, item),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CLText.labelSmall(
                    item.updateTime,
                  ).setPadding(EdgeInsets.symmetric(vertical: 4.px)),
                  SizedBox(
                    height: 20.px,
                    child: Center(
                      child: _buildUnreadWidget(context, item),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildItemIcon(SessionListViewModel item) {
    return ValueListenableBuilder(
      valueListenable: item.groupMember$,
      builder: (context, value, _) {
        final size = 40.px;
        if (value.isNotEmpty) {
          return GroupedAvatar(
            avatars: value,
            size: size,
          );
        }
        return BaseAvatarWidget(
          imageUrl: _AdaptHelperEx(item.entity$.value).iconUrl,
          defaultImageName: _AdaptHelperEx(item.entity$.value).defaultIcon,
          size: size,
          isCircular: true,
        );
      }
    );
  }

  Widget _buildItemSubtitle(BuildContext context, SessionListViewModel item) {
    final style = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    String subtitle = item.subtitle;
    final draft = item.draft;
    final isMentioned = item.isMentioned;
    if (!isMentioned && draft.isNotEmpty) {
      subtitle = draft;
    }

    return RichText(
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          if (isMentioned) 
            TextSpan(
              text: '[${Localized.text('ox_chat.session_content_mentioned')}] ',
              style: style.copyWith(color: ColorToken.error.of(context)),
            )
          else if (draft.isNotEmpty)
            TextSpan(
              text: '[${Localized.text('ox_chat.session_content_draft')}] ',
              style: style.copyWith(color: ColorToken.error.of(context)),
            ),
          TextSpan(
            text: subtitle,
            style: style.copyWith(color: ColorToken.onSecondaryContainer.of(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadWidget(BuildContext context, SessionListViewModel item) {
    if (item.isMute) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 5.px),
        child: Badge(
          smallSize: 10.px,
          backgroundColor: ColorToken.primaryContainer.of(context),
        ),
      );
    }
    if (item.unreadCountText.isNotEmpty) {
      return Badge(
        label: Text(item.unreadCountText),
        backgroundColor: ColorToken.error.of(context),
      );
    }
    return const SizedBox.shrink();
  }

  Widget separatorBuilder(BuildContext context, int index) {
    if (PlatformStyle.isUseMaterial) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(left: 72.px),
      child: Container(
        height: 0.5,
        color: CupertinoColors.separator,
      ),
    );
  }
}

extension _AdaptHelperEx on dynamic {
  String get iconUrl {
    final obj = this;
    if (obj is UserDBISAR) {
      return obj.picture ?? '';
    }
    if (obj is GroupDBISAR){
      if(obj.isDirectMessage == true){
        UserDBISAR? otherUser = Account.sharedInstance.userCache[obj.otherPubkey]?.value;
        return otherUser?.picture ?? '';
      }
      else{
        return obj.picture ?? '';
      }
    }
    if (obj is ChannelDBISAR || obj is RelayGroupDBISAR) {
      return obj.picture ?? '';
    }
    return '';
  }

  String get defaultIcon {
    final obj = this;
    if (obj is UserDBISAR) {
      return 'user_image.png';
    }
    if (obj is GroupDBISAR){
      if(obj.isDirectMessage == true){
        return 'user_image.png';
      }
      else{
        return 'icon_group_default.png';
      }
    }
    if (obj is GroupDBISAR || obj is ChannelDBISAR || obj is RelayGroupDBISAR) {
      return 'icon_group_default.png';
    }

    assert(false, 'obj type: ${obj.runtimeType}');
    return '';
  }

  String get name {
    final obj = this;
    if (obj is UserDBISAR) {
      return obj.getUserShowName();
    }
    if (obj is GroupDBISAR){
      if(obj.isDirectMessage == true){
        UserDBISAR? otherUser = Account.sharedInstance.userCache[obj.otherPubkey]?.value;
        return otherUser?.getUserShowName() ?? '';
      }
      else{
        return obj.name;
      }
    }
    if (obj is ChannelDBISAR || obj is RelayGroupDBISAR) {
      return obj.name;
    }
    return '';
  }
}