
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'platform_style.dart';
import 'theme_data.dart';

class CLApp extends StatelessWidget {
  CLApp({
    super.key,
    this.navigatorKey,
    this.navigatorObservers = const [],
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.themeData,
    this.themeMode,
    this.home,
    this.builder,
  });

  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;

  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;

  final CLThemeData? themeData;
  final ThemeMode? themeMode;

  final Widget? home;
  final TransitionBuilder? builder;

  final bool debugShowCheckedModeBanner = false;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: navigatorObservers,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        themeMode: themeMode,
        theme: themeData?.materialLight,
        darkTheme: themeData?.materialDark,
        home: home,
        builder: builder,
      );
    } else {
      CupertinoThemeData? theme;
      final brightness = View.of(context).platformDispatcher.platformBrightness;
      switch ((themeMode, brightness)) {
        case (ThemeMode.light, _):
        case (ThemeMode.system, Brightness.light):
          theme = themeData?.cupertinoLight;
          break;
        case (ThemeMode.dark, _):
        case (ThemeMode.system, Brightness.dark):
          theme = themeData?.cupertinoDark;
          break;
        default:
          break;
      }
      return CupertinoApp(
        navigatorKey: navigatorKey,
        navigatorObservers: navigatorObservers,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        theme: theme,
        home: home,
        builder: builder,
      );
    }
  }
}