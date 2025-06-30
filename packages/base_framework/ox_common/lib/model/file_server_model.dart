import 'package:isar/isar.dart';

part 'file_server_model.g.dart';

/// Supported file-server types.
/// This enum is used by the new upload pipeline and is independent of
/// the legacy `FileStorageServer` model used by OXServerManager.
enum FileServerType { nip96, blossom, minio }

@collection
class FileServerModel {
  FileServerModel({
    required this.id,
    required this.type,
    required this.url,
    this.name = '',
    this.accessKey = '',
    this.secretKey = '',
    this.bucketName = '',
  });

  int id = 0;

  @enumValue
  FileServerType type;

  /// Display name / custom name
  String name;

  /// Server URL (ws / wss / https)
  String url;

  /// Extra fields for MinIO
  String accessKey;
  String secretKey;
  String bucketName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'url': url,
        'accessKey': accessKey,
        'secretKey': secretKey,
        'bucketName': bucketName,
      };
} 