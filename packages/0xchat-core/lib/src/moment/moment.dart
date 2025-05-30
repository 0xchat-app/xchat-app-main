import 'package:chatcore/chat-core.dart';
import 'package:nostr_core_dart/nostr.dart';

typedef NewNotesCallBack = void Function(List<NoteDBISAR>);
typedef NewNotificationCallBack = void Function(List<NotificationDBISAR>);
typedef OfflineMomentFinishCallBack = void Function();

class Moment {
  /// singleton
  Moment._internal();
  factory Moment() => sharedInstance;
  static final Moment sharedInstance = Moment._internal();

  /// memory storage
  String pubkey = '';
  String privkey = '';
  Map<String, NoteDBISAR> notesCache = {};
  List<NoteDBISAR> newNotes = [];
  List<NotificationDBISAR> newNotifications = [];
  NewNotesCallBack? newNotesCallBack;
  NewNotificationCallBack? newNotificationCallBack;
  NewNotificationCallBack? myZapNotificationCallBack;
  OfflineMomentFinishCallBack? offlineMomentFinishCallBack;

  String notesSubscription = '';
  Map<String, bool> offlineMomentFinish = {};

  int latestNoteTime = 0;
  int latestNotificationTime = 0;
  int limit = 50;

  Future<void> init() async {
    privkey = Account.sharedInstance.currentPrivkey;
    pubkey = Account.sharedInstance.currentPubkey;
  }

  void closeSubscriptions({String? relay}) {
    if (notesSubscription.isNotEmpty) {
      Connect.sharedInstance.closeRequests(notesSubscription, relay: relay);
    }
  }

  Future<void> updateSubscriptions({String? relay}) async {
    closeSubscriptions(relay: relay);

    List<String> authors = Contacts.sharedInstance.allContacts.keys.toList();
    authors.add(pubkey); // add self
    if (authors.isNotEmpty) {
      Map<String, List<Filter>> subscriptions = {};
      if (relay == null) {
        for (String relayURL in Connect.sharedInstance.relays()) {
          int momentUntil = Relays.sharedInstance.getMomentUntil(relayURL);
          Filter f1 = Filter(
              authors: authors,
              kinds: [1, 6],
              since: momentUntil,
              limit: limit);
          Filter f2 = Filter(
              authors: [pubkey], kinds: [7], since: momentUntil, limit: limit);
          subscriptions[relayURL] = [f1, f2];
        }
      } else {
        int momentUntil = Relays.sharedInstance.getMomentUntil(relay);
        Filter f1 = Filter(
            authors: authors, kinds: [1, 6], since: momentUntil, limit: limit);
        Filter f2 = Filter(
            authors: [pubkey], kinds: [7], since: momentUntil, limit: limit);
        subscriptions[relay] = [f1, f2];
      }

      notesSubscription = Connect.sharedInstance.addSubscriptions(subscriptions,
          eventCallBack: (event, relay) async {
        updateMomentTime(event.createdAt, relay);
        if (Contacts.sharedInstance.inBlockList(event.pubkey)) return;
        switch (event.kind) {
          case 1:
            handleNoteEvent(event, relay, false);
            break;
          case 6:
            handleRepostsEvent(event, relay, false);
            break;
          case 7:
            handleReactionEvent(event, relay, false);
            break;
          default:
            LogUtils.v(() => 'moment unhandled message ${event.toJson()}');
            break;
        }
      }, eoseCallBack: (requestId, ok, relay, unCompletedRelays) {
        offlineMomentFinish[relay] = true;
        if (ok.status) {
          updateMomentTime(currentUnixTimestampSeconds() - 1, relay);
        }
        if (unCompletedRelays.isEmpty) {
          offlineMomentFinishCallBack?.call();
        }
      });
    }
  }

  void updateMomentTime(int eventTime, String relay) {
    /// set setMomentSince setMomentUntil
    if (Relays.sharedInstance.relays.containsKey(relay)) {
      Relays.sharedInstance.setMomentSince(eventTime, relay);
      Relays.sharedInstance.setMomentUntil(eventTime, relay);
    } else {
      Relays.sharedInstance.relays[relay] = RelayDBISAR(
          url: relay, momentSince: eventTime, momentUntil: eventTime);
    }
    if (offlineMomentFinish[relay] == true) {
      Relays.sharedInstance.syncRelaysToDB(r: relay);
    }
  }

  void clearNewNotes() {
    newNotes.clear();
  }

  void clearNewNotifications() {
    newNotifications.clear();
  }
}
