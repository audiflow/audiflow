# audiflow

Flutter podcast player app (iOS/Android). Monorepo with 8 packages managed by Melos + Flutter workspace.

## Ecosystem context

Part of the audiflow ecosystem. Consumes smart playlist config JSON from `audiflow-preset` (all environments via GitHub Pages). Config schema SSoT lives in `audiflow-preset-editor/crates/preset_core/assets/`. Model serialization (JSON keys, field structure) must stay aligned with `preset_core` models.

## Packages

| Package | Role |
|---------|------|
| `audiflow_app` | Main Flutter app: routing, screens, controllers |
| `audiflow_core` | Shared constants, extensions, utilities, error types, enums |
| `audiflow_domain` | Business logic, repositories, data sources, Isar collections |
| `audiflow_podcast` | RSS parsing with streaming support, transcript/chapter extraction |
| `audiflow_ui` | Reusable widgets, themes, styles |
| `audiflow_ai` | Placeholder — implementation removed along with voice commands; contains no code |
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
- Station management (custom multi-podcast playlists)
- Background feed refresh, dropped episode cleanup, and new episode notifications
- Per-scope play order preferences (group -> playlist -> podcast -> global cascade)

## Non-responsibilities

- Schema definition (owned by `audiflow-preset-editor`)
- Config authoring/editing (owned by editor)
- Production config data hosting (owned by `audiflow-preset`)
- Voice commands: NOT IMPLEMENTED. The feature was built and later removed (no voice source code remains; `audiflow_ai` is an empty shell). Never describe voice commands as a feature of this app; `docs/fr/10-voice-commands.md` is a historical spec only.

## Validation

```bash
melos run test         # Run all tests
flutter analyze        # Zero issues required
melos run codegen      # Code generation
```

## Key references

- `.claude/rules/project/` -- architecture, tech stack, branching, doc cross-reference rule (loaded automatically)
- `docs/fr/` -- per-feature Functional Requirements (what each feature does, why, how it behaves)
- `docs/overview.md` -- detailed purpose and concepts
- `docs/architecture/` -- system overview, module boundaries, state flow, playback pipeline
- `docs/integration/preset.md` -- preset (smart playlist) config consumption contract
- `docs/kinds.md` -- kusara doc-graph kinds manifest; `kusara validate` / `touched` run via post-edit hook

## When changing this repository

- Schema/model changes: coordinate with `audiflow-preset-editor` (preset_core)
- Run schema conformance tests: `flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart`
- Update vendored schema if upstream changed: copy from `audiflow-preset-editor/crates/preset_core/assets/` (SSoT). Never edit vendored copies directly.
