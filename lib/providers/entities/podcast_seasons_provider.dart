import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/entities/podcast_episodes_provider.dart';

part 'podcast_seasons_provider.g.dart';

@riverpod
List<Season> podcastSeasons(PodcastSeasonsRef ref) {
  final episodes = ref.watch(podcastEpisodesProvider);
  final map = <int, List<Episode>>{};
  for (final episode in episodes) {
    if (map.containsKey(episode.season)) {
      map[episode.season]!.add(episode);
    } else {
      map[episode.season] = [episode];
    }
  }

  return map.keys.sorted((a, b) => b - a).map((seasonNum) {
    final seasonElements =
        map[seasonNum]!.sorted((a, b) => a.episode - b.episode);
    final episode = seasonElements.first;
    return Season(
      pguid: episode.pguid,
      podcast: episode.podcast,
      title: _extractSeasonTitle(episode),
      seasonNum: seasonNum,
      episodes: seasonElements,
    );
  }).toList(growable: false);
}

String? _extractSeasonTitle(Episode episode) {
  if (episode.season < 1) {
    return null;
  }

  switch (episode.pguid) {
    case 'https://anchor.fm/s/8c2088c/podcast/rss': // COTEN
      final m = RegExp(r'【COTEN RADIO\S*\s+(.*?)\d+】')
          .firstMatch(episode.title ?? '');
      return m?.group(1)!.replaceFirst(RegExp(r'\s+編$'), '編');
    default:
      return null;
  }
}
