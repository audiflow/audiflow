import 'package:workmanager/workmanager.dart';

class BackgroundTaskRegistrar {
  BackgroundTaskRegistrar._();

  static const taskName = 'com.audiflow.backgroundRefresh';

  static Future<void> register({required int intervalMinutes}) async {
    try {
      await Workmanager().registerPeriodicTask(
        taskName,
        taskName,
        frequency: Duration(minutes: intervalMinutes),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );
    } on UnimplementedError {
      // Workmanager is not available in test environments.
    }
  }

  static Future<void> cancel() async {
    try {
      await Workmanager().cancelByUniqueName(taskName);
    } on UnimplementedError {
      // Workmanager is not available in test environments.
    }
  }
}
