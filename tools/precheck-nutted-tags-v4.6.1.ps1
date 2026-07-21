# precheck-nutted-tags-v4.6.1.ps1 -- R107-class recompute of nutted tags
# BEFORE the ARR.P resolver consumes them (owner order, batch-3 approval #2).
# READ-ONLY. Scope: all non-rework M4 rows (the partition-fix universe plus
# PASS rows -- a wrong nutted tag anywhere in M4 is worth knowing about).
# Principle (#62 ruling): WITHIN-CATEGORY domination demotes the tag
# (a better straight/flush of the same category is live) -> strong_value/high.
# Cross-category vulnerability (set vs possible straight) does NOT demote.
# Also flags IMPOSSIBLE tags (authored category cannot be made by the cards).

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$data = [System.IO.File]::ReadAllText((Join-Path $root 'postflop\postflop_scenarios.json'), [System.Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
$ALLROWS = $data.scenarios

$REWORK = @('Ac7d2s_4h_m4_action_AcKh_v432','7s5d3h_4c_m4_reason_AhAd_v432','9s8d4c_7h_m4_action_AhAd_v430C','Qs7d3c_3h_m4_action_AhAd_v430C','JdTd5s_2c_m4_action_AhAd_v430C','9s8d4c_7h_m4_action_KsKc_v432','JdTd5s_2c_m4_action_KsKh_v430D','Kd8s3c_8h_m4_action_KsKc_v430C','Ts8s4d_7c_m4_reason_QcQd_v432','Ks8s3d_2s_m4_action_AsKd_v430','Kd8s3c_8h_m4_action_AdKh_v430C','Kd8s3c_8h_m4_action_AdKh_v430D','Qs8s4d_2s_m4_action_AsKc_v430C','8c8d3s_3h_m4_reason_AdKc_v430','Ah9d4d_7h_m4_action_AsKs_v430D','Ts8s4d_7c_m4_action_AsKs_v430C','As8d3h_2c_m4_action_AdQd_v430','Ts8s4d_7c_m4_action_AsQs_v432','9d8c6h_Kc_m4_action_9c9s_v430','9d8c6h_Kc_m4_reason_Tc7c_v430','As8d3h_2c_m4_reason_8c8h_v430','Ts9s5d_6h_m4_action_TcTd_v430','Ts9s5d_6h_m4_action_As6s_v430','QsTs6d_Jc_m4_action_5h4d_v430','JdTd5s_2c_m4_action_JhJs_v430D','Kd8c4s_Ah_m4_action_8d8h_v430C','Qs7d3c_3h_m4_action_7s7c_v430C','Qs8s4d_2s_m4_action_8d8h_v430C','Ts8s4d_7c_m4_action_TcTd_v432','Ts8s4d_7c_m4_reason_TdTc_v430D')

function RankOf($c) {
  $r = $c.Substring(0, $c.Length - 1)
  switch ($r) { 'A' { 14 } 'K' { 13 } 'Q' { 12 } 'J' { 11 } 'T' { 10 } default { [int]$r } }
}
function SuitOf($c) { $c.Substring($c.Length - 1) }

function BestStraight($rankList) {
  $set = @{}; foreach ($r in $rankList) { $set[[int]$r] = $true }
  if ($set[14]) { $set[1] = $true }   # wheel
  for ($hi = 14; $hi -ge 5; $hi--) {
    $all = $true
    for ($k = $hi - 4; $k -le $hi; $k++) { if (-not $set[$k]) { $all = $false; break } }
    if ($all) { return $hi }
  }
  return 0
}

function Analyze($row) {
  $hero = @($row.heroHand)
  $board = @($row.board.flopCards) + @($row.board.turnCard)
  $hr = @($hero | ForEach-Object { RankOf $_ })
  $br = @($board | ForEach-Object { RankOf $_ })
  $seen = @{}
  foreach ($c in ($hero + $board)) { $seen[$c] = $true }
  $avail = @{}
  for ($r = 2; $r -le 14; $r++) { $avail[$r] = 4 }
  foreach ($r in ($hr + $br)) { $avail[[int]$r] = $avail[[int]$r] - 1 }

  # ---- hero category: full 6-card rank-multiset evaluation (v2 fix:
  # unpaired-hero trips/boats via board pairs were missed by v1 -- caught on
  # Ah3d/8c8d3s3h = threes-full; triple-implementation discipline) ----
  $cat = 'high'; $det = ''
  $cnt = @{}
  foreach ($r in ($hr + $br)) { if ($cnt[[int]$r]) { $cnt[[int]$r] = $cnt[[int]$r] + 1 } else { $cnt[[int]$r] = 1 } }
  $quadR = 0; $tripR = @(); $pairR = @()
  foreach ($k in $cnt.Keys) {
    if ($cnt[$k] -ge 4) { $quadR = [int]$k }
    elseif ($cnt[$k] -eq 3) { $tripR += [int]$k }
    elseif ($cnt[$k] -eq 2) { $pairR += [int]$k }
  }
  $tripR = @($tripR | Sort-Object -Descending); $pairR = @($pairR | Sort-Object -Descending)

  # flush (board 3+ of a suit, hero completing to 5)
  $heroFlushTop = 0; $flushSuit = ''
  foreach ($su in @('s','h','d','c')) {
    $bc = @($board | Where-Object { (SuitOf $_) -eq $su }).Count
    $hc = @($hero | Where-Object { (SuitOf $_) -eq $su })
    if (($bc + $hc.Count) -ge 5) {
      $flushSuit = $su
      $heroFlushTop = ($hc | ForEach-Object { RankOf $_ } | Measure-Object -Maximum).Maximum
    }
  }
  $heroStraight = BestStraight ($hr + $br)
  $heroBoatTrip = 0; $heroBoatPair = 0
  if ($tripR.Count -ge 1 -and ($pairR.Count -ge 1 -or $tripR.Count -ge 2)) {
    $heroBoatTrip = $tripR[0]
    if ($tripR.Count -ge 2) { $heroBoatPair = $tripR[1] } else { $heroBoatPair = $pairR[0] }
  }

  if ($quadR -gt 0) { $cat = 'quads'; $det = ('quads ' + $quadR) }
  elseif ($heroBoatTrip -gt 0) { $cat = 'boat'; $det = ($heroBoatTrip.ToString() + 's full of ' + $heroBoatPair) }
  elseif ($flushSuit -ne '') { $cat = 'flush'; $det = ('flush ' + $flushSuit + ' top ' + $heroFlushTop) }
  elseif ($heroStraight -gt 0) { $cat = 'straight'; $det = ('straight hi ' + $heroStraight) }
  elseif ($tripR.Count -ge 1) { $cat = 'trips'; $det = ('trips ' + $tripR[0]) }
  elseif ($pairR.Count -ge 2) { $cat = 'two_pair'; $det = ('two pair ' + $pairR[0] + '+' + $pairR[1]) }
  elseif ($pairR.Count -eq 1) {
    if ($hr[0] -eq $hr[1]) { $cat = 'pocket_pair'; $det = ('pocket ' + $hr[0]) }
    else { $cat = 'pair'; $det = ('pair of ' + $pairR[0]) }
  }

  # ---- within-category domination ----
  $dom = ''
  if ($cat -eq 'straight') {
    for ($r1 = 2; $r1 -le 14; $r1++) {
      for ($r2 = $r1; $r2 -le 14; $r2++) {
        if ($r1 -eq $r2) { if ($avail[$r1] -lt 2) { continue } }
        else { if ($avail[$r1] -lt 1 -or $avail[$r2] -lt 1) { continue } }
        $v = BestStraight ($br + @($r1, $r2))
        if ($v -gt $heroStraight) {
          $n1 = @('','','2','3','4','5','6','7','8','9','T','J','Q','K','A')
          $dom = ('higher straight live: ' + $n1[$r1] + $n1[$r2] + ' makes ' + $n1[$v] + '-high')
          break
        }
      }
      if ($dom -ne '') { break }
    }
  } elseif ($cat -eq 'flush') {
    $bc = @($board | Where-Object { (SuitOf $_) -eq $flushSuit }).Count
    $need = 5 - $bc
    $liveHigher = @()
    for ($r = 14; $r -gt $heroFlushTop; $r--) {
      $n1 = @('','','2','3','4','5','6','7','8','9','T','J','Q','K','A')
      $card = $n1[$r] + $flushSuit
      if (-not $seen[$card]) { $liveHigher += $card }
    }
    $liveSuitTotal = 0
    for ($r = 2; $r -le 14; $r++) {
      $n1 = @('','','2','3','4','5','6','7','8','9','T','J','Q','K','A')
      if (-not $seen[($n1[$r] + $flushSuit)]) { $liveSuitTotal++ }
    }
    if ($liveHigher.Count -ge 1 -and $liveSuitTotal -ge $need) { $dom = ('higher flush live: ' + ($liveHigher -join ',')) }
  } elseif ($cat -eq 'boat' -or $cat -eq 'trips') {
    $heroVal = 0
    if ($cat -eq 'boat') { $heroVal = $heroBoatTrip * 15 + $heroBoatPair } else { $heroVal = $tripR[0] }
    $n1 = @('','','2','3','4','5','6','7','8','9','T','J','Q','K','A')
    for ($r1 = 2; $r1 -le 14; $r1++) {
      for ($r2 = $r1; $r2 -le 14; $r2++) {
        if ($r1 -eq $r2) { if ($avail[$r1] -lt 2) { continue } }
        else { if ($avail[$r1] -lt 1 -or $avail[$r2] -lt 1) { continue } }
        $vc = @{}
        foreach ($r in $br) { if ($vc[[int]$r]) { $vc[[int]$r] = $vc[[int]$r] + 1 } else { $vc[[int]$r] = 1 } }
        foreach ($r in @($r1, $r2)) { if ($vc[$r]) { $vc[$r] = $vc[$r] + 1 } else { $vc[$r] = 1 } }
        $vTrip = @(); $vPair = @()
        foreach ($k in $vc.Keys) {
          if ($vc[$k] -eq 3) { $vTrip += [int]$k }
          elseif ($vc[$k] -eq 2) { $vPair += [int]$k }
        }
        $vTrip = @($vTrip | Sort-Object -Descending); $vPair = @($vPair | Sort-Object -Descending)
        $vVal = 0
        if ($cat -eq 'boat') {
          if ($vTrip.Count -ge 1 -and ($vPair.Count -ge 1 -or $vTrip.Count -ge 2)) {
            $vp = 0; if ($vTrip.Count -ge 2) { $vp = $vTrip[1] } else { $vp = $vPair[0] }
            $vVal = $vTrip[0] * 15 + $vp
          }
        } else {
          if ($vTrip.Count -ge 1) { $vVal = $vTrip[0] }
        }
        if ($vVal -gt $heroVal) {
          $dom = ('higher ' + $cat + ' live: ' + $n1[$r1] + $n1[$r2])
          break
        }
      }
      if ($dom -ne '') { break }
    }
  }

  return [pscustomobject]@{ cat = $cat; det = $det; dom = $dom; straightHi = $heroStraight }
}

$m4 = @($ALLROWS | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
Write-Output ('M4 rows: ' + $m4.Count)
Write-Output ''
Write-Output '=== PRE-CHECK 1: nutted-tag recompute (all non-rework M4 rows) ==='
$flags = @()
foreach ($row in $m4) {
  $isRework = $false
  foreach ($sfx in $REWORK) { if ($row.id -like ('*' + $sfx)) { $isRework = $true; break } }
  if ($isRework) { continue }
  $nutTagged = ($row.showdownValue -eq 'nutted' -or $row.heroHandRole -eq 'nutted_value')
  if (-not $nutTagged) { continue }
  $a = Analyze $row
  $short = $row.id.Replace('pf_btn_v_bb_srp_100bb_turn_','')
  $verdict = 'CLEAN'
  $note = $a.det
  if ($a.cat -in @('high','pair','pocket_pair','two_pair')) {
    $verdict = 'IMPOSSIBLE-TAG'
    $note = ('computed=' + $a.cat + ' (' + $a.det + ') vs authored class=' + $row.handClass)
  } elseif ($a.dom -ne '') {
    $verdict = 'RETAG'
    $note = ($a.det + ' -- ' + $a.dom)
  }
  Write-Output ('  ' + $short + ' | role=' + $row.heroHandRole + ' sdv=' + $row.showdownValue + ' | ' + $verdict + ' | ' + $note)
  if ($verdict -ne 'CLEAN') { $flags += [pscustomobject]@{ id = $row.id; short = $short; verdict = $verdict; cat = $a.cat } }
}
Write-Output ''
Write-Output '=== PRE-CHECK 2: sdv=none sanity on call-dup rows (secondary) ==='
foreach ($row in $m4) {
  $isRework = $false
  foreach ($sfx in $REWORK) { if ($row.id -like ('*' + $sfx)) { $isRework = $true; break } }
  if ($isRework) { continue }
  if ($row.showdownValue -ne 'none') { continue }
  $bad = @($row.answer.bad); $crit = @($row.answer.critical)
  $callDup = ($bad -contains 'call' -and $crit -contains 'call')
  if (-not $callDup) { continue }
  $a = Analyze $row
  $short = $row.id.Replace('pf_btn_v_bb_srp_100bb_turn_','')
  $state = 'OK (no made hand)'
  if ($a.cat -ne 'high') { $state = ('MISMATCH: computed ' + $a.cat + ' (' + $a.det + ')') }
  Write-Output ('  ' + $short + ' | ' + $state)
}
Write-Output ''
Write-Output '=== PRE-CHECK 3: resolution flips for RETAG rows with bad+critical dups ==='
foreach ($f in $flags) {
  $row = $ALLROWS | Where-Object { $_.id -eq $f.id }
  $bad = @($row.answer.bad); $crit = @($row.answer.critical)
  $dups = @(); foreach ($x in $bad) { if ($crit -contains $x) { $dups += $x } }
  if ($dups.Count -eq 0) { Write-Output ('  ' + $f.short + ' | no bad+critical dup -- retag only, no resolver flip'); continue }
  foreach ($d in $dups) {
    # v2 fix: the resolver's fold rule keys on ROLE (nutted_value), not sdv --
    # a slowplay_trap row's fold-dup already resolves bad pre-retag.
    $pre = ''; $post = ''
    if ($d -eq 'fold') {
      if ($row.heroHandRole -eq 'nutted_value') { $pre = 'critical (fold-nuts via role nutted_value)'; $post = 'bad (over-fold, v4.4.1B)' }
      else { $pre = 'bad (role not nutted_value)'; $post = 'bad (unchanged)' }
    }
    elseif ($d -like 'check_raise*') { $pre = 'bad (role not in catch set)'; $post = 'bad (unchanged)' }
    elseif ($d -eq 'call') { $pre = 'bad (sdv not none)'; $post = 'bad (unchanged)' }
    else { $pre = 'bad'; $post = 'bad' }
    Write-Output ('  ' + $f.short + ' | dup=' + $d + ' | pre-retag -> ' + $pre + ' | post-retag -> ' + $post)
  }
}
