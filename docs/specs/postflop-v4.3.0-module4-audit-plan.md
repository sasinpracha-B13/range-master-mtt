# Postflop v4.3.0 -- Module 4 (Turn Barrel OOP Defense) -- Audit Plan

**Status:** planning_only (no production wiring)
**Module ID:** `pf_turn_barrel_oop_def`
**Schema version:** `1.2.0`
**Seed file:** `docs/specs/postflop-v4.3.0-module4-seed-scenarios.json`
**Auditor script (mechanical):** `tools/audit-postflop-module4-seed.ps1`
**Target:** 24 scenarios, 0 hard errors, warnings allowed but minimized

---

## 1. Purpose

This document defines the **machine-checkable rules** (M4.R01 through M4.R49) that the M4 seed JSON must obey. The auditor script validates these mechanically; strategic correctness (range realism, equity logic) is reviewed separately via the GPT review package.

These rules are **planning-only** -- they apply to the seed JSON. They do not run against `postflop_scenarios.json` (production data). When seeds are promoted to production in v4.3.0A or later, the production auditor (`audit-postflop-ps.ps1`) will be extended with M4-aware rules separately.

Rules are numbered `M4.R01..M4.R49` to avoid collision with production rule numbers (the production auditor uses `R29`/`R30` for the v4.2.4 normalization layer; these M4.R rules live in their own namespace).

---

## 2. Rule namespace, severity, and exit semantics

- Each rule is `M4.R##` (two-digit, 01..49 reserved).
- Two severities: **HARD ERROR** (build must fail) and **WARNING** (build passes but logged).
- Auditor script exits with non-zero exit code if **any HARD ERROR** is emitted.
- Warnings are printed but do not block the build.
- Final report line format: `OK -- M4 seeds: 24 / 0 hard errors / N warnings`.

---

## 3. Top-level JSON envelope rules

### M4.R01 -- file is parseable JSON
HARD ERROR if `Get-Content $path -Raw | ConvertFrom-Json` throws.

### M4.R02 -- required top-level keys
HARD ERROR if any of the following is missing:
`moduleId`, `moduleName`, `version`, `status`, `schemaVersion`, `generatedAt`, `scenarios`.

### M4.R03 -- moduleId is `pf_turn_barrel_oop_def`
HARD ERROR if `moduleId != "pf_turn_barrel_oop_def"`.

### M4.R04 -- schemaVersion is `1.2.0`
HARD ERROR if top-level `schemaVersion != "1.2.0"`.

### M4.R05 -- version starts with `v4.3.0`
HARD ERROR if `version` does not start with `v4.3.0`.

### M4.R06 -- status is `planning_only`
HARD ERROR if top-level `status != "planning_only"`.

### M4.R07 -- scenarios is non-empty array of length 24
HARD ERROR if `scenarios` is not an array OR `scenarios.Count != 24`.

---

## 4. Per-scenario identity + housekeeping

### M4.R08 -- id present + unique
HARD ERROR if any scenario lacks `id`, OR if any two scenarios share the same `id`.

### M4.R09 -- id naming convention
HARD ERROR if any `id` does not match the regex
`^pf_btn_v_bb_srp_100bb_turn_[a-zA-Z0-9]+_[0-9a-zA-Z]+_m4_(action|reason)_[A-Za-z0-9_]+_v430$`.

### M4.R10 -- module field equals moduleId
HARD ERROR if any scenario's `module != "pf_turn_barrel_oop_def"`.

### M4.R11 -- schemaVersion field equals `1.2.0`
HARD ERROR if any scenario's `schemaVersion != "1.2.0"`.

### M4.R12 -- auditStatus is `planning_only`
HARD ERROR if any scenario's `auditStatus != "planning_only"`.

### M4.R13 -- reviewStatus is `v4.3.0_seed_candidate`
HARD ERROR if any scenario's `reviewStatus != "v4.3.0_seed_candidate"`.

### M4.R14 -- uniquenessNote present + non-empty
HARD ERROR if any scenario lacks `uniquenessNote` OR `uniquenessNote.Length < 20` characters (anti-filler discipline).

