import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audiflow/common/data/app_path_repository.dart';
import 'package:audiflow/common/data/connectivity.dart'
    show initialConnectivityProvider;
import 'package:audiflow/common/data/isar_factory.dart';
import 'package:audiflow/common/data/isar_repository.dart';
import 'package:audiflow/common/data/shared_preferences.dart';
import 'package:audiflow/constants/env.dart';
import 'package:audiflow/constants/flavors.dart';
import 'package:audiflow/exceptions/async_error_logger.dart';
import 'package:audiflow/exceptions/error_logger.dart';
import 'package:audiflow/features/bootstrap/ui/audiflow_app.dart';
import 'package:audiflow/features/browser/common/data/default_podcast_api_repository.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository_change_handler.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/isar_episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/isar_page_models_repository.dart';
import 'package:audiflow/features/browser/common/data/page_models_repository.dart';
import 'package:audiflow/features/browser/common/data/page_models_repository_change_handler.dart';
import 'package:audiflow/features/browser/common/data/podcast_api_repository.dart';
import 'package:audiflow/features/browser/common/data/podcast_stats_repository/isar_podcast_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/podcast_stats_repository/podcast_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/podcast_stats_repository/podcast_stats_repository_change_handler.dart';
import 'package:audiflow/features/browser/season/data/isar_season_repository.dart';
import 'package:audiflow/features/browser/season/data/season_repository.dart';
import 'package:audiflow/features/config/data/build_config.dart';
import 'package:audiflow/features/config/model/app_build_config.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/data/download_repository_change_handler.dart';
import 'package:audiflow/features/download/data/isar_download_repository.dart';
import 'package:audiflow/features/download/service/default_download_service.dart';
import 'package:audiflow/features/download/service/default_download_task_controller.dart';
import 'package:audiflow/features/download/service/download_service.dart';
import 'package:audiflow/features/download/service/download_task_controller.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/data/episode_repository_change_handler.dart';
import 'package:audiflow/features/feed/data/isar_episode_repository.dart';
import 'package:audiflow/features/feed/data/isar_podcast_repository.dart';
import 'package:audiflow/features/feed/data/isar_rss_repository.dart';
import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/data/podcast_repository_change_handler.dart';
import 'package:audiflow/features/feed/data/rss_repository.dart';
import 'package:audiflow/features/player/data/isar_player_state_repository.dart';
import 'package:audiflow/features/player/data/player_state_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/player/service/default_audio_player_service/default_audio_player_service.dart';
import 'package:audiflow/features/preference/data/isar_preference_repository.dart';
import 'package:audiflow/features/preference/data/preference_repository.dart';
import 'package:audiflow/features/queue/data/isar_queue_repository.dart';
import 'package:audiflow/features/queue/data/queue_repository.dart';
import 'package:audiflow/features/queue/service/audio_queue_service.dart';
import 'package:audiflow/features/queue/service/default_queue_controller.dart';
import 'package:audiflow/features/queue/service/queue_controller.dart';
import 'package:audiflow/localization/string_hardcoded.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

FutureOr<void> runMainApp({required FirebaseOptions firebaseOptions}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = Env.sentryDsn
        ..environment = getFlavor().name
        ..considerInAppFramesByDefault = false
        ..addInAppInclude('audiflow');
    },
  );
  await Firebase.initializeApp(options: firebaseOptions);

  final buildConfig = BuildConfig.fromPackageInfo(
    packageInfo: await PackageInfo.fromPlatform(),
    appFlavor: const String.fromEnvironment('flavor'),
  );
  logger.t(buildConfig);

  final v = await Future.wait([
    Connectivity().checkConnectivity(),
    SharedPreferences.getInstance(),
    getTemporaryDirectory(),
    getApplicationDocumentsDirectory(),
  ]);
  final connectivity = v[0] as List<ConnectivityResult>;
  final preferences = v[1] as SharedPreferences;
  final tempDir = v[2] as Directory;
  final appDocDir = v[3] as Directory;

  final isar = await IsarFactory.create(appDocDir.path);
  final container = ProviderContainer(
    overrides: [
      // foundations
      preferenceRepositoryProvider
          .overrideWith(IsarAppPreferenceRepository.new),
      apiCacheDirProvider.overrideWithValue(tempDir.path),
      appDocDirProvider.overrideWithValue(appDocDir.path),
      buildConfigProvider.overrideWithValue(buildConfig),
      initialConnectivityProvider.overrideWithValue(connectivity),
      isarRepositoryProvider.overrideWithValue(isar),
      sharedPreferencesProvider.overrideWithValue(preferences),
      // core repositories
      episodeRepositoryProvider.overrideWith(
        (ref) =>
            EpisodeRepositoryHandleHandler(ref, IsarEpisodeRepository(isar)),
      ),
      episodeStatsRepositoryProvider.overrideWith(
        (ref) => EpisodeStatsRepositoryChangeHandler(
          ref,
          IsarEpisodeStatsRepository(isar),
        ),
      ),
      pageModelsRepositoryProvider.overrideWith(
        (ref) => PageModelsRepositoryChangeHandler(
          ref,
          IsarPageModelsRepository(isar),
        ),
      ),
      playerStateRepositoryProvider
          .overrideWithValue(IsarPlayerStateRepository(isar)),
      podcastApiRepositoryProvider.overrideWithValue(
        DefaultPodcastApiRepository(cacheDir: tempDir.path),
      ),
      podcastRepositoryProvider.overrideWith(
        (ref) =>
            PodcastRepositoryChangeHandler(ref, IsarPodcastRepository(isar)),
      ),
      podcastStatsRepositoryProvider.overrideWith(
        (ref) => PodcastStatsRepositoryChangeHandler(
          ref,
          IsarPodcastStatsRepository(isar),
        ),
      ),
      rssRepositoryProvider.overrideWithValue(IsarRssRepository(isar)),
      seasonRepositoryProvider.overrideWithValue(IsarSeasonRepository(isar)),
      // download
      downloadRepositoryProvider.overrideWith(
        (ref) =>
            DownloadRepositoryChangeHandler(ref, IsarDownloadRepository(isar)),
      ),
      downloadServiceProvider.overrideWith(DefaultDownloadService.new),
      downloadTaskControllerProvider
          .overrideWith(DefaultDownloaderTaskController.new),
      // queue
      queueControllerProvider.overrideWith(DefaultQueueController.new),
      queueRepositoryProvider.overrideWithValue(IsarQueueRepository(isar)),
      // player
      audioPlayerServiceProvider.overrideWith(DefaultAudioPlayerService.new),
      audioQueueServiceProvider.overrideWith(AudioQueueService.new),
      // pages
      pageModelsRepositoryProvider.overrideWith(
        (ref) => PageModelsRepositoryChangeHandler(
          ref,
          IsarPageModelsRepository(isar),
        ),
      ),
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
