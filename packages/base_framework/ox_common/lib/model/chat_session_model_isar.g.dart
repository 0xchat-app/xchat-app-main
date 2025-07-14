// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session_model_isar.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetChatSessionModelISARCollection on Isar {
  IsarCollection<int, ChatSessionModelISAR> get chatSessionModelISARs =>
      this.collection();
}

const ChatSessionModelISARSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'ChatSessionModelISAR',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'chatId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'chatName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'sender',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'receiver',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'groupId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'content',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'unreadCount',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'createTime',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'lastActivityTime',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'chatType',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'isSingleChat',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'messageType',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'avatar',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'alwaysTop',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'draft',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'replyMessageId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'isMentioned',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'isZapsFromOther',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'messageKind',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'expiration',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'reactionMessageIds',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'mentionMessageIds',
        type: IsarType.stringList,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'chatId',
        properties: [
          "chatId",
        ],
        unique: true,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, ChatSessionModelISAR>(
    serialize: serializeChatSessionModelISAR,
    deserialize: deserializeChatSessionModelISAR,
    deserializeProperty: deserializeChatSessionModelISARProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeChatSessionModelISAR(
    IsarWriter writer, ChatSessionModelISAR object) {
  IsarCore.writeString(writer, 1, object.chatId);
  {
    final value = object.chatName;
    if (value == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      IsarCore.writeString(writer, 2, value);
    }
  }
  IsarCore.writeString(writer, 3, object.sender);
  IsarCore.writeString(writer, 4, object.receiver);
  {
    final value = object.groupId;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeString(writer, 5, value);
    }
  }
  {
    final value = object.content;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeString(writer, 6, value);
    }
  }
  IsarCore.writeLong(writer, 7, object.unreadCount);
  IsarCore.writeLong(writer, 8, object.createTime);
  IsarCore.writeLong(writer, 9, object.lastActivityTime);
  IsarCore.writeLong(writer, 10, object.chatType);
  IsarCore.writeBool(writer, 11, object.isSingleChat);
  {
    final value = object.messageType;
    if (value == null) {
      IsarCore.writeNull(writer, 12);
    } else {
      IsarCore.writeString(writer, 12, value);
    }
  }
  {
    final value = object.avatar;
    if (value == null) {
      IsarCore.writeNull(writer, 13);
    } else {
      IsarCore.writeString(writer, 13, value);
    }
  }
  IsarCore.writeBool(writer, 14, object.alwaysTop);
  {
    final value = object.draft;
    if (value == null) {
      IsarCore.writeNull(writer, 15);
    } else {
      IsarCore.writeString(writer, 15, value);
    }
  }
  {
    final value = object.replyMessageId;
    if (value == null) {
      IsarCore.writeNull(writer, 16);
    } else {
      IsarCore.writeString(writer, 16, value);
    }
  }
  IsarCore.writeBool(writer, 17, object.isMentioned);
  IsarCore.writeBool(writer, 18, object.isZapsFromOther);
  IsarCore.writeLong(writer, 19, object.messageKind ?? -9223372036854775808);
  IsarCore.writeLong(writer, 20, object.expiration ?? -9223372036854775808);
  {
    final list = object.reactionMessageIds;
    final listWriter = IsarCore.beginList(writer, 21, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.mentionMessageIds;
    final listWriter = IsarCore.beginList(writer, 22, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  return object.id;
}

@isarProtected
ChatSessionModelISAR deserializeChatSessionModelISAR(IsarReader reader) {
  final String _chatId;
  _chatId = IsarCore.readString(reader, 1) ?? '';
  final String? _chatName;
  _chatName = IsarCore.readString(reader, 2);
  final String _sender;
  _sender = IsarCore.readString(reader, 3) ?? '';
  final String _receiver;
  _receiver = IsarCore.readString(reader, 4) ?? '';
  final String? _groupId;
  _groupId = IsarCore.readString(reader, 5);
  final String? _content;
  _content = IsarCore.readString(reader, 6);
  final int _unreadCount;
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      _unreadCount = 0;
    } else {
      _unreadCount = value;
    }
  }
  final int _createTime;
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      _createTime = 0;
    } else {
      _createTime = value;
    }
  }
  final int _lastActivityTime;
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      _lastActivityTime = 0;
    } else {
      _lastActivityTime = value;
    }
  }
  final int _chatType;
  {
    final value = IsarCore.readLong(reader, 10);
    if (value == -9223372036854775808) {
      _chatType = 0;
    } else {
      _chatType = value;
    }
  }
  final bool _isSingleChat;
  _isSingleChat = IsarCore.readBool(reader, 11);
  final String? _messageType;
  _messageType = IsarCore.readString(reader, 12) ?? 'text';
  final String? _avatar;
  _avatar = IsarCore.readString(reader, 13);
  final bool _alwaysTop;
  _alwaysTop = IsarCore.readBool(reader, 14);
  final String? _draft;
  _draft = IsarCore.readString(reader, 15);
  final String? _replyMessageId;
  _replyMessageId = IsarCore.readString(reader, 16);
  final bool _isMentioned;
  _isMentioned = IsarCore.readBool(reader, 17);
  final bool _isZapsFromOther;
  _isZapsFromOther = IsarCore.readBool(reader, 18);
  final int? _messageKind;
  {
    final value = IsarCore.readLong(reader, 19);
    if (value == -9223372036854775808) {
      _messageKind = null;
    } else {
      _messageKind = value;
    }
  }
  final int? _expiration;
  {
    final value = IsarCore.readLong(reader, 20);
    if (value == -9223372036854775808) {
      _expiration = null;
    } else {
      _expiration = value;
    }
  }
  final object = ChatSessionModelISAR(
    chatId: _chatId,
    chatName: _chatName,
    sender: _sender,
    receiver: _receiver,
    groupId: _groupId,
    content: _content,
    unreadCount: _unreadCount,
    createTime: _createTime,
    lastActivityTime: _lastActivityTime,
    chatType: _chatType,
    isSingleChat: _isSingleChat,
    messageType: _messageType,
    avatar: _avatar,
    alwaysTop: _alwaysTop,
    draft: _draft,
    replyMessageId: _replyMessageId,
    isMentioned: _isMentioned,
    isZapsFromOther: _isZapsFromOther,
    messageKind: _messageKind,
    expiration: _expiration,
  );
  object.id = IsarCore.readId(reader);
  {
    final length = IsarCore.readList(reader, 21, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.reactionMessageIds = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.reactionMessageIds = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 22, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.mentionMessageIds = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.mentionMessageIds = list;
      }
    }
  }
  return object;
}

