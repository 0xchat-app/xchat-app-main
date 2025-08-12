import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_common/utils/circle_join_utils.dart';
import 'package:ox_common/page/circle_introduction_page.dart';

/// Relay setup page for adding relay and creating circle
/// 
/// This page allows users to add a relay and create a circle after login/registration.
/// Users can skip this step if they want to go directly to home.
class RelaySetupPage extends StatefulWidget {
  const RelaySetupPage({
    super.key,
    this.isNewAccount = false,
  });

  final bool isNewAccount;

  @override
  State<RelaySetupPage> createState() => _RelaySetupPageState();
}

class _RelaySetupPageState extends State<RelaySetupPage> {
  final TextEditingController _relayController = TextEditingController();
  bool _isJoining = false;
  bool _hasRelayInput = false;

  @override
  void initState() {
    super.initState();
    _relayController.addListener(_onRelayInputChanged);
  }

  @override
  void dispose() {
    _relayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isNewAccount 
        ? Localized.text('ox_login.setup_relay_title')
        : Localized.text('ox_login.add_relay_title');
    
    return CLScaffold(
      appBar: CLAppBar(
        title: title,
        actions: [
          // Skip button
          CLButton.text(
            text: Localized.text('ox_common.skip'),
            onTap: _onSkipTap,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(24.px),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 32.px),
            _buildRelayInput(),
            SizedBox(height: 24.px),
            _buildPredefinedRelays(),
            SizedBox(height: 32.px),
            _buildActionButtons(),
            SizedBox(height: 24.px),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final title = widget.isNewAccount 
        ? Localized.text('ox_login.setup_relay_header_title')
        : Localized.text('ox_login.add_relay_header_title');
    
    final subtitle = widget.isNewAccount
        ? Localized.text('ox_login.setup_relay_header_subtitle')
        : Localized.text('ox_login.add_relay_header_subtitle');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          title,
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 12.px),
        CLText.bodyMedium(
          subtitle,
          colorToken: ColorToken.onSurfaceVariant,
          maxLines: null,
        ),
      ],
    );
  }

  Widget _buildRelayInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleMedium(
          Localized.text('ox_login.relay_url_label'),
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 12.px),
        CLTextField(
          controller: _relayController,
          placeholder: Localized.text('ox_login.relay_url_placeholder'),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onJoinRelayTap(),
        ),
        SizedBox(height: 8.px),
        CLText.bodySmall(
          Localized.text('ox_login.relay_url_hint'),
          colorToken: ColorToken.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildPredefinedRelays() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleMedium(
          Localized.text('ox_login.predefined_relays_title'),
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 16.px),
        Wrap(
          spacing: 12.px,
          runSpacing: 12.px,
          children: [
            _buildPredefinedRelayChip('0xchat'),
            _buildPredefinedRelayChip('damus'),
            _buildPredefinedRelayChip('nos'),
            _buildPredefinedRelayChip('primal'),
            _buildPredefinedRelayChip('nostrband'),
          ],
        ),
      ],
    );
  }

  Widget _buildPredefinedRelayChip(String relayName) {
    return ActionChip(
      label: CLText.bodyMedium(relayName),
      onPressed: () {
        _relayController.text = relayName;
        _onRelayInputChanged();
      },
      backgroundColor: ColorToken.surfaceContainer.of(context),
      side: BorderSide(
        color: ColorToken.onSurfaceVariant.of(context).withOpacity(0.2),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CLButton.filled(
          text: _isJoining 
              ? Localized.text('ox_common.loading')
              : Localized.text('ox_login.join_relay'),
          onTap: _hasRelayInput && !_isJoining ? _onJoinRelayTap : null,
          expanded: true,
          height: 48.px,
        ),
        SizedBox(height: 16.px),
        CLButton.tonal(
          text: Localized.text('ox_login.learn_more_about_relays'),
          onTap: _onLearnMoreTap,
          expanded: true,
          height: 48.px,
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(16.px),
      decoration: BoxDecoration(
        color: ColorToken.surfaceContainer.of(context),
        borderRadius: BorderRadius.circular(12.px),
        border: Border.all(
          color: ColorToken.onSurfaceVariant.of(context).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20.px,
                color: ColorToken.primary.of(context),
              ),
              SizedBox(width: 8.px),
              CLText.titleSmall(
                Localized.text('ox_login.relay_info_title'),
                colorToken: ColorToken.primary,
              ),
            ],
          ),
          SizedBox(height: 12.px),
          CLText.bodySmall(
            Localized.text('ox_login.relay_info_content'),
            colorToken: ColorToken.onSurfaceVariant,
            maxLines: null,
          ),
        ],
      ),
    );
  }

  void _onRelayInputChanged() {
    final hasInput = _relayController.text.trim().isNotEmpty;
    if (hasInput != _hasRelayInput) {
      setState(() {
        _hasRelayInput = hasInput;
      });
    }
  }

  Future<void> _onJoinRelayTap() async {
    if (_isJoining) return;

    final relayInput = _relayController.text.trim();
    if (relayInput.isEmpty) return;

    setState(() {
      _isJoining = true;
    });

    try {
      // Show loading
      OXLoading.show();
      
      // Use CircleJoinUtils to join the relay
      final success = await CircleJoinUtils.showJoinCircleDialog(
        context: context,
        circleType: CircleType.relay,
      );

      OXLoading.dismiss();

      if (success) {
        // Successfully joined relay, return true to continue to profile setup
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // User cancelled or failed to join
        setState(() {
          _isJoining = false;
        });
      }
    } catch (e) {
      OXLoading.dismiss();
      setState(() {
        _isJoining = false;
      });
      
      if (mounted) {
        CommonToast.instance.show(
          context, 
          'Failed to join relay: ${e.toString()}'
        );
      }
    }
  }

  void _onLearnMoreTap() {
    // Navigate to circle introduction page
    OXNavigator.pushPage(
      context,
      (context) => const CircleIntroductionPage(),
      type: OXPushPageType.present,
    );
  }

  void _onSkipTap() {
    // Return false to indicate user skipped relay setup
    Navigator.of(context).pop(false);
  }
}
