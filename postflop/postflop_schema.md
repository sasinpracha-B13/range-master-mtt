# Post-flop Scenario Schema — v1.0.0

This document is the **strict spec** for every scenario in `postflop_scenarios.json`. The audit tool enforces it. Any field below marked `required` must be present; `nullable` means present but may be `null` when not applicable.

---

## File envelope

```jsonc
{
  "schemaVersion": "1.0.0",         // bump when shape changes; app refuses mismatched data
  "generatedAt": "2026-05-04",
  "scenarios": [ /* array of Scenario objects */ ]
}
```

---

## Scenario object

```jsonc
{
  // === Identity ===
  "id":              "pf_btn_v_bb_srp_100bb_flop_AhKd5c_freq_001",   // required, globally unique, stable for SRS
  "version":         "1.0.0",                                          // required, scenario-level semver
  "schemaVersion":   "1.0.0",                                          // required, must equal envelope schemaVersion

  // === Domain context ===
  "game":            "NLH_MTT",                                        // required, enum
  "module":          "pf_board_texture",                               // required, enum: pf_board_texture | pf_flop_cbet_ip | pf_bb_def_vs_cbet (v4.1)
  "street":          "flop",                                           // required, enum: flop | turn | river

  // === Pre-flop spot ===
  "spot": {
    "preflopAction":      "BTN_open_2.5x_BB_call",   // required, free-text canonical key
    "heroPosition":       "BTN",                     // required, enum: SB | BB | UTG | UTG1 | LJ | HJ | CO | BTN
    "villainPosition":    "BB",                      // required, same enum
    "effectiveStackBB":   100,                       // required, integer
    "potType":            "SRP",                     // required, enum: SRP | 3BP | 4BP | limped
    "playerCount":        2                          // required, integer; v4.0 only supports 2
  },

  // === Board ===
  "board": {
    "cards":           ["Ah", "Kd", "5c"],          // required, array of card strings; flop=3, turn=4, river=5
    "highCardClass":   "A_high",                    // required, enum from taxonomy
    "textureTags":     ["dry", "disconnected", "rainbow"],  // required, array, all values from taxonomy
    "suitTexture":     "rainbow",                   // required, enum: rainbow | two_tone | monotone
    "connectedness":   "disconnected",              // required, enum from taxonomy
    "pairedStatus":    "unpaired",                  // required, enum: unpaired | paired | trips
    "dynamicLevel":    1,                           // required, integer 1–4
    "rangeAdvantage":  "preflop_raiser",            // required, enum: preflop_raiser | caller | neutral | split
    "nutAdvantage":    "preflop_raiser"             // required, enum, same set as rangeAdvantage
  },

  // === Hero hand (Module 2+ only; null for board-texture questions) ===
  "heroHand":  ["As", "Kc"],                        // nullable, array of card strings (length 2)
  "handClass": "top_pair_top_kicker",               // nullable, enum from concepts list (see hand-class section)

  // === Action history (empty for flop-decision questions; populated for turn/river later) ===
  "actionHistory": [],                              // required, array (may be empty)

  // === Question ===
  "question": {
    "type":   "frequency_strategy",                 // required, enum (see Question Types section)
    "prompt": "On A♥K♦5♣, BTN open vs BB call. As preflop raiser (BTN), what's the optimal c-bet strategy here?",
    "choices": [
      { "id": "check_heavy",  "label": "Check most of the range" },
      { "id": "small_freq",   "label": "C-bet 25–33% small with high frequency (~70%+)" },
      { "id": "polar_big",    "label": "C-bet 75%+ polar with low frequency" },
      { "id": "mixed_split",  "label": "Split 50/50 small bet vs check" }
    ]
  },

  // === Answer ===
  "answer": {
    "best":       ["small_freq"],            // required, array of choice ids; non-empty
    "acceptable": [],                        // required, array (may be empty)
    "bad":        ["check_heavy", "mixed_split"],  // required, array (may be empty)
    "critical":   ["polar_big"]              // required, array (may be empty)
  },

  // === Optional mixing data (frequency-strategy questions) ===
  "mixing": {                                // nullable; present when question is frequency-aware
    "small_freq":   0.75,
    "check_heavy":  0.25,
    "polar_big":    0.0,
    "mixed_split":  0.0
  },

  // === Scoring (multi-tier) ===
  "scoring": {
    "best":        1.0,                      // required, must be 1.0
    "acceptable":  0.5,                      // required, must be in [0.25, 0.5, 0.75]
    "bad":         0,                        // required, must be 0
    "critical":    0                         // required, must be 0; critical also flags
  },

  // === Explanation (multi-section, learner-friendly) ===
  "explanation": {
    "short":          "Small frequent c-bet — BTN has both range and nut advantage on dry A-high boards.",      // required, non-empty
    "rangeLogic":     "BTN open range (~45% of hands) contains much more A-x than BB call range...",            // nullable
    "nutLogic":       "BTN's range contains AA, AK, KK at full frequency; BB 3-bets these...",                 // nullable
    "handLogic":      null,                                                                                     // nullable
    "sizingLogic":    "Small bet (25–33%) achieves: (1) high fold equity from BB's missed Broadways...",       // nullable
    "commonMistake":  "Players often overbet on A-high dry boards thinking 'big bet for value'..."             // nullable
  },

  // === Tagging ===
  "conceptTags":  ["range_advantage", "nut_advantage", "small_cbet_freq", "dry_board", "A_high_board", "BTN_v_BB_SRP"],  // required, array, all values from postflop_concepts.json
  "difficulty":   1,                                  // required, integer 1–5
  "sourceConfidence": "consensus_gto",                // required, enum (see below)
  "auditStatus":  "approved"                          // required, enum: draft | needs_review | approved | deprecated
}
```

