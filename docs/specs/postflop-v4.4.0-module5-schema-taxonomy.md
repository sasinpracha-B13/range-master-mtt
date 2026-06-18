# Postflop v4.4.0 — Module 5 Schema + Taxonomy

**Status:** Planning-only.
**Date:** 2026-06-18
**Companion to:** `postflop-v4.4.0-module5-river-defense-oop-architecture.md`
**Schema version:** `1.3.0` (extends M4 v1.2.0 with river-specific fields)

---

## 1. Required scenario fields (Module 5)

```json
{
  "id":            "string (unique)",
  "module":        "pf_river_barrel_oop_def",
  "moduleName":    "Facing River Barrel OOP",
  "schemaVersion": "1.3.0",
  "spot":          { /* see §2 */ },
  "board":         { /* see §3 */ },
  "heroHand":      ["card1", "card2"],
  "handClass":     "string from M2/M3/M4 vocab",
  "heroHandRole":  "string from §6",
  "drawCategory":  "none (river has no live draws; see note)",
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
  "reviewStatus":  "v4.4.0_seed_candidate",
  "uniquenessNote": "1-2 sentence strategic distinction"
}
```

**`drawCategory` note:** the river is the final street, so no draw can be live. M5 scenarios set `drawCategory` to `none` for made hands, or `busted_flush_draw` / `busted_straight_draw` / `busted_combo_draw` for hands that arrived as draws and missed (these are descriptive of HISTORY, not of live equity — they signal "this is a bluff-raise-or-fold hand, never a call"). The auditor (M5.R32) restricts `drawCategory` to this river-specific set.

---

## 2. Spot field

```json
{
  "format":          "NLH_MTT",
  "stackDepth":      "100BB",
  "potType":         "SRP",
  "preflopAction":   "BTN open 2.5x, BB call",
  "flopAction":      "BTN cbet small (~33%), BB call",
  "turnAction":      "BTN barrel (~50-66%), BB call",
  "riverAction":     "BTN bets river",
  "street":          "river",
  "heroPosition":    "BB",
  "villainPosition": "BTN",
  "heroRole":        "turn_check_caller_oop",
  "villainRole":     "river_barreler_ip"
}
```

All fields **required** in v4.4.0 seeds. Audit rules M5.R15-R19 enforce.

---

## 3. Board field

```json
{
  "flopCards":         ["c1", "c2", "c3"],            // 3 cards
  "turnCard":          "c4",                          // 1 card
  "riverCard":         "c5",                          // 1 card
  "cards":             ["c1","c2","c3","c4","c5"],    // 5 cards (= flop + turn + river)
  "boardKind":         "A_high | K_high | Q_high | J_high | T_high | low",
  "suitTextureFlop":   "rainbow | two_tone | monotone",
  "suitTextureTurn":   "rainbow | two_tone | monotone",
  "suitTextureRiver":  "rainbow | two_tone | monotone | four_flush",  // suit texture of full 5-card runout
  "highCardClass":     "A_high | K_high | Q_high | J_high | T_high | low",
  "textureTags":       ["dry","wet","connected","paired","disconnected","static","flush_possible","straight_possible",...],
  "riverCategory":     "string from §10",
  "boardChange":       "string from §11",
  "runoutTexture":     "string from §12",
  "riverDrawCompletion": "string from §13",
  "villainRiverSizing":  "string from §14"
}
```

`riverCard` and the 5-card `cards` array are introduced in M5. `cards` (5 elements) is used by R20-R24 for collision / count checks. `villainRiverSizing` is the M5-defining board-adjacent field because river sizing drives MDF.

---

## 4. Question field

```json
{
  "qtype":   "action_choice | reason_choice",
  "prompt":  "string (BB-defending framing referencing flop+turn history + river card + villain river sizing)",
  "choices": ["fold", "call", "check_raise_small", "check_raise_big", "mixed"]   // for action_choice
            // OR ["bluff_catch_river", "value_raise_river", ...]                  // for reason_choice
}
```

Choices are **string-form** (matching M3/M4 schema). Runtime normalization via `_pfNormalizePostflopChoices` already handles this. No new normalizers needed.

---

