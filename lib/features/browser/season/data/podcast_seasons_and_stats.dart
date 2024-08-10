import 'dart:async';

import 'package:audiflow/events/season_event.dart';
import 'package:audiflow/features/browser/season/data/season_repository.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_seasons_and_stats.g.dart';

@riverpod
Future<List<SeasonPair>> podcastSeasonsAndStats(
  PodcastSeasonsAndStatsRef ref,
  int pid,
) async {
  Future<void> onSeasonUpdated(Season season) async {
    final stats = ref.state.requireValue
            .firstWhereOrNull(
              (p) => p.season.id == season.id,
            )
            ?.stats ??
        await ref.read(seasonRepositoryProvider).findSeasonStats(season.id);
    ref.state = AsyncData([
      ...ref.state.requireValue
        ..removeWhere((p) => p.season.id == season.id)
        ..add(SeasonPair(season, stats))
        ..sorted(),
    ]);
  }

  Future<void> onSeasonsUpdated(List<Season> seasons) async {
    final current = ref.state.requireValue;
    final newSeasons =
        seasons.where((s) => !current.any((p) => s.id == p.season.id));
    final newStats = newSeasons.isEmpty
        ? <SeasonStats?>[]
        : await ref
            .read(seasonRepositoryProvider)
            .findSeasonStatsList(newSeasons.map((s) => s.id));
    ref.state = AsyncData([
      ...ref.state.requireValue
        ..removeWhere((p) => newSeasons.any((s) => p.season.id == s.id))
        ..addAll(
          newSeasons.map(
            (s) => SeasonPair(
              s,
              newStats.firstWhereOrNull((stats) => stats?.id == s.id),
            ),
          ),
        )
        ..sorted(),
    ]);
  }

  void listen() {
    ref.listen(seasonEventStreamProvider, (_, event) {
      event.whenData(
        (data) {
          switch (event.valueOrNull) {
            case SeasonUpdatedEvent(season: final season):
              if (season.pid == pid) {
                onSeasonUpdated(season);
              }
            case SeasonsUpdatedEvent(seasons: final seasons):
              final podcastSeasons =
                  seasons.where((s) => s.pid == pid).toList();
              if (podcastSeasons.isNotEmpty) {
                onSeasonsUpdated(podcastSeasons);
              }
            case null:
          }
        },
      );
    });
  }

  try {
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
  } finally {
    listen();
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
