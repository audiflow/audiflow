import 'package:audiflow/events/download_event.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/download/service/download_service.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_progress.g.dart';

@riverpod
class DownloadProgress extends _$DownloadProgress {
  @override
  Future<Downloadable?> build(Episode episode) async {
    _listen(episode);
    // initial
    return ref.watch(downloadServiceProvider).findDownload(episode);
  }

  void _listen(Episode episode) {
    ref.listen(downloadEventStreamProvider, (_, next) {
      final event = next.valueOrNull;
      switch (event) {
        case DownloadUpdatedEvent(download: final download):
          if (download.eid == episode.id) {
            state = AsyncData(download);
          }
        case DownloadDeletedEvent(download: final download):
          if (download.eid == episode.id) {
            state = const AsyncData(null);
          }
        case null:
      }
    });
  }
}
