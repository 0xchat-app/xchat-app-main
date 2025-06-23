import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ox_chat/utils/chat_session_utils.dart';
import 'package:ox_common/business_interface/ox_chat/utils.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_localizable/ox_localizable.dart';

import 'session_list_data_controller.dart';
import 'session_view_model.dart';

class SessionListWidget extends StatefulWidget {
  const SessionListWidget({
    super.key,
    required this.ownerPubkey,
    required this.circle,
    required this.itemOnTap,
  });

  final String ownerPubkey;
  final Circle circle;
  final Function(SessionListViewModel item) itemOnTap;

  @override
  State<SessionListWidget> createState() => _SessionListWidgetState();
}

class _SessionListWidgetState extends State<SessionListWidget> {
  SessionListDataController? controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(SessionListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize controller if ownerPubkey or circle changed
    if (oldWidget.ownerPubkey != widget.ownerPubkey || 
        oldWidget.circle.id != widget.circle.id) {
      _initializeController();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeController() {
    if (widget.ownerPubkey.isNotEmpty) {
      controller = SessionListDataController(widget.ownerPubkey, widget.circle);
      controller?.initialized();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if controller is not initialized or ownerPubkey is empty
    if (controller == null || widget.ownerPubkey.isEmpty) {
      return Center(
        child: CLProgressIndicator.circular(),
      );
    }

    return ValueListenableBuilder(
      valueListenable: controller!.sessionList$,
      builder: (context, value, _) {
        // Show empty state when no sessions
        if (value.isEmpty) {
          return _buildEmptyState(context);
        }
        
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
          onTap: () => widget.itemOnTap(item),
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
        final bool? confirmed = await CLAlertDialog.show(
          context: context,
          content: Localized.text('ox_chat.message_delete_tips'),
          actions: [
            CLAlertAction.cancel(),
            CLAlertAction<bool>(
              label: Localized.text('ox_common.confirm'),
              value: true,
              isDestructiveAction: true,
            ),
          ],
        );

        if (confirmed == true) {
          controller?.deleteSession(item);
        }
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
      valueListenable: item.entity$,
      builder: (context, entity, _) {
        return ValueListenableBuilder(
          valueListenable: item.groupMember$,
          builder: (context, groupMember, _) {
            final isSingleChat = _AdaptHelperEx(entity).isSingleChat;
            final size = 40.px;
            if (!isSingleChat && groupMember.isNotEmpty) {
              return GroupedAvatar(
                avatars: groupMember,
                size: size,
              );
            }

            return BaseAvatarWidget(
              imageUrl: _AdaptHelperEx(entity).iconUrl,
              defaultImageName: _AdaptHelperEx(entity).defaultIcon,
              size: size,
              isCircular: true,
            );
          }
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

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: 32.px,
        vertical: 100.px,
      ),
      children: [
        // Empty state icon using Material Icons
        CommonImage(
          iconName: 'image_home_emtyp_circle.png',
          size: 280.px,
          package: 'ox_home',
          isPlatformStyle: true,
        ),

        // Title
        CLText.titleMedium(
          Localized.text('ox_chat.no_sessions_title'),
          colorToken: ColorToken.onSurface,
          textAlign: TextAlign.center,
        ).setPaddingOnly(bottom: 8.px),

        // Description
        CLText.bodyMedium(
          Localized.text('ox_chat.no_sessions_description'),
          colorToken: ColorToken.onSurfaceVariant,
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      ],
    );
  }
}

extension _AdaptHelperEx on dynamic {
  String get iconUrl {
    switch (this) {
      case UserDBISAR user:
        return user.picture ?? '';
      case GroupDBISAR group:
        if(group.isDirectMessage == true){
          UserDBISAR? otherUser = Account.sharedInstance.userCache[group.otherPubkey]?.value;
          return otherUser?.picture ?? '';
        } else {
          return group.picture ?? '';
        }
      case ChannelDBISAR channel:
        return channel.picture ?? '';
      case RelayGroupDBISAR relayGroup:
        return relayGroup.picture;
      default:
        assert(false, 'Unknown Type: $runtimeType');
        return '';
    }
  }

  String get defaultIcon {
    switch (this) {
      case UserDBISAR _:
        return 'user_image.png';
      case GroupDBISAR group:
        if(group.isDirectMessage == true){
          return 'user_image.png';
        } else {
          return 'icon_group_default.png';
        }
      case ChannelDBISAR _:
      case RelayGroupDBISAR _:
        return 'icon_group_default.png';
      default:
        assert(false, 'Unknown Type: $runtimeType');
        return '';
    }
  }

  String get name {
    switch (this) {
      case UserDBISAR user:
        return user.getUserShowName();
      case GroupDBISAR group:
        if (group.isDirectMessage == true) {
          UserDBISAR? otherUser = Account.sharedInstance.userCache[group.otherPubkey]?.value;
          return otherUser?.getUserShowName() ?? '';
        } else {
          return group.name;
        }
      case ChannelDBISAR channel:
        return channel.name ?? '';
      case RelayGroupDBISAR relayGroup:
        return relayGroup.name;
      default:
        assert(false, 'Unknown Type: $runtimeType');
        return '';
    }
  }

  bool get isSingleChat {
    switch (this) {
      case UserDBISAR:
        return true;
      case GroupDBISAR(isDirectMessage: final dm):
        return dm;
      case ChannelDBISAR _:
      case RelayGroupDBISAR _:
        return false;
      default:
        assert(false, 'Unknown Type: $runtimeType');
        return false;
    }
  }
}