@isarProtected
dynamic deserializeChatSessionModelISARProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2);
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      return IsarCore.readString(reader, 5);
    case 6:
      return IsarCore.readString(reader, 6);
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return 0;
        } else {
          return value;
        }
      }
    case 8:
      {
        final value = IsarCore.readLong(reader, 8);
        if (value == -9223372036854775808) {
          return 0;
        } else {
          return value;
        }
      }
    case 9:
      {
        final value = IsarCore.readLong(reader, 9);
        if (value == -9223372036854775808) {
          return 0;
        } else {
          return value;
        }
      }
    case 10:
      {
        final value = IsarCore.readLong(reader, 10);
        if (value == -9223372036854775808) {
          return 0;
        } else {
          return value;
        }
      }
    case 11:
      return IsarCore.readBool(reader, 11);
    case 12:
      return IsarCore.readString(reader, 12) ?? 'text';
    case 13:
      return IsarCore.readString(reader, 13);
    case 14:
      return IsarCore.readBool(reader, 14);
    case 15:
      return IsarCore.readString(reader, 15);
    case 16:
      return IsarCore.readString(reader, 16);
    case 17:
      return IsarCore.readBool(reader, 17);
    case 18:
      return IsarCore.readBool(reader, 18);
    case 19:
      {
        final value = IsarCore.readLong(reader, 19);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 20:
      {
        final value = IsarCore.readLong(reader, 20);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 21:
      {
        final length = IsarCore.readList(reader, 21, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 22:
      {
        final length = IsarCore.readList(reader, 22, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _ChatSessionModelISARUpdate {
  bool call({
    required int id,
    String? chatId,
    String? chatName,
    String? sender,
    String? receiver,
    String? groupId,
    String? content,
    int? unreadCount,
    int? createTime,
    int? lastActivityTime,
    int? chatType,
    bool? isSingleChat,
    String? messageType,
    String? avatar,
    bool? alwaysTop,
    String? draft,
    String? replyMessageId,
    bool? isMentioned,
    bool? isZapsFromOther,
    int? messageKind,
    int? expiration,
  });
}

class _ChatSessionModelISARUpdateImpl implements _ChatSessionModelISARUpdate {
  const _ChatSessionModelISARUpdateImpl(this.collection);

  final IsarCollection<int, ChatSessionModelISAR> collection;

  @override
  bool call({
    required int id,
    Object? chatId = ignore,
    Object? chatName = ignore,
    Object? sender = ignore,
    Object? receiver = ignore,
    Object? groupId = ignore,
    Object? content = ignore,
    Object? unreadCount = ignore,
    Object? createTime = ignore,
    Object? lastActivityTime = ignore,
    Object? chatType = ignore,
    Object? isSingleChat = ignore,
    Object? messageType = ignore,
    Object? avatar = ignore,
    Object? alwaysTop = ignore,
    Object? draft = ignore,
    Object? replyMessageId = ignore,
    Object? isMentioned = ignore,
    Object? isZapsFromOther = ignore,
    Object? messageKind = ignore,
    Object? expiration = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (chatId != ignore) 1: chatId as String?,
          if (chatName != ignore) 2: chatName as String?,
          if (sender != ignore) 3: sender as String?,
          if (receiver != ignore) 4: receiver as String?,
          if (groupId != ignore) 5: groupId as String?,
          if (content != ignore) 6: content as String?,
          if (unreadCount != ignore) 7: unreadCount as int?,
          if (createTime != ignore) 8: createTime as int?,
          if (lastActivityTime != ignore) 9: lastActivityTime as int?,
          if (chatType != ignore) 10: chatType as int?,
          if (isSingleChat != ignore) 11: isSingleChat as bool?,
          if (messageType != ignore) 12: messageType as String?,
          if (avatar != ignore) 13: avatar as String?,
          if (alwaysTop != ignore) 14: alwaysTop as bool?,
          if (draft != ignore) 15: draft as String?,
          if (replyMessageId != ignore) 16: replyMessageId as String?,
          if (isMentioned != ignore) 17: isMentioned as bool?,
          if (isZapsFromOther != ignore) 18: isZapsFromOther as bool?,
          if (messageKind != ignore) 19: messageKind as int?,
          if (expiration != ignore) 20: expiration as int?,
        }) >
        0;
  }
}

sealed class _ChatSessionModelISARUpdateAll {
  int call({
    required List<int> id,
    String? chatId,
    String? chatName,
    String? sender,
    String? receiver,
    String? groupId,
    String? content,
    int? unreadCount,
    int? createTime,
    int? lastActivityTime,
    int? chatType,
    bool? isSingleChat,
    String? messageType,
    String? avatar,
    bool? alwaysTop,
    String? draft,
    String? replyMessageId,
    bool? isMentioned,
    bool? isZapsFromOther,
    int? messageKind,
    int? expiration,
  });
}

class _ChatSessionModelISARUpdateAllImpl
    implements _ChatSessionModelISARUpdateAll {
  const _ChatSessionModelISARUpdateAllImpl(this.collection);

  final IsarCollection<int, ChatSessionModelISAR> collection;

  @override
  int call({
    required List<int> id,
    Object? chatId = ignore,
    Object? chatName = ignore,
    Object? sender = ignore,
    Object? receiver = ignore,
    Object? groupId = ignore,
    Object? content = ignore,
    Object? unreadCount = ignore,
    Object? createTime = ignore,
    Object? lastActivityTime = ignore,
    Object? chatType = ignore,
    Object? isSingleChat = ignore,
    Object? messageType = ignore,
    Object? avatar = ignore,
    Object? alwaysTop = ignore,
    Object? draft = ignore,
    Object? replyMessageId = ignore,
    Object? isMentioned = ignore,
    Object? isZapsFromOther = ignore,
    Object? messageKind = ignore,
    Object? expiration = ignore,
  }) {
    return collection.updateProperties(id, {
      if (chatId != ignore) 1: chatId as String?,
      if (chatName != ignore) 2: chatName as String?,
      if (sender != ignore) 3: sender as String?,
      if (receiver != ignore) 4: receiver as String?,
      if (groupId != ignore) 5: groupId as String?,
      if (content != ignore) 6: content as String?,
      if (unreadCount != ignore) 7: unreadCount as int?,
      if (createTime != ignore) 8: createTime as int?,
      if (lastActivityTime != ignore) 9: lastActivityTime as int?,
      if (chatType != ignore) 10: chatType as int?,
      if (isSingleChat != ignore) 11: isSingleChat as bool?,
      if (messageType != ignore) 12: messageType as String?,
      if (avatar != ignore) 13: avatar as String?,
      if (alwaysTop != ignore) 14: alwaysTop as bool?,
      if (draft != ignore) 15: draft as String?,
      if (replyMessageId != ignore) 16: replyMessageId as String?,
      if (isMentioned != ignore) 17: isMentioned as bool?,
      if (isZapsFromOther != ignore) 18: isZapsFromOther as bool?,
      if (messageKind != ignore) 19: messageKind as int?,
      if (expiration != ignore) 20: expiration as int?,
    });
  }
}

extension ChatSessionModelISARUpdate
    on IsarCollection<int, ChatSessionModelISAR> {
  _ChatSessionModelISARUpdate get update =>
      _ChatSessionModelISARUpdateImpl(this);

  _ChatSessionModelISARUpdateAll get updateAll =>
      _ChatSessionModelISARUpdateAllImpl(this);
}

sealed class _ChatSessionModelISARQueryUpdate {
  int call({
    String? chatId,
    String? chatName,
    String? sender,
    String? receiver,
    String? groupId,
    String? content,
    int? unreadCount,
    int? createTime,
    int? lastActivityTime,
    int? chatType,
    bool? isSingleChat,
    String? messageType,
    String? avatar,
    bool? alwaysTop,
    String? draft,
    String? replyMessageId,
    bool? isMentioned,
    bool? isZapsFromOther,
    int? messageKind,
    int? expiration,
  });
}

class _ChatSessionModelISARQueryUpdateImpl
    implements _ChatSessionModelISARQueryUpdate {
  const _ChatSessionModelISARQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<ChatSessionModelISAR> query;
  final int? limit;

  @override
  int call({
    Object? chatId = ignore,
    Object? chatName = ignore,
    Object? sender = ignore,
    Object? receiver = ignore,
    Object? groupId = ignore,
    Object? content = ignore,
    Object? unreadCount = ignore,
    Object? createTime = ignore,
    Object? lastActivityTime = ignore,
    Object? chatType = ignore,
    Object? isSingleChat = ignore,
    Object? messageType = ignore,
    Object? avatar = ignore,
    Object? alwaysTop = ignore,
    Object? draft = ignore,
    Object? replyMessageId = ignore,
    Object? isMentioned = ignore,
    Object? isZapsFromOther = ignore,
    Object? messageKind = ignore,
    Object? expiration = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (chatId != ignore) 1: chatId as String?,
      if (chatName != ignore) 2: chatName as String?,
      if (sender != ignore) 3: sender as String?,
      if (receiver != ignore) 4: receiver as String?,
      if (groupId != ignore) 5: groupId as String?,
      if (content != ignore) 6: content as String?,
      if (unreadCount != ignore) 7: unreadCount as int?,
      if (createTime != ignore) 8: createTime as int?,
      if (lastActivityTime != ignore) 9: lastActivityTime as int?,
      if (chatType != ignore) 10: chatType as int?,
      if (isSingleChat != ignore) 11: isSingleChat as bool?,
      if (messageType != ignore) 12: messageType as String?,
      if (avatar != ignore) 13: avatar as String?,
      if (alwaysTop != ignore) 14: alwaysTop as bool?,
      if (draft != ignore) 15: draft as String?,
      if (replyMessageId != ignore) 16: replyMessageId as String?,
      if (isMentioned != ignore) 17: isMentioned as bool?,
      if (isZapsFromOther != ignore) 18: isZapsFromOther as bool?,
      if (messageKind != ignore) 19: messageKind as int?,
      if (expiration != ignore) 20: expiration as int?,
    });
  }
}

extension ChatSessionModelISARQueryUpdate on IsarQuery<ChatSessionModelISAR> {
  _ChatSessionModelISARQueryUpdate get updateFirst =>
      _ChatSessionModelISARQueryUpdateImpl(this, limit: 1);

  _ChatSessionModelISARQueryUpdate get updateAll =>
      _ChatSessionModelISARQueryUpdateImpl(this);
}

class _ChatSessionModelISARQueryBuilderUpdateImpl
    implements _ChatSessionModelISARQueryUpdate {
  const _ChatSessionModelISARQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QOperations>
      query;
  final int? limit;

  @override
  int call({
    Object? chatId = ignore,
    Object? chatName = ignore,
    Object? sender = ignore,
    Object? receiver = ignore,
    Object? groupId = ignore,
    Object? content = ignore,
    Object? unreadCount = ignore,
    Object? createTime = ignore,
    Object? lastActivityTime = ignore,
    Object? chatType = ignore,
    Object? isSingleChat = ignore,
    Object? messageType = ignore,
    Object? avatar = ignore,
    Object? alwaysTop = ignore,
    Object? draft = ignore,
    Object? replyMessageId = ignore,
    Object? isMentioned = ignore,
    Object? isZapsFromOther = ignore,
    Object? messageKind = ignore,
    Object? expiration = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (chatId != ignore) 1: chatId as String?,
        if (chatName != ignore) 2: chatName as String?,
        if (sender != ignore) 3: sender as String?,
        if (receiver != ignore) 4: receiver as String?,
        if (groupId != ignore) 5: groupId as String?,
        if (content != ignore) 6: content as String?,
        if (unreadCount != ignore) 7: unreadCount as int?,
        if (createTime != ignore) 8: createTime as int?,
        if (lastActivityTime != ignore) 9: lastActivityTime as int?,
        if (chatType != ignore) 10: chatType as int?,
        if (isSingleChat != ignore) 11: isSingleChat as bool?,
        if (messageType != ignore) 12: messageType as String?,
        if (avatar != ignore) 13: avatar as String?,
        if (alwaysTop != ignore) 14: alwaysTop as bool?,
        if (draft != ignore) 15: draft as String?,
        if (replyMessageId != ignore) 16: replyMessageId as String?,
        if (isMentioned != ignore) 17: isMentioned as bool?,
        if (isZapsFromOther != ignore) 18: isZapsFromOther as bool?,
        if (messageKind != ignore) 19: messageKind as int?,
        if (expiration != ignore) 20: expiration as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension ChatSessionModelISARQueryBuilderUpdate
    on QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QOperations> {
  _ChatSessionModelISARQueryUpdate get updateFirst =>
      _ChatSessionModelISARQueryBuilderUpdateImpl(this, limit: 1);

  _ChatSessionModelISARQueryUpdate get updateAll =>
      _ChatSessionModelISARQueryBuilderUpdateImpl(this);
}

extension ChatSessionModelISARQueryFilter on QueryBuilder<ChatSessionModelISAR,
    ChatSessionModelISAR, QFilterCondition> {
  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatIdGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatIdLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      chatIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      chatIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      chatNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      chatNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> senderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> senderGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> senderGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> senderLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> senderLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> senderBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> senderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> senderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      senderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      senderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> senderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> senderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> receiverEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> receiverGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> receiverGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> receiverLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> receiverLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> receiverBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> receiverStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> receiverEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      receiverContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      receiverMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> receiverIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> receiverIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      groupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      groupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> unreadCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> unreadCountGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> unreadCountGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> unreadCountLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> unreadCountLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> unreadCountBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> createTimeEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> createTimeGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> createTimeGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> createTimeLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> createTimeLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> createTimeBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> lastActivityTimeEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> lastActivityTimeGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> lastActivityTimeGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> lastActivityTimeLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> lastActivityTimeLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> lastActivityTimeBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatTypeEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatTypeGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatTypeGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatTypeLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatTypeLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> chatTypeBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> isSingleChatEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 12,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      messageTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      messageTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 12,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 13));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 13));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 13,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      avatarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      avatarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 13,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 13,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> avatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 13,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> alwaysTopEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 15));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 15));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 15,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      draftContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      draftMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 15,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 15,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> draftIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 15,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 16));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 16));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 16,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      replyMessageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      replyMessageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 16,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 16,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> replyMessageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 16,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> isMentionedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> isZapsFromOtherEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 18,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageKindIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 19));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageKindIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 19));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageKindEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageKindGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageKindGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageKindLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageKindLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> messageKindBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 19,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> expirationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 20));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> expirationIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 20));
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> expirationEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> expirationGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> expirationGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> expirationLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> expirationLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> expirationBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 20,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 21,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsElementGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 21,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 21,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsElementLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 21,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsElementLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 21,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 21,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 21,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 21,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      reactionMessageIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 21,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      reactionMessageIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 21,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 21,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 21,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsIsEmpty() {
    return not().reactionMessageIdsIsNotEmpty();
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> reactionMessageIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 21, value: null),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 22,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsElementGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 22,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 22,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsElementLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 22,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsElementLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 22,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 22,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 22,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 22,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      mentionMessageIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 22,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
          QAfterFilterCondition>
      mentionMessageIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 22,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 22,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 22,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsIsEmpty() {
    return not().mentionMessageIdsIsNotEmpty();
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR,
      QAfterFilterCondition> mentionMessageIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 22, value: null),
      );
    });
  }
}

