import 'dart:async';

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

Uri _artUri(String url) => Uri.parse('content://art/${url.hashCode}');

QueueItemWithEpisode _withArt(int queueItemId) => _queued(
  queueItemId,
).copyWith(artworkUrl: 'https://example.com/$queueItemId');

class _Harness {
  _Harness() {
    publisher = SessionQueuePublisher(
      readQueue: () => queue,
      readNowPlaying: () => nowPlaying,
      readTitle: () => title,
      publish: (items, activeIndex, title) =>
          publishes.add((items: items, activeIndex: activeIndex, title: title)),
      playQueueItem: (id) async {
        queueItemPlays.add(id);
        return queueItemPlayable;
      },
      continueNowPlaying: (id) async {
        continues.add(id);
        return true;
      },
      resolveArtwork: (url) {
        artworkRequests.add(url);
        final completer = Completer<Uri?>();
        artworkCompleters.add((url: url, completer: completer));
        return completer.future;
      },
      logger: Logger(level: Level.off),
      delay: _delay,
    );
  }

  late final SessionQueuePublisher publisher;
  PlaybackQueue? queue = const PlaybackQueue();
  NowPlayingInfo? nowPlaying;
  String title = 'Up Next';
  bool queueItemPlayable = true;
  final publishes =
      <({List<MediaItem> items, int? activeIndex, String title})>[];
  final queueItemPlays = <int>[];
  final continues = <int?>[];
  final artworkRequests = <String>[];
  final artworkCompleters = <({String url, Completer<Uri?> completer})>[];

  /// Answers every open image request and lets the results land.
  void finishArtwork(FakeAsync async, {Uri? Function(String url)? answer}) {
    for (final (:url, :completer) in artworkCompleters) {
      completer.complete((answer ?? _artUri)(url));
    }
    artworkCompleters.clear();
    async.flushMicrotasks();
  }

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

    test('sends the title with the list, and a new title alone', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_queued(1)]);
        h.flush(async);
        check(h.publishes.single.title).equals(h.title);

        h
          ..title = '次に再生'
          ..flush(async);

        check(h.publishes.length).equals(2);
        check(h.publishes.last.title).equals(h.title);
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

  group('artwork', () {
    test('fetches nothing before a head unit browses', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_withArt(1)]);

        h.flush(async);

        check(h.artworkRequests).isEmpty();
        check(h.publishes.single.items.single.artUri).isNull();
      });
    });

    test('sends text first, then fills images in once', () {
      fakeAsync((async) {
        final queued = _withArt(1);
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [queued]);

        h.publisher.enableArtwork();
        async.elapse(_delay);

        check(h.publishes.single.items.single.artUri).isNull();
        check(h.artworkRequests).deepEquals([queued.artworkUrl!]);

        h.finishArtwork(async);

        check(h.publishes.length).equals(2);
        check(
          h.publishes.last.items.single.artUri,
        ).equals(_artUri(queued.artworkUrl!));
      });
    });

    test('does not publish or retry when images fail', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_withArt(1)]);

        h.publisher.enableArtwork();
        async.elapse(_delay);
        h.finishArtwork(async, answer: (_) => null);
        async.elapse(const Duration(minutes: 1));

        check(h.publishes.length).equals(1);
        check(h.artworkRequests.length).equals(1);
      });
    });

    test('keeps the list when an image request throws', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_withArt(1)]);

        h.publisher.enableArtwork();
        async.elapse(_delay);
        h.artworkCompleters.removeLast().completer.completeError(
          StateError('offline'),
        );
        async.flushMicrotasks();

        check(h.publishes.length).equals(1);
      });
    });

    test('does not fetch an image twice for overlapping changes', () {
      fakeAsync((async) {
        final queued = _withArt(1);
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [queued]);
        h.publisher.enableArtwork();
        async.elapse(_delay);

        h
          ..queue = PlaybackQueue(adhocItems: [queued, _queued(2)])
          ..flush(async);

        check(h.artworkRequests).deepEquals([queued.artworkUrl!]);
      });
    });

    test('drops images that arrive for a replaced list', () {
      fakeAsync((async) {
        final first = _withArt(1);
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [first]);
        h.publisher.enableArtwork();
        async.elapse(_delay);
        h
          ..queue = const PlaybackQueue()
          ..flush(async);
        final publishesBefore = h.publishes.length;

        h.finishArtwork(async);

        check(h.publishes.length).equals(publishesBefore);
      });
    });

    test('drops images that arrive after dispose', () {
      fakeAsync((async) {
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [_withArt(1)]);
        h.publisher.enableArtwork();
        async.elapse(_delay);
        final publishesBefore = h.publishes.length;

        h.publisher.dispose();
        h.finishArtwork(async);

        check(h.publishes.length).equals(publishesBefore);
      });
    });

    test('keeps known images on later publishes', () {
      fakeAsync((async) {
        final queued = _withArt(1);
        final h = _Harness()..queue = PlaybackQueue(adhocItems: [queued]);
        h.publisher.enableArtwork();
        async.elapse(_delay);
        h.finishArtwork(async);

        h
          ..queue = PlaybackQueue(adhocItems: [queued, _queued(2)])
          ..flush(async);

        check(
          h.publishes.last.items.first.artUri,
        ).equals(_artUri(queued.artworkUrl!));
        check(h.artworkRequests.length).equals(1);
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
