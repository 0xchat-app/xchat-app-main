import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
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
    return LoseFocusWrap(
      child: CLScaffold(
        appBar: CLAppBar(
          actions: [
            CLButton.text(
              text: Localized.text('ox_common.skip'),
              onTap: _onSkipTap,
            ),
          ],
        ),
        body: _buildBody(),
        bottomWidget: CLButton.filled(
          text: _isJoining
              ? Localized.text('ox_common.loading')
              : Localized.text('ox_login.join_relay'),
          onTap: _hasRelayInput && !_isJoining ? _onJoinRelayTap : null,
          expanded: true,
          height: 48.px,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 24.px,
        horizontal: CLLayout.horizontalPadding,
      ),
      children: [
        _buildHeader(),
        SizedBox(height: 32.px),
        _buildRelayInput(),
      ],
    );
  }

  Widget _buildHeader() {
    final title = widget.isNewAccount
        ? Localized.text('ox_login.setup_relay_header_title')
        : Localized.text('ox_login.add_relay_header_title');
    
    final subtitle = widget.isNewAccount
        ? Localized.text('ox_login.setup_relay_header_subtitle')
        : Localized.text('ox_login.add_relay_header_subtitle');

    final learnMore = Localized.text('ox_login.learn_more_about_relays');
    final subtitleWithLearnMore = '$subtitle $learnMore';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CLText.titleLarge(
          title,
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 12.px),
        CLText.bodyMedium(
          subtitleWithLearnMore,
          colorToken: ColorToken.onSurfaceVariant,
          maxLines: null,
        ).highlighted(
          rules: [
            CLHighlightRule(
              pattern: RegExp(learnMore),
              onTap: (_) => _onLearnMoreTap(),
              cursor: SystemMouseCursors.click,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRelayInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ).highlighted(
          rules: [
            CLHighlightRule(
              pattern: RegExp(r'\b0xchat\b', caseSensitive: false),
              onTap: (match) => _onExampleTap(match),
              cursor: SystemMouseCursors.click,
            ),
            CLHighlightRule(
              pattern: RegExp(r'\bdamus\b', caseSensitive: false),
              onTap: (match) => _onExampleTap(match),
              cursor: SystemMouseCursors.click,
            ),
          ],
        ),
      ],
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
      final success = await CircleJoinUtils.processJoinInput(
        context,
        relayInput,
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

  void _onExampleTap(String example) {
    _relayController.text = example;
    _relayController.selection = TextSelection.fromPosition(
      TextPosition(offset: _relayController.text.length),
    );
    _onRelayInputChanged();
  }

  void _onSkipTap() {
    // Return false to indicate user skipped relay setup
    Navigator.of(context).pop(false);
  }
}
