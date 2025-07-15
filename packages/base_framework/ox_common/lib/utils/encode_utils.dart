
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class EncodeUtils {
  static Future<String> generateMultiSampleFileKey(File file, {
    int totalSampleSize = 1000,
    int segments = 10,
  }) async {
    try {
      final length = await file.length();
      if (length == 0) return '';

      final perSegmentSize = max(1, (totalSampleSize / segments).floor());

      final positions = List<int>.generate(segments, (i) {
        if (i == 0) {
          return 0;
        } else if (i == segments - 1) {
          return max(0, length - perSegmentSize);
        } else {
          return ((i / (segments - 1)) * length).floor();
        }
      });

      final buffer = <int>[];
      for (final pos in positions) {
        final end = min(pos + perSegmentSize, length);
        final chunk = await file
            .openRead(pos, end)
            .fold<List<int>>([], (prev, bytes) => prev..addAll(bytes));
        buffer.addAll(chunk);
      }

      buffer.insertAll(0, List.generate(8, (i) => (length >> (56 - 8 * i)) & 0xFF));

      return sha256.convert(buffer).toString();
    } catch (_) {
      return Uuid().v4();
    }
  }
}