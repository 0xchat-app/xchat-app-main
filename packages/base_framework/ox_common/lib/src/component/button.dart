import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';

import 'button/elevated_button.dart';
import 'button/filled_button.dart';
import 'button/icon_button.dart';
import 'button/outlined_button.dart';
import 'button/text_button.dart';
import 'button/tonal_button.dart';

class CLButton {
  static bool get isDefaultUseThemeGradient => true;

  static Widget _defaultText(String text, [Color? color]) {
    return CLText(
      text,
      resolver: (context) {
        final textStyle = PlatformStyle.isUseMaterial
            ? Theme.of(context).textTheme.titleMedium
            : CupertinoTheme.of(context).textTheme.actionSmallTextStyle;
        return TextStyle().copyWith(
          fontSize: textStyle?.fontSize,
          fontWeight: textStyle?.fontWeight,
          fontStyle: textStyle?.fontStyle,
          letterSpacing: textStyle?.letterSpacing,
          height: textStyle?.height,
        );
      },
      customColor: color,
    );
  }

  /// Wraps the inner label with optional [alignment] while keeping the label‑
  /// driven size (using width/heightFactor = 1).
  static Widget _alignIfNeeded(Widget child, AlignmentGeometry? alignment) {
    if (alignment == null) return child;
    return Align(
      alignment: alignment,
      widthFactor: 1,
      heightFactor: 1,
      child: child,
    );
  }

  /// Applies fixed size or expands to fill according to [expanded], [width],
  /// and [height].
  static Widget _sizeWrapper(
    Widget button, {
    bool expanded = false,
    double? width,
    double? height,
  }) {
    if (expanded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final double? w =
              constraints.maxWidth.isFinite ? constraints.maxWidth : null;
          final double? h =
              constraints.maxHeight.isFinite ? constraints.maxHeight : null;
          return SizedBox(width: w, height: h, child: button);
        },
      );
    }
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: button);
    }
    return button;
  }

  static Widget filled({
    String? text,
    AlignmentGeometry? alignment,
    Widget? child,
    VoidCallback? onTap,
    bool expanded = false,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    child ??= _defaultText(text ?? '');
    child = _alignIfNeeded(child, alignment);

    Size? minimumSize;
    if (width != null || height != null) {
      minimumSize = Size(width ?? 0.0, height ?? 0.0);
    }

    return _sizeWrapper(
      CLFilledButton(
        minimumSize: minimumSize,
        padding: padding,
        useThemeGradient: isDefaultUseThemeGradient,
        onTap: onTap,
        child: child,
      ),
      expanded: expanded,
      width: width,
      height: height,
    );
  }

  static Widget tonal({
    String? text,
    AlignmentGeometry? alignment,
    Widget? child,
    VoidCallback? onTap,
    bool expanded = false,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    child ??= _defaultText(text ?? '');
    child = _alignIfNeeded(child, alignment);

    Size? minimumSize;
    if (width != null || height != null) {
      minimumSize = Size(width ?? 0.0, height ?? 0.0);
    }

    return _sizeWrapper(
      CLTonalButton(
        minimumSize: minimumSize,
        padding: padding,
        useThemeGradient: isDefaultUseThemeGradient,
        onTap: onTap,
        child: child,
      ),
      expanded: expanded,
      width: width,
      height: height,
    );
  }

  static Widget elevated({
    String? text,
    AlignmentGeometry? alignment,
    Widget? child,
    VoidCallback? onTap,
    bool expanded = false,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    child ??= _defaultText(text ?? '');
    child = _alignIfNeeded(child, alignment);

    Size? minimumSize;
    if (width != null || height != null) {
      minimumSize = Size(width ?? 0.0, height ?? 0.0);
    }

    return _sizeWrapper(
      CLElevatedButton(
        minimumSize: minimumSize,
        padding: padding,
        useThemeGradient: isDefaultUseThemeGradient,
        onTap: onTap,
        child: child,
      ),
      expanded: expanded,
      width: width,
      height: height,
    );
  }

  static Widget outlined({
    String? text,
    AlignmentGeometry? alignment,
    Widget? child,
    VoidCallback? onTap,
    bool expanded = false,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    child ??= _defaultText(text ?? '');
    child = _alignIfNeeded(child, alignment);

    Size? minimumSize;
    if (width != null || height != null) {
      minimumSize = Size(width ?? 0.0, height ?? 0.0);
    }

    return _sizeWrapper(
      CLOutlinedButton(
        minimumSize: minimumSize,
        padding: padding,
        useThemeGradient: isDefaultUseThemeGradient,
        onTap: onTap,
        child: child,
      ),
      expanded: expanded,
      width: width,
      height: height,
    );
  }

  static Widget text({
    String? text,
    Color? color,
    AlignmentGeometry? alignment,
    VoidCallback? onTap,
    bool expanded = false,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    Widget child = _defaultText(text ?? '', color);
    child = _alignIfNeeded(child, alignment);

    return _sizeWrapper(
      CLTextButton(
        padding: padding,
        onTap: onTap,
        child: child,
      ),
      expanded: expanded,
      width: width,
      height: height,
    );
  }

  static Widget icon({
    IconData? icon,
    String iconName = '',
    String package = '',
    Widget? child,
    VoidCallback? onTap,
    double? iconSize,
    Color? color,
    double? paddingWidth,
    String? tooltip,
  }) {
    iconSize ??= CLIcon.generalIconSize;
    paddingWidth ??= iconSize / 2;
    color ??= IconTheme.of(OXNavigator.navigatorKey.currentContext!).color;
    if (onTap == null) {
      color = color?.withValues(alpha: 0.3);
    }
    child ??= CLIcon(
      icon: icon,
      iconName: iconName,
      size: iconSize,
      color: color,
      package: package,
    );

    final size = iconSize + paddingWidth * 2;
    return CLIconButton(
      onTap: onTap,
      size: size,
      tooltip: tooltip,
      child: child,
    );
  }
}