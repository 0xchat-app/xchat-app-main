import 'account_path_manager.dart';
import 'login_manager.dart';

class AccountPathHelper {
  static Future<String> imageCacheDir() async {
    final currentState = LoginManager.instance.currentState;
    final account = currentState.account;
    assert(account != null, 'Account is not logged in');

    final pubkey = account?.pubkey;
    final circleId = currentState.currentCircle?.id;

    if (pubkey == null || pubkey.isEmpty) return '';
    if (circleId == null || circleId.isEmpty) return '';

    return AccountPathManager.getCircleImageCachePath(pubkey, circleId);
  }
}