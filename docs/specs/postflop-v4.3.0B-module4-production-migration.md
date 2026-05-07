# Postflop v4.3.0B — Module 4 Production Migration

**Status:** production_data_loaded_preview_only (M4 NOT runtime-wired)
**Sprint:** v4.3.0B
**Module:** `pf_turn_barrel_oop_def` — "Facing Turn Barrel OOP"
**Source:** `docs/specs/postflop-v4.3.0-module4-seed-scenarios.json` (24 reviewed seeds at HEAD `69fe211`)
**Target:** `postflop/postflop_scenarios.json` (385 → 409 scenarios)

This document records the v4.3.0B production migration sprint. 24 strategically-reviewed Module 4 planning seeds are migrated into production data, the production auditor is extended with M4-aware rules R55–R71, the concepts file gains 12 M4-native concepts, and the taxonomy gains M4 module entry + vocabularies + 6 new top-level enums. The cache is bumped to v4.3.0B. **Module 4 remains preview-locked at the runtime layer.**

---

## 1. Baseline state (sprint start)

| Check | Result |
|---|---|
| HEAD = origin/main | `69fe211` (v4.3.0A-doc2) |
| Working tree | clean |
| M4 seed audit | 24 / 0 hard / 0 warnings — PASS |
| Production audit | 385 / 0 / 0 — PASS |
| M2 seed audit | 24 / 0 / 8 — PASS |
| M3 seed audit | 24 / 0 / 0 — PASS clean |
| R29 card-notation guard | 0 warnings |
| Manifest verification | All 4 referenced hashes match |
| Runtime lock | M4 not present in TRAINING_MODES.postflop.actions; no `postflop:m4` route |

**ALL 8 BASELINE GATES GREEN** — migration proceeded.

---

## 2. Source-of-truth manifest verification

The v4.3.0A canonical manifest at `GPT AUDIT/v4.3.0A/MANIFEST_SHA256.txt` was verified:

| File | Expected SHA256 | Actual | Status |
|---|---|---|---|
| `postflop-v4.3.0-module4-seed-scenarios.json` | `0382789135CF39C1...` | matches | ✅ |
| `build-m4-seeds-v4.3.0.ps1` | `32BCD3D5F3889E83...` | matches | ✅ |
| `audit-postflop-module4-seed.ps1` | `EAC79F5845F70224...` | matches | ✅ |
| `postflop-v4.3.0A-module4-strategic-review-results.md` | `CB2FF90A222D044E...` | matches | ✅ |

---

## 3. Why migration now / why M4 remains preview-locked

**Why migration now:** v4.3.0A completed strategic review of all 24 seeds (13 PROMOTE / 11 REVISE / 0 REJECT), and all REVISE edits were applied builder-first. The 24 seeds are mechanically clean (M4.R01–R54 PASS) and strategically reviewed (14-point per-scenario checklist). They are migration-ready foundation data.

