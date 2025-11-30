# Implementation Plan

## Task Breakdown

### Phase 1: Workspace & Package Scaffolding

- [x] 1. Configure monorepo workspace foundation
- [x] 1.1 Configure root workspace with Flutter pub resolution
  - Add `resolution: workspace` to root pubspec.yaml
  - Configure SDK constraints (Dart ≥3.9.2, Flutter 3.35+)
  - Set repository metadata and version
  - Verify workspace resolution with `flutter pub get`
  - _Requirements: 1.1, 1.2_

- [x] 1.2 Configure Melos orchestration
  - Create melos.yaml with package globs (`packages/**`)
  - Define bootstrap hooks (post: codegen)
  - Configure concurrency scripts: codegen, test, analyze, clean
  - Add test:coverage script with coverage reporting
  - Verify package discovery with `melos list`
  - _Requirements: 1.8_

- [x] 2. Create workspace package structure
- [x] 2.1 (P) Create audiflow_app application package
  - Generate Flutter app package with `flutter create --no-pub`
  - Configure pubspec.yaml WITHOUT dependencies (added in Task 2.5)
  - Set publish_to: 'none'
  - Create lib/ directory structure: app/, features/, routing/, l10n/
  - Create main export barrel file
  - _Requirements: 1.4_

- [x] 2.2 (P) Create audiflow_core Dart package
  - Generate Dart package with `flutter create --template=package --no-pub`
  - Configure pubspec.yaml (Dart-only, no Flutter dependencies)
  - Set publish_to: 'none'
  - Create lib/src/ structure: constants/, config/, errors/, extensions/, utils/
  - Create main export barrel: lib/audiflow_core.dart
  - _Requirements: 1.5_

- [x] 2.3 (P) Create audiflow_domain Dart package
  - Generate Dart package with `flutter create --template=package --no-pub`
  - Configure pubspec.yaml WITHOUT dependencies (added in Task 2.5)
  - Set publish_to: 'none'
  - Create lib/src/ structure: common/, features/
  - Create main export barrel: lib/audiflow_domain.dart
  - _Requirements: 1.6_

- [x] 2.4 (P) Create audiflow_ui Flutter package
  - Generate Flutter package with `flutter create --template=package --no-pub`
  - Configure pubspec.yaml WITHOUT dependencies (added in Task 2.5)
  - Set publish_to: 'none'
  - Create lib/src/ structure: widgets/, themes/, styles/
  - Create main export barrel: lib/audiflow_ui.dart
  - _Requirements: 1.7_

- [x] 2.5 Add all package dependencies before bootstrap
  - Add flutter_dotenv, path_provider to audiflow_core pubspec
  - Add isar, isar_flutter_libs, dio, riverpod_annotation, build_runner, riverpod_generator, freezed, freezed_annotation, json_annotation, json_serializable to audiflow_domain pubspec
  - Add flutter_screenutil 5.9.3, cached_network_image 3.3.1, extended_image, material_symbols_icons, dynamic_color to audiflow_ui pubspec
  - Add workspace package dependencies: audiflow_app depends on all packages, audiflow_ui depends on core and domain, audiflow_domain depends on core
  - Add go_router, sentry_flutter, sentry_dio, audio_service, audio_session, flutter_native_splash, flutter_launcher_icons, flutter_localizations, intl to audiflow_app pubspec
  - Add mockito, riverpod_test to dev_dependencies in audiflow_app
  - Verify all dependency declarations complete
  - _Requirements: 1.4, 1.5, 1.6, 1.7_

- [x] 2.6 Bootstrap workspace packages
  - Run `melos bootstrap` to link packages and install dependencies
  - Verify all package dependencies resolved
  - Test cross-package imports
  - _Requirements: 1.3_

### Phase 2: Development Infrastructure

- [x] 3. Configure development tooling and quality infrastructure
- [x] 3.1 (P) Configure code generation infrastructure
  - Add build_runner dependencies to all packages with lib/ directories
  - Configure analysis_options.yaml at repository root with flutter_lints, riverpod_lint
  - Set analyzer to treat warnings as errors
  - Add pedantic_mono lint rules
  - Test `melos run codegen` execution
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.7, 3.8_

- [x] 3.2 (P) Configure development automation
  - Create Melos script for `codegen:watch` in watch mode
  - Create Melos script for parallel testing across packages
  - Create Git pre-commit hook template (analyze + test + codegen check)
  - Document hook installation in README
  - _Requirements: 3.5, 3.6, 3.9, 3.10_

