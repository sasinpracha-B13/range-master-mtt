# Postflop v4.3.0C1 -- Module 4 Expansion Raw Content Hotfix

**Date:** 2026-05-07
**Predecessor:** v4.3.0C (M4 24 -> 53 expansion)
**Sprint type:** content hotfix (no scenario count change, no runtime wiring)
**Status:** complete

## 1. Purpose

v4.3.0C migrated 29 new M4 expansion scenarios into production (24 -> 53)
and the mechanical audit passed at 438 / 0 / 0. Subsequent raw-content QA
caught two scenario-level defects that the mechanical auditor was not
designed to detect, plus a metadata mistake. v4.3.0C1 is a targeted
hotfix that:

- corrects the two scenario defects at the canonical-builder source of
  truth and re-syncs only those two IDs into production;
- adds a new auditor rule (R72) that hardens against the class of defect
  that escaped the v4.3.0C audit;
- bumps cache / version strings so users pick up the corrected data.

No new scenarios are authored. The 53-scenario M4 corpus is unchanged in
size. Module 4 remains preview-locked at the runtime layer (no
`TRAINING_MODES.postflop.actions.m4`, no `postflop:m4` route).

## 2. Defects fixed

### 2.1 -- Scenario `pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_7s6h_v430C`

Defect: false gutshot claim plus self-correction prose left in
`explanation.turnLogic`.

Hero hand `7s6h` on board `Ac 7d 2s 4h` produces hero+board ranks
`{2, 4, 6, 7, A}`. To make a 5-card straight from this rank set hero
needs **two** more ranks (3 + 5 for `3-4-5-6-7`, or 5 + 8 for
`4-5-6-7-8`). No single river card completes a straight, so hero does
not have a one-card gutshot. The original v4.3.0C draft labelled the
hand `drawCategory='gutshot'` with `actionReason='equity_realization_turn_call'`
and the `turnLogic` field contained an unresolved authoring
self-correction beginning `"... wait need 3+5; actually 4-5-6-7..."`.

Fix:

| field             | before                              | after                          |
|-------------------|-------------------------------------|--------------------------------|
| handClass         | `mid_pair`                          | `mid_pair` (unchanged)         |
| heroHandRole      | `marginal_made_hand`                | `bluff_catcher`                |
| drawCategory      | `gutshot`                           | `none`                         |
| actionReason      | `equity_realization_turn_call`      | `bluff_catch_turn`             |
| blockerNote       | `null`                              | explicit "no straight draw" note that names the missing 3+5 / 5+8 pair |
| explanation.*     | contained "... wait need 3+5..." in `turnLogic`; claimed gutshot in `handLogic`/`takeaway`/`commonMistake`/`uniquenessNote` | rewritten to no-draw bluff-catch framing; no "wait..." artifacts |
| conceptTags       | `turn_pot_odds, turn_bluff_catcher, second_barrel_defense` | `turn_bluff_catcher, second_barrel_defense, turn_range_disadvantage` |
| recommendedAction | `call`                              | `call` (unchanged)             |
| answer            | best=call, acceptable=mixed         | unchanged                       |

The recommended action is still `call`, but the *justification* changes
from "multi-source equity (gutshot + pair)" to "showdown bluff-catch
with naked middle pair". This is a strictly more accurate description
of the hand and avoids teaching a poker fiction.

### 2.2 -- Scenario `pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_action_9d6d_v430C`

Defect: prose artifact in `explanation.turnLogic` --
`"Loses only to JT and J9 (J9 makes 7-8-9-T-J wait needs J actually impossible without J on board)"`.

Hero `9d6d` on `Ts 8s 4d 7c` makes `6-7-8-9-T = T-high straight`. The
strategic verdict (check-raise small for value) and `handClass=straight`
classification are correct. The defect is purely in the prose:

- the unresolved `"wait needs J actually impossible without J on
  board"` self-correction was shipped instead of revised away;
