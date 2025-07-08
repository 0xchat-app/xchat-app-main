import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ox_common/component.dart';
import 'package:ox_home/page/home_page.dart';

class LaunchPageView extends StatefulWidget {
  const LaunchPageView({super.key});

  @override
  State<StatefulWidget> createState() {
    return LaunchPageViewState();
  }
}

class LaunchPageViewState extends State<LaunchPageView> {

  @override
  void initState() {
    super.initState();

    // Navigate to HomePage after first frame is rendered
    // Auto login is now handled in AppInitializer.userInitializer()
    WidgetsBinding.instance.waitUntilFirstFrameRasterized.then((_) {
      Navigator.of(context).pushReplacement(
          CustomRouteFadeIn(const HomePage())
      );
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      body: Container(),
    );
  }
}

class CustomRouteFadeIn<T> extends PageRouteBuilder<T> {
  final Widget widget;
  CustomRouteFadeIn(this.widget)
      : super(
          transitionDuration: const Duration(seconds: 1),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation1,
            Animation<double> animation2,
          ) =>
              widget,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation1,
            Animation<double> animation2,
            Widget child,
          ) {
            return FadeTransition(
              opacity: Tween(begin: 0.0, end: 2.0).animate(
                CurvedAnimation(
                  parent: animation1,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
              child: child,
            );
          },
        );

  // The color used behind the presented page, matching iOS present style background.
  @override
  Color? get barrierColor => Colors.black;
}
