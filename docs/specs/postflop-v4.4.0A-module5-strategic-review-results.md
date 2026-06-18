# Postflop v4.4.0A — Module 5 Strategic Seed Review Results

**Status:** Planning-only (review pass; seeds remain `auditStatus=planning_only`).
**Date:** 2026-06-18
**Reviews:** the 24 v4.4.0 M5 seeds in `docs/specs/postflop-v4.4.0-module5-seed-scenarios.json`
**Predecessor:** v4.4.0 (`7845dae`, M5 architecture + seeds)
**Method:** per-scenario strategic review against the river poker-correctness rubric in `postflop-v4.4.0-module5-gpt-review-package.md`.

---

## 1. Verdict summary

| Verdict | Count |
|---|---|
| PROMOTE (as authored) | 22 |
| REVISE -> PROMOTE | 2 |
| REJECT | 0 |
| **Total** | **24** |

All 24 seeds are PROMOTE after 2 builder-first revisions. Re-audit after revisions: **24 / 0 / 0 PASS**. The set is ready for v4.4.1 production migration.

---

## 2. Revisions applied (builder-first, then regenerated + re-audited)

### REVISE 2.2 — `...Js8d5c_Ac_m5_action_AdTh_v440` (AdTh, A-overcard river, pot bet)

- **Issue:** authored as `best=call` (bluff_catch_river). Calling weak-kicker top pair (AT) versus a *pot-sized* bet on an A-high board is genuinely borderline — villain's pot-size betting range on A-high is value-rich (AK/AQ/AJ + sets + two-pair), and AT beats only worse Ax (rarely value-bet at pot) plus busted bluffs. The A-blocker helps but does not make it a clean call.
- **Fix:** `best=call -> best=mixed` (`actionReason: bluff_catch_river -> mixed_indifference_river`; `heroHandRole: bluff_catcher -> marginal_made_hand`). The teaching contrast with 2.1 (clear fold) is preserved and sharpened: the A-blocker turns an auto-fold into a *mix*, not a clean call.
- **Verdict after fix:** PROMOTE.

### REVISE 6.2 — `...Ad8s5c_Kd_m5_action_*_v440` (was AcKh two-pair; now 8c8h set)

- **Issue:** authored with hero AcKh (top two pair on the K river). The made-hand evaluation and the "call don't raise into a polar overbet" lesson were both correct, BUT it relied on BB flatting AKo preflop versus a BTN open, which is frequency-dependent and a reviewer could challenge.
- **Fix:** swapped the hero hand to **8c8h** (a set of eights), which BB unambiguously flats preflop. The lesson is identical and arguably cleaner: a set versus a polar overbet calls rather than raises (raising only folds worse and is called by the over-sets AA/KK). Removed the now-inaccurate "A/K reduce AA/KK" blocker note (88 holds no such blocker) and stated honestly that villain keeps full AA/KK combos but the set still beats the entire Ax-value + bluff portion.
- **Verdict after fix:** PROMOTE.

---

## 3. Per-scenario review table

| ID (suffix) | Board / river | Hero | Line | Verdict |
|---|---|---|---|---|
| R1.1 action KdQh | Ks9d4c / 7s brick | TPTK | call (bluff_catch) | PROMOTE |
| R1.2 action 9c9h | brick | set | check_raise_small (value) | PROMOTE |
| R1.3 action JhTd | brick | air | fold (range_disadv) | PROMOTE |
| R1.4 reason AhKc | brick | TPTK | bluff_catch_river | PROMOTE |
| R2.1 action KcJd | Js8d5c / Ac overcard | pair-J | fold (board_change) | PROMOTE |
| R2.2 action AdTh | overcard | weak TP | **mixed** (was call) | REVISE->PROMOTE |
| R2.3 action JdJh | overcard | set | check_raise_big (value) | PROMOTE |
| R2.4 reason KhQd | overcard | air | range_disadvantage_river_fold | PROMOTE |
| R3.1 action KhJh | Qh9h4c / 7h flush | 2nd-nut flush | call (thin value) | PROMOTE |
| R3.2 action Ah8c | flush | nut-blocker air | check_raise_small (bluff) | PROMOTE |
| R3.3 action QcJs | flush | no-heart TP | fold (board_change) | PROMOTE |
| R3.4 reason Ah9c | flush | 2nd pair + Ah | blocker_bluff_catch_river | PROMOTE |
| R4.1 action JcTd | 9d8c4h / 7h straight | nut straight | check_raise_big (value) | PROMOTE |
| R4.2 action 9h9s | straight | set | call (thin value) | PROMOTE |
| R4.3 action Ad8d | straight | mid pair | fold (board_change) | PROMOTE |
| R4.4 reason 6h5d | straight | low straight | thin_value_call_river | PROMOTE |
| R5.1 action KhJc | Kd7s3c / 7d board-pair, small | top pair | call (MDF) | PROMOTE |
| R5.2 action QcJd | board-pair, small | 2nd pair | call (MDF) | PROMOTE |
| R5.3 action 7h6h | board-pair, small | trips | check_raise_small (value) | PROMOTE |
| R5.4 reason JsTh | board-pair | busted OESD | missed_draw_give_up | PROMOTE |
| R6.1 action AhQc | Ad8s5c / Kd scare, overbet | TP | mixed | PROMOTE |
| R6.2 action 8c8h | scare, overbet | set | **call** (was AcKh two-pair) | REVISE->PROMOTE |
| R6.3 action QdJd | scare, overbet | busted | fold (missed_draw) | PROMOTE |
| R6.4 reason AhJc | scare, overbet | TP + Ah | bluff_catch_river (over-fold trap) | PROMOTE |

---

## 4. Coverage confirmation (post-review)

- **Over-fold trap (must-call):** R1.1, R5.1, R5.2, R6.4 — present.
- **Station trap (must-fold):** R2.1, R3.3, R4.3 — present.
- **River-defining reasons showcased:** `blocker_bluff_catch_river` (R3.4), `mdf_defense_river` (R5.1/R5.2), `missed_draw_give_up` (R5.4/R6.3), `bluff_raise_river` (R3.2), `thin_value_call_river` (R3.1/R4.2/R4.4/R6.2).
- **Sizing spread:** small (R5), medium (R1/R4), large (R2/R3), overbet (R6) — MDF varies across the set.
- **Made-hand correctness:** every straight/flush/set/trips/two-pair claim re-verified on the full 5-card runout (auditor R52/R54 enforce flush/straight; manual review confirmed set/trips rankings vs unblocked villain combos).
- **No draw-equity language** in any river explanation (auditor R56 clean).
- **Critical-flag density:** 11 of 18 action_choice scenarios carry a critical flag (~61% of action seeds), all genuine severe punts (folding sets/straights/flushes/trips, calling busted air, stationing dominated pairs into completed draws). v4.4.1A polish may recalibrate toward the 30-40% band as the corpus grows, mirroring the M4 v4.3.0D recalibration.

---

## 5. Outcome

- 24 / 24 PROMOTE (2 via REVISE).
- Re-audit: 24 / 0 / 0 PASS.
- Production audit unchanged: 477 / 0 / 0 (no production data touched in this review).
- Seeds remain `planning_only` / `v4.4.0_seed_candidate` — the next sprint (v4.4.1) migrates them to production.

**Status: REVIEW COMPLETE · ALL SEEDS PROMOTE · READY FOR v4.4.1 PRODUCTION MIGRATION.**
