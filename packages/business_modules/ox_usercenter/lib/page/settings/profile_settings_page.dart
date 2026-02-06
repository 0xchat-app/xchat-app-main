import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/utils/profile_refresh_utils.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'avatar_display_page.dart';
import 'bio_settings_page.dart';
import 'nickname_settings_page.dart';
import 'keys_page.dart';

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
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    userNotifier = LoginUserNotifier.instance;
  }

  bool _isPaidRelay() {
    final circle = LoginManager.instance.currentCircle;
    return circle != null && CircleApi.isPaidRelay(circle.relayUrl);
  }

  @override
  Widget build(BuildContext context) {
    final isPaidRelay = _isPaidRelay();
    return CLScaffold(
      appBar: CLAppBar(
        title: 'Profile',
        previousPageTitle: widget.previousPageTitle,
        actions: [
          if (!isPaidRelay)
            CLButton.icon(
              icon: _isRefreshing ? Icons.refresh : Icons.refresh_outlined,
              onTap: _isRefreshing ? null : refreshProfile,
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
                overflow: TextOverflow.fade,
                onTap: bioOnTap,
              ),
            ],
          ),
          SectionListViewItem(
            data: [
              LabelItemModel(
                icon: ListViewIcon(iconName: 'icon_setting_security.png', package: 'ox_usercenter'),
                title: Localized.text('ox_usercenter.keys'),
                onTap: keysItemOnTap,
              ),
            ],
          ),
          SectionListViewItem.button(
            text: Localized.text('ox_usercenter.Logout'),
            onTap: logoutItemOnTap,
            type: ButtonType.destructive,
          ),
        ],
        footer: CLButton.text(
          text: Localized.text('ox_usercenter.delete_account'),
          color: ColorToken.error.of(context),
          onTap: deleteAccountItemOnTap,
        ),
      ),
    );
  }

  Widget buildHeaderWidget() {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: userNotifier.userInfo$,
          builder: (context, userInfo, _) {
            return Hero(
              tag: 'profile_avatar_hero',
              child: OXUserAvatar(
                user: userInfo,
                size: 80.px,
                onTap: editPhotoOnTap,
              ),
            );
          },
        ).setPaddingOnly(top: 8.px),
        CLButton.tonal(
          child: CLText.labelLarge(Localized.text('ox_common.edit_photo')),
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
    if (!mounted) return;
    // Use the new avatar display page with static open method
    await AvatarDisplayPage.open(
      context,
      heroTag: 'profile_avatar_hero',
      avatarUrl: Account.sharedInstance.me?.picture,
      showEditButton: true,
    );

    // The page handles avatar updates internally, so we just refresh the UI
    if (mounted) {
      setState(() {});
    }
  }

  void nickNameOnTap() {
    OXNavigator.pushPage(context, (_) => const NicknameSettingsPage());
  }

  void bioOnTap() {
    OXNavigator.pushPage(context, (_) => BioSettingsPage());
  }

  void refreshProfile() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await ProfileRefreshUtils.showProfileRefreshDialog(context);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void keysItemOnTap() {
    OXNavigator.pushPage(context, (_) => KeysPage(previousPageTitle: 'Profile',));
  }

  void logoutItemOnTap() async {
    await _confirmLogout();
  }

  void deleteAccountItemOnTap() async {
    await _confirmDeleteAccount();
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_usercenter.warn_title'),
      content: Localized.text('ox_usercenter.sign_out_dialog_content'),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_usercenter.Logout'),
          value: true,
          isDestructiveAction: true,
        ),
      ],
    );

    if (mounted && shouldLogout == true) {
      try {
        await LoginManager.instance.logoutAccount();
        OXNavigator.popToRoot(context);
      } catch (e) {
        CommonToast.instance.show(context, e.toString());
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_usercenter.delete_account_confirm_title'),
      content: Localized.text('ox_usercenter.delete_account_confirm_content'),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_usercenter.delete_account_confirm'),
          value: true,
          isDestructiveAction: true,
        ),
      ],
    );

    if (shouldDelete == true) {
      OXLoading.show();
      try {
        final success = await LoginManager.instance.deleteAccount();
        OXLoading.dismiss();
        
        if (success) {
          OXNavigator.popToRoot(context);
        } else {
          CommonToast.instance.show(context, Localized.text('ox_usercenter.delete_account_failed'));
        }
      } catch (e) {
        OXLoading.dismiss();
        CommonToast.instance.show(context, '${Localized.text('ox_usercenter.delete_account_failed')}: $e');
      }
    }
  }
}