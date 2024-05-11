import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'opml_event_stream_provider.g.dart';

@Riverpod(dependencies: [])
class OpmlEventStream extends _$OpmlEventStream {
  @override
  Stream<OPMLEvent> build() async* {}

  void add(OPMLEvent event) {
    state = AsyncData(event);
  }
}

sealed class OPMLEvent {}

class OPMLLoadingEvent implements OPMLEvent {
  OPMLLoadingEvent({
    required this.current,
    required this.total,
    required this.podcastTitle,
  });

  final int current;
  final int total;
  final String podcastTitle;
}

class OPMLCompletedEvent implements OPMLEvent {}

class OPMLErrorEvent implements OPMLEvent {}
