
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';

import '../platform_style.dart';
import 'list_view.dart';
import 'section_list_view_model.dart';

class CLSectionListView extends StatelessWidget {
  final ScrollController? controller;
  final List<SectionListViewItem> items;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  const CLSectionListView({
    super.key,
    this.controller,
    required this.items,
    this.shrinkWrap = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: items.length,
      itemBuilder: (context, index) => buildItemWidget(items[index]),
      separatorBuilder: (_, index) => buildSectionSeparator(items[index]),
    );
  }

  Widget buildSectionSeparator(SectionListViewItem item) {
    if (PlatformStyle.isUseMaterial) {
      return Divider(height: 1,).setPadding(EdgeInsets.symmetric(horizontal: 16.px));
    } else {
      return SizedBox();
    }
  }

  Widget buildItemWidget(SectionListViewItem model) {
    if (PlatformStyle.isUseMaterial) {
      return CLListView(shrinkWrap: true, items: model.data);
    } else {
      final listView = CLListView(items: model.data);
      return CupertinoListSection.insetGrouped(
        hasLeading: listView.hasLeading,
        children: listView.asCupertinoSectionChildren(false),
      );
    }
  }
}