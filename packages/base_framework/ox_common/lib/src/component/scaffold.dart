
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';

import '../layout/layout_constant.dart';
import 'app_bar.dart';
import 'platform_style.dart';

class CLScaffold extends StatelessWidget {
  const CLScaffold({
    this.appBar,
    required this.body,
    bool? extendBody,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.bottomWidget,
    this.isSectionListPage = false,
  }) : extendBody = extendBody ?? appBar == null;

  final CLAppBar? appBar;
  final Widget body;
  final bool extendBody;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  final Widget? bottomWidget;

  final bool isSectionListPage;

  @override
  Widget build(BuildContext context) {
    Widget body = this.body;
    if (bottomWidget != null) {
      body = Stack(
        children: [
          body,
          Positioned(
            left: CLLayout.horizontalPadding,
            right: CLLayout.horizontalPadding,
            bottom: 24.px,
            child: SafeArea(
              child: bottomWidget!
            ),
          ),
        ],
      );
    }
    final safeBody = extendBody ? body : SafeArea(bottom: false, child: body);
    if (PlatformStyle.isUseMaterial) {
      return Scaffold(
        appBar: appBar?.buildMaterialAppBar(context),
        backgroundColor: backgroundColor,
        body: safeBody,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      );
    } else {
      return CupertinoPageScaffold(
        navigationBar: appBar?.buildCupertinoAppBar(context),
        backgroundColor: backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        child: safeBody,
      );
    }
  }

  static Color defaultPageBgColor(BuildContext context, bool isSectionListPage) {
    if (!PlatformStyle.isUseMaterial && isSectionListPage) {
      return CupertinoColors.systemGroupedBackground.resolveFrom(context);
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }
}