import 'package:audio_service/audio_service.dart';
import 'package:audiflow_app/features/player/services/session_queue_publisher.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

const _delay = Duration(milliseconds: 500);

Episode _episode(int id) => Episode()
  ..id = id
  ..podcastId = 1
  ..guid = 'guid-$id'
  ..title = 'Episode $id'
  ..audioUrl = 'https://example.com/$id.mp3';

QueueItemWithEpisode _queued(int queueItemId) => QueueItemWithEpisode(
  queueItem: QueueItem()
    ..id = queueItemId
    ..episodeId = queueItemId
    ..position = queueItemId
    ..addedAt = DateTime(2026),
  episode: _episode(queueItemId),
  podcastTitle: 'Podcast',
);

NowPlayingInfo _nowPlaying(Episode episode) => NowPlayingInfo(
  episodeUrl: episode.audioUrl,
  episodeTitle: episode.title,
  podcastTitle: 'Podcast',
  episode: episode,
);

class _Harness {
  _Harness() {
    publisher = SessionQueuePublisher(
      readQueue: () => queue,
      readNowPlaying: () => nowPlaying,
      publish: (items, activeIndex) =>
          publishes.add((items: items, activeIndex: activeIndex)),
      playQueueItem: (id) async {
        queueItemPlays.add(id);
        return queueItemPlayable;
      },
      continueNowPlaying: (id) async {
        continues.add(id);
        return true;
      },
      logger: Logger(level: Level.off),
      delay: _delay,
    );
  }

  late final SessionQueuePublisher publisher;
  PlaybackQueue? queue = const PlaybackQueue();
  NowPlayingInfo? nowPlaying;
  bool queueItemPlayable = true;
  final publishes = <({List<MediaItem> items, int? activeIndex})>[];
  final queueItemPlays = <int>[];
  final continues = <int?>[];

  /// Reports a change and lets the batcher flush it.
  void flush(FakeAsync async) {
    publisher.markChanged();
    async.elapse(_delay);
  }
}

void main() {
  group('publishing', () {
    test('sends a burst of changes once', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_queued(1)]);

        h.publisher
          ..markChanged()
          ..markChanged()
          ..markChanged();
        async.elapse(_delay);

        check(h.publishes.length).equals(1);
      });
    });

    test('reads the state at flush, not at the change', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_queued(1)]);
        final latest = _queued(2);

        h.publisher.markChanged();
        h.queue = PlaybackQueue(adhocItems: [latest]);
        async.elapse(_delay);

        check(
          h.publishes.single.items.single.title,
        ).equals(latest.episode.title);
      });
    });

    test('marks the playing row and fills in row text', () {
      fakeAsync((async) {
        final episode = _episode(1);
        final queued = _queued(2);
        final h = _Harness()
          ..queue = PlaybackQueue(adhocItems: [queued])
          ..nowPlaying = _nowPlaying(episode);

        h.flush(async);

        final published = h.publishes.single;
        check(published.activeIndex).equals(0);
        check(published.items.first.title).equals(episode.title);
        check(published.items.last)
          ..has((i) => i.title, 'title').equals(queued.episode.title)
          ..has((i) => i.artist, 'artist').equals(queued.podcastTitle);
      });
    });

    test('does not send an unchanged list again', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_queued(1)]);

        h
          ..flush(async)
          ..flush(async);

        check(h.publishes.length).equals(1);
      });
    });

    test('sends a retitled row even with the same id', () {
      fakeAsync((async) {
        final queued = _queued(1);
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [queued]);
        h.flush(async);

        final retitled = _episode(1)..title = 'Renamed';
        h
          ..queue = PlaybackQueue(
            adhocItems: [queued.copyWith(episode: retitled)],
          )
          ..flush(async);

        check(h.publishes.length).equals(2);
        check(h.publishes.last.items.single.title).equals(retitled.title);
      });
    });

    test('sends the list again after forgetting it', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_queued(1)]);
        h.flush(async);

        h.publisher.forgetPublished();
        h.flush(async);

        check(h.publishes.length).equals(2);
      });
    });

    test('keeps the last list while the queue is unavailable', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_queued(1)]);
        h.flush(async);

        h
          ..queue = null
          ..flush(async);

        check(h.publishes.length).equals(1);
      });
    });
  });

  group('tap', () {
    test('plays an up-next row through its queue item', () {
      fakeAsync((async) {
        final queued = _queued(2);
        final h = _Harness()
          ..queue = PlaybackQueue(adhocItems: [queued])
          ..nowPlaying = _nowPlaying(_episode(1));
        h.flush(async);

        h.publisher.tap(1);
        async.flushMicrotasks();

        check(h.queueItemPlays).deepEquals([queued.queueItem.id]);
        check(h.continues).isEmpty();
      });
    });

    test('continues the episode for the playing row', () {
      fakeAsync((async) {
        final episode = _episode(1);
        final h = _Harness()
          ..queue = PlaybackQueue(adhocItems: [_queued(2)])
          ..nowPlaying = _nowPlaying(episode);
        h.flush(async);

        h.publisher.tap(0);
        async.flushMicrotasks();

        check(h.continues).deepEquals([episode.id]);
        check(h.queueItemPlays).isEmpty();
      });
    });

    test('ignores a row outside the published list', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_queued(1)]);
        h.flush(async);

        h.publisher
          ..tap(-1)
          ..tap(1);
        async.flushMicrotasks();

        check(h.queueItemPlays).isEmpty();
        check(h.continues).isEmpty();
      });
    });

    test('tolerates an item that has left the queue', () {
      fakeAsync((async) {
        final queued = _queued(1);
        final h = _Harness()
          ..queue = PlaybackQueue(adhocItems: [queued])
          ..queueItemPlayable = false;
        h.flush(async);

        h.publisher.tap(0);
        async.flushMicrotasks();

        check(h.queueItemPlays).deepEquals([queued.queueItem.id]);
      });
    });

    test('uses the list the head unit last received', () {
      fakeAsync((async) {
        final first = _queued(1);
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [first]);
        h.flush(async);

        // Changed but not yet flushed: the head unit still shows `first`.
        h
          ..queue = PlaybackQueue(adhocItems: [_queued(2)])
          ..publisher.markChanged();
        h.publisher.tap(0);
        async.flushMicrotasks();

        check(h.queueItemPlays).deepEquals([first.queueItem.id]);
        async.elapse(_delay);
      });
    });
  });
}
