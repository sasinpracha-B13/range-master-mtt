# Postflop v4.3.0 — Module 4 Schema + Taxonomy

**Status:** Planning-only.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.3.0-module4-turn-defense-oop-architecture.md`
**Schema version:** `1.2.0` (extends M3 v1.1.0 with turn-specific fields)

---

## 1. Required scenario fields (Module 4)

```json
{
  "id":            "string (unique)",
  "module":        "pf_turn_barrel_oop_def",
  "moduleName":    "Facing Turn Barrel OOP",
  "schemaVersion": "1.2.0",
  "spot":          { /* see §2 */ },
  "board":         { /* see §3 */ },
  "heroHand":      ["card1", "card2"],
  "handClass":     "string from M2/M3 vocab",
  "heroHandRole":  "string from §6",
  "drawCategory":  "string from M3 vocab",
  "showdownValue": "string from M3 vocab",
  "blockerNote":   "string or null",
  "recommendedAction": "string from §5",
  "actionReason":  "string from §7",
  "question":      { /* see §4 */ },
  "answer":        {
    "best":       "string (single best action or reason)",
    "acceptable": ["string", ...],
    "bad":        ["string", ...],
    "critical":   ["string", ...]
  },
  "explanation":   { /* see §8 */ },
  "conceptTags":   ["1-4 tags from §9"],
  "sourceConfidence": "expert_judgment | consensus_gto | solver_verified",
  "auditStatus":   "planning_only",
  "reviewStatus":  "v4.3.0_seed_candidate",
  "uniquenessNote": "1-2 sentence strategic distinction"
}
```

---

## 2. Spot field

```json
{
  "format":          "NLH_MTT",
  "stackDepth":      "100BB",
  "potType":         "SRP",
  "preflopAction":   "BTN open 2.5x, BB call",
  "flopAction":      "BTN cbet small (~33%), BB call",
  "turnAction":      "BTN barrel",
  "street":          "turn",
  "heroPosition":    "BB",
  "villainPosition": "BTN",
  "heroRole":        "flop_check_caller_oop",
  "villainRole":     "turn_barreler_ip"
}
```

All fields **required** in v4.3.0 seeds. Audit rules M4.R02 / M4.R03 / M4.R04 enforce.

---

## 3. Board field

```json
{
  "flopCards":         ["c1", "c2", "c3"],     // 3 cards
  "turnCard":          "c4",                   // 1 card
  "cards":             ["c1","c2","c3","c4"],  // 4 cards (= flopCards + turnCard)
  "boardKind":         "A_high | K_high | Q_high | J_high | T_high | low",
  "suitTextureFlop":   "rainbow | two_tone | monotone",
  "suitTextureTurn":   "rainbow | two_tone | monotone",  // suit texture AFTER turn
  "highCardClass":     "A_high | K_high | Q_high | J_high | T_high | low",
  "textureTags":       ["dry","wet","connected","paired","disconnected","static",...],
  "turnCategory":      "string from §10",
  "boardChange":       "string from §11",
  "equityShift":       "string from §12",
  "drawCompletion":    "string from §13",
  "pairStatusChange":  "string from §14"
}
```

`flopCards` and `turnCard` are introduced in M4 to make the turn-card identity programmatically accessible (for `turnCategory` derivation, equity-shift labeling, etc.). `cards` is the concatenation and is used by R02-R04 for collision / count checks.

---

## 4. Question field

```json
{
  "qtype":   "action_choice | reason_choice",
  "prompt":  "string (BB-defending framing referencing flop history + turn card)",
  "choices": ["fold", "call", "check_raise_small", "check_raise_big", "mixed"]   // for action_choice
            // OR ["value_check_raise_turn", "protection_check_raise_turn", ...]  // for reason_choice
}
```

Choices are **string-form** (matching M3 schema, not the M2 `{id, label}` form). Runtime normalization via `_pfNormalizePostflopChoices` already handles this.

---

## 5. Action menu (5 actions)

| Action ID | Display label | Module 3 reuse |
|---|---|---|
| `fold` | Fold | yes |
| `call` | Call | yes |
| `check_raise_small` | Check-raise small | yes |
| `check_raise_big` | Check-raise big | yes |
| `mixed` | Mixed / close | yes |

**No new actions in v4.3.0.** Donk-leading is documented out-of-scope. If added in a future v4.3.x, the action ids would be `donk_small` and `donk_big`.

---

## 6. heroHandRole vocabulary (Module 4)

| Role | Definition |
|---|---|
| `nutted_value` | Hero has the near-nuts (set, two-pair, made flush vs flush board, made straight) |
| `strong_value` | Hero has top pair top-good kicker / overpair / strong made hand |
| `marginal_made_hand` | Mid pair / underpair / weak top pair |
| `bluff_catcher` | Pair / A-high that beats villain's bluff range but loses to value |
| `dominated_marginal` | Pair / draw that's clearly dominated by villain's range |
| `strong_draw` | OESD / nut FD / big combo draw |
| `combo_draw` | Multiple draw equity (FD + OESD, etc.) |
| `nut_draw` | Nut FD specifically |
| `blocker_bluff` | No made hand / no draw, but holds key blocker (A of flush suit, nut straight blocker) |
| `give_up` | No equity, no blocker, no showdown value |
| **`slowplay_trap`** | NEW: hero has a monster (full house, flopped/turned set with strong hand) on a board where calling > raising because villain's range is bluff-heavy |

`slowplay_trap` is the new role unique to M4 — common on board-pairing turns. M3 used `nutted_value` for both "raise for value" and "slowplay" cases; M4 separates them so the auditor can track slowplay teaching coverage.

---

## 7. actionReason vocabulary (Module 4)

12 reasons total. Each turn reason is the M3 reason adapted to the turn street + 3 new turn-specific.

| Reason | Definition | M3 analog |
|---|---|---|
| `pot_odds_turn_call` | Call because mechanical pot odds + equity exceed threshold | (new — M3's "equity_realization_call" partially overlaps) |
| `equity_realization_turn_call` | Call to realize remaining draw / overcard equity OOP on the turn | M3 `equity_realization_call` |
| `bluff_catch_turn` | Call as bluff-catcher; beats villain's air, loses to value | M3 `bluff_catch` |
| `board_change_fold` | Fold because turn card shifted range advantage so much that hand can't continue | new (turn-specific) |
| `domination_turn_fold` | Fold because turn made hero's pair outs / draw outs dominated | M3 `domination_fold` |
| `range_disadvantage_turn_fold` | Fold because BB's range disadvantage compounds with no equity | M3 `range_disadvantage_fold` |
| `value_check_raise_turn` | Check-raise for value with strong made hand | M3 `value_raise` |
| `protection_check_raise_turn` | Check-raise to protect vulnerable made hand vs draws | M3 `protection_raise` |
| `semi_bluff_check_raise_turn` | Check-raise as semi-bluff with combo draw + fold equity | M3 `semi_bluff_raise` |
| `blocker_check_raise_turn` | Check-raise leveraging key blocker (A of flush suit / nut straight blocker) | M3 `blocker_raise` |
| `slowplay_turn_call` | Call with monster to keep villain's bluffs alive | M3 `slowplay_call` |
| `mixed_indifference_turn` | Solver mixes meaningfully between two lines (~30-70% split); both correct | new (turn explicit) |

**Why 12 vs M3's 9:**
- M3's `pot_odds_defense` concept exists but wasn't a per-scenario actionReason; M4 makes it explicit (`pot_odds_turn_call`) because turn pot-odds math is more salient than flop.
- `board_change_fold` is the M4-defining reason — folding because the turn card shifted ranges is the new lesson that doesn't have a perfect flop analog.
- `mixed_indifference_turn` is a small honest-copy improvement: when solver mixes 30-70%, the answer is genuinely "both correct," and `mixed` actionReason captures that.

The 6 directly-mapped reasons (bluff_catch / domination / range_disadvantage / value / protection / semi_bluff / blocker / slowplay / equity_realization) inherit M3's strategic frame but are renamed with `_turn` suffix to keep cross-street weak-spot review clean.

---

## 8. Explanation fields (required)

| Field | Required | Purpose |
|---|---|---|
| `short` | yes | One-line takeaway |
| `turnLogic` | **yes (M4-defining)** | What this turn card does to the range; the M4 equivalent of M3's `defenseLogic` |
| `rangeContext` | yes | Broader BB-vs-BTN range frame at this turn |
| `handLogic` | yes | Strategic frame for THIS hand on THIS turn |
| `sizingLogic` | conditional | Required when recommendedAction is a check-raise; describes sizing rationale |
| `commonMistake` | yes | What learners typically get wrong here |
| `takeaway` | yes | One-sentence pattern to remember |

`turnLogic` is the new field unique to M4. It must explicitly describe how the turn card changed range advantage / draw completion / equity. This is the field the runtime feedback panel will surface PROMINENTLY (analogous to M3's `defenseLogic`).

---

## 9. conceptTags vocabulary (Module 4)

12 M4-native concepts. 1-4 tags per scenario.

| Concept | Definition |
|---|---|
| `turn_equity_shift` | The turn card moved range/equity meaningfully |
| `second_barrel_defense` | Defending vs continued aggression after flop call |
| `turn_pot_odds` | Mechanical equity threshold facing turn bet |
| `turn_bluff_catcher` | Medium-strength hand calling vs barrel range |
| `turn_domination_fold` | Folding marginal hand whose outs are dominated |
| `turn_board_change` | Recognizing turn card shifted range advantage |
| `turn_draw_completion` | Recognizing flush/straight completion or non-completion |
| `turn_check_raise_value` | Raising strong made hand for value on turn |
| `turn_check_raise_bluff` | Raising as semi-bluff or pure bluff with blockers |
| `turn_blocker_pressure` | Using key blockers to expand defense or raise frequency |
| `turn_slowplay_call` | Calling with monster to keep villain's bluffs alive |
| `turn_range_disadvantage` | Folding because BB's range performs worse on this turn |

**M2/M3 reusable tags** (allowed but de-emphasized):
- `bluff_catchers`, `equity_realization_oop`, `range_disadvantage`, `oop_defense_threshold`, `pot_odds_defense`, `check_raise_value`, `check_raise_bluff` — useful when the lesson directly mirrors a flop concept.
- `value_raise`, `protection_raise`, `semi_bluff_raise`, `blocker_raise`, `slowplay_call` — turn-version aliases not strictly needed since `_turn` reasons exist.

Audit M4.R28 enforces 1-4 tags per scenario.

---

## 10. turnCategory enum

```
brick
overcard
broadway_overcard
low_blank
flush_complete
straight_complete
board_pair
top_card_pair
second_card_pair
draw_intensifier
scare_card
range_shift_card
```

**6 used in v4.3.0 seeds:** `brick`, `overcard`, `flush_complete`, `straight_complete`, `board_pair`, `draw_intensifier`. Rest reserved for future expansion.

---

## 11. boardChange enum

```
brick               // turn does not meaningfully change ranges
range_shift_btn     // turn favors BTN's range
range_shift_bb      // turn favors BB's range
polarizing          // turn polarizes both ranges
draw_resolved       // a draw completed (flush/straight)
draw_added          // a new draw became live
counterfeit         // a pocket pair / kicker is now counterfeited
boat_possible       // board paired and full houses now possible
quads_possible      // board paired twice (rare) and quads now possible
```

---

## 12. equityShift enum

```
favors_btn
favors_bb
neutral
polarizing
reduces_bb_realization
improves_bb_draws
completes_bb_draws
improves_btn_overcards
counterfeits_bb_pairs
boats_for_btn
boats_for_bb
```

Per-scenario field; describes how the turn card altered the equity distribution.

---

## 13. drawCompletion enum

```
none                  // no draw completed
flush_completed       // a flush draw became a flush
straight_completed    // a straight draw became a straight
both_completed        // turn brought a card that completes both flush + straight
flush_draw_added      // backdoor became real FD
straight_draw_added   // backdoor became real OE/gutshot
oesd_added            // turn added OE specifically
gutshot_added         // turn added gutshot specifically
```

---

## 14. pairStatusChange enum

```
no_change             // turn doesn't change pair status
flop_card_paired      // turn paired one of the flop cards
two_pair_to_boat      // pre-existing two pair on flop became full house
turn_pairs_overcard   // turn brought an overcard that pairs (rare)
trips_to_quads        // pre-existing trips on flop became quads
```

---

## 15. sourceConfidence values

Same as M3:

| Value | When to use |
|---|---|
| `expert_judgment` | Default; spot is reasonable but not solver-verified |
| `consensus_gto` | Spot is GTO-trivial / textbook (no ambiguity); broad consensus |
| `solver_verified` | Backed by a solver run; requires `solverRunRef` field |

v4.3.0 seeds: all `expert_judgment`. Future v4.3.x can promote textbook spots to `consensus_gto` after review (same pattern as v4.2.3B's M3 promotion).

---

## 16. auditStatus / reviewStatus values

| Field | Allowed values |
|---|---|
| `auditStatus` | `planning_only`, `review_pending`, `approved`, `deprecated`, `draft`, `needs_review` |
| `reviewStatus` | `v4.3.0_seed_candidate` (this sprint), `v4.3.0A_seed_reviewed` (post-review), `v4.3.0_final` (post-final-pass), `v4.3.1_production` (post-migration) |

v4.3.0 seeds = `auditStatus: "planning_only"` + `reviewStatus: "v4.3.0_seed_candidate"`.

---

## 17. Schema versioning

M4 uses `schemaVersion: "1.2.0"`:
- M1 (board texture) = `1.0.0`
- M2 (flop c-bet IP) = `1.0.0` (extended fields, same major)
- M3 (flop defense OOP) = `1.1.0` (string-form choices/best, OOP framing)
- **M4 (turn defense OOP) = `1.2.0`** (turn-specific board fields: `flopCards`, `turnCard`, `turnCategory`, `boardChange`, `equityShift`, `drawCompletion`, `pairStatusChange`, `suitTextureTurn`)

The runtime `_pfNormalizePostflopChoices` + `_pfNormalizePostflopAnswer` continue to work for `1.2.0` because choices/best schema is identical to M3's `1.1.0`.

---

## 18. Sign-off

- [x] Required fields enumerated
- [x] Spot field locked (NLH_MTT 100BB SRP BTN-vs-BB)
- [x] Board field defines `flopCards` + `turnCard` + `cards` (4-card array)
- [x] Action menu 5-action (donk excluded)
- [x] heroHandRole adds `slowplay_trap`
- [x] actionReason: 12 reasons (M3 reasons adapted + 3 turn-specific)
- [x] Explanation fields require new `turnLogic` field
- [x] conceptTags: 12 M4-native + M2/M3 reusable
- [x] turnCategory enum (12 values; 6 used in v4.3.0 seeds)
- [x] boardChange / equityShift / drawCompletion / pairStatusChange enums defined
- [x] schemaVersion bumped to `1.2.0`
- [x] sourceConfidence + auditStatus + reviewStatus values defined
- [x] Compatible with v4.2.4 normalization layer (no new normalizers needed)

**Status: PLANNING-ONLY · APPROVED FOR v4.3.0 PLANNING COMMIT.**
