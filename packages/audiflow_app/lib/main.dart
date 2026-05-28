import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
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
import 'features/force_update/force_update.dart';
import 'features/parental_control/data/local_auth_biometric_authenticator.dart';
import 'features/monitoring/services/firebase_analytics_service.dart';
import 'features/monitoring/services/throttled_analytics_service.dart';
import 'features/player/services/audio_handler_provider.dart';
import 'features/review_prompt/presentation/review_prompt_gate.dart';
import 'features/settings/presentation/controllers/last_tab_controller.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';
import 'features/settings/presentation/widgets/opml_file_receiver.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

/// Optional analytics observer attached to the router for screen_view tracking.
///
/// Overridden in `_startApp` when Firebase is available; null otherwise.
final firebaseAnalyticsObserverProvider = Provider<FirebaseAnalyticsObserver?>(
  (ref) => null,
);

Future<void> appMain({
  required Flavor flavor,
  String presetConfigBaseUrl =
      'https://audiflow.github.io/audiflow-preset/assets-dev/v7',
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final flavorConfig = switch (flavor) {
    Flavor.dev => FlavorConfig.dev,
    Flavor.stg => FlavorConfig.stg,
    Flavor.prod => FlavorConfig.prod,
  };
  FlavorConfig.initialize(flavorConfig);

  final prefs = await SharedPreferences.getInstance();
  final installId = await InstallIdRepositoryImpl(
    SharedPreferencesDataSource(prefs),
  ).getOrCreate();

  FirebaseAnalytics? firebaseAnalytics;
  if (flavorConfig.enableAnalytics) {
    try {
      await Firebase.initializeApp();
      firebaseAnalytics = FirebaseAnalytics.instance;
      await firebaseAnalytics.setConsent(
        adStorageConsentGranted: false,
        adUserDataConsentGranted: false,
        adPersonalizationSignalsConsentGranted: false,
        analyticsStorageConsentGranted: true,
      );
      await firebaseAnalytics.setUserId(id: installId);
      final optIn = prefs.getBool('analytics.opt_in') ?? true;
      await firebaseAnalytics.setAnalyticsCollectionEnabled(optIn);
      if (kDebugMode) {
        debugPrint('[FIREBASE] init OK installId=$installId optIn=$optIn');
      }
    } on Object catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[FIREBASE] init failed: $e\n$stack');
      }
      firebaseAnalytics = null;
    }
  } else if (kDebugMode) {
    debugPrint(
      '[FIREBASE] SKIPPED — enableAnalytics=false for flavor ${flavor.name}',
    );
  }

  const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  const sentryEnvironment = String.fromEnvironment('SENTRY_ENVIRONMENT');

  if (flavorConfig.enableCrashReporting && sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.environment = sentryEnvironment.isNotEmpty
            ? sentryEnvironment
            : flavor.name;
        options.tracesSampleRate = 0;
        options.debug = kDebugMode;
      },
      appRunner: () async {
        Sentry.configureScope((scope) {
          scope.setUser(SentryUser(id: installId));
          scope.setTag('install_id', installId);
        });
        // Diagnostic: verify foreground Sentry pipeline on boot.
        // Remove once investigation is resolved.
        unawaited(
          Sentry.captureMessage(
                'app-boot: Sentry initialized',
                level: SentryLevel.info,
              )
              .then((sentryId) {
                if (kDebugMode) {
                  debugPrint(
                    '[SENTRY-DIAG] boot captureMessage sentryId=$sentryId',
                  );
                }
              })
              .catchError((Object error, StackTrace stackTrace) {
                if (kDebugMode) {
                  debugPrint(
                    '[SENTRY-DIAG] boot captureMessage failed: $error',
                  );
                }
              }),
        );
        await _startApp(
          presetConfigBaseUrl,
          prefs: prefs,
          firebaseAnalytics: firebaseAnalytics,
        );
      },
    );
  } else {
    if (kDebugMode) {
      debugPrint(
        '[SENTRY-DIAG] Sentry SKIPPED — '
        'enableCrashReporting=${flavorConfig.enableCrashReporting}, '
        'dsnEmpty=${sentryDsn.isEmpty}',
      );
    }
    await _startApp(
      presetConfigBaseUrl,
      prefs: prefs,
      firebaseAnalytics: firebaseAnalytics,
    );
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

Future<void> _startApp(
  String presetConfigBaseUrl, {
  required SharedPreferences prefs,
  required FirebaseAnalytics? firebaseAnalytics,
}) async {
  await _configureOrientation();

  final dir = await getApplicationDocumentsDirectory();
  // Standalone logger: ProviderContainer cannot be built before Isar is
  // open (Isar is a container override), so the logger provider is not
  // yet available. A plain Logger is sufficient for surfacing open
  // failures.
  final isarOpenLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.debug,
  );
  Sentry.addBreadcrumb(
    Breadcrumb(
      message: 'Opening Isar database',
      category: 'database',
      data: {'directory': dir.path},
    ),
  );
  final Isar isar;
  try {
    isar = await openIsarWithRecovery(
      directory: dir.path,
      logger: isarOpenLogger,
    );
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'Isar opened', category: 'database'),
    );
  } on IsarError catch (e, stack) {
    // Schema-mismatch errors are recovered inside openIsarWithRecovery
    // by deleting the database; reaching this catch means the recovery
    // path was skipped (non-schema error) or the retried open also
    // failed. Capture explicitly so the failure mode is visible in
    // Sentry even though it would otherwise propagate to the zone
    // error handler — a breadcrumb alone would not carry the message.
    await Sentry.captureException(
      e,
      stackTrace: stack,
      withScope: (scope) {
        scope.setTag('subsystem', 'isar_open');
        scope.setContexts('isar', {'message': e.message});
      },
    );
    rethrow;
  }
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
  final packageInfo = await PackageInfo.fromPlatform();

  // Diagnostic: bridge foreground feed-sync structured events into Sentry
  // so we can distinguish which sync path ran (foreground vs background)
  // and inspect stoppedEarly / cleanup behavior. Remove once investigation
  // is resolved.
  void feedSyncDiagnostic(String event, Map<String, Object?> data) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: event, category: 'feed.sync', data: data),
    );
    if (event == 'feed-sync:parse-complete') {
      unawaited(
        Sentry.captureMessage(
          event,
          level: SentryLevel.info,
          withScope: (scope) => scope.setContexts('feed_sync', data),
        ),
      );
    }
  }

  const forceUpdateConfigUrl = String.fromEnvironment(forceUpdateConfigUrlEnv);

  final container = ProviderContainer(
    overrides: [
      isarProvider.overrideWithValue(isar),
      dioProvider.overrideWithValue(dio),
      cacheDirProvider.overrideWithValue(cacheDir.path),
      sharedPreferencesProvider.overrideWithValue(prefs),
      packageInfoProvider.overrideWithValue(packageInfo),
      analyticsServiceProvider.overrideWithValue(
        firebaseAnalytics == null
            ? FakeAnalyticsService()
            : ThrottledAnalyticsService(
                FirebaseAnalyticsService(firebaseAnalytics),
              ),
      ),
      firebaseAnalyticsObserverProvider.overrideWithValue(
        firebaseAnalytics == null
            ? null
            : FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
      ),
      presetConfigBaseUrlProvider.overrideWithValue(presetConfigBaseUrl),
      feedSyncDiagnosticSinkProvider.overrideWithValue(feedSyncDiagnostic),
      forceUpdateConfigUrlProvider.overrideWithValue(forceUpdateConfigUrl),
      biometricAuthenticatorProvider.overrideWith(
        (ref) => LocalAuthBiometricAuthenticator(
          logger: ref.watch(namedLoggerProvider('ParentalControl')),
        ),
      ),
      // Wire repository warnings through logger + reporter without
      // capturing a late container reference: the override builder reads
      // both seams from its own `ref`, so the sink closure is bound to
      // the container under construction.
      forceUpdateWarningSinkProvider.overrideWith((ref) {
        final logger = ref.watch(namedLoggerProvider('ForceUpdate'));
        final reporter = ref.watch(forceUpdateReporterProvider);
        return (String message, {Object? error, StackTrace? stackTrace}) {
          logger.w(message, error: error, stackTrace: stackTrace);
          if (error != null) {
            unawaited(
              reporter.captureException(
                error,
                stackTrace: stackTrace,
                message: message,
              ),
            );
          }
        };
      }),
    ],
  );

  // Initialize audio service for platform media controls
  await container.read(audioHandlerProvider.future);

  // Restore last played episode for mini player
  await _restoreLastPlayed(container);

  // Fetch preset summaries from remote
  final spLogger = container.read(namedLoggerProvider('Preset'));
  spLogger.d(
    'Fetching preset config from: '
    '$presetConfigBaseUrl',
  );
  final configRepo = container.read(presetConfigRepositoryProvider);
  final rootMeta = await configRepo.fetchRootMeta();
  spLogger.d(
    'Preset config dataVersion=${rootMeta.dataVersion}, '
    'schemaVersion=${rootMeta.schemaVersion}, '
    'presets=${rootMeta.presets.length}',
  );
  await configRepo.reconcileCache(rootMeta.presets);
  configRepo.setPresetSummaries(rootMeta.presets);
  container
      .read(presetSummariesProvider.notifier)
      .setSummaries(rootMeta.presets);
  container
      .read(presetSchemaVersionProvider.notifier)
      .setSchemaVersion(rootMeta.schemaVersion);

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
            itunesId: subscription?.itunesId,
            episodeGuid: episode.guid,
            feedUrl: subscription?.feedUrl,
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
    final faObserver = ref.read(firebaseAnalyticsObserverProvider);
    _router = createAppRouter(
      prefs: ref.read(sharedPreferencesProvider),
      container: ProviderScope.containerOf(context, listen: false),
      lastTabIndex: ref.read(lastTabControllerProvider),
      observers: [?faObserver],
    );
    unawaited(_initNotificationTapHandler());
  }

  Future<void> _initNotificationTapHandler() async {
    try {
      final handler = NotificationTapHandler(router: _router);
      final plugin = FlutterLocalNotificationsPlugin();
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // defaultPresent* tells the UNUserNotificationCenterDelegate to show
        // the banner/list/sound when a notification arrives while the app is
        // in the foreground. Without these, iOS treats the notification as
        // suppressed and it never lands in Notification Center at all.
        iOS: DarwinInitializationSettings(
          defaultPresentBanner: true,
          defaultPresentList: true,
          defaultPresentSound: true,
        ),
      );
      await plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse:
            handler.onDidReceiveNotificationResponse,
      );

      // Handle cold start: check if app was launched by notification.
      final launchDetails = await plugin.getNotificationAppLaunchDetails();
      final didLaunch = launchDetails?.didNotificationLaunchApp ?? false;
      if (!didLaunch) return;

      final coldStartPayload = launchDetails?.notificationResponse?.payload;
      final route = NotificationTapHandler.parseNotificationRoute(
        coldStartPayload,
      );

      if (route == null) {
        unawaited(
          Sentry.captureMessage(
            'notif-init: cold-start launched by notification but '
            'route parse returned null',
            level: SentryLevel.warning,
            withScope: (scope) {
              scope.setContexts('notification_cold_start', {
                'payloadPresent': coldStartPayload != null,
                'payloadLength': coldStartPayload?.length ?? 0,
              });
            },
          ),
        );
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _router.push(route);
        } on Object catch (e, stack) {
          unawaited(
            Sentry.captureException(
              e,
              stackTrace: stack,
              withScope: (scope) {
                scope.setContexts('notification_cold_start', {'route': route});
              },
            ),
          );
        }
      });
    } on Object catch (e, stack) {
      unawaited(Sentry.captureException(e, stackTrace: stack));
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
        title: 'audiflow',
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
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        // The gate is placed inside MaterialApp.builder so it has
        // access to MaterialLocalizations + AppLocalizations and sits
        // above the router subtree — HardUpdate / Maintenance render
        // before any route mounts.
        builder: (context, child) => ForceUpdateGate(
          child: ReviewPromptGate(child: OpmlFileReceiver(child: child!)),
        ),
        routerConfig: _router,
      ),
    );
  }
}
