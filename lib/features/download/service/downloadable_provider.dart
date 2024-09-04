import 'package:audiflow/events/download_event.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/download/service/download_service.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'downloadable_provider.g.dart';

@riverpod
Downloadable? downloadable(DownloadableRef ref, Episode episode) {
  ref.listen(downloadEventStreamProvider, (_, next) {
    final event = next.valueOrNull;
    switch (event) {
      case DownloadUpdatedEvent(download: final download):
        logger.d('DownloadUpdatedEvent: $download');
        if (download.eid == episode.id) {
          ref.state = download;
        }
      case DownloadDeletedEvent(download: final download):
        logger.d('DownloadDeletedEvent: $download');
        if (download.eid == episode.id) {
          ref.state = null;
        }
      case null:
    }
  });

  ref.read(downloadServiceProvider).findDownload(episode).then((download) {
    ref.state = download;
  });

  return null;
}
