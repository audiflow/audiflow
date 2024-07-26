import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_extractor.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_title_extractor/podcast_season_title_extractor.dart';
import 'package:audiflow/features/feed/model/model.dart';

import 'podcast_season_title_extractor/jp/jp1450522865.dart';
import 'podcast_season_title_extractor/jp/jp1567192930.dart';

class PodcastSeasonService {
  PodcastSeasonService() {
    final extractors = [
      JP1450522865(),
      JP1567192930(),
    ];

    for (final extractor in extractors) {
      _extractors[extractor.feedUrl] = extractor;
    }
  }

  final _extractors = <String, PodcastSeasonTitleExtractor>{};

  Iterable<Season> extractSeasons(
    Podcast podcast,
    List<Episode> episodes,
    List<Season> seasons,
  ) {
    final titleExtractor =
        _extractors[podcast.feedUrl] ?? _DefaultTitleExtractor();
    final seasonExtractor = PodcastSeasonExtractor(
      titleExtractor,
      podcast,
      episodes,
      seasons,
    );
    return seasonExtractor.extract();
  }
}

class _DefaultTitleExtractor extends PodcastSeasonTitleExtractor {
  @override
  final feedUrl = '';

  @override
  final label = 'DefaultPodcastSeasonExtractor';
}
