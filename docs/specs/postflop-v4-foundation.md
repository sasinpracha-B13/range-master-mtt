# Spec — Post-flop v4.0 Foundation

**Status**: planning package complete; pending human review/approval before commit.
**Epic**: `v4.0.0 — Post-flop GTO Foundation Architecture`.
**Owner**: Architecture Subagent (planning); Orchestrator (review/approval); DEV Integration Agent (future implementation).
**Underlying decision**: [`DEC-001 — Data-first auditable architecture`](../decisions/DEC-001-postflop-data-first-architecture.md).

---

## TL;DR

This spec is a **high-level index** for the v4.0.0 postflop planning package. The actual artifacts live in `postflop/`. This file does not duplicate them — it gives reviewers and future implementers a single entry point.

For full content, follow the links to the constituent files.

---

## Scope

### In scope (v4.0.0 — planning round only)

- New training domain (`postflop`, sibling to existing preflop)
- Two modules:
  - **Module 1 — Board Texture Trainer**: universal board reading (range adv, nut adv, dynamic vs static, sizing family). 20 scenarios in seed.
  - **Module 2 — Flop C-bet IP Trainer**: BTN open vs BB call, 100BB SRP, flop only. 11 scenarios in seed.
- Strict scenario schema (versioned)
- Concept taxonomy (24 concepts with definitions + cross-references)
- Board / suit / dynamic / advantage / sizing taxonomy
- 31 hand-authored seed scenarios — all passing audit
- 17-rule audit gate (browser + Node CLI)
- Multi-tier scoring (`best=1.0 / acceptable in {0.25, 0.5, 0.75} / bad=0 / critical=0+flag`)
- Multi-section explanations (`short / rangeLogic / nutLogic / handLogic / sizingLogic / commonMistake`)
- Risk register (13 risks, severity-rated)
- Integration map (how postflop will plug into existing app code paths)

### Explicitly NOT in v4.0.0

- ❌ Full drill engine integration in `index.html`
- ❌ Module 3 (BB Defense vs C-bet) — planned for v4.1
- ❌ Turn / river modules — v4.2+
- ❌ Other position trees (CO vs BB, BTN vs SB, 3-bet pots) — v4.3+
- ❌ Multi-way post-flop
- ❌ ICM-aware adjustments
- ❌ Solver embedding / live computation
- ❌ Cosmetic rewards / FX / Aura / Collection extensions for postflop
- ❌ Service worker version bump

See [`postflop/ARCHITECTURE.md`](../../postflop/ARCHITECTURE.md) § 2 for the full out-of-scope list.

---

## Constituent files

All planning artifacts live in `postflop/`. Reviewers should walk these in roughly this order:

| # | File | What it is | Read for |
|---|---|---|---|
| 1 | [`postflop/ARCHITECTURE.md`](../../postflop/ARCHITECTURE.md) | Full architecture proposal | Get the big picture and integration plan |
| 2 | [`postflop/postflop_schema.md`](../../postflop/postflop_schema.md) | Strict schema spec + scoring + UI plan | Understand the data contract |
| 3 | [`postflop/postflop_taxonomy.json`](../../postflop/postflop_taxonomy.json) | Board/suit/dynamic/advantage/sizing enums | See the structured vocabulary |
| 4 | [`postflop/postflop_concepts.json`](../../postflop/postflop_concepts.json) | 24 concepts with definitions | Audit GTO concept coverage |
| 5 | [`postflop/postflop_scenarios.json`](../../postflop/postflop_scenarios.json) | 31 seed scenarios | Spot-check 3–5 for GTO correctness |
| 6 | [`postflop/postflop_audit_rules.js`](../../postflop/postflop_audit_rules.js) | 17 audit rules | Verify the gate is sound |
| 7 | [`postflop/postflop_audit.html`](../../postflop/postflop_audit.html) | Browser audit viewer | Run the audit live |
| 8 | [`postflop/audit-report-sample.md`](../../postflop/audit-report-sample.md) | Example audit output | See what audit results look like |
| 9 | [`postflop/RISKS.md`](../../postflop/RISKS.md) | 13 risks rated by severity | Decide whether mitigations are sufficient |

---

## Acceptance criteria for v4.0.0 sign-off

The planning package is approved when **all** of the following hold:

1. Architecture is endorsed (or change requests are filed in `TASK_BOARD.md`).
2. At least 3 sample scenarios spot-checked by a human reviewer; no critical disagreements with stated `best` answer.
3. Schema judged extensible enough for v4.1 (BB Defense) and v4.2 (turn) without breaking changes.
4. Audit gate runs cleanly on the seed (current state: 0 errors, 0 warnings on 31 scenarios) — re-verified after any data edits during review.
5. Risks reviewed; high-severity risks have agreed mitigations.
6. Open questions in [`PROJECT_STATE.md` § 8](../../PROJECT_STATE.md) resolved (or explicitly deferred with a note).

When approved, Orchestrator commits the v4.0.0 planning package + workflow files in **one** commit, then opens the v4.0.1 implementation brief.

---

## What v4.0.1 will look like (preview, not yet authorized)

When v4.0.0 is approved, the next implementation step (v4.0.1) is narrow:

- Load `postflop/postflop_*.json` into the app via fetch (cached by service worker).
- Verify schema version on load; refuse to render if mismatch.
- Filter scenarios by `auditStatus = "approved"`.
- Add domain field to `App.state.drill` (defaults to `'preflop'`).
- Add `domain: 'postflop'` toggle in Settings → Beta Features (off by default).
- **No UI yet** — render a placeholder when postflop module is selected.

This is one DEV Integration Agent task with explicit `index.html` + `service-worker.js` scope. It produces a separate brief in `docs/specs/brief-v4.0.1-schema-loader.md` (to be authored after v4.0.0 approval).

Module 1 / Module 2 actual UI lands in v4.0.2 / v4.0.3.

---

## Open questions (must resolve before approval)

These are tracked in [`PROJECT_STATE.md` § 8](../../PROJECT_STATE.md):

1. Acceptable-score granularity locked to `{0.25, 0.5, 0.75}` — confirm or relax?
2. Critical-flag UI: flag-only vs block progression?
3. ICM in v4.0: confirm out-of-scope?
4. Hand-class enum location: separate file or inside `postflop_concepts.json`?
5. `mixing` block format: `{ choiceId: freq }` only, or `{ choiceId: { freq, ev } }`?

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | Orchestrator | Initial spec index publication alongside v4.0.0 planning package |
