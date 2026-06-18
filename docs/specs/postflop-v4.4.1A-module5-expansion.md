# Postflop v4.4.1A — Module 5 Expansion (501 → 509)

**Status:** SHIPPED (production data + cache bump). M5 = 32 scenarios, all `approved` + runtime-verified, **NOT yet routed** (route + 5-card renderer land in v4.4.2).
**Date:** 2026-06-18
**Predecessor:** v4.4.1 (`d102d5d`, M5 production migration 477→501)
**Scope:** gap-first expansion of Module 5 from 24 → 32, targeting the coverage holes left by the initial migration. Quality-over-count: 8 scenarios, every spot strategically reviewed.

---

## 1. What shipped

| Artifact | Change |
|---|---|
| `postflop/postflop_scenarios.json` | 501 → **509** (+8 M5; M5 24 → 32). Top-level `description` refreshed to 509. |
| `tools/build-m5-expansion-v4.4.1A.ps1` | NEW expansion seed builder (8 scenarios, 2 new boards). |
| `tools/audit-postflop-module5-expansion-v4.4.1A.ps1` | NEW per-sprint auditor: ports the production R76–R93 rule set + cross-corpus duplicate-ID check vs production and vs the v4.4.0 seeds. |
| `tools/migrate-module5-expansion-v4.4.1A.ps1` | NEW add-not-replace migration (preserves the existing 24 M5; two-phase). |
| `docs/specs/postflop-v4.4.1A-module5-expansion-seeds.json` | NEW 8-seed planning JSON. |
| `index.html` / `service-worker.js` | `appVersion`/`VERSION` `4.4.1` → `4.4.1A`. |

No production-auditor change (R76–R93 already in place from v4.4.1). No runtime route / UI / renderer change.

---

## 2. Gap-first design

The v4.4.1 migration left clear coverage holes (measured on the production 24). This batch fills them:

| Target | Before | After | Scenario |
|---|---|---|---|
| `pot_odds_river_call` | **0** | 1 | A.1 (88 underpair, small bet, price call) |
| `bluff_raise_river` | 1 | 2 | B.1 (AhJc nut-flush-blocker check-raise bluff) |
| `thin_value` (role) | 1 | 2 | B.4 (JhTh non-nut flush, call-not-raise) |
| `mdf_defense_river` | 2 | 3 | A.2 (A6 weak ace defends two-thirds on MDF) |
| `mixed_indifference_river` | 2 | 3 | B.3 (KcTd top pair, no blocker, knife-edge) |
| `range_disadvantage_river_fold` | 2 | 3 | A.4 (KQ air, capped give-up) |

Plus two anchors that are not gap-fills but high-value, distinct content:
- **A.3** — `bluff_catch_river` over-fold-trap: AQ *must call* a pot bet (folding over-folds). Pairs with A.2 to teach the top-pair class defending across sizings.
- **B.2** — `value_raise_river`: the nut flush (Ah3h) check-raises big. Deliberate **polarization pair** with B.1 on the *same board*: with the Ah you either bluff-raise (Ah + blank) or value-raise (Ah + heart = nut flush).

**Two boards** (both new to the corpus): **A** = `Ac 7d 4s / 9h / 2c` (A-high dry double-blank brick); **B** = `Kh 9h 5c / 4d / 2h` (flush-completing, three hearts). Each physical board carries multiple bet sizes (size is a per-hand property, not a board property).

Prompts state the river bet size explicitly (`~33% (small)`, `two-thirds (medium)`, `pot (large)`) — a clarity improvement over the v4.4.0 generic prompts, since these spots are sizing-critical.

---

## 3. Honestly deferred

Two targets were **not** filled, because no clean, non-debatable spot could be constructed this sprint:

