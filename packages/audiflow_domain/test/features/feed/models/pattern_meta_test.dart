import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatternMeta', () {
    test('deserializes from JSON', () {
      final json = {
        'version': 1,
        'id': 'coten_radio',
        'feedUrls': ['https://anchor.fm/s/8c2088c/podcast/rss'],
        'yearGroupedEpisodes': true,
        'playlists': ['regular', 'short', 'extras'],
      };
      final meta = PatternMeta.fromJson(json);
      expect(meta.version, 1);
      expect(meta.id, 'coten_radio');
      expect(meta.feedUrls, hasLength(1));
      expect(meta.yearGroupedEpisodes, isTrue);
      expect(meta.playlists, ['regular', 'short', 'extras']);
    });

    test('defaults yearGroupedEpisodes to false', () {
      final json = {
        'version': 1,
        'id': 'test',
        'feedUrls': <String>[],
        'playlists': ['main'],
      };
      final meta = PatternMeta.fromJson(json);
      expect(meta.yearGroupedEpisodes, isFalse);
    });

    test('handles optional podcastGuid', () {
      final json = {
        'version': 1,
        'id': 'test',
        'podcastGuid': 'abc-123',
        'feedUrls': <String>[],
        'playlists': ['main'],
      };
      final meta = PatternMeta.fromJson(json);
      expect(meta.podcastGuid, 'abc-123');
    });

    test('serializes to JSON', () {
      final meta = PatternMeta(
        version: 1,
        id: 'test',
        feedUrls: ['pattern1'],
        yearGroupedEpisodes: true,
        playlists: ['p1', 'p2'],
      );
      final json = meta.toJson();
      expect(json['version'], 1);
      expect(json['id'], 'test');
      expect(json['yearGroupedEpisodes'], isTrue);
      expect(json['playlists'], ['p1', 'p2']);
    });

    test('parses from JSON string', () {
      final jsonString = jsonEncode({
        'version': 1,
        'id': 'test',
        'feedUrls': ['pattern'],
        'playlists': ['main'],
      });
      final meta = PatternMeta.parseJson(jsonString);
      expect(meta.id, 'test');
    });

    test('roundtrips through JSON', () {
      final original = PatternMeta(
        version: 2,
        id: 'test',
        podcastGuid: 'guid-1',
        feedUrls: ['p1', 'p2'],
        yearGroupedEpisodes: true,
        playlists: ['a', 'b'],
      );
      final restored = PatternMeta.fromJson(original.toJson());
      expect(restored.version, original.version);
      expect(restored.id, original.id);
      expect(restored.podcastGuid, original.podcastGuid);
      expect(restored.feedUrls, original.feedUrls);
      expect(restored.yearGroupedEpisodes, original.yearGroupedEpisodes);
      expect(restored.playlists, original.playlists);
    });
  });
}
