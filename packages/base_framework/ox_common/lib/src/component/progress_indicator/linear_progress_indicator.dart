
import 'package:flutter/material.dart';

import '../platform_style.dart';
import '../theme_data.dart';

class CLLinearProgressIndicator extends StatelessWidget {
  const CLLinearProgressIndicator({
    super.key,
    this.progress,
    this.height,
    this.width
  });

  final double? progress;

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return _buildMaterialIndicator(context);
    } else {
      return _buildCupertinoIndicator(context);
    }
  }

  Widget _buildMaterialIndicator(BuildContext context) {
    return SizedBox(
      width: width,
      child: LinearProgressIndicator(
        value: progress,
        minHeight: height,
      ),
    );
  }

  Widget _buildCupertinoIndicator(BuildContext context) {
    final height = this.height ?? 6.0;
    final trackColor = CupertinoTrackColorEx.of(context);
    return SizedBox(
      width: width,
      child: LinearProgressIndicator(
        value: progress ?? 0.5,
        backgroundColor: trackColor,
        minHeight: height,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}