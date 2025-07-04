import 'dart:convert';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/src/message.dart' as UIMessage;
import 'package:ox_common/business_interface/ox_chat/custom_message_type.dart';
import 'package:ox_chat/utils/custom_message_utils.dart';
import 'package:ox_common/business_interface/ox_chat/utils.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/web_url_helper.dart';
import 'package:ox_localizable/ox_localizable.dart';

abstract class MessageFactory {
  types.Message? createMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String? messageId,
    required String? remoteId,
    required dynamic sourceKey,
    required String content,
    UIMessage.Status? status,
    UIMessage.EncryptionType fileEncryptionType = UIMessage.EncryptionType.none,
    types.Message? repliedMessage,
    String? repliedMessageId,
    String? previewData,
    String? decryptKey,
    String? decryptNonce,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    bool isMe = false,
  });
}

class TextMessageFactory implements MessageFactory {
  types.Message? createMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String? messageId,
    required String? remoteId,
    required dynamic sourceKey,
    required String content,
    UIMessage.Status? status,
    UIMessage.EncryptionType fileEncryptionType = UIMessage.EncryptionType.none,
    types.Message? repliedMessage,
    String? repliedMessageId,
    String? previewData,
    String? decryptKey,
    String? decryptNonce,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    bool isMe = false,
  }) {
    final text = content;
    PreviewData? previewDataEntry;
    if (previewData != null && previewData.isNotEmpty) {
      try {
        previewDataEntry = PreviewData.fromJson(jsonDecode(previewData));
      } catch (_) {}
    }
    return types.TextMessage(
      author: author,
      createdAt: timestamp,
      id: remoteId ?? messageId ?? '',
      sourceKey: sourceKey,
      roomId: roomId,
      remoteId: remoteId,
      text: text,
      status: status,
      repliedMessage: repliedMessage,
      repliedMessageId: repliedMessageId,
      previewData: previewDataEntry,
      expiration: expiration,
      reactions: reactions,
      zapsInfoList: zapsInfoList,
      isMe: isMe,
    );
  }
}

class ImageMessageFactory implements MessageFactory {
  types.Message? createMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String? messageId,
    required String? remoteId,
    required dynamic sourceKey,
    required String content,
    UIMessage.Status? status,
    UIMessage.EncryptionType fileEncryptionType = UIMessage.EncryptionType.none,
    types.Message? repliedMessage,
    String? repliedMessageId,
    String? previewData,
    String? decryptKey,
    String? decryptNonce,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    bool isMe = false,
  }) {
    final uri = content;
    if (uri.isEmpty) {
      return null;
    }
    return types.ImageMessage(
      name: '',
      size: 60,
      uri: uri,
      author: author,
      createdAt: timestamp,
      id: remoteId ?? messageId ?? '',
      sourceKey: sourceKey,
      roomId: roomId,
      remoteId: remoteId,
      status: status,
      repliedMessage: repliedMessage,
      repliedMessageId: repliedMessageId,
      fileEncryptionType: fileEncryptionType,
      decryptKey: decryptKey,
      decryptNonce: decryptNonce,
      expiration: expiration,
      reactions: reactions,
      zapsInfoList: zapsInfoList,
      isMe: isMe,
    );
  }
}

class AudioMessageFactory implements MessageFactory {
  types.Message? createMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String? messageId,
    required String? remoteId,
    required dynamic sourceKey,
    required String content,
    UIMessage.Status? status,
    UIMessage.EncryptionType fileEncryptionType = UIMessage.EncryptionType.none,
    types.Message? repliedMessage,
    String? repliedMessageId,
    String? previewData,
    String? decryptKey,
    String? decryptNonce,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    bool isMe = false,
  }) {
    final uri = content;
    if (uri.isEmpty) {
      return null;
    }
    return types.AudioMessage(
      duration: null,
      name: '$remoteId.mp3',
      size: 60,
      uri: uri,
      author: author,
      createdAt: timestamp,
      id: remoteId ?? messageId ?? '',
      sourceKey: sourceKey,
      roomId: roomId,
      remoteId: remoteId,
      status: status,
      repliedMessage: repliedMessage,
      repliedMessageId: repliedMessageId,
      fileEncryptionType: fileEncryptionType,
      decryptKey: decryptKey,
      decryptNonce: decryptNonce,
      expiration: expiration,
      reactions: reactions,
      zapsInfoList: zapsInfoList,
      isMe: isMe,
    );
  }
}

