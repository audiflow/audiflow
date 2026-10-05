import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';
import '../../../helpers/fake_podcast_audio_preference_repository.dart';

/// Records every speed that reaches the engine. When [gate] is set, each
/// call waits on it, standing in for a slow platform channel.
class _SpyAudioPlayer extends AudioPlayer {
  _SpyAudioPlayer() : super(handleInterruptions: false);

  final List<double> engineCalls = [];
  int inFlight = 0;
  int maxInFlight = 0;
  Completer<void>? gate;

  /// When true, calls are recorded but `speed` never changes, like a
  /// disposed player.
  bool ignoreCalls = false;

  /// Speeds the engine rejects, after waiting on [gate].
  final Set<double> failSpeeds = {};

  /// Every silence skipping value that reaches the engine.
  final List<bool> skipSilenceCalls = [];

  /// When set, silence skipping calls also wait on it, after [gate].
  Completer<void>? skipSilenceGate;

  @override
  Future<void> setSpeed(double speed) async {
    engineCalls.add(speed);
    if (ignoreCalls) return;
    await _inFlight(() async {
      final pending = super.setSpeed(speed);
      await gate?.future;
      if (failSpeeds.contains(speed)) throw StateError('engine rejected');
      await pending;
    });
  }

  @override
  Future<void> setSkipSilenceEnabled(bool enabled) async {
    skipSilenceCalls.add(enabled);
    await _inFlight(() async {
      final pending = super.setSkipSilenceEnabled(enabled);
      await gate?.future;
      await skipSilenceGate?.future;
      await pending;
    });
  }

  Future<void> _inFlight(Future<void> Function() call) async {
    inFlight++;
    if (maxInFlight < inFlight) maxInFlight = inFlight;
    try {
      await call();
    } finally {
      inFlight--;
    }
  }
}

