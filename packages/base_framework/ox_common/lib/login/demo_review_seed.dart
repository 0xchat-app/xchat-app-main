// Demo account seed for App Store review: pre-populate one contact and chat history
// so reviewers can verify report/block and chat features (Guideline 2.1(a)).

import 'package:flutter/foundation.dart';
import 'package:chatcore/chat-core.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/demo_review_config.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';

/// Runs once per circle when current account is the demo account.
/// Seeds one contact ("XChat Demo") and a few sample messages locally.
Future<void> runDemoReviewSeedIfNeeded() async {
  final pubkey = LoginManager.instance.currentPubkey;
  if (pubkey.isEmpty) return;
  if (pubkey.toLowerCase() != kDemoAccountPubkey.toLowerCase()) return;

  final circle = LoginManager.instance.currentState.currentCircle;
  if (circle == null) return;

  final seedKey = '${kDemoSeedDoneKey}_${circle.id}';
  final done = await OXCacheManager.defaultOXCacheManager.getForeverData(seedKey, defaultValue: false);
  if (done == true) return;

  try {
    final me = Account.sharedInstance.me;
    if (me == null) return;

    final privkey = Account.sharedInstance.currentPrivkey;
    if (privkey.isEmpty) return;

    // 1. Add demo friend to friendsList (Nip51) and save me
    final friendList = [People(kDemoFriendPubkey, null, 'XChat Demo', null)];
    final event = await Nip51.createCategorizedPeople(
      Contacts.identifier,
      [],
      friendList,
      privkey,
      pubkey,
    );
    if (event.content.isEmpty) return;
    me.friendsList = event.content;
    await Account.sharedInstance.syncMe();

    // Set demo account (me) avatar so it shows in profile and chat
    me.picture = kDemoAccountAvatarUrl;
    await Account.sharedInstance.syncMe();

    // 2. Create and save demo friend UserDBISAR (immediate write so Contacts can load it)
    final friend = UserDBISAR(pubKey: kDemoFriendPubkey)
      ..name = 'XChat Demo'
      ..nickName = 'XChat Demo'
      ..picture = kDemoFriendAvatarUrl;
    friend.updateEncodedPubkey(kDemoFriendPubkey);
    await DBISAR.sharedInstance.isar.writeAsync((isar) {
      if (friend.id == 0) {
        friend.id = isar.userDBISARs.autoIncrement();
      }
      isar.userDBISARs.put(friend);
    });
    Account.sharedInstance.updateOrCreateUserNotifier(kDemoFriendPubkey, friend);

    // 3. Create session for private chat
    final myPubkey = LoginManager.instance.currentPubkey;
    final session = ChatSessionModelISAR(
      chatId: kDemoFriendPubkey,
      chatName: 'XChat Demo',
      sender: kDemoFriendPubkey,
      receiver: kDemoFriendPubkey,
      chatType: ChatType.chatSingle,
      isSingleChat: true,
      content: 'Welcome! You can try report and block here.',
      createTime: DateTime.now().millisecondsSinceEpoch,
      lastActivityTime: DateTime.now().millisecondsSinceEpoch,
      messageType: 'text',
    );
    await DBISAR.sharedInstance.isar.writeAsync((isar) {
      if (session.id == 0) {
        session.id = isar.chatSessionModelISARs.autoIncrement();
      }
      isar.chatSessionModelISARs.put(session);
    });

    // 4. Create sample messages (private chat, chatType 0)
    // createTime must be in seconds; UI conversion uses createTime * 1000 for createdAt (ms)
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final messages = [
      _message(
        messageId: 'demo_msg_1',
        sender: kDemoFriendPubkey,
        receiver: myPubkey,
        content: 'Hi! This is the XChat demo account.',
        createTime: nowSec - 60,
      ),
      _message(
        messageId: 'demo_msg_2',
        sender: myPubkey,
        receiver: kDemoFriendPubkey,
        content: 'Hello! Thanks for trying XChat.',
        createTime: nowSec - 30,
      ),
      _message(
        messageId: 'demo_msg_3',
        sender: kDemoFriendPubkey,
        receiver: myPubkey,
        content: 'You can long-press a message to Report or Block. This helps App Review verify the app.',
        createTime: nowSec,
      ),
    ];
    await DBISAR.sharedInstance.isar.writeAsync((isar) {
      for (var m in messages) {
        if (m.id == 0) m.id = isar.messageDBISARs.autoIncrement();
      }
      isar.messageDBISARs.putAll(messages);
    });

    await OXCacheManager.defaultOXCacheManager.saveForeverData(seedKey, true);

    // Allow buffered writes (me) to flush
    await Future.delayed(const Duration(milliseconds: 250));

    // 5. Refresh contacts and session list in UI
    Account.sharedInstance.contactListUpdateCallback?.call();
    OXChatBinding.sharedInstance.notifySessionUpdate(session);

    debugPrint('Demo review seed completed for circle ${circle.id}');
  } catch (e, st) {
    debugPrint('Demo review seed failed: $e $st');
  }
}

MessageDBISAR _message({
  required String messageId,
  required String sender,
  required String receiver,
  required String content,
  required int createTime,
}) {
  return MessageDBISAR(
    messageId: messageId,
    sender: sender,
    receiver: receiver,
    groupId: '',
    sessionId: '',
    kind: 4,
    tags: '[]',
    content: content,
    createTime: createTime,
    read: true,
    replyId: '',
    decryptContent: content,
    type: 'text',
    status: 1,
    plaintEvent: '',
    chatType: 0,
  );
}
