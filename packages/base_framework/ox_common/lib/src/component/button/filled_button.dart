import 'package:flutter/material.dart';
import 'package:ox_common/utils/color_extension.dart';

import '../platform_style.dart';
import '../theme_data.dart';
import 'core/cupertino_button.dart';
import 'core/material_button.dart';

class CLFilledButton extends StatelessWidget {
  const CLFilledButton({
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
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: padding,
          minimumSize: minimumSize,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: useThemeGradient ? Colors.transparent : null,
          backgroundBuilder: (BuildContext context, Set<WidgetState> states, Widget? innerChild) {
            if (!useThemeGradient) return innerChild ?? SizedBox();

            // Ref: _FilledButtonDefaultsM3
            var gradient = CLThemeData.themeGradientOf(context);
            if (states.contains(WidgetState.disabled)) {
              // _FilledButtonDefaultsM3.backgroundColor
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
      return CLCupertinoButton.filled(
        padding: padding,
        minSize: minimumSize?.height,
        gradient: useThemeGradient ? CLThemeData.themeGradientOf(context) : null,
        onPressed: onTap,
        child: child,
      );
    }
  }
}