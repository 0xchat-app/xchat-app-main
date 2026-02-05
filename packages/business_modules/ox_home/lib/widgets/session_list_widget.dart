import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/circle_join_utils.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_chat/page/session/find_people_page.dart';
import 'package:ox_usercenter/page/settings/qr_code_display_page.dart';
import 'package:ox_usercenter/utils/invite_link_manager.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:chatcore/chat-core.dart';

import '../page/archived_chats_page.dart';
import 'session_list_data_controller.dart';
import 'session_list_item_widget.dart';
import 'session_view_model.dart';

class SessionListWidget extends StatefulWidget {
  const SessionListWidget({
    super.key,
    required this.ownerPubkey,
    required this.circle,
  });

  final String ownerPubkey;
  final Circle circle;

  @override
  State<SessionListWidget> createState() => _SessionListWidgetState();
}

class _SessionListWidgetState extends State<SessionListWidget> {
  SessionListDataController? controller;
  bool _isPaidRelay = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _checkPaidRelayAndAdmin();
  }

  @override
  void didUpdateWidget(SessionListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize controller if ownerPubkey or circle changed
    if (oldWidget.ownerPubkey != widget.ownerPubkey ||
        oldWidget.circle.id != widget.circle.id) {
      _initializeController();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeController() {
    if (widget.ownerPubkey.isNotEmpty) {
      controller = SessionListDataController(widget.ownerPubkey, widget.circle);
      controller!.initialized();
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Check if current circle is paid relay and if current user is admin
  Future<void> _checkPaidRelayAndAdmin() async {
    try {
      _isPaidRelay = CircleApi.isPaidRelay(widget.circle.relayUrl);
      
      if (_isPaidRelay) {
        // Check admin status
        final currentPubkey = LoginManager.instance.currentPubkey;
        try {
          final tenantInfo = await CircleMemberService.sharedInstance.getTenantInfo();
          final tenantAdminPubkey = tenantInfo['tenant_admin_pubkey'] as String?;
          if (tenantAdminPubkey != null && tenantAdminPubkey.isNotEmpty) {
            _isAdmin = tenantAdminPubkey.toLowerCase() == currentPubkey.toLowerCase();
          }
        } catch (e) {
          // Default to false on error
          _isAdmin = false;
        }
      }
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error checking paid relay and admin status: $e');
      _isPaidRelay = false;
      _isAdmin = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if controller is not initialized or ownerPubkey is empty
    if (controller == null || widget.ownerPubkey.isEmpty) {
      return Center(
        child: CLProgressIndicator.circular(),
      );
    }

    return ValueListenableBuilder(
      valueListenable: controller!.sessionList$,
      builder: (context, sessionList, _) {
        return ValueListenableBuilder(
          valueListenable: controller!.hasArchivedChats$,
          builder: (context, hasArchived, _) {
            if (sessionList.isEmpty && !hasArchived) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              padding:
                  EdgeInsets.only(bottom: Adapt.bottomSafeAreaHeightByKeyboard),
              itemBuilder: (context, index) {
                if (hasArchived && index == sessionList.length) {
                  // This is the footer
                  return _buildArchivedChatsFooter(context);
                }
                return itemBuilder(context, sessionList[index]);
              },
              separatorBuilder: (context, index) {
                if (hasArchived && index == sessionList.length - 1) {
                  // No separator before footer
                  return const SizedBox.shrink();
                }
                return buildSeparator(context, index, sessionList);
              },
              itemCount: sessionList.length + (hasArchived ? 1 : 0),
            );
          },
        );
      },
    );
  }

  Widget? itemBuilder(BuildContext context, SessionListViewModel item) {
    return SessionListItemWidget(
      item: item,
      sessionListController: controller,
      showPinnedBackground: true,
    );
  }

  Widget buildSeparator(BuildContext context, int index, List<SessionListViewModel> sessionList) {
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -120.px),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.px),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Empty state icon
              CommonImage(
                iconName: 'empty.png',
                size: 120.px,
                package: 'ox_home',
              ),

              SizedBox(height: 32.px),

              // Title
              CLText.titleLarge(
                Localized.text('ox_chat.welcome_to_xchat'),
                colorToken: ColorToken.onSurface,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.px),

              // Description
              CLText.bodyMedium(
                Localized.text('ox_chat.welcome_description'),
                colorToken: ColorToken.onSurfaceVariant,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),

              SizedBox(height: 32.px),

              // Find People to Chat button (only for non-paid relay)
              if (!_isPaidRelay)
                CLButton.filled(
                  expanded: true,
                  onTap: () => _navigateToFindPeople(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PlatformStyle.isUseMaterial
                            ? Icons.person_add
                            : CupertinoIcons.person_add,
                        size: 20.px,
                        color: ColorToken.white.of(context),
                      ),
                      SizedBox(width: 8.px),
                      CLText.bodyMedium(
                        Localized.text('ox_chat.add_friends_to_chat'),
                        customColor: ColorToken.white.of(context),
                      ),
                    ],
                  ),
                ),

              // SizedBox(height: 16.px),

              // Invite Friends link
              // For paid relay: only show if admin
              // For regular relay: always show
              if ((_isPaidRelay && _isAdmin) || !_isPaidRelay)
                CupertinoButton(
                  onPressed: () => _navigateToInviteFriends(context),
                  padding: EdgeInsets.zero,
                  child: CLText.bodyMedium(
                    _isPaidRelay
                        ? Localized.text('ox_chat.invite_to_circle_link')
                        : Localized.text('ox_chat.invite_friends_link'),
                    colorToken: ColorToken.onSurfaceXChat,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFindPeople(BuildContext context) {
    OXNavigator.pushPage(
      context,
      (context) => const FindPeoplePage(),
    );
  }

  void _navigateToInviteFriends(BuildContext context) {
    final circle = LoginManager.instance.currentCircle;
    if (circle == null) {
      CircleJoinUtils.showJoinCircleGuideDialog(context: OXNavigator.rootContext);
      return;
    }
    
    // For paid relay, show circle invite QR code
    if (_isPaidRelay) {
      OXNavigator.pushPage(
        context,
        (context) => QRCodeDisplayPage(
          inviteType: InviteType.circle,
          circle: circle,
        ),
      );
    } else {
      // For regular relay, show keypackage invite QR code
      OXNavigator.pushPage(
        context,
        (context) => const QRCodeDisplayPage(),
      );
    }
  }

  Widget _buildArchivedChatsFooter(BuildContext context) {
    return CupertinoButton(
      onPressed: () => _navigateToArchivedChats(context),
      padding: EdgeInsets.symmetric(vertical: 8.px),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CLText.bodyMedium(
            Localized.text('ox_chat.archived_chats'),
            customColor: ColorToken.primary.of(context),
          ),
          SizedBox(width: 4.px),
          Icon(
            CupertinoIcons.chevron_right,
            size: 16.px,
            color: ColorToken.primary.of(context),
          ),
        ],
      ),
    );
  }

  void _navigateToArchivedChats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchivedChatsPage(
          ownerPubkey: widget.ownerPubkey,
          circle: widget.circle,
        ),
      ),
    );
  }
}
