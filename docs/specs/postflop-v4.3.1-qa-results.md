# Postflop v4.3.1 -- Live QA + Ship Results (v4.3.1A hotfix)

**Date:** 2026-05-07
**Sprint type:** Live QA + Ship hotfix on top of v4.3.1
**Predecessor:** v4.3.1 substantive `c1998cf` + doc `1f2689d`
**Status:** complete; one bug found and fixed → v4.3.1A

## 1. Baseline verification

```
HEAD (entry)              = origin/main = 1f2689d
substantive predecessor   = c1998cf (v4.3.1: M4 runtime wire)
production count          = 457
M4 production count       = 72 approved
appVersion (entry)        = 4.3.1
SW VERSION (entry)        = v4.3.1
working tree              = clean
```

**Audits at entry (all PASS):**
```
production audit:           457 / 0 / 0
M4 polish seed audit:        19 / 0 / 0
M4 expansion seed audit:     29 / 0 / 0
M4 original seed audit:      24 / 0 / 0
M3 seed audit:               24 / 0 / 0  PASS clean
M2 seed audit:               24 / 0 / 8  PASS
R29 / R71 / R72 / R44b      = 0
```

## 2. Local browser QA setup

A minimal PowerShell HTTP server (`tools-temp/qa-serve.ps1`, kept locally,
not committed) was spun up at `http://localhost:8765/` to enable
service-worker activation and PWA cache QA. Browser was driven via the
Claude-in-Chrome MCP toolset.

Browser environment:
- Chrome (extension-driven)
- Initial viewport 1280x900
- App loaded successfully; 0 console errors
- Service worker loaded VERSION = `v4.3.1`
- `appVersion` 4.3.1 confirmed in `buildBackupPayload`

## 3. M4 entry QA

Verified:
- Postflop tab toggles correctly in TCC.
- Postflop panel shows the 7 actions (m1/m2/concepts/weakspot/progress/m3/m4).
- M4 tile appears with [BETA] badge, copy "Module 4 - Facing Turn Barrel OOP",
  hint "72 turn-defense scenarios . Limited Beta" -- honest copy preserved.
- Click M4 tile -> `runTrainingModeAction` case `'postflop:m4'` fires
  `startPostflopDrill('pf_turn_barrel_oop_def', 12)`.
- Drill state after click: `module='pf_turn_barrel_oop_def'`, `queueLen=12`,
  `allM4=true` (no M1/M2/M3 leakage).

## 4. M4 question screen QA

Spot tags render the 5-step action history:
```
100BB | BB (hero, OOP) | BTN (villain, IP) | SRP |
BTN open 2.5x . BB call | BTN cbet small . BB call | BTN barrels turn
```

Hero hand renders with correct suits: `As` -> A♠, `6c` -> 6♣, `Js` -> J♠, etc.
Hand-class chip row renders: TOP PAIR TOP KICKER, BLUFF CATCHER, FLUSH DRAW, HIGH.

Board renders 4 cards with the **TURN amber pill** on the 4th card:
```
Q♠ 8♠ 4♦ 2♠(TURN)
K♦ 8♣ 4♠ A♥(TURN)
A♠ 8♦ 3♥ 2♣(TURN)
T♠ 8♠ 4♦ 7♣(TURN)
```

First-time explainer renders on Q1 of the user's first M4 session.
Choice guide `<qtype>_m4` renders with M4-specific summary copy.

## 5. Bug found: M4 question prompt used BTN framing (BUG #1)

**Symptom:** M4 question prompt rendered "With J♠ J♥ on T♠ 8♠ 4♦ 7♣ (BTN open
vs BB call, 100BB SRP), what should BTN do most often?" -- but the M4 hero is
BB defending OOP, not BTN.

**Root cause:** `_pfBuildQuestionPrompt` (in index.html ~line 35211) had a
special branch for M3 (`isM3 = scenario.module === 'pf_flop_cbet_oop_def'`)
that produced BB-defending framing, but no parallel branch for M4. M4
scenarios fell through to the M1/M2 BTN-framing default in the
`switch (qtype)` block.

**Severity:** Copy/text bug, not a grading or data bug. The grading +
classifier worked correctly throughout; only the question prompt text was
mis-framed.

