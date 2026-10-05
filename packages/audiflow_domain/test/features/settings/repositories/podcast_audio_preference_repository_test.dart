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
  Future<void> upsertSpeed(int podcastId, double speed) async {
    rows[podcastId] = (rows[podcastId] ?? PodcastAudioPreference())
      ..podcastId = podcastId
      ..speed = speed;
  }

  @override
  Future<void> delete(int podcastId) async => rows.remove(podcastId);
}

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
    await repo.set(1, const AudioSettings(speed: 1.47));

    check(datasource.rows[1]!.speed).equals(1.5);
    check(await repo.get(1)).equals(const AudioSettings(speed: 1.5));
  });

  test('clear removes the override', () async {
    await repo.set(1, const AudioSettings(speed: 1.5));
    await repo.clear(1);

    check(await repo.get(1)).isNull();
  });

  group('resolveForPodcast', () {
    test('prefers the podcast override', () async {
      await repo.set(1, const AudioSettings(speed: 1.5));

      check(
        await repo.resolveForPodcast(1),
      ).equals(const AudioSettings(speed: 1.5));
    });

    test('falls back to the global speed', () async {
      await repo.set(2, const AudioSettings(speed: 1.5));

      check(
        await repo.resolveForPodcast(1),
      ).equals(const AudioSettings(speed: 1.2));
    });
  });
}
