import 'package:flutter/widgets.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/business_interface/ox_chat/interface.dart';
import 'package:ox_common/business_interface/ox_usercenter/interface.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/widgets/common_hint_dialog.dart';
import 'package:ox_localizable/ox_localizable.dart';

class HomeTabBarPage extends StatefulWidget {
  const HomeTabBarPage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeTabBarPage> createState() => _HomeTabBarPageState();
}

class _HomeTabBarPageState extends State<HomeTabBarPage> {

  SidebarScaffoldController sidebarController = SidebarScaffoldController();

  @override
  void initState() {
    super.initState();
    Localized.addLocaleChangedCallback(onLocaleChange);
    signerCheck();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      controller: sidebarController,
      sidebar: OXUserCenterInterface.settingSlider(),
      body: OXChatInterface.chatSessionListPageWidget(
        context,
      ),
    );
  }

  Widget buildSessionList() {
    return OXChatInterface.chatSessionListPageWidget(
      context,
    );
  }

  void signerCheck() async {
    final bool? localIsLoginAmber = await OXCacheManager.defaultOXCacheManager.getForeverData('${OXUserInfoManager.sharedInstance.currentUserInfo?.pubKey??''}${StorageKeyTool.KEY_IS_LOGIN_AMBER}');
    if (localIsLoginAmber != null && localIsLoginAmber) {
      bool isInstalled = await CoreMethodChannel.isInstalledAmber();
      if (mounted && (!isInstalled || OXUserInfoManager.sharedInstance.signatureVerifyFailed)){
        String showTitle = '';
        String showContent = '';
        if (!isInstalled) {
          showTitle = 'ox_common.open_singer_app_error_title';
          showContent = 'ox_common.open_singer_app_error_content';
        } else if (OXUserInfoManager.sharedInstance.signatureVerifyFailed){
          showTitle = 'ox_common.tips';
          showContent = 'ox_common.str_singer_app_verify_failed_hint';
        }
        OXUserInfoManager.sharedInstance.resetData();
        OXCommonHintDialog.show(
          context, title: Localized.text(showTitle), content: Localized.text(showContent),
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
}