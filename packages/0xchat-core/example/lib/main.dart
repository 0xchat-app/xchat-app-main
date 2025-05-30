import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'main.reflectable.dart'; // Import generated code.
import 'package:nostr_core_dart/nostr.dart';
import 'package:chatcore/chat-core.dart';

initDB() async {
  DB.sharedInstance.schemes.add(UserDBIASR);
  DB.sharedInstance.deleteDBIfNeedMirgration = false;
  await DB.sharedInstance.open("chat1.db", version: 1);
}

Future<void> testAccount() async {
  UserDBIASR db = await Account.newAccount();
  print(db.toMap());
  // UserDB db2 = await Account.newAccountWithPassword("password");
  // print(db2.toMap());

  // UserDB? db3 = await Account.loginWithPubKeyAndPassword(
  //     "7bd7161b4ea87d34dbc9a7f36907c6ada238b29ea7fb469df431921604ee7dba",
  //     "password");
  // print(db3?.toMap());

  // int result = await Account.delete(db3!.privkey!);
  // print('result = $result');
  // await Account.updateProfile(db?.privkey!!, "nickname", "gender", "area", "bio");
  // print(db3?.toMap());
}

///
/// 335189cda14e1f819bc9d39673fed45b4f07ffc688ee12560ba85a1c3d878eef
/// Fw5_COv@,V(IKf+p
Future<void> testConnect() async {
  await Connect.sharedInstance.connectRelays(["ws://192.168.1.3:6969"]);
  Filter f = Filter(
    kinds: [0],
    authors: [
      "bb4beecb9cbd06786506204eff2841387c286a058019fc8de8042d2151bada3d"
    ],
  );
  Connect.sharedInstance.addSubscription([f], eventCallBack: (event, relay) {
    print(event.content);
  });
  // UserDB db = await Account.newAccount();
  // print(db.toMap());
  // Account.updateProfile(db.privkey!, 'name', 'gender', 'area', 'about', 'picture');
}

// user1 pub:   dc6ef75354eaa089089e4cd5246384c2a3ea554fa04bf2c26c8af798e96e6f3d
// user1 priv:  81cce0c8980eafd8eeab8b46c4a93aee0ef4c92c91f4b7b45a4db940304d7f51
// user2 pub:   3d4ce46b892035f0a89dd7df0d69e2c4d63377f139823c8d53a8ebc25b489168
// user2 priv:  a803fee503edde5f08d713a9b5365b7951aa65b986f3a4bcdbc89e6fb9f9847c
Future<void> testFriends() async {
  // pubkey = 353a138b1b398a3203a489d9a9a2023ac1b74ee5bdbe75400e2a7722a686723c
  // alias = acc19e82ec3a908a4fbfef93044baf86ee83b9c39f333600098c851350e33f00
  var user1 = Keychain(
      "81cce0c8980eafd8eeab8b46c4a93aee0ef4c92c91f4b7b45a4db940304d7f50");
  // pubkey = 9918de469f12a7d518b64e2e10249c5e5b2c1b6b2339ca2f0531661d2161b40b
  // alias = da2327a577642d181adb507ff9a15078eb6568fc68ccc56a1f3a00ff3480c8ba
  var user2 = Keychain(
      "fb505c65d4df950f5d28c9e4d285ee12ffaf315deef1fc24e3c7cd1e7e35f2b9");

  var user3 = Keychain(
      '5c4eb49a5098530fc81f89a8fa282f06f94ed3a088f750071b27c6b5f81e053c');

  await Connect.sharedInstance.connectRelays(["ws://192.168.1.7:6969"]);

  // await Account.updateProfile(user1.private, "hkling",
  //     gender: 'male',
  //     picture:
  //         'https://img1.baidu.com/it/u=898692534,2766260827&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
  //     about: 'hello, my name is hkling');
  //
  // await Account.updateProfile(user2.private, "BABY",
  //     gender: 'female',
  //     picture:
  //         'https://c-ssl.dtstatic.com/uploads/blog/202106/22/20210622154903_3c36a.thumb.1000_0.jpeg',
  //     about: 'my name is baby');

  Contacts.sharedInstance.initContacts((){});
  // Contacts.sharedInstance.secretChatMessageCallBack = (MessageDB message) {
  //   print(
  //       'friend message type: ${message.type}, content: ${message.decryptContent}');
  // };

  // await Future.delayed(const Duration(seconds: 3));
  // Map m = {'contentType': 'image', 'content':'https://www.baidu.com'};
  // Friends.sharedInstance.sendMessage(user2.public, '', jsonEncode(m));

  // await Future.delayed(const Duration(seconds: 3));
  // await Future.delayed(const Duration(seconds: 3));
  // Friends.sharedInstance.sendMessage(user1.public, '', 'sendMessage!');

  // await Future.delayed(const Duration(seconds: 1));

  // Friends.sharedInstance.requestFriend(user3.public, "hello, im hq");
  // Friends.sharedInstance.friendRequestCallBack = (Alias alias){
  //   print(
  //       '_handleFriendRequest ${alias.fromPubkey}, ${alias.fromAliasPubkey}, ${alias.toPubkey}, ${alias.toAliasPubkey}, ${alias.content}');
  //   Friends.sharedInstance.acceptFriend(alias.toPubkey, alias.toAliasPubkey);
  // };
  //
  // Friends.sharedInstance.friendAcceptCallBack = (Alias alias){
  //   print(
  //         '_handleFriendAccept ${alias.fromPubkey}, ${alias.fromAliasPubkey}, ${alias.toPubkey}, ${alias.toAliasPubkey}, ${alias.content}');
  //     Friends.sharedInstance.acceptFriend(alias.toPubkey, alias.toAliasPubkey);
  //     Friends.sharedInstance.sendMessage(user2.public, '', 'sendMessage!');
  // };
}

