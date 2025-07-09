import 'dart:async';
import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/utils/ping_utils.dart';
import 'package:ox_localizable/ox_localizable.dart';

/// Result of pre-flight checks
class _PreflightCheckResult {
  final bool isSuccess;
  final String errorMessage;
  
  const _PreflightCheckResult.success() : isSuccess = true, errorMessage = '';
  const _PreflightCheckResult.failure(this.errorMessage) : isSuccess = false;
}

/// Utility class for handling circle joining operations
class CircleJoinUtils {
  CircleJoinUtils._();

  /// Show join circle dialog that allows user to input relay URL and join a circle
  /// 
  /// This method provides a unified way to handle circle joining across the app.
  /// It shows an input dialog for the user to enter a relay URL, validates the URL,
  /// performs pre-flight checks, and attempts to join the circle through LoginManager.
  /// 
  /// [context] BuildContext for showing dialogs
  /// 
  /// Returns Future<bool> indicating whether the operation was successful
  static Future<bool> showJoinCircleDialog({
    required BuildContext context,
  }) async {
    debugPrint('CircleJoinUtils: Show join circle dialog');
    
    try {
      final relayUrl = await CLDialog.showInputDialog(
        context: context,
        title: Localized.text('ox_home.join_circle_title'),
        description: Localized.text('ox_home.join_circle_description'),
        inputLabel: Localized.text('ox_home.join_circle_input_label'),
        confirmText: Localized.text('ox_home.add'),
        onConfirm: (relayUrl) async {
          // Step 1: Validate URL format
          if (!_isValidRelayUrl(relayUrl)) {
            throw Localized.text('ox_common.invalid_url_format');
          }
          
          // Step 2: Perform weak pre-flight checks
          final checkResult = await _performWeakPreflightChecks(context, relayUrl);
          if (!checkResult.isSuccess) {
            // If user chose not to continue after seeing the warning, throw error to cancel
            throw checkResult.errorMessage;
          }
          
          // Step 3: Try to join circle through LoginManager
          final failure = await LoginManager.instance.joinCircle(relayUrl);
          if (failure != null) {
            throw failure.message;
          }
          
          return true; // Success
        },
      );
      
      return relayUrl != null;
    } catch (e) {
      debugPrint('CircleJoinUtils: Error in join circle dialog: $e');
      return false;
    }
  }

  /// Validate relay URL format
  /// 
  /// Checks if the provided URL is a valid relay URL format.
  /// Accepts wss://, ws:// protocols and basic domain validation.
  /// 
  /// [url] The URL string to validate
  /// 
  /// Returns true if URL is valid, false otherwise
  static bool _isValidRelayUrl(String url) {
    // Basic URL validation
    if (url.isEmpty) return false;
    
    // Check if it's a valid URL or relay address
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    
    // Check for common relay URL patterns
    return url.startsWith('wss://') || 
           url.startsWith('ws://');
  }

  /// Perform weak pre-flight checks for a relay URL with user confirmation option
  /// 
  /// This method performs basic connectivity checks. If the checks fail, it shows
  /// a confirmation dialog asking the user if they want to continue despite the
  /// connectivity issues. This provides a better user experience by not blocking
  /// the join operation entirely.
  /// 
  /// [context] BuildContext for showing dialogs
  /// [relayUrl] The relay URL to check
  /// 
  /// Returns [_PreflightCheckResult] indicating whether to proceed (success) or cancel (failure)
  static Future<_PreflightCheckResult> _performWeakPreflightChecks(BuildContext context, String relayUrl) async {
    try {
      debugPrint('CircleJoinUtils: Starting weak pre-flight checks for $relayUrl');
      
      // Perform basic connectivity check
      final host = Uri.parse(relayUrl).host;
      if (host.isEmpty) {
        return _PreflightCheckResult.failure(Localized.text('ox_common.invalid_relay_url_no_host'));
      }
      
      // Test network connectivity with shorter timeout for better UX
      debugPrint('CircleJoinUtils: Testing connectivity to $host');
      final pingLatency = await PingUtils.ping(host, count: 1);
      
      if (pingLatency == null || pingLatency <= 0) {
        // Network connectivity failed - show confirmation dialog
        final shouldContinue = await _showNetworkWarningDialog(context, relayUrl);
        if (shouldContinue) {
          debugPrint('CircleJoinUtils: User chose to continue despite network issues');
          return const _PreflightCheckResult.success();
                 } else {
           debugPrint('CircleJoinUtils: User chose to cancel due to network issues');
           return _PreflightCheckResult.failure(Localized.text('ox_common.user_cancelled_network_issues'));
         }
      }
      
      debugPrint('CircleJoinUtils: Basic connectivity check passed, latency: ${pingLatency}ms');
      return const _PreflightCheckResult.success();
      
    } catch (e) {
      debugPrint('CircleJoinUtils: Weak pre-flight check error: $e');
      // Show warning dialog for any connectivity issues
      final shouldContinue = await _showNetworkWarningDialog(context, relayUrl);
      if (shouldContinue) {
        return const _PreflightCheckResult.success();
             } else {
         return _PreflightCheckResult.failure(Localized.text('ox_common.user_cancelled_network_issues'));
       }
    }
  }

  /// Show network warning dialog when connectivity issues are detected
  /// 
  /// [context] BuildContext for showing dialogs
  /// [relayUrl] The relay URL that failed connectivity check
  /// 
  /// Returns true if user chooses to continue, false if user cancels
  static Future<bool> _showNetworkWarningDialog(BuildContext context, String relayUrl) async {
    final shouldContinue = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_common.network_warning_title'),
      content: Localized.text('ox_common.network_warning_message').replaceFirst('{relay}', relayUrl),
      actions: [
        CLAlertAction<bool>(
          label: Localized.text('ox_common.cancel'),
          value: false,
        ),
        CLAlertAction<bool>(
          label: Localized.text('ox_common.continue_anyway'),
          value: true,
          isDefaultAction: true,
        ),
      ],
    );
    
