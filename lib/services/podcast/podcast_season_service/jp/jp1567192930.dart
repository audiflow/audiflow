import 'package:audiflow/entities/entities.dart';
import 'package:collection/collection.dart';

import '../podcast_season_extractor.dart';

class JP1567192930 extends PodcastSeasonExtractor {
  @override
  final guid = '1567192930';
  @override
  final label = '超相対性理論';

  @override
  List<Season> extractSeasons(Podcast podcast) {
    final map = <String?, List<Episode>>{};
    for (final episode in podcast.episodes) {
      final title = extractSeasonTitle(episode);
      if (map.containsKey(title)) {
        map[title]!.add(episode);
      } else {
        map[title] = [episode];
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
    }).mapIndexed((i, seasonKey) {
      final episodes = map[seasonKey]!;
      final firstEpisode = episodes.first;
      return Season(
        guid: 'season-${firstEpisode.pguid}-${seasonKey ?? 0}',
        pguid: firstEpisode.pguid,
        title: extractSeasonTitle(firstEpisode),
        seasonNum: map.keys.length - i,
        episodes: episodes,
      );
    }).toList();
  }

  @override
  String? extractSeasonTitle(Episode episode) {
    final m = RegExp(r'^#\d+[\s_]*(.*?)（').firstMatch(episode.title);
    return m?.group(1) ?? 'その他';
  }
}
