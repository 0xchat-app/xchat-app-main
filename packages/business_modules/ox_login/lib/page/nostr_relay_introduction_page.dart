import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_localizable/ox_localizable.dart';

class NostrRelayIntroductionPage extends StatelessWidget {
  const NostrRelayIntroductionPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_login.relay_intro_title'),
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
                _buildWhatIsRelay(context),
                SizedBox(height: 24.px),
                _buildHowRelayWorks(context),
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
          Localized.text('ox_login.relay_intro_subtitle'),
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
        SizedBox(height: 16.px),
        CLText.bodyMedium(
          Localized.text('ox_login.relay_intro_description'),
          colorToken: ColorToken.onSurfaceVariant,
          maxLines: null,
        ),
      ],
    );
  }

  Widget _buildWhatIsRelay(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_login.relay_intro_what_title'),
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
              _buildInfoCard(
                context,
                Localized.text('ox_login.relay_intro_what_1'),
                Icons.storage_outlined,
              ),
              SizedBox(height: 12.px),
              _buildInfoCard(
                context,
                Localized.text('ox_login.relay_intro_what_2'),
                Icons.router_outlined,
              ),
              SizedBox(height: 12.px),
              _buildInfoCard(
                context,
                Localized.text('ox_login.relay_intro_what_3'),
                Icons.security_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String content, IconData icon) {
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
          child: CLText.bodyMedium(
            content,
            maxLines: null,
          ),
        ),
      ],
    );
  }

  Widget _buildHowRelayWorks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          Localized.text('ox_login.relay_intro_how_title'),
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
                '1',
                Localized.text('ox_login.relay_intro_how_step_1'),
              ),
              SizedBox(height: 12.px),
              _buildStepItem(
                context,
                '2',
                Localized.text('ox_login.relay_intro_how_step_2'),
              ),
              SizedBox(height: 12.px),
              _buildStepItem(
                context,
                '3',
                Localized.text('ox_login.relay_intro_how_step_3'),
              ),
              SizedBox(height: 12.px),
              _buildStepItem(
                context,
                '4',
                Localized.text('ox_login.relay_intro_how_step_4'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(BuildContext context, String stepNumber, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.px,
          height: 24.px,
          decoration: BoxDecoration(
            color: ColorToken.primary.of(context),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CLText.labelMedium(
              stepNumber,
              colorToken: ColorToken.onPrimary,
            ),
          ),
        ),
        SizedBox(width: 12.px),
        Expanded(
          child: CLText.bodyMedium(
            description,
            maxLines: null,
          ),
        ),
      ],
    );
  }
}
