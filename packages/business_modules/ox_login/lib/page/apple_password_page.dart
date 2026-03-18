import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_localizable/ox_localizable.dart';

/// Full-page form to collect recovery password for Apple-login key derivation.
/// Placed before Create Your Profile. Returns password via Navigator.pop(context, password).
class ApplePasswordPage extends StatefulWidget {
  const ApplePasswordPage({super.key});

  @override
  State<ApplePasswordPage> createState() => _ApplePasswordPageState();
}

class _ApplePasswordPageState extends State<ApplePasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    if (password.isEmpty) {
      setState(() => _errorText = Localized.text('ox_login.apple_password_required'));
      return;
    }
    if (password.length < 8) {
      setState(() => _errorText = Localized.text('ox_login.apple_password_min_length'));
      return;
    }
    if (password != confirm) {
      setState(() => _errorText = Localized.text('ox_login.apple_password_mismatch'));
      return;
    }
    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    return LoseFocusWrap(
      child: CLScaffold(
        appBar: CLAppBar(
          title: Localized.text('ox_login.apple_login_set_password_title'),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(
            vertical: 24.px,
            horizontal: CLLayout.horizontalPadding,
          ),
          children: [
            CLText.bodyMedium(
              Localized.text('ox_login.apple_login_set_password_hint'),
              colorToken: ColorToken.onSurfaceVariant,
              maxLines: null,
            ),
            SizedBox(height: 24.px),
            CLTextField(
              controller: _passwordController,
              placeholder: Localized.text('ox_login.apple_password_placeholder'),
              obscureText: _obscurePassword,
              onChanged: (_) => setState(() => _errorText = null),
            ),
            SizedBox(height: 16.px),
            CLTextField(
              controller: _confirmController,
              placeholder: Localized.text('ox_login.apple_password_confirm_placeholder'),
              obscureText: _obscureConfirm,
              onChanged: (_) => setState(() => _errorText = null),
            ),
            if (_errorText != null) ...[
              SizedBox(height: 12.px),
              CLText.bodySmall(_errorText!, colorToken: ColorToken.error),
            ],
          ],
        ),
        bottomWidget: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16.px),
            child: CLButton.filled(
              onTap: _submit,
              height: 48.px,
              expanded: true,
              text: Localized.text('ox_common.confirm'),
            ),
          ),
        ),
      ),
    );
  }
}
