import 'package:flutter/foundation.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:isar/isar.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:convert/convert.dart';
import 'package:ox_common/utils/extension.dart';
import 'database_manager.dart';
import 'login_models.dart';
import 'account_models.dart';

class LoginUserNotifier {
  LoginUserNotifier._();

  static final LoginUserNotifier _instance = LoginUserNotifier._();
  static LoginUserNotifier get instance => _instance;

  ValueNotifier<String> get encodedPubkey$ => LoginManager.instance._userInfo$
      .map((userInfo) => userInfo?.encodedPubkey ?? '');

  ValueNotifier<String> get name$ => LoginManager.instance._userInfo$
      .map((userInfo) {
        if (userInfo == null) return '';

        final name = userInfo.name;
        if (name != null && name.isNotEmpty) return name;

        return userInfo.shortEncodedPubkey;
      });

  ValueNotifier<String> get bio$ => LoginManager.instance._userInfo$
      .map((userInfo) => userInfo?.about ?? '');

  ValueNotifier<String> get avatarUrl$ => LoginManager.instance._userInfo$
      .map((userInfo) => userInfo?.picture ?? '');
}

/// Login manager
///
/// Manages user account and circle login/logout logic, including:
/// - Account login/logout
/// - Circle management and switching
/// - Login state persistence
/// - Auto-login flow
/// - Database reference tracking
class LoginManager {
  LoginManager._internal();

  static final LoginManager _instance = LoginManager._internal();
  static LoginManager get instance => _instance;

  // State management
  final ValueNotifier<LoginState> _state$ = ValueNotifier(LoginState());
  ValueListenable<LoginState> get state$ => _state$;
  LoginState get currentState => _state$.value;

  Circle? get currentCircle => currentState.currentCircle;
  bool get isLoginCircle => currentCircle != null;

  // User info management for UI updates (separate from login state)
  ValueNotifier<UserDBISAR?> _userInfo$ = ValueNotifier<UserDBISAR?>(null);

  // Observer management
  final List<LoginManagerObserver> _observers = [];

  // Persistence storage keys
  static const String _keyLastPubkey = 'login_manager_last_pubkey';
  // _keyLastCircleId 已移除，现在使用 AccountModel.lastLoginCircleId 存储
}

/// Account management related methods
extension LoginManagerAccount on LoginManager {
  /// Login with private key
  ///
  /// [privateKey] User's private key (unencrypted)
  /// Returns whether login succeeded, failure notified via observer callbacks
  Future<bool> loginWithPrivateKey(String privateKey) async {
    try {
      // 1. Validate private key format
      if (!_isValidPrivateKey(privateKey)) {
        _notifyLoginFailure(const LoginFailure(
          type: LoginFailureType.invalidKeyFormat,
          message: 'Invalid private key format',
        ));
        return false;
      }

      // 2. Generate public key
      final pubkey = _generatePubkeyFromPrivate(privateKey);
      if (pubkey.isEmpty) {
        _notifyLoginFailure(const LoginFailure(
          type: LoginFailureType.errorEnvironment,
          message: 'Failed to generate public key from private key',
        ));
        return false;
      }

      // 3. Unified account login
      return _loginAccount(
        pubkey: pubkey,
        loginType: LoginType.nesc,
        privateKey: privateKey,
      );

    } catch (e) {
      _notifyLoginFailure(LoginFailure(
        type: LoginFailureType.errorEnvironment,
        message: 'Login failed: $e',
      ));
      return false;
    }
  }

  /// Login with NostrConnect URL
  ///
  /// [nostrConnectUrl] NostrConnect URI for remote signing
  /// Returns whether login succeeded, failure notified via observer callbacks
  Future<bool> loginWithNostrConnect(String nostrConnectUrl) async {
    try {
      String pubkey = await Account.getPublicKeyWithNIP46URI(nostrConnectUrl);
      if (pubkey.isEmpty) {
        _notifyLoginFailure(const LoginFailure(
          type: LoginFailureType.errorEnvironment,
          message: 'Failed to get public key from NostrConnect URI',
        ));
        return false;
      }

      // Unified account login
      return await _loginAccount(
        pubkey: pubkey,
        loginType: LoginType.remoteSigner,
        nostrConnectUri: nostrConnectUrl,
      );

    } catch (e) {
      _notifyLoginFailure(LoginFailure(
        type: LoginFailureType.errorEnvironment,
        message: 'NostrConnect login failed: $e',
      ));
      return false;
    }
  }

