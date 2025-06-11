import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:chatcore/chat-core.dart';
import 'package:isar/isar.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/ox_chat_observer.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';

import 'session_view_model.dart';

class SessionListDataController with OXChatObserver {
  SessionListDataController(this.ownerPubkey, this.circle);
  final String ownerPubkey;
  final Circle circle;

  ValueNotifier<List<SessionListViewModel>> sessionList$ = ValueNotifier([]);

  // Key: chatId
  HashMap<String, SessionListViewModel> sessionCache =
      HashMap<String, SessionListViewModel>();

  @override
  void deleteSessionCallback(List<String> chatIds) async {
    chatIds = chatIds.where((e) => e.isNotEmpty).toList();
    if (chatIds.isEmpty) return;

    final isar = DBISAR.sharedInstance.isar;
    await isar.writeTxn(() async {
       await isar.chatSessionModelISARs
          .where()
          .anyOf(chatIds, (q, chatId) => q.chatIdEqualTo(chatId))
          .deleteAll();
    });

    for (var chatId in chatIds) {
      if (chatId.isEmpty) continue;

      final viewModel = sessionCache[chatId];
      if (viewModel == null) continue;

      _removeViewModel(viewModel);
    }
  }

  @override
  void didReceiveMessageCallback(MessageDBISAR message) {
    final messageIsRead =
        OXChatBinding.sharedInstance.msgIsReaded?.call(message) ?? false;
    if (messageIsRead) {
      message.read = messageIsRead;
      Messages.saveMessageToDB(message);
    }

    final chatType = message.chatType;
    if (chatType == null) return;

    final chatId = message.chatId;
    if (chatId.isEmpty) return;

    var viewModel = sessionCache[chatId];
    if (viewModel == null) {
      viewModel = SessionListViewModel(ChatSessionModelISAR(
        chatId: message.chatId,
        receiver: message.receiver,
        sender: message.sender,
        groupId: message.groupId,
        chatType: chatType,
      ));
      viewModel.sessionModel.updateWithMessage(message);
      _addViewModel(viewModel);
    } else {
      viewModel.sessionModel.updateWithMessage(message);
      viewModel.rebuild();
    }

    ChatSessionModelISAR.saveChatSessionModelToDB(viewModel.sessionModel);
  }

  @override
  void deleteMessageHandler(MessageDBISAR delMessage, String newSessionSubtitle) {
    final chatId = delMessage.chatId;
    if (chatId.isEmpty) return;

    final viewModel = sessionCache[chatId];
    if (viewModel == null) return;

    final sessionModel = viewModel.sessionModel;
    sessionModel.content = newSessionSubtitle;

    viewModel.rebuild();
    ChatSessionModelISAR.saveChatSessionModelToDB(sessionModel);
  }

  @override
  void addReactionMessageCallback(String chatId, String messageId) async {
    if (chatId.isEmpty) return;

    final viewModel = sessionCache[chatId];
    if (viewModel == null) return;

    final sessionModel = viewModel.sessionModel;
    final reactionMessageIds = [...sessionModel.reactionMessageIds];
    if (!reactionMessageIds.contains(messageId)) {
      sessionModel.reactionMessageIds = [messageId, ...reactionMessageIds];
      viewModel.rebuild();
      ChatSessionModelISAR.saveChatSessionModelToDB(sessionModel);
    }
  }

  @override
  void removeReactionMessageCallback(String chatId, [bool sendNotification = true]) async {
    if (chatId.isEmpty) return;

    final viewModel = sessionCache[chatId];
    if (viewModel == null) return;

    final sessionModel = viewModel.sessionModel;
    sessionModel.reactionMessageIds = [];
    if (sendNotification) {
      viewModel.rebuild();
    }
    ChatSessionModelISAR.saveChatSessionModelToDB(sessionModel);
  }

  @override
  void addMentionMessageCallback(String chatId, String messageId) async {
    if (chatId.isEmpty) return;

    final viewModel = sessionCache[chatId];
    if (viewModel == null) return;

    final sessionModel = viewModel.sessionModel;
    final mentionMessageIds = [...sessionModel.mentionMessageIds];
    if (!mentionMessageIds.contains(messageId)) {
      sessionModel.mentionMessageIds = [messageId, ...sessionModel.mentionMessageIds];
      viewModel.rebuild();
      ChatSessionModelISAR.saveChatSessionModelToDB(sessionModel);
    }
  }

  @override
  void removeMentionMessageCallback(String chatId, [bool sendNotification = true]) async {
    if (chatId.isEmpty) return;

    final viewModel = sessionCache[chatId];
    if (viewModel == null) return;

    final sessionModel = viewModel.sessionModel;
    sessionModel.mentionMessageIds = [];
    await ChatSessionModelISAR.saveChatSessionModelToDB(sessionModel);
    if (sendNotification) {
      viewModel.rebuild();
    }
  }
}

