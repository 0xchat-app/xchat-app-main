
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';

class SidebarScaffoldController {
  late Function(BuildContext ctx) _open;

  void open(BuildContext ctx) {
    _open(ctx);
  }
}

class SidebarScaffold extends StatefulWidget {
  SidebarScaffold({
    Key? key,
    required this.body,
    required this.sidebarBuilder,
    SidebarScaffoldController? controller,
  })  : controller = controller ?? SidebarScaffoldController(),
        super(key: key);

  final Widget body;
  final WidgetBuilder sidebarBuilder;
  final SidebarScaffoldController controller;

  @override
  State<SidebarScaffold> createState() => _SidebarScaffoldState();
}

class _SidebarScaffoldState extends State<SidebarScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller._open = (ctx) {
      if (PlatformStyle.isUseMaterial) {
        _scaffoldKey.currentState?.openDrawer();
      } else {
        _showSidebar(ctx);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          width: 332.px,
          child: widget.sidebarBuilder(context),
        ),
        drawerEdgeDragWidth: 100.px,
        body: widget.body,
      );
    }
    // Cupertino style: simplified, modal sidebar
    return CLScaffold(body: widget.body);
  }

  void _showSidebar(BuildContext context) {
    OXNavigator.pushPage(
      context,
      widget.sidebarBuilder,
      type: OXPushPageType.present,
    );
  }
}
