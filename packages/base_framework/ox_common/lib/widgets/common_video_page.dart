import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:chewie/chewie.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:ox_common/widgets/common_toast.dart';

class CommonVideoPage extends StatefulWidget {
  final String videoUrl;
  const CommonVideoPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<CommonVideoPage> createState() => _CommonVideoPageState();

  static show(String videoUrl, {BuildContext? context}) {
    return OXNavigator.pushPage(
      context,
      (context) => CommonVideoPage(videoUrl: videoUrl),
      fullscreenDialog: true,
      type: OXPushPageType.present,
    );
  }
}

class _CommonVideoPageState extends State<CommonVideoPage> {
  final GlobalKey<_CustomControlsState> _customControlsKey = GlobalKey<_CustomControlsState>();
  ChewieController? _chewieController;
  late VideoPlayerController _videoPlayerController;
  int? bufferDelay;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializePlayer();
    });
  }

  @override
  void dispose() {
    OXLoading.dismiss();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _onVideoTap() {
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
      _customControlsKey.currentState?.showControls();
    } else {
      _videoPlayerController.play();
      _customControlsKey.currentState?.showControls();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isShowVideoWidget = _chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized;
    if (!isShowVideoWidget) {
      OXLoading.show();
      return Container(
        color: ThemeColor.color180,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned(
              top: 100,
              left: 24,
              child: GestureDetector(
                onTap: () => OXNavigator.pop(context),
                child: Container(
                  width: 35.px,
                  height: 35.px,
                  decoration: BoxDecoration(
                    color: ThemeColor.color180,
                    borderRadius: BorderRadius.all(
                      Radius.circular(35.px),
                    ),
                  ),
                  child: Center(
                    child: CommonImage(
                      iconName: 'circle_close_icon.png',
                      size: 24.px,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    OXLoading.dismiss();
    Size size = MediaQuery.of(context).size;
    return Container(
      color: ThemeColor.color180,
      child: Stack(
        children: [
          GestureDetector(
            onTap: _onVideoTap,
            child: SafeArea(
              child: Chewie(
                controller: _chewieController!,
              ),
            ),
          ),
          GestureDetector(
            onTap: toggleFullScreen,
            child: Container(
              margin: EdgeInsets.only(
                top: 100,
                left: size.width - 50,
              ),
              width: 30.px,
              height: 30.px,
              child: CommonImage(
                iconName: 'video_screen_icon.png',
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleFullScreen() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  Future<void> initializePlayer() async {
    try {
      if (RegExp(r'https?:\/\/').hasMatch(widget.videoUrl)) {
        final cacheManager = await CLCacheManager.getCircleCacheManager(CacheFileType.video);
        final fileInfo = await cacheManager.getFileFromCache(widget.videoUrl);
        if (fileInfo != null) {
          _videoPlayerController = VideoPlayerController.file(fileInfo.file);
        } else {
          _videoPlayerController =
              VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
          cacheVideo();
        }
      } else {
        File videoFile = File(widget.videoUrl);
        _videoPlayerController = VideoPlayerController.file(videoFile);
      }
      await Future.wait([_videoPlayerController.initialize()]);
      _createChewieController();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> cacheVideo() async {
    try {
      print('Starting cache process...');
      final cacheManager = await CLCacheManager.getCircleCacheManager(CacheFileType.video);
      await cacheManager.downloadFile(widget.videoUrl);
      print('Video cached successfully');
    } catch (e) {
      print('Error caching video: $e');
    }
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      customControls: CustomControls(
        key: _customControlsKey,
        videoPlayerController: _videoPlayerController,
        videoUrl: widget.videoUrl,
      ),
      showControls: true,
      videoPlayerController: _videoPlayerController,
      hideControlsTimer: const Duration(seconds: 3),
      autoPlay: true,
      looping: false,
    );
  }
}

class CustomControlsOption {
  bool isDragging;
  bool isVisible;
  CustomControlsOption({required this.isDragging, required this.isVisible});
}

class CustomControls extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final String videoUrl;
  const CustomControls(
      {Key? key, required this.videoPlayerController, required this.videoUrl})
      : super(key: key);

  @override
  _CustomControlsState createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls> {
  ValueNotifier<CustomControlsOption> customControlsStatus =
      ValueNotifier(CustomControlsOption(
    isVisible: true,
    isDragging: false,
  ));

  Timer? _hideTimer;
  List<double> videoSpeedList = [0.5, 1.0, 1.5, 2.0];
  ValueNotifier<double> videoSpeedNotifier = ValueNotifier(1.0);

  @override
  void initState() {
    super.initState();
    widget.videoPlayerController.addListener(() {
      if (!widget.videoPlayerController.value.isPlaying &&
          !customControlsStatus.value.isDragging) {
        customControlsStatus.value = CustomControlsOption(
          isVisible: true,
          isDragging: false,
        );
      }
      if (mounted) {
        setState(() {});
      }
    });
    hideControlsAfterDelay();
  }

  void hideControlsAfterDelay() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      customControlsStatus.value = CustomControlsOption(
        isVisible: false,
        isDragging: customControlsStatus.value.isDragging,
      );
    });
  }

  void showControls() {
    customControlsStatus.value = CustomControlsOption(
      isVisible: true,
      isDragging: customControlsStatus.value.isDragging,
    );
    hideControlsAfterDelay();
  }

  void _toggleControls() {
    if (customControlsStatus.value.isVisible &&
        widget.videoPlayerController.value.isPlaying) {
      hideControlsAfterDelay();
    } else {
      customControlsStatus.value = CustomControlsOption(
        isVisible: false,
        isDragging: customControlsStatus.value.isDragging,
      );
      _hideTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: _toggleControls,
            child: Container(),
          ),
        ),
        _buildProgressBar(),
        _buildBottomOption(),
      ],
    );
  }

  Widget _buildBottomOption() {
    return ValueListenableBuilder<CustomControlsOption>(
      valueListenable: customControlsStatus,
      builder: (context, value, child) {
        if (!value.isVisible) return Container();
        return Positioned(
          bottom: 10.0,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => OXNavigator.pop(context),
                child: CommonImage(
                  iconName: 'video_del_icon.png',
                  size: 30.px,
                ),
              ),
              _buildPlayPause(),
              GestureDetector(
                onTap: () async {
                  await OXLoading.show();
                  if (RegExp(r'https?:\/\/').hasMatch(widget.videoUrl)) {
                    var result;
                    final cacheManager = await CLCacheManager.getCircleCacheManager(CacheFileType.video);
                    final fileInfo = await cacheManager.getFileFromCache(widget.videoUrl);
                    if (fileInfo != null) {
                      result =
                          await ImageGallerySaverPlus.saveFile(fileInfo.file.path);
                    } else {
                      var appDocDir = await getTemporaryDirectory();
                      String savePath = appDocDir.path + "/temp.mp4";
                      await Dio().download(widget.videoUrl, savePath);
                      result = await ImageGallerySaverPlus.saveFile(savePath);
                    }

                    if (result['isSuccess'] == true) {
                      await OXLoading.dismiss();
                      CommonToast.instance.show(context, 'Save successful');
                    }
                  } else {
                    final result =
                        await ImageGallerySaverPlus.saveFile(widget.videoUrl);
                    if (result['isSuccess'] == true) {
                      await OXLoading.dismiss();
                      CommonToast.instance.show(context, 'Save successful');
                    }
                  }
                },
                child: CommonImage(
                  iconName: 'video_down_icon.png',
                  size: 30,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayPause() {
    return ValueListenableBuilder<CustomControlsOption>(
      valueListenable: customControlsStatus,
      builder: (context, value, child) {
        String iconName = 'video_palyer_icon.png';

        if (widget.videoPlayerController.value.isPlaying ||
            value.isDragging ||
            !value.isVisible) {
          iconName = 'video_stop_icon.png';
        }
        return GestureDetector(
          onTap: () {
            if (widget.videoPlayerController.value.isPlaying) {
              widget.videoPlayerController.pause();

              showControls();
            } else {
              widget.videoPlayerController.play();

              hideControlsAfterDelay();
            }
          },
          child: CommonImage(
            iconName: iconName,
            size: 30.px,
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return ValueListenableBuilder<CustomControlsOption>(
      valueListenable: customControlsStatus,
      builder: (context, value, child) {
        if (!value.isVisible) return Container();
        return Positioned(
          bottom: 40.0,
          left: 0,
          right: 0,
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20.px),
                width: 40.px,
                child: Text(
                  _formatDuration(
                      widget.videoPlayerController.value.position),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: CustomVideoProgressIndicator(
                    controller: widget.videoPlayerController,
                    callback: _progressCallback,
                  ),
                ).setPadding(
                  EdgeInsets.symmetric(horizontal: 10.px),
                ),
              ),
              Container(
                width: 40.px,
                margin: EdgeInsets.only(right: 20.px),
                child: Text(
                  _formatDuration(
                      widget.videoPlayerController.value.duration),
                  style: TextStyle(
                    color: ThemeColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ).setPaddingOnly(bottom: 10.px),
        );
      },
    );
  }

  void _progressCallback(bool isStart) {
    if (isStart) {
      _hideTimer?.cancel();
      if (widget.videoPlayerController.value.isPlaying) {
        widget.videoPlayerController.pause();
      }
    } else {
      if (!widget.videoPlayerController.value.isPlaying) {
        widget.videoPlayerController.play();
      }
      hideControlsAfterDelay();
    }
    customControlsStatus.value = CustomControlsOption(
      isDragging: isStart,
      isVisible: customControlsStatus.value.isVisible,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}

class CustomVideoProgressIndicator extends StatelessWidget {
  final VideoPlayerController controller;
  final Function callback;

  const CustomVideoProgressIndicator(
      {super.key, required this.controller, required this.callback});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.position.asStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        Duration position = snapshot.data ?? Duration.zero;
        final totalDuration = controller.value.duration.inMilliseconds;
        double progress = 0;
        if (totalDuration != 0) {
          progress = position.inMilliseconds / controller.value.duration.inMilliseconds;
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (details) {
                callback(true);
                _dragUpdate(context, constraints, details);
              },
              onHorizontalDragEnd: (details) {
                callback(false);
              },
              onHorizontalDragUpdate: (details) =>
                  _dragUpdate(context, constraints, details),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        height: 5, // Thin progress bar
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ThemeColor.color160,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: LinearProgressIndicator(
                          value: progress,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(ThemeColor.purple2),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                    Positioned(
                      left: constraints.maxWidth * progress -
                          20, // Adjust for circle size
                      child: GestureDetector(
                        onPanUpdate: (details) =>
                            _dragUpdate(context, constraints, details),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _dragUpdate(context, constraints, details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset offset = box.globalToLocal(details.globalPosition);
    double newProgress = offset.dx / constraints.maxWidth;
    if (newProgress < 0) newProgress = 0;
    if (newProgress > 1) newProgress = 1;
    controller.seekTo(controller.value.duration * newProgress);
  }
}
