# G3 Range Reveal — Full Hit-List (all 510 scenarios; PIN-2 amended whitelist)

Generated 2026-07-05 from production data (blob 65f0022d). Logic mirrors runtime `_pfRangeRevealBand` exactly:
4 band regexes · negation guard (~40-char window: not / n't / never / rarely / no longer) · flush-dense requires range/value in-sentence · fields: riverLogic+turnLogic+rangeContext+handLogic+blockerNote · **per-scenario suppression list `_PF_REVEAL_SUPPRESS`** (owner line-review 2026-07-05; explicit ids, no regex engineering).

## Summary (post line-review, final)

- polarized · value-lean: **1**
- value-heavy line: **3**
- polarized line: **40**
- bluff-heavy line: **2**
- merged / thin-value line: **4**
- **banded total (chip can fire): 50**
- [NEG-SUPPRESSED] entries: **2**
- [LIST-SUPPRESSED] entries: **1** (owner line-review false positive; see row)
- no chip displayed: **460 of 510 scenarios**

**Owner line-review rulings applied (2026-07-05):**
1. `river_Ks9d4c_7s_m5_action_9c9h_v440` — false positive: "thin value (Kx) that calls a small raise" describes villain's continue-vs-raise range, NOT the composition of villain's betting line → added to `_PF_REVEAL_SUPPRESS`.
2. `river_Js8d5c_Ac_m5_action_KcJd_v440` (polarized · value-lean) — lean component's authored support sentence: "The pot-sized bet is value-weighted; pair of jacks beats only the busted bluffs and is now below them in frequency." (direct composition claim → lean retained).
3. "Polar card" phrasing (rows `KsTd_v430D`, `As9s_v432`): card-level shorthand accepted as conventionally equivalent to a range-polarity claim — accepted-interpretation note recorded in the G3 spec.

> Runtime chip fires ONLY on M4/M5 hands inside Tournament mode; this list covers all 510 for review completeness.

| Scenario id | Band | Matched sentence (verbatim) |
|---|---|---|
| `pf_btn_v_bb_srp_100bb_flop_8h7c6s_action_AA` | polarized line | "Big bet (75%) is part of a polar protection line — denies equity to draws." |
| `pf_btn_v_bb_srp_100bb_flop_AhKd5c_action_55` | polarized line | "Big bet acceptable as part of polar mix but small with the range is the standard line." |
| `pf_btn_v_bb_srp_100bb_flop_8s7d5h_m2_action_9c6c_v412` | polarized line | "Polar big sizing extracts maximum from BB's overpair / two pair calls." |
| `pf_btn_v_bb_srp_100bb_flop_Th6h2c_m2_action_AhKc_v412` | **[NEG-SUPPRESSED]** polarized line | "That's enough equity + leverage to bet, but it is NOT a polar-bluff candidate — overestimating the equity by treating it as a real NFD is the mistake to avoid." |
| `pf_btn_v_bb_srp_100bb_flop_KcKd7s_m2_reason_AhKh_v412` | merged / thin-value line | "Betting small extracts thin value; checking lets BB take a stab on the turn or makes it harder for them to fold middling pairs and ace-high floats." |
| `pf_btn_v_bb_srp_100bb_flop_Jh8h4h_m2_action_AhTd_v412` | polarized line | "It's a strong semi-bluff candidate, but on monotone the dominant sizing is small (rather than polar big), because big chases away the one-pair / lower-FD calling range." |
| `pf_btn_v_bb_srp_100bb_flop_Th6s2c_m2_action_TcTd_v419` | merged / thin-value line | "Small bet extracts thin value from a wide bluff-catcher tail (overpairs, broadway floats); big bet polarises but folds out the long tail." |
| `pf_btn_v_bb_srp_100bb_flop_Kh9c4s_m3_action_AhQs_v420` | value-heavy line | "AQ has no pair, no draw, and the A blocks villain's AK bluffs (so villain's range is more value-heavy)." |
| `pf_btn_v_bb_srp_100bb_flop_Jh8h4h_m3_action_9h8c_v420` | polarized line | "BTN c-bets monotone smaller and less often; range is polarized between flushes and air." |
| `pf_btn_v_bb_srp_100bb_flop_Jh8h4h_m3_reason_KhQc_v420` | polarized line | "BTN c-bets monotone small with a polarized range; flushes and air both possible." |
| `pf_btn_v_bb_srp_100bb_flop_Jh8h4h_m3_action_6c5d_v420` | polarized line | "BTN c-bets monotone polarized; without a heart, hero has no equity vs flushes." |
| `pf_btn_v_bb_srp_100bb_flop_7s5s3s_m3_action_As6h_v423a` | polarized line | "BTN c-bets monotone polarized (flushes vs air); As blocks all of BTN''s nut flush combos." |
| `pf_btn_v_bb_srp_100bb_flop_7s5s3s_m3_action_6h5h_v423a` | polarized line | "BTN c-bets monotone polarized; pair of 5s loses to all flushes and is dominated by 6x and 7x." |
| `pf_btn_v_bb_srp_100bb_flop_7s5s3s_m3_reason_AsKh_v423a` | polarized line | "BTN's c-bet range on monotone is polarized (made flushes + air); the As blocks villain''s flush combos." |
| `pf_btn_v_bb_srp_100bb_flop_KhJh4h_m3_reason_AhTd_v423b` | polarized line | "BTN c-bet range on monotone is polarized (made flushes + air); Ah blocks every flush combo BTN could have." |
| `pf_btn_v_bb_srp_100bb_flop_KhJh4h_m3_action_Th9d_v423b` | polarized line | "BTN c-bets monotone polarized (made flushes + air); Th gives 9 outs to a flush but ranks behind A/K/Q-high flushes." |
| `pf_btn_v_bb_srp_100bb_flop_KhJh4h_m3_action_Ad8c_v423b` | polarized line | "BTN c-bets monotone polarized; without a heart hero has zero flush equity AND Ad does not block hearts." |
| `pf_btn_v_bb_srp_100bb_turn_Ks8s3d_2s_m4_action_Tc9c_v430` | polarized line | "2s completes flush; without a spade, hero has no flush threat and faces a polarized barrel range (flushes + air-with-no-spade)." |
| `pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_9c9d_v430C` | polarized line | "a marginal pair vs a polarized barrel." |
| `pf_btn_v_bb_srp_100bb_turn_9s8d4c_7h_m4_action_JhTh_v430C` | polarized line | "both pay off bigger sizing on a polar turn." |
| `pf_btn_v_bb_srp_100bb_turn_9s8d4c_7h_m4_action_AhAd_v430C` | polarized line | "BTN barrel range polarized" |
| `pf_btn_v_bb_srp_100bb_turn_JdTd5s_2c_m4_action_AhAd_v430C` | polarized line | "Villain barrel range stays polarized: value Jx/Tx/sets + air bluffs that took the line." |
| `pf_btn_v_bb_srp_100bb_turn_JdTd5s_2c_m4_action_9c9d_v430C` | polarized line | "Vs villain barrel range that contains polar value (Jx/Tx/sets) + air, hero is bluff-catcher BUT close to threshold given many bluffs are also gutshots/FDs that have real equity." |
| `pf_btn_v_bb_srp_100bb_turn_9s8d4c_7h_m4_action_TsTc_v430D` | polarized line | "The 7 also turns BB range into the value-favored side, so villain barrel range is more polarized." |
| `pf_btn_v_bb_srp_100bb_turn_JdTd5s_2c_m4_action_JhJs_v430D` | polarized line | "Polar brick favors raising to charge value-region hands plus bluffs while villain has not yet given up." |
| `pf_btn_v_bb_srp_100bb_turn_JdTd5s_2c_m4_action_KsKh_v430D` | polarized line | "Turn 2 brick is harmless and the polar dynamic favors charging Jx." |
| `pf_btn_v_bb_srp_100bb_turn_7s5d3h_4c_m4_action_8d7d_v430D` | polarized line | "Multi-source equity earns the call vs polarized barrel." |
| `pf_btn_v_bb_srp_100bb_turn_7s5d3h_4c_m4_action_KsTd_v430D` | polarized line | "4c is a polar straight-complete card on a low BB-favored board." |
| `pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_reason_AdJc_v430D` | polarized line | "Hero TPGK (A-pair, J kicker) has clean showdown value vs villain barrel range that is polarized into Ax-with-better-kicker (AK/AQ) and air." |
| `pf_btn_v_bb_srp_100bb_turn_JdTd5s_2c_m4_reason_As9s_v432` | polarized line | "2c is a polar brick." |
| `pf_btn_v_bb_srp_100bb_turn_9s8d4c_7h_m4_reason_5h5d_v432` | polarized line | "Turn 7 lands the straight on the BB-favored side and brings villain barrel range toward polar (T-high made or air)." |
| `pf_btn_v_bb_srp_100bb_turn_7s5d3h_4c_m4_action_JsTs_v432` | polarized line | "Villain barrel range is polarized (made-straight value vs air)." |
| `pf_btn_v_bb_srp_100bb_turn_Qs7d3c_3h_m4_action_8d8c_v432` | polarized line | "The mix tension: bluff-catch the polarized barrel vs accept that 88 is too weak vs the value cluster." |
| `pf_btn_v_bb_srp_100bb_turn_Kd8s3c_8h_m4_action_AsTd_v432` | polarized line | "Small check-raise leverages the polar shift toward villain having either a turned trips combo OR air" |
| `pf_btn_v_bb_srp_100bb_river_Ks9d4c_7s_m5_action_KdQh_v440` | polarized line | "BTN bets a medium river polarized into value Kx-strong / sets / overpairs and busted barrel-bluffs; KQ beats every bluff and every worse Kx." |
| `pf_btn_v_bb_srp_100bb_river_Ks9d4c_7s_m5_action_9c9h_v440` | **[LIST-SUPPRESSED]** (was: merged / thin-value line) | "The brick means villain still has thin value (Kx) that calls a small raise." — sentence describes villain's continue-vs-raise range, not the betting line; in `_PF_REVEAL_SUPPRESS`, chip never fires |
| `pf_btn_v_bb_srp_100bb_river_Ks9d4c_7s_m5_reason_AhKc_v440` | polarized line | "The 7s brick keeps villain polar." |
| `pf_btn_v_bb_srp_100bb_river_Js8d5c_Ac_m5_action_KcJd_v440` | polarized · value-lean | "Vs a pot-sized polar bet it is below the bluff-catch threshold." |
| `pf_btn_v_bb_srp_100bb_river_Js8d5c_Ac_m5_action_AdTh_v440` | value-heavy line | "Against a value-heavy A-high pot bet, though, weak top pair is right at indifference: solver mixes call and fold." |
| `pf_btn_v_bb_srp_100bb_river_Js8d5c_Ac_m5_reason_KhQd_v440` | value-heavy line | "The Ac favors BTN heavily and the pot-sized bet is value-weighted." |
| `pf_btn_v_bb_srp_100bb_river_Qh9h4c_7h_m5_action_KhJh_v440` | polarized line | "Vs a pot-sized polar bet this flush beats every non-flush value bet and every bluff, but it is NOT the nuts" |
| `pf_btn_v_bb_srp_100bb_river_Kd7s3c_7d_m5_action_KhJc_v440` | merged / thin-value line | "The small sizing screams thin value / give-ups; folding top pair here lets villain auto-profit by betting small with any two." |
| `pf_btn_v_bb_srp_100bb_river_Kd7s3c_7d_m5_action_QcJd_v440` | bluff-heavy line | "The river barrel range at 33% is bluff-heavy because villain bets small to deny equity cheaply or to value-bet thin; second pair is comfortably above the call threshold." |
| `pf_btn_v_bb_srp_100bb_river_Kd7s3c_7d_m5_action_7h6h_v440` | merged / thin-value line | "Villain bet small with thin value and give-ups" |
| `pf_btn_v_bb_srp_100bb_river_Ad8s5c_Kd_m5_action_AhQc_v440` | polarized line | "The Kd is the second overcard; villain's overbet (~150% pot, BB needs ~37.5%) is polar" |
| `pf_btn_v_bb_srp_100bb_river_Ad8s5c_Kd_m5_action_8c8h_v440` | polarized line | "The Kd is a scare card; vs a polar overbet villain holds either the nuts (AA, KK, or 55/22 sets) or busted bluffs." |
| `pf_btn_v_bb_srp_100bb_river_Ad8s5c_Kd_m5_action_QdJd_v440` | polarized line | "Vs a polar overbet it can only bluff-raise or fold." |
| `pf_btn_v_bb_srp_100bb_river_Ad8s5c_Kd_m5_reason_AhJc_v440` | polarized line | "The Kd overbet (~150% pot, BB needs ~37.5%) is polar: AK/sets/AA-KK for value, busted draws as bluffs." |
| `pf_btn_v_bb_srp_100bb_river_Ac7d4s_2c_m5_action_8d8c_v441a` | bluff-heavy line | "At about a third of pot BTN can bet a wide, bluff-heavy range, so the small price (about 4-to-1) is the whole story." |
| `pf_btn_v_bb_srp_100bb_river_Ac7d4s_2c_m5_action_AsQc_v441a` | **[NEG-SUPPRESSED]** polarized line | "Holds the As (blocks some AK/AQ value) and the Qc; a strong top pair that must not be folded to a polar bet." |
| `pf_btn_v_bb_srp_100bb_river_Ac7d4s_2c_m5_action_AsQc_v441a` | polarized line | "A pot-sized bet is polar" |
| `pf_btn_v_bb_srp_100bb_river_Kh9h5c_2h_m5_action_AhJc_v441a` | polarized line | "BTN bets a large polar range: made flushes and strong hands for value, plus busted hearts as bluffs." |
| `pf_btn_v_bb_srp_100bb_river_Kh9h5c_2h_m5_action_KcTd_v441a` | polarized line | "The 2h completes the flush, so BTN large bet is polar: flushes and better for value, busted hearts as bluffs." |
