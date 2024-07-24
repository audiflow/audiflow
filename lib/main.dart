import 'dart:ui';

import 'package:audiflow/common/data/app_path_repository.dart';
import 'package:audiflow/common/data/isar_factory.dart';
import 'package:audiflow/core/shared_preferences.dart';
import 'package:audiflow/exceptions/async_error_logger.dart';
import 'package:audiflow/exceptions/error_logger.dart';
import 'package:audiflow/features/browser/common/data/isar_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/config/data/build_config.dart';
import 'package:audiflow/features/config/model/app_build_config.dart';
import 'package:audiflow/features/config/ui/audiflow_app.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/data/isar_download_repository.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/data/isar_episode_repository.dart';
import 'package:audiflow/features/feed/data/isar_podcast_repository.dart';
import 'package:audiflow/features/feed/data/isar_rss_repository.dart';
import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/data/rss_repository.dart';
import 'package:audiflow/features/queue/data/isar_queue_repository.dart';
import 'package:audiflow/features/queue/data/queue_repository.dart';
import 'package:audiflow/features/queue/service/default_queue_manager.dart';
import 'package:audiflow/features/queue/service/queue_manager.dart';
import 'package:audiflow/localization/string_hardcoded.dart';
import 'package:audiflow/services/audio/audio_player_service.dart';
import 'package:audiflow/services/audio/mobile_audio_player_service.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final buildConfig = BuildConfig.fromPackageInfo(
    packageInfo: await PackageInfo.fromPlatform(),
    appFlavor: const String.fromEnvironment('flavor'),
  );
  logger.t(buildConfig);

  final preferences = await SharedPreferences.getInstance();
  final tempDir = await getTemporaryDirectory();
  final appDocDir = await getApplicationDocumentsDirectory();
  final isar = await IsarFactory.create(appDocDir.path);
  final container = ProviderContainer(
    overrides: [
      buildConfigProvider.overrideWithValue(buildConfig),
      sharedPreferencesProvider.overrideWithValue(preferences),
      apiCacheDirProvider.overrideWithValue(tempDir.path),
      appDocDirProvider.overrideWithValue(appDocDir.path),
      audioPlayerServiceProvider.overrideWith(MobileAudioPlayerService.new),
      queueManagerProvider.overrideWith(DefaultQueueManager.new),
      statsRepositoryProvider.overrideWithValue(IsarStatsRepository(isar)),
      episodeRepositoryProvider.overrideWithValue(IsarEpisodeRepository(isar)),
      podcastRepositoryProvider.overrideWithValue(IsarPodcastRepository(isar)),
      rssRepositoryProvider.overrideWithValue(IsarRssRepository(isar)),
      downloadRepositoryProvider
          .overrideWithValue(IsarDownloadRepository(isar)),
      queueRepositoryProvider.overrideWithValue(IsarQueueRepository(isar)),
    ],
    observers: [AsyncErrorLogger()],
  );

  final errorLogger = container.read(errorLoggerProvider);
  // * Register error handlers. For more info, see:
  // * https://docs.flutter.dev/testing/errors
  registerErrorHandlers(errorLogger);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AudiflowApp(),
    ),
  );
}

void registerErrorHandlers(ErrorLogger errorLogger) {
  // * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    errorLogger.logError(details.exception, details.stack);
  };
  // * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    errorLogger.logError(error, stack);
    return true;
  };
  // * Show some error UI when any widget in the app fails to build
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('An error occurred'.hardcoded),
      ),
      body: Center(child: Text(details.toString())),
    );
  };
}
