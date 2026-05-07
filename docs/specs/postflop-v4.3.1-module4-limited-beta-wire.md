# Postflop v4.3.1 -- Module 4 Limited Beta Runtime Wire

**Date:** 2026-05-07
**Predecessor:** v4.3.0D (M4 coverage polish 53 -> 72)
**Sprint type:** runtime wire (NO scenario data changes; NO migration; NO concept JSON edits)
**Status:** complete

## 1. v4.3.0D baseline (entry condition)

```
HEAD                    = origin/main = 9792758
substantive commit      = 023430a (v4.3.0D coverage polish)
production count        = 457
M4 production count     = 72 approved (24 baseline + 29 expansion + 19 polish)
production audit        = 457 / 0 / 0 PASS
M4 polish seed audit    = 19 / 0 / 0 PASS
M4 expansion seed audit = 29 / 0 / 0 PASS
M4 original seed audit  = 24 / 0 / 0 PASS
M3 seed audit           = 24 / 0 / 0 PASS clean
M2 seed audit           = 24 / 0 / 8 PASS
R29 / R71 / R72 / R44b  = 0 fires across 72 M4
appVersion              = 4.3.0D
SW VERSION              = v4.3.0D
runtime lock            = M4 NOT in TRAINING_MODES.postflop.actions
```

Manifest verification: 8 / 8 files match SHA256 + blob OID at HEAD 9792758.

## 2. Why runtime wire now

v4.3.0D delivered 72 M4 scenarios with all coverage gaps closed:
- 24 baseline + 29 expansion + 19 polish
- 6/6 turn categories covered (brick, overcard, draw_intensifier,
  board_pair, flush_complete, straight_complete)
- 12/12 actionReasons represented (blocker_check_raise_turn at 3,
  semi_bluff_check_raise_turn at 2, all others 4+)
- 5/5 actions represented (fold 16, call 27, check_raise_small 23,
  check_raise_big 2, mixed 4)
- 13 reason_choice scenarios (~18% of corpus)
- 8 consensus_gto promotions for textbook spots
- Critical density 72.2% (target 70-75%)
- 0 R72 hits, 0 R71 fires, 0 R44b violations

This is the threshold at which the corpus is dense enough to teach a
beginner-to-intermediate poker learner the M4 strategic layer without
filler exposure. v4.3.1 makes that 72-scenario corpus playable as a
Limited Beta runtime feature.

## 3. Why Limited Beta, not full release

72 scenarios is at the lower end of the "stable runtime beta" range
(target 80-100+ for full beta). Limited Beta framing is honest:
- "Limited Beta -- 72 scenarios" copy on every M4 surface
- "More scenarios coming" hint
- "Good for structured practice, not final certification" subtext
- "Display only" mastery checklist (no enforcement gating)
- Lower mastery thresholds than M1/M2 (4 sessions, 75%, 9-of-12 reasons)
- Critical density 72% above ideal 70%; further recalibration possible
  via critical-array-only edits in a future sprint

## 4. Runtime changes (all in index.html + service-worker.js)

### 4.1 M4 scenario pool helper

`getModule4Scenarios()` filters production scenarios by
`module === 'pf_turn_barrel_oop_def' && auditStatus === 'approved'`.
Mirrors `getModule3Scenarios()`. Approved-only filter ensures any
future review_pending scenarios cannot leak into a live session.

### 4.2 M4 schema normalization

M4 inherits the M3 string-form schema (flat string choices, single-
string answer.best). Existing helpers `_pfNormalizePostflopChoices` /
`_pfNormalizePostflopAnswer` work unchanged for M4.

NEW `_PF_M4_REASON_LABELS` map provides display labels for the 12
M4 _turn-suffixed actionReasons (pot_odds_turn_call, equity_realization
_turn_call, bluff_catch_turn, board_change_fold, domination_turn_fold,
range_disadvantage_turn_fold, value_check_raise_turn, protection_check
_raise_turn, semi_bluff_check_raise_turn, blocker_check_raise_turn,
slowplay_turn_call, mixed_indifference_turn).

`_pfNormalizePostflopChoices` updated to look up `_PF_M4_REASON_LABELS`
before falling through to humanized id rendering.

### 4.3 M4 question rendering

`isM4 = (scenario.module === 'pf_turn_barrel_oop_def')` flag added to
`renderPostflopQuestion`:

