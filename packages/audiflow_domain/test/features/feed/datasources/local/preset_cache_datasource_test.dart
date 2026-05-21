import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/feed/datasources/local/preset_cache_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late PresetCacheDatasource datasource;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sp_cache_test_');
    datasource = PresetCacheDatasource(cacheDir: tempDir.path);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('PresetCacheDatasource', () {
    group('versions', () {
      test('returns empty map when no versions cached', () async {
        final versions = await datasource.readVersions();
        expect(versions, isEmpty);
      });

      test('writes and reads versions', () async {
        await datasource.writeVersions({'coten_radio': 3, 'news': 1});
        final versions = await datasource.readVersions();
        expect(versions['coten_radio'], 3);
        expect(versions['news'], 1);
      });
    });

    group('root meta', () {
      test('returns null when no root meta cached', () async {
        final meta = await datasource.readRootMeta();
        expect(meta, isNull);
      });

      test('writes and reads root meta', () async {
        final meta = RootMeta(
          dataVersion: 1,
          schemaVersion: 1,
          presets: [
            PresetSummary(
              id: 'test',
              dataVersion: 1,
              displayName: 'Test',
              feedUrlHint: 'test.com',
              playlistCount: 1,
            ),
          ],
        );
        await datasource.writeRootMeta(meta);
        final restored = await datasource.readRootMeta();
        expect(restored, isNotNull);
        expect(restored!.presets, hasLength(1));
        expect(restored.presets[0].id, 'test');
      });
    });

    group('pattern meta', () {
      test('returns null when not cached', () async {
        final meta = await datasource.readPresetMeta('missing');
        expect(meta, isNull);
      });

      test('writes and reads pattern meta', () async {
        final meta = PresetMeta(
          dataVersion: 1,
          id: 'coten_radio',
          feedUrls: ['anchor.fm'],
          playlists: ['regular'],
        );
        await datasource.writePresetMeta('coten_radio', meta);
        final restored = await datasource.readPresetMeta('coten_radio');
        expect(restored, isNotNull);
        expect(restored!.id, 'coten_radio');
      });
    });

    group('playlist', () {
      test('returns null when not cached', () async {
        final playlist = await datasource.readPlaylist('p', 'missing');
        expect(playlist, isNull);
      });

      test('writes and reads playlist', () async {
        final definition = SmartPlaylistDefinition(
          id: 'regular',
          displayName: 'Regular',
          grouping: GroupingConfig(by: 'seasonNumber'),
          priority: 0,
        );
        await datasource.writePlaylist('coten_radio', 'regular', definition);
        final restored = await datasource.readPlaylist(
          'coten_radio',
          'regular',
        );
        expect(restored, isNotNull);
        expect(restored!.id, 'regular');
        expect(restored.grouping.by, 'seasonNumber');
      });
    });

    group('evictPreset', () {
      test('removes pattern directory and version entry', () async {
        final meta = PresetMeta(
          dataVersion: 1,
          id: 'old',
          feedUrls: [],
          playlists: ['main'],
        );
        await datasource.writePresetMeta('old', meta);
        await datasource.writeVersions({'old': 1, 'keep': 2});

        await datasource.evictPreset('old');

        final restored = await datasource.readPresetMeta('old');
        expect(restored, isNull);

        final versions = await datasource.readVersions();
        expect(versions.containsKey('old'), isFalse);
        expect(versions['keep'], 2);
      });
    });
  });
}
