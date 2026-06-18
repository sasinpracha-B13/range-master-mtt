# Postflop v4.4.0 — Module 5 GPT / Poker Review Package

**Status:** Planning-only. Review package for the v4.4.0A strategic seed review.
**Date:** 2026-06-18
**Reviews:** `docs/specs/postflop-v4.4.0-module5-seed-scenarios.json` (24 seeds)
**Companion to:** architecture / schema-taxonomy / audit-plan docs.

The mechanical auditor (`tools/audit-postflop-module5-seed.ps1`) already passes 24/0/0. This package drives the HUMAN/GPT strategic review (v4.4.0A) that catches what the auditor cannot: river poker correctness, made-hand mis-evaluation, blocker-claim validity, MDF math, and critical-flag calibration. **Five consecutive M4 sprints proved that mechanical pass != poker-correct — this review is mandatory before any production migration.**

---

## 1. The river is showdown-only — the reviewer's prime directive

Every M5 scenario must be checked against the river's defining constraint: **no more cards come; there is no equity, no outs, no draw realization.** A call is justified ONLY by showdown win-probability (bluff-catch / thin value / MDF). A busted draw is NEVER a call. Any seed whose explanation reasons about "outs," "draw equity," or "realizing equity" is wrong by construction.

---

## 2. Per-scenario review template

For each of the 24 seeds, the reviewer fills:

```
ID:
Board (full 5-card runout):
Hero hand:
handClass / heroHandRole / drawCategory / showdownValue:
villainRiverSizing:
recommendedAction / actionReason:
answer.best / acceptable / bad / critical:

[ ] Made-hand evaluation correct on the full 5-card runout?
    - straight: 5 consecutive ranks verified?
    - flush: 5 of a suit verified? is it the NUT flush or a lower flush?
    - set/trips/two-pair/boat: correctly ranked vs what villain can have?
[ ] Blocker claims valid? (nut-flush blocker = hero holds A of suit; nut-straight blocker = correct card)
[ ] Is villain's river range correctly characterized as polar given the sizing?
[ ] MDF math correct for the stated sizing? (small ~75% / medium ~60% / large ~50% / overbet ~40%)
[ ] Busted draws: fold-or-bluff-raise only (never call)?
[ ] recommendedAction defensible vs the polar range at this sizing?
[ ] actionReason matches the action and the showdown logic?
[ ] critical flags reserved for genuine severe punts?
[ ] No draw-equity language in riverLogic / handLogic?
Verdict: PROMOTE / REVISE / REJECT
Notes:
```

---

## 3. Strategic-quality flags (8 things to challenge)

1. **Mis-ranked made hands.** Does the seed call a hand "the nuts" / "strong value" when a higher made hand is possible on the runout? (e.g., a non-nut flush framed as a value-raise; a low straight framed as the nuts).
2. **Phantom blockers.** Does a blocker claim match the hero's actual cards? (the nut-flush bluff-raise requires the A of the completed suit).
3. **Busted-draw calls.** Any scenario where a missed draw is in `best`/`acceptable` as a call — automatic REJECT.
4. **MDF misuse.** Does a fold violate MDF vs a small bet (over-fold trap)? Does a call ignore that an overbet is value-weighted (station trap)?
5. **Value-raise into polarity.** Does a seed raise a strong-but-non-nut hand into a polar overbet where raising only folds worse and is called by better? (should be a call / thin_value_call_river).
6. **Critical over-flagging.** Are close mixes or thin sizing errors marked critical? (only severe concept punts qualify).
7. **Over-/under-bluff assumptions.** Does the seed assume villain is over-bluffing (exploit) when claiming GTO, or vice versa? Honesty in `sourceConfidence`.
8. **Range-history coherence.** Can BB actually arrive at the river with this hand after check-call-call? Can BTN credibly three-barrel this combo? (e.g., would BB flat AK pre? would BTN barrel this bluff?).

---

## 4. Known seeds flagged for extra scrutiny by the author

The author pre-flags these for the reviewer (self-identified soft spots):

| ID | Concern |
|---|---|
| `...Ad8s5c_Kd_m5_action_AcKh_v440` (6.2) | BB flatting AK preflop vs BTN open is range-dependent; consider AKs or a different two-pair combo. Two-pair-vs-overbet call line is sound regardless. |
| `...Js8d5c_Ac_m5_action_AdTh_v440` (2.2) | AT (weak kicker) calling a pot-size bet on A-high is borderline; marked best=call with mixed acceptable and NO critical. Reviewer should confirm the call vs a tighter fold. |
| `...Qh9h4c_7h_m5_action_KhJh_v440` (3.1) | 2nd-nut flush as a CALL (not raise) vs a large bet — confirm the call-don't-raise line holds vs the assumed flush frequency. |
| `...9d8c4h_7h_m5_action_9h9s_v440` (4.2) | Set demoted to thin-value-call on a 4-straight board — confirm vs villain straight frequency at medium sizing. |
| `...Ad8s5c_Kd_m5_action_AhQc_v440` (6.1) | Top-pair-vs-overbet marked `mixed` — confirm the indifference (A-blocker is the swing factor). |

---

## 5. Aggregate review questions

1. **Coverage:** do the 24 seeds collectively teach BOTH the over-fold trap (must-call) AND the station trap (must-fold)? (Yes by design: R1.1/R5.1/R5.2/R6.4 over-fold side; R2.1/R3.3/R4.3 station side.)
2. **Reason coverage:** are all 12 river reasons represented across the 24 seeds, with the river-defining trio (`blocker_bluff_catch_river`, `mdf_defense_river`, `missed_draw_give_up`) each clearly showcased?
3. **Sizing coverage:** are all 4 villain sizings (small/medium/large/overbet) represented so MDF varies across the set? (Yes: R5 small, R1/R4 medium, R2/R3 large, R6 overbet.)
4. **Critical density:** is the critical-flag rate ~30-40% of action_choice scenarios, all genuine punts?
5. **Honesty:** is `sourceConfidence` all `expert_judgment` (correct for pre-solver-review seeds)? Are mixed spots labelled `mixed` rather than over-confidently classified?
6. **Migration readiness:** after REVISE fixes, is the set ready for v4.4.1 production migration (477 -> 501)?

---

## 6. Output of the review (v4.4.0A)

The v4.4.0A sprint produces a strategic-review-results doc with a per-scenario PROMOTE/REVISE/REJECT table, applies all REVISE fixes builder-first (regenerate JSON, re-audit to 24/0/0), and only then is the set eligible for v4.4.1 production migration. Any REJECT must be replaced by a quality scenario, never quota-filled.

**Do NOT migrate to production until every seed is PROMOTE.**
