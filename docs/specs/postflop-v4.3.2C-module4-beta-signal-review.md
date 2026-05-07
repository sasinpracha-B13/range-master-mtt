# Postflop v4.3.2C -- Module 4 Beta Signal Collection / QA Instrumentation Review

**Date:** 2026-05-07
**Sprint type:** Meta-level signal-collection review on top of v4.3.2B + 1 minimal allowed-list runtime fix.
**Predecessor HEAD (entry):** `224e539` (v4.3.2B-doc reconcile)
**Substantive predecessor:** `51633b1` (v4.3.2B metadata hotfix)
**Status:** complete; 1 signal-persistence gap identified and fixed inline (per brief Section H "localStorage/session analytics fix").

## 1. Baseline state at entry (v4.3.2B)

```
HEAD                       = origin/main = 224e539
Production count           = 477  (251 M1 + 49 M2 + 85 M3 + 92 M4)
M4 status                  = Limited Beta, 92 approved
appVersion                 = 4.3.2B
SW VERSION                 = v4.3.2B
working tree               = clean
v4.3.2B manifest           = 10 / 10 blob OIDs match working tree
```

## 2. Audits

```
production audit                 : 477 / 0 / 0  PASS
M4 continuation seed (v4.3.2)    :  20 / 0 / 0  PASS
M4 polish seed (v4.3.0D)         :  19 / 0 / 0  PASS unchanged
M4 expansion seed (v4.3.0C)      :  29 / 0 / 0  PASS unchanged
M4 original seed (v4.3.0)        :  24 / 0 / 0  PASS unchanged
M3 seed                          :  24 / 0 / 0  PASS clean unchanged
M2 seed                          :  24 / 0 / 8  PASS unchanged
R29 / R71 / R72 / R44b           : 0 fires across 92 M4
M4.R73 / M4.R74 / M4.R75         : 0 fires across 20 v4.3.2 continuation
```

## 3. Signal collection inventory

### 3.1 Per-answer (in-memory) -- `recordPostflopAnswer` (index.html ~line 34193)

Pushes to `App.state.postflopDrill.answers[]`:

| Field | Stored | Source |
|---|---|---|
| scenarioId | yes | from scenario.id |
| questionType (qtype) | yes | from scenario.question.qtype |
| choiceId (selected answer) | yes | from click handler |
| tier (best/acceptable/bad/critical) | yes | from `classifyPostflopAnswer` |
| score | yes | from classification |
| isCritical | yes | from classification |
| conceptTags | yes | from scenario.conceptTags slice |

### 3.2 Per-scenario + per-conceptTag aggregates (localStorage) -- `_pfHistoryRecordAnswer` (~line 39746)

Updates `localStorage.rmtt_postflop_history.scenarios[sid]` and `.concepts[tag]`:

```
scenarios[sid]: { attempts, best, acceptable, bad, critical,
                  totalScore, lastTier, lastScore, lastSeenAt, lastSessionId }
concepts[tag] : { attempts, best, acceptable, bad, critical,
                  totalScore, lastSeenAt }
```

### 3.3 Per-session record (localStorage) -- `_pfHistoryRecordSession` (~line 39785)

**PRE-v4.3.2C state (the gap):**
```
session: { id, date, module, scenarioIds, answered, score,
           best, acceptable, bad, critical }
         // NO mode field; NO answers[] array
```

**POST-v4.3.2C fix:**
```
session: { id, date, module, mode, scenarioIds, answered, score,
           best, acceptable, bad, critical,
           answers: [ { scenarioId, questionType, choiceId, tier,
                        score, isCritical, conceptTags }, ... ] }
```

### 3.4 Field coverage table (per the brief's 23-field rubric)

