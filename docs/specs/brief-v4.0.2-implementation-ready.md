# Brief — v4.0.2 IMPLEMENTATION-READY: Post-flop Module 1 (Board Texture Trainer)

> **This is the consolidated, single source of truth for v4.0.2 implementation.**
> Pulls together: Architecture brief + UX plan + Scenario review + QA plan into one actionable spec.
> **Status**: planning complete. Awaiting human approval before DEV Integration Agent begins.
> **Owner once approved**: DEV Integration Agent.
> **Source documents**:
> - `docs/specs/brief-v4.0.2-module1-board-texture-trainer.md` (Architecture)
> - `docs/specs/postflop-v4.0.2-ux-plan.md` (UX)
> - `docs/specs/postflop-v4.0.2-scenario-review.md` (Independent GTO/clarity review)
> - `docs/specs/postflop-v4.0.2-qa-plan.md` (52-item QA matrix)

---

## 1. Goal

Ship the **first visible postflop UI** as a beta-gated module on the existing Home tab, consuming the frozen `App.postflop` namespace from v4.0.1. Player flow:

1. Toggle "Post-flop beta" in Settings (default off).
2. New "🧪 POSTFLOP BETA · Board Texture Trainer" card appears on Home.
3. Tap Start → 15-question board-texture session.
4. Per-question feedback shows score tier + multi-section explanation.
5. Summary screen with per-tier counts + concept-mastery breakdown.

**No** drill engine changes. **No** preflop regression. **No** SRS/cosmetic/boss/mission integration.

---

## 2. Scope IN

| # | Item | File |
|---|---|---|
| 1 | Read-only data accessors (`getPostflopReady`, `getModule1Scenarios`, `getConceptByKey`, `getTaxonomyEnum`) | `index.html` (new fenced v4.0.2 block) |
| 2 | Session state: `App.state.postflopDrill = { active, module, queue, currentIndex, answers, startTime, phase }` | `index.html` |
| 3 | Builders: `buildPostflopQueue`, `startPostflopDrill`, `classifyPostflopAnswer`, `recordPostflopAnswer` | `index.html` |
| 4 | Renderers: `renderPostflopHomeCard`, `renderPostflopQuestion`, `renderPostflopAnswer`, `renderPostflopComplete` | `index.html` |
| 5 | Navigation: `showPostflopScreen`, `exitPostflopScreen`, `confirmExitPostflop` | `index.html` |
| 6 | Settings UI: `renderPostflopBetaToggle`, `togglePostflopBeta` | `index.html` |
| 7 | New container `<div id="postflopScreen" class="container" style="display:none"></div>` | `index.html` (sibling to `#drillScreen`) |
| 8 | CSS block (~80–120 lines) for `.postflop-*` classes | `index.html` style section |
| 9 | One-line append in `renderMastery()` to mount Home card | `index.html` |
| 10 | One-line append in `renderSettings()` to mount beta toggle | `index.html` |
| 11 | `App.state.settings.postflopBeta` already declared in v4.0.1 — no edit needed |  |
| 12 | `service-worker.js` VERSION bump 'v4.0.1' → 'v4.0.2' | `service-worker.js` |
| 13 | `appVersion: '4.0.1'` → `'4.0.2'` in backup builder | `index.html` (single string) |
| 14 | Update `PROJECT_STATE.md` + `TASK_BOARD.md` post-implementation | both files |

**Estimated diff**: `index.html` ≈ 350–500 lines (one fenced block + style + 2 one-liners + appVersion); `service-worker.js` ≈ 1 line.

---

## 3. Scope OUT (do not implement)

- ❌ Module 2 (Flop C-bet IP) — v4.0.3
- ❌ Module 3 (BB Defense) — v4.1
- ❌ Postflop SRS storage — v4.0.4
- ❌ Postflop session-history persistence (`localStorage.rmtt_postflop_history`) — open question, defer to v4.0.4
- ❌ XP / Chips for postflop — v4.1
- ❌ Postflop boss / mission / overall-exam integration — v4.2+
- ❌ Cosmetic / FX / Aura / Collection extensions for postflop
- ❌ Concept-tag click → modal — v4.0.5
- ❌ Custom session length picker — v4.0.4 (hardcoded 15 in v4.0.2)
- ❌ Solver-frequency display (mixing bars) — v4.0.5
- ❌ Field FX bleed into postflop UI — explicitly suppressed
- ❌ Edits to `postflop/*.json` data files — any data fix from scenario review ships in a SEPARATE commit before v4.0.2 implementation