**Fix:** Added an `isM4 = scenario.module === 'pf_turn_barrel_oop_def'` branch
that mirrors the M3 branch but uses turn-defense framing:
- action_choice with hero hand: "BB has [hero] on [flop], turn [turn] (BTN
  open 2.5x, BB call, 100BB SRP). After flop check-call, BTN now barrels turn.
  What is BB's best action OOP?"
- reason_choice: prefer the data prompt if substantial; otherwise build the
  default "BB has [hero] on [flop], turn [turn] and chooses to [action]. What
  is the primary reason?"

The M4 branch extracts `flopCards` and `turnCard` from `board.flopCards` /
`board.turnCard` (M4 schema) so flop and turn render separately in the prompt
text -- mirroring the visual turn-card pill on the board card row.

**Fix verification:** Reloaded local server. `_pfBuildQuestionPrompt(s)` for
M4 action_choice now returns "BB has T♥ 8♥ on A♠ 8♦ 3♥, turn 2♣ (BTN open
2.5x, BB call, 100BB SRP). After flop check-call, BTN now barrels turn. What
is BB's best action OOP?" -- correct framing.

Per Section P of the QA brief: "If minor copy/layout bugs: fix in index.html,
rerun focused QA, bump appVersion/SW only if deployed cache needs invalidation,
document clearly." The fix matches that profile (copy bug, not grading/data/
runtime-logic). Bumped appVersion `4.3.1` -> `4.3.1A` and SW VERSION
`v4.3.1` -> `v4.3.1A` because v4.3.1 was already deployed to Netlify.

## 6. M4 grading QA (4 tiers, action_choice + reason_choice)

Programmatic + interactive QA on multiple scenarios:

| Tier | Scenario | User pick | Result | UI banner |
|---|---|---|---|---|
| best | JsTh fold | fold | tier=best, score=1 | "BEST . 1.00 pts" green |
| acceptable | Th8h fold/call | call | tier=acceptable, score=0.5 | "ACCEPTABLE . 0.50 pts" amber |
| bad | JsTh fold | check_raise_small | tier=bad, score=0 | "BAD . 0.00 pts" |
| critical | JsTh fold | check_raise_big | tier=critical, score=0, isCritical=true | "CRITICAL LEAK . 0.00 pts" red |
| reason_bad | As9c blocker_check_raise | value_check_raise_turn | tier=bad, score=0 | "BAD . 0.00 pts" |

All 5 actions on action_choice scenarios classify correctly. reason_choice
answers reference reason ids only (no action-id leakage). M4.R44b lesson
preserved at runtime.

## 7. M4 feedback QA

The 8-block feedback layout renders correctly via
`_pfM4TeachingFeedbackBlocksHtml`:

1. Recommended Action (BB OOP, turn) + reason chip
2. **Turn Logic (PROMINENT, 🎯)** -- M4-defining field
3. Hand Logic
4. Sizing Logic
5. Blocker note (when present)
6. Range / Board Context (collapsed)
7. Takeaway (💡)
8. Common Mistake (⚠️, auto-open on critical)

Concept tag pills render at the bottom (e.g., turn_blocker_pressure,
turn_check_raise_bluff, turn_draw_completion).

No "wait..." prose artifacts found in any rendered explanation field
(R72 lesson preserved at runtime).

## 8. M4 session complete QA

Programmatic 5-question session was injected and `renderPostflopComplete`
called.

Verified:
- Header: "Module 4 . Facing Turn Barrel OOP . Limited Beta . Complete"
- Eyebrow / headline: "Module 4 Session Summary (Limited Beta)"
- Tier counts: 2 Best / 1 Acceptable / 2 Bad / 0 Critical
- Strongest concepts block fires
- Review signals block fires (with correct Turn-prefixed reason names)
- Board family patterns fires
- Recommended next move fires
- "Module 4 . Turn Defense Breakdown (Limited Beta)" section renders with:
  - Weak hand classes
  - Hand role coverage (Dominated Marginal, Bluff Catcher, Slowplay Trap,
    Give Up, Nutted Value)
  - Action reason coverage (turn) (Range Disadvantage Turn Fold, Bluff Catch
    Turn, Slowplay Turn Call, Board Change Fold, Protection Check Raise Turn)
- Concept mastery -- full breakdown (collapsible)
- Drill Weak Spots button
- Drill again button -> `startPostflopDrill('pf_turn_barrel_oop_def', 12)`
- Back to Home button