---

## 5. Spot block rules (BB-vs-BTN turn defense lock)

### M4.R15 -- spot block present with required keys
HARD ERROR if `spot` is missing OR lacks any of:
`format`, `stackDepth`, `potType`, `preflopAction`, `flopAction`, `turnAction`,
`street`, `heroPosition`, `villainPosition`, `heroRole`, `villainRole`.

### M4.R16 -- spot.format is `NLH_MTT` and stackDepth is `100BB`
HARD ERROR if `spot.format != "NLH_MTT"` OR `spot.stackDepth != "100BB"`.

### M4.R17 -- hero is BB and villain is BTN
HARD ERROR if `spot.heroPosition != "BB"` OR `spot.villainPosition != "BTN"`.

### M4.R18 -- spot.street is `turn` and potType is `SRP`
HARD ERROR if `spot.street != "turn"` OR `spot.potType != "SRP"`.

### M4.R19 -- hero/villain roles are turn-defense locked
HARD ERROR if `spot.heroRole != "flop_check_caller_oop"` OR `spot.villainRole != "turn_barreler_ip"`.

---

## 6. Board block rules (M4-specific 4-card structure)

### M4.R20 -- board block present with required keys
HARD ERROR if `board` is missing OR lacks any of:
`flopCards`, `turnCard`, `cards`, `boardKind`, `suitTextureFlop`, `suitTextureTurn`,
`turnCategory`, `boardChange`, `equityShift`, `drawCompletion`, `pairStatusChange`.

### M4.R21 -- flopCards is array of 3 valid card strings
HARD ERROR if `board.flopCards` is not an array of length 3 OR any element fails the regex `^[2-9TJQKA][cdhs]$`.

### M4.R22 -- turnCard is single valid card string
HARD ERROR if `board.turnCard` does not match `^[2-9TJQKA][cdhs]$`.

### M4.R23 -- cards equals flopCards + turnCard
HARD ERROR if `board.cards.Count != 4` OR if the joined `flopCards` + `turnCard` does not equal `board.cards`.

### M4.R24 -- no card collision in board
HARD ERROR if any of the 4 board cards is repeated.

### M4.R25 -- turnCategory is in approved enum
HARD ERROR if `board.turnCategory` is not one of: `brick`, `overcard`, `flush_complete`, `flush_draw_added`, `straight_complete`, `straight_draw_added`, `board_pair`, `draw_intensifier`, `top_pair_changer`, `ace_overcard`, `low_blank`, `high_blank`.

### M4.R26 -- boardChange is in approved enum
HARD ERROR if `board.boardChange` is not one of: `brick`, `range_shift_btn`, `range_shift_bb`, `polarizing`, `counterfeit`, `draw_added`, `static`, `dynamic`.

### M4.R27 -- equityShift is in approved enum
HARD ERROR if `board.equityShift` is not one of: `neutral`, `favors_btn`, `favors_bb`, `polarizes_btn`, `improves_bb_draws`, `completes_bb_draws`, `counterfeits_bb_pairs`.

### M4.R28 -- drawCompletion is in approved enum
HARD ERROR if `board.drawCompletion` is not one of: `none`, `flush_completed`, `straight_completed`, `flush_draw_added`, `straight_draw_added`, `oesd_added`, `gutshot_added`, `multi_draw_added`.

### M4.R29 -- pairStatusChange is in approved enum
HARD ERROR if `board.pairStatusChange` is not one of: `no_change`, `flop_card_paired`, `paired_top`, `paired_middle`, `paired_bottom`, `double_paired`, `trips_possible`.

---

## 7. Hero hand + role rules

### M4.R30 -- heroHand is array of 2 valid card strings
HARD ERROR if `heroHand` is not array length 2 OR any card fails `^[2-9TJQKA][cdhs]$`.

### M4.R31 -- no hero/board card collision
HARD ERROR if any heroHand card matches any board card.