---

## 4. Files allowed to edit

| File | Permission | Notes |
|---|---|---|
| `index.html` | EDIT — one fenced v4.0.2 block + 1 line in `renderMastery()` + 1 line in `renderSettings()` + 1 line `appVersion` | Total ~350–500 added lines |
| `service-worker.js` | EDIT — bump VERSION only | ~1 line diff |
| `PROJECT_STATE.md` | EDIT — state sync after implementation |  |
| `TASK_BOARD.md` | EDIT — workstream sync after implementation |  |

**No other file is in scope.** In particular:
- `postflop/*.json` — read-only.
- `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html` — read-only.
- `tools/audit-postflop.js` — read-only.
- `ranges.json`, `manifest.json`, icons — untouched.
- `docs/decisions/*.md` — no new decision needed (implements DEC-001 directly).

---

## 5. File ownership

- **DEV Integration Agent** owns the implementation step (`index.html` + `service-worker.js`).
- **Audit Subagent** must run audit BEFORE DEV begins; data must report `0 errors / 0 warnings`.
- **GTO Data Subagent** owns any data fix (per Scenario Review B1–B5) — ships in its own commit BEFORE v4.0.2 implementation.
- **QA Agent** runs the 52-item QA matrix (`docs/specs/postflop-v4.0.2-qa-plan.md`).
- **Orchestrator** updates `PROJECT_STATE.md` and `TASK_BOARD.md` after DEV+QA report.

---

## 6. UI flow (consolidated from UX plan)

```
[Settings tab]
  └── 🧪 Beta Features section
      └── [☐] Enable post-flop beta modules
              (default off; toggle persists via App.saveSettings)

[Home tab — when postflopBeta=true]
  └── (existing Mastery cards)
  └── [NEW] 🧪 POSTFLOP BETA card
            "Module 1 — Board Texture Trainer
             Read the board first.
             20 scenarios · ~10 min
             [▶ Start Board Texture Drill]"

[Tap Start → enters #postflopScreen, hides .tab-panel.active]

[#postflopScreen — Question phase]
  └── Top context bar: "🧪 Board Texture Trainer · Q 4/15  [✕ Exit]"
  └── Progress bar
  └── Spot card (100BB · BTN open · BB call · SRP · "Hero: — board read")
  └── Board cards (3 large cards, 56×80 px each)
  └── Question prompt
  └── 3-4 choice buttons (full-width, 56 px tall)

[Tap a choice → Feedback phase, same screen]
  └── Result row: ✅ BEST · 1.0 pts (color-coded by tier)
  └── Player pick vs GTO best
  └── 💡 Short explanation (always shown)
  └── Concept tag pills
  └── Expandable sections (closed on mobile, open on desktop):
        ▶ Range Logic
        ▶ Nut Logic
        ▶ Sizing Logic (if non-null)
        ▶ Common Mistake (auto-expanded if critical)
  └── [Next →] (or [Finish] on Q15)

[Q15 → Summary]
  └── Score banner: "13.5 / 15 (90%)"
  └── Per-tier counts: Best 12 · Acceptable 1 · Bad 1 · Critical 1
  └── ▶ Concept mastery breakdown
  └── ▶ Critical leaks list (if any)
  └── [▶ Drill again] [← Back to Home]

[Exit mid-session → Confirm modal]
  └── "Exit Drill? Q4 of 15. Progress will be discarded."
  └── [Cancel] [✕ Exit Anyway]
```

Full visual specs: see `postflop-v4.0.2-ux-plan.md` §§ 4–10.

---

## 7. Data flow

```
postflop_scenarios.json  (committed, audited)
        │
        ▼ fetched at boot by loadPostflopData()  [v4.0.1, already shipped]
        │
        ▼ Object.freeze + filter to auditStatus === 'approved'
        │
App.postflop.scenarios   ← frozen array of 31 scenarios
        │
        ▼ getModule1Scenarios()  [v4.0.2 — pure filter]
        │
moduleScenarios          ← array of pf_board_texture (20 scenarios)
        │
        ▼ buildPostflopQueue(moduleScenarios, 15)  [v4.0.2 — Fisher-Yates shuffle, slice 15]
        │
App.state.postflopDrill.queue   ← session state (mutable, session-scoped)
        │
        ▼ render functions  [v4.0.2]
        │
DOM: question card / answer choices / feedback card / summary
```

