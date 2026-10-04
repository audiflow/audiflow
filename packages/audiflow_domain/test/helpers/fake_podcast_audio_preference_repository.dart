import 'package:audiflow_domain/audiflow_domain.dart';

/// In-memory [PodcastAudioPreferenceRepository] that resolves against a
/// caller-supplied global speed.
class FakePodcastAudioPreferenceRepository
    implements PodcastAudioPreferenceRepository {
  FakePodcastAudioPreferenceRepository(this._globalSpeed);

  final double Function() _globalSpeed;
  final Map<int, AudioSettings> overrides = {};

  @override
  Future<AudioSettings?> get(int podcastId) async => overrides[podcastId];

  @override
  Future<void> set(int podcastId, AudioSettings settings) async =>
      overrides[podcastId] = settings;

  @override
  Future<void> clear(int podcastId) async => overrides.remove(podcastId);

  @override
  Future<AudioSettings> resolveForPodcast(int podcastId) async =>
      overrides[podcastId] ?? AudioSettings(speed: _globalSpeed());
}
