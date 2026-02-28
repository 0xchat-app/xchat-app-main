import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:minio/minio.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/model/file_server_model.dart';
import 'package:ox_common/upload/minio_uploader.dart';
import 'package:ox_common/upload/upload_exception.dart';
import 'package:ox_common/upload/uploader.dart';
import 'package:ox_common/utils/file_server_helper.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'blossom_uploader.dart';
import 'file_type.dart';
import 'filedrop_uploader.dart';
import 'nip96_uploader.dart';
import 'pomf2_lain_la.dart';
export 'file_type.dart';

class UploadUtils {
  static Future<UploadResult> uploadFile({
    BuildContext? context,
    String? encryptedKey,
    String? encryptedNonce,
    required File file,
    required String filename,
    required FileType fileType,
    FileServerModel? fileServer,
    bool showLoading = false,
    bool autoStoreImage = true,
    Function(double progress)? onProgress,
    bool isChatFile = false,
  }) async {
    final uploadFile = file;
    final candidates = fileServer != null
        ? <FileServerModel>[fileServer]
        : await FileServerHelper.currentUploadCandidates();

    if (candidates.isEmpty) {
      return UploadResult.error('No file server configured.');
    }

    if (showLoading) OXLoading.show();

    UploadResult? lastError;
    for (final server in candidates) {
      try {
        String url = '';
        switch (server.type) {
          case FileServerType.nip96:
            final uri = Uri.tryParse(server.url);
            if (uri?.host.contains(ImageServices.POMF2_LAIN_LA) ?? false) {
              url = await Pomf2LainLa.upload(
                uploadFile.path,
                fileName: filename,
                onProgress: onProgress,
              ) ?? '';
            } else {
              url = await NIP96Uploader.upload(
                server.url,
                uploadFile.path,
                fileName: filename, onProgress: onProgress,
              ) ?? '';
            }
            break;
          case FileServerType.blossom:
            url = await BolssomUploader.upload(
              server.url,
              uploadFile.path,
              fileName: filename,
              onProgress: onProgress,
            ) ?? '';
            break;
          case FileServerType.minio:
            MinioUploader.init(
              url: server.url,
              accessKey: server.accessKey,
              secretKey: server.secretKey,
              bucketName: server.bucketName,
              pathPrefix: server.pathPrefix,
              region: server.region.isNotEmpty ? server.region : null,
              sessionToken: server.sessionToken,
              expiration: server.expiration,
            );
            // Set tags based on isChatFile for S3 lifecycle management
            // FileType=chat for 30-day expiration, FileType=avatar for permanent
            Map<String, String>? tags;
            if (isChatFile) {
              tags = {'FileType': 'chat'};
            }
            url = await MinioUploader.instance.uploadFile(
              file: uploadFile,
              filename: filename,
              fileType: fileType,
              onProgress: onProgress,
              tags: tags,
            );
            break;
          case FileServerType.filedrop:
            url = await FileDropUploader.upload(
              server.url,
              uploadFile.path,
              fileName: filename,
              onProgress: onProgress,
            ) ?? '';
            break;
        }

        if (url.isEmpty) {
          // Treat empty url as failure and try next candidate.
          lastError = UploadResult.error(UploadExceptionHandler.errorMessage);

          LogUtil.i('[Upload File] server(${server.url}) upload failed');
          continue;
        }

        if (fileType == FileType.image && autoStoreImage) {
          final cacheManager =
          await CLCacheManager.getCircleCacheManager(CacheFileType.image);
          await cacheManager.putFile(
            url,
            file.readAsBytesSync(),
            fileExtension: file.path.getFileExtension(),
          );
        }

        if (showLoading) OXLoading.dismiss();

        LogUtil.i('[Upload File] result: success, server: ${server.url}, imageUrl: $url');

        return UploadResult.success(url, encryptedKey, encryptedNonce);
      } catch (e, s) {
        // Try next server when current one fails.
        LogUtil.i('[Upload File] server(${server.url}) upload failed: $e');
        lastError = UploadExceptionHandler.handleException(e, s);
      }
    }

    if (showLoading) OXLoading.dismiss();

    return lastError ?? UploadResult.error(UploadExceptionHandler.errorMessage);
  }
}

class UploadResult {
  final bool isSuccess;
  final String url;
  final String? errorMsg;
  final String? encryptedKey;
  final String? encryptedNonce;

