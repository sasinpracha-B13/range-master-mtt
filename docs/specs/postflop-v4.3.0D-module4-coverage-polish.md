# Postflop v4.3.0D -- Module 4 Coverage Polish

**Date:** 2026-05-07
**Predecessor:** v4.3.0C1 (M4 expansion raw content hotfix on top of v4.3.0C 53-scenario data expansion)
**Sprint type:** coverage polish (production data expansion 53 -> 72; no runtime wiring)
**Status:** complete

## 1. v4.3.0C1 baseline (entry condition)

```
HEAD                    = origin/main = c8d6ef7
substantive commit      = 896e0ef (v4.3.0C1 hotfix)
production count        = 438
M4 production count     = 53 (24 baseline + 29 expansion, all approved)
production audit        = 438 / 0 / 0 PASS
M4 expansion audit      = 29 / 0 / 0 PASS
M4 original seed audit  = 24 / 0 / 0 PASS
M3 seed audit           = 24 / 0 / 0 PASS clean
M2 seed audit           = 24 / 0 / 8 PASS
R29 / R71 / R72         = 0 fires across 53 M4 scenarios
appVersion              = 4.3.0C1
SW VERSION              = v4.3.0C1
runtime lock            = M4 NOT in TRAINING_MODES.postflop.actions
```

Manifest verification: 10 / 10 files match SHA256 + blob OID at HEAD c8d6ef7.

## 2. Pre-expansion coverage matrix (53 M4 scenarios)

Counts before v4.3.0D polish:

| Axis | Distribution |
|---|---|
| qtype | action_choice 47 / reason_choice 6 |
| recommendedAction | call 21 / check_raise_small 15 / fold 12 / mixed 3 / check_raise_big 2 |
| actionReason | bluff_catch 10 / value_check_raise 9 / range_disadv 5 / protection 5 / pot_odds 4 / equity_real 4 / board_change 4 / domination 3 / mixed_indiff 3 / slowplay 3 / semi_bluff 2 / blocker 1 |
| heroHandRole | nutted_value 11 / bluff_catcher 9 / give_up 8 / combo_draw 6 / dominated_marg 4 / strong_value 4 / marginal_made 4 / draw 3 / slowplay_trap 3 / blocker_bluff 1 |
| handClass | no_pair_no_draw 11 / mid_pair 6 / set 5 / straight 5 / full_house 3 / overpair 3 / underpair 3 / TPGK 3 / TPTK 3 / gutshot 3 / oesd 2 / flush_draw 2 / flush 1 / nut_flush 1 / combo_draw 1 / nut_flush_draw 1 |
| drawCategory | none 33 / gutshot 5 / nut_flush_draw 5 / oesd 4 / backdoor_only 4 / combo_draw 1 / flush_draw 1 |
| turnCategory | brick 10 / overcard 10 / draw_intensifier 10 / board_pair 9 / flush_complete 7 / straight_complete 7 |
| pairStatusChange | no_change 44 / flop_card_paired 9 |
| difficulty | 3: 29 / 4: 16 / 2: 6 / 5: 2 |
| sourceConfidence | expert_judgment 53 / consensus_gto 0 / solver_aligned 0 |
| critical density | 43 / 53 = 81.1% |
| distinct boards | 16 |

**Identified gaps before polish:**
- `blocker_check_raise_turn` thin at 1.
- `reason_choice` qtype thin at 6 (out of 53; ~11%).
- `mixed_indifference_turn` at 3 (acceptable but could grow).
- `consensus_gto` at 0 (no textbook spots promoted).
- critical density elevated at 81% vs ideal ~70-75%.

## 3. Expansion design plan

**Target: 19 new scenarios (53 -> 72), zero filler.**

Allocation:
| Axis | Polish | Combined target | Status |
|---|---|---|---|
| `blocker_check_raise_turn` | +2 (R1 + R2) | 3 | MET (target +2 to +3) |
| `reason_choice` | +7 (R1..R7) | 13 | MET (target +5 to +7) |
| `mixed_indifference_turn` | +1 (R5 TdTs underpair) | 4 | MET |
| `consensus_gto` | +8 textbook spots | 8 | MET |
| `check_raise_big` | +0 | 2 | MET (brief said "+1 to +2 only if natural") |
| critical density | 9 of 19 with critical | 52 / 72 = 72.2% | MET (target 70-75%) |

