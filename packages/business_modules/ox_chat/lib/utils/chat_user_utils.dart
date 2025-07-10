import 'package:chatcore/chat-core.dart';

class ChatUserUtils {
  static Future<List<UserDBISAR>> getAllUsers() async {
    final myPubkey = Account.sharedInstance.me?.pubKey;
    if (myPubkey == null || myPubkey.isEmpty) return [];

    final allUsers = <UserDBISAR>[];

    // Add cached users
    final cachedUsers = Account.sharedInstance.userCache.values
        .map((e) => e.value)
        .toList();
    allUsers.addAll(cachedUsers);

    // Add following list users
    try {
      final followingUsers = await Account.sharedInstance.syncFollowingListFromDB(myPubkey);
      allUsers.addAll(followingUsers);
    } catch (e) {
      print('Error syncing following list from DB: $e');
    }

    // Remove duplicates by pubKey and filter out current user
    final seenPubkeys = <String>{};
    final uniqueUsers = <UserDBISAR>[];
    
    for (final user in allUsers) {
      if (user.pubKey != myPubkey && !seenPubkeys.contains(user.pubKey)) {
        uniqueUsers.add(user);
        seenPubkeys.add(user.pubKey);
      }
    }

    return uniqueUsers;
  }
} 