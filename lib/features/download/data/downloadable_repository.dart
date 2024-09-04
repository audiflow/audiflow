import 'package:audiflow/events/download_event.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'downloadable_repository.g.dart';

@riverpod
Future<Downloadable?> episodeDownloadable(
  EpisodeDownloadableRef ref,
  int eid,
) async {
  ref.listen(downloadEventStreamProvider, (_, next) {
    switch (next.valueOrNull) {
      case DownloadUpdatedEvent(download: final download):
        if (download.eid == eid) {
          ref.state = AsyncData(download);
        }
      case DownloadDeletedEvent(download: final download):
        if (download.eid == eid) {
          ref.state = const AsyncData(null);
        }
      case null:
    }
  });

  return ref.read(downloadRepositoryProvider).findDownload(eid);
}
