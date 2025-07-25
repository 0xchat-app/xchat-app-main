import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/ox_common.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/file_encryption_utils.dart';
import 'package:ox_common/utils/scan_utils.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../utils/theme_color.dart';
import 'common_loading.dart';
import 'common_toast.dart';

typedef DoubleClickAnimationListener = void Function();

class SmoothPageScrollPhysics extends ScrollPhysics {
  final double scrollSpeedMultiplier;

  const SmoothPageScrollPhysics({
    this.scrollSpeedMultiplier = 1.0,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  SmoothPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothPageScrollPhysics(
      scrollSpeedMultiplier: scrollSpeedMultiplier,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset * scrollSpeedMultiplier;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.toleranceFor(position);
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity * scrollSpeedMultiplier,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  double frictionFactor(double overscrollFraction) {
    return 0.1 * math.pow(1 - overscrollFraction, 2);
  }

  @override
  SpringDescription get spring {
    return SpringDescription.withDampingRatio(
      mass: 0.5,
      stiffness: 80.0,
      ratio: 1,
    );
  }

  @override
  double get minFlingVelocity => kMinFlingVelocity * 0.05;

  @override
  double get dragStartDistanceMotionThreshold => 0.1;
}

class ImageEntry {
  ImageEntry({
    required this.id,
    required this.url,
    this.decryptedKey,
    this.decryptedNonce,
  });
  final String id;
  final String url;
  final String? decryptedKey;
  final String? decryptedNonce;
}

class CommonImageGallery extends StatefulWidget {
  final List<ImageEntry> imageList;
  final int initialPage;
  final Widget? extraMenus;
  final void Function(VoidCallback nextPage)? onNextPage;
  const CommonImageGallery({
    required this.imageList, required this.initialPage, this.extraMenus, this.onNextPage});

  @override
  _CommonImageGalleryState createState() => _CommonImageGalleryState();

  static show({
    BuildContext? context,
    required List<ImageEntry> imageList,
    int initialPage = 0,
  }) {
    context ??= OXNavigator.navigatorKey.currentContext;
    if (context == null) return ;

    OXNavigator.pushPage(context, (context) => CommonImageGallery(
      imageList: imageList,
      initialPage: initialPage,
    ), type: OXPushPageType.opacity);
  }
}

class _CommonImageGalleryState extends State<CommonImageGallery>
    with TickerProviderStateMixin {
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  late ExtendedPageController _pageController;
  Animation<double>? _doubleClickAnimation;
  late AnimationController _doubleClickAnimationController;
  late AnimationController _slideEndAnimationController;
  late Animation<double> _slideEndAnimation;
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();
  bool _isPopped = false;
  double _imageDetailY = 0;
  bool _showSwiper = true;
  List<double> doubleTapScales = <double>[1.0, 2.0];
  final StreamController<bool> rebuildSwiper =
      StreamController<bool>.broadcast();
  final StreamController<double> rebuildDetail =
      StreamController<double>.broadcast();

  ScreenshotController _screenshotController = ScreenshotController();

  bool isScrollComplete = true;

  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _pageController = ExtendedPageController(
      initialPage: widget.initialPage,
      pageSpacing: 50,
      shouldIgnorePointerWhenScrolling: false,
    )..addListener(() {
        double? page = _pageController.page;
        if (page != null) {
          _offset = Offset.zero;
          isScrollComplete = page % 1 == 0;
          setState(() {});
        }
      });
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);

    _slideEndAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _slideEndAnimationController.addListener(() {
      _imageDetailY = _slideEndAnimation.value;
      if (_imageDetailY == 0) {
        _showSwiper = true;
        rebuildSwiper.add(_showSwiper);
      }
      rebuildDetail.sink.add(_imageDetailY);
    });
    if (widget.onNextPage != null) widget.onNextPage!(_nextPage);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Screenshot(
          controller: _screenshotController,
          child: GestureDetector(
            onLongPress: _showBottomMenu,
            onTap: () {
              if (isScrollComplete) {
                OXNavigator.pop(context);
              }
            },
            child: ExtendedImageSlidePage(
              key: slidePagekey,
              slideAxis: SlideAxis.both,
              slideType: SlideType.onlyImage,
              slidePageBackgroundHandler: (Offset offset, Size pageSize) =>
                  _slidePageBackgroundHandler(offset, pageSize),
              slideOffsetHandler: (
                Offset offset, {
                ExtendedImageSlidePageState? state,
              }) =>
                  _slideOffsetHandler(offset, state: state),
              slideScaleHandler: (
                Offset offset, {
                ExtendedImageSlidePageState? state,
              }) {
                return 1.0;
              },
              slideEndHandler: (
                Offset offset, {
                ExtendedImageSlidePageState? state,
                ScaleEndDetails? details,
              }) =>
                  _slideEndHandler(offset, state: state, details: details),
              resetPageDuration: const Duration(milliseconds: 1),
              onSlidingPage: (ExtendedImageSlidePageState state) {},
              child: ExtendedImageGesturePageView.builder(
                controller: _pageController,
                itemCount: widget.imageList.length,
                scrollDirection: Axis.horizontal,
                physics: widget.imageList.length == 1
                    ? NeverScrollableScrollPhysics()
                    : SmoothPageScrollPhysics(),
                canScrollPage: (GestureDetails? gestureDetails) {
                  return true;
                },
                itemBuilder: (BuildContext context, int index) {
                  final entry = widget.imageList[index];
                  return buildImageWidget(entry);
                },
                onPageChanged: (int index) {
                  print('page changed to $index');
                },
              ),
            ),
          ),
        ),
        Positioned.directional(
          end: 16,
          textDirection: Directionality.of(context),
          bottom: 56,
          child: GestureDetector(
            onTap: _widgetShotAndSave,
            child: Container(
              width: 35.px,
              height: 35.px,
              decoration: BoxDecoration(
                color: ColorToken.secondaryContainer.of(context),
                borderRadius: BorderRadius.all(
                  Radius.circular(35.px),
                ),
              ),
              alignment: Alignment.center,
              child: CommonImage(
                iconName: 'icon_download.png',
                size: 24,
                color: ColorToken.onSurface.of(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildImageWidget(ImageEntry entry) {
    ImageProvider provider;
    if (entry.url.isImageBase64) {
      provider = Base64ImageProvider(entry.url);
    } else {
      provider = CLEncryptedImageProvider(
        url: entry.url,
        decryptKey: entry.decryptedKey,
        decryptNonce: entry.decryptedNonce,
      );
    }
    return HeroWidget(
      child: ExtendedImage(
        image: provider,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return Center(
                child: CircularProgressIndicator(),
              );
            case LoadState.completed:
              return null; // Use the completed image
            case LoadState.failed:
              return Center(
                child: Text('Load failed'),
              );
          }
        },
        enableSlideOutPage: true,
        onDoubleTap: (ExtendedImageGestureState state) =>
            _onDoubleTap(state),
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: (state) {
          return GestureConfig(
            minScale: 0.9,
            animationMinScale: 0.7,
            maxScale: 3.0,
            animationMaxScale: 3.5,
            speed: 1.0,
            inertialSpeed: 100.0,
            initialScale: 1.0,
            inPageView: true,
            initialAlignment: InitialAlignment.center,
          );
        },
      ),
      tag: entry.id,
      slideType: SlideType.onlyImage,
      slidePagekey: slidePagekey,
    );
  }

  void _showBottomMenu() async {
    final List<CLPickerItem<String>> items = [
      CLPickerItem(
        label: Localized.text('ox_common.scan_qr_code'),
        value: 'scan_qr_code',
      ),
      CLPickerItem(
        label: Localized.text('ox_common.str_save_image'),
        value: 'save_image',
      ),
    ];

    final result = await CLPicker.show<String>(
      context: context,
      items: items,
    );

    if (result != null) {
      switch (result) {
        case 'scan_qr_code':
          _identifyQRCode();
          break;
        case 'save_image':
          await _widgetShotAndSave();
          break;
      }
    }
  }

  Color _slidePageBackgroundHandler(Offset offset, Size pageSize) {
    double opacity = 0.0;
    opacity = offset.distance /
        (Offset(pageSize.width, pageSize.height).distance / 2.0);
    return ThemeColor.color200.withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
  }

  bool? _slideEndHandler(
    Offset offset, {
    ExtendedImageSlidePageState? state,
    ScaleEndDetails? details,
  }) {
    _offset = Offset.zero;
    if (state == null || details == null) {
      return false;
    }

    final double velocity = details.velocity.pixelsPerSecond.dy;

    const double positionThreshold = 200;
    const double velocityThreshold = 1000;

    if (offset.dy > 10 && velocity > 100 && isScrollComplete) {
      return true;
    }

    if (offset.dy > positionThreshold &&
        velocity > velocityThreshold &&
        isScrollComplete) {
      return true;
    }

    return false;
  }

  void _onDoubleTap(ExtendedImageGestureState state) {
    ///you can use define pointerDownPosition as you can,
    ///default value is double tap pointer down postion.
    final Offset? pointerDownPosition = state.pointerDownPosition;
    final double? begin = state.gestureDetails!.totalScale;
    double end;

    //remove old
    _doubleClickAnimation?.removeListener(_doubleClickAnimationListener);

    //stop pre
    _doubleClickAnimationController.stop();

    //reset to use
    _doubleClickAnimationController.reset();

    if (begin == doubleTapScales[0]) {
      end = doubleTapScales[1];
    } else {
      end = doubleTapScales[0];
    }

    _doubleClickAnimationListener = () {
      //print(_animation.value);
      state.handleDoubleTap(
          scale: _doubleClickAnimation!.value,
          doubleTapPosition: pointerDownPosition);
    };
    _doubleClickAnimation = _doubleClickAnimationController
        .drive(Tween<double>(begin: begin, end: end));

    _doubleClickAnimation!.addListener(_doubleClickAnimationListener);

    _doubleClickAnimationController.forward();
  }

  Offset? _slideOffsetHandler(
    Offset offset, {
    ExtendedImageSlidePageState? state,
  }) {
    if (_offset != Offset.zero) {
      _offset = offset;
      return offset;
    }

    if (offset.dy < 0) {
      _offset = Offset.zero;
      return Offset(0, 0);
    }
    if (offset.dy > 1 && (-2 < offset.dx && offset.dx < 2)) {
      _offset = offset;
      return offset;
    }
    _offset = Offset.zero;
    return Offset(0, 0);
  }

  Future _widgetShotAndSave() async {
    if (widget.imageList.isEmpty) return;

    final pageIndex = _pageController.page?.round() ?? 0;
    final imageUri = widget.imageList[pageIndex].url;
    final decryptKey = widget.imageList[pageIndex].decryptedKey;
    final decryptNonce = widget.imageList[pageIndex].decryptedNonce;
    final fileName = imageUri.split('/').lastOrNull?.split('?').firstOrNull ?? '';
    final isGIF = fileName.contains('.gif');
    final isEncryptedFile = decryptKey != null;

    unawaited(OXLoading.show());

    var result;
    if (imageUri.isRemoteURL) {
      // Remote image
      final imageManager = await CLCacheManager.getCircleCacheManager(CacheFileType.image);
      try {
        File imageFile = await imageManager.getSingleFile(imageUri)
            .timeout(const Duration(seconds: 30), onTimeout: () {
          throw Exception('time out');
        });

        switch ((isGIF, isEncryptedFile)) {
          case (true, false):
            result = await ImageGallerySaverPlus.saveFile(
              imageFile.path,
              isReturnPathOfIOS: true,
            );
            break;

          case (true, true):
            final decryptedFile = await FileEncryptionUtils.decryptFile(
              encryptedFile: imageFile,
              decryptKey: decryptKey!,
              decryptNonce: decryptNonce,
            );
            result = await ImageGallerySaverPlus.saveFile(
              decryptedFile.path,
              isReturnPathOfIOS: true,
            );
            decryptedFile.delete();
            break;

          case (false, false):
            final imageData = await imageFile.readAsBytes();
            result = await ImageGallerySaverPlus.saveImage(Uint8List.fromList(imageData));
            break;

          case (false, true):
            final imageData = await FileEncryptionUtils.decryptFileInMemory(
              imageFile,
              decryptKey!,
              decryptNonce,
            );
            result = await ImageGallerySaverPlus.saveImage(Uint8List.fromList(imageData));
            break;
        }
      } catch (e) {
        unawaited(CommonToast.instance.show(context, e.toString()));
      }
    } else if (imageUri.isImageBase64) {
      final imageData = await Base64ImageProvider.decodeBase64ToBytes(imageUri);
      result = await ImageGallerySaverPlus.saveImage(imageData, quality: 100);
    } else {
      // Local image
      final imageFile = File(imageUri);
      if (decryptKey != null) {
        final decryptData = await FileEncryptionUtils.decryptFileInMemory(
          imageFile,
          decryptKey,
          decryptNonce,
        );
        result = await ImageGallerySaverPlus.saveImage(decryptData);
      } else {
        final imageData = await imageFile.readAsBytes();
        result = await ImageGallerySaverPlus.saveImage(imageData);
      }
    }

    unawaited(OXLoading.dismiss());

    if (result != null) {
              unawaited(CommonToast.instance.show(context, Localized.text('ox_common.str_saved_to_album')));
      } else {
        unawaited(CommonToast.instance.show(context, Localized.text('ox_common.str_save_failed')));
    }
  }

  Future<void> _identifyQRCode() async {
    final image = await _screenshotController.capture();
    if(image == null)return;
    OXLoading.show();
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/screenshot.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(image);

    try {
      String qrcode = await OXCommon.scanPath(imageFile.path);
      _deleteImage(imageFile.path);
      OXLoading.dismiss();
      OXNavigator.pop(context);
      ScanUtils.analysis(context, qrcode);
    } catch (e) {
      OXLoading.dismiss();
      CommonToast.instance.show(context, "str_invalid_qr_code".commonLocalized());
    }
  }

  void _deleteImage(String imagePath) {
    final file = File(imagePath);
    if (file.existsSync()) {
      file.delete().then((_) {
        print('File Deleted');
      }).catchError((error) {
        print('Error: $error');
      });
    } else {
      print('File not found');
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
}

/// make hero better when slide out
class HeroWidget extends StatefulWidget {
  const HeroWidget({
    required this.child,
    required this.tag,
    required this.slidePagekey,
    this.slideType = SlideType.onlyImage,
  });
  final Widget child;
  final SlideType slideType;
  final Object tag;
  final GlobalKey<ExtendedImageSlidePageState> slidePagekey;
  @override
  _HeroWidgetState createState() => _HeroWidgetState();
}

class _HeroWidgetState extends State<HeroWidget> {
  RectTween? _rectTween;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.tag,
      createRectTween: (Rect? begin, Rect? end) {
        _rectTween = RectTween(begin: begin, end: end);
        return _rectTween!;
      },
      // make hero better when slide out
      flightShuttleBuilder: (BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext) {
        // make hero more smoothly
        final Hero hero = (flightDirection == HeroFlightDirection.pop
            ? fromHeroContext.widget
            : toHeroContext.widget) as Hero;
        if (_rectTween == null) {
          return hero;
        }

        if (flightDirection == HeroFlightDirection.pop) {
          final bool fixTransform = widget.slideType == SlideType.onlyImage &&
              (widget.slidePagekey.currentState!.offset != Offset.zero ||
                  widget.slidePagekey.currentState!.scale != 1.0);

          final Widget toHeroWidget = (toHeroContext.widget as Hero).child;
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext buildContext, Widget? child) {
              Widget animatedBuilderChild = hero.child;

              // make hero more smoothly
              animatedBuilderChild = Stack(
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: 1 - animation.value,
                    child: UnconstrainedBox(
                      child: SizedBox(
                        width: _rectTween!.begin!.width,
                        height: _rectTween!.begin!.height,
                        child: toHeroWidget,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: animation.value,
                    child: animatedBuilderChild,
                  )
                ],
              );

              // fix transform when slide out
              if (fixTransform) {
                final Tween<Offset> offsetTween = Tween<Offset>(
                    begin: Offset.zero,
                    end: widget.slidePagekey.currentState!.offset);

                final Tween<double> scaleTween = Tween<double>(
                    begin: 1.0, end: widget.slidePagekey.currentState!.scale);
                animatedBuilderChild = Transform.translate(
                  offset: offsetTween.evaluate(animation),
                  child: Transform.scale(
                    scale: scaleTween.evaluate(animation),
                    child: animatedBuilderChild,
                  ),
                );
              }

              return animatedBuilderChild;
            },
          );
        }
        return hero.child;
      },
      child: widget.child,
    );
  }
}


class ImageGalleryOptions {
  const ImageGalleryOptions({
    this.maxScale,
    this.minScale,
  });

  /// See [PhotoViewGalleryPageOptions.maxScale].
  final dynamic maxScale;

  /// See [PhotoViewGalleryPageOptions.minScale].
  final dynamic minScale;
}
