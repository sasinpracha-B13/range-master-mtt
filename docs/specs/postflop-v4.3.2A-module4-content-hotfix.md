# Postflop v4.3.2A -- Module 4 Continuation Raw Content Hotfix

**Date:** 2026-05-07
**Sprint type:** Targeted poker/content hotfix on top of v4.3.2.
**Predecessor HEAD (entry):** `0859d2c` (v4.3.2-doc reconcile)
**Substantive predecessor:** `12ff7c1` (v4.3.2 expansion 72 -> 92)
**Status:** complete; 2 scenario-level content defects corrected; production count unchanged at 477; M4 count unchanged at 92.

## 1. Baseline state at entry (v4.3.2)

```
HEAD                       = origin/main = 0859d2c
Production count           = 477  (251 M1 + 49 M2 + 85 M3 + 92 M4)
M4 status                  = Limited Beta, 92 approved (v4.3.0 24 + v4.3.0C 29 + v4.3.0D 19 + v4.3.2 20)
appVersion                 = 4.3.2
SW VERSION                 = v4.3.2
working tree               = clean
```

**Audits at entry (all PASS):**
```
production audit           : 477 / 0 / 0
M4 continuation seed (v4.3.2)   : 20 / 0 / 0
M4 polish seed (v4.3.0D)        : 19 / 0 / 0
M4 expansion seed (v4.3.0C)     : 29 / 0 / 0
M4 original seed (v4.3.0)       : 24 / 0 / 0
M3 seed                    : 24 / 0 / 0  PASS clean
M2 seed                    : 24 / 0 / 8  PASS
R29 / R71 / R72 / R44b     : 0 fires
```

The v4.3.2 audits were structurally green. Two defects survived the
mechanical audit because they were RAW POKER MISREADS, not schema or
prose-pattern violations. Strategic review caught them post-ship.

## 2. Scenarios fixed (exactly 2)

```
pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_reason_QcQd_v432   [BLOCKER 1]
pf_btn_v_bb_srp_100bb_turn_9c6c3h_8c_m4_reason_7s5s_v432   [BLOCKER 2]
```

## 3. Poker correction summary

### BLOCKER 1 -- R1 QcQd on Ts 8s 4d 7c

**Defect.** v4.3.2 mislabelled the 7c turn on Ts 8s 4d as a "draw-intensifier"
that adds OESDs (98, J9) and gutshots (96, 65). In reality:

```
Hero+villain card pool on Ts 8s 4d 7c:
   J9 = 7-8-9-T-J         MADE STRAIGHT  (not OESD)
   96 = 6-7-8-9-T         MADE STRAIGHT  (not gutshot)
   65 = 4-5-6-7-8         MADE STRAIGHT  (not gutshot)
   98 = pair-of-8 + OESD via 6 or J  (the only legitimate draw)
   T9 = top pair + OESD via 6 or J
```

So 7c is a **straight-complete** turn that polarizes villain barrel range
into made-straight value vs air bluffs. QQ overpair-to-T is now BEHIND
every made straight (65/96/J9) and every set (TT/88/44), sitting in
**bluff-catch territory**. Raising folds out air (which we beat) and
isolates against the straight portion (which crushes us) -- bad EV.

**Strategic verdict.** CALL with `actionReason = bluff_catch_turn`
(NOT check_raise_small / protection_check_raise_turn). Acceptable
secondary reason: `pot_odds_turn_call` (overpair has sufficient one-card
equity vs polar barrel given typical sizing).

### BLOCKER 2 -- R2 7s5s on 9c 6c 3h 8c

**Defect.** v4.3.2 mislabelled hero 7s5s with bottom straight 5-6-7-8-9
as `nutted_value` / `showdownValue: nutted` and prescribed
`check_raise_small / value_check_raise_turn` framed as "charging made
flushes". In reality:

```
Board 9c 6c 3h 8c is monotone-clubs flush-complete.
Hero 7s 5s holds ZERO clubs.
Hero loses to:
   - Every made flush (Ax-clubs nut flush, KQ-clubs, JT-clubs, 2-club
     hands generally) -- significant density on monotone turn.
   - T7 made T-high straight (6-7-8-9-T).
Hero beats:
   - Every set (66/99/33/88), every two-pair, every pair, every air
     bluff. No weaker straight exists -- 5-6-7-8-9 is the lowest
     straight on this board.
```

