import 'dart:convert';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ox_common/log_util.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/login/account_models.dart';
import 'package:ox_common/login/circle_repository.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/purchase/purchase_idempotency_manager.dart';
import 'package:ox_common/purchase/subscription_platform.dart';
import 'package:ox_common/purchase/subscription_registry.dart';

/// Purchase processing result
enum PurchaseProcessResult {
  success,
  alreadyProcessed,
  alreadyRestored,
  serverVerificationFailed,
  deliveryFailed,
  /// Subscription in receipt is expired; transaction was finished so user can renew.
  subscriptionExpired,
  error,
}

/// Purchase processing response
/// 
/// Contains all information about the purchase processing result
class PurchaseProcessResponse {
  PurchaseProcessResponse({
    required this.result,
    this.message,
    this.verificationResult,
  });

  final PurchaseProcessResult result;
  final String? message;
  final PaymentVerificationResult? verificationResult;

  /// Returns true if processing was successful or already processed
  bool get isSuccess => 
      result == PurchaseProcessResult.success || 
      result == PurchaseProcessResult.alreadyProcessed;
}

/// Service for processing purchases (server verification and delivery)
/// 
/// This service handles the business logic of purchase processing:
/// - Server-side verification
/// - Subscription status checking
/// - Delivery (joinCircle)
/// - **Finish transaction (completePurchase) - UNIFIED RESPONSIBILITY**
/// 
/// This is separated from UI to ensure purchases can be processed even
/// if the purchase page is closed or the app is restarted.
/// 
/// **CRITICAL: This is the ONLY place that should call completePurchase.**
/// PurchaseManager should NOT call completePurchase directly.
/// All finish decisions are made here based on business rules.
/// 
/// **Dependency:**
/// - Directly depends on in_app_purchase for completePurchase (business logic)
/// - Does NOT depend on PurchaseManager (avoids circular dependency)
class PurchaseService {
  static final PurchaseService instance = PurchaseService._();
  
  PurchaseService._();

  /// Process a purchased transaction
  /// 
  /// [purchaseDetails] The purchase details from purchaseStream
  /// 
  /// Returns [PurchaseProcessResponse] containing the processing result
  /// 
  /// CRITICAL FINISH RULES:
  /// - Finish ONLY after successful delivery (joinCircle succeeds)
  /// - Finish ONLY for already processed transactions (idempotency)
  /// - DO NOT finish on any errors (network, server, timeout, local state)
  /// 
  /// This ensures failed deliveries can be recovered via:
  /// - System automatic retry (purchase stream will push again)
  /// - User restore purchases
  /// - Manual retry mechanisms
  /// [logicalProductId] When provided (e.g. on Android where purchaseDetails.productID is store id), use for server verification and group/tier lookup.
  Future<PurchaseProcessResponse> processPurchase(
    PurchaseDetails purchaseDetails, {
    String? logicalProductId,
  }) async {
    final transactionId = PurchaseIdempotencyManager.getTransactionId(purchaseDetails);

    // Check if already processed
    final idempotencyResult = await _checkIdempotency(transactionId, purchaseDetails);
    if (idempotencyResult != null) {
      return idempotencyResult;
    }

    try {
      _logPurchaseStart(purchaseDetails, transactionId);

      // Step 1: Server-side verification (use logical id on Android so backend gets e.g. loc1.level1.monthly)
      final verificationResponse = await _verifyPaymentWithServer(purchaseDetails, logicalProductId: logicalProductId);
      if (verificationResponse.result != PurchaseProcessResult.success) {
        // Verification failed - don't finish, let system retry later
        return verificationResponse;
      }
      final verificationResult = verificationResponse.verificationResult!;

      // Step 2: Validate verification result (incl. local expiry check if server wrongly says active)
      final validationResponse = _validateVerificationResult(
        verificationResult,
        purchaseDetails: purchaseDetails,
      );
      if (validationResponse != null) {
        // Subscription expired: finish transaction so queue is cleared and user can tap to renew
        if (validationResponse.result == PurchaseProcessResult.subscriptionExpired) {
          await _completePurchase(purchaseDetails);
          LogUtil.d(() => '[PurchaseService] Expired subscription transaction finished; user can renew');
        }
        return validationResponse;
      }

      // Step 3: Delivery - join Circle (MUST happen before finish)
      // Use logical product id for group lookup (required on Android where productID is store id).
      final productIdForGroup = logicalProductId ?? purchaseDetails.productID;
      final groupId = SubscriptionRegistry.instance
          .groupForProductId(productIdForGroup)
          ?.id;
      final deliveryResponse = await _deliverPurchase(verificationResult, groupId);
      if (deliveryResponse.result != PurchaseProcessResult.success) {
        // Delivery failed - don't finish, don't mark as processed
        // Let system retry later or user can restore purchases
        return deliveryResponse;
      }

      // Step 4: Mark as processed (only after successful delivery)
      // This prevents duplicate processing while allowing retry on failure
      await PurchaseIdempotencyManager.markAsProcessed(transactionId);

      // Step 5: Complete the purchase (finish) - only after successful delivery
      // This removes the transaction from the queue, but only after we've confirmed delivery
      await _completePurchase(purchaseDetails);

      // Success
      LogUtil.d(() => '[PurchaseService] Purchase processed successfully');
      return PurchaseProcessResponse(
        result: PurchaseProcessResult.success,
        verificationResult: verificationResult,
      );

    } catch (e, stack) {
      // On error, don't finish - let system retry later
      return _handleProcessingError(e, stack, purchaseDetails);
    }
  }

