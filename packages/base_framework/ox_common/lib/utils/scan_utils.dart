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
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_common/utils/compression_utils.dart';

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
      
      // Check if it's an invite link first
      if (url.contains('0xchat.com/lite/invite') || url.contains('www.0xchat.com/lite/invite')) {
        // Keep the full URL for invite links
        // Don't modify the URL
      } else if (uri.pathSegments.isNotEmpty && uri.pathSegments.last == CustomURIHelper.nostrAction) {
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
      ScanAnalysisHandlerEx.scanInviteLinkHandler,
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

  static ScanAnalysisHandler scanInviteLinkHandler = ScanAnalysisHandler(
    matcher: (String str) {
      // Check if it's an invite link
      return str.contains('0xchat.com/lite/invite') || 
             str.contains('www.0xchat.com/lite/invite');
    },
    action: (String str, BuildContext context) async {
      try {
        final uri = Uri.parse(str);
        
        // Handle invite links
        if (uri.path == '/lite/invite') {
          await _handleInviteLinkFromScan(uri, context);
          return;
        }
      } catch (e) {
        LogUtil.e('Error handling invite link from scan: $e');
        CommonToast.instance.show(context, 'Invalid invite link');
      }
    },
  );

  static Future<void> _handleInviteLinkFromScan(Uri uri, BuildContext context) async {
    try {
      final keypackage = uri.queryParameters['keypackage'];
      final pubkey = uri.queryParameters['pubkey'];
      final eventid = uri.queryParameters['eventid'];
      final relay = uri.queryParameters['relay'];

      // Check if relay is provided
      if (relay == null || relay.isEmpty) {
        CommonToast.instance.show(context, 'Invalid invite link: missing relay');
        return;
      }

      // Check if we need to join a circle based on relay
      final relayUrl = relay;
      final currentCircle = LoginManager.instance.currentCircle;
      bool needToJoinCircle = false;

      if (currentCircle != null) {
        if (currentCircle.relayUrl != relayUrl &&
            currentCircle.relayUrl.replaceFirst(RegExp(r'/+$'), '') !=
                relayUrl.replaceFirst(RegExp(r'/+$'), '')) {
          needToJoinCircle = true;
        }
      } else {
        needToJoinCircle = true;
      }

      // If we need to join a circle, show dialog first
      if (needToJoinCircle) {
        await _showJoinCircleDialogFromScan(context, [relayUrl], pubkey ?? '');
      }

      // Process the invite link
      bool success = false;
      String? senderPubkey = pubkey; // For one-time invites
      
      if (keypackage != null && pubkey != null) {
        // Decompress keypackage data if it's compressed
        String decompressedKeyPackage = keypackage;
        if (keypackage.startsWith('CMP:')) {
          try {
            final decompressed = await CompressionUtils.decompressWithPrefix(keypackage);
            if (decompressed != null) {
              decompressedKeyPackage = decompressed!;
              print('Successfully decompressed keypackage data');
            } else {
              print('Failed to decompress keypackage data, using original');
            }
          } catch (e) {
            print('Error decompressing keypackage: $e');
          }
        }
        
        // Handle one-time invite link
        success = await KeyPackageManager.handleOneTimeInviteLink(
          encodedKeyPackage: decompressedKeyPackage,
          senderPubkey: pubkey,
          relays: [relayUrl],
        );
      } else if (eventid != null) {
        // Handle permanent invite link
        final result = await KeyPackageManager.handlePermanentInviteLink(
          eventId: eventid,
          relays: [relayUrl],
        );
        
        success = result['success'] as bool;
        senderPubkey = result['pubkey'] as String?;
      }

      if (success) {
        // Navigate to sender's profile page
        if (senderPubkey != null) {
          await _navigateToUserDetailFromScan(context, senderPubkey);
        } else {
          CommonToast.instance.show(context, 'Successfully processed invite link');
        }
      } else {
        CommonToast.instance.show(context, 'Failed to process invite link');
      }
    } catch (e) {
      LogUtil.e('Error handling invite link from scan: $e');
      CommonToast.instance.show(context, 'Failed to process invite link');
    }
  }

  static Future<void> _showJoinCircleDialogFromScan(BuildContext context, List<String> relays, String pubkey) async {
    final primaryRelay = relays.isNotEmpty ? relays.first : '';
    final relayName = _extractRelayNameFromScan(primaryRelay);
    
    final result = await CLAlertDialog.show<bool>(
      context: context,
      title: 'Join Circle',
      content: 'This user is from circle "$relayName". Would you like to join this circle to chat with them?',
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: 'Join Circle',
          value: true,
          isDefaultAction: true,
        ),
      ],
    );

    if (result == true) {
      // Join the circle
      await _joinCircleAndNavigateFromScan(context, primaryRelay, pubkey);
    }
  }

  static Future<void> _joinCircleAndNavigateFromScan(BuildContext context, String relayUrl, String pubkey) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Create circle and join
      final circle = Circle(
        id: _generateCircleIdFromScan(relayUrl),
        name: _extractRelayNameFromScan(relayUrl),
        type: CircleType.relay,
        relayUrl: relayUrl,
      );

      // Join the circle
      final failure = await LoginManager.instance.joinCircle(relayUrl);
      
      // Hide loading
      Navigator.of(context).pop();

      if (failure == null) {
        // Navigate to user detail page
        await _navigateToUserDetailFromScan(context, pubkey);
      } else {
        _showErrorDialogFromScan(context, 'Failed to join circle: ${failure.message}');
      }
    } catch (e) {
      // Hide loading
      Navigator.of(context).pop();
      _showErrorDialogFromScan(context, 'Error joining circle: $e');
    }
  }

  static Future<void> _navigateToUserDetailFromScan(BuildContext context, String pubkey) async {
    // Get user info
    UserDBISAR? user = await Account.sharedInstance.getUserInfo(pubkey);
    if (user == null) {
      _showErrorDialogFromScan(context, 'User not found');
      return;
    }

    // Navigate to user detail page
    OXModuleService.pushPage(context, 'ox_chat', 'ContactUserInfoPage', {
      'pubkey': user.pubKey,
    });
  }

  static void _showErrorDialogFromScan(BuildContext context, String message) {
    CLAlertDialog.show(
      context: context,
      title: 'Error',
      content: message,
      actions: [
        CLAlertAction(
          label: 'OK',
          isDefaultAction: true,
        ),
      ],
    );
  }

  static String _extractRelayNameFromScan(String relayUrl) {
    try {
      final uri = Uri.parse(relayUrl);
      final host = uri.host;
      return host.replaceAll('relay.', '').replaceAll('www.', '').split('.').first;
    } catch (e) {
      return relayUrl.replaceAll('wss://', '').replaceAll('ws://', '').split('/').first;
    }
  }

  static String _generateCircleIdFromScan(String relayUrl) {
    // Simple hash of the relay URL to create a unique ID
    return relayUrl.hashCode.toString();
  }

  /// Get pubkey from event ID by fetching the event from relay
  static Future<String?> _getPubkeyFromEventId(String eventId, String relayUrl) async {
    try {
      // Create a temporary connection to fetch the event
      final completer = Completer<String?>();
      
      Connect.sharedInstance.connect(relayUrl, relayKind: RelayKind.general);
      
      // Wait for connection
      await Future.delayed(Duration(seconds: 2));
      
      // Subscribe to the specific event
      final filter = Filter(ids: [eventId], kinds: [443]);
      final subscriptionId = Connect.sharedInstance.addSubscription(
        [filter],
        eventCallBack: (event, relay) {
          if (event.kind == 443) {
            completer.complete(event.pubkey);
          }
        },
        eoseCallBack: (requestId, ok, relay, unCompletedRelays) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      );

      // Wait for response with timeout
      final result = await completer.future.timeout(Duration(seconds: 10));
      
      // Clean up subscription
      Connect.sharedInstance.closeRequests(subscriptionId);
      
      return result;
    } catch (e) {
      LogUtil.e('Error getting pubkey from event ID: $e');
      return null;
    }
  }

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