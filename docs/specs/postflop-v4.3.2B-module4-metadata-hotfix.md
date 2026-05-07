# Postflop v4.3.2B -- Module 4 R1 Metadata Consistency Hotfix

**Date:** 2026-05-07
**Sprint type:** Targeted metadata-only hotfix on top of v4.3.2A.
**Predecessor HEAD (entry):** `d074e56` (v4.3.2A-doc reconcile)
**Substantive predecessor:** `e8975dd` (v4.3.2A content hotfix)
**Status:** complete; 1 scenario's board metadata corrected; production count unchanged at 477; M4 count unchanged at 92.

## 1. Baseline state at entry (v4.3.2A)

```
HEAD                       = origin/main = d074e56
Production count           = 477  (251 M1 + 49 M2 + 85 M3 + 92 M4)
M4 status                  = Limited Beta, 92 approved
appVersion                 = 4.3.2A
SW VERSION                 = v4.3.2A
working tree               = clean
```

**Audits at entry (all PASS):**
```
production audit                 : 477 / 0 / 0
M4 continuation seed (v4.3.2)    :  20 / 0 / 0
M4 polish seed (v4.3.0D)         :  19 / 0 / 0
M4 expansion seed (v4.3.0C)      :  29 / 0 / 0
M4 original seed (v4.3.0)        :  24 / 0 / 0
M3 seed                          :  24 / 0 / 0  PASS clean
M2 seed                          :  24 / 0 / 8  PASS
R29 / R71 / R72 / R44b           : 0 fires
M4.R73 / M4.R74 (v4.3.2A)        : 0 fires
```

The v4.3.2A content hotfix corrected R1's strategic verdict and prose
(check_raise_small/protection_check_raise_turn -> call/bluff_catch_turn)
and R1's heroHandRole (strong_value -> bluff_catcher) but **left the
board sub-document with stale metadata** that contradicts the corrected
verdict:

| Field | v4.3.2A state | Inconsistency |
|---|---|---|
| board.turnCategory | draw_intensifier | Hero is now bluff-catcher; bluff-catch only makes sense if straights completed (which they did: 65/96/J9). The metadata still claims this is a draw turn. |
| board.boardChange | draw_added | Same inconsistency: classifying the polar straight-complete texture as merely "draw_added" understates the EV-shifting event. |
| board.equityShift | improves_bb_draws | The 7c card improves villain's barrel range polarity (made straights + bluffs vs hero made-pair-only) more than it improves any BB draw. |
| board.drawCompletion | oesd_added | Strictly false: 65/96/J9 are MADE straights on this turn, not OESDs. |

## 2. Exact scenario ID fixed

```
pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_reason_QcQd_v432
```

ONE scenario only. v4.3.2B is a strict metadata-only hotfix; no other
scenario, file, or runtime surface is touched.

## 3. Stale metadata before (v4.3.2A R1 board)

```
board.turnCategory   = draw_intensifier
board.boardChange    = draw_added
board.equityShift    = improves_bb_draws
board.drawCompletion = oesd_added
```

## 4. Corrected metadata after (v4.3.2B R1 board)

```
board.turnCategory   = straight_complete
board.boardChange    = polarizing
board.equityShift    = polarizes_btn
board.drawCompletion = straight_completed
```

All other R1 fields (recommendedAction, actionReason, heroHandRole,
showdownValue, blockerNote, answer partitions, explanation prose,
conceptTags, question.prompt) preserved byte-identical from v4.3.2A.

## 5. Taxonomy validation

The hotfix brief proposed four corrected metadata values. Two are
exact matches in the auditor's approved enums; two required substitution
to the closest valid value:

