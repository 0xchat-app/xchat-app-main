import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
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
  bool _isRefreshing = false;

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
    
    // Show confirmation dialog
    final shouldRefreshFromSpecificRelay = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_usercenter.refresh_profile'),
      content: Localized.text('ox_usercenter.refresh_profile_from_relay_confirm'),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_usercenter.confirm'),
          value: true,
        ),
      ],
    );

    if (shouldRefreshFromSpecificRelay != true) return;
    
    // Check if widget is still mounted before calling setState
    if (!mounted) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      final currentUser = LoginManager.instance.currentState.account;
      if (currentUser == null) {
        if (!mounted) return;
        CommonToast.instance.show(context, Localized.text('ox_usercenter.user_not_found'));
        return;
      }

      // Show loading indicator
      OXLoading.show();
      
      // Connect to specific relay as temp type
      const specificRelay = 'wss://relay.nostr.band';
      final connectSuccess = await Connect.sharedInstance.connectRelays([specificRelay], relayKind: RelayKind.temp);
      
      if (!connectSuccess) {
        if (!mounted) return;
        CommonToast.instance.show(context, '${Localized.text('ox_usercenter.relay_connection_failed')}: $specificRelay');
        return;
      }
      
      // Reload profile from specific relay
      await Account.sharedInstance.reloadProfileFromRelay(currentUser.pubkey, relays: [specificRelay]);
      
      // Close temp relay connection after use
      await Connect.sharedInstance.closeTempConnects([specificRelay]);
      
      // Dismiss loading and show success message
      OXLoading.dismiss();
      if (!mounted) return;
      CommonToast.instance.show(context, Localized.text('ox_usercenter.refresh_profile_success'));
      
    } catch (e) {
      OXLoading.dismiss();
      if (!mounted) return;
      CommonToast.instance.show(context, '${Localized.text('ox_usercenter.refresh_profile_failed')}: $e');
    } finally {
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }
}
