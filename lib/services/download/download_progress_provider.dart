import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/download_event.dart';
import 'package:seasoning/services/download/download_service_provider.dart';

export 'package:seasoning/services/download/download_service.dart';

part 'download_progress_provider.g.dart';

@riverpod
class DownloadProgress extends _$DownloadProgress {
  @override
  Future<Downloadable?> build(Episode episode) async {
    _listen(episode);
    // initial
    return ref.watch(downloadServiceProvider).findDownloadByGuid(episode.guid);
  }

  void _listen(Episode episode) {
    ref.listen(downloadEventStreamProvider, (_, next) {
      final event = next.valueOrNull;
      switch (event) {
        case DownloadUpdatedEvent(download: final download):
          if (download.guid == episode.guid) {
            state = AsyncData(download);
          }
        case DownloadDeletedEvent(download: final download):
          if (download.guid == episode.guid) {
            state = const AsyncData(null);
          }
        case null:
      }
    });
  }
}
