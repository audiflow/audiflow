import 'package:audiflow/features/browser/season/service/podcast_season_title_extractor/podcast_season_title_extractor.dart';

class JP1450522865 extends PodcastSeasonTitleExtractor {
  @override
  final feedUrl = 'https://anchor.fm/s/8c2088c/podcast/rss';
  @override
  final label = 'COTENラジオ';

  final re = RegExp(
    r'【(?<coten>COTEN RADIO)(?<short>ショート)?\s+(?<season>.*?)((?<seq>\d+)|(?<part>[前中後]編))】',
  );

  @override
  String? extractSeasonTitle({
    required String podcastTitle,
    required String title,
    required int? episodeNum,
    required int? seasonNum,
  }) {
    final m = re.firstMatch(title);
    return m?.namedGroup('season')?.replaceFirst(RegExp(r'\s*編?$'), '') ??
        '番外編';
  }

  @override
  String stripEpisodeTitle({
    required String podcastTitle,
    required String title,
    required int? episodeNum,
    required int? seasonNum,
  }) {
    final m = re.firstMatch(title);
    return m == null ? title : title.substring(0, m.start).trim();
  }
}
