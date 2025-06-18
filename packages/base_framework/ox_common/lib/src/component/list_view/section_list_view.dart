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
    // Build a flat list of widgets from sections
    final widgets = <Widget>[];
    
    // Add header if provided
    if (header != null) {
      widgets.add(header!);
    }
    
    // Add sections
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      widgets.add(buildItemWidget(item));
      
      // Add section separator (except for the last section)
      if (i < items.length - 1) {
        widgets.add(buildSectionSeparator(item));
      }
    }
    
    // Add footer if provided
    if (footer != null) {
      widgets.add(footer!);
    }
    
    return ListView.separated(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: widgets.length,
      itemBuilder: (context, index) => widgets[index],
      separatorBuilder: (_, index) => const SizedBox.shrink(), // No separators between widgets since we handle them manually
    );
  }

  Widget buildSectionSeparator(SectionListViewItem item) {
    if (PlatformStyle.isUseMaterial) {
      return Divider(height: 1,).setPadding(EdgeInsets.symmetric(horizontal: 16.px));
    } else {
      return SizedBox(height: 8.px);
    }
  }

  Widget buildItemWidget(SectionListViewItem model) {
    final headerWidget = model.headerWidget;

    if (PlatformStyle.isUseMaterial) {
      final widgets = <Widget>[];
      if (headerWidget != null) {
        widgets.add(headerWidget);
      }
      widgets.add(CLListView(
        shrinkWrap: true,
        items: model.data,
        isEditing: model.isEditing,
        onDelete: model.onDelete,
      ));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    } else {
      final listView = CLListView(
        items: model.data,
        isEditing: model.isEditing,
        onDelete: model.onDelete,
      );
      return CupertinoListSection.insetGrouped(
        header: headerWidget,
        hasLeading: listView.hasLeading,
        children: listView.asCupertinoSectionChildren(false),
      );
    }
  }
}