import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_app_settings_repository.dart';

/// In-memory fake for [PodcastAudioPreferenceLocalDatasource].
class _FakeDatasource implements PodcastAudioPreferenceLocalDatasource {
  final rows = <int, PodcastAudioPreference>{};

  @override
  Future<PodcastAudioPreference?> get(int podcastId) async => rows[podcastId];

  @override
  Future<void> upsert(
    int podcastId, {
    required double speed,
    required bool skipSilence,
    required bool voiceBoost,
  }) async {
    rows[podcastId] = PodcastAudioPreference()
      ..podcastId = podcastId
      ..speed = speed
      ..skipSilence = skipSilence
      ..voiceBoost = voiceBoost;
  }

  @override
  Future<void> delete(int podcastId) async => rows.remove(podcastId);
}

AudioSettings _settings(
  double speed, {
  bool skipSilence = false,
  bool voiceBoost = false,
}) => AudioSettings(
  speed: speed,
  effects: PlaybackEffects(skipSilence: skipSilence, voiceBoost: voiceBoost),
);

void main() {
  late _FakeDatasource datasource;
  late FakeAppSettingsRepository settings;
  late PodcastAudioPreferenceRepository repo;

  setUp(() {
    datasource = _FakeDatasource();
    settings = FakeAppSettingsRepository()..playbackSpeed = 1.2;
    repo = PodcastAudioPreferenceRepositoryImpl(datasource, settings);
  });

  test('get returns null without an override', () async {
    check(await repo.get(1)).isNull();
  });

  test('set snaps the speed to the grid', () async {
    await repo.set(1, _settings(1.47));

    check(datasource.rows[1]!.speed).equals(1.5);
    check(await repo.get(1)).equals(_settings(1.5));
  });

  test('set stores the effects', () async {
    await repo.set(1, _settings(1.0, skipSilence: true));

    check(datasource.rows[1]!.skipSilence).equals(true);
    check(datasource.rows[1]!.voiceBoost).equals(false);
    check(await repo.get(1)).equals(_settings(1.0, skipSilence: true));
  });

  test('get fills effects missing from an older row with global', () async {
    settings
      ..skipSilence = true
      ..voiceBoost = true;
    datasource.rows[1] = PodcastAudioPreference()
      ..podcastId = 1
      ..speed = 1.5;

    check(
      await repo.get(1),
    ).equals(_settings(1.5, skipSilence: true, voiceBoost: true));
  });

  test('clear removes the override', () async {
    await repo.set(1, _settings(1.5));
    await repo.clear(1);

    check(await repo.get(1)).isNull();
  });

  group('resolveForPodcast', () {
    test('prefers the podcast override', () async {
      await repo.set(1, _settings(1.5, voiceBoost: true));

      check(
        await repo.resolveForPodcast(1),
      ).equals(_settings(1.5, voiceBoost: true));
    });

    test('falls back to the global settings', () async {
      settings.skipSilence = true;
      await repo.set(2, _settings(1.5));

      check(
        await repo.resolveForPodcast(1),
      ).equals(_settings(1.2, skipSilence: true));
    });
  });
}