Defensive behavior: every accessor returns safely if `App.postflop.ready === false` or `App.postflop.scenarios.length === 0`.

---

## 8. Scoring behavior (multi-tier)

```js
function classifyPostflopAnswer(scenario, choiceId) {
  if (scenario.answer.best.includes(choiceId))
    return { tier: 'best',       score: scenario.scoring.best,       isCritical: false };
  if (scenario.answer.acceptable.includes(choiceId))
    return { tier: 'acceptable', score: scenario.scoring.acceptable, isCritical: false };
  if (scenario.answer.critical.includes(choiceId))
    return { tier: 'critical',   score: scenario.scoring.critical,   isCritical: true  };
  if (scenario.answer.bad.includes(choiceId))
    return { tier: 'bad',        score: scenario.scoring.bad,        isCritical: false };
  // Defensive fallback (shouldn't happen if R04/R15 audit holds)
  return { tier: 'bad', score: 0, isCritical: false };
}
```

Score values come from `scenario.scoring` (per-scenario): `{ best: 1.0, acceptable: 0.5, bad: 0, critical: 0 }`. v4.0.0 audit rule R11 enforces these.

**Never call** preflop's `classifyAnswer()` — different signature, different state.

---

## 9. Feedback / explanation behavior

Two-tier reveal (UX plan § 6):

**Tier 1 (always visible)**:
- Result icon + label: `✅ BEST` / `≈ ACCEPTABLE` / `❌ BAD` / `🚨 CRITICAL LEAK`
- Player's pick + GTO best (label form, not id)
- `💡 explanation.short` (one-line principle)
- Concept tag pills (static text in v4.0.2; clickable in v4.0.5)

**Tier 2 (collapsible `<details>`)**:
- `▶ Range Logic` (if `scenario.explanation.rangeLogic` non-null)
- `▶ Nut Logic` (if non-null)
- `▶ Hand Logic` (always null for Module 1 — skip)
- `▶ Sizing Logic` (if non-null)
- `▶ Common Mistake` (if non-null; auto-`open` if `tier === 'critical'`)

Mobile (≤ 720 px): all Tier 2 sections start collapsed.
Desktop (≥ 720 px): all Tier 2 sections start expanded.

---

## 10. QA checklist (52 items — full matrix in `postflop-v4.0.2-qa-plan.md`)

Categories (each gates the next):

| Category | Items | Pass criterion |
|---|---|---|
| **A** Loader dependency | 5 | 5/5 (any fail blocks) |
| **B** Preflop regression | 8 | 8/8 (any preflop break is release blocker) |
| **C** Module 1 functional | 12 | 12/12 |
| **D** Defensive paths | 7 | 7/7 |
| **E** UI / UX (incl. mobile 375 px) | 10 | 10/10 |
| **F** Storage / state isolation | 6 | 6/6 |
| **G** Service worker / offline | 4 | 4/4 |

**Console requirements after every category**:
- ✅ Zero `[ERROR]` from postflop code
- ✅ Zero `[WARN]` from postflop code
- ✅ Expected log: `[postflop] loaded 31/31 scenarios (schema 1.0.0)` (one per page load)

**Diff scope check** before commit:
```
index.html               (~350-500 added)
service-worker.js        (1 line VERSION bump)
PROJECT_STATE.md         (state sync)
TASK_BOARD.md            (workstream sync)
docs/specs/brief-v4.0.2-implementation-ready.md  (this file)
```
Any other modified file = stop and identify unauthorized change.

---

## 11. Stop condition

DEV Integration Agent stops after:

1. Implementing exactly the scope in §§ 2 + 6 + 7 + 8 + 9.
2. Passing all 52 QA items per §10.
3. Updating `PROJECT_STATE.md` (current version → 4.0.2; latest completed work entry; next step).
4. Updating `TASK_BOARD.md` (v4.0.2 → done; v4.0.3 → next).
5. Staging the commit (do NOT commit until human approves the diff).
6. Reporting:
   - File-level diff summary
   - QA results (per category, per item)
   - Console clean confirmation
   - Anything unexpected (failed QA item, ambiguous spec, escalation needed)

