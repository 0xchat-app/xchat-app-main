import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/utils/chat_prompt_tone.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/push/push_integration.dart';
import 'package:unifiedpush/unifiedpush.dart';

enum PushMsgType { call, other }

extension PushMsgTypeEx on PushMsgType {
  String get text {
    switch (this) {
      case PushMsgType.call:
        return '1';
      case PushMsgType.other:
        return '0';
      default:
        return 'unknow';
    }
  }
}

class FcmPushManager {
  static FcmPushManager get instance => _instance;

  static final FcmPushManager _instance = FcmPushManager._init();

  static const MethodChannel _channel = MethodChannel('ox_common_fcm_push');

  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  AndroidNotificationChannel? _messageChannel;
  AndroidNotificationChannel? _callChannel;

  FcmPushManager._init() {
    _initFlutterLocalNotificationsPlugin();
  }

  Future<void> _initFlutterLocalNotificationsPlugin() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    // Request notification permissions
    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    await _initializeNotificationChannels();
  }

  Future<void> _initializeNotificationChannels() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ox_logo_launcher");
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _flutterLocalNotificationsPlugin?.initialize(initializationSettings);
    
    _initAndroidNotificationMsgChannel();
    _initAndroidNotificationCallChannel();

    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_messageChannel!);
    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_callChannel!);
  }

  void _initAndroidNotificationMsgChannel() {
    _messageChannel = AndroidNotificationChannel(
      '10000',
      'Chat Notification',
      description: 'This Channel is XChat App Chat push notification',
      importance: Importance.high,
    );
  }

  void _initAndroidNotificationCallChannel() {
    _callChannel = const AndroidNotificationChannel(
      '10001',
      'Call Notifications',
      description: 'This channel is used for call invitations',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('classiccalling'),
      playSound: true,
      enableVibration: true,
    );
  }

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    LogUtil.e('Push: Notification Clicked with payload: $payload');
    _openAppByClick();
  }

  void _openAppByClick() {
    LogUtil.e('Push: background -openAppByClick--');
    PromptToneManager.sharedInstance.stopPlay();
  }

  Future<void> onNewEndpoint(String endpoint, String instance) async {
    LogUtil.d('FCM endpoint received: instance=$instance, endpoint=$endpoint');
    
    try {
      // Extract FCM token from endpoint
      final String? fcmToken = _extractFcmTokenFromEndpoint(endpoint);
      if (fcmToken != null) {
        LogUtil.d('FCM token extracted: $fcmToken');
        await _handleFcmToken(fcmToken);
      } else {
        LogUtil.w('Failed to extract FCM token from endpoint: $endpoint');
        // Fallback: save the entire endpoint
        await OXCacheManager.defaultOXCacheManager.saveForeverData(StorageSettingKey.KEY_PUSH_TOKEN.name, endpoint);
      }
    } catch (e) {
      LogUtil.e('Error processing FCM endpoint: $e');
      // Fallback: save the entire endpoint
      await OXCacheManager.defaultOXCacheManager.saveForeverData(StorageSettingKey.KEY_PUSH_TOKEN.name, endpoint);
    }
  }

  // Extract FCM token from UnifiedPush endpoint
  String? _extractFcmTokenFromEndpoint(String endpoint) {
    try {
      // Parse endpoint like: "Embedded-FCM/FCM?v2&instance=default&token=ACTUAL_FCM_TOKEN"
      final uri = Uri.parse(endpoint);
      final token = uri.queryParameters['token'];
      return token;
    } catch (e) {
      LogUtil.e('Error parsing endpoint: $e');
      return null;
    }
  }

  void onMessage(Uint8List message, String instance) async {
    int notificationID = message.hashCode;
    String showTitle = '';
    String showContent = '';
    String msgType = '0';
    
    try {
      String result = utf8.decode(message);
      LogUtil.d("Push: FcmPushManager--onMessage--result=${result}");
      Map<String, dynamic> jsonMap = json.decode(result);
      notificationID = jsonMap.hashCode;
      showTitle = jsonMap['notification']?['title'] ?? '';
      showContent = jsonMap['notification']?['body'] ?? 'default';
      msgType = jsonMap['data']?['msgType'] ?? '0';
    } catch (e) {
      showContent = 'You\'ve received a message ';
      print(e.toString());
    }

    if (msgType == PushMsgType.call.text) {
      showLocalNotification(notificationID, showTitle, showContent, isCall: true);
    } else {
      showLocalNotification(notificationID, showTitle, showContent);
    }
  }

  void showLocalNotification(int notificationID, String showTitle, String showContent, {bool isCall = false}) async {
    if (_flutterLocalNotificationsPlugin == null) {
      await _initFlutterLocalNotificationsPlugin();
    }
    if (_messageChannel == null) _initAndroidNotificationMsgChannel();
    if (_callChannel == null) _initAndroidNotificationCallChannel();
    
    _flutterLocalNotificationsPlugin?.show(
      notificationID,
      showTitle,
      showContent,
      NotificationDetails(
        android: isCall ? AndroidNotificationDetails(
          _callChannel?.id ?? '',
          _callChannel?.name ?? '',
          channelDescription: _callChannel?.description ?? '',
          importance: Importance.max,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('classiccalling'),
          fullScreenIntent: true,
        ) : AndroidNotificationDetails(
          _messageChannel?.id ?? '',
          _messageChannel?.name ?? '',
          channelDescription: _messageChannel?.description ?? '',
          icon: '@mipmap/ic_notification',
        ),
      ),
    );
  }

  // Initialize FCM push service
  Future<void> initializeFcmPush() async {
    try {
      // Set up method channel handler for FCM messages
      _channel.setMethodCallHandler(_handleMethodCall);
      // Initialize notification channels
      await _initializeNotificationChannels();
      
      // Initialize UnifiedPush with embedded FCM distributor
      await _initializeUnifiedPush();
      
      // FCM token will be received through UnifiedPush onNewEndpoint callback
      // No need to manually request it
      
      LogUtil.d('FCM Push Manager initialized successfully');
    } catch (e) {
      LogUtil.e('Failed to initialize FCM Push Manager: $e');
    }
  }



  // Handle received FCM token
  Future<void> _handleFcmToken(String token) async {
    try {
      // Save push token using LoginManager
      final bool isSuccess = await LoginManager.instance.savePushToken(token);
      if (!isSuccess) {
        LogUtil.w('Failed to save push token to LoginManager');
        return;
      }

      // Upload push token to server
      await CLPushIntegration.instance.uploadPushToken(token);
      
      LogUtil.d('FCM token processed successfully');
    } catch (e) {
      LogUtil.e('Error handling FCM token: $e');
    }
  }

  // Initialize UnifiedPush with embedded FCM distributor
  Future<void> _initializeUnifiedPush() async {
    try {
      await UnifiedPush.initialize(
        onNewEndpoint: onNewEndpoint,
        onMessage: onMessage,
        onRegistrationFailed: _onRegistrationFailed,
        onUnregistered: _onUnregistered,
      );
      
      // Register with the embedded FCM distributor
      await _registerWithEmbeddedFcm();
      
      LogUtil.d('UnifiedPush initialized successfully');
    } catch (e) {
      LogUtil.e('Failed to initialize UnifiedPush: $e');
    }
  }

  // Register with embedded FCM distributor
  Future<void> _registerWithEmbeddedFcm() async {
    try {
      // Use the embedded FCM distributor as default
      const String embeddedFcmDistributor = 'com.oxchat.lite';
      
      // Save the distributor
      await UnifiedPush.saveDistributor(embeddedFcmDistributor);
      
      // Register the app
      await UnifiedPush.registerApp(embeddedFcmDistributor);
      
      LogUtil.d('Registered with embedded FCM distributor: $embeddedFcmDistributor');
    } catch (e) {
      LogUtil.e('Failed to register with embedded FCM distributor: $e');
    }
  }

  // Handle registration failure
  void _onRegistrationFailed(String instance) {
    LogUtil.e('FCM registration failed for instance: $instance');
  }

  // Handle unregistration
  void _onUnregistered(String instance) {
    LogUtil.d('FCM unregistered for instance: $instance');
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onFcmMessage':
        final Uint8List message = call.arguments['message'];
        final String instance = call.arguments['instance'] ?? 'default';
        LogUtil.d('Received FCM message for instance: $instance');
        onMessage(message, instance);
        break;
      case 'onFcmTokenChanged':
        // FCM token changes are now handled through UnifiedPush onNewEndpoint
        // This case is kept for backward compatibility
        final String newToken = call.arguments['token'];
        final String instance = call.arguments['instance'] ?? 'default';
        if (newToken != null && newToken.isNotEmpty) {
          LogUtil.d('FCM token changed via method call: $newToken for instance: $instance');
          await _handleFcmToken(newToken);
        }
        break;
      default:
        LogUtil.w('Unknown method call: ${call.method}');
    }
  }

  // Clean up resources
  void dispose() {
    _channel.setMethodCallHandler(null);
  }
}
