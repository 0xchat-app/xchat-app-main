import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chatcore/chat-core.dart';

class CircleExpiredPromptDialog extends StatelessWidget {
  const CircleExpiredPromptDialog({
    super.key,
    required this.circle,
    required this.isAdmin,
  });

  final Circle circle;
  final bool isAdmin;

  /// Resolves whether current user is admin for [circle] (owner or tenant admin).
  static Future<bool> resolveIsAdmin(Circle circle) async {
    final currentPubkey = LoginManager.instance.currentPubkey;
    bool isAdmin = circle.ownerPubkey != null &&
        circle.ownerPubkey!.isNotEmpty &&
        circle.ownerPubkey!.toLowerCase() == currentPubkey.toLowerCase();

    if (!isAdmin) {
      final circleDB = await Account.sharedInstance.getCircleById(circle.id);
      if (circleDB?.tenantAdminPubkey != null &&
          circleDB!.tenantAdminPubkey!.isNotEmpty) {
        isAdmin = circleDB.tenantAdminPubkey!
                .toLowerCase() ==
            currentPubkey.toLowerCase();
      }
    }
    return isAdmin;
  }

  /// Shows the circle expired dialog. Resolves [isAdmin] first, then builds the dialog (no loading inside).
  static Future<void> show(BuildContext context, Circle circle) async {
    final isAdmin = await resolveIsAdmin(circle);

    if (!context.mounted) return;

    CLDialog.show(context: context, contentWidget: CircleExpiredPromptDialog(circle: circle, isAdmin: isAdmin));
  }

  static const Color _warningGradientStart = Color(0xFFE85D4E);
  static const Color _warningGradientEnd = Color(0xFFD8432E);

  Future<void> _openSubscriptionManagement(BuildContext context) async {
    String url;
    if (Platform.isIOS) {
      url = 'https://apps.apple.com/account/subscriptions';
    } else if (Platform.isAndroid) {
      url =
          'https://play.google.com/store/account/subscriptions?package=com.oxchat.lite';
    } else {
      CommonToast.instance.show(
        context,
        Localized.text('ox_common.unsupported_platform'),
      );
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      CommonToast.instance.show(
        context,
        Localized.text('ox_common.failed_to_open_url'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWarningIcon(),
        SizedBox(height: 20.px),
        _buildHeading(),
        SizedBox(height: 15.px),
        _buildMessage(context),
        SizedBox(height: 20.px),
        if (isAdmin) ...[
          _buildRenewButton(context),
          SizedBox(height: 15.px),
        ],
        _buildConfirmButton(context),
      ],
    );
  }

  Widget _buildWarningIcon() {
    return Container(
      width: 72.px,
      height: 72.px,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_warningGradientStart, _warningGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: _warningGradientEnd.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '!',
          style: TextStyle(
            fontSize: 36.px,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeading() {
    return CLText.titleLarge(
      Localized.text('ox_common.circle_expired_heading'),
      textAlign: TextAlign.center,
      colorToken: ColorToken.onSurface,
    );
  }

  Widget _buildMessage(BuildContext context) {
    return CLText.bodyMedium(
      isAdmin
          ? Localized.text('ox_common.circle_expired_message_admin')
          : Localized.text('ox_common.circle_expired_message_member'),
      textAlign: TextAlign.center,
      colorToken: ColorToken.onSecondaryContainer,
    );
  }

  Widget _buildRenewButton(BuildContext context) {
    return CLButton.filled(
      onTap: () => _openSubscriptionManagement(context),
      text: Localized.text('ox_common.renew'),
      padding: EdgeInsets.zero,
      expanded: true,
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return CLButton.outlined(
      onTap: () => OXNavigator.pop(context),
      text: Localized.text('ox_common.confirm'),
      padding: EdgeInsets.zero,
      expanded: true,
    );
  }
}
