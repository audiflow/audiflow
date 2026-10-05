import 'package:audiflow_domain/audiflow_domain.dart';

/// In-memory [PodcastAudioPreferenceRepository] that resolves against
/// caller-supplied global settings.
class FakePodcastAudioPreferenceRepository
    implements PodcastAudioPreferenceRepository {
  FakePodcastAudioPreferenceRepository(this._globalSettings);

  final AudioSettings Function() _globalSettings;
  final Map<int, AudioSettings> overrides = {};

  /// When true, writes throw the way a failed Isar transaction would.
  bool failWrites = false;

  void _checkWrite() {
    if (failWrites) throw StateError('write failed');
  }

  @override
  Future<AudioSettings?> get(int podcastId) async => overrides[podcastId];

  @override
  Future<void> set(int podcastId, AudioSettings settings) async {
    _checkWrite();
    overrides[podcastId] = settings;
  }

  @override
  Future<void> clear(int podcastId) async {
    _checkWrite();
    overrides.remove(podcastId);
  }

  @override
  Future<AudioSettings> resolveForPodcast(int podcastId) async =>
      overrides[podcastId] ?? _globalSettings();
}
