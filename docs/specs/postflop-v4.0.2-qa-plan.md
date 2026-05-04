# QA Plan — v4.0.2 Board Texture Trainer

> **Owner**: Audit / QA Subagent.
> **Status**: planning. Pairs with Architecture brief + UX plan + Scenario Review.
> **Audience**: DEV Integration Agent (build target) + QA Agent (executor) + reviewer.
> **Test environment**: `http://localhost:8765/index.html` (local server) + Chrome DevTools + browser device emulation for 375 px mobile.

---

## 1. QA philosophy

1. **Regression first**: v4.0.2 must not break preflop. Every QA round opens with a preflop smoke pass.
2. **Defensive paths matter as much as happy paths**: postflop loader off, beta off, empty pool, mid-session reload, dataset edits — all must degrade gracefully.
3. **Postflop has no SRS yet**: do not assume any persistence beyond `App.state.postflopDrill` (session-only). Post-session state should be cleared completely.
4. **Two-tier**: each test item has a (1) deterministic pass/fail criterion and (2) the diagnostic command/observation that proves it.
5. **Mobile is not "test last"**: every screen QA pass runs at 375 px first, then desktop.

---

## 2. Pre-implementation gates

Before DEV Integration Agent starts coding, confirm:

| Gate | Check | Expected |
|---|---|---|
| G1 | Audit clean on postflop data | `node tools/audit-postflop.js` (or browser viewer) → `0 errors / 0 warnings` |
| G2 | App.postflop ready in browser | DevTools console: `App.postflop.ready === true` |
| G3 | Module 1 scenarios accessible | `App.postflop.scenarios.filter(s => s.module === 'pf_board_texture').length === 20` |
| G4 | All 5 question types present in Module 1 | `new Set(App.postflop.scenarios.filter(s => s.module === 'pf_board_texture').map(s => s.question.type))` size ≥ 5 |
| G5 | Working tree clean before edit | `git status` clean (or only documentation changes) |
| G6 | Scenario review concerns addressed (or explicitly deferred) | Decision logged on each B1–B5 finding from `postflop-v4.0.2-scenario-review.md`: fix now, fix in v4.0.3, or accept |

If any gate fails, stop and escalate to Orchestrator.

---

## 3. Test categories

### Category A — Loader dependency tests (5 items)
Verifies v4.0.2 correctly consumes `App.postflop` and degrades when it isn't ready.

### Category B — Preflop regression tests (8 items)
Verifies zero behavior change for the existing app.

### Category C — Module 1 functional tests (12 items)
Happy-path: start → answer → feedback → advance → finish.

### Category D — Defensive / error path tests (7 items)
Beta off, empty pool, missing fields, mid-session reload, double-tap, etc.

### Category E — UI / UX tests (10 items)
Visual layout, tab targets, mobile 375 px, accessibility.

### Category F — Storage / state isolation tests (6 items)
postflop drill state separate from preflop; localStorage clean.

### Category G — Service worker / offline tests (4 items)
Cache behavior, offline reload.

**Total: 52 test items.** Categories run in this order; each category gates the next.

---

## 4. Category A — Loader dependency

| # | Test | How | Expected |
|---|---|---|---|
| A1 | App.postflop loaded on boot | DevTools: `App.postflop.ready` after page load + 200 ms | `true` |
| A2 | Module 1 filter returns expected count | `App.postflop.scenarios.filter(s => s.module === 'pf_board_texture').length` | `20` |
| A3 | Scenario filter respects auditStatus | `App.postflop.scenarios.every(s => s.auditStatus === 'approved')` | `true` |
| A4 | Concept lookup works | `getConceptByKey('range_advantage').displayName` | `"Range advantage"` |
| A5 | Frozen API still enforced | `App.postflop.scenarios.push({})` throws | `TypeError` |

**Pass criterion for category A**: 5/5 pass. Any fail blocks all subsequent categories.

---

## 5. Category B — Preflop regression

| # | Test | How | Expected |
|---|---|---|---|
| B1 | All 5 tabs render | Visit Home, Drill, Progress, Browse, Settings — each loads | All visible |
| B2 | Preflop drill engine still works | Quick Drill 5+ hands, mix of correct/wrong actions | Each answer classifies correctly; SRS updates |
| B3 | classifyAnswer signature unchanged | `typeof classifyAnswer === 'function'` and call with `(action, freqs)` | Returns object with `result`, `score`, `userFreq`, `isPure` |
| B4 | App.state.drill shape unchanged | `Object.keys(App.state.drill).sort()` | Same keys as v4.0.1 (mode, queue, currentIndex, answers, streak, …) |
| B5 | Boss test entry still works | Click "Rank-Up Boss" on a module | Boss gate UI renders, no errors |
| B6 | Settings render unchanged | Open Settings tab; FX, Aura, etc. controls present | All existing settings intact |
| B7 | Existing localStorage keys untouched (after v4.0.2 actions) | After running a postflop session: `Object.keys(localStorage).sort()` | Includes `rmtt_progress`, `rmtt_settings`, `rmtt_streaks`, `rmtt_stats`, `rmtt_profile`; may add `rmtt_postflop_history` ONLY if Open Question 1 resolves to "yes, persist" |
| B8 | Backup export still works | `exportBackup()` triggers download | Backup file appVersion = '4.0.2'; data contains all 6 expected keys |

