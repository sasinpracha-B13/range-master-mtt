# Postflop v4.4.0 — Module 5 Seed Audit Plan

**Status:** Planning-only.
**Date:** 2026-06-18
**Companion to:** `postflop-v4.4.0-module5-river-defense-oop-architecture.md`, `postflop-v4.4.0-module5-schema-taxonomy.md`
**Enforced by:** `tools/audit-postflop-module5-seed.ps1` (PowerShell 5.1, ASCII-only, UTF-8 NO-BOM read)
**Target:** `docs/specs/postflop-v4.4.0-module5-seed-scenarios.json`

This document enumerates the mechanical rules the M5 seed auditor enforces. HARD = blocks the planning commit (auditor exits non-zero). WARN = advisory (does not block). The auditor mirrors the M4 seed auditor (`M4.R01..R54`) with river-specific adaptations and four new river rules (`M5.R55..R58`).

---

## Top-level rules

| Rule | Level | Check |
|---|---|---|
| M5.R01 | HARD | Seed file exists and parses as JSON (UTF-8 NO-BOM) |
| M5.R02 | HARD | Required top-level keys present: `moduleId, moduleName, version, status, schemaVersion, generatedAt, scenarios` |
| M5.R03 | HARD | `moduleId == 'pf_river_barrel_oop_def'` |
| M5.R04 | HARD | top-level `schemaVersion == '1.3.0'` |
| M5.R05 | HARD | `version` starts with `'v4.4.0'` |
| M5.R06 | HARD | `status == 'planning_only'` |
| M5.R07 | HARD | `scenarios` is an array of exactly 24 |
| M5.R08 | HARD | every scenario has a unique `id` |
| M5.R48 | HARD | 6 river categories each have exactly 4 scenarios (`brick, overcard, flush_complete, straight_complete, board_pair, scare_card`) |
| M5.R49 | HARD | each category has >= 2 `action_choice` and >= 1 `reason_choice` |

---

## Per-scenario structural rules

| Rule | Level | Check |
|---|---|---|
| M5.R09 | HARD | `id` matches `^pf_btn_v_bb_srp_100bb_river_<board>_<river>_m5_(action|reason)_<hand>_v440$` |
| M5.R10 | HARD | `module == 'pf_river_barrel_oop_def'` |
| M5.R11 | HARD | per-scenario `schemaVersion == '1.3.0'` |
| M5.R12 | HARD | `auditStatus == 'planning_only'` |
| M5.R13 | HARD | `reviewStatus == 'v4.4.0_seed_candidate'` |
| M5.R14 | HARD | `uniquenessNote` present and >= 20 chars |
| M5.R15 | HARD | `spot` block present with all required keys (incl. `riverAction`) |
| M5.R16 | HARD | `spot.format == 'NLH_MTT'`, `spot.stackDepth == '100BB'` |
| M5.R17 | HARD | `spot.heroPosition == 'BB'`, `spot.villainPosition == 'BTN'` |
| M5.R18 | HARD | `spot.street == 'river'`, `spot.potType == 'SRP'` |
| M5.R19 | HARD | `spot.heroRole == 'turn_check_caller_oop'`, `spot.villainRole == 'river_barreler_ip'` |

---

## Board rules

| Rule | Level | Check |
|---|---|---|
| M5.R20 | HARD | `board` block present with all required keys (`flopCards, turnCard, riverCard, cards, boardKind, suitTextureFlop, suitTextureTurn, suitTextureRiver, riverCategory, boardChange, runoutTexture, riverDrawCompletion, villainRiverSizing`) |
| M5.R21 | HARD | `flopCards` is 3 valid cards (`^[2-9TJQKA][cdhs]$`) |
| M5.R22 | HARD | `turnCard` and `riverCard` are valid cards |
| M5.R23 | HARD | `cards` is 5 elements equal to `flopCards + turnCard + riverCard` (order preserved) |
| M5.R24 | HARD | no duplicate cards within the board |
| M5.R25 | HARD | `riverCategory` in approved enum (9 values; 6 used in seeds) |
| M5.R26 | HARD | `villainRiverSizing` in `{small, medium, large, overbet}` |
| M5.R27 | HARD | `boardChange` in approved enum |
| M5.R28 | HARD | `runoutTexture` in approved enum |
| M5.R29 | HARD | `riverDrawCompletion` in approved enum |

---

## Hero hand / role rules

| Rule | Level | Check |
|---|---|---|
| M5.R30 | HARD | `heroHand` is 2 valid cards |
| M5.R31 | HARD | no hero/board card collision |
| M5.R32 | HARD | `heroHandRole` in M5 vocab AND `drawCategory` in `{none, busted_flush_draw, busted_straight_draw, busted_combo_draw}` |

