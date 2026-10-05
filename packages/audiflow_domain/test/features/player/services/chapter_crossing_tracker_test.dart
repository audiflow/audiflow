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
    test('a seek out of the chapter retargets', () {
      check(observeAt(30)).isNull();
      check(
        tracker.seekStarted(const Duration(seconds: 60), now: t0),
      ).isA<SeekedPastChapterEvent>();
    });

    test('a seek within the chapter changes nothing', () {
      check(observeAt(30)).isNull();
      check(tracker.seekStarted(const Duration(seconds: 50), now: t0)).isNull();
      tracker.seekCompleted();
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });

    test('a seek within the chapter still ignores the position it left', () {
      // Resume: the baseline comes from the saved position, while the
      // freshly loaded source reports zero until the seek lands.
      check(observeAt(90)).isNull();
      tracker.seekStarted(const Duration(seconds: 90), now: t0);
      check(observeAt(0)).isNull();
      check(observeAt(90)).isNull();
      tracker.seekCompleted();
      check(observeAt(120)).isA<ChapterChangedEvent>();
    });

    test('positions before the jump do not look like crossings', () {
      check(observeAt(90)).isNull();
      tracker.seekStarted(const Duration(seconds: 30), now: t0);
      // A stale position from chapter 1 is "forward" of the target.
      check(observeAt(90)).isNull();
      check(observeAt(30)).isNull();
      tracker.seekCompleted();
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });

    test('the settle window ends without a completion', () {
      check(observeAt(90)).isNull();
      tracker.seekStarted(const Duration(seconds: 30), now: t0);
      // Inside the window a stale position forward of the target is ignored.
      check(observeAt(90, now: t0.add(const Duration(seconds: 1)))).isNull();
      check(observeAt(30, now: t0.add(const Duration(seconds: 2)))).isNull();
      final later = t0.add(ChapterCrossingTracker.seekSettleWindow);
      check(observeAt(60, now: later)).isA<ChapterChangedEvent>();
    });

    test('a failed seek returns the baseline to the chapter it left', () {
      check(observeAt(30)).isNull();
      tracker.seekStarted(const Duration(seconds: 130), now: t0);
      tracker.seekFailed();
      // Playback never left chapter 0, so its end still fires.
      check(observeAt(60)).isA<ChapterChangedEvent>();
    });

    test('without chapters a seek yields nothing', () {
      chapters = const [];
      check(
        tracker.observe(chapters: chapters, current: null, now: t0),
      ).isNull();
      check(tracker.seekStarted(const Duration(seconds: 60), now: t0)).isNull();
    });
  });
}
