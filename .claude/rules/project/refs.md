---
description: "Doc cross-reference graph: judgment calls the post-edit hook cannot make. Trigger-specific excerpts are auto-injected by .claude/hooks/refs-postedit.sh."
paths: "**/*.md"
---

# Cross-reference rule

The post-edit hook (`.claude/hooks/refs-postedit.sh`) auto-runs `kusara validate` after every `.md` edit and `kusara touched <file>` after every source edit under `packages/*/lib|test`. When an edit matches a trigger below, the hook injects the matching excerpt of this rule into context.

For the schema and CLI behavior of `kusara`, invoke the `kusara:refs-schema` and `kusara:kinds-manifest` skills.

**This rule covers only what the hook cannot decide.** Do not re-run `validate` or `touched` manually unless investigating a specific failure.

## Trigger: creating a new `.md`

Pick kind by matching the file path against `docs/kinds.md` `path_globs`:

| Situation | Action |
|---|---|
| Path matches an existing kind's `path_globs` | Add `refs:` of that kind. Mirror the closest sibling's frontmatter. |
| New instance of an existing kind, new location | Extend that kind's `path_globs` in `docs/kinds.md`, then add `refs:`. |
| New category of doc | Add a new kind entry to `docs/kinds.md`, then add `refs:`. |
| Deliberately outside graph (README / template / generated) | No `refs:`. Tighten the kind's glob if validate complains. |

## Trigger: source change under any `modules:` path

The hook prints docs of record. Decide per change type:

| Change type | Doc update? |
|---|---|
| Internal: refactor, bugfix, perf, dependency bump | none |
| New / changed user-facing behavior | relevant `fr:NN-*` |
| New / changed system design (state flow, module boundary, pipeline) | relevant `arch:*` |
| New / changed preset config consumption contract | `integration:preset` |
| New / changed package public surface | relevant `pkg:*` |

If unsure whether a change is "public surface", err on updating the doc.

## Trigger: editing the body of a graph-linked `.md`

The hook surfaces the doc's `implements` / `depends_on` / `related` / `modules` plus reverse impact via `kusara show`. Treat the list as a content-drift checklist: if the edit changed observable behavior (not a typo), skim the linked docs and update any whose body would otherwise drift. Skip the sweep for typo / formatting / pure clarification.

## Trigger: rename / delete of a doc

Every reference to the old ID becomes dangling. Update the references; the hook surfaces leftovers on the next edit.

## Trigger: editing `docs/kinds.md`

| Edit type | Risk |
|---|---|
| Tightening a `path_globs` | safe |
| Loosening or adding globs | every newly-matched file must have `refs:` |
| Renaming a kind | invalidates every `kind: <old-name>`; audit + rewrite |
| Adding `index.output` | run `kusara index` once to materialize the file |

## What the hook handles (do NOT re-run unless debugging)

- `kusara validate` after every `.md` edit
- `kusara touched <file>` after every source / `kinds.md` edit
- All graph-integrity errors (dangling refs, dup IDs, unknown kinds, missing frontmatter)
