import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/model/file_server_model.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/repository/file_server_repository.dart';

class FileServerHelper {
  FileServerHelper._();

  /// Returns the current circle's selected [FileServerModel] asynchronously.
  /// Returns `null` when no server is configured.
  static Future<FileServerModel?> currentFileServer() async {
    final circle = LoginManager.instance.currentCircle;
    final url = circle?.selectedFileServerUrl;
    if (url == null || url.isEmpty) return null;

    final repo = FileServerRepository(DBISAR.sharedInstance.isar);
    final list = await repo.watchAll().first;
    try {
      return list.firstWhere((e) => e.url == url);
    } catch (_) {
      return null;
    }
  }
} 