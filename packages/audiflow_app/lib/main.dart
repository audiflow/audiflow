import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path_provider/path_provider.dart';

import 'app/app_lifecycle_observer.dart';
import 'features/player/services/audio_handler_provider.dart';
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

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      dioProvider.overrideWithValue(dio),
      cacheDirProvider.overrideWithValue(cacheDir.path),
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
/// and theme configuration.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
      routerConfig: _router,
    );
  }
}