No M3 labels leak into M4 summary. Module id stored correctly.

## 9. M4 Concept Library QA

`_PF_CONCEPT_LIBRARY` filter shows 12 M4 entries, all `previewOnly=false`,
all drillable. Library summary count: "37 concepts . 10 M1 + 5 M2 + 10 M3
+ 12 M4".

`startPostflopConceptDrill('turn_blocker_pressure')` produced:
- mode: concept
- module: pf_turn_barrel_oop_def
- conceptKey: turn_blocker_pressure
- conceptDisplayName: "Turn Blocker Pressure"
- queueLen: 12 (M4 cap)
- allM4: true
- poolSize: 35 (35 M4 scenarios match this concept)

No M1/M2/M3 leakage.

## 10. M4 Weak-spot review QA

Empty-state path:
- Removed M4 sessions from history.
- `startPostflopWeakSpotReview()` -> toast: "Play Module 4 sessions to
  unlock Turn Defense weak-spot review."
- Drill did NOT start.

Active path:
- Injected 5 fake M4 answers with mixed bad+critical tiers across 5
  distinct M4 reasons.
- `_pfCurrentSessionWeakProfile` returned `mode='weak_spots'`,
  `hardMisses=5`, 5 distinct `targetActionReasons`.
- `startPostflopWeakSpotReview()` started a 12-question M4-only review
  drill.

## 11. M4 Mastery + BetaQA dashboard QA

`_pfM4MasteryStats()` returns 8 fields including `masteryCriteriaMet`.
`_pfM4MasteryProgress` renders 5 items with correct labels:
1. "Complete 4 Module 4 sessions (1 / 4)"
2. "Hit 75%+ quality in 2 M4 sessions (0 / 2)"
3. "See at least 9 of 12 M4 actionReasons (0 / 12 reasons seen)"
4. "Engage with M4 weak-spot review (not yet)"
5. "No critical leaks in latest M4 session (clean)"

Honest copy preserved at the section title:
"🎯 Module 4 Limited Beta progress (display only · 72 scenarios · more scenarios coming)"

`_pfM4BetaQADashboardHtml` returns HTML with:
- "Module 4 Beta QA dashboard (project-owner view)" summary
- 6-metric grid (sessions / answers / latest pct / avg pct / critical / crit rate)
- No `NaN` or `undefined` substrings in dashboard HTML

`_pfM4BetaQACopySnapshotClick` exists and is wired to the snapshot button.

No M3 dashboard data leaks into M4 dashboard.

## 12. M1/M2/M3 regression QA

Pool sizes verified: M1=251, M2=49, M3=85, M4=72.

For each module, fetched the first scenario, normalized `answer.best` via
`_pfNormalizePostflopAnswer`, and confirmed `classifyPostflopAnswer` graded
the best id to `tier=best, score=1`:

| Module | Pool | bestId | Grading |
|---|---:|---|---|
| pf_board_texture (M1) | 251 | preflop_raiser | best (1.0) |
| pf_flop_cbet_ip (M2) | 49 | bet_small | best (1.0) |
| pf_flop_cbet_oop_def (M3) | 85 | call | best (1.0) |
| pf_turn_barrel_oop_def (M4) | 72 | fold | best (1.0) |

`_pfBuildQuestionPrompt` regression: M3 still uses BB-defending framing
("BTN c-bets ~33% pot. What is BB's best action?"); M1/M2 still use BTN
framing ("what should BTN do most often?"). The new M4 branch is additive
and does not affect M1/M2/M3 behavior.

## 13. Mobile QA at 320 / 360 / 375

Browser window resized to 375px column. M4 question + answer screens
render with:
- 5-step spot-tag chip row wraps cleanly across multiple lines
- Hero hand 2-card row stays centered + tappable
- 4-card board row fits with TURN pill not occluding the rank/suit
- All 5 action-choice buttons stack vertically and fill width
- Question prompt readable (no truncation)
- Feedback blocks render readable (Turn Logic / Hand Logic / Sizing /
  Blocker / Range / Takeaway / Common Mistake)
- Concept-tag pills wrap cleanly

Programmatic overflow check at 320px width:
`document.documentElement.scrollWidth === clientWidth` (no horizontal
overflow at the document level). Note: chrome `resize_window` may not
trigger viewport-meta media-query reflow on desktop Chrome -- the column
width measurement is the practical mobile width since the app uses fluid
widths rather than fixed pixel breakpoints. Live device testing on real
mobile hardware is recommended as a follow-up; the layout is structurally
sound based on the desktop column-width simulation.

