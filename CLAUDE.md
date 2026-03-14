# audiflow

Flutter podcast player app (iOS/Android). Monorepo with 8 packages managed by Melos + Flutter workspace.

## Ecosystem context

Part of the audiflow ecosystem. Consumes smart playlist config JSON from sibling data repos (`audiflow-smartplaylist` for prod, `audiflow-smartplaylist-dev` for dev/staging). Config schema SSoT lives in `audiflow-smartplaylist-editor/crates/sp_core/assets/`. Model serialization (JSON keys, field structure) must stay aligned with `sp_core` models.

## Packages

| Package | Role |
|---------|------|
| `audiflow_app` | Main Flutter app: routing, screens, controllers |
| `audiflow_core` | Shared constants, extensions, utilities, error types |
| `audiflow_domain` | Business logic, repositories, data sources, Drift models |
| `audiflow_podcast` | RSS parsing with streaming support and caching |
| `audiflow_ui` | Reusable widgets, themes, styles |
| `audiflow_ai` | On-device AI capabilities (Flutter plugin, iOS/Android) |
| `audiflow_search` | Podcast search and discovery API client (Dio + Freezed) |
| `audiflow_cli` | CLI tools for debugging Audiflow features |

## Responsibilities

- Podcast discovery, subscription, and feed management
- Audio playback with background support and system controls
- Episode download and queue management
- Smart playlist config consumption and local caching

## Non-responsibilities

- Schema definition (owned by `audiflow-smartplaylist-editor`)
- Config authoring/editing (owned by editor)
- Production config data hosting (owned by `audiflow-smartplaylist`)

## Validation

```bash
melos run test         # Run all tests
flutter analyze        # Zero issues required
melos run codegen      # Code generation
```

## Key references

- `.claude/rules/project/` -- architecture, tech stack, branching (loaded automatically)
- `docs/overview.md` -- detailed purpose and concepts
- `docs/architecture/` -- system overview, module boundaries, state flow, playback pipeline
- `docs/integration/smartplaylist.md` -- smart playlist config consumption contract

## When changing this repository

- Schema/model changes: coordinate with `audiflow-smartplaylist-editor` (sp_core)
- Run schema conformance tests: `flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart`
- Update vendored schema if upstream changed: copy from `sp_core/assets/*.schema.json`
