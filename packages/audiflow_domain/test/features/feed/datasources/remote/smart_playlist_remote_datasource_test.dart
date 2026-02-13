import 'dart:convert';

import 'package:audiflow_domain/src/features/feed/datasources/remote/smart_playlist_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const baseUrl = 'https://storage.example.com/config';

  group('SmartPlaylistRemoteDatasource', () {
    late Map<String, String> fakeResponses;
    late SmartPlaylistRemoteDatasource datasource;

    setUp(() {
      fakeResponses = {};
      datasource = SmartPlaylistRemoteDatasource(
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
        'version': 1,
        'patterns': [
          {
            'id': 'test',
            'version': 1,
            'displayName': 'Test',
            'feedUrlHint': 'test.com',
            'playlistCount': 1,
          },
        ],
      });

      final meta = await datasource.fetchRootMeta();
      expect(meta.patterns, hasLength(1));
      expect(meta.patterns[0].id, 'test');
    });

    test('fetchPatternMeta returns parsed pattern meta', () async {
      fakeResponses['$baseUrl/coten_radio/meta.json'] = jsonEncode({
        'version': 1,
        'id': 'coten_radio',
        'feedUrlPatterns': [r'anchor\.fm'],
        'playlists': ['regular'],
      });

      final meta = await datasource.fetchPatternMeta('coten_radio');
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
        'resolverType': 'rss',
      });

      final playlist = await datasource.fetchPlaylist('coten_radio', 'regular');
      expect(playlist.id, 'regular');
      expect(playlist.resolverType, 'rss');
    });
  });
}
