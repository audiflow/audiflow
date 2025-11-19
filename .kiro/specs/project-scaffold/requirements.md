# Requirements Document

## Introduction

This specification defines the foundational project scaffold for Audiflow v2, a Flutter monorepo application. The scaffold provides essential infrastructure including internationalization (i18n), theming with light/dark mode support, responsive design for phones and tablets, multi-flavor build configurations, splash screens with iconsets, bottom tab bar navigation, and Riverpod-based state management initialization. This scaffold enables consistent, production-ready development across all features while adhering to the project's monorepo architecture using Flutter workspace and Melos.

## Requirements

### Requirement 1: Monorepo Package Structure

**Objective:** As a developer, I want a properly configured Flutter workspace with Melos, so that I can work with a modular, scalable monorepo architecture.

#### Acceptance Criteria

1. The scaffold shall create a `pubspec.yaml` at the repository root with `resolution: workspace` configuration
2. The scaffold shall create a `melos.yaml` configuration file at the repository root defining workspace packages
3. When workspace is bootstrapped, the scaffold shall define four workspace packages: `audiflow_app`, `audiflow_core`, `audiflow_domain`, and `audiflow_ui` in the `packages/` directory
4. The scaffold shall configure `audiflow_app` as a Flutter application package with dependencies on all other workspace packages
5. The scaffold shall configure `audiflow_core` as a Dart-only package with no dependencies on other workspace packages
6. The scaffold shall configure `audiflow_domain` as a Dart-only package with dependency on `audiflow_core`
7. The scaffold shall configure `audiflow_ui` as a Flutter package with dependencies on `audiflow_core` and `audiflow_domain`
8. The scaffold shall provide Melos scripts for common operations: `bootstrap`, `codegen`, `test`, `build_runner`, and `clean`

### Requirement 2: Testing Infrastructure

**Objective:** As a developer, I want testing utilities and fixtures for unit and widget tests, so that I can write comprehensive tests efficiently.

#### Acceptance Criteria

1. The scaffold shall create `test/` directories in all workspace packages mirroring `lib/` structure
2. The scaffold shall configure testing dependencies: `flutter_test`, `mockito`, `riverpod_test`
3. The scaffold shall create test helpers in `packages/audiflow_app/test/helpers/`:
   - `pump_app.dart` - Helper for pumping widgets with providers, theme, and routing
   - `test_providers.dart` - Mock provider overrides for testing
   - `fixtures.dart` - Common test data fixtures
4. When widget tests need providers, the scaffold shall provide `createMockContainer()` utility creating `ProviderContainer` with test overrides
5. The scaffold shall create example tests demonstrating:
   - Unit test for Riverpod provider
   - Widget test with routing
   - Widget test with theme switching
   - Widget test with localization
6. The scaffold shall configure test coverage reporting using `flutter test --coverage`
7. The scaffold shall provide Melos script `melos run test:coverage` generating coverage reports for all packages
8. The scaffold shall configure minimum coverage threshold of 80% as project target (enforced in CI)

### Requirement 3: Development Experience and Tooling

**Objective:** As a developer, I want automated code generation and quality checks, so that I can maintain code consistency and catch issues early.

#### Acceptance Criteria

1. The scaffold shall configure `build_runner` for code generation across all workspace packages
2. When Riverpod annotations are added, the scaffold shall generate provider code using `dart run build_runner build --delete-conflicting-outputs`
3. The scaffold shall configure `analysis_options.yaml` at repository root with strict linting rules from `flutter_lints` and `riverpod_lint`
4. The scaffold shall configure analyzer to treat warnings as errors in CI environments
5. The scaffold shall provide Melos script `melos run codegen` executing `build_runner` for all packages in parallel
6. The scaffold shall provide Melos script `melos run test` executing tests for all packages
7. The scaffold shall configure `pedantic_mono` lint rules for consistent code style
8. When code violates lint rules, the scaffold shall fail `flutter analyze` with non-zero exit code
9. The scaffold shall provide Git pre-commit hook template running: `flutter analyze`, `flutter test`, `melos run codegen --no-delete-conflicting-outputs` (check only)
10. The scaffold shall create a `.vscode/` directory with recommended extensions and settings for Flutter development

### Requirement 4: Asset and Resource Management

**Objective:** As a developer, I want centralized asset management with type-safe access, so that resources are organized and easily referenced.

#### Acceptance Criteria

