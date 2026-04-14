import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('fadeOutAndPause restores volume after completing', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final player = container.read(audioPlayerProvider);
    await player.setVolume(1.0);

    final controller = container.read(audioPlayerControllerProvider.notifier);
    await controller.fadeOutAndPause(total: const Duration(milliseconds: 80));

    expect(player.volume, closeTo(1.0, 0.001));
  });

  test('cancelFade aborts in-flight fade and restores volume', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final player = container.read(audioPlayerProvider);
    await player.setVolume(1.0);

    final controller = container.read(audioPlayerControllerProvider.notifier);
    final fadeFuture = controller.fadeOutAndPause(
      total: const Duration(seconds: 8),
    );

    await Future<void>.delayed(const Duration(milliseconds: 50));
    controller.cancelFade();
    await fadeFuture;

    expect(player.volume, closeTo(1.0, 0.001));
  });
}
