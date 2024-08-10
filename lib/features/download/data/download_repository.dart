import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_repository.g.dart';

abstract class DownloadRepository {
  Future<Downloadable?> findDownload(Id eid);

  Future<List<Downloadable?>> findDownloads(Iterable<Id> eids);

  Future<List<Downloadable>> queryDownloads({int? pid});

  Future<List<Downloadable>> queryDownloaded({
    required int pid,
    int? lastOrdinal,
    bool ascending = false,
    int? limit,
  });

  Future<Downloadable?> findDownloadByTaskId(String taskId);

  Future<int> countDownloaded({int? pid});

  Future<void> saveDownload(Downloadable download);

  Future<void> deleteDownload(Downloadable download);
}

@Riverpod(keepAlive: true)
DownloadRepository downloadRepository(DownloadRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
