import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ox_common/component.dart';

// ox_common
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/took_kit.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_loading.dart';

// component
import '../component/lose_focus_wrap.dart';

// plugin
import 'package:chatcore/chat-core.dart';
import 'package:ox_localizable/ox_localizable.dart';
export 'package:visibility_detector/visibility_detector.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_module_service/ox_module_service.dart';

/// Create Account Page
/// 
/// Displays a form for users to create a new nostr account with public/private key pair.
/// Allows users to copy keys, generate new keys, and accept terms before creating account.
class CreateAccountPage extends StatefulWidget {
  CreateAccountPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CreateAccountPageState();
  }
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // Text content for the page
  final String _publicKeyTips = 'Before we get started, you\'ll need to save your nostr account ID. You can share it with your contacts so they can add you as a friend. Tap to copy';
  final String _privateKeyTips = 'This is your secret account key. You need this to access your account. otherwise you won\'t be able to login in the future if you ever uninstall 0xchat. Don\'t share this with anyone! Save it in a password manager and keep it safe!';

  // Key generation state
  late Keychain keychain;
  
  // Reactive state management
  final ValueNotifier<String> _encodedPubkey$ = ValueNotifier<String>('');
  final ValueNotifier<String> _encodedPrivkey$ = ValueNotifier<String>('');
  final ValueNotifier<bool> _hasAcceptedTerms$ = ValueNotifier<bool>(true); // 默认勾选协议

  double get separatorHeight => 20.px;

  @override
  void initState() {
    super.initState();
    _generateKeys();
  }

  @override
  void dispose() {
    _encodedPubkey$.dispose();
    _encodedPrivkey$.dispose();
    _hasAcceptedTerms$.dispose();
    super.dispose();
  }

  /// Generate new key pair for the account
  void _generateKeys() {
    keychain = Account.generateNewKeychain();
    _encodedPubkey$.value = Nip19.encodePubkey(keychain.public);
    _encodedPrivkey$.value = Nip19.encodePubkey(keychain.private);
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_login.create_account'),
      ),
      body: LoseFocusWrap(_buildBody()),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.px),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: separatorHeight),
            _buildPublicKeySection(),
            SizedBox(height: separatorHeight),
            _buildPrivateKeySection(),
            SizedBox(height: separatorHeight), // 40.px = 20 * 2
            _buildCreateButton(),
            SizedBox(height: separatorHeight),
            _buildGenerateNewKeyButton(),
            SizedBox(height: separatorHeight),
            _buildTermsSection(),
            SizedBox(height: separatorHeight), // 40.px = 20 * 2
          ],
        ),
      ),
    );
  }

  /// Build public key input section
  Widget _buildPublicKeySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.bodyMedium(_publicKeyTips),
        SizedBox(height: separatorHeight),
        ValueListenableBuilder<String>(
          valueListenable: _encodedPubkey$,
          builder: (context, encodedPubkey, child) {
            return CLTextField(
              initialText: encodedPubkey,
              placeholder: Localized.text('ox_login.public_key'),
              readOnly: true,
              maxLines: 2,
              onTap: () => _copyKey(encodedPubkey),
              suffixIcon: Icon(
                Icons.copy_rounded,
                size: 24.px,
              ).setPadding(EdgeInsets.all(8.px)),
            );
          },
        ),
      ],
    );
  }

  /// Build private key input section  
  Widget _buildPrivateKeySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.bodyMedium(_privateKeyTips),
        SizedBox(height: separatorHeight),
        ValueListenableBuilder<String>(
          valueListenable: _encodedPrivkey$,
          builder: (context, encodedPrivkey, child) {
            return CLTextField(
              initialText: encodedPrivkey,
              placeholder: Localized.text('ox_login.private_key'),
              readOnly: true,
              maxLines: 2,
              onTap: () => _copyKey(encodedPrivkey),
              suffixIcon: Icon(
                Icons.copy_rounded,
                size: 24.px,
              ).setPadding(EdgeInsets.all(8.px)),
            );
          },
        ),
      ],
    );
  }

  /// Build create account button
  Widget _buildCreateButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _hasAcceptedTerms$,
      builder: (context, hasAccepted, child) {
        return CLButton.filled(
          text: Localized.text('ox_login.create'),
          onTap: hasAccepted ? _onCreateAccountTap : null,
          expanded: true,
          height: 48.px,
        );
      },
    );
  }

  /// Build generate new key button
  Widget _buildGenerateNewKeyButton() {
    return CLButton.tonal(
      text: Localized.text('ox_login.generate_new_key'),
      onTap: _onGenerateNewKeyTap,
      expanded: true,
      height: 48.px,
    );
  }

  /// Build terms and conditions section
  Widget _buildTermsSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _hasAcceptedTerms$,
      builder: (context, hasAccepted, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CLCheckbox(
              value: hasAccepted,
              onChanged: (value) => _hasAcceptedTerms$.value = value ?? false,
              size: 40.px,
            ),
            SizedBox(width: 12.px),
            Expanded(
              child: _buildTermsText(),
            ),
          ],
        );
      },
    );
  }

  /// Build terms and conditions text with links
  Widget _buildTermsText() {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall,
        children: [
          const TextSpan(text: 'By Creating your account you accept the '),
          TextSpan(
            text: Localized.text('ox_login.terms_of_service'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).colorScheme.primary,
            ),
            recognizer: TapGestureRecognizer()..onTap = _onTermsOfUseTap,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: Localized.text('ox_login.privacy_policy'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).colorScheme.primary,
            ),
            recognizer: TapGestureRecognizer()..onTap = _onPrivacyPolicyTap,
          ),
        ],
      ),
    );
  }

  /// Copy key to clipboard
  void _copyKey(String key) {
    TookKit.copyKey(context, key);
  }

  /// Handle create account button tap
  void _onCreateAccountTap() async {
    await _createAccount();
  }

  /// Handle generate new key button tap  
  void _onGenerateNewKeyTap() {
    _generateKeys();
  }

  /// Handle terms of use link tap
  void _onTermsOfUseTap() {
    OXModuleService.invoke('ox_common', 'gotoWebView', [
      context, 
      'https://www.0xchat.com/protocols/0xchat_terms_of_use.html', 
      null, 
      null, 
      null, 
      null
    ]);
  }

  /// Handle privacy policy link tap
  void _onPrivacyPolicyTap() {
    OXModuleService.invoke('ox_common', 'gotoWebView', [
      context, 
      'https://www.0xchat.com/protocols/0xchat_privacy_policy.html', 
      null, 
      null, 
      null, 
      null
    ]);
  }

  /// Create account with generated keys
  Future<void> _createAccount() async {
    await OXLoading.show();
    try {
      await OXUserInfoManager.sharedInstance.initDB(keychain.public);
      final user = await Account.sharedInstance.loginWithPriKey(keychain.private);
      if (user != null) {
        await OXUserInfoManager.sharedInstance.loginSuccess(user);
        OXNavigator.popToRoot(context);
      }
    } catch (e) {
      // TODO: Handle error properly
      debugPrint('Create account failed: $e');
    } finally {
      await OXLoading.dismiss();
    }
  }

  // Legacy method - kept for compatibility
  void createKeys() {
    _generateKeys();
  }

  // Legacy method - kept for compatibility  
  void createOnTap() async {
    await _createAccount();
  }

  // Legacy getters - kept for compatibility
  String get encodedPubkey => _encodedPubkey$.value;
  String get encodedPrivkey => _encodedPrivkey$.value;
}
