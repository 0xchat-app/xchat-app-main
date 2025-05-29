
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLTonalButton extends StatelessWidget {
  CLTonalButton({
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
      return FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: padding,
          minimumSize: minimumSize,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: child,
      );
    } else {
      return CupertinoButton.tinted(
        padding: padding,
        minSize: minimumSize?.height,
        sizeStyle: CupertinoButtonSize.medium,
        onPressed: onTap,
        child: child,
      );
    }
  }
}