1. The scaffold shall create asset directories in `packages/audiflow_app/assets/` with subdirectories: `images/`, `fonts/`, `icons/`
2. The scaffold shall configure asset declarations in `packages/audiflow_app/pubspec.yaml` under `flutter.assets`
3. The scaffold shall create `AssetPaths` constant class in `packages/audiflow_core/lib/src/constants/asset_paths.dart` with static string constants for all asset paths
4. When new assets are added, the scaffold shall require updating `AssetPaths` for type-safe access
5. The scaffold shall configure custom fonts in `packages/audiflow_app/pubspec.yaml` under `flutter.fonts` (if custom fonts are used)
6. The scaffold shall provide `CachedNetworkImage` configuration in `packages/audiflow_ui` for consistent remote image loading with placeholders and error widgets
7. The scaffold shall configure `extended_image` package for advanced image features (zoom, crop, cache)

### Requirement 5: Responsive Design for Phone and Tablet

**Objective:** As a developer, I want responsive layout utilities detecting phone and tablet screen sizes, so that the app adapts to different device form factors.

#### Acceptance Criteria

1. The scaffold shall integrate `flutter_screenutil` package in `packages/audiflow_ui`
2. When app initializes, the scaffold shall configure `ScreenUtilInit` with design size of 375x812 (iPhone X baseline)
3. The scaffold shall provide utility classes in `packages/audiflow_ui/lib/src/utils/responsive.dart` for detecting device type (phone, tablet)
4. The scaffold shall define breakpoints: phone (width less than 600dp), tablet (600dp or greater)
5. The scaffold shall provide extension methods on `BuildContext` for accessing responsive values: `isPhone`, `isTablet`, `screenWidth`, `screenHeight`
6. The scaffold shall provide responsive spacing utilities using `ScreenUtil` for adaptive dimensions
7. The scaffold shall configure `minTextAdapt: true` and `splitScreenMode: true` in `ScreenUtilInit` for better text scaling

### Requirement 6: Configuration and Environment Variables

**Objective:** As a developer, I want environment-specific configuration externalized from code, so that sensitive data and environment settings are managed securely.

#### Acceptance Criteria

1. The scaffold shall create `.env.dev`, `.env.stg`, `.env.prod` files at repository root (gitignored)
2. The scaffold shall create `.env.example` template file in repository for documentation
3. The scaffold shall integrate `flutter_dotenv` package for loading environment variables
4. When app launches, the scaffold shall load the appropriate `.env` file based on flavor
5. The scaffold shall create `Env` class in `packages/audiflow_core/lib/src/config/env.dart` exposing environment variables as static constants:
   - `sentryDsn`
   - `apiBaseUrl`
   - `mixpanelToken`
   - `appName`
6. If required environment variable is missing, then the scaffold shall throw initialization error with clear message
7. The scaffold shall document all required environment variables in `.env.example`
8. The scaffold shall configure `.gitignore` to exclude all `.env.*` files except `.env.example`

### Requirement 7: Multi-Flavor Build Configuration

**Objective:** As a developer, I want development, staging, and production build flavors, so that I can test and deploy to different environments.

#### Acceptance Criteria

1. The scaffold shall create flavor-specific entry points: `main_dev.dart`, `main_stg.dart`, `main_prod.dart` in `packages/audiflow_app/lib/`
2. The scaffold shall create a `FlavorConfig` class in `packages/audiflow_core/lib/src/config/flavor_config.dart` defining flavor enumeration (dev, stg, prod)
3. When app launches, the scaffold shall initialize `FlavorConfig` based on the entry point
4. The scaffold shall provide `FlavorConfig` properties: `name`, `apiBaseUrl`, `enableAnalytics`, `enableCrashReporting`
5. The scaffold shall configure different values for each flavor:
   - Dev: local/mock API, analytics disabled, crash reporting disabled
   - Staging: staging API, analytics enabled, crash reporting enabled
   - Production: production API, analytics enabled, crash reporting enabled
6. The scaffold shall configure iOS schemes and Android product flavors using `flutter_flavorizr` package
7. When building for a specific flavor, the scaffold shall use commands: `flutter run --flavor dev -t lib/main_dev.dart`
8. The scaffold shall provide a Riverpod provider exposing current `FlavorConfig`

### Requirement 8: Riverpod State Management Initialization

**Objective:** As a developer, I want Riverpod properly initialized with logging and error handling, so that state management is production-ready.

