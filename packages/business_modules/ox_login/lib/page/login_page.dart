// plugin
import 'dart:io';

import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/const/common_constant.dart';
// ox_common
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/nip46_status_notifier.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_localizable/ox_localizable.dart';
// ox_login
import 'package:ox_login/page/account_key_login_page.dart';
import 'package:ox_login/page/create_account_page.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:rich_text_widget/rich_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        const Spacer(),
        BannerCarousel(
          items: [
            BannerItem(
              image: CommonImage(
                iconName: 'image_guide_1.png',
                size: 280.px,
                package: 'ox_login',
                isPlatformStyle: true,
              ),
              title: 'End-to-End Encryption',
              text: 'Only you and the recipient can read the messages. No one else.',
            ),
            BannerItem(
              image: CommonImage(
                iconName: 'image_guide_2.png',
                size: 280.px,
                package: 'ox_login',
                isPlatformStyle: true,
              ),
              title: 'Decentralized Network',
              text: 'No central servers. No control. Just private communication.',
            ),
            BannerItem(
              image: CommonImage(
                iconName: 'image_guide_3.png',
                size: 280.px,
                package: 'ox_login',
                isPlatformStyle: true,
              ),
              title: 'Encrypted Local Storage',
              text: 'Chats are encrypted and stored on your device.',
            ),
            BannerItem(
              image: CommonImage(
                iconName: 'image_guide_4.png',
                size: 280.px,
                package: 'ox_login',
                isPlatformStyle: true,
              ),
              title: 'Anonymous Messaging',
              text: 'No phone number. No email. Just pure anonymity.',
            ),
          ],
          height: 460.py,
          padding: EdgeInsets.symmetric(horizontal: 32.px),
        ),
        const Spacer(),
        Column(
          children: [
            buildCreateAccountButton().setPaddingOnly(bottom: 18.px),
            buildLoginButton().setPaddingOnly(bottom: 18.px),
            // buildQrCodeLoginWidget().setPaddingOnly(bottom: 18.px),
            // buildPrivacyWidget().setPaddingOnly(bottom: 18.px),
            if(Platform.isAndroid) buildAmberLoginWidget(),
          ],
        ).setPadding(EdgeInsets.symmetric(horizontal: 32.px)),
        SizedBox(height: 12.py,),
      ],
    );
  }

  Widget buildLogoIcon() => CommonImage(
    iconName: 'logo_icon.png',
    fit: BoxFit.contain,
    width: Adapt.px(180),
    height: Adapt.px(180),
    useTheme: true,
  );

  Widget buildTips() => Container(
    child: Text(
      Localized.text('ox_login.login_tips'),
      style: TextStyle(color: ThemeColor.titleColor, fontSize: 18.sp),
      textAlign: TextAlign.center,
    ),
  );

  Widget buildCreateAccountButton() => CLButton.filled(
    onTap: _createAccount,
    height: 48.py,
    expanded: true,
    text: Localized.text('ox_login.create_account'),
  );

  Widget buildLoginButton() => CLButton.tonal(
    onTap: _login,
    height: 48.py,
    expanded: true,
    text: Localized.text('ox_login.login_button'),
  );

  Widget buildPrivacyWidget() => Container(
    margin: EdgeInsets.symmetric(horizontal: 24.px),
    child: RichTextWidget(
      // default Text
      Text(
        Localized.text('ox_login.terms_of_service_privacy_policy'),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: Adapt.px(14),
          color: ThemeColor.titleColor,
          height: 1.5,
        ),
      ),
      maxLines: 2,
      textAlign: TextAlign.center,
      // rich text list
      richTexts: [
        BaseRichText(
          Localized.text("ox_login.terms_of_service"),
          style: TextStyle(
            fontSize: Adapt.px(14),
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [ThemeColor.gradientMainEnd, ThemeColor.gradientMainStart],
              ).createShader(
                Rect.fromLTWH(0.0, 0.0, 550.0, 70.0),
              ),
          ),
          onTap: _serviceWebView,
        ),
        BaseRichText(
          Localized.text("ox_login.privacy_policy"),
          style: TextStyle(
            fontSize: Adapt.px(14),
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [ThemeColor.gradientMainEnd, ThemeColor.gradientMainStart],
              ).createShader(
                Rect.fromLTWH(0.0, 0.0, 350.0, 70.0),
              ),
          ),
          onTap: _privacyPolicyWebView,
        ),
      ],
    ),
  );

  Widget buildAmberLoginWidget() {
    bool isAndroid = Platform.isAndroid;
    String text = isAndroid ? Localized.text('ox_login.login_with_amber') : Localized.text('ox_login.login_with_aegis');
    GestureTapCallback? onTap = isAndroid ? _loginWithAmber : _loginWithNostrAegis;
    String iconName = isAndroid ? "icon_login_amber.png" : "icon_login_aegis.png";
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 70.px,
        child: Stack(
          children: [
            Positioned(
              top: 24.px,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 0.5.px,
                color: ThemeColor.color160,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: CommonImage(
                iconName: iconName,
                width: 48.px,
                height: 48.px,
                package: 'ox_login',
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CLText.labelSmall(text),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Event Handlers ==========

  void _createAccount() {
    OXNavigator.pushPage(context, (context) => CreateAccountPage());
  }

  void _login() {
    OXNavigator.pushPage(context, (context) => AccountKeyLoginPage());
  }

  void _loginWithNostrAegis() async {
    try {
      bool result = await NIP46StatusNotifier.remoteSignerTips(Localized.text('ox_login.wait_link_service'));
      if (!result) return;
      
      String loginQRCodeUrl = AccountNIP46.createNostrConnectURI(relays:['ws://127.0.0.1:8081']);
      final appScheme = '${CommonConstant.APP_SCHEME}://';
      final uri = Uri.tryParse('aegis://${Uri.encodeComponent("${loginQRCodeUrl}&scheme=${appScheme}")}');
      await _launchAppOrSafari(uri!);
      
      // Use LoginManager for NostrConnect login
      await LoginManager.instance.loginWithNostrConnect(loginQRCodeUrl);
    } catch (e) {
      debugPrint('NostrAegis login failed: $e');
      if (mounted) {
        CommonToast.instance.show(context, 'Login failed: ${e.toString()}');
      }
    }
  }

  Future<void> _launchAppOrSafari(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final Uri fallbackUri = Uri.parse('https://testflight.apple.com/join/DUzVMDMK');
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    }
  }

  void _loginWithAmber() async {
    try {
      // Use LoginManager for Amber login
      await LoginManager.instance.loginWithAmber();
    } catch (e) {
      debugPrint('Amber login failed: $e');
      if (mounted) {
        CommonToast.instance.show(context, 'Login failed: ${e.toString()}');
      }
    }
  }

  void _serviceWebView() {
    OXModuleService.invoke('ox_common', 'gotoWebView', [context, 'https://www.0xchat.com/protocols/0xchat_terms_of_use.html', null, null, null, null]);
  }

  void _privacyPolicyWebView() {
    OXModuleService.invoke('ox_common', 'gotoWebView', [context, 'https://www.0xchat.com/protocols/0xchat_privacy_policy.html', null, null, null, null]);
  }
}