| Brief proposed | Approved enum match | Final value | Substitution rationale |
|---|---|---|---|
| `turnCategory: straight_complete` | exact match in `$approvedTurnCategory` | **straight_complete** | -- |
| `boardChange: draw_completed` | NOT in `$approvedBoardChange` | **polarizing** | `$approvedBoardChange` enumerates: brick, range_shift_btn, range_shift_bb, **polarizing**, counterfeit, draw_added, static, dynamic. `polarizing` directly captures the straight-complete polar shift (made straights vs air); `dynamic` is too generic; existing v4.3.0D F11 (low BB-favored straight-complete) uses `polarizing` for the same kind of board change, so this is the precedent-consistent choice. |
| `equityShift: polarizes_range` | NOT in `$approvedEquityShift` | **polarizes_btn** | `$approvedEquityShift` enumerates: neutral, favors_btn, favors_bb, **polarizes_btn**, improves_bb_draws, completes_bb_draws, counterfeits_bb_pairs. `polarizes_btn` describes the directional shift: the BTN barrel range polarizes (made-straight value vs air bluffs). The brief's `polarizes_range` would be range-direction-agnostic; `polarizes_btn` is the closer existing-enum match because the BTN barrel is the role being polarized. |
| `drawCompletion: straight_completed` | exact match in `$approvedDrawCompletion` | **straight_completed** | -- |

Auditor enums NOT modified. Postflop taxonomy / concepts JSON NOT
modified. Substitutions are within the existing enum vocabulary.

## 6. Auditor guard decision

NEW HARD-level rule M4.R75 added to
`tools/audit-postflop-module4-continuation-v4.3.2.ps1`:

### M4.R75 -- T-8-4 / 7 straight-complete metadata guard

> On the specific physical board where flop ranks contain `{T, 8, 4}`
> (any suits) and turn rank is `7`, three two-card hands make completed
> straights:
> - J9 = 7-8-9-T-J (made)
> - 96 = 6-7-8-9-T (made)
> - 65 = 4-5-6-7-8 (made)
>
> Therefore the turn 7 is a straight-complete event for this exact
> board. Any scenario whose strategic verdict frames hero as a
> bluff-catcher (`heroHandRole = 'bluff_catcher'` AND `handClass` in
> {overpair, underpair, top_pair_top_kicker, top_pair_good_kicker,
> top_pair_weak_kicker, mid_pair, bottom_pair, second_pair}) AND has
> `turnCategory = 'draw_intensifier'` (or `drawCompletion = 'oesd_added'`,
> or `boardChange = 'draw_added'`) is internally inconsistent: bluff-
> catch only makes sense relative to made-straight density, which the
> metadata then denies.
>
> HARD-fail the audit on this exact pattern.

**Scope decision rationale.** The guard is HARD because the board
combinatorics on T-8-4-7 are unambiguous (three made straights via
common villain combos). However, the guard is scoped to the specific
bluff-catcher framing -- not broadcast to all scenarios on this physical
board. Two other v4.3.2 scenarios use the same Ts 8s 4d / 7c board:

