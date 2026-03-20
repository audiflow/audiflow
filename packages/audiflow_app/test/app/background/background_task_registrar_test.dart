import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_app/app/background/background_task_registrar.dart';

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
        BackgroundTaskRegistrar.register(intervalMinutes: 60),
        completes,
      );
    });

    test('cancel does not throw on unsupported platform', () async {
      await expectLater(BackgroundTaskRegistrar.cancel(), completes);
    });
  });
}
