import 'package:chatcore/chat-core.dart';
import 'package:isar/isar.dart';

part 'groupDB_isar.g.dart';

extension GroupDBISARExtensions on GroupDBISAR {
  GroupDBISAR withGrowableLevels() => this
    ..members = members?.toList()
    ..pinned = pinned?.toList();
}

@collection
class GroupDBISAR {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String groupId; //group pubkey

  String owner; // pubkey
  int updateTime;
  bool mute;
  String name;
  List<String>? members;
  List<String>? pinned;
  String? about;
  String? picture;
  String? relay;

  /// MLS GROUP
  List<int>? mlsGroupId;
  int epoch;
  List<String>? adminPubkeys;
  List<int>? serializedWelcomeMessage;

  GroupDBISAR(
      {this.groupId = '',
      this.owner = '',
      this.updateTime = 0,
      this.mute = false,
      this.name = '',
      this.members,
      this.pinned,
      this.about,
      this.picture,
      this.relay,
      this.mlsGroupId,
      this.epoch = 0,
      this.adminPubkeys,
      this.serializedWelcomeMessage});

  static GroupDBISAR fromMap(Map<String, Object?> map) {
    return _groupInfoFromMap(map);
  }

  @ignore
  String get shortGroupId {
    String k = groupId;
    if (k.length < 12) return k;
    final String start = k.substring(0, 6);
    final String end = k.substring(k.length - 6);

    return '$start:$end';
  }
}

GroupDBISAR _groupInfoFromMap(Map<String, dynamic> map) {
  return GroupDBISAR(
    groupId: map['groupId'].toString(),
    owner: map['owner'],
    updateTime: map['updateTime'],
    mute: map['mute'],
    name: map['name'].toString(),
    members: UserDBISAR.decodeStringList(map['members'].toString()),
    pinned: UserDBISAR.decodeStringList(map['pinned'].toString()),
    about: map['about'].toString(),
    picture: map['picture'].toString(),
    relay: map['relay'].toString(),
  );
}
