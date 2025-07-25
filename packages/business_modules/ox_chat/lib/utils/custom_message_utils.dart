
import 'dart:convert';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ox_chat/utils/widget_tool.dart';
import 'package:ox_common/business_interface/ox_chat/call_message_type.dart';
import 'package:ox_common/business_interface/ox_chat/custom_message_type.dart';

extension CustomMessageEx on types.CustomMessage {

  static const metaTypeKey = 'type';
  static const metaContentKey = 'content';

  CustomMessageType? get customType =>
      CustomMessageTypeEx.fromValue(metadata?[CustomMessageEx.metaTypeKey]);

  // static Map<String, dynamic> zapsMetaData({
  //   required String zapper,
  //   required String invoice,
  //   required String amount,
  //   required String description,
  // }) {
  //   return _metaData(CustomMessageType.zaps, {
  //     'zapper': zapper,
  //     'invoice': invoice,
  //     'amount': amount,
  //     'description': description,
  //   });
  // }
  //
  // static Map<String, dynamic> callMetaData({
  //   required String text,
  //   required CallMessageType type,
  // }) {
  //   return _metaData(CustomMessageType.call, {
  //     'text': text,
  //     'type': type.value,
  //   });
  // }

  static Map<String, dynamic> templateMetaData({
    required String title,
    required String content,
    required String icon,
    required String link,
  }) {
    return _metaData(CustomMessageType.template, {
      'title': title,
      'content': content,
      'icon': icon,
      'link': link,
    });
  }

  static Map<String, dynamic> noteMetaData({
    required String sourceScheme,
    required String authorIcon,
    required String authorName,
    required String authorDNS,
    required String createTime,
    required String note,
    required String image,
    required String link,
  }) {
    return _metaData(CustomMessageType.note, {
      'sourceScheme': sourceScheme,
      'authorIcon': authorIcon,
      'authorName': authorName,
      'authorDNS': authorDNS,
      'createTime': createTime,
      'note': note,
      'image': image,
      'link': link,
    });
  }

  // static Map<String, dynamic> ecashMetaData({
  //   required List<String> tokenList,
  //   String isOpened = '',
  // }) {
  //   return _metaData(CustomMessageType.ecash, {
  //     EcashMessageEx.metaTokenListKey: tokenList,
  //     EcashMessageEx.metaIsOpenedKey: isOpened,
  //   });
  // }
  //
  // static Map<String, dynamic> ecashV2MetaData({
  //   required List<String> tokenList,
  //   List<String> receiverPubkeys = const [],
  //   List<EcashSignee> signees = const [],
  //   String validityDate = '',
  //   String isOpened = '',
  // }) {
  //   return _metaData(CustomMessageType.ecashV2, {
  //     EcashV2MessageEx.metaTokenListKey: tokenList,
  //     EcashV2MessageEx.metaIsOpenedKey: isOpened,
  //     if (receiverPubkeys.isNotEmpty)
  //       EcashV2MessageEx.metaReceiverPubkeysKey: receiverPubkeys,
  //     if (signees.isNotEmpty)
  //       EcashV2MessageEx.metaSigneesKey: signees.map((e) => {
  //         EcashV2MessageEx.metaSigneesPubkeyKey: e.$1,
  //         EcashV2MessageEx.metaSigneesSignatureKey: e.$2,
  //       }).toList(),
  //     if (validityDate.isNotEmpty)
  //       EcashV2MessageEx.metaValidityDateKey: validityDate,
  //   });
  // }

  static Map<String, dynamic> imageSendingMetaData({
    String fileId = '',
    String path = '',
    String url = '',
    int? width,
    int? height,
    String? encryptedKey,
    required String? encryptedNonce,
  }) {
    return _metaData(CustomMessageType.imageSending, {
      ImageSendingMessageEx.metaFileIdKey: fileId,
      ImageSendingMessageEx.metaPathKey: path,
      ImageSendingMessageEx.metaURLKey: url,
      if (width != null)
        ImageSendingMessageEx.metaWidthKey: width,
      if (height != null)
        ImageSendingMessageEx.metaHeightKey: height,
      ImageSendingMessageEx.metaEncryptedKey: encryptedKey,
      ImageSendingMessageEx.metaEncryptedNonce: encryptedNonce,
    });
  }

  static Map<String, dynamic> videoMetaData({
    required String fileId,
    String snapshotPath = '',
    String videoPath = '',
    String url = '',
    int? width,
    int? height,
    String? encryptedKey,
    String? encryptedNonce,
  }) {
    return _metaData(CustomMessageType.video, {
      VideoMessageEx.metaFileIdKey: fileId,
      VideoMessageEx.metaSnapshotPathKey: snapshotPath,
      VideoMessageEx.metaVideoPathKey: videoPath,
      VideoMessageEx.metaURLKey: url,
      if (width != null)
        VideoMessageEx.metaWidthKey: width,
      if (height != null)
        VideoMessageEx.metaHeightKey: height,
      VideoMessageEx.metaEncryptedKey: encryptedKey,
      VideoMessageEx.metaEncryptedNonce: encryptedNonce,
    });
  }

  static Map<String, dynamic> _metaData(
    CustomMessageType type,
    Map<String, dynamic> content,
  ) {
    return {
      CustomMessageEx.metaTypeKey: type.value,
      CustomMessageEx.metaContentKey: content,
    };
  }

  String get customContentString {
    try {
      return jsonEncode(metadata ?? {});
    } catch(e) {
      return '';
    }
  }
}

