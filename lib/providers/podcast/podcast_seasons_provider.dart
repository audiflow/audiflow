import 'dart:async';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/podcast_info_provider.dart';
import 'package:seasoning/services/podcast/podcast_season_service.dart';

part 'podcast_seasons_provider.g.dart';

@riverpod
Future<List<Season>> podcastSeasons(
  PodcastSeasonsRef ref,
  PodcastMetadata metadata,
) async {
  final podcast = await ref.watch(
    podcastInfoProvider(metadata).selectAsync((state) => state.podcast),
  );

  final map = <int?, List<Episode>>{};
  for (final episode in podcast.episodes) {
    if (map.containsKey(episode.season)) {
      map[episode.season]!.add(episode);
    } else {
      map[episode.season] = [episode];
    }
  }

  if (map.keys.length < 2) {
    return [];
  }

  for (final entry in map.entries) {
    entry.value.sort((a, b) {
      if (a.episode != null && b.episode != null) {
        return a.episode!.compareTo(b.episode!);
      }
      if (a.publicationDate != null && b.publicationDate != null) {
        return a.publicationDate!.millisecondsSinceEpoch
            .compareTo(b.publicationDate!.millisecondsSinceEpoch);
      }
      return a.publicationDate != null
          ? -1
          : b.publicationDate != null
              ? 1
              : a.title.compareTo(b.title);
    });
  }

  return map.keys.sorted((a, b) {
    if (map[b]!.last.publicationDate != null &&
        map[a]!.last.publicationDate != null) {
      final aVal = map[a]!.last.publicationDate!.millisecondsSinceEpoch;
      final bVal = map[b]!.last.publicationDate!.millisecondsSinceEpoch;
      return bVal.compareTo(aVal);
    }
    if (a != null && b != null) {
      return b.compareTo(a);
    }
    return map[b]!.last.publicationDate != null
        ? -1
        : map[a]!.last.publicationDate != null
            ? 1
            : map[b]!.last.title.compareTo(map[a]!.last.title);
  }).map((seasonKey) {
    final episodes = map[seasonKey]!;
    final firstEpisode = episodes.first;
    return Season(
      guid: 'season-${firstEpisode.pguid}-${seasonKey ?? 0}',
      pguid: firstEpisode.pguid,
      title: PodcastSeasonService().extractSeasonTitle(firstEpisode),
      seasonNum: seasonKey,
      episodes: episodes,
    );
  }).toList();
}
