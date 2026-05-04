# v4.0.7 - GPT Review Package (30 sample scenarios, post-micro-fix)

> Final pass before commit. Two micro-fixes applied to v4.0.7-template-correction:
>
> 1. **monotone_low nut_advantage wording**: removed false claim "BTN holds essentially zero nut combos"; new wording acknowledges BTN's Axs nut-flush combos.
> 2. **Solver-sensitive nut_advantage criticality**: paired_mid + monotone_low + monotone_high + mid_two_tone_dry + low_dry_two_tone now have ``preflop_raiser`` (or opposite) as ``bad`` rather than ``critical`` for nut_advantage. ``neutral`` is added to acceptable.

Stratified sample of 30 scenarios for final GPT review (5 easy + 10 medium + 10 hard + 5 highest-risk + 1 extra).

**Final corpus**: 251 Module 1 / 262 total postflop / audit 0 errors 0 warnings.

## How to use this package

> **"Is this ``best`` answer defensible under BTN open 2.5x vs BB call, 100BB SRP, NLH MTT chipEV?"**

Also check: texture tags, critical tier, commonMistake, difficulty, sourceConfidence, factual logic.

---

## Sample index

| # | id | qtype | suit | diff | sourceConfidence | reason |
|---|---|---|---|---|---|---|
| 1 | `pf_btn_v_bb_srp_100bb_flop_Ah7d2s_rangeadv_v407` | range_advantage | rainbow | 1 | consensus_gto | easy: A-high rainbow rangeAdv (textbook) |
| 2 | `pf_btn_v_bb_srp_100bb_flop_Kh7d2s_rangeadv_v407` | range_advantage | rainbow | 1 | consensus_gto | easy: K-high rainbow rangeAdv |
| 3 | `pf_btn_v_bb_srp_100bb_flop_AhAd7c_rangeadv_v407` | range_advantage | rainbow | 1 | consensus_gto | easy: paired board (high) |
| 4 | `pf_btn_v_bb_srp_100bb_flop_AdTc4h_dyn_v407` | dynamic_level | rainbow | 1 | consensus_gto | easy: dynamic_level static board |
| 5 | `pf_btn_v_bb_srp_100bb_flop_Ad8h6c_freq_v407` | frequency_strategy | rainbow | 1 | consensus_gto | easy: frequency_strategy on dry board |
| 6 | `pf_btn_v_bb_srp_100bb_flop_As9s4d_rangeadv_v407` | range_advantage | two_tone | 2 | consensus_gto | medium: A-high two-tone (high_two_tone_dry) |
| 7 | `pf_btn_v_bb_srp_100bb_flop_KhTh4d_freq_v407` | frequency_strategy | two_tone | 3 | expert_judgment | medium: K-high two-tone freq |
| 8 | `pf_btn_v_bb_srp_100bb_flop_9h9d4h_dyn_v407` | dynamic_level | two_tone | 2 | expert_judgment | medium: paired two-tone |
| 9 | `pf_btn_v_bb_srp_100bb_flop_Qh6c2d_nutadv_v407` | nut_advantage | rainbow | 2 | expert_judgment | medium: Q-high nut advantage |
| 10 | `pf_btn_v_bb_srp_100bb_flop_6h5d4c_rangeadv_v407` | range_advantage | rainbow | 2 | consensus_gto | medium: low-board rainbow rangeAdv |
| 11 | `pf_btn_v_bb_srp_100bb_flop_Jd5s3c_freq_v407` | frequency_strategy | rainbow | 3 | expert_judgment | medium: J-high rainbow |
| 12 | `pf_btn_v_bb_srp_100bb_flop_9c7c5d_rangeadv_v407` | range_advantage | two_tone | 2 | consensus_gto | medium: low two-tone rangeAdv (NEW correct template) |
| 13 | `pf_btn_v_bb_srp_100bb_flop_AsKhQd_dyn_v407` | dynamic_level | rainbow | 3 | consensus_gto | medium: dynamic_level on dynamic board |
| 14 | `pf_btn_v_bb_srp_100bb_flop_AhAc4d_nutadv_v407` | nut_advantage | rainbow | 2 | consensus_gto | medium: paired board nut adv (wording + soft critical) |
| 15 | `pf_btn_v_bb_srp_100bb_flop_Kh8h3h_sizing_v407` | sizing_family | monotone | 5 | expert_judgment | hard: monotone sizing |
| 16 | `pf_btn_v_bb_srp_100bb_flop_Ks7s2s_freq_v407` | frequency_strategy | monotone | 4 | expert_judgment | hard: monotone frequency |
| 17 | `pf_btn_v_bb_srp_100bb_flop_7s5s4d_sizing_v407` | sizing_family | two_tone | 5 | expert_judgment | hard: low_connected_two_tone sizing (NEW template) |
| 18 | `pf_btn_v_bb_srp_100bb_flop_Js9d4h_nutadv_v407` | nut_advantage | rainbow | 4 | expert_judgment | hard: nut adv on broadway-connected rainbow |
| 19 | `pf_btn_v_bb_srp_100bb_flop_9s7d6h_freq_v407` | frequency_strategy | rainbow | 5 | expert_judgment | hard: very-wet low connected rainbow |
| 20 | `pf_btn_v_bb_srp_100bb_flop_KsQsJh_nutadv_v407` | nut_advantage | two_tone | 4 | expert_judgment | hard: broadway_two_tone_connected (NEW template) |
| 21 | `pf_btn_v_bb_srp_100bb_flop_9s8s6h_sizing_v407` | sizing_family | two_tone | 5 | expert_judgment | hard: low two-tone sizing |
| 22 | `pf_btn_v_bb_srp_100bb_flop_Jh7d2s_rangeadv_v407` | range_advantage | rainbow | 4 | expert_judgment | hard: neutral range adv (paired_mid / J_T) |
| 23 | `pf_btn_v_bb_srp_100bb_flop_9c7c2c_nutadv_v407` | nut_advantage | monotone | 4 | expert_judgment | hard: low monotone |
| 24 | `pf_btn_v_bb_srp_100bb_flop_9c8c5h_freq_v407` | frequency_strategy | two_tone | 5 | expert_judgment | hard: two-tone wet freq |
| 25 | `pf_btn_v_bb_srp_100bb_flop_7d6d4d_sizing_v407` | sizing_family | monotone | 5 | expert_judgment | highest-risk: low monotone sizing (template-sensitive) |
| 26 | `pf_btn_v_bb_srp_100bb_flop_TsTh6d_nutadv_v407` | nut_advantage | rainbow | 2 | expert_judgment | highest-risk: paired_mid nut adv (wording + soft critical) |
| 27 | `pf_btn_v_bb_srp_100bb_flop_6h4h3s_sizing_v407` | sizing_family | two_tone | 5 | expert_judgment | highest-risk: low_connected_two_tone sizing |
| 28 | `pf_btn_v_bb_srp_100bb_flop_As7s2s_rangeadv_v407` | range_advantage | monotone | 4 | expert_judgment | highest-risk: A-high monotone rangeAdv (often called neutral) |
| 29 | `pf_btn_v_bb_srp_100bb_flop_QcJc6d_nutadv_v407` | nut_advantage | two_tone | 4 | expert_judgment | highest-risk: mid_two_tone_dry nut adv (NEW template, neutral) |
| 30 | `pf_btn_v_bb_srp_100bb_flop_Ah3h2s_sizing_v407` | sizing_family | two_tone | 4 | expert_judgment | extra: A-high two-tone sizing variation |

