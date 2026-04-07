import 'dart:developer' as developer;
import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'background_settings_repository.dart';
import 'background_task_registrar.dart';

// Temporary diagnostic file logger for background refresh investigation.
// Writes to <appDocDir>/bg_refresh_diag.log so it can be pulled from
// device even on release builds where debugPrint is silent.
// Remove once investigation is resolved.
File? _diagLogFile;

Future<void> _initDiagLog() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    _diagLogFile = File('${dir.path}/bg_refresh_diag.log');
  } catch (_) {
    // path_provider not ready — fall back to console only
  }
}

void _bgDebug(String message) {
  final stamped = '[BG ${DateTime.now().toIso8601String()}] $message';
  if (kDebugMode) {
    debugPrint(stamped);
    developer.log(stamped, name: 'BackgroundRefresh');
  }
  try {
    _diagLogFile?.writeAsStringSync('$stamped\n', mode: FileMode.append);
  } catch (_) {
    // Best-effort — never crash the background task for logging
  }
}

// Temporary diagnostic wrapper for auto-download investigation.
// Delegates all calls to the real repo, adding Sentry breadcrumbs for
// createDownload. Remove once investigation is resolved.
class _DiagDownloadRepo implements DownloadRepository {
  _DiagDownloadRepo(this._inner, {required bool sentryEnabled})
    : _sentry = sentryEnabled;

  final DownloadRepository _inner;
  final bool _sentry;

  @override
  Future<DownloadTask?> createDownload({
    required int episodeId,
    required String audioUrl,
    required bool wifiOnly,
  }) async {
    _bgDebug(
      'auto-download: createDownload '
      'episodeId=$episodeId wifiOnly=$wifiOnly',
    );
    if (_sentry) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'auto-download: createDownload episodeId=$episodeId',
          category: 'background.download',
          data: {'audioUrl': audioUrl, 'wifiOnly': wifiOnly},
        ),
      );
    }
    final task = await _inner.createDownload(
      episodeId: episodeId,
      audioUrl: audioUrl,
      wifiOnly: wifiOnly,
    );
    _bgDebug(
      'auto-download: createDownload result=${task != null ? "created" : "skipped (duplicate)"}',
    );
    if (_sentry) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message:
              'auto-download: ${task != null ? "created" : "skipped"} '
              'episodeId=$episodeId',
          category: 'background.download',
        ),
      );
    }
    return task;
  }

  // --- pass-through ---

  @override
  Future<void> delete(int id) => _inner.delete(id);
  @override
  Future<int> deleteAllCompleted() => _inner.deleteAllCompleted();
  @override
  Future<int> getActiveCount() => _inner.getActiveCount();
  @override
  Future<List<DownloadTask>> getAll() => _inner.getAll();
  @override
  Future<DownloadTask?> getById(int id) => _inner.getById(id);
  @override
  Future<DownloadTask?> getByEpisodeId(int episodeId) =>
      _inner.getByEpisodeId(episodeId);
  @override
  Future<List<DownloadTask>> getByStatus(DownloadStatus status) =>
      _inner.getByStatus(status);
  @override
  Future<DownloadTask?> getCompletedForEpisode(int episodeId) =>
      _inner.getCompletedForEpisode(episodeId);
  @override
  Future<DownloadTask?> getNextPending({required bool isOnWifi}) =>
      _inner.getNextPending(isOnWifi: isOnWifi);
  @override
  Future<int> getTotalStorageUsed() => _inner.getTotalStorageUsed();
  @override
  Future<void> incrementRetryCount(int id) => _inner.incrementRetryCount(id);
  @override
  Future<void> updateProgress({
    required int id,
    required int downloadedBytes,
    int? totalBytes,
  }) => _inner.updateProgress(
    id: id,
    downloadedBytes: downloadedBytes,
    totalBytes: totalBytes,
  );
  @override
  Future<void> updateStatus({
    required int id,
    required DownloadStatus status,
    String? localPath,
    String? lastError,
  }) => _inner.updateStatus(
    id: id,
    status: status,
    localPath: localPath,
    lastError: lastError,
  );
  @override
  Stream<List<DownloadTask>> watchAll() => _inner.watchAll();
  @override
  Stream<DownloadTask?> watchByEpisodeId(int episodeId) =>
      _inner.watchByEpisodeId(episodeId);
  @override
  Stream<List<DownloadTask>> watchByStatus(DownloadStatus status) =>
      _inner.watchByStatus(status);
}

