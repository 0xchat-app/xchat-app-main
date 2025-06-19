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
      return await isar.writeTxn(() async => await isar.fileServerModels.put(server));
    } catch (e) {
      LogUtil.e("create server failed $e");
      rethrow;
    }
  }

  Future<void> delete(Id id) async {
    try {
      await isar.writeTxn(() async => await isar.fileServerModels.delete(id));
    } catch (e) {
      LogUtil.e('delete server failed $e');
    }
  }
} 