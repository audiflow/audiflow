import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

/// Replaying an episode that was already played (issue #599), exercised
/// end to end through the service, repository and Isar datasource.
///
/// The "review finding" tests pin down the edge cases reported on the
/// first fix; FR 04 "Replay and listen sessions" states the rules.
void main() {
  const episodeId = 1;
  const otherEpisodeId = 2;
  const duration = Duration(minutes: 30);
  // 95% of 30 minutes.
  const threshold = Duration(minutes: 28, seconds: 30);

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

  /// Lets playback run to [position] and reports the tick.
  Future<void> playTo(Duration position, {int id = episodeId}) async {
    final history = await repository.getByEpisodeId(id);
    final from = Duration(milliseconds: history?.positionMs ?? 0);
    if (from < position) now = now.add(position - from);
    await service.onProgressUpdate(id, progressAt(position));
  }

  Future<void> pauseAt(Duration position, {int id = episodeId}) =>
      service.onPlaybackPaused(id, progressAt(position));

  Future<void> seek(Duration from, Duration to, {int id = episodeId}) =>
      service.onSeeked(id, from: from, to: to, duration: duration);

  /// Plays from the start through the completion threshold to the end.
  Future<void> playToEnd({int id = episodeId}) async {
    await service.onPlaybackStarted(id, 0);
    for (final minute in [10, 20, 29]) {
      await playTo(Duration(minutes: minute), id: id);
    }
    now = now.add(const Duration(minutes: 1));
    await service.onPlaybackStopped(id, progressAt(duration));
  }

  /// Starts the episode again from the beginning and pauses at [position].
  Future<void> replayAndPauseAt(Duration position) async {
    now = now.add(const Duration(hours: 1));
    await service.onPlaybackStarted(episodeId, 0);
    await playTo(position);
    await pauseAt(position);
  }

  Future<PlaybackHistory> history([int id = episodeId]) async =>
      (await repository.getByEpisodeId(id))!;

  Future<bool> isResumable([int id = episodeId]) async =>
      (await repository.getLastPlayed())?.episodeId == id;

  group('first listen', () {
    test('a finished listen is played and not in progress', () async {
      await playToEnd();

      check(await repository.isCompleted(episodeId)).isTrue();
      check(await isResumable()).isFalse();
      check((await history()).completedCount).equals(1);
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

      final episode = Episode()
        ..id = episodeId
        ..podcastId = 1
        ..guid = 'ep-1'
        ..title = 'Episode 1'
        ..audioUrl = 'https://example.com/ep1.mp3';
      final progress = EpisodeWithProgress(
        episode: episode,
        history: await history(),
      );
      check(progress.isCompleted).isTrue();
      check(progress.isInProgress).isTrue();
    });

    test('playing the replay to the end closes it again', () async {
      await playToEnd();
      await replayAndPauseAt(const Duration(minutes: 5));

      now = now.add(const Duration(minutes: 1));
      service.onPlaybackResumed();
      for (final minute in [15, 25, 29]) {
        await playTo(Duration(minutes: minute));
      }
      await service.onPlaybackStopped(episodeId, progressAt(duration));

      check(await repository.isCompleted(episodeId)).isTrue();
      check(await isResumable()).isFalse();
      check((await history()).completedCount).equals(2);
    });

    test('starts again from the end of a parked player', () async {
      // The player restarts an episode parked at its end from zero.
      await playToEnd();
      now = now.add(const Duration(hours: 1));

      await service.onPlaybackStarted(episodeId, 0);
      await playTo(const Duration(minutes: 1));

      check((await history()).isReplaying).isTrue();
      check(await isResumable()).isTrue();
    });

    test(
      'a listen finished by mark as played replays from its position',
      () async {
        await service.onPlaybackStarted(episodeId, 0);
        await playTo(const Duration(minutes: 10));
        await pauseAt(const Duration(minutes: 10));
        await service.markCompleted(episodeId);
        await service.onPlaybackStopped(
          episodeId,
          progressAt(const Duration(minutes: 10)),
        );

        now = now.add(const Duration(days: 1));
        await service.onPlaybackStarted(
          episodeId,
          const Duration(minutes: 10).inMilliseconds,
        );
        await playTo(const Duration(minutes: 11));

        check(await repository.isCompleted(episodeId)).isTrue();
        check(await isResumable()).isTrue();
      },
    );

    test('mark as unplayed clears the played status', () async {
      await playToEnd();
      await replayAndPauseAt(const Duration(minutes: 5));

      await service.markIncomplete(episodeId);

      check(await repository.isCompleted(episodeId)).isFalse();
      // The replay position stays resumable.
      check(await isResumable()).isTrue();
    });

    test('mark as played ends the replay', () async {
      await playToEnd();
      await replayAndPauseAt(const Duration(minutes: 5));

      await service.markCompleted(episodeId);

      check(await repository.isCompleted(episodeId)).isTrue();
      check(await isResumable()).isFalse();
      // The episode was already played: no second completion.
      check((await history()).completedCount).equals(1);
    });

    test('bulk mark as played skips the played episode', () async {
      await playToEnd();
      await replayAndPauseAt(const Duration(minutes: 5));

      final marked = await service.markAllCompleted([
        episodeId,
        otherEpisodeId,
      ]);

      check(marked).equals(1);
      check(await isResumable()).isTrue();
      check((await history()).completedCount).equals(1);
      check(await repository.isCompleted(otherEpisodeId)).isTrue();
    });
  });

  group('review finding 1: resuming past the threshold', () {
    test('continues the finished listen without a second completion', () async {
      await service.onPlaybackStarted(episodeId, 0);
      for (final minute in [10, 20, 29]) {
        await playTo(Duration(minutes: minute));
      }
      await pauseAt(const Duration(minutes: 29));

      const resumeAt = Duration(minutes: 29, seconds: 10);
      await service.onPlaybackStarted(episodeId, resumeAt.inMilliseconds);
      await playTo(const Duration(minutes: 29, seconds: 20));

      check((await history()).isReplaying).isFalse();
      check((await history()).completedCount).equals(1);
      check(await isResumable()).isFalse();
    });
  });

  group('review finding 3: auto-completion notifies views', () {
    test('passing the completion threshold notifies once', () async {
      final saved = <int>[];
      final subscription = service.progressSaved.listen(saved.add);
      addTearDown(subscription.cancel);

      await service.onPlaybackStarted(episodeId, 0);
      for (final minute in [10, 20, 29]) {
        await playTo(Duration(minutes: minute));
      }
      await playTo(const Duration(minutes: 29, seconds: 30));
      await Future<void>.delayed(Duration.zero);

      check(saved).deepEquals([episodeId]);
    });
  });

  group('review finding 4: rewinding a finished listen', () {
    test('a seek back below the threshold makes it resumable', () async {
      await playToEnd();
      const resumeAt = Duration(minutes: 29, seconds: 10);
      await service.onPlaybackStarted(episodeId, resumeAt.inMilliseconds);

      const rewound = Duration(minutes: 10);
      await seek(resumeAt, rewound);
      await playTo(rewound);
      await pauseAt(rewound);

      final result = await history();
      check(result.isReplaying).isTrue();
      check(result.completedAt).isNotNull();
      check(
        (await repository.getLastPlayed())?.positionMs,
      ).equals(rewound.inMilliseconds);
    });

    test('a seek back that stays past the threshold does not', () async {
      await playToEnd();
      const resumeAt = Duration(minutes: 29, seconds: 10);
      await service.onPlaybackStarted(episodeId, resumeAt.inMilliseconds);

      await seek(resumeAt, threshold);
      await playTo(const Duration(minutes: 29));

      check((await history()).isReplaying).isFalse();
      check((await history()).completedCount).equals(1);
    });

    test('a replay reopened by a rewind finishes without counting', () async {
      await playToEnd();
      const resumeAt = Duration(minutes: 29, seconds: 10);
      await service.onPlaybackStarted(episodeId, resumeAt.inMilliseconds);

      await seek(resumeAt, const Duration(minutes: 20));
      await playTo(const Duration(minutes: 20));
      await playTo(const Duration(minutes: 29));

      check((await history()).isReplaying).isFalse();
      check((await history()).completedCount).equals(1);
      check(await isResumable()).isFalse();
    });

    test('a rewind to the beginning counts when played through', () async {
      await playToEnd();
      const resumeAt = Duration(minutes: 29, seconds: 10);
      await service.onPlaybackStarted(episodeId, resumeAt.inMilliseconds);

      await seek(resumeAt, Duration.zero);
      for (final minute in [10, 20, 29]) {
        await playTo(Duration(minutes: minute));
      }

      check((await history()).isReplaying).isFalse();
      check((await history()).completedCount).equals(2);
    });

    test('a rewind to the beginning of an open replay counts', () async {
      await playToEnd();
      const resumeAt = Duration(minutes: 29, seconds: 10);
      await service.onPlaybackStarted(episodeId, resumeAt.inMilliseconds);
      await seek(resumeAt, const Duration(minutes: 20));
      await playTo(const Duration(minutes: 20));

      await seek(const Duration(minutes: 20), Duration.zero);
      for (final minute in [10, 20, 29]) {
        await playTo(Duration(minutes: minute));
      }

      check((await history()).completedCount).equals(2);
    });
  });

  group('automatic rewind of a finished listen', () {
    test('keeps it finished through the threshold', () async {
      await playToEnd();
      const resumeAt = Duration(minutes: 29, seconds: 10);
      await service.onPlaybackStarted(episodeId, resumeAt.inMilliseconds);

      // An interruption rewind moves the player without reporting a seek.
      await playTo(const Duration(minutes: 28));
      await playTo(const Duration(minutes: 29));
      await pauseAt(const Duration(minutes: 29));

      check((await history()).isReplaying).isFalse();
      check((await history()).completedCount).equals(1);
      check(await isResumable()).isFalse();
    });
  });

  group('review finding 5: playing on after mark as played', () {
    test('keeps the listen finished', () async {
      await service.onPlaybackStarted(episodeId, 0);
      await playTo(const Duration(minutes: 10));
      await service.markCompleted(episodeId);

      await playTo(const Duration(minutes: 11));
      await pauseAt(const Duration(minutes: 11));

      check((await history()).isReplaying).isFalse();
      check(await isResumable()).isFalse();
    });

    test('skipping forward keeps the listen finished', () async {
      await service.onPlaybackStarted(episodeId, 0);
      await playTo(const Duration(minutes: 10));
      await service.markCompleted(episodeId);

      await seek(const Duration(minutes: 10), const Duration(minutes: 12));
      await playTo(const Duration(minutes: 12));
      await pauseAt(const Duration(minutes: 12));

      check((await history()).isReplaying).isFalse();
      check(await isResumable()).isFalse();
    });
  });

  group('review finding 6: a short rewind between two saves', () {
    test('reopens the listen at once', () async {
      await service.onPlaybackStarted(episodeId, 0);
      await playTo(const Duration(seconds: 60));
      await service.markCompleted(episodeId);

      // Plays on to 64s (no save), seeks back to 62s, then pauses.
      await playTo(const Duration(seconds: 64));
      await seek(const Duration(seconds: 64), const Duration(seconds: 62));
      await playTo(const Duration(seconds: 62));
      await pauseAt(const Duration(seconds: 62));

      final result = await history();
      check(result.isReplaying).isTrue();
      check(result.completedAt).isNotNull();
      check(await isResumable()).isTrue();
    });
  });

  group('review finding 7: mark as played after a rewind', () {
    Future<void> rewindAfterMarkPlayed() async {
      await service.onPlaybackStarted(episodeId, 0);
      await playTo(const Duration(seconds: 60));
      await service.markCompleted(episodeId);
      await playTo(const Duration(seconds: 64));
      await seek(const Duration(seconds: 64), const Duration(seconds: 62));
    }

    test('mark as played ends the listen the rewind reopened', () async {
      await rewindAfterMarkPlayed();

      await service.markCompleted(episodeId);
      await pauseAt(const Duration(seconds: 62));

      check((await history()).isReplaying).isFalse();
      check(await isResumable()).isFalse();
    });

    test('bulk mark as played leaves it resumable', () async {
      await rewindAfterMarkPlayed();

      check(await service.markAllCompleted([episodeId])).equals(0);
      await pauseAt(const Duration(seconds: 62));

      check((await history()).isReplaying).isTrue();
      check(await isResumable()).isTrue();
    });
  });

  group('resuming after mark as played while paused', () {
    test('a listener resume below the threshold reopens the listen', () async {
      await service.onPlaybackStarted(episodeId, 0);
      await playTo(const Duration(minutes: 10));
      await pauseAt(const Duration(minutes: 10));
      await service.markCompleted(episodeId);

      service.onPlaybackResumed();
      await service.onListenerResumed(
        episodeId,
        position: const Duration(minutes: 10),
        duration: duration,
      );
      await playTo(const Duration(minutes: 11));
      await pauseAt(const Duration(minutes: 11));

      check((await history()).isReplaying).isTrue();
      check(await isResumable()).isTrue();
      check((await history()).completedCount).equals(1);
    });
  });

  group('review finding 8: mark as played on another episode', () {
    for (final bulk in [false, true]) {
      test('leaves the rewound listen resumable (bulk: $bulk)', () async {
        await playToEnd();
        const resumeAt = Duration(minutes: 29, seconds: 10);
        await service.onPlaybackStarted(episodeId, resumeAt.inMilliseconds);
        await seek(resumeAt, const Duration(minutes: 10));

        if (bulk) {
          await service.markAllCompleted([otherEpisodeId]);
        } else {
          await service.markCompleted(otherEpisodeId);
        }
        await playTo(const Duration(minutes: 10));
        await pauseAt(const Duration(minutes: 10));

        check((await history()).isReplaying).isTrue();
        check(await isResumable()).isTrue();
        check(await repository.isCompleted(otherEpisodeId)).isTrue();
      });
    }
  });

  group('restart', () {
    test('a replay paused before a restart is restored', () async {
      await playToEnd();
      await replayAndPauseAt(const Duration(minutes: 5));

      // A fresh service after relaunch has no session; only the stored
      // history decides what is resumable.
      final relaunched = PlaybackHistoryService(
        repository,
        getCompletionThreshold: () => 0.95,
        clock: () => now,
      );
      final restored = await repository.getLastPlayed();
      check(restored?.episodeId).equals(episodeId);

      await relaunched.onPlaybackStarted(episodeId, restored!.positionMs);
      now = now.add(const Duration(minutes: 1));
      await relaunched.onProgressUpdate(
        episodeId,
        progressAt(const Duration(minutes: 6)),
      );

      check((await history()).isReplaying).isTrue();
      check((await history()).completedCount).equals(1);

      // Resuming mid-episode keeps the replay one from the beginning.
      for (final minute in [15, 25, 29]) {
        now = now.add(const Duration(minutes: 10));
        await relaunched.onProgressUpdate(
          episodeId,
          progressAt(Duration(minutes: minute)),
        );
      }
      check((await history()).completedCount).equals(2);
    });
  });
}
