import 'package:audiflow/entities/entities.dart';

import '../podcast_season_extractor.dart';

class JP1450522865 extends PodcastSeasonExtractor {
  @override
  final guid = '1450522865';
  @override
  final label = 'COTENラジオ';

  @override
  String? extractSeasonTitle(Episode episode) {
    final m = RegExp(r'【COTEN RADIO\S*\s+(.*?)\d+】').firstMatch(episode.title);
    return m?.group(1)!.replaceFirst(RegExp(r'\s+編$'), '編') ?? '番外編';
  }
}