- [x] 13. Implement testing infrastructure foundation
- [x] 13.1 Configure testing dependencies
  - Verify flutter_test SDK dependency in all packages
  - Verify mockito and build_runner in dev_dependencies
  - Add riverpod_test for provider testing (if available)
  - Configure test/ directories mirroring lib/ structure
  - _Requirements: 2.1, 2.2_

- [x] 13.2 Create test helper utilities
  - Create packages/audiflow_app/test/helpers/pump_app.dart extension
  - Implement pumpApp() helper with ProviderScope, theme, locale, routing
  - Create test_providers.dart with createMockContainer() utility
  - Create fixtures.dart with common test data
  - _Requirements: 2.3, 2.4_

- [x] 13.3 Generate mock classes with mockito
  - Create test/helpers/mocks.dart with @GenerateMocks annotations
  - Annotate SharedPreferences, PackageInfo, Isar, Dio, Logger
  - Run build_runner to generate mock classes
  - Verify mocks.mocks.dart generated
  - _Requirements: 2.3_

### Phase 3: Riverpod Foundation

- [ ] 10. Implement Riverpod state management foundation
- [ ] 10.1 Configure Riverpod with code generation
  - Add riverpod, flutter_riverpod, riverpod_annotation dependencies
  - Add riverpod_generator to dev_dependencies
  - Configure riverpod_lint in analysis_options.yaml
  - Wrap root widget with ProviderScope (in main.dart)
  - _Requirements: 8.1, 8.5, 8.6_

- [ ] 10.3 Create app-level infrastructure providers
  - Create flavorConfigProvider exposing FlavorConfig.current
  - Create themeModeNotifierProvider skeleton (implementation in Phase 5)
  - Create localeNotifierProvider skeleton (implementation in Phase 6)
  - Provider overrides configured in main.dart
  - _Requirements: 8.7_

### Phase 4: Core Services

- [ ] 9. Implement core service initialization infrastructure (partial)
- [ ] 9.1 Implement platform service providers
  - Create sharedPreferencesProvider with keepAlive in audiflow_domain
  - Create packageInfoProvider with keepAlive
  - Create isarProvider with keepAlive
  - Create audioHandlerProvider with keepAlive
  - Create dioProvider with keepAlive
  - Create loggerProvider with keepAlive
  - All providers throw UnimplementedError (overridden at startup)
  - _Requirements: 12.7_

- [ ] 9.3 Implement main.dart initialization orchestration (basic services only)
  - Call WidgetsFlutterBinding.ensureInitialized()
  - Set orientation lock (portrait only)
  - Load dotenv with flavor-specific .env file
  - Implement parallel service initialization (SharedPreferences, PackageInfo, path_provider)
  - Open Isar database with schemas and app directory path
  - Initialize AudioService and AudioSession with error handling
  - Configure Dio with base URL, timeouts, basic interceptors (cache, logging only)
  - Initialize Logger with flavor-specific log levels
  - NOTE: Sentry initialization deferred to Phase 9
  - _Requirements: 12.1, 12.8, 12.9, 12.10_

- [ ] 4. Implement core configuration and constants
- [ ] 4.1 (P) Implement FlavorConfig system
  - Create FlavorConfig class with enum (dev, stg, prod)
  - Define flavor properties: name, apiBaseUrl, enableAnalytics, enableCrashReporting
  - Implement static current flavor accessor
  - Configure environment-specific values for each flavor
  - Add envFile property returning appropriate .env filename
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.8_

- [ ] 4.2 (P) Implement environment variable configuration
  - Create .env.example template with all required variables
  - Document required variables: SENTRY_DSN, API_BASE_URL, MIXPANEL_TOKEN, APP_NAME
  - Create Env class with static getters and validation
  - Implement validate() method throwing StateError for missing vars
  - Configure .gitignore to exclude .env.* except .env.example
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8_

### Phase 5: UI Foundation

- [ ] 4.3 (P) Create asset management infrastructure
  - Create asset directories: assets/images/, assets/fonts/, assets/icons/
  - Configure asset declarations in audiflow_app pubspec.yaml
  - Create AssetPaths constant class with static string paths
  - Add placeholder assets: splash_logo.png, app_icon.png
  - Configure custom fonts if needed
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 4.4 (P) Configure CachedNetworkImage and extended_image
  - Configure CachedNetworkImage with default placeholder and error widgets
  - Set up extended_image for advanced features (zoom, crop, cache)
  - Create reusable image loading widgets in audiflow_ui
  - Document usage patterns
  - _Requirements: 4.6, 4.7_

