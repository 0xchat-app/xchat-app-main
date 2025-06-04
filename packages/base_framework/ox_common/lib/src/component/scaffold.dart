
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'platform_style.dart';

class CLScaffold extends StatelessWidget {
  const CLScaffold({
    this.appBar,
    required this.body,
    bool? extendBody,
    this.resizeToAvoidBottomInset = true,
    this.isSectionListPage = false,
  }) : extendBody = extendBody ?? appBar == null;

  final CLAppBar? appBar;
  final Widget body;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  final bool isSectionListPage;

  @override
  Widget build(BuildContext context) {
    final safeBody = extendBody ? body : SafeArea(bottom: false, child: body);
    if (PlatformStyle.isUseMaterial) {
      return Scaffold(
        appBar: appBar?.buildMaterialAppBar(context),
        body: safeBody,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      );
    } else {
      return CupertinoPageScaffold(
        navigationBar: appBar?.buildCupertinoAppBar(context),
        backgroundColor: isSectionListPage ? CupertinoColors.systemGroupedBackground : null,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        child: safeBody,
      );
    }
  }
}