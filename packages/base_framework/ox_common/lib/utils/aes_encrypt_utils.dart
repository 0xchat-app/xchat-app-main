import 'dart:io';

import 'package:chatcore/chat-core.dart';
import 'package:encrypt/encrypt.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class AesEncryptUtils {
  static String _getUploadFileKey() {
    return "nostr@chat*yuele";
  }

  static Uint8List secureRandom() {
    return Key.fromSecureRandom(32).bytes;
  }

  static Uint8List secureRandomNonce() {
    return IV.fromLength(16).bytes;
  }

  static Future<void> encryptFileInIsolate(File sourceFile, File encryptedFile, String key,
      {String? nonce, AESMode mode = AESMode.gcm}) async {
    await ThreadPoolManager.sharedInstance.runAlgorithmTask(
        () => _encryptFile(sourceFile, encryptedFile, key, nonce: nonce, mode: mode));
  }

  static Future<void> _encryptFile(File sourceFile, File encryptedFile, String key,
      {String? nonce, AESMode mode = AESMode.gcm}) async {
    final sourceBytes = sourceFile.readAsBytesSync();
    final uint8list = hexToBytes(key);
    final encrypter = Encrypter(AES(Key(uint8list), mode: mode));
    var iv;
    if (nonce != null && nonce.isNotEmpty) {
      final uint8listNonce = hexToBytes(nonce);
      iv = IV(uint8listNonce);
    } else {
      iv = IV.allZerosOfLength(16);
    }
    final encryptedBytes = encrypter.encryptBytes(sourceBytes, iv: iv);
    encryptedFile.writeAsBytesSync(encryptedBytes.bytes);
  }

  static Future<void> decryptFileInIsolate(
      File encryptedFile,
      File decryptedFile,
      String key, {
        String? nonce,
        AESMode mode = AESMode.gcm,
      }) async {
    await ThreadPoolManager.sharedInstance.runAlgorithmTask(() => _decryptFile(
      encryptedFile,
      decryptedFile,
      key,
      nonce: nonce,
      mode: mode,
    ));
  }

  static Future<List<int>> decryptFileOnMemoryInIsolate(
      File encryptedFile,
      String key, {
        String? nonce,
        AESMode mode = AESMode.gcm,
      }) async {
    return (await ThreadPoolManager.sharedInstance.runAlgorithmTask(() => _decryptFileOnMemory(
      encryptedFile,
      key,
      nonce: nonce,
      mode: mode,
    ))) as List<int>;
  }

  static Future<void> _decryptFile(
    File encryptedFile,
    File decryptedFile,
    String key, {
    String? nonce,
    AESMode mode = AESMode.gcm,
  }) async {
    if (nonce == null || nonce.isEmpty) mode = AESMode.sic;
    final encryptedBytes = encryptedFile.readAsBytesSync();
    final uint8list = hexToBytes(key);
    final decrypter = Encrypter(AES(Key(uint8list), mode: mode));
    final encrypted = Encrypted(encryptedBytes);
    var iv;
    if (nonce != null && nonce.isNotEmpty) {
      final uint8listNonce = hexToBytes(nonce);
      iv = IV(uint8listNonce);
    } else {
      iv = IV.allZerosOfLength(16);
    }
    try{
      final decryptedBytes = decrypter.decryptBytes(encrypted, iv: iv);
      decryptedFile.writeAsBytesSync(decryptedBytes);
    }
    catch(e){
      _decryptFileFromUTF8Nonce(encryptedFile, decryptedFile, key, nonce: nonce, mode: mode);
    }
  }

  static Future<List<int>> _decryptFileOnMemory(
      File encryptedFile,
      String key, {
        String? nonce,
        AESMode mode = AESMode.gcm,
      }) async {
    if (nonce == null || nonce.isEmpty) mode = AESMode.sic;
    final encryptedBytes = encryptedFile.readAsBytesSync();
    final uint8list = hexToBytes(key);
    final decrypter = Encrypter(AES(Key(uint8list), mode: mode));
    final encrypted = Encrypted(encryptedBytes);
    var iv;
    if (nonce != null && nonce.isNotEmpty) {
      final uint8listNonce = hexToBytes(nonce);
      iv = IV(uint8listNonce);
    } else {
      iv = IV.allZerosOfLength(16);
    }

    try {
      return decrypter.decryptBytes(encrypted, iv: iv);
    } catch (e) {
      return _decryptFileFromUTF8NonceOnMemory(
        encryptedFile,
        key,
        nonce: nonce,
        mode: mode,
      );
    }
  }

  static Future<void> _decryptFileFromUTF8Nonce(
      File encryptedFile,
      File decryptedFile,
      String key, {
        String? nonce,
        AESMode mode = AESMode.gcm,
      }) async {
    if (nonce == null || nonce.isEmpty) mode = AESMode.sic;
    final encryptedBytes = encryptedFile.readAsBytesSync();
    final uint8list = hexToBytes(key);
    final decrypter = Encrypter(AES(Key(uint8list), mode: mode));
    final encrypted = Encrypted(encryptedBytes);
    var iv;
    if (nonce != null && nonce.isNotEmpty) {
      iv = IV.fromUtf8(nonce);
    } else {
      iv = IV.allZerosOfLength(16);
    }
    final decryptedBytes = decrypter.decryptBytes(encrypted, iv: iv);
    decryptedFile.writeAsBytesSync(decryptedBytes);
  }

  static Future<List<int>> _decryptFileFromUTF8NonceOnMemory(
      File encryptedFile,
      String key, {
        String? nonce,
        AESMode mode = AESMode.gcm,
      }) async {
    if (nonce == null || nonce.isEmpty) mode = AESMode.sic;
    final encryptedBytes = encryptedFile.readAsBytesSync();
    final uint8list = hexToBytes(key);
    final decrypter = Encrypter(AES(Key(uint8list), mode: mode));
    final encrypted = Encrypted(encryptedBytes);
    var iv;
    if (nonce != null && nonce.isNotEmpty) {
      iv = IV.fromUtf8(nonce);
    } else {
      iv = IV.allZerosOfLength(16);
    }
    return decrypter.decryptBytes(encrypted, iv: iv);
  }

  static String aes128Decrypt(String encryptText, {String? keyStr}) {
    if (keyStr == null) {
      keyStr = _getUploadFileKey();
    }
    final key = Key.fromUtf8(keyStr);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
    final encrypted = Encrypted.fromBase64(encryptText);
    // final encrypted = encrypter.encrypt(plainText, iv: iv);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

  static Uint8List _generateKey(String key) {
    final keyBytes = utf8.encode(key);
    final digest = sha256.convert(keyBytes);
    return Uint8List.fromList(digest.bytes);
  }

  static void encryptFileGeneral(File sourceFile, File encryptedFile, String key) {
    final sourceBytes = sourceFile.readAsBytesSync();
    final encrypter = Encrypter(AES(Key(_generateKey(key))));
    final iv = IV.fromLength(16);
    final encryptedBytes = encrypter.encryptBytes(sourceBytes, iv: iv);
    encryptedFile.writeAsBytesSync(encryptedBytes.bytes);
  }

  static void decryptFileGeneral(File encryptedFile, File decryptedFile, String key,
      {Function(List<int>)? bytesCallback}) {
    final encryptedBytes = encryptedFile.readAsBytesSync();
    final decrypter = Encrypter(AES(Key(_generateKey(key))));
    final encrypted = Encrypted(encryptedBytes);
    final iv = IV.fromLength(16);
    final decryptedBytes = decrypter.decryptBytes(encrypted, iv: iv);
    bytesCallback?.call(decryptedBytes);
    decryptedFile.writeAsBytesSync(decryptedBytes);
  }
}
