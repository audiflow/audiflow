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
///
/// Every mutation updates memory before disk so controls follow input
/// immediately, and restores the previous state when the write fails so
/// memory never disagrees with what `play()` would read after a restart.
/// Mutations are ignored until the stored override has loaded: acting on
/// a loading state could be overwritten by the pending load.
@Riverpod(keepAlive: true)
class PodcastAudioOverrideController extends _$PodcastAudioOverrideController {
  @override
  Future<AudioSettings?> build(int podcastId) {
    return ref.watch(podcastAudioPreferenceRepositoryProvider).get(podcastId);
  }

  /// Whether the stored override has loaded and exists.
  bool get hasOverride => state is AsyncData && state.value != null;

  /// Creates the override by copying the committed global settings, so
  /// switching it on does not change what the listener hears.
  ///
  /// Copies the committed speed rather than the displayed one: they differ
  /// only during a global slider drag, and copying that uncommitted
  /// preview would persist a speed the listener never settled on.
  Future<void> enable() async {
    if (state is! AsyncData || hasOverride) return;
    final globalSpeed = ref
        .read(playbackSpeedSettingsControllerProvider.notifier)
        .committedSpeed;
    final created = AudioSettings(speed: globalSpeed);
    await _update(created, (repo) => repo.set(podcastId, created));
  }

  /// Deletes the override; the podcast follows the global settings again.
  Future<void> disable() async {
    if (!hasOverride) return;
    await _update(null, (repo) => repo.clear(podcastId));
  }

  /// Sets the override's speed (snapped to the grid).
  ///
  /// Ignored when the podcast has no override: a speed edit must never
  /// create one implicitly. Slider drags pass `persist: false` for
  /// intermediate steps, matching the global speed: memory only, so a
  /// drag does not queue a write per step.
  Future<void> saveSpeed(double speed, {required bool persist}) async {
    if (!hasOverride) return;
    final updated = state.value!.copyWith(
      speed: PlaybackSpeedScale.snap(speed),
    );
    if (!persist) {
      state = AsyncData(updated);
      return;
    }
    await _update(updated, (repo) => repo.set(podcastId, updated));
  }

  Future<void> _update(
    AudioSettings? next,
    Future<void> Function(PodcastAudioPreferenceRepository repo) write,
  ) async {
    final previous = state;
    state = AsyncData(next);
    try {
      await write(ref.read(podcastAudioPreferenceRepositoryProvider));
    } catch (_) {
      // A newer edit (such as a slider preview) replaced the pending
      // state; rolling back would discard that input.
      if (state is AsyncData && state.value == next) state = previous;
      rethrow;
    }
  }
}
