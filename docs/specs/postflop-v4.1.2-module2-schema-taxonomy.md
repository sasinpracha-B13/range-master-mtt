# Postflop v4.1.2 — Module 2 Schema & Taxonomy

**Status:** Planning draft. Not implemented.
**Companion to:** `postflop-v4.1.2-module2-architecture.md`

---

## 1. Design principle

**Strictly additive.** The Module 2 schema reuses the v4.0.1 Module 1 schema and adds new optional fields. Existing Module 1 scenarios remain valid under the extended schema (all new fields default to `null` or are absent). No existing field is renamed, removed, or repurposed.

This means:
- A v4.1.2 audit pass on existing data must give identical results to v4.0.1 (262 / 0 / 0).
- An eventual `pf_audit_rules.js` extension can validate the new fields with `if (scenario.module === 'pf_flop_cbet_ip')` guards, leaving Module 1 rules untouched.

---

## 2. Existing Module 1 scenario shape (reference, unchanged)

```jsonc
{
  "id":              "string (snake_case, prefixed pf_btn_v_bb_srp_100bb_flop_<board>_<qtype>_<n>)",
  "version":         "1.0.0",
  "schemaVersion":   "1.0.0",
  "game":            "NLH_MTT",
  "module":          "pf_board_texture",
  "street":          "flop",
  "spot": {
    "preflopAction":      "BTN_open_2.5x_BB_call",
    "heroPosition":       "BTN",
    "villainPosition":    "BB",
    "effectiveStackBB":   100,
    "potType":            "SRP",
    "playerCount":        2
  },
  "board": {
    "cards":           ["Ah","Kd","5c"],
    "highCardClass":   "A_high" | "K_high" | "Q_high" | "J_high" | "T_high" | "low",
    "textureTags":     [...],
    "suitTexture":     "rainbow" | "two_tone" | "monotone",
    "connectedness":   "disconnected" | "semi_connected" | "connected" | "highly_connected",
    "pairedStatus":    "unpaired" | "paired",
    "dynamicLevel":    1..5,
    "rangeAdvantage":  "preflop_raiser" | "caller" | "neutral" | "split",
    "nutAdvantage":    "preflop_raiser" | "caller" | "neutral" | "split"
  },
  "heroHand":        null | ["Xy","Xy"],
  "handClass":       null | "<see § 4.1>",
  "actionHistory":   [],
  "question": {
    "type":   "range_advantage" | "nut_advantage" | "sizing_family" | "frequency_strategy" | "dynamic_level" | "action_choice",
    "prompt": "string",
    "choices": [{ "id": "string", "label": "string" }, ...]
  },
  "answer": {
    "best":       ["choiceId", ...],
    "acceptable": ["choiceId", ...],
    "bad":        ["choiceId", ...],
    "critical":   ["choiceId", ...]
  },
  "mixing":          null,
  "scoring": { "best": 1.0, "acceptable": 0.5, "bad": 0, "critical": 0 },
  "explanation": {
    "short":         "string",
    "rangeLogic":    null | "string",
    "nutLogic":      null | "string",
    "handLogic":     null | "string",
    "sizingLogic":   null | "string",
    "commonMistake": null | "string"
  },
  "conceptTags":      ["string", ...],
  "difficulty":       1..5,
  "sourceConfidence": "consensus_gto" | "expert_judgment" | "solver_verified",
  "auditStatus":      "approved" | "review_pending" | "draft" | "needs_review"
}
```

---

## 3. Module 2 additions (new fields, all optional outside `pf_flop_cbet_ip`)

```jsonc
{
  // ... all existing fields above ...

  // --- v4.1.2 additions, semantically required for module === 'pf_flop_cbet_ip' ---

  "heroHand":          ["Ah","Kh"],         // REQUIRED in M2 — exactly two cards, no overlap with board.cards
  "handClass":         "top_pair_top_kicker", // REQUIRED in M2 — see § 4.1 vocabulary
  "heroHandRole":      "strong_value",      // NEW field — strategic role; see § 4.2 vocabulary
  "drawCategory":      "none",              // NEW field — see § 4.3 vocabulary
  "showdownValue":     "high",              // NEW field — high | medium | low | none
  "blockerNote":       "Blocks AhX nut combos", // NEW field — optional human note; null if not relevant

  "recommendedAction": "bet_small",         // NEW field — REQUIRED in M2 — see § 4.4 vocabulary
                                            // Mirrors answer.best[0] for action_choice qtype;
                                            // for reason_choice qtype, this is the action whose reason is being asked
  "actionReason":      "value",             // NEW field — REQUIRED in M2 — see § 4.5 vocabulary
                                            // The primary reason for recommendedAction; mirrors answer.best[0] for reason_choice qtype

  // explanation gains optional structured slots; all default to null when absent
  "explanation": {
    // ... existing slots ...
    "rangeContext":  "string",   // NEW — short range-frame paragraph (1–2 sentences)
                                 //       Replaces M1's rangeLogic + nutLogic for M2 brevity
    "handLogic":     "string",   // existing slot, REQUIRED in M2 — explains the hand's role here
    "sizingLogic":   "string",   // existing slot, REQUIRED in M2 when recommendedAction is bet_small/bet_big
    "commonMistake": "string",   // existing slot, REQUIRED in M2 when answer.critical is non-empty
    "takeaway":      "string",   // NEW slot — single-sentence summary line; REQUIRED in M2
    "actionLogic":   "string"    // NEW slot (v4.1.5) — optional; covers "why this action" rationale
                                 // for reason_choice scenarios where sizingLogic is not naturally
                                 // applicable (the question is about reason, not sizing).
                                 // sizingLogic remains required/preferred for action_choice
                                 // where bet-size choice is central.
  }
}
```