@pragma('vm:entry-point')
void backgroundCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    // Ensure platform channels are available in the background isolate.
    // Without this, plugins that use platform channels (Isar, connectivity_plus,
    // path_provider, etc.) fail with "Unable to establish connection on channel"
    // errors.
    WidgetsFlutterBinding.ensureInitialized();
    await _initDiagLog();

    _bgDebug('executeTask called — taskName=$taskName');
    if (taskName == BackgroundTaskRegistrar.downloadTaskName) {
      return _executeDownloadTask(inputData);
    }
    if (taskName != BackgroundTaskRegistrar.taskName) {
      _bgDebug('taskName mismatch, returning true');
      return true;
    }

    final logger = Logger(
      printer: PrefixPrinter(PrettyPrinter(methodCount: 0)),
    );

    // Initialize Sentry in the background isolate so crashes are reported.
    // Wrapped in try/catch so a Sentry init failure (e.g. invalid DSN) does
    // not abort the entire background refresh.
    var sentryInitialized = false;
    try {
      const sentryDsn = String.fromEnvironment('SENTRY_DSN');
      const sentryEnvironment = String.fromEnvironment(
        'SENTRY_ENVIRONMENT',
        defaultValue: 'unknown',
      );
      _bgDebug(
        'SENTRY_DSN isEmpty=${sentryDsn.isEmpty}, '
        'env=$sentryEnvironment',
      );
      if (sentryDsn.isNotEmpty) {
        await Sentry.init((options) {
          options.dsn = sentryDsn;
          options.tracesSampleRate = 0;
          options.environment = sentryEnvironment;
          options.debug = kDebugMode;
        });
        sentryInitialized = true;
        _bgDebug('Sentry.init succeeded');
      } else {
        _bgDebug('SENTRY_DSN is empty — Sentry will NOT initialize');
      }
    } catch (e, stack) {
      _bgDebug('Sentry.init FAILED: $e');
      logger.w(
        'Sentry init failed, continuing without telemetry',
        error: e,
        stackTrace: stack,
      );
    }

    if (sentryInitialized) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Background refresh started',
          category: 'background',
        ),
      );
      // Diagnostic: verify background Sentry pipeline works.
      // Remove once investigation is resolved.
      final startId = await Sentry.captureMessage(
        'bg-refresh: started',
        level: SentryLevel.info,
      );
      _bgDebug('captureMessage sentryId=$startId');
    }

    Isar? isar;
    Dio? dio;

    try {
      final dir = await getApplicationDocumentsDirectory();
      isar = await openIsarWithRecovery(directory: dir.path, logger: logger);

      if (sentryInitialized) {
        Sentry.addBreadcrumb(
          Breadcrumb(message: 'Isar opened', category: 'background'),
        );
      }

      final settingsRepo = BackgroundSettingsRepository(inputData);

      if (settingsRepo.getWifiOnlySync()) {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (!connectivityResult.contains(ConnectivityResult.wifi)) {
          logger.i('WiFi-only sync enabled but not on WiFi, skipping');
          if (sentryInitialized) {
            Sentry.addBreadcrumb(
              Breadcrumb(
                message: 'Skipped: WiFi-only but not on WiFi',
                category: 'background',
              ),
            );
          }
          await isar.close();
          return true;
        }
      }

      dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final subscriptionDatasource = SubscriptionLocalDatasource(isar);
      final subscriptionRepo = SubscriptionRepositoryImpl(
        datasource: subscriptionDatasource,
      );

      final episodeDatasource = EpisodeLocalDatasource(isar);
      final episodeRepo = EpisodeRepositoryImpl(datasource: episodeDatasource);

      final downloadDatasource = DownloadLocalDatasource(isar);
      final downloadRepoImpl = DownloadRepositoryImpl(
        datasource: downloadDatasource,
      );
      final downloadRepo = _DiagDownloadRepo(
        downloadRepoImpl,
        sentryEnabled: sentryInitialized,
      );

      final feedParser = FeedParserService(logger: logger);

      final executor = FeedSyncExecutor(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        settingsRepo: settingsRepo,
        feedParser: feedParser,
        dio: dio,
        logger: logger,
      );

      final notificationService = BackgroundNotificationService(logger: logger);

      final refreshService = BackgroundRefreshService(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        downloadRepo: downloadRepo,
        settingsRepo: settingsRepo,
        syncFeed: (sub) async {
          if (sentryInitialized) {
            Sentry.addBreadcrumb(
              Breadcrumb(
                message: 'Syncing feed: ${sub.itunesId}',
                category: 'background.sync',
              ),
            );
          }
          final result = await executor.syncFeed(sub);
          if (sentryInitialized) {
            Sentry.addBreadcrumb(
              Breadcrumb(
                message:
                    'Feed synced: ${sub.itunesId}, '
                    'newEpisodes=${result.newEpisodeCount ?? 0}',
                category: 'background.sync',
              ),
            );
          }
          return result;
        },
        showNotification: (notifications) async {
          if (sentryInitialized) {
            Sentry.addBreadcrumb(
              Breadcrumb(
                message: 'Showing ${notifications.length} notification(s)',
                category: 'background.notification',
              ),
            );
          }
          _bgDebug('showNotification called — count=${notifications.length}');
          try {
            _bgDebug('initializing notification plugin');
            final plugin = await notificationService.initialize();
            _bgDebug('notification plugin initialized');

            // Diagnostic: check if notification permissions are granted.
            final resolved = plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();
            if (resolved != null) {
              final pending = await plugin.pendingNotificationRequests();
              _bgDebug(
                'iOS notification impl resolved, '
                'pending=${pending.length}',
              );
            } else {
              _bgDebug(
                'iOS notification impl NOT resolved '
                '(may indicate plugin init issue)',
              );
            }

            if (sentryInitialized) {
              await Sentry.captureMessage(
                'bg-notification: dispatching '
                '${notifications.length} notification(s)',
                level: SentryLevel.info,
                withScope: (scope) {
                  scope.setContexts('notification_diag', {
                    'notification_count': notifications.length,
                    'ios_impl_resolved': resolved != null,
                    'episodes': notifications
                        .map((n) => '${n.podcastTitle}: ${n.episodeTitle}')
                        .toList(),
                  });
                },
              );
            }

            await notificationService.showPerEpisodeNotifications(
              plugin,
              notifications,
            );
            _bgDebug('notifications dispatched successfully');
            if (sentryInitialized) {
              Sentry.addBreadcrumb(
                Breadcrumb(
                  message: 'Notifications dispatched: ${notifications.length}',
                  category: 'background.notification',
                ),
              );
            }
          } catch (e, stack) {
            _bgDebug('notification FAILED: $e');
            logger.e(
              'Failed to show notifications',
              error: e,
              stackTrace: stack,
            );
            if (sentryInitialized) {
              await Sentry.captureException(e, stackTrace: stack);
            }
          }
        },
        logger: logger,
      );

      _bgDebug('calling refreshService.execute()');
      await refreshService.execute();
      _bgDebug('refreshService.execute() completed');

      // Schedule background download task if any downloads were enqueued.
      final pendingDownloads = await downloadRepo.getByStatus(
        const DownloadStatus.pending(),
      );
      if (pendingDownloads.isNotEmpty) {
        _bgDebug(
          'scheduling download task for '
          '${pendingDownloads.length} pending download(s)',
        );
        await BackgroundTaskRegistrar.registerDownloadTask(
          wifiOnly: settingsRepo.getWifiOnlyDownload(),
        );
      }

      if (sentryInitialized) {
        Sentry.addBreadcrumb(
          Breadcrumb(
            message: 'Background refresh completed',
            category: 'background',
          ),
        );
        // Diagnostic: send completion event with breadcrumb trail attached.
        // Remove once investigation is resolved.
        final doneId = await Sentry.captureMessage(
          'bg-refresh: completed',
          level: SentryLevel.info,
        );
        _bgDebug('completion captureMessage sentryId=$doneId');
      }
    } catch (e, stack) {
      _bgDebug('background refresh FAILED: $e');
      logger.e('Background refresh failed', error: e, stackTrace: stack);
      if (sentryInitialized) {
        await Sentry.captureException(e, stackTrace: stack);
      }
    } finally {
      dio?.close();
      if (isar != null && isar.isOpen) {
        await isar.close();
      }
      if (sentryInitialized) {
        // Allow time for the Sentry transport to send queued events.
        // Sentry.close() calls flush internally but the HTTP transport
        // may not await the response, so events are lost if the isolate
        // exits immediately.
        _bgDebug('waiting for Sentry transport to drain');
        await Future<void>.delayed(const Duration(seconds: 3));
        _bgDebug('calling Sentry.close()');
        await Sentry.close();
        _bgDebug('Sentry.close() done');
      }
      _bgDebug('background callback finished');
    }

    return true;
  });
}