| # | Field | Stored | Derivable | Status |
|---|---|---|---|---|
| 1 | module id | session.module + drill.module | yes | OK |
| 2 | scenario id | session.scenarioIds + answers[].scenarioId | yes | OK |
| 3 | question type | answers[].questionType | yes | OK (post-v4.3.2C; pre-fix only in-memory) |
| 4 | selected answer | answers[].choiceId | yes | OK (post-v4.3.2C) |
| 5 | best answer | from scenario.answer.best in pool | derivable | OK (look up scenario) |
| 6 | score tier | answers[].tier | yes | OK (post-v4.3.2C) |
| 7 | isCritical | answers[].isCritical | yes | OK (post-v4.3.2C) |
| 8 | recommendedAction | scenario field | derivable | OK (join via scenarioId) |
| 9 | actionReason | scenario field | derivable | OK |
| 10 | heroHandRole | scenario field | derivable | OK |
| 11 | handClass | scenario field | derivable | OK |
| 12 | drawCategory | scenario field | derivable | OK |
| 13 | showdownValue | scenario field | derivable | OK |
| 14 | conceptTags | answers[].conceptTags + scenario.conceptTags | yes | OK |
| 15 | turnCategory | scenario.board field | derivable | OK |
| 16 | boardChange | scenario.board field | derivable | OK |
| 17 | equityShift | scenario.board field | derivable | OK |
| 18 | drawCompletion | scenario.board field | derivable | OK |
| 19 | pairStatusChange | scenario.board field | derivable | OK |
| 20 | suitTextureTurn | scenario.board field | derivable | OK |
| 21 | difficulty | scenario field | derivable | OK |
| 22 | sourceConfidence | scenario field | derivable | OK |
| 23 | timestamp / session id | session.date + session.id | yes | OK |

**Verdict:** post-v4.3.2C, all 23 required fields are stored or derivable. Pre-v4.3.2C, fields 3-7 + 14 (per-answer detail) were in-memory only and lost on session-end persistence.

## 4. M4 BetaQA / Beta Lab dashboard review

The dashboard renderer is `_pfM4BetaQADashboardHtml` at ~line 36938; the stats helper is `_pfBetaQAStatsForModule(moduleId)` at ~line 36414. Reads `localStorage.rmtt_postflop_history.sessions[]` filtered by `module === 'pf_turn_barrel_oop_def'`.

| Question the brief asks | Dashboard answer post-v4.3.2C |
|---|---|
| 1. Which actionReasons are weak? | yes -- `out.weakActionReasons` (was empty pre-v4.3.2C; now populated from per-answer history) |
| 2. Which conceptTags are weak? | yes -- `out.weakConcepts` (latest session) + `h.concepts[tag]` (lifetime) |
| 3. Which heroHandRoles are weak? | yes -- `out.weakHeroHandRoles` (was empty pre-v4.3.2C) |
| 4. Which drawCategory spots are weak? | NO -- not aggregated by current dashboard; derivable from answers + pool join |
| 5. Which turnCategory / boardChange / drawCompletion spots are weak? | NO -- not aggregated; derivable; deferred (analytics-risk concern -- see Section 7) |
| 6. Are users over-folding / over-calling / over-raising? | partial -- `rowsByRecommendedAction` shows tier distribution per recommended action; doesn't directly compute over/under-frequency |
| 7. Are critical mistakes concentrated in specific buckets? | yes -- `out.criticalCount` + `criticalScenarioIds` + `weakActionReasons[].critCount` (post-v4.3.2C; was `criticalCount=0` regardless pre-fix) |
| 8. Are reason_choice mistakes separated from action_choice mistakes? | NO -- not currently broken out by qtype in the dashboard; derivable |
| 9. Are M4 metrics isolated from M3? | yes -- `sessions.filter(s => s.module === 'pf_turn_barrel_oop_def')` strict module-id filter |
| 10. Can we tell whether 92 scenarios is enough or which bucket needs more data? | partial -- weak-bucket signal helps after enough sessions; coverage matrix (Section 8 of this doc) shows current data-side balance |

### 4.1 Status summary

- **Already good:** module-id isolation; per-scenario + per-concept lifetime aggregates; latest-session weak-profile generation.
- **Now working post-v4.3.2C:** multi-session per-axis breakdowns (rowsByActionReason / rowsByRecommendedAction / rowsByHeroHandRole / rowsByHandClass), multi-session weakActionReasons / weakHeroHandRoles, lifetime criticalCount across sessions, weakReviewUsed flag.
- **Still missing (deferred to v4.3.3 if user signals demand):** drawCategory aggregation, turnCategory aggregation, qtype split (action_choice vs reason_choice), explicit over/under-frequency analysis, sample-size confidence intervals.
- **Misleading / deferred:** dashboard previously rendered all-zero per-axis tables silently (no warning) -- fixed by signal persistence; future polish could add a "low-sample-size" sentinel below N answers.
- **Too noisy due to low sample:** the existing "(early signal -- small sample)" copy below 3 sessions / 30 answers is correctly retained.

