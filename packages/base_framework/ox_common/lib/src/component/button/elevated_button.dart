
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLElevatedButton extends StatelessWidget {
  CLElevatedButton({
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
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: padding,
        ),
        child: child,
      );
    } else {
      return CupertinoButton.tinted(
        color: CupertinoColors.systemGrey,
        padding: padding,
        onPressed: onTap,
        child: child,
      );
    }
  }
}