import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'package:ox_common/utils/took_kit.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/utils/profile_refresh_utils.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_common/login/login_manager.dart';
import '../../utils/chat_session_utils.dart';
import '../../utils/block_helper.dart';

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
                        _buildPubkeyItem(user),
                        // _buildNIP05Item(),
                        _buildBioItem(user),
                      ],
                    ),
                    if (!LoginManager.instance.isMe(user.pubKey))
                      SectionListViewItem.button(
                        text: _getBlockButtonText(user),
                        onTap: () => _blockUserOnTap(user),
                        type: _getBlockButtonType(user),
                      )
                  ],
                ),
              ),
              Visibility(
                visible: widget.chatId == null && !isCurrentUser,
                child: _buildSendMsgButton(),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildHeaderWidget(UserDBISAR user) {
    final userName = user.name ?? user.shortEncodedPubkey;
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
        SizedBox(height: 8.px),
      ],
    );
  }

  ListViewItem _buildPubkeyItem(UserDBISAR user) {
    final userPubkey = user.encodedPubkey;
    return LabelItemModel(
      icon: ListViewIcon.data(Icons.key),
      title: Localized.text('ox_chat.public_key'),
      isCupertinoAutoTrailing: false,
      maxLines: 1,
      value$: ValueNotifier(userPubkey.truncate(24)),
      onTap: () => _copyToClipboard(userPubkey, Localized.text('ox_chat.public_key')),
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

  Widget _buildSendMsgButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: CLLayout.horizontalPadding,
          right: CLLayout.horizontalPadding,
          bottom: 12.px,
        ),
        child: CLButton.filled(
          text: Localized.text('ox_chat.send_message'),
          expanded: true,
          onTap: _sendMessage,
        ),
      ),
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
    await ChatSessionUtils.createSecretChatWithConfirmation(
      context: context,
      user: user$.value,
      isPushWithReplace: true,
    );
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
