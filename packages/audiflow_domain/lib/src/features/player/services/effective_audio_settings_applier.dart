import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../settings/models/audio_settings.dart';
import '../../settings/models/audio_settings_scope.dart';
import '../../settings/providers/playback_speed_settings_provider.dart';
import '../../settings/providers/podcast_audio_override_provider.dart';
import 'audio_player_service.dart';
import 'now_playing_controller.dart';

part 'effective_audio_settings_applier.g.dart';

/// Audio settings in effect for a podcast and the scope they come from.
typedef EffectiveAudioSettings = ({
  AudioSettingsScope scope,
  AudioSettings settings,
});

/// Id of the podcast the now-playing episode belongs to, or null when
/// nothing is playing or the episode is not in the database.
@Riverpod(keepAlive: true)
int? nowPlayingPodcastId(Ref ref) {
  return ref.watch(
    nowPlayingControllerProvider.select((info) => info?.episode?.podcastId),
  );
}

/// Resolves the audio settings for [podcastId]: override -> global.
///
/// A null [podcastId] resolves to the global settings. Returns null while
/// the podcast's override is still loading, so callers never act on a
/// global value that is about to be replaced by the override. A failed
/// override load falls back to the global settings.
@Riverpod(keepAlive: true)
EffectiveAudioSettings? effectiveAudioSettings(Ref ref, int? podcastId) {
  if (podcastId == null) return _global(ref);
  final override = ref.watch(podcastAudioOverrideControllerProvider(podcastId));
  return switch (override) {
    AsyncData(value: final settings?) => (
      scope: PodcastAudioSettingsScope(podcastId),
      settings: settings,
    ),
    AsyncData() || AsyncError() => _global(ref),
    _ => null,
  };
}

EffectiveAudioSettings _global(Ref ref) {
  final speed = ref.watch(
    playbackSpeedSettingsControllerProvider.select((s) => s.speed),
  );
  return (
    scope: const GlobalAudioSettingsScope(),
    settings: AudioSettings(speed: speed),
  );
}

/// Effective audio settings for the now-playing podcast.
@Riverpod(keepAlive: true)
EffectiveAudioSettings? nowPlayingAudioSettings(Ref ref) {
  final podcastId = ref.watch(nowPlayingPodcastIdProvider);
  return ref.watch(effectiveAudioSettingsProvider(podcastId));
}

/// Keeps the player on the now-playing podcast's effective settings.
///
/// Re-applies whenever the resolution changes: the now-playing podcast
/// switches, its override is switched off (back to global), or a podcast
/// override is edited from outside the player. Global edits do not reach
/// the player while an override is in effect, because the resolved value
/// does not change. Read once at startup to activate.
@Riverpod(keepAlive: true)
void effectiveAudioSettingsApplier(Ref ref) {
  final log = ref.read(namedLoggerProvider('AudioSettings'));
  ref.listen(nowPlayingAudioSettingsProvider, (_, next) {
    if (next == null) return;
    final player = ref.read(audioPlayerControllerProvider.notifier);
    unawaited(
      player.applySpeed(next.settings.speed).catchError((Object error) {
        log.w('Failed to apply effective speed', error: error);
      }),
    );
  });
}
