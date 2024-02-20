import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/podcast_details_provider.dart';
import 'package:seasoning/services/podcast/mobile_podcast_service.dart';

part 'podcast_seasons_provider.g.dart';

@riverpod
Future<List<Season>> podcastSeasons(
  PodcastSeasonsRef ref,
  PodcastSummary summary,
) async {
  final podcastState = ref.watch(podcastDetailsProvider(summary));
  if (!podcastState.hasValue) {
    return [];
  }

  final map = <int?, List<Episode>>{};
  for (final episode in podcastState.value!.podcast.episodes) {
    if (map.containsKey(episode.season)) {
      map[episode.season]!.add(episode);
    } else {
      map[episode.season] = [episode];
    }
  }

  if (map.isEmpty || map.keys.first == null) {
    return [];
  }

  final podcastService = ref.read(podcastServiceProvider);
  final seasons = map.keys.sorted((a, b) => (b ?? 0) - (a ?? 0));
  final tasks = seasons.map((season) async {
    final tasks = map[season]!
        .sorted((a, b) => (a.episode ?? 0) - (b.episode ?? 0))
        .map((episode) async {
      final stats = await podcastService.loadEpisodeStats(episode);
      return (episode, stats);
    });
    return (season, await Future.wait(tasks));
  });

  final results = await Future.wait(tasks);
  return results.map((result) {
    final (season, seasonEpisodes) = result;
    final firstEpisode = seasonEpisodes.first.$1;
    return Season(
      guid: 'season-${firstEpisode.pguid}-${season ?? 0}',
      pguid: firstEpisode.pguid,
      title: _extractSeasonTitle(firstEpisode),
      seasonNum: season,
      episodes: seasonEpisodes.toList(),
    );
  }).toList(growable: false);
}

String? _extractSeasonTitle(Episode episode) {
  switch (episode.pguid) {
    case 'https://anchor.fm/s/8c2088c/podcast/rss': // COTEN
      final m =
          RegExp(r'【COTEN RADIO\S*\s+(.*?)\d+】').firstMatch(episode.title);
      return m?.group(1)!.replaceFirst(RegExp(r'\s+編$'), '編') ?? '番外編';
    default:
      return null;
  }
}
