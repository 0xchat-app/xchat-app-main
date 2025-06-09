import 'package:flutter/foundation.dart';
import 'login_manager.dart';
import 'login_models.dart';

/// Login manager usage example
/// 
/// This file demonstrates how to properly use LoginManager for account and circle management
class LoginManagerUsageExample with LoginManagerObserver {
  final LoginManager _loginManager = LoginManager.instance;

  /// Initialize login manager
  void initializeLoginManager() {
    // 1. Add observer to listen for login state changes
    _loginManager.addObserver(this);

    // 2. Listen for login state changes
    _loginManager.state$.addListener(_onLoginStateChanged);

    // 3. Try auto-login (called on app startup)
    _tryAutoLogin();
  }

  /// Try auto-login
  Future<void> _tryAutoLogin() async {
    debugPrint('Trying auto-login...');
    final success = await _loginManager.autoLogin();
    if (success) {
      debugPrint('Auto-login successful');
    } else {
      debugPrint('Auto-login failed, manual login required');
      // Show login interface
      _showLoginPage();
    }
  }

  /// Manual login example
  Future<void> manualLogin(String privateKey) async {
    debugPrint('Starting manual login...');
    final success = await _loginManager.loginWithPrivateKey(privateKey);
    if (success) {
      debugPrint('Manual login successful');
      // Post-login processing handled in onLoginSuccess callback
    } else {
      debugPrint('Manual login failed');
      // Detailed failure information handled in onLoginFailure callback
    }
  }

  /// Circle management example
  Future<void> manageCircles() async {
    final currentState = _loginManager.currentState;
    
    if (!currentState.isLoggedIn) {
      debugPrint('User not logged in, cannot manage circles');
      return;
    }

    final account = currentState.account!;
    debugPrint('Current account: ${account.pubkey}');
    debugPrint('Available circle count: ${account.circles.length}');

    // List all circles
    for (final circle in account.circles) {
      debugPrint('Circle: ${circle.name} (${circle.id})');
      final isCurrent = currentState.currentCircle?.id == circle.id;
      debugPrint('  - Current circle: $isCurrent');
      debugPrint('  - Relay URL: ${circle.relayUrl}');
    }

    // Switch to another circle
    if (account.circles.length > 1) {
      final targetCircle = account.circles
          .where((c) => c.id != currentState.currentCircle?.id)
          .first;
      
      debugPrint('Switching to circle: ${targetCircle.name}');
      await _switchToCircle(targetCircle);
    }
  }

  /// Switch circle example
  Future<void> _switchToCircle(Circle circle) async {
    debugPrint('Switching to circle: ${circle.name}');
    final success = await _loginManager.switchToCircle(circle);
    if (success) {
      debugPrint('Circle switch successful');
    } else {
      debugPrint('Circle switch failed');
    }
  }

  /// Logout example
  Future<void> logout() async {
    debugPrint('Logging out...');
    await _loginManager.logout();
    debugPrint('Logout completed');
    
    // Clear UI state, navigate to login page
    _showLoginPage();
  }

  /// Listen for login state changes
  void _onLoginStateChanged() {
    final state = _loginManager.currentState;
    debugPrint('Login state changed:');
    debugPrint('  - Logged in: ${state.isLoggedIn}');
    debugPrint('  - Has circle: ${state.hasCircle}');
    
    if (state.isLoggedIn) {
      debugPrint('  - Public key: ${state.account?.pubkey}');
      debugPrint('  - Circle count: ${state.account?.circles.length}');
    }
    
    if (state.hasCircle) {
      debugPrint('  - Current circle: ${state.currentCircle?.name}');
    }
  }

  // ========== LoginManagerObserver Implementation ==========

  @override
  void onLoginSuccess(LoginState state) {
    debugPrint('=== Login Success Callback ===');
    debugPrint('Account public key: ${state.account?.pubkey}');
    debugPrint('Circle count: ${state.account?.circles.length ?? 0}');
    debugPrint('Current circle: ${state.currentCircle?.name ?? "None"}');
    
    // UI handling after login success
    _navigateToMainPage();
  }

