import 'package:audiflow_core/audiflow_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/audio_settings.dart';
import '../repositories/podcast_audio_preference_repository.dart';
import 'playback_speed_settings_provider.dart';

part 'podcast_audio_override_provider.g.dart';

/// Holds a podcast's audio settings override; null when it has none.
///
/// UI must not call [saveSpeed] directly: speed changes go through
/// `AudioPlayerController.setSpeed` with a podcast scope, which also
/// applies the speed to the player and records analytics.
@Riverpod(keepAlive: true)
class PodcastAudioOverrideController extends _$PodcastAudioOverrideController {
  @override
  Future<AudioSettings?> build(int podcastId) {
    return ref.watch(podcastAudioPreferenceRepositoryProvider).get(podcastId);
  }

  /// Creates the override by copying the current global settings, so
  /// switching it on does not change what the listener hears.
  Future<void> enable() async {
    if (state.value != null) return;
    final global = ref.read(playbackSpeedSettingsControllerProvider);
    final created = AudioSettings(speed: global.speed);
    state = AsyncData(created);
    await ref
        .read(podcastAudioPreferenceRepositoryProvider)
        .set(podcastId, created);
  }

  /// Deletes the override; the podcast follows the global settings again.
  Future<void> disable() async {
    state = const AsyncData(null);
    await ref.read(podcastAudioPreferenceRepositoryProvider).clear(podcastId);
  }

  /// Sets the override's speed (snapped to the grid).
  ///
  /// Ignored when the podcast has no override: a speed edit must never
  /// create one implicitly. Slider drags pass `persist: false` for
  /// intermediate steps so only the settled value reaches the database.
  Future<void> saveSpeed(double speed, {required bool persist}) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(speed: PlaybackSpeedScale.snap(speed));
    // Update memory first so the UI follows the slider without waiting
    // on disk; persistence failures surface to the caller.
    state = AsyncData(updated);
    if (!persist) return;
    await ref
        .read(podcastAudioPreferenceRepositoryProvider)
        .set(podcastId, updated);
  }
}