Future<void> testChannel() async {
  var user1 = Keychain(
      "81cce0c8980eafd8eeab8b46c4a93aee0ef4c92c91f4b7b45a4db940304d7f50");
  var user2 = Keychain(
      "fb505c65d4df950f5d28c9e4d285ee12ffaf315deef1fc24e3c7cd1e7e35f2b9");
  var user3 = Keychain(
      '5c4eb49a5098530fc81f89a8fa282f06f94ed3a088f750071b27c6b5f81e053c');

  await Connect.sharedInstance.connectRelays(["ws://192.168.1.7:6969"]);

  await Channels.sharedInstance.initWithPrivkey(user1.private);

  var channels = await Channels.sharedInstance.searchChannelsFromRelay();
  for (ChannelDBISAR channelDB in channels) {
    print(channelDB.name);
  }

  Channels.sharedInstance.channelMessageCallBack = (MessageDB messageDB) {
    print(messageDB.decryptContent);
  };

  // ChannelDB db = ChannelDB(channelId: '969bc1ec0f3ce8d47d573732f0dec4bf236d5c0fecb0a8cc2a5f7c3f10e5d23a',
  //   name: 'dicc',
  //   about: 'heppy dicc',
  //   picture: 'picture',
  //   relayURL: '',
  // );
  // Channels.sharedInstance.setChannel(db);

  // await Channels.sharedInstance.createChannel('name', 'about', 'picture', [], 'relay');

  // await Future.delayed(const Duration(seconds: 3));

  // for(ChannelDB channel in Channels.sharedInstance.myChannels.values){
  //   print(channel.name);
  //   Channels.sharedInstance.sendChannelMessage(channel.channelId!, MessageType.text, "hello, test channel", null, null);
  // }
}

Future<void> testZaps() async {
  String lnurl = await Zaps.getLnurlFromLnaddr('0xchat@getalby.com');
  print(lnurl);
  await Zaps.getInvoice(
      ['ws://192.168.1.7:6969'],
      100,
      lnurl,
      'dc6ef75354eaa089089e4cd5246384c2a3ea554fa04bf2c26c8af798e96e6f3d',
      '5c4eb49a5098530fc81f89a8fa282f06f94ed3a088f750071b27c6b5f81e053c');
}

Future<void> testBadges() async {
  await Connect.sharedInstance.connectRelays(["ws://192.168.1.16:6969"]);
  await Future.delayed(const Duration(seconds: 3));

  // await BadgesHelper.getBadgesInfoFromRelay(['8d2578b83bc18ce792df220652313d2fb4057415aea6cba74ce86f02905ff326'], (List<BadgeDB> badges) {
  //     for(BadgeDB badgeDB in badges){
  //       print(badgeDB.creator);
  //       print(badgeDB.name);
  //     }
  // });

  // await BadgesHelper.searchBadgeFromRelay(
  //     'a19d53de6fb2e04b16ad90a50b36fbccbea2d656fdf5c0629368d690e87bbeb8',
  //     'bravery1685432800690', (BadgeDB? badge) {
  //   print(badge!.creator);
  //   print(badge!.name);
  // });

  // List<BadgeDB?> badges = await BadgesHelper.getBadgeInfosFromDB(
  //     ['8d2578b83bc18ce792df220652313d2fb4057415aea6cba74ce86f02905ff326']);
  // for (BadgeDB? badgeDB in badges) {
  //   print(badgeDB!.creator);
  //   print(badgeDB!.name);
  // }

  var result = await BadgesHelper.getUserBadgeAwardsFromRelay(
      '792ed3a7a45d564f1ad9b21d2da26d0093ec3042475b01a84de206d53e4680b6');
  // for (BadgeDB? b in result!) {
  //   print(b!.d!);
  // }
  await BadgesHelper.setProfileBadges(
      ['3422277673444894c9a78d578641c27a966baa21f04b969ce2753452f5febe23'],
      '792ed3a7a45d564f1ad9b21d2da26d0093ec3042475b01a84de206d53e4680b6',
      '8b6846785424eab24a9a36957df1cb77d3348a4db91019274fb9a1bfa86f1daf');
  var result2 = await BadgesHelper.getProfileBadgesFromRelay(
      '792ed3a7a45d564f1ad9b21d2da26d0093ec3042475b01a84de206d53e4680b6');
  // for (BadgeDB? badgeDB in result2!) {
  //   print('getProfileBadgesFromRelay:${badgeDB!.d}');
  // }
}

Future<void> testNotification() async {
  await Connect.sharedInstance.connectRelays(["ws://192.168.1.16:6969"]);
  await Future.delayed(const Duration(seconds: 3));

  // NotificationHelper.setNotification(
  //     'a19d53de6fb2e04b16ad90a50b36fbccbea2d656fdf5c0629368d690e87bbeb8',
  //     'deviceId',
  //     [4, 42, 10100, 10101, 10102, 10103],
  //     ['wss://relay.0xchat.com'],
  //     ['78fca9b9c335fd51c8541076e6cf5dae4719a3dc6a419ab79c1d718b0dffa541'],
  //     ['969bc1ec0f3ce8d47d573732f0dec4bf236d5c0fecb0a8cc2a5f7c3f10e5d23a'],
  //     '81cce0c8980eafd8eeab8b46c4a93aee0ef4c92c91f4b7b45a4db940304d7f50');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeReflectable(); // Set up reflection support.
  await initDB();
  await testBadges();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
