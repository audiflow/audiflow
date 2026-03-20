# audiflow_domain

Business logic and data layer for Audiflow. All repositories, services, data sources, and Isar collections. Isar models serve as both domain entities and database models (no separate DTOs).

## Ecosystem context

Sub-package of the `audiflow` Flutter monorepo. Depends on `audiflow_core`, `audiflow_podcast`, `audiflow_search`, `audiflow_ai`. Consumed by `audiflow_app`, `audiflow_ui`, `audiflow_cli`. Smart playlist models MUST stay aligned with `sp_core`/`sp_shared` in the editor repo.

## Responsibilities

- Repository interfaces and implementations for 9 feature modules
- Isar collection definitions and local/remote data sources
- Business services (feed sync, playback, download queue, voice commands, station reconciliation)
- Smart playlist config consumption, caching, and resolver pipeline
- Background refresh and new-episode notification orchestration

## Non-responsibilities

- UI, routing, theming (`audiflow_app`, `audiflow_ui`)
- RSS parsing (`audiflow_podcast`), search API (`audiflow_search`), AI inference (`audiflow_ai`)
- Schema definition (`audiflow-smartplaylist-editor`)

## Validation

```bash
cd packages/audiflow_domain && flutter test && flutter analyze
dart run build_runner build --delete-conflicting-outputs
```

## Key references

- `docs/overview.md` -- feature modules, patterns, public API surface, entry points
- `lib/audiflow_domain.dart` -- barrel file (primary public API)
- `lib/patterns.dart` -- pure-Dart exports for CLI (no Flutter deps)

## When changing this package

- New Isar collection: register in `database_provider.dart`, run codegen
- Smart playlist model changes: coordinate with `sp_core`/`sp_shared`, update vendored schema, run conformance tests
- New feature module: add exports to `audiflow_domain.dart`, mirror existing directory structure