---

## Scenarios

### #1 :: pf_btn_v_bb_srp_100bb_flop_Ah7d2s_rangeadv_v407

**Reason for inclusion:** easy: A-high rainbow rangeAdv (textbook)

| Field | Value |
|---|---|
| Question type | range_advantage |
| Board | `Ah 7d 2s` |
| Family | A_high (rainbow, dyn 1) |
| Texture tags | ace_high_dry, disconnected, dry, high_card_dominant, rainbow |
| Range adv | preflop_raiser |
| Nut adv | preflop_raiser |
| Difficulty | 1 |
| Source confidence | **consensus_gto** |
| Audit status | approved |

**Prompt:** On A♥ 7♦ 2♠ (BTN open vs BB call, 100BB SRP), who has range advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral / split
  - `split` - Split

**Best:** `preflop_raiser`  
**Critical:** `caller`  

**Short:** BTN. Range tilts toward the raiser on this board class.

**Range logic:** BTN open contains far more A-x and broadway combos than BB's preflop call range. BB 3-bets dominant A-x (AJo+, AQ, AK), removing them from BB's flatting range. BTN clearly range-advantaged.

**Common mistake:** Some players go big or polar on A-high dry boards - that's a major leak. Solver: small high-frequency wins.

**Concept tags:** board_texture_recognition, dry_board, dry_high_card_strategy, range_advantage

---

### #2 :: pf_btn_v_bb_srp_100bb_flop_Kh7d2s_rangeadv_v407

**Reason for inclusion:** easy: K-high rainbow rangeAdv

| Field | Value |
|---|---|
| Question type | range_advantage |
| Board | `Kh 7d 2s` |
| Family | K_high (rainbow, dyn 1) |
| Texture tags | disconnected, dry, high_card_dominant, rainbow |
| Range adv | preflop_raiser |
| Nut adv | preflop_raiser |
| Difficulty | 1 |
| Source confidence | **consensus_gto** |
| Audit status | approved |

**Prompt:** On K♥ 7♦ 2♠ (BTN open vs BB call, 100BB SRP), who has range advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral / split
  - `split` - Split

**Best:** `preflop_raiser`  
**Critical:** `caller`  

**Short:** BTN. Range tilts toward the raiser on this board class.

**Range logic:** BTN open is K-x heavy (KQ, KJ, KT, K9s, etc.). BB 3-bets KQs/KQo, AK, KK at high frequency, so BB's call range under-represents top-K combos. BTN range-advantaged.

**Common mistake:** Big polar sizings here are a leak; range advantage and lack of draws favor small high-freq.

**Concept tags:** board_texture_recognition, dry_board, dry_high_card_strategy, range_advantage

---

### #3 :: pf_btn_v_bb_srp_100bb_flop_AhAd7c_rangeadv_v407

**Reason for inclusion:** easy: paired board (high)

| Field | Value |
|---|---|
| Question type | range_advantage |
| Board | `Ah Ad 7c` |
| Family | A_high (rainbow, dyn 1) |
| Texture tags | high_card_dominant, paired, rainbow |
| Range adv | preflop_raiser |
| Nut adv | preflop_raiser |
| Difficulty | 1 |
| Source confidence | **consensus_gto** |
| Audit status | approved |

**Prompt:** On A♥ A♦ 7♣ (BTN open vs BB call, 100BB SRP), who has range advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral / split
  - `split` - Split

**Best:** `preflop_raiser`  
**Critical:** `caller`  

**Short:** BTN. Range tilts toward the raiser on this board class.

**Range logic:** BTN open is K/Q/J/A-x heavy, so BTN has more trip combos (e.g., AK/AJ on AAx; KQ/KJ on KKx). BB 3-bets these dominant kickers preflop, further increasing BTN's trips advantage.

**Common mistake:** Checking back too often on paired high boards costs value - most of BTN's range is ahead of BB's calling range.

**Concept tags:** board_texture_recognition, paired_board_strategy, range_advantage

---

### #4 :: pf_btn_v_bb_srp_100bb_flop_AdTc4h_dyn_v407

**Reason for inclusion:** easy: dynamic_level static board

| Field | Value |
|---|---|
| Question type | dynamic_level |
| Board | `Ad Tc 4h` |
| Family | A_high (rainbow, dyn 1) |
| Texture tags | ace_high_dry, disconnected, dry, high_card_dominant, rainbow |
| Range adv | preflop_raiser |
| Nut adv | preflop_raiser |
| Difficulty | 1 |
| Source confidence | **consensus_gto** |
| Audit status | approved |

**Prompt:** On A♦ T♣ 4♥, what is the dynamic level?

