
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
/// [icon], [title], and [valueNty] are required fields; [onTap] is optional.
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
  ValueNotifier<dynamic>? get valueNty;
}

class LabelItemModel<T> extends ListViewItem {
  LabelItemModel({
    super.style = ListViewItemStyle.normal,
    super.icon,
    required super.title,
    super.subtitle,
    this.valueNty,
    this.valueMapper = defaultValueMapper,
    this.onTap,
  });

  @override
  ValueNotifier<T>? valueNty;

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
    required this.valueNty,
  });

  @override
  ValueNotifier<bool> valueNty;
}

class SelectedItemModel<T> extends ListViewItem {
  SelectedItemModel({
    super.icon,
    required super.title,
    super.subtitle,
    required this.value,
    required this.selectedValueNty,

  });

  final T value;
  final ValueNotifier<T> selectedValueNty;

  @override
  ValueNotifier<T> get valueNty => selectedValueNty;
}

class CustomItemModel extends ListViewItem {
  CustomItemModel({
    super.icon,
    super.title = '',
    super.subtitle,
    this.trailing,
    this.customWidgetBuilder,
    this.onTap,
  });

  @override
  ValueNotifier? get valueNty => null;

  Widget? trailing;

  Widget Function(BuildContext context)? customWidgetBuilder;

  VoidCallback? onTap;
}