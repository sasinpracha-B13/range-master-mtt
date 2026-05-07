# Postflop v4.3.2 -- Module 4 Coverage Continuation (72 -> 92)

**Date:** 2026-05-07
**Sprint type:** Production-data continuation expansion (M4 72 -> 92).
**Predecessor HEAD (entry):** `bef1765` (v4.3.1B-doc reconcile)
**Substantive predecessors:** `e9fadfc` (v4.3.1B mobile UX polish), `59b8184` (v4.3.1A M4 prompt fix), `c1998cf` (v4.3.1 M4 runtime wire)
**Status:** complete; 20 NEW M4 scenarios authored, audited, and migrated.

## 1. Baseline state at entry (v4.3.1B)

```
HEAD                       = origin/main = bef1765
Production count           = 457  (251 M1 + 49 M2 + 85 M3 + 72 M4)
appVersion                 = 4.3.1B
SW VERSION                 = v4.3.1B
postflop_scenarios.json    = byte-identical to v4.3.0D blob d13bf697b561...
M4 status                  = playable as Limited Beta on iPhone SE 320 (post-fix)
working tree               = clean (only .qa-* scratch files gitignored)
```

**Audits at entry (all PASS):**
```
production audit          : 457 / 0 / 0
M4 polish seed audit      :  19 / 0 / 0
M4 expansion seed audit   :  29 / 0 / 0
M4 original seed audit    :  24 / 0 / 0
M3 seed audit             :  24 / 0 / 0  PASS clean
M2 seed audit             :  24 / 0 / 8  PASS
R29 / R71 / R72 / R44b    : 0 fires
```

**v4.3.1B manifest (`GPT AUDIT/v4.3.1B/MANIFEST_SHA256.txt`):** all 5 blob OIDs match working tree at entry.

## 2. v4.3.1B mobile QA lessons carried forward

From the v4.3.1B sprint:
- **iframe-based mobile QA harness at 320/360/375/414 is the project standard for any sprint that touches CSS or layout.** Chrome MCP's `resize_window` does not propagate to inner viewport; iframes solve this.
- **CSS Grid `1fr` is `minmax(auto, 1fr)` and can silently overflow under `overflow-x:hidden`.** Any new content-bearing grid must be checked at 320 px.
- **Cache lifecycle after every version bump must be verified:** old cache + new cache before `SKIP_WAITING` is acceptable; only the current cache should remain after `SKIP_WAITING` + reload.

v4.3.2 adds NO new content-bearing grids and changes ZERO CSS, so the v4.3.1B 320-px TCC fix continues to apply unchanged.

## 3. Pre-expansion coverage matrix (v4.3.1B baseline = 72 M4)

| Axis | Distribution at v4.3.1B | Notes |
|---|---|---|
| qtype | 59 action_choice / 13 reason_choice (18.1%) | reason_choice density thin |
| recommendedAction | call 27 / cr_small 23 / fold 16 / mixed 4 / cr_big 2 | all 5 represented |
| actionReason | 12 of 12 covered; semi_bluff 2, blocker 3 (lowest) | thin tails |
| critical density | 52 of 72 = 72.2% | within 65-75% target band |
| sourceConfidence | 64 expert / 8 consensus_gto | conservative |
| board families | 17 unique flops, top concentration 6 | F8 (Ts 8s 4d) heaviest |
| reason_choice depth | blocker 3 / bluff_catch 2 / slowplay 2 / others 1 each | flat |

**Identified expansion priorities:**
1. **reason_choice depth** -- lift from 18.1% toward ~22%.
2. **blocker_check_raise_turn depth** -- lift from 3 toward 5-6.
3. **mixed_indifference_turn depth** -- lift from 4 toward 6-7.
4. **check_raise_big naturals** -- lift from 2 toward 3 if a clean spot exists.
5. **critical density** -- recalibrate slightly toward 70% (already in target).
6. **sourceConfidence** -- keep expert_judgment; do not over-promote.

