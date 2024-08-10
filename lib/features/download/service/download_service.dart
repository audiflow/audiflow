import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_service.g.dart';

abstract class DownloadService {
  Future<List<Downloadable>> loadAllDownloads();

  Future<bool> downloadEpisode(Episode episode);

  Future<void> downloadEpisodes(
    Iterable<Episode> episodes, {
    bool unplayedOnly = false,
  });

  Future<void> deleteDownload(Episode episode);

  Future<Downloadable?> findDownload(Episode episode);

  void dispose();
}

@Riverpod(keepAlive: true)
DownloadService downloadService(DownloadServiceRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
