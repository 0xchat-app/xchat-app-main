import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_localizable/ox_localizable.dart';

class CircleIntroductionPage extends StatelessWidget {
  const CircleIntroductionPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_common.circle_intro_title'),
        previousPageTitle: previousPageTitle,
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
                _buildContent(context),
                SizedBox(height: 24.px),
                // _buildFeatures(),
                // SizedBox(height: 24.px),
                _buildRelayInfo(),
                SizedBox(height: 24.px),
                _buildHowTo(),
                SizedBox(height: 24.px),
                _buildFAQ(context),
                SizedBox(height: 24.px),
                // _buildExamples(context),
                // SizedBox(height: 24.px),
                // _buildNote(context),
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
          Localized.text('ox_common.circle_intro_subtitle'),
          colorToken: ColorToken.primary,
        ),
        SizedBox(height: 8.px),
        Container(
          width: 60.px,
          height: 3.px,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorToken.primary.of(context),
                ColorToken.primary.of(context).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(2.px),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentCard(
          context,
          Localized.text('ox_common.circle_intro_content_1'),
          Icons.hub_outlined,
        ),
        SizedBox(height: 16.px),
        _buildContentCard(
          context,
          Localized.text('ox_common.circle_intro_content_2'),
          Icons.storage,
        ),
        SizedBox(height: 16.px),
        _buildContentCard(
          context,
          Localized.text('ox_common.circle_intro_content_3'),
          Icons.wifi_tethering,
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
              color: ColorToken.primary.of(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.px),
            ),
            child: Icon(
              icon,
              size: 24.px,
              color: ColorToken.primary.of(context),
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

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_common.circle_intro_features_title'),
        ),
        SizedBox(height: 16.px),
        _buildFeatureItem(
          Localized.text('ox_common.circle_intro_feature_1'),
          Localized.text('ox_common.circle_intro_feature_1_desc'),
        ),
        _buildFeatureItem(
          Localized.text('ox_common.circle_intro_feature_2'),
          Localized.text('ox_common.circle_intro_feature_2_desc'),
        ),
        _buildFeatureItem(
          Localized.text('ox_common.circle_intro_feature_3'),
          Localized.text('ox_common.circle_intro_feature_3_desc'),
        ),
        _buildFeatureItem(
          Localized.text('ox_common.circle_intro_feature_4'),
          Localized.text('ox_common.circle_intro_feature_4_desc'),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String feature, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.px),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 4.px),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CLText.titleSmall(feature),
                SizedBox(height: 4.px),
                CLText.bodySmall(
                  description,
                  colorToken: ColorToken.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowTo() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CLText.titleLarge(
            Localized.text('ox_common.circle_intro_how_title'),
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
                _buildStepItem(Localized.text('ox_common.circle_intro_how_step_1')),
                _buildStepItem(Localized.text('ox_common.circle_intro_how_step_2')),
                _buildStepItem(Localized.text('ox_common.circle_intro_how_step_3')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String step) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.px),
      child: CLText.bodyMedium(step),
    );
  }

  Widget _buildRelayInfo() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CLText.titleLarge(
            Localized.text('ox_common.circle_intro_relay_title'),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6.px,
                      height: 6.px,
                      margin: EdgeInsets.only(top: 8.px, right: 8.px),
                      decoration: BoxDecoration(
                        color: ColorToken.primary.of(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: CLText.titleSmall(
                        Localized.text('ox_common.circle_intro_relay_question'),
                        colorToken: ColorToken.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.px),
                Padding(
                  padding: EdgeInsets.only(left: 14.px),
                  child: CLText.bodyMedium(
                    Localized.text('ox_common.circle_intro_relay_answer'),
                    maxLines: null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_common.circle_intro_faq_title'),
        ),
        SizedBox(height: 16.px),
        _buildFAQItem(
          context,
          Localized.text('ox_common.circle_intro_faq_question_1'),
          Localized.text('ox_common.circle_intro_faq_answer_1'),
        ),
        SizedBox(height: 16.px),
        _buildFAQItem(
          context,
          Localized.text('ox_common.circle_intro_faq_question_2'),
          Localized.text('ox_common.circle_intro_faq_answer_2'),
        ),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Container(
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6.px,
                height: 6.px,
                margin: EdgeInsets.only(top: 8.px, right: 8.px),
                decoration: BoxDecoration(
                  color: ColorToken.primary.of(context),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: CLText.titleSmall(
                  question,
                  colorToken: ColorToken.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.px),
          Padding(
            padding: EdgeInsets.only(left: 14.px),
            child: CLText.bodyMedium(
              answer,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_common.circle_intro_examples_title'),
        ),
        SizedBox(height: 16.px),
        _buildExampleChips(context),
      ],
    );
  }

  Widget _buildExampleChips(BuildContext context) {
    final examples = ['0xchat', 'damus', 'nos', 'primal', 'yabu'];
    return Wrap(
      spacing: 8.px,
      runSpacing: 8.px,
      children: examples.map((example) => _buildExampleChip(context, example)).toList(),
    );
  }

  Widget _buildExampleChip(BuildContext context, String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.px, vertical: 6.px),
      decoration: BoxDecoration(
        color: ColorToken.surfaceContainer.of(context),
        borderRadius: BorderRadius.circular(16.px),
        border: Border.all(
          color: ColorToken.onSurfaceVariant.of(context).withOpacity(0.2),
        ),
      ),
      child: CLText.labelMedium(
        name,
        colorToken: ColorToken.onSurfaceVariant,
      ),
    );
  }

  Widget _buildNote(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.px),
      decoration: BoxDecoration(
        color: ColorToken.surfaceContainer.of(context).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.px),
        border: Border.all(
          color: ColorToken.onSurfaceVariant.of(context).withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20.px,
            color: ColorToken.onSurfaceVariant.of(context),
          ),
          SizedBox(width: 12.px),
          Expanded(
            child: CLText.bodySmall(
              Localized.text('ox_common.circle_intro_note'),
              colorToken: ColorToken.onSurfaceVariant,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
} 