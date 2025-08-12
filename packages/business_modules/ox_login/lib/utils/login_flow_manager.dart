import 'package:flutter/material.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/component.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';

/// Login flow manager for handling post-login/registration flow
/// 
/// Manages the flow: key login -> add relay/create circle (optional) -> create/update profile (optional) -> home
class LoginFlowManager {
  LoginFlowManager._();
  
  static final LoginFlowManager instance = LoginFlowManager._();
  
  /// Start the post-login flow
  /// 
  /// [context] BuildContext for navigation
  /// [isNewAccount] Whether this is a new account creation
  Future<void> startPostLoginFlow(BuildContext context, {bool isNewAccount = false}) async {
    // Check if user has any circles
    final account = LoginManager.instance.currentState.account;
    if (account == null) {
      // Should not happen, but if it does, go to home
      _navigateToHome(context);
      return;
    }
    
    if (account.circles.isEmpty) {
      // No circles, show relay setup page
      await _showRelaySetupPage(context, isNewAccount: isNewAccount);
    } else {
      // Has circles, check if profile is set up
      await _checkAndShowProfileSetup(context, isNewAccount: isNewAccount);
    }
  }
  
  /// Show relay setup page for adding relay and creating circle
  Future<void> _showRelaySetupPage(BuildContext context, {bool isNewAccount = false}) async {
    final result = await OXModuleService.pushPage(
      context, 
      'ox_login', 
      'RelaySetupPage',
      {'isNewAccount': isNewAccount}
    );
    
    if (result == true) {
      // User completed relay setup, check profile
      await _checkAndShowProfileSetup(context, isNewAccount: isNewAccount);
    } else {
      // User skipped relay setup, go directly to home
      _navigateToHome(context);
    }
  }
  
  /// Check if profile is set up and show profile setup page if needed
  Future<void> _checkAndShowProfileSetup(BuildContext context, {bool isNewAccount = false}) async {
    final user = LoginManager.instance.currentState.account;
    if (user == null) {
      _navigateToHome(context);
      return;
    }
    
    // Check if profile has basic info (name, avatar, etc.)
    final hasBasicProfile = await _hasBasicProfile();
    
    if (!hasBasicProfile) {
      // Show profile setup page
      await _showProfileSetupPage(context, isNewAccount: isNewAccount);
    } else {
      // Profile is set up, go to home
      _navigateToHome(context);
    }
  }
  
  /// Show profile setup page
  Future<void> _showProfileSetupPage(BuildContext context, {bool isNewAccount = false}) async {
    final result = await OXModuleService.pushPage(
      context, 
      'ox_login', 
      'ProfileSetupPage',
      {'isNewAccount': isNewAccount}
    );
    
    if (result == true) {
      // User completed profile setup, go to home
      _navigateToHome(context);
    } else {
      // User skipped profile setup, go to home
      _navigateToHome(context);
    }
  }
  
  /// Check if user has basic profile information
  Future<bool> _hasBasicProfile() async {
    try {
      final user = LoginManager.instance.currentState.account;
      if (user == null) return false;
      
      // For now, assume user needs profile setup if they don't have circles
      // This is a simplified check - in a real implementation, you might want to check
      // if the user has a custom name, avatar, or bio
      return false;
    } catch (e) {
      debugPrint('Error checking profile: $e');
      return false;
    }
  }
  
  /// Navigate to home page
  void _navigateToHome(BuildContext context) {
    if (context.mounted) {
      OXNavigator.popToRoot(context);
    }
  }
}
