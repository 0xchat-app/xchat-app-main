import 'dart:async';

import 'package:ox_chat/manager/chat_draft_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/utils/ox_chat_observer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chatcore/chat-core.dart';
import 'package:ox_chat/manager/chat_data_manager_models.dart';
import 'package:ox_chat/manager/chat_message_helper.dart';
import 'package:ox_chat/utils/chat_log_utils.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';

class ChatDataCache with OXChatObserver, LoginManagerObserver {

  static final ChatDataCache shared = ChatDataCache._internal();

  ChatDataCache._internal() {
    OXChatBinding.sharedInstance.addObserver(this);
  }

  Completer setupCompleter = Completer();

  Completer offlinePrivateMessageFlag = Completer();
  Completer offlineSecretMessageFlag = Completer();
  Completer offlineChannelMessageFlag = Completer();
  Completer offlineGroupMessageFlag = Completer();

  Future get offlineMessageComplete => Future.wait([
    offlinePrivateMessageFlag.future,
    offlineSecretMessageFlag.future,
    offlineChannelMessageFlag.future,
    offlineGroupMessageFlag.future,
  ]);

  setup() async {

    ChatLogUtils.info(
      className: 'ChatDataCache',
      funcName: 'setup',
      message: 'start',
    );

    final setupCompleter = Completer();
    this.setupCompleter = setupCompleter;
    setupAllCompleter();

    ChatDraftManager.shared.setup();

    ChatLogUtils.info(
      className: 'ChatDataCache',
      funcName: 'setup',
      message: 'finish',
    );
    if (!setupCompleter.isCompleted) {
      setupCompleter.complete();
    }
  }

  void setupAllCompleter() {
    offlinePrivateMessageFlag = Completer();
    offlineSecretMessageFlag = Completer();
    offlineChannelMessageFlag = Completer();
    offlineGroupMessageFlag = Completer();
  }

  @override
  void didPrivateMessageCallBack(MessageDBISAR message) async {
    receiveMessageHandler(message);
  }

  @override
  void didChatMessageUpdateCallBack(MessageDBISAR message, String replacedMessageId) async { }

  @override
  void didSecretChatMessageCallBack(MessageDBISAR message) async {
    receiveMessageHandler(message);
  }

  @override
  void didGroupMessageCallBack(MessageDBISAR message) async {
    receiveMessageHandler(message);
  }

  @override
  void didChannalMessageCallBack(MessageDBISAR message) async {
    receiveMessageHandler(message);
  }

  @override
  void didMessageDeleteCallBack(List<MessageDBISAR> delMessages) async {
    for (var message in delMessages) {
      final chatType = message.chatTypeKey;
      if (chatType == null) continue ;

      final loadParams = chatType.messageLoaderParams;
      List<MessageDBISAR> messages = (await Messages.loadMessagesFromDB(
        receiver: loadParams.receiver,
        groupId: loadParams.groupId,
        sessionId: loadParams.sessionId,
      ))['messages'] ?? <MessageDBISAR>[];

      types.Message? lastMessage = await messages.firstOrNull?.toChatUIMessage();
      OXChatBinding.sharedInstance.deleteMessageHandler(message, lastMessage?.messagePreviewText ?? '');
    }
  }

  @override
  void didOfflinePrivateMessageFinishCallBack() {
    if (!offlinePrivateMessageFlag.isCompleted) {
      offlinePrivateMessageFlag.complete();
    }
  }

  @override
  void didOfflineSecretMessageFinishCallBack() {
    if (!offlineSecretMessageFlag.isCompleted) {
      offlineSecretMessageFlag.complete();
    }
  }

  @override
  void didOfflineChannelMessageFinishCallBack() {
    if (!offlineChannelMessageFlag.isCompleted) {
      offlineChannelMessageFlag.complete();
    }
  }

  @override
  void didOfflineGroupMessageFinishCallBack() {
    if (!offlineGroupMessageFlag.isCompleted) {
      offlineGroupMessageFlag.complete();
    }
  }

  Future receiveMessageHandler(MessageDBISAR message) async {
    final sessionId = message.chatTypeKey?.sessionId;
    final messageId = message.messageId;
    if (sessionId == null || sessionId.isEmpty || messageId.isEmpty) return null;

    await message.toChatUIMessage(
      isMentionMessageCallback: () {
        OXChatBinding.sharedInstance.addMentionMessage(sessionId, messageId);
      },
    );
  }

  @override
  void onLoginSuccess(LoginState state) {
    setup();
  }
}

extension CommonChatSessionEx on ChatSessionModelISAR {
  /// Integer value for [MessageDBISAR.chatType].
  /// Returns `null` if the [chatType] does not match any known chat type.
  int? get coreChatType {
    switch(chatType) {
      case ChatType.chatSingle:
        return 0;
      case ChatType.chatGroup:
        return 1;
      case ChatType.bitchatChannel:
        return 5;
      case ChatType.bitchatPrivate:
        return 6;
      default:
        return null;
    }
  }
}
