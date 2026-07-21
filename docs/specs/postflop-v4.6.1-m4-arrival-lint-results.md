# v4.6.1 M4 Arrival Lint Results (mechanical pass)

Generated from production (542, blob 54f134f5). ARR.A reproduced 18/18 banked leg-(a) rows; ARR.C1 reproduced 6/6 banked pairs. ARR.P found **64 rows with tier-array OVERLAP** (defect class discovered on the V1 row).

| id | class | board | reason | best | D | verdict | overlap | M3 twin |
|---|---|---|---|---|---|---|---|---|
| `7s5d3h_4c_m4_action_6h6d_v430D` | 66 | 7s5d3h/4c | value_check_raise_turn | check_raise_small | 2 | REVIEW | OVERLAP |  |
| `7s5d3h_4c_m4_action_8d7d_v430D` | 87s | 7s5d3h/4c | equity_realization_turn_call | call | 3 | REVIEW | ok |  |
| `7s5d3h_4c_m4_action_JsTs_v432` | JTs | 7s5d3h/4c | mixed_indifference_turn | mixed | 5 | REVIEW | OVERLAP |  |
| `7s5d3h_4c_m4_action_KsTd_v430D` | KTo | 7s5d3h/4c | range_disadvantage_turn_fold | fold | 2 | REVIEW | OVERLAP |  |
| `8c8d3s_3h_m4_action_5h5d_v430` | 55 | 8c8d3s/3h | bluff_catch_turn | call | 3 | REVIEW | OVERLAP |  |
| `8c8d3s_3h_m4_action_Ah3d_v430` | A3o | 8c8d3s/3h | slowplay_turn_call | call | 4 | REVIEW | OVERLAP |  |
| `8c8d3s_3h_m4_action_QhJh_v430` | QJs | 8c8d3s/3h | range_disadvantage_turn_fold | fold | 2 | REVIEW | OVERLAP |  |
| `8d6c3s_Qh_m4_action_6h5h_v430C` | 65s | 8d6c3s/Qh | range_disadvantage_turn_fold | fold | 3 | REVIEW | OVERLAP |  |
| `8d6c3s_Qh_m4_action_AhQc_v430C` | AQo | 8d6c3s/Qh | value_check_raise_turn | check_raise_small | 4 | REVIEW | OVERLAP |  |
| `8d6c3s_Qh_m4_action_JdTd_v430C` | JTs | 8d6c3s/Qh | pot_odds_turn_call | call | 3 | REVIEW | ok |  |
| `8d6c3s_Qh_m4_reason_8h7d_v430D` | 87o | 8d6c3s/Qh | range_disadvantage_turn_fold | fold | 3 | REVIEW | ok |  |
| `9c6c3h_8c_m4_reason_7s5s_v432` | 75s | 9c6c3h/8c | bluff_catch_turn | call | 4 | REVIEW | ok |  |
| `9d8c6h_Kc_m4_action_9h7h_v430` | 97s | 9d8c6h/Kc | board_change_fold | fold | 3 | REVIEW | OVERLAP |  |
| `9d8c6h_Kc_m4_action_AdJs_v430` | AJo | 9d8c6h/Kc | range_disadvantage_turn_fold | fold | 3 | REVIEW | OVERLAP |  |
| `9s8d4c_7h_m4_action_JhTh_v430C` | JTs | 9s8d4c/7h | value_check_raise_turn | check_raise_big | 4 | REVIEW | OVERLAP |  |
| `9s8d4c_7h_m4_action_KdJd_v430C` | KJs | 9s8d4c/7h | pot_odds_turn_call | call | 3 | REVIEW | ok |  |
| `9s8d4c_7h_m4_action_TsTc_v430D` | TT | 9s8d4c/7h | equity_realization_turn_call | call | 3 | REVIEW | ok |  |
| `9s8d4c_7h_m4_reason_5h5d_v432` | 55 | 9s8d4c/7h | slowplay_turn_call | call | 4 | REVIEW | ok |  |
| `Ac7d2s_4h_m4_action_6d5d_v430C` | 65s | Ac7d2s/4h | pot_odds_turn_call | call | 3 | REVIEW | ok |  |
| `Ac7d2s_4h_m4_action_7s6h_v430C` | 76o | Ac7d2s/4h | bluff_catch_turn | call | 3 | REVIEW | ok |  |
| `Ac7d2s_4h_m4_action_9c9d_v430C` | 99 | Ac7d2s/4h | mixed_indifference_turn | mixed | 4 | REVIEW | OVERLAP |  |
| `Ac7d2s_4h_m4_action_KdJc_v430C` | KJo | Ac7d2s/4h | domination_turn_fold | fold | 2 | REVIEW | OVERLAP |  |
| `Ac7d2s_4h_m4_reason_9d8d_v432` | 98s | Ac7d2s/4h | range_disadvantage_turn_fold | fold | 4 | REVIEW | ok |  |
| `Ac7d2s_4h_m4_reason_AdJc_v430D` | AJo | Ac7d2s/4h | bluff_catch_turn | call | 3 | REVIEW | PARTIAL |  |
| `Ah9d4d_7h_m4_action_5d6d_v430C` | 65s | Ah9d4d/7h | semi_bluff_check_raise_turn | check_raise_small | 4 | REVIEW | OVERLAP |  |
| `Ah9d4d_7h_m4_action_AsTs_v430C` | ATs | Ah9d4d/7h | bluff_catch_turn | call | 3 | REVIEW | OVERLAP |  |
| `Ah9d4d_7h_m4_action_JcTd_v432` | JTo | Ah9d4d/7h | range_disadvantage_turn_fold | fold | 3 | REVIEW | OVERLAP |  |
| `Ah9d4d_7h_m4_action_KdQd_v430C` | KQs | Ah9d4d/7h | equity_realization_turn_call | call | 3 | REVIEW | OVERLAP |  |
| `Ah9d4d_7h_m4_reason_TdTs_v430D` | TT | Ah9d4d/7h | mixed_indifference_turn | mixed | 4 | REVIEW | PARTIAL |  |
| `As8d3h_2c_m4_action_JsTh_v430` | JTo | As8d3h/2c | board_change_fold | fold | 2 | REVIEW | OVERLAP |  |
| `As8d3h_2c_m4_action_Th8h_v430` | T8s | As8d3h/2c | range_disadvantage_turn_fold | fold | 3 | REVIEW | OVERLAP |  |
| `JdTd5s_2c_m4_action_9c9d_v430C` | 99 | JdTd5s/2c | mixed_indifference_turn | mixed | 4 | REVIEW | OVERLAP |  |
| `JdTd5s_2c_m4_action_JhJs_v430D` | JJ | JdTd5s/2c | value_check_raise_turn | check_raise_small | 2 | REVIEW | OVERLAP |  |
| `JdTd5s_2c_m4_reason_As9s_v432` | A9s | JdTd5s/2c | blocker_check_raise_turn | check_raise_small | 5 | REVIEW | ok |  |
| `Kc7s2d_Qh_m4_action_AsTs_v432` | ATs | Kc7s2d/Qh | blocker_check_raise_turn | check_raise_small | 5 | REVIEW | OVERLAP |  |
| `Kc7s2d_Qh_m4_action_JhTh_v432` | JTs | Kc7s2d/Qh | equity_realization_turn_call | call | 3 | REVIEW | OVERLAP |  |
| `Kc7s2d_Qh_m4_action_KhJd_v432` | KJo | Kc7s2d/Qh | domination_turn_fold | fold | 3 | REVIEW | OVERLAP |  |
| `Kd8c4s_Ah_m4_action_8d8h_v430C` | 88 | Kd8c4s/Ah | protection_check_raise_turn | check_raise_small | 3 | REVIEW | OVERLAP |  |
| `Kd8c4s_Ah_m4_action_JsTs_v430C` | JTs | Kd8c4s/Ah | pot_odds_turn_call | call | 3 | REVIEW | OVERLAP |  |
| `Kd8c4s_Ah_m4_action_KhQh_v430C` | KQs | Kd8c4s/Ah | domination_turn_fold | fold | 3 | REVIEW | OVERLAP |  |
| `Kd8c4s_Ah_m4_reason_As6c_v430D` | A6o | Kd8c4s/Ah | blocker_check_raise_turn | check_raise_small | 5 | REVIEW | PARTIAL |  |
| `Kd8s3c_8h_m4_action_AsTd_v432` | ATo | Kd8s3c/8h | blocker_check_raise_turn | check_raise_small | 5 | REVIEW | OVERLAP |  |
| `Kd8s3c_8h_m4_action_JsJd_v430D` | JJ | Kd8s3c/8h | range_disadvantage_turn_fold | fold | 3 | REVIEW | OVERLAP |  |
| `Kd8s3c_8h_m4_action_QhJh_v430C` | QJs | Kd8s3c/8h | domination_turn_fold | fold | 2 | REVIEW | OVERLAP |  |
| `Kd8s3c_8h_m4_reason_7c7d_v432` | 77 | Kd8s3c/8h | domination_turn_fold | fold | 3 | REVIEW | ok |  |
| `Ks8s3d_2s_m4_action_6s5s_v430` | 65s | Ks8s3d/2s | bluff_catch_turn | call | 4 | REVIEW | OVERLAP |  |
| `Ks8s3d_2s_m4_action_Tc9c_v430` | T9s | Ks8s3d/2s | board_change_fold | fold | 2 | REVIEW | OVERLAP |  |
| `Ks8s3d_2s_m4_reason_AsJd_v430` | AJo | Ks8s3d/2s | blocker_check_raise_turn | check_raise_small | 5 | REVIEW | ok |  |
| `Qs7d3c_3h_m4_action_7s7c_v430C` | 77 | Qs7d3c/3h | value_check_raise_turn | check_raise_small | 3 | REVIEW | OVERLAP |  |
| `Qs7d3c_3h_m4_action_8d8c_v432` | 88 | Qs7d3c/3h | mixed_indifference_turn | mixed | 5 | REVIEW | OVERLAP |  |
| `Qs7d3c_3h_m4_action_AhQc_v430D` | AQo | Qs7d3c/3h | value_check_raise_turn | check_raise_small | 3 | REVIEW | OVERLAP |  |
| `Qs8s4d_2s_m4_action_8d8h_v430C` | 88 | Qs8s4d/2s | slowplay_turn_call | call | 4 | REVIEW | OVERLAP |  |
| `Qs8s4d_2s_m4_action_As8d_v432` | A8o | Qs8s4d/2s | domination_turn_fold | fold | 4 | REVIEW | OVERLAP |  |
| `Qs8s4d_2s_m4_action_As9s_v430C` | A9s | Qs8s4d/2s | value_check_raise_turn | check_raise_small | 3 | REVIEW | OVERLAP |  |
| `Qs8s4d_2s_m4_action_KsQc_v430D` | KQo | Qs8s4d/2s | bluff_catch_turn | call | 4 | REVIEW | ok |  |
| `Qs8s4d_2s_m4_reason_As9c_v430D` | A9o | Qs8s4d/2s | blocker_check_raise_turn | check_raise_small | 5 | REVIEW | PARTIAL |  |
| `Qs8s4d_2s_m4_reason_Tc9c_v432` | T9s | Qs8s4d/2s | board_change_fold | fold | 3 | REVIEW | ok |  |
| `QsTs6d_Jc_m4_action_9c8h_v430` | 98o | QsTs6d/Jc | value_check_raise_turn | check_raise_small | 3 | REVIEW | OVERLAP |  |
| `QsTs6d_Jc_m4_action_KhQh_v430` | KQs | QsTs6d/Jc | bluff_catch_turn | call | 4 | REVIEW | OVERLAP |  |
| `QsTs6d_Jc_m4_reason_Tc9d_v430` | T9o | QsTs6d/Jc | equity_realization_turn_call | call | 4 | REVIEW | ok |  |
| `Ts8s4d_7c_m4_action_9c8c_v430C` | 98s | Ts8s4d/7c | semi_bluff_check_raise_turn | check_raise_small | 4 | REVIEW | OVERLAP |  |
| `Ts8s4d_7c_m4_action_9d6d_v430C` | 96s | Ts8s4d/7c | value_check_raise_turn | check_raise_small | 3 | REVIEW | OVERLAP |  |
| `Ts8s4d_7c_m4_action_JsJh_v430D` | JJ | Ts8s4d/7c | protection_check_raise_turn | check_raise_small | 3 | REVIEW | OVERLAP |  |
| `Ts8s4d_7c_m4_action_TcTd_v432` | TT | Ts8s4d/7c | value_check_raise_turn | check_raise_big | 4 | REVIEW | OVERLAP |  |
| `Ts8s4d_7c_m4_reason_KsQc_v430D` | KQo | Ts8s4d/7c | domination_turn_fold | fold | 3 | REVIEW | PARTIAL |  |
| `Ts8s4d_7c_m4_reason_TdTc_v430D` | TT | Ts8s4d/7c | slowplay_turn_call | call | 4 | REVIEW | ok |  |
| `Ts9s5d_6h_m4_action_8c7c_v430` | 87s | Ts9s5d/6h | value_check_raise_turn | check_raise_small | 3 | REVIEW | OVERLAP |  |
| `Ts9s5d_6h_m4_reason_KhQd_v430` | KQo | Ts9s5d/6h | range_disadvantage_turn_fold | fold | 3 | REVIEW | ok |  |
| `7s5d3h_4c_m4_reason_AhAd_v432` | AA | 7s5d3h/4c | mixed_indifference_turn | mixed | 5 | REWORK-(a) | ok |  |
| `8c8d3s_3h_m4_reason_AdKc_v430` | AKo | 8c8d3s/3h | bluff_catch_turn | call | 4 | REWORK-(a) | ok |  |
| `9s8d4c_7h_m4_action_AhAd_v430C` | AA | 9s8d4c/7h | mixed_indifference_turn | mixed | 5 | REWORK-(a) | OVERLAP |  |
| `9s8d4c_7h_m4_action_KsKc_v432` | KK | 9s8d4c/7h | bluff_catch_turn | call | 3 | REWORK-(a) | OVERLAP |  |
| `Ac7d2s_4h_m4_action_AcKh_v432` | AKo | Ac7d2s/4h | value_check_raise_turn | check_raise_small | 3 | REWORK-(a) | OVERLAP |  |
| `Ah9d4d_7h_m4_action_AsKs_v430D` | AKs | Ah9d4d/7h | value_check_raise_turn | check_raise_small | 3 | REWORK-(a) | OVERLAP |  |
| `As8d3h_2c_m4_action_AdQd_v430` | AQs | As8d3h/2c | bluff_catch_turn | call | 3 | REWORK-(a) | OVERLAP |  |
| `JdTd5s_2c_m4_action_AhAd_v430C` | AA | JdTd5s/2c | protection_check_raise_turn | check_raise_small | 4 | REWORK-(a) | OVERLAP |  |
| `JdTd5s_2c_m4_action_KsKh_v430D` | KK | JdTd5s/2c | value_check_raise_turn | check_raise_small | 3 | REWORK-(a) | OVERLAP |  |
| `Kd8s3c_8h_m4_action_AdKh_v430C` | AKo | Kd8s3c/8h | bluff_catch_turn | call | 3 | REWORK-(a) | OVERLAP |  |
| `Kd8s3c_8h_m4_action_AdKh_v430D` | AKo | Kd8s3c/8h | bluff_catch_turn | call | 3 | REWORK-(a) | OVERLAP |  |
| `Kd8s3c_8h_m4_action_KsKc_v430C` | KK | Kd8s3c/8h | value_check_raise_turn | check_raise_big | 3 | REWORK-(a) | OVERLAP |  |
| `Ks8s3d_2s_m4_action_AsKd_v430` | AKo | Ks8s3d/2s | bluff_catch_turn | call | 3 | REWORK-(a) | OVERLAP |  |
| `Qs7d3c_3h_m4_action_AhAd_v430C` | AA | Qs7d3c/3h | protection_check_raise_turn | check_raise_small | 4 | REWORK-(a) | OVERLAP |  |
| `Qs8s4d_2s_m4_action_AsKc_v430C` | AKo | Qs8s4d/2s | bluff_catch_turn | call | 3 | REWORK-(a) | OVERLAP |  |
| `Ts8s4d_7c_m4_action_AsKs_v430C` | AKs | Ts8s4d/7c | equity_realization_turn_call | call | 3 | REWORK-(a) | OVERLAP |  |
| `Ts8s4d_7c_m4_action_AsQs_v432` | AQs | Ts8s4d/7c | semi_bluff_check_raise_turn | check_raise_small | 3 | REWORK-(a) | OVERLAP |  |
| `Ts8s4d_7c_m4_reason_QcQd_v432` | QQ | Ts8s4d/7c | bluff_catch_turn | call | 4 | REWORK-(a) | ok |  |
| `QsTs6d_Jc_m4_action_5h4d_v430` | 54o | QsTs6d/Jc | board_change_fold | fold | 2 | REWORK-(b)* | OVERLAP | `QsTs6d_m3_action_5h4d_v423a` |
| `9d8c6h_Kc_m4_action_9c9s_v430` | 99 | 9d8c6h/Kc | protection_check_raise_turn | check_raise_small | 3 | REWORK-(c)* | OVERLAP | `9d8c6h_m3_action_9c9s_v423a` |
| `9d8c6h_Kc_m4_reason_Tc7c_v430` | T7s | 9d8c6h/Kc | value_check_raise_turn | check_raise_small | 3 | REWORK-(c)* | ok | `9d8c6h_m3_reason_Tc7c_v423a` |
| `As8d3h_2c_m4_reason_8c8h_v430` | 88 | As8d3h/2c | slowplay_turn_call | call | 4 | REWORK-(c)* | ok | `As8d3h_m3_action_8c8h_v420` |
| `Ts9s5d_6h_m4_action_As6s_v430` | A6s | Ts9s5d/6h | equity_realization_turn_call | call | 4 | REWORK-(c)* | OVERLAP | `Ts9s5d_m3_action_As6s_v423b` |
| `Ts9s5d_6h_m4_action_TcTd_v430` | TT | Ts9s5d/6h | protection_check_raise_turn | check_raise_small | 3 | REWORK-(c)* | OVERLAP | `Ts9s5d_m3_action_TcTd_v423b` |
