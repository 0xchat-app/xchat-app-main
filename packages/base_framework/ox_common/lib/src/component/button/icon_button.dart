
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLIconButton extends StatelessWidget {
  CLIconButton({
    required this.child,
    required this.size,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final double size;
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
    return SizedBox.square(
      dimension: size,
      child: IconButton(
        onPressed: onTap,
        padding: padding,
        constraints: BoxConstraints(
          minWidth: size,
          minHeight: size,
        ),
        icon: child,
      ),
    );
  }

  Widget buildCupertinoIcon(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CupertinoButton(
        onPressed: onTap,
        minSize: size,
        padding: padding,
        child: child,
      ),
    );
  }
}