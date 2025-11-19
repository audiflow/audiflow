# Research Document: project-scaffold

## Overview

This document captures the discovery and research findings for the project-scaffold feature, focusing on Flutter monorepo setup, state management patterns, and production-ready infrastructure initialization.

## Technology Research

### Flutter Workspace & Melos Monorepo Management

**Key Findings:**
- Dart 3.6+ and Flutter 3.27+ have native support for monorepos through Pub Workspaces
- Melos is the de facto standard for Flutter monorepo orchestration in 2025
- Melos 'bootstrap' command handles dependency resolution and workspace linking automatically
- CI/CD optimization: Melos can detect changed packages between commits for selective testing

**Configuration Best Practices:**
- Root `pubspec.yaml` must include `resolution: workspace`
- `melos.yaml` defines workspace packages and custom scripts
- Structure: `packages/` directory containing all workspace packages
- Melos scripts enable parallel execution of code generation, testing, and analysis

**Source:** Flutter at Scale articles, Melos documentation (2025)

### Riverpod 3.0 Code Generation Patterns

**Key Findings:**
- `@riverpod` annotation eliminates provider boilerplate
- Automatic part file generation with `riverpod_generator`
- New Notifier API reduces boilerplate for stateful providers
- Reactive caching, automatic retry, and offline persistence features in Riverpod 3.0

**Integration Pattern:**
```dart
@riverpod
class ExampleController extends _$ExampleController {
  @override
  Future<Data> build() async {
    // Provider logic
  }
}
```

**Dependencies Required:**
- `flutter_riverpod: ^3.0.0`
- `riverpod_annotation: ^3.0.0`
- `riverpod_generator: ^3.0.0` (dev)
- `build_runner: ^2.4.0` (dev)

**Source:** Riverpod 3.0 release notes, Code with Andrea tutorials (2025)

### Isar Database Initialization

**Best Practices:**
- Initialize before `runApp()` after calling `WidgetsFlutterBinding.ensureInitialized()`
- Use `path_provider` to get application documents directory
- Register all collection schemas in `Isar.open()`
- Global instance access via `late final Isar isar`

**Initialization Pattern:**
```dart
Future<void> initializeIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [Schema1, Schema2, ...],
    directory: dir.path,
  );
}
```

**Testing Consideration:**
- Call `await Isar.initializeIsarCore(download: true)` for unit tests

**Source:** Isar documentation, Flutter community guides (2025)

### Responsive Design with flutter_screenutil

**Configuration:**
- `ScreenUtilInit` with design size (baseline: 375x812 for iPhone X)
- Scaling utilities: `.w`, `.h`, `.sp`, `.r`
- Configuration options: `minTextAdapt: true`, `splitScreenMode: true`

**Common Breakpoints:**
- Phone: width < 600dp
- Tablet: width >= 600dp
- Desktop: width >= 1200dp (not applicable for this mobile-only app)

**Best Practice:**
- Combine flutter_screenutil for scaling with LayoutBuilder/MediaQuery for breakpoint detection
- Test in portrait/landscape orientations

**Source:** flutter_screenutil documentation, responsive design guides (2025)

### Type-Safe Routing with go_router 16

**Code Generation Approach:**
- Use `@TypedGoRoute()` annotations with `go_router_builder`
- Create route classes extending `GoRouteData`
- Compile-time type checking prevents routing errors
- Better IDE support and refactoring safety

**Navigation Pattern:**
```dart
@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) => HomeScreen();
}
```

**Best Practices:**
- Centralize routes in a single file or router class
- Avoid string-based routing
- Use named route constants

**Source:** go_router documentation, Flutter navigation guides (2025)

### Multi-Flavor Configuration

**Setup Requirements:**
- Separate entry points: `main_dev.dart`, `main_stg.dart`, `main_prod.dart`
- Native configuration per platform (Android product flavors, iOS schemes)
- Different bundle IDs for simultaneous installation
- `flutter_flavorizr` package automates native setup

**Environment Isolation:**
- Dev: local/mock APIs, analytics disabled, crash reporting disabled
- Staging: staging APIs, analytics enabled, crash reporting enabled
- Production: production APIs, analytics enabled, crash reporting enabled

