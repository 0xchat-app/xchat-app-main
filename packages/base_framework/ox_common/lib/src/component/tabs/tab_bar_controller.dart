
import 'package:flutter/material.dart';

class CLTabIcon {
  const CLTabIcon({required this.assetName, required this.package});
  final String assetName;
  final String package;
}

class CLTabItem<T> {
  CLTabItem({
    required this.value,
    String? text,
    this.icon,
    required this.pageBuilder,
  }) : text = text ?? value.toString();

  final CLTabIcon? icon;
  final T value;
  final String text;
  final Widget Function(BuildContext context) pageBuilder;
}

class CLTabBarController<T> {
  CLTabBarController({
    required this.items,
    CLTabItem<T>? initialItem,
    required TickerProvider vsync,
  })  : _materialController = TabController(
    initialIndex: initialItem == null ? 0 : items.indexOf(initialItem),
    length: items.length,
    vsync: vsync,
  ),
        selectedItemNty = ValueNotifier<CLTabItem<T>>(
            initialItem ?? items.first);

  final TabController _materialController;
  TabController get asMaterial => _materialController;

  final List<CLTabItem<T>> items;
  final ValueNotifier<CLTabItem<T>> selectedItemNty;
  int get selectedIndex => _materialController.index;

  void onValueChanged(CLTabItem<T>? newItem) {
    if (newItem == null) return;
    if (newItem == selectedItemNty.value) return;

    selectedItemNty.value = newItem;
    _materialController.index = items.indexOf(newItem);
  }
}