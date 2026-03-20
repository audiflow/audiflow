# audiflow

A podcast player for Android and iOS built with Flutter.

## Features

- Podcast discovery via iTunes search and genre/region charts
- Subscription management with automatic feed refresh
- Background audio playback with system media controls
- Episode downloads with WiFi-only option and queue management
- Playback speed control and sleep timer
- Smart playlist consumption (curated episode groupings)
- Station management (custom multi-podcast playlists)
- Podcast transcript and chapter display
- On-device voice commands

## Requirements

- Flutter 3.41.4+ / Dart 3.11.1+
- iOS 14.0+ / Android 8.0+ (API 26)
- Melos 7.3+

## Getting Started

```bash
# Install Melos globally
dart pub global activate melos

# Bootstrap all packages
melos bootstrap

# Run code generation
melos run codegen

# Run the app (development flavor)
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=.env.dev
```

## Project Structure

This is a monorepo managed by [Melos](https://melos.invertase.dev/) and Flutter workspaces.

| Package | Role |
|---------|------|
| `audiflow_app` | Main Flutter app: routing, screens, controllers |
| `audiflow_core` | Shared constants, extensions, utilities, error types |
| `audiflow_domain` | Business logic, repositories, data sources, Isar collections |
| `audiflow_podcast` | RSS parsing with streaming support, transcript/chapter extraction |
| `audiflow_ui` | Reusable widgets, themes, styles |
| `audiflow_ai` | On-device AI capabilities (Flutter plugin, iOS/Android) |
| `audiflow_search` | Podcast search and discovery API client |
| `audiflow_cli` | CLI tools for debugging |

## Development

```bash
# Run all tests
melos run test

# Run tests for a specific package
melos run test --scope=audiflow_domain

# Static analysis (zero issues required)
flutter analyze

# Code generation (after adding annotations)
melos run codegen
```

### Build Flavors

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=.env.dev

# Staging
flutter run --flavor stg -t lib/main_stg.dart --dart-define-from-file=.env.stg

# Production
flutter build apk --flavor prod -t lib/main_prod.dart --release --dart-define-from-file=.env.prod
flutter build ios --flavor prod -t lib/main_prod.dart --release --dart-define-from-file=.env.prod
```

## Architecture

- **State management**: Riverpod with code generation
- **Local storage**: Isar (offline-first)
- **Networking**: Dio with caching interceptors
- **Audio**: just_audio + audio_service
- **Navigation**: go_router with type-safe routes
- **Patterns**: Repository pattern, feature-based module organization

See [`docs/architecture/`](docs/architecture/) for detailed system design documentation.

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md)
before submitting a pull request. All contributors must sign the
[Contributor License Agreement](CLA.md).

## License

This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).
