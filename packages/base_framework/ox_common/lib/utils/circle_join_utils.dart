import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/utils/ping_utils.dart';
import 'package:ox_localizable/ox_localizable.dart';

/// Predefined circle configuration
class _CircleConfig {
  final String? relayUrl;
  final CircleType type;

  const _CircleConfig({
    required this.relayUrl,
    required this.type,
  });
}

/// Result of pre-flight checks
class _PreflightCheckResult {
  final bool isSuccess;
  final String errorMessage;

  const _PreflightCheckResult.success()
      : isSuccess = true,
        errorMessage = '';
  const _PreflightCheckResult.failure(this.errorMessage) : isSuccess = false;
}

/// Result of circle existence check
class _CircleExistsResult {
  final bool isExists;
  final String message;
  
  const _CircleExistsResult.notExists() : isExists = false, message = '';
  const _CircleExistsResult.exists(this.message) : isExists = true;
}

/// Utility class for handling circle joining operations
class CircleJoinUtils {
  CircleJoinUtils._();

  /// Predefined circle mappings
  static const Map<String, _CircleConfig> _predefinedCircles = {
    '0xchat': _CircleConfig(
      relayUrl: 'wss://relay.0xchat.com',
      type: CircleType.relay,
    ),
  };

  /// Get circle config for predefined short name
  static _CircleConfig? _getCircleConfig(String shortName) {
    return _predefinedCircles[shortName.toLowerCase()];
  }

  /// Show join circle dialog that allows user to input relay URL or short name and join a circle
  ///
  /// This method provides a unified way to handle circle joining across the app.
  /// It shows an input dialog for the user to enter a relay URL or predefined short name,
  /// validates the input, performs pre-flight checks, and attempts to join the circle through LoginManager.
  ///
  /// [context] BuildContext for showing dialogs
  /// [circleType] Type of circle to join, defaults to relay (ignored if using predefined short names)
  ///
  /// Returns Future<bool> indicating whether the operation was successful
  static Future<bool> showJoinCircleDialog({
    required BuildContext context,
    CircleType circleType = CircleType.relay,
  }) async {
    try {
      final result = await CLDialog.showInputDialog(
        context: context,
        title: Localized.text('ox_home.join_circle_title'),
        description: Localized.text('ox_home.join_circle_description'),
        inputLabel: Localized.text('ox_home.join_circle_input_label'),
        confirmText: Localized.text('ox_home.add'),
        onConfirm: (input) async {
          return await _processJoinInput(context, input, circleType);
        },
      );

      return result != null;
    } catch (e) {
      debugPrint('CircleJoinUtils: Error in join circle dialog: $e');
      return false;
    }
  }

  /// Process join input (either URL or short name)
  static Future<bool> _processJoinInput(
      BuildContext context, String input, CircleType defaultCircleType) async {
    final trimmedInput = input.trim();

    // Determine CircleConfig based on input
    _CircleConfig circleConfig = _getCircleConfig(trimmedInput) ??
        _CircleConfig(relayUrl: trimmedInput, type: CircleType.relay);

    // Check if circle already exists based on type
    final existsResult = await _checkCircleExists(circleConfig);
    if (existsResult.isExists) {
      throw existsResult.message;
    }

    // Perform pre-checks based on circle type
    final preCheckResult = await _performPreChecks(context, circleConfig);
    if (!preCheckResult.isSuccess) {
      throw preCheckResult.errorMessage;
    }

    // Join circle through LoginManager
    final failure = await LoginManager.instance
        .joinCircle(circleConfig.relayUrl ?? '', type: circleConfig.type);
    if (failure != null) {
      throw failure.message;
    }

    return true;
  }

  /// Check if circle already exists based on circle type
  static Future<_CircleExistsResult> _checkCircleExists(_CircleConfig config) async {
    try {
      final currentState = LoginManager.instance.currentState;
      final account = currentState.account;
      
      if (account == null) {
        return const _CircleExistsResult.notExists();
      }

      switch (config.type) {
        case CircleType.relay:
          return _checkRelayCircleExists(account.circles, config.relayUrl);
      }
    } catch (e) {
      // If error occurs, assume circle doesn't exist and continue
      return const _CircleExistsResult.notExists();
    }
  }

  /// Check if relay type circle exists by relayURL
  static _CircleExistsResult _checkRelayCircleExists(List<Circle> circles, String? relayUrl) {
    if (relayUrl == null || relayUrl.isEmpty) {
      return const _CircleExistsResult.notExists();
    }

    for (final circle in circles) {
      if (circle.type == CircleType.relay && circle.relayUrl == relayUrl) {
        return _CircleExistsResult.exists(
          Localized.text('ox_common.circle_already_exists').replaceFirst('{relay}', relayUrl)
        );
      }
    }

    return const _CircleExistsResult.notExists();
  }

  /// Perform pre-checks based on circle configuration
  static Future<_PreflightCheckResult> _performPreChecks(
      BuildContext context, _CircleConfig config) async {
    switch (config.type) {
      case CircleType.relay:
        return await _performRelayPreChecks(context, config.relayUrl);
    }
  }

  /// Perform pre-checks for relay type circles
  static Future<_PreflightCheckResult> _performRelayPreChecks(
      BuildContext context, String? relayUrl) async {
    if (relayUrl == null || relayUrl.isEmpty) {
      return _PreflightCheckResult.failure(
          Localized.text('ox_common.invalid_url_format'));
    }

    // Validate URL format
    if (!_isValidRelayUrl(relayUrl)) {
      return _PreflightCheckResult.failure(
          Localized.text('ox_common.invalid_url_format'));
    }

    // Perform network connectivity test with user confirmation option
    return await _performWeakPreflightChecks(context, relayUrl);
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

    return url.startsWith('wss://') || url.startsWith('ws://');
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
  static Future<_PreflightCheckResult> _performWeakPreflightChecks(
      BuildContext context, String relayUrl) async {
    try {
      // Perform basic connectivity check
      final host = Uri.parse(relayUrl).host;
      if (host.isEmpty) {
        return _PreflightCheckResult.failure(
            Localized.text('ox_common.invalid_relay_url_no_host'));
      }

      // Test network connectivity with shorter timeout for better UX
      final pingLatency = await PingUtils.ping(host, count: 3);
      if (pingLatency == null || pingLatency <= 0) {
        final shouldContinue = await _showNetworkWarningDialog(
          context,
          relayUrl,
        );
        if (shouldContinue) {
          return const _PreflightCheckResult.success();
        } else {
          return _PreflightCheckResult.failure(
              Localized.text('ox_common.user_cancelled_network_issues'));
        }
      }
      return const _PreflightCheckResult.success();
    } catch (e) {
      // Show warning dialog for any connectivity issues
      final shouldContinue = await _showNetworkWarningDialog(context, relayUrl);
      if (shouldContinue) {
        return const _PreflightCheckResult.success();
      } else {
        return _PreflightCheckResult.failure(
            Localized.text('ox_common.user_cancelled_network_issues'));
      }
    }
  }

  /// Show network warning dialog when connectivity issues are detected
  ///
  /// [context] BuildContext for showing dialogs
  /// [relayUrl] The relay URL that failed connectivity check
  ///
  /// Returns true if user chooses to continue, false if user cancels
  static Future<bool> _showNetworkWarningDialog(
      BuildContext context, String relayUrl) async {
    final shouldContinue = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_common.network_warning_title'),
      content: Localized.text('ox_common.network_warning_message')
          .replaceFirst('{relay}', relayUrl),
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
      content:
          message ?? Localized.text('ox_usercenter.profile_circle_info_dialog'),
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
