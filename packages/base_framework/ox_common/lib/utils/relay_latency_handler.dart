import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/utils/ping_utils.dart';

/// RelayLatencyHandler encapsulates latency measurement of a relay (WebSocket) URL.
/// It follows the workflow:
/// 1. Fast retry (every 5s) until a valid latency (>0) is obtained.
/// 2. After success, refresh periodically (1min when collapsed, 5s when expanded).
/// External callers only interact via simple APIs, complying with the Law of Demeter.
class RelayLatencyHandler {
  RelayLatencyHandler({required ValueNotifier<bool> isExpanded$})
      : _isExpanded$ = isExpanded$ {
    _isExpanded$.addListener(_restartRegularTimer);
  }

  // Expansion status of the UI, influences regular refresh interval
  final ValueNotifier<bool> _isExpanded$;

  // Map of latency notifiers, one per relay URL
  final Map<String, ValueNotifier<String>> _latencyMap = {};

  // Currently measured relay
  String? _currentRelay;

  // Timers
  Timer? _initialTimer;
  Timer? _regularTimer;

  // Constants
  static const Duration _fastRetry = Duration(seconds: 5);
  static const Duration _regularCollapsed = Duration(minutes: 1);
  static const Duration _regularExpanded = Duration(seconds: 5);

  /// Get latency notifier for a relay URL ("--" when unknown).
  ValueNotifier<String> getLatencyNotifier(String relayUrl) {
    return _latencyMap.putIfAbsent(relayUrl, () => ValueNotifier<String>('--'));
  }

  /// Switch to another relay to measure. Fast-retry will start automatically.
  void switchRelay(String relayUrl) {
    if (_currentRelay == relayUrl) return;

    _currentRelay = relayUrl;

    // Ensure notifier exists
    getLatencyNotifier(relayUrl);

    _cancelTimers();

    _attemptFastRetry();
  }

  /// Dispose resources.
  void dispose() {
    _isExpanded$.removeListener(_restartRegularTimer);
    _cancelTimers();
  }

  /// Static helper: map latency value to color.
  static Color latencyColor(int latency) {
    if (latency <= 0) return CupertinoColors.inactiveGray; // unknown / invalid
    if (latency <= 200) return CupertinoColors.systemGreen; // good
    if (latency <= 500) return CupertinoColors.systemYellow; // warning
    return CupertinoColors.systemRed; // bad
  }

  /* ----------------------------- Internal ----------------------------- */

  void _attemptFastRetry() async {
    if (_currentRelay == null) return;
    final success = await _measureOnce(_currentRelay!);
    if (!success) {
      _initialTimer = Timer(_fastRetry, _attemptFastRetry);
    } else {
      _initialTimer = null;
      _startRegularTimer();
    }
  }

  Future<bool> _measureOnce(String relayUrl) async {
    final host = Uri.parse(relayUrl).host.isNotEmpty
        ? Uri.parse(relayUrl).host
        : relayUrl.replaceAll(RegExp(r'^(wss?:\/\/)?'), '').split('/').first;
    final latency = await PingUtils.ping(host, count: 3);
    getLatencyNotifier(relayUrl).value =
        (latency != null && latency > 0) ? '$latency' : '--';
    return latency != null && latency > 0;
  }

  void _startRegularTimer() {
    _regularTimer?.cancel();
    final interval = _isExpanded$.value ? _regularExpanded : _regularCollapsed;
    _regularTimer = Timer.periodic(interval, (_) {
      if (_currentRelay != null) {
        _measureOnce(_currentRelay!);
      }
    });
  }

  void _restartRegularTimer() {
    if (_regularTimer != null) {
      _startRegularTimer();
    }
  }

  void _cancelTimers() {
    _initialTimer?.cancel();
    _regularTimer?.cancel();
    _initialTimer = null;
    _regularTimer = null;
  }
} 