**Choices:**
  - `static` - Static
  - `semi_static` - Semi-static
  - `dynamic` - Dynamic
  - `very_dynamic` - Very dynamic

**Best:** `static`  
**Acceptable:** `semi_static`  
**Critical:** (none - solver-sensitive family)  

**Short:** Dynamic level: static. Static / semi-static - A-high dry boards rarely shift equity rankings dramatically except on board-pair turns.

**Sizing logic:** Static / semi-static - A-high dry boards rarely shift equity rankings dramatically except on board-pair turns.

**Common mistake:** Some players go big or polar on A-high dry boards - that's a major leak. Solver: small high-frequency wins.

**Concept tags:** board_texture_recognition, dry_board, dry_high_card_strategy, static_board

---

### #5 :: pf_btn_v_bb_srp_100bb_flop_Ad8h6c_freq_v407

**Reason for inclusion:** easy: frequency_strategy on dry board

| Field | Value |
|---|---|
| Question type | frequency_strategy |
| Board | `Ad 8h 6c` |
| Family | A_high (rainbow, dyn 1) |
| Texture tags | ace_high_dry, disconnected, dry, high_card_dominant, rainbow |
| Range adv | preflop_raiser |
| Nut adv | preflop_raiser |
| Difficulty | 1 |
| Source confidence | **consensus_gto** |
| Audit status | approved |

**Prompt:** On A♦ 8♥ 6♣, what is the optimal c-bet frequency family for BTN?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `range_small`  
**Acceptable:** `mixed_small_check`  
**Critical:** `check_heavy, polar_big`  

**Short:** Sizing family: range_small. Range-small: bet 33% with ~80%+ frequency. Dry, range-advantaged board with no d...

**Range logic:** BTN open contains far more A-x and broadway combos than BB's preflop call range. BB 3-bets dominant A-x (AJo+, AQ, AK), removing them from BB's flatting range. BTN clearly range-advantaged.

**Sizing logic:** Range-small: bet 33% with ~80%+ frequency. Dry, range-advantaged board with no draws to charge - small bet extracts thin value, denies equity to air, and scales the pot.

**Common mistake:** Some players go big or polar on A-high dry boards - that's a major leak. Solver: small high-frequency wins.

**Concept tags:** board_texture_recognition, dry_board, dry_high_card_strategy, small_cbet_freq

---

### #6 :: pf_btn_v_bb_srp_100bb_flop_As9s4d_rangeadv_v407

**Reason for inclusion:** medium: A-high two-tone (high_two_tone_dry)

| Field | Value |
|---|---|
| Question type | range_advantage |
| Board | `As 9s 4d` |
| Family | A_high (two_tone, dyn 2) |
| Texture tags | ace_high_wet, disconnected, flushing, high_card_dominant, semi_dry, two_tone |
| Range adv | preflop_raiser |
| Nut adv | preflop_raiser |
| Difficulty | 2 |
| Source confidence | **consensus_gto** |
| Audit status | approved |

**Prompt:** On A♠ 9♠ 4♦ (BTN open vs BB call, 100BB SRP), who has range advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral / split
  - `split` - Split

**Best:** `preflop_raiser`  
**Critical:** `caller`  

**Short:** BTN. Range tilts toward the raiser on this board class.

**Range logic:** A-high or K-high two-tone disconnected board. BTN open carries far more A-x and K-x combos than BB's preflop call range, and BB 3-bets dominant top-pair combos preflop. Range advantage clearly BTN.

**Common mistake:** Treating two-tone exactly like rainbow (range-small always) misses value vs. BB's flush draws; check-heavy concedes the board to BB unnecessarily.

**Concept tags:** board_texture_recognition, dry_high_card_strategy, range_advantage, two_tone_board_strategy

---

### #7 :: pf_btn_v_bb_srp_100bb_flop_KhTh4d_freq_v407

**Reason for inclusion:** medium: K-high two-tone freq

| Field | Value |
|---|---|
| Question type | frequency_strategy |
| Board | `Kh Th 4d` |
| Family | K_high (two_tone, dyn 2) |
| Texture tags | disconnected, flushing, high_card_dominant, semi_dry, two_tone |
| Range adv | preflop_raiser |
| Nut adv | preflop_raiser |
| Difficulty | 3 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On K♥ T♥ 4♦, what is the optimal c-bet frequency family for BTN?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `mixed_small_check`  
**Acceptable:** `range_small`  
**Critical:** `check_heavy`  

**Short:** Sizing family: mixed_small_check. Mixed small/check: bet ~33-50% with ~60-70% frequency. Slightly more polarized t...

**Range logic:** A-high or K-high two-tone disconnected board. BTN open carries far more A-x and K-x combos than BB's preflop call range, and BB 3-bets dominant top-pair combos preflop. Range advantage clearly BTN.

**Sizing logic:** Mixed small/check: bet ~33-50% with ~60-70% frequency. Slightly more polarized than rainbow because BB has flush draws to charge. Range_small is also defensible on the dryer end (A-x-x with low x).

**Common mistake:** Treating two-tone exactly like rainbow (range-small always) misses value vs. BB's flush draws; check-heavy concedes the board to BB unnecessarily.

**Concept tags:** board_texture_recognition, dry_high_card_strategy, mixed_small_check, small_cbet_freq, two_tone_board_strategy

---

### #8 :: pf_btn_v_bb_srp_100bb_flop_9h9d4h_dyn_v407

**Reason for inclusion:** medium: paired two-tone

| Field | Value |
|---|---|
| Question type | dynamic_level |
| Board | `9h 9d 4h` |
| Family | low (two_tone, dyn 2) |
| Texture tags | middle_heavy, paired, two_tone |
| Range adv | neutral |
| Nut adv | caller |
| Difficulty | 2 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On 9♥ 9♦ 4♥, what is the dynamic level?

**Choices:**
  - `static` - Static
  - `semi_static` - Semi-static
  - `dynamic` - Dynamic
  - `very_dynamic` - Very dynamic

**Best:** `semi_static`  
**Acceptable:** `static, dynamic`  
**Critical:** (none - solver-sensitive family)  

