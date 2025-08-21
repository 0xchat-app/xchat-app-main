import 'dart:math';
import 'package:flutter/painting.dart';

extension ColorX on Color {
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final l = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final l = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  Color saturate([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final s = (hsl.saturation + amount).clamp(0.0, 1.0);
    return hsl.withSaturation(s).toColor();
  }

  Color desaturate([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final s = (hsl.saturation - amount).clamp(0.0, 1.0);
    return hsl.withSaturation(s).toColor();
  }

  Color toGray() {
    final hsl = HSLColor.fromColor(this);
    return hsl.withSaturation(0).toColor();
  }

  Color rotateHue(double degrees) {
    final hsl = HSLColor.fromColor(this);
    final h = (hsl.hue + degrees) % 360;
    return hsl.withHue(h < 0 ? h + 360 : h).toColor();
  }

  Color ensureContrastOnWhite({double minRatio = 4.5, bool preferDarken = true}) {
    const white = Color(0xFFFFFFFF);
    Color c = this;

    if (_contrastRatio(c, white) >= minRatio) return c;

    for (int i = 0; i < 30; i++) {
      c = preferDarken ? c.darken(0.02) : c.lighten(0.02);
      if (_contrastRatio(c, white) >= minRatio) break;
    }
    return c;
  }
}

double _relativeLuminance(Color c) {
  double chan(int v) {
    final cs = v / 255.0;
    return cs <= 0.03928 ? cs / 12.92 : pow((cs + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = chan(c.red), g = chan(c.green), b = chan(c.blue);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final l1 = max(la, lb), l2 = min(la, lb);
  return (l1 + 0.05) / (l2 + 0.05);
}