- **`domination_river_fold` (still 0):** the obvious construction — fold a weak top pair to a big bet on a dry board — is poker-*wrong*. A made top pair beats *all* of villain's bluffs, so versus a balanced polar bet it is a bluff-catch/mix, **not** a clean fold. A genuine domination-fold needs a hand that beats few/no bluffs (e.g. a counterfeited two-pair on a paired board versus a value-merged line). Deferred to v4.4.1B with a properly-built board.
- **A 2nd `blocker_bluff_catch_river` (still 1):** every clean construction collapsed onto the *same* Ah + weak-pair shape as the already-approved R3.4 — that would be filler. Deferred until a genuinely distinct blocker mechanic (e.g. a straight blocker on a straight-completing board) is built.

This is the "no filler / mechanical-audit-is-not-enough" discipline in action: better to defer a target than ship a debatable scenario.

---

## 4. Strategic review (mandatory pass)

Every scenario was verified on the full 5-card runout. Notable catches during review (before any migration):

- **A5 "domination fold" rejected:** initially authored as a weak ace folding a pot bet; review showed it is actually a bluff-catch/mix (top pair beats the bluffs). Replaced with A.3 (AQ over-fold-trap *call*) — the correct lesson for that texture.
- **Ah9c blocker bluff-catch rejected:** duplicated the approved R3.4 too closely. Replaced with B.2 (nut-flush value-raise), forming the polarization pair with B.1.
- **Flush rankings re-verified:** B.2 Ah3h = nut flush (Ace-high, unpaired board → effective nuts); B.4 JhTh = King-Jack-high flush, beaten only by Ah/Qh flushes (hence call-not-raise).
- **Range realism:** all hero hands are clear BB flats vs a BTN 2.5x open (no reliance on debatable AK/AQ flats — the lesson learned in the v4.4.0A review).

**Critical-flag density (intentionally low):** only 2 of 5 action_choice scenarios carry a critical flag — B.1 `call` (A-high with zero showdown value) and B.2 `fold` (folding the nut flush). This recalibrates the combined M5 corpus downward from the v4.4.0A ~61% toward the 30–40% target band.

---

## 5. Verification

- **Expansion seed audit** (`audit-postflop-module5-expansion-v4.4.1A.ps1`): **8 / 0 / 0 PASS**; no duplicate IDs within the batch, vs production, or vs the v4.4.0 seeds.
- **Production audit** (`audit-postflop-ps.ps1`): **509 / 0 / 0 PASS** (M5 approved: 32; M1–M4 unchanged 251/49/85/92). M5 stats: riverCategory brick 8 / flush_complete 8 / others 4; sizing large 13 / medium 10 / small 5 / overbet 4.
- **Runtime smoke test** (local preview): after clearing the v4.4.1 SW cache, `[postflop] loaded 509/509 scenarios (schema 1.0.0)`, `App.postflop.ready=true error=null`, module pool 251/49/85/92/**32**, M5 inert (no router until v4.4.2), **zero console errors**. (The first reload served the SW-cached 501 — confirming exactly why the `VERSION` bump is required.)

---

## 6. Combined M5 corpus after v4.4.1A (32 scenarios)

- actionReason: value_raise 5, thin_value 5, bluff_catch 4, board_change 3, mdf 3, mixed 3, range_disadvantage 3, missed_draw 2, bluff_raise 2, blocker_bluff_catch 1, pot_odds 1, **domination 0**.
- qtype: 23 action_choice + 9 reason_choice (~28%).
- riverCategory: 6 used (brick/flush_complete 8 each, others 4); 3 reserved unused.
- sizing: all four represented (large 13 / medium 10 / small 5 / overbet 4).

---

## 7. Next

1. **v4.4.1B** — continue M5 expansion toward 60: fill the deferred `domination_river_fold` and a distinct `blocker_bluff_catch_river`, add the reserved riverCategories (blank_runout / double_pair / range_shift_card) and new board families.
2. **v4.4.2** — M5 runtime wire: `postflop:m5` route + `getModule5Scenarios()` + riverLogic-prominent feedback + the 5-card board renderer (must fit 5 cards at mobile 320px).

**Status: SHIPPED · production 509/0/0 · M5 = 32 approved + runtime-verified · NOT routed (v4.4.2).**