**Short:** Dynamic level: semi_static. Semi-static - overcard turns can devalue overpairs on middle paired boards.

**Sizing logic:** Semi-static - overcard turns can devalue overpairs on middle paired boards.

**Common mistake:** Auto-betting paired boards regardless of rank is a leak - middle pairs flip the trips density.

**Concept tags:** board_texture_recognition, paired_board_strategy, static_board

---

### #9 :: pf_btn_v_bb_srp_100bb_flop_Qh6c2d_nutadv_v407

**Reason for inclusion:** medium: Q-high nut advantage

| Field | Value |
|---|---|
| Question type | nut_advantage |
| Board | `Qh 6c 2d` |
| Family | Q_high (rainbow, dyn 1) |
| Texture tags | disconnected, dry, high_card_dominant, rainbow |
| Range adv | preflop_raiser |
| Nut adv | preflop_raiser |
| Difficulty | 2 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On Q♥ 6♣ 2♦, who has nut advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral
  - `split` - Split

**Best:** `preflop_raiser`  
**Critical:** `caller`  

**Short:** BTN. Top of range (overpairs, top-kicker, sets) lives in the raiser preflop range.

**Nut logic:** QQ, AQ, KQ are higher-frequency in BTN's open; BB removes many via 3-bet. Set advantage to BTN, though the gap is smaller than on A/K-high boards.

**Common mistake:** Treating Q-high dry exactly like A-high (always small-bet) loses some EV; mixed approach is closer to optimal.

**Concept tags:** board_texture_recognition, dry_board, nut_advantage

---

### #10 :: pf_btn_v_bb_srp_100bb_flop_6h5d4c_rangeadv_v407

**Reason for inclusion:** medium: low-board rainbow rangeAdv

| Field | Value |
|---|---|
| Question type | range_advantage |
| Board | `6h 5d 4c` |
| Family | low (rainbow, dyn 4) |
| Texture tags | highly_connected, low_connected, low_heavy, rainbow, straightening, very_wet, wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 2 |
| Source confidence | **consensus_gto** |
| Audit status | approved |

**Prompt:** On 6♥ 5♦ 4♣ (BTN open vs BB call, 100BB SRP), who has range advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral / split
  - `split` - Split

**Best:** `caller`  
**Critical:** `preflop_raiser`  

**Short:** BB. Range tilts toward the caller - connectors and small pairs hit harder.

**Range logic:** Low connected boards (8-7-5, 6-5-4) heavily favor BB's flatting range (small pairs, suited connectors). BTN's overpairs are no longer best.

**Common mistake:** C-betting these boards 'because I raised' is the most common postflop leak in MTT play.

**Concept tags:** board_texture_recognition, common_leaks, dynamic_board, low_connected_caution, range_advantage, wet_board

---

### #11 :: pf_btn_v_bb_srp_100bb_flop_Jd5s3c_freq_v407

**Reason for inclusion:** medium: J-high rainbow

| Field | Value |
|---|---|
| Question type | frequency_strategy |
| Board | `Jd 5s 3c` |
| Family | J_high (rainbow, dyn 2) |
| Texture tags | disconnected, middle_heavy, rainbow, semi_dry |
| Range adv | neutral |
| Nut adv | neutral |
| Difficulty | 3 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On J♦ 5♠ 3♣, what is the optimal c-bet frequency family for BTN?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `mixed_small_check`  
**Acceptable:** `range_small, check_heavy`  
**Critical:** `polar_big`  

**Short:** Sizing family: mixed_small_check. Mixed small/check: ~50% small bet, ~50% check. Without strong range advantage, p...

**Range logic:** BTN open includes J-x and T-x but BB calls a lot of suited connectors and middle pocket pairs that connect with this board. Range advantage shifts toward neutral.

**Sizing logic:** Mixed small/check: ~50% small bet, ~50% check. Without strong range advantage, polar betting wastes nut combos.

**Common mistake:** Always c-betting J-high middle boards is a leak - checking ~half the range protects against being raised by BB's draws.

**Concept tags:** board_texture_recognition, mixed_small_check, small_cbet_freq

---

### #12 :: pf_btn_v_bb_srp_100bb_flop_9c7c5d_rangeadv_v407

**Reason for inclusion:** medium: low two-tone rangeAdv (NEW correct template)

| Field | Value |
|---|---|
| Question type | range_advantage |
| Board | `9c 7c 5d` |
| Family | low (two_tone, dyn 4) |
| Texture tags | flushing, highly_connected, low_connected, low_heavy, straightening, two_tone, very_wet, wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 2 |
| Source confidence | **consensus_gto** |
| Audit status | approved |

**Prompt:** On 9♣ 7♣ 5♦ (BTN open vs BB call, 100BB SRP), who has range advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral / split
  - `split` - Split

**Best:** `caller`  
**Critical:** `preflop_raiser`  

**Short:** BB. Range tilts toward the caller - connectors and small pairs hit harder.

**Range logic:** Low connected two-tone board (8-7-x suited, 9-8-x suited, T-9-x with low x and two of a suit). BB's flatting range is full of suited connectors (76s, 87s, 98s, T9s, 65s, 54s) that hit top pair, two-pair, sets, straights, AND flush draws on the suit. BTN's overpairs are bluff-catchers.

**Common mistake:** C-betting low connected two-tone with range-small is one of the biggest postflop leaks in MTT play. Check this board the majority of the time.

**Concept tags:** board_texture_recognition, common_leaks, dynamic_board, low_connected_caution, range_advantage, two_tone_board_strategy, wet_board

---

### #13 :: pf_btn_v_bb_srp_100bb_flop_AsKhQd_dyn_v407

**Reason for inclusion:** medium: dynamic_level on dynamic board

| Field | Value |
|---|---|
| Question type | dynamic_level |
| Board | `As Kh Qd` |
| Family | A_high (rainbow, dyn 3) |
| Texture tags | broadway_heavy, highly_connected, rainbow, straightening, wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 3 |
| Source confidence | **consensus_gto** |
| Audit status | approved |

**Prompt:** On A♠ K♥ Q♦, what is the dynamic level?

