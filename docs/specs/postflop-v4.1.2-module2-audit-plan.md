# Postflop v4.1.2 — Module 2 Audit Plan

**Status:** Rules implemented in **v4.1.3** as a standalone seed auditor at `tools/audit-postflop-module2-seed.ps1`. The production auditor (`tools/audit-postflop-ps.ps1`) and in-browser auditor (`postflop/postflop_audit_rules.js`) remain untouched until the 11 baseline Module 2 scenarios are migrated to the v4.1.2 schema. See `postflop-v4.1.3-module2-audit-tooling-report.md` for implementation details.

**Companion to:** `postflop-v4.1.2-module2-architecture.md`, `postflop-v4.1.2-module2-schema-taxonomy.md`, `postflop-v4.1.2-module2-seed-scenarios.json`

---

## 1. Scope

This audit plan covers **Module 2 scenarios only** (`module === 'pf_flop_cbet_ip'`). Module 1 scenarios are validated by the existing v4.0.x rules (R01–R17), which remain authoritative.

The Module 2 rules are designed to:
- Catch every structural error (collisions, overlaps, missing fields)
- Flag every semantic risk (sourceConfidence honesty, action plausibility)
- **Not regress** any Module 1 rule — additive only

---

## 2. Hard rules (block on fail)

These are mandatory — a Module 2 scenario that fails any of them is rejected.

### 2.1 Card-collision

**Rule M2.R01** — `heroHand` cards must not appear in `board.cards`.

Implementation:
```ps1
foreach ($card in $scenario.heroHand) {
  if ($card -in $scenario.board.cards) { fail "M2.R01 collision: $card in heroHand and board" }
}
```

### 2.2 Hero hand cardinality

**Rule M2.R02** — `heroHand` is exactly 2 cards (a 2-character string each: rank + suit).

### 2.3 Card validity

**Rule M2.R03** — every card in `heroHand` and `board.cards` is a valid 2-character poker card (rank ∈ {2,3,4,5,6,7,8,9,T,J,Q,K,A}, suit ∈ {h,d,c,s}).

### 2.4 No internal hero-hand collision

**Rule M2.R04** — the two cards in `heroHand` are distinct.

### 2.5 Choice-id integrity

**Rule M2.R05** — every id in `answer.{best,acceptable,bad,critical}` appears in `question.choices[].id`.

### 2.6 Tier non-overlap

**Rule M2.R06** — no choice id appears in more than one of `best` / `acceptable` / `bad` / `critical`.

### 2.7 Best non-empty

**Rule M2.R07** — `answer.best` has at least one entry.

### 2.8 Question-type validity

**Rule M2.R08** — `question.type` is `action_choice` or `reason_choice`. (Future qtypes added to the enum extend this rule additively.)

### 2.9 action_choice choice set

