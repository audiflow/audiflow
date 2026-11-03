import 'package:audiflow_app/features/car/services/car_catalog.dart';
import 'package:audiflow_app/features/player/services/session_queue.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _episode(int id) => Episode()
  ..id = id
  ..podcastId = 1
  ..guid = 'guid-$id'
  ..title = 'Episode $id'
  ..audioUrl = 'https://example.com/$id.mp3';

QueueItemWithEpisode _queued(int queueItemId, Episode episode) =>
    QueueItemWithEpisode(
      queueItem: QueueItem()
        ..id = queueItemId
        ..episodeId = episode.id
        ..position = queueItemId
        ..addedAt = DateTime(2026),
      episode: episode,
      artworkUrl: 'https://example.com/$queueItemId.jpg',
      podcastTitle: 'Podcast $queueItemId',
    );

NowPlayingInfo _nowPlaying(Episode episode) => NowPlayingInfo(
  episodeUrl: episode.audioUrl,
  episodeTitle: episode.title,
  podcastTitle: 'Playing podcast',
  artworkUrl: 'https://example.com/playing.jpg',
  episode: episode,
);

List<int> _queueIds(SessionQueue queue) => [
  for (final entry in queue.entries)
    if (entry case SessionUpNextEntry(:final queueItemId)) queueItemId,
];

void main() {
  final playing = _episode(1);
  final next = _queued(11, _episode(2));
  final later = _queued(12, _episode(3));

  group('buildSessionQueue', () {
    test('puts the playing episode first and marks it active', () {
      final info = _nowPlaying(playing);

      final result = buildSessionQueue(
        queue: PlaybackQueue(manualItems: [next], adhocItems: [later]),
        nowPlaying: info,
      );

      check(result.activeIndex).equals(0);
      check(result.entries.first).isA<SessionNowPlayingEntry>()
        ..has((e) => e.episodeId, 'episodeId').equals(playing.id)
        ..has((e) => e.title, 'title').equals(info.episodeTitle)
        ..has((e) => e.podcastTitle, 'podcastTitle').equals(info.podcastTitle)
        ..has((e) => e.artworkUrl, 'artworkUrl').equals(info.artworkUrl);
      check(
        _queueIds(result),
      ).deepEquals([next.queueItem.id, later.queueItem.id]);
    });

    test('carries each queued row from its queue item', () {
      final result = buildSessionQueue(
        queue: PlaybackQueue(manualItems: [next]),
        nowPlaying: null,
      );

      check(result.entries.single).isA<SessionUpNextEntry>()
        ..has((e) => e.title, 'title').equals(next.episode.title)
        ..has((e) => e.podcastTitle, 'podcastTitle').equals(next.podcastTitle)
        ..has((e) => e.artworkUrl, 'artworkUrl').equals(next.artworkUrl);
    });

    test('is empty when playing with nothing up next', () {
      final result = buildSessionQueue(
        queue: const PlaybackQueue(),
        nowPlaying: _nowPlaying(playing),
      );

      check(result.entries).isEmpty();
      check(result.activeIndex).isNull();
    });

    test('has no playing row when nothing is loaded', () {
      final result = buildSessionQueue(
        queue: PlaybackQueue(adhocItems: [next, later]),
        nowPlaying: null,
      );

      check(
        _queueIds(result),
      ).deepEquals([next.queueItem.id, later.queueItem.id]);
      check(result.entries.length).equals(2);
      check(result.activeIndex).isNull();
    });

    test('is empty when nothing is loaded or queued', () {
      final result = buildSessionQueue(
        queue: const PlaybackQueue(),
        nowPlaying: null,
      );

      check(result.entries).isEmpty();
      check(result.activeIndex).isNull();
    });

    test('caps the list including the playing row', () {
      final many = [
        for (var i = 0; i <= CarCatalog.itemLimit; i++)
          _queued(100 + i, _episode(100 + i)),
      ];

      final withHead = buildSessionQueue(
        queue: PlaybackQueue(adhocItems: many),
        nowPlaying: _nowPlaying(playing),
      );
      final withoutHead = buildSessionQueue(
        queue: PlaybackQueue(adhocItems: many),
        nowPlaying: null,
      );

      check(withHead.entries.length).equals(CarCatalog.itemLimit);
      check(withoutHead.entries.length).equals(CarCatalog.itemLimit);
    });

    test('removes one queued copy of the playing episode only', () {
      final duplicate = _queued(13, playing);
      final deliberate = _queued(14, playing);

      final result = buildSessionQueue(
        queue: PlaybackQueue(manualItems: [duplicate, next, deliberate]),
        nowPlaying: _nowPlaying(playing),
      );

      check(
        _queueIds(result),
      ).deepEquals([next.queueItem.id, deliberate.queueItem.id]);
    });

    test('follows the queue order after a reorder', () {
      final before = buildSessionQueue(
        queue: PlaybackQueue(manualItems: [next, later]),
        nowPlaying: null,
      );
      final after = buildSessionQueue(
        queue: PlaybackQueue(manualItems: [later, next]),
        nowPlaying: null,
      );

      check(_queueIds(after)).deepEquals(_queueIds(before).reversed.toList());
    });

    test('leaves the podcast out when now-playing has none', () {
      final result = buildSessionQueue(
        queue: PlaybackQueue(manualItems: [next]),
        nowPlaying: _nowPlaying(playing).copyWith(podcastTitle: ''),
      );

      check(result.entries.first.podcastTitle).isNull();
    });
  });

  group('media ids', () {
    test('never reuse the audio URL of the now-playing media item', () {
      final info = _nowPlaying(playing);
      final result = buildSessionQueue(
        queue: PlaybackQueue(manualItems: [next]),
        nowPlaying: info,
      );

      check(
        result.entries.first.mediaId,
      ).not((it) => it.equals(info.episodeUrl));
    });

    test('stay distinct without an episode record', () {
      final result = buildSessionQueue(
        queue: PlaybackQueue(manualItems: [next]),
        nowPlaying: _nowPlaying(playing).copyWith(episode: null),
      );

      check(
        result.entries.first.mediaId,
      ).not((it) => it.equals(result.entries.last.mediaId));
    });
  });
}
