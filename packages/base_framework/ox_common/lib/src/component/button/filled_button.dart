
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLFilledButton extends StatelessWidget {
  CLFilledButton({
    required this.child,
    this.minimumSize,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final Size? minimumSize;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: padding,
          minimumSize: minimumSize,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: child,
      );
    } else {
      return CupertinoButton.filled(
        padding: padding,
        minSize: minimumSize?.height,
        // sizeStyle: CupertinoButtonSize.medium,
        onPressed: onTap,
        child: child,
      );
    }
  }
}