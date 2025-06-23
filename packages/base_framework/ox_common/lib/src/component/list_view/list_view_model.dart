import 'package:flutter/widgets.dart';

class ListViewIcon {
  ListViewIcon({
    required this.iconName,
    this.package,
    this.data,
    this.size,
  });

  factory ListViewIcon.data(IconData icon) =>
      ListViewIcon(iconName: '', data: icon);

  final String iconName;
  final String? package;
  final IconData? data;
  final double? size;
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
    this.isCupertinoAutoTrailing = true,
    this.isUseMaterial,
  });

  final ListViewItemStyle style;
  final ListViewIcon? icon;
  final String title;
  final String? subtitle;

  final bool isCupertinoAutoTrailing;
  bool isCupertinoListTileBaseStyle = true;

  bool? isUseMaterial;

  @protected
  ValueNotifier<dynamic>? get value$;
}

class LabelItemModel<T> extends ListViewItem {
  LabelItemModel({
    super.style = ListViewItemStyle.normal,
    super.icon,
    required super.title,
    super.subtitle,
    super.isUseMaterial,
    super.isCupertinoAutoTrailing,
    this.value$,
    this.valueMapper = defaultValueMapper,
    this.maxLines,
    this.overflow,
    this.onTap,
  });

  @override
  ValueNotifier<T>? value$;

  String Function(T value) valueMapper;

  String getValueMapData(dynamic value) => valueMapper(value);

  int? maxLines;
  TextOverflow? overflow;
  VoidCallback? onTap;

  static String defaultValueMapper(value) => value.toString();
}

class SwitcherItemModel extends ListViewItem {
  SwitcherItemModel({
    super.icon,
    required super.title,
    super.subtitle,
    super.isUseMaterial,
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
    super.isCupertinoAutoTrailing = false,
    super.isUseMaterial,
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
    super.isUseMaterial,
    this.leading,
    this.titleWidget,
    this.subtitleWidget,
    this.trailing,
    this.customWidgetBuilder,
    this.onTap,
    bool? isCupertinoAutoTrailing,
  }) : super(
    isCupertinoAutoTrailing: isCupertinoAutoTrailing ?? trailing == null,
  );

  @override
  ValueNotifier? get value$ => null;

  Widget? leading;
  Widget? titleWidget;
  Widget? subtitleWidget;
  Widget? trailing;

  Widget Function(BuildContext context)? customWidgetBuilder;

  VoidCallback? onTap;
}

/// Model for multi-select list item. [selectedSet$] holds the global selected
/// id set so each tile can rebuild when selection changes.
class MultiSelectItemModel<T> extends ListViewItem {
  MultiSelectItemModel({
    super.icon,
    required super.title,
    super.subtitle,
    super.isCupertinoAutoTrailing = false,
    super.isUseMaterial,
    required this.value$,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  ValueNotifier<bool> value$;
}