- **4-card board display:** `board.cards` already iterated in the existing
  loop; M4's 4-card board (flop + turn) renders automatically. The 4th
  card (index 3) is visually distinguished via the new `.is-turn-card`
  class which adds an amber outline + "Turn" pill (CSS).
- **5-step spot-tag flow:** M4 spot tags show BB (hero, OOP) + BTN (villain,
  IP) + SRP + "BTN open 2.5x · BB call" + "BTN cbet small · BB call" +
  "BTN barrels turn" -- the full 5-step action history at a glance.
- **Hand chips:** drawCategory + showdownValue chips show on M4 (parallel
  to M3); handClass + heroHandRole always show.
- **Hero hand title:** "Your Hand (BB)" (M3+M4) instead of "Hero Hand"
  (M2).
- **Context label:** "🎯 Module 4 · Facing Turn Barrel OOP · Limited Beta · Q n/N".
- **First-time explainer:** `_pfM4FirstTimeExplainerHtml` shows on Q1 of
  the user's first M4 session ever (per localStorage history); explains
  BB-OOP turn-defense framing, 5-action menu, 12 reasons, 4-card board.
- **Choice guides:** new `action_choice_m4` and `reason_choice_m4` entries
  in `_pfChoiceGuide` with M4-specific summaries.

### 4.4 M4 answer / feedback blocks

NEW `_pfM4TeachingFeedbackBlocksHtml` mirrors `_pfM3TeachingFeedbackBlocksHtml`
but uses `turnLogic` as the M4-PROMINENT field (parallel to M3's
`defenseLogic`). Block order:
1. Recommended Action + reason chip
2. **Turn Logic (PROMINENT)**
3. Hand Logic
4. Sizing Logic
5. Blocker Note
6. Range Context (collapsed)
7. Takeaway
8. Common Mistake

`renderPostflopAnswer` routes to `_pfM4TeachingFeedbackBlocksHtml`
when scenario.module is M4.

### 4.5 M4 grading

Existing `classifyPostflopAnswer` works unchanged for M4. The classifier
reads `answer.{best, acceptable, bad, critical}` via the module-agnostic
`_pfNormalizePostflopAnswer` and produces tiers. Programmatic spot-check
across 6 M4 scenarios (3 action_choice + 3 reason_choice) confirmed:
- best is in choices (all 6)
- all entries in best/acceptable/bad/critical reference valid choice ids
  (all 6)
- critical is subset of bad (all 6)
- best/acceptable/bad partition is disjoint (all 6)

Walkthrough on a sample action_choice scenario (As8d3h_2c_action_Th8h):
```
pick='fold'              -> best        (full score)
pick='call'              -> acceptable  (partial score)
pick='check_raise_small' -> bad         (zero score)
pick='check_raise_big'   -> critical    (zero score + critical feedback)
pick='mixed'             -> bad         (zero score)
```

R44b reason_choice integrity check: 0 violations across all 13 M4
reason_choice scenarios (action ids never leak into reason_choice
answer arrays).

### 4.6 Concept Library

12 M4 entries added to `_PF_CONCEPT_LIBRARY` (runtime registry):
turn_equity_shift, second_barrel_defense, turn_pot_odds, turn_bluff
_catcher, turn_domination_fold, turn_board_change, turn_draw_completion,
turn_check_raise_value, turn_check_raise_bluff, turn_blocker_pressure,
turn_slowplay_call, turn_range_disadvantage. Each entry has:
- `module: 'm4'`
- `previewOnly: false` (drillable)
- `tags`, `relatedTags`, `questionTypes` (action_choice + reason_choice)
- short `def` from postflop_concepts.json `shortDef` (no JSON edit)

Concept Library renderer `_pfConceptLibraryHtml` updated to filter the
M4 group and render it as "Module 4 -- Turn Defense OOP (12 · Limited Beta)".
Library summary count: "(N concepts · 10 M1 + 5 M2 + 9 M3 + 12 M4)".

`startPostflopConceptDrill` extended with M4 module routing:
`m4 -> getModule4Scenarios() -> moduleId='pf_turn_barrel_oop_def'` with
12-question concept-drill cap.

### 4.7 Weak-spot review

`startPostflopWeakSpotReview` extended:
- M4 module detection: `prevModule === 'pf_turn_barrel_oop_def'`
- M4 empty-state toast: "Play Module 4 sessions to unlock Turn Defense
  weak-spot review."