So hero has a made hand but is BEHIND the value portion of villain's
polar barrel range (flushes + T7 straight). Made flushes are NOT a
value target; they crush hero. The right line is **call (bluff-catch)**:
capture the air bucket, do not isolate against flushes/T7.

**Strategic verdict.** CALL with `actionReason = bluff_catch_turn`.
heroHandRole reclassified `nutted_value -> bluff_catcher`. showdownValue
reclassified `nutted -> high`. Acceptable secondary reasons:
`pot_odds_turn_call` and `mixed_indifference_turn` (small-barrel sizing
can tip toward indifference).

## 4. Field-level diff summary

### R1 QcQd (8 fields synced)

| Field | Before (v4.3.2) | After (v4.3.2A) |
|---|---|---|
| recommendedAction | check_raise_small | **call** |
| actionReason | protection_check_raise_turn | **bluff_catch_turn** |
| heroHandRole | strong_value | **bluff_catcher** |
| answer.best | protection_check_raise_turn | **bluff_catch_turn** |
| answer.acceptable | [value_check_raise_turn] | **[pot_odds_turn_call]** |
| answer.bad | [10 reasons] | [10 reasons; protection_check_raise_turn now BAD] |
| question.prompt | "BB check-raises small with..." | **"BB calls with..."** |
| blockerNote | re-written | re-written |
| explanation (all 7 paragraphs) | re-written | re-written |
| conceptTags | turn_check_raise_value, turn_equity_shift, second_barrel_defense | **turn_bluff_catcher, turn_draw_completion, second_barrel_defense** |

handClass (`overpair`), drawCategory (`none`), showdownValue (`high`),
heroHand (`Qc Qd`), board (`Ts 8s 4d / 7c`) and id are unchanged.

### R2 7s5s (9 fields synced)

| Field | Before (v4.3.2) | After (v4.3.2A) |
|---|---|---|
| recommendedAction | check_raise_small | **call** |
| actionReason | value_check_raise_turn | **bluff_catch_turn** |
| heroHandRole | nutted_value | **bluff_catcher** |
| showdownValue | nutted | **high** |
| answer.best | value_check_raise_turn | **bluff_catch_turn** |
| answer.acceptable | [protection_check_raise_turn] | **[pot_odds_turn_call, mixed_indifference_turn]** |
| answer.bad | [10 reasons] | [10 reasons; value_check_raise_turn now BAD] |
| question.prompt | "BB check-raises small with..." | **"BB calls with..."** |
| blockerNote | re-written (was implicit "no club blocker") | explicit "ZERO clubs" + "loses to every made flush" |
| explanation (all 7 paragraphs) | re-written | re-written |
| conceptTags | turn_check_raise_value, turn_draw_completion, second_barrel_defense | **turn_bluff_catcher, turn_draw_completion, second_barrel_defense** |

handClass (`straight`), drawCategory (`none`), heroHand (`7s 5s`),
board (`9c 6c 3h / 8c`) and id are unchanged.

## 5. Auditor guard decision

Two NEW WARN-level rules added to
`tools/audit-postflop-module4-continuation-v4.3.2.ps1`:

### M4.R73 -- flush-complete-monotone "not-nutted" guard

> On any scenario where `board.suitTextureTurn = monotone` OR
> `board.drawCompletion = flush_completed`: if the hero hand has ZERO
> cards of the completed suit AND `handClass` is in
> `{straight, set, two_pair, top_two_pair, trips, full_house}`,
> warn if `heroHandRole = nutted_value` or `showdownValue = nutted`.

Rationale: the made-flush portion of villain barrel range beats every
non-flush made hand by definition; labelling such a hand "nutted" is
poker-incorrect on a flush-complete board where hero has no flush
blocker. WARN level (not HARD) because rare BTN-range-filtered edge
cases exist; learner discretion required to override.

R2 (7s5s on 9c6c3h8c, mislabelled `nutted_value`) would have been
caught by this rule at audit time.

### M4.R74 -- "made flushes as value target" prose scan

> On any scenario where `handClass` is not in `{flush, nut_flush, full_house}`,
> scan `explanation.{short, turnLogic, rangeContext, handLogic, sizingLogic,
> commonMistake, takeaway}` for prose patterns:
> `charges made flushes`, `charges flushes`, `charging made flushes`,
> `value from made flushes`, `extracts from made flushes`,
> `made flushes pay off`, `made flushes that call`, `made flushes call`,
> `made flushes that pay`. Warn if any pattern matches.

