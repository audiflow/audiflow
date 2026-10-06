import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/library/presentation/controllers/library_controller.dart';
import 'background/background_task_registrar.dart';

/// Observes app lifecycle events and triggers feed syncs.
///
/// - On launch: force syncs all subscribed feeds.
/// - On resume: syncs feeds where 1+ hour has elapsed since last refresh.
/// - On launch and resume: removes played auto downloads past their grace
///   period.
class AppLifecycleObserver extends ConsumerStatefulWidget {
  const AppLifecycleObserver({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onResume,
      onHide: _onHide,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLaunch());
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _onLaunch() {
    _syncFeeds(forceRefresh: true);
    _sweepPlayedDownloads();
  }

  void _onResume() {
    _syncFeeds(forceRefresh: false);
    _updateBackgroundRegistration();
    _processPendingDownloads();
    _sweepPlayedDownloads();
  }

  /// Schedules a background download task when the app moves to background
  /// so iOS can continue processing pending downloads via BGProcessingTask.
  /// Also re-locks the parental control gate so restricted content is
  /// protected the next time the user opens the app.
  void _onHide() {
    ref.read(parentalControlGateProvider.notifier).lock();
    _runUnawaited(
      _scheduleBackgroundDownloads(),
      'while scheduling background downloads on app hide',
    );
  }

  void _sweepPlayedDownloads() {
    _runUnawaited(
      ref.read(downloadRetentionServiceProvider).sweepPlayed(),
      'while removing played auto downloads',
    );
  }

  /// Fire-and-forget [task], reporting failures instead of dropping them.
  void _runUnawaited(Future<void> task, String context) {
    unawaited(
      task.catchError((Object error, StackTrace stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'app_lifecycle_observer',
            context: ErrorDescription(context),
          ),
        );
      }),
    );
  }

  Future<void> _scheduleBackgroundDownloads() async {
    final downloadRepo = ref.read(downloadRepositoryProvider);
    final pending = await downloadRepo.getByStatus(
      const DownloadStatus.pending(),
    );
    final downloading = await downloadRepo.getByStatus(
      const DownloadStatus.downloading(),
    );
    final allActive = [...pending, ...downloading];
    if (allActive.isEmpty) return;

    final requireWifiOnly = allActive.every((t) => t.wifiOnly);
    await BackgroundTaskRegistrar.registerDownloadTask(
      wifiOnly: requireWifiOnly,
    );
  }

  Future<void> _updateBackgroundRegistration() async {
    await BackgroundTaskRegistrar.syncWithSettings(
      ref.read(appSettingsRepositoryProvider),
    );
  }

  Future<void> _syncFeeds({required bool forceRefresh}) async {
    final syncService = ref.read(feedSyncServiceProvider);
    final result = await syncService.syncAllSubscriptions(
      forceRefresh: forceRefresh,
    );
    if (!mounted) return;

    if (0 < result.successCount) {
      ref.invalidate(librarySubscriptionsProvider);
    }
  }

  /// Picks up any pending downloads that were enqueued by background
  /// refresh but not yet processed (e.g. download task was deferred
  /// or killed by the OS). Also recovers tasks stuck in "downloading"
  /// status from a prior foreground isolate that was suspended/killed
  /// mid-download — without this, those tasks linger forever because
  /// `getNextPending` only matches "pending".
  void _processPendingDownloads() {
    unawaited(_recoverAndStartQueue());
  }

  Future<void> _recoverAndStartQueue() async {
    final downloadRepo = ref.read(downloadRepositoryProvider);
    final stuck = await downloadRepo.getByStatus(
      const DownloadStatus.downloading(),
    );
    for (final task in stuck) {
      await downloadRepo.updateStatus(
        id: task.id,
        status: const DownloadStatus.pending(),
      );
    }
    await ref.read(downloadQueueServiceProvider).startQueue();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