- `JT` was incorrectly listed alongside `J9` as a higher straight. With
  hero `9d6d` and board `Ts 8s 4d 7c`, villain holding `JT` makes pair
  of tens with J kicker (board has `T,8,7,4`), not a higher straight.
  Only `J9` makes the higher `7-8-9-T-J` straight.

Fix:

| field         | before                                                                 | after |
|---------------|------------------------------------------------------------------------|-------|
| handClass     | `straight`                                                             | `straight` (unchanged) |
| drawCategory  | `none`                                                                 | `none` (unchanged) |
| actionReason  | `value_check_raise_turn`                                               | `value_check_raise_turn` (unchanged) |
| blockerNote   | "Hero made T-high straight 6-7-8-9-T (second-nut behind J9)."          | clarifies that the only higher straight is `7-8-9-T-J` requiring `J9` in villain |
| explanation.turnLogic | contained `"Loses only to JT and J9 (...wait needs J actually impossible without J on board)"` | rewritten: only `J9` is the threat; sets/two-pair/Tx are behind |
| explanation.handLogic | echoed the JT-also-beats claim | hero loses only to `J9`; beats `Tx`/overpairs/sets/two-pair/draws |
| explanation.{sizingLogic, commonMistake, takeaway} | minor parallel cleanup | aligned with corrected blockerNote |

The recommended action and the strategic recommendation are unchanged.

### 2.3 -- Metadata `expansionStats.finalProductionTarget`

Before: `"52 (24 baseline + 28 new)"`
After: `"53 (24 baseline + 29 new)"`

The original v4.3.0C builder wrote a stale target reflecting an
earlier 28-scenario plan. The actual count was always 29 / 53.

## 3. Source-of-truth discipline

The fixes were applied at the **canonical builder**
(`tools/build-m4-expansion-v4.3.0C.ps1`) first, then propagated:

1. Edit canonical builder `tools/build-m4-expansion-v4.3.0C.ps1`.
2. Regenerate `docs/specs/postflop-v4.3.0C-module4-expansion-seeds.json`
   via the builder running in a child PowerShell process with
   `-ExecutionPolicy Bypass -NoProfile -File`. (No Invoke-Expression.)
3. Run `tools/hotfix-module4-v4.3.0C1.ps1` to apply the corrected
   strategy + prose fields from the regenerated expansion JSON onto the
   two target IDs in `postflop/postflop_scenarios.json`.
4. Re-run all audits.

The hotfix tool is idempotent and structurally minimal: it touches only
the two target IDs, preserves all 436 other scenarios byte-identically,
and aborts at any sign of drift (production count != 438, M4 count != 53,
target IDs missing, target IDs not approved, post-write field mismatch
vs source, scenario order drift).

The planning JSON `docs/specs/postflop-v4.3.0-module4-seed-scenarios.json`
(the original 24 reviewed seeds) is **not** modified by this hotfix.

## 4. R72 text-integrity guard (new auditor rule)

The class of defect in 2.1 and 2.2 is "unresolved authoring
self-correction in user-facing prose". Mechanical schema audits (R09 to
R71) cannot catch this on their own because the offending strings are
syntactically valid English. R72 adds a literal substring scan against
explanation prose and `blockerNote`:

```
case-insensitive Contains() against:
  ' wait '
  ' wait,'  ' wait.'  ' wait;'  ' wait:'  ' wait?'  ' wait!'
  'wait needs'
  'wait need '
  'actually impossible'
  '... wait'
  '...wait'
```

Any match in `explanation.{short, turnLogic, rangeContext, handLogic,
sizingLogic, commonMistake, takeaway}` or in `blockerNote` produces a
HARD error. R72 is M4-scoped in the production auditor (mirrors the
R55-R71 scoping convention) and global within the expansion auditor
(which is M4-only by construction).

R72 is a prose hygiene check, not a poker-logic check. It is
intentionally narrow so it cannot cause false positives on legitimate
content.

## 5. CR.R03 refinement (drift detection instead of mere presence)

