import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';

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
      widgets.add(buildItemWidget(item, context));
      
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

  Widget buildItemWidget(SectionListViewItem model, BuildContext context) {
    final headerWidget = model.headerWidget;

    // Handle button sections
    if (model.isButtonSection) {
      return _buildButtonSection(model, context);
    }

    // Handle regular list sections
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
        separatorColor: kSystemSeparator.resolveFrom(context),
        children: listView.asCupertinoSectionChildren(false),
      );
    }
  }

  Widget _buildButtonSection(SectionListViewItem model, BuildContext context) {
    final buttonText = model.buttonText ?? '';
    final buttonType = model.buttonType;
    final buttonOnTap = model.buttonOnTap;

    if (PlatformStyle.isUseMaterial) {
      // Material design button section - use CLButton
      Widget button;
      
      switch (buttonType) {
        case ButtonType.primary:
          button = CLButton.filled(
            text: buttonText,
            onTap: buttonOnTap,
            expanded: true,
          );
          break;
        case ButtonType.destructive:
          button = CLButton.text(
            text: buttonText,
            color: ColorToken.error.of(context),
            onTap: buttonOnTap,
            expanded: true,
          );
          break;
        case ButtonType.secondary:
        default:
          button = CLButton.tonal(
            text: buttonText,
            onTap: buttonOnTap,
            expanded: true,
          );
          break;
      }
      
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: CLLayout.horizontalPadding,
        ),
        child: button,
      );
    } else {
      // Cupertino design button section - use CupertinoButton for native tap feedback
      Color textColor;
      switch (buttonType) {
        case ButtonType.primary:
          textColor = ColorToken.primary.of(context);
          break;
        case ButtonType.destructive:
          textColor = ColorToken.error.of(context);
          break;
        case ButtonType.secondary:
        default:
          textColor = ColorToken.onSurface.of(context);
          break;
      }
      
      return CupertinoListSection.insetGrouped(
        children: [
          CLButton.text(
            text: buttonText,
            color: textColor,
            onTap: buttonOnTap,
            expanded: true,
          )
        ],
      );
    }
  }
}

/// System separator dynamic color (matches iOS 17 runtime values)
const CupertinoDynamicColor kSystemSeparator = CupertinoDynamicColor(
  debugLabel: 'systemSeparator',

  // ---------- Light mode ----------
  color:                     Color.fromRGBO(60, 60, 67, 0.29),   // default
  highContrastColor:         Color.fromRGBO(60, 60, 67, 0.36),   // high-contrast
  elevatedColor:             Color.fromRGBO(60, 60, 67, 0.65),   // blurred / floating
  highContrastElevatedColor: Color.fromRGBO(60, 60, 67, 0.36),   // same as high-contrast

  // ---------- Dark mode ----------
  darkColor:                     Color.fromRGBO(84, 84, 88, 0.60),
  darkHighContrastColor:         Color.fromRGBO(84, 84, 88, 0.75),
  darkElevatedColor:             Color.fromRGBO(84, 84, 88, 0.80),
  darkHighContrastElevatedColor: Color.fromRGBO(84, 84, 88, 0.75), // same as high-contrast
);