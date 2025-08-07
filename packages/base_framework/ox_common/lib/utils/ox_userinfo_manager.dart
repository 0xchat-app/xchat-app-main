import 'dart:convert';

import 'package:chatcore/chat-core.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/const/common_constant.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/ox_moment_manager.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/utils/user_config_tool.dart';

abstract mixin class OXUserInfoObserver {
  void didLoginSuccess(UserDBISAR? userInfo);

  void didSwitchUser(UserDBISAR? userInfo);

  void didLogout();

  void didUpdateUserInfo() {}
}

enum _ContactType {
  contacts,
  channels,
  // groups
  relayGroups,
}

class OXUserInfoManager {

  static final OXUserInfoManager sharedInstance = OXUserInfoManager._internal();

  OXUserInfoManager._internal() {
    addChatCallBack();
  }

  factory OXUserInfoManager() {
    return sharedInstance;
  }

  final List<OXUserInfoObserver> _observers = <OXUserInfoObserver>[];

  Map<String, dynamic> settingsMap = {};

  var _contactFinishFlags = {
    _ContactType.contacts: false,
    _ContactType.channels: false,
    _ContactType.relayGroups: false,
  };

  bool get isFetchContactFinish => _contactFinishFlags.values.every((v) => v);

  bool canVibrate = true;
  bool canSound = true;
  bool signatureVerifyFailed = false;
  //0: top; 1: tabbar; 2: delete.
  int momentPosition= 0;

  void addObserver(OXUserInfoObserver observer) => _observers.add(observer);

  bool removeObserver(OXUserInfoObserver observer) => _observers.remove(observer);

  void addChatCallBack() {
    Contacts.sharedInstance.secretChatRequestCallBack = (SecretSessionDBISAR ssDB) {};
    Contacts.sharedInstance.secretChatAcceptCallBack = (SecretSessionDBISAR ssDB) {
      OXChatBinding.sharedInstance.secretChatAcceptCallBack(ssDB);
    };
    Contacts.sharedInstance.secretChatRejectCallBack = (SecretSessionDBISAR ssDB) {
      OXChatBinding.sharedInstance.secretChatRejectCallBack(ssDB);
    };
    Contacts.sharedInstance.secretChatUpdateCallBack = (SecretSessionDBISAR ssDB) {
      OXChatBinding.sharedInstance.secretChatUpdateCallBack(ssDB);
    };
    Contacts.sharedInstance.secretChatCloseCallBack = (SecretSessionDBISAR ssDB) {
      OXChatBinding.sharedInstance.secretChatCloseCallBack(ssDB);
    };
    Contacts.sharedInstance.secretChatMessageCallBack = (MessageDBISAR message) {
      OXChatBinding.sharedInstance.didReceiveMessageHandler(message);
      OXChatBinding.sharedInstance.secretChatMessageCallBack(message);
    };
    Contacts.sharedInstance.privateChatMessageCallBack = (MessageDBISAR message) {
      OXChatBinding.sharedInstance.didReceiveMessageHandler(message);
      OXChatBinding.sharedInstance.privateChatMessageCallBack(message);
    };

    final messageUpdateCallBack = (MessageDBISAR message, String replacedMessageId) {
      OXChatBinding.sharedInstance.chatMessageUpdateCallBack(message, replacedMessageId);
    };
    Contacts.sharedInstance.privateChatMessageUpdateCallBack = messageUpdateCallBack;
    Contacts.sharedInstance.secretChatMessageUpdateCallBack = messageUpdateCallBack;
    Groups.sharedInstance.groupMessageUpdateCallBack = messageUpdateCallBack;
    Groups.sharedInstance.groupDeleteCallBack = (String groupId) async {
      OXChatBinding.sharedInstance.deleteSession([groupId]);
    };

    Groups.sharedInstance.groupMessageCallBack = (MessageDBISAR messageDB) async {
      OXChatBinding.sharedInstance.didReceiveMessageHandler(messageDB);
      OXChatBinding.sharedInstance.groupMessageCallBack(messageDB);
    };
    Messages.sharedInstance.deleteCallBack = (List<MessageDBISAR> delMessages) {
      OXChatBinding.sharedInstance.messageDeleteCallback(delMessages);
    };
    Contacts.sharedInstance.contactUpdatedCallBack = () {
      _fetchFinishHandler(_ContactType.contacts);
      OXChatBinding.sharedInstance.contactUpdatedCallBack();
    };
    Groups.sharedInstance.myGroupsUpdatedCallBack = () async {
      OXChatBinding.sharedInstance.groupsUpdatedCallBack();
    };
    Contacts.sharedInstance.offlinePrivateMessageFinishCallBack = () {
      OXChatBinding.sharedInstance.offlinePrivateMessageFinishCallBack();
    };
    Contacts.sharedInstance.offlineSecretMessageFinishCallBack = () {
      OXChatBinding.sharedInstance.offlineSecretMessageFinishCallBack();
    };

    Messages.sharedInstance.actionsCallBack = (MessageDBISAR message) {
      OXChatBinding.sharedInstance.messageActionsCallBack(message);
    };
  }

