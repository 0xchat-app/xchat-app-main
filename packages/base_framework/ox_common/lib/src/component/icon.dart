import 'package:flutter/widgets.dart';
import 'package:ox_common/utils/adapt.dart';
import 'color_token.dart';
import 'theme_data.dart';

class CLIcon extends StatelessWidget {
  const CLIcon({
    super.key,
    this.icon,
    this.iconName = '',
    this.package = '',
    this.size,
    this.color,
    this.fit,
    this.useThemeGradient = false,
  });

  static double get generalIconSize => 24.px;

  final IconData? icon;
  final String iconName;
  final String package;
  final double? size;
  final Color? color;
  final BoxFit? fit;

  final bool useThemeGradient;

  @override
  Widget build(BuildContext context) {
    final double iconSize = size ?? generalIconSize;

    if (!useThemeGradient) {
      return _buildBase(context, iconSize);
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return CLThemeData.themeGradientOf(context).createShader(bounds);
      },
      child: _buildBase(
        context,
        iconSize,
      ),
    );
  }

  Widget _buildBase(BuildContext context, double iconSize) {
    final color = this.color ?? ColorToken.primary.of(context);
    if (icon != null) {
      return Icon(
        icon,
        size: iconSize,
        color: color,
      );
    }

    if (iconName.isEmpty) {
      return SizedBox.square(dimension: iconSize);
    }

    return Image.asset(
      'assets/images/$iconName',
      width: iconSize,
      height: iconSize,
      color: color,
      package: package,
      fit: fit,
    );
  }
}