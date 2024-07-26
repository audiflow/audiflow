import 'package:audiflow/features/browser/podcast/model/season.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'podcast_season_extractor/jp/jp1450522865.dart';
import 'podcast_season_extractor/jp/jp1567192930.dart';
import 'podcast_season_extractor/podcast_season_extractor.dart';

part 'podcast_season_service.g.dart';

@Riverpod(keepAlive: true)
PodcastSeasonService podcastSeasonService(PodcastSeasonServiceRef ref) =>
    PodcastSeasonService._();

class PodcastSeasonService {
  PodcastSeasonService._() {
    final extractors = [
      JP1450522865(),
      JP1567192930(),
    ];

    for (final extractor in extractors) {
      _extractors[extractor.guid] = extractor;
    }
  }

  final _extractors = <String, PodcastSeasonExtractor>{};

  List<Season> extractSeasons(Podcast podcast, List<Episode> episodes) {
    final extractor =
        _extractors[podcast.guid] ?? DefaultPodcastSeasonExtractor();
    return extractor.extractSeasons(podcast, episodes);
  }
}
