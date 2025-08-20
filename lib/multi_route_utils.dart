import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/ox_common.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_home/page/launch_page_view.dart';

import 'app_initializer.dart';

///Title: multi_route_utils
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2021
///@author George
///CreateTime: 6/11/21 3:11 PM
class MultiRouteUtils {
  static Widget widgetForRoute(String route, BuildContext context) {
    if (route != '/') {
      String pageName = _getPageName(route);
      String moduleName = _getModuleName(pageName);
      Map<String, dynamic> pageParams = _parseNativeParams(route);
      LogUtil.e("pageName: ${pageName.toString()} pageParams:" + pageParams.toString());
      Widget pathWidget = Scaffold(
        backgroundColor: ThemeColor.dark02,
        body: Container(),
      );
      switch (moduleName) {
        case 'default':
          break;
      }
      return pathWidget;
    } else {
      // Check if app initialization was successful
      if (!AppInitializer.shared.isInitialized) {
        // Return white screen if initialization failed
        return CLScaffold(
          body: Container(),
        );
      }
      return LaunchPageView();
    }
  }

  static String _getPageName(String route) {
    String pageName = route;
    if (route.indexOf("?") != -1) pageName = route.substring(0, route.indexOf("?"));
    return pageName;
  }

  static String _getModuleName(String pageName) {
    String moduleName = pageName;
    if (pageName.indexOf("/") != -1) moduleName = pageName.substring(0, pageName.indexOf("/"));
    return moduleName;
  }

  static String _getPagePath(String pageName) {
    String path = '';
    if (pageName.indexOf("/") != -1) {
      path = pageName.substring(pageName.indexOf("/") + 1);
    }
    return path;
  }

  /// Parse native parameters and perform initialization operations
  static Map<String, dynamic> _parseNativeParams(String route) {
    Map<String, dynamic> nativeParams = {};
    
    // Check if route contains query parameters
    if (route.indexOf("?") != -1) {
      try {
        // Check if this is a URL scheme (not a regular route)
        if (route.startsWith('xchat://') || route.startsWith('xchat:') || 
            route.startsWith('nostr://') || route.startsWith('nostr:')) {
          // This is a URL scheme, not a route with JSON params
          LogUtil.d('Route is a URL scheme, skipping JSON parsing: $route');
          return {};
        }
        
        // Extract query string and try to parse as JSON
        String queryString = route.substring(route.indexOf("?") + 1);
        
        // Check if query string looks like JSON
        if (queryString.startsWith('{') && queryString.endsWith('}')) {
          nativeParams = json.decode(queryString);
        } else {
          // Not JSON format, treat as regular query parameters
          LogUtil.d('Query string is not JSON format: $queryString');
          return {};
        }
      } catch (e) {
        // JSON parsing failed, log error and return empty params
        LogUtil.e('Failed to parse route parameters as JSON: $route, error: $e');
        return {};
      }
    }
    
    return nativeParams['pageParams'] ?? {};
  }

  static void newFlutterActivity(String route, String params) {
    OXCommon.channelPreferences.invokeMethod('showFlutterActivity', {
      'route': route,
      'params': params,
    });
  }
}
