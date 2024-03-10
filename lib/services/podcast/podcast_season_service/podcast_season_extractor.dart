import 'package:collection/collection.dart';
import 'package:seasoning/entities/entities.dart';

abstract class PodcastSeasonExtractor {
  String get guid;

  String get label;

  List<Season> extractSeasons(Podcast podcast) {
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
      if (a != null && b != null) {
        return b.compareTo(a);
      }
      if (map[b]!.last.publicationDate != null &&
          map[a]!.last.publicationDate != null) {
        final aVal = map[a]!.last.publicationDate!.millisecondsSinceEpoch;
        final bVal = map[b]!.last.publicationDate!.millisecondsSinceEpoch;
        return bVal.compareTo(aVal);
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
        title: extractSeasonTitle(firstEpisode),
        seasonNum: seasonKey,
        episodes: episodes,
      );
    }).toList();
  }

  String? extractSeasonTitle(Episode episode) => null;
}

class DefaultPodcastSeasonExtractor extends PodcastSeasonExtractor {
  @override
  final guid = '';

  @override
  final label = 'DefaultPodcastSeasonExtractor';
}