## 5. Weak-spot review review

`startPostflopWeakSpotReview` (~line 39379) + `_pfCurrentSessionWeakProfile` (~line 39184) + `_pfBuildWeakSpotQueue` (~line 39326) + `_pfWeakScenarioScore` (~line 39286).

| Check | Result |
|---|---|
| 1. M4-only pool routing | PASS (`getModule4Scenarios()` only) |
| 2. M4 weak-spot does NOT pool M3 | PASS (module-scoped switch on `prevDrill.module`) |
| 3. Weak buckets driven by user misses (not random) | PASS (looks for tier=bad/critical first; falls back to tier=acceptable when fewer than 2 hard misses) |
| 4. actionReason misses tracked | PASS (`actionReasonCounts` joins `byId[scenarioId].actionReason`) |
| 5. conceptTag misses tracked | PASS (`conceptCounts`) |
| 6. heroHandRole misses tracked | PASS (`heroHandRoleCounts`) |
| 7. drawCategory misses tracked | NO -- not tracked in weak profile (current rules: targetScenarioIds + targetConceptTags + targetFamilyKeys + targetActionReasons + targetHeroHandRoles) |
| 8. turnCategory / drawCompletion misses tracked | NO -- not tracked (similar to drawCategory) |
| 9. Critical mistakes prioritized appropriately | PASS (tier=critical fed into hard-miss bucket alongside bad) |
| 10. reason_choice errors not misclassified as action errors | PASS (qtype is on the answer record; `classifyPostflopAnswer` grades reason vs action distinctly via `_pfNormalizePostflopAnswer`) |
| 11. Works with low sample | PASS (soft fallback to acceptable when fewer than 2 hard misses) |
| 12. Empty-state copy is clear | PASS (M4-specific empty-state toast: "Play Module 4 sessions to unlock Turn Defense weak-spot review") |

### 5.1 Pre/post v4.3.2C weak-spot scope

- **Pre-v4.3.2C:** `_pfCurrentSessionWeakProfile(prevDrill.answers, allScenarios)` works correctly **for the in-memory just-finished session**. The dashboard's `out.lastWeakProfile` was always `null` because it tried to read from `latest.answers` which was undefined in localStorage. Single-session weak-spot review user flow was unaffected.
- **Post-v4.3.2C:** `latest.answers` is now persisted, so `out.lastWeakProfile` populates correctly across page reloads. Weak-spot review user flow is unchanged (it always read in-memory and continues to do so when launched from a just-finished session).

**Proposed minor display improvement (deferred):** the dashboard could surface "weak draw categories" and "weak turn categories" as additional axes once 4-5 user sessions of data exist. Not implemented in v4.3.2C to keep scope minimal.

## 6. Concept drill review

`startPostflopConceptDrill(conceptKey)` (~line 37575) + `_pfBuildConceptQueue` (~line 38000ish) + `_PF_CONCEPT_LIBRARY` array (~line 37650ish).

| Check | Result |
|---|---|
| 1. M4 concept drill filters M4-only pool | PASS (`getModule4Scenarios()` when `moduleForConcept === 'm4'`) |
| 2. All 12 M4 concepts represented in library | PASS (turn_equity_shift, second_barrel_defense, turn_pot_odds, turn_bluff_catcher, turn_domination_fold, turn_board_change, turn_draw_completion, turn_check_raise_value, turn_check_raise_bluff, turn_blocker_pressure, turn_slowplay_call, turn_range_disadvantage) |
| 3. Concepts with zero eligible scenarios marked or hidden | PASS (`previewOnly` flag still respected; v4.3.1 flipped all M4 entries to `previewOnly=false` after wiring) |
| 4. Surface new v4.3.2 scenarios in drills | PASS (concept drills draw from current production pool; no version filter) |
| 5. Concept-drill cap | PASS (M4 conceptLen=12; matches default M4 session length) |
| 6. Concept drill records concept-level results | PASS (`recordPostflopAnswer` persists tier counts to `h.concepts[tag]` regardless of drill mode) |
| 7. Concept mistakes feed weak-spot / BetaQA | PASS (tag-level aggregates available; weak-concept logic uses both latest-session answers and lifetime `h.concepts`) |

### 6.1 Concept coverage table (production data, M4=92)

