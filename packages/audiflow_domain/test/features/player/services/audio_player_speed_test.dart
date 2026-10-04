import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';
import '../../../helpers/fake_podcast_audio_preference_repository.dart';

const _global = GlobalAudioSettingsScope();

void main() {
  late FakeAppSettingsRepository repo;
  late FakePodcastAudioPreferenceRepository overrides;
  late FakeAnalyticsService analytics;
  late ProviderContainer container;

  setUp(() {
    repo = FakeAppSettingsRepository();
    overrides = FakePodcastAudioPreferenceRepository(() => repo.playbackSpeed);
    analytics = FakeAnalyticsService();
    container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(repo),
        podcastAudioPreferenceRepositoryProvider.overrideWithValue(overrides),
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
    );
  });

  tearDown(() => container.dispose());

  AudioPlayerController controller() =>
      container.read(audioPlayerControllerProvider.notifier);

  PlaybackSpeedSettings settings() =>
      container.read(playbackSpeedSettingsControllerProvider);

  double playerSpeed() => container.read(audioPlayerProvider).speed;

  PodcastAudioOverrideController overrideOf(int podcastId) => container.read(
    podcastAudioOverrideControllerProvider(podcastId).notifier,
  );

  /// Puts an episode of [podcastId] in the now-playing slot and waits for
  /// its override to load, the way playing an episode does.
  Future<void> playPodcast(int podcastId) async {
    container
        .read(nowPlayingControllerProvider.notifier)
        .setNowPlaying(
          NowPlayingInfo(
            episodeUrl: 'https://example.com/$podcastId.mp3',
            episodeTitle: 'Episode',
            podcastTitle: 'Podcast $podcastId',
            episode: Episode()
              ..id = podcastId * 10
              ..podcastId = podcastId,
          ),
        );
    await container.read(
      podcastAudioOverrideControllerProvider(podcastId).future,
    );
  }

  group('global scope', () {
    test('setSpeed snaps, applies, records and logs once', () async {
      await controller().setSpeed(1.25, scope: _global);

      expect(playerSpeed(), 1.3);
      expect(settings().speed, 1.3);
      expect(settings().recentSpeeds, [1.3]);
      expect(repo.playbackSpeed, 1.3);
      expect(analytics.events.whereType<PlaybackSpeedChanged>(), hasLength(1));
    });

    test('transient setSpeed skips recents and analytics', () async {
      await controller().setSpeed(1.6, scope: _global, transient: true);
      await controller().setSpeed(1.7, scope: _global, transient: true);

      expect(playerSpeed(), 1.7);
      expect(settings().speed, 1.7);
      expect(settings().recentSpeeds, isEmpty);
      expect(analytics.events.whereType<PlaybackSpeedChanged>(), isEmpty);

      await controller().setSpeed(1.7, scope: _global);

      expect(settings().recentSpeeds, [1.7]);
      expect(analytics.events.whereType<PlaybackSpeedChanged>(), hasLength(1));
    });

    test('never creates a podcast override', () async {
      await playPodcast(1);

      await controller().setSpeed(1.5, scope: _global);

      expect(overrides.overrides, isEmpty);
      expect(
        container.read(podcastAudioOverrideControllerProvider(1)).value,
        isNull,
      );
      expect(playerSpeed(), 1.5);
    });

    test('does not touch the player while an override is in effect', () async {
      overrides.overrides[1] = const AudioSettings(speed: 2.0);
      await playPodcast(1);
      await controller().applySpeed(2.0);

      await controller().setSpeed(0.8, scope: _global);

      expect(repo.playbackSpeed, 0.8);
      expect(playerSpeed(), 2.0);
    });
  });

  group('podcast scope', () {
    const scope = PodcastAudioSettingsScope(1);

    test('persists to the override and applies when it is playing', () async {
      overrides.overrides[1] = const AudioSettings(speed: 1.0);
      await playPodcast(1);

      await controller().setSpeed(1.5, scope: scope);

      expect(overrides.overrides[1], const AudioSettings(speed: 1.5));
      expect(repo.playbackSpeed, 1.0);
      expect(playerSpeed(), 1.5);
      // Recent chips are one shared history across scopes.
      expect(settings().recentSpeeds, [1.5]);
      expect(analytics.events.whereType<PlaybackSpeedChanged>(), hasLength(1));
    });

    test('transient steps save without recording a recent speed', () async {
      overrides.overrides[1] = const AudioSettings(speed: 1.0);
      await playPodcast(1);

      await controller().setSpeed(1.8, scope: scope, transient: true);

      expect(overrides.overrides[1], const AudioSettings(speed: 1.8));
      expect(playerSpeed(), 1.8);
      expect(settings().recentSpeeds, isEmpty);
      expect(analytics.events.whereType<PlaybackSpeedChanged>(), isEmpty);
    });

    test('does not touch the player for another podcast', () async {
      overrides.overrides[2] = const AudioSettings(speed: 1.0);
      await playPodcast(1);
      await container.read(podcastAudioOverrideControllerProvider(2).future);

      await controller().setSpeed(
        2.0,
        scope: const PodcastAudioSettingsScope(2),
      );

      expect(overrides.overrides[2], const AudioSettings(speed: 2.0));
      expect(playerSpeed(), 1.0);
    });

    test('is ignored when the podcast has no override', () async {
      await playPodcast(1);

      await controller().setSpeed(1.5, scope: scope);

      expect(overrides.overrides, isEmpty);
      expect(settings().recentSpeeds, isEmpty);
      expect(analytics.events.whereType<PlaybackSpeedChanged>(), isEmpty);
    });
  });

  group('override switch', () {
    test('enable copies the current global settings', () async {
      repo.playbackSpeed = 1.3;
      await container.read(podcastAudioOverrideControllerProvider(1).future);

      await overrideOf(1).enable();

      expect(overrides.overrides[1], const AudioSettings(speed: 1.3));
    });

    test('a failed write restores the previous state', () async {
      overrides.failWrites = true;
      await container.read(podcastAudioOverrideControllerProvider(1).future);

      await expectLater(overrideOf(1).enable(), throwsA(isA<StateError>()));

      expect(
        container.read(podcastAudioOverrideControllerProvider(1)).value,
        isNull,
      );
    });

    test('disable deletes the override', () async {
      overrides.overrides[1] = const AudioSettings(speed: 2.0);
      await container.read(podcastAudioOverrideControllerProvider(1).future);

      await overrideOf(1).disable();

      expect(overrides.overrides, isEmpty);
    });
  });

  group('effectiveAudioSettingsApplier', () {
    // Listened, not just read: an unlistened provider pauses its own
    // subscriptions, exactly as at app startup.
    setUp(
      () => container.listen(effectiveAudioSettingsApplierProvider, (_, _) {}),
    );

    test('re-applies when the now-playing podcast changes', () async {
      overrides.overrides[1] = const AudioSettings(speed: 1.5);

      await playPodcast(1);
      await pumpEventQueue();
      expect(playerSpeed(), 1.5);

      await playPodcast(2);
      await pumpEventQueue();
      expect(playerSpeed(), 1.0);

      await playPodcast(1);
      await pumpEventQueue();
      expect(playerSpeed(), 1.5);
    });

    test('turning the override off restores the global speed', () async {
      overrides.overrides[1] = const AudioSettings(speed: 1.5);
      await playPodcast(1);
      await pumpEventQueue();
      expect(playerSpeed(), 1.5);

      await overrideOf(1).disable();
      await pumpEventQueue();

      expect(playerSpeed(), 1.0);
    });
  });
}
