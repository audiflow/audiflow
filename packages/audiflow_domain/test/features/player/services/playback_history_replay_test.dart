import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

/// Replaying an episode that was already played (issue #599), exercised
/// end to end through the service, repository and Isar datasource.
void main() {
  const episodeId = 1;
  const duration = Duration(minutes: 30);

  late Isar isar;
  late PlaybackHistoryRepository repository;
  late PlaybackHistoryService service;
  late DateTime now;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([PlaybackHistorySchema]);
    repository = PlaybackHistoryRepositoryImpl(
      datasource: PlaybackHistoryLocalDatasource(isar),
    );
    now = DateTime(2026, 10, 8, 9);
    service = PlaybackHistoryService(
      repository,
      getCompletionThreshold: () => 0.95,
      clock: () => now,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  PlaybackProgress progressAt(Duration position) => PlaybackProgress(
    position: position,
    duration: duration,
    bufferedPosition: position,
  );

  /// Plays from the start through the completion threshold to the end.
  Future<void> playToEnd() async {
    await service.onPlaybackStarted(episodeId, 0);
    for (final minute in [10, 20, 29]) {
      now = now.add(const Duration(minutes: 10));
      await service.onProgressUpdate(
        episodeId,
        progressAt(Duration(minutes: minute)),
      );
    }
    // Tail after the threshold, then the end of the track.
    now = now.add(const Duration(minutes: 1));
    await service.onPlaybackStopped(episodeId, progressAt(duration));
  }

  /// Starts the episode again from the beginning and pauses at [position].
  Future<void> replayAndPauseAt(Duration position) async {
    now = now.add(const Duration(hours: 1));
    await service.onPlaybackStarted(episodeId, 0);
    now = now.add(position);
    await service.onProgressUpdate(episodeId, progressAt(position));
    await service.onPlaybackPaused(episodeId, progressAt(position));
  }

  group('first listen', () {
    test('a finished listen is played and not in progress', () async {
      await playToEnd();

      check(await repository.isCompleted(episodeId)).isTrue();
      check(await repository.getLastPlayed()).isNull();
      final history = await repository.getByEpisodeId(episodeId);
      check(history!.completedCount).equals(1);
    });
  });

  group('replay of a played episode', () {
    test('keeps the played status', () async {
      await playToEnd();

      await replayAndPauseAt(const Duration(minutes: 5));

      check(await repository.isCompleted(episodeId)).isTrue();
    });

    test('shows and resumes the replay position', () async {
      await playToEnd();

      await replayAndPauseAt(const Duration(minutes: 5));

      final lastPlayed = await repository.getLastPlayed();
      check(lastPlayed).isNotNull()
        ..has((h) => h.episodeId, 'episodeId').equals(episodeId)
        ..has(
          (h) => h.positionMs,
          'positionMs',
        ).equals(const Duration(minutes: 5).inMilliseconds);
      final inProgress = await repository.watchInProgress().first;
      check(inProgress.map((h) => h.episodeId)).deepEquals([episodeId]);
    });

    test('reads as played and in progress together', () async {
      await playToEnd();

      await replayAndPauseAt(const Duration(minutes: 5));

      final history = await repository.getByEpisodeId(episodeId);
      final episode = Episode()
        ..id = episodeId
        ..podcastId = 1
        ..guid = 'ep-1'
        ..title = 'Episode 1'
        ..audioUrl = 'https://example.com/ep1.mp3';
      final progress = EpisodeWithProgress(episode: episode, history: history);
      check(progress.isCompleted).isTrue();
      check(progress.isInProgress).isTrue();
    });

    test('playing the replay to the end closes it again', () async {
      await playToEnd();
      await replayAndPauseAt(const Duration(minutes: 5));

      now = now.add(const Duration(minutes: 1));
      service.onPlaybackResumed();
      for (final minute in [15, 25, 29]) {
        now = now.add(const Duration(minutes: 10));
        await service.onProgressUpdate(
          episodeId,
          progressAt(Duration(minutes: minute)),
        );
      }
      await service.onPlaybackStopped(episodeId, progressAt(duration));

      check(await repository.isCompleted(episodeId)).isTrue();
      check(await repository.getLastPlayed()).isNull();
      final history = await repository.getByEpisodeId(episodeId);
      check(history!.completedCount).equals(2);
    });

    test('mark as unplayed clears the played status', () async {
      await playToEnd();
      await replayAndPauseAt(const Duration(minutes: 5));

      await service.markIncomplete(episodeId);

      check(await repository.isCompleted(episodeId)).isFalse();
      // The replay position stays resumable.
      check(await repository.getLastPlayed()).isNotNull();
    });

    test('mark as played ends the replay', () async {
      await playToEnd();
      await replayAndPauseAt(const Duration(minutes: 5));

      await service.markCompleted(episodeId);

      check(await repository.isCompleted(episodeId)).isTrue();
      check(await repository.getLastPlayed()).isNull();
    });
  });

  group('resuming past the completion threshold', () {
    test('continues the finished listen instead of replaying', () async {
      await service.onPlaybackStarted(episodeId, 0);
      for (final minute in [10, 20, 29]) {
        now = now.add(const Duration(minutes: 10));
        await service.onProgressUpdate(
          episodeId,
          progressAt(Duration(minutes: minute)),
        );
      }
      await service.onPlaybackPaused(
        episodeId,
        progressAt(const Duration(minutes: 29)),
      );

      final resumeAt = const Duration(minutes: 29, seconds: 10);
      await service.onPlaybackStarted(episodeId, resumeAt.inMilliseconds);
      now = now.add(const Duration(seconds: 10));
      await service.onProgressUpdate(
        episodeId,
        progressAt(const Duration(minutes: 29, seconds: 20)),
      );

      final history = await repository.getByEpisodeId(episodeId);
      check(history!.isReplaying).isFalse();
      check(history.completedCount).equals(1);
    });
  });

  group('rewinding a finished listen', () {
    test('below the threshold starts a resumable replay', () async {
      await playToEnd();

      final resumeAt = const Duration(minutes: 29, seconds: 10);
      await service.onPlaybackStarted(episodeId, resumeAt.inMilliseconds);
      // Seek back to 10 minutes, then pause there.
      now = now.add(const Duration(seconds: 10));
      const rewound = Duration(minutes: 10);
      await service.onProgressUpdate(episodeId, progressAt(rewound));
      await service.onPlaybackPaused(episodeId, progressAt(rewound));

      final history = await repository.getByEpisodeId(episodeId);
      check(history!.isReplaying).isTrue();
      check(history.completedAt).isNotNull();
      final lastPlayed = await repository.getLastPlayed();
      check(lastPlayed?.positionMs).equals(rewound.inMilliseconds);
    });
  });

  group('refresh notifications', () {
    test('passing the completion threshold notifies once', () async {
      final saved = <int>[];
      final subscription = service.progressSaved.listen(saved.add);
      addTearDown(subscription.cancel);

      await service.onPlaybackStarted(episodeId, 0);
      for (final minute in [10, 20, 29]) {
        now = now.add(const Duration(minutes: 10));
        await service.onProgressUpdate(
          episodeId,
          progressAt(Duration(minutes: minute)),
        );
      }
      await Future<void>.delayed(Duration.zero);

      check(saved).deepEquals([episodeId]);
    });
  });
}
