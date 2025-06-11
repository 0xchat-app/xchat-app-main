
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/upload/file_type.dart';
import 'package:ox_common/upload/upload_utils.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';

import '../../widget/select_asset_dialog.dart';
import '../set_up/avatar_preview_page.dart';
import 'bio_settings_page.dart';
import 'nickname_settings_page.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {

  late LoginUserNotifier userNotifier;

  @override
  void initState() {
    super.initState();
    userNotifier = LoginUserNotifier.instance;
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: 'Profile',
        previousPageTitle: widget.previousPageTitle,
      ),
      isSectionListPage: true,
      body: CLSectionListView(
        header: buildHeaderWidget(),
        items: [
          SectionListViewItem(
            data: [
              LabelItemModel(
                icon: ListViewIcon(
                  iconName: 'icon_setting_nickname.png',
                  package: 'ox_usercenter',
                ),
                title: 'Nickname',
                value$: userNotifier.name$,
                onTap: nickNameOnTap,
              ),
              LabelItemModel(
                icon: ListViewIcon(
                  iconName: 'icon_setting_bio.png',
                  package: 'ox_usercenter',
                ),
                title: 'Bio',
                value$: userNotifier.bio$,
                onTap: bioOnTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHeaderWidget() {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: userNotifier.avatarUrl$,
          builder: (context, avatarUrl, _) {
            return OXUserAvatar(
              imageUrl: avatarUrl,
              size: 80.px,
              onTap: editPhotoOnTap,
            );
          },
        ).setPaddingOnly(top: 8.px),
        CLButton.tonal(
          child: CLText.labelLarge('Edit Photo'),
          height: 30.px,
          width: 90.px,
          padding: EdgeInsets.symmetric(
            horizontal: 12.px,
            vertical: 5.px,
          ),
          onTap: editPhotoOnTap,
        ).setPaddingOnly(top: 12.px),
      ],
    );
  }

  void editPhotoOnTap() async {
    final result = await OXNavigator.pushPage(context, (context) =>
      AvatarPreviewPage(
        userDB: OXUserInfoManager.sharedInstance.currentUserInfo,
      ),
    );

    Map? selectAssetDialog = result as Map?;
    if(selectAssetDialog == null) return;

    SelectAssetAction action = selectAssetDialog['action'];
    File? imgFile = selectAssetDialog['result'];
    if (action == SelectAssetAction.Remove) {
      updateUserAvatar(null);
    } else if (imgFile != null) {
      updateUserAvatar(imgFile);
    }
  }

  void nickNameOnTap() {
    OXNavigator.pushPage(context, (_) => const NicknameSettingsPage());
  }

  void bioOnTap() {
    OXNavigator.pushPage(context, (_) => BioSettingsPage());
  }

  void updateUserAvatar(File? avatarFile) async {
    String avatarUrl = '';
    final user = OXUserInfoManager.sharedInstance.currentUserInfo;

    if (user == null) {
      CommonToast.instance.show(context, 'Current user info is null.');
      return;
    }

    OXLoading.show();

    if (avatarFile != null) {
      UploadResult result  = await UploadUtils.uploadFile(
        fileType: FileType.image,
        file: avatarFile,
        filename: 'avatar_${userNotifier.encodedPubkey$.value}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      if (!result.isSuccess || result.url.isEmpty) {
        await OXLoading.dismiss();
        String errorMsg = result.errorMsg ?? 'unknown';
        CommonToast.instance.show(context, 'Upload Failed: $errorMsg.');
        return;
      }

      avatarUrl = result.url;
    }

    user.picture = avatarUrl;

    final newUser = await Account.sharedInstance.updateProfile(user);
    await OXLoading.dismiss();
    if (newUser == null) {
      CommonToast.instance.show(context, 'Update Avatar Failed.');
    } else {
      CommonToast.instance.show(context, 'Update Avatar Success.');
      OXUserInfoManager.sharedInstance.updateUserInfo(newUser);
    }
  }
}