| conceptTag | scenarios | action_choice | reason_choice | drillable |
|---|---|---|---|---|
| second_barrel_defense | 65 | 47 | 18 | yes |
| turn_check_raise_value | 26 | 23 | 3 | yes |
| turn_blocker_pressure | 25 | 17 | 8 | yes |
| turn_board_change | 25 | 19 | 6 | yes |
| turn_bluff_catcher | 23 | 18 | 5 | yes |
| turn_draw_completion | 22 | 18 | 4 | yes |
| turn_range_disadvantage | 22 | 17 | 5 | yes |
| turn_equity_shift | 21 | 17 | 4 | yes |
| turn_pot_odds | 20 | 18 | 2 | yes |
| turn_check_raise_bluff | 10 | 8 | 2 | yes |
| turn_domination_fold | 10 | 7 | 3 | yes |
| turn_slowplay_call | 7 | 4 | 3 | yes |

All 12 M4 concepts have >= 7 scenarios -- enough for reliable concept drill (12-question cap with cycling). turn_slowplay_call is the thinnest (7) but still drillable.

## 7. Coverage vs signal matrix (M4=92 production, post-v4.3.2B)

```
=== actionReason (12/12 covered) ===
                                 total  action  reason  critical
value_check_raise_turn              16     15       1        15
bluff_catch_turn                    16     12       4        10
range_disadvantage_turn_fold        10      7       3         7
domination_turn_fold                 7      5       2         5
equity_realization_turn_call         7      6       1         4
mixed_indifference_turn              7      5       2         5
protection_check_raise_turn          6      6       0         6   THIN-REASON
blocker_check_raise_turn             6      2       4         2
slowplay_turn_call                   5      2       3         2
board_change_fold                    5      4       1         4
pot_odds_turn_call                   4      4       0         1   THIN total<5 + THIN-REASON
semi_bluff_check_raise_turn          3      3       0         3   THIN total<5 + THIN-REASON

=== recommendedAction ===
call=32, check_raise_small=28, fold=22, mixed=7, check_raise_big=3

=== heroHandRole (10 of 14 enum values; 4 unused are draw_intensifier-irrelevant) ===
nutted_value=14, give_up=14, bluff_catcher=15, strong_value=10, combo_draw=9,
dominated_marginal=9, marginal_made_hand=6, blocker_bluff=6, slowplay_trap=5, draw=4

=== handClass (18 of 24 enum values) ===
no_pair_no_draw=20, set=9, overpair=9, top_pair_top_kicker=8, mid_pair=8,
underpair=7, straight=7, top_pair_good_kicker=4, gutshot=4, nut_flush_draw=3,
oesd=3, full_house=3, flush_draw=2, top_pair_weak_kicker=1, backdoor_only=1,
combo_draw=1, flush=1, nut_flush=1

=== drawCategory ===
none=56, backdoor_only=10, gutshot=9, nut_flush_draw=8, oesd=6, flush_draw=2, combo_draw=1

=== turnCategory ===
draw_intensifier=18, brick=16, straight_complete=16, board_pair=15, overcard=15, flush_complete=12

=== boardChange ===
polarizing=28, draw_added=18, brick=16, counterfeit=15, range_shift_btn=11, range_shift_bb=4

=== drawCompletion ===
none=43, straight_completed=16, flush_completed=12, oesd_added=12, gutshot_added=9

=== sourceConfidence ===
expert_judgment=84, consensus_gto=8 (8.7%; conservative as designed)

=== difficulty ===
diff=2: 9, diff=3: 48, diff=4: 25, diff=5: 10
```

### 7.1 Signal-usability assessment

- **All 12 actionReasons represented; 6 of 12 have >=5 scenarios; 9 of 12 have >=5 scenarios. 3 thin reasons (pot_odds 4, semi_bluff 3, slowplay 5) -- all retain at least 1 reason_choice variant except pot_odds, semi_bluff, protection (0 reason_choice).** -- For BETA SIGNAL purposes this is enough to detect lifetime weakness once users have ~5-10 sessions.
- **All 12 concepts >=7 scenarios.** Concept drill is reliable.
- **All 5 actions covered.** Action-distribution analysis (over-fold/over-call) workable.
- **Critical density 64/92 = 69.6%** within target band; feeds critical-mistake monitor.

## 8. Analytics risk: boardAbsoluteTexture vs scenarioTeachingAxis

