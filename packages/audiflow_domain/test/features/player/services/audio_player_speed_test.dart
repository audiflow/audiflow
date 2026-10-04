import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';

void main() {
  late FakeAppSettingsRepository repo;
  late FakeAnalyticsService analytics;
  late ProviderContainer container;

  setUp(() {
    repo = FakeAppSettingsRepository();
    analytics = FakeAnalyticsService();
    container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(repo),
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
    );
  });

  tearDown(() => container.dispose());

  AudioPlayerController controller() =>
      container.read(audioPlayerControllerProvider.notifier);

  PlaybackSpeedSettings settings() =>
      container.read(playbackSpeedSettingsControllerProvider);

  test('setSpeed snaps, applies, records and logs once', () async {
    await controller().setSpeed(1.25);

    expect(container.read(audioPlayerProvider).speed, 1.3);
    expect(settings().speed, 1.3);
    expect(settings().recentSpeeds, [1.3]);
    expect(repo.playbackSpeed, 1.3);
    expect(analytics.events.whereType<PlaybackSpeedChanged>(), hasLength(1));
  });

  test('transient setSpeed skips recents and analytics', () async {
    await controller().setSpeed(1.6, transient: true);
    await controller().setSpeed(1.7, transient: true);

    expect(container.read(audioPlayerProvider).speed, 1.7);
    expect(settings().speed, 1.7);
    expect(settings().recentSpeeds, isEmpty);
    expect(analytics.events.whereType<PlaybackSpeedChanged>(), isEmpty);

    await controller().setSpeed(1.7);

    expect(settings().recentSpeeds, [1.7]);
    expect(analytics.events.whereType<PlaybackSpeedChanged>(), hasLength(1));
  });
}
