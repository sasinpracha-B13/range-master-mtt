# Postflop v4.2.0 — Module 3 Schema & Taxonomy

**Status:** Planning-only. No production schema changes; this doc defines the *target* schema for v4.2.4 productionization.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.0-module3-architecture.md`, `postflop-v4.1.2-module2-schema-taxonomy.md`

---

## 1. Summary

Module 3 schema is **derived from** the Module 2 v4.1.2 schema with **three additions** to capture villain-action context:

1. New required field `villainAction` (always `"cbet"` in v4.2.0 seeds).
2. New required field `villainSizing` (always `"small"` in v4.2.0 seeds; reserved for `"big"` in later sprints).
3. New optional field `defenseLogic` inside `explanation` (parallel to `rangeContext` / `handLogic` / `sizingLogic` / `commonMistake` / `takeaway`).

All other M2 fields carry over unchanged. Schema version bumps from `1.0.0` (M2) to `1.1.0` (M3) when productionized in v4.2.4.

---

## 2. Full schema proposal (planning target for v4.2.4)

```jsonc
{
  "id": "string (unique scenario id, kebab+snake mix)",
  "module": "pf_flop_cbet_oop_def",
  "moduleName": "Facing C-bet OOP",
  "schemaVersion": "1.1.0",

  "spot": {
    "format": "NLH_MTT",
    "stackDepth": "100BB",
    "potType": "SRP",
    "preflopAction": "BTN open 2.5x, BB call",
    "street": "flop",
    "heroPosition": "BB",
    "villainPosition": "BTN",
    "heroRole": "preflop_caller_oop",
    "villainRole": "preflop_raiser_ip",
    "villainAction": "cbet",
    "villainSizing": "small"
  },

  "board": {
    "cards": ["As", "8d", "3h"],
    "boardKind": "A_high",
    "suitTexture": "rainbow",
    "textureTags": ["dry", "static"],
    "highCardClass": "A_high"
  },

  "heroHand": ["Th", "8h"],
  "handClass": "mid_pair",
  "heroHandRole": "marginal_made_hand",
  "drawCategory": "backdoor_only",
  "showdownValue": "decent",
  "blockerNote": null,

  "recommendedAction": "call",
  "actionReason": "equity_realization_call",

  "question": {
    "qtype": "action_choice",
    "prompt": "BTN c-bets ~33% pot. What's hero's best action with Th8h?",
    "choices": ["fold", "call", "check_raise_small", "check_raise_big", "mixed"]
  },

  "answer": {
    "best": "call",
    "acceptable": [],
    "bad": ["fold", "check_raise_small", "check_raise_big"],
    "critical": ["check_raise_big"]
  },

  "explanation": {
    "short": "Middle pair with backdoor flush — call.",
    "rangeContext": "BTN's c-bet range is wide; we have decent showdown value.",
    "defenseLogic": "Pair plus backdoor equity clears the ~25% defense threshold easily.",
    "handLogic": "Th8h has 5 outs to two-pair/trips and a backdoor heart flush draw.",
    "sizingLogic": "Calling preserves villain's bluffs; raising folds them out.",
    "commonMistake": "Folding middle pair on dry A-high to a small c-bet is over-folding.",
    "takeaway": "Pair + backdoor on dry boards = call vs small c-bet."
  },

  "conceptTags": ["oop_defense_threshold", "equity_realization_oop", "bluff_catchers"],
  "sourceConfidence": "expert_judgment",

  "auditStatus": "planning_only",
  "reviewStatus": "v4.2.0_seed_candidate"
}
```

---

## 3. Required fields (full list)

| Field | Type | Required? | Notes |
|---|---|---|---|
| `id` | string | yes | Format: `pf_btn_v_bb_srp_100bb_flop_<board>_m3_<qtype>_<heroHand>_v420` |
| `module` | string (literal `"pf_flop_cbet_oop_def"`) | yes | |
| `moduleName` | string (literal `"Facing C-bet OOP"`) | yes | |
| `schemaVersion` | string | yes | `"1.1.0"` for M3 |
| `spot` | object | yes | All 11 sub-fields required (see §2) |
| `board` | object | yes | `cards`, `boardKind`, `suitTexture`, `textureTags`, `highCardClass` |
| `heroHand` | array of 2 strings | yes | Each card must not collide with board |
| `handClass` | string (enum) | yes | See §6 |
| `heroHandRole` | string (enum) | yes | See §7 |
| `drawCategory` | string (enum) | yes | See §8 |
| `showdownValue` | string (enum) | yes | See §9 |
| `blockerNote` | string or null | optional | One-sentence blocker reasoning when relevant |
| `recommendedAction` | string (enum, must equal `answer.best`) | yes | One of the 5 action choices |
| `actionReason` | string (enum) | yes | One of the 8 reasons (see §5) |
| `question` | object | yes | `qtype`, `prompt`, `choices` |
| `answer` | object | yes | `best`, `acceptable[]`, `bad[]`, `critical[]` |
| `explanation` | object | yes | `short`, `rangeContext`, `defenseLogic`*, `handLogic`, `sizingLogic`, `commonMistake`, `takeaway` |
| `conceptTags` | array of strings | yes | 1-4 tags per scenario |
| `sourceConfidence` | string (enum) | yes | `expert_judgment` for v4.2.0 seeds |
| `auditStatus` | string (literal `"planning_only"` for v4.2.0) | yes | |
| `reviewStatus` | string (literal `"v4.2.0_seed_candidate"`) | yes | |

`defenseLogic` is **new in M3 schema**; optional in v4.2.0 (recommended on every seed) and will be required in v4.2.4 productionization.

---

## 4. Action choices (the `choices` enum)

| ID | Label | Sizing |
|---|---|---|
| `fold` | Fold | n/a |
| `call` | Call | match villain's bet |
| `check_raise_small` | Check-raise small | ~3× villain bet |
| `check_raise_big` | Check-raise big | ~4× villain bet |
| `mixed` | Mixed | frequency-dependent |

The `choices` array in every seed is exactly these 5 values, in this order, regardless of question type. (For `reason_choice` qtype, the `choices` array contains reason values instead — see §5.)

---

## 5. Reason choices (the `actionReason` enum + `reason_choice` qtype choices)

The 8 reasons used by v4.2.0 seeds:

| Reason ID | Action implication | Used by (target seed count) |
|---|---|---|
| `value_raise` | check_raise_small / check_raise_big | 4 seeds |
| `protection_raise` | check_raise_small | 2 seeds |
| `semi_bluff_raise` | check_raise_small (via reason_choice) | 2 seeds |
| `blocker_raise` | (acceptable answer; not best) | 1 seed |
| `bluff_catch` | call | 1 seed |
| `equity_realization_call` | call | 9 seeds |
| `range_disadvantage_fold` | fold | 5 seeds |
| `domination_fold` | fold | 1 seed |

**Pruned (not used in v4.2.0):** `pot_odds_call`, `reverse_implied_odds_fold`, `slowplay_call` — see architecture doc §6 for justification.

For `reason_choice` qtype, the `question.choices` array contains the 8 reason IDs above (only the ones plausible for the scenario; the seed audit verifies plausibility).

---

## 6. handClass vocabulary (reused from M2 v4.1.2)

All M2 v4.1.2 handClass values are reused:

| Value | Meaning |
|---|---|
| `set` | three of a kind using a pocket pair |
| `top_two_pair` | two pair using top + middle/second |
| `top_pair_good_kicker` | top pair, kicker T+ |
| `top_pair_weak_kicker` | top pair, kicker 9- |
| `mid_pair` | second/middle pair |
| `bottom_pair` | bottom pair |
| `overpair` | pocket pair higher than the highest board card |
| `underpair` | pocket pair lower than the highest board card (paired-board exception applies — see M2 doc) |
| `combo_draw` | any FD+SD or FD+pair etc. with ≥12 outs |
| `oesd` | open-ended straight draw |
| `gutshot` | gutshot straight draw |
| `flush_draw` | flush draw |
| `nut_flush_draw` | nut flush draw specifically |
| `backdoor_only` | only backdoor equity |
| `no_pair_no_draw` | unpaired air |
| `straight` | made straight (rare for BB on flop) |
| `flush` | made flush |
| `nut_flush` | made nut flush |
| `trips` | three of a kind using one hole card on paired board |
| `full_house` | full house |
| `two_pair` | two non-top two pair |

**No new handClass values needed for M3.** All 24 seeds use the M2 vocabulary above.

---

## 7. heroHandRole vocabulary (mostly reused, 1 reframing)

heroHandRole describes the *function* of the hand in the strategic context:

| Value | Used by (M2) | Used by (M3 new context) |
|---|---|---|
| `nutted_value` | premium made hands | sets, top-set, nut flush |
| `strong_value` | TPGK, two-pair, overpair | TPGK on dry, top set on wet |
| `marginal_made_hand` | mid pair, weak top pair | mid pair, bluff-catcher pairs |
| `bluff_catcher` | (new label for M3) | underpair on paired board, weak made hands on monotone |
| `semi_bluff_combo` | combo draws | combo draws (12+ outs) used as raise |
| `pure_draw` | naked FD/OE | naked FD, naked OE that prefer call |
| `blocker_bluff` | A/K-blocker air with backdoor | blocker bluffs (rarely best in M3 OOP; usually acceptable only) |
| `give_up` | air with 0–4 outs | folds — overcards, dominated weak Ax, no-pair-no-draw |
| `dominated_marginal` | (new label for M3) | hands like AQ on K-high facing range that has AK heavy |
| `slowplay_value` | (new label, deferred to v4.2.4) | (not used in v4.2.0; trips on paired board may want this) |

**`bluff_catcher` and `dominated_marginal` are new labels** vs M2. They are documented here but not added to `postflop_taxonomy.json` until v4.2.4. v4.2.0 seeds use them as planned values inside the JSON — the seed audit (v4.2.1) will accept them as M3-specific extensions.

---

## 8. drawCategory vocabulary (reused from M2)

| Value | Meaning |
|---|---|
| `none` | no draw at all |
| `backdoor_only` | runner-runner FD or SD only |
| `gutshot` | 4 outs straight |
| `oesd` | 8 outs open-ended |
| `flush_draw` | 9 outs flush |
| `combo_draw` | 12+ outs combination |
| `nut_flush_draw` | nut flush draw specifically |

No new values needed for M3.

---

## 9. showdownValue vocabulary (reused from M2)

| Value | Meaning |
|---|---|
| `none` | air, will not win at showdown without improving |
| `low` | underpair / weak high card; rarely best at showdown |
| `decent` | mid pair / weak top pair; often best vs villain's bluffs |
| `high` | top pair good kicker / two pair / overpair |
| `nutted` | set / two-pair / made flush / made straight |

No new values needed for M3.

---

## 10. Explanation field requirements

| Field | Length | Required for M3? | Notes |
|---|---|---|---|
| `short` | 1 sentence (~10–15 words) | yes | Quick takeaway shown above the fold |
| `rangeContext` | 1 sentence | yes | What's villain's c-bet range here? |
| `defenseLogic` | 1 sentence | recommended in v4.2.0; required in v4.2.4 | What's hero's relative equity / why continue? |
| `handLogic` | 1 sentence | yes | Why this hand works (or doesn't) here |
| `sizingLogic` | 1 sentence | yes | Why this action over the alternative (fold/call/raise) |
| `commonMistake` | 1 sentence | yes | What worse players do here |
| `takeaway` | 1 short phrase | yes | Generalization (e.g., "Pair+backdoor on dry = call") |

**No `actionLogic` field** in M3 (M2 had this for reason_choice — collapsed into `sizingLogic` for M3 simplicity).

---

## 11. Concept tag plan (planned for v4.2.4 — not added to postflop_concepts.json in v4.2.0)

Module 3 candidate concepts (7):

| Concept ID | Category | Module | What it teaches |
|---|---|---|---|
| `oop_defense_threshold` | module3 | m3 | Minimum equity / pot odds to continue OOP vs c-bet |
| `check_raise_value` | module3 | m3 | When to raise for value with strong made hands OOP |
| `check_raise_bluff` | module3 | m3 | When to raise as a bluff (combo draws / blocker bluffs) |
| `bluff_catchers` | module3 | m3 | When to call to capture villain's bluffs |
| `equity_realization_oop` | module3 | m3 | Calling cheap to realize equity OOP |
| `range_disadvantage` | module3 | m3 | Recognizing when hero's capped range is dominated |
| `pot_odds_defense` | module3 | m3 | Math-driven minimum-defense calls |

These are **planned only** in v4.2.0. They will be added to `postflop_concepts.json` in v4.2.4 alongside Concept Library wiring. v4.2.0 seeds use them inside `conceptTags` arrays as forward references, with a planning note in the audit doc that the production audit will not validate them until v4.2.4.

**Cross-module concept reuse:** v4.2.0 seeds may also use M2 concepts where they apply (e.g., `pot_control` is a valid concept tag for M3 bluff-catch scenarios). The audit accepts both M2 and planned-M3 concepts.

---

## 12. sourceConfidence rules

All v4.2.0 seeds use `sourceConfidence: expert_judgment`. **No `consensus_gto` claims** in v4.2.0 — none of the 24 seeds were derived from solver output.

Honesty rule (carried from v4.1.2): if a seed's recommendation cannot be backed by a solver run or published GTO source, `sourceConfidence` must be `expert_judgment`. The v4.2.1 GPT review pass may upgrade specific seeds to `consensus_gto` if the reviewer cites a solver-aligned source.

---

## 13. auditStatus / reviewStatus lifecycle

| Stage | auditStatus | reviewStatus | Where it lives |
|---|---|---|---|
| v4.2.0 seed authoring | `planning_only` | `v4.2.0_seed_candidate` | `docs/specs/postflop-v4.2.0-module3-seed-scenarios.json` |
| v4.2.1 GPT review pass | `planning_only` | `v4.2.0_seed_reviewed` (per-seed flip) | same file |
| v4.2.2 final review + commit | `planning_only` | `v4.2.0_final` | same file |
| v4.2.3 migration to production | `review_pending` | `v4.2.0_final` | `postflop/postflop_scenarios.json` (appended) |
| v4.2.4 final approval flip | `approved` | `v4.2.0_gpt_reviewed` (or new flag) | `postflop/postflop_scenarios.json` |

**v4.2.0 seeds never touch production data.** The transition from planning JSON to production JSON happens in v4.2.3, after the seeds have passed strategic review.

---

## 14. ID format

All M3 v4.2.0 seed IDs follow this pattern:

```
pf_btn_v_bb_srp_100bb_flop_<board>_m3_<qtype>_<heroHand>_v420
```

Where:
- `<board>` is the concatenated board cards (e.g., `As8d3h`)
- `<qtype>` is `action` or `reason` (shortened from `action_choice` / `reason_choice`)
- `<heroHand>` is the concatenated hero hand (e.g., `Th8h`)

Example IDs:
- `pf_btn_v_bb_srp_100bb_flop_As8d3h_m3_action_Th8h_v420`
- `pf_btn_v_bb_srp_100bb_flop_QhJh6c_m3_reason_9h8h_v420`

This mirrors the M2 v4.1.2 ID format with `m3` and `v420` suffixes.

---

## 15. Forward compatibility notes

**Not breaking M1 / M2:** None of the schema additions affect Module 1 or Module 2 scenarios. The new `villainAction`, `villainSizing` fields live only on M3 scenarios. The new `defenseLogic` field is optional and only meaningful when `module === 'pf_flop_cbet_oop_def'`.

**Production audit gates:** When v4.2.3 ships M3 to production, the existing R18-R28 rules (M2-specific) are not invoked for M3 scenarios because the moduleId differs. New R29-R40 rules will be added in v4.2.1 specifically for `module === 'pf_flop_cbet_oop_def'`.

**Planning JSON schema header:**

```json
{
  "schemaVersion": "1.1.0",
  "moduleId": "pf_flop_cbet_oop_def",
  "scenarios": [ /* 24 seeds */ ]
}
```

The planning JSON is **not** loaded at runtime. It exists only for review and migration tooling.