Rationale: framing made flushes as a value target when hero is a
non-flush hand is poker-incorrect (made flushes beat hero). WARN level
because rare boards can support exotic value lines vs filtered ranges.

R2's pre-fix prose ("charges made flushes that call") would have been
caught by this rule at audit time.

**Decision:** both WARN level, both kept inside the v4.3.2 continuation
auditor (NOT promoted to production R55-R72 auditor) because the rules
target scenario-authoring patterns that are expected to be caught
pre-migration; production-time false positives are riskier than the
incremental coverage.

## 6. Production count unchanged

```
Before: 477 (251 M1 + 49 M2 + 85 M3 + 92 M4)
After:  477 (251 M1 + 49 M2 + 85 M3 + 92 M4)
```

Hotfix tool verified: 90 of 90 non-target M4 scenarios byte-identical
pre/post; 385 non-M4 untouched; scenario-array order preserved.

## 7. M4 count unchanged

92 approved scenarios. Just two had their strategy + prose corrected.

## 8. Audit results

```
production                       : 477 / 0 / 0  PASS
M4 continuation seed (v4.3.2)    :  20 / 0 / 0  PASS  (CR.R03 drift cleared post-hotfix)
M4 polish (v4.3.0D)              :  19 / 0 / 0  PASS  unchanged
M4 expansion (v4.3.0C)           :  29 / 0 / 0  PASS  unchanged
M4 original seed (v4.3.0)        :  24 / 0 / 0  PASS  unchanged
M3 seed (v4.2.0)                 :  24 / 0 / 0  PASS  clean unchanged
M2 seed (v4.1.2)                 :  24 / 0 / 8  PASS  unchanged
R29 / R71 / R72 / R44b           : 0 fires across 92 M4
M4.R73 / M4.R74                  : 0 fires across 20 v4.3.2 continuation
```

## 9. Targeted text/poker scan

Three confirmation scans on the hotfixed production scenarios:

| Scan | Result |
|---|---|
| R1 prose: J9 / 96 / 65 framed as OESD/gutshot/draw on T-8-4-7 | **PASS (no hits)** |
| R2 prose: "made flushes" framed as value target on 9-6-3-8 monotone | **PASS (no hits)** |
| R2 role: heroHandRole != nutted_value AND showdownValue != nutted | **PASS** (bluff_catcher / high) |

## 10. Runtime smoke

`postflop_scenarios.json` size grew slightly (3,380,207 -> 3,381,491 bytes) due to longer corrected prose. M4 pool count unchanged at 92. M4 route, drill, weak-spot, mastery all rely on the SAME runtime functions (no JS changes) -- since the data shape is unchanged and only field VALUES on 2 scenarios changed, runtime behavior is unchanged.

Local browser smoke deferred to Netlify post-deploy because:
- No JS / CSS / runtime logic touched.
- The 2 hotfixed scenarios are still loadable, gradeable (answer.best is now `bluff_catch_turn` instead of `protection_check_raise_turn`/`value_check_raise_turn` -- still a valid reason_choice answer).
- The continuation seed audit + production audit confirm runtime-loadable state.

## 11. Version/cache bump

```
appVersion        : 4.3.2  ->  4.3.2A
SW VERSION        : v4.3.2 ->  v4.3.2A
```

Required because production data (postflop_scenarios.json) changed in
2 scenarios; v4.3.2 is already deployed to Netlify; cache invalidation
needed so users pick up the corrected prose / strategic verdict.

v4.3.1B `@media (max-width: 359px)` mobile fix preserved unchanged.

## 12. Files modified in v4.3.2A

```
M tools/build-m4-continuation-v4.3.2.ps1            (R1 + R2 strategic + prose fixes)
M tools/audit-postflop-module4-continuation-v4.3.2.ps1 (+M4.R73 + M4.R74 guards)
M docs/specs/postflop-v4.3.2-module4-continuation-seeds.json (regenerated)
M postflop/postflop_scenarios.json                   (2 scenarios re-synced)
M index.html                                         (appVersion 4.3.2 -> 4.3.2A only)
M service-worker.js                                  (VERSION v4.3.2 -> v4.3.2A only)
A tools/hotfix-module4-v4.3.2A.ps1                   (idempotent narrow-scope hotfix tool)
A docs/specs/postflop-v4.3.2A-module4-content-hotfix.md (this doc)
M PROJECT_STATE.md                                   (state-doc reconcile)
M TASK_BOARD.md                                      (state-doc reconcile)
A GPT AUDIT/v4.3.2A/                                 (local-only snapshot; gitignored)
```

