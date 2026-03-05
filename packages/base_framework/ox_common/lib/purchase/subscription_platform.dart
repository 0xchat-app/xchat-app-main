import 'subscription_registry.dart';
import 'subscription_platform_impl_stub.dart'
    if (dart.library.io) 'subscription_platform_impl_io.dart' as _impl;

/// Platform-specific subscription product ID handling.
///
/// On iOS: one product ID per (group, tier, period) — 12 product IDs; query and purchase use the same ID.
/// On Android: 6 subscription products, each with 2 base plans (monthly/yearly); query uses 6 IDs,
/// purchase uses product + offerToken; purchaseDetails.productID is the store product ID (e.g. loc1.level1).
abstract class SubscriptionPlatform {
  SubscriptionPlatform();

  static SubscriptionPlatform get instance => _instance;
  static late final SubscriptionPlatform _instance = _impl.getSubscriptionPlatform();

  /// Product IDs to pass to the store's queryProductDetails.
  /// iOS: 12 IDs (loc1.level1.monthly, ...). Android: 6 IDs (loc1.level1, loc1.level2, ...).
  Set<String> get productIdsForQuery;

  /// Resolve the logical product ID for server verification and group/tier lookup.
  /// [storeProductId] is purchaseDetails.productID from the store.
  /// On iOS, this is already the logical ID. On Android, it is the store product ID (e.g. loc1.level1);
  /// [pendingLogicalId] is the logical ID we started the purchase with (e.g. loc1.level1.monthly), use it when available.
  String resolveLogicalProductId(String storeProductId, {String? pendingLogicalId});

  /// For store query/purchase: on Android returns store product id (e.g. loc1.level1) when [logicalProductId] is logical (e.g. loc1.level1.monthly); otherwise returns null (use as-is).
  String? storeProductIdForQuery(String logicalProductId) => null;
}

/// iOS (and stub): 12 product IDs, productID from store is already the logical ID.
class SubscriptionPlatformIos extends SubscriptionPlatform {
  SubscriptionPlatformIos() : super();

  @override
  Set<String> get productIdsForQuery =>
      SubscriptionRegistry.instance.allProductIds;

  @override
  String resolveLogicalProductId(String storeProductId,
      {String? pendingLogicalId}) {
    return pendingLogicalId ?? storeProductId;
  }
}
