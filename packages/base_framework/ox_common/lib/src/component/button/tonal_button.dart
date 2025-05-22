
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLTonalButton extends StatelessWidget {
  CLTonalButton({
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: padding,
        ),
        child: child,
      );
    } else {
      return CupertinoButton.tinted(
        onPressed: onTap,
        padding: padding,
        child: child,
      );
    }
  }
}