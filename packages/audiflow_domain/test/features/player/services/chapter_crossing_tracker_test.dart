import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

EpisodeChapter _chapter(int index, int startSeconds) => EpisodeChapter()
  ..id = index
  ..episodeId = 1
  ..sortOrder = index
  ..title = 'Chapter $index'
  ..startMs = startSeconds * 1000;

List<EpisodeChapter> _chapters() => [
  _chapter(0, 0),
  _chapter(1, 60),
  _chapter(2, 120),
];

CurrentChapter? _at(List<EpisodeChapter> chapters, int seconds) {
  final index = chapterIndexAt(chapters, Duration(seconds: seconds));
  if (index == null) return null;
  return CurrentChapter(index: index, chapter: chapters[index]);
}

void main() {
  final t0 = DateTime(2026);

  late ChapterCrossingTracker tracker;
  late List<EpisodeChapter> chapters;

  SleepTimerPlayerEvent? observeAt(int seconds, {DateTime? now}) =>
      tracker.observe(
        chapters: chapters,
        current: _at(chapters, seconds),
        now: now ?? t0,
      );

  setUp(() {
    tracker = ChapterCrossingTracker();
    chapters = _chapters();
  });

  group('natural playback', () {
    test('crossing into the next chapter is a chapter change', () {
      check(observeAt(30)).isNull();
      check(observeAt(59)).isNull();
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });

    test('moving backward without a seek only re-baselines', () {
      check(observeAt(90)).isNull();
      check(observeAt(30)).isNull();
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });

    test('leaving the lead-in is not the end of a chapter', () {
      chapters = [_chapter(0, 10), _chapter(1, 60)];
      check(observeAt(5)).isNull();
      check(observeAt(10)).isNull();
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });
  });

  group('chapter list changes', () {
    test('the first list is a baseline, not a crossing', () {
      check(tracker.observe(chapters: null, current: null, now: t0)).isNull();
      check(observeAt(90)).isNull();
    });

    test('a replaced list re-baselines even when the index moves', () {
      chapters = [_chapter(0, 0), _chapter(1, 120)];
      check(observeAt(90)).isNull();
      chapters = _chapters();
      check(observeAt(90)).isNull();
      check(observeAt(120)).isA<ChapterChangedEvent>();
    });
  });

  group('seeks', () {
    test('a seek forward out of the chapter leaves it', () {
      check(observeAt(30)).isNull();
      check(
        tracker.seekStarted(1, const Duration(seconds: 60), now: t0),
      ).isA<SeekedOutOfChapterEvent>();
    });

    test('a seek backward out of the chapter leaves it', () {
      check(observeAt(90)).isNull();
      check(
        tracker.seekStarted(1, const Duration(seconds: 30), now: t0),
      ).isA<SeekedOutOfChapterEvent>();
    });

    test('a seek from the lead-in into the first chapter stays', () {
      chapters = [_chapter(0, 10), _chapter(1, 60)];
      check(observeAt(5)).isNull();
      check(
        tracker.seekStarted(1, const Duration(seconds: 20), now: t0),
      ).isNull();
      tracker.seekCompleted(1);
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });

    test('a seek from the lead-in past the first chapter leaves it', () {
      chapters = [_chapter(0, 10), _chapter(1, 60)];
      check(observeAt(5)).isNull();
      check(
        tracker.seekStarted(1, const Duration(seconds: 70), now: t0),
      ).isA<SeekedOutOfChapterEvent>();
    });

    test('a resume after the source read zero does not leave', () {
      // The baseline came from the saved position; the loaded source then
      // reports zero before the player seeks back to that position.
      check(observeAt(90)).isNull();
      check(observeAt(0)).isNull();
      check(
        tracker.seekStarted(
          1,
          const Duration(seconds: 90),
          now: t0,
          automatic: true,
        ),
      ).isNull();
      tracker.seekCompleted(1);
      check(observeAt(120)).isA<ChapterChangedEvent>();
    });

    test('a seek within the chapter changes nothing', () {
      check(observeAt(30)).isNull();
      check(
        tracker.seekStarted(1, const Duration(seconds: 50), now: t0),
      ).isNull();
      tracker.seekCompleted(1);
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });

    test('a seek within the chapter still ignores the position it left', () {
      // Resume: the baseline comes from the saved position, while the
      // freshly loaded source reports zero until the seek lands.
      check(observeAt(90)).isNull();
      tracker.seekStarted(1, const Duration(seconds: 90), now: t0);
      check(observeAt(0)).isNull();
      check(observeAt(90)).isNull();
      tracker.seekCompleted(1);
      check(observeAt(120)).isA<ChapterChangedEvent>();
    });

    test('positions before the jump do not look like crossings', () {
      check(observeAt(90)).isNull();
      tracker.seekStarted(1, const Duration(seconds: 30), now: t0);
      // A stale position from chapter 1 is "forward" of the target.
      check(observeAt(90)).isNull();
      check(observeAt(30)).isNull();
      tracker.seekCompleted(1);
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });

    test('the settle window ends without a completion', () {
      check(observeAt(90)).isNull();
      tracker.seekStarted(1, const Duration(seconds: 30), now: t0);
      // Inside the window a stale position forward of the target is ignored.
      check(observeAt(90, now: t0.add(const Duration(seconds: 1)))).isNull();
      check(observeAt(30, now: t0.add(const Duration(seconds: 2)))).isNull();
      final later = t0.add(ChapterCrossingTracker.seekSettleWindow);
      check(observeAt(60, now: later)).isA<ChapterChangedEvent>();
    });

    test('a failed seek returns the baseline to the chapter it left', () {
      check(observeAt(30)).isNull();
      tracker.seekStarted(1, const Duration(seconds: 130), now: t0);
      tracker.seekFailed(1, const Duration(seconds: 30), now: t0);
      // Playback never left chapter 0, so its end still fires.
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });

    test('a failed seek re-baselines against a reloaded list', () {
      check(observeAt(130)).isNull();
      tracker.seekStarted(1, const Duration(seconds: 10), now: t0);
      // The list is replaced while the seek runs: 130s is now chapter 0.
      chapters = [_chapter(0, 0), _chapter(1, 200)];
      check(observeAt(130)).isNull();
      tracker.seekFailed(1, const Duration(seconds: 130), now: t0);
      check(observeAt(200)).isA<ChapterChangedEvent>();
    });

    test('overlapping seeks settle only after the last report', () {
      check(observeAt(30)).isNull();
      tracker.seekStarted(1, const Duration(seconds: 70), now: t0);
      tracker.seekStarted(2, const Duration(seconds: 130), now: t0);
      tracker.seekFailed(1, const Duration(seconds: 30), now: t0);
      // The second seek is still moving: positions on the way are ignored
      // and its target stays the baseline.
      check(observeAt(70)).isNull();
      check(observeAt(130)).isNull();
      tracker.seekCompleted(2);
      check(observeAt(30)).isNull();
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });

    test('a late report for an expired seek keeps a newer window', () {
      check(observeAt(90)).isNull();
      tracker.seekStarted(1, const Duration(seconds: 130), now: t0);
      final later = t0.add(ChapterCrossingTracker.seekSettleWindow);
      check(observeAt(130, now: later)).isNull();
      tracker.seekStarted(2, const Duration(seconds: 30), now: later);
      tracker.seekCompleted(1);
      // A position from before the second jump is still attributed to it.
      final soon = later.add(const Duration(seconds: 1));
      check(observeAt(130, now: soon)).isNull();
      check(observeAt(30, now: soon)).isNull();
      tracker.seekCompleted(2);
      check(observeAt(60, now: soon)).isA<ChapterChangedEvent>();
    });

    test('an automatic rewind into the previous chapter stays', () {
      check(observeAt(62)).isNull();
      check(
        tracker.seekStarted(
          1,
          const Duration(seconds: 57),
          now: t0,
          automatic: true,
        ),
      ).isNull();
      tracker.seekCompleted(1);
      // Playing back into the chapter the listener was in ends nothing.
      check(observeAt(57)).isNull();
      check(observeAt(60)).isNull();
      check(observeAt(120)).isA<ChapterChangedEvent>();
    });

    test('a seek after an automatic rewind compares with the chapter', () {
      check(observeAt(62)).isNull();
      tracker.seekStarted(
        1,
        const Duration(seconds: 57),
        now: t0,
        automatic: true,
      );
      tracker.seekCompleted(1);
      check(observeAt(57)).isNull();
      // Leaving chapter 1 for chapter 0 on request still leaves it.
      check(
        tracker.seekStarted(2, const Duration(seconds: 20), now: t0),
      ).isA<SeekedOutOfChapterEvent>();
    });

    test('without chapters a seek yields nothing', () {
      chapters = const [];
      check(
        tracker.observe(chapters: chapters, current: null, now: t0),
      ).isNull();
      check(
        tracker.seekStarted(1, const Duration(seconds: 60), now: t0),
      ).isNull();
    });
  });
}