  /// Check if purchase was already processed (idempotency check)
  /// 
  /// Returns [PurchaseProcessResponse] if already processed and subscription is still active, null otherwise
  /// 
  /// For subscriptions, if the subscription has expired, we allow reprocessing even if the transaction
  /// was previously processed. This allows users to renew expired subscriptions.
  Future<PurchaseProcessResponse?> _checkIdempotency(
    String transactionId,
    PurchaseDetails purchaseDetails,
  ) async {
    if (!await PurchaseIdempotencyManager.isProcessed(transactionId)) {
      return null;
    }

    // Check if subscription is still active (for subscriptions only)
    // If subscription has expired, allow reprocessing as a new purchase
    final isSubscriptionExpired = _isSubscriptionExpiredImpl(purchaseDetails);
    if (isSubscriptionExpired) {
      LogUtil.d(() => '''
        [PurchaseService] Transaction already processed but subscription expired, allowing reprocessing:
        - transactionId: $transactionId
        - productID: ${purchaseDetails.productID}
      ''');
      // Clear the processed flag to allow reprocessing
      await PurchaseIdempotencyManager.clearProcessed(transactionId);
      return null; // Allow reprocessing as new purchase
    }

    LogUtil.d(() => 'Purchase already processed, skipping: $transactionId');

    // Re-deliver if user deleted the circle locally: verify → check circle exists → joinCircle if missing
    final account = LoginManager.instance.currentState.account;
    if (account != null) {
      final logicalId = SubscriptionPlatform.instance.resolveLogicalProductId(purchaseDetails.productID);
      final verificationResponse = await _verifyPaymentWithServer(
        purchaseDetails,
        logicalProductId: logicalId,
      );
      if (verificationResponse.result == PurchaseProcessResult.success &&
          verificationResponse.verificationResult != null) {
        final verificationResult = verificationResponse.verificationResult!;
        final validationResponse = _validateVerificationResult(
          verificationResult,
          purchaseDetails: purchaseDetails,
        );
        if (validationResponse == null) {
          final existingCircle = account.circles.where(
            (c) => c.type == CircleType.relay && c.relayUrl == verificationResult.relayUrl,
          );
          if (existingCircle.isEmpty) {
            LogUtil.d(() => '''
              [PurchaseService] Already processed but circle missing locally, re-delivering:
              - transactionId: $transactionId
              - relayUrl: ${verificationResult.relayUrl}
            ''');
            final groupId = SubscriptionRegistry.instance
                .groupForProductId(logicalId)
                ?.id;
            final deliveryResponse = await _deliverPurchase(verificationResult, groupId);
            if (deliveryResponse.result == PurchaseProcessResult.success) {
              LogUtil.d(() => '[PurchaseService] Re-delivery successful - circle re-joined');
              return PurchaseProcessResponse(
                result: PurchaseProcessResult.alreadyProcessed,
                verificationResult: verificationResult,
              );
            }
          }
        }
      }
    }

    // Still need to complete the purchase to free up the queue
    if (purchaseDetails.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchaseDetails);
    }

