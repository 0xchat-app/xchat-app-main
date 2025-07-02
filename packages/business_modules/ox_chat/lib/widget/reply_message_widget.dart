import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/component.dart';

class ReplyMessageWidget extends StatelessWidget {

  ReplyMessageWidget(this.displayContent, {this.deleteCallback = null});

  final ValueNotifier<String?> displayContent;

  final VoidCallback? deleteCallback;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: this.displayContent,
      child: SizedBox(),
      builder: (context, displayContent, child) {
        if (displayContent == null) {
          return SizedBox();
        }

        final textColor = ColorToken.onSurface.of(context).withValues(alpha: 0.5);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.px),
            // Use surfaceContainer with opacity for background
            color: ColorToken.surfaceContainerHigh.of(context),
            // Add a subtle border using onSurfaceVariant
            border: Border.all(
              color: ColorToken.surfaceContainer.of(context),
              width: 0.5,
            ),
          ),
          margin: EdgeInsets.only(
            top: 16.px,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 8.px,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 10.px,),
              // Reply content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CLText.bodyMedium(
                      displayContent,
                      customColor: textColor,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Delete button
              if (deleteCallback != null)
                GestureDetector(
                  onTap: deleteCallback,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.px,
                    ),
                    child: CLIcon(
                      icon: CupertinoIcons.xmark_circle_fill,
                      size: 20.px,
                      color: textColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}