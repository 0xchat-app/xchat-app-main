
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLFilledButton extends StatelessWidget {
  CLFilledButton({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return FilledButton(
        onPressed: onTap,
        child: child,
      );
    } else {
      return CupertinoButton.filled(
        onPressed: onTap,
        child: child,
      );
    }
  }
}