    return PurchaseProcessResponse(
      result: PurchaseProcessResult.alreadyProcessed,
    );
  }

  /// Check if subscription has expired based on expiresDate in localVerificationData.
  /// Exposed for PurchaseManager to decide whether to treat out-of-window restored
  /// events as "already owned" (active sub) or as new purchase (expired → verify + joinCircle).
  bool isSubscriptionExpired(PurchaseDetails purchaseDetails) =>
      _isSubscriptionExpiredImpl(purchaseDetails);

  /// Internal implementation of subscription expiration check.
  bool _isSubscriptionExpiredImpl(PurchaseDetails purchaseDetails) {
    try {
      final localVerificationData = purchaseDetails.verificationData.localVerificationData;
      if (localVerificationData.isEmpty) {
        return false; // Cannot determine, assume not expired
      }

      final json = jsonDecode(localVerificationData) as Map<String, dynamic>;
      
      // Check if this is a subscription
      final type = json['type'] as String?;
      if (type == null || !type.contains('Subscription')) {
        return false; // Not a subscription, cannot expire
      }

      // Get expiresDate (milliseconds since epoch)
      final expiresDateMillis = json['expiresDate'] as int?;
      if (expiresDateMillis == null) {
        return false; // Cannot determine, assume not expired
      }

      // Convert to DateTime and check if expired
      final expiresDate = DateTime.fromMillisecondsSinceEpoch(expiresDateMillis);
      final now = DateTime.now();
      final isExpired = expiresDate.isBefore(now);

      LogUtil.d(() => '''
        [PurchaseService] Subscription expiration check:
        - productID: ${purchaseDetails.productID}
        - expiresDate: ${expiresDate.toIso8601String()}
        - now: ${now.toIso8601String()}
        - isExpired: $isExpired
      ''');

      return isExpired;
    } catch (e) {
      LogUtil.w(() => '[PurchaseService] Failed to check subscription expiration: $e');
      return false; // On error, assume not expired to be safe
    }
  }

  /// Get receipt/purchase token from purchase details
  String _getReceipt(PurchaseDetails purchaseDetails) {
    String receipt = purchaseDetails.verificationData.serverVerificationData;
    if (receipt.isEmpty) {
      receipt = purchaseDetails.verificationData.source;
    }
    return receipt;
  }

  /// Get account credentials for API calls
  /// 
  /// Throws [Exception] if user is not logged in or private key is unavailable
  ({String pubkey, String privkey}) _getAccountCredentials() {
    final account = LoginManager.instance.currentState.account;
    if (account == null) {
      throw Exception('User not logged in');
    }
    
    final privkey = AccountHelperEx.getPrivateKey(
      account.encryptedPrivKey,
      account.defaultPassword,
    );
    
    if (privkey.isEmpty) {
      throw Exception('Private key not available');
    }
    
    return (pubkey: account.pubkey, privkey: privkey);
  }

  /// Verify payment with server
  /// [logicalProductId] When set (e.g. Android), use for productId so backend receives e.g. loc1.level1.monthly.
  Future<PurchaseProcessResponse> _verifyPaymentWithServer(
    PurchaseDetails purchaseDetails, {
    String? logicalProductId,
  }) async {
    final receipt = _getReceipt(purchaseDetails);
    final credentials = _getAccountCredentials();
    final productIdForServer = logicalProductId ?? purchaseDetails.productID;

    LogUtil.d(() => '''
      [PurchaseService] Starting server verification:
      - platform: ${Platform.isIOS ? 'iOS' : 'Android'}
      - productId: $productIdForServer
      - receipt length: ${receipt.length}
    ''');

    try {
      final PaymentVerificationResult verificationResult;
      if (Platform.isIOS) {
        verificationResult = await CircleApi.verifyApplePayment(
          pubkey: credentials.pubkey,
          privkey: credentials.privkey,
          productId: productIdForServer,
          receiptData: receipt,
        );
      } else {
        verificationResult = await CircleApi.verifyGooglePayment(
          pubkey: credentials.pubkey,
          privkey: credentials.privkey,
          productId: productIdForServer,
          purchaseToken: receipt,
        );
      }
      
      LogUtil.d(() => '''
        [PurchaseService] Server verification successful:
        - tenantId: ${verificationResult.tenantId}
        - relayUrl: ${verificationResult.relayUrl}
        - subscriptionStatus: ${verificationResult.subscriptionStatus}
      ''');
      
      return PurchaseProcessResponse(
        result: PurchaseProcessResult.success,
        verificationResult: verificationResult,
      );
    } catch (e, stack) {
      LogUtil.e(() => '''
        [PurchaseService] Server verification failed:
        - productId: ${purchaseDetails.productID}
        - error: $e
        - stack: $stack
      ''');
      return PurchaseProcessResponse(
        result: PurchaseProcessResult.serverVerificationFailed,
        message: 'Server verification failed: $e',
      );
    }
  }

  /// Validate verification result
  /// 
  /// Returns null if valid, [PurchaseProcessResponse] with error otherwise.
  /// When [purchaseDetails] is provided, also checks local expiresDate so we treat
  /// as expired even if server wrongly returns "active".
  PurchaseProcessResponse? _validateVerificationResult(
    PaymentVerificationResult verificationResult, {
    PurchaseDetails? purchaseDetails,
  }) {
    // Check subscription status from server
    if (verificationResult.subscriptionStatus != 'active') {
      LogUtil.w(() => 'Subscription status: ${verificationResult.subscriptionStatus}');
      if (verificationResult.subscriptionStatus == 'expired') {
        return PurchaseProcessResponse(
          result: PurchaseProcessResult.subscriptionExpired,
          message: 'Subscription has expired. Please renew your subscription.',
          verificationResult: verificationResult,
        );
      }
    }

    // Defense: if server says "active" but local receipt is expired, treat as expired
    if (purchaseDetails != null && _isSubscriptionExpiredImpl(purchaseDetails)) {
      LogUtil.w(() => '[PurchaseService] Server returned active but local expiresDate is past; treating as expired');
      return PurchaseProcessResponse(
        result: PurchaseProcessResult.subscriptionExpired,
        message: 'Subscription has expired. Please renew your subscription.',
        verificationResult: verificationResult,
      );
    }

    // Check relay URL
    if (verificationResult.relayUrl.isEmpty) {
      final error = 'Failed to get relay URL from server';
      LogUtil.e(() => '[PurchaseService] $error');
      return PurchaseProcessResponse(
        result: PurchaseProcessResult.serverVerificationFailed,
        message: error,
        verificationResult: verificationResult,
      );
    }

    return null; // Valid
  }

  /// Complete the purchase transaction (finish)
  /// 
  /// This is the ONLY place that should call completePurchase.
  /// All finish decisions are made here based on business rules:
  /// - Finish ONLY after successful delivery
  /// - Finish ONLY for already processed transactions (idempotency)
  /// - DO NOT finish on errors (allows retry/restore)
  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      LogUtil.d(() => '[PurchaseService] Completing purchase...');
      await InAppPurchase.instance.completePurchase(purchaseDetails);
      LogUtil.d(() => '[PurchaseService] Purchase completed');
    } else {
      LogUtil.d(() => '[PurchaseService] No pending complete purchase');
    }
  }

  /// Deliver purchase by joining Circle
  /// 
  /// Returns [PurchaseProcessResponse] with success or failure result
  Future<PurchaseProcessResponse> _deliverPurchase(
    PaymentVerificationResult verificationResult,
    String? groupId,
  ) async {
    LogUtil.d(() => '''
      [PurchaseService] Starting delivery (joinCircle):
      - relayUrl: ${verificationResult.relayUrl}
      - tenantId: ${verificationResult.tenantId}
      - groupId: $groupId
    ''');
    
    final failure = await LoginManager.instance.joinCircle(
      verificationResult.relayUrl,
      type: CircleType.relay,
      groupId: groupId,
    );

    if (failure != null) {
      LogUtil.e(() => '''
        [PurchaseService] Delivery failed:
        - relayUrl: ${verificationResult.relayUrl}
        - failure type: ${failure.type}
        - failure message: ${failure.message}
        - circleId: ${failure.circleId}
      ''');
      return PurchaseProcessResponse(
        result: PurchaseProcessResult.deliveryFailed,
        message: failure.message,
        verificationResult: verificationResult,
      );
    }
    
    LogUtil.d(() => '[PurchaseService] Delivery successful - circle joined');
    return PurchaseProcessResponse(
      result: PurchaseProcessResult.success,
      verificationResult: verificationResult,
    );
  }

  /// Log purchase processing start
  void _logPurchaseStart(PurchaseDetails purchaseDetails, String transactionId) {
    LogUtil.d(() => '''
      [PurchaseService] Processing purchase:
      - productID: ${purchaseDetails.productID}
      - purchaseID: ${purchaseDetails.purchaseID}
      - transactionId: $transactionId
      - transactionDate: ${purchaseDetails.transactionDate}
    ''');
  }

  /// Handle processing error
  /// 
  /// Returns [PurchaseProcessResponse] with error result
  /// 
  /// CRITICAL: Does NOT finish the purchase on error.
  /// 
  /// Rationale:
  /// - Network errors, server errors, timeouts are all recoverable
  /// - Local state issues (e.g., private key not ready) are recoverable
  /// - Only finish when we're CERTAIN the transaction can NEVER be delivered
  /// 
  /// Recoverable errors (DO NOT finish):
  /// - Network connectivity issues
  /// - Server 500/503 errors
  /// - joinCircle timeouts
  /// - Private key parsing failures (user just logged in, state not stable)
  /// - Any transient errors
  /// 
  /// Non-recoverable errors (could finish, but we're conservative):
  /// - User cancellation (handled via PurchaseStatus.canceled, not here)
  /// - Invalid receipt (but might be retryable after user action)
  /// 
  /// By not finishing, we allow:
  /// - System to retry automatically on next purchase stream event
  /// - User to restore purchases to recover failed transactions
  /// - Manual retry mechanisms
  Future<PurchaseProcessResponse> _handleProcessingError(
    Object error,
    StackTrace stack,
    PurchaseDetails purchaseDetails,
  ) async {
    LogUtil.e(() => '[PurchaseService] Error processing purchase: $error\n$stack');
    
    // DO NOT finish purchase on error - treat all errors as recoverable
    // This ensures failed deliveries can be recovered via:
    // 1. System retry (purchase stream will push again)
    // 2. User restore purchases
    // 3. Manual retry mechanisms
    
    return PurchaseProcessResponse(
      result: PurchaseProcessResult.error,
      message: 'Failed to process purchase: $error',
    );
  }

  /// Process a restored purchase
  /// 
  /// Restored purchases should sync entitlements, not create new purchases
  /// 
  /// For restored purchases we always re-verify with the server and then call
  /// [_deliverRestoredPurchase]. Idempotency for delivery is handled at the
  /// circle level (we check whether the circle already exists before calling
  /// `joinCircle`). This allows scenarios like:
  /// - User had an active subscription and a circle created
  /// - User deletes the circle locally
  /// - User taps \"restore purchases\" to (re)join the circle
  /// 
  /// Returns [PurchaseProcessResponse] containing the processing result
  /// [logicalProductId] When provided (e.g. Android store product id), use for verification and group lookup.
  Future<PurchaseProcessResponse> processRestoredPurchase(
    PurchaseDetails purchaseDetails, {
    String? logicalProductId,
  }) async {
    final transactionId = PurchaseIdempotencyManager.getTransactionId(purchaseDetails);

    // Get account to check if circle already exists
    final account = LoginManager.instance.currentState.account;
    if (account == null) {
      throw Exception('User not logged in');
    }

    try {
      LogUtil.d(() => '''
        [PurchaseService] Processing restored purchase:
        - productID: ${purchaseDetails.productID}
        - logicalProductId: $logicalProductId
        - transactionId: $transactionId
      ''');

      // Step 1: Server-side verification
      final verificationResponse = await _verifyPaymentWithServer(
        purchaseDetails,
        logicalProductId: logicalProductId,
      );
      if (verificationResponse.result != PurchaseProcessResult.success) {
        return verificationResponse;
      }
      final verificationResult = verificationResponse.verificationResult!;

      // Step 2: Validate verification result
      final validationResponse = _validateVerificationResult(
        verificationResult,
        purchaseDetails: purchaseDetails,
      );
      if (validationResponse != null) {
        return validationResponse;
      }

      // Step 3: Delivery - join Circle; use logical id for group lookup on Android
      final productIdForGroup = logicalProductId ?? purchaseDetails.productID;
      final groupId = SubscriptionRegistry.instance
          .groupForProductId(productIdForGroup)
          ?.id;
      final deliveryResponse = await _deliverRestoredPurchase(
        verificationResult,
        account,
        groupId,
      );
      if (deliveryResponse.result != PurchaseProcessResult.success &&
          deliveryResponse.result != PurchaseProcessResult.alreadyRestored) {
        // Delivery failed - don't finish, don't mark as processed
        return deliveryResponse;
      }

      // Step 4: Mark as processed (success or alreadyRestored - transaction is valid)
      await PurchaseIdempotencyManager.markAsProcessed(transactionId);

      // Step 5: Complete the purchase (finish) - clear the transaction from queue
      await _completePurchase(purchaseDetails);

      return deliveryResponse;

    } catch (e, stack) {
      return _handleProcessingError(e, stack, purchaseDetails);
    }
  }

  /// Deliver restored purchase by joining Circle
  /// 
  /// For restored purchases, checks if circle already exists before calling joinCircle.
  /// This avoids unnecessary joinCircle calls and potential duplicate circle creation.
  /// 
  /// Returns [PurchaseProcessResponse] with success or failure result
  Future<PurchaseProcessResponse> _deliverRestoredPurchase(
    PaymentVerificationResult verificationResult,
    AccountModel account,
    String? groupId,
  ) async {
    LogUtil.d(() => '''
      [PurchaseService] Starting delivery for restored purchase (joinCircle):
      - relayUrl: ${verificationResult.relayUrl}
      - tenantId: ${verificationResult.tenantId}
      - groupId: $groupId
    ''');
    
    // Check if circle with this relayUrl already exists before calling joinCircle
    // This avoids unnecessary joinCircle calls and potential duplicate circle creation
    final existingCircles = account.circles.where(
      (circle) => circle.type == CircleType.relay && circle.relayUrl == verificationResult.relayUrl,
    );
    
    if (existingCircles.isNotEmpty) {
      LogUtil.d(() => '''
        [PurchaseService] Restored purchase - circle already exists, skipping joinCircle:
        - relayUrl: ${verificationResult.relayUrl}
      ''');
      // Ensure subscription group is recorded so entry display logic can work.
      // Restored circles may have been created without groupId (e.g. migration or old flow).
      if (groupId != null && groupId.isNotEmpty) {
        final accountDb = account.db;
        for (final circle in existingCircles) {
          final needsUpdate = circle.groupId == null || circle.groupId!.isEmpty || circle.ownerPubkey != account.pubkey;
          if (needsUpdate) {
            circle.groupId = groupId;
            circle.ownerPubkey = account.pubkey;
            final updated = await CircleRepository.update(accountDb, circle);
            if (updated) {
              LogUtil.d(() => '''
                [PurchaseService] Restored purchase - updated existing circle with subscription group:
                - circleId: ${circle.id}
                - groupId: $groupId
              ''');
            }
          }
        }
      }
      return PurchaseProcessResponse(
        result: PurchaseProcessResult.alreadyRestored,
        verificationResult: verificationResult,
      );
    }
    
    // Circle doesn't exist, call joinCircle to create it
    final failure = await LoginManager.instance.joinCircle(
      verificationResult.relayUrl,
      type: CircleType.relay,
      groupId: groupId,
    );

    // For restored purchases, it's OK if circle already exists (though we checked above)
    // Even if joinCircle returns a failure, we still consider it successful for restored purchases
    if (failure != null) {
      LogUtil.w(() => '''
        [PurchaseService] Restored purchase - joinCircle returned failure:
        - relayUrl: ${verificationResult.relayUrl}
        - failure type: ${failure.type}
        - failure message: ${failure.message}
        - circleId: ${failure.circleId}
      ''');
      // Still consider it successful for restored purchases (may have been created by another process)
      return PurchaseProcessResponse(
        result: PurchaseProcessResult.success,
        message: failure.message,
        verificationResult: verificationResult,
      );
    }
    
    LogUtil.d(() => '[PurchaseService] Restored purchase - circle joined successfully');
    return PurchaseProcessResponse(
      result: PurchaseProcessResult.success,
      verificationResult: verificationResult,
    );
  }
}
