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
      }
    } else {
      final cupertino = CupertinoTheme.of(context);
      switch (this) {
        case ColorToken.primary:
          return cupertino.primaryColor;
        case ColorToken.onPrimary:
          return CupertinoColors.white;
        case ColorToken.primaryContainer:
          return CupertinoColors.secondarySystemFill.resolveFrom(context);
        case ColorToken.onPrimaryContainer:
          return CupertinoColors.white;
        case ColorToken.secondary:
          // Use primaryContrastingColor if available, fallback to primaryColor
          return cupertino.primaryContrastingColor;
        case ColorToken.onSecondary:
          // Use primaryColor for contrast, fallback to white
          return cupertino.primaryColor;
        case ColorToken.secondaryContainer:
          return CupertinoColors.secondarySystemFill.resolveFrom(context);
        case ColorToken.onSecondaryContainer:
          return CupertinoColors.white;
        case ColorToken.error:
          // Cupertino does not have error color, fallback to Material
          final scheme = Theme.of(context).colorScheme;
          return scheme.error;
        case ColorToken.onError:
          final scheme = Theme.of(context).colorScheme;
          return scheme.onError;
        case ColorToken.surface:
          return CupertinoColors.systemBackground.resolveFrom(context);
        case ColorToken.onSurface:
          return cupertino.textTheme.textStyle.color ??
              CupertinoColors.label.resolveFrom(context);
      }
    }
  }
}
