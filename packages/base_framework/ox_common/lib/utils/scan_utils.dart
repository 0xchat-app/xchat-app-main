import 'dart:async';

import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/const/common_constant.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/custom_uri_helper.dart';
import 'package:ox_common/widgets/common_hint_dialog.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/utils//string_utils.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:ox_common/log_util.dart';

class ScanUtils {
  static Future<void> analysis(BuildContext context, String url) async {
    bool isLogin = LoginManager.instance.isLoginCircle;
    if (!isLogin) {
      CommonToast.instance.show(context, 'please_sign_in'.commonLocalized());
      return;
    }

    // Remove oxchatlite:// prefix if present
    if (url.startsWith('oxchatlite://')) {
      url = url.substring('oxchatlite://'.length);
    }

    try {
      final uri = Uri.parse(url);
      
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.last == CustomURIHelper.nostrAction) {
        url = uri.queryParameters['value'] ?? '';
      } else if (uri.pathSegments.isNotEmpty) {
        url = uri.pathSegments.last;
      }
    } catch (e) {
      String shareAppLinkDomain = CommonConstant.SHARE_APP_LINK_DOMAIN + '/';
      if (url.startsWith(shareAppLinkDomain)) {
        url = url.substring(shareAppLinkDomain.length);
      }
    }

    final handlers = [
      ScanAnalysisHandlerEx.scanUserHandler,
      ScanAnalysisHandlerEx.scanGroupHandler,
      ScanAnalysisHandlerEx.scanNWCHandler,
    ];
    
    for (var handler in handlers) {
      if (await handler.matcher(url)) {
        handler.action(url, context);
        return;
      }
    }
  }
}

class ScanAnalysisHandler {
  ScanAnalysisHandler({required this.matcher, required this.action});
  FutureOr<bool> Function(String str) matcher;
  Function(String str, BuildContext context) action;
}

extension ScanAnalysisHandlerEx on ScanUtils {

  static FutureOr<bool> _tryHandleRelaysFromMap(Map<String, dynamic> map, BuildContext context) {
    List<String> relaysList = (map['relays'] ?? []).cast<String>();
    if (relaysList.isEmpty) return true;
    final newRelay = relaysList.first.replaceFirst(RegExp(r'/+$'), '');
    
    // Get current circle relay
    final circleRelays = Account.sharedInstance.getCurrentCircleRelay();
    
    // Also check currently connected relays as fallback
    final connectedRelays = Connect.sharedInstance.relays();
    
    // Check if relay is already available in circle or connected relays
    bool relayExists = circleRelays.contains(newRelay) ||
                      connectedRelays.contains(newRelay);
    
    if (relayExists) return true;

    final completer = Completer<bool>();
    OXCommonHintDialog.show(context,
        content: 'scan_find_not_same_hint'
            .commonLocalized()
            .replaceAll(r'${relay}', newRelay),
        isRowAction: true,
        actionList: [
          OXCommonHintAction.cancel(onTap: () {
            OXNavigator.pop(context);
            completer.complete(false);
          }),
          OXCommonHintAction.sure(
              text: Localized.text('ox_common.confirm'),
              onTap: () async {
                OXNavigator.pop(context);
                await Connect.sharedInstance.connectRelays([newRelay], relayKind: RelayKind.temp);
                completer.complete(true);
              }),
        ]);
    return completer.future;
  }

  static ScanAnalysisHandler scanUserHandler = ScanAnalysisHandler(
    matcher: (String str) {
      bool matches = str.startsWith('nprofile') ||
          str.startsWith('nostr:nprofile') ||
          str.startsWith('nostr:npub') ||
          str.startsWith('npub');
      return matches;
    },
    action: (String str, BuildContext context) async {
      final failedHandle = () {
        CommonToast.instance.show(context, 'User not found');
      };

      final data = Account.decodeProfile(str);
      
      if (data == null || data.isEmpty) {
        return failedHandle();
      }

      if (!await _tryHandleRelaysFromMap(data, context)) {
        return true;
      }

      final pubkey = data['pubkey'] as String? ?? '';
      
      UserDBISAR? user = await Account.sharedInstance.getUserInfo(pubkey);
      
      if (user == null) {
        return failedHandle();
      }

      OXModuleService.pushPage(context, 'ox_chat', 'ContactUserInfoPage', {
        'pubkey': user.pubKey,
      });
    },
  );

  static ScanAnalysisHandler scanGroupHandler = ScanAnalysisHandler(
    matcher: (String str) {
      return str.startsWith('nevent') ||
          str.startsWith('nostr:nevent') ||
          str.startsWith('naddr') ||
          str.startsWith('nostr:naddr') ||
          str.startsWith('nostr:note') ||
          str.startsWith('note');
    },
    action: (String str, BuildContext context) async {
      final data = Channels.decodeChannel(str);
      final groupId = data?['channelId'];
      final relays = data?['relays'];
      final kind = data?['kind'];
      if (data == null || groupId == null || groupId is! String || groupId.isEmpty) return true;
      if (kind == 40 || kind == 41) {
        
      }
    },
  );

  static ScanAnalysisHandler scanNWCHandler = ScanAnalysisHandler(
    matcher: (String str) {
      return str.startsWith('nostr+walletconnect:');
    },
    action: (String nwcURI, _) async {
      NostrWalletConnection? nwc = NostrWalletConnection.fromURI(nwcURI);
      BuildContext context = OXNavigator.navigatorKey.currentContext!;
      OXCommonHintDialog.show(context,
        title: 'scan_find_nwc_hint'.commonLocalized(),
        content: '${nwc?.relays[0]}\n${nwc?.lud16}',
        isRowAction: true,
        actionList: [
          OXCommonHintAction.cancel(onTap: () {
            OXNavigator.pop(context);
          }),
          OXCommonHintAction.sure(
            text: Localized.text('ox_common.confirm'),
            onTap: () async {
              Zaps.sharedInstance.updateNWC(nwcURI);
              await OXCacheManager.defaultOXCacheManager
                  .saveForeverData('${LoginManager.instance.currentPubkey}.isShowWalletSelector', false);
              await OXCacheManager.defaultOXCacheManager
                  .saveForeverData('${LoginManager.instance.currentPubkey}.defaultWallet', 'NWC');
              OXNavigator.pop(context);
              CommonToast.instance.show(context, 'Success');
            },
          ),
        ],
      );
    },
  );
}