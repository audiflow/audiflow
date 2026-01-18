# Audiflow v2 - Tech Stack

## Core Stack
- **Flutter 3.38.5** / **Dart 3.10.4**
- **iOS 14.0+** / **Android 8.0+ (API 26+)**
- **Analyzer**: 10.x (overridden in root pubspec.yaml for Riverpod 4.x compatibility)

## Critical Dependencies (Always Use These)

**State Management:**
- `riverpod: 3` + code generation (`riverpod_annotation`, `riverpod_generator`)
- Pattern: Use `@riverpod` annotation for all providers

**Database:**
- `drift` + `sqlite3_flutter_libs`
- Pattern: Define tables by extending `Table` class, Drift generates data classes

**Audio:**
- `just_audio` - Primary player
- `audio_service` - Background audio framework
- `audio_session` - Audio focus/interruption

**Networking:**
- `dio` - HTTP client
- `dio_cache_interceptor` + stores - HTTP caching
- `connectivity_plus` - Network monitoring

**Podcast:**
- `podcast_feed_parser` - RSS parsing
- `podcast_feed_searcher` - iTunes API

**Navigation:**
- `go_router` + `go_router_builder` - Type-safe routing

**Code Generation:**
- `build_runner`
- `freezed` - Immutable data classes
- `json_serializable` - JSON serialization

**Monitoring:**
- `sentry_flutter` + `sentry_dio` - Error tracking
- `logger` - Logging

## UI Libraries

**Material & Design:**
- `dynamic_color` - Material You colors
- `material_symbols_icons` - Material icons

**Utilities:**
- `flutter_hooks` - React hooks pattern
- `extended_image` - Advanced image loading
- `auto_size_text` - Auto-sizing text
- `flutter_html` - HTML rendering

## File & Permissions
- `flutter_downloader` - Background downloads
- `path_provider` - Directory access
- `permission_handler` - Runtime permissions

## Platform Services
- `share_plus` - Share content
- `url_launcher` - Open URLs
- `uni_links` - Deep linking
- `package_info_plus` - App version
- `device_info_plus` - Device details

## Linting & Testing
- `flutter_lints` + `riverpod_lint`
- `mockito` - Mocking for tests
- `http_mock_adapter` - HTTP mocking

## When to Use What

**State management?**
→ Always use Riverpod with `@riverpod` annotation

**Local data storage?**
→ Complex data: Drift tables (extend Table class)
→ Simple key-value: SharedPreferences

**Network requests?**
→ Dio with caching interceptors

**Immutable data classes?**
→ Use `@freezed` annotation

**JSON serialization?**
→ Use `@JsonSerializable()` annotation

**Navigation?**
→ go_router with type-safe routes

**Background tasks?**
→ Long tasks: worker_manager (isolates)
→ Audio: audio_service

## Build Flavors
```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor stg -t lib/main_stg.dart

# Production (release)
flutter build apk --flavor prod -t lib/main_prod.dart --release
flutter build ios --flavor prod -t lib/main_prod.dart --release
```

## Common Commands

**Code generation:**
```bash
dart run build_runner build --delete-conflicting-outputs  # Full build
dart run build_runner watch  # Watch mode
```

**Analysis:**
```bash
flutter analyze  # Must pass with zero issues
flutter test     # Must pass all tests
```

**Localization:**
```bash
flutter gen-l10n  # Generate from ARB files
```

## Generated Files
- `*.g.dart` - Riverpod, JSON, Drift
- `*.freezed.dart` - Freezed classes
- `*.gr.dart` - GoRouter routes

**Never edit generated files manually!**
