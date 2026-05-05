import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEpisodeRepository implements EpisodeRepository {
  _FakeEpisodeRepository({Map<int, List<Episode>>? pendingByPodcastId})
    : _pending = pendingByPodcastId ?? {};

  final Map<int, List<Episode>> _pending;
  final List<List<int>> markCalls = [];

  @override
  Future<List<Episode>> getPendingAutoDownloadByPodcastId(int podcastId) async {
    // Return a defensive copy: the enqueuer iterates this list while later
    // calling markAutoDownloadEnqueued, which mutates _pending. Sharing the
    // same list reference would shrink the iteration mid-flight.
    return List.of(_pending[podcastId] ?? const []);
  }

  @override
  Future<void> markAutoDownloadEnqueued(Iterable<int> ids) async {
    final list = ids.toList();
    markCalls.add(list);
    final pendingFlat = _pending.values.expand((e) => e).toList();
    for (final id in list) {
      pendingFlat
          .where((e) => e.id == id)
          .forEach((e) => e.autoDownloadEnqueued = true);
    }
    // Remove the marked items from pending lists so subsequent calls only
    // see still-unmarked episodes.
    for (final entry in _pending.entries) {
      entry.value.removeWhere((e) => list.contains(e.id));
    }
  }

  // Unused
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDownloadRepository implements DownloadRepository {
  _FakeDownloadRepository({this.failOnEpisodeId});

  final int? failOnEpisodeId;
  final List<({int episodeId, String audioUrl, bool wifiOnly})> created = [];
  final Set<int> existingTaskFor = {};

  @override
  Future<DownloadTask?> createDownload({
    required int episodeId,
    required String audioUrl,
    required bool wifiOnly,
  }) async {
    if (episodeId == failOnEpisodeId) {
      throw Exception('simulated download failure');
    }
    if (existingTaskFor.contains(episodeId)) {
      // Simulate dedup: existing active task returns null
      return null;
    }
    created.add((episodeId: episodeId, audioUrl: audioUrl, wifiOnly: wifiOnly));
    final task = DownloadTask()
      ..episodeId = episodeId
      ..audioUrl = audioUrl
      ..wifiOnly = wifiOnly
      ..createdAt = DateTime(2026);
    return task;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Subscription _sub({
  required int id,
  String title = 'Podcast',
  bool autoDownload = true,
}) {
  return Subscription()
    ..id = id
    ..itunesId = 'itunes_$id'
    ..feedUrl = 'https://example.com/feed/$id'
    ..title = title
    ..artistName = 'Artist $id'
    ..subscribedAt = DateTime(2024, 1, id)
    ..autoDownload = autoDownload;
}

Episode _episode({
  required int id,
  required int podcastId,
  String audioUrl = 'https://example.com/audio.mp3',
}) {
  return Episode()
    ..id = id
    ..podcastId = podcastId
    ..guid = 'guid_$id'
    ..title = 'Episode $id'
    ..audioUrl = audioUrl;
}

void main() {
  group('AutoDownloadEnqueuer', () {
    test('returns empty result when no pending episodes', () async {
      final episodeRepo = _FakeEpisodeRepository();
      final downloadRepo = _FakeDownloadRepository();
      final enqueuer = AutoDownloadEnqueuer(
        episodeRepo: episodeRepo,
        downloadRepo: downloadRepo,
      );

      final result = await enqueuer.enqueueForSubscription(
        _sub(id: 1),
        wifiOnly: false,
      );

      expect(result.inspected, 0);
      expect(result.created, 0);
      expect(downloadRepo.created, isEmpty);
      expect(episodeRepo.markCalls, isEmpty);
    });

    test(
      'creates downloads for pending episodes when autoDownload=true',
      () async {
        final episodeRepo = _FakeEpisodeRepository(
          pendingByPodcastId: {
            1: [
              _episode(id: 101, podcastId: 1),
              _episode(id: 102, podcastId: 1),
            ],
          },
        );
        final downloadRepo = _FakeDownloadRepository();
        final enqueuer = AutoDownloadEnqueuer(
          episodeRepo: episodeRepo,
          downloadRepo: downloadRepo,
        );

        final result = await enqueuer.enqueueForSubscription(
          _sub(id: 1, autoDownload: true),
          wifiOnly: true,
        );

        expect(result.inspected, 2);
        expect(result.created, 2);
        expect(result.skipped, 0);
        expect(downloadRepo.created.map((c) => c.episodeId), [101, 102]);
        expect(downloadRepo.created.every((c) => c.wifiOnly), isTrue);
        expect(episodeRepo.markCalls, [
          [101, 102],
        ]);
      },
    );

    test('marks pending episodes processed even when autoDownload=false '
        '(prevents retroactive enqueue on later toggle)', () async {
      final episodeRepo = _FakeEpisodeRepository(
        pendingByPodcastId: {
          1: [_episode(id: 201, podcastId: 1), _episode(id: 202, podcastId: 1)],
        },
      );
      final downloadRepo = _FakeDownloadRepository();
      final enqueuer = AutoDownloadEnqueuer(
        episodeRepo: episodeRepo,
        downloadRepo: downloadRepo,
      );

      final result = await enqueuer.enqueueForSubscription(
        _sub(id: 1, autoDownload: false),
        wifiOnly: false,
      );

      expect(result.inspected, 2);
      expect(result.created, 0);
      expect(result.skipped, 2);
      expect(downloadRepo.created, isEmpty);
      expect(episodeRepo.markCalls, [
        [201, 202],
      ]);
    });

    test('skips episodes with empty audio URL', () async {
      final episodeRepo = _FakeEpisodeRepository(
        pendingByPodcastId: {
          1: [
            _episode(id: 301, podcastId: 1, audioUrl: ''),
            _episode(id: 302, podcastId: 1),
          ],
        },
      );
      final downloadRepo = _FakeDownloadRepository();
      final enqueuer = AutoDownloadEnqueuer(
        episodeRepo: episodeRepo,
        downloadRepo: downloadRepo,
      );

      final result = await enqueuer.enqueueForSubscription(
        _sub(id: 1),
        wifiOnly: false,
      );

      expect(result.inspected, 2);
      expect(result.created, 1);
      expect(result.skipped, 1);
      expect(downloadRepo.created.single.episodeId, 302);
      // Both still marked processed so the empty-URL episode never retries.
      expect(episodeRepo.markCalls.single, [301, 302]);
    });

    test(
      'skips already-active downloads (createDownload returns null)',
      () async {
        final episodeRepo = _FakeEpisodeRepository(
          pendingByPodcastId: {
            1: [
              _episode(id: 401, podcastId: 1),
              _episode(id: 402, podcastId: 1),
            ],
          },
        );
        final downloadRepo = _FakeDownloadRepository()
          ..existingTaskFor.add(401);
        final enqueuer = AutoDownloadEnqueuer(
          episodeRepo: episodeRepo,
          downloadRepo: downloadRepo,
        );

        final result = await enqueuer.enqueueForSubscription(
          _sub(id: 1),
          wifiOnly: false,
        );

        expect(result.inspected, 2);
        expect(result.created, 1);
        expect(result.skipped, 1);
        expect(episodeRepo.markCalls.single, [401, 402]);
      },
    );

    test(
      'on createDownload failure, episode stays unmarked so it can retry',
      () async {
        final episodeRepo = _FakeEpisodeRepository(
          pendingByPodcastId: {
            1: [
              _episode(id: 501, podcastId: 1),
              _episode(id: 502, podcastId: 1),
            ],
          },
        );
        final downloadRepo = _FakeDownloadRepository(failOnEpisodeId: 501);
        final enqueuer = AutoDownloadEnqueuer(
          episodeRepo: episodeRepo,
          downloadRepo: downloadRepo,
        );

        final result = await enqueuer.enqueueForSubscription(
          _sub(id: 1),
          wifiOnly: false,
        );

        // 501 failed -> not marked. 502 succeeded.
        expect(result.created, 1);
        expect(downloadRepo.created.single.episodeId, 502);
        expect(episodeRepo.markCalls.single, [502]);
      },
    );
  });
}
