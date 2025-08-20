import 'dart:async';

import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/const/common_constant.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/custom_uri_helper.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/utils//string_utils.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/compression_utils.dart';

class ScanUtils {
  static Future<void> analysis(BuildContext context, String url) async {
    // Remove xchat:// prefix if present
    if (url.startsWith('xchat://')) {
      url = url.replaceFirst('xchat://', 'https://0xchat.com/x/');
    }

    try {
      final uri = Uri.parse(url);
      
      // Check if it's an invite link first
        if (url.contains('0xchat.com/x/invite') || url.contains('www.0xchat.com/x/invite') || url.contains('0xchat.com/lite/invite') || url.contains('www.0xchat.com/lite/invite')) {
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
      return str.contains('0xchat.com/x/invite') || 
             str.contains('www.0xchat.com/x/invite') ||
             str.contains('0xchat.com/lite/invite') ||
             str.contains('www.0xchat.com/lite/invite');
    },
    action: (String str, BuildContext context) async {
      try {
        final uri = Uri.parse(str);
        
        // Handle invite links
        if (uri.path == '/x/invite' || uri.path == '/lite/invite') {
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
    context = OXNavigator.rootContext;
    
    // Show loading at the beginning
    OXLoading.show();
    
    try {
      final keypackage = uri.queryParameters['keypackage'];
      final pubkey = uri.queryParameters['pubkey'];
      final eventid = uri.queryParameters['eventid'];
      final relay = uri.queryParameters['relay'];

      // Check if relay is provided
      if (relay == null || relay.isEmpty) {
        OXLoading.dismiss();
        CommonToast.instance.show(context, 'Invalid invite link: missing relay');
        return;
      }

      // Check circle handling based on relay
      final relayUrl = relay;
      final currentCircle = LoginManager.instance.currentCircle;
      final account = LoginManager.instance.currentState.account;
      
      if (account == null) {
        OXLoading.dismiss();
        CommonToast.instance.show(context, 'No account logged in');
        return;
      }

      // Normalize relay URLs for comparison (remove trailing slashes)
      final normalizedRelayUrl = relayUrl.replaceFirst(RegExp(r'/+$'), '');
      final normalizedCurrentRelayUrl = currentCircle?.relayUrl.replaceFirst(RegExp(r'/+$'), '') ?? '';

      // Case 1: If it's the current circle, proceed directly
      if (currentCircle != null && normalizedCurrentRelayUrl == normalizedRelayUrl) {
        // Current circle matches, proceed with invite processing
        await _processInviteLink(context, keypackage, pubkey, eventid, relayUrl);
        return;
      }

      // Case 2: Check if target circle exists in account's circle list
      Circle? targetCircle;
      for (final circle in account.circles) {
        final normalizedCircleRelayUrl = circle.relayUrl.replaceFirst(RegExp(r'/+$'), '');
        if (normalizedCircleRelayUrl == normalizedRelayUrl) {
          targetCircle = circle;
          break;
        }
      }

      if (targetCircle != null) {
        // Hide loading for dialog
        OXLoading.dismiss();
        
        // Circle exists in account, show switch confirmation dialog
        final agreeSwitch = await _showSwitchCircleDialogFromScan(context, targetCircle, pubkey ?? '');
        if (agreeSwitch != true) {
          return;
        }
        
        // Switch to the target circle
        final switchResult = await _switchToCircleFromScan(context, targetCircle);
        if (!switchResult) {
          return;
        }
        
        // Show loading again for processing
        OXLoading.show();
        
        // Process the invite link after switching
        await _processInviteLink(context, keypackage, pubkey, eventid, relayUrl);
        return;
      }

      // Hide loading for dialog
      OXLoading.dismiss();
      
      // Case 3: Circle doesn't exist in account, proceed with join circle logic
      final agreeJoin = await _showJoinCircleDialogFromScan(context, [relayUrl], pubkey ?? '');
      if (agreeJoin != true) {
        return;
      }

      // Show loading again for processing
      OXLoading.show();
      
      // Join the circle and process invite
      await _processInviteLink(context, keypackage, pubkey, eventid, relayUrl);
    } catch (e) {
      OXLoading.dismiss();
      CommonToast.instance.show(context, 'Failed to process invite link 111');
    }
  }

  static Future<void> _processInviteLink(BuildContext context, String? keypackage, String? pubkey, String? eventid, String relayUrl) async {
    try {
      // Process the invite link
      bool success = false;
      String? senderPubkey = pubkey; // For one-time invites
      String? keyPackageId;
      
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
        keyPackageId = await KeyPackageManager.handleOneTimeInviteLink(
          encodedKeyPackage: decompressedKeyPackage,
          senderPubkey: pubkey,
          relays: [relayUrl],
        );
        success = keyPackageId.isNotEmpty;
      } else if (eventid != null) {
        // Handle permanent invite link
        final result = await KeyPackageManager.handlePermanentInviteLink(
          eventId: eventid,
          relays: [relayUrl],
        );
        keyPackageId = result['keyPackageId'] as String?;
        success = result['success'] as bool;
        senderPubkey = result['pubkey'] as String?;
      }

      // Hide loading before navigation or showing result
      OXLoading.dismiss();

      if (success) {        
        // Navigate to sender's profile page
        if (senderPubkey != null) {
          // Navigate to user detail page
          await Future.delayed(Duration(milliseconds: 300));
          OXNavigator.popToRoot(context);
          await Future.delayed(Duration(milliseconds: 300));
          await _navigateToUserDetailFromScan(context, senderPubkey);
          await KeyPackageManager.recordScannedKeyPackageId(senderPubkey, keyPackageId);
        } else {
          CommonToast.instance.show(context, 'Successfully processed invite link');
        }
      } else {
        CommonToast.instance.show(context, 'Failed to process invite link 333');
      }
    } catch (e) {
      // Hide loading on error
      OXLoading.dismiss();
      CommonToast.instance.show(context, 'Failed to process invite link 222');
    }
  }

  static Future<bool> _showSwitchCircleDialogFromScan(BuildContext context, Circle targetCircle, String pubkey) async {
    final result = await CLAlertDialog.show<bool>(
      context: context,
      title: 'Switch Circle',
      content: 'This user is from circle "${targetCircle.name}" (${targetCircle.relayUrl}). Would you like to switch to this circle to chat with them?',
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: 'Switch Circle',
          value: true,
          isDefaultAction: true,
        ),
      ],
    );

    return result == true;
  }

  static Future<bool> _switchToCircleFromScan(BuildContext context, Circle targetCircle) async {
    // Show loading
    OXLoading.show();

    // Switch to the target circle
    final failure = await LoginManager.instance.switchToCircle(targetCircle);

    OXLoading.dismiss();

    if (failure != null) {
      _showErrorDialogFromScan(context, 'Failed to switch circle: ${failure.message}');
      return false;
    }

    return true;
  }

  static Future<bool> _showJoinCircleDialogFromScan(BuildContext context, List<String> relays, String pubkey) async {
    final primaryRelay = relays.isNotEmpty ? relays.first : '';

    final result = await CLAlertDialog.show<bool>(
      context: context,
      title: 'Join Circle',
      content: 'This user is from circle "$primaryRelay". Would you like to join this circle to chat with them?',
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
      return await _joinCircleAndNavigateFromScan(context, primaryRelay, pubkey);
    }

    return false;
  }

  static Future<bool> _joinCircleAndNavigateFromScan(BuildContext context, String relayUrl, String pubkey) async {
    // Show loading
    OXLoading.show();

    // Join the circle
    final failure = await LoginManager.instance.joinCircle(relayUrl);

    OXLoading.dismiss();

    if (failure != null) {
      _showErrorDialogFromScan(context, 'Failed to join circle: ${failure.message}');
      return false;
    }

    return true;
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

  static Future<bool> _tryHandleRelaysFromMap(Map<String, dynamic> map, BuildContext context) async {
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

    final result = await CLAlertDialog.show<bool>(
      context: context,
      title: '',
      content: 'scan_find_not_same_hint'
          .commonLocalized()
          .replaceAll(r'${relay}', newRelay),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_common.confirm'),
          value: true,
          isDefaultAction: true,
        ),
      ],
    );
    
    if (result == true) {
      await Connect.sharedInstance.connectRelays([newRelay], relayKind: RelayKind.temp);
      return true;
    } else {
      return false;
    }
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
      bool isLogin = LoginManager.instance.isLoginCircle;
      if (!isLogin) {
        CommonToast.instance.show(context, 'please_sign_in'.commonLocalized());
        return false;
      }

      // Show loading
      OXLoading.show();

      try {
        final failedHandle = () {
          OXLoading.dismiss();
          CommonToast.instance.show(context, 'User not found');
        };

        final data = Account.decodeProfile(str);
        
        if (data == null || data.isEmpty) {
          return failedHandle();
        }

        if (!await _tryHandleRelaysFromMap(data, context)) {
          OXLoading.dismiss();
          return true;
        }

        final pubkey = data['pubkey'] as String? ?? '';
        
        UserDBISAR? user = await Account.sharedInstance.getUserInfo(pubkey);
        
        // Hide loading
        OXLoading.dismiss();
        
        if (user == null) {
          return failedHandle();
        }

        OXModuleService.pushPage(context, 'ox_chat', 'ContactUserInfoPage', {
          'pubkey': user.pubKey,
        });
      } catch (e) {
        OXLoading.dismiss();
        LogUtil.e('Error handling user scan: $e');
        CommonToast.instance.show(context, 'Failed to process user scan');
      }
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
      bool isLogin = LoginManager.instance.isLoginCircle;
      if (!isLogin) {
        CommonToast.instance.show(context, 'please_sign_in'.commonLocalized());
        return false;
      }

      // Show loading
      OXLoading.show();

      try {
        final data = Channels.decodeChannel(str);
        final groupId = data?['channelId'];
        final relays = data?['relays'];
        final kind = data?['kind'];
        
        // Hide loading
        OXLoading.dismiss();
        
        if (data == null || groupId == null || groupId is! String || groupId.isEmpty) return true;
        if (kind == 40 || kind == 41) {
          // Handle group/channel logic here
        }
      } catch (e) {
        OXLoading.dismiss();
        LogUtil.e('Error handling group scan: $e');
        CommonToast.instance.show(context, 'Failed to process group scan');
      }
    },
  );

  static ScanAnalysisHandler scanNWCHandler = ScanAnalysisHandler(
    matcher: (String str) {
      return str.startsWith('nostr+walletconnect:');
    },
    action: (String nwcURI, BuildContext context) async {
      bool isLogin = LoginManager.instance.isLoginCircle;
      if (!isLogin) {
        CommonToast.instance.show(context, 'please_sign_in'.commonLocalized());
        return false;
      }

      // Show loading
      OXLoading.show();

      try {
        NostrWalletConnection? nwc = NostrWalletConnection.fromURI(nwcURI);
        
        // Hide loading for dialog
        OXLoading.dismiss();
        
        final result = await CLAlertDialog.show<bool>(
          context: context,
          title: 'scan_find_nwc_hint'.commonLocalized(),
          content: '${nwc?.relays[0]}\n${nwc?.lud16}',
          actions: [
            CLAlertAction.cancel(),
            CLAlertAction<bool>(
              label: Localized.text('ox_common.confirm'),
              value: true,
              isDefaultAction: true,
            ),
          ],
        );
        
        if (result == true) {
          // Show loading for processing
          OXLoading.show();
          
          try {
            Zaps.sharedInstance.updateNWC(nwcURI);
            await OXCacheManager.defaultOXCacheManager
                .saveForeverData('${LoginManager.instance.currentPubkey}.isShowWalletSelector', false);
            await OXCacheManager.defaultOXCacheManager
                .saveForeverData('${LoginManager.instance.currentPubkey}.defaultWallet', 'NWC');
            
            // Hide loading
            OXLoading.dismiss();
            
            CommonToast.instance.show(context, 'Success');
          } catch (e) {
            OXLoading.dismiss();
            LogUtil.e('Error processing NWC: $e');
            CommonToast.instance.show(context, 'Failed to process NWC');
          }
        }
      } catch (e) {
        OXLoading.dismiss();
        LogUtil.e('Error handling NWC scan: $e');
        CommonToast.instance.show(context, 'Failed to process NWC scan');
      }
    },
  );
}