---

## Field reference

### Identity

| Field | Type | Notes |
|---|---|---|
| `id` | string | Globally unique. Format: `pf_<spot-key>_<street>_<board-key>_<n>`. Stable across versions (SRS depends on it). |
| `version` | semver | Bump when reasoning changes. Player SRS history persists across versions. |
| `schemaVersion` | semver | Must equal envelope schemaVersion. App refuses mismatch. |

### Domain context

| Field | Type | Notes |
|---|---|---|
| `game` | enum | `NLH_MTT` only in v4.0. `NLH_CASH` reserved for future. |
| `module` | enum | `pf_board_texture` (Module 1), `pf_flop_cbet_ip` (Module 2). v4.1 adds `pf_bb_def_vs_cbet`. |
| `street` | enum | `flop` only in v4.0. `turn`, `river` reserved. |

### Spot

`heroPosition` and `villainPosition` are required even when one player is unknown — use the canonical seat name. `playerCount=2` only in v4.0; multiway will need schema review.

### Board

`cards` array length must match `street`: 3 for flop, 4 for turn, 5 for river. Card format: rank-then-suit, two characters, e.g., `"As"`, `"Td"`, `"2h"`. Suits: `s` (spades), `h` (hearts), `d` (diamonds), `c` (clubs). Ranks: `A K Q J T 9 8 7 6 5 4 3 2` (capital).

`highCardClass` derives mechanically from the highest rank but is stored explicitly so audit can verify consistency:

| Top rank | highCardClass |
|---|---|
| A | `A_high` |
| K | `K_high` |
| Q | `Q_high` |
| J | `J_high` |
| T | `T_high` |
| ≤9 | `low` |

`textureTags` is the rich qualitative set — see `postflop_taxonomy.json` for the full list. Any combination is allowed except contradictory pairs (audit rule R13).

`dynamicLevel` 1–4 captures how much equity will swing on future streets:

| Level | Meaning | Examples |
|---|---|---|
| 1 | static | A♥K♦5♣ rainbow — most cards don't change much |
| 2 | semi-static | K♥T♦2♠ rainbow — some draws but limited |
| 3 | dynamic | J♥T♠9♣ — many straights/flushes possible |
| 4 | very-dynamic | 8♥7♥6♣ — equity swings every card |

`rangeAdvantage` and `nutAdvantage` are independent. A board can give one player range advantage and the other nut advantage (e.g., 9♣8♣7♦ — BB calling range has more 9-x and 8-x giving slight range adv, but BTN has more overpairs / sets giving nut adv).

### Hero hand

Module 1 questions have `heroHand: null` and `handClass: null`. Module 2+ questions populate both.

`handClass` is a string from the hand-class enum. Common values:

