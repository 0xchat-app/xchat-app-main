
import 'package:flutter/widgets.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_usercenter/page/settings/single_setting_page.dart';

class NicknameSettingsPage extends StatelessWidget {
  NicknameSettingsPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  Widget build(BuildContext context) {
    return SingleSettingPage(
      previousPageTitle: previousPageTitle,
      title: 'Nickname',
      initialValue: OXUserInfoManager.sharedInstance.currentUserInfo?.name ?? '',
      saveAction: buttonHandler,
    );
  }

  void buttonHandler(BuildContext context, String value) async {
    final user = OXUserInfoManager.sharedInstance.currentUserInfo;

    if (user == null) {
      CommonToast.instance.show(context, 'Current user info is null.');
      return;
    }

    final newNickname = value;
    if (newNickname.isEmpty) {
      CommonToast.instance.show(context, Localized.text('ox_usercenter.enter_username_tips'));
      return;
    }
    if (OXUserInfoManager.sharedInstance.currentUserInfo?.name == newNickname) return;

    user.name = newNickname;

    final newUser = await Account.sharedInstance.updateProfile(user);
    await OXLoading.dismiss();
    if (newUser == null) {
      CommonToast.instance.show(context, 'Update Nickname Failed.');
    } else {
      OXUserInfoManager.sharedInstance.updateUserInfo(newUser);
      OXNavigator.pop(context);
    }
  }
}