extension ChatSessionModelISARQueryObject on QueryBuilder<ChatSessionModelISAR,
    ChatSessionModelISAR, QFilterCondition> {}

extension ChatSessionModelISARQuerySortBy
    on QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QSortBy> {
  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByChatId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByChatIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByChatName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByChatNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortBySender({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortBySenderDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByReceiver({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByReceiverDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByGroupId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByGroupIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByContentDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByUnreadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByLastActivityTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByLastActivityTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByChatType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByChatTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByIsSingleChat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByIsSingleChatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByMessageType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByMessageTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByAvatar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        13,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByAvatarDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        13,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByAlwaysTop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByAlwaysTopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByDraft({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        15,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByDraftDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        15,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByReplyMessageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        16,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByReplyMessageIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        16,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByIsMentioned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByIsMentionedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByIsZapsFromOther() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByIsZapsFromOtherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByMessageKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByMessageKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByExpiration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      sortByExpirationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20, sort: Sort.desc);
    });
  }
}

extension ChatSessionModelISARQuerySortThenBy
    on QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QSortThenBy> {
  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByChatId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByChatIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByChatName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByChatNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenBySender({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenBySenderDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByReceiver({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByReceiverDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByGroupId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByGroupIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByContentDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByUnreadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByLastActivityTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByLastActivityTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByChatType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByChatTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByIsSingleChat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByIsSingleChatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByMessageType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByMessageTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByAvatar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByAvatarDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByAlwaysTop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByAlwaysTopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByDraft({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByDraftDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByReplyMessageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByReplyMessageIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByIsMentioned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByIsMentionedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByIsZapsFromOther() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByIsZapsFromOtherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByMessageKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByMessageKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19, sort: Sort.desc);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByExpiration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterSortBy>
      thenByExpirationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20, sort: Sort.desc);
    });
  }
}

extension ChatSessionModelISARQueryWhereDistinct
    on QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QDistinct> {
  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByChatId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByChatName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctBySender({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByReceiver({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByGroupId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByLastActivityTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByChatType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByIsSingleChat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByMessageType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByAvatar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByAlwaysTop() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByDraft({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(15, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByReplyMessageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(16, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByIsMentioned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(17);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByIsZapsFromOther() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(18);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByMessageKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(19);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByExpiration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(20);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByReactionMessageIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(21);
    });
  }

  QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QAfterDistinct>
      distinctByMentionMessageIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(22);
    });
  }
}

extension ChatSessionModelISARQueryProperty1
    on QueryBuilder<ChatSessionModelISAR, ChatSessionModelISAR, QProperty> {
  QueryBuilder<ChatSessionModelISAR, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ChatSessionModelISAR, String, QAfterProperty> chatIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ChatSessionModelISAR, String?, QAfterProperty>
      chatNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<ChatSessionModelISAR, String, QAfterProperty> senderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<ChatSessionModelISAR, String, QAfterProperty>
      receiverProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<ChatSessionModelISAR, String?, QAfterProperty>
      groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<ChatSessionModelISAR, String?, QAfterProperty>
      contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<ChatSessionModelISAR, int, QAfterProperty>
      unreadCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<ChatSessionModelISAR, int, QAfterProperty> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<ChatSessionModelISAR, int, QAfterProperty>
      lastActivityTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<ChatSessionModelISAR, int, QAfterProperty> chatTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<ChatSessionModelISAR, bool, QAfterProperty>
      isSingleChatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<ChatSessionModelISAR, String?, QAfterProperty>
      messageTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<ChatSessionModelISAR, String?, QAfterProperty> avatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<ChatSessionModelISAR, bool, QAfterProperty> alwaysTopProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<ChatSessionModelISAR, String?, QAfterProperty> draftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<ChatSessionModelISAR, String?, QAfterProperty>
      replyMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<ChatSessionModelISAR, bool, QAfterProperty>
      isMentionedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<ChatSessionModelISAR, bool, QAfterProperty>
      isZapsFromOtherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<ChatSessionModelISAR, int?, QAfterProperty>
      messageKindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<ChatSessionModelISAR, int?, QAfterProperty>
      expirationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }

  QueryBuilder<ChatSessionModelISAR, List<String>, QAfterProperty>
      reactionMessageIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(21);
    });
  }

  QueryBuilder<ChatSessionModelISAR, List<String>, QAfterProperty>
      mentionMessageIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(22);
    });
  }
}

