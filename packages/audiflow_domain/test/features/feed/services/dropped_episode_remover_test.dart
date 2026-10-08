import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_download_repository.dart';

class _FakeEpisodeRepository implements EpisodeRepository {
  _FakeEpisodeRepository(this.events);

  /// Shared log of lookups, download deletions, and episode deletions.
  final List<String> events;
  final Map<String, Episode> episodesByGuid = {};
  final List<Set<String>> deletedGuidSets = [];

  void store(String guid, int id) {
    episodesByGuid[guid] = Episode()
      ..id = id
      ..podcastId = 1
      ..guid = guid
      ..title = guid
      ..audioUrl = 'https://example.com/$guid.mp3';
  }

  @override
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) async {
    events.add('lookup $guid');
    return episodesByGuid[guid];
  }

  @override
  Future<int> deleteByPodcastIdAndGuids(
    int podcastId,
    Set<String> guids,
  ) async {
    events.add('delete episodes');
    deletedGuidSets.add(Set.of(guids));
    return guids.where(episodesByGuid.containsKey).length;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late List<String> events;
  late _FakeEpisodeRepository episodeRepository;
  late FakeDownloadRepository downloadRepository;
  late Set<int> failingTaskIds;
  late List<DownloadStatus> deletedTaskStatuses;
  late DroppedEpisodeRemover remover;

  setUp(() {
    events = [];
    episodeRepository = _FakeEpisodeRepository(events);
    downloadRepository = FakeDownloadRepository();
    failingTaskIds = {};
    deletedTaskStatuses = [];
    remover = DroppedEpisodeRemover(
      episodeRepository: episodeRepository,
      downloadRepository: downloadRepository,
      // Stands in for DownloadService.delete, which cancels an active
      // task before removing its file and record.
      deleteDownload: (task) async {
        events.add('delete download ${task.id}');
        if (failingTaskIds.contains(task.id)) {
          throw const FileSystemException('Operation not permitted');
        }
        deletedTaskStatuses.add(task.downloadStatus);
        await downloadRepository.delete(task.id);
      },
    );
  });

  test('deletes manual and auto downloads of dropped episodes', () async {
    episodeRepository
      ..store('manual', 1)
      ..store('auto', 2);
    downloadRepository.tasks.addAll([
      fakeDownloadTask(episodeId: 1),
      fakeDownloadTask(episodeId: 2, origin: DownloadOrigin.auto),
      fakeDownloadTask(episodeId: 3),
    ]);

    final removal = await remover.remove(1, {'manual', 'auto'});

    check(removal.deleted).equals(2);
    check(removal.kept).equals(0);
    check(downloadRepository.tasks.map((task) => task.id)).deepEquals([3]);
    check(episodeRepository.deletedGuidSets).deepEquals([
      {'manual', 'auto'},
    ]);
  });

  test('resolves episode IDs and removes downloads before deleting the '
      'episodes', () async {
    episodeRepository.store('gone', 1);
    downloadRepository.tasks.add(fakeDownloadTask(episodeId: 1));

    await remover.remove(1, {'gone'});

    check(
      events,
    ).deepEquals(['lookup gone', 'delete download 1', 'delete episodes']);
  });

  test('hands in-flight, pending, and paused downloads to the deleter, '
      'which cancels them', () async {
    episodeRepository
      ..store('downloading', 1)
      ..store('pending', 2)
      ..store('paused', 3);
    downloadRepository.tasks.addAll([
      fakeDownloadTask(
        episodeId: 1,
        status: const DownloadStatus.downloading(),
      ),
      fakeDownloadTask(episodeId: 2, status: const DownloadStatus.pending()),
      fakeDownloadTask(episodeId: 3, status: const DownloadStatus.paused()),
    ]);

    final removal = await remover.remove(1, {
      'downloading',
      'pending',
      'paused',
    });

    check(removal.deleted).equals(3);
    check(deletedTaskStatuses).unorderedEquals([
      const DownloadStatus.downloading(),
      const DownloadStatus.pending(),
      const DownloadStatus.paused(),
    ]);
    check(downloadRepository.tasks).isEmpty();
  });

  test('a failed file delete keeps only that episode for the next sync and '
      'does not stop the rest', () async {
    episodeRepository
      ..store('stuck', 1)
      ..store('gone', 2);
    downloadRepository.tasks.addAll([
      fakeDownloadTask(episodeId: 1),
      fakeDownloadTask(episodeId: 2),
    ]);
    failingTaskIds.add(1);

    final removal = await remover.remove(1, {'stuck', 'gone'});

    check(removal.deleted).equals(1);
    // Reported so the sync withholds cache validators and retries.
    check(removal.kept).equals(1);
    check(downloadRepository.tasks.map((task) => task.id)).deepEquals([1]);
    check(episodeRepository.deletedGuidSets).deepEquals([
      {'gone'},
    ]);
  });

  test('deletes episodes that have no download', () async {
    episodeRepository.store('plain', 1);

    final removal = await remover.remove(1, {'plain', 'unknown'});

    check(removal.deleted).equals(1);
    check(removal.kept).equals(0);
    check(events).not((it) => it.any((e) => e.startsWith('delete download')));
    check(episodeRepository.deletedGuidSets).deepEquals([
      {'plain', 'unknown'},
    ]);
  });

  test('does nothing for an empty GUID set', () async {
    final removal = await remover.remove(1, const {});
    check(removal.deleted).equals(0);
    check(removal.kept).equals(0);
    check(events).isEmpty();
  });
}
