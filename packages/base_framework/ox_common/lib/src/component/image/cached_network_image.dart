import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/num_utils.dart';

import 'cache_manager.dart';
import 'encrypted_image_provider.dart';

/// A stateful widget that manages ImageProvider lifecycle with optimized defaults.
/// 
/// This widget provides a unified solution for image provider creation with
/// automatic retry, lifecycle management, and state persistence.
/// 
/// ## Features
/// 
/// - **Automatic retry**: Smart retry logic with optimized defaults
/// - **Lifecycle management**: Properly manages provider lifecycle
/// - **Cache optimization**: Optimizes cache usage with circle-specific management
/// - **Memory management**: Efficient memory usage
/// - **Error handling**: Comprehensive error handling with retry strategies
/// - **Encrypted image support**: Automatic decryption and caching
/// 
/// ## Usage Examples
/// 
/// ### Basic usage with optimized defaults
/// ```dart
/// CLCachedImageProviderStateful(
///   imageUrl: 'https://example.com/image.jpg',
///   builder: (context, provider, loading, error) {
///     if (loading) return CircularProgressIndicator();
///     if (error != null) return Icon(Icons.error);
///     return Image(image: provider!);
///   },
/// )
/// ```
/// 
/// ### Encrypted image with custom retry
/// ```dart
/// CLCachedImageProviderStateful(
///   imageUrl: 'https://example.com/encrypted.jpg',
///   decryptKey: 'abc123...',
///   decryptNonce: 'def456...',
///   maxRetries: 3,
///   retryDelay: Duration(seconds: 2),
///   builder: (context, provider, loading, error) {
///     if (loading) return CircularProgressIndicator();
///     if (error != null) return Icon(Icons.error);
///     return Image(image: provider!);
///   },
/// )
/// ```
/// 
/// ### Thumbnail optimization
/// ```dart
/// CLCachedImageProviderStateful(
///   imageUrl: 'https://example.com/image.jpg',
///   isThumb: true,
///   width: 80,
///   height: 80,
///   builder: (context, provider, loading, error) {
///     if (loading) return CircularProgressIndicator();
///     if (error != null) return Icon(Icons.error);
///     return Image(image: provider!, width: 80, height: 80);
///   },
/// )
/// ```
class CLCachedImageProviderStateful extends StatefulWidget {
  /// The URL of the image to load
  final String imageUrl;

  /// Decryption key for encrypted images
  final String? decryptKey;

  /// Decryption nonce for encrypted images
  final String? decryptNonce;

  /// Target width for resizing
  final double? width;

  /// Target height for resizing
  final double? height;

  /// Whether this image should be treated as a thumbnail
  final bool isThumb;

  /// Maximum number of retry attempts (default: 1 for optimal UX)
  final int maxRetries;

  /// Delay between retry attempts (default: 500ms for quick retry)
  final Duration retryDelay;

  /// Builder function that receives the provider state
  final Widget Function(
    BuildContext context,
    ImageProvider? provider,
    bool loading,
    Object? error,
  ) builder;

  /// Creates a stateful widget that manages ImageProvider lifecycle.
  /// 
  /// [imageUrl] must not be null or empty.
  /// [builder] is called with the current state (provider, loading, error).
  /// [maxRetries] determines how many times to retry on failure (default: 1).
  /// [retryDelay] is the delay between retry attempts (default: 500ms).
  /// 
  /// The default retry configuration is optimized for most use cases:
  /// - 1 retry attempt provides good UX without excessive network usage
  /// - 500ms delay is fast enough for users to notice improvement
  /// - For special cases, you can customize maxRetries and retryDelay
  CLCachedImageProviderStateful({
    super.key,
    required this.imageUrl,
    this.decryptKey,
    this.decryptNonce,
    this.width,
    this.height,
    this.isThumb = false,
    this.maxRetries = 1,
    this.retryDelay = const Duration(milliseconds: 500),
    required this.builder,
  }) : assert(imageUrl.isNotEmpty, 'Image URL cannot be empty'),
       assert(maxRetries >= 0, 'maxRetries must be non-negative');

  @override
  State<CLCachedImageProviderStateful> createState() => _CLCachedImageProviderStatefulState();
}

