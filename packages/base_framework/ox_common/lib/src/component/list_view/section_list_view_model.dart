
import 'package:flutter/widgets.dart';
import 'package:ox_common/utils/adapt.dart';

import '../text.dart';
import 'list_view_model.dart';

class SectionListViewItem {
  SectionListViewItem({
    required this.data,
    String? header,
    Widget? headerWidget,
  }) : headerWidget = headerWidget
      ?? (header != null ? _buildSectionHeader(header) : null);

  final List<ListViewItem> data;
  final Widget? headerWidget;

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.px,
        top: 16.px,
      ),
      child: CLText.titleSmall(title),
    );
  }
}