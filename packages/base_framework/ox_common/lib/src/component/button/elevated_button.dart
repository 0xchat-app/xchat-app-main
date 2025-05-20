
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';

class CLElevatedButton extends StatelessWidget {
  CLElevatedButton({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(),
        child: child,
      );
    } else {
      return CupertinoButton.tinted(
        color: CupertinoColors.systemGrey,
        onPressed: onTap,
        child: child,
      );
    }
  }
}