extension SessionDCInterface on SessionListDataController {
  void initialized() async {
    final isar = DBISAR.sharedInstance.isar;
    final List<ChatSessionModelISAR> sessionList = await isar
        .chatSessionModelISARs
        .where()
        .chatIdNotEqualTo('')
        .sortByCreateTimeDesc()
        .findAll();

    final viewModelData = <SessionListViewModel>[];
    for (var sessionModel in sessionList) {
      final viewModel = SessionListViewModel(sessionModel);
      viewModelData.add(viewModel);
      sessionCache[sessionModel.chatId] = viewModel;
    }

    sessionList$.value = viewModelData;

    OXChatBinding.sharedInstance.addObserver(this);
    OXChatBinding.sharedInstance.sessionModelFetcher =
        (chatId) => sessionCache[chatId]?.sessionModel;
    OXChatBinding.sharedInstance.updateChatSessionFn = updateChatSession;
    OXChatBinding.sharedInstance.sessionListFetcher =
        () => sessionList$.value.map((e) => e.sessionModel).toList();
  }

  Future deleteSession(SessionListViewModel viewModel) async {
    final chatId = viewModel.sessionModel.chatId;
    if (chatId.isEmpty) return;

    final isar = DBISAR.sharedInstance.isar;
    int count = 0;
    await isar.writeTxn(() async {
      count = await isar.chatSessionModelISARs
          .where()
          .chatIdEqualTo(chatId)
          .deleteAll();
    });
    if (count > 0) {
      _removeViewModel(viewModel);
    }
  }

  Future<bool> updateChatSession(String chatId, {
    String? chatName,
    String? content,
    String? pic,
    int? unreadCount,
    bool? alwaysTop,
    String? draft,
    String? replyMessageId,
    int? messageKind,
    bool? isMentioned,
    int? expiration,
  }) async {
    if (chatId.isEmpty) return true;

    final viewModel = sessionCache[chatId];
    if (viewModel == null) return true;

    final sessionModel = viewModel.sessionModel;

    sessionModel.chatName = chatName ?? sessionModel.chatName;
    sessionModel.content = content ?? sessionModel.content;
    sessionModel.avatar = pic ?? sessionModel.avatar;
    sessionModel.unreadCount = unreadCount ?? sessionModel.unreadCount;
    sessionModel.alwaysTop = alwaysTop ?? sessionModel.alwaysTop;
    sessionModel.draft = draft ?? sessionModel.draft;
    sessionModel.replyMessageId = replyMessageId ?? sessionModel.replyMessageId;
    sessionModel.isMentioned = isMentioned ?? sessionModel.isMentioned;
    sessionModel.messageKind = messageKind ?? sessionModel.messageKind;
    sessionModel.expiration = expiration ?? sessionModel.expiration;

    viewModel.rebuild();
    ChatSessionModelISAR.saveChatSessionModelToDB(sessionModel);

    return true;
  }
}

extension _DataControllerEx on SessionListDataController {
  void _addViewModel(SessionListViewModel viewModel) {
    final chatId = viewModel.sessionModel.chatId;
    if (chatId.isEmpty) return;

    if (sessionCache.containsKey(chatId)) return;

    sessionCache[chatId] = viewModel;

    final newList = [...sessionList$.value];

    int flagIndex = newList.length;
    for (int index = 0; index < newList.length; index++) {
      final data = newList[index];

      if (data.sessionModel.createTime < viewModel.sessionModel.createTime) {
        flagIndex = index;
        break;
      }
    }

    newList.insert(flagIndex, viewModel);

    sessionList$.value = newList;
  }

  void _removeViewModel(SessionListViewModel viewModel) {
    final chatId = viewModel.sessionModel.chatId;
    if (chatId.isEmpty) return;

    final del = sessionCache.remove(chatId);
    if (del == null) return;

    final newList = [...sessionList$.value];
    newList.remove(del);
    sessionList$.value = newList;
  }
}

extension _MessageDBISAREx on MessageDBISAR {
  String get chatId {
    if (groupId.isNotEmpty) return groupId;
    return otherPubkey;
  }

  String get otherPubkey {
    final pubkey =
        OXUserInfoManager.sharedInstance.currentUserInfo?.pubKey ?? '';
    if (pubkey.isEmpty) return '';

    return sender != pubkey ? sender : receiver;
  }
}

extension _ChatSessionModelISAREx on ChatSessionModelISAR {
  void updateWithMessage(MessageDBISAR message) {
    final sessionMessageTextBuilder =
        OXChatBinding.sharedInstance.sessionMessageTextBuilder;
    final text = sessionMessageTextBuilder?.call(message) ?? '';
    createTime = message.createTime;
    content = text;

    if (!message.read) {
      unreadCount += 1;
    }
  }
}
