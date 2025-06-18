import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';

class CLListView extends StatelessWidget {
  final ScrollController? controller;
  final List<ListViewItem> items;
  final bool shrinkWrap;
  final EdgeInsets? padding;

  /// When true, the list will render in editing mode (showing delete or reorder handles if supported).
  final bool isEditing;

  /// Callback when user deletes an item in editing mode.
  final Function(ListViewItem item)? onDelete;

  final bool hasLeading;

  CLListView({
    super.key,
    this.controller,
    required this.items,
    this.shrinkWrap = false,
    this.padding,
    this.isEditing = false,
    this.onDelete,
  }) : hasLeading = itemsHasIcon(items);

  static bool itemsHasIcon(List<ListViewItem> items) {
    return items.any((item) {
      final hasIcon = item.icon != null;
      final hasLeading = (item is CustomItemModel && item.leading != null);
      return hasIcon || hasLeading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = this.items.map((e) => e..isUseMaterial = true).toList();
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return CLListTile(
          model: items[index],
          isEditing: isEditing,
          onDelete: onDelete,
        );
      },
      separatorBuilder: (_, index) => buildSeparator(items[index]),
    );
  }

  Widget buildSeparator(ListViewItem item) {
    if (PlatformStyle.isUseMaterial) {
      return SizedBox();
    } else {
      return SizedBox();
    }
  }

  List<Widget> asCupertinoSectionChildren(bool isCupertinoListTileBaseStyle) {
    return items.map((item) {
      item.isCupertinoListTileBaseStyle = isCupertinoListTileBaseStyle;
      return CLListTile(
        model: item,
        isEditing: isEditing,
        onDelete: onDelete,
      );
    }).toList();
  }
}