# Functional Requirements (FR)

`docs/fr/` collects the **Functional Requirements documents** for the audiflow app.

## Position in the documentation stack

The **per-feature narrative** layer: someone who wants to understand a feature reads exactly one file.

| Layer | Location | Axis |
|---|---|---|
| **FR (this directory)** | `docs/fr/<NN>-<feature>.md` | Per-feature narrative |
| **Architecture** | `docs/architecture/` | System design of record for code |
| **Integration** | `docs/integration/` | External contracts |

FR answers "what is this feature, why does it exist, how does it behave". It does not restate architecture internals or wire-format detail — those live in `docs/architecture/`.

## Layout

```
docs/fr/
├── README.md           (this file)
├── _template.md        (skeleton for one file)
├── index.md            (generated; regenerate with `kusara index`)
└── NN-<feature>.md ... (one file per feature, flat layout)
```

## What to write / what not to write

### Write
- **Purpose**: why the feature exists
- **User-visible Behavior**: how it behaves for the user
- **Capabilities**: main behaviors, prose bullets
- **Boundaries**: what it does NOT do
- **Traceability**: source docs and related FRs

### Do not write
- Internal type definitions, Riverpod provider wiring, Isar collection detail (→ `docs/architecture/`)
- Implementation task breakdowns (→ `docs/superpowers/plans/`)

## Update flow

- New feature → write `docs/fr/NN-<feature>.md`, add `refs:` frontmatter, run `kusara index`.
- Changed feature → update the matching FR's Capabilities / Boundaries; the post-edit hook surfaces linked docs.

## Language

FR is written in English (see `.claude/rules/project/communication.md`).