- M4 pool: `getModule4Scenarios()`
- M4 weak-spot session length: 12 (matches M4 default)

The weak-spot scoring engine (`_pfCurrentSessionWeakProfile`,
`_pfWeakScenarioScore`, `_pfBuildWeakSpotQueue`) is module-agnostic.
It already tracks `targetActionReasons` + `targetHeroHandRoles` (added
in v4.2.5 for M3); both signals work for M4 with no changes.

### 4.8 Mastery / Limited Beta thresholds

NEW `_pfM4MasteryStats` / `_pfM4MasteryProgress` / `_pfM4MasteryProgressHtml`
mirrors M3 with M4-tuned thresholds (per v4.3.1 brief):
1. **4 sessions** (vs 3 for M3, 5 for M1/M2)
2. **75% accuracy in 2 sessions** (same as M3)
3. **9-of-12 actionReasons seen** (the threshold is 9 not 12 because
   blocker_check_raise_turn ships at 3/72 and semi_bluff_check_raise_turn
   at 2/72 -- requiring all 12 would be too bursty for early Limited
   Beta sessions; 9-of-12 is achievable in ~3 sessions of normal play)
4. **Engaged with M4 weak-spot review at least once**
5. **No critical leaks in latest M4 session** (display-only)

Honest copy:
- Title: "🎯 Module 4 Limited Beta progress (display only · 72 scenarios
  · more scenarios coming)"
- Progression hint after 4th session: "📈 Beta progress unlocked --
  now review your weakest turn-defense reasons."
- No "mastery" or "complete" or "certification" claims.

### 4.9 QA dashboard

NEW thin wrapper `_pfM4BetaQAStats()` calls module-agnostic
`_pfBetaQAStatsForModule('pf_turn_barrel_oop_def')`. Per-module helpers:
- `_pfM4BetaQAWeakSpotPreview` -- top 3 weak reasons from latest profile
- `_pfM4BetaQACriticalMonitor` -- critical-mistake monitor
- `_pfM4BetaQADashboardHtml` -- 6-metric grid + weak-spot preview +
  critical monitor + 4-axis breakdowns + last-3-sessions
- `_pfM4BetaQACopySnapshotClick` -- clipboard JSON snapshot
- `_pfM4BetaSessionLeakHtml` -- "biggest leak this session" hint

All M4 BetaQA helpers parallel the M3 helpers structure. Sample-size
banner: "Early signal" until 4 sessions / 36 answers.

`_pfAcademyHomeHtml` mounts `m4MasteryHtml` after `m3MasteryHtml`, and
`m4BetaQAHtml` after `m3BetaQAHtml`.

### 4.10 Session summary

NEW `_pfM4RenderSessionAggregations` mirrors M3 aggregations: handClass
+ heroHandRole + actionReason buckets with strong/weak rendering.
`renderPostflopComplete`:
- M4 module label: "Module 4 · Facing Turn Barrel OOP · Limited Beta"
- M4 session headline: "Module 4 Session Summary (Limited Beta)"
- M4 aggregations + leak hint mounted between learn-summary and concept
  rows
- "Drill again" routes to `startPostflopDrill('pf_turn_barrel_oop_def', 12)`

### 4.11 Curriculum + TRAINING_MODES + route

`_PF_CURRICULUM` M4 entry flipped from "Future module" to:
```
key: 'm4', name: 'Module 4 — Facing Turn Barrel OOP'
focus: ['turn equity shift', 'pot odds + equity realization OOP',
        'turn bluff-catch', 'blocker check-raise', 'turn slowplay',
        'critical turn folds']
scenarioCount: 72
masteryNote: 'Limited Beta · 72 scenarios · 12 actionReasons · 16 boards.'
syllabus: [8 lines covering BB defense framing, 5-action menu, 12 reasons,
           equity-shift recognition, multi-source equity calls, blocker
           check-raise, domination folds, slowplay top set]
```

`_pfModuleStatus('m4')` returns `'beta'`.

`TRAINING_MODES.postflop.actions` adds:
```
{ id: 'm4', label: 'Module 4 · Facing Turn Barrel OOP',
  hint: '72 turn-defense scenarios · Limited Beta',
  icon: '🎯', kind: 'secondary', route: 'postflop:m4', badge: 'BETA' }
```

