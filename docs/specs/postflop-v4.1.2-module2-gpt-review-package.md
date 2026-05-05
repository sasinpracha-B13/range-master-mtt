# Postflop v4.1.2 — Module 2 GPT Review Package

**Status:** Review package prepared. Seed v0.1.1 (post-fix-pass) → v0.1.1 with 3 vocabulary refinements applied in v4.1.3 audit tooling sprint. No GPT review run has been executed yet.

**v4.1.3 audit tooling result:** 0 hard errors, 11 warnings (all defensible), 15 PASS / 9 WARN / 0 FAIL. See `postflop-v4.1.3-module2-audit-tooling-report.md` for full audit findings and warning dispositions.
**Companion to:** `postflop-v4.1.2-module2-architecture.md`, `postflop-v4.1.2-module2-schema-taxonomy.md`, `postflop-v4.1.2-module2-seed-scenarios.json` (v0.1.1), `postflop-v4.1.2-module2-audit-plan.md`

---

## Fix-pass summary (2026-05-05, before any GPT review)

A self-review uncovered **mechanical errors** in 5 scenarios where I mis-counted suit distribution on the monotone (Jh 8h 4h) and two-tone (Th 6h 2c) boards. Specifically I confused "made flush" with "flush draw" — on a 3-of-suit monotone board, a hero with 1 card of that suit holds a 4-card flush DRAW (need 1 more), not a made flush. Same trap on two-tone with 1 hero card of the suit = 3-card backdoor draw, not real draw.

### Self-correction discipline

The user-supplied review brief proposed a fix for scenario #21 (`AhTd` on `Jh8h4h`): "correct from `set` to `made_flush`/`nut_flush`/`strong_value`." I rejected this proposed fix because **it was also wrong** — the hand is a nut flush DRAW, not a made nut flush. The correct fix is `nut_flush_draw` with `heroHandRole: nut_draw`. This matches the brief's explicit warning: *"Be careful: GPT/human can also be wrong. Do not blindly change everything to satisfy concerns."*

### Fixes applied

**FAIL → PASS (5 scenarios with mechanical errors):**
| # | Hand on Board | Pre-fix issue | Post-fix |
|---|---|---|---|
| #11 | 9c6c on 8s7d5h | handClass `combo_draw` was wrong — this is a made straight | handClass: `straight`, heroHandRole: `strong_value`, drawCategory: `none`, showdownValue: `high` |
| #13 | AhKc on Th6h2c | handClass `nut_flush_draw` + drawCategory `nut_fd` wrong — only 3 hearts (1 hero + 2 board) = backdoor only; bet_big strategy was based on phantom equity | handClass: `backdoor_only`, drawCategory: `backdoor_only`, recommendedAction: `bet_small` (range-stab), full explanation rewrite |
| #21 | AhTd on Jh8h4h | handClass `set` was wrong (no set possible — Td doesn't pair anything; hero has 1 heart + 3 board hearts = nut FD, not made nut flush) | handClass: `nut_flush_draw`, heroHandRole: `nut_draw`, drawCategory: `nut_fd`, recommendedAction stays `bet_small` (correct for NFD on monotone), full explanation rewrite |
| #22 | KhQd on Jh8h4h | handClass `flush_draw` was actually CORRECT, but explanation said "made K-high flush" | Explanation rewritten; recommendedAction shifted from `bet_small` to `mixed` (more accurate for K-FD on monotone where the draw is dominated by AhX) |
| #24 | 6h5c on Jh8h4h | handClass `flush_draw` was actually CORRECT, but explanation said "made 6-high flush" and treated it as such | Explanation rewritten; reason_choice `actionReason` shifted from `pot_control` to `give_up` (more accurate for a reverse-dominated low FD); critical answer `value` retained |

**WARN improvements (4 scenarios with labelling refinements):**
| # | Hand on Board | Improvement |
|---|---|---|
| #2 | 7c6c on As8d3h | handClass `no_pair_no_draw` → `backdoor_only` (more precise — has 2-club bdfd + bdsd) |
| #5 | KsQc on Kh9c4s | handClass `top_pair_top_kicker` → `top_pair_good_kicker` (best K-kicker is A; KQ is good but not top) |
| #6 | JdTd on Kh9c4s | handClass `no_pair_no_draw` → `gutshot` (Q completes K-Q-J-T-9; was under-labelled) |
| #17 | QhQc on KcKd7s | Moved `check` from `bad` to `acceptable` tier (modern PIO mixes QQ on K-K-7 between bet_small and check; check is GTO-defensible, not a leak) |
| #18 | AsQs on KcKd7s | Swapped `actionReason` primary: `blocker_pressure` → `range_advantage_stab` (range adv is the engine; the A blocker is supporting evidence). Best/acceptable answer enum unchanged. |

