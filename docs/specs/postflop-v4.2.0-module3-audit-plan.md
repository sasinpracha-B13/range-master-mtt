# Postflop v4.2.0 — Module 3 Audit Plan

**Status:** Planning-only. Defines the audit rules to be implemented in v4.2.1 against the v4.2.0 seed JSON.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.0-module3-architecture.md`, `postflop-v4.2.0-module3-schema-taxonomy.md`, `postflop-v4.2.0-module3-seed-scenarios.json`

---

## 1. Purpose

This doc defines the audit rules that will run against `docs/specs/postflop-v4.2.0-module3-seed-scenarios.json` once the v4.2.1 seed auditor is implemented. The rules mirror the v4.1.3 Module 2 seed auditor (`tools/audit-postflop-module2-seed.ps1`) with M3-specific extensions.

**Implementation strategy for v4.2.1:**
- Extend the existing M2 seed auditor with a `-Module 3` switch that swaps the rule set, **OR**
- Create a sibling `tools/audit-postflop-module3-seed.ps1` mirroring M2's structure.

The audit plan below is implementation-agnostic — it describes *what* to check, not *how* to wire it.

---

## 2. Rule categories (12)

| # | Category | Rule count | Severity |
|---|---|---|---|
| 1 | Mechanical card validation | 4 | hard error |
| 2 | Board / hand collision | 2 | hard error |
| 3 | Board texture validation | 3 | hard error + 1 warning |
| 4 | Spot assumption validation | 5 | hard error |
| 5 | Action choice validation | 3 | hard error |
| 6 | Reason choice validation | 3 | hard error |
| 7 | handClass / role / draw validation | 4 | hard error + 2 warnings |
| 8 | bestAnswer / acceptable / critical consistency | 4 | hard error |
| 9 | Explanation completeness | 4 | hard error + 2 warnings |
| 10 | Concept tag validation | 3 | hard error + 1 warning |
| 11 | sourceConfidence honesty | 2 | hard error + 1 warning |
| 12 | Coverage / distribution warnings | 5 | warnings only |

**Total: 38 hard rules + 7 soft warnings.**

---

## 3. Detailed rules

### 3.1 Mechanical card validation (4 hard errors)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R01 | Each board card must be a valid 2-char card code (rank + suit, e.g., `As`, `Td`, `2c`) | hard | Use existing card regex from M2 auditor |
| M3-R02 | Board must have exactly 3 cards | hard | Flop only in v4.2.0 |
| M3-R03 | Hero hand must have exactly 2 cards | hard | NLH |
| M3-R04 | All cards (board + hero) are distinct | hard | No card appears in board AND hero hand, no duplicates within hand or within board |

### 3.2 Board / hand collision (2 hard errors)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R05 | No card in heroHand appears in board.cards | hard | Cross-collision check (subset of R04 above; called out separately for clarity) |
| M3-R06 | Card suits valid: {s, h, d, c}; ranks valid: {2,3,4,5,6,7,8,9,T,J,Q,K,A} | hard | |

### 3.3 Board texture validation (3 hard + 1 warning)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R07 | board.boardKind ∈ {`A_high`, `K_high`, `Q_high`, `J_high`, `T_high`, `low`} | hard | Reused from M2 vocabulary |
| M3-R08 | board.suitTexture ∈ {`rainbow`, `two_tone`, `monotone`} | hard | |
| M3-R09 | board.textureTags ⊆ {`dry`, `static`, `semi_dry`, `wet`, `very_wet`, `connected`, `paired`, `broadway_heavy`, `low`} | hard | Same taxonomy as M1/M2 |
| M3-R10 | board.highCardClass matches the highest card on the board | warning | Soft check; some scenarios may use boardKind ≠ highCardClass intentionally |

### 3.4 Spot assumption validation (5 hard)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R11 | spot.format == `NLH_MTT` | hard | |
| M3-R12 | spot.stackDepth == `100BB` | hard | |
| M3-R13 | spot.potType == `SRP` | hard | |
| M3-R14 | spot.heroPosition == `BB` AND spot.villainPosition == `BTN` | hard | |
| M3-R15 | spot.villainAction == `cbet` AND spot.villainSizing ∈ {`small`, `big`} | hard | v4.2.0 seeds all use `small`; future expansion allows `big` |

### 3.5 Action choice validation (3 hard)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R16 | If question.qtype == `action_choice`, question.choices == `["fold", "call", "check_raise_small", "check_raise_big", "mixed"]` exactly | hard | Same array order required for runtime UI consistency |
| M3-R17 | recommendedAction ∈ {`fold`, `call`, `check_raise_small`, `check_raise_big`, `mixed`} | hard | |
| M3-R18 | answer.best (when qtype == `action_choice`) must equal recommendedAction | hard | Cross-consistency check |

### 3.6 Reason choice validation (3 hard)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R19 | If question.qtype == `reason_choice`, question.choices ⊆ {`value_raise`, `protection_raise`, `semi_bluff_raise`, `blocker_raise`, `bluff_catch`, `equity_realization_call`, `slowplay_call`, `range_disadvantage_fold`, `domination_fold`} | hard | M3 reason vocabulary (9 values, post-v4.2.2 added `slowplay_call`) |
| M3-R20 | actionReason ∈ {`value_raise`, `protection_raise`, `semi_bluff_raise`, `blocker_raise`, `bluff_catch`, `equity_realization_call`, `slowplay_call`, `range_disadvantage_fold`, `domination_fold`} | hard | |
| M3-R21 | answer.best (when qtype == `reason_choice`) must equal actionReason | hard | Cross-consistency check |

### 3.7 handClass / heroHandRole / drawCategory validation (4 hard + 2 warnings)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R22 | handClass ∈ M2 v4.1.2 vocabulary (set, top_two_pair, top_pair_*, mid_pair, bottom_pair, overpair, underpair, combo_draw, oesd, gutshot, flush_draw, nut_flush_draw, backdoor_only, no_pair_no_draw, straight, flush, nut_flush, trips, full_house, two_pair) | hard | Reused vocabulary; no new values in v4.2.0 |
| M3-R23 | drawCategory ∈ {`none`, `backdoor_only`, `gutshot`, `oesd`, `flush_draw`, `combo_draw`, `nut_flush_draw`} | hard | |
| M3-R24 | showdownValue ∈ {`none`, `low`, `decent`, `high`, `nutted`} | hard | |
| M3-R25 | heroHandRole ∈ {`nutted_value`, `strong_value`, `marginal_made_hand`, `bluff_catcher`, `semi_bluff_combo`, `pure_draw`, `blocker_bluff`, `give_up`, `dominated_marginal`} | hard | M2 set + 2 M3-specific (`bluff_catcher`, `dominated_marginal`) |
| M3-R26 | If handClass == `set`, the matching pocket pair value appears on board exactly once | warning | Sanity check on set classification |
| M3-R27 | If drawCategory == `flush_draw`, hero must have ≥ 1 card matching the dominant board suit (with board having ≥ 2 of that suit) OR hold 2 cards of a suit with ≥ 1 board card same suit | warning | Sanity check on flush_draw classification (covers 1-card FD on monotone) |

### 3.8 Best / acceptable / bad / critical consistency (4 hard)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R28 | answer.best is a single string from question.choices | hard | |
| M3-R29 | answer.acceptable is an array (possibly empty) of strings from question.choices, excluding answer.best | hard | |
| M3-R30 | answer.bad is an array of strings from question.choices, disjoint from {answer.best} ∪ answer.acceptable | hard | |
| M3-R31 | answer.critical is a subset of answer.bad | hard | A critical mistake is a particularly bad version of a bad option |

### 3.9 Explanation completeness (4 hard + 2 warnings)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R32 | explanation.short is non-empty string | hard | |
| M3-R33 | explanation.rangeContext is non-empty string | hard | |
| M3-R34 | explanation.handLogic is non-empty string | hard | |
| M3-R35 | explanation.takeaway is non-empty string | hard | |
| M3-R36 | explanation.defenseLogic is non-empty string | warning | Required for v4.2.4 productionization but optional in v4.2.0 |
| M3-R37 | explanation.commonMistake is non-empty string | warning | Recommended for teaching value |

### 3.10 Concept tag validation (3 hard + 1 warning)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R38 | conceptTags is a non-empty array of strings | hard | |
| M3-R39 | conceptTags ⊆ {M3 planned: `oop_defense_threshold`, `check_raise_value`, `check_raise_bluff`, `bluff_catchers`, `equity_realization_oop`, `range_disadvantage`, `pot_odds_defense`} ∪ {M2 reusable: `pot_control`, `value_raise`, `protection_raise`, `semi_bluff_raise`} | hard | M3 + selected M2 reusable |
| M3-R40 | conceptTags has 1–4 entries | hard | Avoid over-tagging |
| M3-R41 | At least 1 conceptTag must be M3-native (not M2-only) | warning | Encourages M3 module identity in tagging |

### 3.11 sourceConfidence honesty (2 hard + 1 warning)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R42 | sourceConfidence ∈ {`expert_judgment`, `consensus_gto`, `solver_run`} | hard | |
| M3-R43 | If sourceConfidence == `consensus_gto` or `solver_run`, scenario must include a `sourceCitation` field (currently optional) — flag as missing | hard if cited level claimed without citation, soft warning if `expert_judgment` claimed for a scenario that looks like a textbook GTO line | Tightens v4.1.5 honesty rule |
| M3-R44 | All v4.2.0 seeds default to `expert_judgment` | warning | If a v4.2.0 seed claims `consensus_gto` without a solver run, flag |

### 3.12 Coverage / distribution warnings (5 warnings)

| ID | Rule | Severity | Notes |
|---|---|---|---|
| M3-R45 | Total scenarios should be 24 in v4.2.0 | warning | Target check |
| M3-R46 | Question type distribution should be 18 action_choice + 6 reason_choice | warning | |
| M3-R47 | Each board family (6 boards) should have 4 scenarios | warning | |
| M3-R48 | At least 1 scenario per major action (fold / call / check_raise_small / check_raise_big) | warning | Coverage check |
| M3-R49 | check_raise_big appears at most 2 times across all 24 seeds | warning | Polar action discipline (architecture §10 risk #8) |

---

## 4. Pass / warn / fail criteria

| Verdict | Meaning |
|---|---|
| **PASS** | All hard rules (M3-R01..R40, R42) pass. Warnings allowed. |
| **WARN** | All hard rules pass but some warning rules trigger. Acceptable for planning JSON; should be reviewed before v4.2.3 migration. |
| **FAIL** | One or more hard rules fail. Must be fixed before any GPT review or migration. |

**Expected v4.2.0 outcome:** PASS with some warnings (coverage checks, possibly `defenseLogic` if any scenario omitted it).

---

## 5. Audit invocation (planned for v4.2.1)

```powershell
powershell -ExecutionPolicy Bypass -File ".\tools\audit-postflop-module3-seed.ps1"
```

Or, if extending the M2 auditor:

```powershell
powershell -ExecutionPolicy Bypass -File ".\tools\audit-postflop-module2-seed.ps1" -Module 3
```

Output format mirrors M2: hard error count, warning count, per-rule breakdown, summary table.

---

## 6. Production audit (R30-R41 implemented in v4.2.3)

When v4.2.3 migrates seeds to production data, the production auditor (`tools/audit-postflop-ps.ps1`) gets new rules R30-R41 to enforce the M3 schema on `module === 'pf_flop_cbet_oop_def'` scenarios. **Note:** R29 was claimed by the v4.2.2D/E card-notation guard, so M3 production rules begin at R30 (not R29 as originally planned in the v4.2.0 audit-plan draft).

| Production rule (implemented v4.2.3) | Mirrors | Notes |
|---|---|---|
| R30 | M3-R11..R15 (spot assumption) | NLH_MTT, 100BB, SRP, BB vs BTN, villainAction=cbet, villainSizing=small |
| R31 | M3-R16..R18 (action choices) | choices = ["fold","call","check_raise_small","check_raise_big","mixed"] |
| R32 | M3-R19..R21 (reason choices) | 9 reasons including post-v4.2.2 `slowplay_call` |
| R33 | M3-R22..R25 (vocabulary) | M2 handClass set + M3 heroHandRole including `bluff_catcher`/`dominated_marginal` |
| R34 | M3-R28..R31 (answer consistency) | answer.best is single string; acceptable/bad/critical disjoint |
| R35 | M3-R32..R36 (explanation) | short / rangeContext / handLogic / takeaway required + defenseLogic required |
| R36 | M3-R38..R40 (concept tags) | 1–4 tags from M3 + reusable M2 vocabulary |
| R37 | M3-R42..R43 (sourceConfidence honesty) | expert_judgment + solver claims need solverRunRef |
| R38 | New: villainAction must be `cbet` for M3 (until donk-bet decisions are added in M4+) | hard error |
| R39 | New: villainSizing must match the c-bet sizing trained (currently `small` only) | hard error |
| R40 | M3 hero hands must not collide with board (explicit re-check for M3 module on top of R02) | hard error |
| R41 | New: M3 scenarios must have `module === 'pf_flop_cbet_oop_def'` | hard error (mostly trivial — guards against typos) |

These production rules are implemented in v4.2.3 and apply only when `module === 'pf_flop_cbet_oop_def'`.

---

## 7. Audit gates summary

| Gate | v4.2.0 expected | v4.2.1 expected | v4.2.3 expected (post-migration) |
|---|---|---|---|
| Production audit | 300 / 0 / 0 (unchanged) | 300 / 0 / 0 (unchanged) | **324 / 0 / 0** (after migration of 24 M3 seeds) |
| M2 seed audit | 24 / 0 / 8 (unchanged) | 24 / 0 / 8 (unchanged) | 24 / 0 / 8 (unchanged) |
| **M3 seed audit (new in v4.2.1)** | not implemented | **24 PASS / 0 hard errors / N warnings** | 24 / 0 / N (unchanged after migration) |
| R29 card-notation guard | not applicable | not applicable | **0 warnings** (M3 text passes the v4.2.2D/E text-integrity guard) |

Where N is the warning count from M3-R45..R49 coverage rules plus any `defenseLogic` warnings.

---

## 8. Audit plan sign-off

This audit plan is **planning-only**. No auditor code is written in v4.2.0. The plan is approved for v4.2.1 implementation if and only if:

1. ✅ All 38 hard rules + 7 warnings are precisely defined.
2. ✅ Vocabulary references match the schema/taxonomy doc.
3. ✅ Production-audit rules (R29-R40) are forward-planned but not implemented.
4. ✅ The PASS/WARN/FAIL criteria are unambiguous.

Status: ✅ All four conditions met. Approved for v4.2.1 implementation.