The original CR.R03 in the expansion auditor flagged any expansion ID
present in production as a HARD error -- correct pre-migration, but
guaranteed to fire 29/29 post-migration since every expansion ID was
successfully migrated by `tools/migrate-module4-v4.3.0C.ps1`.

CR.R03 is rewritten as a **drift check**:

- if an expansion ID is in production AND every synced field matches
  the expansion source, it is the successfully-synced steady state ->
  no error;
- if an expansion ID is in production AND any synced field differs from
  the expansion source, the canonical source has drifted away from
  production (or vice versa) -> HARD error.

The synced field set is `recommendedAction, actionReason, drawCategory,
handClass, heroHandRole, showdownValue, blockerNote, conceptTags,
explanation.{short, turnLogic, rangeContext, handLogic, sizingLogic,
commonMistake, takeaway}`.

Result: pre-hotfix the auditor correctly flagged the two drifted IDs;
post-hotfix the auditor passes 29 / 0 / 0.

## 6. Audit results

```
production audit:        438 / 0 / 0  PASS
M4 expansion seed audit:  29 / 0 / 0  PASS
M4 original seed audit:   24 / 0 / 0  PASS  (UNCHANGED - planning JSON not touched)
M3 seed audit:            24 / 0 / 0  PASS  (UNCHANGED)
M2 seed audit:            24 / 0 / 8  PASS  (UNCHANGED, 8 pre-existing warnings)
R72 text-integrity scan:  0 hits across 53 M4 production scenarios
R71 nut_flush_draw scan:  0 fires across 53 M4 production scenarios
```

## 7. Cache / version

```
appVersion:  '4.3.0C'  -> '4.3.0C1'   (index.html line 33226)
SW VERSION:  'v4.3.0C' -> 'v4.3.0C1'  (service-worker.js line 1)
```

The bump is for data invalidation only. No new clickable routes are
added. `TRAINING_MODES.postflop.actions` does **not** gain an `m4`
entry. There is no `postflop:m4` route. Module 4 is preview-locked.

## 8. Forbidden / untouched files

The following remain byte-identical to v4.3.0C:

```
tools/build-m4-seeds-v4.3.0.ps1
docs/specs/postflop-v4.3.0-module4-seed-scenarios.json
tools/audit-postflop-module4-seed.ps1
tools/audit-postflop-module2-seed.ps1
tools/audit-postflop-module3-seed.ps1
tools/migrate-module4-v4.3.0B.ps1
tools/migrate-module4-v4.3.0C.ps1
ranges.json / manifest.json / preflop / gamification
M1 / M2 / M3 strategy fields in postflop_scenarios.json
postflop_concepts.json
postflop_taxonomy.json
```

The auditor file changes are intentional (R72 + CR.R03 refinement) and
strictly more strict than v4.3.0C; no v4.3.0C-passing data fails under
v4.3.0C1 auditors aside from the two scenarios already targeted by the
hotfix (which the hotfix itself resolves).

## 9. Process discipline

- canonical builder edited first; production JSON synced from
  regenerated expansion JSON;
- no Invoke-Expression anywhere in the hotfix tool or in regeneration
  invocation (lesson preserved from v4.3.0B helper-script delete bug);
- no Remove-Item on production-adjacent paths; hotfix uses tmp +
  Move-Item -Force atomic write;
- ASCII-only PowerShell;
- pre-write and post-write verification both gate on production total
  = 438, M4 = 53, all approved, target IDs present, target IDs match
  source on the synced field set, scenario order preserved.

## 10. Next sprint (unchanged from v4.3.0C)

Two paths recommended for the next sprint:

PATH 1 (CONSERVATIVE): v4.3.0D additional expansion (53 -> 70+) plus
five-plus reason_choice scenarios; promote textbook spots to
consensus_gto where appropriate; then v4.3.1 runtime wire.

PATH 2 (PRAGMATIC): v4.3.1 runtime wire as Limited Beta with scaled
mastery thresholds; honest "Limited Beta -- 53 scenarios" copy; data
expansion continues in parallel as v4.3.2/3.

Project-owner decision required.
