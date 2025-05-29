
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ox_theme/ox_theme.dart';

/// iOS Router Style
class SlideLeftToRightRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin {
  final WidgetBuilder builder;
  final bool fullscreenDialog;
  final RouteSettings settings;

  SlideLeftToRightRoute({
    required this.builder,
    required this.settings,
    required this.fullscreenDialog
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog);

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  String? get title => '';

  @override
  bool get maintainState => true;
}

class TransparentPageRoute<T> extends PageRouteBuilder<T> {
  final RouteSettings settings;

  TransparentPageRoute({
    required WidgetBuilder builder,
    required this.settings,
  }) : super(
    opaque: false,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: child,
      );
    },
  );
}

class OpacityAnimationPageRoute<T> extends PageRouteBuilder<T> {

  final RouteSettings settings;

  OpacityAnimationPageRoute({
    required WidgetBuilder builder,
    required this.settings,
  }) : super(
    opaque: false,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: child,
      );
    },
  );
}

class NoAnimationPageRoute<T> extends PageRouteBuilder<T> {
  final RouteSettings settings;

  NoAnimationPageRoute({
    required WidgetBuilder builder,
    required this.settings,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

class OXCupertinoSheetRoute<T> extends CupertinoSheetRoute<T> {
  OXCupertinoSheetRoute({
    super.settings,
    required WidgetBuilder builder,
  }) : super(
    builder: (ctx) => FractionallySizedBox(
      alignment: Alignment.topCenter,
      // Fix issue in CupertinoSheetRoute where only offset was applied without reducing content height, causing bottom overflow
      heightFactor: 1 - 0.08,
      child: MediaQuery.removePadding(
        context: ctx,
        removeTop: true,
        child: Navigator(
          observers: [
            HeroController(),
          ],
          onGenerateRoute: (_) => CupertinoPageRoute(
            builder: builder,
          ),
        ),
      ),
    ),
  );

  @override
  void install() {
    super.install();
    animation?.addStatusListener(_onStatusChanged);
  }

  void _onStatusChanged(AnimationStatus status) async {
    if (status == AnimationStatus.dismissed) {
      // HACK: delegatedTransition in CupertinoSheetRoute calls setSystemUIOverlayStyle
      // too early (before the sheet is fully removed), so we wait an extra 100ms
      // to ensure the sheet is actually dismissed before restoring the app's overlay style.
      await Future.delayed(Duration(milliseconds: 100));
      final style = themeManager.themeStyle.toOverlayStyle;
      SystemChrome.setSystemUIOverlayStyle(style);
    }
  }

  @override
  void dispose() {
    animation?.removeStatusListener(_onStatusChanged);
    super.dispose();
  }
}