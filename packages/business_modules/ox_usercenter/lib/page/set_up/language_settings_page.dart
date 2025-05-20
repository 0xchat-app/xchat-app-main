
import 'package:flutter/material.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/platform_utils.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_appbar.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'dart:ui' as ui;


class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> with SingleTickerProviderStateMixin{

  late LocaleType initialType;
  late ValueNotifier<LocaleType> selectedNty;
  late List<SelectedItemModel> data;

  @override
  void initState() {
    super.initState();

    initialType = Localized.localized.localeType;

    selectedNty = ValueNotifier<LocaleType>(initialType);
    selectedNty.addListener(() {
      Localized.changeLocale(selectedNty.value);
    });

    const types = LocaleType.values;
    data = types.map((e) =>
        SelectedItemModel(title: e.languageText, value: e, selectedValueNty: selectedNty),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_usercenter.language'),
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
