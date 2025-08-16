import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/ox_common.dart';
import 'package:ox_common/upload/file_type.dart';
import 'package:ox_common/upload/upload_utils.dart';
import 'package:ox_common/utils/file_utils.dart';
import 'package:ox_common/utils/image_picker_utils.dart';
import 'package:ox_common/utils/permission_utils.dart';
import 'package:ox_common/utils/platform_utils.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:async';
import 'package:extended_image/extended_image.dart';
import 'package:ox_common/utils/file_server_helper.dart';
import 'package:ox_usercenter/page/settings/file_server_page.dart';
import 'package:ox_common/navigator/navigator.dart';

class AvatarDisplayPage extends StatefulWidget {
  final String? avatarUrl;
  final bool showEditButton;
  final String? heroTag;

  const AvatarDisplayPage({
    this.avatarUrl,
    this.showEditButton = false,
    this.heroTag,
    Key? key,
  }) : super(key: key);

  /// Static method to open avatar display page with Hero animation
  /// [heroTag] is required for Hero animation
  /// [avatarUrl] can be network URL or null for default avatar
  /// [showEditButton] controls whether edit functionality is available
  static Future<T?> open<T>(
    BuildContext context, {
    required String heroTag,
    String? avatarUrl,
    bool showEditButton = false,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AvatarDisplayPage(
          avatarUrl: avatarUrl,
          showEditButton: showEditButton,
          heroTag: heroTag,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
        reverseTransitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  State<AvatarDisplayPage> createState() => _AvatarDisplayPageState();
}

class _AvatarDisplayPageState extends State<AvatarDisplayPage>
    with SingleTickerProviderStateMixin {
  String? _currentAvatarUrl;

  // Slide-page & gesture related
  final GlobalKey<ExtendedImageSlidePageState> _slidePageKey =
      GlobalKey<ExtendedImageSlidePageState>();

  late AnimationController _doubleClickAnimationController;
  Animation<double>? _doubleClickAnimation;
  late void Function() _doubleClickAnimationListener;

  final List<double> _doubleTapScales = <double>[1.0, 2.0];

  @override
  void initState() {
    super.initState();
    _currentAvatarUrl = widget.avatarUrl;

    _doubleClickAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _doubleClickAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        actions: [
          CLButton.icon(
            icon: Icons.edit,
            onTap: _showEditOptions,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _buildAvatarWidget(),
    );
  }

  Widget _buildAvatarWidget() {
    Widget avatar = LayoutBuilder(
      builder: (context, constraints) {
        final double size = constraints.maxWidth;
        return SizedBox(
          width: size,
          height: size,
          child: _buildAvatarImage(size: size),
        );
      },
    );

    if (widget.heroTag != null) {
      avatar = Hero(tag: widget.heroTag!, child: avatar);
    }

    return ExtendedImageSlidePage(
      key: _slidePageKey,
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
      slidePageBackgroundHandler: _slidePageBackgroundHandler,
      slideEndHandler: _slideEndHandler,
      child: Center(child: avatar),
    );
  }

  Widget _buildAvatarImage({
    required double size,
  }) {
    final imageUrl = _currentAvatarUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildDefaultAvatar();
    }

    if (OXUserAvatar.isClientAvatar(imageUrl)) {
      return OXUserAvatar(
        imageUrl: imageUrl,
        isCircular: false,
        size: size,
      );
    }

    return CLCachedImageProviderStateful(
      imageUrl: imageUrl,
      builder: (context, provider, loading, error) {
        if (loading) {
          return Center(child: CLProgressIndicator.circular());
        }
        if (provider == null || error != null) {
          provider = AssetImage('icon_user_default.png', package: 'ox_common');
        }
        return ExtendedImage(
          image: provider,
          fit: BoxFit.cover,
          enableSlideOutPage: true,
          onDoubleTap: _onDoubleTap,
          mode: ExtendedImageMode.gesture,
          loadStateChanged: (state) {
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                return Center(child: CLProgressIndicator.circular());
              case LoadState.failed:
                return _buildDefaultAvatar();
              case LoadState.completed:
                return null;
            }
          },
          initGestureConfigHandler: (state) {
            return GestureConfig(
              minScale: 1.0,
              animationMinScale: 0.7,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: false,
              initialAlignment: InitialAlignment.center,
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return CommonImage(
      iconName: 'icon_user_default.png',
      fit: BoxFit.cover,
      package: 'ox_common',
    );
  }

  Future<void> _showEditOptions() async {
    final result = await CLPicker.show<AvatarAction>(
      context: context,
      title: 'Change Avatar',
      items: [
        CLPickerItem(
          label: 'str_album'.commonLocalized(),
          value: AvatarAction.gallery,
        ),
        if (PlatformUtils.isMobile)
          CLPickerItem(
            label: Localized.text('ox_usercenter.camera'),
            value: AvatarAction.camera,
          ),
        CLPickerItem(
          label: Localized.text('ox_usercenter.removePhoto'),
          value: AvatarAction.remove,
          isDestructive: true,
        ),
      ],
    );

    if (result != null) {
      await _handleAvatarAction(result);
    }
  }

  Future<void> _handleAvatarAction(AvatarAction action) async {
    switch (action) {
      case AvatarAction.gallery:
        final imgFile = await _openGallery();
        if (imgFile != null) {
          await _uploadAndUpdateAvatar(imgFile);
        }
        break;
      case AvatarAction.camera:
        final imgFile = await _openCamera();
        if (imgFile != null) {
          await _uploadAndUpdateAvatar(imgFile);
        }
        break;
      case AvatarAction.remove:
        await _updateUserAvatar(null);
        break;
    }
  }

  Future<void> _uploadAndUpdateAvatar(File imageFile) async {
    OXLoading.show();

    try {
      // Upload image to server
      final result = await UploadUtils.uploadFile(
        fileType: FileType.image,
        file: imageFile,
        filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (result.isSuccess && result.url.isNotEmpty) {
        await _updateUserAvatar(result.url);
      } else {
        CommonToast.instance.show(
          context,
          'Upload failed: ${result.errorMsg ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      CommonToast.instance.show(context, 'Upload failed: $e');
    }
  }

  Future<void> _updateUserAvatar(String? avatarUrl) async {
    final user = Account.sharedInstance.me;
    if (user == null) {
      CommonToast.instance.show(context, 'User not found');
      return;
    }

    try {
      user.picture = avatarUrl ?? '';
      final updatedUser = await Account.sharedInstance.updateProfile(user);
      OXLoading.dismiss();
      
      if (updatedUser != null) {
        setState(() {
          _currentAvatarUrl = avatarUrl;
        });
        CommonToast.instance.show(context, 'Avatar updated successfully');
      } else {
        CommonToast.instance.show(context, 'Failed to update avatar');
      }
    } catch (e) {
      CommonToast.instance.show(context, 'Update failed: $e');
    }
  }

  Future<File?> _openGallery() async {
    // Ensure file server configured
    final ok = await FileServerHelper.ensureFileServerConfigured(
      context,
      onGoToSettings: () => OXNavigator.pushPage(
        context,
        (_) => FileServerPage(previousPageTitle: Localized.text('ox_common.back')),
      ),
    );
    if (!ok) return null;

    File? imgFile;
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    bool storagePermission = false;
    
    if (Platform.isAndroid && (await plugin.androidInfo).version.sdkInt >= 34) {
      Map<String, bool> result = await OXCommon.request34MediaPermission(1);
      bool readMediaImagesGranted = result['READ_MEDIA_IMAGES'] ?? false;
      bool readMediaVisualUserSelectedGranted = result['READ_MEDIA_VISUAL_USER_SELECTED'] ?? false;
      
      if (readMediaImagesGranted) {
        storagePermission = true;
      } else if (readMediaVisualUserSelectedGranted) {
        final filePaths = await OXCommon.select34MediaFilePaths(1);
        return File(filePaths[0]);
      }
    } else {
      storagePermission = await PermissionUtils.getPhotosPermission(context);
    }

    if (!storagePermission) return null;

    try {
      if (PlatformUtils.isDesktop) {
        List<Media>? list = await FileUtils.importClientFile(1);
        if (list != null && list.isNotEmpty) {
          imgFile = File(list[0].path ?? '');
        }
      } else {
        final res = await ImagePickerUtils.pickerPaths(
          galleryMode: GalleryMode.image,
          selectCount: 1,
          showGif: false,
          compressSize: 2048,
        );
        if (res.isNotEmpty) {
          imgFile = (res[0].path == null) ? null : File(res[0].path ?? '');
        }
      }
    } catch (e) {
      CommonToast.instance.show(context, 'Failed to select image: $e');
    }

    return imgFile;
  }

  Future<File?> _openCamera() async {
    // Ensure file server configured
    final ok = await FileServerHelper.ensureFileServerConfigured(
      context,
      onGoToSettings: () => OXNavigator.pushPage(
        context,
        (_) => FileServerPage(previousPageTitle: Localized.text('ox_common.back')),
      ),
    );
    if (!ok) return null;

    File? imgFile;
    Map<Permission, PermissionStatus> statuses = await [Permission.camera].request();
    
    if (statuses[Permission.camera]!.isGranted) {
      try {
        Media? res = await ImagePickerUtils.openCamera(
          cameraMimeType: CameraMimeType.photo,
          compressSize: 1024,
        );
        if (res != null) {
          imgFile = File(res.path ?? '');
        }
      } catch (e) {
        CommonToast.instance.show(context, 'Failed to take photo: $e');
      }
    } else {
      PermissionUtils.showPermission(context, statuses);
    }
    
    return imgFile;
  }

  // ---------- Gesture helpers ----------

  void _onDoubleTap(ExtendedImageGestureState state) {
    final Offset? pointerDownPosition = state.pointerDownPosition;
    final double? begin = state.gestureDetails!.totalScale;
    double end;

    _doubleClickAnimation?.removeListener(_doubleClickAnimationListener);
    _doubleClickAnimationController.stop();
    _doubleClickAnimationController.reset();

    if (begin == _doubleTapScales[0]) {
      end = _doubleTapScales[1];
    } else {
      end = _doubleTapScales[0];
    }

    _doubleClickAnimationListener = () {
      state.handleDoubleTap(
        scale: _doubleClickAnimation!.value,
        doubleTapPosition: pointerDownPosition,
      );
    };

    _doubleClickAnimation = _doubleClickAnimationController
        .drive(Tween<double>(begin: begin, end: end));

    _doubleClickAnimation!.addListener(_doubleClickAnimationListener);
    _doubleClickAnimationController.forward();
  }

  Color _slidePageBackgroundHandler(Offset offset, Size pageSize) {
    double opacity =
        offset.distance / (Offset(pageSize.width, pageSize.height).distance / 2.0);
    return Colors.black.withValues(alpha: (1.0 - opacity).clamp(0.0, 1.0));
  }

  bool? _slideEndHandler(
    Offset offset, {
    ExtendedImageSlidePageState? state,
    ScaleEndDetails? details,
  }) {
    if (details == null) return false;

    final double velocity = details.velocity.pixelsPerSecond.dy;

    const double positionThreshold = 200;
    const double velocityThreshold = 1000;

    // Support both upward and downward slide
    if (offset.dy.abs() > 10 && velocity.abs() > 100) {
      return true;
    }

    if (offset.dy.abs() > positionThreshold &&
        velocity.abs() > velocityThreshold) {
      return true;
    }

    return false;
  }
}

enum AvatarAction {
  gallery,
  camera,
  remove,
} 