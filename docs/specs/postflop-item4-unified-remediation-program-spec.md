# Item (4) — Unified Remediation Program SPEC (FOR OWNER REVIEW · nothing built, nothing committed)

**Date:** 2026-07-21 · **Scope source:** post-v4.6.1 ledger + item-(3) solver outcomes + Phase-2 WL sweep + EV-lens rulings. **Standing rules honored:** batch gates before migrations; retags/rule-flips BEFORE resolvers; apostrophes never ship alone; XP forward-only (G1 integrity); don't commit until owner approves.

## §1 The central argument — packaging into THREE migrations, in this order

**A (v4.6.2) "Solver outcomes" → B (v4.6.3) "M3+M5 normalization" → C (v4.6.4) "M1 normalization + guard".**

Why three, why this order:
1. **A is content, B/C are mechanics.** A's changes (5 reworks, 3 new M6 rows, WL surgery) each need SEED-strictness authoring review — the review is *poker judgment*. B's 71 rows resolve by the proven M4 proxies — the review is *counts + samples*. Mixing them makes one gate review two different things badly.
2. **B before C because the machinery transfers.** M3/M5 carry the same role/sdv metadata the M4 resolver used; their rule flips (R34/R84) are the exact R64 pattern. M1 (168 rows) has different metadata and NO mandating rule — it needs its own resolution-rule DESIGN gate first. Shipping B fast banks 71 rows while C's design cooks.
3. **Risk isolation.** A touches game-layer (WL/XP); B/C never do. A validator-green failure would implicate content; B/C failures implicate mechanics. Separate ships = separate rollbacks.
4. **The apostrophes ride A** (first data-touching migration = satisfies never-ships-alone).

## §2 Migration A (v4.6.2) — full manifest

**A1 · 5 M4 solver-driven reworks** (seed pipeline, RW auditor v3, paste-gates):
| row | class | treatment | proposed hero/direction (finalized at seed gate) |
|---|---|---|---|
| `8d6c3s_Qh_action_AhQc_v430C` | leg-(a) AQo out | hero swap | **KhQd (KQo)** — TP-Q on the Q turn, member, no board-collision |
| `Qs7d3c_3h_action_AhQc_v430D` | leg-(a) AQo out | hero swap | **QhJh (QJs)** — KQo is TAKEN on this board by R03 `KhQc_v461`; QJs = TP-Q distinct class |
| `Ks8s3d_2s_action_Tc9c_v430` | leg-(b) fold-99.4 | hero swap | **Td9d (T9s)** — the suit-binary finding IS the fix: Td9d flop-continues 99.9 (solver), then correctly folds the 2s third-spade turn; lesson byte-preserved, suit-corrected |
| `Ac7d2s_4h_action_9c9d_v430C` | EV-lens fail (+1.87) | **EV-REDERIVE** (hero stays) | best mixed→**call**; fold demoted **bad** (99 not nutted → over-fold, taxonomy); actionReason mixed_indifference→bluff_catch_turn (derived at gate); EV refs annotated |
| `Qs7d3c_3h_action_8d8c_v432` | EV-lens fail (+2.63) | **EV-REDERIVE** | same shape; reason re-derived (bluff_catch/pot_odds at gate) |

Tooling: **RW auditor v3** adds reworkClass `EV-REDERIVE` — hero+board preserved, answer/reason/prose re-derived, actionReason change PERMITTED (and required to be different), WL-withdrawal cross-check (an EV-REDERIVE row must NOT remain in `_PF_MIXED_WHITELIST`).

**A2 · 3 new M6 rows** (M6 seed pipeline M6.R01–R29 + paste-gate; `consensus_gto` + solverRunRef; M6 32→35):
- **P2 row**: BTN river A-high-w/-SDV check-back, `clear_direction` CHECK — authored on `9c6d2s/4h/Jd`, BOTH board refs in metadata (second: `Kc7s2d/8d/3h`).
- **P3 pair** (same node `Ts6s2d/3c/Ad`, opposite verdicts by suit — A5/C5/D5 precedent): row A hero **QsJs** best=check_back (blocker kills the bluff, jam 1.4%); row B hero **QhJh** best=**overbet** (jam 99.7–100; tree 107% maps to the overbet action; stakeBasis=overbet).

**A3 · Baseline + lint**: non-member set → `{AA,KK,QQ,AKs,AKo,AQs,AQo}` in audit-plan §2 (authoritative table) + ARR.A lint EXPECT gains AQo=2 pre-migration / 0 post.