class VideoMessageFactory implements MessageFactory {
  types.Message? createMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String? messageId,
    required String? remoteId,
    required dynamic sourceKey,
    required String content,
    UIMessage.Status? status,
    UIMessage.EncryptionType fileEncryptionType = UIMessage.EncryptionType.none,
    types.Message? repliedMessage,
    String? repliedMessageId,
    String? previewData,
    String? decryptKey,
    String? decryptNonce,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    bool isMe = false,
  }) {
    final uri = content;
    final snapshotUrl =
        '${uri}?spm=qipa250&x-oss-process=video/snapshot,t_7000,f_jpg,w_0,h_0,m_fast';
    if (uri.isEmpty) {
      return null;
    }
    return types.CustomMessage(
      author: author,
      createdAt: timestamp,
      id: remoteId ?? messageId ?? '',
      sourceKey: sourceKey,
      remoteId: remoteId,
      roomId: roomId,
      repliedMessage: repliedMessage,
      repliedMessageId: repliedMessageId,
      metadata: CustomMessageEx.videoMetaData(
        fileId: '',
        snapshotPath: '',
        videoPath: '',
        url: uri,
        width: null,
        height: null,
        encryptedKey: decryptKey,
        encryptedNonce: decryptNonce,
      ),
      type: types.MessageType.custom,
      decryptKey: decryptKey,
      decryptNonce: decryptNonce,
      expiration: expiration,
      reactions: reactions,
      zapsInfoList: zapsInfoList,
      viewWithoutBubble: true,
      isMe: isMe,
    );
  }
}

// class CallMessageFactory implements MessageFactory {
//   types.Message? createMessage({
//     required types.User author,
//     required int timestamp,
//     required String roomId,
//     required String? messageId,
//     required String? remoteId,
//     required dynamic sourceKey,
//     required String content,
//     UIMessage.Status? status,
//     UIMessage.EncryptionType fileEncryptionType = UIMessage.EncryptionType.none,
//     types.Message? repliedMessage,
//     String? repliedMessageId,
//     String? previewData,
//     String? decryptKey,
//     String? decryptNonce,
//     int? expiration,
//     List<types.Reaction> reactions = const [],
//     List<types.ZapsInfo> zapsInfoList = const [],
//   }) {
//     if (content.isEmpty) return null;
//
//     var contentMap;
//     try {
//       contentMap = json.decode(content);
//       if (contentMap is! Map) return null;
//     } catch (_) {}
//
//     final state = CallMessageState.values
//         .cast<CallMessageState?>()
//         .firstWhere((state) => state.toString() == contentMap['state'], orElse: () => null);
//     var duration = contentMap['duration'];
//     final media = CallMessageTypeEx.fromValue(contentMap['media']);
//     if (state is! CallMessageState || duration is! int || media == null) return null;
//
//     if (!state.shouldShowMessage) return null;
//
//     duration = max(duration, 0);
//     final isMe = OXUserInfoManager.sharedInstance.isCurrentUser(author.id);
//     final durationText = Duration(milliseconds: duration).toString().substring(2, 7);
//     return types.CustomMessage(
//       author: author,
//       createdAt: timestamp,
//       id: remoteId ?? messageId ?? '',
//       sourceKey: sourceKey,
//       remoteId: remoteId,
//       roomId: roomId,
//       repliedMessage: repliedMessage,
//       repliedMessageId: repliedMessageId,
//       metadata: CustomMessageEx.callMetaData(
//         text: state.messageText(isMe, durationText),
//         type: media,
//       ),
//       type: types.MessageType.custom,
//       expiration: expiration,
//       reactions: reactions,
//       zapsInfoList: zapsInfoList,
//       viewWithoutBubble: false,
//     );
//   }
// }
//
// extension CallStateMessageEx on CallMessageState {
//   bool get shouldShowMessage {
//     switch (this) {
//       case CallMessageState.cancel:
//       case CallMessageState.reject:
//       case CallMessageState.timeout:
//       case CallMessageState.disconnect:
//       case CallMessageState.inCalling:
//         return true;
//       default:
//         return false;
//     }
//   }
//
//   String messageText(bool isMe, String durationText) {
//     switch (this) {
//       case CallMessageState.cancel:
//         return isMe
//             ? Localized.text('ox_calling.str_call_canceled')
//             : Localized.text('ox_calling.str_call_other_canceled');
//       case CallMessageState.reject:
//         return isMe
//             ? Localized.text('ox_calling.str_call_other_rejected')
//             : Localized.text('ox_calling.str_call_rejected');
//       case CallMessageState.timeout:
//         return isMe
//             ? Localized.text('ox_calling.str_call_other_not_answered')
//             : Localized.text('ox_calling.str_call_not_answered');
//       case CallMessageState.disconnect:
//         return Localized.text('ox_calling.str_call_duration').replaceAll(r'${time}', durationText);
//       case CallMessageState.inCalling:
//         return Localized.text('ox_calling.str_call_busy');
//       default:
//         return '';
//     }
//   }
// }

