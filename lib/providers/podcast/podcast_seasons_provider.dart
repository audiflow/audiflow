import 'dart:async';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/podcast_info_provider.dart';

part 'podcast_seasons_provider.g.dart';

@riverpod
Future<List<Season>> podcastSeasons(
  PodcastSeasonsRef ref,
  PodcastSummary summary,
) async {
  final podcast = await ref.watch(
    podcastInfoProvider(summary).selectAsync((state) => state.podcast),
  );

  final map = <int?, List<Episode>>{};
  for (final episode in podcast.episodes) {
    if (map.containsKey(episode.season)) {
      map[episode.season]!.add(episode);
    } else {
      map[episode.season] = [episode];
    }
  }

  if (map.isEmpty || map.keys.first == null) {
    return [];
  }

  return map.keys.sorted((a, b) => (b ?? 0) - (a ?? 0)).map((seasonKey) {
    final seasonEpisodes = map[seasonKey]!
        .sorted((a, b) => (a.episode ?? 0) - (b.episode ?? 0))
        .toList();
    final firstEpisode = seasonEpisodes.first;
    return Season(
      guid: 'season-${firstEpisode.pguid}-${seasonKey ?? 0}',
      pguid: firstEpisode.pguid,
      title: _extractSeasonTitle(firstEpisode),
      seasonNum: seasonKey,
      episodes: seasonEpisodes.toList(),
    );
  }).toList();
}

String? _extractSeasonTitle(Episode episode) {
  switch (episode.pguid) {
    case '1450522865': // COTEN
      final m =
          RegExp(r'【COTEN RADIO\S*\s+(.*?)\d+】').firstMatch(episode.title);
      return m?.group(1)!.replaceFirst(RegExp(r'\s+編$'), '編') ?? '番外編';
    default:
      return null;
  }
}
