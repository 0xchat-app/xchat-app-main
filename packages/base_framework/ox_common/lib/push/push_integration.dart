import 'dart:async';
import 'dart:io';

import 'package:chatcore/chat-core.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_common/ox_common.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/ox_chat_observer.dart';
import 'package:ox_common/utils/chat_prompt_tone.dart';

import 'decision_service.dart';
import 'core/local_notifier.dart';
import 'core/local_push_kit.dart';
import 'core/message_models.dart';
import 'core/policy_config.dart';
import 'core/ports.dart';

/// Wires LocalPushKit + Notifier + DecisionService into app lifecycle and message bus.
class CLPushIntegration with WidgetsBindingObserver, OXChatObserver {
  static final CLPushIntegration instance = CLPushIntegration._();
  CLPushIntegration._();

  late final Notifier _notifier;
  late final NotificationDecisionService _decision;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1) Init base kit
    await LocalPushKit.instance.ensureInitialized(
      androidDefaultIcon: '@mipmap/ic_notification',
      androidChannelId: 'message_channel',
      androidChannelName: 'Messages',
      androidChannelDescription: 'General message notifications',
    );

    // 2) Notifier based on LocalPushKit
    _notifier = LocalNotifier(
      LocalPushKit.instance,
      'message_channel',
      'Messages',
      'General message notifications',
    );

    // 3) Decision service with port adapters
    _decision = NotificationDecisionService(
      state: _ForegroundStateImpl(),
      perms: _PermissionGatewayImpl(),
      mute: _MuteStoreImpl(),
      unread: _UnreadCounterImpl(),
      dedupe: _DedupeStoreImpl(),
      notifier: _notifier,
      config: const NotificationPolicyConfig(
        coalesceWindow: Duration(seconds: 1),
        previewPolicy: PreviewPolicy.summary,
      ),
    );

    // 4) Hook lifecycle & message bus
    WidgetsBinding.instance.addObserver(this);
    OXChatBinding.sharedInstance.addObserver(this);

    if (await LocalPushKit.instance.requestPermission()) {
      _initializeForRemotePush();
    }

    _initialized = true;
  }

  void _initializeForRemotePush() {
    if (Platform.isIOS) {
      OXCommon.registeNotification();
    } else if (Platform.isAndroid) {

    }
  }

  // Lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // cancel any notifications
      _decision.onAppBecameForeground();
    }
  }

  // Message observer
  @override
  void didReceiveMessageCallback(MessageDBISAR message) {
    final msg = _mapToIncomingMessage(message);
    if (msg != null) {
      unawaited(_decision.onMessageArrived(msg));
    }
  }

  // Map MessageDBISAR to IncomingMessage
  IncomingMessage? _mapToIncomingMessage(MessageDBISAR m) {
    try {
      // Determine threadId
      String threadId = '';
      if (m.chatType == 1) {
        // group chat
        threadId = m.groupId;
      } else {
        // private or other: use the other party id
        threadId = m.sender;
      }
      if (threadId.isEmpty) return null;

      final preview = m.content;
      final high = true; // can refine based on kind/type
      final sentAt = DateTime.fromMillisecondsSinceEpoch(
        m.createTime < 1e12 ? m.createTime * 1000 : m.createTime,
      );
      return IncomingMessage(
        id: m.messageId,
        threadId: threadId,
        preview: preview,
        highPriority: high,
        sentAt: sentAt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> uploadPushToken(String token) async {
    OKEvent okEvent = await NotificationHelper.sharedInstance.updateNotificationDeviceId(token);
    return okEvent.status;
  }
}

// -------- Port Implementations --------

class _ForegroundStateImpl implements ForegroundState {
  @override
  bool isAppInForeground() => false;

  @override
  bool isThreadOpen(String threadId) {
    // When chat page is open, PromptToneManager.sharedInstance.isCurrencyChatPage is set
    final checker = PromptToneManager.sharedInstance.isCurrencyChatPage;
    if (checker == null) return false;
    try {
      return checker(threadId, '');
    } catch (_) {
      return false;
    }
  }
}

class _PermissionGatewayImpl implements PermissionGateway {
  @override
  Future<bool> notificationsAllowed() async {
    return LocalPushKit.instance.areNotificationsEnabled();
  }
}

class _MuteStoreImpl implements MuteStore {
  @override
  bool isMuted(String threadId) {
    // Try group first
    final group = Groups.sharedInstance.groups[threadId]?.value ??
        Groups.sharedInstance.myGroups[threadId]?.value;
    if (group != null) {
      return group.mute;
    }
    // Then user mute
    final user = Account.sharedInstance.userCache[threadId]?.value;
    if (user != null) {
      return user.mute ?? false;
    }
    return false;
  }
}

class _UnreadCounterImpl implements UnreadCounter {
  @override
  int unreadCount() {
    int total = 0;
    for (final s in OXChatBinding.sharedInstance.sessionList) {
      total += s.unreadCount;
    }
    return total;
  }
}

class _DedupeStoreImpl implements DedupeStore {
  final Set<String> _seen = <String>{};

  @override
  bool seen(String messageId) => _seen.contains(messageId);

  @override
  void markSeen(Iterable<String> ids) {
    _seen.addAll(ids);
  }
}


