
import 'package:flutter/material.dart';
import 'package:ox_chat/utils/chat_session_utils.dart';
import 'package:ox_common/business_interface/ox_chat/utils.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/date_utils.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_localizable/ox_localizable.dart';

class SessionListViewModel {
  SessionListViewModel(this._raw) {
    updateGroupMemberIfNeeded();
  }

  final ChatSessionModelISAR _raw;
  ChatSessionModelISAR get sessionModel => _raw;

  late ValueNotifier entity$ = ChatSessionUtils.getChatValueNotifier(_raw)
      ?? ValueNotifier(null);

  final ValueNotifier<bool> _build$ = ValueNotifier(false);

  final ValueNotifier<List<String>> groupMember$ = ValueNotifier([]);

  String get subtitle => _raw.content ?? '';
  String get draft => _raw.draft ?? '';
  bool get isMentioned => _raw.mentionMessageIds.isNotEmpty;

  String get updateTime => OXDateUtils.convertTimeFormatString2(_raw.createTime * 1000, pattern: 'MM-dd');

  String get unreadCountText {
    final count = _raw.unreadCount;
    if (count > 99) return '99+';
    if (count > 0 ) return count.toString();
    return '';
  }

  void updateGroupMemberIfNeeded() async {
    if (_raw.hasMultipleUsers) {
      final groupId = _raw.groupId ?? '';
      List<UserDBISAR> groupList = await Groups.sharedInstance.getAllGroupMembers(groupId);
      List<String> avatars = groupList.map((e) => e.picture ?? '').toList();
      avatars.removeWhere((e) => e.isEmpty);

      groupMember$.value = avatars;
    }
  }

  void rebuild() {
    _build$.value = !_build$.value;
  }
}

class SessionListDataController {
  ValueNotifier<List<SessionListViewModel>> sessionList$ = ValueNotifier([]);

  initialized() {
    final data = OXChatBinding.sharedInstance.sessionList;

    data.sort((session1, session2) =>
      session2.createTime.compareTo(session1.createTime),
    );

    sessionList$.value = data.map((e) => SessionListViewModel(e)).toList();
  }
}

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
      valueListenable: item._build$,
      builder: (context, value, _) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => itemOnTap(item),
          child: buildItemContent(context, item),
        );
      }
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
              _buildItemIcon(item).setPaddingOnly(right: 16.px),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.px),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CLText.bodyLarge(
                        _AdaptHelperEx(value).name,
                        customColor: ColorToken.onSurface.of(context),
                      ),
                      _buildItemSubtitle(context, item),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CLText.labelSmall(
                    item.updateTime,
                  ),
                  if (item.unreadCountText.isNotEmpty)
                    Badge(label: Text(item.unreadCountText),).setPaddingOnly(top: 4.px),
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

  Widget separatorBuilder(BuildContext context, int index) {
    return const SizedBox.shrink();
  }
}

extension _AdaptHelperEx on dynamic {
  String get iconUrl {
    final obj = this;
    if (obj is UserDBISAR) {
      return obj.picture ?? '';
    }
    if (obj is GroupDBISAR || obj is ChannelDBISAR || obj is RelayGroupDBISAR) {
      return obj.picture ?? '';
    }
    return '';
  }

  String get defaultIcon {
    final obj = this;
    if (obj is UserDBISAR) {
      return 'user_image.png';
    }
    if (obj is GroupDBISAR || obj is ChannelDBISAR || obj is RelayGroupDBISAR) {
      return 'icon_group_default.png';
    }
    return '';
  }

  String get name {
    final obj = this;
    if (obj is UserDBISAR) {
      return obj.getUserShowName();
    }
    if (obj is GroupDBISAR || obj is ChannelDBISAR || obj is RelayGroupDBISAR) {
      return obj.name;
    }
    return '';
  }
}