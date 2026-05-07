# Postflop v4.3.1B -- Real-Device Mobile QA + UX Polish

**Date:** 2026-05-07
**Sprint type:** Real-device mobile QA + minimal CSS polish on top of v4.3.1A
**Predecessor HEAD (entry):** `f11c154` (v4.3.1A-doc2 reconcile)
**Substantive predecessor:** `59b8184` (v4.3.1A: M4 prompt BB-OOP framing fix)
**Status:** complete; one mobile layout bug found and fixed -> v4.3.1B

## 1. Baseline verification

```
HEAD (entry)              = origin/main = f11c154
substantive predecessor   = 59b8184 (v4.3.1A: M4 prompt fix)
production count          = 457
M4 production count       = 72 approved
appVersion (entry)        = 4.3.1A
SW VERSION (entry)        = v4.3.1A
working tree              = clean (only QA-harness scratch files)
```

**Audits at entry (all PASS, byte-identical to v4.3.1A):**
```
production audit:           457 / 0 / 0
M4 polish seed audit:        19 / 0 / 0
M4 expansion seed audit:     29 / 0 / 0
M4 original seed audit:      24 / 0 / 0
M3 seed audit:               24 / 0 / 0  PASS clean
M2 seed audit:               24 / 0 / 8  PASS
R29 / R71 / R72 / R44b      = 0
postflop_scenarios.json blob = d13bf697b561 (unchanged from v4.3.0D)
```

No scenario data, taxonomy, or audit logic changed in v4.3.1B. The only
substantive runtime change is one CSS media query (and the supporting
appVersion + SW VERSION bump because v4.3.1A is already deployed to
Netlify -- a stale CSS cache would mask the fix).

## 2. Local mobile QA setup

Standard local QA stack:
- `.qa-serve.ps1` -- minimal PowerShell HTTP server at
  `http://localhost:8765/`. Same script as v4.3.1A; gitignored via
  `*.ps1` rule. Disables caching + permits SW scope.
- `.qa-harness.html` -- iframe-based mobile QA harness. Each iframe loads
  `http://localhost:8765/index.html` at a fixed CSS pixel width. Iframe
  content uses its own viewport, so CSS media queries (`max-width: 320 /
  360 / 380 / 400 / 480`) fire correctly inside.
- 4 device-class viewports per harness page:
  - 320x720 -- iPhone SE (1st gen) / iPhone 5 / very narrow Android
  - 360x740 -- typical Android mid-range
  - 375x812 -- iPhone X / 11 / 12 / 13 / 14 / 15 base
  - 414x896 -- iPhone Plus / Pro Max
- Browser driven via Claude-in-Chrome MCP toolset.

All 4 iframes per harness page load successfully; 0 console errors;
service worker reports VERSION = `v4.3.1A` at entry; localStorage state
shared across iframes (same origin), so the postflop beta toggle and
progress carry across the per-width tests.

Approach to drilling content programmatically: because top-level `const App`
is lexically scoped (not on `window`), drill state was injected via
`iframe.contentWindow.eval(...)` -- this evaluates in the iframe's global
script scope and reaches the same `App` the runtime functions close over.

## 3. Cache / update QA -- working as designed

QA at entry verified the v4.3.1A deployed cache lifecycle on Netlify:
- Old `range-master-v4.3.1` cache and new `range-master-v4.3.1A` cache
  both present after a stale-tab visit.
- `SKIP_WAITING` postMessage triggers `self.skipWaiting()` correctly.
- After page reload post-activation, the activate handler's
  `caches.keys().filter(k => k !== CACHE_NAME).map(k => caches.delete(k))`
  cleanup leaves only `range-master-v4.3.1A` behind.

**Verdict:** SW cache lifecycle works as designed. No fix needed.

## 4. Module 4 mobile QA -- per width

Drill state was injected to drive each iframe to a representative M4
scenario (`pf_btn_v_bb_srp_100bb_turn_Qs8s4d_2s_m4_action_KsQc_v430D` --
KQ on Q84-2 with TPTK + K-high spade FD redraw, an action_choice
question with rich chip rendering for layout stress-testing).

### 4.1 M4 entry / home (D1)

All 4 widths render the postflop Home / Training Command Center cleanly:
- Postflop Academy panel header readable
- "Module 1 - Board Texture" primary card highlighted (first-time path)
- Curriculum module cards stack with module identity preserved
- M4 entry tile shows `[BETA]` badge, copy
  "Module 4 - Facing Turn Barrel OOP", hint
  "72 turn-defense scenarios . Limited Beta"

**ISSUE FOUND at 320:** see Section 5 below. M3 + M4 entry tiles in the
right column of `.tcc-action-grid` clipped ~36px past the viewport's
right edge. Fixed in v4.3.1B.

