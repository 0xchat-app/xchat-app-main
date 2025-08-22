import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';
import '../theme_data.dart';
import 'core/cupertino_button.dart';

class CLElevatedButton extends StatelessWidget {
  CLElevatedButton({
    required this.child,
    this.minimumSize,
    this.padding,
    this.onTap,
    required this.useThemeGradient,
  });

  final Widget child;
  final Size? minimumSize;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool useThemeGradient;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: padding,
          minimumSize: minimumSize,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: child,
      );
    } else {
      return CLCupertinoButton.tinted(
        color: CupertinoColors.systemGrey,
        padding: padding,
        minSize: minimumSize?.height,
        gradient: useThemeGradient ? CLThemeData.themeGradientOf(context) : null,
        // sizeStyle: CupertinoButtonSize.medium,
        onPressed: onTap,
        child: child,
      );
    }
  }
}