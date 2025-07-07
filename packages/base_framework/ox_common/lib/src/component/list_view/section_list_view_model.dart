import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';


class SectionListViewItem {
  SectionListViewItem({
    required this.data,
    String? header,
    Widget? headerWidget,
    this.isEditing = false,
    this.onDelete,
  }) : headerWidget = headerWidget
      ?? (header != null ? _buildSectionHeader(header) : null),
       _isButtonSection = false,
       _buttonOnTap = null,
       _buttonType = null,
       _buttonText = null;

  /// Constructor for a section that displays a single button
  /// Similar to the "Sign Out" button in iPhone's Apple ID settings
  SectionListViewItem.button({
    required String text,
    required VoidCallback onTap,
    ButtonType type = ButtonType.secondary,
  }) : data = [],
       headerWidget = null,
       isEditing = false,
       onDelete = null,
       _isButtonSection = true,
       _buttonOnTap = onTap,
       _buttonType = type,
       _buttonText = text;

  final List<ListViewItem> data;
  final Widget? headerWidget;

  /// Whether the CLListView inside this section is in editing mode.
  final bool isEditing;

  /// Callback when an item is deleted in editing mode.
  final Function(ListViewItem item)? onDelete;

  /// Whether this section is a button section
  final bool _isButtonSection;

  /// The onTap callback for button sections
  final VoidCallback? _buttonOnTap;

  /// The button type for styling
  final ButtonType? _buttonType;

  /// The button text
  final String? _buttonText;

  /// Getter to check if this is a button section
  bool get isButtonSection => _isButtonSection;

  /// Getter to get the button onTap callback
  VoidCallback? get buttonOnTap => _buttonOnTap;

  /// Getter to get the button type
  ButtonType? get buttonType => _buttonType;

  /// Getter to get the button text
  String? get buttonText => _buttonText;

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

/// Button types for styling
enum ButtonType {
  /// Primary action (positive, highlighted)
  primary,
  
  /// Secondary action (neutral)
  secondary,
  
  /// Destructive action (dangerous, highlighted in red)
  destructive,
}