
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_theme/ox_theme.dart';

/// Parameter description:
/// package When not transferred, read the common image under ox_common, if not empty, read the image resource under a plugin
/// uIf 'useTheme' is false, the images in assets/images are read; if true, the images in dark and light are read
///
class CommonImage extends StatelessWidget{

  final String iconName;
  ///Whether to use a theme image
  final bool useTheme;
  final Color? color;
  final double? height;
  final double? width;
  final BoxFit? fit;
  ///plugin name
  final String? package;

  CommonImage({
    required this.iconName,
    this.useTheme = false,
    this.color,
    double? height,
    double? width,
    double? size,
    this.package = 'ox_common',
    this.fit,
  }): this.height = size ?? height,
      this.width = size ?? width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
        useTheme ? ThemeManager.images('assets/images/$iconName') : 'assets/images/$iconName',
        width: this.width,
        height: this.height,
        color: this.color,
        package: this.package,
        fit: this.fit,
      );
  }
}

class CommonIconButton extends StatelessWidget {
  CommonIconButton({
    required this.iconName,
    this.useTheme = false,
    this.color,
    double? size,
    double? iconSize,
    this.package = 'ox_common',
    this.fit,
    required this.onPressed,
  }): this.height = size,
      this.width = size,
      this.iconHeight = iconSize,
      this.iconWidth = iconSize;

  final String iconName;
  ///Whether to use a theme image
  final bool useTheme;
  final Color? color;
  final double? height;
  final double? width;
  final double? iconHeight;
  final double? iconWidth;
  final BoxFit? fit;
  ///plugin name
  final String? package;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: CommonImage(
          iconName: iconName,
          height: iconHeight,
          width: iconWidth,
          color: color,
          package: package,
        ),
      ),
    );
  }
}