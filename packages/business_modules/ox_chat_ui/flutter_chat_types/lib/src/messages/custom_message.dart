import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../message.dart';
import '../user.dart' show User;
import 'partial_custom.dart';

// part 'custom_message.g.dart'; // TODO: Restore when json_serializable generation is available

/// A class that represents custom message. Use [metadata] to store anything
/// you want.
@JsonSerializable()
@immutable
abstract class CustomMessage extends Message {
  /// Creates a custom message.
  const CustomMessage._({
    required super.author,
    required super.createdAt,
    required super.id,
    super.sourceKey,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.repliedMessageId,
    super.roomId,
    super.showStatus,
    super.status,
    MessageType? type,
    super.decryptKey,
    super.decryptNonce,
    super.updatedAt,
    super.expiration,
    super.reactions,
    super.zapsInfoList,
    required this.viewWithoutBubble,
    super.isMe,
  }) : super(type: type ?? MessageType.custom);

  const factory CustomMessage({
    required User author,
    required int createdAt,
    required String id,
    dynamic sourceKey,
    Map<String, dynamic>? metadata,
    String? remoteId,
    Message? repliedMessage,
    String? repliedMessageId,
    String? roomId,
    bool? showStatus,
    Status? status,
    MessageType? type,
    String? decryptKey,
    String? decryptNonce,
    int? updatedAt,
    int? expiration,
    List<Reaction> reactions,
    List<ZapsInfo> zapsInfoList,
    required bool viewWithoutBubble,
    bool isMe,
  }) = _CustomMessage;

  @override
  final bool viewWithoutBubble;

  /// Creates a custom message from a map (decoded JSON).
  factory CustomMessage.fromJson(Map<String, dynamic> _json) =>
      throw UnimplementedError('JSON deserialization temporarily disabled');

  /// Creates a full custom message from a partial one.
  factory CustomMessage.fromPartial({
    required User author,
    required int createdAt,
    required String id,
    required PartialCustom partialCustom,
    String? remoteId,
    String? roomId,
    bool? showStatus,
    Status? status,
    String? decryptKey,
    int? updatedAt,
    int? expiration,
    required bool viewWithoutBubble,
  }) =>
      _CustomMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        metadata: partialCustom.metadata,
        remoteId: remoteId,
        repliedMessage: partialCustom.repliedMessage,
        roomId: roomId,
        showStatus: showStatus,
        status: status,
        type: MessageType.custom,
        decryptKey: decryptKey,
        updatedAt: updatedAt,
        expiration: expiration,
        viewWithoutBubble: viewWithoutBubble,
        isMe: false,
      );

  @override
  String get content {
    try {
      return json.encode(metadata);
    } catch (e) {
      return '';
    }
  }

  /// Equatable props.
  @override
  List<Object?> get props => [
        author,
        createdAt,
        id,
        metadata,
        remoteId,
        repliedMessage,
        roomId,
        showStatus,
        status,
        updatedAt,
        expiration,
      ];

  @override
  CustomMessage copyWith({
    User? author,
    int? createdAt,
    String? id,
    dynamic sourceKey,
    Map<String, dynamic>? metadata,
    String? remoteId,
    Message? repliedMessage,
    String? repliedMessageId,
    String? roomId,
    bool? showStatus,
    Status? status,
    int? updatedAt,
    EncryptionType? fileEncryptionType,
    String? decryptKey,
    String? decryptNonce,
    int? expiration,
    List<Reaction>? reactions,
    List<ZapsInfo>? zapsInfoList,
    bool? isMe,
  });

  /// Converts a custom message to the map representation,
  /// encodable to JSON.
  @override
  Map<String, dynamic> toJson() => throw UnimplementedError('JSON serialization temporarily disabled');
}

/// A utility class to enable better copyWith.
class _CustomMessage extends CustomMessage {
  const _CustomMessage({
    required super.author,
    required super.createdAt,
    required super.id,
    super.sourceKey,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.repliedMessageId,
    super.roomId,
    super.showStatus,
    super.status,
    super.type,
    super.decryptKey,
    super.decryptNonce,
    super.updatedAt,
    super.expiration,
    super.reactions,
    super.zapsInfoList,
    required super.viewWithoutBubble,
    super.isMe,
  }) : super._();

  @override
  CustomMessage copyWith({
    User? author,
    int? createdAt,
    String? id,
    dynamic sourceKey,
    dynamic metadata = _Unset,
    dynamic remoteId = _Unset,
    dynamic repliedMessage = _Unset,
    String? repliedMessageId,
    dynamic roomId,
    dynamic showStatus = _Unset,
    dynamic status = _Unset,
    dynamic updatedAt = _Unset,
    EncryptionType? fileEncryptionType,
    String? decryptKey,
    String? decryptNonce,
    int? expiration,
    List<Reaction>? reactions,
    List<ZapsInfo>? zapsInfoList,
    bool? viewWithoutBubble,
    bool? isMe,
  }) =>
      _CustomMessage(
        author: author ?? this.author,
        createdAt: createdAt ?? this.createdAt,
        id: id ?? this.id,
        sourceKey: sourceKey ?? this.sourceKey,
        metadata: metadata == _Unset
            ? jsonDecode(jsonEncode(this.metadata))
            : metadata as Map<String, dynamic>?,
        remoteId: remoteId == _Unset ? this.remoteId : remoteId as String?,
        repliedMessage: repliedMessage == _Unset
            ? this.repliedMessage
            : repliedMessage as Message?,
        repliedMessageId: repliedMessageId ?? this.repliedMessageId,
        roomId: roomId == _Unset ? this.roomId : roomId as String?,
        showStatus:
            showStatus == _Unset ? this.showStatus : showStatus as bool?,
        status: status == _Unset ? this.status : status as Status?,
        decryptKey: decryptKey ?? this.decryptKey,
        decryptNonce: decryptNonce ?? this.decryptNonce,
        updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
        expiration: expiration ?? this.expiration,
        viewWithoutBubble: viewWithoutBubble ?? this.viewWithoutBubble,
        isMe: isMe ?? this.isMe,
        reactions: reactions ?? this.reactions,
        zapsInfoList: zapsInfoList ?? this.zapsInfoList,
      );
}

class _Unset {}