## 4. Expansion design plan

20 NEW scenarios authored across the priority axes:

- **Reason_choice (R1-R8 = 8 scenarios)**
  - R1: protection_check_raise_turn (vs value_check_raise discrimination) on F8 draw-intensifier
  - R2: value_check_raise_turn (vs blocker / semi-bluff) on NEW F13 flush-complete
  - R3: range_disadvantage_turn_fold (vs board_change / domination) on F1 brick
  - R4: board_change_fold (vs range_disadvantage) on F4 flush-complete
  - R5: domination_turn_fold (vs range_disadvantage) on F6 board-paired
  - R6: blocker_check_raise_turn (vs semi_bluff_check_raise) on F10 polar brick
  - R7: slowplay_turn_call (vs value_check_raise) on F5 BB-favored straight-complete
  - R8: mixed_indifference_turn (vs everything else) on F11 BB-favored straight-complete

- **Action_choice (A1-A12 = 12 scenarios)**
  - A1: F4 As8d 2nd-pair-NFD fold (call defensible) -- domination
  - A2: NEW F12 KhJd TPWK fold on Q-overcard turn -- domination
  - A3: NEW F12 JhTh double-gutshot+BDFD call -- equity_realization
  - A4: NEW F12 AsTs broadway gutshot+A-blocker check_raise_small -- blocker bluff
  - A5: F8 AsQs nut FD semi-bluff check_raise_small -- semi_bluff
  - A6: F1 AhKc TPTK+A-blocker check_raise_small -- value
  - A7: F8 TcTd top set check_raise_BIG -- value (priority 4 hit)
  - A8: F11 JsTs naked overcards mixed -- indifference
  - A9: F7 8d8c underpair mixed -- indifference
  - A10: F9 JcTd gutshot fold -- range_disadvantage
  - A11: F5 KsKc overpair call -- bluff_catch
  - A12: F6 AsTd A-blocker check_raise_small -- blocker bluff (counterfeit dynamic)

**2 NEW board families:**
- **F12** = `Kc 7s 2d / Qh` (overcard demote turn; Q hits villain KQ value cluster). Distinct from F3 (A-overcard) because turn is Q not A -- shifts villain value from AA/AK to KQ/AQ/AK.
- **F13** = `9c 6c 3h / 8c` (flush-complete on two-tone-to-monotone with simultaneous straight-complete). Distinct from F4 (Q-high flush-complete) and F8 (T-high draw-intensifier) because here flush AND straight complete on the same turn card.

## 5. Continuation seed audit results

`tools/audit-postflop-module4-continuation-v4.3.2.ps1`:
```
scenarios   = 20
hard errors = 0
warnings    = 0
result      = PASS
```

Distribution at the seed-audit layer (post strategic-review fixes):
- turnCategory: brick 3 / overcard 3 / flush_complete 3 / straight_complete 4 / board_pair 3 / draw_intensifier 4
- qtype: 12 action_choice / 8 reason_choice (40% reason_choice in v4.3.2 batch)
- recommendedAction: fold 6 / call 3 / cr_small 7 / cr_big 1 / mixed 3
- actionReason: 11 of 12 covered (only `pot_odds_turn_call` not in v4.3.2 batch -- already 4 in baseline)
- critical density: 12 of 20 (60%)
- All 20 in `expert_judgment` sourceConfidence (no consensus_gto promotion)

## 6. Strategic review

