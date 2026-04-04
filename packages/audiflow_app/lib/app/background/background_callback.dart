import 'dart:developer' as developer;

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'background_settings_repository.dart';
import 'background_task_registrar.dart';

// Temporary diagnostic helper for background refresh Sentry investigation.
// Remove once the issue is resolved.
void _bgDebug(String message) {
  final stamped = '[BG-DEBUG ${DateTime.now().toIso8601String()}] $message';
  debugPrint(stamped);
  developer.log(stamped, name: 'BackgroundRefresh');
}

@pragma('vm:entry-point')
void backgroundCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    // Ensure platform channels are available in the background isolate.
    // Without this, plugins like SharedPreferences (Pigeon-based) fail with
    // "Unable to establish connection on channel" errors.
    WidgetsFlutterBinding.ensureInitialized();

    _bgDebug('executeTask called — taskName=$taskName');
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
          options.debug = true;
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
      // Diagnostic: send a message event so we know the pipeline works.
      final sentryId = await Sentry.captureMessage(
        'bg-refresh: started',
        level: SentryLevel.info,
      );
      _bgDebug('captureMessage sentryId=$sentryId');
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
      final downloadRepo = DownloadRepositoryImpl(
        datasource: downloadDatasource,
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
          try {
            final plugin = await notificationService.initialize();
            await notificationService.showPerEpisodeNotifications(
              plugin,
              notifications,
            );
            if (sentryInitialized) {
              Sentry.addBreadcrumb(
                Breadcrumb(
                  message: 'Notifications dispatched: ${notifications.length}',
                  category: 'background.notification',
                ),
              );
            }
          } catch (e, stack) {
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

      if (sentryInitialized) {
        Sentry.addBreadcrumb(
          Breadcrumb(
            message: 'Background refresh completed',
            category: 'background',
          ),
        );
        // Diagnostic: send completion event with breadcrumb trail attached.
        final sentryId = await Sentry.captureMessage(
          'bg-refresh: completed',
          level: SentryLevel.info,
        );
        _bgDebug('completion captureMessage sentryId=$sentryId');
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
        _bgDebug('calling Sentry.close()');
        await Sentry.close();
        _bgDebug('Sentry.close() done');
      }
      _bgDebug('background callback finished');
    }

    return true;
  });
}
