import 'package:audiflow/entities/entities.dart';

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
