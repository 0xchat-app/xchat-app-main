import 'package:chatcore/chat-core.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_common/business_interface/ox_chat/utils.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_chat_ui/ox_chat_ui.dart';

class BlockHelper {
  static bool isUserBlocked(String pubKey) {
    return Contacts.sharedInstance.inBlockList(pubKey);
  }

  static String getBlockButtonText(UserDBISAR user) {
    final isBlocked = isUserBlocked(user.pubKey);
    return isBlocked 
        ? Localized.text('ox_chat.unmute_unblock_user')
        : Localized.text('ox_chat.mute_block_user');
  }

  static ButtonType getBlockButtonType(UserDBISAR user) {
    final isBlocked = isUserBlocked(user.pubKey);
    return isBlocked 
        ? ButtonType.primary
        : ButtonType.destructive;
  }

  static Future<bool> blockUser(BuildContext context, UserDBISAR user) async {
    final userName = user.getUserShowName();
    final isBlock = await CLAlertDialog.show(
      context: context,
      title: Localized.text('ox_chat.block_dialog_title')
          .replaceAll(r'${userName}', userName),
      content: Localized.text('ox_chat.block_dialog_content')
          .replaceAll(r'${userName}', userName),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_chat.block'),
          value: true,
          isDestructiveAction: true,
        ),
      ],
    );

    if (isBlock != true) {
      return false;
    }

    await OXLoading.show();
    final pubKey = user.pubKey;
    final okEvent = await Contacts.sharedInstance.addToBlockList(pubKey);
    await OXLoading.dismiss();
    if (!okEvent.status) {
      CommonToast.instance.show(
        context,
        okEvent.message,
      );
    }

    return okEvent.status;
  }

  static Future<bool> unblockUser(BuildContext context, UserDBISAR user) async {
    await OXLoading.show();
    final pubKey = user.pubKey;
    final okEvent = await Contacts.sharedInstance.removeBlockList([pubKey]);
    await OXLoading.dismiss();
    if (!okEvent.status) {
      CommonToast.instance.show(
        context,
        okEvent.message,
      );
    }
    return okEvent.status;
  }

  static Future<bool> handleBlockUser(BuildContext context, UserDBISAR user) async {
    final isBlocked = isUserBlocked(user.pubKey);
    if (isBlocked) {
      return unblockUser(context, user);
    } else {
      return blockUser(context, user);
    }
  }
}
