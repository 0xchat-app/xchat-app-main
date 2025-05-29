
import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/utils/extension.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_theme/ox_theme.dart';
import 'package:ox_usercenter/page/settings/language_settings_page.dart';
import 'package:ox_usercenter/page/settings/theme_settings_page.dart';

import '../set_up/keys_page.dart';
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

  late MutableUser userNotifier;
  late List<SectionListViewItem> pageData;

  @override
  void initState() {
    super.initState();

    prepareData();

    languageItemNty.addListener(() {
      // Update label notifier when language changed.
      themeItemNty.value = themeManager.themeStyle.text;
    });
  }

  void prepareData() {
    prepareNotifier();
    prepareLiteData();
    userNotifier = OXUserInfoManager.sharedInstance.userNotifier;
  }

  void prepareNotifier() {
    themeItemNty = themeManager.styleNty.map((style) => style.text);
    languageItemNty = Localized.localized.localeTypeNty.map((type) => type.languageText);
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
          title: 'Keys',
          onTap: keysItemOnTap,
        ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_circles.png', package: 'ox_usercenter'),
          title: 'Circles',
          value$: ValueNotifier('6'),
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
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_notification.png', package: 'ox_usercenter'),
          title: 'Notifications',
        ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_theme.png', package: 'ox_usercenter'),
          title: 'Theme',
          value$: themeItemNty,
          onTap: themeItemOnTap,
        ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_lang.png', package: 'ox_usercenter'),
          title: 'Language',
          value$: languageItemNty,
          onTap: languageItemOnTap,
        ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_textsize.png', package: 'ox_usercenter'),
          title: 'Text Size',
          value$: ValueNotifier('20'),
          onTap: textSizeItemOnTap,
        ),
        // LabelItemModel(
        //   icon: ListViewIcon(iconName: 'icon_setting_sound.png', package: 'ox_usercenter'),
        //   title: 'Sound',
        //   valueNty: ValueNotifier('Default'),
        // ),
        LabelItemModel(
          icon: ListViewIcon(iconName: 'icon_setting_version.png', package: 'ox_usercenter'),
          title: 'Version',
          value$: ValueNotifier('1.00'),
        ),
      ]),
    ];
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
                ).setPadding(EdgeInsets.symmetric(horizontal: 16.px));
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
}
