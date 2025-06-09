import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Account path utilities for handling database files and directories
/// 
/// Provides static methods for managing file system paths for account and circle databases,
/// as well as other files that may be stored in account/circle folders.
/// Uses platform-specific application support directory as root path.
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
  static Future<String> _getCircleFolderPath(String pubkey, String circleId) async {
    final accountPath = await _getAccountFolderPath(pubkey);
    return path.join(accountPath, circleId);
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

  /// Get circle database file path
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle identifier
  /// Returns: {root}/accounts/{pubkey}/{circleId}/circle.db
  static Future<String> getCircleDbPath(String pubkey, String circleId) async {
    final circlePath = await _getCircleFolderPath(pubkey, circleId);
    return path.join(circlePath, 'circle.db');
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

  /// Get custom file path in circle folder
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle identifier
  /// [fileName] File name
  /// Returns: {root}/accounts/{pubkey}/{circleId}/{fileName}
  static Future<String> getCircleFilePath(String pubkey, String circleId, String fileName) async {
    final circlePath = await _getCircleFolderPath(pubkey, circleId);
    return path.join(circlePath, fileName);
  }

  // ========== Directory Management ==========

  /// Check if account folder exists
  static Future<bool> accountFolderExists(String pubkey) async {
    final accountPath = await _getAccountFolderPath(pubkey);
    final dir = Directory(accountPath);
    return await dir.exists();
  }

  /// Check if circle folder exists
  static Future<bool> circleFolderExists(String pubkey, String circleId) async {
    final circlePath = await _getCircleFolderPath(pubkey, circleId);
    final dir = Directory(circlePath);
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
      final circlePath = await _getCircleFolderPath(pubkey, circleId);
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

  /// Check if custom file exists in circle folder
  static Future<bool> circleFileExists(String pubkey, String circleId, String fileName) async {
    final filePath = await getCircleFilePath(pubkey, circleId, fileName);
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

  /// Delete circle folder and its contents
  static Future<bool> deleteCircleFolder(String pubkey, String circleId) async {
    try {
      final circlePath = await _getCircleFolderPath(pubkey, circleId);
      final dir = Directory(circlePath);
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

  /// Delete specific file in circle folder
  static Future<bool> deleteCircleFile(String pubkey, String circleId, String fileName) async {
    try {
      final filePath = await getCircleFilePath(pubkey, circleId, fileName);
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== Utility Methods ==========

  /// List all circle folders for given account
  static Future<List<String>> listCircleFolders(String pubkey) async {
    try {
      final accountPath = await _getAccountFolderPath(pubkey);
      final accountDir = Directory(accountPath);
      if (!await accountDir.exists()) {
        return [];
      }

      final entities = await accountDir.list().toList();
      final circleFolders = <String>[];

      for (final entity in entities) {
        if (entity is Directory) {
          final folderName = entity.path.split('/').last;
          // Skip files, only include circle folders
          if (!folderName.contains('.')) {
            circleFolders.add(folderName);
          }
        }
      }

      return circleFolders;
    } catch (e) {
      return [];
    }
  }

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

  /// List all files in circle folder
  static Future<List<String>> listCircleFiles(String pubkey, String circleId) async {
    try {
      final circlePath = await _getCircleFolderPath(pubkey, circleId);
      final circleDir = Directory(circlePath);
      if (!await circleDir.exists()) {
        return [];
      }

      final entities = await circleDir.list().toList();
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

  /// Get total size of circle folder
  static Future<int> getCircleFolderSize(String pubkey, String circleId) async {
    try {
      final circlePath = await _getCircleFolderPath(pubkey, circleId);
      final dir = Directory(circlePath);
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