# v4.6.1 · M4 Full Audit under ARRIVAL LEGITIMACY — Execution Spec (FOR REVIEW · nothing built)

**Status:** SPEC ONLY. spec → owner review → build lint → Batch-1 findings paste → rework paste-gates → Batches 2–3 → final report → migration(s). **Production byte-identical (542, blob `54f134f5…`) until an approved rework migration.**
**Date:** 2026-07-07 · **Basis:** the banked plan (`postflop-module4-arrival-legitimacy-audit-plan.md`: criterion §1, ruled baseline §2, 24/92 pre-verdicted §3). This spec operationalizes it: lint design, batch plan, rework-vs-swap policy, V1 pilot.

## 0. Inputs (all banked, none re-litigated)

- **Criterion:** legs (a) preflop-range membership · (b) every prior continue ≥ acceptable · (c) no missed check-raise node. Correct-arrival-fold = PASS, never flagged.
- **Baseline (ruled):** non-member set **{AA, KK, QQ, AKs, AKo, AQs}**; A2s–A5s = member ("part three-bet"); everything else = member.
- **Pre-verdicted 24/92:** 18 leg-(a) rows (AA 4 · KK 3 · QQ 1 · AKo 6 incl. V1 · AKs 2 · AQs 2) + 6 self-inconsistency pairs (5 REWORK-(c), 1 REWORK-(b)). **The audit re-verifies all 24 mechanically** — the banked list is an expectation the lint must reproduce, not a substitute for running it.

## 1. Lint design — `tools/audit-m4-arrival-v4.6.1.ps1` (per-sprint auditor, R29/R107-precedent: deterministic, reproducible, zero judgment)

Runs over all 92 `pf_turn_barrel_oop_def` rows; emits a per-row verdict table (`docs/specs/postflop-v4.6.1-m4-arrival-lint-results.md`).

1. **`ARR.A` — leg-(a) membership (HARD):** canonicalize `heroHand` → 169-class (sorted ranks + s/o); class ∈ non-member set → `REWORK-(a)`. Emits the class per row so the 18 banked rows must reproduce exactly (count mismatch = lint bug, abort).
2. **`ARR.C1` — self-inconsistency cross-check (HARD, mechanized from the G6 scan):** for each M4 row, find any M3 row with the same hero (sorted) + same flop; if that M3 row's `recommendedAction` ∈ {check_raise_small, check_raise_big} → `REWORK-(c)` (the corpus itself says the flop best was a raise); if `fold` → `REWORK-(b)`. Must reproduce the 6 banked pairs exactly.
3. **`ARR.MAP` — review scaffold:** every row not caught above gets a pre-filled review row (id · hand class · board · flop-line reconstruction) for the manual legs-(b)/(c) pass — the lint prepares the table; it never guesses strategy.

What stays MANUAL (strategic review, implementer-owned, consultant advisory): legs (b)/(c) where no M3 twin exists — flop-continue quality and missed-check-raise judged per hand/board by combo reasoning. **Any verdict that turns on an exact frequency → routed to ledger item (3) (consolidated solver session), listed in the batch table as `SOLVER-ROUTED`, never guessed ad-hoc.**

## 2. Batch plan — 92 rows, 3 batches, chat-paste findings table per batch

| Batch | Rows | Content | Deliverable |
|---|---|---|---|
| **1** | 24 (pre-verdicted) | Lint re-verification (expect exact reproduction) + **rework/swap proposal per row** incl. the **V1 pilot authored in full** | Findings table + V1 paste-gate |
| **2** | 34 (ids sorted, first half of the remaining 68) | Full legs-(b)/(c) strategic review; leg-(a) already PASS by lint | Findings table (PASS / REWORK-(b) / REWORK-(c) / SOLVER-ROUTED + one-line reason each) |
| **3** | 34 (second half) | Same | Same + final summary (verdict counts, rework list, solver-routed list) |

Each batch = one chat paste (same discipline as the seed gates). Owner reviews each before the next proceeds.

## 3. Rework-vs-swap policy (per violation class)

- **REWORK-(a)** (non-member hero): **swap the hero only** — to an in-range hand preserving board, `turnCategory`, `actionReason`, difficulty; prose fully re-derived for the new combos (never search-replace the hand into old prose); suit collisions re-checked. If **no** in-range hero teaches that axis on that board → **SWAP** (replace the scenario; same teaching axis, new board allowed).
- **REWORK-(b)** (should have folded the flop): swap hero to one whose flop continue is ≥ acceptable; if the lesson depended on the illegitimate arrival → SWAP.
- **REWORK-(c)** (missed check-raise): swap hero to one whose flop **best is call** — the M4 node's check-call premise must hold. Never re-author the M4 row at the flop node (that is M3's street); if the axis was intrinsically about the slow-played monster → SWAP with an M3-consistent hero.
- All reworks/swaps go through the **full authoring pipeline**: builder (`tools/build-m4-arrival-reworks-v4.6.1.ps1`) → per-sprint auditor (M4 production-rule mirror + prose lints incl. the artifact patterns) → **chat paste-gate** per batch → migration with **zero-drift verification** on every untouched row (R29/R107-precedent mechanics), per-scenario `version` bump, cache bump. **Pilot-first:** V1 lands alone as the pipeline proof (migration 1), then the remaining reworks batch (migration 2).

## 4. V1 pilot (the first rework of the leg-(a) class)

`…turn_Ac7d2s_4h_m4_action_AcKh_v430C` on **A♣7♦2♠ / 4♥** — AKo = ruled non-member → confirmed rework. **Swap target (owner: ATs/AJs-class or equivalent in-range):** propose **A♥J♥** — AJs is a member; TPGK on the A-high board preserves the row's lesson (marginal made hand facing a polar turn barrel — original `actionReason` retained); hearts avoid the board's Ac/7d/2s/4h with no suit story (4h on board + AhJh = 3 hearts total, no flush possible, no draw distortion); the J-kicker keeps the bluff-catch genuinely marginal (AK's kicker made the old row too strong for its own lesson — the swap *improves* the teaching). Full prose re-derivation + paste-gate before migration.

## 5. Invariants & gates

Production byte-identical until each approved migration · validator 542/0/0 through the audit; post-rework re-verify at 542 (hero swaps change no counts; SWAPs replace 1-for-1) · lints deterministic + reproduce the banked 24 exactly before any manual work starts · no frequencies authored anywhere; SOLVER-ROUTED list goes to item (3) · state docs record batch progress · standard 2-commit + snapshot per shipped migration.

## 6. Knobs for owner ruling

(a) V1 swap target **AhJh** (vs ATs variant) · (b) batch sizes 24/34/34 as proposed (vs 2 batches) · (c) SWAP scenarios allowed to change boards (proposed: yes, only when no in-range hero teaches the axis on the original board) · (d) whether Batch-1 rework proposals for the non-pilot 17 leg-(a) rows are authored immediately after V1 clears, or per-batch later.

**STOP: awaiting owner review of this execution spec (esp. §4 pilot target + §2 batch shape). Nothing built; lint tool authored only after approval.**
