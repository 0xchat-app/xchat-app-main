import 'subscription_period.dart';

/// Tier identifiers. Fixed mapping lovers→1, family→2, community→3.
abstract class SubscriptionTierIds {
  SubscriptionTierIds._();

  static const String lovers = 'lovers';
  static const String family = 'family';
  static const String community = 'community';
}

/// Subscription tier: capacity only. No pricing — use store [ProductDetails]
/// for display/charge. UI controls display (name, description, color, isPopular) via tier id.
class SubscriptionTier {
  final String id;
  final int maxUsers;
  final int fileSizeLimitMB;

  const SubscriptionTier({
    required this.id,
    required this.maxUsers,
    required this.fileSizeLimitMB,
  });

  String levelPeriod(SubscriptionPeriod period) =>
      period == SubscriptionPeriod.monthly ? '2592000' : '31536000';

  /// lovers→1, family→2, community→3. Fixed, no extension.
  int get level {
    switch (id) {
      case SubscriptionTierIds.lovers:
        return 1;
      case SubscriptionTierIds.family:
        return 2;
      case SubscriptionTierIds.community:
        return 3;
      default:
        return 1;
    }
  }
}