```
top_pair_top_kicker
top_pair_weak_kicker
second_pair
third_pair
overpair
underpair
set
two_pair
straight
flush
trips
quads
straight_flush
royal_flush
gutshot
open_ended
flush_draw
combo_draw          // straight + flush draw
backdoor_only
overcards
ace_high
no_pair_no_draw     // air
weak_made_hand
```

### Question types

| `question.type` | Meaning | Choices style | Used in module |
|---|---|---|---|
| `range_advantage` | Who has range advantage? | Players (`preflop_raiser` / `caller` / `neutral` / `split`) | Module 1 |
| `nut_advantage` | Who has nut advantage? | Same as above | Module 1 |
| `dynamic_level` | How dynamic is this board? | `static` / `semi_static` / `dynamic` / `very_dynamic` | Module 1 |
| `frequency_strategy` | What c-bet frequency family? | Sizing-family choices | Module 1 |
| `sizing_family` | What sizing family for the raiser? | Sizing-family choices | Module 1 |
| `action_choice` | Hero's action in spot | `check`, `bet_33`, `bet_75` (Module 2); `fold`, `call`, `raise` (Module 3) | Module 2+ |

### Answer

`best` MUST be non-empty. A question may have multiple `best` choices (e.g., when two sizings split 50/50).

`acceptable` is for choices that are reasonable but not optimal (e.g., a small bet when a check is best). Partial credit only.

`bad` is for choices that lose meaningful EV but are not catastrophic (e.g., overbetting a board where small is best).

`critical` is reserved for **strategic blunders** — choices that systematically destroy EV across the spot family (e.g., open-folding the BTN, polar-overbetting the wrong board). Critical answers are flagged in stats so we can track player leaks.

### Mixing

Optional. When present, sums to 1.0 across all choices, allowing display of GTO frequency bars on the feedback screen (similar to preflop). Required for `frequency_strategy` and `sizing_family` questions; optional otherwise.

### Scoring

Scoring tiers are fixed by audit rule R11 to prevent inconsistency:

| Tier | Score |
|---|---|
| `best` | `1.0` |
| `acceptable` | `0.25`, `0.5`, or `0.75` (author choice) |
| `bad` | `0` |
| `critical` | `0` (plus flag) |

If the author wants finer gradations for mixed strategies, set the question to `frequency_strategy` and use `mixing` to compute frequency-weighted partial credit at runtime (formula: `score = sum(userPick × actualFreq[pick])`).

### Explanation

The `short` field is REQUIRED and is what the player sees first on the feedback screen. Keep it under 140 characters when possible — one or two crisp sentences naming the principle.

The other sections are nullable but **strongly encouraged**. Every section that can teach a principle should be filled in. Nulls are acceptable when the section is genuinely not applicable (e.g., `handLogic` is null for Module 1 board-texture questions).

| Section | When to fill | Style |
|---|---|---|
| `short` | Always | One-line principle. |
| `rangeLogic` | When ranges drive the answer | Explain which range hits this board harder. |
| `nutLogic` | When nuts shift between players | Explain who has the top of range. |
| `handLogic` | When hero has a hand and the hand class drives the action | Connect hand class → range strategy. |
| `sizingLogic` | When sizing matters | Why this sizing extracts more EV than alternatives. |
| `commonMistake` | When there's a known leak | Name the leak and why it loses EV. |

### Tagging

`conceptTags` ties scenarios to the concept taxonomy. Every tag must exist in `postflop_concepts.json`. Tagging is what powers the concept-mastery dashboard and the SRS recommendation engine.

`difficulty` 1–5:

| | Meaning |
|---|---|
| 1 | Foundation — "you should never miss this" |
| 2 | Intermediate — common spot, some thought |
| 3 | Solid — requires combining 2+ principles |
| 4 | Advanced — subtle mixing or counterintuitive answer |
| 5 | Expert — solver-precision, edge case |

`sourceConfidence`:

| Value | Meaning |
|---|---|
| `consensus_gto` | Multiple solvers agree; uncontroversial |
| `solver_verified` | Author independently verified one solver output |
| `expert_judgment` | Coaching consensus; solver work not directly applicable |
| `community_consensus` | Multiple training site curricula agree |
| `experimental` | Author opinion; needs review (must NOT ship `auditStatus=approved`) |