**Choices:**
  - `static` - Static
  - `semi_static` - Semi-static
  - `dynamic` - Dynamic
  - `very_dynamic` - Very dynamic

**Best:** `dynamic`  
**Acceptable:** `semi_static, very_dynamic`  
**Critical:** (none - solver-sensitive family)  

**Short:** Dynamic level: dynamic. Very dynamic - straightening turn cards swing equity dramatically.

**Sizing logic:** Very dynamic - straightening turn cards swing equity dramatically.

**Common mistake:** Big polar sizing (75%+) on broadway-connected boards burns through BTN's marginal hands without folding out BB's straight and two-pair combos.

**Concept tags:** board_texture_recognition, common_leaks, dynamic_board, low_connected_caution, wet_board

---

### #14 :: pf_btn_v_bb_srp_100bb_flop_AhAc4d_nutadv_v407

**Reason for inclusion:** medium: paired board nut adv (wording + soft critical)

| Field | Value |
|---|---|
| Question type | nut_advantage |
| Board | `Ah Ac 4d` |
| Family | A_high (rainbow, dyn 1) |
| Texture tags | high_card_dominant, paired, rainbow |
| Range adv | preflop_raiser |
| Nut adv | preflop_raiser |
| Difficulty | 2 |
| Source confidence | **consensus_gto** |
| Audit status | approved |

**Prompt:** On A♥ A♣ 4♦, who has nut advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral
  - `split` - Split

**Best:** `preflop_raiser`  
**Critical:** `caller`  

**Short:** BTN. Top of range (overpairs, top-kicker, sets) lives in the raiser preflop range.

**Nut logic:** Trips combos with strong kickers heavily concentrated in BTN open. BB has occasional trips (suited K-x flatted) but far fewer.

**Common mistake:** Checking back too often on paired high boards costs value - most of BTN's range is ahead of BB's calling range.

**Concept tags:** board_texture_recognition, nut_advantage, paired_board_strategy

---

### #15 :: pf_btn_v_bb_srp_100bb_flop_Kh8h3h_sizing_v407

**Reason for inclusion:** hard: monotone sizing

| Field | Value |
|---|---|
| Question type | sizing_family |
| Board | `Kh 8h 3h` |
| Family | K_high (monotone, dyn 2) |
| Texture tags | flushing, high_card_dominant, monotone, semi_dry |
| Range adv | neutral |
| Nut adv | preflop_raiser |
| Difficulty | 5 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On K♥ 8♥ 3♥, what sizing family does BTN use most?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `check_heavy`  
**Acceptable:** `mixed_small_check`  
**Critical:** `polar_big, range_small`  

**Short:** Sizing family: check_heavy. Check-heavy: check ~50-70%. When betting, use small (33%) - flushes are already ...

**Sizing logic:** Check-heavy: check ~50-70%. When betting, use small (33%) - flushes are already made, so big bluffs are inefficient.

**Common mistake:** Over-betting monotone boards is a leak - many of opponent's continuing hands are already flushes, and your bluffs have minimal fold equity.

**Concept tags:** board_texture_recognition, cbet_size_selection, check_strategy, monotone_board_strategy, wet_board

---

### #16 :: pf_btn_v_bb_srp_100bb_flop_Ks7s2s_freq_v407

**Reason for inclusion:** hard: monotone frequency

| Field | Value |
|---|---|
| Question type | frequency_strategy |
| Board | `Ks 7s 2s` |
| Family | K_high (monotone, dyn 2) |
| Texture tags | flushing, high_card_dominant, monotone, semi_dry |
| Range adv | neutral |
| Nut adv | preflop_raiser |
| Difficulty | 4 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On K♠ 7♠ 2♠, what is the optimal c-bet frequency family for BTN?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `check_heavy`  
**Acceptable:** `mixed_small_check`  
**Critical:** `polar_big, range_small`  

**Short:** Sizing family: check_heavy. Check-heavy: check ~50-70%. When betting, use small (33%) - flushes are already ...

**Range logic:** Monotone high boards split range advantage close to neutral. BB has many suited Broadway combos that contain a flush already; BTN has more high cards but fewer flush combos.

**Sizing logic:** Check-heavy: check ~50-70%. When betting, use small (33%) - flushes are already made, so big bluffs are inefficient.

**Common mistake:** Over-betting monotone boards is a leak - many of opponent's continuing hands are already flushes, and your bluffs have minimal fold equity.

**Concept tags:** board_texture_recognition, check_strategy, low_connected_caution, monotone_board_strategy, wet_board

---

### #17 :: pf_btn_v_bb_srp_100bb_flop_7s5s4d_sizing_v407

**Reason for inclusion:** hard: low_connected_two_tone sizing (NEW template)

| Field | Value |
|---|---|
| Question type | sizing_family |
| Board | `7s 5s 4d` |
| Family | low (two_tone, dyn 4) |
| Texture tags | flushing, highly_connected, low_connected, low_heavy, straightening, two_tone, very_wet, wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 5 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On 7♠ 5♠ 4♦, what sizing family does BTN use most?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `check_heavy`  
**Acceptable:** `mixed_small_check, polar_big`  
**Critical:** `range_small`  

**Short:** Sizing family: check_heavy. Check-heavy: check ~65-75% of range. When betting, polar big (75%+) only with ov...

**Sizing logic:** Check-heavy: check ~65-75% of range. When betting, polar big (75%+) only with overpairs + best draws. Range-small is a textbook leak - doesn't fold out BB's many straight + flush combos.

**Common mistake:** C-betting low connected two-tone with range-small is one of the biggest postflop leaks in MTT play. Check this board the majority of the time.

**Concept tags:** board_texture_recognition, cbet_size_selection, check_strategy, common_leaks, dynamic_board, low_connected_caution, two_tone_board_strategy, wet_board

---

### #18 :: pf_btn_v_bb_srp_100bb_flop_Js9d4h_nutadv_v407

**Reason for inclusion:** hard: nut adv on broadway-connected rainbow

