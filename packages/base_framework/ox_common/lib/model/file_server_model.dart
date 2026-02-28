import 'package:isar/isar.dart';

part 'file_server_model.g.dart';

/// Supported file-server types.
/// This enum is used by the new upload pipeline and is independent of
/// the legacy `FileStorageServer` model used by OXServerManager.
enum FileServerType { nip96, blossom, minio, filedrop }

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
    this.pathPrefix,
    this.region = '',
    this.sessionToken,
    this.expiration,
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
  
  /// Path prefix for S3 (e.g., "tenant-rb8QlKix/")
  /// Required for multi-tenant S3 buckets to ensure IAM policy compliance
  String? pathPrefix;

  /// AWS region (e.g., "ap-southeast-1")
  /// Used when talking to AWS S3 global endpoint (s3.amazonaws.com)
  String region;

  /// AWS Session Token (for temporary credentials from STS)
  /// If null, credentials are permanent
  String? sessionToken;

  /// Credential expiration timestamp (Unix seconds)
  /// If null, credentials don't expire (permanent)
  int? expiration;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'url': url,
        'accessKey': accessKey,
        'secretKey': secretKey,
        'bucketName': bucketName,
        if (pathPrefix != null) 'pathPrefix': pathPrefix,
        'region': region,
        if (sessionToken != null) 'sessionToken': sessionToken,
        if (expiration != null) 'expiration': expiration,
      };
} 