  /// Login with Amber (Android) or external signer
  ///
  /// Returns whether login succeeded, failure notified via observer callbacks
  Future<bool> loginWithAmber() async {
    try {
      // Check if Amber is installed (Android only)
      bool isInstalled = await CoreMethodChannel.isInstalledAmber();
      if (!isInstalled) {
        _notifyLoginFailure(const LoginFailure(
          type: LoginFailureType.errorEnvironment,
          message: 'Amber app is not installed',
        ));
        return false;
      }

      // Get public key from Amber
      String? signature = await ExternalSignerTool.getPubKey();
      if (signature == null) {
        _notifyLoginFailure(const LoginFailure(
          type: LoginFailureType.errorEnvironment,
          message: 'Amber signature request was rejected',
        ));
        return false;
      }

      // Decode public key if it's in npub format
      String decodeSignature = signature;
      if (signature.startsWith('npub')) {
        decodeSignature = UserDBISAR.decodePubkey(signature) ?? '';
        if (decodeSignature.isEmpty) {
          _notifyLoginFailure(const LoginFailure(
            type: LoginFailureType.invalidKeyFormat,
            message: 'Invalid npub format',
          ));
          return false;
        }
      }

      // Unified account login
      return _loginAccount(
        pubkey: decodeSignature,
        loginType: LoginType.androidSigner,
      );

    } catch (e) {
      _notifyLoginFailure(LoginFailure(
        type: LoginFailureType.errorEnvironment,
        message: 'Amber login failed: $e',
      ));
      return false;
    }
  }

