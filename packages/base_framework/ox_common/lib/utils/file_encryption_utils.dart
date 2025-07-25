import 'dart:io';
import 'dart:typed_data';
import 'package:ox_common/login/account_path_manager.dart';
import 'package:ox_common/utils/aes_encrypt_utils.dart';
import 'package:ox_common/utils/string_utils.dart';

/// Utility class for handling file encryption and decryption operations
class FileEncryptionUtils {
  /// Encrypts a file and saves it to a temporary file
  /// 
  /// [sourceFile] - The source file to encrypt
  /// [encryptKey] - The encryption key
  /// [encryptNonce] - The encryption nonce (optional)
  /// 
  /// Returns the encrypted file as a File object
  static Future<File> encryptFile({
    required File sourceFile,
    required String encryptKey,
    String? encryptNonce,
  }) async {
    final tempFile = await AccountPathManager.createTempFile(
      fileExt: sourceFile.path.getFileExtension(),
    );
    
    await AesEncryptUtils.encryptFileInIsolate(
      sourceFile,
      tempFile,
      encryptKey,
      nonce: encryptNonce,
    );
    
    return tempFile;
  }
  /// Decrypts an encrypted file in memory and returns the decrypted bytes
  /// 
  /// [encryptedFile] - The encrypted file to decrypt
  /// [decryptKey] - The decryption key
  /// [decryptNonce] - The decryption nonce (optional)
  /// 
  /// Returns the decrypted file bytes as Uint8List
  static Future<Uint8List> decryptFileInMemory(
    File encryptedFile,
    String decryptKey,
    String? decryptNonce,
  ) async {
    try {
      final bytes = await AesEncryptUtils.decryptFileOnMemoryInIsolate(
        encryptedFile,
        decryptKey,
        nonce: decryptNonce,
      );
      return Uint8List.fromList(bytes);
    } catch (_) {
      return Uint8List(0);
    }
  }

  /// Decrypts an encrypted file and saves it to a temporary file
  /// 
  /// [encryptedFile] - The encrypted file to decrypt
  /// [decryptKey] - The decryption key
  /// [decryptNonce] - The decryption nonce (optional)
  /// 
  /// Returns the decrypted file as a File object
  static Future<File> decryptFile({
    required File encryptedFile,
    required String decryptKey,
    String? decryptNonce,
  }) async {
    final bytes = await decryptFileInMemory(encryptedFile, decryptKey, decryptNonce);
    final tempFile = await AccountPathManager.createTempFile(
      fileExt: encryptedFile.path.getFileExtension(),
    );
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }
} 