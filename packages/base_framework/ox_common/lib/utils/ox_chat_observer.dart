import 'package:chatcore/chat-core.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';

///Title: ox_chat_observer
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2021
///@author Michael
///CreateTime: 2023/10/9 19:28
abstract mixin class OXChatObserver {
  void didSecretChatRequestCallBack() {}

  void didPrivateMessageCallBack(MessageDBISAR message) {}

  void didChatMessageUpdateCallBack(MessageDBISAR message, String replacedMessageId) {}

  void didSecretChatAcceptCallBack(SecretSessionDBISAR ssDB) {}

  void didSecretChatRejectCallBack(SecretSessionDBISAR ssDB) {}

  void didSecretChatCloseCallBack(SecretSessionDBISAR ssDB) {}

  void didSecretChatUpdateCallBack(SecretSessionDBISAR ssDB) {}

  void didContactUpdatedCallBack() {}

  void didGroupMessageCallBack(MessageDBISAR message) {}

  void didMessageDeleteCallBack(List<MessageDBISAR> delMessages) {}

  void didMessageActionsCallBack(MessageDBISAR message) {}

  void didGroupsUpdatedCallBack() {}

  void didSessionUpdate() {}

  void didSessionInfoUpdate(List<ChatSessionModelISAR> updatedSession) {}

  void didSecretChatMessageCallBack(MessageDBISAR message) {}

  void didOfflinePrivateMessageFinishCallBack() {}
  void didOfflineSecretMessageFinishCallBack() {}

  // Lite Feature
  void deleteSessionCallback(List<String> chatIds) {}

  void didReceiveMessageCallback(MessageDBISAR message) {}
  void deleteMessageHandler(MessageDBISAR delMessage, String newSessionSubtitle) {}

  void addReactionMessageCallback(String chatId, String messageId) {}
  void removeReactionMessageCallback(String chatId, [bool sendNotification = true]) {}

  void addMentionMessageCallback(String chatId, String messageId) {}
  void removeMentionMessageCallback(String chatId, [bool sendNotification = true]) {}

  void didCreateSessionCallBack(ChatSessionModelISAR session) {}
}