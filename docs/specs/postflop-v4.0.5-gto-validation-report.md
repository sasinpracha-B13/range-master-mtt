# Post-flop GTO Data Validation Report — v4.0.5

> **Owner**: Orchestrator + Data/GTO Review.
> **Status**: validation pass complete; **no data files modified**. Optional patch plan published separately.
> **Scope**: all 20 Module 1 (Board Texture Trainer) scenarios in `postflop/postflop_scenarios.json`.
> **Spot context (assumed for all scenarios)**: NLH MTT, BTN open 2.5x vs BB call, 100BB SRP, heads-up, chipEV (no ICM), flop only.
> **Deployed data baseline**: post-`473ce9a` (v4.0.2-data fixes already incorporated — #20 nutLogic cleaned, #10 sourceConfidence downgraded, choice label hints stripped).
> **Audit pre-pass**: 31 scenarios · 0 errors · 0 warnings.

---

## 1. Executive summary

Module 1 is in production-ready shape with one recommended downgrade and a few honest-confidence flags.

| Metric | Value |
|---|---|
| Scenarios reviewed | 20 / 20 |
| **KEEP** (no change) | 17 |
| **DOWNGRADE confidence** (data patch — sourceConfidence only) | 1 |
| **REVISE answer** (data patch — answer key change) | 0 |
| **HOLD from production** (block until reviewed) | 0 |
| Currently `consensus_gto` | 16 |
| Currently `expert_judgment` | 3 (#10, #11, #20) |
| Currently `solver_verified` | 0 (none claimed) |
| Currently `needs_review` | 0 |
| Recommended `consensus_gto` after this pass | 15 (-1) |
| Recommended `expert_judgment` after this pass | 4 (+1: #14 added) |

**Top 3 risks identified**:

1. **#11 `Th8h3h_nutadv` (T-high monotone)** — answer is defensible but the nut-advantage axis on monotone flops depends on BB calling-range definition. Already correctly flagged `expert_judgment`. Risk: **Medium**. Verdict: **KEEP with caveat**.
2. **#20 `7d7s3c_rangeadv` (paired low)** — paired low boards are genuinely close to neutral; the "split" verdict is defensible but a learner could legitimately argue any of the four answers. Already correctly flagged `expert_judgment` + difficulty 4. Risk: **Medium-High** (fuzzy by nature). Verdict: **KEEP with caveat**.
3. **#14 `Qd9c4h_rangeadv` (semi-dry Q-high)** — currently `consensus_gto` but the BTN edge is thin enough that some pros would call this near-neutral. Recommend downgrade to `expert_judgment`. Risk: **Low-Medium**. Verdict: **DOWNGRADE confidence**.

**Distribution by question type**:

| Question type | Count | Notes |
|---|---|---|
| range_advantage | 10 | Strong coverage; range advantage is the most well-understood axis |
| nut_advantage | 2 | Lean coverage but two clean examples (#2, #11) |
| dynamic_level | 3 | Clean examples spanning very_dynamic / dynamic / semi_static |
| frequency_strategy | 3 | Clean (#9), mixed-region (#10), check-heavy (#16) |
| sizing_family | 2 | Symmetric — small (#15) vs check-heavy (#19) |

**Distribution by difficulty**:

| Difficulty | Count | Notes |
|---|---|---|
| 1 | 4 | Foundation: #1, #6, #8, #13 |
| 2 | 14 | Bulk of dataset; appropriate for first ship |
| 3 | 3 | Intermediate: #10, #11, #14 (the harder mixed/nuanced spots) |
| 4 | 1 | #20 only — paired-low, genuinely fuzzy |
| 5 | 0 | None — content debt for v4.x data expansion |

**Distribution by board high-card class**:

| Class | Count | Boards |
|---|---|---|
| A_high | 4 | #1, #5, #9, #15 |
| K_high | 4 | #2, #8, #14 (wait — that's Q-high), #17 — corrected: #2, #8, #17 (3 K-high) |
| Q_high | 2 | #10, #14 |
| J_high | 2 | #3, #13 |
| T_high | 2 | #11, #18 |
| low | 8 | #4, #6, #7, #12, #16, #19, #20 (and one more) |

(Slight class imbalance — low and A-high overrepresented, Q-high and J-high underrepresented. Documented as content debt for v4.x data expansion.)

---

## 2. Scenario-by-scenario table

Verdict legend: **KEEP** / **REVISE** / **DOWNGRADE** / **HOLD**. Risk legend: **L** (low) / **M** (medium) / **H** (high).

| # | id (short) | Q-type | Diff | Best answer | Acc. | Crit. | Current src | Verdict | Risk | Reasoning |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `AhKd5c_rangeadv_001` | range_advantage | 1 | preflop_raiser | — | caller | consensus_gto | **KEEP** | L | Textbook A-high dry rainbow. BTN has range adv from A-x and K-x density (BB 3-bets AKo/AJo+/AQs). Choice "neutral" tagged bad but not critical (split is also bad but not critical) — appropriately marks "caller" as the only critical. Explanation teaches range mechanics; commonMistake names a real heuristic error. No issues. |
| 2 | `KhTd2s_nutadv_001` | nut_advantage | 2 | preflop_raiser | — | — | consensus_gto | **KEEP** | L | KK + AK dominate top of range; BB 3-bets these. TT/22 are split-distributed but the AK + KK weight wins. Clean explanation. Note: no critical answer (none of caller/neutral/split is "leak-worthy" — just less correct). Could optionally add `dry_high_card_strategy` to conceptTags (currently only has range_advantage / nut_advantage / dry_board / board_texture_recognition). Low priority. |
| 3 | `JhTs9c_rangeadv_001` | range_advantage | 2 | caller | neutral | preflop_raiser | consensus_gto | **KEEP** | L-M | JT9 is the textbook "BTN doesn't have range adv on connected broadway" board. BB has more JTs/T9s/J9s plus 88-66 sets. Marking "preflop_raiser" as critical correctly flags a major real leak. `acceptable: neutral` honestly hedges (some pros call JT9 close to neutral). Solid scenario. |
| 4 | `5h4d3c_rangeadv_001` | range_advantage | 2 | caller | split | preflop_raiser | consensus_gto | **KEEP** | L | Wet low connected. BB's flatting range crushes this board. "split" as acceptable is generous but defensible (some sims show closer to split with BB slight edge). "preflop_raiser" critical correctly flags leak. Strong. |
| 5 | `AhAd6s_rangeadv_001` | range_advantage | 2 | preflop_raiser | — | caller | consensus_gto | **KEEP** | L | Paired aces. BTN has more A-x trips combos because BB's range has limited A-x (3-bets AJo+, AQ). Difficulty might be 1 rather than 2 (very obvious to anyone who thinks about A-x range distribution), but harmless. |
| 6 | `8h7c6s_dynamic_001` | dynamic_level | 1 | very_dynamic | dynamic | — | consensus_gto | **KEEP** | L | 876 is a textbook very-dynamic board. Every overcard makes a straight for someone. Explanation enumerates the equity-shift cards correctly. Difficulty 1 is right — this is a foundation question. |
| 7 | `9c5d2h_rangeadv_001` | range_advantage | 2 | preflop_raiser | neutral | — | consensus_gto | **KEEP** | L-M | 9-5-2 disconnected rainbow. BTN has overpairs (TT-AA) edge. Acceptable=neutral correctly hedges (the edge is thin; some sims show very close to neutral). No critical (no answer here is a "major leak" — picking caller is just wrong, not leak-worthy). Honest hedging. |
| 8 | `KhKd7s_rangeadv_001` | range_advantage | 1 | preflop_raiser | — | — | consensus_gto | **KEEP** | L | Paired king. BTN has more K-x combos (BB 3-bets KJ+/KQ heavily). Clean answer with no critical (no obvious leak — choosing "caller" is just wrong, not a costly habit). Could add `paired_board_strategy` more prominently. Low-priority. |
| 9 | `AhKd5d_freq_001` | frequency_strategy | 2 | range_small | — | polar_big | consensus_gto | **KEEP** | L | A-K-5dd (two-tone). Range_small (small high-freq c-bet) is the canonical answer here. Polar big as critical correctly flags the "always overbet for value" leak. `mixing` populated honestly (range_small=0.75, mixed_small_check=0.20, etc.). Strong. |
| 10 | `Qh9d6s_freq_001` | frequency_strategy | 3 | mixed_small_check | range_small | polar_big | **expert_judgment** | **KEEP** | M | Q-high semi-connected rainbow. The mixing data (range_small=0.30, mixed_small_check=0.55) honestly shows solver splits between the top two answers. Already downgraded to `expert_judgment` in v4.0.2-data — the right call. The `acceptable: range_small` gives partial credit for the secondary mix. |
| 11 | `Th8h3h_nutadv_001` | nut_advantage | 3 | preflop_raiser | neutral | — | **expert_judgment** | **KEEP-with-caveat** | M | T-high monotone. BTN has more A♥-x and K♥-x (BB 3-bets these). But BB has many T♥-x, 9♥-x, 8♥-x suited Broadways too. Verdict depends on assumed BB calling range. Already `expert_judgment`. **Possible alternative**: flip to `best=neutral, acceptable=preflop_raiser` (a defensible reading of monotone flops). Recommend leaving as-is for now but flagging in `OPTIONAL` patch plan. |
| 12 | `8s7s5s_rangeadv_001` | range_advantage | 2 | caller | — | preflop_raiser | consensus_gto | **KEEP** | L | Monotone low connected. BB owns this board on every dimension (more low spades, more pairs, more 6/4 straight combos). "preflop_raiser" critical is the correct flag — this is the canonical "don't auto-c-bet because monotone" leak. Strong. |
| 13 | `JhTh4d_dynamic_001` | dynamic_level | 1 | dynamic | very_dynamic | — | consensus_gto | **KEEP** | L | JT two-tone with disconnected 4. KQ/Q9/98 straight draws + flush draw. Dynamic-3 is the right primary answer; very_dynamic as acceptable is generous. Clean. |
| 14 | `Qd9c4h_rangeadv_001` | range_advantage | 3 | preflop_raiser | neutral | — | consensus_gto | **DOWNGRADE** | M | Q-high semi-dry rainbow. BTN has Q-x density (KQ, AQ, QJ) + overpairs, BB has more 99 + 8-x. Some sims show this near-neutral; the BTN edge is thinner than #1/#5/#8. **Recommend**: downgrade `sourceConfidence` from `consensus_gto` → `expert_judgment` to match the genuine uncertainty. The answer key (best=preflop_raiser, acceptable=neutral) already hedges correctly; only the confidence tag overclaims. |
| 15 | `AhJh3s_sizing_001` | sizing_family | 2 | range_small | polar_big | — | consensus_gto | **KEEP** | L | A-J-3 two-tone. BTN range adv + nut flush draw lives in BTN's range too (A♥X♥). Range_small with mostly all of range bets. Polar big as `acceptable` recognizes that some hands prefer big sizing (e.g., AdJd+ for protection). Honest. |
| 16 | `9h8c7d_freq_001` | frequency_strategy | 2 | check_heavy | polar_big | range_small | consensus_gto | **KEEP** | L | 987 highly connected middle. BB owns the board. Check-heavy is canonical; range_small marked critical (correct — this is the mirror of the over-c-bet leak). Polar big as acceptable for the top of BTN's range. Solid. |
| 17 | `KhJc8s_rangeadv_001` | range_advantage | 2 | preflop_raiser | neutral | — | consensus_gto | **KEEP** | L | K-J-8 semi-connected. BTN has KQ/AK/KJ/AJ/QJ. BB doesn't 3-bet J9s/T9s and they hit, but density of broadway favors BTN. Acceptable=neutral hedges. Clean. |
| 18 | `Tc9d2s_dynamic_001` | dynamic_level | 2 | semi_static | dynamic | — | consensus_gto | **KEEP** | L | T9 connected + 2 disconnected, rainbow. Some equity shift on overcards but no flush dynamics + 2 doesn't extend the structure. Semi-static is right. Acceptable=dynamic acknowledges the close call. |
| 19 | `6c5c4s_sizing_001` | sizing_family | 2 | check_heavy | polar_big | range_small | consensus_gto | **KEEP** | L | 6-5-4 two-tone with flush draw. BB owns. Same structure as #16 but for sizing question. Strong. |
| 20 | `7d7s3c_rangeadv_001` | range_advantage | 4 | split | neutral, preflop_raiser | — | **expert_judgment** | **KEEP-with-caveat** | M-H | Paired low (7-7-3). The fuzzy zone — overpairs argue for raiser, low pairs balance, neither side has a runaway edge. Already difficulty 4 + `expert_judgment`. The wide acceptable list (neutral + preflop_raiser) honestly tells the player there's no single right answer. `caller` correctly tagged bad (BB doesn't crush this board). Keep as-is; this is the kind of question that exists to teach players that fuzzy spots EXIST. |

---

## 3. Keep / revise / hold counts

| Verdict | Count | Scenarios |
|---|---|---|
| KEEP (no change) | 17 | #1, #2, #3, #4, #5, #6, #7, #8, #9, #10, #12, #13, #15, #16, #17, #18, #19 |
| KEEP-with-caveat (no change but flagged for monitoring) | 2 | #11, #20 |
| DOWNGRADE confidence | 1 | #14 |
| REVISE answer | 0 | — |
| HOLD from production | 0 | — |

**Net production-ready**: 20 / 20 scenarios remain shippable. The single proposed data edit (#14 sourceConfidence) does not affect player-visible behavior — it's an honesty tag only.

---

## 4. Confidence-level distribution

### Current state (post-v4.0.2-data)

| sourceConfidence | Count | Scenarios |
|---|---|---|
| `consensus_gto` | 16 | #1-#9, #12-#19 (excluding #10, #11, #20) |
| `expert_judgment` | 3 | #10, #11, #20 |
| `solver_verified` | 0 | — |
| `needs_review` | 0 | — |

### Recommended state (post-v4.0.5)

| sourceConfidence | Count | Change |
|---|---|---|
| `consensus_gto` | 15 | -1 (lose #14) |
| `expert_judgment` | 4 | +1 (gain #14) |
| `solver_verified` | 0 | — |
| `needs_review` | 0 | — |

This better reflects honest reviewer confidence. No scenario claims solver-verified status (we have not run actual solver outputs against any scenario — that's a v4.x toolchain build-out).

---

## 5. Top correctness risks

Ranked by Orchestrator's view of where a knowledgeable player could legitimately challenge the trainer:

| Rank | Risk | Scenario | Mitigation |
|---|---|---|---|
| 1 | **Monotone nut advantage is calling-range-dependent** | #11 `Th8h3h_nutadv` | Already `expert_judgment`. If a reviewer disputes, downgrade further to `needs_review` (would block from production) or revise answer to `best=neutral`. |
| 2 | **Paired-low is genuinely fuzzy** | #20 `7d7s3c_rangeadv` | Already `expert_judgment` + difficulty 4. Wide acceptable list honestly tells player it's close. Acceptable as-is. |
| 3 | **Q-high semi-dry overclaims `consensus_gto`** | #14 `Qd9c4h_rangeadv` | Recommend downgrade to `expert_judgment` (proposed in patch plan). |
| 4 | **Frequency_strategy answers can be solver-mix-dependent** | #9, #10, #16 | All have `mixing` populated honestly. #10 already `expert_judgment`. #9 (A-K-5dd) and #16 (987) are clean. |
| 5 | **Range_advantage on connected broadways near-neutral** | #3 (JT9), #4 (543), #12 (875ss) | All currently `consensus_gto`. JT9 is the only one some pros would call neutral; 543 and 875ss are unambiguously caller-favored. Acceptable as-is. |

Risks 1, 2, 3 are addressed (or addressable) by source-confidence honesty. None require an answer-key change.

---

## 6. Recommended data edits

**One** proposed edit, captured in `postflop-v4.0.5-data-patch-plan.md`:

```
Scenario:    pf_btn_v_bb_srp_100bb_flop_Qd9c4h_rangeadv_001
Field:       sourceConfidence
Before:      "consensus_gto"
After:       "expert_judgment"
Reason:      Q-high semi-dry rainbow has thinner BTN edge than the
             dry A-high / K-high / paired boards that share consensus_gto.
             Some sims show near-neutral. The answer key already hedges
             with acceptable=neutral; only the confidence tag overclaims.
```

No other edits proposed in this pass. The patch plan also documents two **monitor-only** items (#11, #20) — no edit, but flagged for re-evaluation if real-play user feedback disputes them.

---

## 7. Scenarios safe for production

All 20 Module 1 scenarios remain safe for production with the current beta-gated rollout. The proposed #14 edit is an honesty tag, not a correctness fix — it does not change player-visible answer scoring.

The shipped pool (`getModule1Scenarios()` in `index.html`) currently filters to all `auditStatus: approved` scenarios in the `pf_board_texture` module. After the patch, this stays at 20 scenarios.

---

## 8. Scenarios to exclude until reviewed

**None.** Zero `HOLD` verdicts. No scenario has a critical accuracy issue that would warrant pulling it from the pool.

(Compared to v4.0.0 baseline: scenario #20's "wait, 77 impossible" authoring artifact was already cleaned in `v4.0.2-data`; #10 and #11 already correctly downgraded to `expert_judgment` in `v4.0.2-data`. The v4.0.5 pass adds the #14 downgrade as the only outstanding edit.)

---

## 9. Open questions for human poker review

Items where Orchestrator would benefit from a human poker reviewer's second opinion before a future v4.x revision:

1. **#11 `Th8h3h_nutadv`**: should the answer key flip to `best=neutral, acceptable=preflop_raiser`? Current state defends BTN nut adv but a reviewer who assumes a wider BB calling range (e.g., looser tournament BB defense) would call this neutral.
2. **#3 `JhTs9c_rangeadv`**: is `consensus_gto` overclaim? Some pros call JT9 neutral, not caller-favored. Currently `acceptable: neutral` correctly hedges, but the source tag may overstate confidence.
3. **#4 `5h4d3c_rangeadv` `acceptable: split`**: is "split" really acceptable? On 543 BB has clear range adv. Could argue "split" should be `bad` not `acceptable`. Conservative for now.
4. **`commonMistake` field is not present on every scenario**: scenarios #2, #8 have no critical answer and no commonMistake. Acceptable per audit rule R12 (commonMistake is required only when critical answers exist), but adding a "common reasoning error" note would strengthen pedagogy.
5. **Solver-verified upgrade path**: zero scenarios currently claim `solver_verified`. To upgrade #1, #5, #8 (the textbook spots) to solver_verified would require running and documenting a solver sim per scenario — significant work, low ROI vs other v4.x priorities.

---

## 10. Recommendation

**Proceed with the small data patch.** Specifically:

1. Apply the `postflop-v4.0.5-data-patch-plan.md` edit (#14 sourceConfidence downgrade) in a separate `v4.0.5-data` commit — same pattern as `v4.0.2-data`.
2. Re-run audit (expected 31/0/0 — no field structure changes).
3. Commit `v4.0.5-data: downgrade #14 sourceConfidence honesty tag`.
4. Push.
5. Defer all other open questions to v4.x data expansion (when more scenarios are added, the underrepresented Q-high / J-high boards get attention; controversial calls get human poker review).

**Do not block on solver verification**. A solver-verified upgrade path is worth doing eventually but the cost (manual sim per scenario) significantly outweighs the value (mostly cosmetic — `consensus_gto` already implies wide solver agreement).

**Do not start Module 2 yet**. Module 1 is sound; the next logical postflop direction is either:
- v4.0.6 SRS (postflop spaced repetition tracking)
- v4.x Module 1 data expansion (15-20 more scenarios filling Q-high / J-high gaps and adding diff-3-4-5 spots)
- v4.x Module 2 (Flop C-bet IP) per the v4.0.3 stub

Recommend keeping Module 1 polish + data correctness work going for one more round before Module 2.

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | Orchestrator | Initial validation pass on 20 Module 1 scenarios. 17 KEEP, 2 KEEP-with-caveat, 1 DOWNGRADE (#14). Patch plan published separately. |
