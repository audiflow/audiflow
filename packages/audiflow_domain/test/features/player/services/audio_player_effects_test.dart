import 'package:audiflow_domain/audiflow_domain.dart';
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
    expect(
      container.read(voiceBoostEffectProvider)!.targetGain,
      voiceBoostTargetGainDb,
    );
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

      expect(repo.skipSilence, isTrue);
      expect(repo.voiceBoost, isTrue);
      expect(skipSilenceApplied(), isTrue);
      expect(voiceBoostApplied(), isTrue);
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

      expect(repo.skipSilence, isTrue);
      expect(skipSilenceApplied(), isFalse);
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
      expect(overrides.overrides[1], expected);
      expect(overrideOf(1), expected);
      expect(repo.voiceBoost, isFalse);
      expect(voiceBoostApplied(), isTrue);
    });

    test('is ignored when the podcast has no override', () async {
      await playPodcast(1);

      await controller().setEffect(
        PlaybackEffect.skipSilence,
        enabled: true,
        scope: _podcast,
      );

      expect(overrides.overrides, isEmpty);
      expect(skipSilenceApplied(), isFalse);
    });

    test('enable copies the global effects', () async {
      repo
        ..skipSilence = true
        ..voiceBoost = true;
      await container.read(podcastAudioOverrideControllerProvider(1).future);

      await container
          .read(podcastAudioOverrideControllerProvider(1).notifier)
          .enable();

      expect(
        overrides.overrides[1]!.effects,
        const PlaybackEffects(skipSilence: true, voiceBoost: true),
      );
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

      expect(repo.skipSilence, isTrue);
      expect(skipSilenceApplied(), isFalse);
      expect(voiceBoostApplied(), isNull);
    });

    test('applyAudioSettings applies only the speed', () async {
      await controller().applyAudioSettings(
        const AudioSettings(
          speed: 1.5,
          effects: PlaybackEffects(skipSilence: true, voiceBoost: true),
        ),
      );

      expect(container.read(audioPlayerProvider).speed, 1.5);
      expect(skipSilenceApplied(), isFalse);
    });
  });
}