## 5. Action menu (5 actions)

| Action ID | Display label | M3/M4 reuse |
|---|---|---|
| `fold` | Fold | yes |
| `call` | Call | yes |
| `check_raise_small` | Check-raise small | yes |
| `check_raise_big` | Check-raise big | yes |
| `mixed` | Mixed / close | yes |

**No new actions in v4.4.0.** On the river BB checks, villain bets, BB folds/calls/check-raises. Donk-leading documented out-of-scope (architecture §5).

---

## 6. heroHandRole vocabulary (Module 5)

| Role | Definition |
|---|---|
| `nutted_value` | Hero has the effective nuts (rivered straight/flush/boat/quads, top set on a safe runout) |
| `strong_value` | Strong made hand that beats villain's value-betting range (two-pair, top-set on wet, TPTK on dry blank) — value-raise candidate |
| `thin_value` | Medium made hand too strong to fold, too weak to raise — call for showdown (two-pair on 4-straight board, TPGK on a scary runout) |
| `bluff_catcher` | A made hand (typically a pair) that beats villain's bluffs but loses to his value — call/fold by MDF + blockers |
| `dominated_bluff_catcher` | A weak/second pair dominated even within the bluff-catch class on this runout — usually fold |
| `marginal_made_hand` | Borderline pair whose call/fold is sizing- and blocker-dependent |
| `blocker_bluff` | Busted hand holding a key blocker (nut flush / nut straight blocker) — river bluff-raise candidate |
| `missed_draw` | Busted flush/straight draw with NO useful blocker — fold (never call) |
| `give_up` | No made hand, no draw history, no blocker — fold |

`thin_value`, `dominated_bluff_catcher`, `blocker_bluff`, and `missed_draw` are the river-salient roles. `missed_draw` is the M5 critical-teaching role: it must never appear with `call` in best/acceptable (auditor M5.R48).

---

## 7. actionReason vocabulary (Module 5)

12 reasons total. River-specific; NO equity-realization reason exists (the river has no equity to realize).

| Reason | Definition | Prior-module analog |
|---|---|---|
| `pot_odds_river_call` | Call because showdown win-probability exceeds the price `B/(1+2B)` | M4 `pot_odds_turn_call` (river = showdown, not equity) |
| `bluff_catch_river` | Call as a bluff-catcher; beats villain's bluffs, loses to value | M4 `bluff_catch_turn` |
| `blocker_bluff_catch_river` | Call BECAUSE hero blocks value combos / unblocks bluffs (the decisive river skill) | new (river-defining) |
| `mdf_defense_river` | Call to stay at/above minimum defense frequency vs the sizing | new (river-defining) |
| `thin_value_call_river` | Call (NOT raise) a medium made hand for showdown / thin value | new (river-specific) |
| `value_raise_river` | Check-raise for value with a hand beating villain's value range | M4 `value_check_raise_turn` |
| `bluff_raise_river` | Check-raise as a bluff leveraging a nut blocker | M4 `blocker_check_raise_turn` |
| `range_disadvantage_river_fold` | Fold because BB's capped range can't profitably continue vs the sizing | M4 `range_disadvantage_turn_fold` |
| `domination_river_fold` | Fold a made hand dominated within the value-losing class on this runout | M4 `domination_turn_fold` |
| `board_change_river_fold` | Fold because the river card itself shifted ranges against hero (flush/straight completed, hero misses) | M4 `board_change_fold` |
| `missed_draw_give_up` | Fold a busted draw — no showdown value, no blocker, never a call | new (river-defining) |
| `mixed_indifference_river` | Solver mixes meaningfully (~30-70%); both lines correct | M4 `mixed_indifference_turn` |

**Why these 12:**
- River-defining trio: `blocker_bluff_catch_river`, `mdf_defense_river`, `missed_draw_give_up` — the three skills with no clean turn analog.
- `thin_value_call_river` formalizes the call-don't-raise distinction.
- NO `equity_realization` reason — deliberately absent because the river has no equity to realize. The auditor (M5.R47) bans draw-equity language in river explanations.
- The mapped reasons (`bluff_catch`, `value_raise`, `bluff_raise`, `domination`, `range_disadvantage`, `board_change`, `pot_odds`, `mixed_indifference`) inherit prior strategic frames renamed with `_river` to keep cross-street weak-spot review clean.

