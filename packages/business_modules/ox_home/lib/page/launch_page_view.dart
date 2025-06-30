import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:rive/rive.dart';
import 'package:ox_home/page/home_page.dart';

class LaunchPageView extends StatefulWidget {
  const LaunchPageView({super.key});

  @override
  State<StatefulWidget> createState() {
    return LaunchPageViewState();
  }
}

class LaunchPageViewState extends State<LaunchPageView> {
  final riveFileNames = 'Launcher';
  final stateMachineNames = 'Button';
  final riveInputs = 'Press';

  late StateMachineController? riveControllers;
  Artboard? riveArtboards;

  @override
  void initState() {
    super.initState();

    // Try auto login with LoginManager
    _tryAutoLogin().then((_) async {
      // Navigate to HomePage regardless of login status
      // HomePage will handle the login/not-login state internally
      await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
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

  /// Try auto login using LoginManager
  Future<void> _tryAutoLogin() async {
    try {
      await LoginManager.instance.autoLogin();
    } catch (e) {
      debugPrint('Auto login failed: $e');
      // Continue to HomePage, which will show login page if needed
    }
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