**A4 · WL surgery + annotations** (index.html + row metadata):
- **WITHDRAW 2** entries (`9c9d_v430C`, `8d8c_v432`) — coupled to the EV-REDERIVEs.
- **Annotate**: M2 `KhQd` → sourceConfidence `consensus_gto` + solverRunRef (first solver-verified indifference in the corpus); M6 `AhJh`/`TsTc` → `solverNote` direction-confirmed/size-unverifiable; 11 rows → `solverNote` "unverifiable-at-line (library sizing)". All additive fields; WL block gains dated comments.
- **RISK-NOTE (owner ruling, recorded here + PROJECT_STATE):** EV-lens falsified two authored indifference claims at 10× threshold; the 13 unverifiable WL rows retain PASS-conditional status on combo logic — **no contagion assumption** — but are FIRST IN QUEUE whenever a pricing-capable line becomes available.
- M6 count copy-sweep 32→35 (masteryNote / About box / boss-pool disclosure / progress title — grep-verified per the 72→92 lesson).

**A5 · M3 v423a apostrophe cosmetics** ride here (cosmetic-only list, byte-diff limited to the banked strings).

**A6 · Migration mechanics**: single script (dry-run/apply), start-blob assert (`87df6d9c…`), changed-manifest equality (5 replaced + 3 appended + annotated rows enumerated), zero-drift abort, M6 seed statuses flip approved, cache 4.6.1→4.6.2, validator target 545/0/0 (count 542→**545**), snapshot `GPT AUDIT/v4.6.2/`.
**Gates:** spec (this doc) → authoring paste-gate A1 (5 rework fragments + RW v3 results) → paste-gate A2 (3 M6 rows FULL, seed strictness) → dry-run report → apply+QA → commit approval.

## §3 Migration B (v4.6.3) — M3+M5 partition normalization

- **Pre-checks first (M4 lesson):** nutted-tag precheck extended per module (M3 flop-state evaluator; M5 5-card river evaluator — the 6-card multiset evaluator generalizes) → retag list → owner gate.
- **Resolution:** M3 59 rows / M5 12 rows via the M4 proxies (fold→crit iff nutted_value; call→crit iff sdv none; CR→crit iff catch-role; mixed→bad), module-vocab adjusted (M5 river reasons; M3 flop actions). Deliverable = ARR.P-style report: counts + 10-row samples + 0-flagged-or-listed.
- **Rule flips IN THE SAME COMMIT:** R34 + R84 → exact-partition semantics (the R64 pattern verbatim); **R108 scope extends to M3+M5**; red-by-design window documented (both rules flip red on current data until apply — same as v4.6.1).
- Cache 4.6.2→4.6.3, snapshot. **Gates:** precheck/resolver report paste → dry-run → apply+QA → commit approval. No authored content; no game-layer surface.

## §4 Migration C (v4.6.4) — M1 normalization + guard

- **DESIGN GATE FIRST:** M1 (`pf_board_texture`, 251 rows, 168 overlapped) predates the role/sdv metadata — a resolution-rule proposal (M1-appropriate proxies + expected mechanical coverage + flagged-remainder estimate) goes to the owner BEFORE any resolution runs. If the flagged remainder is large, it batches with paste-gates like the M4 audit.
- Data-fix + **the M1 rule equivalent**: an R108-class exact-partition guard scoped M1 lands with the fix (M1 currently has NO guard — the "convention without a rule" gap closes).
- R108 then guards all six modules. Cache→4.6.4, snapshot, standard gates.

## §5 Solver-support backlog (inside the subscription window; SPEC BEFORE PROBES per ruling)

Targeted probes follow spec need: the A1 hero proposals may want 2–3 verification lookups (KQo@863-Q, QJs@Q73 — cheap, at authoring); the ~9 pending board-line probes and the Phase-3 residue run only if a gate demands numbers; **Phase 4 harvest** (aggregated flop/turn reports + BB check-range composition for the parked M6 chip) scheduled near subscription end. solverRunRef standard: node URL + date + `GTO Wizard MTTGeneral_8m ChipEV 100bb` + screenshot id.

## §6 Open knobs for the owner

1. **Packaging**: approve A→B→C as argued, or merge B into A (my case against: §1.1/§1.3).
2. **A1 hero proposals** (KhQd / QhJh / Td9d) — plan-level approval now, suits/prose at seed gate.
3. **EV-REDERIVE reasons** (bluff_catch_turn both?) — derived + shown at seed gate.
4. **P2 single-row-both-refs** vs two rows (one per board) — I propose single (the lesson is one claim; two rows would dilute the pair-lesson slot budget).
5. **Version numbers** v4.6.2/3/4 as proposed.
6. **M1 design-gate timing**: start drafting during B's QA window, or strictly after B ships.

**STOP — spec review. Nothing built; authoring begins only on your approval of §2's gates.**