- [ ] 5. Implement UI foundation components
- [ ] 5.1 (P) Configure responsive design system
  - Integrate flutter_screenutil in audiflow_ui pubspec
  - Wrap MaterialApp with ScreenUtilInit (design size 375x812)
  - Configure minTextAdapt: true, splitScreenMode: true
  - Create responsive utility classes with device type detection (phone width less than 600dp)
  - Add BuildContext extensions: isPhone, isTablet, screenWidth, screenHeight
  - Create responsive spacing utilities using ScreenUtil
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_

- [ ] 5.2 (P) Implement Material Design 3 theme system
  - Create ColorScheme definitions for light and dark modes
  - Define primary, secondary, tertiary, error, surface, background colors
  - Integrate dynamic_color package for platform-native theming
  - Create ThemeData configurations with Material 3 enabled
  - Create app_theme.dart, color_scheme.dart, text_styles.dart
  - Export theme components from audiflow_ui barrel
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.8_

- [ ] 5.3 Implement theme mode state management
  - Complete ThemeModeNotifier Riverpod provider implementation with persistence
  - Load theme preference from SharedPreferences on build
  - Implement setThemeMode() saving to SharedPreferences
  - Support system, light, dark modes
  - Integrate in MaterialApp.router configuration
  - NOTE: Depends on sharedPreferencesProvider from Task 9.1
  - _Requirements: 9.5, 9.6, 9.7_

### Phase 6: Internationalization

- [ ] 6. Implement internationalization infrastructure
- [ ] 6.1 Configure Flutter gen-l10n
  - Create l10n.yaml at repository root
  - Configure ARB directory (lib/l10n), template file (app_en.arb)
  - Set output file: l10n.dart, nullable-getter: false, synthetic-package: false
  - Add `generate: true` to audiflow_app pubspec.yaml
  - Verify flutter_localizations and intl dependencies from Task 2.5
  - _Requirements: 10.2, 10.3_

- [ ] 6.2 Create ARB translation files
  - Create app_en.arb with base translation keys
  - Create app_ja.arb with Japanese translations
  - Add keys: appTitle, ok, cancel, loading, error, retry
  - Validate ARB file structure
  - Run `flutter gen-l10n` to generate localizations
  - _Requirements: 10.1, 10.4_

- [ ] 6.3 Configure localization in app
  - Register localization delegates in MaterialApp.router
  - Configure supported locales: en, ja
  - Complete LocaleNotifier Riverpod provider implementation with persistence
  - Load locale preference from SharedPreferences
  - Implement setLocale() with persistence
  - NOTE: Depends on sharedPreferencesProvider from Task 9.1
  - _Requirements: 10.5, 10.6, 10.7, 10.8_

### Phase 7: Navigation System

- [ ] 12. Implement navigation system
- [ ] 12.1 Configure go_router with code generation
  - Verify go_router and go_router_builder dependencies from Task 2.5
  - Create AppRouter class in packages/audiflow_app/lib/routing/
  - Configure type-safe routes with @TypedGoRoute annotations
  - Define SplashRoute
  - Configure debug logging based on flavor
  - _Requirements: 14.1, 14.2_

- [ ] 12.2 Define bottom tab navigation routes
  - Create StatefulShellRoute with TypedStatefulShellRoute annotation
  - Define branches: DiscoveryBranch, LibraryBranch, QueueBranch, SettingsBranch
  - Create route definitions: DiscoveryRoute, LibraryRoute, QueueRoute, SettingsRoute
  - Configure paths: /discovery, /library, /queue, /settings
  - Configure /home route redirecting to /discovery
  - _Requirements: 14.4_

- [ ] 12.3 Implement ScaffoldWithNavBar
  - Create ScaffoldWithNavBar widget receiving StatefulNavigationShell
  - Implement NavigationBar with 4 destinations
  - Configure Material Symbols Icons for tabs (explore, library_music, queue_music, settings)
  - Handle destination selection with goBranch navigation
  - Highlight active tab with primary color
  - Preserve navigation state across tab switches
  - _Requirements: 14.3, 14.6, 14.7, 14.8_

- [ ] 12.4 Create placeholder feature screens
  - Create packages/audiflow_app/lib/features/discovery/presentation/screens/discovery_screen.dart
  - Create packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart
  - Create packages/audiflow_app/lib/features/queue/presentation/screens/queue_screen.dart
  - Create packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart
  - Each screen displays simple placeholder UI with feature name
  - _Requirements: 14.5_

- [ ] 12.5 Create navigation index provider
  - Create Riverpod provider managing current navigation index
  - Integrate with ScaffoldWithNavBar for state management
  - _Requirements: 14.9_

