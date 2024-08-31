import 'package:audiflow/events/download_event.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_stats_updater.g.dart';

@Riverpod(keepAlive: true)
void episodeStatsUpdater(EpisodeStatsUpdaterRef ref) {
  ref.listen(downloadEventStreamProvider, (_, next) {
    switch (next.requireValue) {
      case DownloadUpdatedEvent(download: final download):
        if (download.state == DownloadState.downloaded) {
          ref.read(episodeStatsRepositoryProvider).updateEpisodeStats(
                EpisodeStatsUpdateParam(
                  pid: download.pid,
                  eid: download.eid,
                  ordinal: download.ordinal,
                  downloaded: true,
                ),
              );
        }
      case DownloadDeletedEvent(download: final download):
        ref.read(episodeStatsRepositoryProvider).updateEpisodeStats(
              EpisodeStatsUpdateParam(
                pid: download.pid,
                eid: download.eid,
                ordinal: download.ordinal,
                downloaded: false,
              ),
            );
    }
  });
}
