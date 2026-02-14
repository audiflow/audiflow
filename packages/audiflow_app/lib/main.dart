import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_lifecycle_observer.dart';
import 'features/player/services/audio_handler_provider.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

Future<void> main({
  String smartPlaylistConfigBaseUrl =
      'https://storage.googleapis.com/audiflow-dev-config',
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final database = AppDatabase();
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );
  final cacheDir = await getApplicationCacheDirectory();
  final prefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
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

  // Fetch smart playlist pattern summaries from remote
  final configRepo = container.read(smartPlaylistConfigRepositoryProvider);
  final rootMeta = await configRepo.fetchRootMeta();
  await configRepo.reconcileCache(rootMeta.patterns);
  configRepo.setPatternSummaries(rootMeta.patterns);
  container
      .read(patternSummariesProvider.notifier)
      .setSummaries(rootMeta.patterns);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AppLifecycleObserver(child: MyApp()),
    ),
  );
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
  late final _router = createAppRouter();

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
        routerConfig: _router,
      ),
    );
  }
}
