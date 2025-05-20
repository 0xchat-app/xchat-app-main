
import 'package:flutter/material.dart';

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
}

extension AppColorResolver on ColorToken {
  Color of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (this) {
      case ColorToken.primary:              return scheme.primary;
      case ColorToken.onPrimary:            return scheme.onPrimary;
      case ColorToken.primaryContainer:     return scheme.primaryContainer;
      case ColorToken.onPrimaryContainer:   return scheme.onPrimaryContainer;
      case ColorToken.secondary:            return scheme.secondary;
      case ColorToken.onSecondary:          return scheme.onSecondary;
      case ColorToken.secondaryContainer:   return scheme.secondaryContainer;
      case ColorToken.onSecondaryContainer: return scheme.onSecondaryContainer;
      case ColorToken.error:                return scheme.error;
      case ColorToken.onError:              return scheme.onError;
    }
  }
}