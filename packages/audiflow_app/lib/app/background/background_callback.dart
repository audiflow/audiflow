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
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');
    if (sentryDsn.isNotEmpty) {
      await Sentry.init((options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0;
      });
    }

    Sentry.addBreadcrumb(
      Breadcrumb(message: 'Background refresh started', category: 'background'),
    );

    Isar? isar;
    Dio? dio;

    try {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open(
        isarSchemas,
        directory: dir.path,
        name: 'audiflow',
      );

      Sentry.addBreadcrumb(
        Breadcrumb(message: 'Isar opened', category: 'background'),
      );

      final prefs = await SharedPreferences.getInstance();
      final ds = SharedPreferencesDataSource(prefs);
      final settingsRepo = AppSettingsRepositoryImpl(ds);

      if (settingsRepo.getWifiOnlySync()) {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (!connectivityResult.contains(ConnectivityResult.wifi)) {
          logger.i('WiFi-only sync enabled but not on WiFi, skipping');
          Sentry.addBreadcrumb(
            Breadcrumb(
              message: 'Skipped: WiFi-only but not on WiFi',
              category: 'background',
            ),
          );
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

      final subscriptions = await subscriptionRepo.getSubscriptions();
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Found ${subscriptions.length} subscriptions to sync',
          category: 'background',
        ),
      );

      final notificationService = BackgroundNotificationService(logger: logger);

      final refreshService = BackgroundRefreshService(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        downloadRepo: downloadRepo,
        settingsRepo: settingsRepo,
        syncFeed: (sub) async {
          Sentry.addBreadcrumb(
            Breadcrumb(
              message: 'Syncing feed: ${sub.title}',
              category: 'background.sync',
            ),
          );
          final result = await executor.syncFeed(sub);
          Sentry.addBreadcrumb(
            Breadcrumb(
              message:
                  'Feed synced: ${sub.title}, '
                  'newEpisodes=${result.newEpisodeCount ?? 0}',
              category: 'background.sync',
            ),
          );
          return result;
        },
        showNotification: (map) async {
          final plugin = await notificationService.initialize();
          await notificationService.showNewEpisodesNotification(plugin, map);
        },
        logger: logger,
      );

      await refreshService.execute();

      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Background refresh completed',
          category: 'background',
        ),
      );
    } catch (e, stack) {
      logger.e('Background refresh failed', error: e, stackTrace: stack);
      await Sentry.captureException(e, stackTrace: stack);
    } finally {
      dio?.close();
      if (isar != null && isar.isOpen) {
        await isar.close();
      }
      await Sentry.close();
    }

    return true;
  });
}