### 3.1 What stays unchanged from Module 1

- `id`, `version`, `schemaVersion`, `game`, `street`, `spot`, `board`, `actionHistory`, `mixing`, `scoring`
- `question` shape (only `question.type` enum gains new values; existing values keep working)
- `answer` shape and tier semantics
- `conceptTags` shape (vocabulary may grow — § 5)
- `difficulty`, `sourceConfidence`, `auditStatus`

### 3.2 Migration notes for the existing 11 baseline Module 2 scenarios

When integration ships, the baseline 11 will need:
- `recommendedAction` field added (currently implicit via `answer.best`)
- `actionReason` field added (currently implicit via `conceptTags`)
- `heroHandRole` added (mapping from existing `handClass`)
- `drawCategory` added
- `showdownValue` added
- `explanation.takeaway` added
- Best-answer choice ids migrated from `bet_33` → `bet_small`
- `auditStatus: 'approved'` → `'review_pending'` until re-validated under the new schema

This migration is *not* part of v4.1.2. It's tracked as work for v4.1.3 (or the integration sprint).

---

## 4. Vocabularies

### 4.1 `handClass` (mechanical hand category — extends existing baseline values)

These are *what the hand IS* on this board, regardless of strategy.

| Value | Meaning |
|---|---|
| `set` | Three of a kind using a pocket pair on the board |
| `straight` | Made straight |
| `flush` | Made flush, not nut |
| `nut_flush` | Made nut flush |
| `top_two_pair` | Two pair with both top board cards |
| `two_pair` | Two pair, not top-two |
| `overpair` | Pocket pair higher than every board card |
| `top_pair_top_kicker` | Top pair with the best kicker |
| `top_pair_good_kicker` | Top pair with a strong but not best kicker (e.g., KQ on K-9-x) |
| `top_pair_weak_kicker` | Top pair with a marginal kicker (e.g., K5 on K-9-x) |
| `second_pair` | Pair with the second-highest board card |
| `third_pair_or_lower` | Pair with the third board card or lower |
| `underpair` | Pocket pair lower than the bottom board card. **Paired-board exception:** on a paired high-card board (e.g., K-K-7), an overpair to the unpaired side card (e.g., QQ on K-K-7) may also be labeled `underpair` when pedagogically useful — Q is "underpair" relative to the dominant paired rank (KK = trips region). The mechanical `mid_pair` label also applies; both are accepted by the audit on paired boards. |
| `mid_pair` | Pocket pair between top and bottom board cards |
| `combo_draw` | Two real draws combined (e.g., flush draw + open-ender) |
| `flush_draw` | Flush draw, no straight component (4 cards of same suit, need 1 more) |
| `nut_flush_draw` | Flush draw with the nut card (Ah on monotone hearts; Ah on two-tone hearts) |
| `oesd` | Open-ended straight draw, no flush component |
| `gutshot` | Inside straight draw, no flush component |
| `backdoor_only` | Only backdoor draws (3 cards toward a draw, need 2 more) |
| `no_pair_no_draw` | Air with no equity |
| `trips` | Trips on a paired board (e.g., AK on K-K-x) |

> **Suit-count discipline (required when assigning these labels):**
> - On a **monotone** board (3 of one suit), a hero with **2 cards of that suit** has a *made flush*; a hero with **1 card of that suit** has a *flush draw* (4 of suit, need 1 more); a hero with **0 cards of that suit** has nothing in that suit.
> - On a **two-tone** board (2 of one suit), a hero with **2 cards of that suit** has a *flush draw* (4 of suit, need 1 more); a hero with **1 card of that suit** has a *backdoor flush draw* (3 of suit, need 2 more); a hero with **0 cards of that suit** has nothing.
> - On a **rainbow** board (all 3 suits different), no hero hand has a flush or flush draw beyond a *backdoor* (only when the hero holds 2 of one suit that matches one board card).
>
> The audit must reject scenarios where the suit-count math contradicts the assigned `handClass` / `drawCategory`.

