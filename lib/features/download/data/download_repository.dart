import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_repository.g.dart';

abstract class DownloadRepository {
  Future<List<Downloadable>> findDownloadsByPodcastId(int pid);

  Future<List<Downloadable>> findAllDownloads();

  Future<List<Downloadable?>> findDownloads(Iterable<Id> ids);

  Future<Downloadable?> findDownload(Id id);

  Future<Downloadable?> findDownloadByTaskId(String taskId);

  Future<void> saveDownload(Downloadable download);

  Future<void> deleteDownload(Downloadable download);
}

@Riverpod(keepAlive: true)
DownloadRepository downloadRepository(DownloadRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