class _CLCachedImageProviderStatefulState extends State<CLCachedImageProviderStateful> {
  ImageProvider? _provider;
  bool _loading = true;
  Object? _error;
  int _retryCount = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _createProvider();
  }

  @override
  void didUpdateWidget(CLCachedImageProviderStateful oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Recreate provider if key parameters changed
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.decryptKey != widget.decryptKey ||
        oldWidget.decryptNonce != widget.decryptNonce ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.isThumb != widget.isThumb) {
      _resetAndCreateProvider();
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _resetAndCreateProvider() {
    _retryTimer?.cancel();
    setState(() {
      _provider = null;
      _loading = true;
      _error = null;
      _retryCount = 0;
    });
    _createProvider();
  }

  Future<void> _createProvider() async {
    try {
      final devicePixelRatio = Adapt.devicePixelRatio;
      int? cacheWidth;
      int? cacheHeight;
      if (widget.width != null) {
        cacheWidth = (widget.width! * devicePixelRatio).floor();
      }
      if (widget.height != null) {
        cacheHeight = (widget.height! * devicePixelRatio).floor();
      }
      final provider = await CLEncryptedImageProvider(
        url: widget.imageUrl,
        decryptKey: widget.decryptKey,
        decryptNonce: widget.decryptNonce,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        // isThumb: widget.isThumb,
      );

      if (mounted) {
        setState(() {
          _provider = provider;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _handleError(e);
      }
    }
  }

  void _handleError(Object error) {
    if (_retryCount < widget.maxRetries) {
      // Schedule retry
      _retryCount++;
      _retryTimer = Timer(widget.retryDelay, () {
        if (mounted) {
          _createProvider();
        }
      });
      
      setState(() {
        _error = error;
        _loading = false;
      });
    } else {
      // Max retries reached
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _provider, _loading, _error);
  }
}

/// A cached network image widget that provides optimized image loading and caching.
/// 
/// This widget extends the functionality of [CachedNetworkImage] with additional
/// features like encrypted image support and circle-specific cache management.
/// 
/// ## Features
/// 
/// - **Circle-specific caching**: Images can be cached in the current circle's folder
/// - **Encrypted image support**: Automatic decryption of AES encrypted images
/// - **Thumbnail optimization**: Automatic size reduction for thumbnail images
/// - **Memory optimization**: Efficient memory cache management
/// - **Error handling**: Comprehensive error handling with fallback widgets
/// 
/// ## Usage Examples
/// 
/// ### Basic usage with circle cache (default)
/// ```dart
/// CLCachedNetworkImage(
///   imageUrl: 'https://example.com/image.jpg',
///   width: 200,
///   height: 200,
/// )
/// ```
/// 
/// ### Encrypted image
/// ```dart
/// CLCachedNetworkImage(
///   imageUrl: 'https://example.com/encrypted.jpg',
///   decryptKey: 'abc123...',
///   decryptNonce: 'def456...',
///   width: 200,
///   height: 200,
/// )
/// ```
/// 
/// ### All images use circle-specific cache
/// ```dart
/// CLCachedNetworkImage(
///   imageUrl: 'https://example.com/image.jpg',
///   width: 200,
///   height: 200,
/// )
/// ```
/// 
/// ### Thumbnail with circle cache
/// ```dart
/// CLCachedNetworkImage(
///   imageUrl: 'https://example.com/image.jpg',
///   isThumb: true,
///   width: 80,
///   height: 80,
/// )
/// ```
class CLCachedNetworkImage extends StatelessWidget {
  /// The URL of the image to load
  final String imageUrl;

  /// Decryption key for encrypted images
  final String? decryptKey;

  /// Decryption nonce for encrypted images
  final String? decryptNonce;

  /// How to inscribe the image into the space during layout
  final BoxFit? fit;

  /// The width of the image
  final double? width;

  /// The height of the image
  final double? height;

  /// Widget displayed while the image is loading
  final PlaceholderWidgetBuilder? placeholder;

  /// Widget displayed when the image fails to load
  final LoadingErrorWidgetBuilder? errorWidget;

  /// Whether to use circle-specific cache manager
  /// Currently always uses circle-specific cache to avoid creating global cache files
  /// This parameter is kept for backward compatibility but has no effect
  final bool useCircleCache;

  /// Whether this image should be treated as a thumbnail
  /// When true, the image will be cached with reduced dimensions for better performance
  final bool isThumb;

  /// Creates an optimized cached network image widget.
  /// 
  /// [imageUrl] must not be null or empty.
  /// [decryptKey] and [decryptNonce] are required for encrypted images.
  /// [useCircleCache] currently has no effect - all images use circle-specific cache.
  /// [isThumb] when true, optimizes the image for thumbnail display with reduced cache dimensions.
  CLCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.decryptKey,
    this.decryptNonce,
    this.fit,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.useCircleCache = true,
    this.isThumb = false,
  }) : assert(imageUrl.isNotEmpty, 'Image URL cannot be empty');

  @override
  Widget build(BuildContext context) {
    // Validate image URL
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context, 'Invalid image URL');
    }

    // Check if this is an encrypted image
    final isEncrypted = decryptKey != null && decryptKey!.isNotEmpty;

    if (isEncrypted) {
      // For encrypted images, use a custom approach
      return _buildEncryptedImage(context);
    } else {
      // Use standard cached network image for non-encrypted images
      // Always use circle cache manager to avoid creating global cache files
      return FutureBuilder<CacheManager>(
        future: CLCacheManager.getCircleCacheManager(CacheFileType.image),
        builder: (context, snapshot) {
          final cacheManager = snapshot.data;
          if (cacheManager == null) return SizedBox();

          return _buildCachedNetworkImage(context, cacheManager);
        },
      );
    }
  }

  Widget _buildEncryptedImage(BuildContext context) {
    return Image(
      image: CLEncryptedImageProvider(
        url: imageUrl,
        decryptKey: decryptKey,
        decryptNonce: decryptNonce,
      ),
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        return placeholder?.call(context, imageUrl) ?? _buildPlaceholderWidget(context);
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return errorWidget?.call(context, imageUrl, error) ??
            _buildErrorWidget(context, error);
      },
    );
  }

  Widget _buildCachedNetworkImage(BuildContext context, CacheManager cacheManager) {
    final ratio = MediaQuery.of(context).devicePixelRatio;

    // Calculate memory cache dimensions for better performance
    int? memCacheWidth;
    if (width != null && width != double.infinity && width!.isValid()) {
      memCacheWidth = (width! * ratio).round();
    }

    int? memCacheHeight;
    if (height != null && height != double.infinity && height!.isValid()) {
      memCacheHeight = (height! * ratio).round();
    }

    // Generate cache key and disk cache dimensions for thumbnails
    String? cacheKey;
    int? maxWidthDiskCache;
    int? maxHeightDiskCache;
    if (isThumb) {
      // Use a fixed size for thumbnails to avoid dependency on Adapt.px
      final thumbWidth = (80 * ratio).round();
      final thumbHeight = (80 * ratio).round();
      cacheKey = '${imageUrl.hashCode}_thumb_${thumbWidth}x${thumbHeight}';
      maxWidthDiskCache = thumbWidth;
      maxHeightDiskCache = thumbHeight;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: cacheManager,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      cacheKey: cacheKey,
      maxWidthDiskCache: maxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache,
      placeholder: placeholder ?? (context, url) => _buildPlaceholderWidget(context),
      errorWidget: errorWidget ?? (context, url, error) => _buildErrorWidget(context, error),
    );
  }

  Widget _buildPlaceholderWidget(BuildContext context, [String? url]) {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, [dynamic error]) {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.error, color: Colors.red),
      ),
    );
  }

  // Memory cache with size limit to prevent memory leaks
  static final Map<String, Size> _base64SizeCache = <String, Size>{};
  static const int _maxBase64CacheSize = 100; // Limit cache to 100 entries

  /// Gets the size of a base64 encoded image.
  /// 
  /// This method provides a cached way to get image dimensions from base64 data
  /// without fully decoding the image. The result is cached in memory for performance.
  /// 
  /// ## Parameters
  /// 
  /// - [imageBase64]: The base64 encoded image data (with or without data URI prefix)
  /// 
  /// ## Returns
  /// 
  /// The [Size] of the image if available, null if not yet decoded or on error.
  /// 
  /// ## Usage Example
  /// 
  /// ```dart
  /// final size = CLCachedNetworkImage.getImageSizeWithBase64(base64Data);
  /// if (size != null) {
  ///   print('Image size: ${size.width}x${size.height}');
  /// }
  /// ```
  static Size? getImageSizeWithBase64(String imageBase64) {
    String _cacheKeyWithBase64(String imageBase64) {
      return md5.convert(utf8.encode(imageBase64)).toString();
    }

    Uint8List _base64ToBytes(String imageBase64) {
      final base64String = imageBase64.split(',').last;
      return base64.decode(base64String);
    }

    final cacheKey = _cacheKeyWithBase64(imageBase64);
    final size = _base64SizeCache[cacheKey];
    if (size != null) return size;

    // Clean cache if it's too large
    if (_base64SizeCache.length >= _maxBase64CacheSize) {
      _base64SizeCache.clear();
    }

    decodeImageFromList(_base64ToBytes(imageBase64)).then((image) {
      final size = Size(image.width.toDouble(), image.height.toDouble());
      _base64SizeCache[cacheKey] = size;
    });

    return null;
  }
}

 