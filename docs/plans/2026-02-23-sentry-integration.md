# Sentry Integration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Integrate Sentry crash reporting across all flavors, with HTTP tracing for dev/stg only.

**Architecture:** Use `--dart-define-from-file` to load DSN at compile time. `SentryFlutter.init()` wraps the app in `main()`, gated by `FlavorConfig`. `SentryDio` interceptor added conditionally based on `enableHttpTracing` flag.

**Tech Stack:** `sentry_flutter: ^9.10.0`, `sentry_dio: ^9.10.0` (already in pubspec.yaml)

---

## Configuration Matrix

| Flavor | `enableCrashReporting` | `enableHttpTracing` | `environment` tag |
|--------|----------------------|-------------------|-------------------|
| dev    | true                 | true              | `dev`             |
| stg    | true                 | true              | `stg`             |
| prod   | true                 | false             | `prod`            |

## Build Command Change

After this integration, build commands require `--dart-define-from-file`:

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=.env.dev

# Staging
flutter run --flavor stg -t lib/main_stg.dart --dart-define-from-file=.env.stg

# Production
flutter build apk --flavor prod -t lib/main_prod.dart --release --dart-define-from-file=.env.prod
```

---

### Task 1: Add `enableHttpTracing` to FlavorConfig

**Files:**
- Modify: `packages/audiflow_core/lib/src/config/flavor_config.dart`

**Step 1: Update FlavorConfig class**

Add `enableHttpTracing` field to constructor and all factory getters. Also change dev's `enableCrashReporting` from `false` to `true`.

```dart
class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.name,
    required this.apiBaseUrl,
    required this.smartPlaylistConfigBaseUrl,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.enableHttpTracing,
  });

  final Flavor flavor;
  final String name;
  final String apiBaseUrl;
  final String smartPlaylistConfigBaseUrl;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool enableHttpTracing;

  // ... (keep static _current, current getter, initialize(), envFile)

  static FlavorConfig get dev => FlavorConfig._(
    flavor: Flavor.dev,
    name: 'Development',
    apiBaseUrl: 'https://api-dev.audiflow.example.com',
    smartPlaylistConfigBaseUrl:
        'https://storage.googleapis.com/audiflow-dev-config',
    enableAnalytics: false,
    enableCrashReporting: true,   // changed from false
    enableHttpTracing: true,       // NEW
  );

  static FlavorConfig get stg => FlavorConfig._(
    flavor: Flavor.stg,
    name: 'Staging',
    apiBaseUrl: 'https://api-stg.audiflow.example.com',
    smartPlaylistConfigBaseUrl:
        'https://storage.googleapis.com/audiflow-dev-config',
    enableAnalytics: true,
    enableCrashReporting: true,
    enableHttpTracing: true,       // NEW
  );

  static FlavorConfig get prod => FlavorConfig._(
    flavor: Flavor.prod,
    name: 'Production',
    apiBaseUrl: 'https://api.audiflow.example.com',
    smartPlaylistConfigBaseUrl:
        'https://audiflow.github.io/audiflow-smartplaylist',
    enableAnalytics: true,
    enableCrashReporting: true,
    enableHttpTracing: false,      // NEW - prod is crash-only
  );
}
```

**Step 2: Run analyze**

```bash
analyze_files packages/audiflow_core
```
Expected: zero errors

**Step 3: Commit**

```
feat(core): add enableHttpTracing to FlavorConfig
```

---

### Task 2: Refactor `main()` to accept Flavor and initialize Sentry

**Files:**
- Modify: `packages/audiflow_app/lib/main.dart`
- Modify: `packages/audiflow_app/lib/main_dev.dart`
- Modify: `packages/audiflow_app/lib/main_stg.dart`
- Modify: `packages/audiflow_app/lib/main_prod.dart`

**Step 1: Update `main()` signature and add Sentry init**

The main function accepts a `Flavor` and wraps the app in `SentryFlutter.init()`.

```dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_lifecycle_observer.dart';
import 'features/player/services/audio_handler_provider.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';
import 'features/settings/presentation/widgets/opml_file_receiver.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

