import 'dart:ui';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ox_chat/widget/report_dialog.dart';

class MessageReportTarget implements ReportTarget {

  MessageReportTarget({
    required this.message,
    this.completeAction,
  });

  final types.Message message;
  final VoidCallback? completeAction;

  Future<String> reportAction(String reason) async {
    var messageId = message.remoteId;
    if (messageId == null) return 'message not found';

    await Future.delayed(Duration(milliseconds: 1300));
    completeAction?.call();
    return '';
  }
}