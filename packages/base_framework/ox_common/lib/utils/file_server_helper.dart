import 'package:flutter/widgets.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/model/file_server_model.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/repository/file_server_repository.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/utils/account_credentials_utils.dart';

class FileServerHelper {
  FileServerHelper._();

  static List<FileServerModel> get defaultFileServerGroup =>
      [
        // FileServerModel(
        //   id: 0,
        //   type: FileServerType.nip96,
        //   name: 'pomf2.lain.la',
        //   url: 'https://pomf2.lain.la',
        // ),
        // FileServerModel(
        //   id: 0,
        //   type: FileServerType.blossom,
        //   name: 'blossom.lostr.space',
        //   url: 'https://blossom.lostr.space',
        // ),
        FileServerModel(
          id: 0,
          type: FileServerType.filedrop,
          name: 'filedrop.besoeasy.com',
          url: 'https://filedrop.besoeasy.com',
        ),
      ];

  static bool isDefaultFileServerGroupSelected(String? selectedUrl) =>
      selectedUrl == null || selectedUrl.isEmpty;


  /// Get current upload candidates according to current circle selection.
  ///
  /// - When selected url is empty -> returns [defaultFileServerGroup] with S3 server prepended if available.
  /// - When selected url matches a custom server -> returns a single-item list.
  /// - When selected url is not found (e.g. deleted) -> fallback to default
  ///   group and persist selection to empty string.
  static Future<List<FileServerModel>> currentUploadCandidates() async {
    final circle = LoginManager.instance.currentCircle;
    final url = circle?.selectedFileServerUrl;
    
    // Get S3 config from current circle if available
    FileServerModel? s3FileServer;
    if (circle != null) {
      try {
        final circleDB = await Account.sharedInstance.getCircleById(circle.id);
        S3Config? s3Config;
        
        // Try to load from local database first
        if (circleDB != null && circleDB.s3ConfigJson != null && circleDB.s3ConfigJson!.isNotEmpty) {
          s3Config = await S3ConfigUtils.loadS3ConfigFromCircleDB(circle.id);
        }
        
        // Check if S3 config is expired or near expiration
        bool needsRefresh = false;
        if (s3Config != null) {
          needsRefresh = _isS3ConfigExpired(s3Config);
        }
        
        // If no S3 config found or expired, and this is a paid relay, try to fetch from API
        if ((s3Config == null || needsRefresh) && CircleApi.isPaidRelay(circle.relayUrl)) {
          try {
            final tenantId = circleDB?.tenantId;
            if (tenantId != null && tenantId.isNotEmpty) {
              final credentials = await AccountCredentialsUtils.getCredentials();
              if (credentials != null) {
                s3Config = await CircleApi.getS3Credentials(
                  pubkey: credentials['pubkey'] as String,
                  privkey: credentials['privkey'] as String,
                  tenantId: tenantId,
                );
                
                // Save to database
                await S3ConfigUtils.saveS3ConfigToCircleDB(
                  circleId: circle.id,
                  s3Config: s3Config,
                );
              }
            }
          } catch (e) {
            LogUtil.w(() => 'Failed to fetch S3 config from API: $e');
          }
        }
        
        // Create FileServerModel if we have S3 config
        if (s3Config != null) {
          final url = S3ConfigUtils.getS3FileServerUrl(s3Config);
          s3FileServer = FileServerModel(
            id: 0, // Will be used as default server
            type: FileServerType.minio,
            name: circleDB?.tenantName ?? circle.name,
            url: url,
            accessKey: s3Config.accessKeyId,
            secretKey: s3Config.secretAccessKey,
            bucketName: s3Config.bucket,
            pathPrefix: s3Config.pathPrefix,
            region: s3Config.region,
            sessionToken: s3Config.sessionToken,
            expiration: s3Config.expiration,
          );
        }
      } catch (e) {
        LogUtil.w(() => 'Failed to load S3 config for current circle: $e');
      }
    }
    
    if (isDefaultFileServerGroupSelected(url)) {
      // Return default group with S3 server prepended if available
      final candidates = <FileServerModel>[];
      if (s3FileServer != null) {
        candidates.add(s3FileServer);
      }
      candidates.addAll(defaultFileServerGroup);
      return candidates;
    }

    final repo = FileServerRepository(DBISAR.sharedInstance.isar);
    final list = await repo.watchAll().first;
    FileServerModel? matched;
    try {
      matched = list.firstWhere((e) => e.url == url);
    } catch (_) {
      matched = null;
    }

    if (matched == null) {
      // Fallback: revert to default group selection.
      if (circle != null) {
        await circle.updateSelectedFileServerUrl('');
      }
      // Return default group with S3 server prepended if available
      final candidates = <FileServerModel>[];
      if (s3FileServer != null) {
        candidates.add(s3FileServer);
      }
      candidates.addAll(defaultFileServerGroup);
      return candidates;
    }
    return [matched];
  }

  static Future<bool> ensureFileServerConfigured(
      BuildContext context, {
        VoidCallback? onGoToSettings,
      }) async {
    return (await currentUploadCandidates()).isNotEmpty;
  }

  /// Returns the current circle's file server (S3) for display when the circle is a paid relay.
  /// Used on the read-only file server info page for paid circles.
  static Future<FileServerModel?> getCircleFileServerForDisplay() async {
    final circle = LoginManager.instance.currentCircle;
    if (circle == null || !CircleApi.isPaidRelay(circle.relayUrl)) return null;
    final candidates = await currentUploadCandidates();
    try {
      return candidates.firstWhere((e) => e.type == FileServerType.minio);
    } catch (_) {
      return null;
    }
  }

  /// Check if S3 config is expired or near expiration
  /// 
  /// [s3Config] S3 configuration to check
  /// [bufferSeconds] Buffer time in seconds before expiration (default: 300 seconds = 5 minutes)
  /// Returns true if credentials are expired or near expiration
  static bool _isS3ConfigExpired(S3Config s3Config, {int bufferSeconds = 300}) {
    // If no expiration, credentials are permanent
    if (s3Config.expiration == null) {
      return false;
    }
    
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final timeUntilExpiration = s3Config.expiration! - now;
    
    // Consider expired if within buffer time or already expired
    return timeUntilExpiration <= bufferSeconds;
  }
}