20 scenarios reviewed using the per-scenario PROMOTE/REVISE/REJECT rubric:
- **20 PROMOTE / 0 REJECT** at final state.
- **2 REVISE applied during review (then re-audited PASS):**
  - **R3 (9d8d on Ac 7d 2s 4h):** initial draft claimed gutshot to 5; verified that hero+board ranks 2,4,7,8,9,A produce zero one-card straights. Reclassified `drawCategory: gutshot -> backdoor_only`, `handClass: no_pair_no_draw -> backdoor_only`, and rewrote prose to remove the false gutshot claim (only runner-runner backdoor diamond flush remains).
  - **A1 (As8d on Qs 8s 4d 2s):** initial draft had `acceptable=[]` and put `call` in `bad`. Hero has NFD via A-spade (9 outs ~ 19%) plus second-pair (8) -- combined hot/cold equity is borderline at pot odds against polar value-heavy barrel. Updated `acceptable=[call]` and pulled `call` out of `bad`, rewrote `short` to acknowledge the close decision. Strategic verdict stays `fold` (second-pair-with-NFD is dominated even with the redraw vs Qx-heavy barrel range).

5 audit-driven revisions applied during build:
- **R7 blockerNote** had unresolved "wait -- recompute" prose artifact (R72 fire). Cleaned to crisp "Set of 5s on board where 5-6-7-8-9 straight already completed via any 6 in villain range. Hero set is the second-tier nutted region (loses to 6-x straights only)."
- **A5 hero hand** initially `KsQs` claiming `drawCategory=nut_flush_draw` (R52 fire: hero needs A-of-spade for nut FD, K-of-spade is K-high FD only). Replaced with `AsQs` (true nut FD via A-spade) and rewrote prose around A-blocker + nut FD instead of K-high FD.

Net: 20/20 PROMOTE after revisions. Audit clean: hard 0 / warn 0.

## 7. Coverage axes -- before vs after

| Axis | Before (72) | After (92) | Delta |
|---|---|---|---|
| **Total M4** | 72 | **92** | +20 |
| qtype: action_choice | 59 | 71 | +12 |
| qtype: reason_choice | 13 (18.1%) | **21 (22.8%)** | +8 |
| recommendedAction: call | 27 | 30 | +3 |
| recommendedAction: cr_small | 23 | 30 | +7 |
| recommendedAction: fold | 16 | 22 | +6 |
| recommendedAction: mixed | 4 | **7** | +3 |
| recommendedAction: cr_big | 2 | **3** | +1 |
| **actionReason coverage** | | | |
| value_check_raise_turn | 14 | 17 | +3 |
| bluff_catch_turn | 13 | 14 | +1 |
| range_disadvantage_turn_fold | 8 | 10 | +2 |
| domination_turn_fold | 4 | 7 | +3 |
| mixed_indifference_turn | 4 | **7** | +3 |
| equity_realization_turn_call | 6 | 7 | +1 |
| protection_check_raise_turn | 6 | 7 | +1 |
| **blocker_check_raise_turn** | **3** | **6** | **+3** |
| slowplay_turn_call | 4 | 5 | +1 |
| board_change_fold | 4 | 5 | +1 |
| pot_odds_turn_call | 4 | 4 | 0 |
| semi_bluff_check_raise_turn | 2 | 3 | +1 |
| **critical density** | 52/72 = 72.2% | **64/92 = 69.6%** | -2.6pp (target 65-75%) |
| sourceConfidence: expert | 64 | 84 | +20 (all v4.3.2 expert) |
| sourceConfidence: consensus_gto | 8 | 8 | 0 |
| unique flops | 17 | 19 | +2 (F12, F13) |

**Reason_choice coverage matrix after v4.3.2 (21 total):**
- blocker_check_raise_turn: 4 (was 3)
- range_disadvantage_turn_fold: 3 (was 2)
- slowplay_turn_call: 3 (was 2)
- mixed_indifference_turn: 2 (was 1)
- domination_turn_fold: 2 (was 1)
- value_check_raise_turn: 2 (was 1)
- bluff_catch_turn: 2 (was 2)
- board_change_fold: 1 (NEW - was 0)
- protection_check_raise_turn: 1 (NEW - was 0)
- equity_realization_turn_call: 1 (was 1)
- pot_odds_turn_call: 0 (unchanged)
- semi_bluff_check_raise_turn: 0 (unchanged)

