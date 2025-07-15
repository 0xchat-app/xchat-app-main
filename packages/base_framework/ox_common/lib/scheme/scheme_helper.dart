import '../const/common_constant.dart';
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

    handleAppURI(url);
  }

  static handleAppURI(String uri) async {
    if (uri.isEmpty) return ;

    String action = '';
    Map<String, String> query = <String, String>{};

    // Handle custom scheme formats first (oxchatlite:nprofile, nostr:nprofile)
    if (uri.startsWith('oxchatlite:')) {
      final nprofile = uri.replaceFirst('oxchatlite:', '');
      if (nprofile.isNotEmpty) {
        // Handle nprofile directly (main app scheme)
        defaultHandler?.call(uri, 'nprofile', {'value': nprofile});
        return;
      }
    } else if (uri.startsWith('nostr:')) {
      final nostrContent = uri.replaceFirst('nostr:', '');
      if (nostrContent.isNotEmpty) {
        // Handle nostr content directly
        defaultHandler?.call(uri, 'nostr', {'value': nostrContent});
        return;
      }
    }

    try {
      final uriObj = Uri.parse(uri);
      // Handle standard URI schemes (oxchatlite://, nostr://)
      if (uriObj.scheme != 'oxchatlite' && uriObj.scheme != 'nostr') return ;

      // For oxchatlite scheme (main app scheme), extract the nprofile part
      if (uriObj.scheme == 'oxchatlite') {
        final nprofile = uriObj.path.isNotEmpty ? uriObj.path.substring(1) : ''; // Remove leading slash
        if (nprofile.isNotEmpty) {
          // Handle nprofile directly
          defaultHandler?.call(uri, 'nprofile', {'value': nprofile});
          return;
        }
      }

      // For nostr scheme, extract the content part
      if (uriObj.scheme == 'nostr') {
        final nostrContent = uriObj.path.isNotEmpty ? uriObj.path.substring(1) : ''; // Remove leading slash
        if (nostrContent.isNotEmpty) {
          // Handle nostr content directly
          defaultHandler?.call(uri, 'nostr', {'value': nostrContent});
          return;
        }
      }

      action = uriObj.host.toLowerCase();
      query = uriObj.queryParameters;
    } catch (_) {
      // Handle other URI formats if needed
      final liteScheme = 'oxchatlite://';
      final nostrScheme = 'nostr://';
      
      if (uri.startsWith(liteScheme)) {
        final nprofile = uri.replaceFirst(liteScheme, '');
        if (nprofile.isNotEmpty) {
          // Handle nprofile directly (main app scheme)
          defaultHandler?.call(uri, 'nprofile', {'value': nprofile});
          return;
        }
      } else if (uri.startsWith(nostrScheme)) {
        final nostrContent = uri.replaceFirst(nostrScheme, '');
        if (nostrContent.isNotEmpty) {
          // Handle nostr content directly
          defaultHandler?.call(uri, 'nostr', {'value': nostrContent});
          return;
        }
      }
    }

    final handler = schemeAction[action];
    if (handler != null) {
      handler(uri, action, query);
      return;
    }

    defaultHandler?.call(uri, action, query);
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