**Why M4 remains preview-locked:**
- 24 scenarios is a thin Beta floor (compare M3's path: 24 → 62 → 85 across v4.2.3/A/B before v4.2.4 runtime wire).
- A playable Limited Beta requires diversity across hand classes / actions / textures that 24 scenarios cannot provide.
- Stable runtime exposure requires v4.3.0C data expansion to 50+ scenarios (with continued strategic review) before v4.3.1 runtime wire.

**This sprint's deliberate scope:** load production data + extend audit/concept/taxonomy infrastructure. Do NOT runtime-wire. Do NOT make M4 playable. Do NOT add M4 to TRAINING_MODES.postflop.actions. The cache bump (4.2.6 → 4.3.0B) is for production data invalidation only — the user-facing app surface gains zero new clickable routes.

---

## 4. Migration tool

**Tool:** `tools/migrate-module4-v4.3.0B.ps1`

Properties:
- Idempotent (safe to re-run)
- UTF-8 NO-BOM I/O via `[System.IO.File]::WriteAllText`
- ASCII-clean
- Atomic write (tmp + Move-Item -Force)
- Fails loudly on input/output count mismatches
- Two modes:
  - Default (no flag): writes M4 scenarios with `auditStatus = review_pending`
  - `-FlipApproved`: flips all 24 M4 to `auditStatus = approved` (run only after audit passes at review_pending)
- `-DryRun`: print plan without writing

Pipeline:
1. Read source seed JSON; assert exactly 24 M4 planning_only seeds.
2. Read target production JSON; assert non-M4 count = 385 and existing M4 count = 0 (fresh) or 24 (re-run).
3. Transform each seed → production scenario (see Section 5).
4. Reassemble: 385 non-M4 + 24 new/re-rebuilt M4 = 409 scenarios.
5. Write atomically to `postflop/postflop_scenarios.json`.

---

## 5. Production scenario enrichment rules

Each of the 24 seeds was transformed via:

**Added (production-only fields):**
| Field | Value |
|---|---|
| `version` | `'v4.3.0B'` (sprint version tag) |
| `game` | `'NLH_MTT'` |
| `street` | `'turn'` (top-level) |
| `actionHistory` | `[]` |
| `scoring` | `{best:1, acceptable:0.5, bad:0, critical:0}` (M3 production convention with full key names) |
| `difficulty` | `difficultyHint` value, default 3 |
| `auditStatus` | `'review_pending'` initially → flipped to `'approved'` after audit |
| `reviewStatus` | `'v4.3.0A_strategic_reviewed'` (mirrors M3 convention `v4.1.9_gpt_reviewed`) |

**Stripped:**
- `difficultyHint` (replaced by `difficulty`)
- `uniquenessNote` (M3 production convention strips this; preserved in seed JSON for traceability)

**Preserved unchanged from seed:**
- `id`, `module`, `moduleName`, `schemaVersion` (=`1.2.0`)
- `spot` (M4 turn-defense lock with all fields)
- `board` (4-card structure: `flopCards` + `turnCard` + `cards` + M4-specific fields)
- `heroHand`, `handClass`, `heroHandRole`, `drawCategory`, `showdownValue`, `blockerNote`
- `recommendedAction`, `actionReason`
- `question`, `answer` (with critical-flag set + acceptable + bad)
- `explanation` (with `turnLogic` as M4-defining field)
- `conceptTags` (1–4 from M4 concept vocab)
- `sourceConfidence`

**Strategy-field survival check** (Section 12) verified all 14 spot-checked scenarios (11 REVISE + 3 random PROMOTE) preserved their strategy fields byte-equal between seed JSON and production.

---

## 6. Concepts extension summary

`postflop/postflop_concepts.json`: 39 → **51** concepts (added 12 M4-native).

Added concepts (all `category: 'module4'`):

| Key | Display name |
|---|---|
| `turn_equity_shift` | Turn equity shift |
| `second_barrel_defense` | Second-barrel defense (turn) |
| `turn_pot_odds` | Turn pot odds + equity realization |
| `turn_bluff_catcher` | Turn bluff catcher |
| `turn_domination_fold` | Turn domination fold |
| `turn_board_change` | Turn board change |
| `turn_draw_completion` | Turn draw completion |
| `turn_check_raise_value` | Turn check-raise for value |
| `turn_check_raise_bluff` | Turn check-raise as bluff/blocker |
| `turn_blocker_pressure` | Turn blocker pressure |
| `turn_slowplay_call` | Turn slowplay call |
| `turn_range_disadvantage` | Turn range disadvantage |

Each concept follows the existing M3 schema: `key`, `displayName`, `category`, `shortDef`, `longDef`, `examples`, `relatedConcepts`. No `module`/`moduleId`/`previewOnly` field (consistent with M3 concept entries which use `category` for module discrimination).

**Idempotency:** the extension script skips any key that already exists, so re-running is safe.

---

## 7. Taxonomy extension summary

`postflop/postflop_taxonomy.json` extensions:

### 7.1 New module entry

```json
"pf_turn_barrel_oop_def": {
  "displayName": "Facing Turn Barrel OOP",
  "shortDesc": "(v4.3.0B) BB facing BTN turn barrel after flop check-call. 24 production seeds; not runtime-wired in v4.3.0B (preview-locked until expansion to 50+).",
  "spot": "BTN_open_2.5x_BB_call_BTN_cbet_small_BB_call",
  "v": "v4.3.0B",
  "supportedQuestionTypes": ["action_choice", "reason_choice"],
  "validActions": ["fold","call","check_raise_small","check_raise_big","mixed"],
  "validReasons": [12 M4 turn actionReason values]
}
```

### 7.2 New vocabularies

- `heroHandRole.module4` — 13 values: `strong_value, nutted_value, bluff_catcher, marginal_made_hand, dominated_marginal, combo_draw, draw, give_up, air, bluff_candidate, blocker_bluff, slowplay_trap, protection_needed`
- `actionReason.module4` — 12 values: `pot_odds_turn_call, equity_realization_turn_call, bluff_catch_turn, board_change_fold, domination_turn_fold, range_disadvantage_turn_fold, value_check_raise_turn, protection_check_raise_turn, semi_bluff_check_raise_turn, blocker_check_raise_turn, slowplay_turn_call, mixed_indifference_turn`

### 7.3 New top-level enums (M4-specific board fields)

- `turnCategory` (12 values)
- `boardChange` (8 values)
- `equityShift` (7 values)
- `drawCompletion` (8 values)
- `pairStatusChange` (7 values)
- `suitTextureTurn` (3 values: rainbow / two_tone / monotone)

### 7.4 actionMenuByModule extension

Added: `pf_turn_barrel_oop_def: ['fold','call','check_raise_small','check_raise_big','mixed']`

---

## 8. Production auditor extension summary

`tools/audit-postflop-ps.ps1` gained M4-aware rules **R55–R71** (M4 module ID `pf_turn_barrel_oop_def`):

| Rule | Severity | Check |
|---|---|---|
| R55 | HARD | module = pf_turn_barrel_oop_def + street=turn + game=NLH_MTT + schemaVersion=1.2.0 |
| R56 | HARD | spot block matches BB-vs-BTN turn-defense lock (heroPosition=BB, villainPosition=BTN, heroRole=flop_check_caller_oop, villainRole=turn_barreler_ip) |
| R57 | HARD | 4-card board structure (flopCards length 3, turnCard valid, cards = flopCards + turnCard, no duplicates) |
| R58 | HARD | turnCategory in valid M4 enum |
| R59 | HARD | heroHand 2 cards + no hero/board collision |
| R60 | HARD | handClass / heroHandRole / drawCategory / showdownValue in M4 vocab |
| R61 | HARD | action_choice question schema; recommendedAction in valid set; answer.best == recommendedAction |
| R62 | HARD | action_choice prompt does NOT end with `with ` AND contains both hero cards (anti-regression of v4.3.0 prompt bug) |
| R63 | HARD | reason_choice schema + actionReason in v4.3.0B vocab |
| R64 | HARD | answer partition consistency: best/acceptable/bad disjoint; critical subset of bad |
| R65 | HARD | explanation has all 7 fields including `turnLogic` |
| R66 | HARD | conceptTags 1–4 unique entries from M4 concept vocab |
| R67 | HARD | auditStatus + sourceConfidence valid |
| R68 | HARD | nut_flush_draw invariant: drawCategory=nut_flush_draw requires hero to hold A of a 4-suited suit |
| R69 | HARD | "nut-<suit>" blocker invariant: blockerNote claiming nut-color requires hero A of that suit |
| R70 | HARD | handClass=straight invariant: 5 consecutive ranks (or A-2-3-4-5) in hero+board |
| **R71** | **WARN** | **NEW bidirectional nut_flush_draw invariant: hero has A-of-suit + 4-of-suit total + handClass not made-flush-class → drawCategory should be nut_flush_draw** |

### 8.1 R10 + R13 scoping change (compatibility fix)

Two general rules were scoped to non-M4 modules because they enforce flop-board fields (`rangeAdvantage`, `nutAdvantage`, `suitTexture`) that M4's 4-card board does not have:

- **R10** — advantage enums: now skips when `module === 'pf_turn_barrel_oop_def'`. M4 has its own R55+ rules.
- **R13** — contradictory tags + suit consistency: now skips when `module === 'pf_turn_barrel_oop_def'`. M4 uses `suitTextureFlop` + `suitTextureTurn` instead of single `suitTexture`.

These scoping changes are non-regressive for M1/M2/M3 — those modules still get the original R10/R13 enforcement.

### 8.2 R71 — bidirectional nut_flush_draw invariant (NEW)

**Origin:** v4.3.0A strategic review caught two scenarios (#10 AsKd, #11 AsJd) where hero held A-of-suit with 4 spades total but `drawCategory` was `flush_draw`/`none` instead of `nut_flush_draw`. R52/R68 catches the "claimed nut FD without A" direction; R71 catches the converse "has nut FD pattern but not classified".

**Implementation:** WARN-only because of edge cases (hero may simultaneously have a stronger value class like flush, set, two_pair, straight, full_house, trips). The rule triggers only when `handClass` is NOT in those made-hand classes.

**Verification:** Currently fires 0 warnings in production (all M4 nut FD scenarios are correctly classified).

### 8.3 New M4 stats block

Added a Module 4 stats block at end of audit output (mirroring M3's pattern):
- Module 4 total
- qtype distribution
- turnCategory distribution
- highCardClass distribution
- recommendedAction distribution
- auditStatus distribution

---

## 9. M4 auditStatus flow: review_pending → approved

Two-phase staged approval per directive:

**Phase 1:** Migration runs with `auditStatus = review_pending`. Production audit runs against this state.
- Result: **409 / 0 / 0 PASS** (R55-R71 + general rules all clean)

**Phase 2:** Migration re-runs with `-FlipApproved` flag, flipping all 24 M4 scenarios to `auditStatus = approved`. Production audit re-runs.
- Result: **409 / 0 / 0 PASS** (still clean; status is the only field changed)

This ensures the production rules can validate the data structure independently of the approval gate.

---

## 10. Production count before/after

| Module | Before | After | Δ |
|---|---:|---:|---:|
| `pf_board_texture` (M1) | 251 | 251 | 0 |
| `pf_flop_cbet_ip` (M2) | 49 | 49 | 0 |
| `pf_flop_cbet_oop_def` (M3) | 85 | 85 | 0 |
| `pf_turn_barrel_oop_def` (M4) | 0 | **24** | +24 |
| **TOTAL** | **385** | **409** | **+24** |

---

## 11. Audit results (final, post-approve)

| Audit | Result |
|---|---|
| **Production audit** (`audit-postflop-ps.ps1`) | **409 / 0 / 0 — PASS** |
| M2 seed audit | 24 / 0 / 8 — PASS (UNCHANGED) |
| M3 seed audit | 24 / 0 / 0 — PASS clean (UNCHANGED) |
| M4 seed audit | 24 / 0 / 0 — PASS (UNCHANGED — planning JSON not touched by migration) |
| R29 card-notation guard | 0 warnings (preserved) |
| R71 bidirectional FD warn | 0 warnings (all M4 nut FD scenarios correctly classified) |

---

## 12. Strategy-field survival check

14 scenarios checked (11 REVISE from v4.3.0A + 3 random PROMOTE):

| Field | All 14 byte-equal between seed and production? |
|---|---|
| recommendedAction | ✅ |
| actionReason | ✅ |
| answer.best | ✅ |
| answer.critical | ✅ |
| handClass | ✅ |
| heroHandRole | ✅ |
| drawCategory | ✅ |
| sourceConfidence | ✅ |
| conceptTags (count + content) | ✅ |
| explanation.turnLogic | ✅ |
| explanation.short | ✅ |

**Total mismatches: 0** — strategy content survived migration intact.

---

## 13. Version / cache bump rationale

| File | Before | After |
|---|---|---|
| `index.html` `appVersion` | `'4.2.6'` | `'4.3.0B'` |
| `service-worker.js` `VERSION` | `'v4.2.6'` | `'v4.3.0B'` |

**Why bump even though M4 is not playable:**
- Production data file changed (385 → 409 scenarios). Service worker cache invalidation is required so end-users get the new data on next load.
- Concepts file changed (39 → 51 entries).
- Taxonomy file changed (added module + vocabularies + 6 enums).
- The cache bump is for **data invalidation only**. The user-facing app surface gains zero new clickable routes — Module 4 is not added to `TRAINING_MODES.postflop.actions`.

**No runtime UI logic changed.** Only the version string was updated in index.html (line 33226) and service-worker.js (line 1).

---

## 14. Forbidden files untouched

| File | Status |
|---|---|
| `tools/build-m4-seeds-v4.3.0.ps1` | byte-identical |
| `docs/specs/postflop-v4.3.0-module4-seed-scenarios.json` | byte-identical |
| `tools/audit-postflop-module4-seed.ps1` | byte-identical |
| `tools/audit-postflop-module2-seed.ps1` | byte-identical |
| `tools/audit-postflop-module3-seed.ps1` | byte-identical |
| `ranges.json` | byte-identical |
| `manifest.json` | byte-identical |
| `preflop/*` | byte-identical |
| gamification / shop / wardrobe / field-fx | byte-identical |
| M1 / M2 / M3 strategy fields | byte-identical |
| `TRAINING_MODES.m4` logic | UNCHANGED — not added to TRAINING_MODES at all |
| Runtime routes | UNCHANGED — no `postflop:m4` route exists |

**Modified files:**
- `postflop/postflop_scenarios.json` (M4 +24)
- `postflop/postflop_concepts.json` (+12)
- `postflop/postflop_taxonomy.json` (M4 module + vocabs + enums)
- `tools/audit-postflop-ps.ps1` (R55-R71 + R10/R13 scoping)
- `index.html` (1 line — `appVersion` only)
- `service-worker.js` (1 line — `VERSION` only)

**Created files:**
- `tools/migrate-module4-v4.3.0B.ps1`
- `docs/specs/postflop-v4.3.0B-module4-production-migration.md` (this doc)
- `GPT AUDIT/v4.3.0B/` (snapshot folder + manifest)

---

## 15. Known limitation — 24 scenarios is migration-ready, NOT runtime-ready

**Migration-ready means:** the data is structurally valid, strategically reviewed, and survives the production auditor.

**NOT runtime-ready means:**
- 24 scenarios is below the threshold for a stable Limited Beta (M3 ran 62 → 85 scenarios before runtime wire in v4.2.4).
- Diversity across hand classes / actions / textures is too narrow for healthy weak-spot review surfacing.
- Mastery thresholds (sessions / cumulative answers / coverage) cannot be honestly calibrated below 50+ scenarios.

Module 4 stays preview-locked at the runtime layer. The production data is now available for offline analysis, future expansion, and v4.3.0C's data-expansion sprint to build upon.

---

## 16. Next sprint recommendation — v4.3.0C data expansion

Recommended scope for the next sprint:

1. **Expand M4 production data from 24 → 50+ scenarios** following the v4.2.3A/B canonical-builder pattern.
2. Maintain strategic-quality gates: every new seed gets the v4.3.0A 14-point checklist treatment.
3. Maintain anti-filler discipline: every new scenario carries a `uniquenessNote` and represents a strategically-distinct lesson.
4. Distribute new scenarios to fill thin actionReason buckets (currently action distribution: 10 call / 6 check_raise_small / 8 fold / 0 mixed / 0 check_raise_big — heavy fold/call lean, no `mixed` representation).
5. Run R71 bidirectional FD warning systematically during expansion.
6. Reserved for v4.3.1: runtime wire of M4 as Limited Beta with scaled mastery thresholds, full concept-library / weak-spot-review integration. **NOT in v4.3.0C scope.**

Volume target for v4.3.1 runtime wire: **50+ M4 scenarios with diversity across all 6 turn categories AND all 5 actions AND all 12 actionReasons**.

---

## 17. Sprint-time bug discovery + recovery (transparency note)

During the sprint, an accidental file-delete bug was discovered and recovered:

**The bug:** A temp script's `Invoke-Expression` reassigned `$path` to the JSON file path in the outer scope. The subsequent cleanup `Remove-Item $path -Force` deleted both `postflop/postflop_concepts.json` and `postflop/postflop_taxonomy.json` from the working tree (they were preserved in git HEAD).

**Recovery:**
1. `git restore postflop/postflop_concepts.json postflop/postflop_taxonomy.json` (restored from HEAD)
2. Re-applied the M4 extensions inline (no temp file → no scope contamination)
3. Verified the post-restore extensions match the intended content

**Lesson:** Future helper scripts must avoid `Invoke-Expression` of files that share variable names with the outer scope. Using inline blocks or scriptblocks with isolated scope is safer.

The deletion did not propagate to git HEAD, the snapshot, or any user-facing artifact.
