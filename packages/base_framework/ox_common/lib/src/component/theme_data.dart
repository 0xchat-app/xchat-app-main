
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_style.dart';

class CLThemeData {
  const CLThemeData({
    required this.materialLight,
    required this.materialDark,
    required this.cupertinoLight,
    required this.cupertinoDark,
  });

  /// MaterialApp themes
  final ThemeData materialLight;
  final ThemeData materialDark;

  /// CupertinoApp themes
  final CupertinoThemeData cupertinoLight;
  final CupertinoThemeData cupertinoDark;

  factory CLThemeData.fromSeed(Color? seed, {bool useMaterial3 = true}) {
    // Material
    final materialInputTheme = InputDecorationTheme(
      filled: false,
      border: const OutlineInputBorder(),
    );
    final materialProgressTheme = ProgressIndicatorThemeData(
      year2023: false,
    );
    final lightMaterial = ThemeData(
      platform: PlatformStyle.mockPlatform,
      colorSchemeSeed: seed,
      brightness: Brightness.light,
      useMaterial3: useMaterial3,
      inputDecorationTheme: materialInputTheme,
      progressIndicatorTheme: materialProgressTheme,
    );
    final darkMaterial = ThemeData(
      platform: PlatformStyle.mockPlatform,
      colorSchemeSeed: seed,
      brightness: Brightness.dark,
      useMaterial3: useMaterial3,
      inputDecorationTheme: materialInputTheme,
      progressIndicatorTheme: materialProgressTheme,
    );

    // Cupertino
    final lightCupertino = CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: seed,
    );
    final darkCupertino = CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: seed,
    );

    return CLThemeData(
      materialLight: lightMaterial,
      materialDark: darkMaterial,
      cupertinoLight: lightCupertino,
      cupertinoDark: darkCupertino,
    );
  }
}

// https://developer.apple.com/design/human-interface-guidelines/progress-indicators
class CupertinoTrackColorEx {
  static Color of(BuildContext context) => CupertinoDynamicColor.withBrightness(
    color: const Color(0xFFF2F2F7),
    darkColor: const Color(0xFF3A3A3C),
  ).resolveFrom(context);
}