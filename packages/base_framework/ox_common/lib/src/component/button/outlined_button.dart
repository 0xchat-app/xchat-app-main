
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../color_token.dart';
import '../platform_style.dart';

class CLOutlinedButton extends StatelessWidget {
  CLOutlinedButton({
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
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: padding,
        ),
        child: child,
      );
    } else {
      final color = ColorToken.primary.of(context);
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
          borderRadius: kCupertinoButtonSizeBorderRadius[CupertinoButtonSize.large],
        ),
        child: CupertinoButton(
          padding: padding,
          onPressed: onTap,
          child: child,
        ),
      );
    }
  }
}