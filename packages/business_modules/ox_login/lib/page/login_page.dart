import 'dart:io';

import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/const/common_constant.dart';
// ox_common
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/nip46_status_notifier.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_localizable/ox_localizable.dart';
// ox_login
import 'package:ox_login/page/account_key_login_page.dart';
import 'package:ox_login/page/create_account_page.dart';
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
              title: Localized.text('ox_login.carousel_title_1'),
              text: Localized.text('ox_login.carousel_text_1'),
            ),
            BannerItem(
              image: CommonImage(
                iconName: 'image_guide_2.png',
                size: 280.px,
                package: 'ox_login',
                isPlatformStyle: true,
              ),
              title: Localized.text('ox_login.carousel_title_2'),
              text: Localized.text('ox_login.carousel_text_2'),
            ),
            BannerItem(
              image: CommonImage(
                iconName: 'image_guide_3.png',
                size: 280.px,
                package: 'ox_login',
                isPlatformStyle: true,
              ),
              title: Localized.text('ox_login.carousel_title_3'),
              text: Localized.text('ox_login.carousel_text_3'),
            ),
            BannerItem(
              image: CommonImage(
                iconName: 'image_guide_4.png',
                size: 280.px,
                package: 'ox_login',
                isPlatformStyle: true,
              ),
              title: Localized.text('ox_login.carousel_title_4'),
              text: Localized.text('ox_login.carousel_text_4'),
            ),
          ],
          height: 460.py,
          interval: const Duration(seconds: 3),
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
                color: ColorToken.secondaryContainer.of(context),
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
}
