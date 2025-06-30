import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// DBKeyManager
///
/// Generates and persists a 256-bit random key (32 bytes) in the
/// platform secure storage (Android Keystore / iOS Keychain).
/// The key is created once per app installation and reused afterwards.
class DBKeyManager {
  DBKeyManager._();

  static const String _storageKey = 'oxchat_db_enc_key';
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// Returns base64-encoded 256-bit key suitable for Isar or SQLCipher.
  static Future<String> getKey() async {
    try {
      final stored = await _secureStorage.read(key: _storageKey);
      if (stored != null && stored.isNotEmpty) {
        return stored;
      }
    } on PlatformException {
      // Ignore and regenerate.
    }
    // Generate new key
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final encoded = base64Encode(bytes);
    await _secureStorage.write(key: _storageKey, value: encoded);
    return encoded;
  }
} 