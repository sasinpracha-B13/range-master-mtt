# Project State — Range Master MTT

> **READ THIS FIRST** before doing any work in this repo.
> Subagents: this file is your single source of truth for project context, current scope, and what is/is not allowed.
> Last updated: 2026-05-04

---

## 1. Current Version

- **Latest deployed to Netlify**: `v4.0.2` (live at `https://range-master-mtt.netlify.app/`).
- **Pending push (STAGED)**: `v4.0.3` — postflop Module 1 first-session hotfix. 4 fixes from real-play feedback: loader callback re-render + 3-state card, per-question-type Choice Guide, pressed/disabled button state, repositioned to TOP of Home as Beta Lab section.
- **Service worker `VERSION`**: `'v4.0.3'` (staged).
- **App backup `appVersion`**: `'4.0.3'` (staged).

---

## 2. Current App Summary

The shipped app (`v3.8.2`) is a single-file PWA poker training tool focused on **MTT preflop** decisions. Capabilities:

- **Preflop drill engine** — quick / deep / weakness / challenge / overall_exam / marginal modes
- **Boss tests** + **Overall exams** + **Mission system** + **Challenges**
- **XP / Chips / Levels / Rank progression**
- **Wardrobe** cosmetic system (trainer character outfit)
- **Boss / Achievement / Rank / Source rewards** with reveal ceremonies
- **Collection Book** (long-term cosmetic progression with milestone rewards — v3.7.0)
- **Answer FX** + **Field FX** (per-pack themed atmosphere across drill flow — v3.8.0–v3.8.2)
- **Aura system** (cosmetic effect rendered around trainer character — v3.6.0)
- **SRS** (spaced repetition per hand) + **stats breakdown**
- **Settings** (FX intensity, reduced motion, exports/imports)

**Not yet built**:
- ❌ Post-flop training (in planning — see Active Epic).
- ❌ ICM-aware ranges.
- ❌ Multi-language UI.
- ❌ Cloud sync / accounts.

---

## 3. Current Active Epic

**v4.0.0 — Post-flop GTO Foundation Architecture**

A new training domain (sibling to preflop) for No Limit Hold'em MTT post-flop decisions. The first round is a **planning / data / audit package only** — no production integration in v4.0.0.

The epic is tracked in `TASK_BOARD.md`.

---

## 4. Current Execution Gate

**Round 1 (v4.0.0 planning) — what was authorized:**

1. Architecture proposal
2. Strict scenario schema
3. Board / suit / dynamic / advantage / sizing taxonomy
4. Concept taxonomy (with definitions + cross-refs)
5. 20–40 hand-authored sample scenarios
6. Audit script (17 rules) + browser audit viewer
7. Human-readable audit report
8. Risks & mitigations register

**Round 1 — what is NOT authorized:**

- ❌ Full drill engine integration in `index.html`
- ❌ Postflop boss/mission/challenge/reward integration
- ❌ Cosmetic rewards for postflop modules
- ❌ FX / Aura / Collection extensions for postflop
- ❌ Service worker version bump
- ❌ Modifying preflop ranges, scoring, SRS, or any existing reward logic

The gate stays closed until human review approves the planning package.

---

## 5. Latest Completed Work

### v4.0.3 Implementation — STAGED, awaiting commit approval

Real-play hotfix per human tester feedback. Fixes 4 issues:

| # | Issue | Fix |
|---|---|---|
| 1 | Loading feels slow | Loader (`loadPostflopData`) now re-renders Home if user is on it AND beta is on (success and error paths). Card has 3 states: loading (spinner) / ready / error (with reload button). |
| 2 | Choice meanings unclear | New `_pfChoiceGuide(qType)` helper renders an expandable "What are we choosing?" panel above choice buttons. 5 question types × per-type explanations. |
| 3 | Buttons feel unresponsive | `handlePostflopChoice` now disables all buttons synchronously + adds `postflop-choice-pressed` class to tapped button BEFORE classify/render. Uses `requestAnimationFrame` so the pressed visual paints before the heavy innerHTML swap. New phase `'answering'` blocks rapid re-entry. |
| 4 | Home placement too low | `renderPostflopHomeCardMount` now uses `insertAdjacentHTML('afterbegin', ...)` to prepend at TOP of Home; wraps card in `.postflop-betalab-section` with "🧪 BETA LAB" header for clear beta status. |

