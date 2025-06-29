import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ox_common/business_interface/ox_usercenter/interface.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:ox_usercenter/model/request_verify_dns.dart';
import 'package:ox_usercenter/page/settings/avatar_preview_page.dart';
import 'package:ox_usercenter/page/settings/qr_code_display_page.dart';
import 'package:ox_usercenter/page/set_up/relay_detail_page.dart';
import 'package:ox_usercenter/page/set_up/relays_for_login_page.dart';
import 'package:ox_usercenter/page/settings/settings_slider.dart';
import 'package:chatcore/chat-core.dart';

class OXUserCenter extends OXFlutterModule {

  static String get loginPageId => "usercenter_page";

  @override
  Future<void> setup() async {
    await super.setup();
    // ChatBinding.instance.setup();
  }

  @override
  // TODO: implement moduleName
  String get moduleName => OXUserCenterInterface.moduleName;

  @override
  Map<String, Function> get interfaces => {
        'requestVerifyDNS': requestVerifyDNS,
        'settingSliderBuilder': settingSliderBuilder
      };

  @override
  Future<T?>? navigateToPage<T>(BuildContext context, String pageName, Map<String, dynamic>? params) {
    switch (pageName) {
      case 'AvatarPreviewPage':
        UserDBISAR? userDB = params?['userDB'];
        return OXNavigator.pushPage(context, (context) => AvatarPreviewPage(userDB: userDB),);
      case 'QRCodeDisplayPage':
        String? previousPageTitle = params?['previousPageTitle'];
        UserDBISAR? otherUser = params?['otherUser'];
        return OXNavigator.pushPage(context, (context) => QRCodeDisplayPage(previousPageTitle: previousPageTitle, otherUser: otherUser),);
      case 'RelayDetailPage':
        final relayName = params?['relayName'];
        return OXNavigator.pushPage(context, (context) => RelayDetailPage(relayURL: relayName,));
      case 'RelaysForLoginPage':
        return OXNavigator.pushPage(context, (context) => RelaysForLoginPage(relayUrls: params?['relayUrls'],));
    }
    return null;
  }

  Future<Map<String, dynamic>?> requestVerifyDNS(Map<String, dynamic>? params, BuildContext? context, bool? showErrorToast, bool? showLoading) async {
    return await registerNip05(context: context, params: params, showLoading: showLoading, showErrorToast: showErrorToast);
  }

  Widget settingSliderBuilder(BuildContext context) {
    return const SettingSlider();
  }
}