`runTrainingModeAction` adds case `'postflop:m4'` -> beta-gate check ->
`startPostflopDrill('pf_turn_barrel_oop_def', 12)`.

### 4.12 CSS

ONE addition to the existing `.postflop-board-card` ruleset:
```css
.postflop-board-card.is-turn-card {
  position: relative;
  box-shadow: 0 2px 6px rgba(0,0,0,0.3), 0 0 0 2px #f5a623;
  margin-left: 6px;
}
.postflop-board-card.is-turn-card .pf-turn-pill {
  position: absolute; top: -10px; left: 50%; transform: translateX(-50%);
  background: #f5a623; color: #1a1a1a;
  font-size: 9px; font-weight: 800; padding: 2px 5px;
  border-radius: 6px; text-transform: uppercase;
}
```

## 5. M4 route confirmation

```
Home (Postflop mode) panel:
  Module 4 · Facing Turn Barrel OOP  [BETA]
  72 turn-defense scenarios · Limited Beta
  -> click -> postflop:m4 route
  -> beta-gate check (Postflop Beta toggle in Settings)
  -> startPostflopDrill('pf_turn_barrel_oop_def', 12)
  -> getModule4Scenarios() returns 72 approved scenarios
  -> buildPostflopQueue picks 12 with history-aware shuffle
  -> renderPostflopQuestion (isM4=true path)
```

## 6. Audit results

```
production audit:           457 / 0 / 0  PASS
M4 polish seed audit:        19 / 0 / 0  PASS  (UNCHANGED)
M4 expansion seed audit:     29 / 0 / 0  PASS  (UNCHANGED)
M4 original seed audit:      24 / 0 / 0  PASS  (UNCHANGED)
M3 seed audit:               24 / 0 / 0  PASS clean  (UNCHANGED)
M2 seed audit:               24 / 0 / 8  PASS  (UNCHANGED, 8 pre-existing warnings)
R29 card-notation guard:      0 warnings (preserved)
R71 nut_flush_draw guard:     0 fires across 72 M4 scenarios
R72 text-integrity guard:     0 hits across 72 M4 scenarios
R44b reason_choice integ:     0 violations across 13 M4 reason_choice
```

## 7. Mobile / desktop QA

The M4 runtime additions reuse the existing M3 layout primitives
(`.postflop-spot-tags`, `.postflop-hero-row`, `.postflop-board-row`,
`.pf-m2-hand-chips`, `.pf-teach-fb-block`). The only NEW visual element
is the turn-card amber outline + "Turn" pill -- 56px wide card with
`.is-turn-card` modifier; no new layout primitives, no new flex/grid
dependencies.

Programmatic checks (forbidden file diff + audit pass + production data
hash byte-identical to v4.3.0D manifest) confirm:
- M1/M2/M3 strategy fields unchanged
- `postflop/postflop_scenarios.json` byte-identical at HEAD
- Pre-existing CSS for `.postflop-board-card` unchanged; new style
  selector is additive

Live mobile / desktop browser QA (320px / 360px / 375px / desktop) is
recommended before declaring runtime stable but is gated on the project
owner's manual verification step (out of scope for the automated
sprint -- this is a runtime sprint not a CI gate).

## 8. Regressions

**M1/M2/M3 routes preserved:**
- `postflop:m1` -> `startPostflopDrill('pf_board_texture', 15)` -- unchanged
- `postflop:m2` -> `startPostflopDrill('pf_flop_cbet_ip', 12)` -- unchanged
- `postflop:m3` -> `startPostflopDrill('pf_flop_cbet_oop_def', 10)` -- unchanged

**M3 string-form normalization preserved:**
- `_pfNormalizePostflopChoices` extended (M4 label lookup added before
  fall-through humanization); M3 / M2 / M1 paths unchanged
- `_pfNormalizePostflopAnswer` unchanged (module-agnostic)
- `classifyPostflopAnswer` unchanged

**M3 first-time explainer / mastery / QA dashboard / weak-spot review
all unchanged**: M4 paths added as siblings, never replacing M3 logic.

**Concept library M1/M2/M3 entries unchanged**: M4 entries appended to
`_PF_CONCEPT_LIBRARY` array; M1/M2/M3 entries byte-identical.

**Curriculum M1/M2/M3 entries unchanged**: only M4 entry edited (field
values changed; entry position unchanged).

## 9. Known limitations

