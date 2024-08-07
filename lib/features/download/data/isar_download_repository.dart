import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:isar/isar.dart';

class IsarDownloadRepository implements DownloadRepository {
  IsarDownloadRepository(this.isar);

  final Isar isar;

  @override
  Future<Downloadable?> findDownload(Id eid) async {
    return isar.downloadables.get(eid);
  }

  @override
  Future<List<Downloadable?>> findDownloads(Iterable<Id> eids) async {
    return isar.downloadables.getAll(eids.toList());
  }

  @override
  Future<List<Downloadable>> queryDownloads({int? pid}) async {
    return isar.downloadables
        .where()
        .optional(pid != null, (q) => q.pidEqualToAnyOrdinal(pid!))
        .findAll();
  }

  @override
  Future<List<Downloadable>> queryDownloaded({
    required int pid,
    int? lastOrdinal,
    bool ascending = false,
    int? limit,
  }) async {
    return isar.downloadables
        .where()
        .optional(
          true,
          (q) => lastOrdinal == null
              ? q.pidEqualToAnyOrdinal(pid)
              : ascending
                  ? q.pidEqualToOrdinalGreaterThan(pid, lastOrdinal)
                  : q.pidEqualToOrdinalLessThan(pid, lastOrdinal),
        )
        .filter()
        .stateEqualTo(DownloadState.downloaded)
        .optional(
          true,
          (q) => ascending
              ? q.sortByDownloadStartedAt()
              : q.sortByDownloadStartedAtDesc(),
        )
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
  }

  @override
  Future<Downloadable?> findDownloadByTaskId(String taskId) async {
    return isar.downloadables.where().taskIdEqualTo(taskId).findFirst();
  }

  @override
  Future<int> countDownloaded({
    int? pid,
  }) async {
    return isar.downloadables
        .where()
        .optional(pid != null, (q) => q.pidEqualToAnyOrdinal(pid!))
        .count();
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