---

## Question / answer rules

| Rule | Level | Check |
|---|---|---|
| M5.R33 | HARD | `question` block with `qtype, prompt, choices` |
| M5.R34 | HARD | `qtype` in `{action_choice, reason_choice}` |
| M5.R35 | HARD | `action_choice` choices == the 5-action menu |
| M5.R36 | HARD | `reason_choice` choices count 3..12, all in the 12-reason vocab |
| M5.R37 | HARD | `recommendedAction` in 5-action menu |
| M5.R38 | HARD | `actionReason` in the 12-reason river vocab |
| M5.R39 | HARD | `answer` block with `best, acceptable, bad, critical` |
| M5.R40 | HARD | (action_choice) `answer.best` is a single string in the 5-action menu |
| M5.R41 | HARD | (action_choice) `recommendedAction == answer.best` |
| M5.R42 | HARD | (action_choice) `best/acceptable/bad` disjoint; `critical` is a subset of `bad` |
| M5.R43 | HARD | (action_choice) `best + acceptable + bad` covers the full 5-action menu |
| M5.R44 | HARD | (reason_choice) `answer.best` is one of `question.choices` |

---

## Explanation / tagging rules

| Rule | Level | Check |
|---|---|---|
| M5.R45 | HARD | `explanation` block with `short, riverLogic, rangeContext, handLogic, sizingLogic, commonMistake, takeaway`; WARN if `riverLogic` < 60 chars |
| M5.R46 | HARD | `conceptTags` count 1..4, all in the M5 concept vocab |
| M5.R47 | HARD | `sourceConfidence` in approved set |

---

## River-specific hardening rules (NEW for M5)

| Rule | Level | Check |
|---|---|---|
| M5.R50 | HARD | `action_choice` prompt must not end with `'with '` (hero hand lost during interpolation) |
| M5.R51 | HARD | `action_choice` prompt contains both hero cards |
| M5.R52 | HARD | `handClass == 'flush'` requires 5+ of a single suit across hero+board |
| M5.R53 | HARD | `blocker_bluff` role + `blockerNote` claiming `nut-<suit>` requires hero to hold the A of that suit |
| M5.R54 | HARD | `handClass == 'straight'` requires 5 consecutive ranks (or A-2-3-4-5) across hero+board |
| **M5.R55** | **HARD** | **Busted draws never call.** If `heroHandRole == 'missed_draw'` OR `drawCategory` is a `busted_*` value, then `'call'` must NOT be `recommendedAction`, `answer.best`, or in `answer.acceptable`, and `actionReason` must not be a call-flavored reason. (The river is showdown-only; a busted draw has 0% at showdown and is fold-or-bluff-raise.) |
| **M5.R56** | WARN | **No draw-equity-realization language.** Flags M4-carryover phrasing (`equity realization`, `realize equity`, etc.) in any explanation field — the river has no equity to realize. |
| **M5.R57** | WARN | `riverLogic` should reference the river/runout/board/bet/flush/straight/pair (sanity that it describes final-street dynamics) |
| **M5.R58** | HARD | **Text integrity.** No unresolved self-correction artifacts (`wait`, `wait needs`, `actually impossible`, `... wait`) in any explanation field (mirrors M4.R72 lesson) |

---

## Cross-scenario warnings

| Rule | Level | Check |
|---|---|---|
| M5.R42 (TOP) | WARN | At least one scenario has a `critical` action (expects >= 6 teaching spots across the set) |

---

## Distribution targets (v4.4.0 seeds)

- 24 scenarios = 6 river categories x 4 each.
- 18 `action_choice` + 6 `reason_choice` (one reason_choice per category).
- The 6 reason_choice scenarios collectively exercise the river-defining reasons: `bluff_catch_river`, `range_disadvantage_river_fold`, `blocker_bluff_catch_river`, `thin_value_call_river`, `missed_draw_give_up` (and a 6th bluff_catch over-fold-trap).
- Critical-flag density target ~30-40% of the action_choice scenarios (severe punts only: folding the nuts/sets/straights/flushes/trips, calling busted air, stationing dominated pairs into completed draws vs big bets).

---

## Result format

```
M5 seed audit summary:
  scenarios   = 24
  hard errors = 0
  warnings    = 0
  result      = PASS
```

Exit code 0 on PASS (0 hard errors), 1 on FAIL.

**v4.4.0 status: 24 / 0 / 0 PASS.**
