import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/circle_join_utils.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/purchase/purchase_manager.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_usercenter/page/settings/about_xchat_page.dart';
import 'package:ox_usercenter/page/settings/notification_settings_page.dart';
import 'package:ox_usercenter/page/settings/advanced_settings_page.dart';
import 'package:chatcore/chat-core.dart';

import 'circle_detail_page.dart';
import 'profile_settings_page.dart';
import 'settings_detail_page.dart';
import 'qr_code_display_page.dart';
import '../../utils/invite_link_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_login/page/circle_selection_page.dart' show CircleSelectionPage;

class SettingSlider extends StatefulWidget {
  const SettingSlider({super.key});

  @override
  State<StatefulWidget> createState() => SettingSliderState();
}

class SettingSliderState extends State<SettingSlider> {

  String get title => Localized.text('ox_usercenter.str_settings');
  double get circleIconRadius => 12.px; // Match ListViewIcon size (24.px diameter)
  bool get _hasCircle => LoginManager.instance.currentCircle != null;

  late LoginUserNotifier userNotifier;
  bool _isPaidRelay = false;

  @override
  void initState() {
    super.initState();

    prepareData();
  }

  void prepareData() {
    userNotifier = LoginUserNotifier.instance;
    _checkPaidRelayAndAdmin();
  }

