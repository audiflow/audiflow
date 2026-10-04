import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

EpisodeChapter _chapter(int id, int startMs, [String? title]) =>
    EpisodeChapter()
      ..id = id
      ..episodeId = 1
      ..sortOrder = id
      ..title = title ?? 'Chapter $id'
      ..startMs = startMs;

void main() {
  group('chapterIndexAt', () {
    final chapters = [_chapter(1, 0), _chapter(2, 60000), _chapter(3, 120000)];

    test('returns null when there are no chapters', () {
      check(chapterIndexAt(const [], Duration.zero)).isNull();
    });

    test('includes the start and excludes the next start', () {
      check(chapterIndexAt(chapters, Duration.zero)).equals(0);
      check(
        chapterIndexAt(chapters, const Duration(milliseconds: 59999)),
      ).equals(0);
      check(chapterIndexAt(chapters, const Duration(minutes: 1))).equals(1);
    });

    test('keeps the last chapter until the end', () {
      check(chapterIndexAt(chapters, const Duration(hours: 5))).equals(2);
    });

    test('returns null before a late first chapter', () {
      final late = [_chapter(1, 30000), _chapter(2, 60000)];
      check(chapterIndexAt(late, const Duration(seconds: 10))).isNull();
      check(chapterIndexAt(late, const Duration(seconds: 30))).equals(0);
    });
  });

  group('CurrentChapter', () {
    test('number is one-based', () {
      check(CurrentChapter(index: 2, chapter: _chapter(3, 0)).number).equals(3);
    });

    test('equal for distinct instances of the same chapter', () {
      final a = CurrentChapter(index: 0, chapter: _chapter(1, 0, 'Intro'));
      final b = CurrentChapter(index: 0, chapter: _chapter(1, 0, 'Intro'));
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('differs when the chapter changes', () {
      final a = CurrentChapter(index: 0, chapter: _chapter(1, 0));
      check(a).not(
        (it) =>
            it.equals(CurrentChapter(index: 1, chapter: _chapter(2, 60000))),
      );
      check(a).not(
        (it) => it.equals(
          CurrentChapter(index: 0, chapter: _chapter(1, 0, 'Renamed')),
        ),
      );
    });
  });
}