extension ChatSessionModelISARQueryProperty2<R>
    on QueryBuilder<ChatSessionModelISAR, R, QAfterProperty> {
  QueryBuilder<ChatSessionModelISAR, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, String), QAfterProperty>
      chatIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, String?), QAfterProperty>
      chatNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, String), QAfterProperty>
      senderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, String), QAfterProperty>
      receiverProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, String?), QAfterProperty>
      groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, String?), QAfterProperty>
      contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, int), QAfterProperty>
      unreadCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, int), QAfterProperty>
      createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, int), QAfterProperty>
      lastActivityTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, int), QAfterProperty>
      chatTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, bool), QAfterProperty>
      isSingleChatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, String?), QAfterProperty>
      messageTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, String?), QAfterProperty>
      avatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, bool), QAfterProperty>
      alwaysTopProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, String?), QAfterProperty>
      draftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, String?), QAfterProperty>
      replyMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, bool), QAfterProperty>
      isMentionedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, bool), QAfterProperty>
      isZapsFromOtherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, int?), QAfterProperty>
      messageKindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, int?), QAfterProperty>
      expirationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, List<String>), QAfterProperty>
      reactionMessageIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(21);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R, List<String>), QAfterProperty>
      mentionMessageIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(22);
    });
  }
}

extension ChatSessionModelISARQueryProperty3<R1, R2>
    on QueryBuilder<ChatSessionModelISAR, (R1, R2), QAfterProperty> {
  QueryBuilder<ChatSessionModelISAR, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, String), QOperations>
      chatIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, String?), QOperations>
      chatNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, String), QOperations>
      senderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, String), QOperations>
      receiverProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, String?), QOperations>
      groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, String?), QOperations>
      contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, int), QOperations>
      unreadCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, int), QOperations>
      createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, int), QOperations>
      lastActivityTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, int), QOperations>
      chatTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, bool), QOperations>
      isSingleChatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, String?), QOperations>
      messageTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, String?), QOperations>
      avatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, bool), QOperations>
      alwaysTopProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, String?), QOperations>
      draftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, String?), QOperations>
      replyMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, bool), QOperations>
      isMentionedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, bool), QOperations>
      isZapsFromOtherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, int?), QOperations>
      messageKindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, int?), QOperations>
      expirationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, List<String>), QOperations>
      reactionMessageIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(21);
    });
  }

  QueryBuilder<ChatSessionModelISAR, (R1, R2, List<String>), QOperations>
      mentionMessageIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(22);
    });
  }
}
