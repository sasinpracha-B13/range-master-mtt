# Postflop v4.3.0 -- Module 4 (Turn Barrel OOP Defense) -- GPT Review Package

**Status:** planning_only
**Sprint:** v4.3.0
**Module:** `pf_turn_barrel_oop_def` -- "Facing Turn Barrel OOP" (BB defends turn vs BTN second barrel after flop check-call)
**Seeds:** 24 scenarios (6 turn categories x 4 each)
**Mechanical audit baseline:** PASS (24 / 0 hard / 0 warn) via `tools/audit-postflop-module4-seed.ps1`

This package supplies a **strategic poker review prompt** for an external reviewer (GPT-5 / human coach / strategic partner). The mechanical auditor cannot judge poker substance -- it only enforces shape, vocabulary, and structural completeness. The reviewer's job is to validate **strategic correctness** of each seed before it can be promoted to production in v4.3.0A.

---

## 1. Spot lock (constant across all 24 seeds)

| Field | Value |
|---|---|
| Game / Format | NLH MTT |
| Stack depth | 100 BB effective |
| Pot type | SRP |
| Preflop | BTN open 2.5x, BB call |
| Flop | BTN c-bet small (~33% pot), BB call |
| Turn | BTN barrels (size unspecified -- assume reasonable 50-75% pot) |
| Hero seat | BB (OOP) |
| Villain seat | BTN (IP) |
| Hero role | flop_check_caller_oop |
| Villain role | turn_barreler_ip |
| Hero decision street | turn (after villain's barrel) |

**Reviewer must reject** any seed that drifts off this lock (e.g., adds 3-bet, adds donk, changes stack depth).

---

## 2. Action menu (exact 5)

`fold` | `call` | `check_raise_small` | `check_raise_big` | `mixed`

No raise-small / raise-big / donk / bet variants. Mixed = "frequency-based, neither side is clearly best".

---

## 3. Six turn categories x 4 scenarios

| # | Category | Boards used in seeds |
|---|---|---|
| 1 | brick | As 8d 3h, 2c |
| 2 | overcard | 9d 8c 6h, Kc |
| 3 | flush_complete | Ks 8s 3d, 2s |
| 4 | straight_complete | Qs Ts 6d, Jc |
| 5 | board_pair | 8c 8d 3s, 3h |
| 6 | draw_intensifier | Ts 9s 5d, 6h |

Each category has 4 scenarios:
- 3 of qtype `action_choice`
- 1 of qtype `reason_choice`

Many scenarios have items in `bad` flagged as `critical` -- those are deliberate teaching spots for harmful mistakes.

---

## 4. Reviewer's per-scenario checklist

For **every one of the 24 seeds**, answer these questions in writing:

1. **Spot match.** Does the scenario sit cleanly inside the BB-vs-BTN turn-defense lock? (no 3-bet, no donk, no IP hero, no OOP villain, no multiway)
2. **Hero hand realism.** Is `heroHand` a reasonable continuance from BB's flop-call range on this flop? (e.g., would BB normally call flop with this hand? if not -- rejection)
3. **handClass + heroHandRole.** Do these accurately describe the hand's strategic role given the runout? Is `slowplay_trap` used only on appropriate textures (sets on dry brick, not top pair on wet board)?
4. **turnLogic substance.** Does the prose explicitly name the turn card and explain how ranges/equities shifted? Is the explanation correct for BB-vs-BTN dynamics?
5. **recommendedAction realism.** Is the answer.best action consistent with modern theory consensus for that texture + hand? Flag anything that contradicts published GTO solver outputs without justification.
6. **actionReason match.** Does the named `actionReason` actually match the recommendedAction? (e.g., a `fold` decision should not be paired with `bluff_catch_turn`.)
7. **Answer partition discipline.** Do `best`, `acceptable`, `bad` cover all 5 actions exactly once? Is `critical` a proper subset of `bad`? Are critical items ACTUALLY harmful (not just close)?
8. **Critical-mistake calibration.** When something is in `critical`, does the explanation clearly state why this is a strategically harmful error -- not merely a small EV leak?
9. **Mixed answer use.** Is `mixed` reserved for genuinely close strategic decisions (~ within +/- 1 BB EV)? Mixed should not be used as a hedge for ambiguous writing.
10. **conceptTags accuracy.** Do the 1-4 tags match the actual lessons of the scenario?
11. **uniquenessNote.** Does the scenario differ from its 3 category-mates in a meaningful way (different hand class, different draw, different blocker, different reason, etc.)? Not redundant.
12. **No solver overconfidence.** If the explanation says "the solver does X", the scenario must use `sourceConfidence: solver_aligned`. For `expert_judgment`, the prose must read as "modern theory consensus" / "common heuristic" / "MTT default" -- not "the solver".
13. **chipEV / NLH MTT discipline.** No ICM math, no bounty math, no live-cash leveling. If a scenario relies on payout structure, reject.
14. **No card collisions.** All 4 board cards + 2 hero cards must be distinct.

---

## 5. Strategic quality flags to watch

These are recurring failure modes the reviewer should screen for:

- **F1 -- Over-folding small-card pairs on brick turns.** Hero has 5-5 on As 8d 3h 2c -- some seeds may incorrectly recommend fold here.
- **F2 -- Over-calling top-pair on flush-complete turns without a flush blocker.** AsKd on Ks 8s 3d 2s with no spade -- this should usually fold to 75%+ barrels.
- **F3 -- Under-flagging the call vs straight-complete with no straight blocker.** Hero often has to fold middle-pair-no-redraw vs 70%+ barrels on QsTs6dJc.
- **F4 -- Treating set on board_pair as automatic call.** Sometimes set + board pair is even better as small check-raise for value.
- **F5 -- Confusing draw-intensifier with straight-complete.** Ts9s5d6h gives BB draws + open-enders, but 6h is NOT a straight-completing card by itself. Make sure `drawCompletion` reflects this.
- **F6 -- Over-bluffing as BB OOP via check-raise.** BB does check-raise turn at low frequency. Seeds proposing check-raise as best should cite either nutted hands, strong protection-value, or specific blockers.
- **F7 -- Pure 50/50 spots labeled as critical.** If hero is `mixed` between fold/call, neither should be `critical`.
- **F8 -- Slowplay-trap mislabeling.** Only use `slowplay_trap` for sets/2-pairs+ on textures where calling is genuinely better than raising (dry static brick boards). Top-pair-good-kicker on wet boards is NOT a slowplay trap.

---

## 6. Per-scenario review template

For each of the 24 seeds, the reviewer fills in:

```
Scenario id: <copy id>
Category: <brick | overcard | flush_complete | straight_complete | board_pair | draw_intensifier>
Hero hand: <copy>
Recommended action: <copy>

[1] Spot match:               PASS / FAIL  -- comment
[2] Hand realism:             PASS / FAIL  -- comment
[3] handClass + role:         PASS / FAIL  -- comment
[4] turnLogic substance:      PASS / FAIL  -- comment
[5] recommendedAction realism:PASS / FAIL  -- comment
[6] actionReason match:       PASS / FAIL  -- comment
[7] Answer partition:         PASS / FAIL  -- comment
[8] Critical calibration:     PASS / FAIL  -- comment
[9] Mixed use:                PASS / FAIL  -- comment
[10] conceptTags:             PASS / FAIL  -- comment
[11] uniquenessNote:          PASS / FAIL  -- comment
[12] No solver overconfidence:PASS / FAIL  -- comment
[13] chipEV discipline:       PASS / FAIL  -- comment
[14] No card collisions:      PASS / FAIL  -- comment

Overall verdict: PROMOTE / REVISE / REJECT
Specific edits needed: <bullet list>
```

---

## 7. Aggregate review questions

After all 24 individual reviews, the reviewer answers:

1. **Distribution sanity.** Are all 6 categories sufficiently distinct lessons, or do any feel redundant?
2. **Hero hand spread.** Across 24 seeds, is the heroHand pool diverse (mix of made hands, draws, bluff-catchers, air, slowplay traps)? Or does one role dominate unhelpfully?
3. **Critical-mistake density.** How many of the 24 seeds have at least one `critical` action? Is the count appropriate (target: 8-12 across 24)?
4. **Mixed vs decisive ratio.** How many seeds have `recommendedAction: mixed`? Is the ratio balanced (target: 2-5 of 24)?
5. **Promotion readiness.** Are these 24 seeds a viable training set, or do they need a v4.3.0A round of strategic edits before promotion?

---

## 8. Out-of-scope reminders for the reviewer

- The reviewer is **not** asked to validate solver-exact frequencies. Modern theory consensus is sufficient.
- The reviewer is **not** asked to add new fields, new vocab, or new categories -- those are schema-frozen for v4.3.0.
- The reviewer is **not** asked to copy-edit prose for style. The mechanical auditor enforces structural completeness; substance is the focus.
- The reviewer **must not** suggest expanding to BTN-IP-barrel scenarios, donk-bet scenarios, or other modules -- those are explicitly out-of-scope until later sprints.

---

## 9. Output format

The reviewer returns a single Markdown file with:
- A 1-paragraph executive summary
- 24 per-scenario review blocks (Section 6 template)
- Aggregate review answers (Section 7)
- A "promotion verdict" line: `PROMOTE-AS-IS` / `PROMOTE-WITH-EDITS` / `REVISE-MAJOR` / `REJECT`

If the verdict is `PROMOTE-WITH-EDITS`, the reviewer lists exact edits needed (which seed id, which field, old value -> new value).

---

## 10. Next sprint hand-off (v4.3.0A)

After the GPT review, the next sprint (v4.3.0A) will:
1. Apply edits to the seed JSON
2. Re-run the mechanical auditor (must remain PASS)
3. Promote the 24 seeds to a runtime-ready M4 scenario set
4. Wire BETA training mode `m4` (mirror of M3 BETA pattern)
5. Add `appVersion = 4.3.0A` and SW-cache bump
6. Add per-module `_pfBetaQAStatsForModule('m4')` smoke test

The current sprint (v4.3.0) ends at "seeds + auditor + planning docs committed". No production data is touched.
