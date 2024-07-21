import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transcript_event.g.dart';

sealed class TranscriptEvent {}

class TranscriptClearEvent implements TranscriptEvent {
  const TranscriptClearEvent();
}

class TranscriptFilterEvent implements TranscriptEvent {
  const TranscriptFilterEvent({
    required this.search,
  });

  final String search;
}

@Riverpod(keepAlive: true)
class TranscriptEventStream extends _$TranscriptEventStream {
  @override
  Stream<TranscriptEvent> build() async* {}

  void add(TranscriptEvent event) {
    state = AsyncData(event);
  }
}
