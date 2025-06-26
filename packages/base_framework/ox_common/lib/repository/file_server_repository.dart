import 'package:isar/isar.dart';
import 'package:ox_common/model/file_server_model.dart';
import 'package:ox_common/log_util.dart';

/// Provide CRUD helpers for FileServerModel.
class FileServerRepository {
  FileServerRepository(this.isar);

  final Isar isar;

  /// Stream list of servers ordered by id.
  Stream<List<FileServerModel>> watchAll() {
    return isar.fileServerModels.where().watch(fireImmediately: true);
  }

  Future<int> create(FileServerModel server) async {
    try {
      await isar.writeAsync((isar) {
        isar.fileServerModels.put(server);
      });
      return server.id;
    } catch (e) {
      LogUtil.e("create server failed $e");
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await isar.writeAsync((isar) {
        isar.fileServerModels.delete(id);
      });
    } catch (e) {
      LogUtil.e('delete server failed $e');
    }
  }
} 