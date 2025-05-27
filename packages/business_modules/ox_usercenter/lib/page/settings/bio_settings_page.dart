
import 'package:flutter/widgets.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';

import 'single_setting_page.dart';

class BioSettingsPage extends StatelessWidget {
  BioSettingsPage({
    super.key,
    this.previousPageTitle,
  });

  final TextEditingController controller = TextEditingController();
  final String? previousPageTitle;

  @override
  Widget build(BuildContext context) {
    return SingleSettingPage(
      previousPageTitle: previousPageTitle,
      title: 'Bio',
      initialValue: OXUserInfoManager.sharedInstance.currentUserInfo?.about ?? '',
      saveAction: buttonHandler,
    );
  }

  void buttonHandler(BuildContext context, String value) async {
    final user = OXUserInfoManager.sharedInstance.currentUserInfo;

    if (user == null) {
      CommonToast.instance.show(context, 'Current user info is null.');
      return;
    }

    final newBio = value;
    if (OXUserInfoManager.sharedInstance.currentUserInfo?.about == newBio) return;

    user.about = newBio;

    final newUser = await Account.sharedInstance.updateProfile(user);
    await OXLoading.dismiss();
    if (newUser == null) {
      CommonToast.instance.show(context, 'Update Bio Failed.');
    } else {
      OXUserInfoManager.sharedInstance.updateUserInfo(newUser);
      OXNavigator.pop(context);
    }
  }
}