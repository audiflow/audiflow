import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:isar/isar.dart';

class IsarDownloadRepository implements DownloadRepository {
  IsarDownloadRepository(this.isar);

  final Isar isar;

  @override
  Future<List<Downloadable>> findDownloadsByPodcastId(int pid) async {
    return isar.downloadables.where().filter().pidEqualTo(pid).findAll();
  }

  @override
  Future<List<Downloadable>> findAllDownloads() async {
    return isar.downloadables.where().findAll();
  }

  @override
  Future<List<Downloadable?>> findDownloads(Iterable<Id> ids) async {
    return isar.downloadables.getAll(ids.toList());
  }

  @override
  Future<Downloadable?> findDownload(Id id) async {
    return isar.downloadables.get(id);
  }

  @override
  Future<Downloadable?> findDownloadByTaskId(String taskId) async {
    return isar.downloadables
        .where()
        .filter()
        .taskIdEqualTo(taskId)
        .findFirst();
  }

  @override
  Future<void> saveDownload(Downloadable download) async {
    await isar.writeTxn(() => isar.downloadables.put(download));
  }

  @override
  Future<void> deleteDownload(Downloadable download) async {
    await isar.writeTxn(() => isar.downloadables.delete(download.id));
  }
}
