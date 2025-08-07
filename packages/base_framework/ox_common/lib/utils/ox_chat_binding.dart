import 'dart:async';

import 'package:chatcore/chat-core.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/utils/ox_chat_observer.dart';

class OXChatBinding {
  static final OXChatBinding sharedInstance = OXChatBinding._internal();

  OXChatBinding._internal();

  factory OXChatBinding() {
    return sharedInstance;
  }

  final List<OXChatObserver> _observers = <OXChatObserver>[];

  List<ChatSessionModelISAR> Function()? sessionListFetcher;
  List<ChatSessionModelISAR> get sessionList => sessionListFetcher?.call() ?? [];

  String Function(MessageDBISAR messageDB)? sessionMessageTextBuilder;
  bool Function(MessageDBISAR messageDB)? msgIsReaded;

  ChatSessionModelISAR? Function(String chatId)? sessionModelFetcher;
  ChatSessionModelISAR? getSessionModel(String chatId) =>
      sessionModelFetcher?.call(chatId);

  Future<bool> Function(String chatId, {
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
    int? lastMessageTime,
    int? lastActivityTime,
  })? updateChatSessionFn;

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
    int? lastMessageTime,
    int? lastActivityTime,
  }) async => await updateChatSessionFn?.call(
    chatId,
    chatName: chatName,
    content: content,
    pic: pic,
    unreadCount: unreadCount,
    alwaysTop: alwaysTop,
    draft: draft,
    replyMessageId: replyMessageId,
    messageKind: messageKind,
    isMentioned: isMentioned,
    expiration: expiration,
    lastMessageTime: lastMessageTime,
    lastActivityTime: lastActivityTime,
  ) ?? true;

  void addReactionMessage(String chatId, String messageId) {
    for (OXChatObserver observer in _observers) {
      observer.addReactionMessageCallback(chatId, messageId);
    }
  }

  void removeReactionMessage(String chatId, [bool sendNotification = true]) {
    for (OXChatObserver observer in _observers) {
      observer.removeReactionMessageCallback(chatId, sendNotification);
    }
  }

  void addMentionMessage(String chatId, String messageId) {
    for (OXChatObserver observer in _observers) {
      observer.addMentionMessageCallback(chatId, messageId);
    }
  }

  void removeMentionMessage(String chatId, [bool sendNotification = true]) {
    for (OXChatObserver observer in _observers) {
      observer.removeMentionMessageCallback(chatId, sendNotification);
    }
  }

  void deleteMessageHandler(MessageDBISAR delMessage, String newSessionSubtitle) {
    for (OXChatObserver observer in _observers) {
      observer.deleteMessageHandler(delMessage, newSessionSubtitle);
    }
  }

  Future<int> deleteSession(List<String> chatIds) async {
    for (OXChatObserver observer in _observers) {
      observer.deleteSessionCallback(chatIds);
    }
    return chatIds.length;
  }

  void addObserver(OXChatObserver observer) => _observers.add(observer);

  bool removeObserver(OXChatObserver observer) => _observers.remove(observer);

  void contactUpdatedCallBack() {
    for (OXChatObserver observer in _observers) {
      observer.didContactUpdatedCallBack();
    }
  }

  void secretChatAcceptCallBack(SecretSessionDBISAR ssDB) async {
    for (OXChatObserver observer in _observers) {
      observer.didSecretChatAcceptCallBack(ssDB);
    }
  }

  void secretChatRejectCallBack(SecretSessionDBISAR ssDB) async {
    for (OXChatObserver observer in _observers) {
      observer.didSecretChatRejectCallBack(ssDB);
    }
  }

  void didReceiveMessageHandler(MessageDBISAR message) {
    for (OXChatObserver observer in _observers) {
      observer.didReceiveMessageCallback(message);
    }
  }

  void secretChatUpdateCallBack(SecretSessionDBISAR ssDB) {
    for (OXChatObserver observer in _observers) {
      observer.didSecretChatUpdateCallBack(ssDB);
    }
  }

  void secretChatCloseCallBack(SecretSessionDBISAR ssDB) {
    for (OXChatObserver observer in _observers) {
      observer.didSecretChatCloseCallBack(ssDB);
    }
  }

  void privateChatMessageCallBack(MessageDBISAR message) async {
    for (OXChatObserver observer in _observers) {
      observer.didPrivateMessageCallBack(message);
    }
  }

  void chatMessageUpdateCallBack(MessageDBISAR message, String replacedMessageId) async {
    for (OXChatObserver observer in _observers) {
      observer.didChatMessageUpdateCallBack(message, replacedMessageId);
    }
  }

  void secretChatMessageCallBack(MessageDBISAR message) async {
    for (OXChatObserver observer in _observers) {
      observer.didSecretChatMessageCallBack(message);
    }
  }

  void groupMessageCallBack(MessageDBISAR messageDB) async {
    for (OXChatObserver observer in _observers) {
      observer.didGroupMessageCallBack(messageDB);
    }
  }

  void messageDeleteCallback(List<MessageDBISAR> delMessages) {
    for (OXChatObserver observer in _observers) {
      observer.didMessageDeleteCallBack(delMessages);
    }
  }

  void messageActionsCallBack(MessageDBISAR messageDB) async {
    for (OXChatObserver observer in _observers) {
      observer.didMessageActionsCallBack(messageDB);
    }
  }

  void updateMessageDB(MessageDBISAR messageDB) async {
    if (msgIsReaded != null && msgIsReaded!(messageDB) && !messageDB.read){
      messageDB.read = true;
      Messages.saveMessageToDB(messageDB);
    }
  }

  void groupsUpdatedCallBack() {
    for (OXChatObserver observer in _observers) {
      observer.didGroupsUpdatedCallBack();
    }
  }

  void sessionUpdate() {
    for (OXChatObserver observer in _observers) {
      observer.didSessionUpdate();
    }
  }

  void offlinePrivateMessageFinishCallBack() {
    for (OXChatObserver observer in _observers) {
      observer.didOfflinePrivateMessageFinishCallBack();
    }
  }

  void offlineSecretMessageFinishCallBack() {
    for (OXChatObserver observer in _observers) {
      observer.didOfflineSecretMessageFinishCallBack();
    }
  }

  void createSessionCallBack(ChatSessionModelISAR session) {
    for (OXChatObserver observer in _observers) {
      observer.didCreateSessionCallBack(session);
    }
  }
}
