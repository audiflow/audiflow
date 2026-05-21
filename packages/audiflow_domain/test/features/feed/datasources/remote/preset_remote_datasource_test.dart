import 'dart:convert';

import 'package:audiflow_domain/src/features/feed/datasources/remote/preset_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const baseUrl = 'https://storage.example.com/config';

  group('PresetRemoteDatasource', () {
    late Map<String, String> fakeResponses;
    late PresetRemoteDatasource datasource;

    setUp(() {
      fakeResponses = {};
      datasource = PresetRemoteDatasource(
        baseUrl: baseUrl,
        httpGet: (Uri url) async {
          final body = fakeResponses[url.toString()];
          if (body == null) {
            throw Exception('Not found: $url');
          }
          return body;
        },
      );
    });

    test('fetchRootMeta returns parsed root meta', () async {
      fakeResponses['$baseUrl/meta.json'] = jsonEncode({
        'dataVersion': 1,
        'schemaVersion': 1,
        'presets': [
          {
            'id': 'test',
            'dataVersion': 1,
            'displayName': 'Test',
            'feedUrlHint': 'test.com',
            'playlistCount': 1,
          },
        ],
      });

      final meta = await datasource.fetchRootMeta();
      expect(meta.presets, hasLength(1));
      expect(meta.presets[0].id, 'test');
    });

    test('fetchPresetMeta returns parsed pattern meta', () async {
      fakeResponses['$baseUrl/coten_radio/meta.json'] = jsonEncode({
        'dataVersion': 1,
        'id': 'coten_radio',
        'feedUrls': ['anchor.fm'],
        'playlists': ['regular'],
      });

      final meta = await datasource.fetchPresetMeta('coten_radio');
      expect(meta.id, 'coten_radio');
    });

    test('fetchPlaylist returns parsed playlist '
        'definition', () async {
      final url =
          '$baseUrl/coten_radio'
          '/playlists/regular.json';
      fakeResponses[url] = jsonEncode({
        'id': 'regular',
        'displayName': 'Regular',
        'grouping': {'by': 'seasonNumber'},
        'priority': 0,
      });

      final playlist = await datasource.fetchPlaylist('coten_radio', 'regular');
      expect(playlist.id, 'regular');
      expect(playlist.grouping.by, 'seasonNumber');
    });
  });
}