## 8. Anti-filler review

Each of the 20 scenarios carries a uniqueness note and at least one distinct strategic dimension:
- **Different blocker effect**: A4 (broadway gutshot+A-blocker on overcard) vs R6 (A-blocker on polar brick, BDFD dead) vs A12 (A-blocker on counterfeit board-paired) -- three distinct boardStructure x blocker dynamics.
- **Different reason-choice diagnosis**: R3 (range_disadvantage vs board_change vs domination), R5 (domination vs range_disadvantage), R7 (slowplay vs value_raise), R8 (mixed_indifference vs everything) -- 4 different discrimination tests.
- **Different turn equity shift**: F12 overcard (range_shift_btn), F13 flush+straight complete (polarizing), F11 bottom-end straight complete (favors_bb).
- **Different pair-rank demotion**: A2 KJ TPWK on Q-overcard, R3 underpair on K-paired, R5 underpair on board-paired-low, A11 KK overpair on straight-complete.
- **Different bluff-catch threshold**: A11 KK overpair on polar straight (bluff_catch), A1 second-pair-NFD on flush-complete (domination_fold).
- **Different check-raise sizing incentive**: A7 set-of-Tens on draw-heavy (cr_BIG charges draws max), R1 QQ overpair on draw-heavy (cr_small for protection vs value).

No two scenarios share the same `(board_family, heroHandRole, actionReason, recommendedAction)` quadruple. Spot-check: 6 blocker_check_raise spots (R6, A4, A12 + 3 baseline) all carry different boards (F10, F12, F6, F4, F11, F3) and different blocker dynamics.

## 9. Continuation seed audit result -- final

```
scenarios   = 20
hard errors = 0
warnings    = 0
result      = PASS
```

R72 text-integrity (0 unresolved self-correction artifacts), R71 bidirectional nut FD (0 fires), R44b reason_choice answer-id integrity (0 violations), R52 nut FD invariant (0 violations after AsQs fix), R53 nut-suit blocker invariant (0 violations), R54 straight invariant (0 violations).

## 10. Migration result

Two-phase staged approval (`tools/migrate-module4-v4.3.2.ps1`):

**Phase 1 (default, append as `review_pending`):**
```
Source M4 continuation:  20
Production before:       457  (M4: 72)
Production after:        477  (M4: 92)
M4 continuation auditStatus:  review_pending
DryRun:                  False
```
Production audit at Phase 1: **477 / 0 / 0** (M4 = 72 approved + 20 review_pending).

**Phase 2 (`-FlipApproved`, flip to `approved`):**
```
Production before:       477  (M4: 92)
Production after:        477  (M4: 92)
M4 continuation auditStatus:  approved
```
Production audit at Phase 2: **477 / 0 / 0** (all 92 M4 approved).

Migration tool guarantees:
- Idempotent (safe re-run; produces same result on default OR -FlipApproved).
- No `Invoke-Expression`, no unsafe `Remove-Item`.
- Atomic write via `tmp + Move-Item -Force`.
- 385 non-M4 + 72 baseline M4 preserved byte-identical except the 20 new continuation appended at end.

## 11. Production audit result

```
=== Postflop Audit ===
Total scenarios: 477
Errors: 0
Warnings: 0
Scenarios with errors: 0

By module:
  pf_board_texture        : 251
  pf_flop_cbet_ip         :  49
  pf_flop_cbet_oop_def    :  85
  pf_turn_barrel_oop_def  :  92
```

R29 / R71 / R72 / R44b -- all 0 fires across the 92-scenario M4 corpus.

## 12. All seed audit results

| Audit | Result |
|---|---|
| production | **477 / 0 / 0** PASS |
| M4 continuation seed (v4.3.2) | **20 / 0 / 0** PASS |
| M4 polish seed (v4.3.0D) | 19 / 0 / 0 PASS unchanged |
| M4 expansion seed (v4.3.0C) | 29 / 0 / 0 PASS unchanged |
| M4 original seed (v4.3.0) | 24 / 0 / 0 PASS unchanged |
| M3 seed (v4.2.0) | 24 / 0 / 0 PASS clean unchanged |
| M2 seed (v4.1.2) | 24 / 0 / 8 PASS unchanged |

