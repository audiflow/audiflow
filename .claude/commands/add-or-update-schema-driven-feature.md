---
name: add-or-update-schema-driven-feature
description: Workflow command scaffold for add-or-update-schema-driven-feature in audiflow.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /add-or-update-schema-driven-feature

Use this workflow when working on **add-or-update-schema-driven-feature** in `audiflow`.

## Goal

Adds a new config/model feature (e.g., Matcher type) or updates a major config field, propagating changes through models, resolvers, barrels, tests, and docs.

## Common Files

- `packages/audiflow_domain/test/fixtures/playlist-definition.schema.json`
- `packages/audiflow_domain/lib/src/features/feed/models/*.dart`
- `packages/audiflow_domain/lib/src/features/feed/resolvers/*.dart`
- `packages/audiflow_domain/lib/src/features/feed/services/*.dart`
- `packages/audiflow_domain/lib/audiflow_domain.dart`
- `packages/audiflow_domain/lib/patterns.dart`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Add or update schema JSON in packages/audiflow_domain/test/fixtures/
- Add or update model class in packages/audiflow_domain/lib/src/features/feed/models/
- Update related resolver/service classes to use new field/type
- Update barrel exports in packages/audiflow_domain/lib/audiflow_domain.dart and patterns.dart
- Update or add tests in packages/audiflow_domain/test/features/feed/

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.