# Task Board — Range Master MTT

> Active workstream tracker. Updated by Orchestrator + subagents (each role updates their own rows).
> Last updated: 2026-05-04.

---

## Active Epic

**v4.0.2 — Post-flop Module 1: Board Texture Trainer UI** (parent epic v4.0.x — Postflop Foundation)

First visible postflop UI surface. Consumes `App.postflop` namespace shipped in v4.0.1. Delivers: module entry point + question card + board cards + answer choices + multi-tier scoring + multi-section feedback. Mobile-first (375px). Reuses existing drill chrome where possible.

---

## Current Status

🟡 **v4.0.6 staged.** Postflop repeat control via local session history. New `localStorage.rmtt_postflop_history` schema + history-aware queue builder reduces back-to-back overlap to theoretical minimum. `App.postflopHistorySummary()` console helper. "Saved locally on this device" honest copy. Audit clean. Awaiting commit/push approval.

| Metric | Value |
|---|---|
| v4.0.0 planning | ✅ committed (`7849741`) + pushed |
| v4.0.1 implementation | ✅ committed (`2593e5c`) + pushed |
| `App.postflop` runtime | ✅ live; 31/31 approved scenarios loaded; frozen API |
| Browser QA result | ✅ 9/9 PASS (live verified at `http://localhost:8765/index.html`) |
| v4.0.2 planning sprint | 🟡 in progress — Architecture / UX / Data review / QA / Consolidation |
| v4.0.2 production code | ❌ not started; planning only |

---

## Parallel Workstreams

| Workstream | Owner | Status | Notes |
|---|---|---|---|
| Architecture Package | Architecture Subagent | ✅ Done + committed | `postflop/ARCHITECTURE.md` (21.4 KB) — committed in `7849741` |
| GTO Data Package | GTO Data Subagent | ✅ Done + committed | scenarios + concepts + taxonomy clean — committed in `7849741` |
| Audit Package | Audit Subagent | ✅ Done + committed | rules + browser viewer + sample report — committed in `7849741` |
| UX / UI Plan | UX Subagent | 🟡 Partial | Plan in `postflop/postflop_schema.md` § "UI / UX plan"; deeper wireframe pass deferred to v4.0.4 |
| Orchestrator Workflow Files | Orchestrator | ✅ Done + committed | All in `7849741` |
| v4.0.0 Planning Commit + Push | Orchestrator | ✅ Done | `7849741` pushed to origin/main |
| v4.0.1 Brief | Orchestrator | ✅ Done + committed | `docs/specs/brief-v4.0.1-schema-loader.md` — staged with v4.0.1 |
| v4.0.1 Implementation | DEV Integration Agent | 🟡 Staged | per `brief-v4.0.1-schema-loader.md`, awaiting commit approval |
| v4.0.1 QA | QA Agent | 🟡 Partial | All non-browser items pass; live browser load + console verification still needed |
| v4.0.2 Brief (Module 1 UI) | Orchestrator | 🚫 Blocked | Wait for v4.0.1 commit approval |

---

## Blockers

1. **Human review of v4.0.1 staged diff** (`index.html` +71/-3, `service-worker.js` +5/-1) — confirm the diff matches the brief exactly.
2. **Live browser verification of loader** — open the app, check DevTools console for `[postflop] loaded 31/31 scenarios (schema 1.0.0)`, run `App.postflop.ready` etc. (QA items 2–7 in v4.0.1 brief).
3. **Approval to commit** the staged v4.0.1 changes with message `v4.0.1: add postflop schema loader and audit gate`.
4. **Resolution of 5 open questions** (carried in `PROJECT_STATE.md` § 8) — can be deferred until v4.0.2 if not blocking.

---

## Next Actions (in order)

1. ✅ Workflow files created.
2. ✅ v4.0.0 planning package committed (`7849741`) and pushed.
3. ✅ v4.0.1 brief written and approved.
4. ✅ v4.0.1 implementation: 4 edits in `index.html` + 2 edits in `service-worker.js`. Audit re-confirmed 31/0/0.
5. ✅ State files updated (PROJECT_STATE.md, TASK_BOARD.md).
6. ⏸️ Human reviews staged diff, then approves the v4.0.1 commit.
7. ⏸️ Orchestrator commits with message `v4.0.1: add postflop schema loader and audit gate`.
8. ⏸️ Push happens only on a separate explicit "push" instruction.
9. ⏸️ On v4.0.1 commit + push: prepare `docs/specs/brief-v4.0.2-module1-board-texture-trainer.md` (planning only — first actual UI work).

