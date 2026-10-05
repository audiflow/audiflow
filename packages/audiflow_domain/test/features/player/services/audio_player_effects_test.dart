import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';
import '../../../helpers/fake_podcast_audio_preference_repository.dart';

const _global = GlobalAudioSettingsScope();
const _podcast = PodcastAudioSettingsScope(1);

void main() {
  late FakeAppSettingsRepository repo;
  late FakePodcastAudioPreferenceRepository overrides;
  late ProviderContainer container;

  ProviderContainer createContainer({required bool effectsSupported}) {
    return ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(repo),
        podcastAudioPreferenceRepositoryProvider.overrideWithValue(overrides),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        audioEffectsSupportedProvider.overrideWithValue(effectsSupported),
      ],
    );
  }

  setUp(() {
    repo = FakeAppSettingsRepository();
    overrides = FakePodcastAudioPreferenceRepository(() => repo.audioSettings);
    container = createContainer(effectsSupported: true);
  });

  tearDown(() => container.dispose());

  AudioPlayerController controller() =>
      container.read(audioPlayerControllerProvider.notifier);

  bool skipSilenceApplied() =>
      container.read(audioPlayerProvider).skipSilenceEnabled;

  bool? voiceBoostApplied() =>
      container.read(voiceBoostEffectProvider)?.enabled;

  AudioSettings? overrideOf(int podcastId) =>
      container.read(podcastAudioOverrideControllerProvider(podcastId)).value;

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

  test('the voice boost effect uses the target gain', () {
    check(
      container.read(voiceBoostEffectProvider)!.targetGain,
    ).equals(voiceBoostTargetGainDb);
  });

  group('global scope', () {
    test('setEffect persists and applies each effect', () async {
      await controller().setEffect(
        PlaybackEffect.skipSilence,
        enabled: true,
        scope: _global,
      );
      await controller().setEffect(
        PlaybackEffect.voiceBoost,
        enabled: true,
        scope: _global,
      );

      check(repo.skipSilence).isTrue();
      check(repo.voiceBoost).isTrue();
      check(skipSilenceApplied()).isTrue();
      check(voiceBoostApplied()).equals(true);
    });

    test('does not touch the player while an override is in effect', () async {
      overrides.overrides[1] = const AudioSettings(
        speed: 1.0,
        effects: PlaybackEffects.off,
      );
      await playPodcast(1);

      await controller().setEffect(
        PlaybackEffect.skipSilence,
        enabled: true,
        scope: _global,
      );

      check(repo.skipSilence).isTrue();
      check(skipSilenceApplied()).isFalse();
    });
  });

  group('podcast scope', () {
    test('persists to the override and applies when it is playing', () async {
      overrides.overrides[1] = const AudioSettings(
        speed: 1.0,
        effects: PlaybackEffects.off,
      );
      await playPodcast(1);

      await controller().setEffect(
        PlaybackEffect.voiceBoost,
        enabled: true,
        scope: _podcast,
      );

      const expected = AudioSettings(
        speed: 1.0,
        effects: PlaybackEffects(skipSilence: false, voiceBoost: true),
      );
      check(overrides.overrides[1]).equals(expected);
      check(overrideOf(1)).equals(expected);
      check(repo.voiceBoost).isFalse();
      check(voiceBoostApplied()).equals(true);
    });

    test('is ignored when the podcast has no override', () async {
      await playPodcast(1);

      await controller().setEffect(
        PlaybackEffect.skipSilence,
        enabled: true,
        scope: _podcast,
      );

      check(overrides.overrides).isEmpty();
      check(skipSilenceApplied()).isFalse();
    });

    test('a failed write restores the override', () async {
      overrides.overrides[1] = const AudioSettings(
        speed: 1.0,
        effects: PlaybackEffects.off,
      );
      await playPodcast(1);
      overrides.failWrites = true;

      await check(
        controller().setEffect(
          PlaybackEffect.voiceBoost,
          enabled: true,
          scope: _podcast,
        ),
      ).throws<StateError>();

      check(overrideOf(1)!.effects).equals(PlaybackEffects.off);
      check(voiceBoostApplied()).equals(false);
    });

    test('overlapping failed writes leave the stored effects', () async {
      overrides.overrides[1] = const AudioSettings(
        speed: 1.0,
        effects: PlaybackEffects.off,
      );
      await playPodcast(1);
      overrides.failWrites = true;
      final notifier = container.read(
        podcastAudioOverrideControllerProvider(1).notifier,
      );

      final boost = check(
        notifier.saveEffect(PlaybackEffect.voiceBoost, enabled: true),
      ).throws<StateError>();
      final skip = check(
        notifier.saveEffect(PlaybackEffect.skipSilence, enabled: true),
      ).throws<StateError>();
      await boost;
      await skip;

      check(overrideOf(1)!.effects).equals(PlaybackEffects.off);
    });

    test('enable copies the global effects', () async {
      repo
        ..skipSilence = true
        ..voiceBoost = true;
      await container.read(podcastAudioOverrideControllerProvider(1).future);

      await container
          .read(podcastAudioOverrideControllerProvider(1).notifier)
          .enable();

      check(
        overrides.overrides[1]!.effects,
      ).equals(const PlaybackEffects(skipSilence: true, voiceBoost: true));
    });
  });

  group('unsupported platform', () {
    setUp(() {
      container.dispose();
      container = createContainer(effectsSupported: false);
    });

    test('stores effects but never applies them', () async {
      await controller().setEffect(
        PlaybackEffect.skipSilence,
        enabled: true,
        scope: _global,
      );

      check(repo.skipSilence).isTrue();
      check(skipSilenceApplied()).isFalse();
      check(voiceBoostApplied()).isNull();
    });

    test('applyAudioSettings applies only the speed', () async {
      await controller().applyAudioSettings(
        const AudioSettings(
          speed: 1.5,
          effects: PlaybackEffects(skipSilence: true, voiceBoost: true),
        ),
      );

      check(container.read(audioPlayerProvider).speed).equals(1.5);
      check(skipSilenceApplied()).isFalse();
    });
  });
}
