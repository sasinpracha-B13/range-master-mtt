# Ledger Item (3) — Solver Session RESULTS (GTO Wizard Premium, run 2026-07-21)

**Status:** DATA COMPLETE — awaiting owner rulings per the brief's decision rules. **Source:** GTO Wizard web app, solutions library `MTTGeneral_8m`, ChipEV, 100bb symmetric (100.125), 8-max, BTN open **2.5** (library-native — matches the corpus line exactly). Driver: implementer via owner's authenticated session (no credentials handled). Screenshots banked in the session log; node URLs below are exact reproduction paths (`solverRunRef`).

Preflop node (Q1/Q3): `preflop_actions=F-F-F-F-F-R2.5-F` · Flop nodes (Q2): `…-C&board=<flop>&flop_actions=X-R2.1` (exceptions noted).

## Q1 — AQo membership (V3) — ANSWER: NON-MEMBER, decisively

| hand | 3bet (R13.12) | flat | fold |
|---|---|---|---|
| **AQo** | **100** | **0** | 0 |
| AJo (anchor) | 57.4 | 42.6 | 0 |
| ATo (anchor) | 5 | 95 | 0 |

AQo flat = 0% — below any threshold. **Per approved rule: both rows (`8d6c3s_Qh_action_AhQc_v430C`, `Qs7d3c_3h_action_AhQc_v430D`) → leg-(a) hero-swap reworks; baseline non-member set gains AQo → {AA,KK,QQ,AKs,AKo,AQs,AQo}; ARR.A lint EXPECT update rides the migration. V3 CLOSES.** Anchors validate the earlier AJo/ATo member rulings.

## Q2 — No-pair float threshold vs the 33% c-bet — 4 STAND / 1 REWORK

| row | combo @ board | vs size | R / C / F | continue | verdict (rule: ≥40 stand, <20 rework) |
|---|---|---|---|---|---|
| a | 9d8d @ Ac7d2s | 2.1 (32%) | 97.8 / 2.1 / 0.1 | 99.9 | **STAND** + composition flag (raise-dominant; call alone 2.1) |
| b | JcTd @ Ah9d4d | 2.1 | 58 / 41.9 / 0.1 | 99.9 | **STAND** (call alone 41.9 ≥ 40) |
| c | JsTh @ As8d3h | 2.1 | 23.6 / 72.6 / 3.8 | 96.2 | **STAND** (call-dominant) |
| d | Tc9c @ Ks8s3d | 2.1 | 0 / 0.6 / **99.4** | 0.6 | **REWORK** (pure fold — no club backdoor; Td9d continues 99.9) |
| e | Tc9c @ Qs8s4d | 7 (108%; tree has no small size on this texture) | 0 / 71.7 / 28.3 | 71.7 | **STAND by domination** (continue at 108% ⇒ strictly higher at 33%) |

**Systemic finding:** the backdoor-suit split is near-binary everywhere (matching-suit combos continue ~100%, no-backdoor combos fold 70–99%) — the corpus's suit-honesty discipline is solver-validated.
**Disclosure (implementer error found in passing):** my batch-3 #57 note said T9 on Q84 has "no 1-card draw" — WRONG: T9 has a real gutter (Q-J-T-9-8, the Q is on board). The row's arrival is draw-based, stronger than my audit note claimed. No shipped-data impact (the row PASSED anyway); the note is corrected by this record.
**Library constraint (matters for item 4):** MTT General c-bet size is texture-dependent — A/K-high boards carry Bet 2.1 (32% ✓ our line); Q/T-high two-tone + low boards carry Bet 7 (108%) only.

## Q3 — V2: A6o — ANSWER: STANDS

A6o vs 2.5x: 3bet 20.7 / **flat 79.3** / fold 0 → clear defend. `river_Ac7d4s_2c_m5_reason_Ad6c_v441a` STANDS. **V2 CLOSES.**

## Q4 — The 3 parked M6 spots

