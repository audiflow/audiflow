import 'package:workmanager/workmanager.dart';

class BackgroundTaskRegistrar {
  BackgroundTaskRegistrar._();

  static const taskName = 'com.audiflow.backgroundRefresh';

  static Future<void> register({
    required int intervalMinutes,
    bool wifiOnly = false,
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        taskName,
        taskName,
        frequency: Duration(minutes: intervalMinutes),
        constraints: Constraints(
          networkType: wifiOnly ? NetworkType.unmetered : NetworkType.connected,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );
    } on Exception {
      // Platform channel or runtime error.
    } on Error {
      // UnimplementedError in test / unsupported platform.
    }
  }

  static Future<void> cancel() async {
    try {
      await Workmanager().cancelByUniqueName(taskName);
    } on Exception {
      // Platform channel or runtime error.
    } on Error {
      // UnimplementedError in test / unsupported platform.
    }
  }
}
