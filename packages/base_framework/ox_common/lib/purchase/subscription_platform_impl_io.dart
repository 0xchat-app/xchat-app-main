import 'dart:io';

import 'subscription_platform.dart';

SubscriptionPlatform getSubscriptionPlatform() {
  if (Platform.isAndroid) {
    return SubscriptionPlatformAndroid();
  }
  return SubscriptionPlatformIos();
}

/// Android: 6 store product IDs (loc.level); logical ID = storeId + '.' + period (monthly/yearly).
class SubscriptionPlatformAndroid extends SubscriptionPlatform {
  SubscriptionPlatformAndroid() : super();

  static const Set<String> _storeProductIds = {
    'loc1.level1',
    'loc1.level2',
    'loc1.level3',
    'loc2.level1',
    'loc2.level2',
    'loc2.level3',
  };

  static const String _basePlanMonthly = 'monthly';
  static const String _basePlanYearly = 'yearly';

  @override
  Set<String> get productIdsForQuery => _storeProductIds;

  @override
  String resolveLogicalProductId(String storeProductId,
      {String? pendingLogicalId}) {
    if (pendingLogicalId != null && pendingLogicalId.isNotEmpty) {
      return pendingLogicalId;
    }
    // Restore flow: we only have store product ID. Best effort: append .monthly so backend gets a known format.
    // Backend may need to accept "loc1.level1" and map to same relay as loc1.level1.monthly/loc1.level1.yearly.
    if (_storeProductIds.contains(storeProductId)) {
      return '$storeProductId.monthly';
    }
    return storeProductId;
  }

  /// Store product ID for a logical product ID (e.g. loc1.level1.monthly -> loc1.level1).
  static String? storeProductIdFromLogical(String logicalProductId) {
    if (logicalProductId.endsWith('.monthly')) {
      return logicalProductId.substring(
          0, logicalProductId.length - '.monthly'.length);
    }
    if (logicalProductId.endsWith('.yearly')) {
      return logicalProductId.substring(
          0, logicalProductId.length - '.yearly'.length);
    }
    return null;
  }

  /// Base plan ID for a logical product ID (monthly or yearly).
  static String? basePlanIdFromLogical(String logicalProductId) {
    if (logicalProductId.endsWith('.monthly')) return _basePlanMonthly;
    if (logicalProductId.endsWith('.yearly')) return _basePlanYearly;
    return null;
  }

  @override
  String? storeProductIdForQuery(String logicalProductId) =>
      storeProductIdFromLogical(logicalProductId);
}
