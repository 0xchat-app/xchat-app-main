
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/utils/chat_prompt_tone.dart';
import 'package:ox_common/utils/compression_utils.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:isar/isar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';


import 'package:ox_common/model/chat_session_model_isar.dart';

import 'login/circle_config_models.dart';
import 'model/file_server_model.dart';
import 'push/push_integration.dart';
import 'utils/ox_userinfo_manager.dart';

const CommonModule = 'ox_common';

class OXCommon extends OXFlutterModule {
  @override
  // TODO: implement moduleName
  String get moduleName => CommonModule;

  @override
  List<IsarGeneratedSchema> get isarDBSchemes => [
    ChatSessionModelISARSchema,
    CircleConfigISARSchema,
    FileServerModelSchema,
  ];

  @override
  Future<void> setup() async {
    await super.setup();
    await ThreadPoolManager.sharedInstance.initialize();
    PromptToneManager.sharedInstance.setup();
    channel.setMethodCallHandler(_platformCallHandler);
  }

  @override
  Map<String, Function> get interfaces =>{
    "gotoWebView": gotoWebView,
  };

  static const MethodChannel channel = const MethodChannel('$CommonModule');
  static const MethodChannel channelPreferences = const MethodChannel('com.oxchat.global/perferences');

  static Future<String> get platformVersion async {
    final String version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'registerPushTokenHandler':
        String token = call.arguments['token'];
        CLPushIntegration.instance.registerPushTokenHandler(token);
        break;
    }
  }

  static Future<String> getDatabaseFilePath(String dbName) async {
    final String filePath = await channel.invokeMethod('getDatabaseFilePath', {'dbName' :  dbName});
    return filePath;
  }

  static Future<List<String>> select34MediaFilePaths(int type) async {
    final List<dynamic> result = await channel.invokeMethod('select34MediaFilePaths', {'type': type});
    return result.map((e) => e.toString()).toList();
  }

  static Future<Map<String, bool>> request34MediaPermission(int type) async {
    final Map<Object?, Object?> result = await channel.invokeMethod('request34MediaPermission', {'type': type});
    Map<String, bool> convertedResult = {};
    result.forEach((key, value) {
      if (key is String && value is bool) {
        convertedResult[key] = value;
      } else {
        LogUtil.e('Invalid key or value type: key=$key, value=$value');
      }
    });
    return convertedResult;
  }

  static Future<void> callSysShare(String filePath) async {
    await channel.invokeMethod('callSysShare', {'filePath' :  filePath});
  }

  static Future<void> callIOSSysShare(Uint8List? uint8List) async {
    await channel.invokeMethod('callIOSSysShare', {'imageBytes' :  uint8List});
  }

  static void backToDesktop() async {
    await channel.invokeMethod('backToDesktop',);
  }

  static Future<String> getDeviceId() async {
    final String deviceId = await channel.invokeMethod('getDeviceId');
    return deviceId;
  }

  static Future<String> scanPath(String path) async {
    assert(path.isNotEmpty);
    final String result = await channel.invokeMethod('scan_path', {'path': path});
    return result;
  }

  static Future registeNotification({bool isRotation = false}) async {
    await channel.invokeMethod('registeNotification', {'isRotation': isRotation});
  }

  @override
  Future<T?>? navigateToPage<T>(BuildContext context, String pageName, Map<String, dynamic>? params) {
    // TODO: implement navigateToPage
    return null;
  }

  void gotoWebView(BuildContext context, String url, bool? isPresentPage, bool? fullscreenDialog, bool? isLocalHtmlResource, Function(String)? calllBack) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print(e.toString() + 'Cannot open $url');
    }
  }
}