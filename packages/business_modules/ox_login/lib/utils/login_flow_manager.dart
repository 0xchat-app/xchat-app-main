import 'package:flutter/material.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/profile_refresh_utils.dart';
import '../page/profile_setup_page.dart';
import '../page/relay_setup_page.dart';

class LoginFlowManager {
  LoginFlowManager._();
  
  static final LoginFlowManager instance = LoginFlowManager._();

  Future<void> startPostLoginFlow(BuildContext context, {bool isNewAccount = false}) async {
    final account = LoginManager.instance.currentState.account;
    if (account == null || account.circles.isNotEmpty) {
      _navigateToHome(context);
      return;
    }

    await _showRelaySetupPage(context, isNewAccount: isNewAccount);
  }
  
  Future _showRelaySetupPage(BuildContext context, {bool isNewAccount = false}) {
    return OXNavigator.pushReplacement(
      context,
      RelaySetupPage(isNewAccount: isNewAccount, completeHandler: (ctx) async {
        if (!isNewAccount) {
          _navigateToHome(ctx);
          // Show profile refresh dialog after navigating to home
          await ProfileRefreshUtils.showProfileRefreshDialog(ctx);
        } else {
          _showProfileSetupPage(ctx);
        }
      }),
    );
  }

  Future<void> _showProfileSetupPage(BuildContext context) async {
    OXNavigator.pushReplacement(context, ProfileSetupPage());
  }
  
  void _navigateToHome(BuildContext context) {
    if (context.mounted) {
      OXNavigator.popToRoot(context);
    }
  }
}
