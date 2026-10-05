import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/playback_effects.dart';
import 'settings_providers.dart';

part 'playback_effects_settings_provider.g.dart';

/// Holds the global [PlaybackEffects] and persists changes.
///
/// UI must not call [save] directly: effect changes go through
/// `AudioPlayerController.setEffect`, which also applies them to the
/// player. Unlike the speed there is no drag preview, so the state is
/// always the committed value.
@Riverpod(keepAlive: true)
class PlaybackEffectsSettingsController
    extends _$PlaybackEffectsSettingsController {
  @override
  PlaybackEffects build() {
    final repo = ref.watch(appSettingsRepositoryProvider);
    return PlaybackEffects(
      skipSilence: repo.getSkipSilence(),
      voiceBoost: repo.getVoiceBoost(),
    );
  }

  /// Switches [effect] to [enabled].
  ///
  /// Updates memory before disk so the toggle follows input immediately,
  /// and restores the previous state when the write fails so memory never
  /// disagrees with what a restart would read.
  Future<void> save(PlaybackEffect effect, {required bool enabled}) async {
    final previous = state;
    final next = previous.withEffect(effect, enabled: enabled);
    if (next == previous) return;
    state = next;
    final repo = ref.read(appSettingsRepositoryProvider);
    try {
      await switch (effect) {
        PlaybackEffect.skipSilence => repo.setSkipSilence(enabled),
        PlaybackEffect.voiceBoost => repo.setVoiceBoost(enabled),
      };
    } catch (_) {
      // A newer toggle replaced the pending state; rolling back would
      // discard that input.
      if (state == next) state = previous;
      rethrow;
    }
  }
}
