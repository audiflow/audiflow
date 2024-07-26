import 'package:audiflow/features/feed/model/episode.dart';

import '../podcast_season_extractor.dart';

class JP1450522865 extends PodcastSeasonExtractor {
  @override
  final guid = 'https://anchor.fm/s/8c2088c/podcast/rss';
  @override
  final label = 'COTENラジオ';

  @override
  String? extractSeasonTitle(Episode episode) {
    final m = RegExp(r'【COTEN RADIO\S*\s+(.*?)\d+】').firstMatch(episode.title);
    return m?.group(1)!.replaceFirst(RegExp(r'\s+編$'), '編') ?? '番外編';
  }
}
