import 'dart:convert';
import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/feed/datasources/local/smart_playlist_cache_datasource.dart';
import 'package:audiflow_domain/src/features/feed/datasources/remote/smart_playlist_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late Map<String, String> fakeResponses;
  late SmartPlaylistCacheDatasource cache;
  late SmartPlaylistRemoteDatasource remote;
  late SmartPlaylistConfigRepositoryImpl repo;

  const baseUrl = 'https://storage.example.com/config';

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sp_repo_');
    fakeResponses = {};
    cache = SmartPlaylistCacheDatasource(cacheDir: tempDir.path);
    remote = SmartPlaylistRemoteDatasource(
      baseUrl: baseUrl,
      httpGet: (Uri url) async {
        final body = fakeResponses[url.toString()];
        if (body == null) {
          throw Exception('Not found: $url');
        }
        return body;
      },
    );
    repo = SmartPlaylistConfigRepositoryImpl(remote: remote, cache: cache);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('SmartPlaylistConfigRepository', () {
    test('fetchRootMeta returns root meta and caches it', () async {
      fakeResponses['$baseUrl/meta.json'] = jsonEncode({
        'dataVersion': 1,
        'schemaVersion': 1,
        'patterns': [
          {
            'id': 'test',
            'dataVersion': 1,
            'displayName': 'Test',
            'feedUrlHint': 'test.com',
            'playlistCount': 1,
          },
        ],
      });

      final meta = await repo.fetchRootMeta();
      expect(meta.patterns, hasLength(1));

      final cached = await cache.readRootMeta();
      expect(cached, isNotNull);
    });

    test('fetchRootMeta falls back to cache on network error', () async {
      await cache.writeRootMeta(
        RootMeta(
          dataVersion: 1,
          schemaVersion: 1,
          patterns: [
            PatternSummary(
              id: 'cached',
              dataVersion: 1,
              displayName: 'Cached',
              feedUrlHint: 'cached.com',
              playlistCount: 1,
            ),
          ],
        ),
      );

      final meta = await repo.fetchRootMeta();
      expect(meta.patterns[0].id, 'cached');
    });

    test('fetchRootMeta returns empty when no cache and '
        'network fails', () async {
      final meta = await repo.fetchRootMeta();
      expect(meta.dataVersion, 1);
      expect(meta.patterns, isEmpty);
    });

    test('reconcileCache evicts stale patterns', () async {
      await cache.writeVersions({'old_pattern': 1, 'current': 2});
      await cache.writePatternMeta(
        'old_pattern',
        PatternMeta(
          dataVersion: 1,
          id: 'old_pattern',
          feedUrls: [],
          playlists: ['main'],
        ),
      );

      await repo.reconcileCache([
        PatternSummary(
          id: 'current',
          dataVersion: 2,
          displayName: 'Current',
          feedUrlHint: 'current.com',
          playlistCount: 1,
        ),
      ]);

      final meta = await cache.readPatternMeta('old_pattern');
      expect(meta, isNull);
    });

    test('reconcileCache evicts version-bumped patterns', () async {
      await cache.writeVersions({'test': 1});
      await cache.writePatternMeta(
        'test',
        PatternMeta(
          dataVersion: 1,
          id: 'test',
          feedUrls: [],
          playlists: ['main'],
        ),
      );

      await repo.reconcileCache([
        PatternSummary(
          id: 'test',
          dataVersion: 2,
          displayName: 'Test',
          feedUrlHint: 'test.com',
          playlistCount: 1,
        ),
      ]);

      final meta = await cache.readPatternMeta('test');
      expect(meta, isNull);
    });

    test('getConfig fetches and caches when not cached', () async {
      fakeResponses['$baseUrl/test/meta.json'] = jsonEncode({
        'dataVersion': 1,
        'id': 'test',
        'feedUrls': ['test.com'],
        'playlists': ['main'],
      });
      fakeResponses['$baseUrl/test/playlists/main.json'] = jsonEncode({
        'id': 'main',
        'displayName': 'Main',
        'grouping': {'by': 'seasonNumber'},
        'priority': 0,
      });

      final summary = PatternSummary(
        id: 'test',
        dataVersion: 1,
        displayName: 'Test',
        feedUrlHint: 'test.com',
        playlistCount: 1,
      );

      final config = await repo.getConfig(summary);
      expect(config.id, 'test');
      expect(config.playlists, hasLength(1));
      expect(config.playlists[0].id, 'main');

      final cachedMeta = await cache.readPatternMeta('test');
      expect(cachedMeta, isNotNull);
      final cachedPlaylist = await cache.readPlaylist('test', 'main');
      expect(cachedPlaylist, isNotNull);
    });

    test('getConfig uses cache when version matches', () async {
      await cache.writeVersions({'test': 1});
      await cache.writePatternMeta(
        'test',
        PatternMeta(
          dataVersion: 1,
          id: 'test',
          feedUrls: ['test.com'],
          playlists: ['main'],
        ),
      );
      await cache.writePlaylist(
        'test',
        'main',
        SmartPlaylistDefinition(
          id: 'main',
          displayName: 'Main Cached',
          grouping: GroupingConfig(by: 'seasonNumber'),
          priority: 0,
        ),
      );

      final summary = PatternSummary(
        id: 'test',
        dataVersion: 1,
        displayName: 'Test',
        feedUrlHint: 'test.com',
        playlistCount: 1,
      );

      final config = await repo.getConfig(summary);
      expect(config.playlists[0].displayName, 'Main Cached');
    });

    test('getConfig deduplicates concurrent requests', () async {
      var fetchCount = 0;
      fakeResponses['$baseUrl/test/meta.json'] = jsonEncode({
        'dataVersion': 1,
        'id': 'test',
        'feedUrls': ['test.com'],
        'playlists': ['main'],
      });
      fakeResponses['$baseUrl/test/playlists/main.json'] = jsonEncode({
        'id': 'main',
        'displayName': 'Main',
        'grouping': {'by': 'seasonNumber'},
        'priority': 0,
      });

      // Override remote with counting wrapper
      final countingRemote = SmartPlaylistRemoteDatasource(
        baseUrl: baseUrl,
        httpGet: (Uri url) async {
          fetchCount++;
          final body = fakeResponses[url.toString()];
          if (body == null) {
            throw Exception('Not found: $url');
          }
          return body;
        },
      );
      final countingRepo = SmartPlaylistConfigRepositoryImpl(
        remote: countingRemote,
        cache: cache,
      );

      final summary = PatternSummary(
        id: 'test',
        dataVersion: 1,
        displayName: 'Test',
        feedUrlHint: 'test.com',
        playlistCount: 1,
      );

      // Fire two concurrent requests
      final results = await Future.wait([
        countingRepo.getConfig(summary),
        countingRepo.getConfig(summary),
      ]);

      expect(results[0].id, 'test');
      expect(results[1].id, 'test');
      // Second call should reuse the in-flight future,
      // so only 2 HTTP calls (meta + playlist), not 4.
      expect(fetchCount, 2);
    });

    test('findMatchingPattern returns matching summary', () {
      repo.setPatternSummaries([
        PatternSummary(
          id: 'coten',
          dataVersion: 1,
          displayName: 'Coten',
          feedUrlHint: 'anchor.fm/s/8c2088c',
          playlistCount: 3,
        ),
        PatternSummary(
          id: 'other',
          dataVersion: 1,
          displayName: 'Other',
          feedUrlHint: 'other.com',
          playlistCount: 1,
        ),
      ]);

      final match = repo.findMatchingPattern(
        null,
        'https://anchor.fm/s/8c2088c/podcast/rss',
      );
      expect(match, isNotNull);
      expect(match!.id, 'coten');
    });

    test('findMatchingPattern returns null when no match', () {
      repo.setPatternSummaries([
        PatternSummary(
          id: 'test',
          dataVersion: 1,
          displayName: 'Test',
          feedUrlHint: 'test.com',
          playlistCount: 1,
        ),
      ]);

      final match = repo.findMatchingPattern(
        null,
        'https://unrelated.example.com/feed',
      );
      expect(match, isNull);
    });
  });
}
