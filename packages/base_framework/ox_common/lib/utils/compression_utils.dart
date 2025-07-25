import 'dart:convert';

/// Compression utilities for keypackage data
/// 
/// Uses base64 compression to reduce the size of encoded keypackage strings
/// for better QR code readability and URL sharing
class CompressionUtils {
  /// Compress keypackage data using base64 encoding
  /// Returns compressed string or null if compression fails
  static Future<String?> compressKeyPackage(String keyPackageData) async {
    try {
      if (keyPackageData.isEmpty) return null;
      
      // Convert hex string to bytes
      List<int> bytes = [];
      for (int i = 0; i < keyPackageData.length; i += 2) {
        if (i + 1 < keyPackageData.length) {
          bytes.add(int.parse(keyPackageData.substring(i, i + 2), radix: 16));
        }
      }
      
      // Encode to base64
      String base64Encoded = base64Url.encode(bytes);
      
      // Only return compressed data if it's actually smaller
      if (base64Encoded.length >= keyPackageData.length) {
        return null;
      }
      
      return base64Encoded;
    } catch (e) {
      print('Keypackage compression error: $e');
      return null;
    }
  }
  
  /// Decompress keypackage data using base64 decoding
  /// Returns decompressed string or null if decompression fails
  static Future<String?> decompressKeyPackage(String compressedData) async {
    try {
      if (compressedData.isEmpty) return null;
      
      // Decode from base64
      List<int> bytes = base64Url.decode(compressedData);
      
      // Convert bytes back to hex string
      String hexString = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
      
      return hexString;
    } catch (e) {
      print('Keypackage decompression error: $e');
      return null;
    }
  }
  
  /// Check if data is compressed (starts with compression marker)
  static bool isCompressed(String data) {
    // Base64 compressed data starts with 'CMP:' prefix
    return data.startsWith('CMP:');
  }
  
  /// Compress with custom prefix for identification
  static Future<String?> compressWithPrefix(String keyPackageData) async {
    final compressed = await compressKeyPackage(keyPackageData);
    if (compressed != null) {
      return 'CMP:$compressed';
    }
    return null;
  }
  
  /// Decompress with custom prefix handling
  static Future<String?> decompressWithPrefix(String data) async {
    if (isCompressed(data)) {
      final compressedData = data.substring(4); // Remove 'CMP:' prefix
      return await decompressKeyPackage(compressedData);
    }
    return data; // Return as-is if not compressed
  }
  
  /// Get compression ratio (compressed size / original size)
  static double getCompressionRatio(String original, String compressed) {
    if (original.isEmpty) return 1.0;
    return compressed.length / original.length;
  }
  
  /// Check if compression is beneficial
  static bool isCompressionBeneficial(String original, String compressed) {
    return getCompressionRatio(original, compressed) < 0.9; // 10% reduction threshold
  }
} 