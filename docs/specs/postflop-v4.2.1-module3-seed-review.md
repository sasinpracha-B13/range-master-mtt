# Postflop v4.2.1 — Module 3 Seed Strategic Review

**Status:** Planning-only sprint outcome. 24/24 scenarios reviewed. Mechanical audit clean. 8 fixes applied (1 mechanical schema fix on all scenarios + 7 strategic refinements). All 24 scenarios flipped from `reviewStatus: v4.2.0_seed_candidate → v4.2.0_seed_reviewed`.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.0-module3-architecture.md`, `postflop-v4.2.0-module3-schema-taxonomy.md`, `postflop-v4.2.0-module3-seed-scenarios.json`, `postflop-v4.2.0-module3-audit-plan.md`, `postflop-v4.2.0-module3-gpt-review-package.md`

---

## 1. Headline numbers

| Metric | Value |
|---|---|
| Scenarios reviewed | 24 / 24 |
| M3 mechanical audit (final) | **24 / 0 hard errors / 0 warnings** |
| Strategic verdict: **PASS** | **17** |
| Strategic verdict: **WARN (with applied fix)** | **7** |
| Strategic verdict: **FAIL** | **0** |
| Mechanical fixes applied | 1 batch (13 scenarios — `critical ⊆ bad` consistency) |
| Strategic refinements applied | 7 targeted edits |
| reviewStatus flipped | 24 / 24 → `v4.2.0_seed_reviewed` |
| Production audit (unchanged) | 300 / 0 / 0 |
| M2 seed audit (unchanged) | 24 / 0 hard / 8 warnings |

---

## 2. Auditor implementation choice

**Option A chosen: new script `tools/audit-postflop-module3-seed.ps1` (~440 LOC).**

Rationale: M3 vocabulary differs from M2 in too many places to share a single auditor cleanly:
- New required fields: `spot.villainAction`, `spot.villainSizing`, optional `explanation.defenseLogic`.
- 5-action decision set (`fold`/`call`/`check_raise_small`/`check_raise_big`/`mixed`) vs M2's IP-c-bet decision set (`bet_small`/`bet_big`/`check`).
- 8-reason set (different IDs: `equity_realization_call`, `range_disadvantage_fold`, etc. vs M2's `value`, `pot_control`, etc.).
- 2 new heroHandRole values: `bluff_catcher`, `dominated_marginal`.
- 7 planned M3 concept tags + 4 M2 reusable.

Extending `tools/audit-postflop-module2-seed.ps1` with a `-Module 3` switch would have added ~250 LOC of conditional logic and made both rule sets harder to follow. A separate script is cleaner. The M2 auditor is not modified.

The M3 auditor uses pure-ASCII source (no UTF-8 chars) and explicit UTF-8 file I/O via `[System.IO.File]::ReadAllText` to avoid CP874 mojibake on Thai-locale Windows — same convention as M2.

---

## 3. Mechanical defect found and fixed (M3-R31 batch fix)

**Defect:** 13 of 24 scenarios had `answer.critical` values that were not in `answer.bad`. The v4.2.0 author intended `bad` = "non-best, non-acceptable, non-critical" with `critical` as a separate flag set. The schema rule M3-R31 explicitly requires `critical ⊆ bad`.

**Affected scenarios:** F1.1, F1.3, F1.4, F2.1, F2.3, F2.4, F3.4, F4.4, F5.1, F5.3, F5.4, F6.1, F6.4 (13 total).

**Fix:** Added each `critical` value to the `bad` array. `bad` is now the full set of wrong options; `critical` is the worst-leaks subset within it. Schema convention is now consistent and matches the audit-plan doc.

**No strategic intent changed** — the partition (best/acceptable/critical) is identical; only the `bad` array is more inclusive.

---

## 4. Strategic refinements applied (7 targeted edits)

The v4.2.0 GPT review package flagged 5 scenarios where solver mix likely makes `critical` too harsh, plus 2 scenarios where `acceptable` should include slowplay/call. I applied all 7:

| # | Scenario | Original | Fix | Rationale |
|---|---|---|---|---|
| 1 | F1.3 `5h4h` reason call | critical: [`semi_bluff_raise`] | critical: [] | Wheel gutshot + BDFD; solver may mix in 5–10% raise as polar bluff. `bad` (not `critical`). |
| 2 | F2.3 `QcJc` reason call | critical: [`semi_bluff_raise`] | critical: [] | QJ has more equity than 5-4 (overcards). Solver likely 10–15% raise mix. `bad` not `critical`. |
| 3 | F3.3 `Td9d` reason raise | acceptable: [`protection_raise`] | acceptable: [`protection_raise`, `equity_realization_call`] | Strong combo draw can also be reasoned as call (pot odds + draw equity). Both reasons defensible. |
| 4 | F5.2 `AhKh` action raise_big | acceptable: [`check_raise_small`] | acceptable: [`check_raise_small`, `call`] | Solver heavily mixes slowplay on monotone with nut flush because villain's range is uncapped. |
| 5 | F5.3 `KhQc` reason call | critical: [`semi_bluff_raise`] | critical: [] | The raise reasoning would be `blocker_raise` (acceptable), not `semi_bluff_raise`; downgrade from critical. |
| 6 | F6.1 `7d6d` action call | actionReason: `equity_realization_call` | actionReason: `bluff_catch` | Pair of 7s on KK7 is a textbook bluff-catcher (BB beats villain's air). More specific reason. |
| 7 | F6.4 `JcTc` action fold | acceptable: [] | acceptable: [`call`] | JTs has BDFD + 2 overs above 7. Solver may show 15–25% calling frequency. |

**Discipline note:** I deliberately did NOT downgrade `critical` flags on F1.4 (JcTd fold), F3.4 (AhKc fold), or F5.4 (6c5d fold), even though these are the "stubborn call" hands BB players defend too often. Keeping `check_raise_big` as critical here is the right teaching message — over-bluffing OOP with naked overcards is the leak, full stop.

---

## 5. Per-scenario verdict (24 scenarios)

### Family 1 — Dry A-high (As 8d 3h)

| ID | Hero | Type | Best | Reason | Verdict | Fix applied | Notes |
|---|---|---|---|---|---|---|---|
| F1.1 | Th8h | action | call | equity_realization_call | **PASS** | (mech batch) | Mid pair + BDFD — clean defense. |
| F1.2 | 8c8h | action | check_raise_small | value_raise | **PASS** | — | Middle set on dry A-high; raise dominant. |
| F1.3 | 5h4h | reason | equity_realization_call | equity_realization_call | **WARN** | crit removed | Wheel gutshot + BDFD; raise is `bad` not `critical`. |
| F1.4 | JcTd | action | fold | range_disadvantage_fold | **PASS** | (mech batch) | Pure overcards on dry A-high. |

### Family 2 — Dry K-high (Kh 9c 4s)

| ID | Hero | Type | Best | Reason | Verdict | Fix applied | Notes |
|---|---|---|---|---|---|---|---|
| F2.1 | 9d8d | action | call | equity_realization_call | **PASS** | (mech batch) | Mid pair + BDFD. |
| F2.2 | 9s9h | action | check_raise_small | value_raise | **PASS** | — | Middle set; raise dominant. |
| F2.3 | QcJc | reason | equity_realization_call | equity_realization_call | **WARN** | crit removed | QJ gutshot + 2 overs; mixed strategy possible. |
| F2.4 | AhQs | action | fold | domination_fold | **PASS** | (mech batch) | AQ dominated by AK/KQ; reason = domination_fold (more specific than range_disadvantage_fold). |

### Family 3 — Low connected (8s 7d 5h)

| ID | Hero | Type | Best | Reason | Verdict | Fix applied | Notes |
|---|---|---|---|---|---|---|---|
| F3.1 | 9c8c | action | call | equity_realization_call | **PASS** | — | Top pair + gutshot; call > raise on wet board (acceptable: check_raise_small). |
| F3.2 | 5c5d | action | check_raise_small | protection_raise | **PASS** | — | Bottom set on wet; protection raise dominant. |
| F3.3 | Td9d | reason | semi_bluff_raise | semi_bluff_raise | **WARN** | acceptable += equity_realization_call | OE + overcards + BDFD; semi_bluff is dominant reason but ER call also defensible. |
| F3.4 | AhKc | action | fold | range_disadvantage_fold | **PASS** | (mech batch) | Naked AK with no backdoor on low connected; fold dominant despite the "AK is too pretty to fold" instinct. |

### Family 4 — Two-tone broadway (Qh Jh 6c)

| ID | Hero | Type | Best | Reason | Verdict | Fix applied | Notes |
|---|---|---|---|---|---|---|---|
| F4.1 | AcTc | action | call | equity_realization_call | **PASS** | — | Nut gutshot + A blocker + BDFD. |
| F4.2 | QcQd | action | check_raise_small | value_raise | **PASS** | — | Top set on wet two-tone; small raise dominant, big also acceptable. |
| F4.3 | 9h8h | reason | semi_bluff_raise | semi_bluff_raise | **PASS** | — | Combo draw 12+ outs; textbook semi-bluff raise. |
| F4.4 | 8c4c | action | fold | range_disadvantage_fold | **PASS** | (mech batch) | Backdoor club only with weak kicker. |

### Family 5 — Monotone (Jh 8h 4h)

| ID | Hero | Type | Best | Reason | Verdict | Fix applied | Notes |
|---|---|---|---|---|---|---|---|
| F5.1 | 9h8c | action | call | equity_realization_call | **PASS** | (mech batch) | Mid pair + 1-card FD on monotone. drawCategory=flush_draw classification is intentional (true 9-out FD even though only 1 hole-card same suit). |
| F5.2 | AhKh | action | check_raise_big | value_raise | **WARN** | acceptable += call | Nut flush; slowplay is also strongly defensible vs uncapped IP range. |
| F5.3 | KhQc | reason | equity_realization_call | equity_realization_call | **WARN** | crit removed | 2nd-nut FD + K blocker; the raise option's reason is `blocker_raise` (acceptable), so `semi_bluff_raise` shouldn't be `critical`. |
| F5.4 | 6c5d | action | fold | range_disadvantage_fold | **PASS** | (mech batch) | Air with zero hearts. Reason could be `reverse_implied_odds_fold` if that were in the v4.2.0 vocabulary; using `range_disadvantage_fold` as closest available. |

### Family 6 — Paired (Kc Kd 7s)

| ID | Hero | Type | Best | Reason | Verdict | Fix applied | Notes |
|---|---|---|---|---|---|---|---|
| F6.1 | 7d6d | action | call | bluff_catch | **WARN** | actionReason: equity_realization_call → bluff_catch | Pair of 7s on KK7 is more accurately a bluff-catcher than a generic equity-realizing call. |
| F6.2 | AhKh | action | check_raise_small | value_raise | **PASS** | — | Trip K + nut kicker. Slowplay also defensible (acceptable: call). Some reviewers would flip best to call; v4.2.0's slight value-raise lean is also valid. Keep as-is. |
| F6.3 | 8d8s | reason | bluff_catch | bluff_catch | **PASS** | — | 88 underpair to K but overpair to 7; classic bluff-catcher. |
| F6.4 | JcTc | action | fold | range_disadvantage_fold | **WARN** | acceptable += call | JTs with BDFD + 2 overcards above 7; solver may show meaningful calling frequency. |

---

## 6. Aggregate verdict counts

| Verdict | Count | Scenarios |
|---|---|---|
| PASS | 17 | F1.1, F1.2, F1.4, F2.1, F2.2, F2.4, F3.1, F3.2, F3.4, F4.1, F4.2, F4.3, F4.4, F5.1, F5.4, F6.2, F6.3 |
| WARN | 7 | F1.3, F2.3, F3.3, F5.2, F5.3, F6.1, F6.4 |
| FAIL | 0 | — |

**Pre-review prediction was ~12 PASS + ~10 WARN + 0 FAIL.** Actual: 17 PASS + 7 WARN + 0 FAIL. The pre-review was slightly pessimistic — several "potentially WARN" scenarios held up under review.

---

## 7. Updated reason / action distribution after fixes

| actionReason | Pre-review | Post-review | Delta |
|---|---:|---:|---|
| equity_realization_call | 9 | 8 | -1 (F6.1 → bluff_catch) |
| value_raise | 5 | 5 | — |
| range_disadvantage_fold | 5 | 5 | — |
| semi_bluff_raise | 2 | 2 | — |
| protection_raise | 1 | 1 | — |
| bluff_catch | 1 | 2 | +1 (F6.1) |
| domination_fold | 1 | 1 | — |
| **Total** | **24** | **24** | balanced |

| answer.best (action_choice + reason_choice) | Pre | Post |
|---|---:|---:|
| call (action) | 6 | 6 |
| check_raise_small (action) | 5 | 5 |
| check_raise_big (action) | 1 | 1 |
| fold (action) | 6 | 6 |
| equity_realization_call (reason) | 3 | 3 |
| semi_bluff_raise (reason) | 2 | 2 |
| bluff_catch (reason) | 1 | 1 |

No `mixed` used as best (intentional — `mixed` reserved for ~3% EV ties not present in v4.2.0 seeds).

---

## 8. Follow-up notes for v4.2.2 / v4.2.3

1. **F5.4 reason note** — `reverse_implied_odds_fold` would be more pedagogically precise for "65 with 0 hearts on monotone" but isn't in the v4.2.0 reason set. If v4.2.4 production data adds this reason, F5.4 should be updated.
2. **F6.2 best-action coin-flip** — slowplay vs raise frequency on paired-K trips is a 50/50 solver call. Current best=check_raise_small with acceptable=[call]. If v4.2.4 player data shows confusion ("why isn't slowplay best?"), consider flipping to best=call.
3. **F5.1 drawCategory=flush_draw** — 1-card flush draws on monotone are classified as `flush_draw` (true 9-out draw to river). This is a deliberate convention choice; document it in the M3 schema-taxonomy doc when migrating to production in v4.2.3.
4. **`bluff_catcher` and `dominated_marginal` heroHandRole values** — used in 2 scenarios (F2.4 dominated_marginal, F6.3 bluff_catcher). These are M3-specific extensions to M2 vocabulary; need to be added to `postflop_taxonomy.json` when productionized in v4.2.4.
5. **`reverse_implied_odds_fold` candidate for re-introduction** — was pruned in v4.2.0 architecture §6 but F5.4 demonstrates the gap. Reconsider for v4.2.4 productionization.
6. **Concept tag `range_disadvantage` is a planned-only tag** — not in `postflop_concepts.json`. v4.2.3 migration must add it (along with the other 6 M3-native tags) before any seed can flip to `auditStatus: approved`.

---

## 9. Sign-off

All 24 scenarios are mechanically clean (M3 audit PASS) and strategically defensible (17 PASS / 7 WARN / 0 FAIL with all WARNs addressed in-place). All 24 scenarios flipped from `v4.2.0_seed_candidate → v4.2.0_seed_reviewed`.

**Module 3 seed JSON is ready for v4.2.2 (final review pass + commit) and subsequently v4.2.3 (migration to production data with `auditStatus: review_pending`).**

**v4.2.1 deliberately does NOT:**
- Productionize Module 3 (no scenarios in `postflop/postflop_scenarios.json`).
- Add M3 concepts to `postflop/postflop_concepts.json`.
- Add `bluff_catcher` / `dominated_marginal` to `postflop/postflop_taxonomy.json`.
- Bump appVersion or service-worker VERSION.
- Touch any runtime file (`index.html`, `service-worker.js`, etc.).
- Touch any preflop or gamification file.
- Modify the M2 seed auditor or production auditor.

Production audit gate remains **300 / 0 / 0**. M2 seed audit remains **24 / 0 hard / 8 warnings**. M3 seed audit (new) is **24 / 0 hard / 0 warnings**.
