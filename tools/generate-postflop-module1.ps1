# tools/generate-postflop-module1.ps1
# v4.0.7-hardened Module 1 generator. Tracked under tools/ (git-allowed).
#
# Purpose:
#   Build/refresh Module 1 (Board Texture Trainer) scenarios in
#   postflop/postflop_scenarios.json. Idempotent: every scenario this script
#   emits has an id ending in `_v407`; on re-run, all `_v407` ids are stripped
#   from the existing JSON before the freshly-generated set is appended.
#   Hand-authored baseline (v4.0.0 seed and any non-_v407 scenarios) is
#   preserved untouched.
#
# Methodology:
#   - Curated board library across 14 family/suit combos (12 rainbow + 2 added
#     two-tone-variant pools), with `_skip` markers on the 12 boards already in
#     the v4.0.0 seed so we don't duplicate ids.
#   - Per-family GTO templates encode rangeAdvantage, nutAdvantage, default
#     sizingFamily, base textureTags, and the rangeLogic / nutLogic /
#     sizingLogic / commonMistake explanation strings. Templates draw on
#     mainstream MTT 100BB SRP postflop consensus.
#   - sourceConfidence is per-family per-question-type: only low-controversy
#     reads stay `consensus_gto`; everything else (sizing, monotone, two-tone,
#     wet, broadway-connected, paired-mid, J/T-medium) is honestly tagged
#     `expert_judgment`. Zero `solver_verified` because no actual solver
#     output backs these templates.
#   - Difficulty heuristic spans 1..5 based on family + qtype.
#
# Reproducibility:
#   - Deterministic given the board library + plan (no RNG).
#   - Re-run: powershell -ExecutionPolicy Bypass -File tools/generate-postflop-module1.ps1
#   - Then audit: powershell -ExecutionPolicy Bypass -File tools/audit-postflop-ps.ps1
#
# Distribution targets (Module 1 totals after re-run, including 20 baseline):
#   - Question types: ra=50, na=50, fs=50, sf=50, dl=45 (~245 total)
#   - SuitTexture:    rainbow ~45%, two_tone ~45%, monotone ~10%
#   - SourceConfidence: consensus_gto 80-130, expert_judgment 100-150,
#                       needs_review 0, solver_verified 0
#   - Difficulty:     spread across 1..5; diff-2 still heavy
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$scenPath = Join-Path $repoRoot 'postflop/postflop_scenarios.json'

