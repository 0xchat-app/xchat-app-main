import 'package:chatcore/chat-core.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/utils/bitchat_user_helper.dart';

class ChatUserUtils {
  static Future<List<UserDBISAR>> getAllUsers() async {
    final circleType = LoginManager.instance.currentCircle?.type;
    if (circleType == null) return [];

    switch (circleType) {
      case CircleType.relay:
        return _getRelayUserList();
      case CircleType.bitchat:
        return _getBitChatUserList();
    }
  }

  static Future<List<UserDBISAR>> _getRelayUserList() async {

    final myPubkey = LoginManager.instance.currentPubkey;
    if (myPubkey.isEmpty) return [];

    final users = <UserDBISAR>[];

    // Add cached users
    final cachedUsers = Account.sharedInstance.userCache.values
        .map((e) => e.value)
        .toList();
    users.addAll(cachedUsers);

    // Add following list users
    try {
      final followingUsers = await Account.sharedInstance.syncFollowingListFromDB(myPubkey);
      users.addAll(followingUsers);
    } catch (e) {
      print('Error syncing following list from DB: $e');
    }

    // Remove duplicates by pubKey and filter out current user
    final seenPubkeys = <String>{};
    final uniqueUsers = <UserDBISAR>[];

    for (final user in users) {
      if (user.pubKey != myPubkey && !seenPubkeys.contains(user.pubKey)) {
        uniqueUsers.add(user);
        seenPubkeys.add(user.pubKey);
      }
    }

    return uniqueUsers;
  }

  static Future<List<UserDBISAR>> _getBitChatUserList() async {
    return BitchatUserHelper.getCurrentUsers();
  }
} 