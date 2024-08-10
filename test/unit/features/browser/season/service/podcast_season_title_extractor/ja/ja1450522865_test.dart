import 'package:audiflow/features/browser/season/service/podcast_season_title_extractor/ja/jp1450522865.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cases = [
    {
      'title': '【1-1】タイトル【COTEN RADIOショート シーズンX 後編】',
      'expected': 'シーズンX',
    },
    {
      'title': '【10-2】タイトル【COTEN RADIO シーズンX編2】',
      'expected': 'シーズンX',
    },
    {
      'title': '【10-22】タイトル【COTEN RADIO シーズンX編22】',
      'expected': 'シーズンX',
    }
  ];

  final extractor = JP1450522865();
  group('COTEN RADIO', () {
    for (final c in cases) {
      test(c['title']!, () {
        final actual = extractor.extractSeasonTitle(
          podcastTitle: '',
          title: c['title']!,
          episodeNum: 1,
          seasonNum: 49,
        );
        expect(actual, c['expected']);
      });
    }

    test('stripEpisodeTitle', () {
      final actual = extractor.stripEpisodeTitle(
        podcastTitle: '',
        title: '【1-1】タイトル【COTEN RADIOショート シーズンX 後編】',
        episodeNum: 1,
        seasonNum: 49,
      );
      expect(actual, '【1-1】タイトル');
    });
  });
}
