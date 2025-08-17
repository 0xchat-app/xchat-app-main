import 'package:isar/isar.dart';

import 'account_models.dart';
import 'circle_config_models.dart';

/// Login failure type enumeration
enum LoginFailureType {
  invalidKeyFormat,
  errorEnvironment,
  accountDbFailed,
  circleDbFailed,
}

/// Circle type enumeration
enum CircleType {
  relay,
  bitchat,
}

extension CircleTypeExtension on CircleType {
  String get value {
    switch (this) {
      case CircleType.relay:
        return 'relay';
      case CircleType.bitchat:
        return 'bitchat';
    }
  }

  static CircleType fromString(String value) {
    switch (value) {
      case 'relay':
        return CircleType.relay;
      case 'bitchat':
        return CircleType.bitchat;
      default:
        return CircleType.relay;
    }
  }
}

class _NoSet { const _NoSet(); }
const _noSet = _NoSet();

/// Login failure information
class LoginFailure {
  const LoginFailure({
    required this.type,
    required this.message,
    this.circleId,
  });

  final LoginFailureType type;
  final String message;
  final String? circleId; // Circle ID when Circle-related error occurs

  @override
  String toString() => 'LoginFailure(type: $type, message: $message, circleId: $circleId)';
}

/// Circle data model
class Circle {
  Circle({
    required this.id,
    required this.name,
    required this.relayUrl,
    this.type = CircleType.relay,
  });

  final String id;
  final String name;
  final String relayUrl;
  final CircleType type;

  /// Circle level configuration, loaded lazily after circle DB initialized.
  CircleConfigModel _config = CircleConfigModel();

  late Isar db;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relayUrl': relayUrl,
    'type': type.value,
  };

  factory Circle.fromJson(Map<String, dynamic> json) => Circle(
    id: json['id'] as String,
    name: json['name'] as String,
    relayUrl: json['relayUrl'] as String,
    type: CircleTypeExtension.fromString(json['type'] as String? ?? 'relay'),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Circle && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Circle(id: $id, name: $name, relayUrl: $relayUrl, type: ${type.value})';

  /// Internal use only. Called by LoginManager to initialize configuration.
  void initConfig(CircleConfigModel cfg) {
    _config = cfg;
  }

  String get selectedFileServerUrl => _config.selectedFileServerUrl;
  
  /// Get allow send notification setting with fallback to false
  bool get allowSendNotification => _config.allowSendNotification ?? false;
  
  /// Get allow receive notification setting with fallback to false
  bool get allowReceiveNotification => _config.allowReceiveNotification ?? false;
  
  /// Check if notification settings are initialized
  bool get isNotificationSettingsInitialized => 
      _config.allowSendNotification != null && _config.allowReceiveNotification != null;

  /// Update the selected file-server URL and persist the change to database.
  Future<void> updateSelectedFileServerUrl(String url) async {
    if (_config.selectedFileServerUrl == url) return;
    _config = _config.copyWith(selectedFileServerUrl: url);
    await CircleConfigHelper.saveConfig(db, id, _config);
  }
  
  /// Update allow send notification setting and persist the change to database.
  Future<void> updateAllowSendNotification(bool value) async {
    if (_config.allowSendNotification == value) return;
    _config = _config.copyWith(allowSendNotification: value);
    await CircleConfigHelper.saveConfig(db, id, _config);
  }
  
  /// Update allow receive notification setting and persist the change to database.
  Future<void> updateAllowReceiveNotification(bool value) async {
    if (_config.allowReceiveNotification == value) return;
    _config = _config.copyWith(allowReceiveNotification: value);
    await CircleConfigHelper.saveConfig(db, id, _config);
  }
}

/// User information model for UI display
class UserInfo {
  const UserInfo({
    required this.encodedPubkey,
    required this.name,
    required this.bio,
    required this.avatarUrl,
  });

  final String encodedPubkey;
  final String name;
  final String bio;
  final String avatarUrl;

  UserInfo copyWith({
    String? encodedPubkey,
    String? name,
    String? bio,
    String? avatarUrl,
  }) => UserInfo(
    encodedPubkey: encodedPubkey ?? this.encodedPubkey,
    name: name ?? this.name,
    bio: bio ?? this.bio,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );

  @override
  String toString() => 'UserInfo(encodedPubkey: $encodedPubkey, name: $name, bio: $bio, avatarUrl: $avatarUrl)';
}

/// Login state
class LoginState {
  LoginState({
    this.account,
    this.currentCircle,
  });

  final AccountModel? account;
  final Circle? currentCircle;

  bool get isLoggedIn => account != null;
  bool get hasCircle => currentCircle != null;

  LoginState copyWith({
    dynamic account = _noSet,
    dynamic currentCircle = _noSet,
  }) => LoginState(
    account: account != _noSet ? account : this.account,
    currentCircle: currentCircle != _noSet ? currentCircle : this.currentCircle,
  );

  @override
  String toString() => 'LoginState(isLoggedIn: $isLoggedIn, hasCircle: $hasCircle)';
}

/// Login manager observer interface
abstract mixin class LoginManagerObserver {
  /// Login success callback
  void onLoginSuccess(LoginState state) {}

  /// Login failure callback
  void onLoginFailure(LoginFailure failure) {}

  /// Logout callback
  void onLogout() {}

  /// Circle change success callback
  void onCircleChanged(Circle? circle) {}

  /// Circle change failure callback
  void onCircleChangeFailed(LoginFailure failure) {}
} 