class SystemMessageFactory implements MessageFactory {
  types.Message? createMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String? messageId,
    required String? remoteId,
    required dynamic sourceKey,
    required String content,
    UIMessage.Status? status,
    UIMessage.EncryptionType fileEncryptionType = UIMessage.EncryptionType.none,
    types.Message? repliedMessage,
    String? repliedMessageId,
    String? previewData,
    String? decryptKey,
    String? decryptNonce,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    bool isMe = false,
  }) {
    var text = content;
    final key = text;
    if (key.isNotEmpty) {
      text = Localized.text(key, useOrigin: true);
      if (key == 'ox_chat.screen_record_hint_message' || key == 'ox_chat.screenshot_hint_message') {
        final name =
            isMe ? Localized.text('ox_common.you') : (author.sourceObject?.getUserShowName() ?? '');
        text = text.replaceAll(r'${user}', name);
      }
    }
    return types.SystemMessage(
      author: author,
      createdAt: timestamp,
      id: remoteId ?? messageId ?? '',
      roomId: roomId,
      repliedMessage: repliedMessage,
      repliedMessageId: repliedMessageId,
      text: text,
      expiration: expiration,
      reactions: reactions,
      zapsInfoList: zapsInfoList,
      isMe: isMe,
    );
  }
}

class CustomMessageFactory implements MessageFactory {
  static ({CustomMessageType type, Map content})? parseFromContentString(String contentString) {
    try {
      final contentMap = json.decode(contentString);
      if (contentMap is! Map) return null;

      final type = CustomMessageTypeEx.fromValue(contentMap['type']);
      final content = contentMap['content'];
      if (type == null || content is! Map) return null;

      return (type: type, content: content);
    } catch (_) {
      return null;
    }
  }

