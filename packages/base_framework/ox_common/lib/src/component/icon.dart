import 'package:flutter/widgets.dart';
import 'package:ox_common/utils/adapt.dart';

class CLIcon extends StatelessWidget {
  const CLIcon({
    super.key,
    this.icon,
    this.iconName = '',
    this.package = '',
    this.size,
    this.color,
    this.fit,
  });

  static double get generalIconSize => 24.px;

  final IconData? icon;

  final String iconName;
  final String package;
  final double? size;
  final Color? color;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? generalIconSize;
    if (icon != null) {
      return Icon(
        icon,
        size: size,
        color: color,
      );
    }
    return Image.asset(
      'assets/images/$iconName',
      width: size,
      height: size,
      color: color,
      package: package,
      fit: fit,
    );
  }
}