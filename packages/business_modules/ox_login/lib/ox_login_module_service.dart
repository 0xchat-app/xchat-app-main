import 'package:flutter/material.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'utils/login_flow_manager.dart';
import 'page/relay_setup_page.dart';
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
      case 'RelaySetupPage':
        return _navigateToRelaySetupPage(context, params) as Future<T?>?;
      case 'ProfileSetupPage':
        return _navigateToProfileSetupPage(context, params) as Future<T?>?;
      default:
        return null;
    }
  }

  /// Get LoginFlowManager instance
  dynamic _getLoginFlowManager() {
    return LoginFlowManager.instance;
  }

  /// Navigate to RelaySetupPage
  Future<bool?> _navigateToRelaySetupPage(BuildContext context, Map<String, dynamic>? params) async {
    final isNewAccount = params?['isNewAccount'] as bool? ?? false;
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => RelaySetupPage(isNewAccount: isNewAccount),
      ),
    );
    
    return result;
  }

  /// Navigate to ProfileSetupPage
  Future<bool?> _navigateToProfileSetupPage(BuildContext context, Map<String, dynamic>? params) async {
    final isNewAccount = params?['isNewAccount'] as bool? ?? false;
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ProfileSetupPage(isNewAccount: isNewAccount),
      ),
    );
    
    return result;
  }
}
