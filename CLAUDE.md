# AI-DLC and Spec-Driven Development

Kiro-style Spec Driven Development implementation on AI-DLC (AI Development Life Cycle)

## Project Context

### Paths
- Steering: `.kiro/steering/`
- Specs: `.kiro/specs/`

### Steering vs Specification

**Steering** (`.kiro/steering/`) - Guide AI with project-wide rules and context
**Specs** (`.kiro/specs/`) - Formalize development process for individual features

### Active Specifications
- Check `.kiro/specs/` for active specifications
- Use `/kiro:spec-status [feature-name]` to check progress

## Development Guidelines
- Think in English, generate responses in English. All Markdown content written to project files (e.g., requirements.md, design.md, tasks.md, research.md, validation reports) MUST be written in the target language configured for this specification (see spec.json.language).

## Minimal Workflow
- Phase 0 (optional): `/kiro:steering`, `/kiro:steering-custom`
- Phase 1 (Specification):
  - `/kiro:spec-init "description"`
  - `/kiro:spec-requirements {feature}`
  - `/kiro:validate-gap {feature}` (optional: for existing codebase)
  - `/kiro:spec-design {feature} [-y]`
  - `/kiro:validate-design {feature}` (optional: design review)
  - `/kiro:spec-tasks {feature} [-y]`
- Phase 2 (Implementation): `/kiro:spec-impl {feature} [tasks]`
  - `/kiro:validate-impl {feature}` (optional: after implementation)
- Progress check: `/kiro:spec-status {feature}` (use anytime)

## Development Rules
- 3-phase approval workflow: Requirements → Design → Tasks → Implementation
- Human review required each phase; use `-y` only for intentional fast-track
- Keep steering current and verify alignment with `/kiro:spec-status`
- Follow the user's instructions precisely, and within that scope act autonomously: gather the necessary context and complete the requested work end-to-end in this run, asking questions only when essential information is missing or the instructions are critically ambiguous.

## Steering Configuration
- Load entire `.kiro/steering/` as project memory
- Default files: `product.md`, `tech.md`, `structure.md`
- Custom files are supported (managed via `/kiro:steering-custom`)

## Smart Playlist Schema Conformance

`audiflow_domain` has hand-written smart playlist models (`fromJson()`/`toJson()`) that must stay aligned with the JSON Schema defined in the `audiflow-smartplaylist-web` repo (`sp_shared/assets/schema.json`).

### Vendored schema

A copy of the reference schema lives at `packages/audiflow_domain/test/fixtures/schema.json`. This is the single source of truth for conformance testing.

### Conformance tests

`packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart` validates:
- **Round-trip tests**: model `toJson()` output wrapped in a config envelope validates against the vendored schema
- **Enum conformance**: Dart enum `.name` values and string constants match the schema's `oneOf`/`enum` definitions

### Keeping the schema in sync

When `sp_shared/assets/schema.json` changes upstream:
1. Copy the updated file to `packages/audiflow_domain/test/fixtures/schema.json`
2. Run `flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart`
3. Fix any failures (update models, enums, or test data to match the new schema)
4. Run `flutter test packages/audiflow_domain` to ensure no regressions

### Test data rules

Always use schema-valid values in test data:
- Resolver types: `'rss'`, `'category'`, `'year'`, `'titleAppearanceOrder'` (not `'rssSeason'`, `'categoryGroup'`, `'flat'`)
- Content types: `'episodes'`, `'groups'`
- Sort fields: use `SmartPlaylistSortField` enum names (match schema)
- Sort orders: `'ascending'`, `'descending'`
