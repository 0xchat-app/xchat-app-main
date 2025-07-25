import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:file/file.dart' as file;
import 'package:file/local.dart';
import 'package:ox_common/login/account_path_manager.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'cache_manager.dart';

class CacheManagerHelper {
  /// key: cacheKey(circleId, fileType), Value: CacheManager.config
  static Map<String, Config> _configCache = {};

  /// Get target config based on circle and file type
  /// 
  /// [circleId] - The circle identifier
  /// [fileType] - The type of file (audio, image, video, file)
  /// Returns the cached config or creates a new one if not cached
  static Future<Config> getConfig(String circleId, CacheFileType fileType) async {
    final cacheKey = _generateCacheKey(circleId, fileType);
    
    // Check if config is already cached
    if (_configCache.containsKey(cacheKey)) {
      return _configCache[cacheKey]!;
    }
    
    // Create new config if not cached
    final config = await _createConfig(circleId, fileType);
    
    // Cache the config for future use
    _configCache[cacheKey] = config;
    
    return config;
  }

  /// Generate cache key for circle and file type combination
  static String _generateCacheKey(String circleId, CacheFileType fileType) {
    return '${circleId}_${fileType.name}';
  }

  /// Create a new config for the given circle and file type
  static Future<Config> _createConfig(String circleId, CacheFileType fileType) async {
    final fileTypeString = _getFileTypeString(fileType);
    final cacheKey = '${circleId}_${fileTypeString}_cached_data';

    final currentState = LoginManager.instance.currentState;
    final account = currentState.account;
    assert(account != null, 'Account is not logged in');

    final pubkey = account!.pubkey;
    final cacheMetaDir = await AccountPathManager.getCircleCachePath(pubkey, circleId);
    final cacheMetaPath = '$cacheMetaDir/${fileTypeString}_cached_data.json';

    return Config(
      cacheKey,
      repo: JsonCacheInfoRepository(
        path: cacheMetaPath,
      ),
      fileSystem: _IOCacheFileSystem(
        pubkey: pubkey,
        circleId: circleId,
        fileType: fileType,
      ),
      fileService: HttpFileService(),
    );
  }

  /// Convert CacheFileType to string for config creation
  static String _getFileTypeString(CacheFileType fileType) {
    switch (fileType) {
      case CacheFileType.audio:
        return 'Audio';
      case CacheFileType.image:
        return 'Image';
      case CacheFileType.video:
        return 'Video';
      case CacheFileType.file:
        return 'File';
    }
  }

  /// Clear config cache for a specific circle
  static void clearCircleConfig(String circleId) {
    final keysToRemove = <String>[];
    
    for (final key in _configCache.keys) {
      if (key.startsWith('${circleId}_')) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      _configCache.remove(key);
    }
  }

  /// Clear all config cache
  static void clearAllConfigs() {
    _configCache.clear();
  }

  /// Get the number of cached configs
  static int getCachedConfigCount() {
    return _configCache.length;
  }

  /// Check if a config is cached for the given circle and file type
  static bool isConfigCached(String circleId, CacheFileType fileType) {
    final cacheKey = _generateCacheKey(circleId, fileType);
    return _configCache.containsKey(cacheKey);
  }

  /// Cache a file using the appropriate CacheManager for the given file type
  /// 
  /// [file] - The file to be cached
  /// [url] - The URL of the file
  /// [fileType] - The type of file (audio, image, video, file)
  /// Returns the cached File object
  static Future<File> cacheFile(
    File file,
    String url,
    CacheFileType fileType,
  ) async {
    final cacheManager = await CLCacheManager.getCircleCacheManager(fileType);
    final fileBytes = await file.readAsBytes();
    return cacheManager.putFile(
      url, fileBytes,
      fileExtension:
      file.path.getFileExtension(),
    );
  }
}

class _IOCacheFileSystem implements FileSystem {
  final Future<file.Directory> _fileDir;

  _IOCacheFileSystem({
    required String pubkey,
    required String circleId,
    required CacheFileType fileType,
  }) : _fileDir = createDirectory(pubkey, circleId, fileType);

  static Future<file.Directory> createDirectory(
    String pubkey,
    String circleId,
    CacheFileType fileType,
  ) async {
    String path;
    switch (fileType) {
      case CacheFileType.image:
        path = await AccountPathManager.getCircleImageCachePath(pubkey, circleId);
      case CacheFileType.audio:
        path = await AccountPathManager.getCircleAudioCachePath(pubkey, circleId);
      case CacheFileType.video:
        path = await AccountPathManager.getCircleVideoCachePath(pubkey, circleId);
      case CacheFileType.file:
        path = await AccountPathManager.getCircleFileCachePath(pubkey, circleId);
    }

    const fs = LocalFileSystem();
    final directory = fs.directory(path);
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<file.File> createFile(String name) async {
    final directory = await _fileDir;
    return directory.childFile(name);
  }
}