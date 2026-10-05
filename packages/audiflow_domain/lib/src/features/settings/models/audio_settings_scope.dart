/// Where an audio settings change is persisted.
///
/// Every speed write names its scope explicitly so a control that edits
/// the global settings can never land in a podcast override, and the
/// other way round.
sealed class AudioSettingsScope {
  const AudioSettingsScope();
}

/// The global settings that apply to every podcast without an override.
final class GlobalAudioSettingsScope extends AudioSettingsScope {
  const GlobalAudioSettingsScope();

  @override
  bool operator ==(Object other) => other is GlobalAudioSettingsScope;

  @override
  int get hashCode => (GlobalAudioSettingsScope).hashCode;

  @override
  String toString() => 'GlobalAudioSettingsScope()';
}

/// The override owned by a single podcast.
final class PodcastAudioSettingsScope extends AudioSettingsScope {
  const PodcastAudioSettingsScope(this.podcastId);

  final int podcastId;

  @override
  bool operator ==(Object other) =>
      other is PodcastAudioSettingsScope && other.podcastId == podcastId;

  @override
  int get hashCode => Object.hash(PodcastAudioSettingsScope, podcastId);

  @override
  String toString() => 'PodcastAudioSettingsScope($podcastId)';
}
