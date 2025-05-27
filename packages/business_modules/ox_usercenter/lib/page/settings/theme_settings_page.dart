import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_theme/ox_theme.dart';
import 'dart:ui' as ui;

extension ThemeSettingTypeEx on ThemeStyle {
  String get text {
    switch (this) {
      case ThemeStyle.system:
        final platformBrightness = ui.window.platformBrightness;
        return Localized.text('ox_usercenter.theme_color_default').replaceAll(r'${theme}', Localized.text(platformBrightness == Brightness.dark ? 'ox_usercenter.theme_color_dart' : 'ox_usercenter.theme_color_light'));
      case ThemeStyle.dark:
        return Localized.text('ox_usercenter.theme_color_dart');
      case ThemeStyle.light:
        return Localized.text('ox_usercenter.theme_color_light');
    }
  }
}

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPage();
}

class _ThemeSettingsPage extends State<ThemeSettingsPage> {

  late ThemeStyle initialType;
  late ValueNotifier<ThemeStyle> selectedNty;
  late List<SelectedItemModel> data;

  @override
  void initState() {
    super.initState();
    initialType = themeManager.themeStyle;

    selectedNty = ValueNotifier<ThemeStyle>(initialType);
    selectedNty.addListener(() {
      ThemeManager.changeTheme(selectedNty.value);
    });

    const types = ThemeStyle.values;
    data = types.map((e) =>
      SelectedItemModel(title: e.text, value: e, selected$: selectedNty),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_usercenter.theme'),
        previousPageTitle: widget.previousPageTitle,
      ),
      isSectionListPage: true,
      body: CLSectionListView(
        items: [
          SectionListViewItem(data: data),
        ],
      ),
    );
  }
}
