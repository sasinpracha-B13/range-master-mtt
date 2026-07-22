# Ledger Item (3) — Consolidated Solver Session BRIEF (request document)

**Date:** 2026-07-21 · **Status:** AWAITING OWNER SOLVER RUNS · This document lists every open solver question with its exact run spec and its decision consequence (which rows change on which answer), so the solver time is spent once. Answers return per the format in §5; each becomes `solverRunRef` metadata.

**Shared config (Q1–Q3):** NLH MTT chipEV (no ICM, no rake adjustments), 100BB effective, BTN opens 2.5x, BB defends. Postflop line for the M4 rows: BB check-calls a ~33% flop c-bet, faces a turn barrel (~66–75%). Q4 uses the M6 spot: same preflop/flop, river node after BB checks.

## Q1 — AQo preflop membership (V3's open question · 2 M4 rows ride)

**Run:** BB response vs BTN 2.5x, 100bb. **Report:** AQo strategy split (flat% / 3bet% / fold%), plus the same for AJo and ATo as calibration anchors (both ruled members).
**Decision rule (proposed):** flat ≥ 25% of combos → MEMBER; flat < 25% with 3-bet dominant → NON-MEMBER; owner adjusts thresholds at will.
**Consequence:**
- MEMBER → `…8d6c3s_Qh_m4_action_AhQc_v430C` + `…Qs7d3c_3h_m4_action_AhQc_v430D` STAND (no data change); non-member set stays `{AA,KK,QQ,AKs,AKo,AQs}`; V3 closes.
- NON-MEMBER → both rows become leg-(a) hero-swap reworks (seed strictness, v4.6.1 pipeline); baseline set gains AQo; ARR.A lint EXPECT table updated in the same migration.

## Q2 — No-pair float threshold vs the 33% c-bet (5 M4 rows, 5 flops)

**Runs (5):** BB vs 33% c-bet on each flop; **report the continue% (call+raise) for the exact combo** and its class line:
| # | flop | combo | row |
|---|---|---|---|
| a | Ac 7d 2s (r) | 9d8d | `…Ac7d2s_4h_m4_reason_9d8d_v432` |
| b | Ah 9d 4d (tt) | JcTd | `…Ah9d4d_7h_m4_action_JcTd_v432` |
| c | As 8d 3h (r) | JsTh | `…As8d3h_2c_m4_action_JsTh_v430` |
| d | Ks 8s 3d (tt) | Tc9c | `…Ks8s3d_2s_m4_action_Tc9c_v430` |
| e | Qs 8s 4d (tt) | Tc9c | `…Qs8s4d_2s_m4_reason_Tc9c_v432` |

**Decision rule (proposed):** continue ≥ 40% → arrival ≥ acceptable → row STANDS (PASS confirmed); < 20% → pure fold → leg-(b) rework (same-board member hero swap); 20–40% → owner judgment with the number in hand.
**Consequence:** 0–5 hero-swap reworks; candidates proposed at authoring per the v4.6.1 collision/coherence rules.

## Q3 — V2: A6o flat confirm (1 M5 row)

**Run:** same BB-vs-2.5x node as Q1. **Report:** A6o split (flat/3bet/fold).
**Consequence:** defend-mixed-or-better → `…river_Ac7d4s_2c_m5_reason_Ad6c_v441a` STANDS; pure-fold → M5 hero-swap that RIDES the item-(4) M5 remediation migration (never standalone).

## Q4 — The 3 parked M6 `solver_required` spots (river, BTN in position after BB checks)

| spot | node to run | report |
|---|---|---|
| P1 | KQ (K-kicker TP) on `Kh 7c 2d / 9s / 4h`, bet-vs-check | BTN strategy for KQ (check% / small% / big%) + BB check-call composition (promoted K9 vs dominated KJ/KT ratio) |
| P2 | A-high w/ showdown value on a low draw-light runout (owner picks the exact combo/board at run time per the parking sketch) | bluff-vs-check frequency for the chosen A-high combo |
| P3 | QsJs busted spade on `Ts 6s 2d / 3c / Ad`, overbet-vs-check | BTN strategy for QsJs (check% / overbet%) + how much of BB's check range is A-high floats |

**Decision rule (per G4 schema ruling):** ≥ ~65% single action → enters the corpus as `clear_direction` + `sourceConfidence=consensus_gto` + `solverRunRef` (authored at seed strictness through the RW pipeline); genuinely mixed with stable EV → `mixed_nudge` + whitelist entry per the G4 regime; knife-edge/unstable → stays parked.
**Consequence:** 0–3 new M6 rows (32→ up to 35) in the next data migration.

## §5 — Return format (per question)

`tool + version / config (positions, stack, open size, bet sizes) / node path / output frequencies for the exact combo / an export or screenshot reference name` — the reference becomes `solverRunRef`. Partial returns are fine; every question is independent.

## §6 — Migration packaging

If Q1/Q2 produce zero reworks: no M4 migration needed — Q4's M6 additions (if any) ship alone. Otherwise: one consolidated follow-up migration, or fold everything into the item-(4) remediation migration if timing aligns (owner call at results review).
