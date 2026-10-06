import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_app/app/background/background_settings_repository.dart';
import 'package:audiflow_app/app/background/background_task_registrar.dart';
import 'package:checks/checks.dart';

void main() {
  group('BackgroundTaskRegistrar', () {
    test('taskName is a valid identifier', () {
      expect(
        BackgroundTaskRegistrar.taskName,
        'com.audiflow.backgroundRefresh',
      );
    });

    test('register does not throw on unsupported platform', () async {
      // Workmanager throws UnimplementedError in test environments;
      // register() should swallow it gracefully.
      await expectLater(
        BackgroundTaskRegistrar.register(
          intervalMinutes: 60,
          inputData: const {},
        ),
        completes,
      );
    });

    test('buildInputData snapshots the language setting', () {
      final data = BackgroundTaskRegistrar.buildInputData(
        BackgroundSettingsRepository({BackgroundInputKeys.locale: 'ja'}),
      );

      check(data[BackgroundInputKeys.locale]).equals('ja');
    });

    test('buildInputData snapshots the auto-download keep count', () {
      final data = BackgroundTaskRegistrar.buildInputData(
        BackgroundSettingsRepository({
          BackgroundInputKeys.autoDownloadKeepCount: 10,
        }),
      );

      check(data[BackgroundInputKeys.autoDownloadKeepCount]).equals(10);
    });

    test('buildInputData omits the language when following the system', () {
      final data = BackgroundTaskRegistrar.buildInputData(
        BackgroundSettingsRepository(null),
      );

      check(data.containsKey(BackgroundInputKeys.locale)).isFalse();
    });

    test('syncWithSettings does not throw on unsupported platform', () async {
      for (final autoSync in [true, false]) {
        await check(
          BackgroundTaskRegistrar.syncWithSettings(
            BackgroundSettingsRepository({
              BackgroundInputKeys.autoSync: autoSync,
            }),
            replaceExisting: true,
          ),
        ).completes();
      }
    });

    test('cancel does not throw on unsupported platform', () async {
      await expectLater(BackgroundTaskRegistrar.cancel(), completes);
    });
  });
}