**P1 · KQ thin value, Kh7c2d/9s/4h.** Two structural facts: (1) KQ **pure-barrels the 9s turn** (absent from the turn check-back range — the K9-promotion worry does not slow it down); (2) in the barrel line (`X-R2.1-C / X-R17.9-C / X`) the river tree is **check-or-jam-167% only** — no thin-value size exists at that SPR, and **KQ checks 94.2–99.8%** (only Kd-combos jam 3.9–5.8%). → The parked "thin value vs check" premise does not print. **Option: promote as clear_direction CHECK_BACK** (river node, ≥94% single action) **or keep parked** — owner call.

**P2 · A-high with SDV, bluff-vs-check.** Representative pick (disclosed — mine): AQo on 9c6d2s/4h/Jd, line cbet7-call / X-X / BB check. **All 12 AQo combos: Check 100 / Bet 0** → clear_direction CHECK (meaningful SDV kills the bluff — the hypothesis resolved exactly). Re-run trivial if the owner prefers a different board/combo.

**P3 · QsJs busted-spade overbet, Ts6s2d/3c/Ad** (line `X-R7-C / X-R21.9-C / X`; river tree = Allin 68.6 ≈ 107% overbet). **The blocker INVERTS the sketch:**
| combo | overbet-jam | check |
|---|---|---|
| **QsJs** (busted FD) | 1.4 | **98.6** |
| QhJh / QdJd / QcJc | **100 / 99.7 / 100** | ~0 |

Holding the spades blocks BB's folded busted-FDs → the bluff dies; the no-spade combos jam pure. **Strongest promotion candidate: a bluff-suit-selection PAIR on one node** (clear_direction both directions, A5/C5/D5-style multi-row lesson).

## PHASE 2 — WL mixed-row sweep (16 rows, run 2026-07-21 per owner protocol: VERIFY/FLAG only)

Node pricing: corpus line = flop 33% (tree 2.1) + turn 50–66% (tree 7.2); library sizes are texture-dependent — where the tree cannot price the line, the row is TREE-MISMATCH (no frequencies reported; a wrong-size mix read would mislead).

| # | row (`pf_btn_v_bb_srp_100bb_` stripped) | claimed mix | solver @ line | verdict |
|---|---|---|---|---|
| 1 | `flop_Jh8h4h_m2_action_KhQd_v412` | bet_small/check | **Bet2.1 68.2 / Check 31.8** (exact 32% node) | **CONFIRMED** ✓ |
| 2 | `turn_Ac7d2s_4h_m4_action_9c9d_v430C` | call/fold | Call **100** / Fold 0 / Raise 0 (exact 2.1+7.2 line) | **FLAGGED — freq-pure call** |
| 3 | `turn_Qs7d3c_3h_m4_action_8d8c_v432` | fold/call | Call **100** / Fold 0 / Raise 0 (exact line) | **FLAGGED — freq-pure call** |
| 4 | `river_Ac7d4s_2c_m6_action_AhJh_v451` | bet_small/check_back | at 75% (only size): **Bet 100 / Check 0** | **FLAGGED — pure bet; small size absent** |
| 5 | `river_Th7d2s_2h_m6_action_TsTc_v451` | overbet/bet_big | at 75% (only size): **Bet 100 / Check 0** | **FLAGGED — pure bet; overbet absent** |
| 6–16 | `JcJh@9847`(flop 108-only) · `9c9d@JT52`(flop 108) · `TdTs@A947`(turn 167) · `JhJd@7534`(turn 25) · `JsTs@7534`(turn 25) · `AdTh@J853A`(flop 108) · `AhJc@A852K`(turn 167) · `KcTd@K954-2`(flop 108) · `Th9h@J9842`(turn 167) · `AhTd@Q74T2`(turn 167) · `AsKs@AJ627`(turn 167) | — | — | **TREE-MISMATCH ×11** (line unpriceable in MTT General library) |

