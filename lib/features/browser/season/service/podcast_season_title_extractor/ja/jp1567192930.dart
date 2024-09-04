import 'package:audiflow/features/browser/season/service/podcast_season_title_extractor/podcast_season_title_extractor.dart';

class JP1567192930 extends PodcastSeasonTitleExtractor {
  @override
  final feedUrl = 'https://anchor.fm/s/57a9101c/podcast/rss';
  @override
  final label = '超相対性理論';
  @override
  final distinction = SeasonDistinction.title;

  @override
  String? extractSeasonTitle({
    required String podcastTitle,
    required String title,
    required int? episodeNum,
    required int? seasonNum,
  }) {
    final m = RegExp(r'^#\d+[\s_]*(.*?)（').firstMatch(title);
    return m?.group(1) ?? 'その他';
  }

  @override
  String stripEpisodeTitle({
    required String podcastTitle,
    required String title,
    required int? episodeNum,
    required int? seasonNum,
  }) {
    return title.replaceFirst('【超相対性理論】', '');
  }
}
