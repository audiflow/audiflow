import 'dart:io';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDownloadRepository implements DownloadRepository {
  final List<DownloadTask> tasks = [];

  /// IDs promoted to manual after the sweep listed them.
  final Set<int> promotedIds = {};

  /// Statuses tasks moved to after they were listed.
  final Map<int, DownloadStatus> statusNow = {};

  @override
  Future<List<DownloadTask>> getByStatus(DownloadStatus status) async =>
      tasks.where((task) => task.downloadStatus == status).toList();

  /// When set, task lookups by episode fail with this error.
  Object? lookupError;

  @override
  Future<List<DownloadTask>> getByEpisodeIds(Iterable<int> episodeIds) async {
    final error = lookupError;
    if (error != null) throw error;
    final ids = episodeIds.toSet();
    return tasks.where((task) => ids.contains(task.episodeId)).toList();
  }

  @override
  Future<DownloadTask?> getById(int id) async {
    final task = tasks.where((t) => t.id == id).firstOrNull;
    if (task == null) return null;
    if (promotedIds.contains(id)) {
      return _task(id: id, origin: DownloadOrigin.manual);
    }
    final status = statusNow[id];
    return status == null ? task : _task(id: id, status: status);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackHistoryRepository implements PlaybackHistoryRepository {
  final Map<int, PlaybackHistory> byEpisodeId = {};

  @override
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) async =>
      byEpisodeId[episodeId];

  @override
  Future<Map<int, PlaybackHistory>> getByPodcastId(int podcastId) async =>
      Map.of(byEpisodeId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeEpisodeRepository implements EpisodeRepository {
  final List<Episode> episodes = [];

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) async =>
      episodes.where((episode) => episode.podcastId == podcastId).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _now = DateTime(2026, 10, 6, 12);
final _graceElapsed = _now.subtract(AppConstants.playedDownloadGracePeriod);

DownloadTask _task({
  required int id,
  DownloadOrigin origin = DownloadOrigin.auto,
  DownloadStatus status = const DownloadStatus.completed(),
}) {
  return DownloadTask()
    ..id = id
    ..episodeId = id
    ..audioUrl = 'https://example.com/$id.mp3'
    ..status = status.toDbValue()
    ..origin = origin.dbValue
    ..createdAt = DateTime(2026);
}

void main() {
  late _FakeDownloadRepository downloadRepository;
  late _FakePlaybackHistoryRepository historyRepository;
  late _FakeEpisodeRepository episodeRepository;
  late List<int> deletedTaskIds;
  late bool enabled;
  late DownloadRetentionService service;

  void completeEpisode(int episodeId, DateTime completedAt) {
    historyRepository.byEpisodeId[episodeId] = PlaybackHistory()
      ..episodeId = episodeId
      ..completedAt = completedAt;
  }

  setUp(() {
    downloadRepository = _FakeDownloadRepository();
    historyRepository = _FakePlaybackHistoryRepository();
    episodeRepository = _FakeEpisodeRepository();
    deletedTaskIds = [];
    enabled = true;
    service = DownloadRetentionService(
      downloadRepository: downloadRepository,
      episodeRepository: episodeRepository,
      playbackHistoryRepository: historyRepository,
      isAutoDeletePlayedEnabled: () => enabled,
      deleteDownload: (task) async {
        deletedTaskIds.add(task.id);
        return true;
      },
      clock: () => _now,
    );
  });

  group('sweepPlayed', () {
    test(
      'deletes auto downloads completed at least the grace period ago',
      () async {
        downloadRepository.tasks.add(_task(id: 1));
        completeEpisode(1, _graceElapsed);

        final deleted = await service.sweepPlayed();

        check(deleted).equals(1);
        check(deletedTaskIds).deepEquals([1]);
      },
    );

    test('keeps auto downloads still within the grace period', () async {
      downloadRepository.tasks.add(_task(id: 1));
      completeEpisode(1, _graceElapsed.add(const Duration(minutes: 1)));

      check(await service.sweepPlayed()).equals(0);
      check(deletedTaskIds).isEmpty();
    });

    test('keeps manual downloads', () async {
      downloadRepository.tasks.add(_task(id: 1, origin: DownloadOrigin.manual));
      completeEpisode(1, _graceElapsed);

      check(await service.sweepPlayed()).equals(0);
    });

    test('keeps downloads whose episode is not completed', () async {
      downloadRepository.tasks.add(_task(id: 1));
      historyRepository.byEpisodeId[1] = PlaybackHistory()..episodeId = 1;
      downloadRepository.tasks.add(_task(id: 2)); // no history at all

      check(await service.sweepPlayed()).equals(0);
    });

    test('ignores downloads that have not finished downloading', () async {
      downloadRepository.tasks.add(
        _task(id: 1, status: const DownloadStatus.paused()),
      );
      completeEpisode(1, _graceElapsed);

      check(await service.sweepPlayed()).equals(0);
    });

    test('does nothing when auto-delete is disabled', () async {
      enabled = false;
      downloadRepository.tasks.add(_task(id: 1));
      completeEpisode(1, _graceElapsed);

      check(await service.sweepPlayed()).equals(0);
      check(deletedTaskIds).isEmpty();
    });

    test('keeps a download promoted to manual after it was listed', () async {
      downloadRepository.tasks.add(_task(id: 1));
      downloadRepository.promotedIds.add(1);
      completeEpisode(1, _graceElapsed);

      check(await service.sweepPlayed()).equals(0);
      check(deletedTaskIds).isEmpty();
    });

    test('does not count a task the deleter found kept', () async {
      // The deleter re-checks the origin atomically; a keep that lands
      // after the sweep's re-read makes it decline.
      downloadRepository.tasks.addAll([_task(id: 1), _task(id: 2)]);
      completeEpisode(1, _graceElapsed);
      completeEpisode(2, _graceElapsed);
      service = DownloadRetentionService(
        downloadRepository: downloadRepository,
        episodeRepository: episodeRepository,
        playbackHistoryRepository: historyRepository,
        isAutoDeletePlayedEnabled: () => true,
        deleteDownload: (task) async => task.id != 1,
        clock: () => _now,
      );

      check(await service.sweepPlayed()).equals(1);
    });

    test('continues past a failed delete', () async {
      downloadRepository.tasks.addAll([_task(id: 1), _task(id: 2)]);
      completeEpisode(1, _graceElapsed);
      completeEpisode(2, _graceElapsed);
      service = DownloadRetentionService(
        downloadRepository: downloadRepository,
        episodeRepository: episodeRepository,
        playbackHistoryRepository: historyRepository,
        isAutoDeletePlayedEnabled: () => true,
        deleteDownload: (task) async {
          if (task.id == 1) throw Exception('file locked');
          deletedTaskIds.add(task.id);
          return true;
        },
        clock: () => _now,
      );

      check(await service.sweepPlayed()).equals(1);
      check(deletedTaskIds).deepEquals([2]);
    });
  });

  group('trimForSubscription', () {
    final subscription = Subscription()
      ..id = 7
      ..itunesId = 'itunes_7'
      ..feedUrl = 'https://example.com/feed/7'
      ..title = 'Podcast'
      ..artistName = 'Artist'
      ..subscribedAt = DateTime(2026)
      ..autoDownload = true;

    /// Adds an auto download for episode [id] published on day [day].
    void addEpisode(
      int id, {
      int? day,
      DownloadOrigin origin = DownloadOrigin.auto,
      DownloadStatus status = const DownloadStatus.completed(),
    }) {
      episodeRepository.episodes.add(
        Episode()
          ..id = id
          ..podcastId = subscription.id
          ..guid = 'guid_$id'
          ..title = 'Episode $id'
          ..audioUrl = 'https://example.com/$id.mp3'
          ..publishedAt = day == null ? null : DateTime(2026, 1, day),
      );
      downloadRepository.tasks.add(
        _task(id: id, origin: origin, status: status)
          ..createdAt = DateTime(2026, 2, id),
      );
    }

    test(
      'deletes the oldest unstarted auto downloads beyond the keep count',
      () async {
        for (final day in [1, 2, 3, 4]) {
          addEpisode(day, day: day);
        }

        final deleted = await service.trimForSubscription(
          subscription,
          defaultKeepCount: 2,
        );

        check(deleted).equals(2);
        check(deletedTaskIds).unorderedEquals([1, 2]);
      },
    );

    test(
      'does not count or delete started, finished, or manual downloads',
      () async {
        addEpisode(1, day: 1);
        addEpisode(2, day: 2);
        addEpisode(3, day: 3, origin: DownloadOrigin.manual);
        addEpisode(4, day: 4); // in progress
        addEpisode(5, day: 5); // finished
        historyRepository.byEpisodeId[4] = PlaybackHistory()
          ..episodeId = 4
          ..positionMs = 1000;
        completeEpisode(5, _now);

        final deleted = await service.trimForSubscription(
          subscription,
          defaultKeepCount: 1,
        );

        check(deletedTaskIds).deepEquals([1]);
        check(deleted).equals(1);
      },
    );

    test(
      'counts queued downloads but ignores failed and cancelled ones',
      () async {
        addEpisode(1, day: 1);
        addEpisode(2, day: 2, status: const DownloadStatus.pending());
        addEpisode(3, day: 3, status: const DownloadStatus.failed());
        addEpisode(4, day: 4, status: const DownloadStatus.cancelled());

        await service.trimForSubscription(subscription, defaultKeepCount: 1);

        check(deletedTaskIds).deepEquals([1]);
      },
    );

    test(
      'ranks episodes without a publish date by download creation time',
      () async {
        addEpisode(1);
        addEpisode(2);

        await service.trimForSubscription(subscription, defaultKeepCount: 1);

        check(deletedTaskIds).deepEquals([1]);
      },
    );

    test('hands the deleter the current row, not the listed one', () async {
      // The background deleter skips active downloads by the status it is
      // given, so it must see a download that started after listing.
      addEpisode(1, day: 1, status: const DownloadStatus.pending());
      addEpisode(2, day: 2);
      downloadRepository.statusNow[1] = const DownloadStatus.downloading();
      final handed = <DownloadStatus>[];
      service = DownloadRetentionService(
        downloadRepository: downloadRepository,
        episodeRepository: episodeRepository,
        playbackHistoryRepository: historyRepository,
        isAutoDeletePlayedEnabled: () => true,
        deleteDownload: (task) async {
          handed.add(task.downloadStatus);
          return true;
        },
        clock: () => _now,
      );

      await service.trimForSubscription(subscription, defaultKeepCount: 1);

      check(handed).deepEquals([const DownloadStatus.downloading()]);
    });

    test('breaks equal dates by keeping the later task', () async {
      addEpisode(1, day: 1);
      addEpisode(2, day: 1);

      await service.trimForSubscription(subscription, defaultKeepCount: 1);

      check(deletedTaskIds).deepEquals([1]);
    });

    test('never throws, so a failed trim cannot fail the feed sync', () async {
      addEpisode(1, day: 1);
      addEpisode(2, day: 2);
      // Isar reports storage failures as Error subclasses.
      downloadRepository.lookupError = StateError('database closed');

      check(
        await service.trimForSubscription(subscription, defaultKeepCount: 1),
      ).equals(0);
    });

    test('per-podcast keep count overrides the default', () async {
      for (final day in [1, 2, 3]) {
        addEpisode(day, day: day);
      }

      await service.trimForSubscription(
        Subscription()
          ..id = subscription.id
          ..autoDownloadKeepCount = 3,
        defaultKeepCount: 1,
      );

      check(deletedTaskIds).isEmpty();
    });

    test('ignores downloads of other podcasts', () async {
      addEpisode(1, day: 1);
      addEpisode(2, day: 2);
      downloadRepository.tasks.add(_task(id: 99));

      await service.trimForSubscription(subscription, defaultKeepCount: 1);

      check(deletedTaskIds).deepEquals([1]);
    });

    group('file removal retry', () {
      late int retries;

      setUp(() {
        retries = 0;
        service = DownloadRetentionService(
          downloadRepository: downloadRepository,
          episodeRepository: episodeRepository,
          playbackHistoryRepository: historyRepository,
          isAutoDeletePlayedEnabled: () => enabled,
          deleteDownload: (task) async => true,
          retryFileRemovals: () async => ++retries,
          clock: () => _now,
        );
      });

      test('runs on played cleanup even when it is turned off', () async {
        enabled = false;

        await service.sweepPlayed();

        check(retries).equals(1);
      });

      test('runs on a keep-count trim', () async {
        await service.trimForSubscription(subscription, defaultKeepCount: 3);

        check(retries).equals(1);
      });

      test('a retry failure does not stop the pass', () async {
        addEpisode(1, day: 1);
        addEpisode(2, day: 2);
        final deleted = <int>[];
        service = DownloadRetentionService(
          downloadRepository: downloadRepository,
          episodeRepository: episodeRepository,
          playbackHistoryRepository: historyRepository,
          isAutoDeletePlayedEnabled: () => enabled,
          deleteDownload: (task) async {
            deleted.add(task.id);
            return true;
          },
          retryFileRemovals: () =>
              throw const FileSystemException('Operation not permitted'),
          clock: () => _now,
        );

        check(
          await service.trimForSubscription(subscription, defaultKeepCount: 1),
        ).equals(1);
        check(deleted).length.equals(1);
      });
    });
  });
}