| Field | Value |
|---|---|
| Question type | nut_advantage |
| Board | `Js 9d 4h` |
| Family | J_high (rainbow, dyn 3) |
| Texture tags | disconnected, middle_heavy, rainbow, semi_dry |
| Range adv | neutral |
| Nut adv | neutral |
| Difficulty | 4 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On J♠ 9♦ 4♥, who has nut advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral
  - `split` - Split

**Best:** `neutral`  
**Critical:** (none - solver-sensitive family)  

**Short:** Roughly neutral - nut combos split between ranges.

**Nut logic:** Sets of J/T/9 distributed similarly between ranges; BB's flatting range has slightly more straight equity. Nut advantage close to neutral.

**Common mistake:** Always c-betting J-high middle boards is a leak - checking ~half the range protects against being raised by BB's draws.

**Concept tags:** board_texture_recognition, nut_advantage

---

### #19 :: pf_btn_v_bb_srp_100bb_flop_9s7d6h_freq_v407

**Reason for inclusion:** hard: very-wet low connected rainbow

| Field | Value |
|---|---|
| Question type | frequency_strategy |
| Board | `9s 7d 6h` |
| Family | low (rainbow, dyn 4) |
| Texture tags | connected, rainbow, straightening, very_wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 5 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On 9♠ 7♦ 6♥, what is the optimal c-bet frequency family for BTN?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `check_heavy`  
**Acceptable:** `mixed_small_check, polar_big`  
**Critical:** `range_small`  

**Short:** Sizing family: check_heavy. Check-heavy: check ~60-70%. When betting, use polar big with the few nut combos ...

**Range logic:** Very wet boards (T-9-8, J-9-8) are loaded with draws and made hands for the caller. BTN's range has overpairs and overcards but minimal nutted combos.

**Sizing logic:** Check-heavy: check ~60-70%. When betting, use polar big with the few nut combos + best draws.

**Common mistake:** Range-bet small on very wet boards is a leak - small bet doesn't charge BB's many draws and gets raised often.

**Concept tags:** board_texture_recognition, check_strategy, common_leaks, dynamic_board, low_connected_caution, wet_board

---

### #20 :: pf_btn_v_bb_srp_100bb_flop_KsQsJh_nutadv_v407

**Reason for inclusion:** hard: broadway_two_tone_connected (NEW template)

| Field | Value |
|---|---|
| Question type | nut_advantage |
| Board | `Ks Qs Jh` |
| Family | K_high (two_tone, dyn 4) |
| Texture tags | broadway_heavy, flushing, highly_connected, straightening, two_tone, very_wet, wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 4 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On K♠ Q♠ J♥, who has nut advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral
  - `split` - Split

**Best:** `caller`  
**Critical:** `preflop_raiser`  

**Short:** BB. Sets, straights, and two-pair combos concentrate in the caller flatting range.

**Nut logic:** Made straights, two-pair combos, and combo draws are concentrated in BB's range. BTN's AK/KQ block some BB combos but don't outrun BB's nutted region. Adding flush completions to many BB hands further shifts nuts to BB.

**Common mistake:** Range-small on broadway-connected two-tone is a major leak; BB's range hits this board with two-pair, sets, straights, and flush draws.

**Concept tags:** board_texture_recognition, common_leaks, dynamic_board, low_connected_caution, nut_advantage, two_tone_board_strategy, wet_board

---

### #21 :: pf_btn_v_bb_srp_100bb_flop_9s8s6h_sizing_v407

**Reason for inclusion:** hard: low two-tone sizing

| Field | Value |
|---|---|
| Question type | sizing_family |
| Board | `9s 8s 6h` |
| Family | low (two_tone, dyn 4) |
| Texture tags | flushing, highly_connected, low_connected, low_heavy, straightening, two_tone, very_wet, wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 5 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On 9♠ 8♠ 6♥, what sizing family does BTN use most?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `check_heavy`  
**Acceptable:** `mixed_small_check, polar_big`  
**Critical:** `range_small`  

**Short:** Sizing family: check_heavy. Check-heavy: check ~65-75% of range. When betting, polar big (75%+) only with ov...

**Sizing logic:** Check-heavy: check ~65-75% of range. When betting, polar big (75%+) only with overpairs + best draws. Range-small is a textbook leak - doesn't fold out BB's many straight + flush combos.

**Common mistake:** C-betting low connected two-tone with range-small is one of the biggest postflop leaks in MTT play. Check this board the majority of the time.

**Concept tags:** board_texture_recognition, cbet_size_selection, check_strategy, common_leaks, dynamic_board, low_connected_caution, two_tone_board_strategy, wet_board

---

### #22 :: pf_btn_v_bb_srp_100bb_flop_Jh7d2s_rangeadv_v407

**Reason for inclusion:** hard: neutral range adv (paired_mid / J_T)

| Field | Value |
|---|---|
| Question type | range_advantage |
| Board | `Jh 7d 2s` |
| Family | J_high (rainbow, dyn 2) |
| Texture tags | disconnected, middle_heavy, rainbow, semi_dry |
| Range adv | neutral |
| Nut adv | neutral |
| Difficulty | 4 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On J♥ 7♦ 2♠ (BTN open vs BB call, 100BB SRP), who has range advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral / split
  - `split` - Split

**Best:** `neutral`  
**Acceptable:** `split`  
**Critical:** (none - solver-sensitive family)  

**Short:** Roughly neutral - neither range hits this board significantly harder.

**Range logic:** BTN open includes J-x and T-x but BB calls a lot of suited connectors and middle pocket pairs that connect with this board. Range advantage shifts toward neutral.

**Common mistake:** Always c-betting J-high middle boards is a leak - checking ~half the range protects against being raised by BB's draws.

**Concept tags:** board_texture_recognition, range_advantage

---

### #23 :: pf_btn_v_bb_srp_100bb_flop_9c7c2c_nutadv_v407

**Reason for inclusion:** hard: low monotone

| Field | Value |
|---|---|
| Question type | nut_advantage |
| Board | `9c 7c 2c` |
| Family | low (monotone, dyn 3) |
| Texture tags | flushing, low_heavy, monotone, wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 4 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On 9♣ 7♣ 2♣, who has nut advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral
  - `split` - Split

