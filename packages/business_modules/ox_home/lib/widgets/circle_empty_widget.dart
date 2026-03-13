import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/page/circle_introduction_page.dart';
import 'package:ox_common/utils/scan_utils.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_scan_page.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:permission_handler/permission_handler.dart';

class CircleEmptyWidget extends StatelessWidget {
  final VoidCallback? onJoinCircle;
  final VoidCallback? onCreatePaidCircle;

  const CircleEmptyWidget({
    Key? key,
    this.onJoinCircle,
    this.onCreatePaidCircle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
        return Transform.translate(
      offset: Offset(0, -120.px),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.px),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
          children: [
          // Empty state icon
          CommonImage(
            iconName: 'empty.png',
            size: 120.px,
            package: 'ox_home',
          ),

          SizedBox(height: 24.px),

          // Title
          CLText.headlineSmall(
            Localized.text('ox_home.join_or_create_circle_now'),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.px),

          // Subtitle
          CLText.titleSmall(
            Localized.text('ox_home.unlock_advanced_model'),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.px),

          // Circle Introduction Button
          GestureDetector(
            onTap: () => _showCircleIntroduction(context),
            child: CLText.labelMedium(
              Localized.text('ox_home.what_is_circle'),
              colorToken: ColorToken.primary,
            ),
          ),

          SizedBox(height: 20.px),

          // Join Circle Button
          CLButton.filled(
            text: Localized.text('ox_home.join_circle'),
            onTap: onJoinCircle,
            expanded: true,
            height: 52.px,
          ),

          SizedBox(height: 16.px),

          // Scan QR Code entry (e.g. circle invite, npub, etc.)
          CLButton.text(
            text: Localized.text('ox_common.scan_qr_code'),
            onTap: () => _onScanQRCode(context),
            expanded: true,
            height: 52.px,
          ),
        ],
        ),
      ),
        ),
    );
  }

  /// Show Circle introduction page
  void _showCircleIntroduction(BuildContext context) {
    OXNavigator.pushPage(
      context,
      (context) => const CircleIntroductionPage(),
      type: OXPushPageType.present,
    );
  }

  /// Open scan page and handle result (invite link, npub, etc.) via ScanUtils
  Future<void> _onScanQRCode(BuildContext context) async {
    if (await Permission.camera.request().isGranted) {
      final String? result = await OXNavigator.pushPage<String>(
        context,
        (context) => CLScaffold(
          appBar: CLAppBar(
            title: Localized.text('ox_common.scan_qr_code'),
          ),
          body: CommonScanPage(),
        ),
      );
      if (result != null && result.isNotEmpty) {
        await ScanUtils.analysis(context, result);
      }
    } else {
      CLAlertDialog.show<bool>(
        context: context,
        content: Localized.text('ox_common.str_permission_camera_hint'),
        actions: [
          CLAlertAction.cancel(),
          CLAlertAction<bool>(
            label: Localized.text('ox_common.str_go_to_settings'),
            value: true,
            isDefaultAction: true,
          ),
        ],
      ).then((value) {
        if (value == true) openAppSettings();
      });
    }
  }
} 