DEV Integration Agent must NOT:
- Push to remote (separate explicit instruction).
- Begin v4.0.3.
- Add postflop SRS storage (that's v4.0.4).
- Add cosmetic / reward / boss extensions.
- Modify guardrail surfaces (preflop ranges/scoring/SRS/cooldowns/Chips/cosmetic logic).
- Edit `postflop/*.json` data files (data fixes ship in their own commit BEFORE v4.0.2).
- Touch `postflop_audit_rules.js` or `tools/audit-postflop.js`.

---

## 12. Hard guardrails (carried from PROJECT_STATE.md § 6)

These apply regardless of any apparent exception:

- ❌ No changes to preflop ranges (`ranges.json`).
- ❌ No changes to scoring (`classifyAnswer`).
- ❌ No changes to SRS (`getSRSKey`, `updateSRS`).
- ❌ No changes to cooldowns / boss-fail rules.
- ❌ No changes to rank progression / Chips formula / XP.
- ❌ No changes to cosmetic ownership / grant / reveal logic.
- ❌ No new postflop bosses / rewards / FX / Aura / Collection items.
- ❌ No service-worker cache strategy changes for non-postflop assets.
- ❌ No changes to existing tab navigation or tab labels.

If any guardrail must be touched, DEV Integration Agent stops and escalates to Orchestrator via `TASK_BOARD.md` Blockers section.

---

## 13. Human approval gate

This brief is **planning only**.

> **Do not implement v4.0.2 until human reviewer reads this brief + the 4 source documents and explicitly approves.**

After approval, the workflow is:

1. **(optional pre-step)** GTO Data Subagent fixes the scenario review B1–B5 issues in their own commit (`postflop/*.json` data fixes only); audit re-runs clean. Decision: ship v4.0.2 with these fixes vs without (recommend WITH; see Open Question 4 below).
2. Audit Subagent confirms 0/0 on `postflop/*.json`.
3. DEV Integration Agent implements per this brief.
4. QA Agent runs the 52-item checklist.
5. Orchestrator updates `PROJECT_STATE.md` + `TASK_BOARD.md`.
6. DEV Integration Agent stages the commit with message:
   ```
   v4.0.2: add postflop Module 1 Board Texture Trainer UI
   ```
7. Human reviews diff and approves the commit.
8. DEV Integration Agent commits.
9. Push happens only on a separate explicit "push" instruction.

---

## 14. Open questions (must resolve before approval)

Consolidated from all four source documents:

1. **Session history persistence** (Architecture § 14, QA F3) — store completed sessions in `localStorage.rmtt_postflop_history` (new namespace) or keep session-only?
   - **Orchestrator recommendation**: session-only in v4.0.2; add persistence in v4.0.4 alongside SRS.

2. **Default session length** (Architecture § 14) — 10, 15, or 20 questions?
   - **Orchestrator recommendation**: 15 (matches existing Quick Drill default).

3. **Beta toggle visibility** (Architecture § 14) — show toggle in Settings (v4.0.2) or hide until v4.0.4?
   - **Orchestrator recommendation**: show in v4.0.2 — players need a way to opt in without DevTools.

4. **Pre-implementation data fix** (Scenario Review B1–B5) — fix the 5 review concerns (#20 "wait" artifact, #11 GTO confidence, #10 sourceConfidence, missing concept tags, choice label hint inconsistency) in a separate data-only commit BEFORE v4.0.2 implementation, OR ship v4.0.2 first and fix data in v4.0.3?
   - **Orchestrator recommendation**: fix data first. Specifically:
     - **Must-fix before v4.0.2**: #20 "wait" artifact (it's an authoring bug, not a judgment call).
     - **Should-fix**: choice label hint consistency (visible to every user; UX risk).
     - **Defer**: #10/#11 GTO confidence downgrades (defensible as-is; revisit after user feedback).
     - **Defer**: missing concept tags (additive; not user-visible until v4.0.5 concept-tag clicks).

5. **Critical-flag UI** (carried from v4.0.0 open questions) — flag-only in stats, or block progression?
   - **Orchestrator recommendation**: flag-only in v4.0.2. No blocking. Player learns from the explanation.

6. **Re-read explanation in summary** (Architecture § 14) — modal vs review mode?
   - **Orchestrator recommendation**: scroll-back review mode in v4.0.5 polish; v4.0.2 just shows the leak text inline.

7. **Reduced motion respected by postflop UI** (UX § 11) — yes/no?
   - **Orchestrator recommendation**: yes — reuse existing `App.state.settings.fxRespectMotion` flag.

8. **Choice label hint policy** (Scenario Review E1) — always include rationale parentheticals or never?
   - **Orchestrator recommendation**: never (cleanest test integrity). Strip existing hints in the data-fix commit.

9. **Postflop UI inheriting Field FX** (UX § 5, QA E10) — explicit suppression or accept any bleed?
   - **Orchestrator recommendation**: explicit suppression. Postflop screen sets a body class `body[data-postflop-active]` that overrides field-fx canvas opacity to 0.

10. **Curated 15 vs random 15** (Scenario Review C) — use the curated order from Scenario Review C, OR random shuffle from full 20?
    - **Orchestrator recommendation**: random shuffle from approved subset (excluding #20 hold + #10/#11 deferred = 17 scenarios). Curated order is for first-session demo; production should shuffle for replay value.

---

## 15. Curated subset for v4.0.2 first ship

Per Scenario Review § C with Orchestrator adjustments:

**Approved-for-shuffle pool (17 scenarios)**:
All 20 Module 1 scenarios EXCEPT:
- `pf_btn_v_bb_srp_100bb_flop_7d7s3c_rangeadv_001` (#20 — HOLD until "wait" artifact fixed)
- `pf_btn_v_bb_srp_100bb_flop_Th8h3h_nutadv_001` (#11 — defer; GTO confidence concern)
- `pf_btn_v_bb_srp_100bb_flop_Qh9d6s_freq_001` (#10 — defer; sourceConfidence overclaim)

**Implementation**: filter in `getModule1Scenarios()`:
```js
function getModule1Scenarios() {
  if (!getPostflopReady()) return [];
  // v4.0.2: temporarily exclude 3 scenarios pending data revision
  var excludeForV402 = new Set([
    'pf_btn_v_bb_srp_100bb_flop_7d7s3c_rangeadv_001',
    'pf_btn_v_bb_srp_100bb_flop_Th8h3h_nutadv_001',
    'pf_btn_v_bb_srp_100bb_flop_Qh9d6s_freq_001'
  ]);
  return App.postflop.scenarios.filter(function (s) {
    return s.module === 'pf_board_texture' && !excludeForV402.has(s.id);
  });
}
```

This keeps the data files untouched (no edit to `auditStatus`) — exclusions are coded in the v4.0.2 module renderer, easily removed in a future version when the data is revised.

If 17 scenarios is judged too few for `15 × random` (might feel repetitive on replay), the alternative is to fix #10 and #11's `sourceConfidence` to `expert_judgment` in the data-fix commit, which restores them to the pool.

---

## 16. Data-fix commit (recommended pre-step)

Before DEV Integration Agent starts v4.0.2 implementation:

**GTO Data Subagent ships ONE data-only commit** (separate from v4.0.2):

```
postflop: data fixes for v4.0.2 readiness
  - Fix #20 (7d7s3c_rangeadv) "wait" leftover in nutLogic explanation
  - Strip choice label rationale hints (consistency)
  - [optional] Downgrade #10 sourceConfidence → expert_judgment
  - [optional] Add missing concept tags per scenario review B4
```

After this commit lands:
- Audit must re-confirm 0/0
- v4.0.2 brief's "exclude 3" filter shrinks accordingly

If GTO Data Subagent decides to fix all of B1–B5, the v4.0.2 brief excludeForV402 list shrinks to ONLY the must-defer scenarios (likely empty). Recommended path.

---

## 17. Implementation sequence (post-approval)

```
Step 1 — Data fix commit (GTO Data Subagent)
  - Fix #20 "wait" artifact
  - Strip choice label hints
  - Optional: B4 tag additions, B1 sourceConfidence downgrades
  - Audit 0/0
  - Stage commit; human approves; commit

Step 2 — v4.0.2 implementation (DEV Integration Agent)
  - Implement per this brief (§§ 2 + 6 + 7 + 8 + 9)
  - Local QA (52 items)
  - Update PROJECT_STATE.md + TASK_BOARD.md
  - Stage commit with message "v4.0.2: add postflop Module 1 Board Texture Trainer UI"
  - Human approves; commit; push (separate instruction)

Step 3 — Post-deploy spot check
  - Netlify deploy; verify v4.0.2 cache active
  - Real-mobile (not just emulator) test on 375 px device
  - Toggle beta on/off; play one 15-question session end-to-end
```

---

## 18. Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | Orchestrator | Initial publication; consolidates Architecture / UX / Scenario Review / QA sources |
