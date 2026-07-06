# v4.5.1 · M6 Strategic Seed Review — 24/24 verified (FOR OWNER REVIEW · nothing committed)

**Date:** 2026-07-05 · **Scope:** implementer-owned combinatorial verification of the 24 v4.5.1 M6 seeds (`postflop-v4.5.1-module6-seeds.json`, built by `tools/build-m6-seeds-v4.5.1.ps1`, audited by `tools/audit-postflop-module6-seed.ps1` → **24/0/0 PASS**). Production untouched.

**Method (every row):** (1) recompute made-hand class on the full 5-card runout; (2) enumerate ALL possible straights/flushes two-card-hand-vs-board and check villain's line plausibly contains/excludes them; (3) verify blocker claims combo-by-combo; (4) verify hero's flop/turn barrels are defensible (the setup line must not be spew); (5) classify verdictBasis by the schema rule — percentage-dependent = rejected to the parked list (3 spots parked).

## Verdicts: 24/24 PROMOTE (0 revise, 0 reject)

| # | Row (hero @ runout) | Best | Key verification points |
|---|---|---|---|
| A1 | K8s @ K-8-3-6-2r | bet_big | No flush (2d max 2). Straights: 45 needs 2-3-4-5-6 — 54 had NO one-card draw on flop (3+45 needs two more) → line-excluded; 75/96 never complete. K8 > K6 (turned 2-pair, 8>6). Beaten only by 33/66/rare-22 lines. |
| A2 | 99 @ A-9-5-Q-2r | bet_big | Set under TP. No straight: JT/KJ max 4-run (no K on board); 43s wheel = real but flop bare-gutter + turn-barrel filtered → discounted, disclosed in prose. 99 blocks 9x two-pairs → calls concentrate in Ax ✓. |
| A3 | AK @ A-K-7-7-3 (reason) | value_bet_thick | AAKK beats every one-pair Ax. Trips = 75s/76s only (7x mostly folds A-K flop); A7s/K7s part check-raise turn. No straight possible (A,K,7,7,3 gaps). |
| A4 | KJ @ Q-9-5-T-3 | **overbet** | PURE NUTS verified: K-Q-J-T-9 top straight; AJ needs board K (absent); no flush; no pair. Hero K+J halves villain KJ chops. **FLAG-1: critical=[check_back]** — see review flags. |
| B1 | AJ @ A-8-5-2-7 | bet_small | River 7s completes 46/96 — but both held 4-out gutters facing flop cbet + turn barrel → heavily filtered (disclosed). No 9 on board → A9 stays dominated (this is why this board). Dominated ladder AT/A9/A6s/A4s/A3s >> promoted A8/A7/A5s/A2s (partially check-raised earlier). |
| B2 | AQ @ A-T-6-3-8 | bet_small | 8s completes 97 (6-7-8-9-T) — 97 = flop gutter, turn-barrel filtered ✓ disclosed. A8s promoted (2-3 combos). AT flopped 2-pair but discount via flop/turn check-raise frequency. AQ > AJ/A9s/A7s + all Tx. |
| B3 | KQ @ Q-7-4-J-2 (reason) | value_bet_thin | 2s brick. T9 busted OESD (river 2) → folds to bets anyway; KT/AT busted gutters. KQ > QT/Q9s/JT/J9s; loses QJ/AQ/sets only. K blocks KQ-chop + KJ float. |
| B4 | AJ @ A-7-4-9-2 (**mixed**, SHARED M5 board #1) | mixed [bs, cb] | Bettor-seat mirror of the M5 8d8c pot-odds row. A9 (A9o defends, turn-9 two pair) = the big promoted block, partially removed by turn check-raise frequency; dominated AT/A8s/A6s/A5s vs promoted A9/A7/A4s/A2s genuinely close. Nudge = J-kicker clears the small-bet callers; bet_big = the one real error ✓. |
| C1 | Ah5s @ K-T-4-7hhh-2 | **overbet** | Turn 7h = hero had NUT FLUSH DRAW (Ah + 3 board hearts) → barrel defensible ✓. Ah deletes ALL AhXh nut flushes from villain (combinatorial certainty). A-high SDV ≈ nil vs pair+flush check-call core (rare Qh/Jh floats disclosed). Polar story consistent. |
| C2 | KJ @ Q-9-4-8-2 | bet_big | 8c completed JT (8-9-T-J-Q) — hero's J halves JT traps (16→12 combos... exact: 4×4=16 unblocked; J block → 3×4=12; disclosed qualitatively); K blocks KQ (stoutest catcher). Hero K-high = zero SDV vs 2-street callers ✓ (KJ gutter=T verified both windows). |
| C3 | QhJs @ K-T-4-7hhh-2 (reason, intra-shared w/ C1) | blocker_bluff | Qh deletes QhXh second-nut flushes. Busted OESD (A/9 outs verified: J-Q + K-T = 4-run) + combo FD on turn → line ✓. Distractor "Q-high sometimes wins" = plausible-wrong (pair-dense range). |
| C4 | 76s no-heart @ 9-8-3hh-K-2 | bet_big | **Unblock lesson**: hero holds NO heart → villain's busted-heart check-folds all remain (fold region max width). 7-high literal zero SDV. OESD flop (5/T outs: 6-7+8-9) + turn gutter-9 hold the line together ✓. Counterintuitive-but-verifiable = diff 5. |
| D1 | 76s @ J-T-3-8-4 | check_back | Turn 8 completed 97 + Q9 (both = flop gutter/OESD peels ✓ live traps); J8/T8 two pairs grew. Hero 7+6 thin villain's own busted 76/65 folds AND the 7c clips part of the 97 turned straights (mixed blocker profile per owner line-review); range stays uncapped either way + zero SDV → give up; temptation bet_big = critical (burn 20). |
| D2 | KTs @ A-Q-7-7-3 | check_back | Royal gutter (J) verified: K-T + A-Q. K/T block KJ/JT/T9 busted broadways = the ONLY foldable region on A-Q-7-7 (Ax never folds river at sane prices). No pair no SDV no FE. |
| D3 | QhJh @ K-9-5-6-6 (reason) | give_up | Turn 6h completed 87 (5-6-7-8-9 ✓) AND gave hero a real FD (4 hearts) → turn barrel ✓; river 6c = villain's card (trips for 76s/86s peels). "Right action wrong reason" distractor included (Q-high-wins = false). NO villain flush possible (2 board hearts) ✓. |
| D4 | KQdd @ T-9-3-A-7 | check_back | River 7d completes 68 (peeled flop gutter ✓ live). Turn A = villain's card (Ax floats → TP, called turn ON PURPOSE). K/Q block QJ/KJ fold region. Royal-gutter (J) + bdfd justified the turn barrel ✓. **Temptation = overbet → stakeBasis 30** (critical). |
| E1 | AJ @ Q-8-3-K-4 | check_back | A-high REAL SDV: beats busted JT/T9 (verified: JT = flop gutter-9, turn 4-run to A/9, river brick ✓ in range). Beats-all-folds/loses-all-calls shape airtight. **FLAG-2: critical=[bet_big]**. |
| E2 | AQ @ K-7-3-Q-7 (SHARED M5 board #2) | check_back | Bettor-seat mirror of M5 KhJc "small = thin value/give-ups" row. River 7 pairs → villain 7x = trips; hero's own Q blocks QJ/QT (the would-be callers-worse) → thin-value market deleted. Temptation = bet_small → stakeBasis 7 (spread includes small temptations). |
| E3 | ATs @ Q-8-3-K-4 (reason, intra-shared w/ E1) | check_back_showdown | Distractor "bet small — 8x calls and we beat it" is FACTUALLY false (8x = pair > ace-high) = M5-style trap. Trap-risk distractor = right action wrong reason. |
| E4 | AT @ Q-7-4-T-2 (**mixed**) | mixed [bs, cb] | No straights (all windows < 3 board ranks in 5-span verified); no flush. Callers-worse T9s/T8s/7x vs callers-better Qx/JJ near-balance. Nudge = hero Td cuts QT 9 -> 6 combos (Qd and Th already on board; arithmetic corrected per owner line-review). bet_big = only error. |
| F1 | 88 top set @ 8-5-2-K-Q | bet_big | K,Q runout BUILT villain's calling range (KJ/KT/QJ/QT/KQ floats→pairs). No straight; no flush; board unpaired; KK/QQ 3-bet preflop ⇒ ZERO combos beat hero. **Owner line-review: check_back upgraded to CRITICAL (CHECK-BACK-NUTS class, R25); role/sdv → nutted_value/nutted. bet_small stays bad = the sizing lesson.** |
| F2 | AQ @ Q-8-3-2-9 (reason) | sizing_merge_small | 9h completes JT (flop gutter peel ✓) + promotes Q9. Distractors include "charge draws" river category-error (M5-style). Small keeps QJ/QT/8x in; polar isolates vs improved region exactly. |
| F3 | AK @ A-J-6-2-7 (**mixed**, size-split) | mixed [bb, bs] | No straights verified (all 2-card completions fail). Two coexisting pools: Ax pays big / Jx pays small. Nudge = K blocks KJ (small-size caller) + A thins AJ two-pair → primary bet_big. Check_back = only losing line. |
| F4 | TT boat @ T-7-2-A-2 (**mixed**, polarity) | mixed [ob, bb] | TTT22 verified above 222AA (trips rank first) and 777-x; beaten ONLY by quad 2s (1 combo; AA three-bets preflop -- qualifier added per line-review). Reclassified strong_value/high per the zero-combos-beaten bound (check_back caps at bad here, R25). Hero TT deletes Tx price-sensitive callers → remaining Ax pays either size → primary overbet, stakeBasis 30. |

## Review flags for the owner (3 judgment calls, all deliberate)

1. **A4 `critical=[check_back]`** (checking the pure nuts at overbet stakes). Precedent tension: v4.4.1B downgraded over-fold/over-call to bad; but this is a pure-EV burn of the entire polar bet with zero risk offset — magnitude ≈ a full critical at stake 30. If you rule it down, it becomes `bad` with no other change.
2. **E1/D-rows `critical=[bet_big]`** (big-bluffing A-high-with-SDV / bluffing into uncapped+blocked-folds ranges). Rationale: active money-burn punts (analogous to M5's raise-bluff criticals), distinct from passive over-folds. Same one-word downgrade available per row if ruled otherwise.
3. **Mixed primary-member sub-rule** (stakeBasis = first acceptable entry): implementer-proposed extension of the PIN, encoded in auditor R14 and spec §10 — needs your explicit approve/adjust.

## Range Reveal prose discipline (day-one) — evidence

Auditor lint R20 (negator within 40 chars before a band phrase): **0 warnings**. R21 (`flush-dense` ban): **0 uses**. Deliberate band-compatible language where true: "polar"/"polarized" in A4/C1/C2/F2/F4 sizing prose; "merge/merged" in B/F2; no accidental negated-band constructions.

## Standing invariants — evidence

- Production `postflop/postflop_scenarios.json` untouched: builder and auditor read/write ONLY `docs/specs/postflop-v4.5.1-module6-seeds.json` (verified by code inspection; hash re-check in the final gate below).
- Seed batch: 24 rows, all `auditStatus: review_pending`, `schemaVersion 1.4.0`, module `pf_river_value_ip` (matches the live FT hook string exactly).
- Owner rulings encoded and machine-enforced: verdictBasis (R10, solver_required hard-blocked), stakeBasis PIN (R11–R14), mixed-whitelist-with-migration (R14/R15), overbet spread (R23 ≥2; actual 4: A4, C1 best · F4 mix-primary · D4 temptation), 24-row count (R01), all-12-reason coverage (R23).
- 2 boards shared with M5 runouts for mirror-seat teaching (B4 ↔ M5 8d8c pot-odds row; E2 ↔ M5 KhJc small-bet row); 2 intra-module shared boards (C1/C3, E1/E3) per M5 practice; 20 unique runouts total.

**STOP: awaiting owner review of the 24 seeds + 3 flags. No commit. Next after approval: v4.5.2 migration sprint (510 → 534, R94+ production rules, FT debut automatic).**
