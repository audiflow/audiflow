import 'dart:io';

import 'package:audiflow_domain/src/features/download/services/download_path.dart';
import 'package:audiflow_domain/src/features/download/services/episode_download_files.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory downloadsDir;

  setUp(() async {
    downloadsDir = await Directory.systemTemp.createTemp('episode_files_');
  });

  tearDown(() => downloadsDir.delete(recursive: true));

  File write(String name) =>
      File(p.join(downloadsDir.path, name))..writeAsStringSync('audio');

  test('removes a partial file the task never recorded a path for', () async {
    // The queue names the file this way before any byte arrives, but saves
    // the path on the task only once the download completes.
    final partial = File(
      buildDownloadPath(
        downloadsDir: downloadsDir.path,
        episodeId: 12,
        episodeTitle: 'Old title',
        url: 'https://example.com/ep.m4a',
      ),
    )..writeAsStringSync('partial');

    await deleteEpisodeDownloadFiles(
      downloadsDir: downloadsDir.path,
      episodeId: 12,
    );

    check(partial.existsSync()).isFalse();
  });

  test('leaves files of other episodes alone', () async {
    final other = write('123_Other.mp3');
    final another = write('1_Another.mp3');
    final own = write('12_Own.mp3');

    await deleteEpisodeDownloadFiles(
      downloadsDir: downloadsDir.path,
      episodeId: 12,
    );

    check(own.existsSync()).isFalse();
    check(other.existsSync()).isTrue();
    check(another.existsSync()).isTrue();
  });

  test('resolves a stale stored path against the current directory', () async {
    final legacy = write('legacy-name.mp3');

    await deleteEpisodeDownloadFiles(
      downloadsDir: downloadsDir.path,
      episodeId: 12,
      storedPath: '/old-container/Documents/downloads/legacy-name.mp3',
    );

    check(legacy.existsSync()).isFalse();
  });

  test('does nothing when the downloads directory does not exist', () async {
    await deleteEpisodeDownloadFiles(
      downloadsDir: p.join(downloadsDir.path, 'missing'),
      episodeId: 12,
      storedPath: '/somewhere/12_Gone.mp3',
    );
  });
}
