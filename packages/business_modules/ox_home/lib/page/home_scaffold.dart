
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_chat/page/session/chat_message_page.dart';
import 'package:ox_common/business_interface/ox_usercenter/interface.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/account_models.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_localizable/ox_localizable.dart';

import 'home_header_components.dart';
import '../widgets/session_list_widget.dart';
import '../widgets/session_view_model.dart';
import '../widgets/circle_empty_widget.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({
    super.key,
  });

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
  Widget build(BuildContext context) {
    final headerComponents = HomeHeaderComponents(
      circles: circleList,
      selectedCircle$: selectedCircle$,
      onCircleSelected: _onCircleSelected,
      avatarOnTap: _avatarOnTap,
      nameOnTap: _nameOnTap,
      addOnTap: _addOnTap,
      joinOnTap: _handleJoinCircle,
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
        drawerEdgeDragWidth: 50.px,
        resizeToAvoidBottomInset: false,
        body: buildBody(headerComponents),
      );
    }
    // Cupertino style: simplified, modal sidebar
    return Scaffold(
      appBar: headerComponents.buildAppBar(context),
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      resizeToAvoidBottomInset: false,
      body: buildBody(headerComponents),
    );
  }

  Widget buildBody(HomeHeaderComponents components) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: _buildMainContent(),
        ),
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

  Widget _buildMainContent() {
    return ValueListenableBuilder<LoginState>(
      valueListenable: LoginManager.instance.state$,
      builder: (context, loginState, child) {
        final loginAccount = loginState.account;
        final loginCircle = loginState.currentCircle;

        if (loginAccount == null) {
          // This shouldn't happen since HomePage should handle login check
          return const Center(child: CircularProgressIndicator());
        }
        
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: loginCircle != null
              ? buildSessionList(loginAccount, loginCircle)
              : CircleEmptyWidget(
                  onJoinCircle: _handleJoinCircle,
                  onCreatePaidCircle: _handleCreatePaidCircle,
                ),
        );
      },
    );
  }

  Widget buildSessionList(AccountModel loginAccount, Circle circle) {
    return SessionListWidget(
      ownerPubkey: loginAccount.pubkey,
      circle: circle,
      itemOnTap: sessionItemOnTap,
    );
  }

  void sessionItemOnTap(SessionListViewModel item) {
    final session = item.sessionModel;
    final unreadMessageCount = session.unreadCount;

    ChatMessagePage.open(
      context: context,
      communityItem: session,
      unreadMessageCount: unreadMessageCount,
    ).then((_) {
      item.rebuild();
    });

    session.unreadCount = 0;
    OXChatBinding.sharedInstance.updateChatSession(
      session.chatId,
      unreadCount: 0,
    );

    item.rebuild();
  }

  void _handleJoinCircle() {
    debugPrint('HomeScaffold: Join Circle button tapped');
    
    CLDialog.showInputDialog(
      context: context,
      title: Localized.text('ox_home.join_circle_title'),
      description: Localized.text('ox_home.join_circle_description'),
      inputLabel: Localized.text('ox_home.join_circle_input_label'),
      confirmText: Localized.text('ox_home.add'),
      onConfirm: (relayUrl) async {
        // Validate URL format
        if (!_isValidRelayUrl(relayUrl)) {
          throw Exception(Localized.text('ox_common.invalid_url_format'));
        }
        
        // Try to join circle through LoginManager
        final success = await LoginManager.instance.joinCircle(relayUrl);
        return success;
      },
    );
  }

  bool _isValidRelayUrl(String url) {
    // Basic URL validation
    if (url.isEmpty) return false;
    
    // Check if it's a valid URL or relay address
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    
    // Check for common relay URL patterns
    return url.startsWith('wss://') || 
           url.startsWith('ws://') || 
           url.contains('.') && !url.contains(' ');
  }

  void _handleCreatePaidCircle() {
    debugPrint('HomeScaffold: Create Paid Circle button tapped');
    // TODO: Navigate to create paid circle page
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

  void _paidOnTap() {
  }

  void _onCircleSelected(CircleItem newSelected) {
    selectedCircle$.value = newSelected;
  }
}