**Files modified**: `index.html` (~250 lines added/modified across 6 surgical edits + 1 CSS block), `service-worker.js` (VERSION bump).

**Audit re-confirmed**: 31 scenarios · 0 errors · 0 warnings (no data files touched).

### v4.0.2 Postflop Module 1 (Board Texture Trainer) UI — committed (`5d21128`) + pushed

First visible postflop UI. Beta-gated via `App.state.settings.postflopBeta` (default `false`). Implementation per `docs/specs/brief-v4.0.2-implementation-ready.md`.

**Changes**:
- `index.html` (~960 lines added in single fenced v4.0.2 block + 2 one-liner appends to renderMastery/renderSettings + `appVersion` bump):
  - New `#postflopScreen` container (sibling to `#drillScreen` inside tab-drill panel)
  - CSS block for all `.postflop-*` classes (~290 lines)
  - JS block: `getPostflopReady`, `getModule1Scenarios`, `getConceptByKey`, `App.state.postflopDrill` state, `buildPostflopQueue`, `startPostflopDrill`, `classifyPostflopAnswer` (multi-tier), `recordPostflopAnswer`, `handlePostflopChoice`, `advancePostflopDrill`, `showPostflopScreen`, `exitPostflopScreen`, `confirmExitPostflop`, `renderPostflopHomeCardMount`, `renderPostflopBetaToggleMount`, `togglePostflopBeta`, `renderPostflopQuestion`, `renderPostflopAnswer`, `renderPostflopComplete`
  - Field FX suppression: `body[data-postflop-active="true"] .field-fx-canvas { display: none !important; }`
  - Wiring: 1-line defensive append in `renderMastery` wrapper (line 29279) + 1-line defensive append in `renderSettings` (line 31484)
- `service-worker.js`: VERSION `'v4.0.1'` → `'v4.0.2'`

**Live browser QA result** (29-item subset of 52-item matrix):
- ✅ Loader: ready=true, scenarios=31, schema=1.0.0, getModule1Count=20, all functions exist
- ✅ Beta default off: no postflop UI when off
- ✅ Toggle on: home card appears + Settings shows beta section
- ✅ Drill flow: question→feedback→advance→summary all render
- ✅ All 4 scoring tiers verified (best=1.0/best, acceptable=0.5/acceptable, critical=0/critical+flag, bad path also exercised)
- ✅ Multi-section feedback renders all 4 expandable sections + short explanation + concept tag pills
- ✅ Summary screen: score banner + per-tier counts + 17-row concept mastery + critical leaks list
- ✅ Preflop drill regression: 5 hands played, all classified correctly, progress key created, App.postflop untouched
- ✅ All 5 tabs render after postflop session
- ✅ Settings panel: existing FX/Aura/etc. controls intact + beta toggle appended
- ✅ Console clean: only the expected `[postflop] loaded 31/31 scenarios (schema 1.0.0)` from v4.0.1 loader; zero new errors/warnings
- ✅ Field FX suppression rule present in CSS (verified via stylesheet inspection)

**Implementation note**: One bug surfaced and was fixed in-flight — `#postflopScreen` lives inside `tab-drill` panel which gets hidden when other tabs become active. Fix: `showPostflopScreen()` now activates `tab-drill` panel + hides all OTHER drill sub-screens; `exitPostflopScreen()` returns to Home tab cleanly.

### v4.0.2-data Postflop Seed Fix — committed (`473ce9a`) + pushed

Pre-implementation data hygiene pass per `postflop-v4.0.2-scenario-review.md` findings + `brief-v4.0.2-implementation-ready.md` § 16. Three fix categories applied to `postflop/postflop_scenarios.json` only:

