import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:workmanager/workmanager.dart';

/// Keys for the inputData map passed to the background task.
class BackgroundInputKeys {
  BackgroundInputKeys._();

  static const autoSync = 'autoSync';
  static const wifiOnlySync = 'wifiOnlySync';
  static const notifyNewEpisodes = 'notifyNewEpisodes';
  static const wifiOnlyDownload = 'wifiOnlyDownload';
  static const syncIntervalMinutes = 'syncIntervalMinutes';
}

class BackgroundTaskRegistrar {
  BackgroundTaskRegistrar._();

  static const taskName = 'com.audiflow.backgroundRefresh';
  static const downloadTaskName = 'com.audiflow.backgroundDownload';

  /// Snapshots the current settings into a map for the background isolate.
  static Map<String, dynamic> buildInputData(AppSettingsRepository repo) => {
    BackgroundInputKeys.autoSync: repo.getAutoSync(),
    BackgroundInputKeys.wifiOnlySync: repo.getWifiOnlySync(),
    BackgroundInputKeys.notifyNewEpisodes: repo.getNotifyNewEpisodes(),
    BackgroundInputKeys.wifiOnlyDownload: repo.getWifiOnlyDownload(),
    BackgroundInputKeys.syncIntervalMinutes: repo.getSyncIntervalMinutes(),
  };

  /// Registers the periodic background refresh task.
  ///
  /// When [replaceExisting] is true, any pending task is cancelled and
  /// rescheduled from scratch (`now + interval`). Use this when the user
  /// changes sync settings (interval, wifi-only, notifications) so that
  /// the updated [inputData] snapshot takes effect immediately.
  ///
  /// When false (default), the existing schedule is preserved if a task
  /// is already registered. This avoids resetting the timer on every app
  /// resume, which would perpetually delay the first execution.
  static Future<void> register({
    required int intervalMinutes,
    required Map<String, dynamic> inputData,
    bool wifiOnly = false,
    bool replaceExisting = false,
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        taskName,
        taskName,
        frequency: Duration(minutes: intervalMinutes),
        inputData: inputData,
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

  /// Schedules a one-off background download task to process pending
  /// downloads enqueued by the feed sync.
  static Future<void> registerDownloadTask({bool wifiOnly = false}) async {
    try {
      await Workmanager().registerOneOffTask(
        downloadTaskName,
        downloadTaskName,
        constraints: Constraints(
          networkType: wifiOnly ? NetworkType.unmetered : NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 1),
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
