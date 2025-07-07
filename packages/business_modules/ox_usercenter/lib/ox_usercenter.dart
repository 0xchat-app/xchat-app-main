import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ox_common/business_interface/ox_usercenter/interface.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:ox_usercenter/page/settings/avatar_display_page.dart';
import 'package:ox_usercenter/page/settings/qr_code_display_page.dart';
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
        'settingSliderBuilder': settingSliderBuilder
      };

  @override
  Future<T?>? navigateToPage<T>(BuildContext context, String pageName, Map<String, dynamic>? params) {
    switch (pageName) {
      case 'AvatarDisplayPage':
        String? avatarUrl = params?['avatarUrl'];
        bool showEditButton = params?['showEditButton'] ?? false;
        String? heroTag = params?['heroTag'];
        return OXNavigator.pushPage(context, (context) => AvatarDisplayPage(avatarUrl: avatarUrl, showEditButton: showEditButton, heroTag: heroTag),);
      case 'QRCodeDisplayPage':
        String? previousPageTitle = params?['previousPageTitle'];
        UserDBISAR? otherUser = params?['otherUser'];
        return OXNavigator.pushPage(context, (context) => QRCodeDisplayPage(previousPageTitle: previousPageTitle, otherUser: otherUser),);
    }
    return null;
  }

  Widget settingSliderBuilder(BuildContext context) {
    return const SettingSlider();
  }
}
