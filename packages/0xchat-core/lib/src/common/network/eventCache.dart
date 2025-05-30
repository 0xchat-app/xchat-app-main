import 'package:isar/isar.dart';
import 'package:chatcore/chat-core.dart';
import 'package:nostr_core_dart/nostr.dart';

class EventCache {
  /// singleton
  EventCache._internal();
  factory EventCache() => sharedInstance;
  static final EventCache sharedInstance = EventCache._internal();

  Set<String> cacheIds = {};
  //cache kinds
  List<int> kinds = [4, 1059, 42, 1, 6, 7, 9, 10, 11, 12, 9735];

  final cacheTimeStamp = 24 * 60 * 60 * 7;

  Future<void> loadAllEventsFromDB() async {
    List<EventDBISAR> eventDBs = await DBISAR.sharedInstance.isar.eventDBISARs.where().findAll();
    List<int> expiredEvents = [];
    for (var eventDB in eventDBs) {
      if (eventDB.expiration != null &&
          eventDB.expiration! > 0 &&
          eventDB.expiration! < currentUnixTimestampSeconds()) {
        expiredEvents.add(eventDB.id);
        continue;
      }
      cacheIds.add(eventDB.eventId);
    }

    if (expiredEvents.isEmpty) return;
    DBISAR.sharedInstance.isar.writeTxn(() async {
      int result = await DBISAR.sharedInstance.isar.eventDBISARs.deleteAll(expiredEvents);
      LogUtils.v(() => 'Deleted event caches: $result');
    });
  }

  Future<EventDBISAR?> loadEventFromDB(String eventId) async {
    return await DBISAR.sharedInstance.isar.eventDBISARs
        .where()
        .eventIdEqualTo(eventId)
        .findFirst();
  }

  Future<void> saveEventToDB(EventDBISAR eventDB) async {
    await DBISAR.sharedInstance.saveToDB(eventDB);
  }

  Future<bool> eventExit(Event event) async {
    EventDBISAR? eventDB = await loadEventFromDB(event.id);
    return eventDB != null;
  }

  Future<void> receiveEvent(Event event, String relay) async {
    if (cacheIds.contains(event.id)) return;
    cacheIds.add(event.id);
    if (!kinds.contains(event.kind)) return;
    EventDBISAR? eventDB =
        EventDBISAR(eventId: event.id, expiration: currentUnixTimestampSeconds() + cacheTimeStamp);
    eventDB.eventReceiveStatus.add(EventStatusISAR(relay: relay, status: true, message: ''));
    await saveEventToDB(eventDB);
  }

  Future<void> sendEvent(Event event, String relay, bool status, String message) async {
    cacheIds.add(event.id);
    EventDBISAR? eventDB = await loadEventFromDB(event.id);
    eventDB ??=
        EventDBISAR(eventId: event.id, expiration: currentUnixTimestampSeconds() + cacheTimeStamp);
    eventDB.eventSendStatus.add(EventStatusISAR(relay: relay, status: status, message: message));
    await saveEventToDB(eventDB);
  }
}
