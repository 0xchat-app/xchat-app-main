
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLTonalButton extends StatelessWidget {
  CLTonalButton({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return FilledButton.tonal(
        onPressed: onTap,
        child: child,
      );
    } else {
      return CupertinoButton.tinted(
        onPressed: onTap,
        child: child,
      );
    }
  }
}