  UploadResult({required this.isSuccess, required this.url, this.errorMsg, this.encryptedKey, this.encryptedNonce});

  factory UploadResult.success(String url, String? encryptedKey, String? encryptedNonce) {
    return UploadResult(isSuccess: true, url: url, encryptedKey: encryptedKey, encryptedNonce: encryptedNonce);
  }

  factory UploadResult.error(String errorMsg) {
    return UploadResult(isSuccess: false, url: '', errorMsg: errorMsg);
  }

  @override
  String toString() {
    return '${super.toString()}, url: $url, isSuccess: $isSuccess, errorMsg: $errorMsg';
  }
}

class UploadExceptionHandler {
  static const errorMessage = 'Unable to connect to the file storage server.';

  static UploadResult handleException(dynamic e, [dynamic s]) {
    LogUtil.e('Upload File Exception Handler: $e\r\n$s');
    if (e is http.ClientException) {
      return UploadResult.error(e.message);
    } else if (e is MinioError) {
      return UploadResult.error(e.message ?? errorMessage);
    } else if (e is DioException) {
      if (e.type == DioExceptionType.badResponse) {
        String errorMsg = '';
        dynamic data = e.response?.data;
        if (data != null) {
          if (data is Map) {
            errorMsg = data['message'];
          }
          if (data is String) {
            errorMsg = data;
          }
        }
        return UploadResult.error(errorMsg);
      }
      return UploadResult.error(parseError(e));
    } else if (e is UploadException) {
      return UploadResult.error(e.message);
    } else {
      return UploadResult.error(errorMessage);
    }
  }

  static String parseError(dynamic e) {
    String errorMsg = e.message ?? errorMessage;
    if (e.error is SocketException) {
      SocketException socketException = e.error as SocketException;
      errorMsg = socketException.message;
    }
    if (e.error is HttpException) {
      HttpException httpException = e.error as HttpException;
      errorMsg = httpException.message;
    }
    return errorMsg;
  }
}

class UploadManager {
  static final UploadManager shared = UploadManager._internal();
  UploadManager._internal();

  // Key: _cacheKey(uploadId, pubkey)
  Map<String, StreamController<double>> uploadStreamMap = {};

  // Key: _cacheKey(uploadId, pubkey)
  Map<String, UploadResult> uploadResultMap = {};

  StreamController prepareUploadStream(String uploadId, String? pubkey) {
    return uploadStreamMap.putIfAbsent(
      _cacheKey(uploadId, pubkey),
          () => StreamController<double>.broadcast(),
    );
  }

  Future<(UploadResult, bool isFromCache)> uploadFile({
    required FileType fileType,
    required String filePath,
    required uploadId,
    required String? receivePubkey,
    String? encryptedKey,
    String? encryptedNonce,
    bool autoStoreImage = true,
    bool isChatFile = true, // Default to true since UploadManager is primarily used for chat file uploads
  }) async {
    final cacheKey = _cacheKey(uploadId, receivePubkey);
    final cacheResult = uploadResultMap[cacheKey];
    if (cacheResult != null && cacheResult.isSuccess) {
      return (cacheResult, true);
    }

    final streamController = prepareUploadStream(uploadId, receivePubkey);
    streamController.add(0.0);
    uploadResultMap.remove(cacheKey);

    final file = File(filePath);
    // UploadManager is primarily used for chat file uploads
    // Pass isChatFile parameter to UploadUtils for lifecycle management
    final result = await UploadUtils.uploadFile(
      file: file,
      filename: file.path.getFileName() ?? '${Uuid().v1()}.${filePath.getFileExtension()}',
      fileType: fileType,
      encryptedKey: encryptedKey,
      encryptedNonce: encryptedNonce,
      autoStoreImage: autoStoreImage,
      isChatFile: isChatFile,
      onProgress: (progress) {
        streamController.add(progress);
      },
    );

    uploadResultMap[cacheKey] = result;
    return (result, false);
  }

  Stream<double>? getUploadProgress(String uploadId, String? pubkey) {
    final controller = uploadStreamMap[_cacheKey(uploadId, pubkey)];
    if (controller == null) {
      return null;
    }
    return controller.stream;
  }

  UploadResult? getUploadResult(String uploadId, String? receivePubkey) =>
      uploadResultMap[_cacheKey(uploadId, receivePubkey)];

  String _cacheKey(String uploadId, String? pubkey) => '$uploadId-CacheKey-${pubkey ?? ''}';
}