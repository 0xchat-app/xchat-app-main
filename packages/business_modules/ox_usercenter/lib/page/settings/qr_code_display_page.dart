import 'dart:ui' as ui;
import 'package:ox_common/login/account_path_manager.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/widgets/common_scan_page.dart';
import 'package:flutter/services.dart';

import '../qr_code/user_qr_code_display.dart';
import 'qr_code_color_picker_page.dart';
import '../../utils/invite_link_manager.dart';
import 'package:ox_common/login/login_models.dart';

enum QRCodeStyle {
  defaultStyle, // Default
  classic,      // Classic
  dots,         // Dots
  gradient,     // Gradient
}

enum QRCodePageMode {
  code,  // Show QR code
  scan,  // Show scan page
}

/// Data for QR code display. Used by FutureBuilder (has-data vs no-data).
typedef _QrPageData = ({String inviteLink, String displayName});

class QRCodeDisplayPage extends StatefulWidget {
  const QRCodeDisplayPage({
    super.key,
    this.previousPageTitle,
    this.inviteType = InviteType.keypackage,
    this.circle,
  });

  final String? previousPageTitle;
  final InviteType inviteType;
  final Circle? circle;

  @override
  State<QRCodeDisplayPage> createState() => _QRCodeDisplayPageState();
}

class _QRCodeDisplayPageState extends State<QRCodeDisplayPage> {
  late final String userName;

  final GlobalKey qrWidgetKey = GlobalKey();

  // QR Code color
  Color selectedColor = const Color(0xFF2196F3); // Default blue

  double get horizontal => 32.px;

  // Discoverable by ID setting
  late final ValueNotifier<bool> discoverableByID$;

  // Page mode (Code or Scan)
  late final ValueNotifier<QRCodePageMode?> currentMode$;

  /// Data to display: initialized in didChangeDependencies (has context), replaced on regenerate.
  Future<_QrPageData?>? _qrPageDataFuture;

  @override
  void initState() {
    super.initState();
    final user = Account.sharedInstance.me!;
    userName = user.name ?? user.shortEncodedPubkey;

    discoverableByID$ = ValueNotifier<bool>(false);
    _initializeDiscoverableByID();

    currentMode$ = ValueNotifier<QRCodePageMode?>(QRCodePageMode.code);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize QR data future once when a valid BuildContext with dependencies is available.
    _qrPageDataFuture ??= _loadQrPageData(context);
  }

  /// Initialize discoverable by ID state by checking database
  Future<void> _initializeDiscoverableByID() async {
    try {
      final ownerPubkey = Account.sharedInstance.currentPubkey;
      
      // Check if there are any permanent keypackages that are published
      List<KeyPackageDBISAR> permanentKeyPackages =
          await KeyPackageManager.getLocalKeyPackagesByType(
              ownerPubkey, KeyPackageType.permanent);
      
      // Check if any keypackage has been published (isPublished = true)
      // Use database state as the only source of truth
      bool isDiscoverable = permanentKeyPackages.any((kp) => kp.isPublished);
      
      discoverableByID$.value = isDiscoverable;
    } catch (e) {
      print('Failed to initialize discoverable by ID: $e');
      // Default to false on error
      discoverableByID$.value = false;
    }
  }

  Future<void> _regenerateInviteLink() async {
    try {
      if (widget.inviteType == InviteType.circle) {
        if (widget.circle == null) {
          CommonToast.instance.show(context, 'Circle is required for circle invite');
          return;
        }
        await InviteLinkManager.regenerateCircleInviteLink(
          circle: widget.circle!,
        );
      } else {
        await InviteLinkManager.regenerateKeyPackageInviteLink(
          context: context,
        );
      }

      _qrPageDataFuture = _loadQrPageData(context);
      if (mounted) setState(() {}); // FutureBuilder will listen to the new future

      CommonToast.instance.show(context, Localized.text('ox_usercenter.invite_link_regenerated'));
    } catch (e) {
      CommonToast.instance.show(context, e.toString());
    }
  }

  @override
  void dispose() {
    discoverableByID$.dispose();
    currentMode$.dispose();
    super.dispose();
  }

