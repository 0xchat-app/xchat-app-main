import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/utils/extension.dart';
import 'package:ox_common/utils/font_size_notifier.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_theme/ox_theme.dart';
import 'package:ox_usercenter/page/settings/language_settings_page.dart';
import 'package:ox_usercenter/page/settings/theme_settings_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'keys_page.dart';
import 'circle_detail_page.dart';
import 'font_size_settings_page.dart';
import 'profile_settings_page.dart';

class SettingSlider extends StatefulWidget {
  const SettingSlider({super.key});

  @override
  State<StatefulWidget> createState() => SettingSliderState();
}

class SettingSliderState extends State<SettingSlider> {

  String get title => Localized.text('ox_usercenter.str_settings');

  late ValueNotifier themeItemNty;
  late ValueNotifier languageItemNty;
  late ValueNotifier versionItemNty;
  late ValueNotifier textSizeItemNty;

  late LoginUserNotifier userNotifier;
  late List<SectionListViewItem> pageData;

  @override
  void initState() {
    super.initState();

    prepareData();

    languageItemNty.addListener(() {
      // Update label notifier when language changed.
      themeItemNty.value = themeManager.themeStyle.text;
      prepareLiteData();
    });
  }

  void prepareData() {
    prepareNotifier();
    prepareLiteData();
    userNotifier = LoginUserNotifier.instance;
  }

  void prepareNotifier() {
    themeItemNty = themeManager.styleNty.map((style) => style.text);
    languageItemNty = Localized.localized.localeTypeNty.map((type) => type.languageText);
    versionItemNty = ValueNotifier<String>('');
    textSizeItemNty = textScaleFactorNotifier.map((scale) => getFormattedTextSize(scale));
    _loadAppVersion();
  }

  void prepareLiteData() {
    pageData = [
      SectionListViewItem(data: [
        CustomItemModel(
          customWidgetBuilder: buildUserInfoWidget,
        ),
        // LabelItemModel(
        //   style: ListViewItemStyle.theme,
        //   icon: ListViewIcon(iconName: 'icon_setting_add.png', package: 'ox_usercenter'),
        //   title: 'My Circles',
        //   valueNty: ValueNotifier('Upgrade'),
        // ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_security.png', package: 'ox_usercenter'),
          title: Localized.text('ox_usercenter.keys'),
          onTap: keysItemOnTap,
        ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_circles.png', package: 'ox_usercenter'),
          title: Localized.text('ox_usercenter.circle_settings'),
          onTap: circleItemOnTap,
        ),
      ]),
      // SectionListViewItem(data: [
      //   LabelItemModel(
      //     icon: ListViewIcon(iconName: 'icon_setting_contact.png', package: 'ox_usercenter'),
      //     title: 'Contact',
      //     valueNty: ValueNotifier('23'),
      //   ),
      //   LabelItemModel(
      //     icon: ListViewIcon(iconName: 'icon_setting_security.png', package: 'ox_usercenter'),
      //     title: 'Private and Security',
      //   ),
      // ]),
      SectionListViewItem(data: [
        // LabelItemModel(
        //   icon: ListViewIcon(iconName: 'icon_setting_notification.png', package: 'ox_usercenter'),
        //   title: 'Notifications',
        // ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_theme.png', package: 'ox_usercenter'),
          title: Localized.text('ox_usercenter.theme'),
          value$: themeItemNty,
          onTap: themeItemOnTap,
        ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_lang.png', package: 'ox_usercenter'),
          title: Localized.text('ox_usercenter.language'),
          value$: languageItemNty,
          onTap: languageItemOnTap,
        ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_textsize.png', package: 'ox_usercenter'),
          title: Localized.text('ox_usercenter.text_size'),
          value$: textSizeItemNty,
          onTap: textSizeItemOnTap,
        ),
        // LabelItemModel(
        //   icon: ListViewIcon(iconName: 'icon_setting_sound.png', package: 'ox_usercenter'),
        //   title: 'Sound',
        //   valueNty: ValueNotifier('Default'),
        // ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_version.png', package: 'ox_usercenter'),
          title: Localized.text('ox_usercenter.version'),
          value$: versionItemNty,
        ),
      ]),
      SectionListViewItem.button(
        text: 'Logout',
        onTap: logoutItemOnTap,
        type: ButtonType.destructive,
      )
    ];
  }

  @override
  void dispose() {
    languageItemNty.dispose();
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
    return CLSectionListView(
      items: pageData,
    );
  }

  Widget buildUserInfoWidget(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: profileItemOnTap,
      child: Container(
        height: 72.px,
        margin: EdgeInsets.symmetric(vertical: 12.px),
        child: Row(
          children: [
            ValueListenableBuilder(
              valueListenable: userNotifier.avatarUrl$,
              builder: (context, avatarUrl, _) {
                return OXUserAvatar(
                  imageUrl: avatarUrl,
                  size: 60.px,
                ).setPadding(EdgeInsets.symmetric(horizontal: CLLayout.horizontalPadding));
              }
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder(
                    valueListenable: userNotifier.name$,
                    builder: (context, name, _) {
                      return CLText.bodyLarge(name);
                    }
                  ),
                  ValueListenableBuilder(
                    valueListenable: userNotifier.encodedPubkey$,
                    builder: (context, encodedPubkey, _) {
                      return CLText.bodyMedium(encodedPubkey.truncate(20));
                    }
                  ),
                ],
              ),
            ),
            // _kNotchedPadding = EdgeInsets.symmetric(horizontal: 14.0);
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: CLListTile.buildDefaultTrailing(profileItemOnTap),
            ),
          ],
        ),
      ),
    );
  }

  void keysItemOnTap() {
    OXNavigator.pushPage(context, (_) => KeysPage(previousPageTitle: title,));
  }

  void circleItemOnTap() {
    final circle = LoginManager.instance.currentCircle;
    if (circle == null) return;

    OXNavigator.pushPage(context, (_) => CircleDetailPage(
      previousPageTitle: title,
      circle: circle,
    ));
  }

  void profileItemOnTap() {
    OXNavigator.pushPage(context, (_) => ProfileSettingsPage(previousPageTitle: title,));
  }

  void themeItemOnTap() {
    OXNavigator.pushPage(context, (_) => ThemeSettingsPage(previousPageTitle: title,));
  }

  void languageItemOnTap() {
    OXNavigator.pushPage(context, (_) => LanguageSettingsPage(previousPageTitle: title,));
  }

  void textSizeItemOnTap() {
    OXNavigator.pushPage(context, (_) => FontSizeSettingsPage(previousPageTitle: title,));
  }

  void logoutItemOnTap() async {
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

    if (shouldLogout == true) {
      await LoginManager.instance.logout();
      OXNavigator.popToRoot(context);
    }
  }

  /// Load the application version and build number then update [versionItemNty].
  void _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final String version = packageInfo.version;
      final String buildNumber = packageInfo.buildNumber;
      versionItemNty.value = '$version+$buildNumber';
    } catch (_) {
      // Fallback in case of error
      versionItemNty.value = '';
    }
  }
}