**Pass criterion**: 8/8 pass. Any preflop regression is a release blocker.

---

## 6. Category C — Module 1 functional

| # | Test | How | Expected |
|---|---|---|---|
| C1 | Beta toggle off → no Home card | `App.state.settings.postflopBeta = false; renderMastery();` | No `.postflop-home-card` in DOM |
| C2 | Beta toggle on → Home card renders | `App.state.settings.postflopBeta = true; saveSettings(); renderMastery();` | `.postflop-home-card` visible with title + scenario count + start button |
| C3 | Click Start → enters question screen | Click `[ ▶ Start Board Texture Drill ]` | `#postflopScreen` visible; `.tab-panel` hidden; Q 1/15 displayed |
| C4 | First question renders correctly | Inspect `#postflopScreen` content | Spot card, board cards (3 visible), question prompt, ≥3 choice buttons |
| C5 | Tap a choice → feedback screen | Click any choice | Feedback card appears with result icon (✅/≈/❌/🚨), short explanation, expandable sections |
| C6 | Feedback shows correct tier | Click `best` → ✅ BEST · 1.0 pts; click `bad` → ❌ BAD · 0 pts; click `critical` → 🚨 CRITICAL LEAK | All 4 tiers reachable across the 20 scenarios |
| C7 | Critical auto-expands commonMistake | On a critical answer | Common Mistake `<details>` element has `open` attribute |
| C8 | Next button advances | Click `[ Next → ]` | `currentIndex` increments; new question renders |
| C9 | Q counter updates | After 5 advances | "Q 6 / 15" |
| C10 | Last question changes Next → Finish | On Q 15 feedback | Button label = `Finish` or `Summary`, action goes to summary |
| C11 | Summary screen renders | After Q 15 finish | Score banner, per-tier counts, concept-mastery section, optional critical-leaks list, action buttons |
| C12 | Drill again restarts session | Click `[ ▶ Drill again ]` | Fresh queue (deterministic shuffle or random); back to Q 1/15 |

**Pass criterion**: 12/12 pass. C5–C7 are the core scoring contract.

---

## 7. Category D — Defensive / error paths

| # | Test | How | Expected |
|---|---|---|---|
| D1 | App.postflop not ready on boot | Throttle network in DevTools; navigate to Home before postflop loads | Home card replaced by "loading…" placeholder; no crash |
| D2 | App.postflop.ready === false (load failed) | Block postflop fetches in DevTools; reload | Home card replaced by error placeholder; existing UI fully functional |
| D3 | Empty Module 1 pool | Override `App.postflop.scenarios = []` (impossible due to freeze; simulate by editing JSON locally) | Home card shows "No scenarios available" |
| D4 | Scenario missing required field | Local JSON edit removing `explanation.short` from one scenario; reload + audit | Audit catches it (R06). If shipped anyway, render falls back gracefully (skip section, render others) |
| D5 | Mid-session reload | Start session, answer 3 questions, hit F5 | App boots fresh; postflop session state cleared; user lands on Home (or last tab); no orphan UI |
| D6 | Double-tap a choice | Click choice rapidly twice | First click registers; second click ignored (button disables or `state.phase === 'answer'` blocks) |
| D7 | Exit mid-session via browser back | Press browser back during question | Either: confirm modal appears (if popstate handler added) OR returns to previous tab cleanly with state cleared |

**Pass criterion**: 7/7 pass. D5 and D7 are the most subtle.

---

## 8. Category E — UI / UX

| # | Test | How | Expected |
|---|---|---|---|
| E1 | 375 px viewport: question screen layout | Chrome DevTools device emulation, 375 px | No horizontal scroll; board cards fit; choice buttons full-width 56 px tall |
| E2 | 375 px viewport: feedback screen | Same | Sections collapsible; Next button reachable; concept tags wrap cleanly |
| E3 | 375 px viewport: summary screen | Same | Score banner readable; lists scroll if long |
| E4 | Choice button tap target | Inspect computed style | `min-height: 56px`, `width: 100%` |
| E5 | Color contrast on result tiers | Use DevTools Lighthouse a11y | All text ≥ 4.5:1 contrast |
| E6 | Reduced motion respected | Set `App.state.settings.fxRespectMotion = true` AND OS reduced-motion on | No transitions on result row; no count-up animation on summary |
| E7 | `<details>` keyboard accessible | Tab to summary; Enter/Space toggles expand | Native browser behavior |
| E8 | Concept tag pills wrap (not scroll) | Long tag list on Q 8 (multiple tags) | Pills wrap to next line; no horizontal scroll on the tag row |
| E9 | Critical leak amber styling | Trigger a critical answer | Border has amber accent; commonMistake auto-expanded |
| E10 | Postflop UI does not inherit Field FX | Equip a Field FX (existing v3.8.x feature); enter postflop | Postflop screen shows no field-fx-canvas overlay |