  void updateUserInfo(UserDBISAR? userDB) {
    assert(false, 'Deprecated method. Use LoginUserNotifier.instance');
  }

  void updateSuccess() {
    for (OXUserInfoObserver observer in _observers) {
      observer.didUpdateUserInfo();
    }
  }

  Future logout({bool needObserver = true}) async {
    assert(false, 'Use LoginManager');
  }

  Future<bool> setNotification() async {
    assert(false, 'Deprecated Class');

    bool updateNotificatin = false;
    String deviceId = await OXCacheManager.defaultOXCacheManager.getForeverData(StorageSettingKey.KEY_PUSH_TOKEN.name, defaultValue: '');
    String jsonString = UserConfigTool.getSetting(StorageSettingKey.KEY_NOTIFICATION_LIST.name, defaultValue: '{}');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    ///4、 44 private chat;  1059 secret chat & audio video call; 42  channel message; 9735 zap; 9、10 relay group; 1、6 reply&repost; 7 like
    List<int> kinds = [4, 44, 1059, 42, 9735, 9, 10, 1, 6, 7];
    for (var entry in jsonMap.entries) {
      var value = entry.value;
      if (value is Map<String, dynamic>) {
        if (value['id'] == CommonConstant.NOTIFICATION_PUSH_NOTIFICATIONS && !value['isSelected']){
          kinds = [];
          break;
        }
        if (value['id'] == CommonConstant.NOTIFICATION_PRIVATE_MESSAGES && !value['isSelected']) {
          kinds.remove(4);
          kinds.remove(44);
          kinds.remove(1059);
        }
        if (value['id'] == CommonConstant.NOTIFICATION_CHANNELS && !value['isSelected']) {
          kinds.remove(42);
        }
        if (value['id'] == CommonConstant.NOTIFICATION_ZAPS && !value['isSelected']) {
          kinds.remove(9735);
        }
        if (value['id'] == CommonConstant.NOTIFICATION_REACTIONS && !value['isSelected']) {
          kinds.remove(7);
        }
        if (value['id'] == CommonConstant.NOTIFICATION_REPLIES && !value['isSelected']) {
          kinds.remove(1);
          kinds.remove(6);
        }
        if (value['id'] == CommonConstant.NOTIFICATION_GROUPS && !value['isSelected']) {
          kinds.remove(9);
          kinds.remove(10);
        }
      }
    }
    List<String> relayAddressList = await Account.sharedInstance.getMyGeneralRelayList().map((e) => e.url).toList();
    OKEvent okEvent = await NotificationHelper.sharedInstance.setNotification(deviceId, kinds, relayAddressList);
    updateNotificatin = okEvent.status;

    return updateNotificatin;
  }

  Future<bool> checkDNS({required UserDBISAR userDB}) async {
    String pubKey = userDB.pubKey;
    String dnsStr = userDB.dns ?? '';
    if(dnsStr.isEmpty || dnsStr == 'null') {
      return false;
    }
    List<String> relayAddressList = await Account.sharedInstance.getUserGeneralRelayList(pubKey);
    List<String> temp = dnsStr.split('@');
    String name = temp[0];
    String domain = temp[1];
    DNS dns = DNS(name, domain, pubKey, relayAddressList);
    try {
      return await Account.checkDNS(dns);
    } catch (error, stack) {
      LogUtil.e("check dns error:$error\r\n$stack");
      return false;
    }
  }

  void _fetchFinishHandler(_ContactType type) {
    if (_contactFinishFlags[type] ?? false) return;
    _contactFinishFlags[type] = true;
    if (isFetchContactFinish) setNotification();
  }
}
