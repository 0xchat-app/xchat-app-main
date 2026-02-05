import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_localizable/ox_localizable.dart';

class PrivateCircleLearnMorePage extends StatelessWidget {
  const PrivateCircleLearnMorePage({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.px,
            height: 6.px,
            margin: EdgeInsets.only(top: 8.px, right: 8.px),
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
              _buildPricingItem(
                context,
                '2',
                '0.99',
                '9.99',
              ),
              _buildDivider(context),
              _buildPricingItem(
                context,
                '6',
                '2.99',
                '29.99',
              ),
              _buildDivider(context),
              _buildPricingItem(
                context,
                '20',
                '9.99',
                '99.99',
              ),
            ],
          ),
        ),
        SizedBox(height: 12.px),
        CLText.bodySmall(
          Localized.text('ox_login.private_circle_pricing_disclaimer'),
          colorToken: ColorToken.onSurfaceVariant,
          maxLines: null,
        ),
      ],
    );
  }

  Widget _buildPricingItem(BuildContext context, String members, String monthlyPrice, String yearlyPrice) {
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
                '$members Members',
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
              CLText.titleLarge(
                '\$$monthlyPrice/mo',
                isBold: true,
              ),
              SizedBox(width: 12.px),
              CLText.bodySmall(
                '\$$yearlyPrice/year',
                colorToken: ColorToken.onSurfaceVariant,
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

