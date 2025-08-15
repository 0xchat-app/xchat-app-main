/// App configuration for 0xChat Lite
class AppConfig {
  /// App display name
  static const String appDisplayName = '0xChat Lite';
  
  /// App scheme for custom URLs
  static const String appScheme = 'oxchatlite';
  
  /// Base URL for invite links
  static const String inviteBaseUrl = 'https://0xchat.com/x/invite';
  
  /// Universal Links configuration
  static const List<String> supportedPaths = [
    '/lite',
    '/x/invite',
    '/lite/invite',
    '/lite/join',
    '/lite/profile',
  ];
  
  /// Get supported domains for Universal Links
  static List<String> get supportedDomains => [
    '0xchat.com',
    'www.0xchat.com',
  ];
  
  /// Check if a path is supported
  static bool isPathSupported(String path) {
    return supportedPaths.any((supportedPath) => 
      path.startsWith(supportedPath));
  }
} 