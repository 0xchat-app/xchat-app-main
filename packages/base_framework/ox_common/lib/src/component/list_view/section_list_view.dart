
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
  final Widget? header;
  final Widget? footer;

  const CLSectionListView({
    super.key,
    this.controller,
    required this.items,
    this.shrinkWrap = false,
    this.padding,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final headerCount = header == null ? 0 : 1;
    final footerCount = footer == null ? 0 : 1;
    final itemCount = items.length + headerCount + footerCount;
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (headerCount > 0 && index < headerCount) return header;
        if (footerCount > 0 && index > itemCount - footerCount - 1) return footer;
        return buildItemWidget(items[index - headerCount]);
      },
      separatorBuilder: (_, index) {
        if (headerCount > 0 && index < headerCount) return const SizedBox.shrink();
        if (footerCount > 0 && index > itemCount - footerCount - 2) return SizedBox(height: 12.px,);
        return buildSectionSeparator(items[index - headerCount]);
      },
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