  /// Pure fetch: returns [_QrPageData] or throws. No toast/pop.
  Future<_QrPageData> _fetchQrPageData(BuildContext context) async {
    if (widget.inviteType == InviteType.circle) {
      if (widget.circle == null) {
        throw Exception('Circle is required for circle invite');
      }
      final result = await InviteLinkManager.generateCircleInviteLink(
        circle: widget.circle!,
      );
      final inviteLink = result['inviteLink'] as String;
      return (inviteLink: inviteLink, displayName: widget.circle!.name);
    } else {
      final inviteLink = await InviteLinkManager.generateKeyPackageInviteLink(
        linkType: InviteLinkType.permanent,
        context: context,
      );
      return (inviteLink: inviteLink, displayName: userName);
    }
  }

  /// Wraps [_fetchQrPageData]: on error completes with null and shows toast/pop.
  Future<_QrPageData?> _loadQrPageData(BuildContext context) {
    return _fetchQrPageData(context).then<_QrPageData?>((d) => d).catchError((e, st) {
      if (mounted) {
        CommonToast.instance.show(context, e.toString());
        if (widget.inviteType == InviteType.circle) {
          OXNavigator.pop(context);
        }
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: _buildSegmentControl(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSegmentControl() {
    return CLSelector<QRCodePageMode>(
      items: [
        CLSelectorItem<QRCodePageMode>(
          value: QRCodePageMode.code,
          label: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.px),
            child: Text(Localized.text('ox_usercenter.code')),
          ),
        ),
        CLSelectorItem<QRCodePageMode>(
          value: QRCodePageMode.scan,
          label: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.px),
            child: Text(Localized.text('ox_usercenter.scan')),
          ),
        ),
      ],
      selectedValue$: currentMode$,
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<QRCodePageMode?>(
      valueListenable: currentMode$,
      builder: (context, currentMode, _) {
        if (currentMode == QRCodePageMode.scan) {
          return _buildScanPage();
        }

        return FutureBuilder<_QrPageData?>(
          future: _qrPageDataFuture,
          builder: (context, snapshot) {
            // If future is not yet set (ConnectionState.none) or still loading, show loading UI.
            if (snapshot.connectionState == ConnectionState.none ||
                snapshot.connectionState == ConnectionState.waiting) {
              return _buildCodeTabContentLoading();
            }
            if (snapshot.hasError) {
              return _buildCodeTabContentError(snapshot.error);
            }
            final data = snapshot.data;
            if (data == null) {
              return _buildCodeTabContentNoData();
            }
            return _buildCodeTabContentWithData(data);
          },
        );
      },
    );
  }

  Widget _buildCodeTabContentLoading() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        child: Column(
          children: [
            SizedBox(height: 24.px),
            RepaintBoundary(
              key: qrWidgetKey,
              child: _buildQrCodeLoadingPlaceholder(),
            ),
            SizedBox(height: 32.px),
            _buildActionButtonsPlaceholder(),
            SizedBox(height: 32.px),
            CLText.bodySmall(
              widget.inviteType == InviteType.circle
                  ? Localized.text('ox_usercenter.qr_code_share_warning_circle')
                  : Localized.text('ox_usercenter.qr_code_share_warning'),
              textAlign: TextAlign.center,
              colorToken: ColorToken.onSurfaceVariant,
            ),
            SafeArea(child: SizedBox(height: 12.px)),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeTabContentError(Object? error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CLText.bodyMedium(
              error?.toString() ?? Localized.text('ox_common.error'),
              textAlign: TextAlign.center,
              colorToken: ColorToken.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeTabContentNoData() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        child: CLText.bodyMedium(
          Localized.text('ox_usercenter.no_invite_data'),
          textAlign: TextAlign.center,
          colorToken: ColorToken.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildCodeTabContentWithData(_QrPageData data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        child: Column(
          children: [
            SizedBox(height: 24.px),
            RepaintBoundary(
              key: qrWidgetKey,
              child: UserQrCodeDisplay(
                qrcodeValue: data.inviteLink,
                tintColor: selectedColor,
                userName: data.displayName,
                canCopyName: true,
              ),
            ),
            SizedBox(height: 32.px),
            _buildActionButtons(data),
            SizedBox(height: 32.px),
            CLText.bodySmall(
              widget.inviteType == InviteType.circle
                  ? Localized.text('ox_usercenter.qr_code_share_warning_circle')
                  : Localized.text('ox_usercenter.qr_code_share_warning'),
              textAlign: TextAlign.center,
              colorToken: ColorToken.onSurfaceVariant,
            ),
            SizedBox(height: 32.px),
            CLButton.outlined(
              text: Localized.text('ox_usercenter.reset'),
              onTap: _showRegenerateConfirmDialog,
              expanded: true,
            ),
            SafeArea(child: SizedBox(height: 12.px)),
          ],
        ),
      ),
    );
  }

  /// Loading placeholder with same card style as UserQrCodeDisplay.
  Widget _buildQrCodeLoadingPlaceholder() {
    return Container(
      padding: EdgeInsets.all(30.px),
      decoration: BoxDecoration(
        color: selectedColor,
        borderRadius: BorderRadius.circular(30.px),
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 250.px,
              child: Center(
                child: SizedBox(
                  width: 40.px,
                  height: 40.px,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.px),
            CLText.bodyMedium(
              widget.inviteType == InviteType.circle && widget.circle != null
                  ? widget.circle!.name
                  : userName,
              textAlign: TextAlign.center,
              colorToken: ColorToken.white,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsPlaceholder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCircularActionButton(icon: Icons.link, label: Localized.text('ox_usercenter.link'), onTap: null),
        _buildCircularActionButton(icon: Icons.share, label: Localized.text('ox_usercenter.share'), onTap: null),
        _buildCircularActionButton(icon: Icons.palette, label: Localized.text('ox_usercenter.color'), onTap: null),
      ],
    );
  }

  Widget _buildScanPage() {
    return CommonScanPage();
  }

  Widget _buildActionButtons(_QrPageData data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCircularActionButton(
          icon: Icons.link,
          label: Localized.text('ox_usercenter.link'),
          onTap: () => _copyLink(data.inviteLink),
        ),
        _buildCircularActionButton(
          icon: Icons.share,
          label: Localized.text('ox_usercenter.share'),
          onTap: _shareQRCodeImage,
        ),
        _buildCircularActionButton(
          icon: Icons.palette,
          label: Localized.text('ox_usercenter.color'),
          onTap: () => _showColorPicker(qrcodeValue: data.inviteLink, displayName: data.displayName),
        ),
      ],
    );
  }

  Widget _buildCircularActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56.px,
            height: 56.px,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorToken.cardContainer.of(context),
            ),
            child: Icon(
              icon,
              size: 24.px,
              color: ColorToken.onSurface.of(context),
            ),
          ),
        ),
        SizedBox(height: 8.px),
        CLText.bodySmall(
          label,
          colorToken: ColorToken.onSurface,
        ),
      ],
    );
  }
  
  void changeQrColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  PrettyQrDecoration createDecoration(QRCodeStyle style, {Color? customColor}) {
    Color color = customColor ?? selectedColor;
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
        // For gradient style, use theme gradient if no custom color is provided
        // Otherwise, create a gradient from the custom color
        if (customColor != null) {
          shape = PrettyQrSmoothSymbol(
            color: PrettyQrBrush.gradient(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0.6),
                ],
              ),
            ),
            roundFactor: roundFactor,
          );
        } else {
          shape = PrettyQrSmoothSymbol(
            color: PrettyQrBrush.gradient(
              gradient: CLThemeData.themeGradientOf(OXNavigator.rootContext),
            ),
            roundFactor: roundFactor, // Rounded
          );
        }
        break;
    }

    return PrettyQrDecoration(
      shape: shape,
    );
  }

  Future<void> _shareQRCodeImage() async {
    try {
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

      // Create temporary file
      final tempFile =  await AccountPathManager.createTempFile(
        fileExt: 'png',
      );
      await tempFile.writeAsBytes(pngBytes);

      await OXLoading.dismiss();

      // Share the image file
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: Localized.text('ox_usercenter.invite_to_chat'),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (tempFile.existsSync()) {
          tempFile.deleteSync();
        }
      });
    } catch (e) {
      await OXLoading.dismiss();
      CommonToast.instance.show(
        context,
        '${Localized.text('ox_usercenter.share_failed')}: $e',
      );
    }
  }

  Future<void> _copyLink(String inviteLink) async {
    // Show dialog with link information
    if (PlatformStyle.isUseMaterial) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(24.px, 20.px, 24.px, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CLText.bodyMedium(
                Localized.text('ox_usercenter.invite_link_description'),
                colorToken: ColorToken.onSurfaceVariant,
              ),
              SizedBox(height: 16.px),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: inviteLink));
                  CommonToast.instance.show(context, Localized.text('ox_common.copied_to_clipboard'));
                },
                child: Container(
                  padding: EdgeInsets.all(12.px),
                  decoration: BoxDecoration(
                    color: ColorToken.surfaceContainerHigh.of(context),
                    borderRadius: BorderRadius.circular(8.px),
                  ),
                  child: Text(
                    inviteLink,
                    style: TextStyle(
                      fontSize: 14.px,
                      color: ColorToken.onSurface.of(context),
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await Clipboard.setData(ClipboardData(text: inviteLink));
                CommonToast.instance.show(context, Localized.text('ox_common.copied_to_clipboard'));
              },
              icon: Icon(Icons.description_outlined, size: 20.px),
              label: Text(Localized.text('ox_usercenter.copy_link')),
            ),
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await Share.share(
                  inviteLink,
                  subject: Localized.text('ox_usercenter.invite_to_chat'),
                );
              },
              icon: Icon(Icons.share, size: 20.px),
              label: Text(Localized.text('ox_usercenter.share')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(Localized.text('ox_common.cancel')),
            ),
          ],
        ),
      );
    } else {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CLText.bodyMedium(
                Localized.text('ox_usercenter.invite_link_description'),
                colorToken: ColorToken.onSurfaceVariant,
              ),
              SizedBox(height: 16.px),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: inviteLink));
                  CommonToast.instance.show(context, Localized.text('ox_common.copied_to_clipboard'));
                },
                child: Container(
                  padding: EdgeInsets.all(12.px),
                  decoration: BoxDecoration(
                    color: ColorToken.surfaceContainerHigh.of(context),
                    borderRadius: BorderRadius.circular(8.px),
                  ),
                  child: Text(
                    inviteLink,
                    style: TextStyle(
                      fontSize: 14.px,
                      color: ColorToken.onSurface.of(context),
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () async {
                Navigator.pop(context);
                await Clipboard.setData(ClipboardData(text: inviteLink));
                CommonToast.instance.show(context, Localized.text('ox_common.copied_to_clipboard'));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined, size: 18.px),
                  SizedBox(width: 6.px),
                  Text(Localized.text('ox_usercenter.copy_link')),
                ],
              ),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.pop(context);
                await Share.share(
                  inviteLink,
                  subject: Localized.text('ox_usercenter.invite_to_chat'),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, size: 18.px),
                  SizedBox(width: 6.px),
                  Text(Localized.text('ox_usercenter.share')),
                ],
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(Localized.text('ox_common.cancel')),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showColorPicker({required String qrcodeValue, required String displayName}) async {
    final Color? selectedColorResult = await OXNavigator.pushPage<Color>(
      context,
      (context) => QRCodeColorPickerPage(
        initialColor: selectedColor,
        qrcodeValue: qrcodeValue,
        userName: displayName,
      ),
      type: OXPushPageType.present,
    );

    if (selectedColorResult != null) {
      changeQrColor(selectedColorResult);
    }
  }

  void _showRegenerateConfirmDialog() {
    final content = widget.inviteType == InviteType.circle
        ? Localized.text('ox_usercenter.reset_circle_invite_confirm')
        : Localized.text('ox_usercenter.regenerate_confirm_content');
    
    CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_usercenter.regenerate_invite_link'),
      content: content,
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_common.confirm'),
          value: true,
          isDefaultAction: true,
        ),
      ],
    ).then((value) {
      if (value == true) {
        _regenerateInviteLink();
      }
    });
  }
}