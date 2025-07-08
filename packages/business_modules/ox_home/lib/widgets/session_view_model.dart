import 'package:flutter/foundation.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_chat/utils/chat_session_utils.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/utils/date_utils.dart';
import 'package:ox_common/utils/extension.dart';

class SessionListViewModel {
  SessionListViewModel(this._raw) {
    updateGroupMemberIfNeeded();
  }

  final ChatSessionModelISAR _raw;
  ChatSessionModelISAR get sessionModel => _raw;

  late ValueNotifier entity$ =
      ChatSessionUtils.getChatValueNotifier(_raw) ?? ValueNotifier(null);

  final ValueNotifier<bool> build$ = ValueNotifier(false);

  final ValueNotifier<List<String>> groupMember$ = ValueNotifier([]);

  String get subtitle => _raw.content ?? '';
  String get draft => _raw.draft ?? '';
  bool get isMentioned => _raw.mentionMessageIds.isNotEmpty;
  bool get isMute => ChatSessionUtils.getChatMute(sessionModel);

  String get updateTime =>
      OXDateUtils.convertTimeFormatString2(_raw.createTime,
          pattern: 'MM-dd');

  String get unreadCountText {
    final count = _raw.unreadCount;
    if (count > 99) return '99+';
    if (count > 0) return count.toString();
    return '';
  }

  void updateGroupMemberIfNeeded() async {
    if (_raw.hasMultipleUsers) {
      final groupId = _raw.groupId ?? '';
      List<UserDBISAR> groupList =
          await Groups.sharedInstance.getAllGroupMembers(groupId);
      List<String> avatars = groupList.map((e) => e.picture ?? '').toList();
      avatars.removeWhere((e) => e.isEmpty);

      groupMember$.value = avatars;
    }
  }

  void rebuild() {
    build$.safeUpdate(!build$.value);
  }
}
