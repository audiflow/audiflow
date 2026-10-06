import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDownloadRepository implements DownloadRepository {
  final List<DownloadTask> tasks = [];

  @override
  Future<List<DownloadTask>> getByStatus(DownloadStatus status) async =>
      tasks.where((task) => task.downloadStatus == status).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackHistoryRepository implements PlaybackHistoryRepository {
  final Map<int, PlaybackHistory> byEpisodeId = {};

  @override
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) async =>
      byEpisodeId[episodeId];

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
    deletedTaskIds = [];
    enabled = true;
    service = DownloadRetentionService(
      downloadRepository: downloadRepository,
      playbackHistoryRepository: historyRepository,
      isAutoDeletePlayedEnabled: () => enabled,
      deleteDownload: (taskId) async => deletedTaskIds.add(taskId),
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

    test('continues past a failed delete', () async {
      downloadRepository.tasks.addAll([_task(id: 1), _task(id: 2)]);
      completeEpisode(1, _graceElapsed);
      completeEpisode(2, _graceElapsed);
      service = DownloadRetentionService(
        downloadRepository: downloadRepository,
        playbackHistoryRepository: historyRepository,
        isAutoDeletePlayedEnabled: () => true,
        deleteDownload: (taskId) async {
          if (taskId == 1) throw Exception('file locked');
          deletedTaskIds.add(taskId);
        },
        clock: () => _now,
      );

      check(await service.sweepPlayed()).equals(1);
      check(deletedTaskIds).deepEquals([2]);
    });
  });
}