### 4.2 M4 question screen (D2)

All 4 widths render the question screen cleanly after the v4.3.1A copy
fix is in place:

- Header: "Module 4 . Facing Turn Barrel OOP - Limited Beta . Q 1/1"
  with red Exit button (44x44+ tap target).
- LEARN MODE banner: "LEARN MODE . EXPLANATIONS ENABLED" amber pill.
- SPOT chips (5-step action history) wrap cleanly:
  - 100BB | BB (hero, OOP)
  - BTN (villain, IP) | SRP
  - BTN open 2.5x . BB call
  - BTN cbet small . BB call
  - BTN barrels turn
- YOUR HAND (BB): K Q with hand-class chip row TOP PAIR TOP KICKER,
  BLUFF CATCHER, FLUSH DRAW, HIGH wraps to 2 rows at 320; 1-2 rows wider.
- BOARD: 4 cards Q 8 4 2 inline at all widths including 320 -- the
  4-card row fits without horizontal overflow.
- TURN amber pill positions cleanly above the 4th card (the 2s) at all
  widths -- no occlusion of rank/suit.
- "Q-high dry board" subtitle "rainbow . disconnected . static" present.
- QUESTION text wraps over 4-5 lines at 320 (readable density).
- Choice-guide pill ("BB facing BTN turn barrel -- what is hero's best
  response OOP?") and disclosure ("What do these choices mean?") render.
- "Need a hint?" toggle (33px; tertiary) renders.
- 5 primary action buttons (Fold / Call / Check-raise small /
  Check-raise big / Mixed / close): 56x271 to 56x366 -- exceed Apple
  HIG 44x44.

**Programmatic horizontal-overflow check on the question screen:**
```
w320: iw=320 dw=303 bw=303 -> ok no element overflows
w360: iw=360 dw=343 bw=343 -> ok
w375: iw=375 dw=358 bw=359 -> ok (sub-pixel)
w414: iw=414 dw=397 bw=398 -> ok
```

### 4.3 M4 answer / feedback (D3)

Clicked Fold (BAD-tier choice) on the KsQc scenario. Feedback renders
cleanly at all 4 widths:

- "BAD . 0.00 pts" red verdict pill
- "Your pick: Fold" + "GTO best: Call" two-line summary
- Yellow headline: "TPTK with K-high spade redraw on flush-complete
  turn -- call (bluff-catch)"
- RECOMMENDED ACTION (BB OOP, TURN): "Call . REASON: BLUFF-CATCH (TURN)"
- TURN LOGIC (M4-prominent): full turn-explanation paragraph wraps cleanly
- HAND LOGIC + SIZING LOGIC + BLOCKER NOTE blocks
- Range / Board Context (collapsed disclosure)
- TAKEAWAY pill (yellow)
- COMMON MISTAKE pill (orange, auto-open on critical -- did not auto-open
  on BAD as expected)
- Concept tags: turn_bluff_catcher, turn_blocker_pressure,
  turn_draw_completion
- Finish -> button: 271-336 x 44 (meets HIG)

**Tap-target measurements:**
```
.postflop-choice-btn (5 buttons):    56x271..366  PASS
.postflop-exit-btn:                  49x44..58x44 PASS (borderline w320)
.postflop-next-btn (Finish):         44x271..336  PASS
.postflop-summary-btn (Drill Weak):  49x271..366  PASS
.postflop-restart-btn (Drill again): 47x271..366  PASS
.postflop-back-btn (Back to Home):   41x271..366  WARN (3px under HIG)
.bottom-nav-item (Home/Drill/...):   53x61        PASS
.pf-teach-hint-row (Need a hint?):   33x271..366  WARN (tertiary)
.pf-rng-toggle (Range/Board):        36x239..333  WARN (tertiary)
```

The two `WARN`s (Back-to-Home, hint disclosure) are tertiary controls
already small in v4.3.1A; not introduced by v4.3.1B and not in scope of
the M4 mobile polish brief. Documented for a future polish sprint.

### 4.4 M4 session complete (D4)

Click Finish -> on the 1-question session triggers the summary screen.
Renders cleanly at all 4 widths:

- Header: "Module 4 . Facing Turn Barrel OOP - Limited Beta . Complete"
- Eyebrow: "MODULE 4 SESSION SUMMARY (LIMITED BETA)" + "Needs review" pill
- "0.0 / 1.0 (0%)" big red score
- Tier chips in 2x2 grid: BEST=0 (green), ACCEPTABLE+=0, BAD=1 (red),
  CRITICAL=0 -- 2x2 fits cleanly even at 320
- REVIEW SIGNALS list (concept tags with weakness)
- RECOMMENDED NEXT MOVE block
- "MODULE 4 . TURN DEFENSE BREAKDOWN (LIMITED BETA)" with HAND ROLE
  COVERAGE + ACTION REASON COVERAGE (TURN)
- Concept mastery -- full breakdown (collapsed)
- 3 buttons: Drill Weak Spots (49 px), Drill again (47 px green primary),
  Back to Home (41 px) -- all stack vertically at all widths

### 4.5 Concept Library + Weak-spot review (D5)

Concept Library renders the full M4 section ("Module 4 -- Turn Defense
OOP (12 . Limited Beta)") at all 4 widths. Each of the 12 concept cards
has bold title + 3-line description + amber "trained in Module N" pill +
full-width "Drill this concept" primary button. Cards stack vertically;
no overflow.

### 4.6 Academy mastery + Beta Lab (D6)

Beta Lab section renders cleanly at all 4 widths with:
- "BETA LAB . NEW TRAINING MODES BEING TESTED" amber pill
- Postflop Academy header + description
- YOUR PROGRESS: 2-column key/value layout (Sessions completed N,
  Latest score X%, Latest quality "Needs review" pill, Weak families)
- RECOMMENDED NEXT STEP block
- CURRICULUM cards (Module 1 ACTIVE green, Module 2/3/4 BETA amber)
- M4 mastery checklist appears (parallel to M3, M2, M1) -- no layout
  break

## 5. ISSUE FOUND: M3 / M4 entry-tile right-edge clip at 320 width

### 5.1 Symptom

On 320 px CSS-width viewports (iPhone SE 1st gen, iPhone 5/5s, very
narrow Android), the right column of the Training Command Center tile
grid clipped roughly 36 px past the iframe's right edge. Visible
consequences:

- "Concept Library" tile -> right edge clipped (`Conce` / `Librar`)
- "Postflop Progress" tile -> right edge clipped
- **"Module 4 . Facing Turn Barrel OOP" tile -> right edge clipped**
  -- title characters (`Modul` / `Facin` / `Barre`), `BETA` badge, and
  the `72 turn-d[efense] scenarios . Limited Beta` subtitle all lost
  their last few px on the right.

The 320 viewport is the worst case. 360 width fits with -3.5 px to
spare; 375 / 414 are clean.

### 5.2 Root cause

`.tcc-action-grid` is declared `display:grid; grid-template-columns: 1fr
1fr` (CSS at line ~11700 of index.html). The default `1fr` track is
`minmax(auto, 1fr)`, where `auto` is the child's min-content width.

A single `.tcc-action` tile's min-content is roughly:
`icon (26) + gap (8) + label-min (~50) + gap (8) + badge (~40) +
padding (24) ~= 156 px`.

At 320 px viewport, the tcc-shell + tcc-panel paddings leave roughly 220
px of horizontal room for the grid. With both columns demanding ~156
min-content, the grid widens to 156 + 8 + 151 = 315 px and the right
column overflows ~36 px past the panel's right edge. The body has
`overflow-x: hidden`, so the overflow is invisible to the user but the
text is silently clipped.

This is a pre-existing layout fragility, not a v4.3.1 regression. It
became user-visible because v4.3.1 added the M4 entry tile (long title +
BETA badge) to the right column at the bottom of the grid -- the same
position where Concept Library / Postflop Progress also clipped, but
those have shorter copy and the visual hit is less obvious.

### 5.3 Fix (the only runtime change in v4.3.1B)

`index.html` -- one new media-query block after the existing
`@media (max-width: 380px)` block (lines 11790-11806):

```css
/* v4.3.1B: at very narrow viewports (iPhone SE 320 width), the 2-column
   Training Command Center tile grid exceeds the panel width because the
   tile min-content (icon + label + BETA badge) is wider than the
   allocated 1fr track. ... Switching to single column at <360 width
   eliminates the clipping while keeping all tile content visible. */
@media (max-width: 359px) {
  .tcc-action-grid { grid-template-columns: 1fr; }
  .tcc-action.is-primary { grid-column: 1; }
}
```

Behaviour:
- `<360` width -> single-column stack of all 7 tiles (Module 1, Module 2,
  Concept Library, Weak Spot Review, Postflop Progress, Module 3,
  Module 4). Each tile is full-width with title + subtitle + BETA badge
  fully readable. Module 4 entry visible end-to-end.
- `>=360` width -> unchanged (2-column grid as before; no regression).
- `>=720` width -> unchanged (3-column grid as before, via the existing
  `@media (min-width: 720px)` block).

### 5.4 Fix verification

After fix + iframe reload:
```
w320: tile.maxRight=261.1 vs iw=320 -> overflow=no  PASS
w360: tile.maxRight=356.5 vs iw=360 -> overflow=no  PASS (unchanged)
w375: tile.maxRight=356.5 vs iw=375 -> overflow=no  PASS (unchanged)
w414: tile.maxRight=372.2 vs iw=414 -> overflow=no  PASS (unchanged)
```

Visual at 320 confirms all 7 tiles render with full readable copy
including "Module 4 . Facing Turn Barrel OOP" + BETA badge + "72 turn-
defense scenarios . Limited Beta" subtitle. No regressions at 360+.

## 6. M1 / M2 / M3 + Preflop regression QA

After the fix, drove each iframe through M1 / M2 / M3 question rendering
with a representative scenario per module:

| Module | Scenario | Render at 320/360/375/414 |
|---|---|---|
| M1 (board texture) | `pf_btn_v_bb_srp_100bb_flop_AhKd5c_rangeadv_001` | clean |
| M2 (flop c-bet IP) | `pf_btn_v_bb_srp_100bb_flop_AhKd5c_action_AsKc` | clean |
| M3 (BB defense OOP) | `pf_btn_v_bb_srp_100bb_flop_As8d3h_m3_action_Th8h_v420` | clean |
| M4 (turn defense OOP) | `pf_btn_v_bb_srp_100bb_turn_Qs8s4d_2s_m4_action_KsQc_v430D` | clean |

- M1 renders 3-card flop (A K 5) without overflow.
- M2 renders HERO HAND + 3-card flop without overflow.
- M3 renders the "About Module 3" expanded explainer with bullet points
  wrapping cleanly + SPOT chips + HERO HAND.
- M4 renders the 4-card flop+turn row with the amber TURN pill on the
  4th card, BB-OOP framing, and full feedback copy.

Preflop regression spots:
- Drill tab: 4 mode cards (Quick / Deep / Weakness / Marginal) +
  STACK DEPTH chips + POSITION chips + ACTION TYPE chips render cleanly
  at all 4 widths.
- Browse tab: 13x13 hand grid, color legend, "Study This Scenario"
  primary button render cleanly at all 4 widths (grid scales to viewport).
- Settings tab: Identity panel + toggles + DAILY GOAL radios + DEFAULT
  DRILL MODE radios render cleanly at all 4 widths.

No preflop / M1 / M2 / M3 regressions introduced by the v4.3.1B CSS fix
(the new media query targets `.tcc-action-grid` only, and only at
`max-width: 359`).

## 7. Programmatic checks summary

| Check | w320 | w360 | w375 | w414 |
|---|---|---|---|---|
| Horizontal overflow on body (postflop screen) | none | none | none (sub-pixel) | none |
| Horizontal overflow on body (home post-fix) | none | none | none | none |
| `.tcc-action` right-edge vs viewport (post-fix) | 261 < 320 | 357 < 360 | 357 < 375 | 372 < 414 |
| Action button minH (`.postflop-choice-btn`) | 56 | 56 | 56 | 56 |
| Finish button minH | 44 | 44 | 44 | 44 |
| Bottom nav button (`.bottom-nav-item`) | 53x61 | 53x61 | 53x61 | 53x61 |

All primary tap targets >= Apple HIG 44 x 44 across all 4 widths.

## 8. Version + cache decision

- `index.html` runtime asset changed (one CSS block). v4.3.1A is already
  deployed to Netlify -- a stale cache would mask the fix. Therefore:
  - `appVersion` 4.3.1A -> 4.3.1B
  - SW VERSION v4.3.1A -> v4.3.1B (CACHE_NAME flips, install->activate
    cleanup deletes the v4.3.1A cache via the existing
    `caches.keys().filter(...)` path).
- No data, taxonomy, audit, or schema change.
- No service-worker logic change beyond the VERSION string.

## 9. Files changed in v4.3.1B

```
M index.html              (CSS media query + appVersion bump)
M service-worker.js       (VERSION bump v4.3.1A -> v4.3.1B)
A docs/specs/postflop-v4.3.1B-real-device-mobile-qa.md  (this doc)
M PROJECT_STATE.md        (state-doc reconcile)
M TASK_BOARD.md           (state-doc reconcile)
A GPT AUDIT/v4.3.1B/...   (per-sprint snapshot)
```

No scenario / taxonomy / concept JSON changed in v4.3.1B.

## 10. Out of scope / explicitly NOT done

- No scenario data changes.
- No strategy field changes.
- No audit-tooling changes.
- No new audit runs (audits are byte-identical to v4.3.1A).
- No M1 / M2 / M3 / M4 content drift.
- No scope creep into v4.3.2 or v4.4.0.

The two tertiary tap-target WARNs (`.pf-teach-hint-row` 33 px,
`.pf-rng-toggle` 36 px, `.postflop-back-btn` 41 px) are documented but
NOT fixed in v4.3.1B. They are not v4.3.1 regressions and not part of
the M4 mobile-polish primary surface; they belong to a future polish
sprint.
