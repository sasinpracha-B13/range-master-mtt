# Postflop v4.2.3 — Module 3 Migration to Production Data

**Status:** Implemented and shipped.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.0-module3-architecture.md`, `postflop-v4.2.0-module3-schema-taxonomy.md`, `postflop-v4.2.0-module3-seed-scenarios.json`, `postflop-v4.2.0-module3-audit-plan.md`
**Builds on:** v4.2.2G (Training Command Center polish + routing honesty)

---

## 1. Goal

Migrate the 24 finalized v4.2.0 Module 3 (Facing C-bet OOP) planning seeds into production
`postflop/postflop_scenarios.json` so they are loaded into `App.state.postflop.scenarios`
at runtime alongside Module 1 and Module 2.

**Critical constraint:** Module 3 must remain NOT runtime-wired. The Training Command
Center entry for M3 stays `kind: 'preview'`, `route: null`. No drill engine activation.
This sprint is data-only migration plus audit hardening.

---

## 2. Volume gates

| Gate | v4.2.2G (before) | v4.2.3 (after) |
|---|---|---|
| Total production scenarios | 300 | **324** (+24) |
| Module 1 (pf_board_texture) | 251 | 251 (unchanged) |
| Module 2 (pf_flop_cbet_ip) | 49 | 49 (unchanged) |
| Module 3 (pf_flop_cbet_oop_def) | 0 | **24** (NEW) |
| Production audit result | 300 / 0 / 0 | **324 / 0 / 0** |
| R29 card-notation guard | 0 warnings | **0 warnings** (preserved) |
| M2 seed audit | PASS (8 warnings) | PASS (8 warnings) |
| M3 seed audit | PASS clean | PASS clean (unchanged) |

---

## 3. What changed

### 3.1 `postflop/postflop_concepts.json` (+10 concepts)

New M3-flavored concept entries (category: `module3`):

1. `oop_defense_threshold` — minimum equity / hand strength needed to continue OOP
2. `check_raise_value` — raising strong made hands OOP for value
3. `check_raise_bluff` — raising draws / blockers OOP as semi-bluff
4. `bluff_catchers` — medium-strength hands that beat bluffs but lose to value
5. `equity_realization_oop` — how much raw equity converts to chips OOP
6. `range_disadvantage` — hero's range performs worse than villain's on this board
7. `pot_odds_defense` — mechanical equity threshold from bet sizing
8. `value_raise` — OOP framing of M2's value-betting concept
9. `protection_raise` — OOP framing of M2's protection-betting concept
10. `semi_bluff_raise` — OOP framing of M2's semi-bluff concept

Concepts 8–10 are aliases used as conceptTags in M3 seeds; they were originally listed
in the v4.2.0 audit-plan §3.10 as "M2 reusable" but had no concept-file entries.
Added in v4.2.3 to satisfy R07.

Pre-migration concept count: 15 (10 M1 foundation/strategy + 5 M2 explicit)
Post-migration concept count: **25** (+10)

### 3.2 `postflop/postflop_taxonomy.json`

New canonical arrays for M3 vocabulary:

- `heroHandRole.module2[]` — 10 entries (locked from v4.1.2)
- `heroHandRole.module3[]` — 9 entries including new `bluff_catcher`, `dominated_marginal`
- `actionReason.module2[]` — 10 entries (locked from v4.1.5)
- `actionReason.module3[]` — 9 entries including new `slowplay_call` (added v4.2.2)
- `auditStatusValues[]` — extended with `review_pending`, `planning_only`
- `textureTags[]` — extended with `static` (used by M3 dry-board seeds)
- `modules.pf_flop_cbet_oop_def` — full module entry (validActions, validReasons, supportedQuestionTypes)

### 3.3 `tools/audit-postflop-ps.ps1` (+R30..R41 M3 production rules)

Rules R30–R41 implemented for `module === 'pf_flop_cbet_oop_def'`. Numbering note:
R29 is the v4.2.2D/E card-notation guard, so M3 production rules begin at R30
(not R29 as originally drafted in the v4.2.0 audit-plan).

| Rule | Mirrors seed audit plan | Purpose |
|---|---|---|
| R30 | M3-R11..R15 | Spot assumption (NLH_MTT, 100BB, SRP, BB vs BTN) |
| R31 | M3-R16..R18 | Action choices = {fold, call, check_raise_small, check_raise_big, mixed} |
| R32 | M3-R19..R21 | Reason choices subset of 9 M3 reasons (incl. slowplay_call) |
| R33 | M3-R22..R25 | Vocabulary: handClass, heroHandRole, drawCategory, showdownValue |
| R34 | M3-R28..R31 | Answer consistency (best is single string, disjoint from acceptable/bad) |
| R35 | M3-R32..R36 | Explanation: short / rangeContext / handLogic / takeaway / defenseLogic required |
| R36 | M3-R38..R40 | conceptTags 1–4 entries from M3 + reusable M2 vocabulary |
| R37 | M3-R42..R43 | sourceConfidence honesty (solver_verified requires solverRunRef) |
| R38 | New | spot.villainAction must be `cbet` |
| R39 | New | spot.villainSizing must be `small` (in v4.2.3) |
| R40 | New | heroHand vs board collision (explicit M3 re-check) |
| R41 | New | module === `pf_flop_cbet_oop_def` (typo guard) |

Also: R04/R05 generalized to handle string-form choices and string-form `answer.best`
(M3 schema), preserving M1/M2 array-form behavior.

### 3.4 `postflop/postflop_scenarios.json` (+24 M3 scenarios)

Each migrated M3 scenario includes:

- All seed fields: spot, board, heroHand, handClass, heroHandRole, drawCategory,
  showdownValue, blockerNote, recommendedAction, actionReason, question, answer,
  explanation, conceptTags, sourceConfidence
- Production additions:
  - `version: "1.0.0"`, `schemaVersion: "1.0.0"`, `game: "NLH_MTT"`
  - `street: "flop"` (top-level mirror of spot.street)
  - `actionHistory: []`
  - `scoring: { best: 1.0, acceptable: 0.5, bad: 0, critical: 0 }`
  - `difficulty: 3` (intermediate; reviewer may re-tune in a future polish pass)
  - `auditStatus: "approved"` (after the review_pending → approved flip)
  - Board enriched with `connectedness`, `pairedStatus`, `dynamicLevel`,
    `rangeAdvantage`, `nutAdvantage` per the 6 board families
- Stripped: `reviewStatus` (planning-only sentinel)

### 3.5 Migration tool (NEW)

`tools/migrate-module3-v4.2.3.ps1` — one-shot migration script. Idempotent:
aborts if M3 count > 0 to prevent duplicates. UTF-8 NO-BOM via
`[System.IO.File]::WriteAllText(..., UTF8Encoding($false))` to avoid CP874
mojibake on Windows PowerShell 5.1. Retained in the repo for reference / replay.

### 3.6 Audit-plan renumbering

`docs/specs/postflop-v4.2.0-module3-audit-plan.md` §6 production-rule table
renumbered from R29–R40 → **R30–R41** to reflect that R29 is the v4.2.2D/E
card-notation guard. Audit gates table updated with the R29 = 0 warnings line.

### 3.7 Version bumps

| File | Before | After |
|---|---|---|
| `index.html` (App.state.appVersion / buildBackupPayload) | `4.2.2G` | **`4.2.3`** |
| `service-worker.js` (VERSION) | `v4.2.2G` | **`v4.2.3`** |

Cache name `range-master-v4.2.3` triggers SW reactivation; old cache cleared on activate.

---

## 4. What did NOT change

| Item | Status |
|---|---|
| `TRAINING_MODES.preflop` registry | unchanged |
| `TRAINING_MODES.postflop.actions[m3]` | still `kind: 'preview'`, `route: null`, hint "Coming in v4.2.4 beta" |
| `runHomeCommandCenterMount` / `runTrainingModeAction` | unchanged |
| Postflop drill engine (`startPostflopDrill`, `App.postflop.*`) | unchanged |
| `App.state.postflop.scenarios` / module loader | unchanged shape — picks up the new 24 automatically because they have `module === 'pf_flop_cbet_oop_def'` and live in the same JSON, but no UI surface filters or routes them |
| Module 1 / Module 2 scenarios | byte-identical |
| `ranges.json` | unchanged |
| `postflop/postflop_concepts.json` (M1+M2 entries) | unchanged; only +10 appended |

**Net runtime effect of v4.2.3:** App.state.postflop.scenarios goes 300 → 324 in memory.
Nothing on the surface uses the new 24. They are inert until v4.2.4 wires the M3 drill engine.

---

## 5. Strategic spot-check (8 scenarios)

Reviewer-verified poker correctness:

| # | Scenario ID | Spot | Verdict |
|---|---|---|---|
| 1 | `As8d3h_m3_action_Th8h` | Mid pair (8) + bd flush on dry A-high → call ✓ | correct |
| 2 | `As8d3h_m3_action_JcTd` | Two overcards no draw on dry A-high → fold ✓ | correct (range disadvantage) |
| 3 | `KcKd7s_m3_action_7d6d` | Mid pair (7) on paired K → bluff-catch call ✓ | correct |
| 4 | `8s7d5h_m3_action_5c5d` | Bottom set on draw-heavy → check-raise small for protection ✓ | correct |
| 5 | `8s7d5h_m3_action_AhKc` | AK no equity on low connected → fold ✓ | correct |
| 6 | `QhJh6c_m3_reason_9h8h` | Combo draw 12+ outs → semi-bluff raise reason ✓ | correct |
| 7 | `Jh8h4h_m3_action_6c5d` | No heart on monotone → fold ✓ | correct |
| 8 | `KcKd7s_m3_action_AhKh` | Trips with nut kicker → slowplay_call (v4.2.2 reason addition) ✓ | correct |

All 8 strategic recommendations match GTO/expert-judgment intuition for BB-vs-BTN
SRP 100BB OOP defense.

---

## 6. Audit results (final)

### 6.1 Production audit

```
=== Postflop Audit ===
Total scenarios: 324
Errors: 0
Warnings: 0
Scenarios with errors: 0

  Module 1 total: 251 (status approved: 251)
  Module 2 total: 49  (status approved: 49)
  Module 3 total: 24  (status approved: 24)
    qtype action_choice: 18
    qtype reason_choice: 6
    suit monotone: 4 / rainbow: 16 / two_tone: 4
    hcc A_high:4 / K_high:8 / Q_high:4 / J_high:4 / low:4
    action call: 11 / check_raise_small: 6 / fold: 6 / check_raise_big: 1
