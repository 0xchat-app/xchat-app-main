
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/business_interface/ox_usercenter/interface.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';

import 'home_header_components.dart';

class HomeScaffold extends StatefulWidget {
  HomeScaffold({
    super.key,
    required this.body,
  });

  final Widget body;

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  List<CircleItem> circleList = [
    CircleItem(name: 'Damus', level: 0,  relayUrl: 'wss://relay.damus.io/'),
    CircleItem(name: '0xChat', level: 1,  relayUrl: 'wss://relay.0xchat.com/'),
  ];
  final ValueNotifier<CircleItem?> selectedCircle$ = ValueNotifier(null);
  final ValueNotifier<bool> isShowExtendBody$ = ValueNotifier(false);

  Duration get extendBodyDuration => const Duration(milliseconds: 200);



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final headerComponents = HomeHeaderComponents(
      circles: circleList,
      selectedCircle$: selectedCircle$,
      onCircleSelected: _onCircleSelected,
      avatarOnTap: _avatarOnTap,
      nameOnTap: _nameOnTap,
      addOnTap: _addOnTap,
      joinOnTap: _joinOnTap,
      paidOnTap: _paidOnTap,
      isShowExtendBody$: isShowExtendBody$,
      extendBodyDuration: extendBodyDuration,
    );

    if (PlatformStyle.isUseMaterial) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: headerComponents.buildAppBar(context),
        drawer: Drawer(
          width: 332.px,
          child: OXUserCenterInterface.settingSliderBuilder(context),
        ),
        drawerEdgeDragWidth: 100.px,
        body: buildBody(headerComponents),
      );
    }
    // Cupertino style: simplified, modal sidebar
    return Scaffold(
      appBar: headerComponents.buildAppBar(context),
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      body: buildBody(headerComponents),
    );
  }

  Widget buildBody(HomeHeaderComponents components) {
    return Stack(
      children: [
        widget.body,
        Positioned.fill(
          child: components.buildMask(),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder(
            valueListenable: isShowExtendBody$,
            builder: (context, isShowExtendBody, __) {
              return AnimatedSlide(
                offset: isShowExtendBody ? Offset.zero : const Offset(0, -1),
                duration: extendBodyDuration,
                child: components.buildCircleList(context),
              );
            }
          ),
        ),
      ],
    );
  }

  void _showSidebar(BuildContext context) {
    OXNavigator.pushPage(
      context,
      OXUserCenterInterface.settingSliderBuilder,
      type: OXPushPageType.present,
    );
  }

  void _avatarOnTap() {
    if (PlatformStyle.isUseMaterial) {
      _scaffoldKey.currentState?.openDrawer();
    } else {
      _showSidebar(context);
    }
  }

  void _nameOnTap() {
    isShowExtendBody$.value = !isShowExtendBody$.value;
  }

  void _addOnTap() {
  }

  void _joinOnTap() {
  }

  void _paidOnTap() {
  }

  void _onCircleSelected(CircleItem newSelected) {
    selectedCircle$.value = newSelected;
  }
}