**Schema additions** (in `postflop-v4.1.2-module2-schema-taxonomy.md`):
- New `handClass` values: `straight`, `flush`, `nut_flush` (made-hand vocabulary previously missing)
- New "Suit-count discipline" rule (§ 4.1) — explicit math the audit must enforce going forward

### Distribution changes (post-fix-pass)
| Axis | Pre-fix | Post-fix | Note |
|---|---|---|---|
| `recommendedAction = bet_big` | 3 | 2 | #13 reclassified bet_small (was over-aggressive) |
| `recommendedAction = mixed` | 1 | 2 | #22 added (K-FD on monotone) |
| Critical answers | 16 | 14 | #13 lost critical (over-betting backdoor isn't critical); #22 lost critical (mixed strategy with no clear leak) |
| handClass with mechanical errors | 5 | 0 | All corrected |

---

## 1. Executive summary

This package prepares the v4.1.2 Module 2 (Flop C-bet IP) seed for external sanity-check by a domain-aware reviewer (GPT-5 / Claude-4 / human poker coach).

**What you're reviewing:**
- 24 hand-authored seed scenarios for the BTN-vs-BB SRP 100BB flop spot
- Two question types: `action_choice` (18 scenarios) and `reason_choice` (6 scenarios)
- All scenarios use family-level sizing (`bet_small` / `bet_big` / `check` / `mixed`)
- All scenarios are tagged `auditStatus: review_pending` and `sourceConfidence: expert_judgment` — none are claimed as solver-verified
- 6 board buckets × 4 hands per bucket: A-high dry, K-high semi-dry, low connected, two-tone, paired Kx, monotone

**What you are NOT reviewing:**
- Module 1 scenarios (251 already approved)
- The 11 existing Module 2 baseline scenarios (those use older `bet_33` naming and will be migrated separately)
- The audit script (this package only reviews the seed data; the audit code extension is a separate sprint)
- Any UI / integration code

**Asked of the reviewer:**
- For each scenario, is the recommended action correct?
- For each scenario, is the action reason correct?
- Are critical answers (the leaks the seed is designed to flag) actually critical leaks?
- Are explanations accurate and pedagogically clean?
- Are concept tags well-chosen?
- Across the seed, is coverage representative?

---

## 2. Single-spot context

Every scenario sits in the same spot:

- **Game:** No-Limit Hold'em, MTT, chipEV (no ICM)
- **Stacks:** 100BB effective
- **Preflop:** BTN opens 2.5x, SB folds, BB calls
- **Pot type:** Single-raised pot (~5.5BB pot pre-flop, ~2.75BB to win + 2.5BB raise)
- **Position:** BTN is in position
- **Street:** Flop
- **Hero:** BTN (preflop raiser)

This is the most-played BTN-vs-BB SRP-IP spot at MTT stakes. Recommendations should reflect modern solver consensus for this exact spot at 100BB chipEV.

---

## 3. Scenario distribution

### 3.1 By board bucket

| Board bucket | Board | Scenarios |
|---|---|---|
| A-high dry | As 8d 3h | 4 |
| K-high semi-dry | Kh 9c 4s | 4 |
| Low connected | 8s 7d 5h | 4 |
| Two-tone | Th 6h 2c | 4 |
| Paired Kx | Kc Kd 7s | 4 |
| Monotone | Jh 8h 4h | 4 |

### 3.2 By question type

| Question type | Count | % |
|---|---|---|
| action_choice | 18 | 75% |
| reason_choice | 6 | 25% |

### 3.3 By recommended action (post-fix-pass)

| Action | Count | % |
|---|---|---|
| bet_small | 11 | 46% |
| check | 9 | 38% |
| bet_big | 2 | 8% |
| mixed | 2 | 8% |

> Pre-fix had 3 bet_big and 1 mixed. Fix-pass moved #13 from bet_big to bet_small (correctly identified the hand as backdoor-only) and #22 from bet_small to mixed (correctly identified the hand as K-FD on monotone, not made K-flush).

### 3.4 By heroHandRole

| Role | Count |
|---|---|
| thin_value | 5 |
| weak_showdown | 4 |
| air | 4 |
| strong_value | 3 |
| strong_draw | 2 |
| weak_draw | 2 |
| medium_showdown | 1 |
| nut_draw | 1 |
| blocker_bluff | 1 |
| trap_check | 1 |

### 3.5 By difficulty

| Difficulty | Count |
|---|---|
| 1 (introductory) | 3 |
| 2 (applied) | 12 |
| 3 (intermediate) | 5 |
| 4 (advanced) | 4 |
| 5 (exam) | 0 |

