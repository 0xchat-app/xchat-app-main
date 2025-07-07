import 'package:ox_common/const/common_constant.dart';
import 'package:ox_common/log_util.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'package:dio/dio.dart';
import 'package:ox_common/utils/aes_encrypt_utils.dart';

enum UplodAliyunType {
  imageType,
  voiceType,
  videoType,
  logType,
}

class UplodAliyun {

  static bool isAliOSSUrl(String url) => false;

  // https://help.aliyun.com/zh/oss/user-guide/video-snapshots
  static String getSnapshot(
      String url,
      {String t = '0',
        String f = 'jpg',
        String w = '0',
        String h = '0',
        String m = 'fast',
        String ar = 'auto',
      }) {

    final aliyunSnapshotParams = {
      'spm': 'qipa250',
      'x-oss-process': 'video/snapshot,t_$t,f_$f,w_$w,h_$h,m_$m,ar_$ar',
    };

    final uri = Uri.tryParse(url);
    if (uri == null) {
      final queryString = aliyunSnapshotParams.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');
      return '$url?$queryString';
    }

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...aliyunSnapshotParams,
      },
    ).toString();
  }
}