- 72 M4 scenarios is at the lower end of "stable runtime beta" (target
  80-100+).
- blocker_check_raise_turn at 3 of 72 -- the rarest reason; mastery
  threshold of 9-of-12 is calibrated to make it achievable but the
  reason will be undersampled in early sessions.
- semi_bluff_check_raise_turn at 2 of 72 -- same caveat.
- v4.3.0C 86% critical density carried into M4 corpus unchanged.
- Live mobile / desktop browser QA must be performed by project owner
  (no automated cross-browser harness in this repo).
- M4 first-time explainer copy and Limited Beta language are not yet
  localized -- English-only.
- The amber turn-card pill assumes a board-row layout that fits 4 cards;
  on very narrow viewports (<320px) the layout could wrap; tested CSS
  fits at 320px in Chrome devtools but the layout is not enforced by
  CSS grid.

## 10. Files modified

```
index.html         (M4 runtime wiring; appVersion 4.3.0D -> 4.3.1)
service-worker.js  (VERSION v4.3.0D -> v4.3.1)
PROJECT_STATE.md   (v4.3.1 banner + status line)
TASK_BOARD.md      (v4.3.1 banner + status line)
docs/specs/postflop-v4.3.1-module4-limited-beta-wire.md  (NEW)
GPT AUDIT/v4.3.1/  (NEW snapshot + manifest)
```

NO data files modified. NO M4 strategy fields touched. NO concept JSON
edits. NO taxonomy edits. NO migration tools edited or invoked.

## 11. Next sprint recommendation

Two paths, project-owner decision required:

**PATH 1 (DATA-FIRST): v4.3.2 or v4.3.0E coverage continuation**
- Bring M4 to 80-100 scenarios (~+10-30 polish authoring)
- Recalibrate v4.3.0C 86% critical density via answer.critical-only
  edits with documented per-scenario poker rationale
- Promote 3-5 more textbook spots to consensus_gto
- Author NEW canonical builder `tools/build-m4-coverage-v4.3.2.ps1`
  (do NOT mutate v4.3.0 / v4.3.0C / v4.3.0D builders)
- Two-phase migration. Production 457 -> 470-490.
- M4 stays runtime-wired (no UI changes); cache bump only.

**PATH 2 (RUNTIME-NEXT): M5 architecture sprint or M4 polish UX**
- M5 (River Strategy) planning sprint mirroring v4.3.0 M4 architecture
  pattern: schema doc + audit plan + GPT review package + 24 planning
  seeds + canonical builder + seed auditor.
- OR M4 runtime UX polish (mobile breakpoints, BetaQA dashboard layout
  improvements, mastery copy refinement).

**PATH 3 (BROWSER QA + LIVE BETA SHIP): v4.3.1-doc + manual QA**
- Project owner runs cross-browser QA on mobile 320/360/375 + desktop
- Confirm M4 board renders correctly with turn-card pill
- Confirm M4 grading + feedback blocks render at all breakpoints
- Confirm M1/M2/M3 regression
- Ship v4.3.1 to Netlify after green QA gate
- Then decide PATH 1 vs PATH 2

Recommendation: **PATH 3 first (manual QA), then PATH 1 if data is the
bottleneck or PATH 2 if M5 architecture is the project owner's next
focus.**

## 12. Process discipline

Builder-first canonical-source rule preserved (no data files touched).
v4.3.0 / v4.3.0C / v4.3.0D builders byte-identical. v4.3.0B / v4.3.0C /
v4.3.0D migration tools byte-identical. Production auditor byte-identical
(R55-R72 from v4.3.0C1 unchanged; R44b lives in the v4.3.0D polish
auditor).

No Invoke-Expression. No unsafe Remove-Item. ASCII-only PowerShell in
the audit verification scripts.

R72 lesson preserved: the M4 first-time explainer copy was authored
without "wait..." or "actually impossible" prose; the runtime feedback
blocks display the source explanation fields verbatim through the
existing `_pfFixMojibake` safety net.

R44b lesson preserved: the M4 reason_choice answer arrays were verified
to contain reason ids only (0 action ids leaked into bad/acceptable/critical).

The M4 runtime additions never call into M1/M2/M3-specific paths;
they always fall through additive checks (isM4 then isM3 then isM2
then default). This preserves backward compatibility for all existing
modules and keeps the wire scope strictly additive.
