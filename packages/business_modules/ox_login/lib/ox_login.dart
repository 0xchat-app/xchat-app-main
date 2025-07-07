import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ox_module_service/ox_module_service.dart';

class OXLogin extends OXFlutterModule {
  static const MethodChannel channel = const MethodChannel('ox_login');
  static String get loginPageId  => "login_page";
  static Future<String> get platformVersion async {
    final String version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  Future<void> setup() async {
    await super.setup();
  }

  @override
  String get moduleName => 'ox_login';

  @override
  Map<String, Function> get interfaces => {};

  @override
  Future<T?>? navigateToPage<T>(BuildContext context, String pageName, Map<String, dynamic>? params) {
    return null;
  }
}




