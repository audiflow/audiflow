import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app_lifecycle_observer.dart';
import 'app/notification/notification_tap_handler.dart';
import 'app/background/background_callback.dart';
import 'app/background/background_task_registrar.dart';
import 'features/player/services/audio_handler_provider.dart';
import 'features/settings/presentation/controllers/last_tab_controller.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';
import 'features/settings/presentation/widgets/opml_file_receiver.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

Future<void> appMain({
  required Flavor flavor,
  String smartPlaylistConfigBaseUrl =
      'https://audiflow.github.io/audiflow-smartplaylist/assets-dev/v3',
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final flavorConfig = switch (flavor) {
    Flavor.dev => FlavorConfig.dev,
    Flavor.stg => FlavorConfig.stg,
    Flavor.prod => FlavorConfig.prod,
  };
  FlavorConfig.initialize(flavorConfig);

  const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  const sentryEnvironment = String.fromEnvironment('SENTRY_ENVIRONMENT');

  if (flavorConfig.enableCrashReporting && sentryDsn.isNotEmpty) {
    await SentryFlutter.init((options) {
      options.dsn = sentryDsn;
      options.environment = sentryEnvironment.isNotEmpty
          ? sentryEnvironment
          : flavor.name;
      options.tracesSampleRate = 0;
    }, appRunner: () => _startApp(smartPlaylistConfigBaseUrl));
  } else {
    await _startApp(smartPlaylistConfigBaseUrl);
  }
}

Future<void> _configureOrientation() async {
  final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
  final logicalSize = view != null
      ? view.physicalSize / view.devicePixelRatio
      : Size.zero;
  final isTablet = DeviceUtils.isTablet(logicalSize.shortestSide);
  await SystemChrome.setPreferredOrientations(
    isTablet
        ? DeviceOrientation.values
        : const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
}

Future<void> _startApp(String smartPlaylistConfigBaseUrl) async {
  await _configureOrientation();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await openIsarWithRecovery(directory: dir.path);
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );

  if (FlavorConfig.current.enableHttpTracing) {
    dio.addSentry();
  }

  final cacheDir = await getApplicationCacheDirectory();
  final prefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();

  final container = ProviderContainer(
    overrides: [
      isarProvider.overrideWithValue(isar),
      dioProvider.overrideWithValue(dio),
      cacheDirProvider.overrideWithValue(cacheDir.path),
      sharedPreferencesProvider.overrideWithValue(prefs),
      packageInfoProvider.overrideWithValue(packageInfo),
      smartPlaylistConfigBaseUrlProvider.overrideWithValue(
        smartPlaylistConfigBaseUrl,
      ),
    ],
  );

  // Initialize audio service for platform media controls
  await container.read(audioHandlerProvider.future);

  // Restore last played episode for mini player
  await _restoreLastPlayed(container);

  // Fetch smart playlist pattern summaries from remote
  final spLogger = container.read(namedLoggerProvider('SmartPlaylist'));
  spLogger.d(
    'Fetching smart playlist config from: '
    '$smartPlaylistConfigBaseUrl',
  );
  final configRepo = container.read(smartPlaylistConfigRepositoryProvider);
  final rootMeta = await configRepo.fetchRootMeta();
  spLogger.d(
    'Smart playlist config dataVersion=${rootMeta.dataVersion}, '
    'schemaVersion=${rootMeta.schemaVersion}, '
    'patterns=${rootMeta.patterns.length}',
  );
  await configRepo.reconcileCache(rootMeta.patterns);
  configRepo.setPatternSummaries(rootMeta.patterns);
  container
      .read(patternSummariesProvider.notifier)
      .setSummaries(rootMeta.patterns);

  // Run cache eviction non-blocking after startup
  _runCacheEviction(container, isar);

  // Initialize background refresh (guarded for unsupported platforms)
  try {
    await Workmanager().initialize(backgroundCallback);
    final settingsRepo = container.read(appSettingsRepositoryProvider);
    if (settingsRepo.getAutoSync()) {
      await BackgroundTaskRegistrar.register(
        intervalMinutes: settingsRepo.getSyncIntervalMinutes(),
        wifiOnly: settingsRepo.getWifiOnlySync(),
        inputData: BackgroundTaskRegistrar.buildInputData(settingsRepo),
      );
    }
  } catch (e, stack) {
    // Workmanager not available or platform error — non-critical
    final logger = container.read(namedLoggerProvider('BackgroundRefresh'));
    logger.w(
      'Failed to initialize background refresh',
      error: e,
      stackTrace: stack,
    );
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AppLifecycleObserver(child: MyApp()),
    ),
  );
}

