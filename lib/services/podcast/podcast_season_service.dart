import 'package:seasoning/entities/entities.dart';

class PodcastSeasonService {
  factory PodcastSeasonService() {
    return _instance;
  }

  PodcastSeasonService._();

  static final _instance = PodcastSeasonService._();

  String? extractSeasonTitle(Episode episode) {
    switch (episode.pguid) {
      case '1450522865': // COTENラジオ
        final m =
            RegExp(r'【COTEN RADIO\S*\s+(.*?)\d+】').firstMatch(episode.title);
        return m?.group(1)!.replaceFirst(RegExp(r'\s+編$'), '編') ?? '番外編';
      case '1567192930': // 超相対性理論
        if (episode.season == null) {
          return 'その他';
        }
        final m = RegExp(r'^#\d+\s+(.*?)（').firstMatch(episode.title);
        return m?.group(1) ?? 'その他';
        return null;
      default:
        return null;
    }
  }
}