## 14. Desktop QA

Window 1280x900:
- 0 console errors
- 0 console warnings
- No horizontal overflow
- Layout readable
- All M4 surfaces (entry, question, answer, complete, mastery, BetaQA)
  render without overcrowding
- Turn-card amber pill is intentional-looking and immediately legible

## 15. Netlify deploy

Netlify is configured to auto-deploy from the `main` branch on push.

Live state at https://range-master-mtt.netlify.app/ at QA time:
- appVersion: 4.3.1
- M4 pool: 72
- M4 in TRAINING_MODES: true
- `_pfBuildQuestionPrompt` is M4-aware: **false**
- `_pfBuildQuestionPrompt` for M4 action_choice returns: "With T♥ 8♥ on
  A♠ 8♦ 3♥ 2♣ (BTN open vs BB call, 100BB SRP), what should BTN do most
  often?" -- confirms BUG #1 was deployed live.

Action: push v4.3.1A fix to `main`. Netlify auto-redeploys.

After v4.3.1A deploy verification:
- Live appVersion = 4.3.1A
- Live SW VERSION = v4.3.1A
- Live `_pfBuildQuestionPrompt` for M4 returns the BB-OOP framing
- M4 entry / question / answer / feedback / concept drill / weak-spot /
  mastery / BetaQA all render correctly on live

## 16. Issues found / fixes applied

| # | Issue | Severity | Fix | Verified |
|---|---|---|---|---|
| 1 | M4 question prompt used BTN framing ("what should BTN do most often?") | minor copy bug | added `isM4` branch in `_pfBuildQuestionPrompt` mirroring M3 with turn-defense framing | yes (programmatic + visual) |

No grading bugs. No data bugs. No runtime-logic bugs. No production-data
mismatch. No M1/M2/M3 regressions.

## 17. Final ship verdict

**SHIP** -- v4.3.1A.

Rationale:
- v4.3.1 wiring is correct end-to-end (M4 dispatchers, grading, feedback,
  concept drill, weak-spot review, mastery, BetaQA dashboard, session
  summary all work).
- The one bug found is a copy bug (text framing) not a logic/data bug.
- Fix is minimal (additive `isM4` branch parallel to existing `isM3`
  branch).
- All audits remain 0-error post-fix (no scenario data changed).
- Honest Limited Beta copy preserved throughout ("display only", "more
  scenarios coming", "structured practice not final certification").
- M1/M2/M3 regression clean.

## 18. Known limitations

- Mobile QA was performed at the browser-window-resize level. Live device
  testing on real mobile hardware (320 / 360 / 375 actual viewports with
  iOS / Android) is recommended as a follow-up but does not block ship.
- 72 M4 scenarios is at the lower end of "stable runtime beta" (target
  80-100+); honest "Limited Beta" framing throughout.
- blocker_check_raise_turn ships at 3/72; semi_bluff_check_raise_turn at
  2/72. Mastery threshold 9-of-12 reasons accommodates this; reason
  coverage will be undersampled in early sessions.

## 19. Next sprint recommendation

Two paths, project-owner decision required:

**PATH A (DATA-FIRST): v4.3.2 coverage continuation**
- Bring M4 to 80-100 scenarios (~+10-30 polish authoring).
- Recalibrate v4.3.0C 86% critical density via answer.critical-only edits.
- Promote 3-5 more textbook spots to consensus_gto.
- Author NEW canonical builder `tools/build-m4-coverage-v4.3.2.ps1`.
- Two-phase migration. Production 457 -> 470-490.
- M4 stays runtime-wired (no UI changes); cache bump only.

**PATH B (M5 ARCHITECTURE): v4.4.0 planning sprint**
- Mirror v4.3.0 M4 architecture pattern for M5 (River Strategy):
  schema doc + audit plan + GPT review package + 24 planning seeds +
  canonical builder + seed auditor.
- NO production data, NO runtime wiring, NO appVersion bump.

Recommendation: **PATH A** if learner feedback after the v4.3.1A live
deploy reports the corpus feels too thin; **PATH B** if the project owner
wants to start the M5 planning track in parallel with M4 staying as-is.
