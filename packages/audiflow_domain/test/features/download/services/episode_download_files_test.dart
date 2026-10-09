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

  test('removes the files of many episodes in one sweep', () async {
    final first = write('12_First.mp3');
    final second = write('34_Second.mp3');
    final legacy = write('legacy-name.mp3');
    final other = write('56_Other.mp3');
    final unnumbered = write('x12_Other.mp3');

    final failed = await deleteEpisodesDownloadFiles(
      downloadsDir: downloadsDir.path,
      storedPaths: {12: null, 34: '/old/downloads/legacy-name.mp3'},
    );

    check(failed).isEmpty();
    check(first.existsSync()).isFalse();
    check(second.existsSync()).isFalse();
    check(legacy.existsSync()).isFalse();
    check(other.existsSync()).isTrue();
    check(unnumbered.existsSync()).isTrue();
  });

  test('reports the episodes whose files failed to delete', () async {
    final first = write('12_First.mp3');
    final second = write('34_Second.mp3');
    // A read-only directory refuses every delete in it.
    Process.runSync('chmod', ['555', downloadsDir.path]);
    addTearDown(() => Process.runSync('chmod', ['755', downloadsDir.path]));

    final failed = await deleteEpisodesDownloadFiles(
      downloadsDir: downloadsDir.path,
      storedPaths: {12: null, 34: null},
    );

    check(failed).deepEquals({12, 34});
    check(first.existsSync()).isTrue();
    check(second.existsSync()).isTrue();
  }, testOn: 'mac-os || linux');

  test('does nothing when the downloads directory does not exist', () async {
    await deleteEpisodeDownloadFiles(
      downloadsDir: p.join(downloadsDir.path, 'missing'),
      episodeId: 12,
      storedPath: '/somewhere/12_Gone.mp3',
    );
  });
}
