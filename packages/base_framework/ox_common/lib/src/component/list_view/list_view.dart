
import 'package:flutter/cupertino.dart';
import 'package:ox_common/component.dart';

class CLListView extends StatelessWidget {
  final ScrollController? controller;
  final List<ListViewItem> items;
  final bool shrinkWrap;
  final EdgeInsets? padding;

  final bool hasLeading;

  CLListView({
    super.key,
    this.controller,
    required this.items,
    this.shrinkWrap = false,
    this.padding,
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
    if (PlatformStyle.isUseMaterial) {
      return ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: items.length,
        itemBuilder: (context, index) => CLListTile(model: items[index]),
        separatorBuilder: (_, index) => buildSeparator(items[index]),
      );
    } else {
      return ListView(
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          if (padding == EdgeInsets.zero)
            CupertinoListSection.insetGrouped(
              hasLeading: hasLeading,
              topMargin: 0,
              margin: EdgeInsets.zero,
              backgroundColor: ColorToken.surface.of(context),
              children: asCupertinoSectionChildren(true),
            )
          else
            CupertinoListSection.insetGrouped(
              hasLeading: hasLeading,
              backgroundColor: ColorToken.surface.of(context),
              children: asCupertinoSectionChildren(true),
            )
        ],
      );
    }
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
      return CLListTile(model: item);
    }).toList();
  }
}