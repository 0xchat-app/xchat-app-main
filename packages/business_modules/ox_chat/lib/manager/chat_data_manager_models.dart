
import 'package:flutter/foundation.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_chat/manager/chat_message_helper.dart';
import 'package:ox_chat/utils/chat_log_utils.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/model/chat_type.dart';

class ChatTypeMessageLoaderParams {
  ChatTypeMessageLoaderParams({
    this.receiver,
    this.groupId,
    this.sessionId,
  });
  String? receiver;
  String? groupId;
  String? sessionId;

  @override
  String toString() {
    return '${super.toString()}, receiver: $receiver, groupId: $groupId, sessionId: $sessionId';
  }
}

abstract class ChatTypeKey {
  // DB Option
  String getSQLFilter();
  List<String> getSQLFilterArgs();

  ChatTypeMessageLoaderParams get messageLoaderParams;
  String get sessionId;

  // Equatable
  bool operator ==(Object other);
  int get hashCode;
}

@immutable
class PrivateChatKey implements ChatTypeKey {
  final String userId1;
  final String userId2;

  PrivateChatKey(this.userId1, this.userId2);

  String getSQLFilter() {
    return '(sessionId IS NULL OR sessionId = "") AND ((sender = ? AND receiver = ? ) OR (sender = ? AND receiver = ? )) ';
  }

  List<String> getSQLFilterArgs() {
    return [userId1, userId2, userId2, userId1];
  }

  @override
  ChatTypeMessageLoaderParams get messageLoaderParams => ChatTypeMessageLoaderParams(
    receiver: userId1 == Account.sharedInstance.currentPubkey ? userId2 : userId1,
  );

  @override
  String get sessionId => userId1 != Account.sharedInstance.me!.pubKey
      ? userId1 : userId2;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrivateChatKey &&
        ((other.userId1 == userId1 && other.userId2 == userId2) || (other.userId1 == userId2 && other.userId2 == userId1));
  }

  @override
  int get hashCode => userId1.hashCode ^ userId2.hashCode;

  @override
  String toString() {
    return '${super.toString()}, userId1: $userId1, userId2: $userId2';
  }
}

@immutable
class GroupKey implements ChatTypeKey {
  final String groupId;

  GroupKey(this.groupId);

  String getSQLFilter() {
    return ' groupId = ? ';
  }

  List<String> getSQLFilterArgs() {
    return [groupId];
  }

  @override
  ChatTypeMessageLoaderParams get messageLoaderParams => ChatTypeMessageLoaderParams(
    groupId: groupId,
  );

  @override
  String get sessionId => groupId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupKey && other.groupId == groupId;
  }

  @override
  int get hashCode => groupId.hashCode;

  @override
  String toString() {
    return '${super.toString()}, groupId: $groupId';
  }
}

@immutable
class ChannelKey implements ChatTypeKey {
  final String channelId;

  ChannelKey(this.channelId);

  String getSQLFilter() {
    return ' groupId = ? ';
  }

  List<String> getSQLFilterArgs() {
    return [channelId];
  }

  @override
  ChatTypeMessageLoaderParams get messageLoaderParams => ChatTypeMessageLoaderParams(
    groupId: channelId,
  );

  @override
  String get sessionId => channelId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChannelKey && other.channelId == channelId;
  }

  @override
  int get hashCode => channelId.hashCode;

  @override
  String toString() {
    return '${super.toString()}, channelId: $channelId';
  }
}

@immutable
class SecretChatKey implements ChatTypeKey {
  final String sessionId;

  SecretChatKey(this.sessionId);

  String getSQLFilter() {
    return ' sessionId = ? ';
  }

  List<String> getSQLFilterArgs() {
    return [sessionId];
  }

  @override
  ChatTypeMessageLoaderParams get messageLoaderParams => ChatTypeMessageLoaderParams(
    sessionId: sessionId,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretChatKey && other.sessionId == sessionId;
  }

  @override
  int get hashCode => sessionId.hashCode;

  @override
  String toString() {
    return '${super.toString()}, sessionId: $sessionId';
  }
}

@immutable
class RelayGroupKey implements ChatTypeKey {
  final String groupId;

  RelayGroupKey(this.groupId);

  String getSQLFilter() {
    return ' groupId = ? ';
  }

  List<String> getSQLFilterArgs() {
    return [groupId];
  }

