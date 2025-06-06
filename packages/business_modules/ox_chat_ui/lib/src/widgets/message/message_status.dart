import 'package:flutter/widgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ox_common/component.dart';
import '../state/inherited_chat_theme.dart';

/// A class that represents a message status.
class MessageStatus extends StatelessWidget {
  /// Creates a message status widget.
  const MessageStatus({
    super.key,
    required this.size,
    required this.status,
  });

  final double size;
  /// Status of the message.
  final types.Status? status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case types.Status.warning:
        return Image.asset(
          'assets/images/message_status_warn_icon.png',
          height: size,
          width: size,
          package: 'ox_chat_ui',
        );
      case types.Status.error:
        return InheritedChatTheme.of(context).theme.errorIcon != null
            ? InheritedChatTheme.of(context).theme.errorIcon!
            : Image.asset(
                'assets/images/message_status_fail_icon.png',
                height: size,
                width: size,
                package: 'ox_chat_ui',
              );
      case types.Status.sending:
        return InheritedChatTheme.of(context).theme.sendingIcon != null
            ? InheritedChatTheme.of(context).theme.sendingIcon!
            : Center(
                child:CLProgressIndicator.circular(
                  size: size,
                ),
              );
      default:
        return SizedBox(width: size);
    }
  }
}
