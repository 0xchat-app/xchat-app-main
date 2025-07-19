import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ox_common/component.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/utils/string_utils.dart';

class ChatVoiceMessageHelper {
  static Map<String, Duration> durationCache = {};

  static Future<Duration?> getAudioDuration(String uri) async {
    final cache = durationCache[uri];
    if (cache != null && cache != Duration.zero) return cache;

    final player = AudioPlayer();
    await player.setSource(uri.isRemoteURL ? UrlSource(uri) : DeviceFileSource(uri));
    final duration = await player.getDuration();
    if (duration != null && duration != Duration.zero) {
      durationCache[uri] = duration;
    }
    return duration;
  }

  static Future<(File audioFile, Duration? duration)> populateMessageWithAudioDetails({
    required ChatSessionModelISAR session,
    required types.AudioMessage message,
  }) async {
    File sourceFile;
    final uri = message.uri;
    final urlExtension = uri.split('.').last;
    final audioManager = await CLCacheManager.getCircleCacheManager(CacheFileType.audio);
    final cacheFile = message.audioFile ?? (await audioManager.getFileFromCache(uri))?.file;

    if (cacheFile != null) {
      sourceFile = cacheFile;
    } else {
      var tempFile = await audioManager.getSingleFile(uri);

      String newExtension = tempFile.path.split('.').last;
      String newPath = tempFile.path.replaceAll(newExtension, urlExtension);
      tempFile = await tempFile.rename(newPath);

      sourceFile = await audioManager.putFile(
        uri,
        tempFile.readAsBytesSync(),
        fileExtension: tempFile.path.getFileExtension(),
      );

      tempFile.delete();
    }

    final duration = await getAudioDuration(sourceFile.path);
    return (sourceFile, duration);
  }
}
