---
name: schema-migration-workflow
description: Workflow command scaffold for schema-migration-workflow in audiflow.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /schema-migration-workflow

Use this workflow when working on **schema-migration-workflow** in `audiflow`.

## Goal

Migrates the SmartPlaylist schema to a new major version (e.g., v4→v5), updating models, resolvers, providers, app references, tests, docs, and vendored schema files.

## Common Files

- `docs/superpowers/plans/*-schema-v*-migration.md`
- `packages/audiflow_domain/test/fixtures/playlist-definition.schema.json`
- `packages/audiflow_domain/lib/src/features/feed/models/*.dart`
- `packages/audiflow_domain/lib/src/features/feed/resolvers/*.dart`
- `packages/audiflow_domain/lib/src/features/feed/services/*.dart`
- `packages/audiflow_domain/lib/src/features/feed/providers/*.dart`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Add migration plan document in docs/superpowers/plans/
- Vendor new schema JSON files in packages/audiflow_domain/test/fixtures/
- Update domain model classes in packages/audiflow_domain/lib/src/features/feed/models/ to match new schema fields and structure
- Update resolver and service classes in packages/audiflow_domain/lib/src/features/feed/resolvers/ and services/
- Update providers in packages/audiflow_domain/lib/src/features/feed/providers/

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.