// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:collection/collection.dart';

abstract class PodcastSeasonExtractor {
  String get guid;

  String get label;

  List<Season> extractSeasons(Podcast podcast, List<Episode> episodes) {
    final map = <int?, List<Episode>>{};
    for (final episode in episodes) {
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
        guid: 'season-${firstEpisode.pid}-${seasonKey ?? 0}',
        pid: firstEpisode.pid,
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
