import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:chatcore/chat-core.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ox_common/utils/permission_utils.dart';
import 'package:ox_common/const/app_config.dart';

enum QRCodeStyle {
  defaultStyle, // Default
  classic,      // Classic
  dots,         // Dots
  gradient,     // Gradient
}

enum InviteLinkType {
  oneTime,    // One-time invite link
  permanent,  // Permanent invite link
}

class QRCodeDisplayPage extends StatefulWidget {
  const QRCodeDisplayPage({
    super.key,
    this.previousPageTitle,
    this.otherUser,
  });

  final String? previousPageTitle;
  final UserDBISAR? otherUser;

  @override
  State<QRCodeDisplayPage> createState() => _QRCodeDisplayPageState();
}

class _QRCodeDisplayPageState extends State<QRCodeDisplayPage> {
  late final UserDBISAR userNotifier;
  late final String userName;
  String? currentInviteLink;
  String? currentQrCodeData;

  // QR Code style options
  QRCodeStyle currentStyle = QRCodeStyle.gradient;
  final GlobalKey qrWidgetKey = GlobalKey();

  double get horizontal => 32.px;

  QrCode? qrCode;
  QrImage? qrImage;
  late PrettyQrDecoration previousDecoration;
  late PrettyQrDecoration currentDecoration;

  // Invite link type
  InviteLinkType currentLinkType = InviteLinkType.oneTime;

