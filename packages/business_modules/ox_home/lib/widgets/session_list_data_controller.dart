import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:chatcore/chat-core.dart';
import 'package:isar/isar.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/ox_chat_observer.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';

import 'session_view_model.dart';

class SessionListDataController with OXChatObserver {
  ValueNotifier<List<SessionListViewModel>> sessionList$ = ValueNotifier([]);

  // Key: chatId
  HashMap<String, SessionListViewModel> sessionCache =
      HashMap<String, SessionListViewModel>();

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

  @override
  void didReceiveMessageCallBack(MessageDBISAR message) {
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
  String get chatId => otherPubkey;

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
  }
}
