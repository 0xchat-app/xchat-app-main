import 'dart:io';

import 'package:chatcore/chat-core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ox_chat/ox_chat.dart';
import 'package:ox_chat_ui/ox_chat_ui.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/desktop/window_manager.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/ox_common.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/utils/error_utils.dart';
import 'package:ox_common/utils/font_size_notifier.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/utils/user_config_tool.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_home/ox_home.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_login/ox_login.dart';
import 'package:ox_push/push_lib.dart';
import 'package:ox_theme/ox_theme.dart';
import 'package:ox_usercenter/ox_usercenter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_socks_proxy/socks_proxy.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:nostr_mls_package/nostr_mls_package.dart';
import 'main.reflectable.dart';

class OXErrorInfo {
  OXErrorInfo(this.error, this.stack);
  Object error;
  StackTrace stack;
}

class AppInitializer {
  static final AppInitializer shared = AppInitializer();
  List<OXErrorInfo> initializeErrors = [];
  
  // Track initialization status
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  OXWindowManager windowManager = OXWindowManager();

  Future initialize() async {
    await _safeHandle(() async {
      try {
        await coreInitializer();
        await Future.wait([
          uiInitializer(),
          businessInitializer(),
        ]);
        await userInitializer();
        if (kDebugMode) {
          getApplicationDocumentsDirectory().then((value) {
            LogUtil.d('[App start] Application Documents Path: $value');
          });
        }
        _isInitialized = true;
      } catch (error, stack) {
        initializeErrors.add(OXErrorInfo(error, stack));
        _isInitialized = false;
      }
    });
  }

  Future coreInitializer() async {
    initializeReflectable();
    await RustLib.init();
    improveOnErrorHandler();
    improveErrorWidget();
  }

  Future businessInitializer() async {
    HttpOverrides.global = OXHttpOverrides(); //ignore all ssl
    await Future.wait([
      ThemeManager.init(),
      Localized.init(),
    ]);
    await _setupModules();

    ThemeManager.addOnThemeChangedCallback(onThemeStyleChange);
    DartPingIOS.register();
  }

  /// User-level initialization including auto login
  Future userInitializer() async {
    await _tryAutoLogin();
  }

  /// Try auto login using LoginManager
  Future<void> _tryAutoLogin() async {
    try {
      await LoginManager.instance.autoLogin();
    } catch (e) {
      debugPrint('Auto login failed: $e');
      // Continue to app, which will show login page if needed
    }
  }

  Future uiInitializer() async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.initWindow();
    PlatformStyle.initialized();
    double fontSize = await OXCacheManager.defaultOXCacheManager.getForeverData(
      StorageKeyTool.APP_FONT_SIZE,
      defaultValue: 1.0,
    );
    textScaleFactorNotifier.value = fontSize;
  }

  onThemeStyleChange() async {
    print("******  changeTheme int ${ThemeManager.getCurrentThemeStyle().name}");
  }

  Future<void> _setupModules() async {
    await Future.wait([
      OXCommon().setup(),
      OXLogin().setup(),
      OXUserCenter().setup(),
      OXPush().setup(),
      OXChat().setup(),
      OXChatUI().setup(),
      OxChatHome().setup(),
    ]);
  }

  Future _safeHandle(Function fn) async {
    try {
      await fn();
    } catch (e, stack) {
      if (kDebugMode) {
        print(e);
        print(stack);
        rethrow;
      }
    }
  }

  void improveOnErrorHandler() {
    FlutterError.onError = (FlutterErrorDetails details) async {
      bool openDevLog = UserConfigTool.getSetting(StorageSettingKey.KEY_OPEN_DEV_LOG.name,
          defaultValue: false);
      if (openDevLog || kDebugMode) {
        FlutterError.presentError(details);
        ErrorUtils.logErrorToFile(details.toString() + '\n' + details.stack.toString());
      }
    };
  }

  void improveErrorWidget() {
    final originErrorWidgetBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        return ConstrainedBox(
          constraints: BoxConstraints.loose(Size.square(300)),
          child: originErrorWidgetBuilder(details),
        );
      } else {
        return SizedBox();
      }
    };
  }
}

class OXHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = createProxyHttpClient(context: context)
      ..findProxy = (Uri uri) {
        ProxySettings? settings = Config.sharedInstance.proxySettings;
        if (settings == null) {
          return 'DIRECT';
        }
        if (settings.turnOnProxy) {
          return 'PROXY ${settings.socksProxyHost}:${settings.socksProxyPort}';
          bool onionURI = uri.host.contains(".onion");
          switch (settings.onionHostOption) {
            case EOnionHostOption.no:
              return onionURI ? '' : 'SOCKS5 ${settings.socksProxyHost}:${settings.socksProxyPort}';
            case EOnionHostOption.whenAvailable:
              return !onionURI
                  ? 'DIRECT'
                  : 'SOCKS5 ${settings.socksProxyHost}:${settings.socksProxyPort}';
            case EOnionHostOption.required:
              return !onionURI ? '' : 'SOCKS5 ${settings.socksProxyHost}:${settings.socksProxyPort}';
            default:
              break;
          }
        }
        return "DIRECT";
      }
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      }; // add your localhost detection logic here if you want;
    return client;
  }
}