1. **Scenario #20** (`pf_btn_v_bb_srp_100bb_flop_7d7s3c_rangeadv_001`) — replaced the leftover authoring artifact `"Trips-7 even (both have 77 — wait, 77 impossible; ..."` in `nutLogic` with a clean GTO-facing explanation covering trips-7 distribution, impossible 77, full-house combinatorics, and overpair density.
2. **Choice label hint stripping** — removed all 14 rationale parentheticals from Module 1 answer-choice labels (e.g., `"Preflop raiser (BTN) — overpairs dominate"` → `"Preflop raiser (BTN)"`). Choices now have neutral labels; reasoning belongs in `explanation` fields.
3. **#10 `sourceConfidence` downgrade** — `Qh9d6s_freq_001` changed from `consensus_gto` → `expert_judgment` (the answer depends on solver-mix interpretation; confidence overclaim risk per scenario review B1/E3). #11 (`Th8h3h_nutadv_001`) was already `expert_judgment` — no change needed.

**Audit result**: 31 scenarios · 0 errors · 0 warnings. All 16 fixes applied; verified spot-checks confirm targets corrected.

**Files modified**: `postflop/postflop_scenarios.json` only. No other surface touched.

### v4.0.2 Planning Sprint — committed (`377c844`) + pushed

### v4.0.1 Postflop Schema Loader + Audit Gate — committed (`2593e5c`) + pushed

| Change | File | Diff |
|---|---|---|
| Loader block (POSTFLOP_SCHEMA_VERSION + App.postflop init + loadPostflopData + boot setTimeout) | `index.html` | +63 lines (one fenced v4.0.1 block) |
| `postflopBeta: false` in settings defaults (App.state) + confirmReset | `index.html` | +4 lines / -2 modified |
| `appVersion: '3.8.2'` → `'4.0.1'` | `index.html` | 1 string |
| `VERSION` bump + 3 postflop paths in STATIC_ASSETS | `service-worker.js` | +5 lines / -1 modified |

**Total**: 2 files modified; 71 insertions / 3 deletions in `index.html`; 6 insertions / 2 deletions in `service-worker.js`. All within the v4.0.1 brief scope.

**QA result**: audit re-confirmed clean (31/0/0); loader logic simulated successfully (`[postflop] loaded 31/31 scenarios (schema 1.0.0)`); production data files unchanged; postflop_audit_rules.js unchanged; preflop code paths untouched.

**Not yet done**: actual browser load + console verification of `App.postflop.ready === true` (requires a human or QA Agent with browser access).

### v4.0.0 Postflop Planning Package — committed (`7849741`) + pushed

| File | Purpose | Status |
|---|---|---|
| `postflop/ARCHITECTURE.md` | Full architecture proposal + module plan + integration map | ✅ Done |
| `postflop/postflop_schema.md` | Strict schema spec + scoring + UI plan | ✅ Done |
| `postflop/postflop_taxonomy.json` | Board / suit / dynamic / advantage / sizing enums | ✅ Done |
| `postflop/postflop_concepts.json` | 24 concepts with short + long defs + cross-refs | ✅ Done |
| `postflop/postflop_scenarios.json` | 31 audited seed scenarios (20 Module 1 + 11 Module 2) | ✅ Done |
| `postflop/postflop_audit_rules.js` | 17 audit rules as pure JS functions | ✅ Done |
| `postflop/postflop_audit.html` | Self-contained browser audit viewer | ✅ Done |
| `postflop/audit-report-sample.md` | Example audit output | ✅ Done |
| `postflop/RISKS.md` | 13 risks rated by severity + mitigations | ✅ Done |

**Audit result on the seed dataset**: `31 scenarios · 0 errors · 0 warnings · 31 approved` (after fixing 2 misuses of textureTags as conceptTags during the run).

### Recent shipped versions (latest 5)