---

## 8. Explanation fields (required)

| Field | Required | Purpose |
|---|---|---|
| `short` | yes | One-line takeaway |
| `riverLogic` | **yes (M5-defining)** | What the river card + villain's sizing mean for the polar range; the M5 equivalent of M4's `turnLogic` |
| `rangeContext` | yes | BB-vs-BTN range frame at the river (polarization + capping) |
| `handLogic` | yes | Strategic frame for THIS hand on THIS runout (made-hand strength vs value range; blocker effect) |
| `sizingLogic` | conditional | Required when recommendedAction is a check-raise; describes raise-sizing rationale and what value the raise targets |
| `commonMistake` | yes | What learners typically get wrong here (over-fold / station / call-busted-draw) |
| `takeaway` | yes | One-sentence pattern to remember |

`riverLogic` is the new field unique to M5. It must describe (1) what the river card did to the runout, (2) villain's polar range given his sizing, and (3) the MDF / blocker logic — WITHOUT invoking draw equity. Runtime surfaces it PROMINENTLY (analogous to M4's `turnLogic`).

---

## 9. conceptTags vocabulary (Module 5)

12 M5-native concepts. 1-4 tags per scenario.

| Concept | Definition |
|---|---|
| `river_bluff_catcher` | Medium-strength made hand calling vs the polar barrel |
| `river_polarization` | Recognizing villain's river range is value-or-bluff |
| `river_mdf` | Minimum defense frequency vs the sizing |
| `river_blocker_defense` | Blocker-driven call/fold selection among equal bluff-catchers |
| `river_value_raise` | Raising a strong made hand for value on the river |
| `river_bluff_raise` | Raising as a blocker-bluff on the river |
| `river_thin_value` | Calling (not raising) a medium hand for showdown |
| `river_missed_draw` | Resolving a busted draw (bluff-raise or fold, never call) |
| `river_range_disadvantage` | Folding because BB's capped range performs worst on this runout |
| `river_board_change` | Recognizing the river card shifted ranges (completed flush/straight/pair) |
| `river_overfold_trap` | Avoiding the over-fold leak — keeping mandatory bluff-catchers |
| `third_barrel_defense` | Defending the final/third barrel after two prior calls |

**M3/M4 reusable tags** (allowed but de-emphasized): `second_barrel_defense`, `turn_blocker_pressure`, `turn_bluff_catcher`, etc. — useful only when explicitly contrasting the river decision with the prior street. M5 seeds prefer the `river_*` natives.

Audit M5.R46 enforces 1-4 tags per scenario, all from the M5 vocab (natives + the explicitly-allowed reusables).

---

## 10. riverCategory enum

```
brick
overcard
flush_complete
straight_complete
board_pair
scare_card
blank_runout
double_pair
range_shift_card
```

**6 used in v4.4.0 seeds:** `brick`, `overcard`, `flush_complete`, `straight_complete`, `board_pair`, `scare_card`. Rest reserved for future expansion.

---

## 11. boardChange enum (river)

```
brick               // river does not change ranges
range_shift_btn     // river favors BTN's value representation
range_shift_bb      // river favors BB's range (rare; BB usually capped)
polarizing          // river makes villain's range maximally polar
draw_resolved       // a draw completed (flush/straight)
counterfeit         // a bluff-catcher got counterfeited (board paired)
boat_possible       // board paired; full houses now possible
```

---

## 12. runoutTexture enum

Describes the full 5-card runout (what hands are POSSIBLE):

```
dry_unpaired           // no flush, no straight, no pair on board
flush_possible         // 3+ of a suit on board
straight_possible      // board allows a one-card straight
double_draw_possible   // both flush and straight possible
paired_board           // board has a pair
paired_flush_possible  // paired AND flush possible
double_paired          // two board pairs
monotone_board         // 3+ to a flush of the SAME suit visible
```

Per-scenario field; describes the texture villain's value/bluff ranges live in.

---

## 13. riverDrawCompletion enum

