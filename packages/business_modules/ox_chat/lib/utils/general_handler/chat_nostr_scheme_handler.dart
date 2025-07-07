import 'dart:convert';
import 'package:chatcore/chat-core.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_chat/model/option_model.dart';
import 'package:ox_common/business_interface/ox_discovery/interface.dart';
import 'package:ox_common/const/common_constant.dart';
import 'package:ox_common/utils/custom_uri_helper.dart';

class ChatNostrSchemeHandle {
  static String? getNostrScheme(String content) {
    final regexNostr =
        r'^(?:\s+)?(nostr:)?(npub|note|nprofile|nevent|nrelay|naddr)[0-9a-zA-Z]{8,}(?=\s*$)';
    final urlRegexp = RegExp(regexNostr);
    final match = urlRegexp.firstMatch(content);
    return match?.group(0);
  }

  static Future<String?> tryDecodeNostrScheme(String content) async {
    String? nostrScheme = getNostrScheme(content);
    if (nostrScheme == null)
      return null;
    else if (nostrScheme.startsWith('nostr:nprofile') ||
        nostrScheme.startsWith('nprofile') ||
        nostrScheme.startsWith('npub')) {
      final tempMap = Account.decodeProfile(nostrScheme);
      return await pubkeyToMessageContent(tempMap?['pubkey'], nostrScheme);
    }
    return null;
  }

  static Future<String?> pubkeyToMessageContent(
      String? pubkey, String nostrScheme) async {
    if (pubkey != null) {
      UserDBISAR? userDB = await Account.sharedInstance.getUserInfo(pubkey);
      if (userDB?.lastUpdatedTime == 0) {
        userDB = await Account.sharedInstance.reloadProfileFromRelay(pubkey);
      }
      return userToMessageContent(userDB, nostrScheme);
    }
    return null;
  }

  static String blankToMessageContent() {
    Map<String, dynamic> map = {};
    map['type'] = '3';
    map['content'] = {
      'title': 'Loading...',
      'content': 'Loading...',
      'icon': '',
      'link': ''
    };
    return jsonEncode(map);
  }

  static String? userToMessageContent(UserDBISAR? userDB, String nostrScheme) {
    String link = CustomURIHelper.createModuleActionURI(
        module: 'ox_chat',
        action: 'contactUserInfoPage',
        params: {'pubkey': userDB?.pubKey});
    Map<String, dynamic> map = {};
    map['type'] = '3';
    map['content'] = {
      'title': '${userDB?.name}',
      'content': '${userDB?.about}',
      'icon': '${userDB?.picture}',
      'link': link
    };
    return jsonEncode(map);
  }

  static String? groupDBToMessageContent(GroupDBISAR? groupDB) {
    String link = CustomURIHelper.createModuleActionURI(
        module: 'ox_chat',
        action: 'groupInfoPage',
        params: {'groupId': groupDB?.privateGroupId ?? ''});
    String? name = groupDB?.name.isEmpty == true ? groupDB?.shortGroupId : groupDB?.name;
    String? about = groupDB?.about?.isEmpty == true ? groupDB?.shortGroupId : groupDB?.about;
    Map<String, dynamic> map = {};
    map['type'] = '3';
    map['content'] = {
      'title': '${name ?? groupDB?.shortGroupId}',
      'content': '${about ?? groupDB?.shortGroupId}',
      'icon': '${groupDB?.picture}',
      'link': link
    };
    return jsonEncode(map);
  }

  static Future<String?> noteToMessageContent(NoteDBISAR? noteDB) async {
    if (noteDB == null) return null;
    UserDBISAR? userDB = await Account.sharedInstance.getUserInfo(noteDB.author);
    if (userDB?.lastUpdatedTime == 0) {
      userDB =
          await Account.sharedInstance.reloadProfileFromRelay(noteDB.author);
    }

    // String resultString = nostrScheme.replaceFirst('nostr:', "");
    // final url = '${CommonConstant.njumpURL}${resultString}';
    String link =
        await OXDiscoveryInterface.getJumpMomentPageUri(noteDB.noteId);
    Map<String, dynamic> map = {};
    map['type'] = '4';

    map['content'] = {
      'sourceScheme': noteDB.encodedNoteId,
      'authorIcon': '${userDB?.picture}',
      'authorName': '${userDB?.name}',
      'authorDNS': '${userDB?.dns}',
      'createTime': '${noteDB.createAt}',
      'note': '${noteDB.content}',
      'image': '${_extractFirstImageUrl(noteDB.content)}',
      'link': link,
    };
    return jsonEncode(map);
  }

  static String _extractFirstImageUrl(String text) {
    RegExp regExp = RegExp(r'(http[s]?:\/\/.*\.(?:png|jpg|gif|jpeg))');
    RegExpMatch? match = regExp.firstMatch(text);
    if (match != null) {
      return match.group(0) ?? '';
    }
    return '';
  }
}