### 8.1 The risk

v4.3.2B established that the same physical board can carry different `turnCategory` / `boardChange` / `equityShift` / `drawCompletion` classification across scenarios:

- **R1 QcQd on Ts 8s 4d / 7c** -- $f8R1 board variant: `turnCategory=straight_complete`, `boardChange=polarizing`, `equityShift=polarizes_btn`, `drawCompletion=straight_completed` (bluff-catcher framing).
- **A5 AsQs on same physical board** -- $f8 board: `turnCategory=draw_intensifier`, `boardChange=draw_added`, `equityShift=improves_bb_draws`, `drawCompletion=oesd_added` (semi-bluff NFD framing).
- **A7 TcTd on same physical board** -- $f8 board: `turnCategory=draw_intensifier` etc. (top-set value-raise framing).

This is intentional: the metadata describes the **scenarioTeachingAxis** (which axis the lesson emphasizes), not the **boardAbsoluteTexture** (the physical card structure).

### 8.2 Audit of current analytics paths

| Path | Aggregates by | Treats as |
|---|---|---|
| Dashboard `rowsByActionReason` | scenario.actionReason | scenarioTeachingAxis (per-scenario; safe) |
| Dashboard `rowsByRecommendedAction` | scenario.recommendedAction | scenarioTeachingAxis (per-scenario; safe) |
| Dashboard `rowsByHeroHandRole` | scenario.heroHandRole | scenarioTeachingAxis (per-scenario; safe) |
| Dashboard `rowsByHandClass` | scenario.handClass | per-scenario (safe; not turn-axis) |
| Weak-spot `targetActionReasons` | scenario.actionReason | scenarioTeachingAxis (per-scenario; safe) |
| Weak-spot `targetHeroHandRoles` | scenario.heroHandRole | scenarioTeachingAxis (safe) |
| Weak-spot `targetFamilyKeys` | `_pfBoardFamilyKey(board)` -- derived from highCardClass + suitTexture + textureTags + paired status | board-level but uses STABLE axes (highCardClass, suitTexture) that are the same across all scenarios on a physical board |
| Weak-spot `targetConceptTags` | scenario.conceptTags | per-scenario (safe) |

### 8.3 Verdict

**Current analytics treat board metadata as scenarioTeachingAxis (correctly). No analytics path aggregates by `turnCategory` / `boardChange` / `equityShift` / `drawCompletion` across scenarios.** No live bug.

The risk would manifest IF a future dashboard added e.g. `rowsByTurnCategory` -- F8 scenarios would split into two buckets (`draw_intensifier` and `straight_complete`) despite being on the same physical board. This would be misleading at the boardAbsoluteTexture level.

### 8.4 Future schema recommendation (deferred; NOT implemented in v4.3.2C)

If/when a future sprint adds dashboard aggregation by board metadata, propose extending the schema:

```
board: {
  // existing per-scenario fields (scenarioTeachingAxis):
  turnCategory, boardChange, equityShift, drawCompletion, pairStatusChange,
  suitTextureTurn,

  // NEW per-physical-board fields (boardAbsoluteTexture):
  absoluteTurnCategory,  // canonical classification by physical card structure
  absoluteBoardChange,
  ...
}
```

Each scenario's `absolute*` fields would be derived deterministically from `flopCards` + `turnCard` (no per-author judgment); the existing `turnCategory` etc. stays as the per-scenario teaching emphasis.

This would require:
- A new auditor rule validating `absoluteTurnCategory` consistency across all scenarios on the same physical board (mechanical detection).
- Auditor extension to allow EITHER axis to be referenced in dashboard aggregations.
- Postflop concepts/taxonomy JSON extension to define the absolute-vs-teaching distinction.

**Decision:** documentation only in v4.3.2C. No schema change. No taxonomy edit. The current analytics are safe; the future risk is documented for the next architecture review (likely concurrent with v4.4.0 / Module 5 if/when that ships).

## 9. Issues found

