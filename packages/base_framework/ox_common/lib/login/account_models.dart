import 'package:isar/isar.dart';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'login_models.dart';

part 'account_models.g.dart';

/// Account level key-value storage
/// 
/// Stores various account-level information in key-value format
/// Examples: pubkey, createdAt, lastLoginAt, themeMode, language, fontSize, etc.
@collection
class AccountDataISAR {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String key;

  String? stringValue;
  int? intValue;
  double? doubleValue;
  bool? boolValue;

  int updatedAt;

  AccountDataISAR({
    this.key = '',
    this.stringValue,
    this.intValue,
    this.doubleValue,
    this.boolValue,
    this.updatedAt = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'stringValue': stringValue,
      'intValue': intValue,
      'doubleValue': doubleValue,
      'boolValue': boolValue,
      'updatedAt': updatedAt,
    };
  }

  static AccountDataISAR fromMap(Map<String, dynamic> map) {
    return AccountDataISAR(
      key: map['key'] ?? '',
      stringValue: map['stringValue'],
      intValue: map['intValue'],
      doubleValue: map['doubleValue']?.toDouble(),
      boolValue: map['boolValue'],
      updatedAt: map['updatedAt'] ?? 0,
    );
  }

  // Helper methods for different value types
  static AccountDataISAR createString(String key, String value) {
    return AccountDataISAR(
      key: key,
      stringValue: value,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static AccountDataISAR createInt(String key, int value) {
    return AccountDataISAR(
      key: key,
      intValue: value,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static AccountDataISAR createDouble(String key, double value) {
    return AccountDataISAR(
      key: key,
      doubleValue: value,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static AccountDataISAR createBool(String key, bool value) {
    return AccountDataISAR(
      key: key,
      boolValue: value,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Common account data keys
  static const String keyPubkey = 'pubkey';
  static const String keyCreatedAt = 'createdAt';
  static const String keyLastLoginAt = 'lastLoginAt';
  static const String keyThemeMode = 'themeMode';
  static const String keyPrimaryColor = 'primaryColor';
  static const String keyLanguage = 'language';
  static const String keyLocale = 'locale';
  static const String keyFontSize = 'fontSize';
  static const String keyFontFamily = 'fontFamily';
}

/// Account level schemas utilities
class AccountSchemas {
  AccountSchemas._(); // Private constructor to prevent instantiation

  // Private static list to avoid recreating the list every time
  static final List<CollectionSchema<dynamic>> _schemas = [
    AccountDataISARSchema,
  ];

  /// Get account level schemas for independent Isar instance
  /// Returns an unmodifiable view to prevent external modification
  static List<CollectionSchema<dynamic>> get schemas => 
      UnmodifiableListView(_schemas);
}

/// Account login types
enum LoginType {
  nesc(1),           // Private key login
  androidSigner(2),  // Amber signer login  
  remoteSigner(3);   // NostrConnect remote signer login
  
  const LoginType(this.value);
  final int value;
  
  static LoginType fromValue(int value) {
    return LoginType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => LoginType.nesc,
    );
  }
}

/// Account model for LoginManager
class AccountModel {
  AccountModel({
    required this.pubkey,
    required this.loginType,
    required this.encryptedPrivKey,
    required this.defaultPassword,
    required this.nostrConnectUri,
    required this.circles,
    required this.createdAt,
    required this.lastLoginAt,
    this.lastLoginCircleId,
    required this.db,
  });

  final String pubkey;
  final LoginType loginType;
  final String encryptedPrivKey;     // Only has value for nesc login type
  final String defaultPassword;      // Used to decrypt private key
  final String nostrConnectUri;     // Only has value for remoteSigner login type
  final List<Circle> circles;
  final int createdAt;
  final int lastLoginAt;
  String? lastLoginCircleId;   // Last logged in circle ID
  
  late Isar db;

  AccountModel copyWith({
    String? pubkey,
    LoginType? loginType,
    String? encryptedPrivKey,
    String? defaultPassword,
    String? nostrConnectUri,
    List<Circle>? circles,
    int? createdAt,
    int? lastLoginAt,
    String? lastLoginCircleId,
  }) {
    return AccountModel(
      pubkey: pubkey ?? this.pubkey,
      loginType: loginType ?? this.loginType,
      encryptedPrivKey: encryptedPrivKey ?? this.encryptedPrivKey,
      defaultPassword: defaultPassword ?? this.defaultPassword,
      nostrConnectUri: nostrConnectUri ?? this.nostrConnectUri,
      circles: circles ?? this.circles,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastLoginCircleId: lastLoginCircleId ?? this.lastLoginCircleId,
      db: db,
    );
  }
}

/// Helper class for AccountDataISAR conversion
class AccountHelper {
  // AccountDataISAR keys
  static const String keyPubkey = 'pubkey';
  static const String keyLoginType = 'login_type';
  static const String keyEncryptedPrivKey = 'encrypted_priv_key';
  static const String keyDefaultPassword = 'default_password';
  static const String keyNostrConnectUri = 'nostr_connect_uri';
  static const String keyCircles = 'circles';
  static const String keyCreatedAt = 'created_at';
  static const String keyLastLoginAt = 'last_login_at';
  static const String keyLastLoginCircleId = 'last_login_circle_id';

  /// Convert AccountModel to list of AccountDataISAR entries
  static List<AccountDataISAR> toAccountDataList(AccountModel account) {
    final result = <AccountDataISAR>[
      AccountDataISAR.createString(keyPubkey, account.pubkey),
      AccountDataISAR.createInt(keyLoginType, account.loginType.value),
      AccountDataISAR.createString(keyEncryptedPrivKey, account.encryptedPrivKey),
      AccountDataISAR.createString(keyDefaultPassword, account.defaultPassword),
      AccountDataISAR.createString(keyCircles, 
        jsonEncode(account.circles.map((c) => c.toJson()).toList())),
      AccountDataISAR.createInt(keyCreatedAt, account.createdAt),
      AccountDataISAR.createInt(keyLastLoginAt, account.lastLoginAt),
      AccountDataISAR.createString(keyNostrConnectUri, account.nostrConnectUri),
    ];
  
    if (account.lastLoginCircleId != null) {
      result.add(AccountDataISAR.createString(keyLastLoginCircleId, account.lastLoginCircleId!));
    }
    
    return result;
  }

  /// Load AccountModel from AccountDataISAR entries
  static Future<AccountModel?> fromAccountDataList(
    Isar accountDb, 
    String pubkey,
  ) async {
    try {
      final accountData = await accountDb.accountDataISARs.where()
        .anyOf([keyPubkey, keyLoginType, keyEncryptedPrivKey, keyDefaultPassword, 
               keyNostrConnectUri, keyCircles, keyCreatedAt, keyLastLoginAt, keyLastLoginCircleId],
               (q, String key) => q.keyEqualTo(key))
        .findAll();

      if (accountData.isEmpty) return null;

      final dataMap = <String, dynamic>{};
      for (final data in accountData) {
        if (data.stringValue != null) {
          dataMap[data.key] = data.stringValue;
        } else if (data.intValue != null) {
          dataMap[data.key] = data.intValue;
        } else if (data.doubleValue != null) {
          dataMap[data.key] = data.doubleValue;
        } else if (data.boolValue != null) {
          dataMap[data.key] = data.boolValue;
        }
      }

      // Parse circles
      List<Circle> circles = [];
      if (dataMap[keyCircles] != null) {
        final circlesJson = jsonDecode(dataMap[keyCircles] as String) as List;
        circles = circlesJson
            .map((json) => Circle.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      final pubkey = dataMap[keyPubkey] as String?;
      final loginTypeRaw = dataMap[keyLoginType] as int?;
      final encryptedPrivKey = dataMap[keyEncryptedPrivKey] as String?;
      final defaultPassword = dataMap[keyDefaultPassword] as String?;
      final nostrConnectUri = dataMap[keyNostrConnectUri] as String?;
      if (pubkey == null ||
          loginTypeRaw == null ||
          encryptedPrivKey == null ||
          defaultPassword == null ||
          nostrConnectUri == null) {
        return null;
      }

      return AccountModel(
        pubkey: pubkey,
        loginType: LoginType.fromValue(loginTypeRaw),
        encryptedPrivKey: encryptedPrivKey,
        defaultPassword: defaultPassword,
        nostrConnectUri: nostrConnectUri,
        circles: circles,
        createdAt: dataMap[keyCreatedAt] as int? ?? DateTime.now().millisecondsSinceEpoch,
        lastLoginAt: dataMap[keyLastLoginAt] as int? ?? DateTime.now().millisecondsSinceEpoch,
        lastLoginCircleId: dataMap[keyLastLoginCircleId] as String?,
        db: accountDb,
      );
    } catch (e) {
      debugPrint('Failed to load AccountModel: $e');
      return null;
    }
  }

  /// Save AccountModel to database
  static Future<void> _saveAccount(Isar accountDb, AccountModel account) async {
    final accountDataList = toAccountDataList(account);
    await accountDb.writeTxn(() async {
      await accountDb.accountDataISARs.putAll(accountDataList);
    });
  }

  /// Update last login time
  static Future<void> updateLastLoginTime(Isar accountDb, String pubkey) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await accountDb.writeTxn(() async {
      await accountDb.accountDataISARs.put(
        AccountDataISAR.createInt(keyLastLoginAt, now),
      );
    });
  }
}

extension AccountHelperEx on AccountModel {
  void updateLastLoginCircle(String? circleId) {
    if (lastLoginCircleId == circleId) return;

    lastLoginCircleId = circleId;
    saveToDB();
  }

  Future saveToDB() {
    return AccountHelper._saveAccount(db, this);
  }
}