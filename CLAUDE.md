# audiflow

Flutter podcast player app (iOS/Android). Monorepo with 8 packages managed by Melos + Flutter workspace.

## Ecosystem context

Part of the audiflow ecosystem. Consumes smart playlist config JSON from `audiflow-smartplaylist` (all environments via GitHub Pages). Config schema SSoT lives in `audiflow-smartplaylist-editor/crates/sp_core/assets/`. Model serialization (JSON keys, field structure) must stay aligned with `sp_core` models.

## Packages

| Package | Role |
|---------|------|
| `audiflow_app` | Main Flutter app: routing, screens, controllers |
| `audiflow_core` | Shared constants, extensions, utilities, error types, enums |
| `audiflow_domain` | Business logic, repositories, data sources, Isar collections |
| `audiflow_podcast` | RSS parsing with streaming support, transcript/chapter extraction |
| `audiflow_ui` | Reusable widgets, themes, styles |
| `audiflow_ai` | On-device AI capabilities (Flutter plugin, iOS/Android) |
| `audiflow_search` | Podcast search and discovery API client (Dio + Freezed) |
| `audiflow_cli` | CLI tools for debugging Audiflow features |

## Responsibilities

- Podcast discovery, subscription, and feed management
- Audio playback with background support and system controls
- Configurable audio interruption behavior (duck or pause-and-rewind)
- Episode download and queue management
- Smart playlist config consumption and local caching
- Podcast transcript and chapter display
- Sleep timer with fade-out (duration, episode count, end-of-episode, end-of-chapter modes)
- On-device voice commands
- Station management (custom multi-podcast playlists)
- Background feed refresh, dropped episode cleanup, and new episode notifications
- Per-scope play order preferences (group -> playlist -> podcast -> global cascade)

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
- Update vendored schema if upstream changed: copy from `audiflow-smartplaylist-editor/crates/sp_core/assets/` (SSoT). Never edit vendored copies directly.
