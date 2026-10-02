import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

const _ids = (
  podcastId: 'p1',
  feedUrl: 'https://example.com/feed.xml',
  episodeId: 'e1',
  podcastTitle: 'Pod 1',
  episodeTitle: 'Ep 1',
);

void main() {
  group('ListenSessionTracker', () {
    late ListenSessionTracker tracker;

    setUp(() => tracker = ListenSessionTracker());

    test('is closed initially and close returns null', () {
      check(tracker.isOpen).isFalse();
      check(
        tracker.close(
          positionSec: 10,
          durationSec: 100,
          reason: ListenEndReason.pause,
        ),
      ).isNull();
    });

    test('open then close emits a session with captured ids and speed', () {
      tracker.open(ids: _ids, positionSec: 30, speed: 1.5);
      check(tracker.isOpen).isTrue();
      check(tracker.openIds).equals(_ids);

      final session = tracker.close(
        positionSec: 90,
        durationSec: 1800,
        reason: ListenEndReason.pause,
      );

      check(tracker.isOpen).isFalse();
      check(tracker.openIds).isNull();
      check(session).isNotNull();
      check(session!.params).deepEquals({
        'podcast_id': 'p1',
        'feed_key': '7a775db75c1d6d17',
        'episode_id': 'e1',
        'podcast_title': 'Pod 1',
        'episode_title': 'Ep 1',
        'start_sec': 30,
        'end_sec': 90,
        'duration_sec': 1800,
        'speed': 1.5,
        'end_reason': 'pause',
      });
    });

    test('open while already open keeps the original segment', () {
      tracker.open(ids: _ids, positionSec: 30, speed: 1.0);
      tracker.open(ids: _ids, positionSec: 50, speed: 2.0);

      final session = tracker.close(
        positionSec: 90,
        durationSec: 100,
        reason: ListenEndReason.stop,
      );

      check(session!.startSec).equals(30);
      check(session.speed).equals(1.0);
    });

    test('drops segments shorter than the minimum', () {
      tracker.open(ids: _ids, positionSec: 30, speed: 1.0);

      final session = tracker.close(
        positionSec: 31,
        durationSec: 100,
        reason: ListenEndReason.seek,
      );

      check(session).isNull();
      check(tracker.isOpen).isFalse();
    });

    test('keeps a segment exactly at the minimum', () {
      tracker.open(ids: _ids, positionSec: 30, speed: 1.0);

      final session = tracker.close(
        positionSec: 32,
        durationSec: 100,
        reason: ListenEndReason.seek,
      );

      check(session).isNotNull();
    });

    test('drops segments whose end precedes the start', () {
      tracker.open(ids: _ids, positionSec: 30, speed: 1.0);

      final session = tracker.close(
        positionSec: 0,
        durationSec: 100,
        reason: ListenEndReason.switchEpisode,
      );

      check(session).isNull();
    });

    test('reports each end reason', () {
      for (final reason in ListenEndReason.values) {
        tracker.open(ids: _ids, positionSec: 0, speed: 1.0);
        final session = tracker.close(
          positionSec: 10,
          durationSec: 100,
          reason: reason,
        );
        check(session!.endReason).equals(reason);
      }
    });

    test('a closed tracker can open a new segment', () {
      tracker.open(ids: _ids, positionSec: 0, speed: 1.0);
      tracker.close(
        positionSec: 10,
        durationSec: 100,
        reason: ListenEndReason.speedChange,
      );
      tracker.open(ids: _ids, positionSec: 10, speed: 2.0);

      final session = tracker.close(
        positionSec: 40,
        durationSec: 100,
        reason: ListenEndReason.complete,
      );

      check(session!.startSec).equals(10);
      check(session.speed).equals(2.0);
    });
  });
}