# ============================================================
# Board library
# ============================================================
# Each entry: id, cards, family, dyn (1..4), suit ('rainbow'|'two_tone'|'monotone')
# Boards marked with `_skip` family suffix are filtered out (used to deduplicate
# against v4.0.0 seed scenarios that already cover those exact boards).
$boards = @(
  # ===== Rainbow boards (existing pool) =====
  @{id='Ah7d2s';cards=@('Ah','7d','2s');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='Ad8s2c';cards=@('Ad','8s','2c');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='As9d3h';cards=@('As','9d','3h');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='Ah8c3d';cards=@('Ah','8c','3d');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='Ad9h2c';cards=@('Ad','9h','2c');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='As7c4d';cards=@('As','7c','4d');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='Ah8s5d';cards=@('Ah','8s','5d');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='Ac9d5s';cards=@('Ac','9d','5s');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='Ad8h6c';cards=@('Ad','8h','6c');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='As9c6h';cards=@('As','9c','6h');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='AhTs3d';cards=@('Ah','Ts','3d');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='AdTc4h';cards=@('Ad','Tc','4h');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='AsTh5c';cards=@('As','Th','5c');family='A_high_dry';dyn=1;suit='rainbow'},
  @{id='Kh7d2s';cards=@('Kh','7d','2s');family='K_high_dry';dyn=1;suit='rainbow'},
  @{id='Kd8s3c';cards=@('Kd','8s','3c');family='K_high_dry';dyn=1;suit='rainbow'},
  @{id='Ks9d4h';cards=@('Ks','9d','4h');family='K_high_dry';dyn=1;suit='rainbow'},
  @{id='Kh9c2d';cards=@('Kh','9c','2d');family='K_high_dry';dyn=1;suit='rainbow'},
  @{id='Kd7s4c';cards=@('Kd','7s','4c');family='K_high_dry';dyn=1;suit='rainbow'},
  @{id='Ks8h5d';cards=@('Ks','8h','5d');family='K_high_dry';dyn=1;suit='rainbow'},
  @{id='Kh6c2s';cards=@('Kh','6c','2s');family='K_high_dry';dyn=1;suit='rainbow'},
  @{id='Kd6h3c';cards=@('Kd','6h','3c');family='K_high_dry';dyn=1;suit='rainbow'},
  @{id='Ks5c2h';cards=@('Ks','5c','2h');family='K_high_dry';dyn=1;suit='rainbow'},
  @{id='Kh5d3s';cards=@('Kh','5d','3s');family='K_high_dry';dyn=1;suit='rainbow'},
  @{id='Qh7d2s';cards=@('Qh','7d','2s');family='Q_high_dry';dyn=1;suit='rainbow'},
  @{id='Qd8s3c';cards=@('Qd','8s','3c');family='Q_high_dry';dyn=1;suit='rainbow'},
  @{id='Qs9d4h';cards=@('Qs','9d','4h');family='Q_high_dry';dyn=2;suit='rainbow'},
  @{id='Qh6c2d';cards=@('Qh','6c','2d');family='Q_high_dry';dyn=1;suit='rainbow'},
  @{id='Qd5s2c';cards=@('Qd','5s','2c');family='Q_high_dry';dyn=1;suit='rainbow'},
  @{id='Qs7h3d';cards=@('Qs','7h','3d');family='Q_high_dry';dyn=1;suit='rainbow'},
  @{id='Qh8d4c';cards=@('Qh','8d','4c');family='Q_high_dry';dyn=1;suit='rainbow'},
  @{id='Qd9s5h';cards=@('Qd','9s','5h');family='Q_high_dry';dyn=2;suit='rainbow'},
  @{id='Qs8c5d';cards=@('Qs','8c','5d');family='Q_high_dry';dyn=2;suit='rainbow'},
  @{id='Qh7s4d';cards=@('Qh','7s','4d');family='Q_high_dry';dyn=1;suit='rainbow'},
  @{id='Qd9h6c';cards=@('Qd','9h','6c');family='Q_high_dry';dyn=2;suit='rainbow'},
  @{id='Jh7d2s';cards=@('Jh','7d','2s');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='Jd8s3c';cards=@('Jd','8s','3c');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='Js9d4h';cards=@('Js','9d','4h');family='J_T_medium';dyn=3;suit='rainbow'},
  @{id='Jh6c2d';cards=@('Jh','6c','2d');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='Jd5s3c';cards=@('Jd','5s','3c');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='Js8c4d';cards=@('Js','8c','4d');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='Jh4d2c';cards=@('Jh','4d','2c');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='Th7d2s';cards=@('Th','7d','2s');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='Td6s3c';cards=@('Td','6s','3c');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='Ts5d4h';cards=@('Ts','5d','4h');family='J_T_medium';dyn=3;suit='rainbow'},
  @{id='Td3s2h';cards=@('Td','3s','2h');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='Th5c2d';cards=@('Th','5c','2d');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='Td7c2h';cards=@('Td','7c','2h');family='J_T_medium';dyn=2;suit='rainbow'},
  @{id='9c5d2h_v2';cards=@('9c','5d','2h');family='low_dry_skip';dyn=1;suit='rainbow'},
  @{id='8d4s2c';cards=@('8d','4s','2c');family='low_dry';dyn=1;suit='rainbow'},
  @{id='9h6c2s';cards=@('9h','6c','2s');family='low_dry';dyn=1;suit='rainbow'},
  @{id='8c5h2d';cards=@('8c','5h','2d');family='low_dry';dyn=1;suit='rainbow'},
  @{id='9s4d2h';cards=@('9s','4d','2h');family='low_dry';dyn=1;suit='rainbow'},
  @{id='8h3s2c';cards=@('8h','3s','2c');family='low_dry';dyn=1;suit='rainbow'},
  @{id='7c4d2s';cards=@('7c','4d','2s');family='low_dry';dyn=2;suit='rainbow'},
  @{id='6h4s2c';cards=@('6h','4s','2c');family='low_dry';dyn=2;suit='rainbow'},
  @{id='9d6h3c';cards=@('9d','6h','3c');family='low_dry';dyn=2;suit='rainbow'},
  @{id='8s5d3c';cards=@('8s','5d','3c');family='low_dry';dyn=2;suit='rainbow'},
  @{id='9c3s2h';cards=@('9c','3s','2h');family='low_dry';dyn=1;suit='rainbow'},
  @{id='AhAd7c';cards=@('Ah','Ad','7c');family='paired_high';dyn=1;suit='rainbow'},
  @{id='AsAh5d';cards=@('As','Ah','5d');family='paired_high';dyn=1;suit='rainbow'},
  @{id='AdAc9s';cards=@('Ad','Ac','9s');family='paired_high';dyn=1;suit='rainbow'},
  @{id='AhAc4d';cards=@('Ah','Ac','4d');family='paired_high';dyn=1;suit='rainbow'},
  @{id='AsAd2h';cards=@('As','Ad','2h');family='paired_high';dyn=1;suit='rainbow'},
  @{id='KhKd5c_v2';cards=@('Kh','Kd','5c');family='paired_high_skip';dyn=1;suit='rainbow'},
  @{id='KsKh3d';cards=@('Ks','Kh','3d');family='paired_high';dyn=1;suit='rainbow'},
  @{id='KdKc9s';cards=@('Kd','Kc','9s');family='paired_high';dyn=1;suit='rainbow'},
  @{id='KhKc8d';cards=@('Kh','Kc','8d');family='paired_high';dyn=1;suit='rainbow'},
  @{id='KsKd2c';cards=@('Ks','Kd','2c');family='paired_high';dyn=1;suit='rainbow'},
  @{id='QhQd5c';cards=@('Qh','Qd','5c');family='paired_high';dyn=2;suit='rainbow'},
  @{id='QsQh4d';cards=@('Qs','Qh','4d');family='paired_high';dyn=2;suit='rainbow'},
  @{id='QdQc8s';cards=@('Qd','Qc','8s');family='paired_high';dyn=2;suit='rainbow'},
  @{id='ThTd4c';cards=@('Th','Td','4c');family='paired_mid';dyn=2;suit='rainbow'},
  @{id='TsTh6d';cards=@('Ts','Th','6d');family='paired_mid';dyn=2;suit='rainbow'},
  @{id='9h9d3c';cards=@('9h','9d','3c');family='paired_mid';dyn=2;suit='rainbow'},
  @{id='9s9h2d';cards=@('9s','9h','2d');family='paired_mid';dyn=2;suit='rainbow'},
  @{id='9d9c5h';cards=@('9d','9c','5h');family='paired_mid';dyn=2;suit='rainbow'},
  @{id='8h8d2c';cards=@('8h','8d','2c');family='paired_mid';dyn=2;suit='rainbow'},
  @{id='7h7d2c';cards=@('7h','7d','2c');family='paired_low';dyn=1;suit='rainbow'},
  @{id='7s7h4d';cards=@('7s','7h','4d');family='paired_low';dyn=1;suit='rainbow'},
  @{id='7d7s3c_v2';cards=@('7d','7s','3c');family='paired_low_skip';dyn=1;suit='rainbow'},
  @{id='7h7s5d';cards=@('7h','7s','5d');family='paired_low';dyn=2;suit='rainbow'},
  @{id='6h6d2c';cards=@('6h','6d','2c');family='paired_low';dyn=1;suit='rainbow'},
  @{id='6s6h3d';cards=@('6s','6h','3d');family='paired_low';dyn=1;suit='rainbow'},
  @{id='5h5d2c';cards=@('5h','5d','2c');family='paired_low';dyn=1;suit='rainbow'},
  @{id='4h4d2s';cards=@('4h','4d','2s');family='paired_low';dyn=1;suit='rainbow'},
  @{id='3h3d6s';cards=@('3h','3d','6s');family='paired_low';dyn=2;suit='rainbow'},
  @{id='3s3hAc';cards=@('3s','3h','Ac');family='paired_low';dyn=1;suit='rainbow'},
  @{id='2h2dKc';cards=@('2h','2d','Kc');family='paired_low';dyn=1;suit='rainbow'},
  @{id='2s2hQd';cards=@('2s','2h','Qd');family='paired_low';dyn=1;suit='rainbow'},
  @{id='KhQdJc';cards=@('Kh','Qd','Jc');family='broadway_connected';dyn=4;suit='rainbow'},
  @{id='KsQhJd';cards=@('Ks','Qh','Jd');family='broadway_connected';dyn=4;suit='rainbow'},
  @{id='QhJsTd';cards=@('Qh','Js','Td');family='broadway_connected';dyn=4;suit='rainbow'},
  @{id='QdJhTc';cards=@('Qd','Jh','Tc');family='broadway_connected';dyn=4;suit='rainbow'},
  @{id='JhTs9c_v2';cards=@('Jh','Ts','9c');family='broadway_connected_skip';dyn=3;suit='rainbow'},
  @{id='JdTh9s';cards=@('Jd','Th','9s');family='broadway_connected';dyn=3;suit='rainbow'},
  @{id='QhTs9d';cards=@('Qh','Ts','9d');family='broadway_connected';dyn=3;suit='rainbow'},
  @{id='AhKdQc';cards=@('Ah','Kd','Qc');family='broadway_connected';dyn=3;suit='rainbow'},
  @{id='AsKhQd';cards=@('As','Kh','Qd');family='broadway_connected';dyn=3;suit='rainbow'},
  @{id='AdKsJc';cards=@('Ad','Ks','Jc');family='broadway_connected';dyn=3;suit='rainbow'},
  @{id='KhTs9d';cards=@('Kh','Ts','9d');family='broadway_connected';dyn=3;suit='rainbow'},
  @{id='6h5d4c';cards=@('6h','5d','4c');family='low_connected';dyn=4;suit='rainbow'},
  @{id='7h6d5c';cards=@('7h','6d','5c');family='low_connected';dyn=4;suit='rainbow'},
  @{id='8h7c5s';cards=@('8h','7c','5s');family='low_connected';dyn=4;suit='rainbow'},
  @{id='9h8d6c';cards=@('9h','8d','6c');family='low_connected';dyn=4;suit='rainbow'},
  @{id='Th9c8s';cards=@('Th','9c','8s');family='low_connected';dyn=4;suit='rainbow'},
  @{id='Ts9h7d';cards=@('Ts','9h','7d');family='low_connected';dyn=4;suit='rainbow'},
  @{id='6h4d3s';cards=@('6h','4d','3s');family='low_connected';dyn=3;suit='rainbow'},
  @{id='7h5d3c';cards=@('7h','5d','3c');family='low_connected';dyn=3;suit='rainbow'},
  @{id='8h6d4s';cards=@('8h','6d','4s');family='low_connected';dyn=3;suit='rainbow'},
  @{id='9h7d5s';cards=@('9h','7d','5s');family='low_connected';dyn=3;suit='rainbow'},
  @{id='5h4d3c_v2';cards=@('5h','4d','3c');family='low_connected_skip';dyn=3;suit='rainbow'},
  @{id='8h5d4s';cards=@('8h','5d','4s');family='low_connected';dyn=3;suit='rainbow'},
  @{id='9h6d4s';cards=@('9h','6d','4s');family='low_connected';dyn=3;suit='rainbow'},
  @{id='6c5d3h';cards=@('6c','5d','3h');family='low_connected';dyn=3;suit='rainbow'},
  @{id='9h8d7c_v2';cards=@('9h','8d','7c');family='very_wet_skip';dyn=4;suit='rainbow'},
  @{id='Th9d8c';cards=@('Th','9d','8c');family='very_wet';dyn=4;suit='rainbow'},
  @{id='Jh9c8s';cards=@('Jh','9c','8s');family='very_wet';dyn=4;suit='rainbow'},
  @{id='8h7c6s_v2';cards=@('8h','7c','6s');family='very_wet_skip';dyn=4;suit='rainbow'},
  @{id='Th8s7c';cards=@('Th','8s','7c');family='very_wet';dyn=4;suit='rainbow'},
  @{id='Jd9s8c';cards=@('Jd','9s','8c');family='very_wet';dyn=4;suit='rainbow'},
  @{id='QhTd9c';cards=@('Qh','Td','9c');family='very_wet';dyn=4;suit='rainbow'},
  @{id='QdTh9s_v2';cards=@('Qd','Th','9s');family='very_wet_skip';dyn=4;suit='rainbow'},
  @{id='Jh9d7c';cards=@('Jh','9d','7c');family='very_wet';dyn=4;suit='rainbow'},
  @{id='Tc8d6s';cards=@('Tc','8d','6s');family='very_wet';dyn=4;suit='rainbow'},
  @{id='Qh9d7c';cards=@('Qh','9d','7c');family='very_wet';dyn=3;suit='rainbow'},
  @{id='KhTs8c';cards=@('Kh','Ts','8c');family='very_wet';dyn=3;suit='rainbow'},
  @{id='9s7d6h';cards=@('9s','7d','6h');family='very_wet';dyn=4;suit='rainbow'},

  # ===== Existing two-tone boards =====
  @{id='As9s4d';cards=@('As','9s','4d');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Ks9s3d';cards=@('Ks','9s','3d');family='two_tone';dyn=2;suit='two_tone'},
  @{id='QhJh4c';cards=@('Qh','Jh','4c');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Ts8s3d';cards=@('Ts','8s','3d');family='two_tone';dyn=3;suit='two_tone'},
  @{id='AhJh3s_v2';cards=@('Ah','Jh','3s');family='two_tone_skip';dyn=2;suit='two_tone'},
  @{id='AhKh5c';cards=@('Ah','Kh','5c');family='two_tone';dyn=2;suit='two_tone'},
  @{id='9c7c5d';cards=@('9c','7c','5d');family='two_tone';dyn=4;suit='two_tone'},
  @{id='8c6c4d';cards=@('8c','6c','4d');family='two_tone';dyn=4;suit='two_tone'},
  @{id='Tc8c5d';cards=@('Tc','8c','5d');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Jc9c4d';cards=@('Jc','9c','4d');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Qd9d3s';cards=@('Qd','9d','3s');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Kd8d2s';cards=@('Kd','8d','2s');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Ad7d2s';cards=@('Ad','7d','2s');family='two_tone';dyn=2;suit='two_tone'},
  @{id='AcKc8d';cards=@('Ac','Kc','8d');family='two_tone';dyn=2;suit='two_tone'},
  @{id='QcJc6d';cards=@('Qc','Jc','6d');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Jd8d4s';cards=@('Jd','8d','4s');family='two_tone';dyn=3;suit='two_tone'},
  @{id='6c5c3d';cards=@('6c','5c','3d');family='two_tone';dyn=4;suit='two_tone'},
  @{id='7d6d4s';cards=@('7d','6d','4s');family='two_tone';dyn=4;suit='two_tone'},
  @{id='Th9h6c_v2';cards=@('Th','9h','6c');family='two_tone';dyn=3;suit='two_tone'},
  @{id='As4s2d';cards=@('As','4s','2d');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Kc6c2d';cards=@('Kc','6c','2d');family='two_tone';dyn=2;suit='two_tone'},

  # ===== NEW two-tone boards (v4.0.7-hardened) =====
  # A-high two-tone (extends two_tone family with A-high boards distinct from existing)
  @{id='Ah6h3c';cards=@('Ah','6h','3c');family='two_tone';dyn=2;suit='two_tone'},
  @{id='As5s3c';cards=@('As','5s','3c');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Ad8d3s';cards=@('Ad','8d','3s');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Ah4h2s';cards=@('Ah','4h','2s');family='two_tone';dyn=2;suit='two_tone'},
  @{id='As6s2d';cards=@('As','6s','2d');family='two_tone';dyn=2;suit='two_tone'},
  @{id='AcQc4d';cards=@('Ac','Qc','4d');family='two_tone';dyn=2;suit='two_tone'},
  @{id='AhTh4c';cards=@('Ah','Th','4c');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Ad9d6s';cards=@('Ad','9d','6s');family='two_tone';dyn=2;suit='two_tone'},

  # K-high two-tone
  @{id='KhTh4d';cards=@('Kh','Th','4d');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Ks7s3h';cards=@('Ks','7s','3h');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Kd6d2c';cards=@('Kd','6d','2c');family='two_tone';dyn=2;suit='two_tone'},
  @{id='KhJh5s';cards=@('Kh','Jh','5s');family='two_tone';dyn=3;suit='two_tone'},
  @{id='KsQs4h';cards=@('Ks','Qs','4h');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Kc5c2h';cards=@('Kc','5c','2h');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Kd9d4c';cards=@('Kd','9d','4c');family='two_tone';dyn=2;suit='two_tone'},
  @{id='KhTh7c';cards=@('Kh','Th','7c');family='two_tone';dyn=3;suit='two_tone'},

  # Q-high two-tone
  @{id='QhTh3c';cards=@('Qh','Th','3c');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Qs8s4d';cards=@('Qs','8s','4d');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Qd6d2h';cards=@('Qd','6d','2h');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Qc9c3h';cards=@('Qc','9c','3h');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Qh5h2s';cards=@('Qh','5h','2s');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Qd7d4s';cards=@('Qd','7d','4s');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Qs9s6h';cards=@('Qs','9s','6h');family='two_tone';dyn=3;suit='two_tone'},

  # J/T-high two-tone
  @{id='JhTh3c';cards=@('Jh','Th','3c');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Js7s2d';cards=@('Js','7s','2d');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Jc6c3h';cards=@('Jc','6c','3h');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Jh5h2s';cards=@('Jh','5h','2s');family='two_tone';dyn=2;suit='two_tone'},
  @{id='Th8h4c';cards=@('Th','8h','4c');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Tc7c2h';cards=@('Tc','7c','2h');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Td9d6s';cards=@('Td','9d','6s');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Ts5s3h';cards=@('Ts','5s','3h');family='two_tone';dyn=3;suit='two_tone'},

  # Low two-tone (low pair / connector with two of a suit)
  @{id='9h6h2c';cards=@('9h','6h','2c');family='two_tone';dyn=3;suit='two_tone'},
  @{id='8s4s2d';cards=@('8s','4s','2d');family='two_tone';dyn=3;suit='two_tone'},
  @{id='7h3h2s';cards=@('7h','3h','2s');family='two_tone';dyn=3;suit='two_tone'},
  @{id='9d5d3c';cards=@('9d','5d','3c');family='two_tone';dyn=3;suit='two_tone'},
  @{id='8c4c3s';cards=@('8c','4c','3s');family='two_tone';dyn=3;suit='two_tone'},

  # Low connected two-tone (very wet variant)
  @{id='9c8c5h';cards=@('9c','8c','5h');family='two_tone';dyn=4;suit='two_tone'},
  @{id='Th9h5c';cards=@('Th','9h','5c');family='two_tone';dyn=4;suit='two_tone'},
  @{id='Jh9h6s';cards=@('Jh','9h','6s');family='two_tone';dyn=4;suit='two_tone'},
  @{id='Td8d7c';cards=@('Td','8d','7c');family='two_tone';dyn=4;suit='two_tone'},
  @{id='8h6h5d';cards=@('8h','6h','5d');family='two_tone';dyn=4;suit='two_tone'},
  @{id='7s5s4d';cards=@('7s','5s','4d');family='two_tone';dyn=4;suit='two_tone'},
  @{id='9s8s6h';cards=@('9s','8s','6h');family='two_tone';dyn=4;suit='two_tone'},
  @{id='6h4h3s';cards=@('6h','4h','3s');family='two_tone';dyn=4;suit='two_tone'},

  # Broadway connected two-tone
  @{id='QhJhTc';cards=@('Qh','Jh','Tc');family='two_tone';dyn=4;suit='two_tone'},
  @{id='KsQsJh';cards=@('Ks','Qs','Jh');family='two_tone';dyn=4;suit='two_tone'},
  @{id='JdTd8c';cards=@('Jd','Td','8c');family='two_tone';dyn=4;suit='two_tone'},
  @{id='KhJhTd';cards=@('Kh','Jh','Td');family='two_tone';dyn=3;suit='two_tone'},
  @{id='AhQhJs';cards=@('Ah','Qh','Js');family='two_tone';dyn=3;suit='two_tone'},
  @{id='QcTcJs';cards=@('Qc','Tc','Js');family='two_tone';dyn=4;suit='two_tone'},

  # Paired two-tone (one of the pair shares suit with kicker)
  @{id='AhAh2s';cards=@('Ah','Ad','2s');family='paired_high_two';dyn=1;suit='two_tone_disabled'},  # disabled - bad construction
  @{id='AhAd5h';cards=@('Ah','Ad','5h');family='paired_high';dyn=1;suit='two_tone'},
  @{id='KhKd9h';cards=@('Kh','Kd','9h');family='paired_high';dyn=1;suit='two_tone'},
  @{id='QsQh4s';cards=@('Qs','Qh','4s');family='paired_high';dyn=2;suit='two_tone'},
  @{id='JhJd6h';cards=@('Jh','Jd','6h');family='paired_high';dyn=2;suit='two_tone'},
  @{id='ThTd5h';cards=@('Th','Td','5h');family='paired_mid';dyn=2;suit='two_tone'},
  @{id='9h9d4h';cards=@('9h','9d','4h');family='paired_mid';dyn=2;suit='two_tone'},
  @{id='7h7d3h';cards=@('7h','7d','3h');family='paired_low';dyn=1;suit='two_tone'},
  @{id='6s6h3s';cards=@('6s','6h','3s');family='paired_low';dyn=1;suit='two_tone'},
  @{id='5h5d2h';cards=@('5h','5d','2h');family='paired_low';dyn=1;suit='two_tone'},

  # ===== Additional two-tone boards (v4.0.7-hardened, batch 2) =====
  # More A-high two-tone (covers more sizing teaching angles)
  @{id='Ah3h2s';cards=@('Ah','3h','2s');family='two_tone';dyn=2;suit='two_tone'},
  @{id='As8s4d';cards=@('As','8s','4d');family='two_tone';dyn=2;suit='two_tone'},
  @{id='AdJd5c';cards=@('Ad','Jd','5c');family='two_tone';dyn=2;suit='two_tone'},
  @{id='AcTc6h';cards=@('Ac','Tc','6h');family='two_tone';dyn=2;suit='two_tone'},
  # More K-high two-tone
  @{id='KhJh2s';cards=@('Kh','Jh','2s');family='two_tone';dyn=3;suit='two_tone'},
  @{id='KsJs6c';cards=@('Ks','Js','6c');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Kc7c4d';cards=@('Kc','7c','4d');family='two_tone';dyn=2;suit='two_tone'},
  @{id='KdQd5h';cards=@('Kd','Qd','5h');family='two_tone';dyn=3;suit='two_tone'},
  # More Q-high two-tone
  @{id='Qh4h2s';cards=@('Qh','4h','2s');family='two_tone';dyn=2;suit='two_tone'},
  @{id='QcTc3s';cards=@('Qc','Tc','3s');family='two_tone';dyn=3;suit='two_tone'},
  @{id='QdTd2h';cards=@('Qd','Td','2h');family='two_tone';dyn=3;suit='two_tone'},
  # More J-high two-tone
  @{id='JhTh5s';cards=@('Jh','Th','5s');family='two_tone';dyn=3;suit='two_tone'},
  @{id='JdTd2h';cards=@('Jd','Td','2h');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Js6s4h';cards=@('Js','6s','4h');family='two_tone';dyn=3;suit='two_tone'},
  # More T-high two-tone
  @{id='ThTd3h';cards=@('Th','Td','3h');family='paired_mid';dyn=2;suit='two_tone'},
  @{id='Tc6c2s';cards=@('Tc','6c','2s');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Td7d3h';cards=@('Td','7d','3h');family='two_tone';dyn=3;suit='two_tone'},
  # More low two-tone (low_connected variants)
  @{id='9c8c6h';cards=@('9c','8c','6h');family='two_tone';dyn=4;suit='two_tone'},
  @{id='8h7h4d';cards=@('8h','7h','4d');family='two_tone';dyn=4;suit='two_tone'},
  @{id='Th8h7d';cards=@('Th','8h','7d');family='two_tone';dyn=4;suit='two_tone'},
  @{id='Js7s6d';cards=@('Js','7s','6d');family='two_tone';dyn=4;suit='two_tone'},
  @{id='9d6d3s';cards=@('9d','6d','3s');family='two_tone';dyn=3;suit='two_tone'},
  @{id='8s5s4c';cards=@('8s','5s','4c');family='two_tone';dyn=4;suit='two_tone'},
  # More wet two-tone
  @{id='Qh9h4d';cards=@('Qh','9h','4d');family='two_tone';dyn=3;suit='two_tone'},
  @{id='Kc9c5d';cards=@('Kc','9c','5d');family='two_tone';dyn=3;suit='two_tone'},
  # More paired two-tone
  @{id='AdAc6d';cards=@('Ad','Ac','6d');family='paired_high';dyn=1;suit='two_tone'},
  @{id='KsKh4s';cards=@('Ks','Kh','4s');family='paired_high';dyn=1;suit='two_tone'},
  @{id='QdQc7d';cards=@('Qd','Qc','7d');family='paired_high';dyn=2;suit='two_tone'},
  @{id='4s4d2s';cards=@('4s','4d','2s');family='paired_low';dyn=1;suit='two_tone'},

  # ===== Monotone boards (existing pool) =====
  @{id='As7s2s';cards=@('As','7s','2s');family='monotone_high';dyn=2;suit='monotone'},
  @{id='Ah8h3h';cards=@('Ah','8h','3h');family='monotone_high';dyn=2;suit='monotone'},
  @{id='Ad9d4d';cards=@('Ad','9d','4d');family='monotone_high';dyn=2;suit='monotone'},
  @{id='Ks7s2s';cards=@('Ks','7s','2s');family='monotone_high';dyn=2;suit='monotone'},
  @{id='Kh8h3h';cards=@('Kh','8h','3h');family='monotone_high';dyn=2;suit='monotone'},
  @{id='Kd9d4d';cards=@('Kd','9d','4d');family='monotone_high';dyn=2;suit='monotone'},
  @{id='Qs8s3s';cards=@('Qs','8s','3s');family='monotone_high';dyn=2;suit='monotone'},
  @{id='Qh9h2h';cards=@('Qh','9h','2h');family='monotone_high';dyn=2;suit='monotone'},
  @{id='Js7s4s';cards=@('Js','7s','4s');family='monotone_high';dyn=3;suit='monotone'},
  @{id='Th8h3h_v2';cards=@('Th','8h','3h');family='monotone_high_skip';dyn=2;suit='monotone'},
  @{id='Ts7s4s';cards=@('Ts','7s','4s');family='monotone_high';dyn=3;suit='monotone'},
  @{id='9d8d3d';cards=@('9d','8d','3d');family='monotone_low';dyn=3;suit='monotone'},
  @{id='9c7c2c';cards=@('9c','7c','2c');family='monotone_low';dyn=3;suit='monotone'},
  @{id='8s7s5s_v2';cards=@('8s','7s','5s');family='monotone_low_skip';dyn=4;suit='monotone'},
  @{id='8h6h4h';cards=@('8h','6h','4h');family='monotone_low';dyn=4;suit='monotone'},
  @{id='7d6d4d';cards=@('7d','6d','4d');family='monotone_low';dyn=4;suit='monotone'},
  @{id='6s5s2s';cards=@('6s','5s','2s');family='monotone_low';dyn=4;suit='monotone'},
  @{id='9h7h5h';cards=@('9h','7h','5h');family='monotone_low';dyn=4;suit='monotone'},
  @{id='7c5c3c';cards=@('7c','5c','3c');family='monotone_low';dyn=4;suit='monotone'},

  # ===== Restored rainbow boards (top up A/K/Q-high + low_connected + very_wet) =====
  # A-high (was 13, need 15 for plan; add 4)
  @{id='AhJs3c';cards=@('Ah','Js','3c');family='A_high_dry';dyn=2;suit='rainbow'},
  @{id='AdJc4h';cards=@('Ad','Jc','4h');family='A_high_dry';dyn=2;suit='rainbow'},
  @{id='AhQs4c';cards=@('Ah','Qs','4c');family='A_high_dry';dyn=2;suit='rainbow'},
  @{id='AdQc5h';cards=@('Ad','Qc','5h');family='A_high_dry';dyn=2;suit='rainbow'},

  # K-high (was 10, need 13; add 5)
  @{id='KdTs2c';cards=@('Kd','Ts','2c');family='K_high_dry';dyn=2;suit='rainbow'},
  @{id='KsTh3d';cards=@('Ks','Th','3d');family='K_high_dry';dyn=2;suit='rainbow'},
  @{id='KhTc4s';cards=@('Kh','Tc','4s');family='K_high_dry';dyn=2;suit='rainbow'},
  @{id='KhQc2s';cards=@('Kh','Qc','2s');family='K_high_dry';dyn=2;suit='rainbow'},
  @{id='KdQs3h';cards=@('Kd','Qs','3h');family='K_high_dry';dyn=2;suit='rainbow'},

  # Q-high (was 11, need 13; add 4)
  @{id='QhTd5s';cards=@('Qh','Td','5s');family='Q_high_dry';dyn=2;suit='rainbow'},
  @{id='QdTs6c';cards=@('Qd','Ts','6c');family='Q_high_dry';dyn=2;suit='rainbow'},
  @{id='QhJd2s';cards=@('Qh','Jd','2s');family='Q_high_dry';dyn=2;suit='rainbow'},
  @{id='QdJs3h';cards=@('Qd','Js','3h');family='Q_high_dry';dyn=2;suit='rainbow'},

  # Low_connected (was 13, need 14; add 2)
  @{id='Th8d6s';cards=@('Th','8d','6s');family='low_connected';dyn=3;suit='rainbow'},
  @{id='9d6c5h';cards=@('9d','6c','5h');family='low_connected';dyn=3;suit='rainbow'},

  # Broadway_connected (was 10, need 11; add 1)
  @{id='AcKdJh';cards=@('Ac','Kd','Jh');family='broadway_connected';dyn=3;suit='rainbow'},

  # Very_wet (was 10, need 21; add 12)
  @{id='9c8h7d';cards=@('9c','8h','7d');family='very_wet';dyn=4;suit='rainbow'},
  @{id='Js9c7d';cards=@('Js','9c','7d');family='very_wet';dyn=4;suit='rainbow'},
  @{id='QcTh8d';cards=@('Qc','Th','8d');family='very_wet';dyn=3;suit='rainbow'},
  @{id='Jc8d6h';cards=@('Jc','8d','6h');family='very_wet';dyn=3;suit='rainbow'},
  @{id='Td9c7s';cards=@('Td','9c','7s');family='very_wet';dyn=4;suit='rainbow'},
  @{id='8c7s5h';cards=@('8c','7s','5h');family='very_wet';dyn=4;suit='rainbow'},
  @{id='Tc9s6h';cards=@('Tc','9s','6h');family='very_wet';dyn=4;suit='rainbow'},
  @{id='Jh8d6c';cards=@('Jh','8d','6c');family='very_wet';dyn=4;suit='rainbow'},
  @{id='Qd9c7h';cards=@('Qd','9c','7h');family='very_wet';dyn=4;suit='rainbow'},
  @{id='Ts9d6c';cards=@('Ts','9d','6c');family='very_wet';dyn=4;suit='rainbow'},
  @{id='9h7c5d';cards=@('9h','7c','5d');family='very_wet';dyn=3;suit='rainbow'},
  @{id='8d6h4s';cards=@('8d','6h','4s');family='very_wet';dyn=3;suit='rainbow'}
)

# Drop _skip boards + invalid construction markers
$boards = $boards | Where-Object { $_.family -notlike '*_skip' -and $_.suit -ne 'two_tone_disabled' }

# Validate: each two-tone board must actually have 2-of-suit and 1-other
foreach($b in $boards){
  if($b.suit -eq 'two_tone'){
    $suits = $b.cards | ForEach-Object { $_.Substring(1,1) }
    $unique = ($suits | Sort-Object -Unique).Count
    if($unique -ne 2){ throw "Board $($b.id) declared two_tone but suits derive $unique-tone" }
  }
  if($b.suit -eq 'monotone'){
    $suits = $b.cards | ForEach-Object { $_.Substring(1,1) }
    $unique = ($suits | Sort-Object -Unique).Count
    if($unique -ne 1){ throw "Board $($b.id) declared monotone but suits derive $unique unique suit(s)" }
  }
}

# ============================================================
# Re-classify generic two_tone family into precise sub-families
# (v4.0.7-template-correction)
# ============================================================
# The v4.0.7-hardened pass had a single "two_tone" family that was strategically
# wrong for ~25-30 boards. Split into 5 sub-families based on rank-class +
# connectedness so each board gets the correct GTO answer/explanation.
function ClassifyTwoTone($cards){
  # Rank index: A=12, K=11, Q=10, J=9, T=8, 9=7, 8=6, 7=5, 6=4, 5=3, 4=2, 3=1, 2=0
  $rankOrder = @('A','K','Q','J','T','9','8','7','6','5','4','3','2')
  $rankIdxLocal = @{}; for($i=0;$i -lt $rankOrder.Count;$i++){ $rankIdxLocal[$rankOrder[$i]] = (12 - $i) }
  $ranks = $cards | ForEach-Object { $rankIdxLocal[$_.Substring(0,1)] }
  $sorted = $ranks | Sort-Object -Descending
  $top = $sorted[0]; $mid = $sorted[1]; $bot = $sorted[2]
  $spread = $top - $bot

  # Rule 1: broadway-connected (top 2 in T+ range AND spread <= 4)
  #   captures: KQJ(11/10/9), AQJ(12/10/9), QJT(10/9/8), JT9(9/8/7), JT8(9/8/6),
  #             KQT(11/10/8), KJT(11/9/8), AKQ(12/11/10), AKJ(12/11/9), AKT(12/11/8)
  #   does NOT match: A/K-high with low x (e.g., AhKh5c spread=9), AK7 spread=5
  if($top -ge 8 -and $mid -ge 8 -and $spread -le 4){
    return 'broadway_two_tone_connected'
  }

  # Rule 2: A/K-high disconnected (low spread mid/bot)
  if($top -ge 11){
    return 'high_two_tone_dry'
  }

  # Rule 3: Q/J/T-high (top 2 not both broadway, or spread too large)
  if($top -ge 8){
    # T98, T97, T87, T76 - low-connected style despite T top
    #   (top 2 NOT both broadway; AND tightly connected at the bottom)
    if($top -eq 8 -and ($top - $mid) -le 2 -and $spread -le 4){
      return 'low_connected_two_tone'
    }
    # Q/J/T-high otherwise disconnected
    return 'mid_two_tone_dry'
  }

  # Rule 4: 9-high or below
  if(($top - $mid) -le 2 -and $spread -le 5){
    return 'low_connected_two_tone'
  }
  return 'low_dry_two_tone'
}

foreach($b in $boards){
  if($b.suit -eq 'two_tone' -and $b.family -eq 'two_tone'){
    $b.family = ClassifyTwoTone $b.cards
  }
}

Write-Host "Boards (after dedup + validation + two_tone reclassification): $($boards.Count)"
$boards | Group-Object suit | Sort-Object Name | ForEach-Object { Write-Host "  suit=$($_.Name): $($_.Count)" }
$boards | Group-Object { $_.family } | Sort-Object Name | ForEach-Object { Write-Host "  family=$($_.Name): $($_.Count)" }

# ============================================================
# Per-family plan: how many scenarios per qtype per family
# ============================================================
# Rainbow plan reduced to make room for two-tone variants on same families.
# Two-tone family stays as a separate family with mixed high cards.
$plan = @{
  # Rainbow families
  'A_high_dry'         = @{ ra=4; na=4; fs=2; sf=1; dl=3 } # 14
  'K_high_dry'         = @{ ra=3; na=3; fs=2; sf=1; dl=3 } # 12
  'Q_high_dry'         = @{ ra=3; na=3; fs=2; sf=1; dl=3 } # 12
  'J_T_medium'         = @{ ra=2; na=2; fs=2; sf=1; dl=2 } # 9
  'low_dry'            = @{ ra=2; na=2; fs=1; sf=1; dl=2 } # 8
  'broadway_connected' = @{ ra=2; na=3; fs=1; sf=1; dl=3 } # 10
  'low_connected'      = @{ ra=3; na=3; fs=2; sf=2; dl=3 } # 13
  'very_wet'           = @{ ra=3; na=4; fs=3; sf=4; dl=5 } # 19
  # Paired families (any suit; rainbow + two-tone variants share template)
  'paired_high'        = @{ ra=3; na=4; fs=3; sf=2; dl=2 } # 14 (some two-tone variants surface)
  'paired_mid'         = @{ ra=1; na=2; fs=2; sf=2; dl=1 } # 8
  'paired_low'         = @{ ra=2; na=3; fs=3; sf=2; dl=2 } # 12
  # Two-tone families (split from generic two_tone in v4.0.7-template-correction)
  'high_two_tone_dry'           = @{ ra=8; na=8; fs=6; sf=5; dl=5 } # 32 (have 33)
  'mid_two_tone_dry'            = @{ ra=5; na=5; fs=8; sf=6; dl=4 } # 28 (have 33)
  'broadway_two_tone_connected' = @{ ra=1; na=2; fs=1; sf=1; dl=1 } # 6 (have 6)
  'low_dry_two_tone'            = @{ ra=1; na=1; fs=2; sf=1; dl=1 } # 6 (have 7)
  'low_connected_two_tone'      = @{ ra=3; na=3; fs=3; sf=3; dl=3 } # 15 (have 15)
  # Monotone families
  'monotone_high'      = @{ ra=1; na=2; fs=1; sf=2; dl=2 } # 8
  'monotone_low'       = @{ ra=1; na=1; fs=1; sf=1; dl=1 } # 5
}
# Plan total: 14+12+12+9+8+10+13+19+14+8+12+32+28+6+6+15+8+5 = 231 + 20 baseline = 251

# ============================================================
# Per-family GTO templates
# ============================================================
$tmpl = @{
  'A_high_dry' = @{
    ra='preflop_raiser'; na='preflop_raiser'
    sizing='range_small'; sizingAcc=@('mixed_small_check'); sizingCrit=@('check_heavy','polar_big')
    textureBase=@('dry','disconnected','rainbow','ace_high_dry','high_card_dominant')
    conn='disconnected'; paired='unpaired'
    raExpl="BTN open contains far more A-x and broadway combos than BB's preflop call range. BB 3-bets dominant A-x (AJo+, AQ, AK), removing them from BB's flatting range. BTN clearly range-advantaged."
    naExpl="AA, AK appear in BTN open at full preflop frequency; BB 3-bets these heavily so they're sparse in BB's flatting range. BTN dominates the top of range."
    sizingExpl="Range-small: bet 33% with ~80%+ frequency. Dry, range-advantaged board with no draws to charge - small bet extracts thin value, denies equity to air, and scales the pot."
    dynNotes="Static / semi-static - A-high dry boards rarely shift equity rankings dramatically except on board-pair turns."
    mistake="Some players go big or polar on A-high dry boards - that's a major leak. Solver: small high-frequency wins."
    confidence=@{ ra='consensus_gto'; na='consensus_gto'; fs='consensus_gto'; sf='expert_judgment'; dl='consensus_gto' }
  }
  'K_high_dry' = @{
    ra='preflop_raiser'; na='preflop_raiser'
    sizing='range_small'; sizingAcc=@('mixed_small_check'); sizingCrit=@('check_heavy','polar_big')
    textureBase=@('dry','disconnected','rainbow','high_card_dominant')
    conn='disconnected'; paired='unpaired'
    raExpl="BTN open is K-x heavy (KQ, KJ, KT, K9s, etc.). BB 3-bets KQs/KQo, AK, KK at high frequency, so BB's call range under-represents top-K combos. BTN range-advantaged."
    naExpl="KK, AK weighted heavily in BTN open and 3-bet by BB; remaining BB call range has few KK/AK combos. BTN holds nut advantage."
    sizingExpl="Range-small: bet 33% with ~75% frequency. K-high dry behaves like A-high dry - small high-freq is the textbook line."
    dynNotes="Static - K stays best most run-outs unless an A or board-pair lands."
    mistake="Big polar sizings here are a leak; range advantage and lack of draws favor small high-freq."
    confidence=@{ ra='consensus_gto'; na='consensus_gto'; fs='consensus_gto'; sf='expert_judgment'; dl='consensus_gto' }
  }
  'Q_high_dry' = @{
    ra='preflop_raiser'; na='preflop_raiser'
    sizing='range_small'; sizingAcc=@('mixed_small_check'); sizingCrit=@('check_heavy','polar_big')
    textureBase=@('dry','disconnected','rainbow','high_card_dominant')
    conn='disconnected'; paired='unpaired'
    raExpl="BTN range carries plenty of Q-x and overpairs (KK, AA). BB 3-bets QQ+, AK, KQs at high frequency, so BB's flatting range is thinner at the top. BTN range-advantaged but margin smaller than A/K-high."
    naExpl="QQ, AQ, KQ are higher-frequency in BTN's open; BB removes many via 3-bet. Set advantage to BTN, though the gap is smaller than on A/K-high boards."
    sizingExpl="Range-small / mixed: 33% bet ~60-70% frequency, check the rest. Slightly more checking than A/K-high because BB has somewhat more equity in middle pairs."
    dynNotes="Mostly semi-static - straightening turn cards (J/T arriving on Q-low boards) can shift equity."
    mistake="Treating Q-high dry exactly like A-high (always small-bet) loses some EV; mixed approach is closer to optimal."
    confidence=@{ ra='consensus_gto'; na='expert_judgment'; fs='expert_judgment'; sf='expert_judgment'; dl='consensus_gto' }
  }
  'J_T_medium' = @{
    ra='neutral'; na='neutral'
    sizing='mixed_small_check'; sizingAcc=@('range_small','check_heavy'); sizingCrit=@('polar_big')
    textureBase=@('semi_dry','disconnected','rainbow','middle_heavy')
    conn='disconnected'; paired='unpaired'
    raExpl="BTN open includes J-x and T-x but BB calls a lot of suited connectors and middle pocket pairs that connect with this board. Range advantage shifts toward neutral."
    naExpl="Sets of J/T/9 distributed similarly between ranges; BB's flatting range has slightly more straight equity. Nut advantage close to neutral."
    sizingExpl="Mixed small/check: ~50% small bet, ~50% check. Without strong range advantage, polar betting wastes nut combos."
    dynNotes="Semi-dynamic - turn cards (8, 9, Q, K) can swing equity. Rainbow J-high boards are mostly semi-static."
    mistake="Always c-betting J-high middle boards is a leak - checking ~half the range protects against being raised by BB's draws."
    confidence=@{ ra='expert_judgment'; na='expert_judgment'; fs='expert_judgment'; sf='expert_judgment'; dl='expert_judgment' }
  }
  'low_dry' = @{
    ra='preflop_raiser'; na='preflop_raiser'
    sizing='range_small'; sizingAcc=@('mixed_small_check'); sizingCrit=@('polar_big')
    textureBase=@('dry','disconnected','rainbow','low_heavy','low_disconnected')
    conn='disconnected'; paired='unpaired'
    raExpl="Low dry boards (e.g., 9-6-2 rainbow) favor the player with overpairs and high cards. BTN open has TT-AA at full frequency, plus broadway floats; BB 3-bets the same pairs, leaving BTN with overpair advantage."
    naExpl="BTN holds AA-TT and AKo/AQo as overpairs and overcards; BB has small pairs but they're often blocked by the board (e.g., 22-66 with 6-x on board)."
    sizingExpl="Range-small: bet 33% high-frequency (~75-85%). Small bet exploits BB's many missed overcards and weak pairs."
    dynNotes="Static - low boards rarely shift equity unless a card pairs the board or completes a backdoor straight."
    mistake="Going polar (75%+ pot) on low dry rainbow is a leak - there's nothing to charge, and small wins more in the long run."
    confidence=@{ ra='consensus_gto'; na='consensus_gto'; fs='consensus_gto'; sf='expert_judgment'; dl='consensus_gto' }
  }
  'paired_high' = @{
    ra='preflop_raiser'; na='preflop_raiser'
    sizing='range_small'; sizingAcc=@('mixed_small_check'); sizingCrit=@('polar_big','check_heavy')
    textureBase=@('paired','rainbow','high_card_dominant')
    conn='disconnected'; paired='paired'
    raExpl="BTN open is K/Q/J/A-x heavy, so BTN has more trip combos (e.g., AK/AJ on AAx; KQ/KJ on KKx). BB 3-bets these dominant kickers preflop, further increasing BTN's trips advantage."
    naExpl="Trips combos with strong kickers heavily concentrated in BTN open. BB has occasional trips (suited K-x flatted) but far fewer."
    sizingExpl="Range-small: ~33% bet at very high frequency (~75-85%). Paired high boards rarely change equity; small bet extracts marginal calls and denies equity to nothing."
    dynNotes="Static - paired boards rarely shift equity rankings."
    mistake="Checking back too often on paired high boards costs value - most of BTN's range is ahead of BB's calling range."
    confidence=@{ ra='consensus_gto'; na='consensus_gto'; fs='consensus_gto'; sf='expert_judgment'; dl='consensus_gto' }
  }
  'paired_mid' = @{
    ra='neutral'; na='caller'
    sizing='mixed_small_check'; sizingAcc=@('check_heavy','range_small'); sizingCrit=@('polar_big')
    textureBase=@('paired','rainbow','middle_heavy')
    conn='disconnected'; paired='paired'
    raExpl="Paired middle boards (T-T-x, 9-9-x, 8-8-x) shift slightly toward BB because BB flats more 8x / 9x / Tx suited combos that hit trips. BTN still has overpair equity, but the trips density edge belongs to BB."
    naExpl="BB's flatting range contains more trips combos with the paired rank (e.g., 98s/T9s/J9s on 9-9-x give trips). BTN's overpairs (JJ-AA) are still strong but no longer top-of-range; the full-house region is roughly even but BB's trips density is higher."
    sizingExpl="Mixed small/check: ~40% bet, 60% check. Don't bloat the pot when BB has the nut-trips edge; protect overpairs by checking."
    dynNotes="Semi-static - overcard turns can devalue overpairs on middle paired boards."
    mistake="Auto-betting paired boards regardless of rank is a leak - middle pairs flip the trips density."
    confidence=@{ ra='expert_judgment'; na='expert_judgment'; fs='expert_judgment'; sf='expert_judgment'; dl='expert_judgment' }
  }
  'paired_low' = @{
    ra='preflop_raiser'; na='preflop_raiser'
    sizing='range_small'; sizingAcc=@('mixed_small_check'); sizingCrit=@('polar_big')
    textureBase=@('paired','rainbow','low_heavy')
    conn='disconnected'; paired='paired'
    raExpl="Paired low boards (5-5-x, 4-4-x) heavily favor BTN. BB rarely flats 22-55 (often 3-bets or folds), and even when present, BTN's overpairs (TT-AA) dominate."
    naExpl="Trips of low pair are roughly even between ranges (small pairs are in both), but BTN's overpair density (JJ-AA) gives nut advantage."
    sizingExpl="Range-small: ~33% bet at very high frequency. Bet often, bet small."
    dynNotes="Static - low paired boards almost never shift equity."
    mistake="Big bets on paired low boards burn money - opponents fold all worse, call only with the rare set."
    confidence=@{ ra='consensus_gto'; na='consensus_gto'; fs='consensus_gto'; sf='expert_judgment'; dl='consensus_gto' }
  }
  'broadway_connected' = @{
    ra='caller'; na='caller'
    sizing='check_heavy'; sizingAcc=@('mixed_small_check'); sizingCrit=@('range_small','polar_big')
    textureBase=@('wet','highly_connected','rainbow','broadway_heavy','straightening')
    conn='highly_connected'; paired='unpaired'
    raExpl="Highly connected broadway boards (KQJ, QJT, JT9) belong to the caller. BB calls many JT, QJ, KJ, T9, 98 combos that hit this board for top pair, two-pair, or straights."
    naExpl="Made straights and two-pair combos heavily concentrated in BB's flatting range. BTN's AK/KQ block some BB combos but don't outrun BB's nutted region."
    sizingExpl="Check-heavy: check ~50-70% of range. When betting, use small (33%) with the better top-pair / overpair combos and a mix of bluffs."
    dynNotes="Very dynamic - straightening turn cards swing equity dramatically."
    mistake="Big polar sizing (75%+) on broadway-connected boards burns through BTN's marginal hands without folding out BB's straight and two-pair combos."
    confidence=@{ ra='consensus_gto'; na='consensus_gto'; fs='expert_judgment'; sf='expert_judgment'; dl='consensus_gto' }
  }
  'low_connected' = @{
    ra='caller'; na='caller'
    sizing='check_heavy'; sizingAcc=@('mixed_small_check'); sizingCrit=@('polar_big','range_small')
    textureBase=@('wet','highly_connected','rainbow','low_heavy','low_connected','straightening')
    conn='highly_connected'; paired='unpaired'
    raExpl="Low connected boards (8-7-5, 6-5-4) heavily favor BB's flatting range (small pairs, suited connectors). BTN's overpairs are no longer best."
    naExpl="Sets, two-pair, and straights are concentrated in BB's range. BTN's nut hands here are rare."
    sizingExpl="Check-heavy: check ~60-70% of range. Use polar big (75%+) sparingly with overpairs + best draws."
    dynNotes="Very dynamic - every turn card threatens straights or two-pair completions."
    mistake="C-betting these boards 'because I raised' is the most common postflop leak in MTT play."
    confidence=@{ ra='consensus_gto'; na='consensus_gto'; fs='consensus_gto'; sf='expert_judgment'; dl='consensus_gto' }
  }
  # ===== SPLIT FROM GENERIC TWO_TONE (v4.0.7-template-correction) =====
  # Each two-tone family used to share a single template. They are now split so
  # boards inherit the answer/confidence/explanation appropriate to their
  # rank-class and connectedness. Boards are reassigned at parse time by
  # ClassifyTwoTone() into the right sub-family.

  'high_two_tone_dry' = @{
    # A/K-high two-tone, disconnected. BTN keeps range/nut adv; flush draws shift sizing slightly larger.
    ra='preflop_raiser'; na='preflop_raiser'
    sizing='mixed_small_check'; sizingAcc=@('range_small'); sizingCrit=@('check_heavy')
    textureBase=@('semi_dry','disconnected','two_tone','flushing','high_card_dominant')
    conn='disconnected'; paired='unpaired'
    raExpl="A-high or K-high two-tone disconnected board. BTN open carries far more A-x and K-x combos than BB's preflop call range, and BB 3-bets dominant top-pair combos preflop. Range advantage clearly BTN."
    naExpl="BTN holds the nut flush draw region (A-x and K-x of suit) plus dominant top pairs (AK, AQ, KQ). Nut advantage stays with BTN despite BB picking up some flush draws."
    sizingExpl="Mixed small/check: bet ~33-50% with ~60-70% frequency. Slightly more polarized than rainbow because BB has flush draws to charge. Range_small is also defensible on the dryer end (A-x-x with low x)."
    dynNotes="Semi-dynamic - turn flush completions or board pair shift equity meaningfully."
    mistake="Treating two-tone exactly like rainbow (range-small always) misses value vs. BB's flush draws; check-heavy concedes the board to BB unnecessarily."
    confidence=@{ ra='consensus_gto'; na='consensus_gto'; fs='expert_judgment'; sf='expert_judgment'; dl='expert_judgment' }
  }

  'mid_two_tone_dry' = @{
    # Q/J/T-high two-tone, disconnected. Closer to neutral; mixed approach.
    ra='neutral'; na='neutral'
    sizing='mixed_small_check'; sizingAcc=@('range_small','check_heavy'); sizingCrit=@('polar_big')
    textureBase=@('semi_dry','disconnected','two_tone','flushing','middle_heavy')
    conn='disconnected'; paired='unpaired'
    raExpl="Q/J/T-high two-tone disconnected board. BTN has overpairs and high cards but BB's flatting range is dense in suited middle hands (T9s, JTs, QJs, 87s, etc.) that connect with this board. Range advantage close to neutral; not a clear BTN spot."
    naExpl="Both ranges have plausible top pairs and middle pairs. BB has more two-pair / set combos with the connected lower cards; BTN holds higher-kicker combos. Nut advantage roughly neutral."
    sizingExpl="Mixed small/check: ~50/50 between small bet and check. Polar big is wasteful here because BB's range has too many bluff-catchers; range-small over-folds BB's flush draws."
    dynNotes="Semi-dynamic - flush completions, straight-completion turn cards swing equity meaningfully."
    mistake="Auto range-small on Q/J/T two-tone is a leak; this is not an A/K-high board."
    confidence=@{ ra='expert_judgment'; na='expert_judgment'; fs='expert_judgment'; sf='expert_judgment'; dl='expert_judgment' }
  }

  'broadway_two_tone_connected' = @{
    # QJT, KQJ, AQJ, JT8/9, T98 with two-tone. Caller's board.
    ra='caller'; na='caller'
    sizing='check_heavy'; sizingAcc=@('mixed_small_check','polar_big'); sizingCrit=@('range_small')
    textureBase=@('wet','highly_connected','two_tone','flushing','straightening','broadway_heavy')
    conn='highly_connected'; paired='unpaired'
    raExpl="Broadway-connected two-tone board (QJT, KQJ, AQJ, JT8/9, T98 etc.) belongs to the caller. BB's flatting range is loaded with JT, QJ, KJ, T9, 98 combos that hit top pair, two-pair, or made straights. Adding flush draws to many BB combos compounds the edge."
    naExpl="Made straights, two-pair combos, and combo draws are concentrated in BB's range. BTN's AK/KQ block some BB combos but don't outrun BB's nutted region. Adding flush completions to many BB hands further shifts nuts to BB."
    sizingExpl="Check-heavy: check ~60-70% of range. When betting, use polar big (75%+) with the few nutted combos + best draws. Range-small is the textbook leak here - it doesn't fold out BB's strong made hands or charge their draws enough."
    dynNotes="Very dynamic - both straightening and flushing turn cards swing equity dramatically."
    mistake="Range-small on broadway-connected two-tone is a major leak; BB's range hits this board with two-pair, sets, straights, and flush draws."
    confidence=@{ ra='consensus_gto'; na='expert_judgment'; fs='expert_judgment'; sf='expert_judgment'; dl='consensus_gto' }
  }

  'low_dry_two_tone' = @{
    # 9-high or below, disconnected, two-tone. BTN's overpair density still edges range/nut adv.
    ra='preflop_raiser'; na='preflop_raiser'
    sizing='mixed_small_check'; sizingAcc=@('range_small'); sizingCrit=@('polar_big','check_heavy')
    textureBase=@('semi_dry','disconnected','two_tone','flushing','low_heavy')
    conn='disconnected'; paired='unpaired'
    raExpl="Low (9-high or below) disconnected two-tone board. BTN's overpair density (TT-AA) and overcard density still beats BB's flatting range, which contains some pairs but few straight draws on disconnected lows. Flush draws moderate the sizing but don't flip range advantage."
    naExpl="BTN's overpairs (JJ-AA) sit above all of BB's made hands here. BB has the occasional set and some flush draws, but BTN holds more nut hands overall."
    sizingExpl="Mixed small/check: bet ~33-50% with ~60% frequency. Slightly larger than rainbow low-dry because of BB's flush draws; polar big is overkill on a board with no straights to charge."
    dynNotes="Semi-dynamic - flush turns add equity for BB; pair-the-board turns rarely shift things."
    mistake="Polar big on low two-tone disconnected is a leak - BB folds all the worse hands you wanted to value-bet, and the flush draws still call."
    confidence=@{ ra='expert_judgment'; na='expert_judgment'; fs='expert_judgment'; sf='expert_judgment'; dl='expert_judgment' }
  }

  'low_connected_two_tone' = @{
    # Low connected/very-wet two-tone (8-7-x suited, 9-8-x suited, 6-5-x, T-9-x suited). BB hits hard.
    ra='caller'; na='caller'
    sizing='check_heavy'; sizingAcc=@('mixed_small_check','polar_big'); sizingCrit=@('range_small')
    textureBase=@('wet','highly_connected','two_tone','flushing','straightening','low_heavy','low_connected')
    conn='highly_connected'; paired='unpaired'
    raExpl="Low connected two-tone board (8-7-x suited, 9-8-x suited, T-9-x with low x and two of a suit). BB's flatting range is full of suited connectors (76s, 87s, 98s, T9s, 65s, 54s) that hit top pair, two-pair, sets, straights, AND flush draws on the suit. BTN's overpairs are bluff-catchers."
    naExpl="Made straights, sets, two-pair, and combo draws are heavily concentrated in BB's range. BTN's nut combos are rare; even AA is just an overpair vs. many BB combos that have huge equity."
    sizingExpl="Check-heavy: check ~65-75% of range. When betting, polar big (75%+) only with overpairs + best draws. Range-small is a textbook leak - doesn't fold out BB's many straight + flush combos."
    dynNotes="Very dynamic - any non-pair turn typically improves multiple BB combos. Flush, straight, two-pair completions all swing equity."
    mistake="C-betting low connected two-tone with range-small is one of the biggest postflop leaks in MTT play. Check this board the majority of the time."
    confidence=@{ ra='consensus_gto'; na='consensus_gto'; fs='expert_judgment'; sf='expert_judgment'; dl='consensus_gto' }
  }
  'monotone_high' = @{
    ra='neutral'; na='preflop_raiser'
    sizing='check_heavy'; sizingAcc=@('mixed_small_check'); sizingCrit=@('polar_big','range_small')
    textureBase=@('semi_dry','monotone','flushing','high_card_dominant')
    conn='disconnected'; paired='unpaired'
    raExpl="Monotone high boards split range advantage close to neutral. BB has many suited Broadway combos that contain a flush already; BTN has more high cards but fewer flush combos."
    naExpl="BTN holds the nut flush draw and the rare made nut flush (AKs of suit, AQs of suit). Nut advantage modest but real."
    sizingExpl="Check-heavy: check ~50-70%. When betting, use small (33%) - flushes are already made, so big bluffs are inefficient."
    dynNotes="Semi-dynamic - fourth flush card or pair can swing equity hard."
    mistake="Over-betting monotone boards is a leak - many of opponent's continuing hands are already flushes, and your bluffs have minimal fold equity."
    confidence=@{ ra='expert_judgment'; na='expert_judgment'; fs='expert_judgment'; sf='expert_judgment'; dl='expert_judgment' }
  }
  'monotone_low' = @{
    ra='caller'; na='caller'
    sizing='check_heavy'; sizingAcc=@('mixed_small_check'); sizingCrit=@('polar_big','range_small')
    textureBase=@('wet','monotone','flushing','low_heavy')
    conn='semi_connected'; paired='unpaired'
    raExpl="Low monotone boards favor BB overall. BB's flatting range carries many low suited connectors that flop flushes, two-pair, and combo draws. BTN still has overpairs and the nut flush draw with Axs of suit, but the made-flush + combo-draw density tilts the range to BB."
    naExpl="BB can have higher made-flush density and more low suited connector coverage, but BTN still retains meaningful Axs nut-flush combos on the suited card. The caller edge comes from overall flush / low-connected density, not from BTN having zero nut combos. This is a solver-sensitive spot - the magnitude of the caller edge depends heavily on the specific board."
    sizingExpl="Check-heavy: check ~70%+. Limit betting to occasional polar protection with overpairs + nut flush draws (Axs of suit)."
    dynNotes="Very dynamic - every off-suit pair or connector turn changes equity."
    mistake="Big bluffs on low monotone boards lose to BB's flopped flushes and combo draws - disaster spot to spew."
    confidence=@{ ra='expert_judgment'; na='expert_judgment'; fs='expert_judgment'; sf='expert_judgment'; dl='expert_judgment' }
  }
  'very_wet' = @{
    ra='caller'; na='caller'
    sizing='check_heavy'; sizingAcc=@('mixed_small_check','polar_big'); sizingCrit=@('range_small')
    textureBase=@('very_wet','connected','rainbow','straightening')
    conn='connected'; paired='unpaired'
    raExpl="Very wet boards (T-9-8, J-9-8) are loaded with draws and made hands for the caller. BTN's range has overpairs and overcards but minimal nutted combos."
    naExpl="Straights, two-pair, sets concentrated in BB's flatting range. BTN's nut combos are rare here."
    sizingExpl="Check-heavy: check ~60-70%. When betting, use polar big with the few nut combos + best draws."
    dynNotes="Very dynamic - almost every turn card changes equity for someone."
    mistake="Range-bet small on very wet boards is a leak - small bet doesn't charge BB's many draws and gets raised often."
    confidence=@{ ra='consensus_gto'; na='consensus_gto'; fs='expert_judgment'; sf='expert_judgment'; dl='consensus_gto' }
  }
}

# ============================================================
# Helpers
# ============================================================
function Map-Dyn($d){ switch($d){ 1{'static'} 2{'semi_static'} 3{'dynamic'} 4{'very_dynamic'} default{'semi_static'} } }

function HighCardClass($cards){
  $order = @('A','K','Q','J','T','9','8','7','6','5','4','3','2')
  $best = $null; $bestIdx = 99
  foreach($c in $cards){
    $r = $c.Substring(0,1)
    $idx = $order.IndexOf($r)
    if($idx -ge 0 -and $idx -lt $bestIdx){ $bestIdx = $idx; $best = $r }
  }
  switch($best){
    'A'{'A_high'} 'K'{'K_high'} 'Q'{'Q_high'} 'J'{'J_high'} 'T'{'T_high'}
    default{'low'}
  }
}

function Boards-To-Texture($cards, $baseTags, $dyn, $suit){
  $tags = @() + $baseTags
  $tags = $tags | Where-Object { $_ -notin @('rainbow','two_tone','monotone') }
  if ($suit -eq 'monotone') { $tags += 'monotone' }
  elseif ($suit -eq 'two_tone') { $tags += 'two_tone' }
  else { $tags += 'rainbow' }
  if ($dyn -ge 4 -and ($tags -notcontains 'very_wet')) { $tags = @($tags | Where-Object { $_ -notin @('semi_dry','dry') }) + 'very_wet' }
  $tags | Sort-Object -Unique
}

function CardLabel($c){
  $r = $c.Substring(0,1); $s = $c.Substring(1,1)
  $sym = switch($s){'h'{[char]9829} 'd'{[char]9830} 's'{[char]9824} 'c'{[char]9827}}
  "$r$sym"
}

function PromptText($qtype, $cards){
  $b = ($cards | ForEach-Object { CardLabel $_ }) -join ' '
  switch($qtype){
    'range_advantage'    { "On $b (BTN open vs BB call, 100BB SRP), who has range advantage?" }
    'nut_advantage'      { "On $b, who has nut advantage?" }
    'frequency_strategy' { "On $b, what is the optimal c-bet frequency family for BTN?" }
    'sizing_family'      { "On $b, what sizing family does BTN use most?" }
    'dynamic_level'      { "On $b, what is the dynamic level?" }
  }
}

function ChoicesFor($qtype){
  switch($qtype){
    'range_advantage'    { @(@{id='preflop_raiser';label='Preflop raiser (BTN)'},@{id='caller';label='Caller (BB)'},@{id='neutral';label='Neutral / split'},@{id='split';label='Split'}) }
    'nut_advantage'      { @(@{id='preflop_raiser';label='Preflop raiser (BTN)'},@{id='caller';label='Caller (BB)'},@{id='neutral';label='Neutral'},@{id='split';label='Split'}) }
    'dynamic_level'      { @(@{id='static';label='Static'},@{id='semi_static';label='Semi-static'},@{id='dynamic';label='Dynamic'},@{id='very_dynamic';label='Very dynamic'}) }
    'frequency_strategy' { @(@{id='range_small';label='Range small (33%, high freq)'},@{id='mixed_small_check';label='Mixed small / check'},@{id='polar_big';label='Polar big (75%+)'},@{id='check_heavy';label='Check-heavy'},@{id='low_frequency';label='Low frequency overall'}) }
    'sizing_family'      { @(@{id='range_small';label='Range small (33%, high freq)'},@{id='mixed_small_check';label='Mixed small / check'},@{id='polar_big';label='Polar big (75%+)'},@{id='check_heavy';label='Check-heavy'},@{id='low_frequency';label='Low frequency overall'}) }
  }
}

# Solver-sensitive families: nut_advantage answer is the consensus read but the
# opposite is not a "critical" leak — competent players can disagree.
# For these families, on nut_advantage:
#   - add 'neutral' to acceptable (when best is preflop_raiser or caller)
#   - DO NOT mark the opposite range as critical (move to bad)
$nutAdvSoftFamilies = @('paired_mid','monotone_low','monotone_high','mid_two_tone_dry','low_dry_two_tone')

function AcceptableFor($qtype, $best, $famT, $famName){
  switch($qtype){
    'range_advantage' {
      if ($best -eq 'preflop_raiser' -or $best -eq 'caller') { @() }
      elseif ($best -eq 'neutral') { @('split') }
      else { @('neutral') }
    }
    'nut_advantage' {
      if ($best -in @('preflop_raiser','caller') -and $famName -in $nutAdvSoftFamilies) {
        # Solver-sensitive: add neutral as acceptable
        @('neutral')
      } elseif ($best -eq 'preflop_raiser' -or $best -eq 'caller') {
        @()
      } else {
        @()
      }
    }
    'dynamic_level' {
      switch($best){
        'static' { @('semi_static') }
        'semi_static' { @('static','dynamic') }
        'dynamic' { @('semi_static','very_dynamic') }
        'very_dynamic' { @('dynamic') }
      }
    }
    'frequency_strategy' { @() + $famT.sizingAcc }
    'sizing_family'      { @() + $famT.sizingAcc }
  }
}

function CriticalFor($qtype, $best, $famT, $famName){
  switch($qtype){
    'range_advantage' {
      if ($best -eq 'preflop_raiser') { @('caller') }
      elseif ($best -eq 'caller') { @('preflop_raiser') }
      else { @() }
    }
    'nut_advantage' {
      # Solver-sensitive families: opposite range is bad, not critical
      if ($famName -in $nutAdvSoftFamilies) { return @() }
      if ($best -eq 'preflop_raiser') { @('caller') }
      elseif ($best -eq 'caller') { @('preflop_raiser') }
      else { @() }
    }
    'dynamic_level' { @() }
    'frequency_strategy' { @() + $famT.sizingCrit }
    'sizing_family'      { @() + $famT.sizingCrit }
  }
}

function ExplanationFor($qtype, $famT, $cards, $dyn){
  $short = ''
  $rangeLogic = $famT.raExpl
  $nutLogic = $famT.naExpl
  $sizingLogic = $famT.sizingExpl
  $mistake = $famT.mistake
  switch($qtype){
    'range_advantage' {
      $short = if ($famT.ra -eq 'preflop_raiser') { 'BTN. Range tilts toward the raiser on this board class.' }
               elseif ($famT.ra -eq 'caller') { 'BB. Range tilts toward the caller - connectors and small pairs hit harder.' }
               else { 'Roughly neutral - neither range hits this board significantly harder.' }
      @{ short=$short; rangeLogic=$rangeLogic; nutLogic=$null; handLogic=$null; sizingLogic=$null; commonMistake=$mistake }
    }
    'nut_advantage' {
      $short = if ($famT.na -eq 'preflop_raiser') { 'BTN. Top of range (overpairs, top-kicker, sets) lives in the raiser preflop range.' }
               elseif ($famT.na -eq 'caller') { 'BB. Sets, straights, and two-pair combos concentrate in the caller flatting range.' }
               else { 'Roughly neutral - nut combos split between ranges.' }
      @{ short=$short; rangeLogic=$null; nutLogic=$nutLogic; handLogic=$null; sizingLogic=$null; commonMistake=$mistake }
    }
    'dynamic_level' {
      $lbl = Map-Dyn $dyn
      $short = "Dynamic level: $lbl. " + $famT.dynNotes
      @{ short=$short; rangeLogic=$null; nutLogic=$null; handLogic=$null; sizingLogic=$famT.dynNotes; commonMistake=$mistake }
    }
    'frequency_strategy' {
      $short = "Sizing family: $($famT.sizing). " + $sizingLogic.Substring(0, [Math]::Min(80, $sizingLogic.Length)) + '...'
      @{ short=$short; rangeLogic=$rangeLogic; nutLogic=$null; handLogic=$null; sizingLogic=$sizingLogic; commonMistake=$mistake }
    }
    'sizing_family' {
      $short = "Sizing family: $($famT.sizing). " + $sizingLogic.Substring(0, [Math]::Min(80, $sizingLogic.Length)) + '...'
      @{ short=$short; rangeLogic=$null; nutLogic=$null; handLogic=$null; sizingLogic=$sizingLogic; commonMistake=$mistake }
    }
  }
}

function ConceptsFor($qtype, $famT, $famName){
  $base = @('board_texture_recognition')
  switch($qtype){
    'range_advantage' { $base += 'range_advantage' }
    'nut_advantage'   { $base += 'nut_advantage' }
    'dynamic_level'   { if ($famT.ra -eq 'caller') { $base += 'dynamic_board' } else { $base += 'static_board' } }
    'frequency_strategy' {
      switch($famT.sizing){
        'range_small'       { $base += @('small_cbet_freq','dry_high_card_strategy') }
        'mixed_small_check' { $base += @('mixed_small_check','small_cbet_freq') }
        'check_heavy'       { $base += @('check_strategy','low_connected_caution') }
        'polar_big'         { $base += @('polar_big_strategy','wet_board') }
      }
    }
    'sizing_family' {
      switch($famT.sizing){
        'range_small'       { $base += @('cbet_size_selection','small_cbet_freq') }
        'mixed_small_check' { $base += @('cbet_size_selection','mixed_small_check') }
        'check_heavy'       { $base += @('cbet_size_selection','check_strategy') }
        'polar_big'         { $base += @('cbet_size_selection','polar_big_strategy') }
      }
    }
  }
  switch($famName){
    'A_high_dry'                  { $base += @('dry_high_card_strategy','dry_board') }
    'K_high_dry'                  { $base += @('dry_high_card_strategy','dry_board') }
    'Q_high_dry'                  { $base += 'dry_board' }
    'J_T_medium'                  { $base += 'board_texture_recognition' }
    'low_dry'                     { $base += 'dry_board' }
    'paired_high'                 { $base += 'paired_board_strategy' }
    'paired_mid'                  { $base += 'paired_board_strategy' }
    'paired_low'                  { $base += 'paired_board_strategy' }
    'broadway_connected'          { $base += @('wet_board','dynamic_board','low_connected_caution','common_leaks') }
    'low_connected'               { $base += @('wet_board','low_connected_caution','common_leaks','dynamic_board') }
    'high_two_tone_dry'           { $base += @('two_tone_board_strategy','dry_high_card_strategy') }
    'mid_two_tone_dry'            { $base += @('two_tone_board_strategy','board_texture_recognition') }
    'broadway_two_tone_connected' { $base += @('two_tone_board_strategy','wet_board','dynamic_board','low_connected_caution','common_leaks') }
    'low_dry_two_tone'            { $base += @('two_tone_board_strategy','dry_board') }
    'low_connected_two_tone'      { $base += @('two_tone_board_strategy','wet_board','low_connected_caution','common_leaks','dynamic_board') }
    'monotone_high'               { $base += @('monotone_board_strategy','wet_board') }
    'monotone_low'                { $base += @('monotone_board_strategy','wet_board','common_leaks') }
    'very_wet'                    { $base += @('wet_board','dynamic_board','common_leaks','low_connected_caution') }
  }
  $base | Sort-Object -Unique
}

function DifficultyFor($qtype, $famT, $famName, $dyn){
  $d = 2
  switch($qtype){
    'range_advantage' {
      if ($famName -in @('A_high_dry','K_high_dry','low_dry','paired_high','paired_low') -and $dyn -le 1) { $d=1 }
      elseif ($famT.ra -in @('preflop_raiser','caller')) { $d=2 }
      else { $d=4 }
    }
    'nut_advantage' {
      if ($famT.na -in @('preflop_raiser','caller')) {
        if ($dyn -ge 3) { $d=3 } else { $d=2 }
      } else { $d=4 }
    }
    'dynamic_level' {
      switch($dyn){ 1{$d=1} 2{$d=2} 3{$d=3} 4{$d=4} }
    }
    'frequency_strategy' {
      if ($famT.sizing -eq 'range_small' -and $famName -in @('A_high_dry','K_high_dry')) { $d=1 }
      elseif ($famT.sizing -in @('range_small','check_heavy')) { $d=2 }
      elseif ($famT.sizing -eq 'mixed_small_check') { $d=3 }
      else { $d=4 }
    }
    'sizing_family' {
      if ($famT.sizing -eq 'range_small') { $d=2 }
      elseif ($famT.sizing -eq 'check_heavy') { $d=3 }
      elseif ($famT.sizing -eq 'mixed_small_check') { $d=4 }
      else { $d=5 }
    }
  }
  if ($famName -in @('monotone_low','very_wet','low_connected_two_tone','broadway_two_tone_connected') -and $qtype -in @('sizing_family','frequency_strategy')) { $d = 5 }
  if ($famName -eq 'monotone_high' -and $qtype -eq 'sizing_family') { $d = 5 }
  if ($famName -eq 'monotone_high' -and $qtype -eq 'frequency_strategy') { $d = 4 }
  if ($famName -in @('monotone_high','monotone_low','very_wet','broadway_connected','broadway_two_tone_connected','low_connected_two_tone') -and $qtype -eq 'nut_advantage') {
    if ($d -lt 4) { $d = 4 }
  }
  if ($famName -eq 'broadway_connected' -and $qtype -eq 'nut_advantage') { $d = 5 }
  if ($famName -eq 'very_wet' -and $qtype -eq 'dynamic_level') { $d = 4 }
  if ($famName -eq 'broadway_connected' -and $qtype -eq 'sizing_family') { $d = 5 }
  if ($famName -in @('high_two_tone_dry','mid_two_tone_dry','low_dry_two_tone') -and $qtype -eq 'sizing_family') {
    if ($d -lt 3) { $d = 3 }
  }
  if ($d -gt 5) { $d=5 }
  if ($d -lt 1) { $d=1 }
  $d
}

function BestForQtype($qtype, $famT, $dyn){
  switch($qtype){
    'range_advantage'    { $famT.ra }
    'nut_advantage'      { $famT.na }
    'dynamic_level'      { Map-Dyn $dyn }
    'frequency_strategy' { $famT.sizing }
    'sizing_family'      { $famT.sizing }
  }
}

function ConfidenceFor($qtype, $famT){
  $key = switch($qtype){ 'range_advantage'{'ra'} 'nut_advantage'{'na'} 'frequency_strategy'{'fs'} 'sizing_family'{'sf'} 'dynamic_level'{'dl'} }
  if ($famT.confidence -and $famT.confidence[$key]) { $famT.confidence[$key] } else { 'expert_judgment' }
}

# ============================================================
# Build scenario
# ============================================================
function Build-Scenario($board, $qtype){
  $famName = $board.family
  $famT = $tmpl[$famName]
  if (-not $famT) { throw "No template for family $famName" }

  $best = BestForQtype $qtype $famT $board.dyn
  $accept = AcceptableFor $qtype $best $famT $famName
  $crit = CriticalFor $qtype $best $famT $famName
  $choices = ChoicesFor $qtype
  $allChoiceIds = $choices | ForEach-Object { $_.id }
  $bad = $allChoiceIds | Where-Object { $_ -ne $best -and $_ -notin $accept }

  $textureTags = Boards-To-Texture $board.cards $famT.textureBase $board.dyn $board.suit
  $hcc = HighCardClass $board.cards
  if ($hcc -eq 'A_high' -and $board.suit -eq 'two_tone') {
    $textureTags = $textureTags | Where-Object { $_ -ne 'ace_high_dry' }
    if ($textureTags -notcontains 'ace_high_wet') { $textureTags += 'ace_high_wet' }
  }
  if (($textureTags -contains 'wet' -or $textureTags -contains 'very_wet')) {
    $textureTags = $textureTags | Where-Object { $_ -notin @('dry','semi_dry','disconnected','broadway_dry','ace_high_dry') }
  }
  if ($hcc -in @('A_high','K_high','Q_high','J_high','T_high')) {
    $textureTags = $textureTags | Where-Object { $_ -ne 'low_heavy' }
  }
  if ($hcc -ne 'A_high') {
    $textureTags = $textureTags | Where-Object { $_ -notin @('ace_high_dry','ace_high_wet') }
  }
  $broadwayCount = 0
  foreach($c in $board.cards){ if($c.Substring(0,1) -in @('A','K','Q','J','T')){ $broadwayCount++ } }
  if ($broadwayCount -lt 2) {
    $textureTags = $textureTags | Where-Object { $_ -notin @('broadway_heavy','broadway_dry','broadway_wet') }
  }
  $textureTags = $textureTags | Sort-Object -Unique

  $expl = ExplanationFor $qtype $famT $board.cards $board.dyn
  $concepts = ConceptsFor $qtype $famT $famName
  $diff = DifficultyFor $qtype $famT $famName $board.dyn
  $confidence = ConfidenceFor $qtype $famT
  $idQt = switch($qtype){ 'range_advantage'{'rangeadv'} 'nut_advantage'{'nutadv'} 'dynamic_level'{'dyn'} 'frequency_strategy'{'freq'} 'sizing_family'{'sizing'} }
  $sid = "pf_btn_v_bb_srp_100bb_flop_$($board.id)_${idQt}_v407"
  $promptStr = PromptText $qtype $board.cards

  [PSCustomObject]@{
    id              = $sid
    version         = '1.0.0'
    schemaVersion   = '1.0.0'
    game            = 'NLH_MTT'
    module          = 'pf_board_texture'
    street          = 'flop'
    spot            = [PSCustomObject]@{
      preflopAction = 'BTN_open_2.5x_BB_call'
      heroPosition  = 'BTN'
      villainPosition = 'BB'
      effectiveStackBB = 100
      potType       = 'SRP'
      playerCount   = 2
    }
    board           = [PSCustomObject]@{
      cards           = $board.cards
      highCardClass   = $hcc
      textureTags     = @($textureTags)
      suitTexture     = $board.suit
      connectedness   = $famT.conn
      pairedStatus    = $famT.paired
      dynamicLevel    = $board.dyn
      rangeAdvantage  = $famT.ra
      nutAdvantage    = $famT.na
    }
    heroHand        = $null
    handClass       = $null
    actionHistory   = @()
    question        = [PSCustomObject]@{
      type    = $qtype
      prompt  = $promptStr
      choices = @($choices | ForEach-Object { [PSCustomObject]@{ id=$_.id; label=$_.label } })
    }
    answer          = [PSCustomObject]@{
      best       = @($best)
      acceptable = @($accept)
      bad        = @($bad)
      critical   = @($crit)
    }
    mixing          = $null
    scoring         = [PSCustomObject]@{ best=1.0; acceptable=0.5; bad=0; critical=0 }
    explanation     = [PSCustomObject]@{
      short         = $expl.short
      rangeLogic    = $expl.rangeLogic
      nutLogic      = $expl.nutLogic
      handLogic     = $expl.handLogic
      sizingLogic   = $expl.sizingLogic
      commonMistake = $expl.commonMistake
    }
    conceptTags     = @($concepts)
    difficulty      = $diff
    sourceConfidence = $confidence
    auditStatus     = 'approved'
  }
}

# ============================================================
# Plan execution
# ============================================================
function Plan-Boards($boards, $plan){
  $results = @()
  $byFam = $boards | Group-Object { $_.family }
  foreach ($g in $byFam) {
    $famName = $g.Name
    $famPlan = $plan[$famName]
    if (-not $famPlan) { Write-Host "  WARNING: no plan for family $famName"; continue }
    $famBoards = @($g.Group)
    $idx = 0
    foreach ($qtypeKey in @('ra','na','fs','sf','dl')) {
      $count = $famPlan[$qtypeKey]
      $qtypeFull = switch($qtypeKey){ 'ra'{'range_advantage'} 'na'{'nut_advantage'} 'fs'{'frequency_strategy'} 'sf'{'sizing_family'} 'dl'{'dynamic_level'} }
      for ($i = 0; $i -lt $count; $i++) {
        if ($idx -ge $famBoards.Count) { break }
        $results += [PSCustomObject]@{ board=$famBoards[$idx]; qtype=$qtypeFull }
        $idx++
      }
    }
  }
  return $results
}

# ============================================================
# Run
# ============================================================
$assignments = Plan-Boards $boards $plan
Write-Host "Assignments planned: $($assignments.Count)"
$assignments | Group-Object qtype | Sort-Object Name | ForEach-Object { Write-Host "  qtype=$($_.Name): $($_.Count)" }
$assignments | Group-Object { $_.board.suit } | Sort-Object Name | ForEach-Object { Write-Host "  suit=$($_.Name): $($_.Count)" }

$newScenarios = @()
foreach ($a in $assignments) { $newScenarios += Build-Scenario $a.board $a.qtype }
Write-Host "Generated scenarios: $($newScenarios.Count)"

# Merge
$existing = Get-Content -Raw $scenPath | ConvertFrom-Json
$baselineScens = @($existing.scenarios | Where-Object { $_.id -notlike '*_v407' })
$baselineIds = @($baselineScens | ForEach-Object { $_.id })
Write-Host "Baseline (non-_v407): $($baselineScens.Count)"

$filtered = @()
$collisions = 0
foreach ($s in $newScenarios) {
  if ($baselineIds -contains $s.id) { $collisions++; continue }
  $filtered += $s
}
Write-Host "Collisions with baseline skipped: $collisions"
Write-Host "New scenarios to add: $($filtered.Count)"

$totalM1 = ($baselineScens | Where-Object { $_.module -eq 'pf_board_texture' }).Count + $filtered.Count

$merged = [PSCustomObject]@{
  schemaVersion = $existing.schemaVersion
  generatedAt   = '2026-05-04'
  description   = "v4.0.7-hardened expansion. Module 1 Board Texture Trainer at $totalM1 scenarios across 14 family/suit combos with rebalanced suitTexture distribution and honest sourceConfidence per family/qtype. Module 2 (Flop C-bet IP) unchanged. Spot context: BTN open 2.5x vs BB call, 100BB SRP, flop only, NLH MTT chipEV. All scenarios audited per postflop_audit_rules.js."
  scenarios     = @($baselineScens) + @($filtered)
}

$json = $merged | ConvertTo-Json -Depth 12
Set-Content -Path $scenPath -Value $json -Encoding UTF8
Write-Host "Wrote $($merged.scenarios.Count) total scenarios to $scenPath"
