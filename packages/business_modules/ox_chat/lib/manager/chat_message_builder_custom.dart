part of 'chat_message_builder.dart';

extension ChatMessageBuilderCustomEx on ChatMessageBuilder {
  static TextSpan buildTextSpan(String text) {
    RegExp regExp = RegExp(r"#\w+|https?://\S+|nostr:\S+");
    Iterable<RegExpMatch> matches = regExp.allMatches(text);

    List<TextSpan> spans = [];
    int start = 0;

    matches.forEach((match) {
      spans.add(TextSpan(text: text.substring(start, match.start)));

      var matchedText = text.substring(match.start, match.end);
      spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(
            color: Color(0xFFC084FC),
          )));

      start = match.end;
    });

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start, text.length)));
    }

    return TextSpan(children: spans, style: TextStyle(
      fontSize: 14.sp,
      color: ThemeColor.color0,
      height: 1.4,
    ));
  }

  static Widget _buildTemplateMessage(types.CustomMessage message, bool isMe) {
    final title = TemplateMessageEx(message).title;
    final content = TemplateMessageEx(message).content;
    final icon = TemplateMessageEx(message).icon;
    Widget iconWidget = SizedBox();
    if (icon.isNotEmpty) {
      if (icon.isRemoteURL) {
        iconWidget = CLCachedNetworkImage(
          imageUrl: icon,
          height: 48.px,
          width: 48.px,
          fit: BoxFit.cover,
        ).setPadding(EdgeInsets.only(left: 10.px));
      }
      else {
        iconWidget = CommonImage(
          iconName: icon,
          fit: BoxFit.contain,
          height: 48.px,
          width: 48.px,
          package: 'ox_common',
        ).setPadding(EdgeInsets.only(left: 10.px));
      }
    }
    return Container(
      width: 266.px,
      color: ThemeColor.color180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ThemeColor.color0,
                  height: 1.4,
                ),
              ),
              Container(color: ThemeColor.color160, height: 0.5,)
                  .setPadding(EdgeInsets.symmetric(vertical: 4.px)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ThemeColor.color60,
                        height: 1.4,
                      ),
                    ),
                  ),
                  iconWidget,
                ],
              ),
            ],
          ).setPadding(EdgeInsets.all(10.px)),
        ],
      ),
    );
  }

  static Widget _buildNoteMessage(types.CustomMessage message, bool isMe) {
    final title = NoteMessageEx(message).authorName;
    final authorIcon = NoteMessageEx(message).authorIcon;
    final dns = NoteMessageEx(message).authorDNS;
    final createTime = NoteMessageEx(message).createTime;
    final createTimeInMs = createTime * 1000;
    final content = NoteMessageEx(message).note;
    final icon = NoteMessageEx(message).image;
    Widget iconWidget = SizedBox().setPadding(EdgeInsets.only(bottom: 10.px));
    if (icon.isNotEmpty) {
      if (icon.isRemoteURL) {
        iconWidget = CLCachedNetworkImage(
          imageUrl: icon,
          height: 139.px,
          width: 265.px,
          fit: BoxFit.fitWidth,
        ).setPadding(EdgeInsets.only(bottom: 8.px));
      }
      else {
        iconWidget = CommonImage(
          iconName: icon,
          fit: BoxFit.contain,
          height: 139.px,
          width: 265.px,
          package: 'ox_common',
        ).setPadding(EdgeInsets.only(bottom: 8.px));
      }
    }
    return Container(
      width: 266.px,
      color: ThemeColor.color180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                    child: CLCachedNetworkImage(
                      imageUrl: authorIcon,
                      height: 20.px,
                      width: 20.px,
                    )).setPadding(EdgeInsets.only(right: 4.px)),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: 100.px,
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: ThemeColor.color0,
                        height: 1.4
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ).setPadding(EdgeInsets.only(right: 4.px)),
                ),
                Expanded(
                  child: Text(
                    dns,
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: ThemeColor.color120,
                        height: 1.4
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Spacer(),
                Text(
                  OXDateUtils.convertTimeFormatString2(createTimeInMs,
                      pattern: 'MM-dd'),
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: ThemeColor.color120,
                      height: 1.4
                  ),
                  textAlign: TextAlign.center,
                )
              ]).setPadding(EdgeInsets.only(left: 10.px, right: 10.px)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: buildTextSpan(content),
                  maxLines: 20,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ).setPadding(EdgeInsets.only(top: 2.px, left: 10.px, right: 10.px, bottom: 10.px)),
        ],
      ),
    );
  }

  static Widget _buildImageSendingMessage(
    types.CustomMessage message,
    int messageWidth,
    BorderRadius borderRadius,
    String? receiverPubkey,
    bool isMe,
    bool isSelfChat,
  ) {
    final uri = ImageSendingMessageEx(message).uri;
    final url = ImageSendingMessageEx(message).url;
    final fileId = ImageSendingMessageEx(message).fileId;
    var width = ImageSendingMessageEx(message).width;
    var height = ImageSendingMessageEx(message).height;
    final encryptedKey = ImageSendingMessageEx(message).encryptedKey;
    final encryptedNonce = ImageSendingMessageEx(message).encryptedNonce;
    Stream<double>? stream;
    if (isSelfChat) {
      stream = null;
    } else if (fileId.isEmpty || url.isNotEmpty || message.status == types.Status.error) {
      stream = null;
    } else {
      stream = UploadManager.shared.getUploadProgress(fileId, receiverPubkey);
    }

    if (width == null || height == null) {
      try {
        final uri = Uri.parse(url);
        final query = uri.queryParameters;
        width ??= int.tryParse(query['width'] ?? query['w'] ?? '');
        height ??= int.tryParse(query['height'] ?? query['h'] ?? '');
      } catch (_) { }
    }

    return Hero(
      tag: message.id,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: ChatImagePreviewWidget(
          uri: uri,
          imageWidth: width,
          imageHeight: height,
          maxWidth: messageWidth.toDouble(),
          progressStream: stream,
          decryptKey: encryptedKey,
          decryptNonce: encryptedNonce,
        ),
      ),
    );
  }

  static Widget _buildVideoMessage(
    types.CustomMessage message,
    int messageWidth,
    BorderRadius borderRadius,
    String? receiverPubkey,
    bool isMe,
    Function(types.Message newMessage)? messageUpdateCallback,
    bool isSelfChat,
  ) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: ChatVideoMessage(
        message: message,
        messageWidth: messageWidth,
        receiverPubkey: receiverPubkey,
        isSelfChat: isSelfChat,
        messageUpdateCallback: messageUpdateCallback,
      ),
    );
  }
}