`auditStatus`:

| Value | App behavior |
|---|---|
| `draft` | Visible in audit tool only; NOT loaded by app |
| `needs_review` | Visible in audit tool with warning; NOT loaded by app |
| `approved` | Loaded by app; passes all audit rules |
| `deprecated` | Excluded from new sessions; SRS history preserved for read-only |

---

## Concept taxonomy reference

`postflop_concepts.json` is the source of truth. Each concept entry:

```jsonc
{
  "key": "range_advantage",
  "displayName": "Range advantage",
  "shortDef": "Whose preflop range hits this board class harder, by EV.",
  "longDef":  "A player has range advantage when their preflop range...",
  "examples": [
    "BTN open vs BB call on A-high dry: BTN has range advantage (more A-x).",
    "..."
  ],
  "relatedConcepts": ["nut_advantage", "board_texture_recognition"]
}
```

The concept taxonomy is intentionally limited to ~24 concepts in v4.0 to keep the audit gate practical. New concepts are added with each module expansion (v4.1+).

---

## Board taxonomy reference

`postflop_taxonomy.json` is the source of truth for all enums:

```jsonc
{
  "version": "1.0.0",
  "highCardClass":   ["A_high", "K_high", "Q_high", "J_high", "T_high", "low"],
  "textureTags":     [ /* full list */ ],
  "suitTexture":     ["rainbow", "two_tone", "monotone"],
  "connectedness":   ["disconnected", "semi_connected", "connected", "highly_connected"],
  "pairedStatus":    ["unpaired", "paired", "trips"],
  "dynamicLevel":    { "1": "static", "2": "semi_static", "3": "dynamic", "4": "very_dynamic" },
  "rangeAdvantage":  ["preflop_raiser", "caller", "neutral", "split"],
  "nutAdvantage":    ["preflop_raiser", "caller", "neutral", "split"],
  "sizingFamily":    ["range_small", "mixed_small_check", "polar_big", "check_heavy", "low_frequency"],
  "contradictoryPairs": [
    ["monotone", "rainbow"],
    ["monotone", "two_tone"],
    ["rainbow",  "two_tone"],
    ["paired",   "trips"],
    ["dry",      "wet"],
    ["disconnected", "highly_connected"]
  ]
}
```

Audit rule R13 reads `contradictoryPairs` to flag invalid tag combinations.

---

## Versioning rules

- `schemaVersion` bump (e.g., `1.0.0` → `1.1.0`) — additive change (new optional fields). App handles backward compat.
- `schemaVersion` major bump (e.g., `1.x` → `2.0`) — breaking change. Old data needs migration script before app loads it.
- `version` per scenario bump — preserves SRS continuity; player sees a "scenario updated" indicator on next encounter.

---

## App load contract

When the app loads `postflop_scenarios.json`, it MUST:

1. Verify `envelope.schemaVersion === APP_KNOWN_SCHEMA_VERSION`. If not, refuse to load and surface an upgrade-required banner.
2. Filter to `auditStatus === "approved"`. Drafts are invisible.
3. Verify each scenario's `conceptTags` exist in the loaded concepts file. Skip + log any with unknown tags.
4. Index by `id` for SRS lookup.
5. Index by `module` and `conceptTags` for module / weakness drill queries.

The app NEVER computes truth values for postflop scenarios. It only serves data.

---

## Open questions for review

1. **Acceptable scoring granularity** — is `0.25 / 0.5 / 0.75` enough, or should authors have any value in `[0, 1]`? (Current proposal: locked to three steps for consistency.)
2. **Hand-class enum extensibility** — when v4.1 adds turn/river, the hand-class enum will need `top_two_pair`, `flush_blocker`, etc. Should the enum live in `postflop_concepts.json` or a separate file?
3. **`mixing` block format** — is keying by choice id sufficient, or do we need explicit sizing-frequency pairs (`{ "bet_33": { "freq": 0.6, "ev": +0.42 }, ... }`) for richer feedback later?
4. **Critical-flag UI** — should critical leaks block progression (force review) or merely flag in stats? (Current proposal: flag only; no blocking.)
5. **ICM in v4.0** — confirm we keep ICM out and limit to 100BB chipEV. Adding ICM later requires schema field `icmContext: { ... }`.

---

End of schema spec.
