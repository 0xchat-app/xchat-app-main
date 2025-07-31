
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLIconButton extends StatelessWidget {
  CLIconButton({
    required this.child,
    required this.size,
    this.onTap,
    this.tooltip,
  });

  final Widget child;
  final double size;
  final VoidCallback? onTap;
  final String? tooltip;

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
        constraints: BoxConstraints(
          minWidth: size,
          minHeight: size,
        ),
        alignment: Alignment.center,
        tooltip: tooltip,
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
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}