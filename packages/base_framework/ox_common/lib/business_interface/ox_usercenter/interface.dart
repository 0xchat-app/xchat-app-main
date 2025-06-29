import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_module_service/ox_module_service.dart';

import 'zaps_detail_model.dart';

class OXUserCenterInterface {

  static const moduleName = 'ox_usercenter';

  static Widget settingSliderBuilder(BuildContext ctx) {
    return OXModuleService.invoke<Widget>(
      OXUserCenterInterface.moduleName,
      'settingSliderBuilder',
      [ctx],
    ) ?? const SizedBox();
  }

  static Future<T?>? pushQRCodeDisplayPage<T>(BuildContext context, {String? previousPageTitle, UserDBISAR? otherUser}) {
    return OXModuleService.pushPage<T>(
      context,
      moduleName,
      'QRCodeDisplayPage',
      {
        'previousPageTitle': previousPageTitle,
        'otherUser': otherUser,
      },
    );
  }
}