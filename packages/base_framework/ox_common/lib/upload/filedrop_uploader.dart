import 'package:dio/dio.dart';
import 'package:http_parser/src/media_type.dart';

import 'base64.dart';
import 'uploader.dart';

/// Upload to FileDrop / Originless-style servers (e.g. https://filedrop.besoeasy.com).
/// POST multipart to [serverUrl]upload with field name "file".
class FileDropUploader {
  static final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Upload file to FileDrop server.
  /// [serverUrl] The base URL (e.g. https://filedrop.besoeasy.com/)
  /// [filePath] Local file path to upload
  /// [fileName] Optional file name
  /// [onProgress] Optional progress callback
  static Future<String?> upload(
    String serverUrl,
    String filePath, {
    String? fileName,
    Function(double progress)? onProgress,
  }) async {
    if (!serverUrl.endsWith('/')) {
      serverUrl = '$serverUrl/';
    }

    final uploadUrl = '${serverUrl}upload';
    final fileType = Uploader.getFileType(filePath);
    MultipartFile? multipartFile;

    if (BASE64.check(filePath)) {
      final bytes = BASE64.toData(filePath);
      multipartFile = await MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: MediaType.parse(fileType),
      );
    } else {
      multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: MediaType.parse(fileType),
      );
    }

    final formData = FormData.fromMap({'file': multipartFile});

    try {
      final response = await dio.post<dynamic>(
        uploadUrl,
        data: formData,
        onSendProgress: (count, total) {
          onProgress?.call(count / total);
        },
      );

      final body = response.data;
      if (body is Map<String, dynamic>) {
        String? mimeType;
        if (body.containsKey('mime_type')) {
          mimeType = body['mime_type'] as String?;
        } else if (body.containsKey('details') && body['details'] is Map) {
          final details = body['details'] as Map;
          if (details.containsKey('mime_type')) {
            mimeType = details['mime_type'] as String?;
          }
        }

        String? url;
        if (body.containsKey('url')) {
          url = body['url'] as String?;
        } else if (body.containsKey('fileUrl')) {
          url = body['fileUrl'] as String?;
        } else if (body.containsKey('data') && body['data'] is Map) {
          final data = body['data'] as Map;
          if (data.containsKey('url')) {
            url = data['url'] as String?;
          }
        } else {
          for (final value in body.values) {
            if (value is String &&
                (value.startsWith('http://') || value.startsWith('https://'))) {
              url = value;
              break;
            }
          }
        }

        if (url != null && mimeType != null) {
          try {
            final uri = Uri.parse(url);
            final updatedUri = uri.replace(
              queryParameters: {
                ...uri.queryParameters,
                'm': mimeType,
              },
            );
            return updatedUri.toString();
          } catch (_) {
            return url;
          }
        }
        if (url != null) return url;
      } else if (body is String) {
        if (body.startsWith('http://') || body.startsWith('https://')) {
          return body;
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
