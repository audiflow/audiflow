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
        // Use replace so the latest derived wifiOnly constraint is applied.
        // With keep, a previously-enqueued task's constraints are preserved
        // even when the pending-task mix has changed.
        existingWorkPolicy: ExistingWorkPolicy.replace,
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
    await _cancelByName(taskName);
  }

  /// Unschedules both the periodic refresh and the one-off download task.
  ///
  /// Used by "Reset All Data" so no background task starts after storage
  /// is cleared. A task that is already executing is stopped by the
  /// platform asynchronously (Android) or runs to completion (iOS), so this
  /// is best effort for in-flight work. The periodic task is re-registered
  /// on the next app resume.
  static Future<void> cancelAll() async {
    await _cancelByName(taskName);
    await _cancelByName(downloadTaskName);
  }

  static Future<void> _cancelByName(String name) async {
    try {
      await Workmanager().cancelByUniqueName(name);
    } on Exception {
      // Platform channel or runtime error.
    } on Error {
      // UnimplementedError in test / unsupported platform.
    }
  }
}