```

### 6.2 R29 card-notation guard

`R29 warnings: 0` — text integrity preserved across migration.

### 6.3 Seed audits (unchanged)

- M2 seed audit: PASS (8 warnings, mature labeling guidance)
- M3 seed audit: PASS clean (24/0/0)

### 6.4 Text integrity sweep

```
postflop_scenarios.json: thai=0 repl=0 rank--x=0 rRr=0 board=0 ax=0 slash=0
```

---

## 7. Module 3 distribution snapshot

| Board | Scenarios | qtype split | Action distribution |
|---|---|---|---|
| As 8d 3h (dry A-high rainbow) | 4 | 3 action + 1 reason | 2 call, 1 raise, 1 fold |
| Kh 9c 4s (dry K-high rainbow) | 4 | 3 action + 1 reason | 2 call, 1 raise, 1 fold |
| 8s 7d 5h (wet low connected) | 4 | 3 action + 1 reason | 1 call, 2 raise, 1 fold |
| Qh Jh 6c (wet two-tone broadway) | 4 | 3 action + 1 reason | 1 call, 2 raise, 1 fold |
| Jh 8h 4h (wet monotone J-high) | 4 | 3 action + 1 reason | 1 call, 1 small raise, 1 big raise, 1 fold |
| Kc Kd 7s (paired K rainbow) | 4 | 2 action + 2 reason | 4 call (1 slowplay), 0 raise, 0 fold |

Spread covers all major fold/call/raise outcomes plus the post-v4.2.2 `slowplay_call`
reason. Coverage of `check_raise_big` is intentionally thin (1 scenario — only the
nut flush on monotone) to avoid the polar-action over-representation flagged in the
architecture risk #8.

---

## 8. Training volume caveat

24 scenarios is **far too thin for a playable Module 3 beta**. By comparison:

- M1 (Board Texture) = 251 scenarios across 14 family/suit combos
- M2 (Flop C-bet IP) = 49 scenarios with explicit "BETA" / "small set" labeling

A reasonable beta-quality M3 needs roughly 80–120 scenarios spanning:
- ≥12 board families (currently 6)
- ≥3–4 hand archetypes per family per qtype (currently 4 hands × 1 qtype mix)
- Larger board sample for `domination_fold`, `slowplay_call`, `equity_realization_call`,
  and the marginal-pair bluff-catcher line on broadway boards
- Coverage for `big` c-bet sizing (R39 currently locked to `small` only)

v4.2.3 is intentionally a **migration sprint, not a production-quality content drop**.
The 24 seeds become the foundational training set; v4.2.4 / v4.2.5 will expand
volume before the Training Command Center M3 tile flips from `kind: 'preview'`
to `kind: 'available'`.

---

## 9. v4.2.4 prerequisites (forward-look, NOT in scope of v4.2.3)

To make M3 playable in v4.2.4 / v4.2.5:

1. **Volume expansion** — at least double the seed count to ~50–80, ideally to ~120
2. **Drill engine wiring** — `startPostflopDrill('pf_flop_cbet_oop_def', N)` analog
   to M2's `startPostflopDrill('pf_flop_cbet_ip', N)`
3. **Question rendering** — M3 uses string-form `question.choices` (not `{id, label}`
   objects); the choice renderer needs a string-aware path
4. **Answer rendering** — M3 `answer.best` is a single string; result/comparison code
   needs to handle string-best in addition to array-best
5. **TRAINING_MODES flip** — change M3 entry from
   `{ kind: 'preview', route: null }` to
   `{ kind: 'available', route: 'postflop:m3', entryHint: '24 OOP defense scenarios · BETA' }`
   and add the `postflop:m3` action to `runTrainingModeAction`
6. **Concept Library tile** — render the 10 new M3 concepts when M3 is the
   selected training mode
7. **Big c-bet sizing** — relax R39 to allow `villainSizing ∈ {small, big}` once
   big-sized c-bet seeds are added (currently only small is trained)

---

## 10. Files touched

| File | Type of change |
|---|---|
| `postflop/postflop_scenarios.json` | +24 M3 scenarios, top-level description updated |
| `postflop/postflop_concepts.json` | +10 concept entries (7 M3-native + 3 M3 alias) |
| `postflop/postflop_taxonomy.json` | +heroHandRole, +actionReason, +pf_flop_cbet_oop_def module, +static textureTag, +review_pending/planning_only auditStatusValues |
| `tools/audit-postflop-ps.ps1` | +R30..R41 M3 production rules; R04/R05 generalized for string-choice schema; +M3 stats block |
| `tools/migrate-module3-v4.2.3.ps1` | NEW one-shot migration script |
| `docs/specs/postflop-v4.2.0-module3-audit-plan.md` | §6 renumbered R29..R40 → R30..R41; §7 audit gates updated |
| `docs/specs/postflop-v4.2.3-module3-migration.md` | NEW (this document) |
| `index.html` | `appVersion` 4.2.2G → 4.2.3 (1 line) |
| `service-worker.js` | `VERSION` v4.2.2G → v4.2.3 (1 line) |
| `PROJECT_STATE.md` | sprint status update |
| `TASK_BOARD.md` | task close-out |
| `GPT AUDIT/v4.2.3/` | NEW snapshot folder per §7.5 convention |

---

## 11. Sign-off checklist

- [x] 24 M3 seeds migrated → 324 total scenarios
- [x] Production audit: 324 / 0 / 0 (target 324 / 0 / 0)
- [x] R29 card-notation guard: 0 warnings (preserved)
- [x] M2 seed audit: PASS (8 warnings, unchanged)
- [x] M3 seed audit: PASS clean (24/0/0, unchanged)
- [x] Text integrity sweep: 0 mojibake / 0 broken patterns
- [x] 8-scenario poker spot-check: all 8 strategic verdicts match expert judgment
- [x] `index.html` appVersion + `service-worker.js` VERSION bumped to 4.2.3
- [x] TRAINING_MODES M3 entry untouched (still `kind: 'preview'`, `route: null`)
- [x] Runtime helpers untouched (`runHomeCommandCenterMount`, `runTrainingModeAction`,
  `startPostflopDrill`, etc. byte-identical)
- [x] M3 NOT playable, NOT routable, NOT runtime-wired
- [x] Volume caveat documented (24 too thin for beta; v4.2.4+ scope)

**Status: SHIPPED.**