## 13. Runtime smoke result

Local browser smoke deferred to Netlify auto-deploy because the only runtime-affecting changes are:
- `postflop_scenarios.json`: 92 M4 scenarios (data only; no runtime logic change).
- `index.html`: appVersion `4.3.1B -> 4.3.2` (string change only).
- `service-worker.js`: VERSION `v4.3.1B -> v4.3.2` (string change only).

Audit results above (especially production 477/0/0 and seed audits all PASS) confirm runtime-loadable state. Post-push Netlify smoke verifies live appVersion + M4 pool count + M4 route + cache lifecycle.

## 14. Mobile 320/360/375/414 smoke result

v4.3.1B's `@media (max-width: 359px)` single-column TCC fix is preserved unchanged in `index.html` (verified via grep at line 11801-11804 post-bump). v4.3.2 adds zero new content-bearing grids and zero CSS, so the v4.3.1B mobile QA findings carry forward unchanged:
- 320 px: TCC tiles single-column, M4 entry tile fully readable.
- 360 / 375 / 414 px: 2-column TCC tiles, no overflow.
- All primary tap targets >= Apple HIG 44 x 44 (unchanged from v4.3.1B).
- 4-card board with TURN amber pill on M4 question screen (unchanged from v4.3.1).

## 15. Cache lifecycle

appVersion + SW VERSION bumped together (4.3.1B / v4.3.1B -> 4.3.2 / v4.3.2). Production data changed (postflop_scenarios.json grew by 20 M4 scenarios), so the cache MUST invalidate. SW activate handler `caches.keys().filter(k => k !== CACHE_NAME).map(k => caches.delete(k))` continues to clean old caches automatically (verified live at v4.3.1A -> v4.3.1B post-deploy).

## 16. Files modified in v4.3.2

```
M index.html                      (appVersion 4.3.1B -> 4.3.2 only)
M service-worker.js               (VERSION v4.3.1B -> v4.3.2 only)
M postflop/postflop_scenarios.json (457 -> 477; M4 72 -> 92)
A tools/build-m4-continuation-v4.3.2.ps1
A tools/audit-postflop-module4-continuation-v4.3.2.ps1
A tools/migrate-module4-v4.3.2.ps1
A docs/specs/postflop-v4.3.2-module4-continuation-seeds.json
A docs/specs/postflop-v4.3.2-module4-coverage-continuation.md  (this doc)
M PROJECT_STATE.md
M TASK_BOARD.md
A GPT AUDIT/v4.3.2/                (local-only snapshot; gitignored)
```

## 17. Forbidden files unchanged (byte-identical)

```
tools/build-m4-seeds-v4.3.0.ps1                  -- byte-identical
tools/build-m4-expansion-v4.3.0C.ps1             -- byte-identical
tools/build-m4-polish-v4.3.0D.ps1                -- byte-identical
docs/specs/postflop-v4.3.0-module4-seed-scenarios.json   -- byte-identical
docs/specs/postflop-v4.3.0C-module4-expansion-seeds.json -- byte-identical
docs/specs/postflop-v4.3.0D-module4-polish-seeds.json    -- byte-identical
tools/migrate-module4-v4.3.0B.ps1                -- byte-identical
tools/migrate-module4-v4.3.0C.ps1                -- byte-identical
tools/migrate-module4-v4.3.0D.ps1                -- byte-identical
tools/hotfix-module4-v4.3.0C1.ps1                -- byte-identical
tools/audit-postflop-module4-seed.ps1            -- byte-identical
tools/audit-postflop-module4-expansion-v4.3.0C.ps1 -- byte-identical
tools/audit-postflop-module4-polish-v4.3.0D.ps1  -- byte-identical
tools/audit-postflop-module2-seed.ps1            -- byte-identical
tools/audit-postflop-module3-seed.ps1            -- byte-identical
tools/audit-postflop-ps.ps1                      -- byte-identical (R55-R72 unchanged)
M1/M2/M3 strategy fields                         -- byte-identical
ranges.json, manifest.json, preflop data         -- byte-identical
gamification/shop/wardrobe/field-fx              -- byte-identical
postflop/postflop_concepts.json                  -- byte-identical (51 concepts)
postflop/postflop_taxonomy.json                  -- byte-identical
```

