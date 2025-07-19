import 'dart:async';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:minio/minio.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/model/file_server_model.dart';
import 'package:ox_common/upload/file_type.dart';
import 'package:ox_common/upload/minio_uploader.dart';
import 'package:ox_common/upload/upload_exception.dart';
import 'package:ox_common/upload/uploader.dart';
import 'package:ox_common/utils/aes_encrypt_utils.dart';
import 'package:ox_common/utils/file_utils.dart';
import 'package:ox_common/utils/file_server_helper.dart';
import 'package:ox_common/utils/string_utils.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class UploadUtils {
  static Future<UploadResult> uploadFile({
    BuildContext? context,
    params,
    String? encryptedKey,
    String? encryptedNonce,
    required File file,
    required String filename,
    required FileType fileType,
    bool showLoading = false,
    bool autoStoreImage = true,
    Function(double progress)? onProgress,
  }) async {
    File uploadFile = file;
    File? encryptedFile;
    if (encryptedKey != null && encryptedKey.isNotEmpty) {
      String directoryPath = '';
      if (Platform.isAndroid) {
        Directory? externalStorageDirectory = await getExternalStorageDirectory();
        if (externalStorageDirectory == null) {
          return UploadResult.error('Storage function abnormal');
        }
        directoryPath = externalStorageDirectory.path;
      } else if (Platform.isIOS || Platform.isMacOS) {
        Directory temporaryDirectory = await getTemporaryDirectory();
        directoryPath = temporaryDirectory.path;
      }
      encryptedFile = FileUtils.createFolderAndFile(directoryPath + "/encrytedfile", filename);
      await AesEncryptUtils.encryptFileInIsolate(file, encryptedFile, encryptedKey,
          nonce: encryptedNonce, mode: AESMode.gcm);
      uploadFile = encryptedFile;
    }
    final fileServer = await FileServerHelper.currentFileServer();
    if (fileServer == null) {
      return UploadResult.error('No file server configured.');
    }

    String url = '';
    if (showLoading) OXLoading.show();
    try {
      final type = fileServer.type;
      switch (type) {
        case FileServerType.nip96:
        case FileServerType.blossom:
          var imageServices = fileServer.name;
          if (FileServerType.blossom == type) imageServices = ImageServices.BLOSSOM;
          url = await Uploader.upload(
                uploadFile.path,
                imageServices,
                fileName: filename,
                imageServiceAddr: fileServer.url,
                onProgress: onProgress,
              ) ??
              '';
          break;
        case FileServerType.minio:
          MinioUploader.init(
            url: fileServer.url,
            accessKey: fileServer.accessKey,
            secretKey: fileServer.secretKey,
            bucketName: fileServer.bucketName,
          );
          url = await MinioUploader.instance.uploadFile(
            file: uploadFile,
            filename: filename,
            fileType: fileType,
            onProgress: onProgress,
          );
          break;
      }
      if (showLoading) OXLoading.dismiss();
    } catch (e, s) {
      if (showLoading) OXLoading.dismiss();
      return UploadExceptionHandler.handleException(e, s);
    }

    if (fileType == FileType.image && autoStoreImage) {
      final cacheManager = await CLCacheManager.getCircleCacheManager(CacheFileType.image);
      await cacheManager.putFile(
        url,
        file.readAsBytesSync(),
        fileExtension: file.path.getFileExtension(),
      );
    }
    if (encryptedFile != null && encryptedFile.existsSync()) {
      encryptedFile.delete();
    }

    return UploadResult.success(url, encryptedKey, encryptedNonce);
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
    if (e is ClientException) {
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
  UploadManager._internal() {}

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

  Future<void> uploadFile({
    required FileType fileType,
    required String filePath,
    required uploadId,
    required String? receivePubkey,
    String? encryptedKey,
    String? encryptedNonce,
    bool autoStoreImage = true,
    Function(UploadResult, bool isFromCache)? completeCallback,
  }) async {
    final cacheKey = _cacheKey(uploadId, receivePubkey);
    final result = uploadResultMap[cacheKey];
    if (result != null && result.isSuccess) {
      completeCallback?.call(result, true);
      return;
    }

    final streamController = prepareUploadStream(uploadId, receivePubkey);
    streamController.add(0.0);
    uploadResultMap.remove(cacheKey);

    final file = File(filePath);
    UploadUtils.uploadFile(
      file: file,
      filename: '${Uuid().v1()}.${filePath.getFileExtension()}',
      fileType: fileType,
      encryptedKey: encryptedKey,
      encryptedNonce: encryptedNonce,
      autoStoreImage: autoStoreImage,
      onProgress: (progress) {
        streamController.add(progress);
      },
    ).then((result) {
      uploadResultMap[cacheKey] = result;
      completeCallback?.call(result, false);
    });
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
