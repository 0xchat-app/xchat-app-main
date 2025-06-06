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
    int? expiration
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
    int? expiration
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

  Future<int> deleteSession(List<String> chatIds, {bool isStranger = false}) async {
    for (OXChatObserver observer in _observers) {
      observer.deleteSessionCallback(chatIds);
    }
    return chatIds.length;
  }

  void addObserver(OXChatObserver observer) => _observers.add(observer);

  bool removeObserver(OXChatObserver observer) => _observers.remove(observer);

  void createChannelSuccess(ChannelDBISAR channelDB) {
    for (OXChatObserver observer in _observers) {
      observer.didCreateChannel(channelDB);
    }
  }

  void deleteChannel(ChannelDBISAR channelDB) {
    for (OXChatObserver observer in _observers) {
      observer.didDeleteChannel(channelDB);
    }
  }

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

  void channalMessageCallBack(MessageDBISAR messageDB) async {
    for (OXChatObserver observer in _observers) {
      observer.didChannalMessageCallBack(messageDB);
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

  void relayGroupJoinReqCallBack(JoinRequestDBISAR joinRequestDB) async {
    for (OXChatObserver observer in _observers) {
      observer.didRelayGroupJoinReqCallBack(joinRequestDB);
    }
  }

  void relayGroupModerationCallBack(ModerationDBISAR moderationDB) async {
    for (OXChatObserver observer in _observers) {
      observer.didRelayGroupModerationCallBack(moderationDB);
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

  Future<void> changeChatSessionTypeAll(String pubkey, bool isBecomeContact) async {
    // //strangerSession to chatSession
    // bool isChange = false;
    // List<ChatSessionModelISAR> list = OXChatBinding.sharedInstance.sessionMap.values.toList();
    // Set<ChatSessionModelISAR> changedSessions = {};
    // await Future.forEach(list, (csModel) async {
    //   if(csModel.chatType == ChatType.chatChannel || csModel.chatType == ChatType.chatGroup){
    //     return;
    //   }
    //   isChange = true;
    //   int? tempChatType = csModel.chatType;
    //   if (isBecomeContact) {
    //     if (csModel.chatType == ChatType.chatSecretStranger && (csModel.sender == pubkey || csModel.receiver == pubkey)) {
    //       tempChatType = ChatType.chatSecret;
    //       await updateChatSessionDB(csModel, tempChatType);
    //       changedSessions.add(csModel);
    //     } else if (csModel.chatType == ChatType.chatStranger && csModel.chatId == pubkey) {
    //       tempChatType = ChatType.chatSingle;
    //       await updateChatSessionDB(csModel, tempChatType);
    //       changedSessions.add(csModel);
    //     }
    //   } else {
    //     if (csModel.chatType == ChatType.chatSecret && (csModel.sender == pubkey || csModel.receiver == pubkey)) {
    //       tempChatType = ChatType.chatSecretStranger;
    //       await updateChatSessionDB(csModel, tempChatType);
    //       changedSessions.add(csModel);
    //     } else if (csModel.chatType == ChatType.chatSingle && csModel.chatId == pubkey) {
    //       tempChatType = ChatType.chatStranger;
    //       await updateChatSessionDB(csModel, tempChatType);
    //       changedSessions.add(csModel);
    //     }
    //   }
    // });
    // if (isChange) {
    //   _updateUnReadStrangerSessionCount();
    //   sessionUpdate();
    //   sessionInfoUpdate(changedSessions.toList());
    // }
  }

  void noticeFriendRequest() {
    for (OXChatObserver observer in _observers) {
      observer.didSecretChatRequestCallBack();
    }
  }

  void channelsUpdatedCallBack() {
    for (OXChatObserver observer in _observers) {
      observer.didChannelsUpdatedCallBack();
    }
  }

  void groupsUpdatedCallBack() {
    for (OXChatObserver observer in _observers) {
      observer.didGroupsUpdatedCallBack();
    }
  }

  void relayGroupsUpdatedCallBack() {
    for (OXChatObserver observer in _observers) {
      observer.didRelayGroupsUpdatedCallBack();
    }
  }

  void sessionUpdate() {
    for (OXChatObserver observer in _observers) {
      observer.didSessionUpdate();
    }
  }

  void sessionInfoUpdate(List<ChatSessionModelISAR> updatedSession) {
    for (OXChatObserver observer in _observers) {
      observer.didSessionInfoUpdate(updatedSession);
    }
  }

  void noticePromptToneCallBack(MessageDBISAR message, int type) async {
    for (OXChatObserver observer in _observers) {
      observer.didPromptToneCallBack(message, type);
    }
  }

  void zapRecordsCallBack(ZapRecordsDBISAR zapRecordsDB) {
    for (OXChatObserver observer in _observers) {
      observer.didZapRecordsCallBack(zapRecordsDB);
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

  void offlineChannelMessageFinishCallBack() {
    for (OXChatObserver observer in _observers) {
      observer.didOfflineChannelMessageFinishCallBack();
    }
  }

  void offlineGroupMessageFinishCallBack() {
    for (OXChatObserver observer in _observers) {
      observer.didOfflineGroupMessageFinishCallBack();
    }
  }
}
