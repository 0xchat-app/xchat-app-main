import '../const/common_constant.dart';
import '../const/app_config.dart';
import '../log_util.dart';
import '../ox_common.dart';
import '../utils/platform_utils.dart';

typedef SchemeHandler = Function(String uri, String action, Map<String, String> queryParameters);

class SchemeHelper {

  static SchemeHandler? defaultHandler;
  static Map<String, SchemeHandler> schemeAction = {};

  static register(String action, SchemeHandler handler) {
    schemeAction[action.toLowerCase()] = handler;
  }

  static tryHandlerForOpenAppScheme() async {
    if(!PlatformUtils.isMobile) return;
    String url = await OXCommon.channelPreferences.invokeMethod(
      'getAppOpenURL',
    );
    LogUtil.d("App open URL: $url");

    if (url.isNotEmpty) {
      LogUtil.d("Processing Universal Link: $url");
      await handleAppURI(url);
    } else {
      LogUtil.d("No Universal Link to process");
    }
  }

  static handleAppURI(String uri) async {
    if (uri.isEmpty) return ;

    // Handle custom scheme formats first (xchat://, nostr://)
    if (uri.startsWith('xchat://') || uri.startsWith('xchat:') || uri.startsWith('nostr://') || uri.startsWith('nostr:')) {
      // This is a custom scheme, handle it directly
      LogUtil.d('Processing custom scheme: $uri');
      
      // Handle xchat://invite format (absolute path)
      if (uri.startsWith('xchat://invite')) {
        LogUtil.d('Processing xchat://invite scheme: $uri');
        if (defaultHandler != null) {
          final handler = defaultHandler!;
          await handler(uri, 'invite_link', {});
        }
        return;
      }
      
      // Handle xchat:nprofile format
      if (uri.startsWith('xchat:nprofile')) {
        final nprofile = uri.replaceFirst('xchat:', '');
        if (nprofile.isNotEmpty) {
          // Handle nprofile directly (main app scheme)
          defaultHandler?.call(uri, 'nprofile', {'value': nprofile});
          return;
        }
      }
      
      // Handle nostr content
      if (uri.startsWith('nostr:')) {
        final nostrContent = uri.replaceFirst('nostr:', '');
        if (nostrContent.isNotEmpty) {
          // Handle nostr content directly
          defaultHandler?.call(uri, 'nostr', {'value': nostrContent});
          return;
        }
      }
      
      return;
    }

    // Handle Universal Links for 0xchat.com domains
    if (AppConfig.supportedDomains.any((domain) => uri.contains(domain))) {
      final uriObj = Uri.parse(uri);
      final path = uriObj.path;
      
      // Handle /x/invite paths specifically
      if (path.startsWith('/x/invite') || path.startsWith('/lite/invite')) {
        LogUtil.d('Processing invite link: $uri');
        if (defaultHandler != null) {
          final handler = defaultHandler!;
          await handler(uri, 'invite_link', {});
        }
        return;
      }
    }

    // If we reach here, it's an unknown scheme or format
    LogUtil.d('Unknown scheme or format: $uri');
    defaultHandler?.call(uri, 'unknown', {});
  }
}

enum SchemeShareType {
  text,
  image,
  video,
  file,
}

extension SchemeShareTypeEx on SchemeShareType{

  String get typeText{
    switch(this){
      case SchemeShareType.text:
        return 'text';
      case SchemeShareType.image:
        return 'image';
      case SchemeShareType.video:
        return 'video';
      case SchemeShareType.file:
        return 'file';
    }
  }
}