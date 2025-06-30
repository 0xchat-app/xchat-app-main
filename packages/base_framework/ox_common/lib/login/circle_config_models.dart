import 'package:isar/isar.dart';
import 'dart:collection';

part 'circle_config_models.g.dart';

/// Circle level key-value storage
///
/// Stores various circle-level information in key–value format. The
/// combination of `circleId` and `key` is unique so every circle can have its
/// own independent set of configurations.
@collection
class CircleConfigISAR {
  int id = 0;

  /// Belongs to which circle – pubkey or uuid defined by business layer.
  late String circleId;

  /// Configuration key. Unique together with [circleId].
  @Index(unique: true)
  late String keyName;

  String? stringValue;
  int? intValue;
  double? doubleValue;
  bool? boolValue;

  late int updatedAt;

  CircleConfigISAR({
    required this.circleId,
    this.keyName = '',
    this.stringValue,
    this.intValue,
    this.doubleValue,
    this.boolValue,
    this.updatedAt = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'circleId': circleId,
      'key': keyName,
      'stringValue': stringValue,
      'intValue': intValue,
      'doubleValue': doubleValue,
      'boolValue': boolValue,
      'updatedAt': updatedAt,
    };
  }

  static CircleConfigISAR fromMap(Map<String, dynamic> map) {
    return CircleConfigISAR(
      circleId: map['circleId'] ?? '',
      keyName: map['key'] ?? '',
      stringValue: map['stringValue'],
      intValue: map['intValue'],
      doubleValue: map['doubleValue']?.toDouble(),
      boolValue: map['boolValue'],
      updatedAt: map['updatedAt'] ?? 0,
    );
  }

  // Helper constructors for different value types
  static CircleConfigISAR createString(
      String circleId, String key, String value) {
    return CircleConfigISAR(
      circleId: circleId,
      keyName: key,
      stringValue: value,
    );
  }

  static CircleConfigISAR createInt(String circleId, String key, int value) {
    return CircleConfigISAR(
      circleId: circleId,
      keyName: key,
      intValue: value,
    );
  }

  static CircleConfigISAR createDouble(
      String circleId, String key, double value) {
    return CircleConfigISAR(
      circleId: circleId,
      keyName: key,
      doubleValue: value,
    );
  }

  static CircleConfigISAR createBool(String circleId, String key, bool value) {
    return CircleConfigISAR(
      circleId: circleId,
      keyName: key,
      boolValue: value,
    );
  }

  // Common configuration keys (extend as needed)
  static const String keySelectedFileServerUrl = 'selected_file_server_url';
}

/// Circle configuration schemas utilities
class CircleConfigSchemas {
  CircleConfigSchemas._();

  static final List<IsarGeneratedSchema> _schemas = [
    CircleConfigISARSchema,
  ];

  static List<IsarGeneratedSchema> get schemas =>
      UnmodifiableListView(_schemas);
}

/// Strongly-typed configuration model for upper layer usage.
class CircleConfigModel {
  CircleConfigModel({
    this.selectedFileServerUrl = '',
  });

  /// Currently selected file-server url for this circle.
  String selectedFileServerUrl;

  CircleConfigModel copyWith({String? selectedFileServerUrl}) =>
      CircleConfigModel(
        selectedFileServerUrl:
            selectedFileServerUrl ?? this.selectedFileServerUrl,
      );

  Map<String, dynamic> toJson() => {
        'selectedFileServerUrl': selectedFileServerUrl,
      };

  @override
  String toString() =>
      'CircleConfigModel(selectedFileServerUrl: $selectedFileServerUrl)';
}

/// Helper for converting between [CircleConfigModel] and database entries.
class CircleConfigHelper {
  // Convert model to database entries
  static List<CircleConfigISAR> toConfigDataList(
      String circleId, CircleConfigModel config) {
    return [
      CircleConfigISAR.createString(circleId,
          CircleConfigISAR.keySelectedFileServerUrl, config.selectedFileServerUrl),
    ];
  }

  /// Load configuration from database for given circle
  static Future<CircleConfigModel> loadConfig(Isar circleDb, String circleId) async {
    final kvs = await circleDb.circleConfigISARs
        .where()
        .circleIdEqualTo(circleId)
        .findAll();

    if (kvs.isEmpty) {
      return CircleConfigModel();
    }

    // Map from key to record for fast lookup
    final map = {for (final kv in kvs) kv.keyName: kv};

    return CircleConfigModel(
      selectedFileServerUrl:
          map[CircleConfigISAR.keySelectedFileServerUrl]?.stringValue ?? '',
    );
  }

  /// Persist configuration into database (upsert)
  static Future<void> saveConfig(
      Isar circleDb, String circleId, CircleConfigModel config) async {
    final dataList = toConfigDataList(circleId, config);
    // Assign auto-increment IDs for new entries
    for (var data in dataList) {
      if (data.id == 0) {
        data.id = circleDb.circleConfigISARs.autoIncrement();
      }
    }
    await circleDb.writeAsync((circleDb) {
      circleDb.circleConfigISARs.putAll(dataList);
    });
  }
} 