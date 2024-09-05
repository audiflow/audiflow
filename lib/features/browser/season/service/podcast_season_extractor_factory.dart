import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_extractor.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_title_extractor/ja/jp1450522865.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_title_extractor/ja/jp1567192930.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_title_extractor/podcast_season_title_extractor.dart';
import 'package:audiflow/features/feed/model/model.dart';

final _extractors = Map<String, PodcastSeasonTitleExtractor>.fromEntries([
  JP1450522865(),
  JP1567192930(),
].map((e) => MapEntry(e.feedUrl, e)));

class PodcastSeasonExtractorFactor {
  PodcastSeasonExtractorFactor._();

  static PodcastSeasonExtractor create(
    Podcast podcast, {
    List<Season> knownSeasons = const [],
  }) {
    final titleExtractor =
        _extractors[podcast.feedUrl] ?? _DefaultTitleExtractor();
    return PodcastSeasonExtractor(
      titleExtractor,
      podcast,
      knownSeasons,
    );
  }

  static bool supports(String feedUrl) => _extractors.containsKey(feedUrl);
}

class _DefaultTitleExtractor extends PodcastSeasonTitleExtractor {
  @override
  final feedUrl = '';

  @override
  final label = 'DefaultPodcastSeasonExtractor';
}
