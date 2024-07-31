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
  Future<List<Downloadable>> findDownloadsBy({
    int? pid,
    DateTime? lastDownloadStartedAt,
    DownloadSortBy? sortBy,
    bool ascending = false,
    int? offset,
    int? limit,
  }) async {
    return isar.downloadables
        .where()
        .filter()
        .optional(pid != null, (q) => q.pidEqualTo(pid!))
        .optional(
          lastDownloadStartedAt != null,
          (q) => ascending
              ? q.downloadStartedAtGreaterThan(lastDownloadStartedAt!)
              : q.downloadStartedAtLessThan(lastDownloadStartedAt!),
        )
        .optional(sortBy != null, (q) {
          switch (sortBy!) {
            case DownloadSortBy.downloadStartedAt:
              return ascending
                  ? q.sortByDownloadStartedAt()
                  : q.sortByDownloadStartedAtDesc();
          }
        })
        .optional(offset != null, (q) => q.offset(offset!))
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
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
  Future<int> countDownloaded({
    int? pid,
  }) async {
    return isar.downloadables
        .where()
        .optional(pid != null, (q) => q.pidEqualTo(pid!))
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
