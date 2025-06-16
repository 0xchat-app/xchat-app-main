import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_localizable/ox_localizable.dart';

/// Action model for alert dialog buttons.
class CLAlertAction<T> {
  const CLAlertAction({
    required this.label,
    this.value,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });

  /// Button label text.
  final String label;

  /// Value returned when this action is selected.
  final T? value;

  /// Whether this is the "default" affirmative action (Cupertino style).
  final bool isDefaultAction;

  /// Whether this action is destructive (highlighted in red on iOS / Material).
  final bool isDestructiveAction;

  /// Common OK / confirm action (value == true).
  static CLAlertAction<bool> ok() =>
      CLAlertAction<bool>(
        label: Localized.text('ox_common.ok'),
        value: true,
        isDefaultAction: true,
      );

  /// Common Cancel action (value == false).
  static CLAlertAction<bool> cancel() =>
      CLAlertAction<bool>(
        label: Localized.text('ox_common.cancel'),
        value: false,
        isDestructiveAction: false,
      );
}

/// Cross-platform Alert Dialog (Material & Cupertino).
class CLAlertDialog {
  /// Show alert dialog and return the [value] of the button tapped.
  /// If dismissed by other ways, returns null.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    required List<CLAlertAction<T>> actions,
    bool barrierDismissible = true,
  }) {
    if (PlatformStyle.isUseMaterial) {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (ctx) => AlertDialog(
          title: CLText(title),
          content: CLText.bodyMedium(content),
          actions: _materialActions(ctx, actions),
        ),
      );
    }

    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => CupertinoAlertDialog(
        title: CLText(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CLText.bodyMedium(content),
        ),
        actions: _cupertinoActions(ctx, actions),
      ),
    );
  }

  /// Build Material buttons.
  static List<Widget> _materialActions<T>(
    BuildContext ctx,
    List<CLAlertAction<T>> models,
  ) {
    return models
        .map((m) => TextButton(
              onPressed: () => Navigator.of(ctx).pop(m.value),
              style: m.isDestructiveAction
                  ? TextButton.styleFrom(foregroundColor: ColorToken.error.of(ctx))
                  : null,
              child: CLText(m.label),
            ))
        .toList();
  }

  /// Build Cupertino buttons.
  static List<Widget> _cupertinoActions<T>(
    BuildContext ctx,
    List<CLAlertAction<T>> models,
  ) {
    return models
        .map((m) => CupertinoDialogAction(
              isDefaultAction: m.isDefaultAction,
              isDestructiveAction: m.isDestructiveAction,
              onPressed: () => Navigator.of(ctx).pop(m.value),
              child: CLText(m.label),
            ))
        .toList();
  }
}