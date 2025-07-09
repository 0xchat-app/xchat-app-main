import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Account path utilities for handling database files and directories
/// 
/// Provides static methods for managing file system paths for account databases
/// and other files that may be stored in account folders.
/// Circle database paths are now managed internally by DBISAR.
class AccountPathUtils {
  // Private constructor to prevent instantiation
  AccountPathUtils._();

  // Cache for root directory path
  static String? _rootPath;

  // ========== Root Directory Management ==========

  /// Get application support directory path (cached)
  /// 
  /// Returns platform-specific directory for storing application data:
  /// - iOS: Library/Application Support (not backed up to iCloud)
  /// - Android: Application private directory
  static Future<String> _getRootPath() async {
    if (_rootPath != null) {
      return _rootPath!;
    }

    try {
      final directory = await getApplicationSupportDirectory();
      _rootPath = directory.path;
      return _rootPath!;
    } catch (e) {
      // Fallback to application documents directory if support directory fails
      final directory = await getApplicationDocumentsDirectory();
      _rootPath = directory.path;
      return _rootPath!;
    }
  }

  /// Clear cached root path (useful for testing)
  static void clearRootPathCache() {
    _rootPath = null;
  }

  // ========== Private Path Generation ==========

  /// Generate account folder path for given pubkey
  static Future<String> _getAccountFolderPath(String pubkey) async {
    final rootPath = await _getRootPath();
    return path.join(rootPath, 'accounts', pubkey);
  }

  /// Generate circle folder path for given pubkey and circle ID
  static Future<String> getCircleFolderPath(String pubkey, String circleId) async {
    final accountPath = await _getAccountFolderPath(pubkey);
    return path.join(accountPath, 'circles', circleId);
  }

  // ========== Public Path Interfaces ==========

  /// Get account database file path
  /// 
  /// [pubkey] User's public key
  /// Returns: {root}/accounts/{pubkey}/account.db
  static Future<String> getAccountDbPath(String pubkey) async {
    final accountPath = await _getAccountFolderPath(pubkey);
    return path.join(accountPath, 'account.db');
  }

  /// Get custom file path in account folder
  /// 
  /// [pubkey] User's public key
  /// [fileName] File name
  /// Returns: {root}/accounts/{pubkey}/{fileName}
  static Future<String> getAccountFilePath(String pubkey, String fileName) async {
    final accountPath = await _getAccountFolderPath(pubkey);
    return path.join(accountPath, fileName);
  }

  // ========== Directory Management ==========

  /// Check if account folder exists
  static Future<bool> accountFolderExists(String pubkey) async {
    final accountPath = await _getAccountFolderPath(pubkey);
    final dir = Directory(accountPath);
    return await dir.exists();
  }

  /// Create account folder if not exists
  static Future<bool> ensureAccountFolderExists(String pubkey) async {
    try {
      final accountPath = await _getAccountFolderPath(pubkey);
      final dir = Directory(accountPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create circle folder if not exists
  static Future<bool> ensureCircleFolderExists(String pubkey, String circleId) async {
    try {
      final circlePath = await getCircleFolderPath(pubkey, circleId);
      final dir = Directory(circlePath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== File Existence Checks ==========

  /// Check if account database file exists
  static Future<bool> accountDbExists(String pubkey) async {
    final filePath = await getAccountDbPath(pubkey);
    final file = File(filePath);
    return await file.exists();
  }

  /// Check if custom file exists in account folder
  static Future<bool> accountFileExists(String pubkey, String fileName) async {
    final filePath = await getAccountFilePath(pubkey, fileName);
    final file = File(filePath);
    return await file.exists();
  }

  // ========== Cleanup Operations ==========

  /// Delete account folder and all its contents
  static Future<bool> deleteAccountFolder(String pubkey) async {
    try {
      final accountPath = await _getAccountFolderPath(pubkey);
      final dir = Directory(accountPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete specific file in account folder
  static Future<bool> deleteAccountFile(String pubkey, String fileName) async {
    try {
      final filePath = await getAccountFilePath(pubkey, fileName);
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete circle folder and all its contents
  static Future<bool> deleteCircleFolder(String pubkey, String circleId) async {
    try {
      final circlePath = await getCircleFolderPath(pubkey, circleId);
      final dir = Directory(circlePath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== Utility Methods ==========

  /// List all files in account folder
  static Future<List<String>> listAccountFiles(String pubkey) async {
    try {
      final accountPath = await _getAccountFolderPath(pubkey);
      final accountDir = Directory(accountPath);
      if (!await accountDir.exists()) {
        return [];
      }

      final entities = await accountDir.list().toList();
      final files = <String>[];

      for (final entity in entities) {
        if (entity is File) {
          final fileName = entity.path.split('/').last;
          files.add(fileName);
        }
      }

      return files;
    } catch (e) {
      return [];
    }
  }

  /// Get total size of account folder
  static Future<int> getAccountFolderSize(String pubkey) async {
    try {
      final accountPath = await _getAccountFolderPath(pubkey);
      final dir = Directory(accountPath);
      if (!await dir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
} 