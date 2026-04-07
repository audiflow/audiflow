import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/library/presentation/controllers/library_controller.dart';
import 'background/background_task_registrar.dart';

/// Observes app lifecycle events and triggers feed syncs.
///
/// - On launch: force syncs all subscribed feeds.
/// - On resume: syncs feeds where 1+ hour has elapsed since last refresh.
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
    _lifecycleListener = AppLifecycleListener(onResume: _onResume);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLaunch());
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _onLaunch() {
    _syncFeeds(forceRefresh: true);
  }

  void _onResume() {
    _syncFeeds(forceRefresh: false);
    _updateBackgroundRegistration();
    _processPendingDownloads();
  }

  Future<void> _updateBackgroundRegistration() async {
    final settingsRepo = ref.read(appSettingsRepositoryProvider);
    if (settingsRepo.getAutoSync()) {
      await BackgroundTaskRegistrar.register(
        intervalMinutes: settingsRepo.getSyncIntervalMinutes(),
        wifiOnly: settingsRepo.getWifiOnlySync(),
        inputData: BackgroundTaskRegistrar.buildInputData(settingsRepo),
      );
    } else {
      await BackgroundTaskRegistrar.cancel();
    }
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
  /// or killed by the OS).
  void _processPendingDownloads() {
    ref.read(downloadQueueServiceProvider).startQueue();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