**Best:** `caller`  
**Acceptable:** `neutral`  
**Critical:** (none - solver-sensitive family)  

**Short:** BB. Sets, straights, and two-pair combos concentrate in the caller flatting range.

**Nut logic:** BB can have higher made-flush density and more low suited connector coverage, but BTN still retains meaningful Axs nut-flush combos on the suited card. The caller edge comes from overall flush / low-connected density, not from BTN having zero nut combos. This is a solver-sensitive spot - the magnitude of the caller edge depends heavily on the specific board.

**Common mistake:** Big bluffs on low monotone boards lose to BB's flopped flushes and combo draws - disaster spot to spew.

**Concept tags:** board_texture_recognition, common_leaks, monotone_board_strategy, nut_advantage, wet_board

---

### #24 :: pf_btn_v_bb_srp_100bb_flop_9c8c5h_freq_v407

**Reason for inclusion:** hard: two-tone wet freq

| Field | Value |
|---|---|
| Question type | frequency_strategy |
| Board | `9c 8c 5h` |
| Family | low (two_tone, dyn 4) |
| Texture tags | flushing, highly_connected, low_connected, low_heavy, straightening, two_tone, very_wet, wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 5 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On 9♣ 8♣ 5♥, what is the optimal c-bet frequency family for BTN?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `check_heavy`  
**Acceptable:** `mixed_small_check, polar_big`  
**Critical:** `range_small`  

**Short:** Sizing family: check_heavy. Check-heavy: check ~65-75% of range. When betting, polar big (75%+) only with ov...

**Range logic:** Low connected two-tone board (8-7-x suited, 9-8-x suited, T-9-x with low x and two of a suit). BB's flatting range is full of suited connectors (76s, 87s, 98s, T9s, 65s, 54s) that hit top pair, two-pair, sets, straights, AND flush draws on the suit. BTN's overpairs are bluff-catchers.

**Sizing logic:** Check-heavy: check ~65-75% of range. When betting, polar big (75%+) only with overpairs + best draws. Range-small is a textbook leak - doesn't fold out BB's many straight + flush combos.

**Common mistake:** C-betting low connected two-tone with range-small is one of the biggest postflop leaks in MTT play. Check this board the majority of the time.

**Concept tags:** board_texture_recognition, check_strategy, common_leaks, dynamic_board, low_connected_caution, two_tone_board_strategy, wet_board

---

### #25 :: pf_btn_v_bb_srp_100bb_flop_7d6d4d_sizing_v407

**Reason for inclusion:** highest-risk: low monotone sizing (template-sensitive)

| Field | Value |
|---|---|
| Question type | sizing_family |
| Board | `7d 6d 4d` |
| Family | low (monotone, dyn 4) |
| Texture tags | flushing, low_heavy, monotone, very_wet, wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 5 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On 7♦ 6♦ 4♦, what sizing family does BTN use most?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `check_heavy`  
**Acceptable:** `mixed_small_check`  
**Critical:** `polar_big, range_small`  

**Short:** Sizing family: check_heavy. Check-heavy: check ~70%+. Limit betting to occasional polar protection with over...

**Sizing logic:** Check-heavy: check ~70%+. Limit betting to occasional polar protection with overpairs + nut flush draws (Axs of suit).

**Common mistake:** Big bluffs on low monotone boards lose to BB's flopped flushes and combo draws - disaster spot to spew.

**Concept tags:** board_texture_recognition, cbet_size_selection, check_strategy, common_leaks, monotone_board_strategy, wet_board

---

### #26 :: pf_btn_v_bb_srp_100bb_flop_TsTh6d_nutadv_v407

**Reason for inclusion:** highest-risk: paired_mid nut adv (wording + soft critical)

| Field | Value |
|---|---|
| Question type | nut_advantage |
| Board | `Ts Th 6d` |
| Family | T_high (rainbow, dyn 2) |
| Texture tags | middle_heavy, paired, rainbow |
| Range adv | neutral |
| Nut adv | caller |
| Difficulty | 2 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On T♠ T♥ 6♦, who has nut advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral
  - `split` - Split

**Best:** `caller`  
**Acceptable:** `neutral`  
**Critical:** (none - solver-sensitive family)  

**Short:** BB. Sets, straights, and two-pair combos concentrate in the caller flatting range.

**Nut logic:** BB's flatting range contains more trips combos with the paired rank (e.g., 98s/T9s/J9s on 9-9-x give trips). BTN's overpairs (JJ-AA) are still strong but no longer top-of-range; the full-house region is roughly even but BB's trips density is higher.

**Common mistake:** Auto-betting paired boards regardless of rank is a leak - middle pairs flip the trips density.

**Concept tags:** board_texture_recognition, nut_advantage, paired_board_strategy

---

### #27 :: pf_btn_v_bb_srp_100bb_flop_6h4h3s_sizing_v407

**Reason for inclusion:** highest-risk: low_connected_two_tone sizing

| Field | Value |
|---|---|
| Question type | sizing_family |
| Board | `6h 4h 3s` |
| Family | low (two_tone, dyn 4) |
| Texture tags | flushing, highly_connected, low_connected, low_heavy, straightening, two_tone, very_wet, wet |
| Range adv | caller |
| Nut adv | caller |
| Difficulty | 5 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On 6♥ 4♥ 3♠, what sizing family does BTN use most?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `check_heavy`  
**Acceptable:** `mixed_small_check, polar_big`  
**Critical:** `range_small`  

**Short:** Sizing family: check_heavy. Check-heavy: check ~65-75% of range. When betting, polar big (75%+) only with ov...

**Sizing logic:** Check-heavy: check ~65-75% of range. When betting, polar big (75%+) only with overpairs + best draws. Range-small is a textbook leak - doesn't fold out BB's many straight + flush combos.

**Common mistake:** C-betting low connected two-tone with range-small is one of the biggest postflop leaks in MTT play. Check this board the majority of the time.

**Concept tags:** board_texture_recognition, cbet_size_selection, check_strategy, common_leaks, dynamic_board, low_connected_caution, two_tone_board_strategy, wet_board