**Existing baseline values reused as-is:** `set`, `top_two_pair`, `overpair`, `underpair`, `combo_draw`, `gutshot`, `backdoor_only`, `no_pair_no_draw`.

### 4.2 `heroHandRole` (strategic role — NEW)

These are *what the hand DOES* in the current spot. A `set` is mechanically a `set` no matter the board, but its role can be `strong_value` (on a dry board) or `protection_bet` (on a wet board) or even `trap_check` (on a board where slow-playing dominates).

| Value | Meaning |
|---|---|
| `strong_value` | Top of range; bets confidently for value |
| `thin_value` | Marginal made hand that bets small to extract from worse |
| `medium_showdown` | Hand with showdown value but doesn't want to face raises |
| `weak_showdown` | Hand with marginal showdown value; usually checks |
| `nut_draw` | Draw with nut potential (nut flush draw, oesd to nuts) |
| `strong_draw` | Strong but non-nut draw (e.g., second-nut FD, high-equity oesd) |
| `weak_draw` | Marginal draw (gutshot only, low FD) |
| `air` | No equity, no draw |
| `blocker_bluff` | Air with meaningful blocker properties (Ah on monotone hearts, A-blocker on paired Ax) |
| `trap_check` | Strong hand that GTO checks at high frequency to balance the checking range |

### 4.3 `drawCategory` (draw type — NEW)

| Value | Meaning |
|---|---|
| `nut_fd` | Nut flush draw |
| `fd` | Flush draw, not nut |
| `oesd` | Open-ended straight draw |
| `gutshot` | Inside straight draw |
| `combo` | Combination of two real draws |
| `backdoor_only` | Only backdoor equity (one card from a real draw) |
| `none` | No draw |

### 4.4 `recommendedAction` (action family — NEW, REQUIRED in M2)

The four options the player chooses from in `action_choice`:

| Value | Sizing range | Meaning |
|---|---|---|
| `bet_small` | ~25–33% pot | Range-bet sizing on dry / range-advantaged boards |
| `bet_big` | ~66–100% pot | Polar / protection sizing on dynamic or nut-advantaged boards |
| `check` | — | Pure or near-pure check (>80% check frequency) |
| `mixed` | — | GTO mixes meaningfully between two actions; both lines are correct |

### 4.5 `actionReason` (action reason — NEW, REQUIRED in M2)

The reasons used in `reason_choice`:

| Value | Meaning |
|---|---|
| `value` | Bet because we're ahead and worse hands call |
| `thin_value` | Bet small for marginal value; a slightly bigger bet would lose worse-hand calls |
| `protection` | Bet to deny equity to live overcards / draws |
| `bluff` | Bet without showdown value, hoping opponent folds better |
| `equity_realization` | Check (or bet) primarily to ensure we get to see future cards / showdown |
| `pot_control` | Check primarily to keep pot small with marginal showdown value |
| `blocker_pressure` | Bet (or check-raise later) using removal to make opponent's calling range thin |
| `range_advantage_stab` | Bet small as part of a range strategy because we have range advantage |
| `give_up` | Check intending to fold to most pressure; no plan to continue |

### 4.6 `showdownValue` (showdown strength — NEW)

| Value | Meaning |
|---|---|
| `high` | Almost always wins at showdown vs opponent's calling range (top pair top kicker on dry, sets, two pair) |
| `medium` | Wins frequently at showdown but not always (mid pair, weak top pair, second pair) |
| `low` | Rarely wins at showdown without improvement (underpairs to one or two board cards, ace-high) |
| `none` | Loses at showdown almost always (air, low draws that miss) |

---

## 5. Concept tag taxonomy (Module 2)

### 5.1 Existing Module 1 concepts reused by Module 2 seeds

These are already in `postflop_concepts.json` and require no changes:

- `range_advantage`
- `nut_advantage`
- `dry_board`, `wet_board`
- `static_board`, `dynamic_board`
- `small_cbet_freq`
- `polar_big_strategy`
- `mixed_small_check`
- `check_strategy`
- `cbet_size_selection`
- `dry_high_card_strategy`
- `low_connected_caution`
- `paired_board_strategy`
- `monotone_board_strategy`
- `two_tone_board_strategy`
- `board_texture_recognition`
- `thin_value_betting`
- `semi_bluff_with_equity`
- `protection_betting`
- `equity_realization`
- `ip_advantage`
- `common_leaks`

### 5.2 New Module 2-specific concepts (PROPOSED — NOT added in v4.1.2)

