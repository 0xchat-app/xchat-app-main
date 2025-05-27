
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ListViewIcon {
  ListViewIcon({
    required this.iconName,
    this.package,
    this.data,
  });

  factory ListViewIcon.data(IconData icon) =>
      ListViewIcon(iconName: '', data: icon);

  final String iconName;
  final String? package;
  final IconData? data;
}

enum ListViewItemStyle {
  normal,
  theme,
}

/// Model class representing a single item in a sectioned list.
/// [icon], [title], and [value$] are required fields; [onTap] is optional.
abstract class ListViewItem {
  ListViewItem({
    this.style = ListViewItemStyle.normal,
    this.icon,
    required this.title,
    this.subtitle,
  });

  ListViewItemStyle style;
  ListViewIcon? icon;
  String title;
  String? subtitle;

  bool isCupertinoListTileBaseStyle = true;

  @protected
  ValueNotifier<dynamic>? get value$;
}

class LabelItemModel<T> extends ListViewItem {
  LabelItemModel({
    super.style = ListViewItemStyle.normal,
    super.icon,
    required super.title,
    super.subtitle,
    this.value$,
    this.valueMapper = defaultValueMapper,
    this.onTap,
  });

  @override
  ValueNotifier<T>? value$;

  String Function(T value) valueMapper;

  String getValueMapData(dynamic value) => valueMapper(value);

  VoidCallback? onTap;

  static String defaultValueMapper(value) => value.toString();
}

class SwitcherItemModel extends ListViewItem {
  SwitcherItemModel({
    super.icon,
    required super.title,
    super.subtitle,
    required this.value$,
  });

  @override
  ValueNotifier<bool> value$;
}

class SelectedItemModel<T> extends ListViewItem {
  SelectedItemModel({
    super.icon,
    required super.title,
    super.subtitle,
    required this.value,
    required this.selected$,

  });

  final T value;
  final ValueNotifier<T> selected$;

  @override
  ValueNotifier<T> get value$ => selected$;
}

class CustomItemModel extends ListViewItem {
  CustomItemModel({
    super.icon,
    super.title = '',
    super.subtitle,
    this.leading,
    this.titleWidget,
    this.subtitleWidget,
    this.trailing,
    this.customWidgetBuilder,
    this.onTap,
  });

  @override
  ValueNotifier? get value$ => null;

  Widget? leading;
  Widget? titleWidget;
  Widget? subtitleWidget;
  Widget? trailing;

  Widget Function(BuildContext context)? customWidgetBuilder;

  VoidCallback? onTap;
}