- `v3.8.2` — Viewport-Dominant Field FX (canvas with 5 animated layers)
- `v3.8.1` — Anime Battle Field FX (intensity surge + page shake)
- `v3.8.0` — Field FX pivot + lifecycle bug fix
- `v3.7.4` — Aura Identity + Premium Hierarchy + 3 new auras
- `v3.7.3` — Anime FX + Premium Hierarchy

---

## 6. Hard Guardrails

The following surfaces require explicit per-task approval to modify. **Subagents cannot touch them on their own initiative.**

| Surface | File / Concept | Why locked |
|---|---|---|
| Preflop ranges | `ranges.json` | Source of truth for the entire preflop trainer; any change cascades through SRS and stats |
| Scoring formula | `classifyAnswer()` in `index.html` (line ~11219) | Touches every drill answer; regression risk to thousands of stored SRS entries |
| SRS state | `getSRSKey()` + `updateSRS()` in `index.html` (line ~12584) | Player-progress data; backward compat critical |
| Cooldowns | Boss-fail cooldowns in `index.html` (line ~28405) | Anti-grind rule that gates progression |
| Rank progression | Rank/Level XP curves | Player progression curve already tuned |
| Chips formula | Chip grant logic in `index.html` (~line 12267 area) | Economy balance |
| Existing reward grant | `_grantCosmeticByKey()` and surrounding hooks | Cosmetic ownership integrity |
| Cosmetic ownership | `App.state.profile.owned*` arrays | Player inventory; corruption is irreversible |
| Production UI shell | `index.html`, `service-worker.js` | Single-file PWA; one bad edit breaks the live deploy |
| Manifest / PWA | `manifest.json`, icon files | PWA install behavior |

**Rule**: any task touching the above must explicitly cite the surface in its scope and pass through Orchestrator before a subagent edits it.

---

## 7. File Ownership Rules

- Every subagent has an explicit **allowed file pattern** (declared in `AGENTS.md`).
- A subagent that needs to edit a file outside its pattern must **stop and request Orchestrator escalation**.
- **No subagent except DEV Integration Agent may edit `index.html` or `service-worker.js`**, and only when Orchestrator has assigned a controlled implementation task with explicit scope.
- Multiple subagents may edit different files in parallel as long as their patterns don't overlap.
- Orchestrator is the only role that may edit `PROJECT_STATE.md`, `AGENTS.md`, `TASK_BOARD.md`.

---

## 8. Open Questions (carried forward, awaiting human input)

Tagged from `postflop/postflop_schema.md` "Open questions for review":

1. **Acceptable-score granularity** — locked to `{0.25, 0.5, 0.75}`, or allow any value in `[0, 1]`?
2. **Critical-flag UI** — flag-only in stats, or block progression / force review?
3. **ICM in v4.0** — confirm out-of-scope (chipEV-only foundation)?
4. **Hand-class enum location** — separate file, or stays inside `postflop_concepts.json`?
5. **`mixing` block format** — is `{ choiceId: freq }` enough, or richer `{ freq, ev }` per choice?

Plus, before commit:

6. **Spot-check of 3–5 sample scenarios** by a human reviewer.
7. **Approval to commit** the v4.0.0 planning package.

---

## 9. Next Recommended Step

1. ✅ Workflow files created (DEC-001, etc.).
2. ✅ v4.0.0 planning package reviewed + approved + committed (`7849741`) + pushed.
3. ✅ v4.0.1 implementation (schema loader + audit gate) staged per brief.
4. ⏸️ **Human review of staged v4.0.1 diff**, then approve the commit.
5. ⏸️ On approval: stage commit message `v4.0.1: add postflop schema loader and audit gate`; commit; await separate "push" instruction.
6. ⏸️ Resolve the 5 open questions above (or defer with explicit notes).
7. ⏸️ After v4.0.1 commit: prepare `docs/specs/brief-v4.0.2-module1-board-texture-trainer.md` (planning only — actual UI work).

---

**Maintained by**: Orchestrator Agent. Update on every state change. Do not delete entries — annotate with status.