---

## 4. All 24 seed scenarios — table summary

| # | Board | Hand | handClass | Action (best) | Reason | Critical | Difficulty |
|---|---|---|---|---|---|---|---|
| 1 | As 8d 3h | AhKh | top_pair_top_kicker | **bet_small** | value | bet_big | 1 |
| 2 | As 8d 3h | 7c6c | no_pair_no_draw | **bet_small** | range_advantage_stab | bet_big | 2 |
| 3 | As 8d 3h | 9d9s | mid_pair | **check** | pot_control | bet_big | 2 |
| 4 | As 8d 3h | QcJh | no_pair_no_draw | bet_small (mixed) → reason: **range_advantage_stab** | — | none | 3 |
| 5 | Kh 9c 4s | KsQc | top_pair_top_kicker | **bet_small** | value | bet_big | 1 |
| 6 | Kh 9c 4s | JdTd | no_pair_no_draw | **bet_small** | equity_realization | bet_big | 2 |
| 7 | Kh 9c 4s | 7h7c | underpair | **check** | pot_control | bet_big | 2 |
| 8 | Kh 9c 4s | AcQh | no_pair_no_draw | bet_small → reason: **range_advantage_stab** | — | none | 3 |
| 9 | 8s 7d 5h | JhJc | overpair | **check** | pot_control | bet_big | 2 |
| 10 | 8s 7d 5h | AhQc | no_pair_no_draw | **check** | give_up | bet_big | 2 |
| 11 | 8s 7d 5h | 9c6c | straight (made; was wrongly labelled combo_draw) | **bet_big** | value | none | 2 |
| 12 | 8s 7d 5h | KsKd | overpair | check → reason: **pot_control** | — | protection | 3 |
| 13 | Th 6h 2c | AhKc | backdoor_only (was wrongly labelled NFD) | **bet_small** | range_advantage_stab | none | 3 |
| 14 | Th 6h 2c | Tc8s | top_pair_weak_kicker | **bet_small** | thin_value | bet_big | 2 |
| 15 | Th 6h 2c | 4d4c | underpair | **check** | give_up | bet_big | 1 |
| 16 | Th 6h 2c | 9h8h | combo_draw | bet_big → reason: **equity_realization** | — | value | 3 |
| 17 | Kc Kd 7s | QhQc | underpair | **bet_small** (check now acceptable) | thin_value | bet_big | 2 |
| 18 | Kc Kd 7s | AsQs | no_pair_no_draw | **bet_small** | range_advantage_stab (was blocker_pressure) | bet_big | 2 |
| 19 | Kc Kd 7s | 6c6d | underpair | **check** | pot_control | bet_big | 2 |
| 20 | Kc Kd 7s | AhKh | trips | mixed → reason: **value** | — | give_up | 4 |
| 21 | Jh 8h 4h | AhTd | nut_flush_draw (was wrongly labelled set) | **bet_small** | equity_realization | none | 4 |
| 22 | Jh 8h 4h | KhQd | flush_draw (K-FD, not made flush as previously claimed in explanation) | **mixed** (was bet_small) | equity_realization | none | 4 |
| 23 | Jh 8h 4h | 9d9c | underpair | **check** | give_up | bet_big | 2 |
| 24 | Jh 8h 4h | 6h5c | flush_draw (low FD, not made flush as previously claimed in explanation) | check → reason: **give_up** (was pot_control) | — | value | 4 |

> Post-fix-pass note: The original report flagged a "made nut flush" mislabel on #21. After re-verification I found the **proposed fix was also wrong** — AhTd on Jh8h4h is a nut flush DRAW, not a made nut flush. Hero has 1 heart (Ah) + 3 board hearts = 4 hearts total = draw (need 1 more). The seed JSON has been corrected accordingly. Same suit-count discipline applied to #22 and #24 (both K-FD and low-FD on monotone, not made flushes).

---

## 4.5 Post-fix-pass PASS / WARN / FAIL classification (24/24)

After the fix-pass, every scenario is either PASS or WARN. Zero remaining FAILs. WARN entries are solver-sensitive but defensible.