**Interpretive notes for the ruling:** (i) freq-purity does NOT by itself refute an indifference claim — EV gaps can be ~0 while strategy is pure; the two exact-priced M4 flags are candidates for an EV-lens follow-up (2 nodes, minutes) or advisor ruling. WL rows carry shipped game-layer promotion — per protocol nothing auto-reworks. (ii) M6 flags: the mix DIRECTION includes betting (half-consistent); the size claims (small / overbet) are unverifiable in this library. (iii) **Library sizing map (banked for Phase 3 + item 4):** flop 2.1 exists on A72/A83/A85/A94/K72/K83/753/Q73/Q74/AJ6/T72/J98/J84-mono; 108%-only on 984/JT5/Q84/T84/T62/962/J85/K95hh. Turn 7.2 (67%) exists on A72-4h/Q73-3h/A74-9h/T72-Ac; 167%-only on A94-7h/A85-2h/J98-4h/Q74-Th/AJ6-2c/K72-9s; 25%-only on 753-4c. **Phase 3 must pre-filter its sweep to priceable nodes** — scope decision surfaced to owner before it runs.

## EV-LENS FOLLOW-UP (owner rule: <0.15bb stands / 0.15–0.3 advisor / >0.3 rework)

Display: GTO Wizard Strategy+EV mode (`stratab=strategy_ev`), same exact-priced lines (2.1 flop + 7.2 turn), fold EV = 0 baseline.

| row | combo EV(call) | EV(raise) | gap vs fold | outcome |
|---|---|---|---|---|
| `turn_Ac7d2s_4h_m4_action_9c9d_v430C` | **+1.87bb** (family 1.80–1.87) | −1.18 to −1.52 | **1.87** | **MIX CLAIM FAILS → REWORK candidate (item 4)** |
| `turn_Qs7d3c_3h_m4_action_8d8c_v432` | **+2.63bb** (family 2.57–2.64) | −0.24 to −0.68 | **2.63** | **MIX CLAIM FAILS → REWORK candidate (item 4)** |

Both an order of magnitude past the 0.3 threshold: these are clear-value calls, not indifferences. **Game-layer impact (required by ruling):** both rows' WL entries currently promote `call` AND `fold` to best-equivalent Stack/XP credit — a player folding gets full credit against a call worth ~2bb. Rework direction (owner decides at item-4 spec): best=call with fold demoted, WL entries removed/replaced; XP economy touch is the promotion removal (no retroactive XP change — forward-only, consistent with G1 integrity rules).

## PHASE 3 PRE-FILTER (interim report — per protocol, before any sweeping)

Target set = 31 `_v461` + 32 M6 = 63 rows. Applying the banked sizing map + the four M6-line probes:
- **Known priceable now: 3 M4 rows** — V1 `AhJh@A72-4h`, `KhQc@Q73-3h` (R03), `As3s@Q73-3h` (R24) — both boards carry 2.1 flop + 7.2 turn.
- **Known unpriceable: 16 M4 rows** on 984/JT5/Q84/T84/A94/753 lines (flop-108 or turn-167/25 walls).
- **Pending probes: ~9 board-lines** (Kd8s3c-8h ×3 rows, Ks8s3d-2s turn, 8833 ×1, A83-2c turn, QT6-Jc, 986-Kc ×2, T95-6h, F-family 855-2h/Q88-4h/TT4-7h/T72-4h) — ~10 minutes of URL probes to finalize X/Y.
- **M6 river wall:** even fully-priced M6 lines carry a single ~75% river size at these SPRs (both probed lines) vs corpus stakeBasis small/big/overbet → M6 sweep readings will be DIRECTION-ONLY (bet-vs-check) with size-unverifiable annotations, same class as the AhJh/TsTc WL findings.

## P2 SECOND BOARD (owner Q4 ruling item)

AQo on `Kc7s2d/8d/3h` (cbet2.1-call / X-X / BB check): **Check 100 / Bet 0 across all 12 combos** (one 99.9). Two boards, two textures (962-low + K72-dry), same answer → **P2 promotes as clear_direction CHECK** with both solverRunRefs; "A-high with meaningful SDV never bluffs this river" = the authored lesson line.

## Consequences / packaging (per brief §6)

Confirmed reworks: **3 hero swaps** (Q1 ×2 + Q2d ×1) + baseline/lint update + optional M6 promotions (0–3 rows, P3 strongest). Recommendation: fold all of it into the item-(4) unified remediation migration (knob — owner call). Phase 1 of the Premium plan is complete; Phases 2–4 (mixed-row sweep, v461+M6 verdict sweep, harvest) await go.
