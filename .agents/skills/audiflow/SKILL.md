```markdown
# audiflow Development Patterns

> Auto-generated skill from repository analysis

## Overview

This skill teaches you how to develop and maintain the `audiflow` codebase, a TypeScript project (no framework detected) with a strong schema-driven architecture. The repository emphasizes clear, conventional commits, modular code organization, and robust workflows for evolving schema, models, and documentation. You'll learn the coding conventions, how to propagate schema changes, update tests and docs, and use common CLI commands to streamline your workflow.

---

## Coding Conventions

### File Naming

- **Snake case** is used for file names.
  - Example: `playlist_definition.ts`, `feed_models.ts`

### Imports

- **Relative imports** are standard.
  - Example:
    ```typescript
    import { FeedModel } from './feed_models';
    ```

### Exports

- **Named exports** are preferred.
  - Example:
    ```typescript
    export const FEED_SCHEMA = { ... };
    export function parseFeed() { ... }
    ```

### Commit Messages

- **Conventional commit** style with prefixes:
  - `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
- Example:
  ```
  feat: add Matcher type to playlist schema
  refactor: rename episodeExtractor to numberingExtractor in models
  ```

---

## Workflows

### Schema Migration Workflow

**Trigger:** When a new SmartPlaylist schema version is released and the codebase must be updated to conform.  
**Command:** `/migrate-schema`

1. Add a migration plan document in `docs/superpowers/plans/`.
2. Vendor new schema JSON files in `packages/audiflow_domain/test/fixtures/`.
3. Update domain model classes in `packages/audiflow_domain/lib/src/features/feed/models/` to match the new schema.
4. Update resolver and service classes in `packages/audiflow_domain/lib/src/features/feed/resolvers/` and `services/`.
5. Update providers in `packages/audiflow_domain/lib/src/features/feed/providers/`.
6. Update barrel exports in `packages/audiflow_domain/lib/audiflow_domain.dart` and `patterns.dart`.
7. Update app layer references in `packages/audiflow_app/lib/features/podcast_detail/presentation/`.
8. Update CLI commands in `packages/audiflow_cli/lib/src/commands/`.
9. Update test fixtures and files in `packages/audiflow_domain/test/features/feed/`.
10. Update documentation and integration guides.
11. Update config URLs and references in `packages/audiflow_core/lib/src/config/` and app entrypoints.

**Example:**
```typescript
// Update model to match new schema field
export interface Playlist {
  id: string;
  title: string;
  matcher: Matcher; // new field from schema v5
}
```

---

### Add or Update Schema-Driven Feature

**Trigger:** When introducing a new config-driven feature or field (such as Matcher) or making a significant update to an existing config field.  
**Command:** `/add-schema-feature`

1. Add or update schema JSON in `packages/audiflow_domain/test/fixtures/`.
2. Add or update model class in `packages/audiflow_domain/lib/src/features/feed/models/`.
3. Update related resolver/service classes to use the new field/type.
4. Update barrel exports in `packages/audiflow_domain/lib/audiflow_domain.dart` and `patterns.dart`.
5. Update or add tests in `packages/audiflow_domain/test/features/feed/`.
6. Update documentation/comments as needed.

**Example:**
```typescript
// Add new Matcher type
export interface Matcher {
  type: string;
  pattern: string;
}
```

---

### Refactor Schema Field or Class

**Trigger:** When a schema field or class is renamed or its structure changes, requiring codebase-wide updates for consistency.  
**Command:** `/rename-schema-field`

1. Rename field/class in model(s) in `packages/audiflow_domain/lib/src/features/feed/models/`.
2. Update all usages in resolvers, services, and providers.
3. Update barrel exports in `packages/audiflow_domain/lib/audiflow_domain.dart` and `patterns.dart`.
4. Update references in the app layer (`packages/audiflow_app/lib/features/podcast_detail/presentation/`).
5. Update CLI commands if affected.
6. Update or rename relevant test files and fixtures.
7. Update documentation and migration notes if needed.

**Example:**
```typescript
// Before
export interface Playlist {
  episodeExtractor: string;
}

// After
export interface Playlist {
  numberingExtractor: string;
}
```

---

### Update All Tests for Schema Change

**Trigger:** When a schema migration or major config/model change occurs, requiring test updates for conformance and correctness.  
**Command:** `/update-schema-tests`

1. Update or rename test files in `packages/audiflow_domain/test/features/feed/` to match new model/resolver names and fields.
2. Update test fixtures and expected values for new schema fields.
3. Update schema conformance tests.
4. Regenerate mocks if needed.

**Example:**
```typescript
// Update test to expect new field
test('parses playlist with matcher', () => {
  expect(playlist.matcher).toBeDefined();
});
```

---

### Update Documentation for Schema Change

**Trigger:** When a schema migration or config field change requires documentation updates.  
**Command:** `/update-schema-docs`

1. Update migration plan in `docs/superpowers/plans/`.
2. Update integration guide in `docs/integration/smartplaylist.md`.
3. Update architecture docs and references in `.claude/rules/project/architecture.md`.
4. Update config URLs and references in docs and code comments.

---

## Testing Patterns

- **Test files** use the `*.test.ts` pattern.
- Test framework is **unknown**, but standard TypeScript test conventions apply.
- Tests are updated alongside schema/model changes to ensure conformance.
- Fixtures are stored in `packages/audiflow_domain/test/fixtures/`.

**Example:**
```typescript
import { parseFeed } from '../feed_models';

test('parseFeed returns correct model', () => {
  const result = parseFeed(sampleFeed);
  expect(result.title).toBe('Sample');
});
```

---

## Commands

| Command              | Purpose                                                        |
|----------------------|----------------------------------------------------------------|
| /migrate-schema      | Migrate codebase to new SmartPlaylist schema version           |
| /add-schema-feature  | Add or update a schema-driven feature or config field          |
| /rename-schema-field | Refactor schema field or class across the codebase             |
| /update-schema-tests | Update all relevant tests and fixtures for schema changes      |
| /update-schema-docs  | Update documentation and guides for schema/config changes      |
```