| # | Issue | Severity | Disposition |
|---|---|---|---|
| 1 | `_pfHistoryRecordSession` does not persist per-answer detail (answers[] array). BetaQA dashboard's multi-session per-axis aggregation (`rowsByActionReason`, `rowsByRecommendedAction`, `rowsByHeroHandRole`, `rowsByHandClass`, `weakConcepts` lifetime, `weakActionReasons`, `weakHeroHandRoles`, `lastWeakProfile`, `criticalCount`) silently returns empty/zero. | high | **FIXED INLINE** in v4.3.2C per brief Section H ("localStorage/session analytics fix" allow-listed) |
| 2 | `_pfHistoryRecordSession` does not persist drill `mode`. BetaQA dashboard's `weakReviewUsed` flag is never true. | medium | **FIXED INLINE** in v4.3.2C (caller now forwards `d.mode`) |
| 3 | Dashboard does not aggregate by `drawCategory`, `turnCategory`, `boardChange`, `drawCompletion`, or by `qtype` (action_choice vs reason_choice split). | low | **deferred** -- requires dashboard rendering work; defer until user-signal cycle reveals demand |
| 4 | `targetDrawCategories` and `targetTurnCategories` not tracked by weak-spot review. | low | **deferred** -- same rationale; not blocking |
| 5 | Future risk: dashboard aggregation by board metadata could misclassify same physical board if metadata is treated as boardAbsoluteTexture instead of scenarioTeachingAxis. | low (no live bug) | **documented** as future schema recommendation; no fix applied |
| 6 | Coverage thinness: `pot_odds_turn_call` (4), `semi_bluff_check_raise_turn` (3) thin; `protection_check_raise_turn` no reason_choice. | low | **acceptable** for Limited Beta signal collection; revisit in v4.3.3 if user signals show weakness in these specific reasons |

## 10. Fixes applied

### 10.1 `_pfHistoryRecordSession` -- persist per-answer detail + mode

**File:** `index.html`. **Function:** `_pfHistoryRecordSession` (~line 39785). **Caller:** session-completion path (~line 39501).

Pre-fix: persisted session record was `{ id, date, module, scenarioIds, answered, score, best, acceptable, bad, critical }`. Per-answer detail (tier, choiceId, conceptTags) lost on session end.

Post-fix: persists a compact `answers[]` array mirroring the in-memory `App.state.postflopDrill.answers` shape (scenarioId, questionType, choiceId, tier, score, isCritical, conceptTags). Persists `mode` field (default 'normal'). No new dependencies; no schema migration; pre-fix sessions already in localStorage continue to work (dashboard handles missing answers[] defensively via `Array.isArray(sObj.answers) ? sObj.answers : []`).

**localStorage budget check:** ~80 bytes per answer x 12 answers per session x 50-session cap = ~48 KB. Far below browser localStorage quota (~5-10 MB).

**Strategy / scoring / UI / route impact:** none. The fix only adds fields to the persistence layer that the dashboard already expects to read.

**Pre/post regression check:**
- production audit: 477 / 0 / 0 PASS unchanged
- M4 continuation seed: 20 / 0 / 0 PASS unchanged
- All seed audits unchanged
- R29 / R71 / R72 / R44b / R73 / R74 / R75: 0 fires unchanged

### 10.2 Caller -- forward `d.mode` to session record

Caller at session completion path (~line 39501) now passes `mode: d.mode || 'normal'`. The drill state's `.mode` is set to `'weak_spots'` by `startPostflopWeakSpotReview` and `'concept'` by `startPostflopConceptDrill`. Default `'normal'` is used for direct M4 sessions. The dashboard's `if (sObj.mode === 'weak_spots') weakReviewSeen = true` check now functions as designed.

## 11. Version / cache decision

