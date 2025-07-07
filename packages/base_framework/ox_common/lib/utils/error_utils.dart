import 'dart:async';
import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/utils/user_config_tool.dart';
import 'package:ox_common/upload/file_type.dart';
import 'package:ox_common/upload/upload_utils.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/business_interface/ox_chat/interface.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'dart:io';

import 'aes_encrypt_utils.dart';

///Title: error_utils
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2021
///@author Michael
///CreateTime: 2024/3/5 20:19
class ErrorUtils{
  static Future<void> logErrorToFile(String error) async {
    LogUtil.e('logErrorToFile: $error');
    return;
    await ThreadPoolManager.sharedInstance.runOtherTask(() => inputLogErrorToFile(error));
  }

  static Future<void> inputLogErrorToFile(String error) async {
    final directory = await getApplicationDocumentsDirectory();
    int lastTime = UserConfigTool.getSetting(StorageSettingKey.KEY_SAVE_LOG_TIME.name, defaultValue: 0) as int;
    int fileNameTime = DateTime.now().millisecondsSinceEpoch;
    if (lastTime + 24 * 3600 * 1000 > fileNameTime) {
      fileNameTime = lastTime;
    } else {
      UserConfigTool.saveSetting(StorageSettingKey.KEY_SAVE_LOG_TIME.name, fileNameTime);
    }
    final path = directory.path + '/'+'0xchat_log_${fileNameTime}.txt';
    final file = File(path);
    List<String> errorLogs = [];
    if (await file.exists()) {
      final existingContent = await file.readAsString();
      errorLogs = existingContent.split('\n').where((line) => line.isNotEmpty).toList();
    }
    errorLogs.add(error);
    if (errorLogs.length > 20) {
      errorLogs = errorLogs.sublist(errorLogs.length - 20);
    }
    await file.writeAsString(errorLogs.join('\n') + '\n');
    LogUtil.e('John: ErrorUtils--path =${path}');
  }
}