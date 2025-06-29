import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:chatcore/chat-core.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/custom_uri_helper.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

enum QRCodeStyle {
  defaultStyle, // Default
  classic,      // Classic
  dots,         // Dots
  gradient,     // Gradient
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
  late final String qrCodeData;

  // QR Code style options
  QRCodeStyle currentStyle = QRCodeStyle.gradient;
  final GlobalKey qrWidgetKey = GlobalKey();

  double get horizontal => 32.px;

  late QrCode qrCode;
  late QrImage qrImage;
  late PrettyQrDecoration previousDecoration;
  late PrettyQrDecoration currentDecoration;

  @override
  void initState() {
    super.initState();
    userNotifier = widget.otherUser ?? Account.sharedInstance.me!;
    userName = userNotifier.name ?? userNotifier.shortEncodedPubkey;
    
    // Generate QR code data with Nostr protocol
    List<String> relayList;
    if (widget.otherUser != null) {
      // For other users, use empty relay list or their known relays
      relayList = [];
    } else {
      // For current user, use their relay list
      relayList = Account.sharedInstance.getMyGeneralRelayList().map((e) => e.url).take(5).toList();
    }
    final nostrValue = Account.encodeProfile(
      userNotifier.pubKey, 
      relayList,
    );
    qrCodeData = CustomURIHelper.createNostrURI(nostrValue);

    // Initialize QR code and image
    qrCode = QrCode.fromData(
      data: qrCodeData,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );
    qrImage = QrImage(qrCode);

    currentDecoration = createDecoration(currentStyle);
    previousDecoration = currentDecoration;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: widget.otherUser != null 
            ? Localized.text('ox_usercenter.user_qr_code')
            : Localized.text('ox_usercenter.my_qr_code'),
        previousPageTitle: widget.previousPageTitle,
      ),
      isSectionListPage: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // QR Code Card
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
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: 16.px,
            ),
            child: Column(
              children: [
                // Style Selection
                // _buildStyleSelection(),

                // SizedBox(height: 20.px),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
          SafeArea(child: SizedBox(height: 12.px))
        ],
      ),
    );
  }

  Widget _buildQRCodeCard() {
    return Container(
      padding: EdgeInsets.all(32.px),
      decoration: BoxDecoration(
        color: ColorToken.surface.of(context),
        borderRadius: BorderRadius.circular(24.px),
        boxShadow: [
          BoxShadow(
            color: ColorToken.onSurface.of(context).withValues(alpha: 0.1),
            blurRadius: 20.px,
            offset: Offset(0, 4.px),
          ),
        ],
      ),
      child: Container(
        color: ColorToken.surface.of(context),
        child: Column(
          children: [
            // User Info Header
            _buildUserHeader(),

            SizedBox(height: 16.px),

            // QR Code
            _buildQRCode(),

            SizedBox(height: 16.px),

            // Description
            CLText.bodyMedium(
              Localized.text('ox_chat.str_scan_user_qrcode_hint'),
              textAlign: TextAlign.center,
              colorToken: ColorToken.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        OXUserAvatar(
          imageUrl: userNotifier.picture ?? '',
          size: 56.px,
        ),
        SizedBox(width: 16.px),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CLText.titleMedium(
                userName,
                maxLines: 1,
                colorToken: ColorToken.onSurface,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.px),
              CLText.bodySmall(
                userNotifier.shortEncodedPubkey,
                colorToken: ColorToken.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
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
    return TweenAnimationBuilder<PrettyQrDecoration>(
      tween: PrettyQrDecorationTween(
        begin: previousDecoration,
        end: currentDecoration,
      ),
      curve: Curves.ease,
      duration: const Duration(milliseconds: 300),
      builder: (context, decoration, child) {
        return PrettyQrView(
          qrImage: qrImage,
          decoration: decoration,
        );
      },
    );
  }

  Widget _buildStyleSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: QRCodeStyle.values.map((style) {
        final isSelected = style == currentStyle;
        return _buildStyleOption(style, isSelected);
      }).toList(),
    );
  }

  Widget _buildStyleOption(QRCodeStyle style, bool isSelected) {
    return GestureDetector(
      onTap: () => changeQrStyle(style),
      child: Container(
        width: 80.px,
        height: 80.px,
        decoration: BoxDecoration(
          color: isSelected 
              ? ColorToken.primaryContainer.of(context)
              : ColorToken.surfaceContainer.of(context),
          borderRadius: BorderRadius.circular(12.px),
          border: isSelected 
              ? Border.all(
                  color: ColorToken.primary.of(context),
                  width: 2.px,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32.px,
              height: 32.px,
              child: _buildStylePreview(style),
            ),
            SizedBox(height: 6.px),
            CLText.bodySmall(
              _getStyleName(style),
              textAlign: TextAlign.center,
              colorToken: isSelected 
                  ? ColorToken.primary 
                  : ColorToken.onSurface,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylePreview(QRCodeStyle style) {
    return PrettyQrView.data(
      data: 'preview',
      decoration: createDecoration(style),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        CLButton.filled(
          text: Localized.text('ox_usercenter.save_qr_code'),
          onTap: _saveQRCode,
          expanded: true,
        ),
        SizedBox(height: 20.px),
        CLButton.outlined(
          text: Localized.text('ox_usercenter.share_qr_code'),
          onTap: _shareQRCode,
          expanded: true,
        ),
      ],
    );
  }

  Future<void> _saveQRCode() async {
    try {
      // Request storage permission
      final permission = Platform.isAndroid
          ? Permission.storage
          : Permission.photos;

      final status = await permission.request();
      if (!status.isGranted) {
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

  Future<void> _shareQRCode() async {
    // TODO: Implement share functionality
    CommonToast.instance.show(
      context, 
      Localized.text('ox_usercenter.share_coming_soon'),
    );
  }
} 