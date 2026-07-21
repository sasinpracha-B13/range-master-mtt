# M4 Full Audit under ARRIVAL LEGITIMACY — Audit-Plan Spec (QUEUED · baseline RULED · nothing built)

**Status:** BASELINE RULED (owner, 2026-07-07 — §2 resolved, banked). Audit itself QUEUED behind the G6 Continuous-Hand slice (v4.6.0) by owner intent. Version assigned when the audit sprint starts. **PLANNING-ONLY: production `postflop_scenarios.json` byte-identical (542, blob `54f134f5…`) until any approved rework migration.**
**Date:** 2026-07-07 · **Scope:** post-launch sequence item (2). Audit all 92 M4 (`pf_turn_barrel_oop_def`) scenarios against the owner's ARRIVAL LEGITIMACY criterion. V1 AKo is the pilot rework of the class.

---

## SLOWPLAY-FAMILY TEACHING FRAME (owner-approved curriculum language, gate-2 2026-07-21)

Slowplay is licensed by **absence of danger, not hand strength**. The v4.6.1 family teaches the license spectrum:

1. **Dead-board license with expiry** — nut straight on a four-suit runout (`9s8d4c_7h` JcTd): nothing current beats it; the license expires on board-pairing rivers (a slowplayed set boats past) — the trap is priced one street at a time.
2. **Inversion license** — flopped boat on a draw-live board (`8s5s5d_2h` 8h8d): every draw that arrives improves villain into a second-best hand; draws are income, not threats — the opposite pole of the set rule (sets fast-play precisely because live draws beat them).
3. **Absolute license (recognition)** — quads (`Qh8s8d_4h` 8h8c): zero outs against, villain pair-capped forever; the slowplay is free and the skill is recognizing that freedom (difficulty drops to recognition level, D2).
4. **Bluff-stream license with expiry** — nut trips on a paired board (`TsTc4d_7h` AhTh): the barrel range is air-rich, the beats are countable (six boat combos), the trap prices that trade; the license expires on straight-completing rivers.

Fast-play remains the corpus standard for SETS (live draws beat them); trips/boats slowplay per M3's own class verdicts (trips call-best 3/3, full_house call-best 1/1).

## CAUSAL FINDING — R64 was the systemic cause of the M4 partition defect (owner-recorded, dry-run 2026-07-21)

The validator's legacy clause **"M4 critical choice must also appear in bad" (R64) MANDATED dual-listing** — the 64 overlap rows were *rule-compliant*, not sloppy authoring. The v4.6.1 migration flips R64 to exact-partition semantics (M4 scope). Consequence for the banked corpus diagnostic: **M3 (59 rows) and M5 (12 rows) remediations must flip their sibling rules R34/R84 in the same migration as their data fixes** — a data-only fix would go red against the very rule that caused the defect. M1 (168 rows) follows the dual-listing convention *without* a mandating rule — data-fix only. M2 and M6 were born clean (R108 already guards M6, and extends per module as remediation lands).

---

## 1. The criterion (owner ruling, restated verbatim from PROJECT_STATE §1)

Every hero hand must satisfy all three, per its full line:
- **(a) preflop-range membership** under the locked BB-vs-BTN-2.5x baseline;
- **(b) every prior-street continue is at least acceptable** — the scenario tests only the final node; a hand that should have folded earlier may not appear as a turn puzzle;
- **(c) no missed check-raise node** — if check-raising a prior street is the true best line, the scenario must be authored AT that node, not downstream of it.

Rows failing any leg → flagged **rework/swap**. **NOT a violation:** "arrived correctly, correct turn answer is fold" — that is the MDF lesson, a PASS. The audit must never flag a correct fold.

## 2. LEG-(a) BASELINE — RULED (owner, 2026-07-07; banked and locked)

> **"The locked baseline stands unchanged: QQ+/AK/AQs (plus part of A2s–A5s) three-bet; they are NOT in BB's flat range. AA/KK/QQ/AK appearing as a flatting hero in any M4 row is an Arrival Legitimacy leg-(a) violation (V1 AKo = the known exemplar). No baseline expansion."**

Consequences, mechanically applied when the audit runs:

