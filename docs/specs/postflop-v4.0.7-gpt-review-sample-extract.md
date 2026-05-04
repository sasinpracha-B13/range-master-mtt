# v4.0.7 - GPT Review Sample Extract (concise, post-micro-fix)

> Final pass: monotone_low + paired_mid solver-sensitive families now soften critical-tier on nut_advantage.
> One-line-per-sample summary of the 30 v4.0.7 GPT review scenarios.
> For full prompts, choices, explanations, and risk analysis see ``postflop-v4.0.7-gpt-review-package.md``.

**Total samples**: 30
**Coverage**: 5 easy (diff 1) + 10 medium (diff 2-3) + 10 hard (diff 4-5) + 5 highest-risk + 1 extra.
**Final corpus**: 251 Module 1 scenarios / 262 total postflop / audit 0 errors 0 warnings.

---

## Sample table

| # | id | board | family / suit | qtype | best | acceptable | critical | diff | confidence | reason |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `Ah7d2s_rangeadv_v407` | `Ah 7d 2s` | A_high / rainbow | range_advantage | preflop_raiser | - | caller | 1 | consensus_gto | easy: A-high rainbow rangeAdv (textbook) |
| 2 | `Kh7d2s_rangeadv_v407` | `Kh 7d 2s` | K_high / rainbow | range_advantage | preflop_raiser | - | caller | 1 | consensus_gto | easy: K-high rainbow rangeAdv |
| 3 | `AhAd7c_rangeadv_v407` | `Ah Ad 7c` | A_high / rainbow | range_advantage | preflop_raiser | - | caller | 1 | consensus_gto | easy: paired board (high) |
| 4 | `AdTc4h_dyn_v407` | `Ad Tc 4h` | A_high / rainbow | dynamic_level | static | semi_static | - | 1 | consensus_gto | easy: dynamic_level static board |
| 5 | `Ad8h6c_freq_v407` | `Ad 8h 6c` | A_high / rainbow | frequency_strategy | range_small | mixed_small_check | check_heavy, polar_big | 1 | consensus_gto | easy: frequency_strategy on dry board |
| 6 | `As9s4d_rangeadv_v407` | `As 9s 4d` | A_high / two_tone | range_advantage | preflop_raiser | - | caller | 2 | consensus_gto | medium: A-high two-tone (high_two_tone_dry) |
| 7 | `KhTh4d_freq_v407` | `Kh Th 4d` | K_high / two_tone | frequency_strategy | mixed_small_check | range_small | check_heavy | 3 | expert_judgment | medium: K-high two-tone freq |
| 8 | `9h9d4h_dyn_v407` | `9h 9d 4h` | low / two_tone | dynamic_level | semi_static | static, dynamic | - | 2 | expert_judgment | medium: paired two-tone |
| 9 | `Qh6c2d_nutadv_v407` | `Qh 6c 2d` | Q_high / rainbow | nut_advantage | preflop_raiser | - | caller | 2 | expert_judgment | medium: Q-high nut advantage |
| 10 | `6h5d4c_rangeadv_v407` | `6h 5d 4c` | low / rainbow | range_advantage | caller | - | preflop_raiser | 2 | consensus_gto | medium: low-board rainbow rangeAdv |
| 11 | `Jd5s3c_freq_v407` | `Jd 5s 3c` | J_high / rainbow | frequency_strategy | mixed_small_check | range_small, check_heavy | polar_big | 3 | expert_judgment | medium: J-high rainbow |
| 12 | `9c7c5d_rangeadv_v407` | `9c 7c 5d` | low / two_tone | range_advantage | caller | - | preflop_raiser | 2 | consensus_gto | medium: low two-tone rangeAdv (NEW correct template) |
| 13 | `AsKhQd_dyn_v407` | `As Kh Qd` | A_high / rainbow | dynamic_level | dynamic | semi_static, very_dynamic | - | 3 | consensus_gto | medium: dynamic_level on dynamic board |
| 14 | `AhAc4d_nutadv_v407` | `Ah Ac 4d` | A_high / rainbow | nut_advantage | preflop_raiser | - | caller | 2 | consensus_gto | medium: paired board nut adv (wording + soft critical) |
| 15 | `Kh8h3h_sizing_v407` | `Kh 8h 3h` | K_high / monotone | sizing_family | check_heavy | mixed_small_check | polar_big, range_small | 5 | expert_judgment | hard: monotone sizing |
| 16 | `Ks7s2s_freq_v407` | `Ks 7s 2s` | K_high / monotone | frequency_strategy | check_heavy | mixed_small_check | polar_big, range_small | 4 | expert_judgment | hard: monotone frequency |
| 17 | `7s5s4d_sizing_v407` | `7s 5s 4d` | low / two_tone | sizing_family | check_heavy | mixed_small_check, polar_big | range_small | 5 | expert_judgment | hard: low_connected_two_tone sizing (NEW template) |
| 18 | `Js9d4h_nutadv_v407` | `Js 9d 4h` | J_high / rainbow | nut_advantage | neutral | - | - | 4 | expert_judgment | hard: nut adv on broadway-connected rainbow |
| 19 | `9s7d6h_freq_v407` | `9s 7d 6h` | low / rainbow | frequency_strategy | check_heavy | mixed_small_check, polar_big | range_small | 5 | expert_judgment | hard: very-wet low connected rainbow |
| 20 | `KsQsJh_nutadv_v407` | `Ks Qs Jh` | K_high / two_tone | nut_advantage | caller | - | preflop_raiser | 4 | expert_judgment | hard: broadway_two_tone_connected (NEW template) |
| 21 | `9s8s6h_sizing_v407` | `9s 8s 6h` | low / two_tone | sizing_family | check_heavy | mixed_small_check, polar_big | range_small | 5 | expert_judgment | hard: low two-tone sizing |
| 22 | `Jh7d2s_rangeadv_v407` | `Jh 7d 2s` | J_high / rainbow | range_advantage | neutral | split | - | 4 | expert_judgment | hard: neutral range adv (paired_mid / J_T) |
| 23 | `9c7c2c_nutadv_v407` | `9c 7c 2c` | low / monotone | nut_advantage | caller | neutral | - | 4 | expert_judgment | hard: low monotone |
| 24 | `9c8c5h_freq_v407` | `9c 8c 5h` | low / two_tone | frequency_strategy | check_heavy | mixed_small_check, polar_big | range_small | 5 | expert_judgment | hard: two-tone wet freq |
| 25 | `7d6d4d_sizing_v407` | `7d 6d 4d` | low / monotone | sizing_family | check_heavy | mixed_small_check | polar_big, range_small | 5 | expert_judgment | highest-risk: low monotone sizing (template-sensitive) |
| 26 | `TsTh6d_nutadv_v407` | `Ts Th 6d` | T_high / rainbow | nut_advantage | caller | neutral | - | 2 | expert_judgment | highest-risk: paired_mid nut adv (wording + soft critical) |
| 27 | `6h4h3s_sizing_v407` | `6h 4h 3s` | low / two_tone | sizing_family | check_heavy | mixed_small_check, polar_big | range_small | 5 | expert_judgment | highest-risk: low_connected_two_tone sizing |
| 28 | `As7s2s_rangeadv_v407` | `As 7s 2s` | A_high / monotone | range_advantage | neutral | split | - | 4 | expert_judgment | highest-risk: A-high monotone rangeAdv (often called neutral) |
| 29 | `QcJc6d_nutadv_v407` | `Qc Jc 6d` | Q_high / two_tone | nut_advantage | neutral | - | - | 4 | expert_judgment | highest-risk: mid_two_tone_dry nut adv (NEW template, neutral) |
| 30 | `Ah3h2s_sizing_v407` | `Ah 3h 2s` | A_high / two_tone | sizing_family | mixed_small_check | range_small | check_heavy | 4 | expert_judgment | extra: A-high two-tone sizing variation |

---

## How to use this extract

1. Open this file alongside ``postflop-v4.0.7-gpt-review-package.md`` (full prompt + explanations + risk analysis).
2. For each row, ask: **"Is this `best` answer defensible under BTN open 2.5x vs BB call, 100BB SRP, NLH MTT chipEV?"**
3. Flag any disagreements by id.
4. **Special focus**: rows tagged "(NEW template)" or referring to two-tone sub-families. Also note that monotone_low + paired_mid + monotone_high + mid_two_tone_dry + low_dry_two_tone now have softened critical tier on nut_advantage (preflop_raiser/caller in the opposite direction is `bad`, not `critical`, since these families are solver-sensitive).

## Per-tier counts in this 30-sample set

**By sourceConfidence:**  
- consensus_gto: 10  
- expert_judgment: 20  

**By difficulty:**  
- diff 1: 5  
- diff 2: 7  
- diff 3: 3  
- diff 4: 8  
- diff 5: 7  

**By suitTexture:**  
- monotone: 5  
- rainbow: 14  
- two_tone: 11  

**By question type:**  
- dynamic_level: 3  
- frequency_strategy: 6  
- nut_advantage: 7  
- range_advantage: 8  
- sizing_family: 6  
