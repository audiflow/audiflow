import 'package:seasoning/entities/entities.dart';

import '../podcast_season_extractor.dart';

class JP1567192930 extends PodcastSeasonExtractor {
  @override
  final guid = '1567192930';
  @override
  final label = '超相対性理論';

  @override
  String? extractSeasonTitle(Episode episode) {
    if (episode.season == null) {
      return 'その他?';
    }
    final m = RegExp(r'^#\d+\s+(.*?)（').firstMatch(episode.title);
    return m?.group(1) ?? 'その他!';
  }
}
