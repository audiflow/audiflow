import 'package:audiflow/events/download_event.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

class DownloadRepositoryChangeHandler implements DownloadRepository {
  DownloadRepositoryChangeHandler(this._ref, this._inner);

  final Ref _ref;
  final DownloadRepository _inner;

  @override
  Future<Downloadable?> findDownload(Id eid) => _inner.findDownload(eid);

  @override
  Future<List<Downloadable?>> findDownloads(Iterable<Id> eids) =>
      _inner.findDownloads(eids);

  @override
  Future<List<Downloadable>> queryDownloads({int? pid}) =>
      _inner.queryDownloads(pid: pid);

  @override
  Future<List<Downloadable>> queryDownloaded({
    required int pid,
    int? lastOrdinal,
    bool ascending = false,
    int? limit,
  }) =>
      _inner.queryDownloaded(
        pid: pid,
        lastOrdinal: lastOrdinal,
        ascending: ascending,
        limit: limit,
      );

  @override
  Future<Downloadable?> findDownloadByTaskId(String taskId) =>
      _inner.findDownloadByTaskId(taskId);

  @override
  Future<int> countDownloaded({int? pid}) => _inner.countDownloaded(pid: pid);

  @override
  Future<void> saveDownload(Downloadable download) async {
    await _inner.saveDownload(download);
    _ref
        .read(downloadEventStreamProvider.notifier)
        .add(DownloadUpdatedEvent(download));
  }

  @override
  Future<void> deleteDownload(Downloadable download) async {
    await _inner.deleteDownload(download);
    _ref
        .read(downloadEventStreamProvider.notifier)
        .add(DownloadDeletedEvent(download));
  }
}
