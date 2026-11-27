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
/// - On launch: drops download records whose file is gone (for example
///   after a restore to a new device, which carries no audio).
/// - On hide: writes the continuity snapshot when it is due.
/// - Throughout: keeps sync connected while the app is in the foreground
///   or playing, and disconnected otherwise (plan P10).
class AppLifecycleObserver extends ConsumerStatefulWidget {
  const AppLifecycleObserver({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver> {
  late final AppLifecycleListener _lifecycleListener;
  StreamSubscription<bool>? _playing;
  bool _foreground = true;
  bool _isPlaying = false;

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
    unawaited(_playing?.cancel());
    super.dispose();
  }

  void _onLaunch() {
    _startSync();
    _syncFeeds(forceRefresh: true);
    _sweepPlayedDownloads();
    _runUnawaited(
      ref.read(downloadServiceProvider).reconcileCompletedFiles(),
      'while removing downloads whose file is missing',
    );
  }

  void _onResume() {
    _foreground = true;
    _updateSyncActivity();
    // Playback may have kept sync active all along; a refused device
    // still gets its retry on coming back.
    ref.read(syncControllerProvider).onForeground();
    _syncFeeds(forceRefresh: false);
    _updateBackgroundRegistration();
    _processPendingDownloads();
    _sweepPlayedDownloads();
  }

  /// Schedules a background download task when the app moves to background
  /// so iOS can continue processing pending downloads via BGProcessingTask.
  /// Also re-locks the parental control gate so restricted content is
  /// protected the next time the user opens the app, and refreshes the
  /// continuity snapshot: the user may be about to move to a new phone.
  void _onHide() {
    _foreground = false;
    _updateSyncActivity();
    ref.read(parentalControlGateProvider.notifier).lock();
    // Never throws; the scheduler logs its own failures.
    unawaited(ref.read(autoSnapshotSchedulerProvider).onBackground());
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
    _runUnawaited(
      ref.read(streamCacheServiceProvider).sweep(),
      'while removing cached audio of finished episodes',
    );
  }

  /// Loads the sync secrets, then connects while the app is active.
  /// Playback keeps it connected in the background, so a position change
  /// reaches the user's other devices (plan P10).
  void _startSync() {
    // Synced positions reach the player; nothing without a relay.
    ref.read(syncPlaybackBridgeProvider);
    _playing = ref.read(audioPlayerProvider).playingStream.listen((playing) {
      _isPlaying = playing;
      _updateSyncActivity();
    });
    _runUnawaited(
      ref.read(syncControllerProvider).load().then((_) {
        if (mounted) _updateSyncActivity();
      }),
      'while loading sync',
    );
  }

  void _updateSyncActivity() {
    ref.read(syncControllerProvider).setActive(_foreground || _isPlaying);
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
