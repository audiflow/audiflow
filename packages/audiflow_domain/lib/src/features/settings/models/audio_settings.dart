import 'playback_effects.dart';

/// Audio settings values that can be set globally or per podcast.
final class AudioSettings {
  const AudioSettings({required this.speed, required this.effects});

  /// Playback speed, a member of `PlaybackSpeedScale.steps`.
  final double speed;

  /// Silence skipping and voice boost. Applied on Android only.
  final PlaybackEffects effects;

  AudioSettings copyWith({double? speed, PlaybackEffects? effects}) =>
      AudioSettings(
        speed: speed ?? this.speed,
        effects: effects ?? this.effects,
      );

  @override
  bool operator ==(Object other) =>
      other is AudioSettings &&
      other.speed == speed &&
      other.effects == effects;

  @override
  int get hashCode => Object.hash(speed, effects);

  @override
  String toString() => 'AudioSettings(speed: $speed, effects: $effects)';
}
