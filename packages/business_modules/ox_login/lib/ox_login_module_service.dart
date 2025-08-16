import 'package:flutter/material.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'utils/login_flow_manager.dart';
import 'page/profile_setup_page.dart';

/// OXLogin module service interface
/// 
/// Provides access to LoginFlowManager and other login-related services
class OXLoginModuleService extends OXFlutterModule {
  @override
  String get moduleName => 'ox_login';

  @override
  Future<void> setup() async {
    await super.setup();
  }

  @override
  Map<String, Function> get interfaces => {
    'getLoginFlowManager': _getLoginFlowManager,
  };

  @override
  Future<T?>? navigateToPage<T>(BuildContext context, String pageName, Map<String, dynamic>? params) {
    switch (pageName) {
      default:
        return null;
    }
  }

  /// Get LoginFlowManager instance
  dynamic _getLoginFlowManager() {
    return LoginFlowManager.instance;
  }
}
