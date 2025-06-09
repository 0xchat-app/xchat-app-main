import 'package:isar/isar.dart';

import 'account_models.dart';

/// Login failure type enumeration
enum LoginFailureType {
  invalidKeyFormat,
  errorEnvironment,
  accountDbFailed,
  circleDbFailed,
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
    required this.id,
    required this.name,
    required this.relayUrl,
  });

  final String id;
  final String name;
  final String relayUrl;

  late Isar db;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relayUrl': relayUrl,
  };

  factory Circle.fromJson(Map<String, dynamic> json) => Circle(
    id: json['id'] as String,
    name: json['name'] as String,
    relayUrl: json['relayUrl'] as String,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Circle && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Circle(id: $id, name: $name, relayUrl: $relayUrl)';
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
    AccountModel? account,
    Circle? currentCircle,
  }) => LoginState(
    account: account ?? this.account,
    currentCircle: currentCircle ?? this.currentCircle,
  );

  @override
  String toString() => 'LoginState(isLoggedIn: $isLoggedIn, hasCircle: $hasCircle)';
}

/// Login manager observer interface
abstract mixin class LoginManagerObserver {
  /// Login success callback
  void onLoginSuccess(LoginState state);

  /// Login failure callback
  void onLoginFailure(LoginFailure failure);

  /// Logout callback
  void onLogout();

  /// Circle change success callback
  void onCircleChanged(Circle? circle);

  /// Circle change failure callback
  void onCircleChangeFailed(LoginFailure failure);
} 