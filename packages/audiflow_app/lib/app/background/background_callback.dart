import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
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

    Isar? isar;
    Dio? dio;

    try {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open(
        isarSchemas,
        directory: dir.path,
        name: 'audiflow',
      );

      final prefs = await SharedPreferences.getInstance();
      final ds = SharedPreferencesDataSource(prefs);
      final settingsRepo = AppSettingsRepositoryImpl(ds);

      if (settingsRepo.getWifiOnlySync()) {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (!connectivityResult.contains(ConnectivityResult.wifi)) {
          logger.i('WiFi-only sync enabled but not on WiFi, skipping');
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
        syncFeed: executor.syncFeed,
        showNotification: (map) async {
          final plugin = await notificationService.initialize();
          await notificationService.showNewEpisodesNotification(plugin, map);
        },
        logger: logger,
      );

      await refreshService.execute();
    } catch (e, stack) {
      logger.e('Background refresh failed', error: e, stackTrace: stack);
    } finally {
      dio?.close();
      if (isar != null && isar.isOpen) {
        await isar.close();
      }
    }

    return true;
  });
}