  @override
  ChatTypeMessageLoaderParams get messageLoaderParams => ChatTypeMessageLoaderParams(
    groupId: groupId,
  );

  @override
  String get sessionId => groupId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RelayGroupKey && other.groupId == groupId;
  }

  @override
  int get hashCode => groupId.hashCode;

  @override
  String toString() {
    return '${super.toString()}, groupId: $groupId';
  }
}

@immutable
class BitchatChannelKey implements ChatTypeKey {
  final String channel;

  BitchatChannelKey(this.channel);

  String getSQLFilter() {
    return ' groupId = ? ';
  }

  List<String> getSQLFilterArgs() {
    return [channel];
  }

  @override
  ChatTypeMessageLoaderParams get messageLoaderParams => ChatTypeMessageLoaderParams(
    groupId: channel,
  );

  @override
  String get sessionId => channel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BitchatChannelKey && other.channel == channel;
  }

  @override
  int get hashCode => channel.hashCode;

  @override
  String toString() {
    return '${super.toString()}, channel: $channel';
  }
}

@immutable
class BitchatPrivateKey implements ChatTypeKey {
  final String userId;

  BitchatPrivateKey(this.userId);

  String getSQLFilter() {
    return ' groupId = ? ';
  }

  List<String> getSQLFilterArgs() {
    return [userId];
  }

  @override
  ChatTypeMessageLoaderParams get messageLoaderParams => ChatTypeMessageLoaderParams(
    groupId: userId,
  );

  @override
  String get sessionId => userId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BitchatPrivateKey && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return '${super.toString()}, channel: $userId';
  }
}

extension MessageChatTypeKeyEx on MessageDBISAR {
  ChatTypeKey? get chatTypeKey {
    MessageDBISAR message = this;
    final type = message.chatType;

    switch (type) {
      case ChatType.chatGroup:
        return GroupKey(message.groupId);
      case ChatType.chatSingle:
        if (message.sender.isNotEmpty && message.receiver.isNotEmpty) {
          return PrivateChatKey(message.sender, message.receiver);
        }
        break;
      case ChatType.bitchatChannel:
        return BitchatChannelKey(message.groupId);
      case ChatType.bitchatPrivate:
        return BitchatPrivateKey(message.getOtherPubkey);
    }

    ChatLogUtils.info(
      className: 'MessageChatTypeKeyEx',
      funcName: 'chatTypeKey',
      message: 'ChatTypeKey is null, messageId: ${message.messageId}, messageType: ${message.type}',
    );

    return null;
  }
}

extension SessionChatTypeKeyEx on ChatSessionModelISAR {
  ChatTypeKey? get chatTypeKey {
    final chatType = this.chatType;
    switch (chatType) {
      case ChatType.chatSingle:
        return _convertSessionToPrivateChatKey();
      case ChatType.chatGroup:
        return _convertSessionToGroupKey();
      case ChatType.bitchatChannel:
        return _convertSessionToBitchatChannelKey();
      case ChatType.bitchatPrivate:
        return _convertSessionToBitchatPrivateKey();
      default:
        assert(false, 'unknown chatType');
        return null;
    }
  }

  ChatTypeKey? _convertSessionToPrivateChatKey() {
    return PrivateChatKey(sender, receiver);
  }

  GroupKey? _convertSessionToGroupKey() {
    final groupId = this.groupId;
    if (groupId == null) {
      assert(false, 'groupId is null');
      return null;
    }
    return GroupKey(groupId);
  }

  ChannelKey? _convertSessionToChannelKey() {
    final channelId = this.groupId;
    if (channelId == null) {
      assert(false, 'channelId is null');
      return null;
    }
    return ChannelKey(channelId);
  }

  ChatTypeKey? _convertSessionToSecretChatKey() {
    return SecretChatKey(chatId);
  }

  RelayGroupKey? _convertSessionToRelayGroupKey() {
    final groupId = this.groupId;
    if (groupId == null) {
      assert(false, 'groupId is null');
      return null;
    }
    return RelayGroupKey(groupId);
  }

  BitchatChannelKey? _convertSessionToBitchatChannelKey() {
    return BitchatChannelKey(chatId);
  }

  BitchatPrivateKey? _convertSessionToBitchatPrivateKey() {
    return BitchatPrivateKey(chatId);
  }
}