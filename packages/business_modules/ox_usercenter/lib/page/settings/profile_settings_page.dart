import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'avatar_display_page.dart';
import 'bio_settings_page.dart';
import 'nickname_settings_page.dart';
import 'qr_code_display_page.dart';

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
        actions: [
          CLButton.icon(
            isAppBarAction: true,
            child: const Icon(Icons.qr_code),
            onTap: showMyQRCode,
          ),
        ],
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
            return Hero(
              tag: 'profile_avatar_hero',
              child: OXUserAvatar(
                imageUrl: avatarUrl,
                size: 80.px,
                onTap: editPhotoOnTap,
              ),
            );
          },
        ).setPaddingOnly(top: 8.px),
        CLButton.tonal(
          child: CLText.labelLarge('Edit Photo'),
          height: 30.px,
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
    // Use the new avatar display page with static open method
    await AvatarDisplayPage.open(
      context,
      heroTag: 'profile_avatar_hero',
      avatarUrl: Account.sharedInstance.me?.picture,
      showEditButton: true,
    );
    
    // The page handles avatar updates internally, so we just refresh the UI
    setState(() {});
  }

  void nickNameOnTap() {
    OXNavigator.pushPage(context, (_) => const NicknameSettingsPage());
  }

  void bioOnTap() {
    OXNavigator.pushPage(context, (_) => BioSettingsPage());
  }

  void showMyQRCode() {
    OXNavigator.pushPage(
      context, 
      (context) => const QRCodeDisplayPage(previousPageTitle: 'Profile'),
    );
  }
}
