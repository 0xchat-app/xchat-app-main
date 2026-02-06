import 'package:flutter_test/flutter_test.dart';
import 'package:ox_common/purchase/subscription_tier.dart';
import 'package:ox_common/purchase/subscription_period.dart';

void main() {
  group('SubscriptionTier', () {
    group('level', () {
      test('lovers returns 1', () {
        const tier = SubscriptionTier(
          id: SubscriptionTierIds.lovers,
          maxUsers: 2,
          fileSizeLimitMB: -1,
        );
        expect(tier.level, 1);
      });

      test('family returns 2', () {
        const tier = SubscriptionTier(
          id: SubscriptionTierIds.family,
          maxUsers: 6,
          fileSizeLimitMB: -1,
        );
        expect(tier.level, 2);
      });

      test('community returns 3', () {
        const tier = SubscriptionTier(
          id: SubscriptionTierIds.community,
          maxUsers: 20,
          fileSizeLimitMB: -1,
        );
        expect(tier.level, 3);
      });

      test('unknown id returns 1 (default)', () {
        const tier = SubscriptionTier(
          id: 'unknown',
          maxUsers: 1,
          fileSizeLimitMB: -1,
        );
        expect(tier.level, 1);
      });
    });

    group('levelPeriod', () {
      test('returns 2592000 for monthly (30 days in seconds)', () {
        const tier = SubscriptionTier(
          id: SubscriptionTierIds.family,
          maxUsers: 6,
          fileSizeLimitMB: -1,
        );
        expect(tier.levelPeriod(SubscriptionPeriod.monthly), '2592000');
      });

      test('returns 31536000 for yearly', () {
        const tier = SubscriptionTier(
          id: SubscriptionTierIds.family,
          maxUsers: 6,
          fileSizeLimitMB: -1,
        );
        expect(tier.levelPeriod(SubscriptionPeriod.yearly), '31536000');
      });
    });
  });
}
