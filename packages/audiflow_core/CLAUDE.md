# audiflow_core

Foundation package for the audiflow Flutter app. Provides shared constants, configuration, error types, extensions, and utilities used by every other package in the monorepo.

## Ecosystem context

Leaf dependency in the audiflow monorepo -- no internal package dependencies. All sibling packages (audiflow_domain, audiflow_podcast, audiflow_search, audiflow_ai, audiflow_ui, audiflow_app, audiflow_cli) depend on this package.

## Responsibilities

- App constants (`AppConstants`, `AssetPaths`, `LayoutConstants`, `SettingsKeys`)
- Build flavor configuration (`FlavorConfig` with dev/stg/prod, including smart playlist base URLs)
- Environment config (`Env`)
- Exception hierarchy (`AppException`, `NetworkException`, `ServerException`, `CacheException`, `ValidationException`, `DownloadException`)
- Failure types for result-based error handling
- Extension methods on `String`, `DateTime`, `Duration` (e.g., `formatEpisodeDate()`)
- Validators and formatters
- Device utilities
- Shared models (`AutoPlayOrder`, `EpisodeData`)

## Non-responsibilities

- Business logic, repositories, or data access (owned by audiflow_domain)
- RSS parsing (owned by audiflow_podcast)
- UI widgets, themes, or styling (owned by audiflow_ui)
- State management or providers

## Key entry points

- `lib/audiflow_core.dart` -- barrel file exporting the full public API
- `lib/src/errors/exceptions.dart` -- `AppException` sealed hierarchy
- `lib/src/config/flavor_config.dart` -- `FlavorConfig` with `initialize()` / `current`

## Validation

```bash
cd packages/audiflow_core && flutter test
flutter analyze .
```
