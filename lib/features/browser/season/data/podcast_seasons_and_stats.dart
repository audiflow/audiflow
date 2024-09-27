import 'dart:async';

import 'package:audiflow/events/season_event.dart';
import 'package:audiflow/features/browser/season/data/season_repository.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'podcast_seasons_and_stats.g.dart';

@riverpod
class PodcastSeasonsAndStats extends _$PodcastSeasonsAndStats {
  @override
  Future<List<SeasonPair>> build(int pid) async {
    final completer = Completer<void>();
    _listen(completer.future);

    final initialData = await _initialData();
    completer.complete(null);
    return initialData;
  }

  Future<List<SeasonPair>> _initialData() async {
    final seasons =
        await ref.read(seasonRepositoryProvider).findPodcastSeasons(pid);
    if (seasons.isEmpty) {
      return [];
    }

    final statsList = await ref
        .read(seasonRepositoryProvider)
        .findSeasonStatsList(seasons.map((e) => e.id).toList());
    return seasons
        .mapIndexed((i, season) => SeasonPair(season, statsList[i]))
        .toList();
  }

  void _listen(Future<void> completer) {
    final streamController = StreamController<SeasonEvent>();
    ref.onDispose(streamController.close);

    streamController.stream.flatMap(
      (event) async* {
        // Wait for populating the initial data.
        await completer;

        switch (event) {
          case SeasonsUpdatedEvent(seasons: final seasons):
            final podcastSeasons = seasons.where((s) => s.pid == pid).toList();
            if (podcastSeasons.isNotEmpty) {
              await _onSeasonsUpdated(podcastSeasons);
            }
        }
      },
      maxConcurrent: 1,
    ).drain<void>();

    ref.listen(seasonEventStreamProvider, (_, event) {
      event.whenData(
        (data) => streamController.add(event.requireValue),
      );
    });
  }

  Future<void> _onSeasonsUpdated(List<Season> seasons) async {
    if (seasons.isEmpty) {
      return;
    }

    final newStats = seasons.isEmpty
        ? <SeasonStats?>[]
        : await ref
            .read(seasonRepositoryProvider)
            .findSeasonStatsList(seasons.map((s) => s.id));
    state = AsyncData([
      ...state.requireValue
        ..removeWhere(
          (p) => seasons.any((s) => p.season.seasonNum == s.seasonNum),
        )
        ..addAll(
          seasons.map(
            (s) => SeasonPair(
              s,
              newStats.firstWhereOrNull((stats) => stats?.id == s.id),
            ),
          ),
        )
        ..sort(),
    ]);
  }
}

class SeasonPair implements Comparable<SeasonPair> {
  SeasonPair(this.season, this.stats);

  final Season season;
  final SeasonStats? stats;

  @override
  int compareTo(SeasonPair other) {
    return (other.season.latestPublicationDate?.millisecondsSinceEpoch ?? 0)
        .compareTo(
      season.latestPublicationDate?.millisecondsSinceEpoch ?? 0,
    );
  }
}
