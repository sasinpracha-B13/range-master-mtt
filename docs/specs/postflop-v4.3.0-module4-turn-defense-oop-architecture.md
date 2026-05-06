# Postflop v4.3.0 — Module 4: BB Turn Defense OOP — Architecture

**Status:** Planning-only. No production data. No runtime wiring. No version bump.
**Date:** 2026-05-06
**Builds on:** Module 3 (BB Defense vs Flop C-bet OOP, v4.2.3..v4.2.6)
**Companion docs:** `postflop-v4.3.0-module4-schema-taxonomy.md`, `postflop-v4.3.0-module4-seed-scenarios.json`, `postflop-v4.3.0-module4-audit-plan.md`, `postflop-v4.3.0-module4-gpt-review-package.md`

---

## 1. Module purpose

Module 4 teaches Big Blind defense **on the turn**, after BB has already check-called the flop, and now faces a second barrel from BTN. It is the first turn-street module in the Postflop Academy curriculum and the natural continuation of Module 3 (flop check-call decision).

Where Module 3 asks "should BB defend the flop c-bet?", Module 4 asks "now that BB called the flop, what does the turn card change about the right action?"

The single most important lesson Module 4 introduces is **equity shift on the turn** — recognizing how a turn card moves range advantage, completes draws, brings overcards, pairs the board, or blanks out. Most learner leaks on the turn come from failing to update assessments after a card changes the relative strength of both ranges.

---

## 2. Why Module 4 follows Module 3

Module 3 is BB's flop decision (defend a small c-bet OOP). Once a learner can defend the flop competently, the next decision in the same hand tree is: **continue defending on the turn?**

