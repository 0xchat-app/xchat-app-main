
import 'package:flutter/widgets.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';

class NicknameSettingsPage extends StatelessWidget {
  NicknameSettingsPage({
    super.key,
    this.previousPageTitle,
  });

  final TextEditingController controller = TextEditingController();
  final String? previousPageTitle;

  @override
  Widget build(BuildContext context) {
    final nickname = OXUserInfoManager.sharedInstance.currentUserInfo?.name ?? '';
    controller.text = nickname;
    controller.selection = TextSelection.collapsed(offset: nickname.length);
    return CLScaffold(
      appBar: CLAppBar(
        title: 'Nickname',
        previousPageTitle: previousPageTitle,
        autoTrailing: false,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: 16.px,
            vertical: 12.px,
          ),
          children: [
            CLTextField(
              controller: controller,
              autofocus: true,
              placeholder: 'Nickname',
            ),
            SizedBox(height: 20.px,),
            CLButton.filled(
              padding: EdgeInsets.symmetric(vertical: 12.px),
              text: Localized.text('ox_common.save'),
              onTap: () => buttonHandler(context),
            )
          ],
        ),
      ),
    );
  }

  void buttonHandler(BuildContext context) async {
    final user = OXUserInfoManager.sharedInstance.currentUserInfo;

    if (user == null) {
      CommonToast.instance.show(context, 'Current user info is null.');
      return;
    }

    final newNickname = controller.text;
    if (newNickname.isEmpty) {
      CommonToast.instance.show(context, Localized.text('ox_usercenter.enter_username_tips'));
      return;
    }

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