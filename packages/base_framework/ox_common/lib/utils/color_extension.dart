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

extension GradientGrayExtension on Gradient {
  Gradient toOpacity(double opacity) {
    final gradient = this;
    if (gradient is LinearGradient) {
      return LinearGradient(
        begin: gradient.begin,
        end: gradient.end,
        stops: gradient.stops,
        tileMode: gradient.tileMode,
        transform: gradient.transform,
        colors: gradient.colors.map(
                (c) => c.withOpacity(opacity * c.opacity)
        ).toList(growable: false),
      );
    } else if (gradient is RadialGradient) {
      return RadialGradient(
        center: gradient.center,
        radius: gradient.radius,
        stops: gradient.stops,
        tileMode: gradient.tileMode,
        focal: gradient.focal,
        focalRadius: gradient.focalRadius,
        transform: gradient.transform,
        colors: gradient.colors.map(
                (c) => c.withOpacity(opacity * c.opacity)
        ).toList(growable: false),
      );
    } else if (gradient is SweepGradient) {
      return SweepGradient(
        center: gradient.center,
        startAngle: gradient.startAngle,
        endAngle: gradient.endAngle,
        stops: gradient.stops,
        tileMode: gradient.tileMode,
        transform: gradient.transform,
        colors: gradient.colors.map(
                (c) => c.withOpacity(opacity * c.opacity)
        ).toList(growable: false),
      );
    }
    return gradient;
  }

  Gradient toGray() {
    if (this is LinearGradient) {
      final g = this as LinearGradient;
      return LinearGradient(
        begin: g.begin,
        end: g.end,
        stops: g.stops,
        tileMode: g.tileMode,
        transform: g.transform,
        colors: g.colors.map((c) => c.toGray()).toList(growable: false),
      );
    } else if (this is RadialGradient) {
      final g = this as RadialGradient;
      return RadialGradient(
        center: g.center,
        radius: g.radius,
        stops: g.stops,
        tileMode: g.tileMode,
        focal: g.focal,
        focalRadius: g.focalRadius,
        transform: g.transform,
        colors: g.colors.map((c) => c.toGray()).toList(growable: false),
      );
    } else if (this is SweepGradient) {
      final g = this as SweepGradient;
      return SweepGradient(
        center: g.center,
        startAngle: g.startAngle,
        endAngle: g.endAngle,
        stops: g.stops,
        tileMode: g.tileMode,
        transform: g.transform,
        colors: g.colors.map((c) => c.toGray()).toList(growable: false),
      );
    }
    return this;
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