### Phase 8: Bootstrap Feature

- [ ] 11. Implement bootstrap feature
- [ ] 11.1 Create bootstrap feature structure
  - Create packages/audiflow_app/lib/features/bootstrap/ directory
  - Create presentation/controllers/ subdirectory
  - Create presentation/screens/ subdirectory
  - _Requirements: 13.1_

- [ ] 11.2 Implement SplashScreen widget
  - Create SplashScreen displaying app logo
  - Add loading indicator
  - Watch bootstrapControllerProvider
  - Listen for bootstrap completion and navigate to /home
  - Display error UI with retry button on failure
  - NOTE: /home route must exist from Task 12.2
  - _Requirements: 13.2, 13.7_

- [ ] 11.3 Implement BootstrapController
  - Create BootstrapController Riverpod provider
  - Implement build() method performing initialization sequence
  - Validate Isar database integrity
  - Load user preferences (theme, locale)
  - Enforce minimum 1s splash display time
  - Implement retry() method invalidating provider
  - _Requirements: 13.3, 13.4, 13.5, 13.8, 13.9_

- [ ] 11.4 Configure bootstrap routing
  - Set initial route to /splash in AppRouter
  - Verify navigation to /home on bootstrap success
  - Prevent navigation during bootstrap
  - _Requirements: 13.6_

### Phase 9: Enhanced Services

- [ ] 9.2 Configure Sentry error tracking
  - Add sentry_flutter and sentry_dio dependencies (verified in Task 2.5)
  - Implement Sentry initialization wrapper in main.dart
  - Configure DSN from environment variables
  - Set environment tag from FlavorConfig
  - Configure release version from PackageInfo
  - Enable auto session tracking based on flavor
  - Set traces sample rate (production: 0.2, dev: 1.0)
  - _Requirements: 12.2_

- [ ] 9.4 Configure global error handlers
  - Set FlutterError.onError to log and capture in Sentry
  - Set PlatformDispatcher.instance.onError for async errors
  - Configure flavor-based crash reporting (disabled in dev)
  - Provide global error widget builder
  - Update Sentry scope with app version and build number
  - _Requirements: 12.3, 12.4, 12.5_

- [ ] 9.5 Implement AppLifecycleListener
  - Create AppLifecycleListener for lifecycle events
  - Log lifecycle state changes using logger
  - Configure audio session handling on interruptions
  - _Requirements: 12.11_

- [ ] 10.2 Implement AppProviderObserver
  - Create AppProviderObserver class extending ProviderObserver
  - Implement didAddProvider logging provider creation
  - Implement didUpdateProvider logging state changes
  - Implement didDisposeProvider logging disposal
  - Implement providerDidFail capturing errors to Sentry
  - Register observer in ProviderScope
  - _Requirements: 8.2, 8.3, 8.4, 8.8_

### Phase 10: Build System

- [ ] 7. Configure multi-flavor build system
- [ ] 7.1 Create flavor entry points
  - Create main_dev.dart initializing FlavorConfig.dev
  - Create main_stg.dart initializing FlavorConfig.stg
  - Create main_prod.dart initializing FlavorConfig.prod
  - Load appropriate .env file based on flavor
  - Configure common initialization in shared main() function
  - _Requirements: 7.1, 7.3, 7.7_

- [ ] 7.2 Configure native flavor setup with flavorizr
  - Install flutter_flavorizr package (verified in Task 2.5)
  - Create flavorizr configuration (iOS schemes, Android product flavors)
  - Configure bundle IDs per flavor for simultaneous installation
  - Run flavorizr to generate native configurations
  - Test build commands for each flavor
  - _Requirements: 7.6_

- [ ] 8. Configure splash screens and app icons
- [ ] 8.1 (P) Configure flutter_native_splash
  - Verify flutter_native_splash dependency from Task 2.5
  - Create flutter_native_splash.yaml at repository root
  - Configure background colors (light/dark variants)
  - Set splash logo image path
  - Add flavor-specific configurations (dev, stg, prod)
  - Configure Android 12+ specific settings
  - Generate splash resources with `dart run flutter_native_splash:create`
  - _Requirements: 11.1, 11.2, 11.3_

- [ ] 8.2 (P) Configure flutter_launcher_icons
  - Verify flutter_launcher_icons dependency from Task 2.5
  - Create flutter_launcher_icons.yaml at repository root
  - Configure Android and iOS icon paths
  - Set adaptive icon configurations for Android
  - Add flavor-specific icon variants
  - Generate launcher icons with `dart run flutter_launcher_icons`
  - Verify icon generation for all platforms and flavors
  - _Requirements: 11.4, 11.5, 11.6, 11.7_

