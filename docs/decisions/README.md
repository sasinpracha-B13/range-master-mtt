# Decision Records

Architectural Decision Records (ADRs) live here. One file per decision.

## Why we keep decision records

Future-you (and future subagents) need to understand **why** the project is the way it is, not just **what** it currently does. A decision record captures the context, the alternatives considered, the choice made, and the consequences — so when someone later asks "why did we do X?", the answer is in the repo, not lost in chat history.

## File naming

Use one of two patterns (pick whichever the task feels more natural with):

- `DEC-NNN-short-title.md` — sequential numbering, e.g., `DEC-001-postflop-data-first-architecture.md`
- `DEC-YYYYMMDD-short-title.md` — date-prefixed, e.g., `DEC-20260504-postflop-data-first-architecture.md`

The current convention is **sequential numbering** (`DEC-NNN`). Use the next free number. Do not renumber existing entries when inserting; just take the next available.

## Required sections per record

Every decision record MUST include the following H2 sections in this order:

```markdown
## Status
(proposed | accepted | superseded | deprecated)
Date: YYYY-MM-DD

## Context
What's the problem? What's the situation? What constraints apply?

## Decision
What did we decide? Be specific and unambiguous.

## Alternatives considered
What other options did we evaluate? Why were they rejected?

## Consequences
What follows from this decision — both positive and negative? What does it commit us to?

## Related
Links to other decision records, specs, code locations, or external references.
```

Optional sections:

- `## Open questions` — things still unresolved that this decision depends on.
- `## Revisit triggers` — what would cause us to reopen this decision?

## When to write a decision record

Write one when the decision:

- Locks in an architecture or schema that's expensive to change later
- Makes a non-obvious trade-off
- Picks one of several reasonable options
- Affects file ownership or workflow patterns
- Establishes a convention multiple subagents need to follow

Do **not** write decision records for routine choices, code-level micro-decisions, or things obvious from the code itself.

## Status lifecycle

- `proposed` — the decision is drafted but not yet adopted; teammates can comment.
- `accepted` — the decision is in force; subsequent work follows it.
- `superseded` — a later decision replaces this one. Add a `Superseded by: DEC-NNN` line at the top, but DO NOT delete the file. History matters.
- `deprecated` — no longer in force, but no replacement; decision is simply abandoned. Same retention rule — don't delete.

## Index

Decision records, in order:

| ID | Title | Status |
|---|---|---|
| [DEC-001](DEC-001-postflop-data-first-architecture.md) | Post-flop will be a data-first auditable domain (not hardcoded UI quiz logic) | accepted |

When you add a new record, append to this index.
