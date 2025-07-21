
import 'package:flutter/widgets.dart';
import 'progress_indicator/linear_progress_indicator.dart';
import 'progress_indicator/circular_progress_indicator.dart';

class CLProgressIndicator {

  static Widget circular({
    double? progress,
    double? size,
    Color? color,
  }) {
    return CLCircularProgressIndicator(
      progress: progress,
      size: size,
      color: color,
    );
  }

  static Widget linear({
    double? progress,
    double? width,
    double? height,
  }) {
    return CLLinearProgressIndicator(progress: progress, width: width, height: height,);
  }
}