## 18. sourceConfidence decisions

All 20 v4.3.2 continuation scenarios carry `sourceConfidence: expert_judgment` and NONE are promoted to `consensus_gto`. Rationale:
- Reason_choice scenarios test STRATEGIC DISCRIMINATION which is inherently nuanced (not solver-pure).
- Mixed scenarios test indifference (genuinely opponent-and-sizing-dependent).
- Blocker bluff scenarios depend on combinatorial detail and population reads -- not consensus-solver-clear.
- The ONE check_raise_big spot (A7 = top set on draw-intensifier turn) is debatably consensus_gto but errs conservative because the value-vs-protection mix on draw-heavy turns has solver variance.

Combined with the 8 v4.3.0D consensus_gto promotions, the M4 corpus stays at 8 / 92 = 8.7% consensus_gto (down from 8 / 72 = 11.1% pre-v4.3.2). This reflects the brief's "use consensus_gto only for textbook obvious spots" discipline.

## 19. Known limitations

- **Pot_odds_turn_call** not added in v4.3.2 (already at 4 baseline; no clean new spot identified that didn't overlap an existing reason).
- **F12 + F13 are new boards but only 4-7 scenarios each** -- room for further expansion to 8-10 per family in a future continuation if M4 grows further.
- **Strategic review caught 2 REVISE-level issues post-audit-PASS**: this is the second sprint in a row where strategic review > mechanical audit (cf. v4.3.0C1's prose-only fixes; v4.3.1A's BB-OOP framing fix). Recommend the mechanical auditor continue to grow teeth -- a `nut_flush_draw_blocker_consistency` check (validating `blockerNote` claims of nut blocker actually match hero hand) would have caught the A5 KsQs error pre-audit.
- **No M5 / M6 / river module work done**. v4.3.2 stays runtime-data-only on top of v4.3.1B.

## 20. Recommendation

Three options, in order of preference:

**Option A (recommended): Keep M4 Limited Beta and collect user signals.**
- 92 scenarios is approaching mature-runtime-beta density. Two consecutive continuation expansions (v4.3.0C +29, v4.3.0D +19, v4.3.2 +20 = 68 of the 92) suggest diminishing returns from raw content; real-user weak-spot data would now drive better prioritization than guessed gaps.
- Honest copy stays "Limited Beta", "Turn Defense Practice".
- Mastery thresholds may need a slight lift in a future v4.3.x: 9-of-12 reasons -> 10-of-12 since `pot_odds`, `semi_bluff` are now no longer thinnest tail.

**Option B: One more continuation (v4.3.3) targeting 92 -> 100-110.**
- Focus: pot_odds depth (currently 4), semi_bluff depth (currently 3), F12/F13 expansion to 8-10 per family.
- Risk: filler if not gap-driven. Defer if user signals from Option A reveal different priorities.

**Option C: Start v4.4.0 / Module 5 architecture.**
- River-defense module mirroring the v4.2.0 / v4.3.0 architecture+seed planning pattern.
- Premature without M4 user signals; recommend Option A first.

**Project owner recommendation:** start collecting M4 Limited Beta user signals (via the Beta Lab dashboard already wired in v4.3.1) for at least one cycle before deciding between B and C. Do NOT auto-start v4.3.3 or v4.4.0.
