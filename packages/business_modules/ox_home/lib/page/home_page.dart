import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:chatcore/src/account/model/userDB_isar.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_chat/page/session/chat_message_page.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/widgets/common_hint_dialog.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_login/page/login_page.dart';
import 'package:ox_theme/ox_theme.dart';

import '../widgets/session_list_data_controller.dart';
import '../widgets/session_list_widget.dart';
import '../widgets/session_view_model.dart';
import 'home_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.ownerPubkey,
  }) : super(key: key);

  final String ownerPubkey;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with OXUserInfoObserver {
  late SessionListDataController sessionDataController;

  @override
  void initState() {
    super.initState();
    Localized.addLocaleChangedCallback(onLocaleChange);
    signerCheck();

    sessionDataController = SessionListDataController(widget.ownerPubkey);
    sessionDataController.initialized();

    final style = themeManager.themeStyle.toOverlayStyle;
    SystemChrome.setSystemUIOverlayStyle(style);
    OXUserInfoManager.sharedInstance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didLoginSuccess(UserDBISAR? userInfo) {
    setState(() {});
  }

  @override
  void didLogout() {
    setState(() {});
  }

  @override
  void didSwitchUser(UserDBISAR? userInfo) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = OXUserInfoManager.sharedInstance.isLogin;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child:
          isLogin ? HomeScaffold(body: buildSessionList()) : const LoginPage(),
    );
  }

  Widget buildSessionList() {
    return SessionListWidget(
      controller: sessionDataController,
      itemOnTap: sessionItemOnTap,
    );
  }

  void signerCheck() async {
    final bool? localIsLoginAmber = await OXCacheManager.defaultOXCacheManager
        .getForeverData(
            '${OXUserInfoManager.sharedInstance.currentUserInfo?.pubKey ?? ''}${StorageKeyTool.KEY_IS_LOGIN_AMBER}');
    if (localIsLoginAmber != null && localIsLoginAmber) {
      bool isInstalled = await CoreMethodChannel.isInstalledAmber();
      if (mounted &&
          (!isInstalled ||
              OXUserInfoManager.sharedInstance.signatureVerifyFailed)) {
        String showTitle = '';
        String showContent = '';
        if (!isInstalled) {
          showTitle = 'ox_common.open_singer_app_error_title';
          showContent = 'ox_common.open_singer_app_error_content';
        } else if (OXUserInfoManager.sharedInstance.signatureVerifyFailed) {
          showTitle = 'ox_common.tips';
          showContent = 'ox_common.str_singer_app_verify_failed_hint';
        }
        OXUserInfoManager.sharedInstance.resetData();
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

  onLocaleChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void sessionItemOnTap(SessionListViewModel item) {
    final session = item.sessionModel;
    final unreadMessageCount = session.unreadCount;

    ChatMessagePage.open(
      context: context,
      communityItem: session,
      unreadMessageCount: unreadMessageCount,
    ).then((_) {
      item.rebuild();
    });

    session.unreadCount = 0;
    OXChatBinding.sharedInstance.updateChatSession(
      session.chatId,
      unreadCount: 0,
    );

    item.rebuild();
  }
}