**Pass criterion**: 10/10. E10 is the most likely sleeper bug — Field FX is body-level and could bleed into postflop.

---

## 9. Category F — Storage / state isolation

| # | Test | How | Expected |
|---|---|---|---|
| F1 | App.state.drill (preflop) untouched after postflop session | Snapshot before, run session, snapshot after | Both snapshots identical |
| F2 | App.state.postflopDrill cleared after exit | Run session to summary, click "Back to Home" | `App.state.postflopDrill.active === false` AND `queue.length === 0` |
| F3 | localStorage keys after postflop session | `Object.keys(localStorage).sort()` | Same as before postflop session (if no history persistence added) |
| F4 | Settings persistence: postflopBeta survives reload | Toggle on, reload, check | `App.state.settings.postflopBeta === true` |
| F5 | confirmReset clears postflop state too | Trigger reset, check | `App.state.postflopDrill === undefined` or default empty; `App.state.settings.postflopBeta === false` (default) |
| F6 | postflop session resilient to App.saveProgress() during play | Mid-session, call `App.saveProgress()` | postflopDrill is excluded from save (session-only); no console errors |

**Pass criterion**: 6/6. F1 is the regression critical.

---

## 10. Category G — Service worker / offline

| # | Test | How | Expected |
|---|---|---|---|
| G1 | SW VERSION reflects v4.0.2 | DevTools Application → Service Workers | `range-master-v4.0.2` cache active |
| G2 | postflop JSON files cached | Application → Cache Storage → range-master-v4.0.2 | All 3 postflop JSON paths present |
| G3 | Offline reload preserves postflop UI | Toggle DevTools "Offline", reload | App boots; `App.postflop.ready === true`; postflop UI accessible |
| G4 | Old cache (v4.0.1) cleaned up | Application → Cache Storage | Only `range-master-v4.0.2` present (no v4.0.1 leftover after activation) |

**Pass criterion**: 4/4.

---

## 11. Browser console requirements

After every test category, check the console:

- ✅ Zero `[ERROR]` entries from postflop code (any error from existing `[DEBUG Browse]` etc. is preexisting and not new)
- ✅ Zero `[WARN]` entries from postflop code
- ✅ Expected log present: `[postflop] loaded 31/31 scenarios (schema 1.0.0)` (from v4.0.1 loader; appears once per page load)
- ✅ Optional postflop session logs (e.g., `[postflop] session started: pf_board_texture`) are INFO level; OK to ship if not noisy

If a postflop error appears in any category, document it with: timestamp, full stack, reproduction steps, and link to issue in TASK_BOARD.md.

---

## 12. Diff scope check (post-implementation)

Before committing v4.0.2, confirm `git diff --stat` shows ONLY:

```
index.html                         (~200-400 lines added in one fenced v4.0.2 block + ~3 isolated edits)
service-worker.js                  (VERSION bump only — assets unchanged from v4.0.1 list)
PROJECT_STATE.md                   (state sync)
TASK_BOARD.md                      (workstream sync)
docs/specs/brief-v4.0.2-implementation-ready.md  (the brief itself)
```

NOT modified:
- `postflop/*.json` (any data fixes from scenario review B1-B5 ship in a separate commit)
- `postflop/postflop_audit_rules.js`
- `postflop/postflop_audit.html`
- `tools/audit-postflop.js`
- `ranges.json`, `manifest.json`
- Any cosmetic / FX / aura / collection / boss code paths

If the diff exceeds these files, stop and identify the unauthorized change.

---

## 13. Pre-commit checklist (for DEV Integration Agent + QA Agent)

```
[ ] G1-G6 pre-implementation gates passed
[ ] Implementation matches consolidated brief scope
[ ] Categories A, B, C, D, E, F, G all pass
[ ] Console clean (no postflop errors/warnings)
[ ] Diff scope check passes
[ ] PROJECT_STATE.md + TASK_BOARD.md updated
[ ] Commit message drafted (suggested: `v4.0.2: add postflop Module 1 Board Texture Trainer UI`)
[ ] Approval requested from human
```

---

## 14. Recommended manual play-through (smoke before signoff)

In addition to automated/console QA, a human (or QA Agent driving Chrome) should:

1. Toggle beta on in Settings.
2. Click Start on Home card.
3. Play through 5 questions, intentionally answering: 2× correct, 1× acceptable, 1× bad, 1× critical.
4. Verify each feedback screen reads naturally.
5. Click an expandable section (Range Logic) and confirm content matches scenario.
6. Exit via `[ ✕ Exit ]` mid-session; confirm modal works.
7. Restart, complete to summary, verify per-tier counts match what was answered.
8. Resize to 375 px and re-do steps 4–6 to catch mobile-specific issues.

This is the play-through the human reviewer can demo before approving commit.

---

## 15. Stop condition

QA Subagent stops after this plan. Orchestrator consolidates with Architecture / UX / Scenario Review into the implementation-ready brief.

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | QA Subagent | Initial publication |
