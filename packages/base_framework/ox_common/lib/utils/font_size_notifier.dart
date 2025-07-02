import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';

///Title: font_size_notifier
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2024
///@author Michael
///CreateTime: 2024/11/18 15:28

final ValueNotifier<double> textScaleFactorNotifier = ValueNotifier(1.0);

/// Get formatted text size display value
/// This method provides a consistent way to format text size for display
/// across different parts of the application
String getFormattedTextSize(double scale) {
  return '${TextScaler.linear(scale).scale(14.sp).round()}';
}