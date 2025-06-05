import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/widgets/common_image.dart';

/// A class that represents send button widget.
class SendButton extends StatelessWidget {
  /// Creates send button widget.
  const SendButton({
    super.key,
    required this.onPressed,
    required this.size,
    required this.iconSize,
  });

  /// Callback for send button tap event.
  final VoidCallback onPressed;

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
        child: CommonIconButton(
          iconName: 'chat_send.png',
          size: size,
          iconSize: iconSize,
          package: 'ox_chat_ui',
          color: ColorToken.onSurface.of(context),
          onPressed: onPressed,
        ),
      );
}