**Build Commands:**
```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter build apk --flavor prod -t lib/main_prod.dart --release
```

**Source:** Flutter official documentation, flavor tutorials (Oct 2025)

### Environment Variables with flutter_dotenv

**Latest Version:** 6.0.0

**Initialization:**
```dart
await dotenv.load(fileName: ".env");
```

**Security Considerations:**
- **Critical:** Sensitive keys can be extracted from Flutter apps even when obfuscated
- Use for non-sensitive configuration only
- Sensitive API keys should use backend proxy or platform-specific secure storage

**Features:**
- Variable referencing: `$FOO$BAR`
- Merging multiple env files
- Typed getters: `getInt()`, `getBool()`, `getDouble()`

**Source:** flutter_dotenv pub.dev (v6.0.0)

### Audio Service & just_audio Integration

**Initialization Pattern:**
```dart
final audioHandler = await AudioService.init(
  builder: () => AudioPlayerHandler(),
  config: AudioServiceConfig(
    androidNotificationChannelId: 'com.example.app.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  ),
);
```

**AudioHandler Pattern:**
- Extend `BaseAudioHandler` with `SeekHandler`
- Initialize `just_audio.AudioPlayer` instance
- Connect player's playback event stream to audio_service state
- Implement media controls and notification management

**Alternative:**
- `just_audio_background` for simpler use cases without full audio_service

**Source:** audio_service documentation, Flutter audio guides (2025)

### Splash Screen Configuration

**Package:** flutter_native_splash 2.4.7

**Configuration Structure:**
- YAML-based configuration in `flutter_native_splash.yaml`
- Android 12+ requires separate configuration section
- Flavor support via named YAML files: `flutter_native_splash-{flavor}.yaml`

**Generation Commands:**
```bash
dart run flutter_native_splash:create --flavor production
dart run flutter_native_splash:create --all-flavors
```

**Key Requirements:**
- Android 12: Window background, center icon (1152×1152px), icon background color
- iOS: Standard splash assets via Xcode

**Source:** flutter_native_splash pub.dev (v2.4.7)

### Internationalization (i18n) Setup

**Configuration:**
- `generate: true` in `pubspec.yaml`
- `l10n.yaml` configuration file at project root
- ARB files for each locale in `lib/l10n/`

