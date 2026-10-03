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

- [fvm](https://fvm.app/) (pins Flutter 3.47.6 / Dart 3.13.5 via `.fvmrc`)
- iOS (configured in Xcode) / Android 8.0+ (API 26)
- Melos 7.3+
- [mise](https://mise.jdx.dev/) (task runner; also installs sops, age, and pre-commit)

mise tasks run Flutter from `.fvm/flutter_sdk`. The project's `mise.toml` disables
any `flutter` from your global mise config, so mise never installs a second SDK here.

## Getting Started

```bash
# Install the pinned Flutter SDK into .fvm/flutter_sdk
fvm install

# Trust the mise config and install its tools
mise trust && mise install

# Install Melos globally (with the fvm Dart SDK)
mise exec -- dart pub global activate melos

# Maintainers only: clone audiflow-secrets next to this checkout and decrypt
# (contributors: create your own configs instead, see Secrets below)
mise run secrets:pull

# Bootstrap all packages
mise run setup

# Run code generation
mise run codegen

# Run the app (development flavor)
mise run run-dev
```

Run `mise tasks` to see all available tasks.

### Secrets

`.env.dev`, `.env.stg`, `.env.prod`, the Firebase configs, and the Android
signing files are gitignored.

- **Maintainers:** they live sops/age-encrypted in the private
  `audiflow/audiflow-secrets` repo, cloned next to this checkout. Place your
  age key at `~/.config/mise/age.txt`, then run `mise run secrets:pull`.
  After editing a plaintext file, run `mise run secrets:encrypt -- <path>` and
  commit in `audiflow-secrets`. In a new worktree, run `mise run secrets:decrypt`.
- **Contributors:** create the `.env.*` files at the repo root and place your own
  Firebase configs next to the committed `*.example` templates.

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
mise run test             # Run all tests
mise run analyze          # Static analysis (zero issues required)
mise run codegen          # Code generation (after adding annotations)
mise run check            # Run analyze + test
mise run format           # Format code
```

### Build Flavors

```bash
mise run run-dev            # Run dev flavor
mise run run-stg            # Run staging flavor
mise run run-prod           # Run production flavor
mise run build-android-dev  # Build dev AAB
mise run build-ios-dev      # Build dev IPA
```

Staging and production builds/deploys run through CI.

See `mise tasks` for the full list of tasks.

## Architecture

- **State management**: Riverpod with code generation
- **Local storage**: Isar (offline-first)
- **Networking**: Dio with caching interceptors
- **Audio**: just_audio + audio_service
- **Navigation**: go_router with type-safe routes
- **Patterns**: Repository pattern, feature-based module organization

See [`docs/fr/`](docs/fr/) for per-feature Functional Requirements and [`docs/architecture/`](docs/architecture/) for system design documentation.

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md)
before submitting a pull request. All contributors must sign the
[Contributor License Agreement](CLA.md).

## License

This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).