### M4.R32 -- heroHandRole in approved vocab
HARD ERROR if `heroHandRole` is not one of:
`strong_value`, `nutted_value`, `bluff_catcher`, `marginal_made_hand`, `dominated_marginal`,
`combo_draw`, `draw`, `give_up`, `air`, `bluff_candidate`, `blocker_bluff`, `slowplay_trap`, `protection_needed`.

---

## 8. Question block rules

### M4.R33 -- question block present with required keys
HARD ERROR if `question` lacks any of: `qtype`, `prompt`, `choices`.

### M4.R34 -- qtype is action_choice or reason_choice
HARD ERROR if `question.qtype` is not in {`action_choice`, `reason_choice`}.

### M4.R35 -- choices for action_choice is exact 5-action menu
HARD ERROR if `qtype == action_choice` AND `choices` does not equal exactly the set
`{ fold, call, check_raise_small, check_raise_big, mixed }` (order-insensitive, no extras, no missing).

### M4.R36 -- choices for reason_choice is non-empty array of 3..12 strings drawn from M4 actionReason vocab
HARD ERROR if `qtype == reason_choice` AND (`choices.Count < 3` OR `choices.Count > 12` OR any non-string element OR any choice not in M4-approved actionReason vocab).

---

## 9. Recommended action + answer partition rules

### M4.R37 -- recommendedAction in 5-action menu
HARD ERROR if `recommendedAction` is not one of: `fold`, `call`, `check_raise_small`, `check_raise_big`, `mixed`.

### M4.R38 -- actionReason in M4-approved vocab
HARD ERROR if `actionReason` is not one of:
`pot_odds_turn_call`, `equity_realization_turn_call`, `bluff_catch_turn`,
`board_change_fold`, `domination_turn_fold`, `range_disadvantage_turn_fold`,
`value_check_raise_turn`, `protection_check_raise_turn`, `semi_bluff_check_raise_turn`,
`blocker_check_raise_turn`, `slowplay_turn_call`, `mixed_indifference_turn`.

### M4.R39 -- answer block has best/acceptable/bad/critical keys
HARD ERROR if `answer` lacks any of `best`, `acceptable`, `bad`, `critical`.

### M4.R40 -- answer.best is single string in 5-action menu (when qtype=action_choice)
HARD ERROR if `qtype == action_choice` AND (`answer.best` is not string OR not in the 5-action menu).

### M4.R41 -- recommendedAction equals answer.best for action_choice
HARD ERROR if `qtype == action_choice` AND `recommendedAction != answer.best`.

### M4.R42 -- answer partitions semantic
The three primary partitions `best`, `acceptable`, `bad` MUST be **disjoint** and exhaustive over the 5-action menu (for `action_choice`).
The fourth partition `critical` is a **highlight subset of `bad`** -- every action in `critical` must also be in `bad`. `critical` is for "harmful enough to mark as a teaching spot".

HARD ERROR if any action appears in more than one of {best, acceptable, bad}.
HARD ERROR if any action in `critical` is NOT also in `bad`.

