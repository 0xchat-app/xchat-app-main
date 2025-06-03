import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/component.dart';

enum ColorToken {
  primary,
  onPrimary,
  primaryContainer,
  onPrimaryContainer,
  secondary,
  onSecondary,
  secondaryContainer,
  onSecondaryContainer,
  error,
  onError,
  surface,
  onSurface,
  surfaceContainer,
}

extension AppColorResolver on ColorToken {
  Color of(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      final scheme = Theme.of(context).colorScheme;
      switch (this) {
        case ColorToken.primary:
          return scheme.primary;
        case ColorToken.onPrimary:
          return scheme.onPrimary;
        case ColorToken.primaryContainer:
          return scheme.primaryContainer;
        case ColorToken.onPrimaryContainer:
          return scheme.onPrimaryContainer;
        case ColorToken.secondary:
          return scheme.secondary;
        case ColorToken.onSecondary:
          return scheme.onSecondary;
        case ColorToken.secondaryContainer:
          return scheme.secondaryContainer;
        case ColorToken.onSecondaryContainer:
          return scheme.onSecondaryContainer;
        case ColorToken.error:
          return scheme.error;
        case ColorToken.onError:
          return scheme.onError;
        case ColorToken.surface:
          return scheme.surface;
        case ColorToken.onSurface:
          return scheme.onSurface;
        case ColorToken.surfaceContainer:
          return scheme.surfaceContainer;
      }
    } else {
      final cupertino = CupertinoTheme.of(context);
      switch (this) {
        case ColorToken.primary:
          return cupertino.primaryColor;
        case ColorToken.onPrimary:
          return cupertino.primaryContrastingColor;
        case ColorToken.primaryContainer:
          final base = cupertino.primaryColor.withAlpha(0x26);
          final surface = CupertinoColors.systemBackground.resolveFrom(context);
          return Color.alphaBlend(base, surface);
        case ColorToken.onPrimaryContainer:
          return cupertino.primaryColor;
        case ColorToken.secondary:
          return cupertino.primaryColor;
        case ColorToken.onSecondary:
          return cupertino.primaryContrastingColor;
        case ColorToken.secondaryContainer:
          return CupertinoColors.secondarySystemBackground.resolveFrom(context);
        case ColorToken.onSecondaryContainer:
          return CupertinoColors.secondaryLabel.resolveFrom(context);
        case ColorToken.error:
          return CupertinoColors.systemRed.resolveFrom(context);
        case ColorToken.onError:
          return CupertinoColors.white;
        case ColorToken.surface:
          return CupertinoColors.systemBackground.resolveFrom(context);
        case ColorToken.onSurface:
          return cupertino.textTheme.textStyle.color ??
              CupertinoColors.label.resolveFrom(context);
        case ColorToken.surfaceContainer:
          return CupertinoColors.secondarySystemFill.resolveFrom(context);
      }
    }
  }
}