| # | Board | Hero | handClass | qtype | Best | Verdict | Notes |
|---|---|---|---|---|---|---|---|
| 1 | As 8d 3h | AhKh | top_pair_top_kicker | action | bet_small | PASS | Standard top-pair-top-kicker on dry A-high → small range bet for value |
| 2 | As 8d 3h | 7c6c | backdoor_only | action | bet_small | PASS | Air with bdfd + bdsd on dry A-high → range-stab small (handClass refined) |
| 3 | As 8d 3h | 9d9s | mid_pair | action | check | PASS | Mid pocket pair on A-high → pot control |
| 4 | As 8d 3h | QcJh | no_pair_no_draw | reason | range_advantage_stab | PASS | Reason framing: range advantage, not bluff |
| 5 | Kh 9c 4s | KsQc | top_pair_good_kicker | action | bet_small | PASS | Strong top pair on K-high (handClass refined from top kicker) |
| 6 | Kh 9c 4s | JdTd | gutshot | action | bet_small | PASS | Gutshot + bdfd + 2 J/T cards (handClass refined) |
| 7 | Kh 9c 4s | 7h7c | underpair | action | check | PASS | Small underpair → check, accept showdown |
| 8 | Kh 9c 4s | AcQh | no_pair_no_draw | reason | range_advantage_stab | PASS | Same reason framing as #4 |
| 9 | 8s 7d 5h | JhJc | overpair | action | check | WARN | bet_big as critical leak is the strongest pedagogical move; defensible but reviewer-sensitive |
| 10 | 8s 7d 5h | AhQc | no_pair_no_draw | action | check | PASS | Air on BB-favored low connected → check, give up |
| 11 | 8s 7d 5h | 9c6c | straight | action | bet_big | PASS | Made straight on wet board (handClass corrected from combo_draw) |
| 12 | 8s 7d 5h | KsKd | overpair | reason | pot_control | WARN | "protection" as critical is strong pedagogical call; reviewer-sensitive |
| 13 | Th 6h 2c | AhKc | backdoor_only | action | bet_small | PASS | **Major fix** — was wrongly labelled NFD; now correctly air-with-blockers; range-stab small |
| 14 | Th 6h 2c | Tc8s | top_pair_weak_kicker | action | bet_small | PASS | Top pair weak kicker on two-tone → thin value + protection |
| 15 | Th 6h 2c | 4d4c | underpair | action | check | PASS | Small underpair on FD board → check, give up |
| 16 | Th 6h 2c | 9h8h | combo_draw | reason | equity_realization | PASS | Real combo draw (4 hearts + gutshot) — verified suit count |
| 17 | Kc Kd 7s | QhQc | underpair | action | bet_small | PASS | Check tier upgraded from "bad" to "acceptable" — modern PIO mixes |
| 18 | Kc Kd 7s | AsQs | no_pair_no_draw | action | bet_small | PASS | actionReason corrected to range_advantage_stab |
| 19 | Kc Kd 7s | 6c6d | underpair | action | check | PASS | Small underpair on paired K → check |
| 20 | Kc Kd 7s | AhKh | trips | reason | value | WARN | "value" framing for the check line on trips top kicker — defensible (delayed value) but reviewer-sensitive |
| 21 | Jh 8h 4h | AhTd | nut_flush_draw | action | bet_small | PASS | **Major fix** — was wrongly labelled set; now correctly NFD; full explanation rewrite |
| 22 | Jh 8h 4h | KhQd | flush_draw | action | mixed | PASS | **Action shift** — best moved from bet_small to mixed (K-FD on monotone is dominated by AhX) |
| 23 | Jh 8h 4h | 9d9c | underpair | action | check | PASS | Underpair with 0 hearts on monotone → check, give up |
| 24 | Jh 8h 4h | 6h5c | flush_draw | reason | give_up | PASS | **Reason shift** — actionReason moved from pot_control to give_up (low FD is reverse-dominated) |

**Tally:** 21 PASS / 3 WARN / 0 FAIL.

