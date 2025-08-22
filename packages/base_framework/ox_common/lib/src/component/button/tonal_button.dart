import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/color_extension.dart';

import '../platform_style.dart';
import '../theme_data.dart';
import 'core/cupertino_button.dart';
import 'core/material_button.dart';

class CLTonalButton extends StatelessWidget {
  CLTonalButton({
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
      return FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: padding,
          minimumSize: minimumSize,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: useThemeGradient ? Colors.transparent : null,
          backgroundBuilder: (BuildContext context, Set<WidgetState> states, Widget? innerChild) {
            if (!useThemeGradient) return innerChild ?? SizedBox();

            // Ref: _FilledTonalButtonDefaultsM3
            var gradient = CLThemeData.themeGradientOf(context).toOpacity(0.18);
            if (states.contains(WidgetState.disabled)) {
              // _FilledTonalButtonDefaultsM3.backgroundColor
              gradient = gradient.toGray().toOpacity(0.12);
            }

            final layerOpacity = MaterialButtonHelper
                .fillButtonOpacityWithStates(states);
            final borderRadius = MaterialButtonHelper
                .borderRadiusOf(StadiumBorder());

            return ClipRRect(
              borderRadius: borderRadius,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // color: Colors.cyan,
                  gradient: gradient.toOpacity(layerOpacity),
                ),
                child: innerChild ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
        child: child,
      );
    } else {
      return CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(
          primaryColor: CupertinoDynamicColor.withBrightness(
            color: CLThemeData.themeColorLight,
            darkColor: CLThemeData.themeColorDark,
          ),
        ),
        child: CLCupertinoButton.tinted(
          padding: padding,
          minSize: minimumSize?.height,
          gradient: useThemeGradient ? CLThemeData.themeGradientOf(context) : null,
          // sizeStyle: CupertinoButtonSize.medium,
          onPressed: onTap,
          child: child,
        ),
      );
    }
  }
}