**Essential l10n.yaml Settings:**
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
nullable-getter: false
synthetic-package: false
```

**Automation:**
- Running the app auto-generates localization files
- `flutter gen-l10n` for manual generation

**Limitations:**
- gen_l10n doesn't fully support nested plurals/selects (in active development)

**Source:** Flutter i18n documentation, ARB best practices (2025)

### Sentry Error Tracking

**Initialization Pattern:**
```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'https://example@sentry.io/your-dsn';
    options.environment = 'production';
    options.release = '1.0.0';
  },
  appRunner: () => runApp(MyApp()),
);
```

**Error Capture:**
- Automatic capture of `FlutterError.onError`
- Zone-based error handling for async errors
- `isolate.addSentryErrorListener()` for background tasks
- `SentryNavigatorObserver` for navigation tracking

**Dio Integration:**
- Use `sentry_dio` package for HTTP request/response tracking
- Add `SentryDioClientAdapter` to Dio instance

**Source:** sentry_flutter documentation

## Architecture Decisions

### Monorepo Package Structure

**Decision:** Four-package workspace architecture
- `audiflow_app`: Main Flutter application
- `audiflow_core`: Dart-only shared utilities
- `audiflow_domain`: Business logic, repositories, data sources, Isar models
- `audiflow_ui`: Shared Flutter UI components

**Rationale:**
- Clear separation of concerns
- Enables parallel development
- Reduces coupling between layers
- Facilitates code reuse across features

**Domain Boundaries:**
- Core has no dependencies on other packages
- Domain depends only on core
- UI depends on core and domain
- App depends on all packages

### Merged Data + Domain Layer

**Decision:** Combine traditional data and domain layers in `audiflow_domain`

**Rationale:**
- Zero mapping overhead - Isar models used directly as domain entities
- Simpler codebase - fewer layers to navigate
- Faster development - less boilerplate
- Performance optimization for mobile

**Trade-offs Accepted:**
- Less flexibility to swap Isar (acceptable - committed to Isar)
- Repository implementations in same package as interfaces (acceptable for monorepo)

### State Management: Riverpod 3.0 with Code Generation

**Decision:** Use `@riverpod` annotation exclusively, avoid manual provider definitions

**Rationale:**
- Compile-time safety with code generation
- Reduced boilerplate
- Better IDE support and refactoring
- Automatic dependency injection

**Pattern:**
- Infrastructure providers in `audiflow_domain/src/common/providers/`
- Feature-specific providers in respective feature directories
- Presentation controllers in `audiflow_app/lib/features/{feature}/presentation/controllers/`

### Database: Isar Collections as Domain Entities

**Decision:** Use Isar `@collection` models directly throughout the application

**Rationale:**
- Eliminates DTO conversion overhead
- Single source of truth for data structure
- Leverages Isar's built-in types (DateTime, enum support)
- Simpler testing - no mapping logic to verify

**Pattern:**
- Persisted models: `@collection` annotation
- Transient models: `@freezed` annotation
- All models in `audiflow_domain/lib/src/features/{feature}/models/`

### Testing Strategy

**Decision:** TDD approach with comprehensive test helpers

**Rationale:**
- Catch issues early in development
- Document expected behavior
- Enable refactoring with confidence
- 80% coverage target aligns with industry standards

**Infrastructure:**
- `pump_app.dart` helper for widget tests with providers/theme/routing
- `createMockContainer()` for provider testing
- Example tests demonstrating patterns
- Melos scripts for parallel test execution

## Risk Assessment

### Performance Risks

**Risk:** Isar initialization delay on first app launch
- **Mitigation:** Initialize in parallel with other services, show splash screen with minimum 1s duration
- **Severity:** Low - typical initialization <100ms

**Risk:** Riverpod provider rebuild performance
- **Mitigation:** Use `@riverpod(keepAlive: true)` for global services, proper provider scoping
- **Severity:** Low - Riverpod 3.0 optimized for performance

### Integration Complexity

**Risk:** Audio service initialization conflicts with other platform services
- **Mitigation:** Strict initialization order in main.dart, proper error handling
- **Severity:** Medium - audio service requires platform channels

**Risk:** Flavor configuration mismatch between Dart and native code
- **Mitigation:** Use flutter_flavorizr for automated setup, comprehensive testing
- **Severity:** Medium - manual configuration error-prone

### Development Risks

**Risk:** Code generation dependency management across workspace packages
- **Mitigation:** Melos scripts for synchronized code generation, clear documentation
- **Severity:** Low - Melos handles workspace coordination

**Risk:** ARB file maintenance for multiple locales
- **Mitigation:** Establish process for translation updates, CI checks for missing keys
- **Severity:** Low - only 2 locales (en, ja)

### Security Considerations

**Risk:** Sensitive data exposure via environment variables
- **Mitigation:** Never store API keys in .env files, use backend proxy for sensitive operations
- **Severity:** High - documented in design, enforced in code review

**Risk:** Sentry DSN exposure in client code
- **Mitigation:** Acceptable - Sentry DSNs are designed for client-side use, implement rate limiting on backend
- **Severity:** Low - Sentry best practice

## Gaps Requiring Further Investigation

### Firebase Configuration
- Firebase flavor setup not fully specified in requirements
- **Action:** Defer to future feature specification when Firebase features are defined

### Platform-Specific Permissions
- Exact permission requirements for audio playback not detailed
- **Action:** Document in audio player feature specification

### Migration from v1
- v1 reference implementation exists but migration strategy undefined
- **Action:** Consider data migration requirements in separate specification

### CI/CD Pipeline
- Melos CI/CD integration patterns identified but pipeline not specified
- **Action:** Address in CI/CD infrastructure specification

## Conclusion

All 14 requirements are technically feasible with the chosen technology stack. The monorepo architecture, Riverpod 3.0 state management, and Isar database integration are well-supported by current Flutter ecosystem. The merged data+domain layer provides performance benefits while maintaining architectural clarity.

Key success factors:
1. Strict initialization order in main.dart
2. Comprehensive test helpers for TDD workflow
3. Melos automation for code generation and testing
4. Proper flavor isolation for environment management

No blocking technical risks identified. Medium-severity risks have clear mitigation strategies.