Each is *referenced* in seed scenarios where appropriate but tagged as `[planned]` in the audit plan until the corresponding `postflop_concepts.json` entry is added in a later patch.

| Proposed key | Display name | One-line definition |
|---|---|---|
| `value_betting` | Value betting | Betting a strong hand because worse hands call |
| `pot_control` | Pot control | Checking with medium showdown value to keep the pot small |
| `blocker_pressure` | Blocker pressure | Bluffing with hands that block opponent's strong calling range |
| `give_up_strategy` | Give-up strategy | Checking with the intent to fold to pressure |
| `hand_class_recognition` | Hand class recognition | Knowing which strategic class your hand is in |

These five become real concept entries (with full long-defs and examples) in the integration sprint. The seed scenarios in v4.1.2 attach them as `conceptTags` so the audit can flag them as `[planned]` rather than reject them — this also lets the future Concept Library expansion pull in the right list without re-tagging scenarios.

---

## 6. ID convention for Module 2 seeds

Module 1 IDs:
```
pf_btn_v_bb_srp_100bb_flop_<board>_<qtype>[_v407]
```

Module 2 IDs (v4.1.2 seeds):
```
pf_btn_v_bb_srp_100bb_flop_<board>_m2_<qtype>_<handTag>_v412
```

Examples:
- `pf_btn_v_bb_srp_100bb_flop_As8d3h_m2_action_AhKh_v412`
- `pf_btn_v_bb_srp_100bb_flop_Kh9c4s_m2_reason_AcQh_v412`

The `_v412` suffix:
- Differentiates v4.1.2 seed scenarios from the v4.0.0 baseline 11 (which use the older ID convention without an `_m2_` infix).
- Lets future generators strip-and-replace just the `*_v412` ids, the same idempotent pattern v4.0.7 used for `*_v407`.

---

## 7. Validation rules summary (full list in audit-plan.md)

Hard rules a Module 2 scenario must satisfy:

1. `module === 'pf_flop_cbet_ip'`
2. `heroHand` is exactly 2 cards, none of which appear in `board.cards`
3. `handClass` is from § 4.1 vocabulary
4. `heroHandRole` is from § 4.2 vocabulary
5. `drawCategory` is from § 4.3 vocabulary
6. `showdownValue` is from § 4.6 vocabulary
7. `recommendedAction` is from § 4.4 vocabulary AND appears in `answer.best` for `action_choice` qtype
8. `actionReason` is from § 4.5 vocabulary AND appears in `answer.best` for `reason_choice` qtype
9. `question.type` is `action_choice` or `reason_choice`
10. `question.choices` ids match the exhaustive choice enum for that qtype
11. `answer.best` is non-empty
12. No choice id appears in more than one of `best`/`acceptable`/`bad`/`critical`
13. `explanation.short`, `explanation.handLogic`, and `explanation.takeaway` are non-empty strings
14. `explanation.sizingLogic` is non-empty when `recommendedAction` is `bet_small` or `bet_big`
15. `explanation.commonMistake` is non-empty when `answer.critical` is non-empty
16. Every `conceptTag` is either in `postflop_concepts.json` OR in the § 5.2 `[planned]` list
17. `sourceConfidence` is `consensus_gto`, `expert_judgment`, or `solver_verified`
18. `sourceConfidence === 'solver_verified'` requires a `solverRunRef` field (not added in v4.1.2 seeds)
19. `auditStatus === 'review_pending'` for all v4.1.2 seeds

---

## 8. Backward compatibility checklist

Before integration, the audit script must verify:

- [ ] Every Module 1 scenario still validates with the extended schema (all new fields are absent → treated as null).
- [ ] No Module 1 audit rule (R01–R17) regresses.
- [ ] Existing 11 Module 2 baseline scenarios either (a) still pass under the extended schema as `module: pf_flop_cbet_ip` legacy entries, or (b) are explicitly migrated.
- [ ] `getModule1Scenarios()` (in `index.html`) continues to return only `module === 'pf_board_texture'` scenarios.
- [ ] `_pfBuildConceptQueue` and `_pfBuildWeakSpotQueue` continue to draw only from Module 1 scenarios when called from the existing Module 1 surfaces.

---

## 9. Future schema extensions (out of v4.1.2 scope)

Tracked here for visibility, not implemented:

- `solverRunRef` — pointer to a solver tree dump that backed the `solver_verified` confidence label
- `mixingDistribution` — for scenarios where best is `mixed`, the GTO frequency split (e.g., `{ bet_small: 0.55, check: 0.45 }`)
- `multiActionPath` — turn / river decision tree for Module 4 / Module 5
- `villainRangeNote` — short text describing how Villain's range narrows after each action
- `bbDefenseModel` — for Module 3 (BB defense vs c-bet)
