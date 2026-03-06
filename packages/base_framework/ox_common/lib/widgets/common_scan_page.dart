import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/ox_common.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/image_picker_utils.dart';
import 'package:ox_common/utils/permission_utils.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common_image.dart';

class CommonScanPage extends StatefulWidget {
  @override
  CommonScanPageState createState() => CommonScanPageState();
}

class CommonScanPageState extends State<CommonScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late final MobileScannerController _scannerController;
  late double _scanArea;
  bool _isProcessingScan = false;
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    _scanArea = (Adapt.screenW < 375 ||
        Adapt.screenH < 400)
        ? Adapt.px(160)
        : Adapt.px(260);
    final Size? preferredResolution = _resolvePreferredCameraResolution();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
      autoStart: true,
      cameraResolution: preferredResolution,
    );
  }

  Size? _resolvePreferredCameraResolution() {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return null;
    }
    final Iterable<ui.FlutterView> views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) {
      return null;
    }
    final ui.Size physicalSize = views.first.physicalSize;
    if (physicalSize.width <= 0 || physicalSize.height <= 0) {
      return null;
    }
    final double maxSide = math.max(physicalSize.width, physicalSize.height);
    final double minSide = math.min(physicalSize.width, physicalSize.height);
    final double normalizedWidth = _normalizeResolutionDimension(maxSide);
    final double normalizedHeight = _normalizeResolutionDimension(minSide);
    if (normalizedWidth <= 0 || normalizedHeight <= 0) {
      return null;
    }
    return Size(normalizedWidth, normalizedHeight);
  }

  double _normalizeResolutionDimension(double value) {
    const double alignmentUnit = 16.0;
    final double rounded = (value / alignmentUnit).round() * alignmentUnit;
    return math.max(alignmentUnit, rounded);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _scannerController.stop();
    }
    _scannerController.start();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: _buildCameraView(),
          ),
          Positioned(
            top: Adapt.px(100),
            left: 0,
            right: 0,
            child: Center(
              child: CLText.bodyMedium(
                'str_scan_contact_qr_hint'.commonLocalized(),
                colorToken: ColorToken.white,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned.fill(
            child: _ScannerOverlay(
              cutOutSize: _scanArea,
            ),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            bottom: Adapt.px(56),
            child: buildOptionWidget(),
          ),
        ],
      );
  }

  Widget _buildCameraView() {
    return MobileScanner(
      controller: _scannerController,
      fit: BoxFit.cover,
      onDetect: _handleBarcodeDetection,
      errorBuilder: _scannerErrorBuilder,
    );
  }

  Widget _scannerErrorBuilder(BuildContext context, MobileScannerException error) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleScannerError(error);
    });
    return Container(color: Colors.black);
  }

  Widget buildOptionWidget() {
    return Container(
      margin: EdgeInsets.only(left: Adapt.px(24), right: Adapt.px(24), top: Adapt.px(16)),
      // height: Adapt.px(105),
      width: double.infinity,
      child: Row(
        children: [

          Expanded(
            child: buildOptionButton(
              iconData: CupertinoIcons.photo,
              label: 'str_album'.commonLocalized(),
              onTap: _onPicTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOptionButton({
    String? icon,
    IconData? iconData,
    required String label,
    required GestureTapCallback onTap,
  }) {
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(
              height: Adapt.px(20),
            ),
            _itemView(icon: icon, iconData: iconData),
            SizedBox(
              height: Adapt.px(7),
            ),
            CLText.labelSmall(
              label,
              colorToken: ColorToken.white,
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _itemView({String? icon, IconData? iconData}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: CLIcon(
            iconName: 'icon_btn_bg.png',
            package: 'ox_common',
            size: 54.px,
            color: ColorToken.white.of(context),
          ),
        ),
        Center(
          child: iconData != null
              ? CLIcon(
                  icon: iconData,
                  size: 24.px,
                  color: ColorToken.black.of(context),
                )
              : CommonImage(
                  iconName: icon ?? '',
                  size: 24.px,
                  color: ColorToken.black.of(context),
                ),
        ),
      ],
    );
  }

  void _onPicTap() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    bool storagePermission = false;
    File? _imgFile;
    if (Platform.isAndroid && (await plugin.androidInfo).version.sdkInt >= 34) {
      Map<String, bool> result = await OXCommon.request34MediaPermission(1);
      bool readMediaImagesGranted = result['READ_MEDIA_IMAGES'] ?? false;
      bool readMediaVisualUserSelectedGranted = result['READ_MEDIA_VISUAL_USER_SELECTED'] ?? false;
      if (readMediaImagesGranted) {
        storagePermission = true;
      } else if (readMediaVisualUserSelectedGranted) {
        final filePaths = await OXCommon.select34MediaFilePaths(1);
        _imgFile = File(filePaths[0]);
      }
    } else {
      storagePermission = await PermissionUtils.getPhotosPermission(context);
    }
    if (storagePermission) {
      final res = await ImagePickerUtils.pickerPaths(
        galleryMode: GalleryMode.image,
        selectCount: 1,
        showGif: false,
        compressSize: 5120,
      );
      if (res.isEmpty) return;

      _imgFile = (res[0].path == null) ? null : File(res[0].path ?? '');
    } else {
      final result = await CLAlertDialog.show<bool>(
        context: context,
        title: Localized.text('ox_common.tips'),
        content: Localized.text('ox_common.str_grant_permission_photo_hint'),
        actions: [
          CLAlertAction.cancel(),
          CLAlertAction<bool>(
            label: Localized.text('ox_common.str_go_to_settings'),
            value: true,
            isDefaultAction: true,
          ),
        ],
      );

      if (result == true) {
        await openAppSettings();
      }
      return;
    }
    try {
      String qrcode = await OXCommon.scanPath(_imgFile?.path ?? '');
      OXNavigator.pop(context, qrcode);
    } catch (e) {
      CommonToast.instance.show(context, "str_invalid_qr_code".commonLocalized());
    }
  }

  void _handleBarcodeDetection(BarcodeCapture capture) {
    if (_isProcessingScan) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue ?? barcode.displayValue;
      if (value != null && value.isNotEmpty) {
        _isProcessingScan = true;
        _scannerController.stop();
        OXNavigator.pop(context, value);
        return;
      }
    }
  }

  void _handleScannerError(MobileScannerException error) {
    final details = error.errorDetails?.toString();
    final message = (details != null && details.trim().isNotEmpty)
        ? details
        : error.errorCode.name;
    if (message.isEmpty) {
      return;
    }
    if (_lastErrorMessage == message) {
      return;
    }
    _lastErrorMessage = message;
    _showMessage(context, '${"str_error".commonLocalized()}: $message');
  }

  _showMessage(BuildContext context, String message) {
    CommonToast.instance.show(context, message);
  }
}

class _ScannerOverlay extends StatelessWidget {
  final double cutOutSize;

  const _ScannerOverlay({
    required this.cutOutSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final left = (width - cutOutSize) / 2;
        final top = (height - cutOutSize) / 2 - 50;
        final cornerLength = Adapt.px(24);
        final strokeWidth = 4.px;

        return Stack(
          children: [
            CustomPaint(
              size: Size(width, height),
              painter: _ScannerOverlayBackgroundPainter(
                left: left,
                top: top,
                cutOutSize: cutOutSize,
              ),
            ),
            _CornerBorder(
              top: top,
              left: left,
              size: cornerLength,
              border: Border(
                top: BorderSide(color: Colors.white, width: strokeWidth),
                left: BorderSide(color: Colors.white, width: strokeWidth),
              ),
            ),
            _CornerBorder(
              top: top,
              right: left,
              size: cornerLength,
              border: Border(
                top: BorderSide(color: Colors.white, width: strokeWidth),
                right: BorderSide(color: Colors.white, width: strokeWidth),
              ),
            ),
            _CornerBorder(
              top: top + cutOutSize - cornerLength,
              left: left,
              size: cornerLength,
              border: Border(
                bottom: BorderSide(color: Colors.white, width: strokeWidth),
                left: BorderSide(color: Colors.white, width: strokeWidth),
              ),
            ),
            _CornerBorder(
              top: top + cutOutSize - cornerLength,
              right: left,
              size: cornerLength,
              border: Border(
                bottom: BorderSide(color: Colors.white, width: strokeWidth),
                right: BorderSide(color: Colors.white, width: strokeWidth),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CornerBorder extends StatelessWidget {
  final double size;
  final double? left;
  final double? top;
  final double? right;
  final Border border;

  const _CornerBorder({
    required this.size,
    required this.border,
    this.left,
    this.top,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(border: border),
        ),
      ),
    );
  }
}

class _ScannerOverlayBackgroundPainter extends CustomPainter {
  final double left;
  final double top;
  final double cutOutSize;

  _ScannerOverlayBackgroundPainter({
    required this.left,
    required this.top,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(left, top, cutOutSize, cutOutSize));

    final backgroundPaint = Paint()
      ..color = Colors.black45;

    canvas.drawPath(overlayPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _ScannerOverlayBackgroundPainter) {
      return true;
    }
    return left != oldDelegate.left ||
        top != oldDelegate.top ||
        cutOutSize != oldDelegate.cutOutSize;
  }
}