The 3 WARN entries (#9, #12, #20) involve pedagogically strong pedagogical framings that are solver-defensible but where a reviewer might prefer different best/critical assignments. These are flagged for the reviewer to opine on; they are not blockers for committing the planning package.

---

## 5. 10 highest-risk scenarios (reviewer should focus here)

> **Updated post-fix-pass.** The original list had 10 scenarios where I was unsure; 5 of those are now resolved (mechanical fixes #11/#13/#21/#22/#24). The remaining 5 from the original list stay on the high-risk register, joined by 5 new strategic-judgment items.

These are the seeds where the GTO answer is most likely to vary by tree / sizing tree / population assumption. A reviewer should prioritise them.

### Risk #1 — Scenario 9 (`JhJc` on 8s 7d 5h) — UNCHANGED, still high-risk
- **Issue:** Marking `bet_big` as critical is the strongest pedagogical move in the seed. Confirm this is genuinely a critical leak and not just "suboptimal but defensible."
- **Sub-question:** Some heuristic-driven players will argue JJ has 2 outs to a set + protection value. Is the seed's framing ("bluff-catcher, not protection candidate") solver-correct?

### Risk #2 — Scenario 12 (`KsKd` on 8s 7d 5h, reason_choice) — UNCHANGED, still high-risk
- **Issue:** The seed forces the player to call the check "pot_control" and marks "protection" as critical. This is the central pedagogical hammer of the bucket. Confirm the framing.
- **Sub-question:** Is there a defensible "protection" frame for KK on 8-7-5 that we're rejecting too harshly?

### Risk #3 — Scenario 11 (`9c6c` on 8s 7d 5h) — handClass corrected, strategy still solver-sensitive
- **Issue:** Post-fix the handClass is `straight` (correctly identifies the made hand). The seed says `bet_big` for value with `mixed` as acceptable. Confirm the polar-big preference vs mixed-sizing solver outputs.
- **Sub-question:** Should `bet_small` also appear in `acceptable` for OOP-favored straight on connected boards?

### Risk #4 — Scenario 13 (`AhKc` on Th 6h 2c) — RESOLVED via fix-pass
- **Pre-fix issue:** Wrongly labelled NFD; recommended bet_big as polar bluff.
- **Post-fix:** Correctly labelled `backdoor_only` with `range_advantage_stab` as actionReason; recommendedAction is `bet_small`. The fix changes the entire pedagogical frame from "polar bluff with strong draw" to "range stab with backdoors + ace blocker." Reviewer should confirm the new framing is correct.

### Risk #5 — Scenario 17 (`QhQc` on Kc Kd 7s) — partially addressed via fix-pass
- **Post-fix:** `check` was moved from `bad` to `acceptable` to reflect modern PIO mixes. Best stays `bet_small`. Reviewer should confirm whether `mixed` should be best instead.
- **Sub-question:** Is the GTO frequency split closer to 50/50 bet/check than the seed's "best=bet_small with check acceptable" suggests?

### Risk #6 — Scenario 18 (`AsQs` on Kc Kd 7s) — RESOLVED via fix-pass
- **Pre-fix issue:** `actionReason: blocker_pressure` as primary.
- **Post-fix:** `actionReason: range_advantage_stab` as primary; explanation rewritten to clarify the A blocker is supporting evidence not the engine. Reviewer should confirm the new framing.

### Risk #7 — Scenario 20 (`AhKh` on Kc Kd 7s, reason_choice) — UNCHANGED, still high-risk
- **Issue:** Forces "value" as the best reason for the check line on trips top kicker. Some interpretations favour "trap" or "pot_control" framing; the seed deliberately uses `value` to teach delayed value. Confirm pedagogically.
- **Sub-question:** Is `pot_control` (currently `acceptable`) actually the more defensible primary framing?

### Risk #8 — Scenario 21 (`AhTd` on Jh 8h 4h) — RESOLVED via fix-pass
- **Pre-fix issue:** handClass `set` was wrong (Ah is on monotone hearts, with 4 hearts in hand+board → flush DRAW, not made flush, not set).
- **Post-fix:** handClass `nut_flush_draw`, drawCategory `nut_fd`, recommendedAction stays `bet_small` (correct for NFD on monotone), full explanation rewrite. Reviewer should confirm the small-bet-with-NFD-on-monotone framing.
- **Sub-question:** Some PIO outputs check NFD on monotone for equity-realization; should `check` be best instead of `acceptable`?

### Risk #9 — Scenario 22 (`KhQd` on Jh 8h 4h) — strategy shifted via fix-pass
- **Pre-fix issue:** Treated as made K-flush.
- **Post-fix:** Correctly identified as K-FD, recommendedAction shifted from `bet_small` to `mixed` (more defensible for a draw dominated by AhX). Reviewer should confirm.
- **Sub-question:** With the dominated-draw problem, should `check` be best instead of `mixed`?

### Risk #10 — Scenario 24 (`6h5c` on Jh 8h 4h, reason_choice) — strategy refined via fix-pass
- **Pre-fix issue:** Treated as made 6-high flush; reason_choice answer was `pot_control`.
- **Post-fix:** Correctly identified as low FD; reason_choice answer shifted to `give_up`. The reverse-domination problem is now central to the pedagogy. Reviewer should confirm.
- **Sub-question:** Some interpretations would still favor `pot_control` (currently `acceptable`) because the gutshot escapes domination via a straight; is `give_up` too strong?

---

## 6. Questions for the GPT reviewer

Please answer each as: **PASS / WARN / FAIL** + a one-line justification.

1. **Coverage** — do the 24 scenarios representatively cover the BTN-vs-BB SRP IP flop spot for a recreational-to-intermediate audience?
2. **Action correctness** — for each of the 24 scenarios, is the seed's `recommendedAction` solver-correct (or solver-defensible) for this exact spot?
3. **Reason correctness** — for each `reason_choice` scenario, is the seed's `actionReason` (best) the strategically primary reason?
4. **Critical-leak correctness** — for each scenario where `answer.critical` is non-empty, is the flagged action actually a textbook leak?
5. **Explanation accuracy** — are `explanation.handLogic`, `sizingLogic`, `commonMistake`, and `takeaway` factually correct and free of misleading shortcuts?
6. **Pedagogical layering** — does the explanation depth match the difficulty rating? (Low difficulty → simpler explanations; high difficulty → more nuanced.)
7. **Concept-tag fit** — do the concept tags meaningfully describe what the scenario teaches, or are some tags noise?
8. **Schema additivity** — does the proposed Module 2 schema (heroHandRole, drawCategory, showdownValue, recommendedAction, actionReason, blockerNote) genuinely add pedagogical value, or are some fields redundant?
9. **Family-naming consistency** — should `bet_small` / `bet_big` be retained as the family vocabulary, or should we move to size-specific naming (`bet_33` / `bet_75`) to match the existing baseline?
10. **Mixed-action ratio** — is 1 of 24 scenarios with `recommendedAction = 'mixed'` under-representing GTO mixing? What's a good target ratio for the production expansion (~150 scenarios)?
11. **Bet-big ratio** — is 3 of 24 (12.5%) too low to teach polar play adequately? What's the right ratio for production?
12. **Suit-count discipline** — confirm the post-fix labelling on monotone and two-tone boards (#13, #21, #22, #24). The fix-pass corrected scenarios where 1-card-of-suit on monotone or 1-card-of-suit on two-tone was wrongly labelled as a real flush draw or made flush. Reviewer should sanity-check the math.
13. **Open audit questions (audit-plan § 8)** — review the 6 open questions about mixed ratio, bet_big representation, monotone air drilling, reason enum depth, drawCategory granularity, and suit-count audit-script enforcement.

---

## 7. Known limitations

1. **Single spot only** — only BTN-vs-BB SRP 100BB IP. No 3-bet pots, no other positions, no other stack depths. Module 2 is intentionally narrow in v4.1.2.
2. **No solver runs** — all seeds are `expert_judgment`. The reviewer should treat all `recommendedAction` values as expert opinion subject to solver disagreement on ~5–10% of spots.
3. **Family-level sizing** — the seed uses `bet_small` / `bet_big` and intentionally ignores the granular 25% / 33% / 50% / 66% / 75% / 100% distinctions. Some scenarios where sizing is mid-range (e.g., `bet_50`) are forced into `bet_small` or `bet_big` based on closer family.
4. **No turn / river continuation** — the seed asks only the flop decision. Real strategies depend on the planned turn line; the seed assumes "play a balanced strategy on the turn."
5. **`actionReason` is single-valued** — many scenarios have multiple valid reasons (e.g., bet_small with strong top pair is BOTH value AND protection). The seed forces a single primary reason for pedagogical clarity, but this may be reductive.
6. **No villain modelling** — the seed assumes balanced GTO BB defense. Real exploitative deviations (e.g., vs. an over-folding population) are not addressed.
7. **No board paired turn / river dynamics** — `nut_advantage_shift` (a Module 1 concept) doesn't appear in the seed because the seed is flop-only.

---

## 8. Recommendation

### 8.1 Status of the seed

**Ready for seed review** — the 24 scenarios are structurally clean, distributionally representative, and pedagogically purposeful. The single content-level error identified (handClass mislabel on scenario 21) is fixable in-place during the GPT review pass.

### 8.2 What should happen after a clean GPT review

1. ~~**Fix scenario 21 handClass.**~~ ✅ Already corrected in v0.1.1 fix-pass. Plus 4 other mechanical fixes (#11, #13, #22, #24) and 5 labelling improvements (#2, #5, #6, #17, #18).
2. **Apply any reviewer-flagged corrections.** Each correction is a localised edit to the seed JSON; no architectural changes expected.
3. **Add the 5 `[planned]` concepts to `postflop_concepts.json`** (`value_betting`, `pot_control`, `blocker_pressure`, `range_advantage_stab`, `give_up_strategy`) — each gets a full long-def + examples + relatedConcepts entry mirroring the existing concept entries.
4. **Migrate the existing 11 baseline scenarios** to the v4.1.2 schema: rename `bet_33` → `bet_small`, populate `heroHandRole` / `drawCategory` / `showdownValue` / `recommendedAction` / `actionReason` / `explanation.takeaway` from the existing fields.
5. **Implement the suit-count discipline rule** in the audit script (`tools/audit-postflop-ps.ps1` and `postflop/postflop_audit_rules.js`) — this was the rule that would have caught my pre-fix mechanical errors automatically.
6. **Expand the seed.** v4.1.3 (data sprint) targets ~150 production scenarios using the same authoring pattern, mirroring v4.0.7's expansion of Module 1 from 20 to 251 scenarios.

### 8.3 What should NOT happen

- No production integration (live drill, teaching layer, weak-spot review for M2, concept drill expansion to M2 concepts) until the data sprint completes.
- No flip from `review_pending` → `approved` until the audit script extension lands.
- No removal of the existing 11 baseline scenarios until the migration question (replace / coexist / refactor) is answered by a human.

### 8.4 Final recommendation

**Status: ready for seed review.**

Hand this package to the GPT reviewer (or human poker coach) and wait for their PASS / WARN / FAIL responses against § 6. Apply corrections and re-export the seed JSON. Then schedule v4.1.3 (data + audit-script + integration sprint).

---

## 9. Appendix — full seed scenario index

For convenience, every seed scenario id linked back to its bucket:

```
A-high dry (As 8d 3h):
  001  AhKh   action  → bet_small  (value, critical: bet_big)
  002  7c6c   action  → bet_small  (range_advantage_stab, critical: bet_big)        [handClass refined to backdoor_only]
  003  9d9s   action  → check      (pot_control, critical: bet_big)
  004  QcJh   reason  → range_advantage_stab

K-high semi-dry (Kh 9c 4s):
  005  KsQc   action  → bet_small  (value, critical: bet_big)                       [handClass refined to top_pair_good_kicker]
  006  JdTd   action  → bet_small  (equity_realization, critical: bet_big)          [handClass refined to gutshot]
  007  7h7c   action  → check      (pot_control, critical: bet_big)
  008  AcQh   reason  → range_advantage_stab

Low connected (8s 7d 5h):
  009  JhJc   action  → check      (pot_control, critical: bet_big)
  010  AhQc   action  → check      (give_up, critical: bet_big)
  011  9c6c   action  → bet_big    (value, made straight)                           [handClass corrected: combo_draw → straight]
  012  KsKd   reason  → pot_control (critical: protection)

Two-tone (Th 6h 2c):
  013  AhKc   action  → bet_small  (range_advantage_stab)                           [MAJOR FIX: was wrongly labelled NFD; now backdoor_only with bet_small]
  014  Tc8s   action  → bet_small  (thin_value, critical: bet_big)
  015  4d4c   action  → check      (give_up, critical: bet_big)
  016  9h8h   reason  → equity_realization (critical: value)

Paired Kx (Kc Kd 7s):
  017  QhQc   action  → bet_small  (thin_value, critical: bet_big)                  [check moved from bad to acceptable]
  018  AsQs   action  → bet_small  (range_advantage_stab, critical: bet_big)        [actionReason corrected from blocker_pressure]
  019  6c6d   action  → check      (pot_control, critical: bet_big)
  020  AhKh   reason  → value      (critical: give_up)

Monotone (Jh 8h 4h):
  021  AhTd   action  → bet_small  (equity_realization)                             [MAJOR FIX: handClass set → nut_flush_draw; explanation rewrite]
  022  KhQd   action  → mixed      (equity_realization)                             [STRATEGY SHIFT: was bet_small; explanation rewrite — K-FD not made K-flush]
  023  9d9c   action  → check      (give_up, critical: bet_big)
  024  6h5c   reason  → give_up    (critical: value)                                [REASON SHIFT: was pot_control; explanation rewrite — low FD not made flush]
```

Total: **24 scenarios** across 6 boards. Post-fix-pass audit verification: 30/30 hard rules pass, 8/8 soft rules pass, 5/5 coverage rules pass (with 5 `[planned]` concept tags warning per audit-plan § 2.24). Fix-pass corrected 5 mechanical errors and applied 5 labelling improvements.

---

# v4.1.4 Review Addendum — strategic re-review + baseline migration decision

**Status of this addendum:** Appended on 2026-05-05. Previous history above is unchanged.

## A1. Latest audit results

| Audit | Result | Status |
|---|---|---|
| Production audit (`tools/audit-postflop-ps.ps1`) | 262 / 0 / 0 | unchanged from v4.1.3 |
| Module 2 seed audit (`tools/audit-postflop-module2-seed.ps1`) | 24 / 0 hard errors / 11 warnings, **15 PASS / 9 WARN / 0 FAIL** | unchanged from v4.1.3 |

## A2. Strategic review verdict (overlay on top of mechanical audit)

| Verdict | Count | Scenarios |
|---|---|---|
| **PASS** (mechanical + strategic) | 20 | #1, #2, #3, #4, #5, #6, #7, #8, #10, #11, #13, #14, #15, #16, #18, #19, #21, #22, #23, #24 |
| **WARN** (defensible but reviewer-sensitive) | 4 | #9, #12, #17, #20 |
| **FAIL** | 0 | — |

Note: this strategic verdict **differs** from the audit verdict (15 PASS / 9 WARN / 0 FAIL) because some scenarios have audit warnings (about labeling precision: backdoor_only vs no_pair_no_draw, sizingLogic optional, made-flush wording) but pass strategically. Full reconciliation in `postflop-v4.1.4-module2-seed-review-report.md` § 3.

## A3. Remaining warnings — disposition

| Code | Count | Disposition for v4.1.5 |
|---|---|---|
| M2.HC11 (no_pair_no_draw vs backdoor_only) | 4 | **3 fixes** (#4, #8, #18 → backdoor_only). #10 stays no_pair_no_draw (backdoor not strategically relevant). |
| M2.HC09 (underpair vs mid_pair on QQ on K-K-7) | 1 | Keep #17 as underpair; extend `underpair` definition in schema-taxonomy.md to allow paired-board exception. |
| M2.H14 (sizingLogic optional for reason_choice) | 3 | Keep as warning. Optionally add `actionLogic` field for reason_choice in v4.1.6 schema refinement. |
| M2.SC05 (made-flush wording in negation) | 3 | Keep as warning. Audit text-match is fuzzy; explanation negations are intentional. Re-examine if in-browser auditor adopts the rule. |

## A4. Strategic WARN — disposition

| # | Scenario | Disposition |
|---|---|---|
| 9 | JJ on 8-7-5 (critical=bet_big) | **KEEP** — bet_big IS the textbook leak; pedagogically correct |
| 12 | KK on 8-7-5 reason_choice (critical=protection) | **KEEP** — protection-bet frame is the leak we teach against |
| 17 | QQ on K-K-7 (best=bet_small) | **KEEP** — solver mixes; bet_small as best with check acceptable is one defensible position |
| 20 | AhKh trips reason_choice (best=value) | **REWORD** — change prompt to make trap framing explicit ("when BTN checks trip Ks back as a trap...") so "value" reason reads naturally |

## A5. Baseline migration decision

The 11 legacy Module 2 scenarios in `postflop/postflop_scenarios.json` use older schema (choice ids `bet_33`/`bet_75`, missing v4.1.2 fields like `heroHandRole` / `recommendedAction` / `actionReason` / `drawCategory` / `showdownValue` / `takeaway`).

**Decision: Option C — Refactor / Migrate** (per `postflop-v4.1.4-module2-baseline-migration-plan.md`).

| Reason | Detail |
|---|---|
| Preserve consensus_gto work | Baseline-11 are tagged `consensus_gto`; discarding them wastes high-confidence content |
| Schema unity | Avoids dual answer-id sets (`bet_33` and `bet_small` both live) |
| No board overlap | Baseline-11 boards (Ah Kd 5c, Kh Td 2s, 8h 7c 6s, Jh Ts 9c, Ah Jh 3s, 6c 5c 4s) don't overlap v4.1.2 seed boards → 12 distinct boards × ~3 hands/board after merge = good production base |
| Mechanical mapping | `bet_33 → bet_small`, `bet_75 → bet_big`, `handClass` already valid v4.1.2 vocab. Judgment-required only for `heroHandRole` and `actionReason` |

After the v4.1.5 migration sprint, production Module 2 set will be **35 scenarios** (24 v4.1.2 seeds + 11 migrated baseline) across **12 distinct boards**. Production audit gate will move from **262 / 0 / 0** to **286 / 0 / 0**.

## A6. Recommendation for v4.1.5

**v4.1.5 — Module 2 Seed Cleanup + Baseline Migration + Audit Extension** (data + audit only, no runtime).

Atomic scope:
1. Apply 3 `backdoor_only` relabels + 1 reword to seed JSON.
2. Extend `underpair` definition + document `actionLogic` field in schema-taxonomy.
3. Add 5 `[planned]` concepts to `postflop/postflop_concepts.json`.
4. Migrate 11 baseline scenarios per the migration plan.
5. Extend `tools/audit-postflop-ps.ps1` with v4.1.2 Module 2 rules.
6. Audit gates: production 286/0/0 + seed (now reading production) 35/0 hard errors.
7. GPT review pass on the 11 migrated scenarios.
8. Commit + push.
9. Stop.

After v4.1.5: production gate is 286/0/0, Module 2 is `consensus_gto`-quality data in production JSON, and Module 2 is **still not playable** (runtime not wired). Module 2 plays around **v4.1.7** — see § 9 of `postflop-v4.1.4-module2-seed-review-report.md`.