10 boards used: 9 existing M4 families + 1 new (F11 = `7s 5d 3h / 4c` low BB-favored straight-complete).

## 4. New scenario count + final production count

```
polish scenarios authored:  19
production count before:   438
production count after:    457
M4 baseline:                53 (24 v4.3.0 + 29 v4.3.0C, with v4.3.0C1 hotfix)
M4 polish:                  19 (v4.3.0D)
M4 total:                   72
```

## 5. Board / turn families

```
F1  Ac 7d 2s 4h    brick           (existing) +1
F2  8d 6c 3s Qh    overcard BB-fav (existing) +1
F3  Kd 8c 4s Ah    A-overcard      (existing) +1
F4  Qs 8s 4d 2s    flush_complete  (existing) +2
F5  9s 8d 4c 7h    straight_compl  (existing) +1
F6  Kd 8s 3c 8h    board_pair K    (existing) +2
F7  Qs 7d 3c 3h    board_pair low  (existing) +1
F8  Ts 8s 4d 7c    draw_intensif   (existing) +3
F9  Ah 9d 4d 7h    multi-FD        (existing) +2
F10 Jd Td 5s 2c    polar brick     (existing) +2
F11 7s 5d 3h 4c    low BB-fav str  (NEW)      +3
```

NEW family F11 strategic dimension: low BB-favored straight-complete turn (4 lands the
bottom-end one-card straight on 7-5-3). BB call range owns the 6-x / 4-x / wheel-suited
combos that make the straight; BTN open range is much narrower in low connectors.
This contrasts with F5 (9-8-4-7 mid-range straight-complete; range advantage less extreme).

## 6. Reason-choice coverage

Before polish: 6 reason_choice scenarios.
After polish:  6 + 7 = 13 reason_choice scenarios (~18% of 72 M4).

Polish reason_choice diagnostic targets (one each):
| ID suffix | Best reason | Diagnostic distinction |
|---|---|---|
| As9c v430D | blocker_check_raise_turn | vs semi_bluff (the seductive wrong answer) |
| As6c v430D | blocker_check_raise_turn | second blocker engine: A-on-Ax-overcard-density |
| AdJc v430D | bluff_catch_turn | vs range_disadvantage (over-fold vs bluff-catch threshold) |
| KsQc v430D | domination_turn_fold | vs range_disadvantage (kicker dominance vs hand-position) |
| TdTs v430D | mixed_indifference_turn | vs bluff_catch / pot_odds (true indifference vs frequency-dependent) |
| TdTc v430D | slowplay_turn_call | vs value_check_raise (preserve bluffs vs charge value) |
| 8h7d v430D | range_disadvantage_turn_fold | vs domination (range-position vs kicker-dominance) |

## 7. blocker_check_raise_turn coverage

Before: 1 scenario (AsJd on Ks 8s 3d 2s, v4.3.0-preA repaired).
After:  3 scenarios.

Polish additions:
- **As9c on Qs 8s 4d 2s** (F4 flush-complete): As blocks every Ax-of-spades nut-flush combo from villain calling range; secondary nut FD redraw (~17%).
- **As6c on Kd 8c 4s Ah** (F3 A-overcard): As removes one ace from villain Ax-density (the dominant value cluster on A-overcard turn) plus AA from 6 combos to 1.

Both are reason_choice (target test: BLOCKER as primary engine, semi_bluff as acceptable but secondary).

## 8. mixed / check_raise_big coverage

`mixed_indifference_turn`: +1 (TdTs underpair on multi-FD turn). Distinct from existing
F1 99 brick / F5 AA polar straight / F10 99 polar brick — different mixed-frequency math
(here the board is multi-FD and hero is UNDERPAIR with backdoor diamond redraw).

