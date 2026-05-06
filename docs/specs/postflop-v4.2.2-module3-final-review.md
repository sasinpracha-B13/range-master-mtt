# Postflop v4.2.2 — Module 3 Final Strategic Review + Planning Commit Lock

**Status:** Planning-only sprint outcome. 24/24 scenarios reviewed in second pass. All cleared and flipped to `reviewStatus: v4.2.0_final`. Module 3 seeds are locked and ready for v4.2.3 migration to production data.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.1-module3-seed-review.md`, `postflop-v4.2.0-module3-architecture.md`, `postflop-v4.2.0-module3-schema-taxonomy.md`, `postflop-v4.2.0-module3-seed-scenarios.json`, `postflop-v4.2.0-module3-audit-plan.md`

---

## 1. Headline numbers

| Metric | Value |
|---|---|
| Scenarios reviewed (second pass) | 24 / 24 |
| **FINAL_PASS** | **22** |
| **FINAL_WARN** (with documented uncertainty) | **2** |
| **BLOCKED** | **0** |
| Second-pass changes applied | 3 targeted edits + 1 vocabulary expansion |
| reviewStatus flipped to `v4.2.0_final` | 24 / 24 |
| M3 seed audit (final) | **24 / 0 hard / 0 warnings PASS clean** |
| Production audit (unchanged) | 300 / 0 / 0 |
| M2 seed audit (unchanged) | 24 / 0 hard / 8 warnings |

---

## 2. Resolution of 6 follow-up notes from v4.2.1

### Note 1 — F5.4 reason: re-introduce `reverse_implied_odds_fold`?

**Decision: REJECT — no vocabulary expansion.**

Reasoning: 65o on Jh-8h-4h has zero hearts, no pair, and a gutshot to 7. This isn't a "reverse implied odds" spot in the strict sense — RIO applies when hero makes a hand that loses to a better one (e.g., a non-nut straight on a monotone board). 65o here just has no equity worth defending. The lesson is "BB has no business in this pot" which is exactly what `range_disadvantage_fold` already conveys.

I confirmed by re-reading the explanation: "Zero hearts means zero flush equity; gutshot to 7 (4 outs) is dominated by villain's range." That IS the lesson. No vocabulary churn. F5.4 keeps `range_disadvantage_fold`.

### Note 2 — F6.2 best-action coin-flip: keep `check_raise_small` or flip to `call`?

**Decision: APPLY FIX NOW — flip best=call, re-introduce `slowplay_call`.**

Reasoning (project-owner):
- Solver studies (e.g., GTO Wizard for 100BB BTN-vs-BB SRP on KK7 vs ~33% c-bet) show the slowplay frequency for trip K + nut kicker at roughly 50–65%, with raise small at 25–40%. Slowplay is the slight favorite.
- More importantly: keeping F6.2 as raise creates an anti-pattern across the seed set. 5 of 6 board families (F1.2 88, F2.2 99, F3.2 55, F4.2 QQ, F5.2 AhKh) already have raise as best for the nutted-value scenario. If F6.2 also raises, the player sees "always raise nuts OOP" — which is wrong on paired boards.
- Flipping F6.2 to call teaches the **paired-board exception**: "Slowplay disguised nuts on paired boards because villain's c-bet range is air-heavy and raising folds out the bluffs."
- This is a distinct teaching lesson worth the cost of a small vocabulary expansion.

Reason choice: `value_raise` doesn't fit when best is call. `bluff_catch` is awkward for a nutted hand (catch-bluff implies marginal). `equity_realization_call` is wrong — trip K isn't realizing equity, it's slowplaying. The honest fit is `slowplay_call`, which was originally pruned in v4.2.0 architecture §6 and explicitly listed as a re-introduction candidate in v4.2.1 review §8 note 5.

**Vocabulary expansion applied:**
- Added `slowplay_call` to `tools/audit-postflop-module3-seed.ps1` `$validReasons` array.
- Updated `postflop-v4.2.0-module3-architecture.md` §6 reason table (8 → 9 reasons).
- Updated `postflop-v4.2.0-module3-schema-taxonomy.md` §5 reason table (8 → 9 reasons).
- Updated `postflop-v4.2.0-module3-audit-plan.md` rules M3-R19 + M3-R20 (added slowplay_call to enumeration).

F6.2 explanation rewritten to match the slowplay framing.

### Note 3 — F5.1 drawCategory=`flush_draw` for 1-card FD: classification convention

**Decision: DEFER to v4.2.3 migration.** Document the convention in v4.2.3's migration notes when the seeds enter production data. The v4.2.0 schema-taxonomy doc §8 already lists `flush_draw` as a valid drawCategory and the auditor's M3-R27 explicitly accepts 4-card-suit (1 hero + 3 board) as valid for `flush_draw` classification (not warned). No change needed in v4.2.2.

### Note 4 — `bluff_catcher` and `dominated_marginal` heroHandRole values: taxonomy entry needed

**Decision: DEFER to v4.2.4 productionization.** These are M3-specific extensions to M2 vocabulary (per schema doc §7) used by F2.4 (`dominated_marginal`) and F6.3 (`bluff_catcher`). They will be added to `postflop/postflop_taxonomy.json` in v4.2.4 alongside the rest of the M3 runtime wiring. v4.2.0 schema doc already documents them as planned values. No change in v4.2.2.

### Note 5 — `reverse_implied_odds_fold` candidate for re-introduction

**Decision: REJECT** — same reasoning as Note 1. Resolved together.

### Note 6 — `range_disadvantage` concept tag is planned-only

**Decision: DEFER to v4.2.3 migration.** Along with the other 6 M3-native concept tags (`oop_defense_threshold`, `check_raise_value`, `check_raise_bluff`, `bluff_catchers`, `equity_realization_oop`, `pot_odds_defense`), `range_disadvantage` will be added to `postflop/postflop_concepts.json` as part of the v4.2.3 migration to production data. No change in v4.2.2.

### Resolution summary

| Note | Decision | Action timing |
|---|---|---|
| 1 (F5.4 reason) | REJECT | none — current is correct |
| 2 (F6.2 best) | APPLY NOW | v4.2.2 (this sprint) |
| 3 (F5.1 1-card FD) | DEFER | v4.2.3 |
| 4 (heroHandRole taxonomy) | DEFER | v4.2.4 |
| 5 (RIO reintroduction) | REJECT | none — Note 1 dup |
| 6 (range_disadvantage concept) | DEFER | v4.2.3 |

---

## 3. Re-evaluation of 7 v4.2.1 strategic refinements (UN-soften pass)

The v4.2.1 review applied 7 strategic refinements. Re-read each with the question "did this actually improve teaching value, or did I soften the lesson too much?"

| # | Scenario | v4.2.1 fix | v4.2.2 verdict | Action |
|---|---|---|---|---|
| 1 | F1.3 `5h4h` reason call | critical [`semi_bluff_raise`] removed | **UN-SOFTEN** — solver mix to raise is ~3–5%, near-zero. Critical flag was justified. | **Re-add `semi_bluff_raise` to critical.** |
| 2 | F2.3 `QcJc` reason call | critical [`semi_bluff_raise`] removed | KEEP v4.2.1 — QJ has more equity than 54 (overcards); 10–15% raise mix makes critical too harsh. | No change. |
| 3 | F3.3 `Td9d` reason raise | acceptable += `equity_realization_call` | KEEP v4.2.1 — both reasons defensible; giving credit for the alternative read is correct. | No change. |
| 4 | F5.2 `AhKh` action raise_big | acceptable += `call` | KEEP v4.2.1 — solver heavily mixes slowplay nut flush on monotone. | No change. |
| 5 | F5.3 `KhQc` reason call | critical [`semi_bluff_raise`] removed | **UN-SOFTEN** — picking `semi_bluff_raise` as the reason for *calling* is genuinely confused (semi_bluff is a raise reason, not a call reason). Critical is appropriate. | **Re-add `semi_bluff_raise` to critical.** |
| 6 | F6.1 `7d6d` action call | actionReason: equity_realization_call → bluff_catch | KEEP v4.2.1 — pair of 7s on KK7 is genuinely a bluff-catcher; reason is more specific and accurate. | No change. |
| 7 | F6.4 `JcTc` action fold | acceptable += `call` | KEEP v4.2.1 — JTs has BDFD + 2 overcards above 7; solver may show meaningful calling frequency. Adding call as acceptable gives credit for the float read. | No change. |

**UN-soften count: 2 (F1.3, F5.3).** The other 5 refinements held up under second-pass scrutiny.

---

## 4. F5.4 specific resolution

**Question:** Should F5.4 reason flip to `reverse_implied_odds_fold`?

**Answer: NO.** See follow-up note 1 above for full reasoning. 65o on monotone Jh-8h-4h has 0 hearts and just a 4-out gutshot to 7. The "reverse implied odds" framing doesn't apply because hero has no made hand to be RIO against. The hand simply has no equity. `range_disadvantage_fold` is the correct reason. Explanation already covers the "no flush equity" angle clearly.

**Final F5.4 state:**
- best: `fold` ✓
- actionReason: `range_disadvantage_fold` (no change) ✓
- reviewStatus: `v4.2.0_final` ✓

---

## 5. F6.2 specific resolution

**Question:** Should F6.2 best stay `check_raise_small` or flip to `call`?

**Answer: FLIP to `call`.** See follow-up note 2 above for full reasoning.

**Final F6.2 state (post-v4.2.2 changes):**
- best: `call` (flipped from `check_raise_small`)
- acceptable: `[check_raise_small]` (was `[call]`)
- bad: `[fold, check_raise_big, mixed]` (unchanged)
- critical: `[fold]` (unchanged — folding trip K is the real leak)
- recommendedAction: `call` (flipped)
- actionReason: `slowplay_call` (re-introduced vocab; was `value_raise`)
- explanation: rewritten to match slowplay framing

---

## 6. Per-scenario final sign-off (24 scenarios)

Format: `ID | board | hero | qtype | best | reason | verdict | second-pass change | migration readiness`

### Family 1 — Dry A-high (As 8d 3h)

| F | Hero | qtype | best | reason | verdict | 2nd-pass change | ready |
|---|---|---|---|---|---|---|---|
| 1.1 | Th8h | action | call | equity_realization_call | **FINAL_PASS** | none | ✅ |
| 1.2 | 8c8h | action | check_raise_small | value_raise | **FINAL_PASS** | none | ✅ |
| 1.3 | 5h4h | reason | equity_realization_call | equity_realization_call | **FINAL_PASS** | critical=[semi_bluff_raise] re-added (UN-soften) | ✅ |
| 1.4 | JcTd | action | fold | range_disadvantage_fold | **FINAL_PASS** | none | ✅ |

### Family 2 — Dry K-high (Kh 9c 4s)

| F | Hero | qtype | best | reason | verdict | 2nd-pass change | ready |
|---|---|---|---|---|---|---|---|
| 2.1 | 9d8d | action | call | equity_realization_call | **FINAL_PASS** | none | ✅ |
| 2.2 | 9s9h | action | check_raise_small | value_raise | **FINAL_PASS** | none | ✅ |
| 2.3 | QcJc | reason | equity_realization_call | equity_realization_call | **FINAL_WARN** | none — kept v4.2.1 softening (QJ has overcard equity; 10-15% raise mix justifies non-critical) | ✅ |
| 2.4 | AhQs | action | fold | domination_fold | **FINAL_PASS** | none | ✅ |

### Family 3 — Low connected (8s 7d 5h)

| F | Hero | qtype | best | reason | verdict | 2nd-pass change | ready |
|---|---|---|---|---|---|---|---|
| 3.1 | 9c8c | action | call | equity_realization_call | **FINAL_PASS** | none | ✅ |
| 3.2 | 5c5d | action | check_raise_small | protection_raise | **FINAL_PASS** | none | ✅ |
| 3.3 | Td9d | reason | semi_bluff_raise | semi_bluff_raise | **FINAL_PASS** | none — v4.2.1 ER call acceptable retained | ✅ |
| 3.4 | AhKc | action | fold | range_disadvantage_fold | **FINAL_PASS** | none | ✅ |

### Family 4 — Two-tone broadway (Qh Jh 6c)

| F | Hero | qtype | best | reason | verdict | 2nd-pass change | ready |
|---|---|---|---|---|---|---|---|
| 4.1 | AcTc | action | call | equity_realization_call | **FINAL_PASS** | none | ✅ |
| 4.2 | QcQd | action | check_raise_small | value_raise | **FINAL_PASS** | none | ✅ |
| 4.3 | 9h8h | reason | semi_bluff_raise | semi_bluff_raise | **FINAL_PASS** | none | ✅ |
| 4.4 | 8c4c | action | fold | range_disadvantage_fold | **FINAL_PASS** | none | ✅ |

### Family 5 — Monotone (Jh 8h 4h)

| F | Hero | qtype | best | reason | verdict | 2nd-pass change | ready |
|---|---|---|---|---|---|---|---|
| 5.1 | 9h8c | action | call | equity_realization_call | **FINAL_PASS** | none — 1-card FD classification deferred to v4.2.3 docs | ✅ |
| 5.2 | AhKh | action | check_raise_big | value_raise | **FINAL_PASS** | none — v4.2.1 call as acceptable retained | ✅ |
| 5.3 | KhQc | reason | equity_realization_call | equity_realization_call | **FINAL_PASS** | critical=[semi_bluff_raise] re-added (UN-soften); the raise reason is blocker_raise, not semi_bluff | ✅ |
| 5.4 | 6c5d | action | fold | range_disadvantage_fold | **FINAL_PASS** | none — RIO reintroduction rejected | ✅ |

### Family 6 — Paired (Kc Kd 7s)

| F | Hero | qtype | best | reason | verdict | 2nd-pass change | ready |
|---|---|---|---|---|---|---|---|
| 6.1 | 7d6d | action | call | bluff_catch | **FINAL_PASS** | none — v4.2.1 reason refinement retained | ✅ |
| 6.2 | AhKh | action | **call** | **slowplay_call** | **FINAL_PASS** | **FLIPPED best (was check_raise_small); reason re-introduced slowplay_call; explanation rewritten** | ✅ |
| 6.3 | 8d8s | reason | bluff_catch | bluff_catch | **FINAL_PASS** | none | ✅ |
| 6.4 | JcTc | action | fold | range_disadvantage_fold | **FINAL_WARN** | none — v4.2.1 call as acceptable retained; JTs is fold-dominant but float frequency may justify the soft call window | ✅ |

---

## 7. Aggregate verdict counts

| Verdict | Count | Scenarios |
|---|---|---|
| **FINAL_PASS** | **22** | All except F2.3, F6.4 |
| **FINAL_WARN** | **2** | F2.3 (QJ raise frequency uncertainty), F6.4 (JTs call frequency uncertainty) |
| **BLOCKED** | **0** | — |

All 24 scenarios are ready for migration (`migration readiness: ✅`).

---

## 8. Distribution after v4.2.2 changes

| Dimension | Pre-v4.2.2 | Post-v4.2.2 | Delta |
|---|---:|---:|---|
| Total scenarios | 24 | 24 | — |
| action_choice | 18 | 18 | — |
| reason_choice | 6 | 6 | — |
| Distinct boards × 4 | 6 × 4 | 6 × 4 | — |
| best=`call` (action) | 6 | 7 | +1 (F6.2 flip) |
| best=`check_raise_small` (action) | 5 | 4 | -1 (F6.2 flip) |
| best=`check_raise_big` (action) | 1 | 1 | — |
| best=`fold` (action) | 6 | 6 | — |
| best=`mixed` (action) | 0 | 0 | — |
| **actionReason: equity_realization_call** | 8 | 8 | — |
| **actionReason: value_raise** | 5 | 4 | -1 (F6.2) |
| **actionReason: range_disadvantage_fold** | 5 | 5 | — |
| **actionReason: semi_bluff_raise** | 2 | 2 | — |
| **actionReason: bluff_catch** | 2 | 2 | — |
| **actionReason: protection_raise** | 1 | 1 | — |
| **actionReason: domination_fold** | 1 | 1 | — |
| **actionReason: slowplay_call (NEW)** | 0 | 1 | +1 (F6.2) |
| reviewStatus: `v4.2.0_seed_reviewed` | 24 | 0 | -24 (flipped) |
| **reviewStatus: `v4.2.0_final`** | 0 | 24 | +24 (flipped) |

`mixed` still never used as best (intentional — reserved for ~3% EV ties not present in the seed set).

---

## 9. Training Quality + Volume Principle assessment

### 9.1 Accuracy

- **22 FINAL_PASS + 2 FINAL_WARN + 0 BLOCKED** — 92% strong-pass rate after second pass.
- Critical flags are honest after UN-softening (F1.3, F5.3 re-added).
- Best/acceptable/bad/critical partitions internally consistent (audit M3-R28..R31 PASS).
- Explanations align with answers (verified per-scenario in §6).
- ConceptTags fit the decision being trained (audit M3-R38..R41 PASS, no R41 warnings).
- The 2 FINAL_WARN scenarios (F2.3, F6.4) explicitly carry solver-uncertainty notes; not overconfident PASS.

### 9.2 Learning coverage

| Concept | Primary-tag count in v4.2.2 seeds | Healthy target |
|---|---:|---:|
| `oop_defense_threshold` | 7 | 8–12 |
| `equity_realization_oop` | 8 | 8–12 ✓ |
| `bluff_catchers` | 4 | 8–12 |
| `range_disadvantage` | 6 | 8–12 |
| `check_raise_value` | 4 | 8–12 |
| `check_raise_bluff` | 2 | 8–12 |
| `pot_odds_defense` | 0 | 8–12 |

**Verdict: BELOW DEPTH TARGET.** 6 of 7 native M3 concepts are below the 8-scenario healthy threshold. `pot_odds_defense` has zero seeds (it was a planned concept that didn't get used — the v4.2.0 seeds collapsed pot_odds reasoning into `equity_realization_call`).

Board family coverage: 6 families × 4 hands = decent variety per family but each unique hand-on-board only seen once. After 2–3 12-question sessions, repeat risk is high.

Decision coverage: fold (6) + call (7) + raise small (4) + raise big (1) + slowplay call (1) + reason answers (6). Missing: any `mixed` answer scenarios.

### 9.3 Question count

- **24 seeds** is below the 40–60 minimum for "playable beta" per the Training Quality principle.
- Strong-module target: 100–150 scenarios.
- Concept depth (≥8 primary-tag per concept) target: 7 concepts × 8 = 56 scenarios minimum to be depth-healthy.
- Session length normally 12–15 questions: with 24 seeds, players see >50% of the pool in a single session, which makes repeat-risk significant after 2 sessions.

### 9.4 User experience

- M3 must be labeled **BETA / PREVIEW** when productionized in v4.2.4.
- The 24-seed pool is teaching one layer at a time (BB defense vs small c-bet only), which is good.
- Should NOT be unlocked as "stable" at 24 scenarios — clearly a starting set, not a production pool.

### 9.5 Expansion recommendation

**C. major data sprint** required after v4.2.4 productionization.

**Suggested expansion plan (v4.3.x territory):**
- v4.2.5 (immediately after v4.2.4 BETA ships): +12 scenarios targeting depth gaps (`pot_odds_defense` +6, `check_raise_bluff` +3, `bluff_catchers` +3) → 36 total
- v4.3.0: +24 scenarios introducing **defense vs `bet_big` (~75% pot)** as a separate seed batch → 60 total, M3 reaches "playable" threshold
- v4.3.1: +24 scenarios for paired-board defense expansion + monotone defense expansion → 84 total
- v4.3.2: +20 scenarios for board-family balance + concept-depth balancing → 100+ total, M3 reaches "stable" threshold

This mirrors the M2 arc (architecture v4.1.2 → seeds → migration → 35 → 49 in v4.1.9). M2 took ~6 sprints to reach 49; M3 will likely need ~5–8 more sprints after v4.2.4 to reach 100+.

---

## 10. Files modified in v4.2.2

| File | Action | Notes |
|---|---|---|
| `docs/specs/postflop-v4.2.0-module3-seed-scenarios.json` | modified in-place | 3 strategic edits (F1.3, F5.3, F6.2) + 24 reviewStatus flips to `v4.2.0_final` |
| `tools/audit-postflop-module3-seed.ps1` | modified | Added `slowplay_call` to `$validReasons` |
| `docs/specs/postflop-v4.2.0-module3-architecture.md` | modified | §6 reason set table updated (8 → 9 reasons; slowplay_call re-introduced) |
| `docs/specs/postflop-v4.2.0-module3-schema-taxonomy.md` | modified | §5 reason set table updated (8 → 9 reasons) |
| `docs/specs/postflop-v4.2.0-module3-audit-plan.md` | modified | M3-R19 + M3-R20 enumerations updated |
| `docs/specs/postflop-v4.2.2-module3-final-review.md` | NEW | this file |
| `PROJECT_STATE.md` | modified | v4.2.2 status block |
| `TASK_BOARD.md` | modified | v4.2.2 staged → v4.2.1 committed |

---

## 11. Sign-off

All 24 v4.2.0 Module 3 seed scenarios are **strategically locked** at `reviewStatus: v4.2.0_final`. Mechanical audit clean (24/0/0). Strategic verdict: 22 FINAL_PASS + 2 FINAL_WARN + 0 BLOCKED. Reason set expanded from 8 → 9 (re-introduced `slowplay_call` for F6.2's paired-board slowplay). All cross-doc references updated.

**Module 3 seeds are ready for v4.2.3 migration to production data** (append to `postflop/postflop_scenarios.json` with `auditStatus: review_pending`, run production audit + extension rules R29-R40, then flip per-scenario to `auditStatus: approved`).

**v4.2.2 deliberately does NOT:**
- Productionize M3 (no scenarios in `postflop/postflop_scenarios.json`).
- Add M3 concepts to `postflop/postflop_concepts.json`.
- Add M3-specific heroHandRole values to `postflop/postflop_taxonomy.json`.
- Bump appVersion or service-worker VERSION.
- Touch any runtime file.
- Modify M2 / M1 seed JSONs.
- Modify the M2 seed auditor or production auditor (only the M3 auditor was modified, and only its `$validReasons` array).

Production audit gate remains **300 / 0 / 0**. M2 seed audit remains **24 / 0 hard / 8 warnings**. M3 seed audit (post-v4.2.2) is **24 / 0 hard / 0 warnings PASS clean**.

---

## 12. Honest disclosure for v4.2.4 productionization

When M3 ships as a playable beta in v4.2.4, the following must be honest in the UI / Concept Library / Curriculum Map:
- Curriculum card label: "▶ Start Module 3 Beta" (parallel to M2's beta status)
- Status pill: "BETA · 24 scenarios"
- Concept Library: M3 concepts shown but with low-depth warning
- Mastery checklist: scaled to seed pool size; should not promise mastery at 24 scenarios

The v4.2.4 sprint should also include a "Module 3 expansion plan" doc pointing to v4.2.5 / v4.3.x as the path to a depth-healthy module.
