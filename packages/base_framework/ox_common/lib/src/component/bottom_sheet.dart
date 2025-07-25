import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'color_token.dart';
import 'text.dart';
import 'platform_style.dart';

/// Action model for bottom sheet items.
class CLBottomSheetAction {
  const CLBottomSheetAction({
    required this.label,
    this.icon,
    this.onTap,
    this.isDestructive = false,
  });

  /// Item label text.
  final String label;

  /// Optional icon widget.
  final Widget? icon;

  /// Callback when this item is tapped.
  final VoidCallback? onTap;

  /// Whether this action is destructive (highlighted in red).
  final bool isDestructive;

  /// Common cancel action.
  static CLBottomSheetAction cancel({VoidCallback? onTap}) =>
      CLBottomSheetAction(
        label: Localized.text('ox_common.cancel'),
        onTap: onTap,
      );
}

/// Cross-platform Bottom Sheet component.
class CLBottomSheet {
  /// Show a bottom sheet with a list of actions.
  static Future<void> show({
    required BuildContext context,
    String? title,
    required List<CLBottomSheetAction> actions,
    bool showCancelButton = true,
    VoidCallback? onCancel,
  }) {
    if (PlatformStyle.isUseMaterial) {
      // Android style - Material Design
      return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _BottomSheetContent(
          title: title,
          actions: actions,
          showCancelButton: showCancelButton,
          onCancel: onCancel,
        ),
      );
    } else {
      // iOS style - Cupertino Action Sheet
      return showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          actions: actions.map((action) => CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              action.onTap?.call();
            },
            isDestructiveAction: action.isDestructive,
            child: action.icon != null 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      action.icon!,
                      SizedBox(width: 8.px),
                      Text(action.label),
                    ],
                  )
                : Text(action.label),
          )).toList(),
          cancelButton: showCancelButton ? CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel?.call();
            },
            child: Text(Localized.text('ox_common.cancel')),
          ) : null,
        ),
      );
    }
  }

  /// Show a bottom sheet with custom content.
  static Future<void> showWithContent({
    required BuildContext context,
    String? title,
    required Widget content,
    bool showCancelButton = true,
    VoidCallback? onCancel,
  }) {
    if (PlatformStyle.isUseMaterial) {
      // Android style - Material Design
      return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _BottomSheetContent(
          title: title,
          content: content,
          showCancelButton: showCancelButton,
          onCancel: onCancel,
        ),
      );
    } else {
      // iOS style - Custom modal with Cupertino styling
      return showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.px),
              topRight: Radius.circular(20.px),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.px),
                  width: 40.px,
                  height: 4.px,
                  decoration: BoxDecoration(
                    color: CupertinoColors.separator,
                    borderRadius: BorderRadius.circular(2.px),
                  ),
                ),
                
                SizedBox(height: 20.px),
                
                // Title
                if (title != null) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.px,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  SizedBox(height: 16.px),
                ],
                
                // Content
                content,
                
                // Cancel button
                if (showCancelButton) ...[
                  SizedBox(height: 8.px),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel?.call();
                    },
                    child: Text(Localized.text('ox_common.cancel')),
                  ),
                ],
                
                SizedBox(height: 20.px),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent({
    this.title,
    this.actions,
    this.content,
    this.showCancelButton = true,
    this.onCancel,
  }) : assert(actions != null || content != null);

  final String? title;
  final List<CLBottomSheetAction>? actions;
  final Widget? content;
  final bool showCancelButton;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorToken.surface.of(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.px),
          topRight: Radius.circular(20.px),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.px),
              width: 40.px,
              height: 4.px,
              decoration: BoxDecoration(
                color: ColorToken.onSurfaceVariant.of(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.px),
              ),
            ),
            
            SizedBox(height: 20.px),
            
            // Title
            if (title != null) ...[
              CLText.titleMedium(
                title!,
                colorToken: ColorToken.onSurface,
              ),
              SizedBox(height: 16.px),
            ],
            
            // Content or Actions
            if (content != null)
              content!
            else if (actions != null)
              ...actions!.map((action) => _buildActionTile(context, action)),
            
            // Cancel button
            if (showCancelButton) ...[
              SizedBox(height: 8.px),
              ListTile(
                title: CLText.bodyLarge(
                  Localized.text('ox_common.cancel'),
                  colorToken: ColorToken.onSurface,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
              ),
            ],
            
            SizedBox(height: 20.px),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, CLBottomSheetAction action) {
    return ListTile(
      leading: action.icon,
      title: CLText.bodyLarge(
        action.label,
        colorToken: action.isDestructive 
            ? ColorToken.error 
            : ColorToken.onSurface,
      ),
      onTap: () {
        Navigator.of(context).pop();
        action.onTap?.call();
      },
    );
  }
} 