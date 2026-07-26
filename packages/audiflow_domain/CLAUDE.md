---
refs:
  id: pkg:audiflow_domain
  kind: package
  title: "audiflow_domain"
  modules:
    - packages/audiflow_domain/
---
# audiflow_domain

Business logic and data layer for Audiflow. All repositories, services, data sources, and Isar collections. Isar models serve as both domain entities and database models (no separate DTOs).

## Ecosystem context

Sub-package of the `audiflow` Flutter monorepo. Depends on `audiflow_core`, `audiflow_podcast`, `audiflow_search`. Consumed by `audiflow_app`, `audiflow_ui`, `audiflow_cli`. Smart playlist models MUST stay aligned with `preset_core`/`preset_shared` in the editor repo.

## Responsibilities

- Repository interfaces and implementations for the feature modules under `lib/src/features/`
- Isar collection definitions and local/remote data sources
- Business services (feed sync, playback, download queue, station reconciliation)
- Smart playlist config consumption, caching, and resolver pipeline
- Background refresh and new-episode notification orchestration
- Parental control: PIN-gated Restricted Mode (`ParentalControlRepository`, `PinHasher`, `UnlockState`, Riverpod providers)

## Non-responsibilities

- UI, routing, theming (`audiflow_app`, `audiflow_ui`)
- RSS parsing (`audiflow_podcast`), search API (`audiflow_search`)
- Schema definition (`audiflow-preset-editor`)
- Voice commands: NOT IMPLEMENTED. The Gemma voice pipeline (`VoiceCommandOrchestrator`, `GemmaVoiceCommandRoute`, etc.) was removed from the codebase; `audiflow_ai` is no longer a dependency.

## Validation

```bash
cd packages/audiflow_domain && flutter test && flutter analyze
dart run build_runner build --delete-conflicting-outputs
```

## Key references

- `docs/overview.md` -- feature modules, patterns, public API surface, entry points
- `lib/audiflow_domain.dart` -- barrel file (primary public API)
- `lib/presets.dart` -- pure-Dart exports for CLI (no Flutter deps)

## When changing this package

- New Isar collection: register in `database_provider.dart`, run codegen
- Smart playlist model changes: coordinate with `preset_core`/`preset_shared`, update vendored schema, run conformance tests
- New feature module: add exports to `audiflow_domain.dart`, mirror existing directory structure
