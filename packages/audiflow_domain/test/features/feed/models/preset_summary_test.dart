import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PresetSummary', () {
    test('constructs with required fields', () {
      final summary = PresetSummary(
        id: 'coten_radio',
        dataVersion: 1,
        displayName: 'Coten Radio',
        feedUrlHints: ['anchor.fm/s/8c2088c'],
        playlistCount: 3,
      );
      expect(summary.id, 'coten_radio');
      expect(summary.dataVersion, 1);
      expect(summary.displayName, 'Coten Radio');
      expect(summary.feedUrlHints, ['anchor.fm/s/8c2088c']);
      expect(summary.playlistCount, 3);
    });

    test('deserializes from JSON', () {
      final json = {
        'id': 'coten_radio',
        'dataVersion': 2,
        'displayName': 'Coten Radio',
        'feedUrlHints': ['anchor.fm/s/8c2088c'],
        'playlistCount': 3,
      };
      final summary = PresetSummary.fromJson(json);
      expect(summary.id, 'coten_radio');
      expect(summary.dataVersion, 2);
    });

    test('keeps every feed URL hint in order', () {
      final summary = PresetSummary.fromJson({
        'id': 'moved_show',
        'dataVersion': 1,
        'displayName': 'Moved Show',
        'feedUrlHints': [
          'https://new.example.com/rss',
          'https://old.example.com/rss',
        ],
        'playlistCount': 1,
      });
      expect(summary.feedUrlHints, [
        'https://new.example.com/rss',
        'https://old.example.com/rss',
      ]);
    });

    test('rejects the v7 scalar feedUrlHint', () {
      expect(
        () => PresetSummary.fromJson({
          'id': 'legacy',
          'dataVersion': 1,
          'displayName': 'Legacy',
          'feedUrlHint': 'example.com',
          'playlistCount': 1,
        }),
        throwsFormatException,
      );
    });

    for (final (label, hints) in [
      ('no', <String>[]),
      ('an empty', ['']),
    ]) {
      test('rejects $label feed URL hint', () {
        // An empty hint is a substring of every URL and would match all
        // podcasts; the schema requires at least one non-empty hint.
        expect(
          () => PresetSummary.fromJson({
            'id': 'bad',
            'dataVersion': 1,
            'displayName': 'Bad',
            'feedUrlHints': hints,
            'playlistCount': 1,
          }),
          throwsFormatException,
        );
      });
    }

    test('serializes to JSON', () {
      final summary = PresetSummary(
        id: 'news',
        dataVersion: 1,
        displayName: 'News',
        feedUrlHints: ['example.com'],
        playlistCount: 2,
      );
      final json = summary.toJson();
      expect(json['id'], 'news');
      expect(json['dataVersion'], 1);
      expect(json['displayName'], 'News');
      expect(json['feedUrlHints'], ['example.com']);
      expect(json['playlistCount'], 2);
    });

    test('roundtrips through JSON', () {
      final original = PresetSummary(
        id: 'test',
        dataVersion: 5,
        displayName: 'Test Pattern',
        feedUrlHints: ['test.com/feed'],
        playlistCount: 1,
      );
      final restored = PresetSummary.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.dataVersion, original.dataVersion);
      expect(restored.displayName, original.displayName);
      expect(restored.feedUrlHints, original.feedUrlHints);
      expect(restored.playlistCount, original.playlistCount);
    });
  });
}