/// Runs podcast cache eviction in the background.
///
/// Removes stale cached (non-subscribed) podcasts that haven't
/// been accessed recently. Non-blocking -- errors are logged
/// but don't affect app startup.
void _runCacheEviction(ProviderContainer container, Isar isar) {
  final logger = container.read(namedLoggerProvider('CacheEviction'));
  final subscriptionRepo = container.read(subscriptionRepositoryProvider);

  final evictionService = PodcastCacheEvictionService(
    subscriptionRepository: subscriptionRepo,
    isar: isar,
    logger: logger,
  );

  // Fire-and-forget -- non-blocking startup
  // ignore: unawaited_futures
  evictionService.evict().then(
    (_) {},
    onError: (Object error, StackTrace stack) {
      logger.e('Cache eviction failed', error: error, stackTrace: stack);
    },
  );
}

/// Restores the last played episode into [NowPlayingController].
///
/// Queries [PlaybackHistoryRepository] for the most recent incomplete episode
/// and populates the mini player metadata so it appears on app launch.
Future<void> _restoreLastPlayed(ProviderContainer container) async {
  try {
    final historyRepo = container.read(playbackHistoryRepositoryProvider);
    final lastPlayed = await historyRepo.getLastPlayed();
    if (lastPlayed == null) return;

    final episodeRepo = container.read(episodeRepositoryProvider);
    final episode = await episodeRepo.getById(lastPlayed.episodeId);
    if (episode == null) return;

    final subscriptionRepo = container.read(subscriptionRepositoryProvider);
    final subscription = await subscriptionRepo.getById(episode.podcastId);

    container
        .read(nowPlayingControllerProvider.notifier)
        .setNowPlaying(
          NowPlayingInfo(
            episodeUrl: episode.audioUrl,
            episodeTitle: episode.title,
            podcastTitle: subscription?.title ?? '',
            artworkUrl: episode.imageUrl ?? subscription?.artworkUrl,
            totalDuration: episode.durationMs != null
                ? Duration(milliseconds: episode.durationMs!)
                : lastPlayed.durationMs != null
                ? Duration(milliseconds: lastPlayed.durationMs!)
                : null,
            savedPosition: Duration(milliseconds: lastPlayed.positionMs),
            episode: episode,
          ),
        );
  } catch (_) {
    // Non-critical: silently ignore restore failures
  }
}

/// Root application widget.
///
/// Creates the [MaterialApp.router] with the application router
/// and theme configuration. Watches [ThemeModeController] and
/// [TextScaleController] to apply live settings changes.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(
      lastTabIndex: ref.read(lastTabControllerProvider),
    );
    unawaited(_initNotificationTapHandler());
  }

  Future<void> _initNotificationTapHandler() async {
    final handler = NotificationTapHandler(router: _router);
    final plugin = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse:
          handler.onDidReceiveNotificationResponse,
    );

    // Handle cold start: check if app was launched by notification
    final launchDetails = await plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final route = NotificationTapHandler.parseNotificationRoute(
        launchDetails.notificationResponse?.payload,
      );
      if (route != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _router.push(route);
        });
      }
    }
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeControllerProvider);
    final textScale = ref.watch(textScaleControllerProvider);

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: MaterialApp.router(
        title: 'Audiflow',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale?.languageCode) {
              intl.Intl.defaultLocale = supported.toLanguageTag();
              return supported;
            }
          }
          intl.Intl.defaultLocale = supportedLocales.first.toLanguageTag();
          return supportedLocales.first;
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: themeMode,
        builder: (context, child) => OpmlFileReceiver(child: child!),
        routerConfig: _router,
      ),
    );
  }
}