**Rule M2.R09** — when `question.type === 'action_choice'`, `question.choices[].id` set is exactly `{bet_small, bet_big, check, mixed}` (order doesn't matter, but all four must be present and no extras).

### 2.10 reason_choice choice set

**Rule M2.R10** — when `question.type === 'reason_choice'`, every `question.choices[].id` is drawn from the enum `{value, thin_value, protection, bluff, equity_realization, pot_control, blocker_pressure, range_advantage_stab, give_up}`. The number of choices must be 3 or 4.

### 2.11 recommendedAction validity

**Rule M2.R11** — `recommendedAction` is non-null and ∈ `{bet_small, bet_big, check, mixed}`.

### 2.12 actionReason validity

**Rule M2.R12** — `actionReason` is non-null and drawn from the reason_choice enum.

### 2.13 recommendedAction ↔ best (action_choice)

**Rule M2.R13** — when `question.type === 'action_choice'`, `recommendedAction` must appear in `answer.best`.

### 2.14 actionReason ↔ best (reason_choice)

**Rule M2.R14** — when `question.type === 'reason_choice'`, `actionReason` must appear in `answer.best`.

### 2.15 handClass validity

**Rule M2.R15** — `handClass` ∈ vocabulary defined in schema-taxonomy § 4.1.

### 2.16 heroHandRole validity

**Rule M2.R16** — `heroHandRole` ∈ vocabulary defined in schema-taxonomy § 4.2.

### 2.17 drawCategory validity

**Rule M2.R17** — `drawCategory` ∈ `{nut_fd, fd, oesd, gutshot, combo, backdoor_only, none}`.

### 2.18 showdownValue validity

**Rule M2.R18** — `showdownValue` ∈ `{high, medium, low, none}`.

### 2.19 Explanation completeness — short

**Rule M2.R19** — `explanation.short` is a non-empty string.

### 2.20 Explanation completeness — handLogic

**Rule M2.R20** — `explanation.handLogic` is a non-empty string.

### 2.21 Explanation completeness — takeaway

**Rule M2.R21** — `explanation.takeaway` is a non-empty string.

### 2.22 Explanation completeness — sizingLogic when betting

**Rule M2.R22** — when `recommendedAction` ∈ `{bet_small, bet_big}`, `explanation.sizingLogic` is a non-empty string.

### 2.23 Explanation completeness — commonMistake when critical exists

**Rule M2.R23** — when `answer.critical` is non-empty, `explanation.commonMistake` is a non-empty string.

### 2.24 Concept tag validity

**Rule M2.R24** — every entry in `conceptTags` is either:
- (a) a `key` in `postflop/postflop_concepts.json`, OR
- (b) a key in the `[planned]` list defined in schema-taxonomy § 5.2.

Keys in (b) trigger a *warning* (not a hard fail) reminding the maintainer that the concept needs an entry in `postflop_concepts.json` before integration.

### 2.25 sourceConfidence honesty

**Rule M2.R25** — when `sourceConfidence === 'solver_verified'`, the scenario must include a `solverRunRef` field pointing at the solver tree. Without it, the audit fails. (The v4.1.2 seed has zero solver runs, so all v4.1.2 seeds use `expert_judgment`.)

### 2.26 auditStatus discipline

**Rule M2.R26** — `auditStatus` ∈ `{review_pending, draft, needs_review, approved}`. v4.1.2 seeds must use `review_pending`.

### 2.27 Family naming consistency

**Rule M2.R27** — the choice ids in answer tiers use family-level names (`bet_small`, `bet_big`) — not size-specific (`bet_25`, `bet_33`, `bet_75`, `bet_100`). The existing baseline 11 use `bet_33` and will need a migration before they pass this rule.

### 2.28 ID uniqueness

**Rule M2.R28** — every Module 2 scenario `id` is unique within the production data set (after merge).

### 2.29 ID convention compliance

**Rule M2.R29** — Module 2 v4.1.2 seed ids match the pattern `pf_btn_v_bb_srp_100bb_flop_<board>_m2_<qtype>_<handTag>_v412`.

### 2.30 Single-spot enforcement (v4.1.2)

**Rule M2.R30** — `spot.heroPosition === 'BTN'`, `spot.villainPosition === 'BB'`, `spot.potType === 'SRP'`, `spot.effectiveStackBB === 100`, `spot.preflopAction === 'BTN_open_2.5x_BB_call'`, `street === 'flop'`. v4.1.2 trains exactly one spot. Future modules will relax this.

---

## 3. Soft rules (warning on fail)

These produce warnings but do not block. They flag scenarios that are *likely* wrong but might be intentional outliers — humans review the warnings during the GPT-review + integration sprint.

### 3.1 Action vs handClass plausibility

**Rule M2.S01 — overpair-on-low-connected-bet**
- If `handClass === 'overpair'` AND `board.textureTags` includes `low_connected` AND `recommendedAction === 'bet_small'` or `'bet_big'`, warn: "Overpairs on low-connected boards usually check. Confirm intentional."

**Rule M2.S02 — air-on-dry-check**
- If `handClass === 'no_pair_no_draw'` AND `board.textureTags` includes `dry` AND `recommendedAction === 'check'`, warn: "Air on dry boards usually range-stabs. Confirm intentional."

**Rule M2.S03 — top-pair-good-kicker-bet-big**
- If `handClass` ∈ `{top_pair_top_kicker, top_pair_good_kicker}` AND `board.textureTags` includes `dry` AND `recommendedAction === 'bet_big'`, warn: "Strong top pair on dry boards usually bets small high-frequency. Big sizing is a known leak."

**Rule M2.S04 — small-underpair-bet**
- If `handClass === 'underpair'` AND `showdownValue ∈ {low, none}` AND `recommendedAction === 'bet_small'`, warn: "Small underpairs usually check for showdown. Confirm intentional."

**Rule M2.S05 — air-on-monotone-stab**
- If `board.suitTexture === 'monotone'` AND `handClass === 'no_pair_no_draw'` AND `drawCategory === 'none'` AND `recommendedAction` starts with `bet_`, warn: "Naked air on monotone usually checks. Confirm intentional (e.g., blocker bluff)."

### 3.2 Critical-tier coverage

**Rule M2.S06 — no critical answer on a leaky board**
- If `board.textureTags` includes any of `{ace_high_dry, low_connected, monotone}` AND `answer.critical` is empty, warn: "Boards with classic leaks should usually flag at least one critical answer. Confirm none applies."

### 3.3 Concept tag depth

**Rule M2.S07 — too few concept tags**
- If `conceptTags.length < 2`, warn: "Module 2 scenarios should carry 2+ concept tags."

### 3.4 Explanation depth

**Rule M2.S08 — short explanation length**
- If `explanation.short.length < 40` chars OR `explanation.handLogic.length < 60` chars, warn: "Explanation may be too thin to teach."

---

## 4. Cross-scenario coverage rules (run once per audit)

These check the seed set as a whole, not individual scenarios.

### 4.1 Board coverage

**Rule M2.C01** — at least one scenario in each of these board buckets:
- A-high (any suit pattern)
- K-high or Q-high
- Low-connected (high card ≤ 9)
- Two-tone (any suit, suitTexture=`two_tone`)
- Paired (pairedStatus=`paired`)
- Monotone (suitTexture=`monotone`)

### 4.2 Action coverage

**Rule M2.C02** — at least one scenario per `recommendedAction` value (`bet_small`, `bet_big`, `check`, `mixed`).

### 4.3 Hand-role coverage

**Rule M2.C03** — at least one scenario per major `heroHandRole` value: `strong_value`, `thin_value`, `medium_showdown`, `weak_showdown`, `air`. (Other roles like `nut_draw`, `blocker_bluff`, `trap_check` are nice-to-have but not required for v4.1.2 seed.)

### 4.4 Question-type coverage

**Rule M2.C04** — at least 4 scenarios use `reason_choice` (≥ ~15% of seed). v4.1.2 seed has 6 of 24 = 25%.

### 4.5 Critical-leak representation

**Rule M2.C05** — at least 5 scenarios have non-empty `answer.critical`. v4.1.2 seed has 16 of 24 with critical answers.

---

## 5. Integration rules (apply at production-merge time, not before)

These rules apply only when the seed JSON is being merged into `postflop/postflop_scenarios.json`:

### 5.1 No id collision with existing data

**Rule M2.I01** — every `id` being merged is not already present in production data.

### 5.2 Baseline-vs-seed reconciliation

**Rule M2.I02** — for each board in the seed, log how many existing baseline scenarios use that board. For v4.1.2 seeds, this should be 0 (we picked non-overlapping boards). If non-zero, flag for human decision (replace baseline / coexist / refactor).

### 5.3 Choice-naming reconciliation

**Rule M2.I03** — log every scenario in production data that uses a non-family choice id (e.g., `bet_33`). Existing baseline 11 will all flag here. They must be migrated to family naming before the audit moves to "approved" globally.

### 5.4 Concept tag reconciliation

**Rule M2.I04** — log every scenario that references a `[planned]` concept (per schema-taxonomy § 5.2). The corresponding `postflop/postflop_concepts.json` entries must be added before flipping the seed `auditStatus` to `approved`.

---

## 6. Audit script implementation plan (NOT implemented in v4.1.2)

When v4.1.3 implements the audit extension, the work splits:

1. **`tools/audit-postflop-ps.ps1`** — extend the existing PowerShell auditor with M2.R01–M2.R30 hard rules and M2.S01–M2.S08 soft rules. Each new rule is keyed `M2.<code>` so output is unambiguous.
2. **`postflop/postflop_audit_rules.js`** — extend the in-browser auditor symmetrically. Same rule codes.
3. **`postflop/postflop_audit.html`** — add a Module-2 filter toggle that scopes the audit run to `module === 'pf_flop_cbet_ip'`.
4. **CI / pre-commit** — keep the existing 262/0/0 gate. Add a Module-2 gate (e.g., 24/0/0 once seeds are merged) that runs alongside.

---

## 7. Audit verification of v4.1.2 seed (manual run, this sprint, post-fix-pass)

The 24 v4.1.2 seed scenarios were manually verified against rules M2.R01–M2.R30 during seed authoring AND re-verified after the fix-pass that corrected mechanical errors in scenarios #11, #13, #21, #22, #24 (flush-vs-flush-draw mis-counts on monotone/two-tone boards) and applied labelling improvements in #2, #5, #6, #17, #18.

**Suit-count discipline added** to the schema-taxonomy doc (§ 4.1) as an explicit rule the audit must enforce: a hero with N cards of a suit on a monotone (3-of-suit) or two-tone (2-of-suit) board has the resulting flush/draw status mathematically determined. The audit must reject scenarios whose `handClass` / `drawCategory` contradicts the suit-count math.

Verification recap (post-fix-pass):

| Rule | Result |
|---|---|
| M2.R01 (card collision) | ✅ 0 collisions across 24 scenarios |
| M2.R02 (heroHand size) | ✅ all scenarios have exactly 2 hero cards |
| M2.R03 (card validity) | ✅ all cards parse as valid 2-char codes |
| M2.R04 (heroHand internal collision) | ✅ no scenario has duplicate hero cards |
| M2.R05 (choice-id integrity) | ✅ 0 unknown ids in answer tiers |
| M2.R06 (tier non-overlap) | ✅ 0 overlapping ids |
| M2.R07 (best non-empty) | ✅ all 24 have ≥ 1 best |
| M2.R08 (qtype validity) | ✅ 18 action_choice + 6 reason_choice |
| M2.R09 (action_choice set) | ✅ all action_choice scenarios use the exact 4-id set |
| M2.R10 (reason_choice set) | ✅ all reason_choice scenarios use enum-valid ids only |
| M2.R11 (recommendedAction validity) | ✅ all populated |
| M2.R12 (actionReason validity) | ✅ all populated |
| M2.R13 (recommendedAction ↔ best for action_choice) | ✅ 0 mismatches |
| M2.R14 (actionReason ↔ best for reason_choice) | ✅ 0 mismatches |
| M2.R15 (handClass vocabulary) | ✅ all values within (extended) vocabulary; new values `straight`, `flush`, `nut_flush` added in fix-pass |
| M2.R15-mech (suit-count discipline) | ✅ all 24 scenarios verified post-fix-pass; pre-fix #11, #13, #21, #22, #24 had errors that have been corrected |
| M2.R16 (heroHandRole vocabulary) | ✅ all values within vocabulary |
| M2.R17 (drawCategory vocabulary) | ✅ all values within vocabulary |
| M2.R18 (showdownValue vocabulary) | ✅ all values within vocabulary |
| M2.R19 (explanation.short non-empty) | ✅ all populated |
| M2.R20 (explanation.handLogic non-empty) | ✅ all populated |
| M2.R21 (explanation.takeaway non-empty) | ✅ all populated |
| M2.R22 (sizingLogic when betting) | ✅ all bet_small/bet_big scenarios populated |
| M2.R23 (commonMistake when critical) | ✅ all 16 critical-bearing scenarios populated |
| M2.R24 (concept tag validity) | ⚠️ 5 `[planned]` tags used: `value_betting`, `pot_control`, `blocker_pressure`, `range_advantage_stab`, `give_up_strategy`. Per § 2.24, these warn but don't fail. |
| M2.R25 (sourceConfidence honesty) | ✅ all 24 use `expert_judgment`; no `solver_verified` claims |
| M2.R26 (auditStatus discipline) | ✅ all 24 use `review_pending` |
| M2.R27 (family naming) | ✅ all use `bet_small`/`bet_big`, not size-specific |
| M2.R28 (id uniqueness) | ✅ 24 unique ids, no collision with existing 262 production scenarios |
| M2.R29 (id convention) | ✅ all match the v4.1.2 pattern |
| M2.R30 (single spot) | ✅ all 24 use BTN-vs-BB SRP 100BB IP flop |

| Soft rule | Result |
|---|---|
| M2.S01 (overpair on low connected bet) | ✅ no flags — KK on 8s7d5h is `check`, not bet |
| M2.S02 (air on dry check) | ✅ no flags |
| M2.S03 (top-pair-good-kicker bet big on dry) | ✅ no flags |
| M2.S04 (small underpair bet) | ✅ no flags |
| M2.S05 (air on monotone stab) | ✅ no flags |
| M2.S06 (no critical on leaky board) | ✅ critical answers present on all leaky-board scenarios |
| M2.S07 (concept-tag depth) | ✅ all 24 carry ≥ 3 concept tags |
| M2.S08 (explanation depth) | ✅ all 24 meet length thresholds |

| Coverage rule | Result |
|---|---|
| M2.C01 (board coverage) | ✅ all 6 buckets represented |
| M2.C02 (action coverage) | ✅ all 4 actions represented (post-fix: 11 bet_small / 9 check / 2 bet_big / 2 mixed) |
| M2.C03 (hand-role coverage) | ✅ 10 distinct heroHandRole values represented |
| M2.C04 (qtype coverage) | ✅ 6 of 24 are reason_choice (25%) |
| M2.C05 (critical-leak representation) | ✅ 14 of 24 carry critical answers (post-fix; 2 fewer than pre-fix because #13's bet_big was downgraded to "bad" — over-aggression but not a critical leak when the hand isn't actually a real NFD) |

---

## 8. Open audit questions for human review

1. **Mixed action ratio** — post-fix the seed has 2 of 24 scenarios with `recommendedAction === 'mixed'`. Still likely under-representing the GTO mix-heavy nature of postflop play. Recommendation: when expanding to ~150 scenarios, target ~15–20% mixed.
2. **bet_big low frequency** — post-fix 2 of 24 (8%). Even lower than pre-fix because #13's reclassification correctly downgraded a bet_big scenario. The two remaining bet_big scenarios (#9 critical-leak and #11 made-straight value) feel pedagogically necessary; expansion should add more genuine polar spots.
3. **Soft rule M2.S05 strictness** — naked air on monotone almost always checks, but the seed has 0 such examples. Should we add 1–2 explicit "you should check this air" scenarios on monotone to drill the rule?
4. **`reason_choice` enum depth** — current enum has 9 values; each scenario presents 3–4 of them. Is 9 the right count, or should we trim to 6 most-pedagogical reasons?
5. **`drawCategory` granularity** — should `nut_fd` and `fd` collapse into a single `flush_draw` value, with `nutBlocker: bool` as a separate field? Current design carries both nut and non-nut FD as distinct `drawCategory` values; recommend keeping current granularity.
6. **Suit-count discipline rule** — the fix-pass added a hard rule that `handClass` / `drawCategory` must be consistent with the actual suit count given the board's suitTexture. The future audit script must implement this check; until then it lives only as a doc note.

These ride into the GPT review package as discussion items.