extension ZapsMessageEx on types.CustomMessage {
  String get zapper => metadata?[CustomMessageEx.metaContentKey]?['zapper'] ?? '';
  String get invoice => metadata?[CustomMessageEx.metaContentKey]?['invoice'] ?? '';
  int get amount => int.tryParse(metadata?[CustomMessageEx.metaContentKey]?['amount'] ?? '') ?? 0;
  String get description => metadata?[CustomMessageEx.metaContentKey]?['description'] ?? '';
}

extension CallMessageEx on types.CustomMessage {
  String get callText => metadata?[CustomMessageEx.metaContentKey]?['text'] ?? '';
  CallMessageType? get callType => CallMessageTypeEx.fromValue(metadata?[CustomMessageEx.metaContentKey]?['type']);

  static String? getDescriptionWithMetadata(Map? metadata) {
    final type = CallMessageTypeEx.fromValue(metadata?[CustomMessageEx.metaContentKey]?['type']);
    if (type == null) return null;
    switch (type) {
      case CallMessageType.audio: return '[${'str_voice_call'.localized()}]';
      case CallMessageType.video: return '[${'str_video_call'.localized()}]';
    }
  }
}

extension TemplateMessageEx on types.CustomMessage {
  String get title => metadata?[CustomMessageEx.metaContentKey]?['title'] ?? '';
  String get content => metadata?[CustomMessageEx.metaContentKey]?['content'] ?? '';
  String get icon => metadata?[CustomMessageEx.metaContentKey]?['icon'] ?? '';
  String get link => metadata?[CustomMessageEx.metaContentKey]?['link'] ?? '';
}

extension NoteMessageEx on types.CustomMessage {
  String get authorIcon => metadata?[CustomMessageEx.metaContentKey]?['authorIcon'] ?? '';
  String get authorName => metadata?[CustomMessageEx.metaContentKey]?['authorName'] ?? '';
  String get authorDNS => metadata?[CustomMessageEx.metaContentKey]?['authorDNS'] ?? '';
  int get createTime => int.tryParse(metadata?[CustomMessageEx.metaContentKey]?['createTime'] ?? '') ?? 0;
  String get note => metadata?[CustomMessageEx.metaContentKey]?['note'] ?? '';
  String get image => metadata?[CustomMessageEx.metaContentKey]?['image'] ?? '';
  String get link => metadata?[CustomMessageEx.metaContentKey]?['link'] ?? '';

  static String? getSourceSchemeWithMetadata(Map? metadata) =>
      metadata?[CustomMessageEx.metaContentKey]?['sourceScheme'];
}

extension ImageSendingMessageEx on types.CustomMessage {
  static const metaFileIdKey = 'fileId';
  static const metaPathKey = 'path';
  static const metaURLKey = 'url';
  static const metaWidthKey = 'width';
  static const metaHeightKey = 'height';
  static const metaEncryptedKey = 'encrypted';
  static const metaEncryptedNonce = 'encryptedNonce';

  String get fileId => metadata?[CustomMessageEx.metaContentKey]?[metaFileIdKey] ?? '';
  String get path => metadata?[CustomMessageEx.metaContentKey]?[metaPathKey] ?? '';
  // This property could be a remote URL or an image encoded in Base64 format.
  String get url => metadata?[CustomMessageEx.metaContentKey]?[metaURLKey] ?? '';
  int? get width => metadata?[CustomMessageEx.metaContentKey]?[metaWidthKey];
  int? get height => metadata?[CustomMessageEx.metaContentKey]?[metaHeightKey];
  String? get encryptedKey => metadata?[CustomMessageEx.metaContentKey]?[metaEncryptedKey];
  String? get encryptedNonce => metadata?[CustomMessageEx.metaContentKey]?[metaEncryptedNonce];

  String get uri => path.isNotEmpty ? path : url;
}

extension VideoMessageEx on types.CustomMessage {
  static const metaFileIdKey = 'fileId';
  static const metaSnapshotPathKey = 'snapshotPath';
  static const metaVideoPathKey = 'videoPath';
  static const metaURLKey = 'url';
  static const metaWidthKey = 'width';
  static const metaHeightKey = 'height';
  static const metaEncryptedKey = 'encrypted';
  static const metaEncryptedNonce = 'encryptedNonce';

  String get fileId => metadata?[CustomMessageEx.metaContentKey]?[metaFileIdKey] ?? '';
  String get snapshotPath => metadata?[CustomMessageEx.metaContentKey]?[metaSnapshotPathKey] ?? '';
  String get videoPath => metadata?[CustomMessageEx.metaContentKey]?[metaVideoPathKey] ?? '';
  String get url => metadata?[CustomMessageEx.metaContentKey]?[metaURLKey] ?? '';
  int? get width => metadata?[CustomMessageEx.metaContentKey]?[metaWidthKey];
  int? get height => metadata?[CustomMessageEx.metaContentKey]?[metaHeightKey];
  String? get encryptedKey => metadata?[CustomMessageEx.metaContentKey]?[metaEncryptedKey];
  String? get encryptedNonce => metadata?[CustomMessageEx.metaContentKey]?[metaEncryptedNonce];

  bool get isLocalFile => videoPath.isNotEmpty;

  String get videoURI {
    return isLocalFile ? videoPath : url;
  }

  void set snapshotPath(String value) {
    metadata?[CustomMessageEx.metaContentKey]?[metaSnapshotPathKey] = value;
  }

  void set videoPath(String value) {
    metadata?[CustomMessageEx.metaContentKey]?[metaVideoPathKey] = value;
  }
}