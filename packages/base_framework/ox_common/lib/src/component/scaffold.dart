
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'platform_style.dart';

class CLScaffold extends StatelessWidget {
  const CLScaffold({
    this.appBar,
    required this.body,
    bool? extendBody,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.isSectionListPage = false,
  }) : extendBody = extendBody ?? appBar == null;

  final CLAppBar? appBar;
  final Widget body;
  final bool extendBody;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  final bool isSectionListPage;

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: backgroundColor ?? defaultCupertinoPageBgColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        child: safeBody,
      );
    }
  }

  Color? get defaultCupertinoPageBgColor {
    return isSectionListPage ? CupertinoColors.systemGroupedBackground : null;
  }

  static Color defaultPageBgColor(BuildContext context, bool isSectionListPage) {
    if (!PlatformStyle.isUseMaterial && isSectionListPage) {
      return CupertinoColors.systemGroupedBackground;
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }
}