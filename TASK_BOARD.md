# Task Board — Range Master MTT

> Active workstream tracker. Updated by Orchestrator + subagents (each role updates their own rows).
> Last updated: 2026-05-04.

---

## Active Epic

**v4.0.0 — Post-flop GTO Foundation Architecture**

Build a data-first, auditable Post-flop NLH MTT training domain. v4.0.0 ships planning + data + audit only — no production integration.

---

## Current Status

🟡 **Planning package produced. Audit clean. Pending human review/approval. Not committed yet.**

| Metric | Value |
|---|---|
| Scenarios authored | 31 (target was 20–40) |
| Audit errors | 0 |
| Audit warnings | 0 |
| Approved scenarios | 31 / 31 |
| Concept coverage | 23 / 24 (96%) |
| Files staged for commit | 9 in `postflop/` + 1 `.gitignore` change |
| Production files modified | 0 (gate respected) |

---

## Parallel Workstreams

| Workstream | Owner | Status | Notes |
|---|---|---|---|
| Architecture Package | Architecture Subagent | ✅ Done | `postflop/ARCHITECTURE.md` (21.4 KB) |
| GTO Data Package | GTO Data Subagent | ✅ Done | scenarios + concepts + taxonomy clean |
| Audit Package | Audit Subagent | ✅ Done | rules + browser viewer + sample report |
| UX / UI Plan | UX Subagent | 🟡 Partial | Plan included in `postflop/postflop_schema.md` § "UI / UX plan"; deeper wireframe pass deferred to v4.0.4 (post-implementation polish round) |
| Orchestrator Workflow Files | Orchestrator | 🟡 In progress | This commit — `PROJECT_STATE.md`, `AGENTS.md`, `TASK_BOARD.md`, `docs/`, `tools/audit-postflop.js` |
| Human Review | (human) | ⏸️ Pending | Architecture + 3–5 sample scenarios + RISKS.md |
| Commit v4.0.0 planning package | Orchestrator | 🚫 Blocked | Awaiting approval |
| v4.0.1 Implementation (schema loader + audit gate) | DEV Integration Agent | 🚫 Blocked | Awaiting approval of v4.0.0 planning |

---

## Blockers

1. **Human review of `postflop/ARCHITECTURE.md`** — does the architecture proposal match the project's direction?
2. **Human spot-check of 3–5 scenarios in `postflop/postflop_scenarios.json`** — do the GTO answers and explanations look right?
3. **Resolution of 5 open questions** (carried in `PROJECT_STATE.md` § 8):
   - Acceptable-score granularity locked to `{0.25, 0.5, 0.75}`?
   - Critical-flag UI: flag-only or block progression?
   - ICM out-of-scope confirmed?
   - Hand-class enum location?
   - `mixing` block format?
4. **Approval to commit** the staged v4.0.0 planning package + workflow files.

---

## Next Actions (in order)

1. ✅ Create workflow files (`PROJECT_STATE.md`, `AGENTS.md`, `TASK_BOARD.md`, `docs/`, `tools/audit-postflop.js`).
2. ✅ Update `.gitignore` to make `tools/*.js` and `postflop/*.js` trackable.
3. ✅ Re-run postflop audit; confirm still 0 errors / 0 warnings.
4. ⏸️ Report and stop. Wait for human approval.
5. ⏸️ On approval → Orchestrator commits the v4.0.0 planning package + workflow files in **one** commit.
6. ⏸️ On approval of v4.0.1 brief → DEV Integration Agent implements schema loader + audit gate (NOT Module 1/2 UI yet).

---

## Recently Completed

- 2026-05-04: Postflop planning package (9 files, ~206 KB) — Audit Subagent verified 0/0.
- 2026-05-04: Started Orchestrator workflow files.
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