  /// Check if current circle is paid relay
  Future<void> _checkPaidRelayAndAdmin() async {
    try {
      final circle = LoginManager.instance.currentCircle;
      _isPaidRelay = circle != null && CircleApi.isPaidRelay(circle.relayUrl);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error checking paid relay: $e');
      _isPaidRelay = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  List<SectionListViewItem> pageData() {
    // Build first section items
    List<ListViewItem> firstSectionItems = [
      CustomItemModel(
        customWidgetBuilder: buildUserInfoWidget,
      ),
    ];
    
    // // Only add circle settings when user has a circle
    // if (hasCircle) {
    //   firstSectionItems.add(
    //     LabelItemModel(
    //       icon: ListViewIcon(iconName: 'icon_setting_circles.png', package: 'ox_usercenter'),
    //       title: Localized.text('ox_usercenter.circle_settings'),
    //       onTap: circleItemOnTap,
    //     ),
    //   );
    // }
    
    // Build circles section
    final account = LoginManager.instance.currentState.account;
    final circles = account?.circles ?? [];
    final currentCircle = LoginManager.instance.currentCircle;
    
    List<SectionListViewItem> sections = [
      SectionListViewItem(data: firstSectionItems),
    ];
    
    // Add CIRCLES section if there are any circles
    if (circles.isNotEmpty) {
      // Sort circles so that the selected one appears first
      final sortedCircles = List<Circle>.from(circles);
      if (currentCircle != null) {
        sortedCircles.sort((a, b) {
          final aIsSelected = a.id == currentCircle.id;
          final bIsSelected = b.id == currentCircle.id;
          if (aIsSelected && !bIsSelected) return -1;
          if (!aIsSelected && bIsSelected) return 1;
          return 0;
        });
      }
      final circleItems = sortedCircles.map((circle) => _buildCircleItem(circle, currentCircle)).toList();
      
      // Add "Add a Circle" button item
      circleItems.add(
        CustomItemModel(
          customWidgetBuilder: buildAddCircleButton,
        ),
      );
      
      sections.add(
        SectionListViewItem(
          headerWidget: _buildCirclesSectionHeader(),
          additionalDividerMargin: circleIconRadius * 2 + CLLayout.horizontalPadding - 2,
          data: circleItems,
        ),
      );
    } else {
      // If no circles, show add circle button in a separate section
      sections.add(
        SectionListViewItem(
          headerWidget: _buildCirclesSectionHeader(),
          data: [
            CustomItemModel(
              customWidgetBuilder: buildAddCircleButton,
            ),
          ],
        ),
      );
    }
    
    // Add PREFERENCES section (Preferences, Notifications, Advanced)
    sections.add(
      SectionListViewItem(
        data: [
          LabelItemModel(
            icon: ListViewIcon(iconName: 'icon_setting_theme.png', package: 'ox_usercenter'),
            title: Localized.text('ox_usercenter.preferences'),
            onTap: settingsItemOnTap,
          ),
          LabelItemModel(
            icon: ListViewIcon(iconName: 'icon_setting_notification.png', package: 'ox_usercenter'),
            title: Localized.text('ox_usercenter.notification'),
            onTap: notificationItemOnTap,
          ),
          LabelItemModel(
            icon: ListViewIcon.data(CupertinoIcons.gear_alt),
            title: Localized.text('ox_usercenter.advanced_settings'),
            onTap: advancedItemOnTap,
          ),
        ],
      ),
    );
    
    // Add Restore Purchases and HELP section
    sections.add(
      SectionListViewItem(
        data: [
          LabelItemModel(
            icon: ListViewIcon.data(CupertinoIcons.arrow_2_circlepath),
            title: Localized.text('ox_usercenter.restore_purchases'),
            onTap: _restorePurchasesOnTap,
          ),
          LabelItemModel(
            icon: ListViewIcon.data(CupertinoIcons.info),
            title: Localized.text('ox_usercenter.about_xchat'),
            onTap: aboutXChatItemOnTap,
          ),
        ],
      ),
    );
    
    if (!_hasCircle) {
      sections.add(
        SectionListViewItem.button(
          text: Localized.text('ox_usercenter.Logout'),
          onTap: _confirmLogout,
          type: ButtonType.destructive,
        ),
      );
    }

    return sections;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: PlatformStyle.isUseMaterial ? null : CLAppBar(title: title),
      isSectionListPage: true,
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return ValueListenableBuilder(
      valueListenable: LoginManager.instance.state$,
      builder: (context, loginState, _) {
        // Rebuild data when circle state changes
        return CLSectionListView(
          items: pageData(),
          footer: _hasCircle ? null : CLButton.text(
            text: Localized.text('ox_usercenter.delete_account'),
            color: ColorToken.error.of(context),
            onTap: _confirmDeleteAccount,
          ),
        );
      },
    );
  }

  Widget _buildCirclesSectionHeader() {
    final title = Localized.text('ox_common.circles').toUpperCase();
    Widget widget = CLText.titleSmall(title);
    if (PlatformStyle.isUseMaterial) {
      widget = Padding(
        padding: EdgeInsets.only(
          left: 20.px,
          top: 16.px,
        ),
        child: widget,
      );
    }
    return widget;
  }


  ListViewItem _buildCircleItem(Circle circle, Circle? currentCircle) {
    return CustomItemModel(
      customWidgetBuilder: (context) => _buildCircleItemWidget(context, circle, currentCircle),
    );
  }

  Widget _buildCircleItemWidget(BuildContext context, Circle circle, Circle? currentCircle) {
    final isSelected = circle.id == currentCircle?.id;
    
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _onCircleTap(circle),
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: CLLayout.horizontalPadding,
          vertical: 12.px,
        ),
        child: Row(
          children: [
            // Circle avatar
            CircleAvatar(
              radius: circleIconRadius,
              backgroundColor: isSelected 
                ? ColorToken.primaryContainer.of(context)
                : ColorToken.surfaceContainer.of(context),
              child: Text(
                circle.name.isNotEmpty ? circle.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isSelected
                    ? ColorToken.onPrimaryContainer.of(context)
                    : ColorToken.onSurfaceVariant.of(context),
                  fontSize: 16.px,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 12.px),
            // Circle name and relay URL
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CLText.bodyLarge(
                    circle.name,
                    isBold: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (circle.type != CircleType.bitchat)
                    CLText.bodyMedium(
                      circle.relayUrl,
                      colorToken: ColorToken.onSurfaceVariant,
                    ),
                ],
              ),
            ),
            // Selected indicator and settings icon
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Padding(
                    padding: EdgeInsets.only(right: 8.px),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: ColorToken.primary.of(context),
                      size: 24.px,
                    ),
                  ),
                if (isSelected)
                  GestureDetector(
                    onTap: () => _onCircleSettingsTap(circle),
                    child: Icon(
                      CupertinoIcons.gear,
                      color: ColorToken.onSurfaceVariant.of(context),
                      size: 20.px,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddCircleButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: addCircleItemOnTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: CLLayout.horizontalPadding,
          vertical: 12.px,
        ),
        child: Row(
          children: [
            Container(
              width: 24.px,
              height: 24.px,
              decoration: BoxDecoration(
                // color: ColorToken.primaryContainer.of(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.add_circled,
                color: ColorToken.onPrimaryContainer.of(context),
                size: 24.px,
              ),
            ),
            SizedBox(width: 12.px),
            Expanded(
              child: CLText.bodyLarge(
                Localized.text('ox_home.add_circle'),
                colorToken: ColorToken.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserInfoWidget(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LoginManager.instance.state$,
      builder: (context, loginState, _) {
        final circle = loginState.currentCircle;
        final hasCircle = circle != null;
        
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: profileItemOnTap,
          child: Container(
            height: 72.px,
            margin: EdgeInsets.symmetric(vertical: 12.px),
            child: Row(
              children: [
                // Avatar area
                Container(
                  width: 60.px,
                  height: 60.px,
                  margin: EdgeInsets.symmetric(horizontal: CLLayout.horizontalPadding),
                  child: hasCircle
                    ? ValueListenableBuilder(
                        valueListenable: userNotifier.userInfo$,
                        builder: (context, userInfo, _) {
                          return OXUserAvatar(
                            user: userInfo,
                            size: 60.px,
                          );
                        }
                      )
                    : CircleAvatar(
                        radius: 30.px,
                        backgroundColor: ColorToken.surfaceContainer.of(context),
                        child: Icon(
                          CupertinoIcons.person,
                          size: 30.px,
                          color: ColorToken.onSurfaceVariant.of(context),
                        ),
                      ),
                ),
                // Content area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: hasCircle
                      ? [
                          // Show actual user info when logged in circle
                          ValueListenableBuilder(
                            valueListenable: userNotifier.name$,
                            builder: (context, name, _) {
                              return CLText.bodyLarge(name);
                            }
                          ),
                          SizedBox(height: 4.px),
                          ValueListenableBuilder(
                            valueListenable: userNotifier.encodedPubkey$,
                            builder: (context, encodedPubkey, _) {
                              return CLText.bodyMedium(encodedPubkey.truncate(PlatformStyle.isUseMaterial ? 20 : 25));
                            }
                          ),
                        ]
                      : [
                          // Show guide info when no circle
                          CLText.bodyLarge(
                            Localized.text('ox_usercenter.profile'),
                          ),
                          SizedBox(height: 4.px),
                          CLText.bodyMedium(
                            Localized.text('ox_home.join_or_create_circle_now'),
                          ),
                        ],
                  ),
                ),
                // Trailing - QR code button
                // For paid circle: do not show
                // For regular relay: always show
                if (!_isPaidRelay)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: GestureDetector(
                      onTap: inviteItemOnTap,
                      child: Icon(
                        CupertinoIcons.qrcode,
                        color: ColorToken.onSurfaceVariant.of(context),
                        size: 24.px,
                      ),
                    ),
                  ),
                // Arrow indicator for navigation - only show for paid relay
                if (_isPaidRelay)
                  Padding(
                    padding: EdgeInsets.only(right: CLLayout.horizontalPadding),
                    child: Icon(
                      PlatformStyle.isUseMaterial
                          ? Icons.chevron_right
                          : CupertinoIcons.chevron_right,
                      color: ColorToken.onSurfaceVariant.of(context),
                      size: 20.px,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onCircleTap(Circle circle) async {
    final currentCircle = LoginManager.instance.currentCircle;
    if (currentCircle?.id == circle.id) {
      // Already selected, do nothing
      return;
    }

    // Show confirmation dialog
    final shouldSwitch = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_usercenter.switch_circle_confirm_title'),
      content: Localized.text('ox_usercenter.switch_circle_confirm_content'),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_common.confirm'),
          value: true,
        ),
      ],
    );

    if (!mounted || shouldSwitch != true) {
      return;
    }

    OXLoading.show();
    try {
      final failure = await LoginManager.instance.switchToCircle(circle);
      OXLoading.dismiss();

      if (failure != null) {
        CommonToast.instance.show(context, failure.message);
      } else {
        // Switch successful, close settings page after a short delay
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          OXNavigator.pop(context);
        }
      }
    } catch (e) {
      OXLoading.dismiss();
      CommonToast.instance.show(context, e.toString());
    }
  }

  void _onCircleSettingsTap(Circle circle) {
    OXNavigator.pushPage(context, (_) => CircleDetailPage(
      previousPageTitle: title,
      circle: circle,
    ));
  }

  void addCircleItemOnTap() {
    OXNavigator.pushPage(
      context,
      (context) => const CircleSelectionPage(controller: null),
    );
  }

  void profileItemOnTap() {
    final circle = LoginManager.instance.currentCircle;
    if (circle == null) {
      CircleJoinUtils.showJoinCircleGuideDialog(context: OXNavigator.rootContext);
      return;
    }
    
    OXNavigator.pushPage(context, (_) => ProfileSettingsPage(previousPageTitle: title,));
  }

  void inviteItemOnTap() {
    final circle = LoginManager.instance.currentCircle;
    if (circle == null) {
      CircleJoinUtils.showJoinCircleGuideDialog(context: OXNavigator.rootContext);
      return;
    }
    
    // For paid relay, show circle invite QR code
    if (_isPaidRelay) {
      OXNavigator.pushPage(
        context, 
        (context) => QRCodeDisplayPage(
          previousPageTitle: title,
          inviteType: InviteType.circle,
          circle: circle,
        ),
      );
    } else {
      // For regular relay, show keypackage invite QR code
      OXNavigator.pushPage(
        context, 
        (context) => QRCodeDisplayPage(previousPageTitle: title),
      );
    }
  }

  void settingsItemOnTap() {
    OXNavigator.pushPage(context, (_) => SettingsDetailPage(previousPageTitle: title,));
  }

  void notificationItemOnTap() {
    OXNavigator.pushPage(context, (_) => NotificationSettingsPage(previousPageTitle: title,));
  }

  void advancedItemOnTap() {
    OXNavigator.pushPage(context, (_) => AdvancedSettingsPage(previousPageTitle: title,));
  }

  Future<void> _restorePurchasesOnTap() async {
    try {
      OXLoading.show(status: Localized.text('ox_usercenter.restoring_purchases'));
      final results = await PurchaseManager.instance.restorePurchases();
      if (!mounted) return;
      await OXLoading.dismiss();

      final successes = results.where((r) => r.success).toList();
      final failures = results.where((r) => !r.success).toList();
      final realFailures = failures.where((r) {
        final msg = (r.errorMessage ?? '').trim();
        if (msg.isEmpty) return false;
        return msg != 'No purchase to restore for this product';
      }).toList();

      var message = '';
      if (successes.isNotEmpty) {
        message = Localized.text('ox_usercenter.restore_purchases_success');
      } else if (realFailures.isNotEmpty) {
        message = realFailures.first.errorMessage ?? 'Failed to restore purchases. Please try again.';
      } else if (results.any((r) => r.isAlreadyRestored)) {
        message = Localized.text('ox_usercenter.restore_purchases_already_restored');
      } else {
        message = 'No purchases found to restore';
      }

      await CLAlertDialog.show<bool>(
        context: context,
        content: message,
        actions: [CLAlertAction.ok()],
      );
    } catch (e) {
      if (mounted) {
        await OXLoading.dismiss();
        CommonToast.instance.show(context, 'Failed to restore purchases: $e');
      }
    } finally {
      await OXLoading.dismiss();
    }
  }

  void aboutXChatItemOnTap() {
    OXNavigator.pushPage(context, (_) => AboutXChatPage(previousPageTitle: title,));
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
