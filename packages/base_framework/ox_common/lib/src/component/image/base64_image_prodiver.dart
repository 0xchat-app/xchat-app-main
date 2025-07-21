import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/painting.dart';

String _stripDataUriPrefix(String s) {
  final comma = s.indexOf(',');
  return comma >= 0 ? s.substring(comma + 1) : s;
}

/// Decode Base64 → Uint8List.
/// Throws [FormatException] on invalid input.
Uint8List _decodeBase64(String base64) => base64Decode(base64);

@immutable
class _B64Key {
  const _B64Key(this.hash, this.version, this.w, this.h);

  final String hash;   // SHA-256 of the original Base64 string
  final int version;   // Manual version for cache invalidation
  final int? w, h;     // Target decode size

  @override
  bool operator ==(Object other) =>
      other is _B64Key &&
          other.hash == hash &&
          other.version == version &&
          other.w == w &&
          other.h == h;

  @override
  int get hashCode => Object.hash(hash, version, w, h);
}

class Base64ImageProvider extends ImageProvider<_B64Key> {
  Base64ImageProvider(
      this.base64String, {
        this.version = 0,
        this.cacheWidth,
        this.cacheHeight,
        this.maxBytes = 10 << 20, // Default safety limit: 10 MiB
      });

  /// Raw Base64 string OR data-URI (`data:image/png;base64,...`).
  final String base64String;

  /// Bump this to invalidate the cache when the source changes.
  final int version;

  /// Down-sample dimensions (logical pixels before device-pixel-ratio).
  final int? cacheWidth, cacheHeight;

  /// Reject images whose decoded size exceeds this many bytes.
  final int maxBytes;

  @override
  Future<_B64Key> obtainKey(ImageConfiguration _) =>
      SynchronousFuture(
        _B64Key(
          sha256.convert(utf8.encode(base64String)).toString(),
          version,
          cacheWidth,
          cacheHeight,
        ),
      );

  @override
  ImageStreamCompleter loadImage(
      _B64Key key,
      ImageDecoderCallback decode,
      ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Base64ImageProvider failed for key: $key');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      _B64Key key,
      ImageDecoderCallback decode,
      ) async {
    Uint8List bytes;

    // Decode Base64 in a background isolate.
    try {
      bytes = await compute(
        _decodeBase64,
        _stripDataUriPrefix(base64String),
      );

      if (bytes.length > maxBytes) {
        throw StateError(
          'Decoded image too large: ${bytes.length} B > $maxBytes B',
        );
      }
    } on FormatException catch (e, s) {
      // Log and rethrow so errorBuilder can handle it.
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: s),
      );
      rethrow;
    }

    // Wrap bytes in ImmutableBuffer (zero-copy where possible).
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);

    // Let Flutter decode (with optional down-sampling).
    return decode(
      buffer,
      getTargetSize: (int intrinsicW, int intrinsicH) {
        final hasW = key.w != null;
        final hasH = key.h != null;
        if (!hasW && !hasH) {
          return ui.TargetImageSize(width: intrinsicW, height: intrinsicH);
        }

        final aspect = intrinsicW / intrinsicH;
        final targetW = hasW ? key.w! : (key.h! * aspect).round();
        final targetH = hasH ? key.h! : (key.w! / aspect).round();
        return ui.TargetImageSize(width: targetW, height: targetH);
      },
    );
  }
}