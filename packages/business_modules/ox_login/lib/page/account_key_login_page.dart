import 'package:flutter/material.dart';
import 'package:ox_common/login/login_models.dart';

// common
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/utils/nip46_status_notifier.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/component.dart';

// plugin
import 'package:ox_localizable/ox_localizable.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_module_service/ox_module_service.dart';

class AccountKeyLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountKeyLoginPageState();
  }
}

class _AccountKeyLoginPageState extends State<AccountKeyLoginPage> with LoginManagerObserver {
  TextEditingController _accountKeyEditingController = new TextEditingController();
  bool _isShowLoginBtn = false;
  String _accountKeyInput = '';
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _accountKeyEditingController.addListener(_checkAccountKey);
    LoginManager.instance.addObserver(this);
  }

  @override
  void dispose() {
    LoginManager.instance.removeObserver(this);
    _accountKeyEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_login.login_button'),
      ),
      body: LoseFocusWrap(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(30.px, 32.px, 30.px, 120.px), // bottom padding to avoid overlap with button
          children: [
            buildKeyInputView(),
          ]
        ),
        Positioned(
          left: 30.px,
          right: 30.px,
          bottom: 24.px,
          child: SafeArea(
            child: CLButton.filled(
              text: _isLoggingIn ? Localized.text('ox_common.loading') : Localized.text('ox_login.login_button'),
              onTap: _isShowLoginBtn && !_isLoggingIn ? _loginWithKey : null,
              expanded: true,
              height: 48.px,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildKeyInputView() {
    final inputStr = _accountKeyEditingController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add title and description
        CLText.headlineSmall(
          Localized.text('ox_login.enter_account_key_login_hint'),
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 16.px),
        
        // Input field with improved placeholder
        CLTextField(
          controller: _accountKeyEditingController,
          placeholder: Localized.text('ox_login.account_key_placeholder'),
          maxLines: null,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            _checkAccountKey();
            if (_accountKeyInput.isNotEmpty && !_isLoggingIn) {
              _loginWithKey();
            }
          },
        ),
        
        SizedBox(height: 12.px),

        CLDescription(
          '${Localized.text('ox_login.nsec_explanation')}\n'
          '${Localized.text('ox_login.bunker_explanation')}\n',
          title: Localized.text('ox_login.account_key_explanation_title'),
        ),
        
        SizedBox(height: 8.px),
        
        // Error hint for invalid nsec
        if (!_isShowLoginBtn && inputStr.trim().startsWith('nsec') && inputStr.length >= 63)
          CLText.bodySmall(
            Localized.text('ox_login.str_nesc_invalid_hint'),
            colorToken: ColorToken.error,
          ),
      ],
    );
  }

  void _checkAccountKey() {
    if (_isLoggingIn) return;
    
    String textContent = _accountKeyEditingController.text.trim();
    if (textContent.startsWith('bunker://')){
      _isShowLoginBtn = true;
      _accountKeyInput = textContent;
    } else {
      if (textContent.length >= 63) {
        final String? decodeResult = UserDBISAR.decodePrivkey(textContent);
        if (decodeResult == null || decodeResult.isEmpty) {
          _isShowLoginBtn = false;
        } else {
          _accountKeyInput = decodeResult;
          _isShowLoginBtn = true;
        }
      } else {
        _isShowLoginBtn = false;
      }
    }
    setState(() {});
  }

  void _loginWithKey() async {
    if (_isLoggingIn || _accountKeyInput.isEmpty) return;

    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _isLoggingIn = true;
    });

    bool success = false;
    
    if (_accountKeyInput.startsWith('bunker://')) {
      // Handle NIP-46 login
      success = await _loginWithNip46();
    } else {
      // Handle private key login with LoginManager
      success = await LoginManager.instance.loginWithPrivateKey(_accountKeyInput);
    }
    
    if (!success) {
      setState(() {
        _isLoggingIn = false;
      });
      // Error handling done in LoginManagerObserver callbacks for private key
      // For NIP-46, errors are handled in _loginWithNip46 method
    }
  }

  Future<bool> _loginWithNip46() async {
    try {
      bool result = await NIP46StatusNotifier.remoteSignerTips(Localized.text('ox_login.wait_link_service'));
      if (!result) {
        return false;
      }

      // Use LoginManager for NIP-46 login
      return await LoginManager.instance.loginWithNostrConnect(_accountKeyInput);
    } catch (e) {
      debugPrint('NIP-46 login failed: $e');
      if (mounted) {
        CommonToast.instance.show(context, 'Login failed: ${e.toString()}');
      }
      return false;
    }
  }

  @override
  void onLoginSuccess(LoginState state) {
    setState(() {
      _isLoggingIn = false;
    });
    
    // Start post-login flow instead of going directly to home
    if (mounted) {
      _startPostLoginFlow();
    }
  }
  
  /// Start the post-login flow
  Future<void> _startPostLoginFlow() async {
    try {
      // Import and use LoginFlowManager
      final flowManager = await _getLoginFlowManager();
      if (flowManager != null) {
        await flowManager.startPostLoginFlow(context, isNewAccount: false);
      } else {
        // Fallback: go directly to home
        if (mounted) {
          OXNavigator.popToRoot(context);
        }
      }
    } catch (e) {
      debugPrint('Error starting post-login flow: $e');
      // Fallback: go directly to home
      if (mounted) {
        OXNavigator.popToRoot(context);
      }
    }
  }
  
  /// Get LoginFlowManager instance
  Future<dynamic> _getLoginFlowManager() async {
    try {
      // Use dynamic import to avoid circular dependency
      final flowManager = await OXModuleService.invoke('ox_login', 'getLoginFlowManager', []);
      return flowManager;
    } catch (e) {
      debugPrint('Error getting LoginFlowManager: $e');
      return null;
    }
  }

  @override
  void onLoginFailure(LoginFailure failure) {
    setState(() {
      _isLoggingIn = false;
    });
    
    if (!mounted) return;
    
    // Show error message based on failure type
    String errorMessage;
    switch (failure.type) {
      case LoginFailureType.invalidKeyFormat:
        errorMessage = Localized.text('ox_login.private_key_regular_failed');
        break;
      case LoginFailureType.errorEnvironment:
        errorMessage = 'Environment error: ${failure.message}';
        break;
      case LoginFailureType.accountDbFailed:
        errorMessage = 'Failed to initialize account database';
        break;
      case LoginFailureType.circleDbFailed:
        errorMessage = 'Failed to initialize circle database';
        break;
    }
    
    CommonToast.instance.show(context, errorMessage);
  }
}
