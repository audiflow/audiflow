import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'season_event.g.dart';

sealed class SeasonEvent {}

class SeasonUpdatedEvent implements SeasonEvent {
  const SeasonUpdatedEvent(this.season);

  final Season season;
}

class SeasonsUpdatedEvent implements SeasonEvent {
  const SeasonsUpdatedEvent(this.seasons);

  final List<Season> seasons;
}

@Riverpod(keepAlive: true)
class SeasonEventStream extends _$SeasonEventStream {
  @override
  Stream<SeasonEvent> build() async* {}

  void add(SeasonEvent event) {
    state = AsyncData(event);
  }
}
