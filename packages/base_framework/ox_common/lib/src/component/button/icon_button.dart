
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLIconButton extends StatelessWidget {
  CLIconButton({
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return buildMaterialIcon(context);
    } else {
      return buildCupertinoIcon(context);
    }
  }

  Widget buildMaterialIcon(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      padding: padding,
      icon: child,
    );
  }

  Widget buildCupertinoIcon(BuildContext context) {
    return CupertinoButton(
      onPressed: onTap,
      padding: padding,
      child: child,
    );
  }
}