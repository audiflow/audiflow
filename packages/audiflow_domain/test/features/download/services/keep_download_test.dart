import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../helpers/isar_test_helper.dart';

class _UnusedQueueService implements DownloadQueueService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedFileService implements DownloadFileService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedSubscriptionRepository implements SubscriptionRepository {
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

final _now = DateTime(2026, 10, 9, 12);
const _podcastId = 7;

void main() {
  late Isar isar;
  late DownloadRepositoryImpl repository;
  late _FakeEpisodeRepository episodeRepository;
  late _FakePlaybackHistoryRepository historyRepository;
  late List<int> deletedTaskIds;
  late DownloadService downloadService;
  late DownloadRetentionService retentionService;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([DownloadTaskSchema]);
    repository = DownloadRepositoryImpl(
      datasource: DownloadLocalDatasource(isar),
    );
    episodeRepository = _FakeEpisodeRepository();
    historyRepository = _FakePlaybackHistoryRepository();
    deletedTaskIds = [];
    downloadService = DownloadService(
      repository: repository,
      queueService: _UnusedQueueService(),
      fileService: _UnusedFileService(),
      episodeRepository: episodeRepository,
      subscriptionRepository: _UnusedSubscriptionRepository(),
      logger: Logger(level: Level.off),
      getWifiOnly: () => true,
      getBatchDownloadLimit: () => 10,
    );
    retentionService = DownloadRetentionService(
      downloadRepository: repository,
      episodeRepository: episodeRepository,
      playbackHistoryRepository: historyRepository,
      isAutoDeletePlayedEnabled: () => true,
      deleteDownload: (task) async {
        deletedTaskIds.add(task.id);
        await repository.delete(task.id);
      },
      clock: () => _now,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Future<DownloadTask> createTask(
    int episodeId, {
    DownloadOrigin origin = DownloadOrigin.auto,
    DownloadStatus status = const DownloadStatus.completed(),
  }) async {
    episodeRepository.episodes.add(
      Episode()
        ..id = episodeId
        ..podcastId = _podcastId
        ..guid = 'guid_$episodeId'
        ..title = 'Episode $episodeId'
        ..audioUrl = 'https://example.com/$episodeId.mp3'
        ..publishedAt = DateTime(2026, 1, episodeId),
    );
    final task = await repository.createDownload(
      episodeId: episodeId,
      audioUrl: 'https://example.com/$episodeId.mp3',
      wifiOnly: true,
      origin: origin,
    );
    await repository.updateStatus(
      id: task!.id,
      status: status,
      localPath: '/downloads/$episodeId.mp3',
    );
    return task;
  }

  group('keep', () {
    test('promotes an auto download to manual', () async {
      final task = await createTask(1);

      check(await downloadService.keep(task.id)).isTrue();

      final stored = await repository.getById(task.id);
      check(stored!.downloadOrigin).equals(DownloadOrigin.manual);
      check(stored.isRemovableByRetention).isFalse();
    });

    test('promotes a pending auto download', () async {
      final task = await createTask(1, status: const DownloadStatus.pending());

      check(await downloadService.keep(task.id)).isTrue();

      final stored = await repository.getById(task.id);
      check(stored!.downloadOrigin).equals(DownloadOrigin.manual);
    });

    test('reports no change for a manual download', () async {
      final task = await createTask(1, origin: DownloadOrigin.manual);

      check(await downloadService.keep(task.id)).isFalse();
    });

    test('reports no change for a failed auto download', () async {
      final task = await createTask(1, status: const DownloadStatus.failed());

      check(await downloadService.keep(task.id)).isFalse();
      final stored = await repository.getById(task.id);
      check(stored!.downloadOrigin).equals(DownloadOrigin.auto);
    });

    test('reports no change for a missing task', () async {
      check(await downloadService.keep(999)).isFalse();
    });
  });

  group('retention after keep', () {
    test('played cleanup leaves a kept download in place', () async {
      final kept = await createTask(1);
      final other = await createTask(2);
      for (final episodeId in [1, 2]) {
        historyRepository.byEpisodeId[episodeId] = PlaybackHistory()
          ..episodeId = episodeId
          ..completedAt = _now.subtract(AppConstants.playedDownloadGracePeriod);
      }

      await downloadService.keep(kept.id);
      await retentionService.sweepPlayed();

      check(deletedTaskIds).deepEquals([other.id]);
      check(await repository.getById(kept.id)).isNotNull();
    });

    test('keep-count trim leaves a kept download in place', () async {
      final kept = await createTask(1);
      final newer = await createTask(2);
      final newest = await createTask(3);
      final subscription = Subscription()
        ..id = _podcastId
        ..autoDownloadKeepCount = 1;

      await downloadService.keep(kept.id);
      await retentionService.trimForSubscription(
        subscription,
        defaultKeepCount: 1,
      );

      check(deletedTaskIds).deepEquals([newer.id]);
      check(await repository.getById(kept.id)).isNotNull();
      check(await repository.getById(newest.id)).isNotNull();
    });
  });
}