## 13. Forbidden files unchanged (byte-identical)

```
tools/build-m4-seeds-v4.3.0.ps1                  -- byte-identical
tools/build-m4-expansion-v4.3.0C.ps1             -- byte-identical
tools/build-m4-polish-v4.3.0D.ps1                -- byte-identical
docs/specs/postflop-v4.3.0-module4-seed-scenarios.json   -- byte-identical
docs/specs/postflop-v4.3.0C-module4-expansion-seeds.json -- byte-identical
docs/specs/postflop-v4.3.0D-module4-polish-seeds.json    -- byte-identical
tools/migrate-module4-v4.3.0B.ps1                -- byte-identical
tools/migrate-module4-v4.3.0C.ps1                -- byte-identical
tools/migrate-module4-v4.3.0D.ps1                -- byte-identical
tools/migrate-module4-v4.3.2.ps1                 -- byte-identical (not re-run)
tools/hotfix-module4-v4.3.0C1.ps1                -- byte-identical
tools/audit-postflop-module4-seed.ps1            -- byte-identical
tools/audit-postflop-module4-expansion-v4.3.0C.ps1 -- byte-identical
tools/audit-postflop-module4-polish-v4.3.0D.ps1  -- byte-identical
tools/audit-postflop-module2-seed.ps1            -- byte-identical
tools/audit-postflop-module3-seed.ps1            -- byte-identical
tools/audit-postflop-ps.ps1                      -- byte-identical (R55-R72 unchanged)
M1/M2/M3 strategy fields                         -- byte-identical
ranges.json, manifest.json, preflop data         -- byte-identical
gamification/shop/wardrobe/field-fx              -- byte-identical
postflop/postflop_concepts.json                  -- byte-identical (51 concepts)
postflop/postflop_taxonomy.json                  -- byte-identical
docs/specs/postflop-v4.3.2-module4-coverage-continuation.md -- byte-identical
                                                    (v4.3.2 doc; not re-edited)
```

The 90 non-target M4 production scenarios are byte-identical pre/post
(verified by hotfix tool's post-write check); only the 2 target IDs
changed.

## 14. Known limitations

- The F8 board (`Ts 8s 4d / 7c`) carries `turnCategory: draw_intensifier`
  in the v4.3.2 continuation builder declaration (inherited from v4.3.0D
  polish builder). The strategic correction in R1 acknowledges that 7c
  IS predominantly straight-complete, but the metadata classification
  was not changed because that would require touching the v4.3.0D source
  builder (forbidden). All F8 scenarios share the same `turnCategory`
  value across builders for cross-corpus consistency. The R1 prose and
  conceptTags accurately describe the straight-completing texture; the
  metadata mismatch is documentation-only and does not affect runtime
  classification, drill routing, or feedback.

- Strategic review > mechanical audit pattern persists. v4.3.0C1 caught
  prose bugs; v4.3.1A caught a render-path framing bug; v4.3.1B caught a
  layout overflow bug; v4.3.2 caught 4 audit-driven REVISE pre-ship; now
  v4.3.2A catches 2 raw poker misreads post-ship. The auditor must KEEP
  growing teeth -- the new M4.R73 and M4.R74 are incremental coverage.

- Real-user M4 weak-spot data (via the existing Beta Lab dashboard,
  v4.3.1+) should now drive any future M4 expansion priorities rather
  than guessed gaps.

## 15. Recommendation for next sprint

**Pause M4 content authoring. Collect Beta Lab user signals.**

After at least one user-signal cycle:

- If real users are systematically misanswering specific actionReasons /
  heroHandRoles / boards, design a v4.3.3 user-signal-driven continuation
  targeting those weak spots (NOT generic gap-fills).
- If Beta Lab dashboard reveals a runtime bug (NaN, undefined, render
  error), fix it as a v4.3.x hotfix.
- If user signals confirm M4 is mature, evaluate v4.4.0 / Module 5
  (River Defense OOP) architecture sprint mirroring the v4.2.0 / v4.3.0
  planning pattern.

**Do NOT auto-start v4.3.3 or v4.4.0 without user-signal data.**