/// Handles the background download processing task.
///
/// Initializes Isar, Dio, and Sentry, then processes pending download
/// tasks within a 5-minute time budget. Uses [BackgroundDownloadService]
/// which mirrors the download logic from [DownloadFileService] but runs
/// independently of the Riverpod container.
Future<bool> _executeDownloadTask(Map<String, dynamic>? inputData) async {
  _bgDebug('download task started');

  final logger = Logger(printer: PrefixPrinter(PrettyPrinter(methodCount: 0)));

  var sentryInitialized = false;
  try {
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');
    const sentryEnvironment = String.fromEnvironment(
      'SENTRY_ENVIRONMENT',
      defaultValue: 'unknown',
    );
    if (sentryDsn.isNotEmpty) {
      await Sentry.init((options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0;
        options.environment = sentryEnvironment;
        options.debug = kDebugMode;
      });
      sentryInitialized = true;
    }
  } catch (e, stack) {
    logger.w(
      'Sentry init failed in download task',
      error: e,
      stackTrace: stack,
    );
  }

  Isar? isar;
  Dio? dio;
  var success = false;

  try {
    final dir = await getApplicationDocumentsDirectory();
    isar = await openIsarWithRecovery(directory: dir.path, logger: logger);
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 10),
      ),
    );

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnWifi = connectivityResult.contains(ConnectivityResult.wifi);

    final episodeDatasource = EpisodeLocalDatasource(isar);
    final episodeRepo = EpisodeRepositoryImpl(datasource: episodeDatasource);

    final downloadDatasource = DownloadLocalDatasource(isar);
    final downloadRepo = DownloadRepositoryImpl(datasource: downloadDatasource);

    final downloadsDir = '${dir.path}/downloads';

    final service = BackgroundDownloadService(
      downloadRepo: downloadRepo,
      episodeRepo: episodeRepo,
      dio: dio,
      downloadsDir: downloadsDir,
      logger: logger,
      isOnWifi: isOnWifi,
    );

    _bgDebug('calling download service execute()');
    final count = await service.execute();
    _bgDebug('download service completed — $count downloaded');

    // Check if pending downloads remain (failures or time budget exhaustion).
    final remaining = await downloadRepo.getByStatus(
      const DownloadStatus.pending(),
    );
    // Return false so workmanager retries with backoff when tasks remain.
    success = remaining.isEmpty;

    if (sentryInitialized) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message:
              'Background download completed: $count files, '
              '${remaining.length} remaining',
          category: 'background.download',
        ),
      );
    }
  } catch (e, stack) {
    _bgDebug('download task FAILED: $e');
    logger.e('Background download failed', error: e, stackTrace: stack);
    if (sentryInitialized) {
      await Sentry.captureException(e, stackTrace: stack);
    }
  } finally {
    dio?.close();
    if (isar != null && isar.isOpen) {
      await isar.close();
    }
    if (sentryInitialized) {
      _bgDebug('waiting for Sentry transport to drain');
      await Future<void>.delayed(const Duration(seconds: 3));
      await Sentry.close();
    }
    _bgDebug('download task finished (success=$success)');
  }

  return success;
}
