import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'login_manager.dart';

/// Account path manager for handling database files and directories
/// 
/// Provides static methods for managing file system paths for account databases,
/// circle-specific files, and cache management. All persistent paths are unified here.
/// 
/// ## Directory Structure
/// ```
/// {root}/accounts/{pubkey}/
/// ├── account.db
/// └── circles/{circleId}/
///     ├── mls.db
///     ├── circle.sqlite
///     └── cache/
///         ├── cached_image_data.db (cache metadata)
///         ├── Image/
///         │   └── {encrypted image files}
///         ├── File/
///         │   └── {other cached files}
///         ├── Audio/
///         │   └── {audio files}
///         ├── Video/
///         │   └── {video files}
///         └── Temp/
///             └── {temporary files}
/// ```
class AccountPathManager {
  // Private constructor to prevent instantiation
  AccountPathManager._();

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

  // ========== Circle Cache Path Management ==========

  /// Get circle cache root directory path
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// Returns: {root}/accounts/{pubkey}/circles/{circleId}/cache/
  static Future<String> getCircleCachePath(String pubkey, String circleId) async {
    final circlePath = await getCircleFolderPath(pubkey, circleId);
    return path.join(circlePath, 'cache');
  }

  /// Get circle cache metadata database path
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// Returns: {root}/accounts/{pubkey}/circles/{circleId}/cache/cached_image_data.db
  static Future<String> getCircleCacheMetadataPath(String pubkey, String circleId) async {
    final cachePath = await getCircleCachePath(pubkey, circleId);
    return path.join(cachePath, 'cached_image_data.db');
  }

  /// Get circle cache file directory path for specific file type
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// [fileType] Type of cached files (Image, File, Audio, Video)
  /// Returns: {root}/accounts/{pubkey}/circles/{circleId}/cache/{fileType}/
  static Future<String> _getCircleCacheFilePath(String pubkey, String circleId, String fileType) async {
    final cachePath = await getCircleCachePath(pubkey, circleId);
    return path.join(cachePath, fileType);
  }

  /// Get circle image cache directory path
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// Returns: {root}/accounts/{pubkey}/circles/{circleId}/cache/Image/
  static Future<String> getCircleImageCachePath(String pubkey, String circleId) async {
    return _getCircleCacheFilePath(pubkey, circleId, 'Image');
  }

  /// Get circle file cache directory path
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// Returns: {root}/accounts/{pubkey}/circles/{circleId}/cache/File/
  static Future<String> getCircleFileCachePath(String pubkey, String circleId) async {
    return _getCircleCacheFilePath(pubkey, circleId, 'File');
  }

  /// Get circle audio cache directory path
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// Returns: {root}/accounts/{pubkey}/circles/{circleId}/cache/Audio/
  static Future<String> getCircleAudioCachePath(String pubkey, String circleId) async {
    return _getCircleCacheFilePath(pubkey, circleId, 'Audio');
  }

  /// Get circle video cache directory path
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// Returns: {root}/accounts/{pubkey}/circles/{circleId}/cache/Video/
  static Future<String> getCircleVideoCachePath(String pubkey, String circleId) async {
    return _getCircleCacheFilePath(pubkey, circleId, 'Video');
  }

