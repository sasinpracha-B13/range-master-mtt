# tools/downgrade-crb-critical-v4.2.5.ps1
# v4.2.5 - Module 3 critical-flag rebalancing.
#
# Removes 'check_raise_big' from answer.critical for 21 scenarios where the
# big raise is wrong but NOT a severe conceptual punt (hand has real equity
# backup, made-hand component, or solver mixes some sizing alts). Leaves
# 'check_raise_big' in answer.bad — only changes the critical flag.
#
# Does NOT change: answer.best, answer.acceptable, answer.bad,
# recommendedAction, actionReason, conceptTags, board, heroHand, or any
# explanation text. Pure critical-array edits.
#
# Strategic rationale recorded in
# docs/specs/postflop-v4.2.5-module3-limited-beta-ux-polish.md sec.3.
#
# After edit, removes scenarios from `answer.critical` if the only remaining
# item was check_raise_big — leaving an empty array (R15-compliant).

$ErrorActionPreference = 'Stop'
$path = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt\postflop\postflop_scenarios.json'

$raw = [System.IO.File]::ReadAllText($path, [System.Text.UTF8Encoding]::new($false))
$d = $raw | ConvertFrom-Json

# 21 scenario IDs to downgrade (remove check_raise_big from critical only;
# leave it in bad). Each entry: id + brief rationale tag.
$downgrades = @(
  # === BEST=call, hand has real equity backup (17 scenarios) ===
  @{ id='pf_btn_v_bb_srp_100bb_flop_As8d3h_m3_action_Th8h_v420';      reason='mid pair + BDFD (backdoor heart equity)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_Kh9c4s_m3_action_9d8d_v420';      reason='mid pair + BDFD (backdoor diamond equity)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_Jh8h4h_m3_action_9h8c_v420';      reason='mid pair + 1-card FD on monotone (real flush outs)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_As9s4d_m3_action_AdQd_v423a';     reason='TPGK + BDFD (top pair good kicker has real value)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_Ks8s3d_m3_action_8h7h_v423a';     reason='mid pair + BDFD + backdoor straight' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_Ks8s3d_m3_action_6s5s_v423a';     reason='real 9-out flush draw (4 spades visible)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_QsTs6d_m3_action_AcKc_v423a';     reason='AK + BDFD + gutshot (multi-source backdoor equity)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_7s5s3s_m3_action_As6h_v423a';     reason='Ace nut-flush blocker + wheel gutshot (blocker pressure has real strategic merit)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_8c8d3s_m3_action_AhKs_v423a';     reason='A-blocker on paired-low (blocker pressure is a legitimate raise consideration)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_8c8d3s_m3_action_Tc9c_v423a';     reason='2 overcards + BDFD on paired-low (multi-source backdoor)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_9d8c6h_m3_action_JsTh_v423a';     reason='OESD + 2 overcards (8 OE outs + 6 overcards = strong combo equity)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_TcTh6s_m3_action_6c5c_v423a';     reason='bottom pair + BDFD on paired-T' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_TcTh6s_m3_action_AhKc_v423a';     reason='A-blocker on paired-T (blocker pressure)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_KhQh4s_m3_action_QdTd_v423b';     reason='mid pair + gutshot + BDFD on broadway' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_KhJh4h_m3_action_Th9d_v423b';     reason='1-card FD on monotone (9 outs to T-high flush)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_KhJh4h_m3_action_5h4c_v423b';     reason='bottom pair + 1-card FD (combined pair + FD outs)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_Qd7d2c_m3_action_QhJc_v423b';     reason='TPGK on dry Q-high (top pair J kicker has real showdown value)' }
  # === BEST=check_raise_small, hero has TPTK (1 scenario) ===
  @{ id='pf_btn_v_bb_srp_100bb_flop_Qd7d2c_m3_action_AhQh_v423b';     reason='TPTK; oversizing big-raise vs small-raise is a sizing error, not a severe punt — TPTK has plenty of value to take to a big pot' }
  # === BEST=fold, hero has made-hand component (3 scenarios) ===
  @{ id='pf_btn_v_bb_srp_100bb_flop_7s5s3s_m3_action_6h5h_v423a';     reason='mid pair + gutshot, dominated_marginal (real pair + 4 gutshot outs)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_KhQh4s_m3_action_Qc9c_v423b';     reason='top pair weak kicker (TPWK has 5 outs to two-pair plus showdown value)' }
  @{ id='pf_btn_v_bb_srp_100bb_flop_Qd7d2c_m3_action_Qh9h_v423b';     reason='top pair weak kicker (TPWK on dry Q-high has real made-hand value)' }
)

$idsToDowngrade = @{}
foreach ($e in $downgrades) { $idsToDowngrade[$e.id] = $e.reason }

$edits = 0
$emptyCriticals = 0
foreach ($s in $d.scenarios) {
  if ($s.module -ne 'pf_flop_cbet_oop_def') { continue }
  if (-not $idsToDowngrade.ContainsKey($s.id)) { continue }
  if (-not $s.answer.critical -or $s.answer.critical.Count -eq 0) { continue }
  # Filter out check_raise_big from critical
  $newCrit = @($s.answer.critical | Where-Object { $_ -ne 'check_raise_big' })
  $s.answer.critical = $newCrit
  $edits++
  if ($newCrit.Count -eq 0) { $emptyCriticals++ }
}

Write-Output "Edits applied: $edits"
Write-Output "Critical arrays now empty: $emptyCriticals"

$json = $d | ConvertTo-Json -Depth 100
[System.IO.File]::WriteAllText($path, $json, [System.Text.UTF8Encoding]::new($false))
Write-Output "Wrote: $path"

# Re-count crb-critical occurrences
$rawAfter = [System.IO.File]::ReadAllText($path, [System.Text.UTF8Encoding]::new($false))
$dAfter = $rawAfter | ConvertFrom-Json
$m3 = @($dAfter.scenarios | Where-Object { $_.module -eq 'pf_flop_cbet_oop_def' })
$crbCrit = @($m3 | Where-Object { $s = $_; $s.answer.critical -and ($s.answer.critical | Where-Object { $_ -eq 'check_raise_big' }) }).Count
Write-Output ""
Write-Output "=== After downgrade ==="
Write-Output "M3 total: $($m3.Count)"
Write-Output "crb-critical scenarios: $crbCrit / $($m3.Count) ($([math]::Round(100 * $crbCrit / $m3.Count, 1))%)"