Runtime change to `index.html` (`_pfHistoryRecordSession` function body + caller's session-record arg) requires cache invalidation:

```
appVersion        : 4.3.2B  ->  4.3.2C
SW VERSION        : v4.3.2B ->  v4.3.2C
```

v4.3.1B `@media (max-width: 359px)` mobile fix preserved unchanged.
postflop_scenarios.json unchanged (no scenario data touched).
postflop_concepts.json + postflop_taxonomy.json unchanged.
M1/M2/M3 strategy fields unchanged.

## 12. Decision framework for next sprint

### 12.1 Option A -- collect Beta Lab user signals first (RECOMMENDED)

**Trigger:** Now that v4.3.2C makes per-axis dashboard aggregation actually work, the user can play M4 for one feedback cycle and the dashboard will surface real signals.

**Objective thresholds for moving on:**

| Threshold | Min |
|---|---|
| M4 sessions completed | 5 |
| M4 hands answered | 60 (5 sessions x 12 questions) |
| actionReason coverage in user history | >= 8 of 12 reasons hit |
| conceptTag coverage in user history | >= 8 of 12 concepts hit |
| Critical mistake distribution interpretable | >= 3 distinct critical buckets surfaced |
| Weak-review usage | at least 1 weak-spot review session played |
| reason_choice accuracy distinct from action_choice accuracy | both >= 30% answer volume |

If after reaching these thresholds the dashboard reveals concentrated weakness in a specific bucket, prioritize **Option B** targeted to that bucket. Otherwise consider **Option C**.

### 12.2 Option B -- v4.3.3 user-signal-driven M4 continuation

**Trigger:** Beta signals show concentrated weakness in 1-3 specific actionReasons / heroHandRoles / boards.

**Authoring discipline:**
- Add 8-18 scenarios ONLY in identified weak buckets.
- Target M4 100-110 only if user signals justify.
- Continue source-of-truth-first authoring (separate v4.3.3 builder).
- Continue to grow auditor (R76+) targeting any new bug class observed during authoring.

**Forbid:** generic gap-fills not justified by user signals.

### 12.3 Option C -- v4.4.0 Module 5 (River Defense OOP) Architecture

**Trigger:** M4 user signals confirm M4 is mature (no concentrated weakness), curriculum stays balanced, reason_choice accuracy >= 60% on average, critical-mistake rate stable at 5-15% (neither too high indicating misdesign nor too low indicating too easy).

**Architecture pattern:** mirror v4.2.0 / v4.3.0 planning sprints. River-defense OOP with a similar combinatorial expansion path.

**Forbid:** starting v4.4.0 without M4 user-signal evidence.

### 12.4 Decision logic

```
if (M4 sessions < 5)             -> Option A
elif (concentrated weakness)     -> Option B
elif (M4 mature signals)         -> Option C
else                             -> Option A (more data needed)
```

## 13. Files modified

```
M index.html             (signal-persistence fix + appVersion bump)
M service-worker.js      (VERSION bump only)
A docs/specs/postflop-v4.3.2C-module4-beta-signal-review.md  (this doc)
M PROJECT_STATE.md       (state-doc reconcile)
M TASK_BOARD.md          (state-doc reconcile)
A GPT AUDIT/v4.3.2C/     (local-only snapshot; gitignored)
```

**No scenario / data / strategy / taxonomy / concepts changes.**

## 14. Forbidden files unchanged (byte-identical)

```
postflop/postflop_scenarios.json                 -- byte-identical
all v4.3.0 / v4.3.0C / v4.3.0D / v4.3.2 builders -- byte-identical
all v4.3.0 / v4.3.0C / v4.3.0D / v4.3.2 seed JSONs -- byte-identical
all migration tools (B/C/D/v4.3.2)               -- byte-identical
v4.3.0C1 hotfix tool                             -- byte-identical
v4.3.2A hotfix tool                              -- byte-identical
v4.3.2B hotfix tool                              -- byte-identical
audit-postflop-ps.ps1 (R55-R72 unchanged)        -- byte-identical
M2/M3/M4 seed auditors                           -- byte-identical
audit-postflop-module4-continuation-v4.3.2.ps1   -- byte-identical
ranges.json, manifest.json, preflop data         -- byte-identical
gamification/shop/wardrobe/field-fx              -- byte-identical
M1/M2/M3 strategy fields                         -- byte-identical
postflop/postflop_concepts.json                  -- byte-identical (51 concepts)
postflop/postflop_taxonomy.json                  -- byte-identical
v4.3.2 doc / v4.3.2A doc / v4.3.2B doc           -- byte-identical (not re-edited)
```

## 15. Final recommendation

**SHIP v4.3.2C and immediately enter Option A (collect user signals).**

The signal-persistence fix unblocks the BetaQA dashboard's multi-session aggregation, which has been silently empty since v4.2.6 BetaQA introduction. With this fix in place, real-user signals can drive the v4.3.3-vs-v4.4.0 decision objectively. The 92-scenario M4 corpus is balanced enough for signal-collection purposes (12/12 actionReasons, 12/12 concepts, all 5 actions, 19 unique boards, 8.7% consensus_gto, 69.6% critical density).

**DO NOT auto-start v4.3.3 or v4.4.0 without at least one user-signal cycle of M4 play with the v4.3.2C dashboard fix in place.**
