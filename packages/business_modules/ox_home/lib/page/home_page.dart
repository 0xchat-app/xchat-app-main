import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/widgets/common_hint_dialog.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_login/page/login_page.dart';
import 'package:ox_theme/ox_theme.dart';

import 'home_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    signerCheck();

    final style = themeManager.themeStyle.toOverlayStyle;
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoginState>(
      valueListenable: LoginManager.instance.state$,
      builder: (context, loginState, child) {
        final loginAccount = loginState.account;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: loginAccount != null
              ? const HomeScaffold()
              : const LoginPage(),
        );
      },
    );
  }

  void signerCheck() async {
    final loginState = LoginManager.instance.state$.value;
    if (!loginState.isLoggedIn) return;
    
    final currentPubkey = loginState.account?.pubkey ?? '';
    final bool? localIsLoginAmber = await OXCacheManager.defaultOXCacheManager
        .getForeverData('$currentPubkey${StorageKeyTool.KEY_IS_LOGIN_AMBER}');
    
    if (localIsLoginAmber != null && localIsLoginAmber) {
      bool isInstalled = await CoreMethodChannel.isInstalledAmber();
      if (mounted && !isInstalled) {
        String showTitle = 'ox_common.open_singer_app_error_title';
        String showContent = 'ox_common.open_singer_app_error_content';
        
        await LoginManager.instance.logout();
        
        if (mounted) {
          OXCommonHintDialog.show(
            context,
            title: Localized.text(showTitle),
            content: Localized.text(showContent),
            actionList: [
              OXCommonHintAction.sure(
                  text: Localized.text('ox_common.confirm'),
                  onTap: () {
                    OXNavigator.pop(context);
                  }),
            ],
          );
        }
      }
    }
  }
}