Module 4 inherits the BTN-vs-BB SRP 100BB framing from Module 3 but extends one street. The flop action is now fixed (BB called BTN's small c-bet), the turn card is the new variable, and the question is what BB does facing BTN's barrel.

This narrows the spot to a coherent first turn module:
- Same range assumptions as Module 3 (just one street later)
- Same BB-OOP perspective (consistent learner mental model)
- Same actionReason vocabulary structure (extends, not replaces)
- Different equity dynamics (the new lesson)

Module 4 is **NOT** "BTN turn c-betting IP" or "donk-leading the turn." Both are valuable but reserved for later modules to keep this module bounded.

---

## 3. Exact spot assumption

| Field | Value |
|---|---|
| Game | NLH MTT, chipEV (no ICM) |
| Effective stacks | 100BB |
| Format | NLH_MTT |
| Pot type | SRP |
| Preflop action | BTN open 2.5x, BB call |
| Flop action | BTN c-bets small (~33% pot), BB calls |
| Turn action | BTN barrels (sizing varies by board class — small or medium; brick turns favor smaller, dynamic turns favor larger) |
| Hero | BB (out of position) |
| Hero role | flop_check_caller_oop |
| Villain | BTN (in position) |
| Villain role | turn_barreler_ip |
| Hero turn decision | fold / call / check_raise_small / check_raise_big / mixed |

Pot odds note: vs a small turn barrel (~50% pot), BB needs ~25% raw equity to call profitably; OOP equity realization is imperfect, so the practical defense threshold is closer to 30-35% on most textures.

---

## 4. What learner should master

Module 4 trains these decisions:

1. **Continue with bluff-catchers when BTN's barrel range still contains air**
   — middle pair / weak top pair / overpair on board-paired turns / underpair on paired-low boards.
2. **Fold marginal hands when the turn card crushes BB's range**
   — overcard turns (K on T-9-6 flop) shift equity strongly toward BTN; mid-pair holdings often become folds.
3. **Recognize draw completions and respond accordingly**
   — flush-completing turns require either fold (no flush, no blocker) or call (with the blocker / with a made flush).
4. **Defend straights and made flushes for value or check-raise**
   — when BB's flop calling range completes a straight on the turn, the equity flip becomes a value-raise opportunity.
5. **Use blockers / removal to expand defense**
   — A-of-flush-suit blocker on flush-completing turns; nut-straight blocker on straight-completing turns.
6. **Avoid stationing dominated hands on bad turns**
   — middle pair on overcard turns where BTN's range now beats us heavily.
7. **Recognize counterfeit / re-pair turns**
   — pocket pair counterfeited by board-pairing turn; turn pair improves opponent's range.
8. **Identify check-raise turn opportunities**
   — strong made hands wanting to deny equity, combo draws with fold equity, or polar bluffs with key blockers.
9. **Know when slowplay-call beats raise on the turn**
   — paired or board-pairing turns where villain's range is bluff-heavy and a raise folds out the bluff bucket.
10. **Avoid overfolding strong bluff-catchers**
    — TPGK on dry flush-completing turns where the A-blocker still works; underpair on counterfeit-paired turns.

---

## 5. What is intentionally out of scope

Documented for clarity so future modules can fill these:

| Out of scope | Future module |
|---|---|
| Donk-leading the turn (BB betting first) | M4-extension or M5+ |
| BTN turn c-betting IP after BB check | Future "Turn IP barrel" module |
| Delayed c-bet (turn bet after flop check-back) | Future "Delayed C-bet" module |
| Probe turns (BB betting after flop check-check) | Future "Probe Turn" module |
| Multi-way turn play | Future advanced module |
| 3-bet pots | Future "3BP Postflop" module |
| Larger turn barrel sizings (overbet) | M4 v2 expansion |
| River decisions | Module 5 (River Defense OOP) |
| ICM-aware adjustments | Future tournament-specific module |

---

## 6. How M4 differs from M3

| Dimension | Module 3 (Flop Defense OOP) | Module 4 (Turn Defense OOP) |
|---|---|---|
| Street | flop | turn |
| Board cards | 3 | **4** |
| New strategic axis | BB's flop calling threshold + flop range vs BTN c-bet | **Equity shift from turn card** + BB's turn defense vs barrel |
| Action menu | fold / call / check_raise_small / check_raise_big / mixed | same |
| ActionReason vocabulary | 9 reasons | **12 reasons** (M3 reasons adapted to turn + 3 new turn-specific) |
| Hand category emphasis | bluff-catchers vs domination, flop range disadvantage | **turn category** matters most: brick / overcard / flush-complete / straight-complete / paired / draw-intensifier |
| Critical-mistake vocabulary | check_raise_big over-bloating; folding strong value | calling no-equity floats on bad turns; folding mandatory bluff-catchers on brick turns; check-raising with no equity/blockers |
| Schema additions | none vs M2 (BB-OOP framing) | **flopCards + turnCard fields, turnCategory, equityShift, drawCompletion, boardChange, suitTextureTurn, pairStatusChange** |

---

## 7. Core strategic concepts

### 7.1 Turn equity shift (the central concept)

A turn card can:
- **Favor BB** — completes BB's straight draw range; pairs BB's middle-card holdings; brings the third card of a board where BB is range-advantaged.
- **Favor BTN** — overcard to the flop's high card; brings a card BTN's preflop range hits hard (Ax/Kx); pairs BTN's overpairs into top set rarely but gives BTN's overpair range better equity vs draws.
- **Polarize** — completes one player's draws while leaving the rest of both ranges unchanged (e.g., flush-completing turn).
- **Reduce BB realization** — overcards make BB's medium pairs worse; cards that bring big draws on a board where BB only has weak draws.

### 7.2 Second-barrel defense

BTN's range narrows on the turn vs flop:
- Pure air folds the flop most of the time, so the air remaining for the turn barrel is weighted toward fold-equity-driven bluffs (with backdoors that picked up).
- BTN's value range concentrates: top pair good kicker / overpairs / sets / two-pair.
- BB's flop call range filtered weak hands; what remains tends to have showdown value or a draw.

The turn defense threshold therefore rises in absolute equity (more BB folding) but drops in relative-to-villain-range terms (BB needs less equity to defend because BTN's range is more value-skewed).

### 7.3 Turn pot odds

Standard math: facing X% pot bet, hero needs X/(2X+1) raw equity. Vs a 50% pot barrel, hero needs ~25%. Vs a 75% barrel, ~30%. Vs an overbet (1.5x pot), ~37.5%.

OOP, this raw threshold isn't enough — equity realization is worse OOP, so practical defense requires 5-10% above the raw threshold for marginal hands without strong blockers.

### 7.4 Bluff-catchers on the turn

A bluff-catcher on the turn is a hand that:
- Beats most of BTN's continuing air range
- Loses to most of BTN's value range
- Cannot raise profitably (raise folds the bluffs and isolates the value)
- Has enough showdown equity at river to reach showdown reasonably often

Examples: middle pair on dry brick turns, top pair weak kicker on flush-completing turns where hero has the A-blocker, underpair on counterfeit-paired turns.

### 7.5 Domination folds on the turn

When the turn card crushes hero's marginal hand class:
- Mid pair on K-overcard turn (now dominated by Kx + still loses to overpairs)
- TPWK on flush-complete turn without blocker (dominated by flushes, dominated by TPGK)
- Underpair on overcard turn (now well below villain's value bucket)

### 7.6 Range disadvantage turn folds

Some hands enter the flop "barely defending" and the turn card amplifies the range disadvantage:
- Overcards no draw on overcard turn that hit BTN
- Backdoor-only floats on bricked turns
- Naked Ace-high on flush-completing monotone-ish turns (without the Ace of suit)

### 7.7 Value check-raise turn

When BB has top set or a strong draw + nut blocker on a dynamic turn, the check-raise becomes valuable:
- Builds the pot when value is huge
- Denies equity to villain's draws when board is dynamic
- Makes solver mix between call (for slowplay) and check-raise (for value+protection)

### 7.8 Semi-bluff check-raise turn

Strong combo draws (15+ outs counting outs to better) become semi-bluff candidates on dynamic turns:
- Combo draw + overcard
- OESD + flush draw (if a card adds new draws)
- Already-strong draw + improved equity from turn

The trade-off: turn check-raise commits more chips than flop check-raise (deeper pot), so the semi-bluff threshold is higher than M3's flop semi-bluff.

### 7.9 Blocker check-raise turn

Pure bluff-raises on the turn require strong blockers:
- A-of-flush-suit on flush-completing turns
- Nut straight blocker on straight-completing turns

These are advanced, low-frequency lines — solver mixes 5-15% on the right boards. Module 4 should expose 1-2 examples with honest "(advanced; solver mixes)" copy.

### 7.10 Slowplay turn call

When BB has a monster (straight, set, two pair on dry) on a board where BTN's barrel range is bluff-heavy, call > raise:
- Raise folds the bluffs
- Call keeps the bluff bucket alive for river barrel

Different from "bluff-catch": slowplay-call is hero is FAR ahead, not just ahead-of-air.

### 7.11 Mixed indifference turn

Some turn spots are genuinely close — solver mixes call/raise or call/fold meaningfully. Module 4 should label these honestly as "mixed" and not over-confidently classify one as critical.

### 7.12 Turn board change recognition

Recognize flag dimensions:
- **drawCompletion**: did a flush draw or straight draw complete?
- **boardChange**: brick / overcard / paired / scare / dynamic
- **suitTextureTurn**: rainbow / two_tone / monotone (after turn card)
- **pairStatusChange**: did the board pair this turn? trips? quads possible?

These tags drive the strategic conclusions about who hit the turn harder.

---

## 8. Turn-card categories (6 used in seeds)

| Category | Definition | Strategic effect |
|---|---|---|
| **brick** | Card that doesn't complete draws, doesn't bring overcard, doesn't pair the board | Range stays static; bluff-catch threshold close to flop level; weak floats give up |
| **overcard** | Card that brings a higher card than the flop's high card (especially K, A on lower flops) | Range shifts toward BTN; many BB mid-pairs become folds |
| **broadway_overcard** | A specific overcard subtype where the new card is broadway and hits BTN's preflop range hard | Same as overcard but more pronounced |
| **flush_complete** | Third card of a suit on a 2-flush-suited flop | Polarizes ranges; A-of-suit blocker becomes critical |
| **straight_complete** | Card that fills a straight available to either player's range | Polarizes; check-raise value spots emerge |
| **board_pair** | Card that pairs one of the flop ranks (or already-paired flop pairs again) | Counterfeits some pocket pairs; opens slowplay opportunities |
| **draw_intensifier** | Card that adds a new draw to existing structure (turn 6 on T-9-5 makes 5-6-7-8-9 + 6-7-8-9-T draws live) | More semi-bluff candidates; protection raise becomes important |
| **scare_card** | A card that visibly threatens both players (J on KQ board, etc.) | Forces decisions on top pair; tests TPGK calls |
| **range_shift_card** | Generic catch-all for cards that meaningfully reshape ranges | Used when more specific category doesn't fit |
| **second_card_pair** / **top_card_pair** / **low_blank** | Sub-types of board_pair / brick | Optional refinement |

The seed scenarios use **6 of these categories** (brick, overcard, flush_complete, straight_complete, board_pair, draw_intensifier) for v4.3.0 to keep scope bounded.

---

## 9. Action menu

Same as Module 3 (5 actions, intentional consistency for cross-module learning):

| Action ID | Display label |
|---|---|
| `fold` | Fold |
| `call` | Call |
| `check_raise_small` | Check-raise small |
| `check_raise_big` | Check-raise big |
| `mixed` | Mixed / close |

**Donk-leading is NOT in the v4.3.0 action menu.** Donk-leading the turn (BB betting before BTN acts) is a real strategic option in some spots, but it adds an extra strategic axis (BB can lead OR check-call OR check-raise) that bloats the decision tree. v4.3.0 keeps the menu identical to M3 to leverage learner familiarity. A future v4.3.x extension can add `donk_small` / `donk_big` once base content is stable.

---

## 10. Answer partition philosophy

Same partition discipline as Module 3 (locked in v4.2.5):

- **best**: one action representing the highest-EV solver choice (or the dominant choice on close-to-pure spots).
- **acceptable**: actions that are within ~5% EV of best, OR that solver mixes meaningfully (15%+ of the time).
- **bad**: actions that are clearly losing EV but not severe punts.
- **critical**: actions that are uniquely worst-bad in this spot — folding strong value, bloating no-equity hands, raising trash with no fold equity, calling dominated hands with no equity.

**Critical-flag discipline** (carried from v4.2.5):
- Do NOT mark close mixed alternatives as critical.
- Do NOT mark sizing errors as critical (an oversized raise is usually bad, not severe punt).
- DO mark concept punts as critical (folding a flopped set on the turn, calling air on overcard turn).

---

## 11. Critical mistake philosophy

Module 4 critical mistakes should be a small subset of the overall scenarios — ideally 25-35% of the 24 seeds, mirroring M3's 30.6% post-v4.2.5 rate. Examples of justified critical flags on the turn:

| Mistake type | Example | Why critical |
|---|---|---|
| Fold strong value on good price | Fold top set on dry brick turn | Severe punt; hero is far ahead |
| Call dominated trash on bad turn | Call mid-pair on K-overcard turn against barrel | Bleeds chips into dominating range |
| Raise no-equity bluff | Raise turn with no draw + no blocker on flush-completing turn | Pure spew; no fold equity vs polarized barrel |
| Overplay marginal made hand | Raise mid-pair on dynamic turn into BTN's range adv | Folds out air, gets called by better |
| Fold mandatory bluff-catcher | Fold TPGK + nut FD blocker on flush-complete turn | Over-folds vs villain's air-heavy barrel |

---

## 12. Future migration path (v4.3.x)

Module 4 in v4.3.0 is **planning-only**. The migration path mirrors v4.2.0 → v4.2.6:

| Future sprint | What it does |
|---|---|
| **v4.3.0** (this sprint) | 5 planning docs + 24 seed scenarios + seed audit script. No production data. No runtime. |
| **v4.3.0A** (suggested next) | Strategic seed review (24 scenarios reviewed by GPT/poker reviewer); fix any flagged seeds. |
| **v4.3.1** (production migration) | Migrate 24 seeds to `postflop/postflop_scenarios.json`. Production audit raises 385/0/0 → 409/0/0. Add R30+ M4-specific rules to `tools/audit-postflop-ps.ps1`. |
| **v4.3.1A** (data expansion) | Expand from 24 to ~50-60 M4 scenarios (mirroring v4.2.3A pattern). |
| **v4.3.1B** (data polish) | Fill thin-bucket reasons / add nut-flush-draw scenarios / promote textbook scenarios to consensus_gto. |
| **v4.3.2** (runtime wire) | TRAINING_MODES.m4 from preview → secondary; postflop:m4 route; M4 question/answer rendering using the same string-form schema as M3 (zero new normalizers needed). |
| **v4.3.2A** (UX polish + critical-flag review) | Mirror v4.2.5 polish round on M4. |
| **v4.3.3** (Beta QA dashboard) | Reuse `_pfBetaQAStatsForModule('pf_turn_barrel_oop_def')` from v4.2.6 — one-line wrapper enables full M4 dashboard. |

---

## 13. Future runtime path

When M4 ships its first runtime (planned v4.3.2), the wiring is significantly simpler than M3's was because:

1. **Schema normalization layer is reused** — `_pfNormalizePostflopChoices` + `_pfNormalizePostflopAnswer` already handle string-form choices and string-form best. M4 uses identical schema.
2. **Action labels are reused** — `_PF_M3_ACTION_LABELS` covers all 5 M4 actions. No new label map needed.
3. **Question prompt template is similar** — BB-defending framing extends from M3's flop framing to M4's turn framing with a small variant (mention turn card + turn barrel context).
4. **Teaching-block layout is reused** — `_pfM3TeachingFeedbackBlocksHtml` becomes `_pfM4TeachingFeedbackBlocksHtml` with `defenseLogic` → `turnLogic` field rename.
5. **Concept Library is extended** — add 12 M4 concept entries with `module: 'm4'`. Pattern-identical to M3's 10 entries.
6. **Mastery checklist is reused** — `_pfM4MasteryStats` is a thin wrapper over the M3 mastery pattern with the M4 module id.
7. **TCC tile flip is identical** — preview → secondary + BETA badge.

The reuse pattern means M4 runtime wire is approximately 200-300 lines of new code (vs M3's 800+) because all the architectural keystones already exist.

---

## 14. How v4.2.6 QA dashboard pattern supports M4 later

The v4.2.6 dashboard was designed module-agnostic specifically for this:

```js
// v4.2.6 helper (already exists):
_pfBetaQAStatsForModule(moduleId)  // accepts any postflop module id

// Future v4.3.3 wrappers (one-line each):
_pfM4BetaQAStats() {
  return _pfBetaQAStatsForModule('pf_turn_barrel_oop_def');
}

// _pfM4BetaQADashboardHtml() = _pfM3BetaQADashboardHtml() with M4 labels + 'turn' framing.
```

When M4 launches:
- `_pfBetaQAStatsForModule('pf_turn_barrel_oop_def')` immediately surfaces M4 sessions, accuracy by actionReason, weak-spot review effectiveness, critical-mistake monitor, etc.
- M4 dashboard mounts inside Postflop Academy alongside M3 dashboard.
- Cross-module comparisons become possible (e.g., "Is the learner's flop defense accuracy higher than turn defense?").
- Export snapshot format is portable across modules (`moduleId` field in JSON).

---

## 15. Risks + mitigations

| Risk | Mitigation |
|---|---|
| Turn schema is more complex than flop (4 cards, equity-shift annotation) | All new schema fields are optional with sensible defaults; auditor enforces presence; planning seeds populate all of them. |
| Solver-uncertain turn spots tempt overconfident `critical` flags | Critical-flag discipline (Section 11) limits criticals to genuine punts. v4.3.0A review pass will downgrade overconfident flags. |
| 24 seeds is thin for a turn module — turn play has more board states than flop | v4.3.0 = planning only. v4.3.1A expansion will grow to ~50-60 scenarios using the v4.2.3A pattern. |
| Donk-lead absence might be noticed by advanced players | Honest scope statement (Section 5) + future module promised. |
| Equity-shift assessments depend on solver assumptions | Explicit `equityShift` field in schema lets us calibrate per-scenario; reviewers can challenge specific claims. |
| Turn pot-odds threshold differs from flop | Documented per-category in Section 8 + per-scenario in seed `turnLogic` explanations. |
| Sample-size honesty needed once runtime ships | v4.2.6 QA dashboard already enforces "Early signal" warnings below 3 sessions / 30 answers; same threshold applies to M4. |

---

## 16. Sign-off checklist

- [x] Module purpose stated
- [x] Spot assumption locked
- [x] Scope intentionally narrow (BB Turn Defense OOP only; donk + IP-barrel out of scope)
- [x] Learning goals enumerated (10 items)
- [x] Out-of-scope items documented (8 items, each with future-module promise)
- [x] Action menu identical to M3 (intentional consistency)
- [x] Schema additions documented (companion schema-taxonomy doc)
- [x] Strategic concepts enumerated (12 concepts, mapped to actionReason vocabulary)
- [x] Future migration path documented (v4.3.0A → v4.3.3+)
- [x] Reuse-from-v4.2.x pattern documented (normalization, labels, dashboard, mastery, TCC)
- [x] Risks + mitigations documented
- [x] No production data touched
- [x] No runtime wiring touched
- [x] No version bump

**Status: PLANNING-ONLY · APPROVED FOR v4.3.0 PLANNING COMMIT.**
