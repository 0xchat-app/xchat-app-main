import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import '../../utils/chat_session_utils.dart';

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
      ),
      isSectionListPage: true,
      body: ValueListenableBuilder(
        valueListenable: user$,
        builder: (context, user, _) {
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
                  ],
                ),
              ),
              Visibility(
                visible: widget.chatId == null,
                child: _buildBottomButton(),
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

  LabelItemModel _buildPubkeyItem(UserDBISAR user) {
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

  LabelItemModel _buildBioItem(UserDBISAR user) {
    final userBio = user.about ?? '';
    return LabelItemModel(
      icon: ListViewIcon(
        iconName: 'icon_setting_bio.png',
        package: 'ox_usercenter',
      ),
      title: Localized.text('ox_chat.bio'),
      value$: ValueNotifier(userBio.isEmpty ? Localized.text('ox_chat.no_bio') : userBio),
      onTap: null,
    );
  }

  Widget _buildBottomButton() {
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

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    CommonToast.instance.show(
      context, 
      '$label ${Localized.text('ox_common.copied_to_clipboard')}',
    );
  }

  void _sendMessage() async {
    await ChatSessionUtils.createSecretChatWithConfirmation(
      context: context,
      user: user$.value,
      isPushWithReplace: true,
    );
  }
}
