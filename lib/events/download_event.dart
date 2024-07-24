import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_event.g.dart';

sealed class DownloadEvent {}

class DownloadUpdatedEvent implements DownloadEvent {
  const DownloadUpdatedEvent(this.download);

  final Downloadable download;
}

class DownloadDeletedEvent implements DownloadEvent {
  const DownloadDeletedEvent(this.download);

  final Downloadable download;
}

@Riverpod(keepAlive: true)
class DownloadEventStream extends _$DownloadEventStream {
  @override
  Stream<DownloadEvent> build() async* {}

  void add(DownloadEvent event) {
    state = AsyncData(event);
  }
}
