import 'package:chatcore/chat-core.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import 'account_models.dart';
import 'circle_config_models.dart';
import 'circle_isar.dart';

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

/// Circle category enumeration
enum CircleCategory {
  custom,    
  paid,      
}

extension CircleCategoryExtension on CircleCategory {
  String get value {
    switch (this) {
      case CircleCategory.custom:
        return 'custom';
      case CircleCategory.paid:
        return 'paid';
    }
  }

  static CircleCategory fromString(String value) {
    switch (value) {
      case 'custom':
        return CircleCategory.custom;
      case 'paid':
        return CircleCategory.paid;
      default:
        return CircleCategory.custom;
    }
  }
}

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
    String? id,
    required this.name,
    required this.relayUrl,
    this.type = CircleType.relay,
    this.ownerPubkey,
    this.invitationCode,
    this.category = CircleCategory.custom,
    this.groupId,
  }) : id = id ?? Uuid().v4();

  final String id;
  String name;
  String relayUrl;
  final CircleType type;
  /// Pubkey of the account that owns this circle (e.g. purchaser). When equal to
  /// current account pubkey, the circle is "owned"; used for subscription slot occupation.
  String? ownerPubkey;
  String? invitationCode; // Invitation code for this circle
  CircleCategory category; // Circle category (custom or paid)
  /// Subscription group id (e.g. loc1) for paid circles owned by this account.
  String? groupId;

  /// Tenant info for paid relay (from [CircleMemberService.getTenantInfo]).
  /// Updated when tenant info is fetched; null until loaded or for non-paid circles.
  TenantInfo? tenantInfo;

  /// Circle level configuration, loaded lazily after circle DB initialized.
  CircleConfigModel _config = CircleConfigModel();

  /// Whether this circle uses a paid relay (by relay URL pattern).
  /// Synchronous, no I/O.
  bool get isPaidRelay => CircleApi.isPaidRelay(relayUrl);

  /// Whether the given [currentPubkey] is admin of this circle (paid relay only).
  /// Derived from [tenantInfo]; returns false when [tenantInfo] is null or not loaded.
  bool isAdminFor(String currentPubkey) =>
      tenantInfo != null &&
      currentPubkey.isNotEmpty &&
      tenantInfo!.tenantAdminPubkey.toLowerCase() == currentPubkey.toLowerCase();

  late Isar db;

  /// Create Circle from CircleISAR
  /// [Circle.tenantInfo] is not persisted here; load from [CircleDBISAR] / getTenantInfo when needed.
  factory Circle.fromISAR(CircleISAR isar) {
    return Circle(
      id: isar.circleId,
      name: isar.name,
      relayUrl: isar.relayUrl,
      type: isar.type,
      ownerPubkey: isar.pubkey.isEmpty ? null : isar.pubkey,
      invitationCode: isar.invitationCode,
      category: isar.category,
      groupId: isar.groupId,
    );
  }

  /// Convert Circle to CircleISAR
  /// [Circle.tenantInfo] is not persisted; tenant info lives in [CircleDBISAR] / runtime only.
  CircleISAR toISAR() {
    return CircleISAR(
      pubkey: ownerPubkey ?? '',
      circleId: id,
      name: name,
      relayUrl: relayUrl,
      type: type,
      invitationCode: invitationCode,
      category: category,
      groupId: groupId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relayUrl': relayUrl,
    'type': type.value,
    'groupId': groupId,
    'ownerPubkey': ownerPubkey,
  };

  factory Circle.fromJson(Map<String, dynamic> json) => Circle(
    id: json['id'] as String,
    name: json['name'] as String,
    relayUrl: json['relayUrl'] as String,
    type: CircleTypeExtension.fromString(json['type'] as String? ?? 'relay'),
    groupId: json['groupId'],
    ownerPubkey: json['ownerPubkey'],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Circle && runtimeType == other.runtimeType && id == other.id && ownerPubkey == other.ownerPubkey;

  @override
  int get hashCode => Object.hash(id, ownerPubkey);

  @override
  String toString() => 'Circle(id: $id, name: $name, relayUrl: $relayUrl, type: ${type.value}, ownerPubkey: ${ownerPubkey ?? 'null'})';

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

  AccountModel? account;
  Circle? currentCircle;

  bool get isLoggedIn => account != null;
  bool get hasCircle => currentCircle != null;

  LoginState copy() => LoginState(
    account: account,
    currentCircle: currentCircle,
  );

  @override
  String toString() => 'LoginState(isLoggedIn: $isLoggedIn, hasCircle: $hasCircle)';
}

/// Login manager observer interface
abstract mixin class LoginManagerObserver {
  void onLoginSuccess(LoginState state) {}

  void onLoginFailure(LoginFailure failure) {}

  void onLogout() {}

  void onCircleChange(bool isSuccess, LoginFailure? failure) {}

  void onCircleConnected(bool isConnected) {}
} 