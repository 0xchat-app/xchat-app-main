import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_chat/widget/common_chat_widget.dart';
import 'package:ox_chat_ui/ox_chat_ui.dart';
import 'package:ox_chat/utils/general_handler/chat_general_handler.dart';
import 'package:ox_common/business_interface/ox_chat/utils.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import '../../utils/block_helper.dart';

/// Chat page for Nostr DM (ChatType.chatSingle) without MLS group.
/// Used e.g. for demo review account pre-seeded conversation.
class PrivateChatMessagePage extends StatefulWidget {
  const PrivateChatMessagePage({super.key, required this.handler});

  final ChatGeneralHandler handler;

  @override
  State<PrivateChatMessagePage> createState() => _PrivateChatMessagePageState();
}

class _PrivateChatMessagePageState extends State<PrivateChatMessagePage> {
  ChatGeneralHandler get handler => widget.handler;
  ChatSessionModelISAR get session => handler.session;

  String get _title {
    if (session.isSelfChat) {
      return Localized.text('ox_chat.file_transfer_assistant');
    }
    final other = handler.otherUser;
    if (other != null) return other.getUserShowName();
    return session.chatName ?? session.chatId;
  }

  ChatHintParam? get _bottomHintParam {
    if (session.isSelfChat) return null;
    final otherPubkey = handler.otherUser?.pubKey;
    if (otherPubkey == null) return null;
    final otherUser = Account.sharedInstance.userCache[otherPubkey]?.value;
    if (otherUser != null && BlockHelper.isUserBlocked(otherUser.pubKey)) {
      return ChatHintParam(
        Localized.text('ox_chat.user_blocked_hint'),
        _unblockOnTap,
      );
    }
    return null;
  }

  Future<void> _unblockOnTap() async {
    final other = handler.otherUser;
    if (other == null) return;
    final success = await BlockHelper.unblockUser(context, other);
    if (success && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CommonChatWidget(
      handler: handler,
      title: _title,
      showUserNames: false,
      bottomHintParam: _bottomHintParam,
    );
  }
}
