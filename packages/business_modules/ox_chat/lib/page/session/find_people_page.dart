import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/scan_utils.dart';
import 'package:ox_common/widgets/common_scan_page.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:permission_handler/permission_handler.dart';

class FindPeoplePage extends StatefulWidget {
  /// When true, page title shows "Join Circle" and is used for entering
  /// circle invite link or scanning QR (e.g. from "I have an invite").
  final bool joinCircleMode;

  const FindPeoplePage({super.key, this.joinCircleMode = false});

  @override
  State<FindPeoplePage> createState() => _FindPeoplePageState();
}

class _FindPeoplePageState extends State<FindPeoplePage> {
  final TextEditingController _userIdController = TextEditingController();
  final FocusNode _userIdFocusNode = FocusNode();

  @override
  void dispose() {
    _userIdController.dispose();
    _userIdFocusNode.dispose();
    super.dispose();
  }

  bool get _isUsernameValid {
    return _userIdController.text.trim().isNotEmpty;
  }

  void _onUsernameChanged(String value) {
    setState(() {});
  }

  String get _pageTitle =>
      widget.joinCircleMode
          ? Localized.text('ox_chat.join_circle_title')
          : Localized.text('ox_chat.add_friends_to_chat');

  String get _privacyNotice =>
      widget.joinCircleMode
          ? Localized.text('ox_chat.find_people_join_circle_notice')
          : Localized.text('ox_chat.find_people_privacy_notice');

  String get _inputPlaceholder =>
      widget.joinCircleMode
          ? Localized.text('ox_chat.enter_circle_invite_link')
          : Localized.text('ox_chat.enter_user_id');

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: _pageTitle,
        actions: [
          // Next button - disabled when username is invalid
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isUsernameValid ? () => _onFindAndAdd(context) : null,
            child: CLText.bodyMedium(
              Localized.text('ox_chat.next'),
              colorToken: _isUsernameValid 
                  ? ColorToken.primary
                  : ColorToken.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: LoseFocusWrap(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(CLLayout.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Username input field
              CLTextField(
                controller: _userIdController,
                focusNode: _userIdFocusNode,
                placeholder: _inputPlaceholder,
                onChanged: _onUsernameChanged,
                autofocus: false,
              ),
              
              SizedBox(height: 12.px),
              
              // Instruction text
              CLText.bodySmall(
                _privacyNotice,
                colorToken: ColorToken.onSurfaceVariant,
              ),
              
              SizedBox(height: 32.px),
              
              // Scan QR Code button
              _buildScanQRCodeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanQRCodeButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _onScanQRCode(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 16.px),
        decoration: BoxDecoration(
          color: ColorToken.cardContainer.of(context),
          borderRadius: BorderRadius.circular(12.px),
          border: Border.all(
            color: ColorToken.onSurfaceVariant.of(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CLIcon(
              icon: PlatformStyle.isUseMaterial
                  ? Icons.qr_code_scanner
                  : CupertinoIcons.qrcode_viewfinder,
              size: 24.px,
              color: ColorToken.onSurface.of(context),
            ),
            SizedBox(width: 12.px),
            CLText.bodyMedium(
              Localized.text('ox_common.scan_qr_code'),
              colorToken: ColorToken.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  void _onScanQRCode(BuildContext context) async {
    // Check camera permission first
    if (await Permission.camera.request().isGranted) {
      // Navigate to scan page and get result
      String? result = await OXNavigator.pushPage(
        context,
        (context) => CLScaffold(
          appBar: CLAppBar(
            title: Localized.text('ox_common.scan_qr_code'),
          ),
          body: CommonScanPage(),
        ),
      );

      if (result != null && result.isNotEmpty) {
        // Use ScanUtils to analyze the scanned result
        // This will automatically handle npubkey and navigate to user detail page
        await ScanUtils.analysis(context, result);
      }
    } else {
      // Show permission dialog if camera permission is denied
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
      ).then((result) {
        if (result == true) {
          openAppSettings();
        }
      });
    }
  }

  void _onFindAndAdd(BuildContext context) async {
    final input = _userIdController.text.trim();
    if (input.isEmpty) {
      CommonToast.instance.show(context, Localized.text('ox_chat.enter_user_id'));
      return;
    }

    // Show loading
    OXLoading.show();

    try {
      // Use ScanUtils to analyze the input - it supports both invite links and user IDs (npub)
      // ScanUtils will automatically detect if it's an invite link or user ID
      await ScanUtils.analysis(context, input);
    } catch (e) {
      OXLoading.dismiss();
      // Check if it's an invite link to show appropriate error message
      if (input.contains('0xchat.com/x/invite') || 
          input.contains('0xchat.com/lite/invite') ||
          input.contains('www.0xchat.com/x/invite') ||
          input.contains('www.0xchat.com/lite/invite')) {
        CommonToast.instance.show(context, Localized.text('ox_common.failed_to_process_invite_link'));
      } else {
        CommonToast.instance.show(context, Localized.text('ox_common.user_not_found'));
      }
    } finally {
      // Note: ScanUtils.analysis may handle loading dismissal internally,
      // but we ensure it's dismissed here as a safety measure
      OXLoading.dismiss();
    }
  }
}

