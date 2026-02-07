import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/purchase/purchase_manager.dart';
import 'package:ox_common/purchase/subscription_period.dart';
import 'package:ox_common/purchase/subscription_product_prices.dart';
import 'package:ox_common/purchase/subscription_registry.dart';
import 'package:ox_common/purchase/subscription_tier.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_localizable/ox_localizable.dart';

class PrivateCircleLearnMorePage extends StatefulWidget {
  const PrivateCircleLearnMorePage({super.key});

  @override
  State<PrivateCircleLearnMorePage> createState() => _PrivateCircleLearnMorePageState();
}

class _PrivateCircleLearnMorePageState extends State<PrivateCircleLearnMorePage> {
  late final String _groupId;
  late final List<SubscriptionTier> _tiers;

  @override
  void initState() {
    super.initState();
    _groupId = SubscriptionRegistry.instance.groups.first.id;
    _tiers = SubscriptionRegistry.instance.tiersForGroup(_groupId);
    PurchaseManager.instance.refreshAllPrices();
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_login.private_circle_learn_more'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.px),
        child: SafeArea(
          child: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 24.px),
                _buildFeatures(context),
                SizedBox(height: 24.px),
                _buildPrivacy(context),
                SizedBox(height: 24.px),
                _buildPricing(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _planDisplayName(SubscriptionTier t) {
    switch (t.id) {
      case SubscriptionTierIds.lovers:
        return Localized.text('ox_login.capacity_2_members');
      case SubscriptionTierIds.family:
        return Localized.text('ox_login.capacity_6_members');
      case SubscriptionTierIds.community:
        return Localized.text('ox_login.capacity_50_members');
      default:
        return '${t.maxUsers} ${Localized.text('ox_login.max_users')}';
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.headlineSmall(
          Localized.text('ox_login.private_cloud'),
          colorToken: ColorToken.xChat,
        ),
        SizedBox(height: 8.px),
        Container(
          width: 60.px,
          height: 3.px,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorToken.xChat.of(context),
                ColorToken.xChat.of(context).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(2.px),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_login.private_circle_features_title'),
        ),
        SizedBox(height: 16.px),
        _buildContentCard(
          context,
          Localized.text('ox_login.private_circle_features_1'),
          Icons.dns,
        ),
        SizedBox(height: 12.px),
        _buildContentCard(
          context,
          Localized.text('ox_login.private_circle_features_2'),
          Icons.storage,
        ),
        SizedBox(height: 12.px),
        _buildContentCard(
          context,
          Localized.text('ox_login.private_circle_features_3'),
          Icons.people_outline,
        ),
      ],
    );
  }

  Widget _buildContentCard(BuildContext context, String content, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.px),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.px),
        border: Border.all(
          color: ColorToken.onSurfaceVariant.of(context).withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.px),
            decoration: BoxDecoration(
              color: ColorToken.xChat.of(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.px),
            ),
            child: Icon(
              icon,
              size: 24.px,
              color: ColorToken.xChat.of(context),
            ),
          ),
          SizedBox(width: 12.px),
          Expanded(
            child: CLText.bodyMedium(
              content,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_login.private_circle_privacy_title'),
        ),
        SizedBox(height: 16.px),
        _buildFAQItem(
          context,
          Localized.text('ox_login.private_circle_privacy_1'),
        ),
        SizedBox(height: 12.px),
        _buildFAQItem(
          context,
          Localized.text('ox_login.private_circle_privacy_2'),
        ),
        SizedBox(height: 12.px),
        _buildFAQItem(
          context,
          Localized.text('ox_login.private_circle_privacy_3'),
        ),
        SizedBox(height: 12.px),
        _buildFAQItem(
          context,
          Localized.text('ox_login.private_circle_privacy_4'),
        ),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String content) {
    return Container(
      padding: EdgeInsets.all(16.px),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.px),
        border: Border.all(
          color: ColorToken.onSurfaceVariant.of(context).withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6.px,
            height: 6.px,
            margin: EdgeInsets.only(right: 8.px),
            decoration: BoxDecoration(
              color: ColorToken.xChat.of(context),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: CLText.bodyMedium(
              content,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricing(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_login.private_circle_pricing_title'),
        ),
        SizedBox(height: 16.px),
        Container(
          padding: EdgeInsets.all(16.px),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.px),
            border: Border.all(
              color: ColorToken.onSurfaceVariant.of(context).withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _tiers.length; i++) ...[
                if (i > 0) _buildDivider(context),
                _buildPricingItem(
                  context,
                  _tiers[i],
                  SubscriptionProductPrices.instance.getNotifier(
                    SubscriptionRegistry.instance.productIdFor(
                      _groupId,
                      _tiers[i].id,
                      SubscriptionPeriod.monthly,
                    ),
                  ),
                  SubscriptionProductPrices.instance.getNotifier(
                    SubscriptionRegistry.instance.productIdFor(
                      _groupId,
                      _tiers[i].id,
                      SubscriptionPeriod.yearly,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.px),
        CLText.bodySmall(
          Localized.text('ox_login.private_circle_pricing_disclaimer'),
          colorToken: ColorToken.onSurfaceVariant,
          maxLines: null,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPricingItem(
    BuildContext context,
    SubscriptionTier tier,
    ValueNotifier<String?> monthlyPriceNotifier,
    ValueNotifier<String?> yearlyPriceNotifier,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.px),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              CLText.titleMedium(
                _planDisplayName(tier),
                isBold: true,
              ),
              SizedBox(width: 8.px),
              CLText.labelSmall(
                Localized.text('ox_login.yearly_plan'),
                colorToken: ColorToken.onSurfaceVariant,
              ),
            ],
          ),
          SizedBox(height: 8.px),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ValueListenableBuilder<String?>(
                valueListenable: monthlyPriceNotifier,
                builder: (_, monthlyPrice, __) {
                  if (monthlyPrice == null || monthlyPrice.isEmpty) {
                    return SizedBox(
                      width: 24.px,
                      height: 24.px,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorToken.xChat.of(context),
                      ),
                    );
                  }
                  return CLText.titleLarge(
                    '$monthlyPrice${Localized.text('ox_login.per_month')}',
                    isBold: true,
                  );
                },
              ),
              SizedBox(width: 12.px),
              ValueListenableBuilder<String?>(
                valueListenable: yearlyPriceNotifier,
                builder: (_, yearlyPrice, __) {
                  if (yearlyPrice == null || yearlyPrice.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return CLText.bodySmall(
                    '$yearlyPrice${Localized.text('ox_login.per_year')}',
                    colorToken: ColorToken.onSurfaceVariant,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1.px,
      color: ColorToken.onSurfaceVariant.of(context).withOpacity(0.2),
    );
  }
}