`check_raise_big`: +0. No polish scenario uses check_raise_big as best because no v4.3.0D
spot has the polar-sizing structure that justifies it (per brief's "ONLY if natural" rule).
The 2 existing v4.3.0C check_raise_big-best scenarios remain (JT nut straight on 9-8-4-7;
KsKc top boat on Kd 8s 3c 8h).

## 9. critical-flag recalibration

Polish scenarios author critical=[] for 10 of 19 (clean lessons that don't punish close
mistakes); critical=[fold,...] or critical=[call,check_raise_big] for 9 of 19 (severe-punt
scenarios where the wrong action is genuinely a leak).

Combined density:
```
existing 53 with critical:  43
new 19 with critical:        9
combined:                   52 / 72 = 72.2%
```
Hits the target 70-75% range without recalibrating any existing scenario.

Critical assignment rules followed:
- Severe punts (folding TPTK, calling no-pair-no-draw, big-raising weak hands) -> critical=[wrong action]
- Reason_choice scenarios -> critical=[] (diagnostic misses are not severe punts; mirrors
  existing reason_choice convention in v4.3.0/C corpus)
- Genuine mixed spots -> critical=[] (no action is a punt)
- Blocker bluffs (advanced, not punt) -> critical=[]

## 10. sourceConfidence decisions

Before: 0 consensus_gto in M4 (53 of 53 expert_judgment).
After:  8 of 72 = 11.1% consensus_gto.

Promoted to consensus_gto (8):
1. AdKh TPTK + A-blocker bluff-catch on F6 board-paired
2. AhQc TPTK + A-blocker on F7 board-paired-low
3. AsKs TPTK + A-blocker value-raise on F9 multi-FD
4. JhJs top set value-raise on F10 polar brick
5. 6h6d 7-high straight value-raise on F11 (NEW board)
6. AdJc TPGK bluff-catch on F1 brick (reason_choice)
7. KsQc overcards-fold on F8 draw-intensifier (reason_choice)
8. TdTc top-set slowplay on F8 draw-intensifier (reason_choice)

All 8 are textbook-clean spots where the recommended action is widely accepted as
optimal across solver outputs and modern tournament strategy. Remaining 11 polish
scenarios stay at expert_judgment because they involve nuanced trade-offs (mixed
spots, second-best blockers, demoted pairs, etc.) where solver claims would overclaim.

## 11. Anti-filler review

Each new scenario has a uniquenessNote >= 30 chars stating the strategic dimension
distinct from its closest existing M4 cousin. All 19 pass.

Cross-board filler check:
- 7 reason_choice spots span 6 distinct boards (no double-up of same board same qtype).
- 12 action_choice spots span 9 boards with at most 3 per board on F8 and F11.
- F11 (3 polish scenarios on the new board) has strategic spread: made-straight,
  pair+OESD, naked-overcards-fold -- 3 distinct lessons.

No same-board-same-role-same-reason-same-best-action with cosmetic suit swap.
No copied explanation prose with only card names changed.
No fake gutshot / fake blocker claim (R72 + manual review verified).

## 12. Strategic review result

| Verdict | Count |
|---|---|
| PROMOTE | 19 / 19 |
| REVISE  | 0 |
| REJECT  | 0 |

3 audit-driven revisions applied during build:
1. AsQs (Qs board-collision) -> AhQc (clean A-blocker, no board collision)
2. JhJs critical=[fold, check_raise_big] -> [fold] (check_raise_big is acceptable for top set, not bad)
3. As9c drawCategory: backdoor_only -> nut_flush_draw (R71 invariant; hero with As + 4 spades total IS a nut FD even when blocker is the primary strategic engine)

2 production-auditor-driven revisions applied post-Phase-1:
4. TdTc reason_choice answer.bad: removed 'fold' and 'mixed' (those are actions, not reasons)
5. 8h7d reason_choice answer.critical: cleared (actions in critical not allowed for reason_choice)

R44b added to polish auditor (mirrors production auditor R04 strictness on reason_choice
answer integrity) so this class of bug is caught pre-migration in future sprints.

## 13. Audit results

```
production audit:           457 / 0 / 0  PASS
M4 polish seed audit:        19 / 0 / 0  PASS
M4 expansion seed audit:     29 / 0 / 0  PASS  (UNCHANGED)
M4 original seed audit:      24 / 0 / 0  PASS  (UNCHANGED -- planning JSON not touched)
M3 seed audit:               24 / 0 / 0  PASS clean  (UNCHANGED)
M2 seed audit:               24 / 0 / 8  PASS  (UNCHANGED)
R29 card-notation guard:      0 warnings (preserved)
R71 nut_flush_draw guard:     0 fires across 72 M4 scenarios
R72 text-integrity guard:     0 hits across 72 M4 scenarios
```

## 14. Production migration result

Two-phase migration executed via `tools/migrate-module4-v4.3.0D.ps1`:

```
Phase 1 (review_pending):
  source M4 polish:          19
  production before:         438
  production after:          457
  M4 polish auditStatus:     review_pending
  baseline M4 (53) preserved approved: yes
  production audit:          457 / 0 / 0 PASS

Phase 2 (-FlipApproved):
  M4 polish auditStatus:     approved
  baseline M4 (53) preserved approved: yes
  production audit:          457 / 0 / 0 PASS
```

Migration tool preserved 385 non-M4 scenarios byte-identically and 53 baseline M4
scenarios unchanged at auditStatus=approved.

## 15. Runtime-lock confirmation

```
TRAINING_MODES.postflop.actions:
  - m1 (route postflop:m1)
  - m2 (route postflop:m2, BETA)
  - concepts (route postflop:concepts)
  - weakspot (route postflop:weakspot)
  - progress (route postflop:progress)
  - m3 (route postflop:m3, BETA)
  - m4: NOT PRESENT

postflop:m4 route:           not implemented
M4 start function:           none
M4 concept-drill route:      none
M4 weak-spot review:         none
M4 mastery UI:               none
```

Module 4 stays preview-locked. The user surface gains zero new clickable routes from
v4.3.0D. The cache bump (4.3.0C1 -> 4.3.0D) invalidates stored M4 data so a future
runtime-wire sprint sees the polished 72-scenario corpus.

## 16. Version / cache bump

```
appVersion:  '4.3.0C1' -> '4.3.0D'  (index.html line 33226)
SW VERSION:  'v4.3.0C1' -> 'v4.3.0D' (service-worker.js line 1)
```

Data-invalidation only.

## 17. Known limitations

- 72 M4 scenarios still at the lower end of "stable runtime beta" range (target 80-100+).
- `blocker_check_raise_turn` now at 3 (improved from 1) but still thinnest of all 12 actionReasons.
- `reason_choice` ratio 13 / 72 = 18% (improved from 11%) but action_choice still dominates 82%.
- All 11 expert_judgment polish scenarios remain expert; only 8 textbook spots promoted to consensus_gto.
- Critical density 72.2% lands inside target 70-75% but recalibration was achieved purely by polish authoring (no existing scenarios touched). A v4.3.0E pass that recalibrates the v4.3.0C 86% polish-density would be cleaner.
- pairStatusChange enum still mostly `no_change`/`flop_card_paired` (only 2 of the schema's 7 values used in production).
- All 4 sourceConfidence buckets except expert_judgment + consensus_gto remain empty (solver_aligned, theory_consensus, heuristic, mixed_uncertain unused).

## 18. Recommendation

Two paths for the next sprint:

**PATH 1 (DATA-FIRST): v4.3.0E or v4.3.1-data**
- Bring M4 to 80-100 scenarios via 1-2 more polish passes
- Recalibrate v4.3.0C critical density (86% -> 70%) via answer.critical edits only
- Promote 5+ more textbook spots to consensus_gto
- Then v4.3.2 runtime wire as full Beta (vs Limited Beta)

**PATH 2 (RUNTIME-FIRST): v4.3.1 runtime wire as Limited Beta**
- Wire M4 with 72 scenarios as "Limited Beta -- 72 scenarios"
- Scaled mastery thresholds (e.g., 4 sessions / 75% / 9 actionReasons / weak-review used)
- Honest copy: "Module 4 -- Facing Turn Barrel OOP -- Limited Beta"
- Continue data expansion in parallel as v4.3.2/3

Project-owner decision still required.

## 19. Process discipline

- Builder-first canonical-source rule preserved (edit `tools/build-m4-polish-v4.3.0D.ps1`,
  regenerate `docs/specs/postflop-v4.3.0D-module4-polish-seeds.json`, then migrate).
- v4.3.0 builder + 24-baseline JSON byte-identical.
- v4.3.0C builder + 29-expansion JSON byte-identical (the v4.3.0C1 hotfix-corrected
  29-scenario JSON is unchanged in v4.3.0D).
- No Invoke-Expression. No unsafe Remove-Item. ASCII-only PowerShell. UTF-8 NO-BOM.
  Atomic tmp + Move-Item -Force.
- Two-phase staged approval (review_pending then approved) preserved.
- Pre-flight + post-write verification gates in migration tool.
- New auditor rule M4.R44b (reason_choice answer integrity) added so the sprint-time
  bug class (action ids in reason_choice answer arrays) is caught pre-migration in future.
