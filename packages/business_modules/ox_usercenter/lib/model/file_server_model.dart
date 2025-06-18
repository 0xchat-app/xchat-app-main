import 'package:isar/isar.dart';

part 'file_server_model.g.dart';

/// Supported file-server types.
enum FileServerType { nip96, blossom, minio }

@collection
class FileServerModel {
  FileServerModel({
    this.id = Isar.autoIncrement,
    required this.type,
    required this.url,
    this.name = '',
    this.accessKey = '',
    this.secretKey = '',
    this.bucketName = '',
    this.pubkey = '',
  });

  Id id;

  @enumerated
  FileServerType type;

  /// display name / custom name
  String name;

  /// server url (ws / wss / https)
  String url;

  /// minio / blossom extra fields
  String accessKey;
  String secretKey;
  String bucketName;
  String pubkey; // blossom pubkey

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'url': url,
        'accessKey': accessKey,
        'secretKey': secretKey,
        'bucketName': bucketName,
        'pubkey': pubkey,
      };
} 