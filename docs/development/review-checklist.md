# Review Checklist

## Behavior

- Is the intended behavior clear from the code and tests?
- Is there test coverage for the changed behavior?
- Are edge cases handled (null, empty, error states)?
- Do async operations handle cancellation on disposal?

## Module boundaries

- Does the change respect package dependency rules? (`App -> UI -> Domain -> Core`)
- Has any responsibility shifted between packages?
- Are new files in the correct package per the decision tree in `.claude/rules/project/architecture.md`?
- Are reusable widgets in `audiflow_ui`, not duplicated in `audiflow_app`?

## State management

- Are new providers using `@riverpod` code generation?
- Are long-lived providers marked `@Riverpod(keepAlive: true)` only when necessary?
- Are side effects in `ref.listen()`, not in `build()`?
- Is cross-feature communication via event streams, not direct provider coupling?

## Data layer

- Are new Isar collections in `audiflow_domain/lib/src/features/<feature>/models/`?
- Are non-persisted models using `@freezed`?
- No separate DTO classes (Isar collection classes used directly)?
- Repository interfaces and implementations co-located?

## Smart playlist / cross-repo

- Do JSON keys match `sp_core` models in the editor repo?
- Do enum values match schema definitions?
- Were schema conformance tests run?
- Is vendored schema up to date?

## Code quality

- `flutter analyze` passes with zero issues?
- All tests pass (`melos run test`)?
- Code generation run after annotation changes (`melos run codegen`)?
- No `>` or `>=` operators (must use `<` or `<=` per number rules)?
- Functions under 20 lines?
- No `any` types or loose typing?

## Documentation

- Are relevant docs updated for behavior/architecture changes?
- If a new package was added: `CLAUDE.md`, `docs/overview.md`, `docs/architecture/module-boundaries.md` updated?
- If schema/contract changed: `docs/integration/smartplaylist.md` updated?

## When to update

Update when: new review criteria emerge, process changes, new quality gates added.