  /// Get circle temp cache directory path
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// Returns: {root}/accounts/{pubkey}/circles/{circleId}/cache/Temp/
  static Future<String> _getCircleTempCachePath(String pubkey, String circleId) async {
    return _getCircleCacheFilePath(pubkey, circleId, 'Temp');
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

  /// Get circle database file path
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// Returns: {root}/accounts/{pubkey}/circles/{circleId}/circle.sqlite
  static Future<String> getCircleDbPath(String pubkey, String circleId) async {
    final circlePath = await getCircleFolderPath(pubkey, circleId);
    return path.join(circlePath, 'circle.sqlite');
  }

  /// Get circle MLS database file path
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// Returns: {root}/accounts/{pubkey}/circles/{circleId}/mls.db
  static Future<String> getCircleMlsDbPath(String pubkey, String circleId) async {
    final circlePath = await getCircleFolderPath(pubkey, circleId);
    return path.join(circlePath, 'mls.db');
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

  /// Create circle cache directory structure if not exists
  /// 
  /// Creates the complete cache directory structure:
  /// - cache/
  /// - cache/Image/
  /// - cache/File/
  /// - cache/Audio/
  /// - cache/Video/
  /// - cache/Temp/
  static Future<bool> ensureCircleCacheExists(String pubkey, String circleId) async {
    try {
      // Ensure circle folder exists first
      await ensureCircleFolderExists(pubkey, circleId);
      
      // Create cache directories
      final cachePaths = [
        await getCircleCachePath(pubkey, circleId),
        await getCircleImageCachePath(pubkey, circleId),
        await getCircleFileCachePath(pubkey, circleId),
        await getCircleAudioCachePath(pubkey, circleId),
        await getCircleVideoCachePath(pubkey, circleId),
        await _getCircleTempCachePath(pubkey, circleId),
      ];
      
      for (final cachePath in cachePaths) {
        final dir = Directory(cachePath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
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

  /// Check if circle database file exists
  static Future<bool> circleDbExists(String pubkey, String circleId) async {
    final filePath = await getCircleDbPath(pubkey, circleId);
    final file = File(filePath);
    return await file.exists();
  }

  /// Check if circle MLS database file exists
  static Future<bool> circleMlsDbExists(String pubkey, String circleId) async {
    final filePath = await getCircleMlsDbPath(pubkey, circleId);
    final file = File(filePath);
    return await file.exists();
  }

  /// Check if circle cache metadata exists
  static Future<bool> circleCacheMetadataExists(String pubkey, String circleId) async {
    final filePath = await getCircleCacheMetadataPath(pubkey, circleId);
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

  /// Delete circle cache directory and all its contents
  static Future<bool> deleteCircleCache(String pubkey, String circleId) async {
    try {
      final cachePath = await getCircleCachePath(pubkey, circleId);
      final dir = Directory(cachePath);
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

  /// Get total size of circle cache
  static Future<int> getCircleCacheSize(String pubkey, String circleId) async {
    try {
      final cachePath = await getCircleCachePath(pubkey, circleId);
      final dir = Directory(cachePath);
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

  /// Get cache size by file type
  static Future<int> getCircleCacheSizeByType(String pubkey, String circleId, String fileType) async {
    try {
      final cachePath = await _getCircleCacheFilePath(pubkey, circleId, fileType);
      final dir = Directory(cachePath);
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

  // ========== Temp Folder Cleanup ==========

  /// Create temporary file in current circle temp folder
  /// 
  /// [suffix] File extension (e.g., '.txt', '.jpg', '.mp4')
  /// Returns: File object of the created temporary file
  /// Throws: Exception if not logged in or no current circle
  static Future<File> createTempFile({String fileExt = ''}) async {
    try {
      // Get current login state
      final loginManager = LoginManager.instance;
      final currentState = loginManager.currentState;
      
      final pubkey = loginManager.currentPubkey;
      final circleId = currentState.currentCircle?.id;
      
      // Validate parameters
      if (pubkey.isEmpty) {
        throw Exception('Invalid pubkey');
      }
      
      if (circleId == null || circleId.isEmpty) {
        throw Exception('Invalid circle ID');
      }

      // Ensure temp folder exists
      final tempPath = await _getCircleTempCachePath(pubkey, circleId);
      final tempDir = Directory(tempPath);
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      // Generate random filename with UUID
      final uuid = Uuid().v4();
      if (fileExt.isNotEmpty) fileExt = '.$fileExt';
      final fileName = '$uuid$fileExt';
      final filePath = path.join(tempPath, fileName);

      // Create and return the file
      final file = File(filePath);
      await file.create();
      return file;
    } catch (e) {
      throw Exception('Failed to create temp file: $e');
    }
  }

  /// Clear temp folder for specific circle
  /// 
  /// [pubkey] User's public key
  /// [circleId] Circle ID
  /// Returns: Number of files successfully deleted
  static Future<int> clearCircleTempFolder(String pubkey, String circleId) async {
    try {
      final tempPath = await _getCircleTempCachePath(pubkey, circleId);
      final dir = Directory(tempPath);
      if (!await dir.exists()) {
        return 0;
      }

      int deletedCount = 0;
      await for (final entity in dir.list()) {
        if (entity is File) {
          try {
            await entity.delete();
            deletedCount++;
          } catch (e) {
            // Continue with other files if deletion fails
          }
        }
      }
      return deletedCount;
    } catch (e) {
      return 0;
    }
  }

  /// Clear temp folders for specific account
  /// 
  /// [pubkey] User's public key
  /// Returns: Number of files successfully deleted
  static Future<int> clearAccountTempFolders(String pubkey) async {
    try {
      final accountPath = await _getAccountFolderPath(pubkey);
      final accountDir = Directory(accountPath);
      if (!await accountDir.exists()) {
        return 0;
      }

      int totalDeleted = 0;
      final circlesDir = Directory(path.join(accountPath, 'circles'));
      if (!await circlesDir.exists()) {
        return 0;
      }

      await for (final circleEntity in circlesDir.list()) {
        if (circleEntity is Directory) {
          final circleId = path.basename(circleEntity.path);
          final deletedCount = await clearCircleTempFolder(pubkey, circleId);
          totalDeleted += deletedCount;
        }
      }
      return totalDeleted;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all temp folders for all accounts
  /// 
  /// Returns: Number of files successfully deleted
  static Future<int> clearAllTempFolders() async {
    try {
      final rootPath = await _getRootPath();
      final accountsDir = Directory(path.join(rootPath, 'accounts'));
      if (!await accountsDir.exists()) {
        return 0;
      }

      int totalDeleted = 0;
      await for (final accountEntity in accountsDir.list()) {
        if (accountEntity is Directory) {
          final pubkey = path.basename(accountEntity.path);
          final deletedCount = await clearAccountTempFolders(pubkey);
          totalDeleted += deletedCount;
        }
      }
      return totalDeleted;
    } catch (e) {
      return 0;
    }
  }
} 