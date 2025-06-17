import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'platform_style.dart';
import 'package:ox_localizable/ox_localizable.dart';

class CLPickerItem<T> {
  CLPickerItem({required this.label, required this.value});
  final String label;
  final T value;
}

class CLPicker {
  /// Universal bottom picker adapting to Material BottomSheet or Cupertino ActionSheet automatically based on PlatformStyle
  static Future<T?> show<T>({
    required BuildContext context,
    required List<CLPickerItem<T>> items,
    String? title,
  }) async {
    if (PlatformStyle.isUseMaterial) {
      return await showModalBottomSheet<T>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items
                .map((e) => ListTile(
                      title: Text(e.label),
                      onTap: () => Navigator.pop(ctx, e.value),
                    ))
                .toList(),
          ),
        ),
      );
    } else {
      return await showCupertinoModalPopup<T>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          actions: items
              .map((e) => CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(ctx, e.value),
                    child: Text(e.label),
                  ))
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(Localized.text('ox_common.cancel')),
          ),
        ),
      );
    }
  }
} 