---

### #28 :: pf_btn_v_bb_srp_100bb_flop_As7s2s_rangeadv_v407

**Reason for inclusion:** highest-risk: A-high monotone rangeAdv (often called neutral)

| Field | Value |
|---|---|
| Question type | range_advantage |
| Board | `As 7s 2s` |
| Family | A_high (monotone, dyn 2) |
| Texture tags | flushing, high_card_dominant, monotone, semi_dry |
| Range adv | neutral |
| Nut adv | preflop_raiser |
| Difficulty | 4 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On A♠ 7♠ 2♠ (BTN open vs BB call, 100BB SRP), who has range advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral / split
  - `split` - Split

**Best:** `neutral`  
**Acceptable:** `split`  
**Critical:** (none - solver-sensitive family)  

**Short:** Roughly neutral - neither range hits this board significantly harder.

**Range logic:** Monotone high boards split range advantage close to neutral. BB has many suited Broadway combos that contain a flush already; BTN has more high cards but fewer flush combos.

**Common mistake:** Over-betting monotone boards is a leak - many of opponent's continuing hands are already flushes, and your bluffs have minimal fold equity.

**Concept tags:** board_texture_recognition, monotone_board_strategy, range_advantage, wet_board

---

### #29 :: pf_btn_v_bb_srp_100bb_flop_QcJc6d_nutadv_v407

**Reason for inclusion:** highest-risk: mid_two_tone_dry nut adv (NEW template, neutral)

| Field | Value |
|---|---|
| Question type | nut_advantage |
| Board | `Qc Jc 6d` |
| Family | Q_high (two_tone, dyn 3) |
| Texture tags | disconnected, flushing, middle_heavy, semi_dry, two_tone |
| Range adv | neutral |
| Nut adv | neutral |
| Difficulty | 4 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On Q♣ J♣ 6♦, who has nut advantage?

**Choices:**
  - `preflop_raiser` - Preflop raiser (BTN)
  - `caller` - Caller (BB)
  - `neutral` - Neutral
  - `split` - Split

**Best:** `neutral`  
**Critical:** (none - solver-sensitive family)  

**Short:** Roughly neutral - nut combos split between ranges.

**Nut logic:** Both ranges have plausible top pairs and middle pairs. BB has more two-pair / set combos with the connected lower cards; BTN holds higher-kicker combos. Nut advantage roughly neutral.

**Common mistake:** Auto range-small on Q/J/T two-tone is a leak; this is not an A/K-high board.

**Concept tags:** board_texture_recognition, nut_advantage, two_tone_board_strategy

---

### #30 :: pf_btn_v_bb_srp_100bb_flop_Ah3h2s_sizing_v407

**Reason for inclusion:** extra: A-high two-tone sizing variation

| Field | Value |
|---|---|
| Question type | sizing_family |
| Board | `Ah 3h 2s` |
| Family | A_high (two_tone, dyn 2) |
| Texture tags | ace_high_wet, disconnected, flushing, high_card_dominant, semi_dry, two_tone |
| Range adv | preflop_raiser |
| Nut adv | preflop_raiser |
| Difficulty | 4 |
| Source confidence | **expert_judgment** |
| Audit status | approved |

**Prompt:** On A♥ 3♥ 2♠, what sizing family does BTN use most?

**Choices:**
  - `range_small` - Range small (33%, high freq)
  - `mixed_small_check` - Mixed small / check
  - `polar_big` - Polar big (75%+)
  - `check_heavy` - Check-heavy
  - `low_frequency` - Low frequency overall

**Best:** `mixed_small_check`  
**Acceptable:** `range_small`  
**Critical:** `check_heavy`  

**Short:** Sizing family: mixed_small_check. Mixed small/check: bet ~33-50% with ~60-70% frequency. Slightly more polarized t...

**Sizing logic:** Mixed small/check: bet ~33-50% with ~60-70% frequency. Slightly more polarized than rainbow because BB has flush draws to charge. Range_small is also defensible on the dryer end (A-x-x with low x).

**Common mistake:** Treating two-tone exactly like rainbow (range-small always) misses value vs. BB's flush draws; check-heavy concedes the board to BB unnecessarily.

**Concept tags:** board_texture_recognition, cbet_size_selection, dry_high_card_strategy, mixed_small_check, two_tone_board_strategy

---

## Scenarios most likely to be disputed by strong players

After the template-correction + micro-fix passes, the remaining risk categories (rank-ordered):

### 1. mid_two_tone_dry (Q/J/T-high two-tone disconnected, e.g., QcJc6d, KhTh4d)
- **Template:** ra=neutral, na=neutral (acceptable), sizing=mixed_small_check
- **Why disputed:** Boundary cases sensitive to specific kicker; solver mix can favor either side.

### 2. paired_mid nut_advantage (TsTh6d, 9h9d3c, 8h8d2c)
- **Template:** na=caller (acceptable: neutral; bad: preflop_raiser; **no critical**)
- **Why disputed:** Some pros prefer "neutral" because BTN overpair density partly offsets BB trips density. Soft critical tier reflects this.

### 3. monotone_low nut_advantage (9c7c2c, 8h6h4h)
- **Template:** na=caller (acceptable: neutral; bad: preflop_raiser; **no critical**). NEW wording acknowledges BTN's Axs nut-flush combos.
- **Why disputed:** Magnitude of caller edge varies by exact board.

### 4. low_dry_two_tone (9h6h2c, 8s4s2d)
- **Template:** ra=preflop_raiser, na=preflop_raiser (acceptable: neutral on nut_advantage; **no critical**)
- **Why disputed:** Some argue closer to neutral on wetter variants.

### 5. monotone_high A rangeAdv (As7s2s)
- **Template:** ra=neutral
- **Why disputed:** Some argue BTN still has range edge.

## Reviewer instruction

Beyond these 30, please pick 10-15 random additional ``*_v407`` scenarios and apply the same review checklist. **Final-pass focus**: verify the soft-critical fix landed on monotone_low + paired_mid + similar solver-sensitive nut_advantage scenarios.
