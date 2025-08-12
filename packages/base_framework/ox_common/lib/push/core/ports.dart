abstract class ForegroundState {
  bool isAppInForeground();
  bool isThreadOpen(String threadId);
}

abstract class PermissionGateway {
  Future<bool> notificationsAllowed();
}

abstract class MuteStore {
  bool isMuted(String threadId);
}

abstract class UnreadCounter {
  int unreadCount();
}

abstract class DedupeStore {
  bool seen(String messageId);   // returns true if already seen
  void markSeen(Iterable<String> ids);
}

abstract class Notifier {
  Future<void> showMessage({
    required String threadId,
    required String title,
    required String body,
    required bool high,
  });
  Future<void> cancelAll();
}