#### Acceptance Criteria

1. The scaffold shall configure `riverpod`, `flutter_riverpod`, `riverpod_annotation`, and `riverpod_generator` dependencies
2. When app initializes, the scaffold shall create a `ProviderContainer` with configured observers
3. The scaffold shall implement `ProviderObserver` subclass `AppProviderObserver` in `packages/audiflow_app/lib/app/observers.dart` for logging provider lifecycle events
4. When provider state changes in debug mode, the scaffold shall log provider updates using the `logger` package
5. The scaffold shall wrap the root widget with `ProviderScope` passing the configured container
6. The scaffold shall configure `riverpod_lint` custom lint rules in `analysis_options.yaml`
7. The scaffold shall provide common infrastructure providers in `packages/audiflow_app/lib/app/providers.dart`:
   - `flavorConfigProvider`
   - `themeModeProvider`
   - `localeProvider`
   - `routerProvider`
8. The scaffold shall handle async errors in providers by logging to error tracking service

### Requirement 9: Theme System with Light/Dark Mode

**Objective:** As a user, I want automatic light/dark mode theming that respects system preferences, so that I can use the app comfortably in different lighting conditions.

#### Acceptance Criteria

1. The scaffold shall create a theme configuration in `packages/audiflow_ui/lib/src/themes/` with `app_theme.dart`, `color_scheme.dart`, and `text_styles.dart`
2. When Material Design 3 is enabled, the scaffold shall generate color schemes using `dynamic_color` package for platform-native theming
3. The scaffold shall define light and dark `ColorScheme` instances with primary, secondary, tertiary, error, surface, and background colors
4. The scaffold shall configure `ThemeData` for both light and dark modes with Material 3 enabled
5. The scaffold shall provide a Riverpod provider for managing `ThemeMode` state (system, light, dark)
6. When `ThemeMode` is set to system, the scaffold shall follow platform brightness settings
7. The scaffold shall persist user's manual `ThemeMode` selection using local storage
8. The scaffold shall export theme components from `packages/audiflow_ui/lib/audiflow_ui.dart`

### Requirement 10: Internationalization (i18n) Infrastructure

**Objective:** As a developer, I want a complete i18n system supporting English and Japanese, so that the app can deliver localized user experiences.

#### Acceptance Criteria

1. The scaffold shall create ARB files for English (`app_en.arb`) and Japanese (`app_ja.arb`) in `packages/audiflow_app/lib/l10n/`
2. When Flutter generates localizations, the scaffold shall configure `flutter_localizations` and `intl` dependencies in `audiflow_app`
3. The scaffold shall configure `flutter gen-l10n` in `audiflow_app/pubspec.yaml` with the following settings:
   - ARB directory: `lib/l10n`
   - Template ARB file: `app_en.arb`
   - Output localization file: `l10n.dart`
   - Nullable getter: `false`
   - Synthetic package: `false`
4. The scaffold shall provide base translation keys in both ARB files including: `appTitle`, `ok`, `cancel`, `loading`, `error`, `retry`
5. When the app initializes, the scaffold shall register localization delegates in the `MaterialApp.router` configuration
6. The scaffold shall configure supported locales: English (`en`) and Japanese (`ja`)
7. The scaffold shall provide a Riverpod provider for accessing current locale state
8. When user locale changes, the scaffold shall persist the selection using local storage

### Requirement 11: Splash Screen and App Icon

**Objective:** As a user, I want branded splash screens and app icons for all platforms, so that the app has a professional appearance.

#### Acceptance Criteria

1. The scaffold shall configure `flutter_native_splash` package for generating native splash screens
2. The scaffold shall create `flutter_native_splash.yaml` configuration at repository root with:
   - Background color (light and dark variants)
   - Image path for splash logo
   - Flavor-specific configurations (dev, stg, prod)
3. When splash screen configuration changes, the scaffold shall regenerate native splash resources using `dart run flutter_native_splash:create`
4. The scaffold shall configure `flutter_launcher_icons` package for generating app icons
5. The scaffold shall create `flutter_launcher_icons.yaml` configuration at repository root with:
   - Android and iOS icon paths
   - Adaptive icon configurations for Android
   - Flavor-specific icon variants
6. When icon configuration changes, the scaffold shall regenerate launcher icons using `dart run flutter_launcher_icons`
7. The scaffold shall provide placeholder assets in `packages/audiflow_app/assets/images/` including: `splash_logo.png`, `app_icon.png`

