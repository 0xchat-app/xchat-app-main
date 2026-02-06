import 'subscription_group.dart';
import 'subscription_period.dart';
import 'subscription_tier.dart';

/// Single source for subscription groups, tiers, and productIds.
/// ProductIds are explicitly configured per (groupId, tierId, period).
class SubscriptionRegistry {
  SubscriptionRegistry._();

  static final SubscriptionRegistry instance = SubscriptionRegistry._();

  static final List<SubscriptionGroup> _groups = [
    const SubscriptionGroup(
      id: SubscriptionGroupIds.loc1,
      displayName: 'Server location 1',
      sortOrder: 0,
    ),
    const SubscriptionGroup(
      id: SubscriptionGroupIds.loc2,
      displayName: 'Server location 2',
      sortOrder: 1,
    ),
  ];

  static const List<SubscriptionTier> _tiers = [
    SubscriptionTier(
      id: SubscriptionTierIds.lovers,
      maxUsers: 2,
      fileSizeLimitMB: -1,
    ),
    SubscriptionTier(
      id: SubscriptionTierIds.family,
      maxUsers: 6,
      fileSizeLimitMB: -1,
    ),
    SubscriptionTier(
      id: SubscriptionTierIds.community,
      maxUsers: 20,
      fileSizeLimitMB: -1,
    ),
  ];

  static String _productIdKey(String g, String t, SubscriptionPeriod p) {
    final periodStr = p == SubscriptionPeriod.monthly ? 'monthly' : 'yearly';
    return '$g|$t|$periodStr';
  }

  static const Map<String, String> _productIds = {
    'loc1|lovers|monthly': 'loc1.level1.monthly',
    'loc1|lovers|yearly': 'loc1.level1.yearly',
    'loc1|family|monthly': 'loc1.level2.monthly',
    'loc1|family|yearly': 'loc1.level2.yearly',
    'loc1|community|monthly': 'loc1.level3.monthly',
    'loc1|community|yearly': 'loc1.level3.yearly',
    'loc2|lovers|monthly': 'loc2.level1.monthly',
    'loc2|lovers|yearly': 'loc2.level1.yearly',
    'loc2|family|monthly': 'loc2.level2.monthly',
    'loc2|family|yearly': 'loc2.level2.yearly',
    'loc2|community|monthly': 'loc2.level3.monthly',
    'loc2|community|yearly': 'loc2.level3.yearly',
  };

  /// All subscription groups, ordered by sortOrder.
  List<SubscriptionGroup> get groups => List.unmodifiable(_groups);

  /// Tiers for a group (2 / 6 / 20), fixed order.
  List<SubscriptionTier> tiersForGroup(String groupId) {
    if (!_groups.any((g) => g.id == groupId)) return [];
    return List.unmodifiable(_tiers);
  }

  /// ProductId for (groupId, tierId, period). Throws if not configured.
  String productIdFor(String groupId, String tierId, SubscriptionPeriod period) {
    final key = _productIdKey(groupId, tierId, period);
    final pid = _productIds[key];
    if (pid == null) {
      throw StateError('No productId for groupId=$groupId tierId=$tierId period=$period');
    }
    return pid;
  }

  /// All configured productIds (for restore).
  Set<String> get allProductIds =>
      Set.unmodifiable(_productIds.values.toSet());

  /// Group for productId, or null.
  SubscriptionGroup? groupForProductId(String productId) {
    for (final e in _productIds.entries) {
      if (e.value == productId) {
        final parts = e.key.split('|');
        if (parts.length < 2) return null;
        final gid = parts[0];
        for (final g in _groups) {
          if (g.id == gid) return g;
        }
        return null;
      }
    }
    return null;
  }

  /// Tier for productId, or null.
  SubscriptionTier? tierForProductId(String productId) {
    for (final e in _productIds.entries) {
      if (e.value == productId) {
        final parts = e.key.split('|');
        if (parts.length < 2) return null;
        final tid = parts[1];
        for (final t in _tiers) {
          if (t.id == tid) return t;
        }
        return null;
      }
    }
    return null;
  }
}