void main() {
  late FakeAppSettingsRepository settingsRepo;
  late FakePodcastAudioPreferenceRepository overrides;
  late _SpyAudioPlayer player;
  late ProviderContainer container;

  setUp(() {
    settingsRepo = FakeAppSettingsRepository();
    overrides = FakePodcastAudioPreferenceRepository(
      () => settingsRepo.audioSettings,
    );
    player = _SpyAudioPlayer();
    container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(settingsRepo),
        podcastAudioPreferenceRepositoryProvider.overrideWithValue(overrides),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        audioEffectsSupportedProvider.overrideWithValue(true),
        audioPlayerProvider.overrideWith((ref) {
          ref.onDispose(player.dispose);
          return player;
        }),
      ],
    );
  });

  tearDown(() => container.dispose());

  /// Mirrors main.dart: the applier is listened to before the last
  /// played episode is restored.
  void startApplier() =>
      container.listen(effectiveAudioSettingsApplierProvider, (_, _) {});

  AudioPlayerController controller() =>
      container.read(audioPlayerControllerProvider.notifier);

  void restoreNowPlaying(int podcastId) {
    container
        .read(nowPlayingControllerProvider.notifier)
        .setNowPlaying(
          NowPlayingInfo(
            episodeUrl: 'https://example.com/$podcastId.mp3',
            episodeTitle: 'Episode',
            podcastTitle: 'Podcast',
            episode: Episode()
              ..id = podcastId * 10
              ..podcastId = podcastId,
          ),
        );
  }

  const global = GlobalAudioSettingsScope();

  test(
    'boot restore with off-grid stored speeds settles after one apply',
    () async {
      // Stored values that predate the step grid.
      settingsRepo.playbackSpeed = 1.25;
      overrides.overrides[1] = const AudioSettings(
        speed: 1.75,
        effects: PlaybackEffects.off,
      );
      startApplier();

      restoreNowPlaying(1);
      await pumpEventQueue(times: 100);

      check(player.engineCalls).deepEquals([1.8]);
      check(player.speed).equals(1.8);
    },
  );

  test(
    'each drag step reaches the engine once, the commit not again',
    () async {
      startApplier();

      for (final step in [1.1, 1.2, 1.3, 1.2]) {
        await controller().setSpeed(step, scope: global, transient: true);
      }
      await controller().setSpeed(1.2, scope: global);
      await pumpEventQueue(times: 100);

      check(player.engineCalls).deepEquals([1.1, 1.2, 1.3, 1.2]);
      check(player.speed).equals(1.2);
    },
  );

  test('a slow engine serializes calls and collapses to the latest', () async {
    startApplier();
    player.gate = Completer<void>();

    for (final step in [1.1, 1.2, 1.3, 1.4]) {
      unawaited(controller().setSpeed(step, scope: global, transient: true));
    }
    await pumpEventQueue();
    player.gate!.complete();
    await pumpEventQueue(times: 100);

    check(player.maxInFlight).equals(1);
    check(player.engineCalls).deepEquals([1.1, 1.4]);
    check(player.speed).equals(1.4);
  });

  test('an engine failure does not drop a newer pending speed', () async {
    player.gate = Completer<void>();
    player.failSpeeds.add(1.1);

    final first = controller().applySpeed(1.1);
    final second = controller().applySpeed(1.4);
    await pumpEventQueue();
    player.gate!.complete();

    // Only the final speed's outcome is reported, and it succeeded.
    await first;
    await second;
    check(player.engineCalls).deepEquals([1.1, 1.4]);
    check(player.speed).equals(1.4);
  });

  test('an engine failure on the final speed is reported', () async {
    player.failSpeeds.add(1.5);

    await check(controller().applySpeed(1.5)).throws<StateError>();
  });

  test(
    'a later pass for another setting keeps reporting the failure',
    () async {
      player.gate = Completer<void>();
      player.skipSilenceGate = Completer<void>();
      player.failSpeeds.add(1.5);
      const skipOn = PlaybackEffects(skipSilence: true, voiceBoost: false);

      final first = controller().applyAudioSettings(
        const AudioSettings(speed: 1.5, effects: skipOn),
      );
      await pumpEventQueue();
      // The speed step fails; the silence step of the same pass starts.
      player.gate!.complete();
      await pumpEventQueue();
      // A silence request made now needs a second pass, which succeeds.
      final second = controller().applyAudioSettings(
        const AudioSettings(speed: 1.5, effects: PlaybackEffects.off),
      );
      player.skipSilenceGate!.complete();

      await check(first).throws<StateError>();
      await check(second).throws<StateError>();
      check(player.skipSilenceCalls).deepEquals([true, false]);
    },
  );

  test('an engine that ignores calls cannot make applySpeed spin', () async {
    player.ignoreCalls = true;

    await controller().applySpeed(1.5).timeout(const Duration(seconds: 1));
    await controller().applySpeed(1.5).timeout(const Duration(seconds: 1));

    // The second request is not deduplicated (speed never changed) but
    // each request reaches the engine exactly once.
    check(player.engineCalls).deepEquals([1.5, 1.5]);
  });

  test(
    'applySpeed is idempotent for the applied and the pending speed',
    () async {
      await controller().applySpeed(1.5);
      await controller().applySpeed(1.5);
      await controller().applySpeed(1.48);

      check(player.engineCalls).deepEquals([1.5]);
    },
  );

  group('effects', () {
    const skipSilence = AudioSettings(
      speed: 1.0,
      effects: PlaybackEffects(skipSilence: true, voiceBoost: false),
    );
    const boosted = AudioSettings(
      speed: 1.0,
      effects: PlaybackEffects(skipSilence: false, voiceBoost: true),
    );

    AndroidLoudnessEnhancer voiceBoost() =>
        container.read(voiceBoostEffectProvider)!;

    test('follow the podcast override when the episode changes', () async {
      overrides.overrides[1] = skipSilence;
      overrides.overrides[2] = boosted;
      startApplier();

      restoreNowPlaying(1);
      await pumpEventQueue(times: 100);
      check(player.skipSilenceEnabled).isTrue();
      check(voiceBoost().enabled).isFalse();

      restoreNowPlaying(2);
      await pumpEventQueue(times: 100);
      check(player.skipSilenceEnabled).isFalse();
      check(voiceBoost().enabled).isTrue();
      check(player.skipSilenceCalls).deepEquals([true, false]);
    });

    test('share the serialized engine path with the speed', () async {
      player.gate = Completer<void>();

      final first = controller().applySpeed(1.5);
      final second = controller().applyAudioSettings(skipSilence);
      await pumpEventQueue();
      player.gate!.complete();
      await first;
      await second;

      check(player.maxInFlight).equals(1);
      check(player.engineCalls).deepEquals([1.5, 1.0]);
      check(player.skipSilenceCalls).deepEquals([true]);
    });

    test('are idempotent', () async {
      await controller().applyAudioSettings(skipSilence);
      await controller().applyAudioSettings(skipSilence);

      check(player.skipSilenceCalls).deepEquals([true]);
      check(player.engineCalls).isEmpty();
    });

    test(
      'a scope switch with the same values does not reach the engine',
      () async {
        settingsRepo.skipSilence = true;
        startApplier();
        restoreNowPlaying(1);
        await pumpEventQueue(times: 100);
        check(player.skipSilenceCalls).deepEquals([true]);

        await container
            .read(podcastAudioOverrideControllerProvider(1).notifier)
            .enable();
        await pumpEventQueue(times: 100);

        check(player.skipSilenceCalls).deepEquals([true]);
      },
    );

    test('a toggle made while an earlier call runs is not lost', () async {
      player.gate = Completer<void>();

      final first = controller().applyAudioSettings(
        skipSilence.copyWith(speed: 1.5),
      );
      await pumpEventQueue();
      // The speed call is in flight; silence skipping is still queued.
      final second = controller().applyAudioSettings(
        const AudioSettings(speed: 1.5, effects: PlaybackEffects.off),
      );
      player.gate!.complete();
      await first;
      await second;

      check(player.skipSilenceEnabled).isFalse();
      check(player.maxInFlight).equals(1);
    });
  });
}