  /// Auto login (called on app startup)
  ///
  /// Try to auto-login using last logged pubkey by opening local database
  Future<bool> autoLogin() async {
    try {
      final lastPubkey = await _getLastPubkey();
      if (lastPubkey == null || lastPubkey.isEmpty) {
        return false; // No login record
      }

      // Try to auto-login with existing account
      final accountDb = await _initAccountDb(lastPubkey);
      if (accountDb == null) {
        return false; // Failed to initialize database
      }

      // Load account model
      final account = await AccountHelper.fromAccountDataList(
        accountDb,
        lastPubkey,
      );
      if (account == null) {
        return false; // No account data found
      }

      // Update login state
      final loginState = LoginState(account: account);
      _state$.value = loginState;

      // Try to login to last circle or first circle
      await _tryLoginLastCircle(loginState);

      // Notify login success
      _notifyLoginSuccess();
      return true;

    } catch (e) {
      debugPrint('Auto login failed: $e');
      _notifyLoginFailure(LoginFailure(
        type: LoginFailureType.errorEnvironment,
        message: 'Auto login failed: $e',
      ));
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {

    final loginState = _state$.value;

    // Clear login state
    _state$.value = LoginState();
    _userInfo$ = ValueNotifier<UserDBISAR?>(null);

    await Account.sharedInstance.logout();

    // Close all opened databases
    final circle = loginState.currentCircle;
    if (circle != null) {
      await DatabaseUtils.closeCircleDatabase;
    }

    final account = loginState.account;
    if (account != null) {
      await DatabaseUtils.closeAccountDatabase(account.db);
    }

    // Clear persistent data
    await _clearLoginInfo();

    // Notify observers
    for (final observer in _observers) {
      observer.onLogout();
    }
  }

  // ============ Private Authentication Methods ============

  /// Unified account login interface
  ///
  /// Handles account-level authentication and data setup for all login types
  Future<bool> _loginAccount({
    required String pubkey,
    required LoginType loginType,
    String? privateKey,
    String? nostrConnectUri,
  }) async {
    try {
      // 1. Initialize account database
      final accountDb = await _initAccountDb(pubkey);
      if (accountDb == null) {
        _notifyLoginFailure(const LoginFailure(
          type: LoginFailureType.accountDbFailed,
          message: 'Failed to initialize account database',
        ));
        return false;
      }

      // 2. Create or load account model
      final now = DateTime.now().millisecondsSinceEpoch;
      AccountModel? account = (await AccountHelper.fromAccountDataList(
        accountDb,
        pubkey,
      ))?.copyWith(
        lastLoginAt: now,
      );

      if (account == null) {
        // Generate default password and encrypt private key for nesc login
        String encryptedPrivKey = '';
        String defaultPassword = '';

        if (loginType == LoginType.nesc) {
          if (privateKey == null) throw Exception('nesc login must has privateKey');
          defaultPassword = _generatePassword();
          encryptedPrivKey = _encryptPrivateKey(privateKey, defaultPassword);
        }

        account = AccountModel(
          pubkey: pubkey,
          loginType: loginType,
          encryptedPrivKey: encryptedPrivKey,
          defaultPassword: defaultPassword,
          nostrConnectUri: nostrConnectUri ?? '',
          circles: [],
          createdAt: now,
          lastLoginAt: now,
          db: accountDb,
        );
      }

      // 3. Save account info to DB.
      await account.saveToDB();

      // 4. Update login state
      final loginState = LoginState(account: account);
      _state$.value = loginState;

      // 5. Persist login information
      await _persistLoginInfo(pubkey);

      // 6. Try to login to last circle or first circle
      await _tryLoginLastCircle(loginState);

      // 7. Notify login success
      _notifyLoginSuccess();
      return true;

    } catch (e) {
      _notifyLoginFailure(LoginFailure(
        type: LoginFailureType.errorEnvironment,
        message: 'Account login failed: $e',
      ));
      return false;
    }
  }


  /// Validate private key format
  bool _isValidPrivateKey(String privateKey) {
    try {
      if (privateKey.isEmpty) return false;

      // Try to generate public key from private key to verify validity
      final pubkey = _generatePubkeyFromPrivate(privateKey);
      return pubkey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Generate public key from private key
  String _generatePubkeyFromPrivate(String privateKey) {
    try {
      // Use Keychain.getPublicKey to generate public key from private key
      return Keychain.getPublicKey(privateKey);
    } catch (e) {
      return '';
    }
  }

  /// Generate strong password for private key encryption
  String _generatePassword() {
    return generateStrongPassword(16);
  }

  /// Encrypt private key using password
  String _encryptPrivateKey(String privateKey, String password) {
    final privateKeyBytes = hex.decode(privateKey);
    final encryptedBytes = encryptPrivateKey(Uint8List.fromList(privateKeyBytes), password);
    return hex.encode(encryptedBytes);
  }

  /// Notify login success
  void _notifyLoginSuccess() {
    for (final observer in _observers) {
      observer.onLoginSuccess(currentState);
    }
  }

  /// Notify login failure
  void _notifyLoginFailure(LoginFailure failure) {
    for (final observer in _observers) {
      observer.onLoginFailure(failure);
    }
  }
}

// ============ Circle Management Extension ============
/// Circle management related methods
extension LoginManagerCircle on LoginManager {
  /// Switch to specified circle
  ///
  /// [circle] Target circle
  Future<bool> switchToCircle(Circle circle) async {
    final currentState = this.currentState;
    final account = currentState.account;
    if (account == null) {
      _notifyCircleChangeFailed(const LoginFailure(
        type: LoginFailureType.errorEnvironment,
        message: 'No account logged in',
      ));
      return false;
    }

    if (!account.circles.contains(circle)) {
      _notifyCircleChangeFailed(LoginFailure(
        type: LoginFailureType.errorEnvironment,
        message: 'Circle not found in account',
        circleId: circle.id,
      ));
      return false;
    }

    if (currentState.hasCircle) {
      await DatabaseUtils.closeCircleDatabase();
    }

    if (!await _loginToCircle(circle, currentState)) {
      _notifyCircleChangeFailed(LoginFailure(
        type: LoginFailureType.circleDbFailed,
        message: 'Login circle failed',
        circleId: circle.id,
      ));
      return false;
    }

    return true;
  }

  /// Join circle
  ///
  /// [relayUrl] Circle's relay address
  Future<bool> joinCircle(String relayUrl) async {
    try {
      final currentState = this.currentState;

      final account = currentState.account;
      if (account == null) {
        _notifyCircleChangeFailed(const LoginFailure(
          type: LoginFailureType.errorEnvironment,
          message: 'No account logged in',
        ));
        return false;
      }

      // Generate circle ID from relay URL (simplified for now)
      final circleId = _generateCircleId(relayUrl);

      // Check if circle already exists in account
      final existingCircle = account.circles.where((c) => c.id == circleId).firstOrNull;
      if (existingCircle != null) {
        // Circle already exists, just switch to it
        return switchToCircle(existingCircle);
      }

      // Create new circle
      final newCircle = Circle(
        id: circleId,
        name: _extractCircleName(relayUrl),
        relayUrl: relayUrl,
      );

      if (!await _loginToCircle(newCircle, currentState)) {
        _notifyCircleChangeFailed(LoginFailure(
            type: LoginFailureType.circleDbFailed,
            message: 'Failed to initialize circle database',
        ));
        return false;
      }

      // Add circle to account's circle list
      final updatedCircles = [...account.circles, newCircle];

      // Update account model in database FIRST
      final updatedAccount = account.copyWith(
        circles: updatedCircles,
      );
      await updatedAccount.saveToDB();

      _state$.value = currentState.copyWith(
        account: updatedAccount,
        currentCircle: newCircle,
      );

      // Notify circle change success
      for (final observer in _observers) {
        observer.onCircleChanged(newCircle);
      }

      return true;

    } catch (e) {
      _notifyCircleChangeFailed(LoginFailure(
        type: LoginFailureType.circleDbFailed,
        message: 'Failed to join circle: $e',
      ));
      return false;
    }
  }

  /// Leave circle
  ///
  /// [circleId] Circle ID to leave
  Future<bool> leaveCircle(String circleId) async {
    try {
      final currentState = this.currentState;
      final account = currentState.account;
      if (account == null) {
        _notifyCircleChangeFailed(const LoginFailure(
          type: LoginFailureType.errorEnvironment,
          message: 'No account logged in',
        ));
        return false;
      }

      // Find circle
      final leavingCircle = account.circles.where((c) => c.id == circleId).firstOrNull;
      if (leavingCircle == null) {
        _notifyCircleChangeFailed(LoginFailure(
          type: LoginFailureType.errorEnvironment,
          message: 'Circle not found',
          circleId: circleId,
        ));
        return false;
      }

      // Close DB if current
      if (currentState.currentCircle?.id == circleId) {
        await DatabaseUtils.closeCircleDatabase();
      }

      // Remove circle from list
      final updatedCircles = [...account.circles]..removeWhere((c) => c.id == circleId);

      // Determine next circle (if current removed)
      Circle? nextCircle = currentState.currentCircle;
      if (nextCircle?.id == circleId) {
        nextCircle = updatedCircles.isNotEmpty ? updatedCircles.first : null;
      }

      // Logout & Delete circle database files
      await Account.sharedInstance.deletecircle(circleId, nextCircle?.id);

      // Persist account update
      final updatedAccount = account.copyWith(
        circles: updatedCircles,
        lastLoginCircleId: nextCircle?.id,
      );

      await updatedAccount.saveToDB();

      // Update state
      _state$.value = currentState.copyWith(
        account: updatedAccount,
        currentCircle: nextCircle,
      );
      _userInfo$ = ValueNotifier<UserDBISAR?>(null);

      // Notify observers that there is no circle currently
      for (final observer in _observers) {
        observer.onCircleChanged(nextCircle);
      }

      return true;
    } catch (e) {
      _notifyCircleChangeFailed(LoginFailure(
        type: LoginFailureType.circleDbFailed,
        message: 'Failed to leave circle: $e',
        circleId: circleId,
      ));
      return false;
    }
  }

  Future<bool> _tryLoginLastCircle(LoginState loginState) async {
    final account = loginState.account;
    if (account == null) return false;

    final lastCircleId = account.lastLoginCircleId ?? '';
    if (lastCircleId.isNotEmpty && account.circles.isNotEmpty) {
      final targetCircle = account.circles.where((c) => c.id == lastCircleId).firstOrNull;
      if (targetCircle != null) {
        return await _loginToCircle(targetCircle, loginState);
      }
    }

    return false;
  }

  /// Login to specified circle
  ///
  /// This performs circle-level login using Account.sharedInstance methods
  Future<bool> _loginToCircle(Circle circle, LoginState loginState) async {
    try {
      final account = loginState.account;
      if (account == null) {
        _notifyCircleChangeFailed(LoginFailure(
          type: LoginFailureType.errorEnvironment,
          message: 'Account is null',
          circleId: circle.id,
        ));
        return false;
      }

      // Initialize circle database using DatabaseUtils
      final circleDb = await DatabaseUtils.initCircleDatabase(
        account.pubkey,
        circle,
      );
      if (circleDb == null) {
        _notifyCircleChangeFailed(LoginFailure(
          type: LoginFailureType.circleDbFailed,
          message: 'Failed to initialize circle database',
          circleId: circle.id,
        ));
        return false;
      }

      circle.db = circleDb;

      // Initialize Account system
      Account.sharedInstance.init();

      // Perform circle-level login based on account login type
      final user = await _performNostrLogin(account);
      if (user == null) {
        _notifyCircleChangeFailed(LoginFailure(
          type: LoginFailureType.circleDbFailed,
          message: 'Circle-level login failed',
          circleId: circle.id,
        ));
        return false;
      }

      await ChatCoreManager().initChatCore(
        isLite: true,
        circleRelay: circle.relayUrl,
        contactUpdatedCallBack: Contacts.sharedInstance.contactUpdatedCallBack,
        channelsUpdatedCallBack: Channels.sharedInstance.myChannelsUpdatedCallBack,
        groupsUpdatedCallBack: Groups.sharedInstance.myGroupsUpdatedCallBack,
        relayGroupsUpdatedCallBack: RelayGroup.sharedInstance.myGroupsUpdatedCallBack,
      );

      // Login success
      account.updateLastLoginCircle(circle.id);
      _state$.value = loginState.copyWith(
        currentCircle: circle,
      );
      _userInfo$ = Account.sharedInstance.getUserNotifier(user.pubKey);

      // Reload profile from relay and update settings (circle-level)
      Account.sharedInstance.reloadProfileFromRelay(
        account.pubkey,
      );

      // Notify circle change success
      for (final observer in _observers) {
        observer.onCircleChanged(circle);
      }

      return true;
    } catch (e) {
      _notifyCircleChangeFailed(LoginFailure(
        type: LoginFailureType.circleDbFailed,
        message: 'Failed to login to circle: $e',
        circleId: circle.id,
      ));
      return false;
    }
  }

  /// Perform circle-level login based on account login type
  Future<UserDBISAR?> _performNostrLogin(AccountModel account) async {
    try {
      final loginType = account.loginType;
      switch (loginType) {
        case LoginType.nesc:
        // Use private key login
          final privateKey = account.getPrivateKey();
          return Account.sharedInstance.loginWithPriKey(privateKey);

        case LoginType.androidSigner:
        // Use Amber signer login
          return Account.sharedInstance.loginWithPubKey(
            account.pubkey,
            SignerApplication.androidSigner,
          );

        case LoginType.remoteSigner:
        // Use NostrConnect login
          final nostrConnectUri = account.nostrConnectUri;
          if (nostrConnectUri.isNotEmpty) {
            return Account.sharedInstance.loginWithNip46URI(
              nostrConnectUri,
            );
          }
          break;
      }

      return null;
    } catch (e) {
      debugPrint('Circle login failed: $e');
      return null;
    }
  }

  /// Notify circle change failure
  void _notifyCircleChangeFailed(LoginFailure failure) {
    for (final observer in _observers) {
      observer.onCircleChangeFailed(failure);
    }
  }
}

/// Observer management related methods
extension LoginManagerObserverEx on LoginManager {
  /// Add observer
  void addObserver(LoginManagerObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  /// Remove observer
  void removeObserver(LoginManagerObserver observer) {
    _observers.remove(observer);
  }

  /// Dispose resources
  void dispose() {
    _state$.dispose();
    _observers.clear();
  }
}

/// Database and persistence related methods
extension LoginManagerDatabase on LoginManager {
  /// Initialize account database using new DatabaseUtils
  Future<Isar?> _initAccountDb(String pubkey) async {
    try {
      // Use new DatabaseUtils instead of legacy logic
      return await DatabaseUtils.initAccountDatabase(pubkey);
    } catch (e) {
      debugPrint('Failed to init account DB: $e');
      return null;
    }
  }

  /// Persist login information
  Future<void> _persistLoginInfo(String pubkey) async {
    await OXCacheManager.defaultOXCacheManager.saveForeverData(
      LoginManager._keyLastPubkey,
      pubkey,
    );
  }

  /// Clear login information
  Future<void> _clearLoginInfo() async {
    await OXCacheManager.defaultOXCacheManager.saveForeverData(
      LoginManager._keyLastPubkey,
      null,
    );
  }

  /// Get last logged pubkey
  Future<String?> _getLastPubkey() async {
    return await OXCacheManager.defaultOXCacheManager.getForeverData(
      LoginManager._keyLastPubkey,
    );
  }
}

/// Utility methods for LoginManager
extension LoginManagerUtils on LoginManager {
  /// Generate circle ID from relay URL
  String _generateCircleId(String relayUrl) {
    // Simple hash of the relay URL to create a unique ID
    return relayUrl.hashCode.abs().toString();
  }

  /// Extract circle name from relay URL
  String _extractCircleName(String relayUrl) {
    try {
      final uri = Uri.parse(relayUrl);
      final host = uri.host;
      // Remove common prefixes and return a clean name
      return host.replaceAll('relay.', '').replaceAll('www.', '').split('.').first;
    } catch (e) {
      // Fallback to simplified name
      return relayUrl.replaceAll('wss://', '').replaceAll('ws://', '').split('/').first;
    }
  }
}