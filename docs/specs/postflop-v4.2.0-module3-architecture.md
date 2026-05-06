# Postflop v4.2.0 — Module 3 Architecture (BB Defense vs BTN C-bet OOP)

**Status:** Planning-only. No production data, no runtime wiring, no version bumps.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.1.2-module2-architecture.md`, `postflop-v4.1.7-module2-playable-beta.md`

---

## 1. Module purpose

Module 3 teaches the player **how to defend the Big Blind out-of-position when the preflop raiser c-bets the flop**.

Where Module 2 trained the IP c-bettor's choice ("should I bet, and how much?"), Module 3 trains the OOP caller's response ("should I fold, call, or check-raise — and why?").

This is the second half of the flop SRP cycle. Together with Module 2 it covers both seats of the most common postflop spot in MTT poker.

**Skill goals (8):**
1. Understand the BB OOP defense threshold vs a small c-bet (~25% equity, MDF ≈ 67%).
2. Distinguish hands that continue (call) from hands that should fold.
3. Choose between call and check-raise with mid-strength to strong made hands.
4. Understand which draws prefer call (most) vs check-raise (combo draws / blocker bluffs).
5. Understand blocker-driven bluffs (which removes hits villain's value range).
6. Avoid over-defending dominated hands (overcards on A/K-high, weak Ax on dry boards).
7. Avoid under-raising strong value/combo draws (sets, two-pair, big combo equity).
8. Understand board texture impact on BB's defense range (dry vs draw-heavy vs paired vs monotone).

---

## 2. Position in curriculum

| Module | Title | Reads | Acts as | Status |
|---|---|---|---|---|
| M1 | Board Texture Trainer | "Read the board" | observer | shipped (251 scenarios) |
| M2 | Flop C-bet IP | "Choose the action with a hand as IP c-bettor" | BTN preflop raiser, IP | shipped beta (49 scenarios) |
| **M3** | **Facing C-bet OOP** | **"Defend OOP vs villain's c-bet"** | **BB preflop caller, OOP** | **planning v4.2.0** |
| M4 | Turn IP c-bettor | "Continue or shut down on the turn IP" | preflop raiser, IP | future |
| M5 | River IP value/bluff | "Polarize OOP on the river" | preflop raiser, IP | future |
| M6 | Multi-way & ICM | "Adjust for stack pressure / extra players" | varies | future |

M3 is the natural bookend to M2: same spot (BTN-vs-BB SRP, 100BB, flop) viewed from the OOP defender's perspective. Players who have completed M2 will already know what the IP c-bettor's range and sizing look like — M3 leverages that knowledge to teach the response.

---

## 3. Spot assumptions

| Field | Value |
|---|---|
| Format | NLH MTT |
| ICM | none (chipEV) |
| Stack depth | 100 BB effective |
| Pot type | Single-raised pot (SRP) |
| Preflop action | BTN open 2.5×, BB call |
| Street | Flop |
| Hero seat | BB |
| Hero role | preflop_caller_oop |
| Villain seat | BTN |
| Villain role | preflop_raiser_ip |
| Villain action | cbet |
| Villain sizing (default for v4.2.0 seeds) | small (~33% pot) |
| Hero starts the street | checking (BB checks to BTN by convention) |
| Hero decision | fold / call / check_raise_small / check_raise_big / mixed |

**Deliberate scope limit:** v4.2.0 seeds assume villain c-bets `bet_small` (~33% pot). This is the most common c-bet size in M2, and defending vs ~33% is the foundational MDF/pot-odds skill. Defense vs `bet_big` (~75% pot) is a different equity threshold (~30% needed) and a different range structure — that expansion is left for v4.3.x or a v4.2.x polish sprint, not v4.2.0.

---

## 4. Player roles

**Villain (BTN, IP, preflop raiser):**
- Opens 2.5× from BTN with a wide MTT range (~45–55% of hands).
- C-bets the flop frequently with a small sizing on most boards (~50–80% c-bet frequency depending on texture).
- Range on the flop is **uncapped** (still has all overpairs, sets, two-pairs, top-pair-best-kicker, plus draws and air).

**Hero (BB, OOP, preflop caller):**
- Calls preflop with a wide capped range (no AA–QQ, no AK by convention; flat with broadways, suited connectors, suited Ax, pocket pairs, suited kings, suited gappers).
- Range is **capped** on most flops (no nut-range hands).
- On the flop, checks first by convention (donk-betting is excluded from M3 — it's a separate decision tree).
- After villain's c-bet, the decision tree is: fold, call, or check-raise.

This creates the classic OOP defender problem: capped range, position disadvantage, but preflop caller does have specific ranges that perform well on certain textures (e.g., low connected boards, paired low boards).

---

## 5. Decision set (5 actions)

| Action ID | Label | Sizing reference | Notes |
|---|---|---|---|
| `fold` | Fold | — | Give up the hand. Most common decision with weak/dominated holdings. |
| `call` | Call | match villain's bet | Continue with marginal made hands, draws, and bluff catchers. |
| `check_raise_small` | Check-raise small | ~3× villain's bet (~6 BB total in 100BB SRP) | Standard value-raise size; also used for some semi-bluffs. |
| `check_raise_big` | Check-raise big | ~4× villain's bet (~8 BB total) | Polar sizing for strong value or extreme bluffs (rare). |
| `mixed` | Mixed (frequency dependent) | — | When multiple actions are roughly equal-EV. |

**Excluded:** `donk_bet` is intentionally **not** in M3's decision set. Module 3 begins after the BB checks and the BTN c-bets — the donk-bet decision happens before that fork and is conceptually separate (BB-leads-into-PFR is a Module 4+ topic if it's covered at all).

---

## 6. Reason set

Reason values used in v4.2.0/v4.2.2 seeds — **trimmed from the 11 candidates** in the brief to the **9 that are actually used by the 24 seeds** (after v4.2.2 re-introduced `slowplay_call`):

| Reason ID | Used by | Meaning |
|---|---|---|
| `value_raise` | sets, top-set, nut flush | Raise to extract value from worse made hands. |
| `protection_raise` | bottom set on wet board | Raise to charge draws / deny equity to two overcards. |
| `semi_bluff_raise` | OE+overcard combos, FD+gutshot combos | Raise as a bluff with backed-up equity. |
| `blocker_raise` | A-blocker / K-blocker on dry boards (acceptable answer only) | Raise as a polar bluff using blockers to villain's value. |
| `bluff_catch` | pair-of-7s on KK7, underpair on paired | Call to capture villain's bluffs without raising. |
| `equity_realization_call` | mid pair + draw, gutshot + 2 overcards, weak pair with redraw | Call to realize equity cheaply OOP. |
| `slowplay_call` | trip K + nut kicker on paired-K (re-introduced in v4.2.2) | Call to disguise a nutted hand and keep villain's bluffs in. |
| `range_disadvantage_fold` | overcards no draw, weak no-pair air | Fold because hero's capped range is dominated by villain's c-bet range. |
| `domination_fold` | AQ on K-high (vs AK-AT range) | Fold because hero's hand is specifically dominated. |

**Pruned (not used by the 24 seeds; reserved for future expansion):**
- `pot_odds_call` — collapsed into `equity_realization_call` to avoid taxonomy bloat (the two are >90% overlapping).
- `reverse_implied_odds_fold` — reserved for monotone / paired turn / river spots; v4.2.2 reviewed and confirmed not needed at flop scope (65o on monotone is range_disadvantage, not RIO).

This pruning is explicitly reversible: if real-data testing later shows the player needs `pot_odds_call` distinct from `equity_realization_call`, we add it back. v4.2.0 started narrow; v4.2.2 added `slowplay_call` because F6.2 (trip K + nut kicker on paired-K) genuinely warranted it.

---

## 7. Relationship to Module 1 and Module 2

**M1 dependency (loose):** Module 3 assumes the player can read the flop's texture (dry/wet/paired/monotone) — that's M1's territory. M3 doesn't re-teach board reading; it uses M1 vocabulary (`textureTags`, `boardKind`).

**M2 dependency (tight):** Module 3 inverts Module 2. The same boards that M2 used to teach IP c-bet decisions can be reused (with a different hero hand) to teach BB defense. **Three M2 boards are deliberately reused as M3 seed boards** for learning continuity:
- `Kh 9c 4s` (M2: K-9-4 dry K-high → M3 family 2)
- `Qh Jh 6c` (M2 used `Qh Jh 8c` and `KsQc8d` similar two-tone broadway; M3 uses `Qh Jh 6c` for variety → not strictly reuse)
- `Kc Kd 7s` (paired K board — close cousin of M2's `KcKd4c`)

(Exact board list is in §10 below.) The intent is for the player to recognize "this is the same board I trained as IP c-bettor — now I'm on the other seat."

**Concept-tag overlap:** Several M2 concept tags transfer (`pot_control`, `range_advantage_stab` is inverted — BB has range *disadvantage* on most boards, so a new tag `range_disadvantage` may be useful in v4.2.x). Module-specific concepts are listed in §11 of the schema/taxonomy doc.

**Mastery / Concept Library wiring (deferred):** v4.2.0 plans M3 concepts in docs only; the runtime Concept Library (`_PF_CONCEPT_LIBRARY`) and curriculum map (`_PF_CURRICULUM`) remain unchanged until v4.2.4 (M3 playable beta).

---

## 8. Teaching layer requirements

Module 3 needs a richer feedback layer than Module 2 because the OOP decision involves both a **defense decision** (continue at all?) and a **continuation choice** (call vs raise). The teaching feedback for each scenario should answer:

1. **What's villain's range here?** (A one-line summary of BTN's c-bet range on this texture.)
2. **What's hero's relative equity?** (range advantage / disadvantage / neutral.)
3. **Why this action?** (the reason value, expanded.)
4. **Why not the other options?** (e.g., why call instead of raise; why fold instead of call.)
5. **Common mistake** (what less-skilled players do here).
6. **Takeaway** (one-line generalization).

This maps to the existing `explanation` block from M2 schema with one addition: `defenseLogic` (a new field) capturing point 1+2+4 above. The schema doc proposes this as an optional field.

---

## 9. Runtime implications for v4.2.4 (M3 playable beta)

When M3 is productionized in v4.2.4, the runtime will need:

1. **`getModule3Scenarios()`** helper (parallel to `getModule2Scenarios()`).
2. **`startPostflopDrill('pf_flop_cbet_oop_def', 12)`** routed pool.
3. **`renderPostflopQuestion`** hand-aware rendering for M3 (hero hand row + handClass chip + villain action chip "BTN bets small").
4. **`renderPostflopAnswer`** route to a new `_pfM3TeachingFeedbackBlocksHtml` (parallels `_pfM2TeachingFeedbackBlocksHtml`).
5. **`_pfChoiceGuide`** extension for M3 actions (`fold`/`call`/`check_raise_small`/`check_raise_big`/`mixed`) and reason vocabulary.
6. **`_PF_CURRICULUM`** m3 entry: scenarioCount → 24 (or however many production scenarios exist) + syllabus.
7. **`_PF_CONCEPT_LIBRARY`** extension with M3 concepts (preview-only initially, then drillable).
8. **Concept queue scoring** (`_pfBuildConceptQueue`) needs to handle M3 conceptTags.
9. **Module 3 mastery checklist** (parallel to M1/M2; 5 criteria evaluated against M3-only sessions).
10. **Module 3 session summary** (parallel to M2's `_pfM2RenderSessionAggregations`; aggregate by handClass + actionReason).

None of these are touched in v4.2.0. They are scoped for v4.2.4.

---

## 10. Known risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| 1 | Reason set under-specified — `bluff_catch` may need to split into `pot_control_bluff_catch` vs `floating_bluff_catch` | low | low | Tag reasons consistently in v4.2.0; revisit in v4.2.2 final review based on seed coverage. |
| 2 | M3 board overlap with M2 confuses players ("didn't I see this board already?") | medium | low | Use deliberate overlap as a teaching tool ("same board, opposite seat"); make this explicit in M3 question prompts. |
| 3 | Sizing assumption (`bet_small` only) restricts realism — vs `bet_big` defense is a real skill | medium | medium | Document the limit explicitly (§3); plan v4.3.x for `bet_big` defense expansion. |
| 4 | `mixed` action becomes a dumping ground for any close decision | high | medium | Limit `mixed` to scenarios where two actions are within ~3% EV of each other; flag every `mixed` answer in audit review. |
| 5 | OOP defense theory has more solver disagreement than IP c-bet theory — `sourceConfidence` honesty matters | high | low | Default all M3 seeds to `sourceConfidence: expert_judgment`; upgrade to `consensus_gto` only after explicit solver runs. |
| 6 | Concept tags inflate quickly (new module → new concepts) | medium | medium | Plan M3 concepts (§11 of schema doc) but defer adding to `postflop_concepts.json` until v4.2.4 productionization. |
| 7 | Confusion between M2's `range_advantage_stab` (IP has the advantage) and M3's "BB has range disadvantage" | medium | low | Introduce `range_disadvantage` as a planned-but-not-yet-shipped concept; use it in M3 explanations. |
| 8 | `check_raise_big` in seeds may be over-used (it's a polar action, not an everyday choice) | medium | low | Limit `check_raise_big` to exactly 1 seed in v4.2.0 (nut flush on monotone); flag if more appear. |

---

## 11. Open decisions (resolved + carried)

**Resolved in this doc:**
- ✅ Villain sizing for v4.2.0 = `bet_small` only.
- ✅ Reason set trimmed to 8 (from 11 candidates).
- ✅ `donk_bet` excluded from decision set.
- ✅ `mixed` capped via solver-disagreement criterion (~3% EV gap).
- ✅ Boards: 6 families × 4 hands = 24 seeds.
- ✅ Question type mix: 18 action_choice + 6 reason_choice.

**Carried to v4.2.x (later sprints):**
- ⏸️ Defense vs `bet_big` (different equity threshold, different range structure) — v4.3.x candidate.
- ⏸️ Adding `pot_odds_call` / `slowplay_call` / `reverse_implied_odds_fold` if v4.2.4 player data shows they are needed.
- ⏸️ Adding M3-specific concept `range_disadvantage` to `postflop_concepts.json` — scoped for v4.2.4.
- ⏸️ Multi-way SRP defense (3+ players) — out of v4.2.x scope; v5.x territory.
- ⏸️ ICM-aware OOP defense (final-table pressure) — out of v4.2.x scope.

---

## 12. Board family map for the 24 seeds

| Family | Board | Texture | Hero hand spread (4 hands) | Why this family teaches |
|---|---|---|---|---|
| 1 | `As 8d 3h` | dry, A-high | 1 call / 1 value-raise / 1 reason-call / 1 fold | BB defense threshold on the most range-disadvantaged texture |
| 2 | `Kh 9c 4s` | dry, K-high, rainbow | 1 call / 1 value-raise / 1 reason-call / 1 fold | K-high vs A-high comparison; AQ domination |
| 3 | `8s 7d 5h` | low connected, draw-heavy | 1 call / 1 value-raise / 1 reason-raise / 1 fold | BB has range advantage; semi-bluff raise teaching |
| 4 | `Qh Jh 6c` | two-tone broadway, draw-heavy | 1 call / 1 value-raise / 1 reason-raise / 1 fold | Combo-draw raises (FD+gutshot 12-out semi-bluff) |
| 5 | `Jh 8h 4h` | monotone | 1 call / 1 value-raise / 1 reason-call / 1 fold | Reverse implied odds; nut flush check-raise big |
| 6 | `Kc Kd 7s` | paired board | 1 call / 1 value-raise / 1 reason-call / 1 fold | Bluff-catch underpairs; trips value raise |

**Per family the structure is "1 call / 1 raise / 1 of-either-via-reason-choice / 1 fold"** — slightly looser than the brief's strict "1 call, 1 value-raise, 1 semi-bluff, 1 fold" because some families (dry A-high, paired) don't have a textbook semi-bluff candidate, and I'd rather honestly teach the discipline of OOP defense than force-fit a raise where call is correct.

The aggregate distribution (10 calls + 8 raises + 6 folds across 24 seeds) reflects realistic BB defense frequencies: most defended hands call, fewer raise, and folds happen on a meaningful minority of holdings.

---

## 13. Next-sprint pointer (v4.2.1)

After v4.2.0 ships (planning docs only), the next sprint **v4.2.1** will:
1. Extend the existing seed auditor (`tools/audit-postflop-module2-seed.ps1`) to handle `module === 'pf_flop_cbet_oop_def'` — likely a `-Module 3` switch rather than a new file.
2. Run the v4.2.0 seeds through the extended auditor; expect 0 hard errors with some warnings.
3. Run a full strategic GPT review on the 24 seeds (companion to `postflop-v4.1.7-final-gpt-review-of-seeds.md`).
4. Decide on PASS / WARN / FAIL per seed.

v4.2.0 must **not** start v4.2.1 work. Stop after planning docs are written, audited internally, and committed.