- **Categorical membership, no frequency threshold needed for the named hands.** The ruling is a SET ruling: **AA, KK, QQ, AKs, AKo, AQs = non-members** of BB's flat range → any M4 row with these as the flatting hero is a **definite leg-(a) violation** (the earlier §2 threshold proposal is superseded for these hands).
- **A2s–A5s:** "part three-bet" → these hands retain flat membership at the remaining frequency; A2s–A5s flatting rows are **members** (legitimate arrivals) unless legs (b)/(c) fail.
- **Everything not named** (JJ and below, AQo, AJ-, KQ, suited connectors, etc.) remains in the flat range → leg (a) PASS; still receives full legs (b)/(c) review.
- **AJo — RULED MEMBER** (owner, batch-1 review): not in the 3-bet set, and it dominates the explicit-member ATo — recorded as the standing interpretation for swap targets (rows 5/7/14/17 proposals stand on it).
- **AQo — DO NOT USE AS A SWAP TARGET**: its membership is **V3's open solver question** (ledger item 3). Until that session rules, AQo is neither confirmed member nor non-member for authoring purposes; batch-1 row 4 re-targeted to KQo accordingly.
- No new range artifact is required: the ruling above IS the leg-(a) reference; the mechanized `M4.ARRIVAL` rule encodes the non-member set `{AA, KK, QQ, AKs, AKo, AQs}` directly, with this section cited as the source of truth.

## 3. Scope from real data (runtime enumeration, 2026-07-07)

92 rows · **45 distinct hero hands**. With the §2 ruling banked, the premium rows resolve to **definite leg-(a) verdicts** (legs b/c still reviewed for every row):

| Hand | rows | leg-(a) verdict under the ruled baseline |
|---|---|---|
| AA | 4 | **VIOLATION** — non-member (QQ+ three-bets) |
| KK | 3 | **VIOLATION** — non-member |
| QQ | 1 | **VIOLATION** — non-member |
| AKo | 6 (incl. **V1** `…Ac7d2s_4h_m4_action_AcKh`) | **VIOLATION** — non-member; V1 = the pilot rework |
| AKs | 2 | **VIOLATION** — non-member |
| AQs | 2 | **VIOLATION** — non-member (named in the ruling) |
| JJ | 3 | PASS — member (below QQ+) |
| AQo | 2 | PASS — member (only AQs named) |
| TT | 5 | PASS — member |
| KQs | 3 | PASS — member |

**Banked result: 18 of 92 rows are definite leg-(a) violations** (AA 4 + KK 3 + QQ 1 + AKo 6 + AKs 2 + AQs 2) → REWORK-(a) when the audit sprint runs. The remaining 74 rows pass leg (a) and get full legs (b)/(c) strategic review. A2s–A5s flatting rows (if any) are members per the ruling's "part three-bet" wording.

**Banked legs-(b)/(c) findings from the G6 chain scan (owner-accepted 2026-07-07; SELF-INCONSISTENCY — the corpus's own M3 verdict contradicts the M4 row's assumed check-call line; zero judgment required):**

| M4 row (assumes flop check-call) | Same hero's M3 row says best = | Leg |
|---|---|---|
| `…turn_As8d3h_2c_m4_reason_8c8h_v430` (set of 8s) | `check_raise_small` (`…flop_As8d3h_m3_action_8c8h_v420`) | (c) missed check-raise |
| `…turn_9d8c6h_Kc_m4_action_9c9s_v430` (set of 9s) | `check_raise_small` (`…flop_9d8c6h_m3_action_9c9s_v423a`) | (c) |
| `…turn_9d8c6h_Kc_m4_reason_Tc7c_v430` | `check_raise_small` (`…flop_9d8c6h_m3_reason_Tc7c_v423a`) | (c) |
| `…turn_Ts9s5d_6h_m4_action_TcTd_v430` (top set) | `check_raise_small` (`…flop_Ts9s5d_m3_action_TcTd_v423b`) | (c) |
| `…turn_Ts9s5d_6h_m4_action_As6s_v430` | `check_raise_small` (`…flop_Ts9s5d_m3_action_As6s_v423b`) | (c) |
| `…turn_QsTs6d_Jc_m4_action_5h4d_v430` | `fold` (`…flop_QsTs6d_m3_action_5h4d_v423a`) | (b) should have folded flop |

These six enter the audit's results report pre-verdicted (REWORK-(c) ×5, REWORK-(b) ×1) alongside the 18 leg-(a) rows — **24 of 92 rows are already decided before the audit sprint begins.**

