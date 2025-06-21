import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';

import '../text.dart';
import 'list_view_model.dart';

class SectionListViewItem {
  SectionListViewItem({
    required this.data,
    String? header,
    Widget? headerWidget,
    this.isEditing = false,
    this.onDelete,
  }) : headerWidget = headerWidget
      ?? (header != null ? _buildSectionHeader(header) : null);

  final List<ListViewItem> data;
  final Widget? headerWidget;

  /// Whether the CLListView inside this section is in editing mode.
  final bool isEditing;

  /// Callback when an item is deleted in editing mode.
  final Function(ListViewItem item)? onDelete;

  static Widget _buildSectionHeader(String title) {
    Widget widget = CLText.titleSmall(title);
    if (PlatformStyle.isUseMaterial) {
      widget = Padding(
        padding: EdgeInsets.only(
          left: 20.px,
          top: 16.px,
        ),
        child: widget,
      );
    }
    return widget;
  }
}