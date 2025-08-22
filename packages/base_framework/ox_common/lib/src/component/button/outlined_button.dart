import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../color_token.dart';
import '../platform_style.dart';
import '../theme_data.dart';
import 'core/cupertino_button.dart';

class CLOutlinedButton extends StatelessWidget {
  CLOutlinedButton({
    required this.child,
    this.minimumSize,
    this.padding,
    this.onTap,
    required this.useThemeGradient,
  });

  final Widget child;
  final Size? minimumSize;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool useThemeGradient;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return _buildThemeGradientShaderMask(
        context: context,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: padding,
            minimumSize: minimumSize,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: child,
        ),
      );
    } else {
      final color = ColorToken.primary.of(context);
      return _buildThemeGradientShaderMask(
        context: context,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 1,
            ),
            borderRadius: kCupertinoButtonSizeBorderRadius[CupertinoButtonSize.large],
          ),
          child: CLCupertinoButton(
            padding: padding,
            minSize: minimumSize?.height,
            // sizeStyle: CupertinoButtonSize.medium,
            onPressed: onTap,
            child: child,
          ),
        ),
      );
    }
  }

  Widget _buildThemeGradientShaderMask({
    required BuildContext context,
    required Widget child,
  }) {
    if (!useThemeGradient) return child;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return CLThemeData.themeGradientOf(context).createShader(bounds);
      },
      child:child,
    );
  }
}