  types.Message? createMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String? messageId,
    required String? remoteId,
    required dynamic sourceKey,
    required String content,
    UIMessage.Status? status,
    UIMessage.EncryptionType fileEncryptionType = UIMessage.EncryptionType.none,
    types.Message? repliedMessage,
    String? repliedMessageId,
    String? previewData,
    String? decryptKey,
    String? decryptNonce,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    bool isMe = false,
  }) {
    final contentString = content;
    if (contentString.isEmpty) return null;

    final info = CustomMessageFactory.parseFromContentString(contentString);
    if (info == null) return null;

    final type = info.type;
    final contentMap = info.content;

    switch (type) {
      // case CustomMessageType.zaps:
      //   final zapper = contentMap['zapper'];
      //   final invoice = contentMap['invoice'];
      //   final amount = contentMap['amount'];
      //   final description = contentMap['description'];
      //   return createZapsMessage(
      //     author: author,
      //     timestamp: timestamp,
      //     roomId: roomId,
      //     id: remoteId ?? messageId ?? '',
      //     remoteId: remoteId,
      //     sourceKey: sourceKey,
      //     zapper: zapper,
      //     invoice: invoice,
      //     amount: amount,
      //     description: description,
      //     expiration: expiration,
      //     status: status,
      //     reactions: reactions,
      //     zapsInfoList: zapsInfoList,
      //   );

      case CustomMessageType.template:
        final title = contentMap['title'];
        final contentStr = contentMap['content'];
        final icon = contentMap['icon'];
        final link = contentMap['link'];
        return createTemplateMessage(
          author: author,
          timestamp: timestamp,
          roomId: roomId,
          id: remoteId ?? messageId ?? '',
          remoteId: remoteId,
          sourceKey: sourceKey,
          title: title,
          content: contentStr,
          icon: icon,
          link: link,
          expiration: expiration,
          status: status,
          reactions: reactions,
          zapsInfoList: zapsInfoList,
          isMe: isMe,
        );

      case CustomMessageType.note:
        final sourceScheme = contentMap['sourceScheme'] ?? '';
        final authorIcon = contentMap['authorIcon'] ?? '';
        final authorName = contentMap['authorName'] ?? '';
        final authorDNS = contentMap['authorDNS'] ?? '';
        final createTime = contentMap['createTime'] ?? '';
        final note = contentMap['note'] ?? '';
        final image = contentMap['image'] ?? '';
        final link = contentMap['link'] ?? '';
        return createNoteMessage(
          author: author,
          timestamp: timestamp,
          roomId: roomId,
          id: remoteId ?? messageId ?? '',
          remoteId: remoteId,
          sourceKey: sourceKey,
          sourceScheme: sourceScheme,
          authorIcon: authorIcon,
          authorName: authorName,
          authorDNS: authorDNS,
          createTime: createTime,
          note: note,
          image: image,
          link: link,
          expiration: expiration,
          status: status,
          reactions: reactions,
          zapsInfoList: zapsInfoList,
          isMe: isMe,
        );

      // case CustomMessageType.ecash:
      //   try {
      //     final tokenList = (contentMap[EcashMessageEx.metaTokenListKey] as List)
      //         .map((e) => e.toString())
      //         .toList();
      //     final isOpened = contentMap[EcashMessageEx.metaIsOpenedKey] ?? '';
      //     return createEcashMessage(
      //       author: author,
      //       timestamp: timestamp,
      //       roomId: roomId,
      //       id: remoteId ?? messageId ?? '',
      //       remoteId: remoteId,
      //       sourceKey: sourceKey,
      //       tokenList: tokenList,
      //       isOpened: isOpened,
      //       expiration: expiration,
      //       status: status,
      //       reactions: reactions,
      //       zapsInfoList: zapsInfoList,
      //     );
      //   } catch (e) {
      //     print(e);
      //     return null;
      //   }
      //
      // case CustomMessageType.ecashV2:
      //   try {
      //     final tokenListRaw = contentMap[EcashV2MessageEx.metaTokenListKey];
      //     List<String> tokenList = [];
      //     if (tokenListRaw is List) {
      //       tokenList = tokenListRaw.map((e) => e.toString()).toList();
      //     }
      //
      //     final receiverPubkeysRaw = contentMap[EcashV2MessageEx.metaReceiverPubkeysKey];
      //     List<String> receiverPubkeys = [];
      //     if (receiverPubkeysRaw is List) {
      //       receiverPubkeys = receiverPubkeysRaw.map((e) => e.toString()).toList();
      //     }
      //     return createEcashMessage(
      //       author: author,
      //       timestamp: timestamp,
      //       roomId: roomId,
      //       id: remoteId ?? messageId ?? '',
      //       remoteId: remoteId,
      //       sourceKey: sourceKey,
      //       tokenList: tokenList,
      //       receiverPubkeys: receiverPubkeys,
      //       signees: EcashV2MessageEx.getSigneesWithContentMap(contentMap),
      //       validityDate: contentMap[EcashV2MessageEx.metaValidityDateKey] ?? '',
      //       isOpened: contentMap[EcashV2MessageEx.metaIsOpenedKey] ?? '',
      //       expiration: expiration,
      //       status: status,
      //       reactions: reactions,
      //       zapsInfoList: zapsInfoList,
      //     );
      //   } catch (e, stack) {
      //     print(e);
      //     print(stack);
      //     return null;
      //   }

      case CustomMessageType.imageSending:
        String fileId = contentMap[ImageSendingMessageEx.metaFileIdKey] ?? '';
        String path = contentMap[ImageSendingMessageEx.metaPathKey] ?? '';
        String url = contentMap[ImageSendingMessageEx.metaURLKey] ?? '';
        int? width = contentMap[ImageSendingMessageEx.metaWidthKey];
        int? height = contentMap[ImageSendingMessageEx.metaHeightKey];
        String? encryptedKey = contentMap[ImageSendingMessageEx.metaEncryptedKey];
        String? encryptedNonce = contentMap[ImageSendingMessageEx.metaEncryptedNonce];
        return createImageSendingMessage(
          author: author,
          timestamp: timestamp,
          roomId: roomId,
          id: remoteId ?? messageId ?? '',
          remoteId: remoteId,
          sourceKey: sourceKey,
          expiration: expiration,
          status: status,
          reactions: reactions,
          zapsInfoList: zapsInfoList,
          fileId: fileId,
          path: path,
          url: url,
          width: width,
          height: height,
          encryptedKey: encryptedKey,
          encryptedNonce: encryptedNonce,
          isMe: isMe,
        );

      case CustomMessageType.video:
        final fileId = contentMap[VideoMessageEx.metaFileIdKey];
        final snapshotPath = contentMap[VideoMessageEx.metaSnapshotPathKey];
        final videoPath = contentMap[VideoMessageEx.metaVideoPathKey];
        final url = contentMap[VideoMessageEx.metaURLKey];
        final width = contentMap[VideoMessageEx.metaWidthKey];
        final height = contentMap[VideoMessageEx.metaHeightKey];
        final encryptedKey = contentMap[VideoMessageEx.metaEncryptedKey];
        final encryptedNonce = contentMap[VideoMessageEx.metaEncryptedNonce];
        return createVideoMessage(
          author: author,
          timestamp: timestamp,
          roomId: roomId,
          id: remoteId ?? messageId ?? '',
          remoteId: remoteId,
          sourceKey: sourceKey,
          expiration: expiration,
          status: status,
          reactions: reactions,
          zapsInfoList: zapsInfoList,
          fileId: fileId,
          snapshotPath: snapshotPath,
          videoPath: videoPath,
          url: url,
          width: width,
          height: height,
          encryptedKey: encryptedKey,
          encryptedNonce: encryptedNonce,
          isMe: isMe,
        );
    }
  }

  // types.CustomMessage createZapsMessage({
  //   required types.User author,
  //   required int timestamp,
  //   required String roomId,
  //   required String id,
  //   String? remoteId,
  //   dynamic sourceKey,
  //   UIMessage.Status? status,
  //   int? expiration,
  //   List<types.Reaction> reactions = const [],
  //   List<types.ZapsInfo> zapsInfoList = const [],
  //   required String zapper,
  //   required String invoice,
  //   required String amount,
  //   required String description,
  // }) {
  //   return types.CustomMessage(
  //     author: author,
  //     createdAt: timestamp,
  //     id: id,
  //     sourceKey: sourceKey,
  //     remoteId: remoteId,
  //     roomId: roomId,
  //     metadata: CustomMessageEx.zapsMetaData(
  //       zapper: zapper,
  //       invoice: invoice,
  //       amount: amount,
  //       description: description,
  //     ),
  //     type: types.MessageType.custom,
  //     expiration: expiration,
  //     status: status,
  //     reactions: reactions,
  //     zapsInfoList: zapsInfoList,
  //     viewWithoutBubble: true,
  //   );
  // }

  types.CustomMessage createTemplateMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String id,
    String? remoteId,
    dynamic sourceKey,
    UIMessage.Status? status,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    required String title,
    required String content,
    required String icon,
    required String link,
    bool isMe = false,
  }) {
    return types.CustomMessage(
      author: author,
      createdAt: timestamp,
      id: id,
      sourceKey: sourceKey,
      remoteId: remoteId,
      roomId: roomId,
      metadata: CustomMessageEx.templateMetaData(
        title: title,
        content: content,
        icon: icon,
        link: link,
      ),
      type: types.MessageType.custom,
      expiration: expiration,
      status: status,
      reactions: reactions,
      zapsInfoList: zapsInfoList,
      viewWithoutBubble: true,
      isMe: isMe,
    );
  }

  types.CustomMessage createNoteMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String id,
    String? remoteId,
    dynamic sourceKey,
    UIMessage.Status? status,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    required String sourceScheme,
    required String authorIcon,
    required String authorName,
    required String authorDNS,
    required String createTime,
    required String note,
    required String image,
    required String link,
    bool isMe = false,
  }) {
    return types.CustomMessage(
      author: author,
      createdAt: timestamp,
      id: id,
      sourceKey: sourceKey,
      remoteId: remoteId,
      roomId: roomId,
      metadata: CustomMessageEx.noteMetaData(
        sourceScheme: sourceScheme,
        authorIcon: authorIcon,
        authorName: authorName,
        authorDNS: authorDNS,
        createTime: createTime,
        note: note,
        image: image,
        link: link,
      ),
      type: types.MessageType.custom,
      expiration: expiration,
      status: status,
      reactions: reactions,
      zapsInfoList: zapsInfoList,
      viewWithoutBubble: true,
      isMe: isMe,
    );
  }

  // types.CustomMessage createEcashMessage({
  //   required types.User author,
  //   required int timestamp,
  //   required String roomId,
  //   required String id,
  //   String? remoteId,
  //   dynamic sourceKey,
  //   UIMessage.Status? status,
  //   int? expiration,
  //   List<types.Reaction> reactions = const [],
  //   List<types.ZapsInfo> zapsInfoList = const [],
  //   required List<String> tokenList,
  //   List<String> receiverPubkeys = const [],
  //   List<EcashSignee> signees = const [],
  //   String validityDate = '',
  //   String isOpened = '',
  // }) {
  //   return types.CustomMessage(
  //     author: author,
  //     createdAt: timestamp,
  //     id: id,
  //     sourceKey: sourceKey,
  //     remoteId: remoteId,
  //     roomId: roomId,
  //     metadata: CustomMessageEx.ecashV2MetaData(
  //       tokenList: tokenList,
  //       receiverPubkeys: receiverPubkeys,
  //       signees: signees,
  //       validityDate: validityDate,
  //       isOpened: isOpened,
  //     ),
  //     type: types.MessageType.custom,
  //     expiration: expiration,
  //     status: status,
  //     reactions: reactions,
  //     zapsInfoList: zapsInfoList,
  //     viewWithoutBubble: true,
  //   );
  // }

  types.CustomMessage createImageSendingMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String id,
    String? remoteId,
    dynamic sourceKey,
    UIMessage.Status? status,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    required String fileId,
    required String path,
    required String url,
    required int? width,
    required int? height,
    required String? encryptedKey,
    required String? encryptedNonce,
    bool isMe = false,
  }) {
    return types.CustomMessage(
      author: author,
      createdAt: timestamp,
      id: id,
      sourceKey: sourceKey,
      remoteId: remoteId,
      roomId: roomId,
      metadata: CustomMessageEx.imageSendingMetaData(
        fileId: fileId,
        path: path,
        url: url,
        width: width,
        height: height,
        encryptedKey: encryptedKey,
        encryptedNonce: encryptedNonce,
      ),
      type: types.MessageType.custom,
      decryptKey: encryptedKey,
      decryptNonce: encryptedNonce,
      expiration: expiration,
      status: status,
      reactions: reactions,
      zapsInfoList: zapsInfoList,
      viewWithoutBubble: true,
      isMe: isMe,
    );
  }

  types.CustomMessage createVideoMessage({
    required types.User author,
    required int timestamp,
    required String roomId,
    required String id,
    String? remoteId,
    dynamic sourceKey,
    UIMessage.Status? status,
    int? expiration,
    List<types.Reaction> reactions = const [],
    List<types.ZapsInfo> zapsInfoList = const [],
    required String fileId,
    required String snapshotPath,
    required String videoPath,
    required String url,
    int? width,
    int? height,
    String? encryptedKey,
    String? encryptedNonce,
    bool isMe = false,
  }) {
    return types.CustomMessage(
      author: author,
      createdAt: timestamp,
      id: id,
      sourceKey: sourceKey,
      remoteId: remoteId,
      roomId: roomId,
      metadata: CustomMessageEx.videoMetaData(
        fileId: fileId,
        snapshotPath: snapshotPath,
        videoPath: videoPath,
        url: url,
        width: width,
        height: height,
        encryptedKey: encryptedKey,
        encryptedNonce: encryptedNonce,
      ),
      type: types.MessageType.custom,
      decryptKey: encryptedKey,
      decryptNonce: encryptedNonce,
      expiration: expiration,
      status: status,
      reactions: reactions,
      zapsInfoList: zapsInfoList,
      viewWithoutBubble: true,
      isMe: isMe,
    );
  }
}