## 4. Method — per row

- **Leg (a) — MECHANIZED** (new audit rule `M4.ARRIVAL`, R29/R107-precedent deterministic): canonicalize hero's two cards → 169-hand class (e.g. `Ac Kh → AKo`), look up membership in the locked baseline SET. Non-member → `REWORK-(a)`. Runs over all 92 in one pass; reproducible.
- **Leg (b) — STRATEGIC REVIEW** (implementer-owned, consultant advisory): reconstruct the full line (preflop flat → flop check-call vs ~33% c-bet → turn arrival). Is each prior continue **at least acceptable** for this exact hand on this board? A hand that must fold the flop (e.g. a naked overcard with no backdoors vs a range-betting BTN on a BTN-favored flop) cannot legitimately arrive at the turn node. Fail → `REWORK-(b)`.
- **Leg (c) — STRATEGIC REVIEW:** is check-raising a PRIOR street the true best line for this hand? If a hand's flop best play is check-raise (e.g. a strong draw or set that should have raised the flop), authoring it as a passive turn-defense puzzle teaches the wrong node. Fail → `REWORK-(c)` (re-author at the check-raise node or swap).
- **Not-a-violation guard:** if the hand arrived legitimately (legs a/b/c pass) and the authored turn answer is fold, that is a correct MDF fold → **PASS**, never flagged.

## 5. Output

A batch report `docs/specs/postflop-v4.6.0-module4-arrival-audit-results.md`: one row per scenario → `PASS | REWORK-(a) | REWORK-(b) | REWORK-(c) | SWAP` + the failing leg + one-line reason + (for rework) the proposed fix. Summary counts per verdict. Mirrors the M6 strategic-review format. V1 AKo appears as the first worked example.

## 6. Rework / swap pipeline (after the audit results are reviewed)

- **REWORK** = change the hero hand to a legitimate arrival on the SAME board + SAME teaching axis (turnCategory / actionReason preserved), or re-author at the correct node. Data change.
- **SWAP** = replace the whole scenario when no legitimate hand teaches that axis on that board. Data change.
- All reworks land via a migration tool with the **standing gates**: zero-drift on every untouched row (compact-JSON equality, abort-on-drift, R29/R107 precedent), validator re-run, new per-scenario `version`, cache bump. Reworks may batch (one migration) or pilot-first (V1 AKo alone) — a knob.
- **V1 AKo pilot:** `…Ac7d2s_4h_m4_action_AcKh` on `Ac 7d 2s / 4h`. AKo is a ruled non-member → CONFIRMED REWORK: swap hero to a legitimate Ax-suited or medium-pair flat that teaches the same turn node (marginal made hand vs polar barrel), preserving turnCategory + actionReason. Worked in full as the pipeline proof before the batch.

## 7. Invariants & gates

Production data byte-identical until an approved rework migration · leg-(a) baseline is a PLANNING artifact only (never wired into the runtime preflop trainer) · validator stays 542/0/0 through the audit; reworks re-verify N/0/0 at the new count · the ARRIVAL LEGITIMACY criterion + baseline lock recorded in PROJECT_STATE as the standing M4 reference · no runtime/UI change in the audit sprint.

## 8. Deliverable order (when the audit sprint starts)

1. ~~Baseline lock~~ — **DONE** (§2 ruled 2026-07-07; non-member set `{AA, KK, QQ, AKs, AKo, AQs}` banked).
2. Build the `M4.ARRIVAL` mechanized rule encoding the §2 set; run leg (a) over 92 → verdict list (expected: the 18 banked violations reproduce exactly).
3. Legs (b)/(c) strategic review over all 92 (leg-(a) survivors get full b/c; leg-(a) failures still get b/c noted for the rework's benefit).
4. Deliver the results report → owner review of verdicts.
5. V1 AKo pilot rework migration → owner review → then the batch.

## 9. Knobs remaining for owner ruling (baseline knobs RESOLVED by the §2 ruling)

(a) reworks batch-vs-pilot-first (pilot-first proposed) · (b) whether reworked rows keep their board + teaching axis (proposed: yes — swap hero only, preserve turnCategory + actionReason) — all range-membership questions are closed.

**QUEUED: the audit runs after the G6 Continuous-Hand slice (v4.6.0) per owner intent. The §2 ruling is banked and waiting; no further gate blocks the audit's start.**
