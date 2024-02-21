import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/events/download_event.dart';
import 'package:seasoning/repository/repository_provider.dart';
import 'package:seasoning/services/download/download_service_provider.dart';

export 'package:seasoning/services/download/download_service.dart';

part 'download_progress_provider.g.dart';

@riverpod
class DownloadProgress extends _$DownloadProgress {
  @override
  Future<Downloadable?> build(Episode episode) async {
    final download =
        ref.watch(downloadServiceProvider).findDownloadByGuid(episode.guid);
    _listen(episode);
    return download;
  }

  void _listen(Episode episode) {
    final sub = ref.read(repositoryProvider).downloadStream.listen((event) {
      switch (event) {
        case DownloadUpdatedEvent(download: final download):
          if (download.guid == episode.guid) {
            state = AsyncData(download);
          }
        case DownloadDeletedEvent(download: final download):
          if (download.guid == episode.guid) {
            state = const AsyncData(null);
          }
      }
    });

    ref.onDispose(sub.cancel);
  }
}
