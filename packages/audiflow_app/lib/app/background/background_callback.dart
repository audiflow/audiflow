import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'background_task_registrar.dart';

@pragma('vm:entry-point')
void backgroundCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != BackgroundTaskRegistrar.taskName) return true;

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
      if (sentryDsn.isNotEmpty) {
        await Sentry.init((options) {
          options.dsn = sentryDsn;
          options.tracesSampleRate = 0;
          options.environment = sentryEnvironment;
        });
        sentryInitialized = true;
      }
    } catch (e, stack) {
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

      final prefs = await SharedPreferences.getInstance();
      final ds = SharedPreferencesDataSource(prefs);
      final settingsRepo = AppSettingsRepositoryImpl(ds);

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
        showNotification: (map) async {
          final plugin = await notificationService.initialize();
          await notificationService.showNewEpisodesNotification(plugin, map);
        },
        logger: logger,
      );

      await refreshService.execute();

      if (sentryInitialized) {
        Sentry.addBreadcrumb(
          Breadcrumb(
            message: 'Background refresh completed',
            category: 'background',
          ),
        );
      }
    } catch (e, stack) {
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
        await Sentry.close();
      }
    }

    return true;
  });
}