  @override
  void initState() {
    super.initState();
    userNotifier = widget.otherUser ?? Account.sharedInstance.me!;
    userName = userNotifier.name ?? userNotifier.shortEncodedPubkey;
    
    currentDecoration = createDecoration(currentStyle);
    previousDecoration = currentDecoration;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _generateInviteLink(InviteLinkType linkType) async {
    if (widget.otherUser != null) return; // Only for current user
    
    try {
      OXLoading.show();
      
      KeyPackageEvent? keyPackageEvent;
      
      if (linkType == InviteLinkType.oneTime) {
        keyPackageEvent = await Groups.sharedInstance.createOneTimeKeyPackage();
      } else {
        keyPackageEvent = await Groups.sharedInstance.createPermanentKeyPackage(
          Account.sharedInstance.getCurrentCircleRelay(),
        );
      }
      
      if (keyPackageEvent == null) {
              await OXLoading.dismiss();
      CommonToast.instance.show(context, Localized.text('ox_usercenter.invite_link_generation_failed'));
      return;
      }

      // Get relay URL
      List<String> relays = Account.sharedInstance.getCurrentCircleRelay();
      String relayUrl = relays.isNotEmpty ? relays.first : 'wss://relay.0xchat.com';

      // Generate invite link
      if (linkType == InviteLinkType.oneTime) {
        // For one-time invites, include sender's pubkey
        final senderPubkey = Account.sharedInstance.currentPubkey;
        currentInviteLink = '${AppConfig.inviteBaseUrl}?keypackage=${Uri.encodeComponent(keyPackageEvent.encoded_key_package)}&pubkey=${Uri.encodeComponent(senderPubkey)}&relay=${Uri.encodeComponent(relayUrl)}';
      } else {
        currentInviteLink = '${AppConfig.inviteBaseUrl}?eventid=${Uri.encodeComponent(keyPackageEvent.eventId)}&relay=${Uri.encodeComponent(relayUrl)}';
      }

      // Update QR code data and current link type
      currentQrCodeData = currentInviteLink;
      currentLinkType = linkType;
      
      // Initialize QR code and image with optimized settings for long URLs
      try {
        // Use lower error correction level for better readability with long URLs
        qrCode = QrCode.fromData(
          data: currentQrCodeData!,
          errorCorrectLevel: QrErrorCorrectLevel.L, // Use lowest error correction level
        );
        qrImage = QrImage(qrCode!);
      } catch (e) {
        print('QR code generation failed: $e');
        qrCode = null;
        qrImage = null;
        CommonToast.instance.show(context, Localized.text('ox_usercenter.qr_generation_failed'));
      }

      await OXLoading.dismiss();
      setState(() {});
    } catch (e) {
      await OXLoading.dismiss();
      CommonToast.instance.show(context, '${Localized.text('ox_usercenter.invite_link_generation_failed')}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: widget.otherUser != null 
            ? Localized.text('ox_usercenter.user_qr_code')
            : Localized.text('ox_usercenter.generate_invite_link'),
        previousPageTitle: widget.previousPageTitle,
        actions: widget.otherUser == null ? <Widget>[
          // Share button with proper alignment
          Transform.translate(
            offset: Offset(0, -2.px),
            child: IconButton(
              onPressed: currentInviteLink != null ? _showShareOptions : null,
              icon: Icon(
                Icons.share,
                color: currentInviteLink != null 
                    ? ColorToken.primary.of(context)
                    : ColorToken.onSurfaceVariant.of(context),
                size: 24.px,
              ),
              tooltip: Localized.text('ox_usercenter.share_invite_link'),
            ),
          ),
        ] : <Widget>[],
      ),
      isSectionListPage: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // QR Code Card - Place at the top, following Signal's layout
          RepaintBoundary(
            key: qrWidgetKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: 20.px,
              ),
              child: _buildQRCodeCard(),
            ),
          ),
          
          // Invite Link Type Selector (only for current user)
          if (widget.otherUser == null) ...[
            SizedBox(height: 24.px),
            _buildInviteLinkTypeSelector(),
          ],
          

          
          SafeArea(child: SizedBox(height: 12.px))
        ],
      ),
    );
  }



  Widget _buildInviteLinkTypeSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: Column(
        children: [
          // One-time invite button
          if (Platform.isIOS) ...[
            // iOS style buttons
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(12.px),
                padding: EdgeInsets.symmetric(vertical: 16.px),
                onPressed: () => _showOneTimeConfirmDialog(),
                child: Text(
                  Localized.text('ox_usercenter.generate_one_time_invite'),
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16.px,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.px),
            // Permanent invite button
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12.px),
                padding: EdgeInsets.symmetric(vertical: 16.px),
                onPressed: () => _showPermanentConfirmDialog(),
                child: Text(
                  Localized.text('ox_usercenter.generate_permanent_invite'),
                  style: TextStyle(
                    color: CupertinoColors.systemBlue,
                    fontSize: 16.px,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Android style buttons
            CLButton.filled(
              text: Localized.text('ox_usercenter.generate_one_time_invite'),
              onTap: () => _showOneTimeConfirmDialog(),
              expanded: true,
            ),
            SizedBox(height: 12.px),
            CLButton.outlined(
              text: Localized.text('ox_usercenter.generate_permanent_invite'),
              onTap: () => _showPermanentConfirmDialog(),
              expanded: true,
            ),
          ],
        ],
      ),
    );
  }

    Widget _buildQRCodeCard() {
    return Container(
      padding: EdgeInsets.all(24.px),
      decoration: BoxDecoration(
        color: Platform.isIOS 
            ? CupertinoColors.systemBackground
            : ColorToken.surface.of(context),
        borderRadius: BorderRadius.circular(16.px),
        border: Border.all(
          color: Platform.isIOS 
              ? CupertinoColors.separator
              : ColorToken.onSurfaceVariant.of(context).withValues(alpha: 0.1),
          width: Platform.isIOS ? 0.5.px : 1.px,
        ),
      ),
      child: Column(
        children: [
          // QR Code
          _buildQRCode(),

          // SizedBox(height: 16.px),

          // Description - Platform adaptive text style
          if (Platform.isIOS) ...[
            Text(
              currentInviteLink == null
                  ? Localized.text('ox_usercenter.click_to_generate_invite')
                  : Localized.text('ox_usercenter.scan_qr_to_find_me'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 14.px,
              ),
            ),
          ] else ...[
            CLText.bodyMedium(
              currentInviteLink == null
                  ? Localized.text('ox_usercenter.click_to_generate_invite')
                  : Localized.text('ox_usercenter.scan_qr_to_find_me'),
              textAlign: TextAlign.center,
              colorToken: ColorToken.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }





  Widget _buildQRCode() {
    return Container(
      padding: EdgeInsets.all(16.px),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.px),
      ),
      child: _buildStyledQRCode(),
    );
  }

  Widget _buildStyledQRCode() {
    if (qrImage == null) {
      return Container(
        width: 240.px,
        height: 240.px,
        decoration: BoxDecoration(
          color: Platform.isIOS 
              ? CupertinoColors.systemGrey6
              : ColorToken.surfaceContainer.of(context),
          borderRadius: BorderRadius.circular(12.px),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Platform.isIOS ? CupertinoIcons.qrcode : Icons.qr_code_2,
              size: 64.px,
              color: Platform.isIOS 
                  ? CupertinoColors.systemGrey
                  : ColorToken.onSurfaceVariant.of(context),
            ),
            SizedBox(height: 16.px),
            if (Platform.isIOS) ...[
                              Text(
                  currentInviteLink == null 
                      ? Localized.text('ox_usercenter.empty_invite_link')
                      : Localized.text('ox_usercenter.qr_generation_failed'),
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14.px,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              CLText.bodyMedium(
                currentInviteLink == null 
                    ? Localized.text('ox_usercenter.empty_invite_link')
                    : Localized.text('ox_usercenter.qr_generation_failed'),
                colorToken: ColorToken.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }
    
    return Container(
      width: 280.px,
      height: 280.px,
      padding: EdgeInsets.all(6.px),
      child: TweenAnimationBuilder<PrettyQrDecoration>(
        tween: PrettyQrDecorationTween(
          begin: previousDecoration,
          end: currentDecoration,
        ),
        curve: Curves.ease,
        duration: const Duration(milliseconds: 300),
        builder: (context, decoration, child) {
          return PrettyQrView(
            qrImage: qrImage!,
            decoration: decoration,
          );
        },
      ),
    );
  }

  void changeQrStyle(QRCodeStyle style) {
    setState(() {
      currentStyle = style;
      previousDecoration = currentDecoration;
      currentDecoration = createDecoration(style);
    });
  }

  PrettyQrDecoration createDecoration(QRCodeStyle style) {
    Color color = ColorToken.primary.of(
      OXNavigator.navigatorKey.currentState!.context
    ).withValues(alpha: 0.8);
    double roundFactor = 1;
    PrettyQrShape shape;

    switch (style) {
      case QRCodeStyle.defaultStyle:
        shape = PrettyQrSmoothSymbol(
          color: color,
          roundFactor: roundFactor,
        );
        break;

      case QRCodeStyle.classic:
        shape = PrettyQrSmoothSymbol(
          color: color,
          roundFactor: 0,
        );
        break;

      case QRCodeStyle.dots:
        shape = PrettyQrRoundedSymbol(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        );
        break;

      case QRCodeStyle.gradient:
        shape = PrettyQrSmoothSymbol(
          color: PrettyQrBrush.gradient(
            gradient: LinearGradient(
              colors: [
                color,
                Colors.teal.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          roundFactor: roundFactor, // Rounded
        );
        break;
    }

    return PrettyQrDecoration(
      shape: shape,
    );
  }

  String _getStyleName(QRCodeStyle style) {
    switch (style) {
      case QRCodeStyle.defaultStyle:
        return Localized.text('ox_usercenter.default');
      case QRCodeStyle.classic:
        return Localized.text('ox_usercenter.classic');
      case QRCodeStyle.dots:
        return Localized.text('ox_usercenter.dots');
      case QRCodeStyle.gradient:
        return Localized.text('ox_usercenter.gradient');
    }
  }



  Future<void> _saveQRCode() async {
    try {
      // Request appropriate permissions using existing utility method
      bool permissionGranted = await PermissionUtils.getPhotosPermission(context, type: 1);

      if (!permissionGranted) {
        CommonToast.instance.show(
          context, 
          Localized.text('ox_usercenter.storage_permission_denied'),
        );
        return;
      }

      OXLoading.show();

      // Capture QR code widget as image
      final boundary = qrWidgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Failed to capture QR code');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final pngBytes = byteData.buffer.asUint8List();
      
      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        name: 'QRCode_${DateTime.now().millisecondsSinceEpoch}',
        isReturnImagePathOfIOS: true,
      );

      await OXLoading.dismiss();

      if (result['isSuccess'] == true) {
        CommonToast.instance.show(
          context, 
          Localized.text('ox_usercenter.qr_code_saved'),
        );
      } else {
        throw Exception('Save failed');
      }
    } catch (e) {
      await OXLoading.dismiss();
      CommonToast.instance.show(
        context, 
        Localized.text('ox_usercenter.save_failed'),
      );
    }
  }

  void _showShareOptions() {
    if (Platform.isIOS) {
      // iOS style
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text(Localized.text('ox_usercenter.select_operation')),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _saveQRCode();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8.px),
                  Text(Localized.text('ox_usercenter.save_qr_code')),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _shareInvite();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8.px),
                  Text(Localized.text('ox_usercenter.share_invite_link')),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(Localized.text('ox_usercenter.cancel')),
          ),
        ),
      );
    } else {
      // Android style
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
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
                
                // Options
                ListTile(
                  title: CLText.bodyLarge(
                    Localized.text('ox_usercenter.save_qr_code'),
                    colorToken: ColorToken.onSurface,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _saveQRCode();
                  },
                ),
                
                ListTile(
                  title: CLText.bodyLarge(
                    Localized.text('ox_usercenter.share_invite_link'),
                    colorToken: ColorToken.onSurface,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _shareInvite();
                  },
                ),
                
                SizedBox(height: 20.px),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _shareInvite() async {
    try {
      // Share invite link
      await Share.share(
        currentInviteLink!,
        subject: Localized.text('ox_usercenter.invite_to_chat'),
      );
    } catch (e) {
      CommonToast.instance.show(
        context, 
        '${Localized.text('ox_usercenter.share_failed')}: $e',
      );
    }
  }

  void _showOneTimeConfirmDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(Localized.text('ox_usercenter.one_time_keypackage_confirm_title')),
          content: Text(Localized.text('ox_usercenter.one_time_keypackage_confirm_content')),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(Localized.text('ox_usercenter.cancel')),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                _generateInviteLink(InviteLinkType.oneTime);
              },
              child: Text(Localized.text('ox_usercenter.confirm')),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(Localized.text('ox_usercenter.one_time_keypackage_confirm_title')),
          content: Text(Localized.text('ox_usercenter.one_time_keypackage_confirm_content')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(Localized.text('ox_usercenter.cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generateInviteLink(InviteLinkType.oneTime);
              },
              child: Text(Localized.text('ox_usercenter.confirm')),
            ),
          ],
        ),
      );
    }
  }

  void _showPermanentConfirmDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(Localized.text('ox_usercenter.permanent_keypackage_confirm_title')),
          content: Text(Localized.text('ox_usercenter.permanent_keypackage_confirm_content')),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(Localized.text('ox_usercenter.cancel')),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                _generateInviteLink(InviteLinkType.permanent);
              },
              child: Text(Localized.text('ox_usercenter.confirm')),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(Localized.text('ox_usercenter.permanent_keypackage_confirm_title')),
          content: Text(Localized.text('ox_usercenter.permanent_keypackage_confirm_content')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(Localized.text('ox_usercenter.cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generateInviteLink(InviteLinkType.permanent);
              },
              child: Text(Localized.text('ox_usercenter.confirm')),
            ),
          ],
        ),
      );
    }
  }


} 