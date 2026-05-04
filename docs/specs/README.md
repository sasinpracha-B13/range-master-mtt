# Specs

Feature specs, implementation briefs, and planning index documents.

## Two kinds of files live here

### 1. Feature specs (long-lived)

A spec describes a feature or subsystem at the level a DEV Integration Agent could implement from. Specs typically:

- Describe the user-facing behavior precisely.
- List the files and code paths affected.
- Reference data files / taxonomies / decision records.
- Include acceptance criteria.

Specs persist; they get updated as the feature evolves.

### 2. Spec index documents (epic-level)

For a multi-file deliverable (like the v4.0.0 postflop planning package), a spec index document gives reviewers a single entry point that links out to all the constituent files. The index file does NOT duplicate content — it summarizes scope and points reviewers at the right place.

## File naming

- Feature specs: `<feature-area>-<descriptor>.md`. Examples: `ux-postflop-question-screen.md`, `audit-postflop-rules.md`, `postflop-v4-foundation.md`.
- QA reports: `qa-<task-id>-<short-desc>.md`. Example: `qa-v4.0.1-schema-loader.md`.
- Implementation briefs (one-shot): `brief-<task-id>-<descriptor>.md`. Example: `brief-v4.0.1-schema-loader.md`. Briefs are typically deleted (or moved to a completed/ subfolder) after the implementation lands.

## Index of current specs

| Spec | Status | Owner |
|---|---|---|
| [`postflop-v4-foundation.md`](postflop-v4-foundation.md) | active | Architecture Subagent |

When you add a new spec, append to this index.

## Conventions

- Use H2 (`##`) for top-level sections; H3 (`###`) for subsections.
- Include a "Status" line near the top: `proposed | in-progress | shipped | deprecated`.
- Always link to the relevant decision records in `../decisions/` if the spec implements an established decision.
- For long-lived specs, include a "Change log" at the bottom recording material updates.
- For one-shot implementation briefs, include explicit "Out of scope" and "Stop condition" sections so the implementing agent knows when to stop.

## What does NOT belong here

- General documentation about the app's existing features (those go elsewhere or stay inline as code comments).
- Tutorials / how-tos for end users.
- Marketing copy.
- Subagent-specific instructions (those belong in `AGENTS.md`).

## Relationship to other docs

```
PROJECT_STATE.md  ← overall project state and active epic
AGENTS.md         ← who edits what, universal rules
TASK_BOARD.md     ← active work tracking
docs/decisions/   ← why we made structural choices
docs/specs/       ← what we're building or have built
postflop/         ← actual data + audit + per-epic docs (specific to v4.0)
```

A spec in `docs/specs/` typically references one or more decision records in `docs/decisions/` and one or more data/code locations in the rest of the repo.
