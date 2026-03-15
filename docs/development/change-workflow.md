# Change Workflow

## Before making changes

- Read `docs/overview.md` for repository purpose and boundaries
- Read relevant architecture doc (`docs/architecture/`) for the area you are changing
- Check `docs/integration/smartplaylist.md` if touching feed or smart playlist code
- Check `.claude/rules/project/architecture.md` for the decision tree on where to add code
- Identify whether the change affects schema, cross-repo contracts, or module boundaries

## Branch creation

Never commit directly to `main`. Create a feature branch first:

```bash
git checkout -b <type>/<short-description>
```

Types: `feat/`, `fix/`, `refactor/`, `chore/`, `docs/`, `test/`

## During implementation

- Keep changes within documented module boundaries (see `docs/architecture/module-boundaries.md`)
- Use the "Decision Tree: Where to Add New Code" in `.claude/rules/project/architecture.md`
- Add or update tests for changed behavior
- Use `@riverpod` annotation for all new providers
- Isar collections for persisted data, `@freezed` for transient models
- Follow layer rules: `App -> UI -> Domain -> Core`

## Code generation

Run after adding/modifying annotated classes:

```bash
# Single package
cd packages/<package_name>
dart run build_runner build --delete-conflicting-outputs

# All packages
melos run codegen
```

## Validation checklist

Run before committing:

```bash
flutter analyze           # Zero errors/warnings
melos run test            # All tests pass
```

For smart playlist changes, also run:

```bash
flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart
```

## Required documentation updates

Update documentation when:
- A new package is added to the monorepo -> update `CLAUDE.md`, `docs/overview.md`, `docs/architecture/module-boundaries.md`
- Behavior changes in a feature -> update relevant `docs/specs/` file
- Smart playlist model or fetch logic changes -> update `docs/integration/smartplaylist.md`
- State management pattern changes -> update `docs/architecture/state-flow.md`
- Playback pipeline changes -> update `docs/architecture/playback-pipeline.md`
- Module dependency direction changes -> update `docs/architecture/module-boundaries.md`

## Cross-repo coordination

If changes touch smart playlist models or JSON serialization:
1. Verify alignment with `sp_core` models in `audiflow-smartplaylist-editor`
2. Update vendored schema if upstream changed
3. Run schema conformance tests
4. Coordinate with data repo maintainers if config format changes

## Commit format

Use conventional commits:

```
feat(feed): add category resolver for smart playlists
fix(player): handle audio focus loss during phone calls
refactor(domain): extract download queue into separate service
```

## When to update

Update this document when: validation commands change, new cross-repo coordination steps are needed, branching strategy changes.