### Requirement 12: Core Library Initialization

**Objective:** As a developer, I want essential services initialized at app startup, so that core functionality is ready when needed.

#### Acceptance Criteria

1. The scaffold shall create `main.dart` orchestrating app initialization in the following order:
   - `WidgetsFlutterBinding.ensureInitialized()`
   - Orientation lock (portrait only)
   - Permission handler initialization
   - Sentry initialization with environment-based DSN
   - `SharedPreferences` initialization
   - `PackageInfo` loading
   - Path provider directories setup
   - Isar database initialization
   - Audio service initialization (`AudioService`, `AudioSession`)
   - Dio HTTP client configuration
2. When Sentry is initialized, the scaffold shall configure environment (dev/stg/prod), release version, and in-app frame filtering
3. The scaffold shall create error handling utilities in `packages/audiflow_core/lib/src/errors/error_handler.dart`
4. When uncaught exceptions occur, the scaffold shall capture errors using `FlutterError.onError` and `PlatformDispatcher.instance.onError`
5. The scaffold shall provide a global error widget builder displaying user-friendly error messages
6. The scaffold shall initialize `Logger` instance with different log levels per flavor (verbose for dev, warning for prod)
7. The scaffold shall provide common providers for platform services in `packages/audiflow_domain/lib/src/common/providers/`:
   - `sharedPreferencesProvider`
   - `packageInfoProvider`
   - `connectivityProvider`
   - `deviceInfoProvider`
   - `isarProvider`
   - `audioServiceProvider`
   - `dioProvider`
8. The scaffold shall configure Dio with interceptors for logging, error handling, and Sentry integration via `sentry_dio`
9. When Isar is initialized, the scaffold shall configure the database path and register all collection schemas
10. When audio services are initialized, the scaffold shall configure `AudioSession` category and handle interruptions
11. When app lifecycle changes, the scaffold shall log lifecycle events using `AppLifecycleListener`

### Requirement 13: Bootstrap Feature Module

**Objective:** As a user, I want a smooth app launch experience with proper initialization feedback, so that I understand the app is loading correctly.

#### Acceptance Criteria

1. The scaffold shall create a `bootstrap` feature in `packages/audiflow_app/lib/features/bootstrap/` with presentation layer
2. The scaffold shall implement `SplashScreen` widget displaying app logo and loading indicator
3. When app launches, the scaffold shall navigate to `SplashScreen` as the initial route
4. The scaffold shall create `BootstrapController` Riverpod provider in `packages/audiflow_app/lib/features/bootstrap/presentation/controllers/bootstrap_controller.dart`
5. When bootstrap process starts, the scaffold shall perform sequential initialization:
   - Check app version for forced updates (future-proofing)
   - Validate local database integrity
   - Perform any necessary migrations
   - Load user preferences (theme, locale)
6. When bootstrap completes successfully, the scaffold shall navigate to the main app (bottom tab navigation)
7. If initialization fails, then the scaffold shall display error screen with retry option
8. The scaffold shall ensure splash screen displays for minimum 1 second to avoid jarring transitions
9. When bootstrap process is in progress, the scaffold shall prevent user navigation

### Requirement 14: Bottom Tab Bar Navigation

**Objective:** As a user, I want bottom tab bar navigation to primary app sections, so that I can quickly access main features.

#### Acceptance Criteria

1. The scaffold shall integrate `go_router` package with `go_router_builder` for type-safe routing
2. The scaffold shall create `AppRouter` class in `packages/audiflow_app/lib/routing/app_router.dart` using `@TypedGoRoute` annotations
3. When app launches, the scaffold shall display a `ScaffoldWithNavBar` widget containing bottom navigation bar
4. The scaffold shall define navigation tabs: Discovery, Library, Queue, Settings
5. The scaffold shall create placeholder screens for each tab in `packages/audiflow_app/lib/features/` following structure:
   - `discovery/presentation/screens/discovery_screen.dart`
   - `library/presentation/screens/library_screen.dart`
   - `queue/presentation/screens/queue_screen.dart`
   - `settings/presentation/screens/settings_screen.dart`
6. When user taps a tab, the scaffold shall navigate to the corresponding route and maintain navigation state
7. The scaffold shall use Material Symbols Icons for tab bar icons
8. The scaffold shall highlight the currently active tab with primary color
9. The scaffold shall provide a Riverpod provider for managing current navigation index
