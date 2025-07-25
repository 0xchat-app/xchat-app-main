
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ox_chat/widget/chat_image_preview_widget.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/upload/upload_utils.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/video_data_manager.dart';
import 'package:ox_chat/utils/custom_message_utils.dart';

class ChatVideoMessage extends StatefulWidget {

  ChatVideoMessage({
    required this.message,
    required this.messageWidth,
    required this.receiverPubkey,
    this.messageUpdateCallback,
  });

  final types.CustomMessage message;
  final int messageWidth;
  final String? receiverPubkey;
  final Function(types.Message newMessage)? messageUpdateCallback;

  @override
  State<StatefulWidget> createState() => ChatVideoMessageState();
}

class ChatVideoMessageState extends State<ChatVideoMessage> {

  String get fileId => VideoMessageEx(widget.message).fileId;
  String get videoURL => VideoMessageEx(widget.message).url;
  String get videoPath => VideoMessageEx(widget.message).videoPath;
  String get snapshotPath => VideoMessageEx(widget.message).snapshotPath;
  String? get encryptedKey => VideoMessageEx(widget.message).encryptedKey;
  String? get encryptedNonce => VideoMessageEx(widget.message).encryptedNonce;

  bool canOpen = false;

  int? width;
  int? height;
  Stream<double>? stream;

  @override
  void initState() {
    super.initState();
    prepareData();
  }
  
  @override
  void dispose() {
    VideoDataManager.shared.cancelTask(videoURL);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatVideoMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    prepareData();
  }

  void prepareData() {
    final message = widget.message;

    width = VideoMessageEx(message).width;
    height = VideoMessageEx(message).height;
    stream = fileId.isEmpty || videoURL.isNotEmpty || widget.message.status == types.Status.error
        ? null
        : UploadManager.shared.getUploadProgress(fileId, widget.receiverPubkey);

    if (videoPath.isNotEmpty) {
      canOpen = true;
    } else if (videoURL.isNotEmpty) {
      canOpen = snapshotPath.isNotEmpty;
    }

    if (width == null || height == null) {
      try {
        final uri = Uri.parse(videoURL);
        final query = uri.queryParameters;
        width ??= int.tryParse(query['width'] ?? query['w'] ?? '');
        height ??= int.tryParse(query['height'] ?? query['h'] ?? '');
      } catch (_) { }
    }
    tryInitializeVideoMedia();
  }

  void tryInitializeVideoMedia() async {
    if (videoURL.isEmpty || snapshotPath.isNotEmpty) return;

    final media = await VideoDataManager.shared.fetchVideoMedia(
      videoURL: videoURL,
      encryptedKey: encryptedKey,
      encryptedNonce: encryptedNonce,
    );
    if (media == null) return;

    types.CustomMessage newMessage = widget.message.copyWith();
    VideoMessageEx(newMessage).videoPath = media.path ?? '';
    VideoMessageEx(newMessage).snapshotPath = media.thumbPath ?? '';

    widget.messageUpdateCallback?.call(newMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        snapshotBuilder(snapshotPath),
        if (videoURL.isNotEmpty || widget.message.status == types.Status.error)
          Positioned.fill(
            child: Center(
              child: canOpen || widget.message.status == types.Status.error
                  ? buildPlayIcon()
                  : buildLoadingWidget()
            ),
          )
      ],
    );
  }

  Widget buildPlayIcon() => Icon(Icons.play_circle, size: 60.px,);

  Widget buildLoadingWidget() => CLProgressIndicator.circular(
    size: 28.px,
    color: ColorToken.secondaryContainer.of(context)
  );

  Widget snapshotBuilder(String imagePath) {
    return Container(
      color: ColorToken.onSecondaryContainer.of(context).withValues(alpha: 1.0),
      child: ChatImagePreviewWidget(
        uri: imagePath,
        imageWidth: width,
        imageHeight: height,
        decryptKey: encryptedKey,
        decryptNonce: encryptedNonce,
        maxWidth: widget.messageWidth.toDouble(),
        progressStream: stream,
      ),
    );
  }
}