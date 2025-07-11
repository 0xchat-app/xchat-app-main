import 'package:flutter/material.dart';
import 'package:ox_chat/page/contacts/groups/group_info_page.dart';
import 'package:ox_chat/widget/common_chat_widget.dart';
import 'package:ox_chat/utils/general_handler/chat_general_handler.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/smart_group_avatar.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';

class BitchatChannelMessagePage extends StatefulWidget {
  final ChatGeneralHandler handler;

  const BitchatChannelMessagePage({
    super.key,
    required this.handler,
  });

  @override
  State<BitchatChannelMessagePage> createState() => _BitchatChannelMessagePageState();
}

class _BitchatChannelMessagePageState extends State<BitchatChannelMessagePage> {
  ChatGeneralHandler get handler => widget.handler;
  ChatSessionModelISAR get session => handler.session;

  @override
  void initState() {
    super.initState();
    prepareData();
  }

  void prepareData() {}

  @override
  Widget build(BuildContext context) {
    return CommonChatWidget(
      handler: handler,
      title: session.chatName,
      actions: [
        Container(
          alignment: Alignment.center,
          child: SmartGroupAvatar(
            size: 36.px,
            isClickable: false,
            onTap: () async {
              OXNavigator.pushPage(context, (_) => GroupInfoPage(groupId: '123',));
            },
          ),
        ),
      ],
      showUserNames: true,
    );
  }
}
