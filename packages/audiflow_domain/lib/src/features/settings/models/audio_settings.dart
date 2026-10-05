/// Audio settings values that can be set globally or per podcast.
final class AudioSettings {
  const AudioSettings({required this.speed});

  /// Playback speed, a member of `PlaybackSpeedScale.steps`.
  final double speed;

  AudioSettings copyWith({double? speed}) =>
      AudioSettings(speed: speed ?? this.speed);

  @override
  bool operator ==(Object other) =>
      other is AudioSettings && other.speed == speed;

  @override
  int get hashCode => speed.hashCode;

  @override
  String toString() => 'AudioSettings(speed: $speed)';
}