### M4.R43 -- answer partition coverage for action_choice
HARD ERROR if `qtype == action_choice` AND the union of (best, acceptable, bad) does not equal the full 5-action menu. `critical` is excluded from coverage check (it's a subset of bad).

### M4.R44 -- answer.best for reason_choice is one of the choices
HARD ERROR if `qtype == reason_choice` AND `answer.best` is not in `question.choices`.

---

## 10. Explanation + concept tag rules

### M4.R45 -- explanation block has required fields including turnLogic
HARD ERROR if `explanation` lacks any of: `short`, `turnLogic`, `rangeContext`, `handLogic`, `sizingLogic`, `commonMistake`, `takeaway`.

`turnLogic` is the M4-defining required field -- it must explain how the turn card changed ranges/equities. WARNING if `turnLogic.Length < 60` characters.

### M4.R46 -- conceptTags is array of 1..4 strings from approved vocab
HARD ERROR if `conceptTags` is not array, OR length < 1 OR > 4, OR any tag is not in:
`turn_equity_shift`, `second_barrel_defense`, `turn_pot_odds`, `turn_bluff_catcher`,
`turn_domination_fold`, `turn_board_change`, `turn_draw_completion`,
`turn_check_raise_value`, `turn_check_raise_bluff`, `turn_blocker_pressure`,
`turn_slowplay_call`, `turn_range_disadvantage`.

### M4.R47 -- sourceConfidence in approved set
HARD ERROR if `sourceConfidence` not in: `solver_aligned`, `theory_consensus`, `expert_judgment`, `heuristic`, `mixed_uncertain`.

---

## 11. Distribution + anti-filler rules (cross-scenario)

### M4.R48 -- six turnCategory values, exactly 4 scenarios each
HARD ERROR if scenario distribution is not exactly:
- `brick`: 4
- `overcard`: 4
- `flush_complete`: 4
- `straight_complete`: 4
- `board_pair`: 4
- `draw_intensifier`: 4

### M4.R49 -- qtype distribution per category
HARD ERROR if any category has fewer than 2 `action_choice` questions OR fewer than 1 `reason_choice` question. WARNING if a category has more than 4 of either type (uneven coverage).

---

## 12. Strategic quality rules (NOT auto-checked)

The following rules are **strategic-quality flags** that are reviewed by humans/GPT, not by the mechanical auditor. They are listed here for traceability and for the GPT review package.

- **S.Q01 -- chipEV / NLH MTT discipline:** No ICM-aware reasoning, no ko-bounty math, no live-cash leveling.
- **S.Q02 -- BTN-vs-BB SRP context:** No 3-bet pots, no multiway, no straddle, no out-of-line stacks.
- **S.Q03 -- No overconfident solver claims:** Phrases like "the solver says exactly X" require `sourceConfidence: solver_aligned`. Prefer "modern theory consensus" or "common heuristic" otherwise.
- **S.Q04 -- Close mixed spots are acceptable, not critical:** A 50/50 fold-vs-call should not have `critical` set on either action.
- **S.Q05 -- Card collision sanity:** Already covered by M4.R24/R31.
- **S.Q06 -- turnLogic quality:** Each scenario's `turnLogic` must explicitly name the turn card and explain the equity shift. Auditor warns if < 60 chars; humans check substance.
- **S.Q07 -- uniquenessNote substance:** Must explain WHY this scenario is non-redundant relative to its category-mates (different hand class, different draw, different blocker, different action, etc.).
- **S.Q08 -- heroHandRole correctness:** `slowplay_trap` only used when hand is set+ on a board where hero CAN call vs barrel without losing value (e.g., set on dry brick). Not for top pair.
- **S.Q09 -- actionReason matches recommendedAction:** Mechanical check that they pair correctly (fold reasons with fold, call reasons with call, etc.) -- not enforced by auditor in v4.3.0; flagged in GPT review.
- **S.Q10 -- No donk-bet leak:** This module is OOP turn defense AFTER flop check-call. There is no donk-bet option (BB checked the turn first). The action menu must not include `donk_bet`.

---

## 13. How the auditor maps to rules

The auditor script `tools/audit-postflop-module4-seed.ps1` implements these rules in the listed order. Each violation prints:

```
[M4.RNN] HARD/WARN -- <rule short name> -- <scenario id or 'TOP'> -- <details>
```

Final summary:

```
M4 seed audit:
  scenarios = 24
  hard errors = 0
  warnings    = N
  result      = PASS / FAIL
```

Exit code: `0` if `hard errors == 0`, else `1`.

---

## 14. Changes in subsequent versions

- **v4.3.0A** (next sprint, planned): seed strategic review; some warnings may upgrade to HARD if review reveals systemic issues.
- **v4.3.1+** (post-promotion): production auditor `audit-postflop-ps.ps1` extended with M4-aware variants of these rules. The seed auditor remains as a pre-flight check.

---

## 15. Audit baseline expectation (v4.3.0)

Running `tools/audit-postflop-module4-seed.ps1` against `docs/specs/postflop-v4.3.0-module4-seed-scenarios.json` is expected to produce:

- scenarios = 24
- hard errors = 0
- warnings = small count (<= 10) for short turnLogic or short uniquenessNote
- result = PASS

Any HARD ERROR blocks the v4.3.0 commit.