Future<void> main({
  required Flavor flavor,
  String smartPlaylistConfigBaseUrl =
      'https://storage.googleapis.com/audiflow-dev-config',
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize flavor configuration
  final flavorConfig = switch (flavor) {
    Flavor.dev => FlavorConfig.dev,
    Flavor.stg => FlavorConfig.stg,
    Flavor.prod => FlavorConfig.prod,
  };
  FlavorConfig.initialize(flavorConfig);

  // Read DSN from compile-time env (--dart-define-from-file)
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  if (flavorConfig.enableCrashReporting && sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.environment = flavor.name;
        options.tracesSampleRate = 0;
      },
      appRunner: () => _startApp(
        flavorConfig: flavorConfig,
        smartPlaylistConfigBaseUrl: smartPlaylistConfigBaseUrl,
      ),
    );
  } else {
    await _startApp(
      flavorConfig: flavorConfig,
      smartPlaylistConfigBaseUrl: smartPlaylistConfigBaseUrl,
    );
  }
}

Future<void> _startApp({
  required FlavorConfig flavorConfig,
  required String smartPlaylistConfigBaseUrl,
}) async {
  final database = AppDatabase();
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );

  // Add SentryDio interceptor for HTTP tracing (dev/stg only)
  if (flavorConfig.enableHttpTracing) {
    dio.addInterceptor(SentryDioInterceptor());
  }

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
```

**Step 2: Update flavor entry points**

`main_dev.dart`:
```dart
import 'package:audiflow_core/audiflow_core.dart';

import 'main.dart' as app;

Future<void> main() => app.main(flavor: Flavor.dev);
```

`main_stg.dart`:
```dart
import 'package:audiflow_core/audiflow_core.dart';

import 'main.dart' as app;

Future<void> main() => app.main(
  flavor: Flavor.stg,
  smartPlaylistConfigBaseUrl:
      'https://storage.googleapis.com/audiflow-dev-config',
);
```

`main_prod.dart`:
```dart
import 'package:audiflow_core/audiflow_core.dart';

import 'main.dart' as app;

Future<void> main() => app.main(
  flavor: Flavor.prod,
  smartPlaylistConfigBaseUrl:
      'https://audiflow.github.io/audiflow-smartplaylist',
);
```

**Step 3: Verify `Dio.addInterceptor` API**

Check that `addInterceptor` is the correct method name. It may be `dio.interceptors.add(...)` instead. Verify from Dio source before implementing.

**Step 4: Run analyze**

```bash
analyze_files packages/audiflow_app
```
Expected: zero errors

**Step 5: Commit**

```
feat(app): integrate Sentry crash reporting and HTTP tracing
```

---

### Task 3: Update build command documentation

**Files:**
- Modify: `.claude/rules/project/tech.md` (Build Flavors section)

**Step 1: Update build commands**

Update the Build Flavors section to include `--dart-define-from-file`:

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=.env.dev

# Staging
flutter run --flavor stg -t lib/main_stg.dart --dart-define-from-file=.env.stg

# Production (release)
flutter build apk --flavor prod -t lib/main_prod.dart --release --dart-define-from-file=.env.prod
flutter build ios --flavor prod -t lib/main_prod.dart --release --dart-define-from-file=.env.prod
```

**Step 2: Commit**

```
docs: update build commands with --dart-define-from-file for Sentry DSN
```

---

### Task 4: Remove unused flutter_dotenv dependency (cleanup)

Since we use `--dart-define-from-file` instead of runtime .env loading, `flutter_dotenv` is no longer needed.

**Files:**
- Modify: `packages/audiflow_core/pubspec.yaml` (remove `flutter_dotenv: ^6.0.0`)

**Step 1: Remove dependency**

```bash
pub remove flutter_dotenv  # in audiflow_core
```

**Step 2: Verify no imports remain**

Search for any `flutter_dotenv` imports in Dart files. If the `Env` class used it, confirm it no longer does (current `Env` class does not import it).

**Step 3: Run analyze**

```bash
analyze_files packages/audiflow_core
```
Expected: zero errors

**Step 4: Commit**

```
chore(core): remove unused flutter_dotenv dependency
```

---

### Task 5: Run full test suite

**Step 1: Run all tests**

```bash
run_tests  # all packages
```
Expected: all pass

**Step 2: Run analyze on entire workspace**

```bash
analyze_files  # all packages
```
Expected: zero errors
