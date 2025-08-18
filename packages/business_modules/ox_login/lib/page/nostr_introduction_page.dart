import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_localizable/ox_localizable.dart';

class NostrIntroductionPage extends StatelessWidget {
  const NostrIntroductionPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_login.understanding_nostr_relay'),
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
                _buildWhatIsNostr(context),
                SizedBox(height: 24.px),
                _buildPrivateKeyExplanation(context),
                SizedBox(height: 24.px),
                _buildRemoteSignerExplanation(context),
                SizedBox(height: 24.px),
                _buildHowToUse(context),
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
          Localized.text('ox_login.nostr_intro_subtitle'),
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

  Widget _buildWhatIsNostr(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_login.what_is_nostr_title'),
        ),
        SizedBox(height: 16.px),
        _buildContentCard(
          context,
          Localized.text('ox_login.nostr_explanation'),
          Icons.public,
        ),
      ],
    );
  }

  Widget _buildPrivateKeyExplanation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_login.nostr_private_key_title'),
        ),
        SizedBox(height: 16.px),
        _buildContentCard(
          context,
          Localized.text('ox_login.nostr_private_key_explanation'),
          Icons.key,
        ),
        SizedBox(height: 16.px),
        _buildContentCard(
          context,
          Localized.text('ox_login.nsec_format_explanation'),
          Icons.code,
        ),
      ],
    );
  }

  Widget _buildRemoteSignerExplanation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_login.remote_signer_title'),
        ),
        SizedBox(height: 16.px),
        _buildContentCard(
          context,
          Localized.text('ox_login.remote_signer_explanation'),
          Icons.cloud,
        ),
        SizedBox(height: 16.px),
        _buildContentCard(
          context,
          Localized.text('ox_login.bunker_protocol_explanation'),
          Icons.security,
        ),
      ],
    );
  }

  Widget _buildHowToUse(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_login.how_to_use_title'),
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
              _buildStepItem(
                context,
                '1. ${Localized.text('ox_login.how_to_use_step_1')}',
                Icons.key,
              ),
              SizedBox(height: 12.px),
              _buildStepItem(
                context,
                '2. ${Localized.text('ox_login.how_to_use_step_2')}',
                Icons.cloud,
              ),
              SizedBox(height: 12.px),
              _buildStepItem(
                context,
                '3. ${Localized.text('ox_login.how_to_use_step_3')}',
                Icons.login,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(BuildContext context, String step, IconData icon) {
    return Row(
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
            size: 20.px,
            color: ColorToken.primary.of(context),
          ),
        ),
        SizedBox(width: 12.px),
        Expanded(
          child: CLText.bodyMedium(step),
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
}
