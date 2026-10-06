import 'package:audiflow_domain/src/features/download/services/download_path.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('buildDownloadPath', () {
    String build({
      String title = 'Episode',
      String url = 'https://example.com/audio/episode.mp3',
    }) => buildDownloadPath(
      downloadsDir: '/docs/downloads',
      episodeId: 42,
      episodeTitle: title,
      url: url,
    );

    test('joins downloads dir, episode id, title, and extension', () {
      check(
        build(title: 'Hello World'),
      ).equals(p.join('/docs/downloads', '42_Hello_World.mp3'));
    });

    test('strips filesystem-invalid characters', () {
      final name = p.basename(build(title: 'a<b>c:d"e/f\\g|h?i*j'));

      check(name).equals('42_abcdefghij.mp3');
    });

    test('strips URI-reserved # and % that break file:// playback', () {
      final name = p.basename(build(title: 'Episode #42: 100% Pure'));

      check(name).equals('42_Episode_42_100_Pure.mp3');
    });

    test('collapses whitespace runs into a single underscore', () {
      final name = p.basename(build(title: 'a  b\t\nc'));

      check(name).equals('42_a_b_c.mp3');
    });

    test('truncates the sanitized title to 50 characters', () {
      final name = p.basename(build(title: 'x' * 80));

      check(name).equals('42_${'x' * 50}.mp3');
    });

    test('takes the extension from the URL path, ignoring the query', () {
      final name = p.basename(
        build(url: 'https://example.com/a/episode.m4a?token=abc#frag'),
      );

      check(name).equals('42_Episode.m4a');
    });

    test('falls back to .mp3 when the URL path has no extension', () {
      check(
        p.basename(build(url: 'https://example.com/stream')),
      ).equals('42_Episode.mp3');
    });

    test('falls back to .mp3 when the URL cannot be parsed', () {
      check(p.basename(build(url: 'http://[bad'))).equals('42_Episode.mp3');
    });
  });
}