---

## Recently Completed

- 2026-05-04: v4.0.6 postflop repeat control + local history STAGED. Awaiting commit approval.
- 2026-05-04: v4.0.5-data committed (`87c741e`) + pushed (#14 sourceConfidence honesty downgrade).
- 2026-05-04: v4.0.5 GTO Validation Pass complete (report + patch plan committed alongside v4.0.5-data).
- 2026-05-04: v4.0.4 critical hotfix committed (`519df53`) + pushed; postflop answer interaction now works on desktop + mobile.
- 2026-05-04: v4.0.3 polish committed (`25fb45e`) + pushed.
- 2026-05-04: v4.0.2 deployed live to Netlify; tester real-play surfaced 4 UX issues feeding v4.0.3 + critical onclick bug feeding v4.0.4.
- 2026-05-04: v4.0.2 Module 1 UI committed (`5d21128`) + pushed to origin/main.
- 2026-05-04: v4.0.2-data seed fix committed (`473ce9a`) + pushed.
- 2026-05-04: v4.0.2 planning sprint committed (`377c844`) + pushed.
- 2026-05-04: v4.0.1 schema loader committed (`2593e5c`) + pushed; live browser QA 9/9 PASS.
- 2026-05-04: v4.0.0 planning package committed (`7849741`) + pushed to origin/main.
- 2026-05-04: Orchestrator workflow files created (PROJECT_STATE.md, AGENTS.md, TASK_BOARD.md, docs/, tools/audit-postflop.js).
- 2026-05-04: Postflop planning package (9 files, ~206 KB) — Audit Subagent verified 0/0.
- 2026-05-04 (prior): v3.8.2 shipped to Netlify (Viewport-Dominant Field FX).
- 2026-05-04 (prior): v3.8.1 (Anime Battle Field) shipped.
- 2026-05-04 (prior): v3.8.0 (Field FX pivot + lifecycle bug fix) shipped.

---

## Discovered Work (out-of-scope; not started)

Items found during v4.0.0 work that are **not** in scope for v4.0.0 but should be tracked:

- **(low priority)** Audit Subagent could run automatically on a pre-commit hook. Currently runs only when human opens the audit page or runs the Node script. → Tracked in `RISKS.md` R-07; deferred to v4.0.5.
- **(low priority)** GitHub Action to run audit on PRs touching `postflop/*.json`. → Tracked in `RISKS.md` R-07; deferred to v4.1.
- **(medium priority)** Concept coverage gaps: `nut_advantage_shift`, `ip_advantage`, `equity_realization` have 0 scenarios. → Tracked in `audit-report-sample.md` "v4.1 expansion targets".
- **(medium priority)** Q-high and J-high boards underrepresented (only 2 scenarios each). → Tracked in `RISKS.md` R-05; planned for v4.1 data expansion.

---

## Do Not Start Yet

These tasks are deliberately **blocked** until v4.0.0 planning is approved:

- ❌ Full postflop drill integration in `index.html`
- ❌ Postflop boss tests / missions / overall exams
- ❌ Postflop cosmetic rewards / Answer FX / Aura tie-ins
- ❌ Postflop Collection Book extensions
- ❌ Service worker version bump
- ❌ Module 3 (BB Defense vs C-bet) data — v4.1 territory
- ❌ Turn / river modules — v4.2+ territory
- ❌ ICM-aware adjustments — out of v4.0.0 scope
- ❌ Multi-way post-flop — out of v4.0.0 scope

Anyone (human or subagent) starting these tasks before approval should be redirected by Orchestrator.

---

## Update protocol

- Each subagent updates its own row when status changes (✅ done / 🟡 in progress / 🚫 blocked / ⏸️ paused).
- New blockers go under "Blockers" with clear ownership.
- Discovered work goes under "Discovered Work" — never silently fixed.
- Orchestrator does the bigger reorganizations (status sync after a session, archiving completed epics).
