
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLTextButton extends StatelessWidget {
  CLTextButton({
    required this.child,
    EdgeInsetsGeometry? padding,
    this.onTap,
  }) : padding = padding ?? EdgeInsets.zero;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return TextButton(
        style: TextButton.styleFrom(
          padding: padding,
        ),
        onPressed: onTap,
        child: child,
      );
    } else {
      return CupertinoButton(
        onPressed: onTap,
        padding: padding,
        child: child,
      );
    }
  }
}