import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';

class SidebarScaffoldController {
  late VoidCallback _open;

  void open() {
    _open();
  }
}

class SidebarScaffold extends StatefulWidget {
  SidebarScaffold({
    Key? key,
    required this.body,
    required this.sidebar,
    SidebarScaffoldController? controller,
  })  : controller = controller ?? SidebarScaffoldController(),
        super(key: key);

  final Widget body;
  final Widget sidebar;
  final SidebarScaffoldController controller;

  @override
  State<SidebarScaffold> createState() => _SidebarScaffoldState();
}

class _SidebarScaffoldState extends State<SidebarScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller._open = () {
      if (PlatformStyle.isUseMaterial) {
        _scaffoldKey.currentState?.openDrawer();
      } else {
        _showSidebar(context);
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
          child: widget.sidebar,
        ),
        drawerEdgeDragWidth: 100.px,
        body: widget.body,
      );
    }
    // Cupertino style: simplified, modal sidebar
    return widget.body;
  }

  void _showSidebar(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: double.infinity,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: widget.sidebar,
          ),
        ),
      ),
    );
  }
}
