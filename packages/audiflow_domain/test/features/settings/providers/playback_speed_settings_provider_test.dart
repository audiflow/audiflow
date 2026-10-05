import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';

void main() {
  late FakeAppSettingsRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeAppSettingsRepository()
      ..playbackSpeed = 1.5
      ..recentPlaybackSpeeds = [1.5];
    container = ProviderContainer(
      overrides: [appSettingsRepositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() => container.dispose());

  PlaybackSpeedSettingsController notifier() =>
      container.read(playbackSpeedSettingsControllerProvider.notifier);

  test('seeds state from the repository', () {
    final state = container.read(playbackSpeedSettingsControllerProvider);
    expect(state.speed, 1.5);
    expect(state.recentSpeeds, [1.5]);
    expect(state.chipSpeeds, [1.0, 1.5]);
  });

  test('save records a recent speed and persists both values', () async {
    await notifier().save(2.0, commit: true);

    final state = container.read(playbackSpeedSettingsControllerProvider);
    expect(state.speed, 2.0);
    expect(state.recentSpeeds, [2.0, 1.5]);
    expect(repo.playbackSpeed, 2.0);
    expect(repo.recentPlaybackSpeeds, [2.0, 1.5]);
  });

  test('a preview step updates memory only', () async {
    await notifier().save(2.4, commit: false);

    final state = container.read(playbackSpeedSettingsControllerProvider);
    expect(state.speed, 2.4);
    expect(state.recentSpeeds, [1.5]);
    expect(repo.playbackSpeed, 1.5);
    expect(repo.recentPlaybackSpeeds, [1.5]);
  });

  test('save snaps off-grid speeds', () async {
    await notifier().save(1.25, commit: true);

    expect(container.read(playbackSpeedSettingsControllerProvider).speed, 1.3);
    expect(repo.playbackSpeed, 1.3);
  });

  test('recordRecent adds a recent speed without changing the speed', () async {
    await notifier().recordRecent(2.0);

    final state = container.read(playbackSpeedSettingsControllerProvider);
    expect(state.speed, 1.5);
    expect(state.recentSpeeds, [2.0, 1.5]);
    expect(repo.playbackSpeed, 1.5);
    expect(repo.recentPlaybackSpeeds, [2.0, 1.5]);
  });

  test('chip speeds stay ascending regardless of recency', () async {
    await notifier().save(0.8, commit: true);
    await notifier().save(2.0, commit: true);

    final state = container.read(playbackSpeedSettingsControllerProvider);
    expect(state.recentSpeeds, [2.0, 0.8]);
    expect(state.chipSpeeds, [0.8, PlaybackSpeedScale.normal, 2.0]);
  });
}