  @override
  void onLoginFailure(LoginFailure failure) {
    debugPrint('=== Login Failure Callback ===');
    debugPrint('Failure type: ${failure.type}');
    debugPrint('Failure message: ${failure.message}');
    if (failure.circleId != null) {
      debugPrint('Related circle: ${failure.circleId}');
    }
    
    // Show different error messages based on failure type
    switch (failure.type) {
      case LoginFailureType.invalidKeyFormat:
        _showError('Invalid private key format, please check input');
        break;
      case LoginFailureType.errorEnvironment:
        _showError('Private key validation failed, please confirm key is correct');
        break;
      case LoginFailureType.accountDbFailed:
        _showError('Account database open failed, please retry');
        break;
      case LoginFailureType.circleDbFailed:
        if (failure.circleId != null) {
          _showError('Circle "${failure.circleId}" database corrupted, will skip this circle');
        } else {
          _showError('Circle database operation failed');
        }
        break;
    }
  }

  @override
  void onLogout() {
    debugPrint('=== Logout Callback ===');
    debugPrint('User logged out, clearing related state');
    
    // Clear app state, navigate to login page
    _clearAppState();
    _showLoginPage();
  }

  @override
  void onCircleChanged(Circle? circle) {
    debugPrint('=== Circle Change Success Callback ===');
    if (circle != null) {
      debugPrint('Switched to circle: ${circle.name} (${circle.id})');
      debugPrint('Relay URL: ${circle.relayUrl}');
    } else {
      debugPrint('Cleared current circle');
    }
    
    // Update UI to reflect circle changes
    _updateCircleUI(circle);
  }

  @override
  void onCircleChangeFailed(LoginFailure failure) {
    debugPrint('=== Circle Change Failure Callback ===');
    debugPrint('Failure type: ${failure.type}');
    debugPrint('Failure message: ${failure.message}');
    debugPrint('Target circle: ${failure.circleId}');
    
    // Show circle switch failure error message
    _showError('Circle switch failed: ${failure.message}');
  }

  // ========== UI Related Methods (Examples) ==========

  void _showLoginPage() {
    debugPrint('[UI] Show login page');
    // TODO: Implement navigation to login page logic
  }

  void _navigateToMainPage() {
    debugPrint('[UI] Navigate to main page');
    // TODO: Implement navigation to main page logic
  }

  void _showError(String message) {
    debugPrint('[UI] Show error: $message');
    // TODO: Implement error message display logic (e.g., Toast, Dialog)
  }

  void _clearAppState() {
    debugPrint('[UI] Clear app state');
    // TODO: Implement app state clearing logic
  }

  void _updateCircleUI(Circle? circle) {
    debugPrint('[UI] Update circle UI');
    // TODO: Implement circle-related UI update logic
  }

  // ========== Resource Cleanup ==========

  void dispose() {
    // Remove observer
    _loginManager.removeObserver(this);
    
    // Remove state listener
    _loginManager.state$.removeListener(_onLoginStateChanged);
  }
}

// ========== Utility Methods Example ==========

/// Login manager utility class
class LoginManagerUtils {
  /// Check if logged in
  static bool get isLoggedIn => LoginManager.instance.currentState.isLoggedIn;
  
  /// Get current user public key
  static String? get currentPubkey => LoginManager.instance.currentState.account?.pubkey;
  
  /// Get current circle
  static Circle? get currentCircle => LoginManager.instance.currentState.currentCircle;
  
  /// Get all circles for current user
  static List<Circle> get allCircles => 
      LoginManager.instance.currentState.account?.circles ?? [];
  
  /// Format login status information
  static String getStatusInfo() {
    final state = LoginManager.instance.currentState;
    if (!state.isLoggedIn) {
      return 'Not logged in';
    }
    
    final pubkey = state.account!.pubkey;
    final shortPubkey = '${pubkey.substring(0, 8)}...${pubkey.substring(pubkey.length - 8)}';
    final circleInfo = state.hasCircle 
        ? 'Current circle: ${state.currentCircle!.name}'
        : 'No circle';
    
    return 'Logged in: $shortPubkey | $circleInfo';
  }
} 