    return shouldContinue ?? false;
  }

  /// Perform comprehensive pre-flight checks for a relay URL
  /// 
  /// This method validates that the relay is accessible and functional before
  /// attempting to join the circle. It includes network connectivity, WebSocket
  /// connection, and relay information validation.
  /// 
  /// [relayUrl] The relay URL to check
  /// 
  /// Returns [_PreflightCheckResult] indicating success or failure with error message
  static Future<_PreflightCheckResult> _performPreflightChecks(String relayUrl) async {
    try {
      debugPrint('CircleJoinUtils: Starting pre-flight checks for $relayUrl');
      
      // Step 1: Test network connectivity via ping
      final host = Uri.parse(relayUrl).host;
      if (host.isEmpty) {
        return _PreflightCheckResult.failure(Localized.text('ox_common.invalid_relay_url_no_host'));
      }
      
      debugPrint('CircleJoinUtils: Testing connectivity to $host');
      final pingLatency = await PingUtils.ping(host, count: 2);
      if (pingLatency == null || pingLatency <= 0) {
        return _PreflightCheckResult.failure(
          Localized.text('ox_common.network_unreachable')
        );
      }
      debugPrint('CircleJoinUtils: Ping successful, latency: ${pingLatency}ms');
      
      // Step 2: Test WebSocket connection
      debugPrint('CircleJoinUtils: Testing WebSocket connection');
      final wsConnectResult = await _testWebSocketConnection(relayUrl);
      if (!wsConnectResult.isSuccess) {
        return wsConnectResult;
      }
      
      // Step 3: Validate relay information (optional but recommended)
      debugPrint('CircleJoinUtils: Validating relay information');
      final relayInfoResult = await _validateRelayInfo(relayUrl);
      if (!relayInfoResult.isSuccess) {
        debugPrint('CircleJoinUtils: Relay info validation failed, but continuing: ${relayInfoResult.errorMessage}');
        // We don't fail here as some relays might not provide proper info endpoints
      }
      
      debugPrint('CircleJoinUtils: All pre-flight checks passed');
      return const _PreflightCheckResult.success();
      
    } catch (e) {
      debugPrint('CircleJoinUtils: Pre-flight check error: $e');
      return _PreflightCheckResult.failure(
        '${Localized.text('ox_common.connection_test_failed')}: $e'
      );
    }
  }

  /// Test WebSocket connection to relay
  static Future<_PreflightCheckResult> _testWebSocketConnection(String relayUrl) async {
    try {
      // Use Connect class to test actual WebSocket connection with timeout
      final completer = Completer<_PreflightCheckResult>();
      
      // Set up timeout
      Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          completer.complete(_PreflightCheckResult.failure(
            Localized.text('ox_common.connection_timeout')
          ));
        }
      });
      
      // Attempt to connect using the existing Connect infrastructure
      final connectSuccess = await Connect.sharedInstance.connectRelays(
        [relayUrl], 
        relayKind: RelayKind.temp
      );
      
      if (connectSuccess) {
        // Clean up temporary connection
        await Connect.sharedInstance.closeTempConnects([relayUrl]);
        
        if (!completer.isCompleted) {
          completer.complete(const _PreflightCheckResult.success());
        }
      } else {
        if (!completer.isCompleted) {
          completer.complete(_PreflightCheckResult.failure(
            Localized.text('ox_common.websocket_connection_failed')
          ));
        }
      }
      
      return await completer.future;
      
    } catch (e) {
      return _PreflightCheckResult.failure(
        '${Localized.text('ox_common.websocket_connection_failed')}: $e'
      );
    }
  }

  /// Validate relay information by checking the relay info endpoint
  static Future<_PreflightCheckResult> _validateRelayInfo(String relayUrl) async {
    try {
      final relayInfo = await Relays.getRelayDetails(relayUrl);
      if (relayInfo == null) {
        return _PreflightCheckResult.failure(
          Localized.text('ox_common.unable_to_retrieve_relay_info')
        );
      }
      
      // Basic validation - relay should have some identifying information
      if (relayInfo.url.isEmpty) {
        return _PreflightCheckResult.failure(
          Localized.text('ox_common.invalid_relay_info_received')
        );
      }
      
      return const _PreflightCheckResult.success();
      
    } catch (e) {
      // Non-critical failure - some relays might not have proper info endpoints
      return _PreflightCheckResult.failure(
        '${Localized.text('ox_common.relay_info_validation_failed')}: $e'
      );
    }
  }

  /// Show a guide dialog when user is not in any circle
  /// 
  /// This method shows an informational dialog explaining that the user needs
  /// to join a circle first, and provides an option to join a circle directly.
  /// 
  /// [context] BuildContext for showing dialogs
  /// [message] Custom message to show in the dialog
  /// 
  /// Returns Future<bool> indicating whether user chose to join a circle
  static Future<bool> showJoinCircleGuideDialog({
    required BuildContext context,
    String? message,
  }) async {
    final shouldJoin = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_usercenter.profile'),
      content: message ?? Localized.text('ox_usercenter.profile_circle_info_dialog'),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_home.join_circle'),
          value: true,
          isDefaultAction: true,
        ),
      ],
    );

    if (shouldJoin == true) {
      return showJoinCircleDialog(context: context);
    }
    
    return false;
  }
} 