import 'dart:async';

import 'package:chatcore/chat-core.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'login_manager.dart';

/// Registers [Account.onRelayOkError] in ox_common.
/// Handles relay OK errors (status false + non-empty message):
/// - "tenant expired" → show circle expired toast
/// - "not a member of this tenant" → delete current circle and show dialog with circle name
void registerRelayOkErrorHandler() {
  Account.onRelayOkError = (OKEvent ok) {
    final msg = ok.message.toLowerCase();
    if (msg.contains('tenant expired')) {
      final context = OXNavigator.navigatorKey.currentContext;
      if (context != null) {
        CommonToast.instance.show(
          context,
          Localized.text('ox_common.circle_expired_title'),
        );
      }
    } else if (msg.contains('not a member of this tenant')) {
      final circle = LoginManager.instance.currentCircle;
      if (circle != null) {
        final circleName = circle.name;
        unawaited(_removeFromCircleAndNotify(circle.id, circleName));
      }
    }
  };
}

Future<void> _removeFromCircleAndNotify(String circleId, String circleName) async {
  await LoginManager.instance.deleteCircle(circleId);
  final context = OXNavigator.navigatorKey.currentContext;
  if (context != null && context.mounted) {
    final title = Localized.text('ox_common.circle_removed_title');
    final content = Localized.text('ox_common.circle_removed_message').replaceAll('{name}', circleName);
    await CLAlertDialog.show<void>(
      context: context,
      title: title,
      content: content,
      actions: [CLAlertAction.ok()],
    );
  }
}