```
none                  // river completed nothing that was drawing
flush_completed       // the river card completed a flush draw
straight_completed    // the river card completed a straight draw
board_paired          // the river paired a board card
flush_and_straight    // river completes both (rare)
overcard_blank        // river is an overcard that completes nothing
```

Unlike M4's `drawCompletion`, M5 has NO `*_added` values — the river adds nothing (it is the last card). Only completions / blanks.

---

## 14. villainRiverSizing enum (M5-defining)

```
small      // ~33% pot   -> MDF ~75%, merge/thin-value heavy, defend wide
medium     // ~66% pot   -> MDF ~60%, balanced polar
large      // ~100% pot  -> MDF ~50%, polar
overbet    // ~150% pot  -> MDF ~40%, maximally polar, blocker-dependent
```

The single most important M5 field. Drives MDF, which bluff-catchers continue, and whether BB's own value-raises survive. Auditor M5.R26 restricts to these four values; per-scenario `riverLogic` must state the implied MDF.

---

## 15. sourceConfidence values

Same as M3/M4:

| Value | When to use |
|---|---|
| `expert_judgment` | Default; spot is reasonable but not solver-verified |
| `consensus_gto` | Spot is GTO-trivial / textbook (no ambiguity); broad consensus |
| `solver_verified` | Backed by a solver run; requires `solverRunRef` field |

v4.4.0 seeds: all `expert_judgment`. Future v4.4.x can promote textbook spots to `consensus_gto` after review (same pattern as v4.3.0D's M4 promotion of 8 textbook spots).

---

## 16. auditStatus / reviewStatus values

| Field | Allowed values |
|---|---|
| `auditStatus` | `planning_only`, `review_pending`, `approved`, `deprecated`, `draft`, `needs_review` |
| `reviewStatus` | `v4.4.0_seed_candidate` (this sprint), `v4.4.0A_seed_reviewed`, `v4.4.0_final`, `v4.4.1_production` |

v4.4.0 seeds = `auditStatus: "planning_only"` + `reviewStatus: "v4.4.0_seed_candidate"`.

---

## 17. Schema versioning

M5 uses `schemaVersion: "1.3.0"`:
- M1 (board texture) = `1.0.0`
- M2 (flop c-bet IP) = `1.0.0`
- M3 (flop defense OOP) = `1.1.0`
- M4 (turn defense OOP) = `1.2.0`
- **M5 (river defense OOP) = `1.3.0`** (river-specific board fields: `riverCard`, 5-card `cards`, `riverCategory`, `runoutTexture`, `riverDrawCompletion`, `villainRiverSizing`, `suitTextureRiver`; new `riverLogic` explanation field)

The runtime `_pfNormalizePostflopChoices` + `_pfNormalizePostflopAnswer` continue to work for `1.3.0` because choices/best schema is identical to M3/M4's.

---

## 18. Sign-off

- [x] Required fields enumerated
- [x] Spot field locked (NLH_MTT 100BB SRP, BTN 3-barrel vs BB river)
- [x] Board field defines `flopCards` + `turnCard` + `riverCard` + `cards` (5-card array)
- [x] Action menu 5-action (donk excluded; identical to M3/M4)
- [x] heroHandRole adds `thin_value`, `dominated_bluff_catcher`, `blocker_bluff`, `missed_draw`
- [x] actionReason: 12 reasons (river-specific; NO equity-realization reason)
- [x] Explanation fields require new `riverLogic` field
- [x] conceptTags: 12 M5-native + M3/M4 reusable
- [x] riverCategory enum (9 values; 6 used in v4.4.0 seeds)
- [x] boardChange / runoutTexture / riverDrawCompletion / villainRiverSizing enums defined
- [x] `villainRiverSizing` is the M5-defining field (drives MDF)
- [x] schemaVersion bumped to `1.3.0`
- [x] sourceConfidence + auditStatus + reviewStatus values defined
- [x] Compatible with the M3/M4 normalization layer (no new normalizers needed)
- [x] `drawCategory` restricted to none / busted_* (river has no live draws)

**Status: PLANNING-ONLY · APPROVED FOR v4.4.0 PLANNING COMMIT.**