- **A5 (AsQs nut FD)** -- `heroHandRole = combo_draw`. R75 does NOT fire
  because A5's strategic verdict legitimately treats the turn primarily
  as draw-intensifying (hero has 9-out NFD; the made-straight density
  is acknowledged but the hero's equity story is the draw). Keeping
  `turnCategory = draw_intensifier` for A5 is defensible.
- **A7 (TcTd top set)** -- `heroHandRole = nutted_value`. R75 does NOT
  fire because A7's strategic verdict treats the turn as draw-intensifying
  (set-of-T's check-raise BIG to charge draws). Made-straight density is
  acknowledged but hero set is in the small fraction of made-hand region
  that legitimately raises for value vs draws. Keeping
  `turnCategory = draw_intensifier` for A7 is defensible.

The same physical board can carry different `turnCategory` labels
across scenarios when the strategic-verdict framing emphasizes
different axes -- the auditor permits this and only flags the specific
inconsistency where a bluff-catcher framing meets a draw-intensifier
classification.

After the v4.3.2B fix, M4.R75 fires zero times across the 20-scenario
v4.3.2 continuation corpus.

## 7. Production count unchanged

```
Before: 477  (251 M1 + 49 M2 + 85 M3 + 92 M4)
After:  477  (251 M1 + 49 M2 + 85 M3 + 92 M4)
```

Hotfix tool verified: 91 of 91 non-target M4 byte-identical pre/post;
385 non-M4 untouched; scenario-array order preserved.

## 8. M4 count unchanged

92 approved scenarios. Only one had its `board` sub-document re-synced.

## 9. Audit results

```
production                       : 477 / 0 / 0  PASS
M4 continuation seed (v4.3.2)    :  20 / 0 / 0  PASS  (CR.R03 + R75 clean post-hotfix)
M4 polish (v4.3.0D)              :  19 / 0 / 0  PASS  unchanged
M4 expansion (v4.3.0C)           :  29 / 0 / 0  PASS  unchanged
M4 original seed (v4.3.0)        :  24 / 0 / 0  PASS  unchanged
M3 seed (v4.2.0)                 :  24 / 0 / 0  PASS  clean unchanged
M2 seed (v4.1.2)                 :  24 / 0 / 8  PASS  unchanged
R29 / R71 / R72 / R44b           : 0 fires across 92 M4
M4.R73 / M4.R74 (v4.3.2A)        : 0 fires across 20 v4.3.2 continuation
M4.R75 (v4.3.2B)                 : 0 fires across 20 v4.3.2 continuation
```

## 10. Targeted raw scan result

| Check | Expected | Result |
|---|---|---|
| R1 board.turnCategory != 'draw_intensifier' | true | **PASS** (= 'straight_complete') |
| R1 board.boardChange != 'draw_added' | true | **PASS** (= 'polarizing') |
| R1 board.drawCompletion != 'oesd_added' | true | **PASS** (= 'straight_completed') |
| R1 prose still says call / bluff-catch on a straight-complete turn | true | **PASS** (preserved from v4.3.2A; not re-edited) |
| R1 recommendedAction = 'call' (preserved from v4.3.2A) | true | **PASS** |
| R1 actionReason = 'bluff_catch_turn' (preserved from v4.3.2A) | true | **PASS** |
| R1 heroHandRole = 'bluff_catcher' (preserved from v4.3.2A) | true | **PASS** |

## 11. Runtime smoke

`postflop_scenarios.json` size grew minimally (3,381,491 -> 3,381,496
bytes; +5 bytes net; the 4 string substitutions add 22 chars and remove
17 chars of UTF-8 content). M4 pool count unchanged at 92. M4 route,
drill, weak-spot, and mastery rely on the SAME runtime functions
(no JS edits) -- since data shape is unchanged and only string-typed
metadata field VALUES on 1 scenario changed, runtime behavior is
unchanged.

Local browser smoke deferred to Netlify post-deploy because:
- No JS / CSS / runtime logic touched.
- The 1 hotfixed scenario is still loadable and gradeable; runtime
  uses scenario.recommendedAction / scenario.actionReason for grading
  (both unchanged) and reads `scenario.board.turnCategory` only for
  display-side classification labels (no behavior change).
- Audits all PASS; production data shape verified.

## 12. Version/cache bump

```
appVersion        : 4.3.2A  ->  4.3.2B
SW VERSION        : v4.3.2A ->  v4.3.2B
```

Required because production data (1 scenario's board metadata) changed;
v4.3.2A is already deployed to Netlify; cache invalidation needed so
the deployed PWA picks up the corrected metadata.

v4.3.1B `@media (max-width: 359px)` mobile fix preserved unchanged.

## 13. Recommendation for next sprint

**Pause M4 content authoring. Collect Beta Lab user signals.**

This is the same recommendation as v4.3.2 and v4.3.2A. The strategic-
review-after-mechanical-audit pattern has now caught content/metadata
bugs in 5 consecutive sprints (v4.3.0C1 prose; v4.3.1A render-path
framing; v4.3.1B layout overflow; v4.3.2A two strategic verdicts;
v4.3.2B one metadata leftover). The auditor evolution is working: each
sprint adds targeted rules that prevent the previous class of bug from
recurring.

After at least one Beta Lab user-signal cycle:
- If real users systematically miss specific actionReasons / boards,
  design **v4.3.3 user-signal-driven continuation** targeting weak spots.
- If Beta Lab dashboard reveals a runtime bug, fix as **v4.3.x runtime
  hotfix**.
- If user signals confirm M4 is mature, evaluate **v4.4.0 / Module 5
  (River Defense OOP) architecture** sprint mirroring v4.2.0 / v4.3.0
  planning pattern.

**DO NOT auto-start v4.3.3 or v4.4.0 without user-signal data.**
