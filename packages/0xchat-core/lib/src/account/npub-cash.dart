import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nostr_core_dart/nostr.dart';
import 'package:chatcore/chat-core.dart';

class NpubCash {
  static String address(String pubkey) {
    return '${Nip19.encodePubkey(pubkey)}@npub.cash';
  }

  static Future<int?> balance() async {
    String url = 'https://npub.cash/api/v1/balance';
    String authToken = await Nip98.base64Event(
        url, Account.sharedInstance.currentPubkey, Account.sharedInstance.currentPrivkey);
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Nostr $authToken',
      },
    );

    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      if (body['error'] == false) {
        var data = body['data'];
        if (data != null) {
          if (data is String) {
            return int.tryParse(data) ?? 0;
          } else if (data is int) {
            return data;
          }
        }
      }
    } else {
      LogUtils.v(() => 'Request failed with status: ${response.statusCode}');
    }
    return null;
  }

  static Future<String?> claim() async {
    String url = 'https://npub.cash/api/v1/claim';
    String authToken = await Nip98.base64Event(
        url, Account.sharedInstance.currentPubkey, Account.sharedInstance.currentPrivkey);
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Nostr $authToken',
      },
    );

    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      if (body['error'] == false) {
        var data = body['data'];
        var token = data['token'];
        return token;
      }
    } else {
      LogUtils.v(() => 'Request failed with status: ${response.statusCode}');
    }
    return null;
  }
}
