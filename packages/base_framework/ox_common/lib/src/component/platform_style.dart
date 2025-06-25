
import 'dart:io';

import 'package:flutter/foundation.dart';

class PlatformStyle {

  static const isMock = false;

  static bool _isUseMaterial = false;
  static bool get isUseMaterial => _isUseMaterial;
  // static bool get isUseMaterial => true;

  static TargetPlatform? get mockPlatform {
    if (!isMock) return null;
    return isUseMaterial
        ? TargetPlatform.android
        : TargetPlatform.iOS;
  }

  static initialized() {
    _isUseMaterial = Platform.isAndroid;
  }
}