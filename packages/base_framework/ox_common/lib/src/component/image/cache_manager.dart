import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/account_path_manager.dart';

import 'cache_manager_helper.dart';
import 'constant.dart';

export 'constant.dart';

/// Cache manager for CLCachedNetworkImage with circle-specific isolation
class CLCacheManager {
  // Private constructor to prevent instantiation
  CLCacheManager._();

  /// Get a circle-specific cache manager for a specific file type
  /// 
  /// [fileType] - Type of files to cache (Audio, Image, Video, File)
  /// Returns a cache manager configured for the specified file type
  static Future<CacheManager> getCircleCacheManager(CacheFileType fileType) async {
    final currentState = LoginManager.instance.currentState;
    final account = currentState.account;
    final circle = currentState.currentCircle;
    
    if (account == null || circle == null) {
      // Fall back to default cache manager if no circle is active
      assert(false, 'Error Scene');
      return DefaultCacheManager();
    }

    // Get circle cache path for cache storage
    Config managerConfig = await CacheManagerHelper.getConfig(circle.id, fileType);

    // Ensure circle cache directory structure exists
    await AccountPathManager.ensureCircleCacheExists(account.pubkey, circle.id);

    // Use singleton pattern to get or create cache manager for specific type
    return CircleDefaultCacheManager(managerConfig, circle.id, fileType);
  }

  static CacheManager? getCircleCacheManagerSync(CacheFileType fileType) {
    final currentState = LoginManager.instance.currentState;
    final account = currentState.account;
    final circle = currentState.currentCircle;

    if (account == null || circle == null) {
      // Fall back to default cache manager if no circle is active
      assert(false, 'Error Scene');
      return DefaultCacheManager();
    }

    return CircleDefaultCacheManager.get(circle.id, fileType);
  }

  /// Empty cache for all circles
  static Future<void> clearAllCircleCache() async {
    final currentState = LoginManager.instance.currentState;
    final account = currentState.account;
    
    if (account == null) {
      return;
    }

    // Clear all singleton instances after clearing cache
    CircleDefaultCacheManager.clearInstances();
  }
  
  /// Clear cache for a specific circle and remove its singleton instance
  static Future<void> clearCircleCacheById(String circleId) async {
    final currentState = LoginManager.instance.currentState;
    final account = currentState.account;
    
    if (account == null) {
      return;
    }

    try {
      // Clear all file types for this circle
      for (final fileType in CacheFileType.values) {
        // Remove the singleton instance
        CircleDefaultCacheManager.removeInstance(circleId, fileType);
      }
    } catch (e) {
      print('Failed to clear cache for circle $circleId: $e');
    }
  }
}

/// Circle-specific default cache manager that stores cache in circle cache directory
/// 
/// This class implements a singleton pattern to ensure consistent store and helper objects
/// across different instances for the same circle and file type.
class CircleDefaultCacheManager extends CacheManager with ImageCacheManager {
  final String circleId;
  final CacheFileType fileType;
  
  // Static cache to store instances by circleId
  static final Map<String, CircleDefaultCacheManager> _instances = {};

  // Private constructor
  CircleDefaultCacheManager._internal(Config config, this.circleId, this.fileType)
    : super(config);
  
  /// Factory constructor that returns singleton instance for the given circleId and fileType
  factory CircleDefaultCacheManager(Config config, String circleId, CacheFileType fileType) {
    final key = _generateCacheKey(circleId, fileType);
    
    if (!_instances.containsKey(key)) {
      // Create new instance if it doesn't exist
      _instances[key] = CircleDefaultCacheManager._internal(config, circleId, fileType);
    }
    
    return _instances[key]!;
  }

  static CircleDefaultCacheManager? get(String circleId, CacheFileType fileType) {
    final key = _generateCacheKey(circleId, fileType);
    return _instances[key];
  }

  /// Generate cache key
  static String _generateCacheKey(String circleId, CacheFileType fileType) {
    return '${circleId}_${_getFileTypeString(fileType)}';
  }
  
  /// Clear all cached instances
  /// This should be called when switching accounts or clearing all cache
  static void clearInstances() {
    final managers = [..._instances.values];
    _instances.clear();
    managers.forEach((e) => e.emptyCache());
  }
  
  /// Remove specific circle instance for a file type
  /// This should be called when deleting a specific circle or clearing specific cache type
  static void removeInstance(String circleId, CacheFileType fileType) {
    final key = _generateCacheKey(circleId, fileType);
    final manager = _instances.remove(key);
    manager?.emptyCache();
  }

  /// Convert CacheFileType to string for instance key
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
} 