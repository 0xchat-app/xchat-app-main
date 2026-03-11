import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/took_kit.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/utils/profile_refresh_utils.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/session_helper.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import '../../utils/chat_session_utils.dart';
import '../../utils/block_helper.dart';
import '../session/chat_message_page.dart';
import 'user_remark_settings_page.dart';

class ContactUserInfoPage extends StatefulWidget {
  final String? pubkey;
  final UserDBISAR? user;
  final String? chatId;

  ContactUserInfoPage({
    Key? key,
    this.pubkey,
    this.user,
    this.chatId,
  }) : assert(pubkey != null || user != null),
    super(key: key);

  @override
  State<ContactUserInfoPage> createState() => _ContactUserInfoPageState();
}

class _ContactUserInfoPageState extends State<ContactUserInfoPage> {
  late ValueNotifier<UserDBISAR> user$;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    prepareData();
  }

  void prepareData() {
    final pubkey = widget.user?.pubKey ?? widget.pubkey ?? '';
    user$ = Account.sharedInstance.getUserNotifier(pubkey);
    Account.sharedInstance.reloadProfileFromRelay(pubkey);
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_chat.user_detail'),
        actions: [
          CLButton.icon(
            icon: _isRefreshing ? Icons.refresh : Icons.refresh_outlined,
            onTap: _isRefreshing ? null : refreshUserProfile,
          ),
        ],
      ),
      isSectionListPage: true,
      body: ValueListenableBuilder(
        valueListenable: user$,
        builder: (context, user, _) {
          // Check if the displayed user is the current user
          final currentUserPubkey = LoginManager.instance.currentState.account?.pubkey;
          final isCurrentUser = currentUserPubkey == user.pubKey;
          return Column(
            children: [
              Expanded(
                child: CLSectionListView(
                  header: _buildHeaderWidget(user),
                  items: [
                    SectionListViewItem(
                      data: [
                        if (!isCurrentUser) _buildRemarkItem(user),
                        // _buildNIP05Item(),
                        _buildBioItem(user),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: widget.chatId == null || !isCurrentUser,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: CLLayout.horizontalPadding,
                      right: CLLayout.horizontalPadding,
                      bottom: 12.px,
                    ),
                    child: Column(
                      children: [
                        if (widget.chatId == null) _buildSendMsgButton(isCurrentUser),
                        if (widget.chatId == null && !LoginManager.instance.isMe(user.pubKey))
                          SizedBox(height: 8.px),
                        if (!LoginManager.instance.isMe(user.pubKey))
                          _buildBlockButton(user),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildHeaderWidget(UserDBISAR user) {
    final userName = user.name ?? user.shortEncodedPubkey;
    final userPubkey = user.encodedPubkey;
    return Column(
      children: [
        OXUserAvatar(
          user: user,
          size: 80.px,
        ).setPaddingOnly(top: 8.px),
        SizedBox(height: 12.px),
        CLText.titleLarge(
          userName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.px),
        GestureDetector(
          onTap: () => _copyToClipboard(userPubkey, Localized.text('ox_chat.public_key')),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 56.px),
            child: CLText.bodySmall(
              userPubkey,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              colorToken: ColorToken.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(height: 8.px),
      ],
    );
  }

  ListViewItem _buildBioItem(UserDBISAR user) {
    final userBio = user.about ?? '';
    return LabelItemModel(
      icon: ListViewIcon(
        iconName: 'icon_setting_bio.png',
        package: 'ox_usercenter',
      ),
      title: Localized.text('ox_chat.bio'),
      value$: ValueNotifier(userBio.isEmpty ? Localized.text('ox_chat.no_bio') : userBio),
      overflow: TextOverflow.fade,
      onTap: null,
    );
  }

  ListViewItem _buildRemarkItem(UserDBISAR user) {
    final userRemark = user.nickName ?? '';
    return LabelItemModel(
      icon: ListViewIcon.data(Icons.edit_note),
      title: Localized.text('ox_chat.user_remark'),
      value$: ValueNotifier(userRemark.isEmpty ? Localized.text('ox_chat.no_remark') : userRemark),
      overflow: TextOverflow.ellipsis,
      onTap: () => _navigateToRemarkSettings(user),
    );
  }

  void _navigateToRemarkSettings(UserDBISAR user) async {
    final result = await OXNavigator.pushPage(
      context,
      (context) => UserRemarkSettingsPage(
        user: user,
        previousPageTitle: Localized.text('ox_chat.user_detail'),
      ),
    );
    // Refresh user data after returning from remark settings
    if (mounted && result == true) {
      // Reload user from DB to get updated remark
      final updatedUser = await Account.sharedInstance.getUserInfo(user.pubKey, false);
      if (updatedUser != null) {
        // Update the ValueNotifier to trigger UI refresh
        Account.sharedInstance.updateOrCreateUserNotifier(updatedUser.pubKey, updatedUser);
        // Also update allContacts if user is in contacts
        if (Contacts.sharedInstance.allContacts.containsKey(user.pubKey)) {
          Contacts.sharedInstance.allContacts[user.pubKey] = updatedUser;
        }
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  Widget _buildBlockButton(UserDBISAR user) {
    return CLButton.text(
      color: _getBlockButtonType(user) == ButtonType.destructive
          ? ColorToken.error.of(context)
          : null,
      text: _getBlockButtonText(user),
      expanded: true,
      onTap: () => _blockUserOnTap(user),
    );
  }

  Widget _buildSendMsgButton([bool isSelf = false]) {
    return CLButton.filled(
      text: isSelf 
          ? Localized.text('ox_chat.file_transfer_assistant')
          : Localized.text('ox_chat.send_message'),
      expanded: true,
      onTap: _sendMessage,
    );
  }

  String _getBlockButtonText(UserDBISAR user) {
    return BlockHelper.getBlockButtonText(user);
  }

  ButtonType _getBlockButtonType(UserDBISAR user) {
    return BlockHelper.getBlockButtonType(user);
  }

  void _copyToClipboard(String text, String label) {
    TookKit.copyKey(
      context,
      text,
      '$label ${Localized.text('ox_common.copied_to_clipboard')}',
    );
  }

  void _blockUserOnTap(UserDBISAR user) async {
    final isSuccess = await BlockHelper.handleBlockUser(context, user);
    if (isSuccess) setState(() {});
  }

  void _sendMessage() async {
    if (!mounted) return;
    
    final currentUserPubkey = LoginManager.instance.currentState.account?.pubkey;
    final isCurrentUser = currentUserPubkey == user$.value.pubKey;
    
    if (isCurrentUser) {
      // Create self chat (memo/file transfer assistant)
      _createSelfChat();
    } else {
      await ChatSessionUtils.createSecretChatWithConfirmation(
        context: context,
        user: user$.value,
        isPushWithReplace: true,
      );
    }
  }

  void _createSelfChat() async {
    final myPubkey = LoginManager.instance.currentPubkey;
    if (myPubkey.isEmpty) {
      CommonToast.instance.show(context, 'Current account is null');
      return;
    }

    final circle = LoginManager.instance.currentCircle;
    if (circle == null) {
      CommonToast.instance.show(context, 'Current circle is null');
      return;
    }

    OXLoading.show();

    try {
      // Create group name for self chat
      String groupName = Localized.text('ox_chat.file_transfer_assistant');
      
      // Create MLS group with only current user (self chat)
      GroupDBISAR? groupDB = await Groups.sharedInstance.createMLSGroup(
        groupName,
        '',
        [myPubkey], // Only current user
        [myPubkey],
        [circle.relayUrl],
        onKeyPackageSelection: (pubkey, availableKeyPackages) =>
            ChatSessionUtils.onKeyPackageSelection(
              context: context,
              pubkey: pubkey,
              availableKeyPackages: availableKeyPackages,
            ),
      );

      if (groupDB == null) {
        await OXLoading.dismiss();
        CommonToast.instance.show(context, 'Failed to create memo');
        return;
      }

      await OXLoading.dismiss();

      // Create session model using SessionHelper
      final params = SessionCreateParams.fromGroup(groupDB, user$.value);
      final sessionModel = await SessionHelper.createSessionModel(params);

      // Navigate to chat page
      ChatMessagePage.open(
        context: null,
        communityItem: sessionModel,
        isPushWithReplace: true,
      );
    } catch (e) {
      await OXLoading.dismiss();
      CommonToast.instance.show(context, e.toString());
    }
  }

  void refreshUserProfile() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      final pubkey = widget.user?.pubKey ?? widget.pubkey ?? '';
      final success = await ProfileRefreshUtils.showUserProfileRefreshDialog(
        context,
        pubkey: pubkey,
      );
      if (success && mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }
}
