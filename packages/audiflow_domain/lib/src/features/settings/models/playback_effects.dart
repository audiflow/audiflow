/// Audio effects that can be switched on globally or per podcast.
///
/// Only Android applies them (see `audioEffectsSupportedProvider`); on
/// other platforms the stored values are kept but ignored.
enum PlaybackEffect {
  /// Shortens silent passages.
  skipSilence,

  /// Raises loudness so speech is easier to hear.
  voiceBoost,
}

/// On/off state of every [PlaybackEffect].
final class PlaybackEffects {
  const PlaybackEffects({required this.skipSilence, required this.voiceBoost});

  /// Every effect switched off.
  static const off = PlaybackEffects(skipSilence: false, voiceBoost: false);

  final bool skipSilence;
  final bool voiceBoost;

  /// Whether [effect] is switched on.
  bool isEnabled(PlaybackEffect effect) => switch (effect) {
    PlaybackEffect.skipSilence => skipSilence,
    PlaybackEffect.voiceBoost => voiceBoost,
  };

  /// Returns a copy with [effect] switched to [enabled].
  PlaybackEffects withEffect(PlaybackEffect effect, {required bool enabled}) =>
      switch (effect) {
        PlaybackEffect.skipSilence => PlaybackEffects(
          skipSilence: enabled,
          voiceBoost: voiceBoost,
        ),
        PlaybackEffect.voiceBoost => PlaybackEffects(
          skipSilence: skipSilence,
          voiceBoost: enabled,
        ),
      };

  @override
  bool operator ==(Object other) =>
      other is PlaybackEffects &&
      other.skipSilence == skipSilence &&
      other.voiceBoost == voiceBoost;

  @override
  int get hashCode => Object.hash(skipSilence, voiceBoost);

  @override
  String toString() =>
      'PlaybackEffects(skipSilence: $skipSilence, voiceBoost: $voiceBoost)';
}
