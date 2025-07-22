import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:ox_common/utils/aes_encrypt_utils.dart';
import 'package:path_provider/path_provider.dart';

import 'cache_manager.dart';

@immutable
class _CLEncryptedImageKey {
  const _CLEncryptedImageKey({
    required this.url,
    required this.version,
    required this.width,
    required this.height,
  });

  final String url;
  final int version;
  final int? width, height;

  @override
  bool operator ==(Object other) =>
      other is _CLEncryptedImageKey &&
          other.url == url &&
          other.version == version &&
          other.width == width &&
          other.height == height;

  @override
  int get hashCode => Object.hash(url, version, width, height);
}

class CLEncryptedImageProvider extends ImageProvider<_CLEncryptedImageKey> {
  const CLEncryptedImageProvider({
    required this.url,
    required this.decryptKey,
    required this.decryptNonce,
    this.version = 0,
    this.cacheWidth,
    this.cacheHeight,
    this.enableNetworkDiskCache = true,
  });

  final String url;
  final String? decryptKey;
  final String? decryptNonce;

  final int version;
  final int? cacheWidth, cacheHeight;
  final bool enableNetworkDiskCache;

  final int _kFakeTotal = 100;

  @override
  Future<_CLEncryptedImageKey> obtainKey(ImageConfiguration _) {
    return SynchronousFuture(
      _CLEncryptedImageKey(
        url: url,
        version: version,
        width: cacheWidth,
        height: cacheHeight,
      ),
    );
  }

  @override
  ImageStreamCompleter loadImage(
      _CLEncryptedImageKey key,
      ImageDecoderCallback decode,
      ) {
    final controller = StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode, controller),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('EncryptedImageProvider failed for $key');
      },
    );
  }

  Future<Codec> _loadAsync(
      _CLEncryptedImageKey key,
      ImageDecoderCallback decode,
      StreamController<ImageChunkEvent> progress,
      ) async {
    final cipherFile = await _ensureCipherFile(url);

    final isEncryptFile = decryptKey?.isNotEmpty == true ||
        decryptNonce?.isNotEmpty == true;

    ImmutableBuffer buffer;
    if (isEncryptFile) {
      final Uint8List bytes = await decryptFileInMemory(
        cipherFile,
        decryptKey ?? '',
        decryptNonce,
      );
      buffer = await ImmutableBuffer.fromUint8List(bytes);
    } else {
      buffer = await ImmutableBuffer.fromFilePath(cipherFile.path);
    }

    return decode(
      buffer,
      getTargetSize: (int intrinsicWidth, int intrinsicHeight) {
        final hasCustomWidth = key.width != null;
        final hasCustomHeight = key.height != null;
        if (!hasCustomWidth && !hasCustomHeight) {
          return TargetImageSize(
            width: intrinsicWidth,
            height: intrinsicHeight,
          );
        }

        final double aspectRatio = intrinsicWidth / intrinsicHeight;
        final customWidth = min(key.width ?? intrinsicWidth, intrinsicWidth);
        final customHeight = min(key.height ?? intrinsicHeight, intrinsicHeight);

        num targetW = hasCustomWidth ? customWidth : (customHeight * aspectRatio);
        num targetH = hasCustomHeight ? customHeight : (customWidth / aspectRatio);

        return TargetImageSize(
          width: targetW.floor(),
          height: targetH.floor(),
        );
      },
    );
  }

  Future<File> _ensureCipherFile(String urlOrPath) async {
    final uri = Uri.parse(urlOrPath);
    if (uri.isScheme('http') || uri.isScheme('https')) {
      final cacheManager = await CLCacheManager.getCircleCacheManager(CacheFileType.image);
      final file = await cacheManager.getSingleFile(uri.toString());
      return file;
    }
    return File(uri.isScheme('file') ? uri.toFilePath() : urlOrPath);
  }

  Future<T> _trackPhase<T>({
    required Future<T> task,
    required int startPct,
    required int endPct,
    required StreamController<ImageChunkEvent> progress,
    int step = 2,
    Duration interval = const Duration(milliseconds: 80),
  }) async {
    assert(startPct <= endPct);

    int current = startPct;
    progress.add(ImageChunkEvent(
      cumulativeBytesLoaded: current,
      expectedTotalBytes: _kFakeTotal,
    ));

    late Timer timer;
    timer = Timer.periodic(interval, (_) {
      current = min(current + step, endPct);
      progress.add(ImageChunkEvent(
        cumulativeBytesLoaded: current,
        expectedTotalBytes: _kFakeTotal,
      ));
      if (current >= endPct) timer.cancel();
    });

    final T result = await task;
    timer.cancel();

    if (current < endPct) {
      progress.add(ImageChunkEvent(
        cumulativeBytesLoaded: endPct,
        expectedTotalBytes: _kFakeTotal,
      ));
    }
    return result;
  }

  static Future<Uint8List> decryptFileInMemory(
      File encryptedFile,
      String decryptKey,
      String? decryptNonce,
      ) async {
    try {
      final bytes = await AesEncryptUtils.decryptFileOnMemoryInIsolate(
        encryptedFile,
        decryptKey,
        nonce: decryptNonce,
      );
      return Uint8List.fromList(bytes);
    } catch (_) {
      return Uint8List(0);
    }
  }
}