# Postflop v4.2.0 — Module 3 GPT/Strategic Review Package

**Status:** Planning-only. Per-scenario review prompts and risk flags for the v4.2.1 strategic review pass.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.0-module3-architecture.md`, `postflop-v4.2.0-module3-schema-taxonomy.md`, `postflop-v4.2.0-module3-seed-scenarios.json`, `postflop-v4.2.0-module3-audit-plan.md`

---

## 1. Purpose

This doc is the input package for the v4.2.1 strategic review pass on the 24 v4.2.0 seed scenarios. It surfaces:

1. The strategic context the reviewer needs (spot, sizing, range assumptions).
2. The per-scenario review prompts (what the reviewer should evaluate).
3. The known risk flags per scenario (where I expect potential WARN or FAIL).

The output of v4.2.1's review is per-scenario PASS / WARN / FAIL, with optional fixes recommended. v4.2.0 itself does not run the review — it just packages the inputs.

---

## 2. Strategic context the reviewer needs

| Item | Value | Source |
|---|---|---|
| Spot | NLH MTT, 100BB, BTN open 2.5x, BB call, flop, BTN c-bets ~33% pot | architecture §3 |
| Hero | BB, OOP, preflop caller, range capped (no AA-QQ, no AK by convention) | architecture §4 |
| Villain | BTN, IP, preflop raiser, c-bet range wide (~50-80% depending on texture) | architecture §4 |
| Decision set | fold / call / check_raise_small (~3x) / check_raise_big (~4x) / mixed | schema §4 |
| Reason set | 8 reasons (value_raise, protection_raise, semi_bluff_raise, blocker_raise [acceptable only], bluff_catch, equity_realization_call, range_disadvantage_fold, domination_fold) | schema §5 |
| Defense threshold | ~25% equity vs small bet (MDF ≈ 67%) | architecture §1 |

**Source confidence:** All v4.2.0 seeds are `expert_judgment`. The reviewer should treat them as a starting point, not as solver-verified ground truth. Specific solver disagreements should be flagged as WARN.

---

## 3. Review prompt template

For **every** scenario in the seed JSON, the v4.2.1 reviewer answers:

1. **Mechanical validity** — handClass, drawCategory, showdownValue, heroHandRole all correctly assigned? (PASS / FAIL)
2. **Strategic best action** — is `answer.best` defensible at this stack/sizing/spot? (PASS / WARN if mixed-strategy line could be argued / FAIL if clearly wrong)
3. **Acceptable / bad / critical** — is the partition reasonable? Specifically, is `critical` calling out a real leak? (PASS / WARN / FAIL)
4. **actionReason fit** — does the reason match the line and the strategic intent? (PASS / WARN / FAIL)
5. **Explanation quality** — does it teach the *why* without misleading? (PASS / WARN / FAIL)
6. **Concept tag relevance** — do the tags match the decision being trained? (PASS / WARN — tags off but action correct / FAIL — tags imply wrong concept)

**Aggregate per-scenario verdict:** PASS if all 6 dimensions PASS; WARN if 1-2 WARN with no FAIL; FAIL if any dimension FAIL.

---

## 4. Per-scenario review entries (24)

### Family 1: Dry A-high (As 8d 3h)

#### F1.1 — pf_btn_v_bb_srp_100bb_flop_As8d3h_m3_action_Th8h_v420
- **Hero:** Th 8h | **Type:** action_choice | **Best:** call | **Reason:** equity_realization_call
- **handClass:** mid_pair | **drawCategory:** backdoor_only | **showdownValue:** decent
- **Critical mistake flagged:** check_raise_big
- **Strategic question:** Is mid pair + BDFD a clear continue (no mixed call/fold) on dry A-high vs small c-bet?
- **Risk flag:** Some solvers fold the worst combo of mid pair + BDFD when villain's range is heavy on overpairs (4-bet pots, etc.) — but this is SRP, so call should be solid.
- **Reviewer focus:** Confirm critical=check_raise_big captures a real leak (over-bluffing OOP with marginal pair).

#### F1.2 — pf_btn_v_bb_srp_100bb_flop_As8d3h_m3_action_8c8h_v420
- **Hero:** 8c 8h | **Type:** action_choice | **Best:** check_raise_small | **Reason:** value_raise
- **handClass:** set | **drawCategory:** none | **showdownValue:** nutted
- **Critical mistake flagged:** fold
- **Strategic question:** Is raise vs slowplay the correct frequency-dominant action with middle set OOP on dry A-high?
- **Risk flag:** Solver mix probably 60/40 raise/call. Marking raise as best with call as acceptable should be fine.
- **Reviewer focus:** Verify acceptable=[call] captures the slowplay option; verify critical=[fold] is correctly flagged.

#### F1.3 — pf_btn_v_bb_srp_100bb_flop_As8d3h_m3_reason_5h4h_v420
- **Hero:** 5h 4h | **Type:** reason_choice | **Best reason:** equity_realization_call
- **handClass:** gutshot | **drawCategory:** gutshot | **showdownValue:** low
- **Critical mistake flagged:** semi_bluff_raise (as a reason)
- **Strategic question:** Is wheel gutshot + BDFD a call (not raise) OOP on dry A-high?
- **Risk flag:** Some solvers mix in a small raise frequency with this combo as a polar bluff. Marking semi_bluff_raise as `critical` may be too harsh; consider whether it should be merely `bad`.
- **Reviewer focus:** Decide whether semi_bluff_raise should be `bad` or `critical`. If solver mix is non-trivial (>10%), downgrade from `critical` to `bad`.

#### F1.4 — pf_btn_v_bb_srp_100bb_flop_As8d3h_m3_action_JcTd_v420
- **Hero:** Jc Td | **Type:** action_choice | **Best:** fold | **Reason:** range_disadvantage_fold
- **handClass:** no_pair_no_draw | **drawCategory:** none | **showdownValue:** none
- **Critical mistake flagged:** check_raise_big
- **Strategic question:** Is JTo on dry A-high a pure fold (no calling frequency)?
- **Risk flag:** Some BB defense ranges include JTo for board coverage; might be a small calling frequency. WARN if solver shows >15% call.
- **Reviewer focus:** Confirm fold > call is the dominant solver line; verify critical=[check_raise_big] catches the worst over-bluff.

### Family 2: Dry K-high (Kh 9c 4s)

#### F2.1 — pf_btn_v_bb_srp_100bb_flop_Kh9c4s_m3_action_9d8d_v420
- **Hero:** 9d 8d | **Type:** action_choice | **Best:** call | **Reason:** equity_realization_call
- **handClass:** mid_pair | **drawCategory:** backdoor_only | **showdownValue:** decent
- **Critical mistake flagged:** check_raise_big
- **Strategic question:** Same defense logic as F1.1 but on K-high.
- **Risk flag:** None — middle pair + BDFD is a textbook call vs small.
- **Reviewer focus:** Verify the acceptable list (currently empty) — should slowplay/protection raise be acceptable? Probably no.

#### F2.2 — pf_btn_v_bb_srp_100bb_flop_Kh9c4s_m3_action_9s9h_v420
- **Hero:** 9s 9h | **Type:** action_choice | **Best:** check_raise_small | **Reason:** value_raise
- **handClass:** set | **drawCategory:** none | **showdownValue:** nutted
- **Critical mistake flagged:** fold
- **Strategic question:** Same as F1.2 — middle set raise vs slowplay frequency.
- **Risk flag:** None.
- **Reviewer focus:** Confirm raise frequency dominant on dry K-high.

#### F2.3 — pf_btn_v_bb_srp_100bb_flop_Kh9c4s_m3_reason_QcJc_v420
- **Hero:** Qc Jc | **Type:** reason_choice | **Best reason:** equity_realization_call
- **handClass:** gutshot | **drawCategory:** gutshot | **showdownValue:** low
- **Critical mistake flagged:** semi_bluff_raise
- **Strategic question:** Is QJ-suited a clear call (not semi-bluff) on dry K-high?
- **Risk flag:** QJ has more equity than 5-4 (more overcard outs). Solver mix may include some semi-bluff frequency. Same caveat as F1.3.
- **Reviewer focus:** Same as F1.3 — decide whether semi_bluff_raise should be `bad` or `critical`.

#### F2.4 — pf_btn_v_bb_srp_100bb_flop_Kh9c4s_m3_action_AhQs_v420
- **Hero:** Ah Qs | **Type:** action_choice | **Best:** fold | **Reason:** domination_fold
- **handClass:** no_pair_no_draw | **drawCategory:** none | **showdownValue:** none
- **Critical mistake flagged:** check_raise_big
- **Strategic question:** Is AQ a fold on K-high vs small c-bet?
- **Risk flag:** AQ may be a mixed call/fold depending on villain's c-bet range tightness. With BTN's wide c-bet, fold is dominant. Acceptable=[call] correctly captures the mixed line.
- **Reviewer focus:** Verify domination_fold is the right reason (vs range_disadvantage_fold).

### Family 3: Low connected (8s 7d 5h)

#### F3.1 — pf_btn_v_bb_srp_100bb_flop_8s7d5h_m3_action_9c8c_v420
- **Hero:** 9c 8c | **Type:** action_choice | **Best:** call | **Reason:** equity_realization_call
- **handClass:** top_pair_weak_kicker | **drawCategory:** gutshot | **showdownValue:** high
- **Critical mistake flagged:** fold
- **Strategic question:** Is top pair + gutshot a call (not raise) on wet low connected from BB?
- **Risk flag:** With BB's range advantage on low connected, raise is also defensible. acceptable=[check_raise_small] handles this.
- **Reviewer focus:** Confirm call > raise frequency for top-pair-weak-kicker on wet low. Verify critical=[fold] is correct (folding TP+gutshot would be a huge leak).

#### F3.2 — pf_btn_v_bb_srp_100bb_flop_8s7d5h_m3_action_5c5d_v420
- **Hero:** 5c 5d | **Type:** action_choice | **Best:** check_raise_small | **Reason:** protection_raise
- **handClass:** set | **drawCategory:** none | **showdownValue:** nutted
- **Critical mistake flagged:** fold
- **Strategic question:** Is bottom set a raise (vs slowplay) on draw-heavy low connected?
- **Risk flag:** None — bottom set on wet board is a clear protection raise.
- **Reviewer focus:** Verify protection_raise vs value_raise — both apply, but protection is the dominant motivation here.

#### F3.3 — pf_btn_v_bb_srp_100bb_flop_8s7d5h_m3_reason_Td9d_v420
- **Hero:** Td 9d | **Type:** reason_choice | **Best reason:** semi_bluff_raise
- **handClass:** oesd | **drawCategory:** oesd | **showdownValue:** low
- **Critical mistake flagged:** none
- **Strategic question:** Is OE+overcards+BDFD a semi-bluff raise (not call) on low connected?
- **Risk flag:** This is one of the few BB semi-bluff raise spots. Could be mixed call/raise. Both reasons (semi_bluff_raise and equity_realization_call) are defensible — acceptable=[protection_raise] captures the value-protection blend.
- **Reviewer focus:** Confirm semi_bluff_raise as the dominant motivation; equity_realization_call would also be acceptable but second-best.

#### F3.4 — pf_btn_v_bb_srp_100bb_flop_8s7d5h_m3_action_AhKc_v420
- **Hero:** Ah Kc | **Type:** action_choice | **Best:** fold | **Reason:** range_disadvantage_fold
- **handClass:** no_pair_no_draw | **drawCategory:** none | **showdownValue:** none
- **Critical mistake flagged:** check_raise_big
- **Strategic question:** Is AKo a clear fold on low connected vs small c-bet?
- **Risk flag:** AKo is one of the most-debated folds in poker. Solvers may show small calling frequency. WARN if >20% call.
- **Reviewer focus:** Confirm fold > call. If solver shows >25% call, downgrade to acceptable=[call].

### Family 4: Two-tone broadway (Qh Jh 6c)

#### F4.1 — pf_btn_v_bb_srp_100bb_flop_QhJh6c_m3_action_AcTc_v420
- **Hero:** Ac Tc | **Type:** action_choice | **Best:** call | **Reason:** equity_realization_call
- **handClass:** gutshot | **drawCategory:** gutshot | **showdownValue:** low
- **Critical mistake flagged:** fold
- **Strategic question:** Is nut gutshot + A blocker + BDFD a clear call on Q-high two-tone?
- **Risk flag:** Some solvers mix in semi-bluff raise for the A-blocker pressure. acceptable=[check_raise_small] handles this.
- **Reviewer focus:** Confirm call dominant; verify critical=[fold] catches the over-fold leak.

#### F4.2 — pf_btn_v_bb_srp_100bb_flop_QhJh6c_m3_action_QcQd_v420
- **Hero:** Qc Qd | **Type:** action_choice | **Best:** check_raise_small | **Reason:** value_raise
- **handClass:** set | **drawCategory:** none | **showdownValue:** nutted
- **Critical mistake flagged:** fold
- **Strategic question:** Top set on wet board — raise small or big?
- **Risk flag:** Big raise also defensible on this draw-heavy texture. acceptable=[check_raise_big] handles this.
- **Reviewer focus:** Verify value_raise + protection_raise concept tags; some reviewers may prefer protection as primary on this texture.

#### F4.3 — pf_btn_v_bb_srp_100bb_flop_QhJh6c_m3_reason_9h8h_v420
- **Hero:** 9h 8h | **Type:** reason_choice | **Best reason:** semi_bluff_raise
- **handClass:** combo_draw | **drawCategory:** combo_draw | **showdownValue:** low
- **Critical mistake flagged:** none
- **Strategic question:** Is FD+gutshot 12+ outs a raise (not call) on Q-high two-tone?
- **Risk flag:** None — combo draws are textbook semi-bluff raise candidates.
- **Reviewer focus:** Verify semi_bluff_raise dominance over equity_realization_call.

#### F4.4 — pf_btn_v_bb_srp_100bb_flop_QhJh6c_m3_action_8c4c_v420
- **Hero:** 8c 4c | **Type:** action_choice | **Best:** fold | **Reason:** range_disadvantage_fold
- **handClass:** backdoor_only | **drawCategory:** backdoor_only | **showdownValue:** none
- **Critical mistake flagged:** check_raise_big
- **Strategic question:** Is 84s with backdoor club only a clear fold on Q-high two-tone?
- **Risk flag:** None — backdoor-only with weak high card is below threshold.
- **Reviewer focus:** Verify the fold over the float frequency.

### Family 5: Monotone (Jh 8h 4h)

#### F5.1 — pf_btn_v_bb_srp_100bb_flop_Jh8h4h_m3_action_9h8c_v420
- **Hero:** 9h 8c | **Type:** action_choice | **Best:** call | **Reason:** equity_realization_call
- **handClass:** mid_pair | **drawCategory:** flush_draw | **showdownValue:** decent
- **Critical mistake flagged:** check_raise_big
- **Strategic question:** Pair + 1-card FD on monotone — call vs raise?
- **Risk flag:** Some monotone defense theory says always check-call vs small bet to keep villain's bluffs in. Should be solid.
- **Reviewer focus:** Confirm 1-card FD classification (drawCategory=flush_draw) is consistent with rest of M3 vocabulary; some reviewers may prefer drawCategory=backdoor_only for 1-card FDs.

#### F5.2 — pf_btn_v_bb_srp_100bb_flop_Jh8h4h_m3_action_AhKh_v420
- **Hero:** Ah Kh | **Type:** action_choice | **Best:** check_raise_big | **Reason:** value_raise
- **handClass:** nut_flush | **drawCategory:** none | **showdownValue:** nutted
- **Critical mistake flagged:** fold
- **Strategic question:** Nut flush on monotone — raise big vs small vs slowplay?
- **Risk flag:** Slowplay also strongly defensible to disguise. acceptable=[check_raise_small] handles small-raise option, but slowplay (call) is missing from acceptable. Reviewer may want to add `call` to acceptable.
- **Reviewer focus:** Decide if `call` (slowplay) should be in acceptable. Likely YES for solver coherence.

#### F5.3 — pf_btn_v_bb_srp_100bb_flop_Jh8h4h_m3_reason_KhQc_v420
- **Hero:** Kh Qc | **Type:** reason_choice | **Best reason:** equity_realization_call
- **handClass:** flush_draw | **drawCategory:** flush_draw | **showdownValue:** low
- **Critical mistake flagged:** semi_bluff_raise
- **Strategic question:** 2nd-nut FD with K blocker — call (best) vs blocker_raise (acceptable)?
- **Risk flag:** Some solvers prefer the blocker raise frequency on monotone with K-blocker. Marking semi_bluff_raise as critical (because it's not a semi-bluff per se — it's a blocker bluff) may need to be downgraded to bad.
- **Reviewer focus:** Validate the distinction between semi_bluff_raise (which is wrong here) and blocker_raise (which is acceptable).

#### F5.4 — pf_btn_v_bb_srp_100bb_flop_Jh8h4h_m3_action_6c5d_v420
- **Hero:** 6c 5d | **Type:** action_choice | **Best:** fold | **Reason:** range_disadvantage_fold
- **handClass:** no_pair_no_draw | **drawCategory:** none | **showdownValue:** none
- **Critical mistake flagged:** check_raise_big
- **Strategic question:** No-heart air on monotone — pure fold?
- **Risk flag:** None — zero hearts means zero flush equity.
- **Reviewer focus:** Verify reason is range_disadvantage_fold (could also be reverse_implied_odds for the gutshot to 7).

### Family 6: Paired (Kc Kd 7s)

#### F6.1 — pf_btn_v_bb_srp_100bb_flop_KcKd7s_m3_action_7d6d_v420
- **Hero:** 7d 6d | **Type:** action_choice | **Best:** call | **Reason:** equity_realization_call
- **handClass:** mid_pair | **drawCategory:** none | **showdownValue:** decent
- **Critical mistake flagged:** check_raise_big
- **Strategic question:** Trip 7 on paired-K — call to bluff-catch?
- **Risk flag:** Wait — hero has 7d6d on Kc-Kd-7s. Pair of 7s, NOT trip 7. Hero just has a pair (7) with a kicker (6). Confirm handClass=mid_pair is correct (not trips). Yes, mid_pair is right because hero has only one 7 in hand + one 7 on board = pair, not trips.
- **Reviewer focus:** Confirm reason should be bluff_catch (not equity_realization_call). The scenario teaches catching bluffs on paired boards.

#### F6.2 — pf_btn_v_bb_srp_100bb_flop_KcKd7s_m3_action_AhKh_v420
- **Hero:** Ah Kh | **Type:** action_choice | **Best:** check_raise_small | **Reason:** value_raise
- **handClass:** trips | **drawCategory:** none | **showdownValue:** nutted
- **Critical mistake flagged:** fold
- **Strategic question:** Trip K + nut kicker — raise vs slowplay?
- **Risk flag:** Slowplay heavily favored on paired boards by many solvers. acceptable=[call] correctly captures this.
- **Reviewer focus:** Decide if best should flip to call (slowplay) and acceptable=[check_raise_small]. Currently raise is best, slowplay acceptable. May need flip.

#### F6.3 — pf_btn_v_bb_srp_100bb_flop_KcKd7s_m3_reason_8d8s_v420
- **Hero:** 8d 8s | **Type:** reason_choice | **Best reason:** bluff_catch
- **handClass:** underpair | **drawCategory:** none | **showdownValue:** decent
- **Critical mistake flagged:** none
- **Strategic question:** 88 on KK7 — bluff catch (not range_disadvantage_fold)?
- **Risk flag:** Solver may show small fold frequency. acceptable=[equity_realization_call] captures the alternative reasoning.
- **Reviewer focus:** Confirm bluff_catch over equity_realization_call. Both are defensible reasons; bluff_catch is the more specific one.

#### F6.4 — pf_btn_v_bb_srp_100bb_flop_KcKd7s_m3_action_JcTc_v420
- **Hero:** Jc Tc | **Type:** action_choice | **Best:** fold | **Reason:** range_disadvantage_fold
- **handClass:** backdoor_only | **drawCategory:** backdoor_only | **showdownValue:** none
- **Critical mistake flagged:** check_raise_big
- **Strategic question:** JTs with backdoor club — fold on paired-K?
- **Risk flag:** JTs has backdoor flush (3 clubs: Jc, Tc, Kc) and overcards. Solver may show small calling frequency.
- **Reviewer focus:** Verify fold dominance; if solver shows >15% call, add `call` to acceptable.

---

## 5. Risk flag summary

| Risk type | Count | Scenarios | Action for v4.2.1 reviewer |
|---|---|---|---|
| Mixed strategy may downgrade `critical` to `bad` | 5 | F1.3, F2.3, F3.4, F5.3, F6.4 | Check solver mix; downgrade if frequency >10% |
| Slowplay should be added to `acceptable` | 2 | F5.2, F6.2 | Add `call` to acceptable if solver supports |
| Reason ambiguity (multiple valid reasons) | 3 | F2.4 (domination vs range_disadvantage), F3.3 (semi_bluff vs protection), F6.1 (bluff_catch vs equity_realization) | Reviewer picks the more specific |
| Vocabulary classification edge case | 2 | F5.1 (1-card FD = flush_draw or backdoor?), F5.4 (range_disadvantage vs reverse_implied_odds) | Decide and document |
| Likely-PASS-no-changes | 12 | F1.1, F1.2, F1.4, F2.1, F2.2, F3.1, F3.2, F4.1, F4.2, F4.3, F4.4, F5.4 | Quick PASS expected |

**Pre-review prediction:** ~12 PASS + ~10 WARN (with minor adjustments) + ~2 needing discussion. **0 expected FAIL** — no scenario is expected to be strategically incorrect at the action level.

---

## 6. Process for v4.2.1

1. v4.2.1 implements the seed auditor (per audit-plan doc).
2. Run mechanical audit → expect 0 hard errors, some warnings.
3. Reviewer (GPT/strategic) goes scenario-by-scenario answering the 6 review questions per §3.
4. Output: per-scenario PASS / WARN / FAIL + recommended fixes for WARN/FAIL.
5. Apply fixes to seed JSON (still planning JSON, not production).
6. Flip `reviewStatus` per-scenario from `v4.2.0_seed_candidate` → `v4.2.0_seed_reviewed`.
7. v4.2.2 = final review pass + commit of reviewed seeds.
8. v4.2.3 = migration to production data.

---

## 7. Sign-off

This GPT review package is **planning-only**. v4.2.0 produces the inputs but does not run the review. The package is ready for v4.2.1 if and only if:

1. ✅ All 24 scenarios have a per-scenario review entry.
2. ✅ Risk flags are explicit and actionable.
3. ✅ The review prompt template (§3) is applicable across all scenarios.
4. ✅ The PASS/WARN/FAIL criteria match the audit plan.

Status: ✅ All four conditions met. Ready for v4.2.1 review.
