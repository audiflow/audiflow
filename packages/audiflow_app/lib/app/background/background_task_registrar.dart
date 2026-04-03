import 'package:workmanager/workmanager.dart';

class BackgroundTaskRegistrar {
  BackgroundTaskRegistrar._();

  static const taskName = 'com.audiflow.backgroundRefresh';

  /// Registers the periodic background refresh task.
  ///
  /// When [replaceExisting] is true, any pending task is cancelled and
  /// rescheduled from scratch (`now + interval`). Use this when the user
  /// changes sync settings (interval, wifi-only).
  ///
  /// When false (default), the existing schedule is preserved if a task
  /// is already registered. This avoids resetting the timer on every app
  /// resume, which would perpetually delay the first execution.
  static Future<void> register({
    required int intervalMinutes,
    bool wifiOnly = false,
    bool replaceExisting = false,
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        taskName,
        taskName,
        frequency: Duration(minutes: intervalMinutes),
        constraints: Constraints(
          networkType: wifiOnly ? NetworkType.unmetered : NetworkType.connected,
        ),
        existingWorkPolicy: replaceExisting
            ? ExistingPeriodicWorkPolicy.replace
            : ExistingPeriodicWorkPolicy.keep,
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
