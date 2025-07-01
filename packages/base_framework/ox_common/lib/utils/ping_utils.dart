import 'package:dart_ping/dart_ping.dart';

class PingUtils {
  /// Ping [host] once, return latency in ms; null if failed.
  static Future<int?> ping(String host, {int count = 1}) async {
    try {
      final ping = Ping(host, count: count, timeout: 3);
      await for (final event in ping.stream) {
        if (event.response != null) {
          return event.response!.time?.inMilliseconds;
        } else if (event.error != null) {
          return null;
        }
      }
    } catch (_) {}
    return null;
  }
} 