### Phase 11: Feature Tests

- [ ] 13.4* Create example tests demonstrating patterns
  - Create unit test for Riverpod provider (e.g., FlavorConfig provider)
  - Create widget test with routing (e.g., SplashScreen navigation)
  - Create widget test with theme switching
  - Create widget test with localization
  - Document test patterns in test files
  - _Requirements: 2.5_

### Phase 12: Final Validation

- [ ] 13.5 Configure test coverage reporting
  - Add coverage configuration to Melos test:coverage script
  - Configure minimum coverage threshold (80%) as target
  - Document coverage generation command
  - Test `melos run test:coverage` execution
  - _Requirements: 2.6, 2.7, 2.8_

- [ ] 14. Final integration and validation
- [ ] 14.1 Run complete code generation
  - Execute `melos run codegen` for all packages
  - Verify all generated files created (.g.dart, .freezed.dart)
  - Fix any code generation errors
  - Commit generated files
  - _Requirements: 3.1, 3.2_

- [ ] 14.2 Execute full test suite
  - Run `melos run test` across all packages
  - Verify all tests pass
  - Check test coverage meets 80% target
  - Fix any failing tests
  - _Requirements: 2.6, 2.7, 2.8_

- [ ] 14.3 Validate build for all flavors
  - Build dev flavor: `flutter run --flavor dev -t lib/main_dev.dart`
  - Build staging flavor: `flutter run --flavor stg -t lib/main_stg.dart`
  - Build production flavor: `flutter build apk --flavor prod -t lib/main_prod.dart --release`
  - Verify app launches and displays SplashScreen
  - Verify bootstrap completes and navigates to bottom tabs
  - Test tab switching and navigation state preservation
  - _Requirements: 7.7, 13.6, 14.6_

- [ ] 14.4 Verify quality gates
  - Run `flutter analyze` with zero issues
  - Verify all lint rules enforced
  - Test pre-commit hook functionality
  - Validate all environment variables in .env.example
  - Review generated documentation
  - _Requirements: 3.3, 3.4, 3.9, 6.7_

- [ ] 14.5 Performance validation
  - Measure cold start time (target: less than 1000ms on mid-range device)
  - Profile parallel service initialization (target: less than 500ms)
  - Measure database validation time (target: less than 100ms)
  - Test tab switching frame rate (target: 60 FPS, frame time less than 16ms)
  - Use Flutter DevTools performance overlay for profiling
  - _Requirements: 13.8_

## Implementation Notes

### Critical Dependency Order

**Task 2.5 is critical**: All package dependencies MUST be declared before `melos bootstrap` in Task 2.6. This prevents bootstrap failures and ensures proper workspace resolution.

**Phase 3 before Phase 4-6**: Riverpod foundation (Tasks 10.1, 10.3) must be established before service providers (Task 9.1) and state management features (Tasks 5.3, 6.3) that depend on Riverpod code generation.

**Phase 4 before Phase 5-6**: Core service providers (Task 9.1) must exist before theme and locale state management (Tasks 5.3, 6.3) that depend on SharedPreferences provider.

**Phase 7 before Phase 8**: Navigation routes (Tasks 12.1-12.5) must be defined before bootstrap feature (Task 11.2) that navigates to /home route.

**Phase 8 before Phase 9**: Basic initialization (Task 9.3) establishes platform services before Sentry enhancement (Tasks 9.2, 9.4) adds error tracking layer.

### Parallel Execution Guidelines

- Tasks marked with `(P)` can be executed in parallel with other `(P)` tasks within the same phase
- Package creation (Tasks 2.1-2.4) can run in parallel as they operate on separate directories
- Asset management (4.3), image configuration (4.4), responsive design (5.1), and theme system (5.2) can run in parallel as they operate in separate packages with no shared state
- Splash and icons (8.1, 8.2) can run in parallel as they generate independent native resources

### Optional Test Coverage

- Task 13.4 marked with `*` is optional test coverage that can be deferred post-MVP
- Implementation work takes priority; example tests demonstrate patterns but are not blocking for MVP launch

### Code Generation

All tasks involving annotations (@riverpod, @freezed, @collection, @TypedGoRoute) require running `melos run codegen` after implementation. Final code generation sweep happens in Task 14.1.

### Testing Strategy

Phase 2 establishes testing infrastructure early to enable TDD workflow throughout implementation. Phase 11 adds feature-specific example tests after features are implemented. Phase 12 validates complete test coverage.
