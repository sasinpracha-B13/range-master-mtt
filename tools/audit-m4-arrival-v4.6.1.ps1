# audit-m4-arrival-v4.6.1.ps1 -- M4 ARRIVAL LEGITIMACY lint (92 rows).
# Deterministic, reproducible, zero judgment (R29/R107 precedent).
# READS production postflop_scenarios.json; writes the results table to
# docs/specs/postflop-v4.6.1-m4-arrival-lint-results.md. Never mutates data.
#
# Rules:
#   ARR.A  -- leg-(a) membership: hero 169-class vs the RULED non-member set
#             {AA, KK, QQ, AKs, AKo, AQs}. Must reproduce the banked class
#             counts {AA:4, KK:3, QQ:1, AKo:6, AKs:2, AQs:2} = 18 or ABORT.
#   ARR.C1 -- self-inconsistency: an M3 row with the SAME hero + SAME flop
#             whose recommendedAction is check_raise_* => REWORK-(c); fold =>
#             REWORK-(b). Must reproduce the 6 banked pairs or ABORT.
#   ARR.P  -- answer-array partition/overlap scan (defect class found live on
#             the V1 row: fold + check_raise_big graded in BOTH bad and
#             critical). Informational column; feeds the rework batches.
#   ARR.MAP-- review scaffold rows for the manual legs-(b)/(c) passes.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$data = [System.IO.File]::ReadAllText((Join-Path $root 'postflop\postflop_scenarios.json'), [System.Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
$S = $data.scenarios
$m4 = @($S | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
$m3 = @($S | Where-Object { $_.module -eq 'pf_flop_cbet_oop_def' })
if ($m4.Count -ne 92) { throw ('ABORT: expected 92 M4 rows, found ' + $m4.Count) }

$order = '23456789TJQKA'
function Canon($hand) {
  $a = $hand[0]; $b = $hand[1]
  $r1 = $a.Substring(0,1); $r2 = $b.Substring(0,1); $s1 = $a.Substring(1,1); $s2 = $b.Substring(1,1)
  if ($order.IndexOf($r1) -lt $order.IndexOf($r2)) { $t = $r1; $r1 = $r2; $r2 = $t }
  if ($r1 -eq $r2) { return $r1 + $r2 }
  return $r1 + $r2 + $(if ($s1 -eq $s2) { 's' } else { 'o' })
}
function HK($s) { (@($s.heroHand) | Sort-Object) -join '' }
function FlopKey($s) {
  if ($s.board.flopCards) { return (@($s.board.flopCards) -join '') }
  if ($s.board.cards -and @($s.board.cards).Count -eq 3) { return (@($s.board.cards) -join '') }
  return $null
}

$NONMEMBER = @('AA','KK','QQ','AKs','AKo','AQs')
$EXPECT_A = @{ 'AA'=4; 'KK'=3; 'QQ'=1; 'AKo'=6; 'AKs'=2; 'AQs'=2 }
# Banked C1 pairs keyed (sortedHero|flop|kind) -- version-agnostic tuples.
$EXPECT_C1 = @(
  '8c8h|As8d3h|c', '9c9s|9d8c6h|c', '7cTc|9d8c6h|c', 'TcTd|Ts9s5d|c', '6sAs|Ts9s5d|c', '4d5h|QsTs6d|b'
)

# index M3 by hero+flop
$m3Idx = @{}
foreach ($s in $m3) {
  $k = (HK $s) + '|' + (FlopKey $s)
  if (-not $m3Idx[$k]) { $m3Idx[$k] = @() }
  $m3Idx[$k] += $s
}

$rows = @(); $legA = @{}; $c1Found = @()
foreach ($s in $m4) {
  $cls = Canon $s.heroHand
  $isA = $NONMEMBER -contains $cls
  if ($isA) { if (-not $legA[$cls]) { $legA[$cls] = 0 }; $legA[$cls]++ }
  # C1: M3 twin verdict
  $twinKind = ''; $twinId = ''
  $k = (HK $s) + '|' + (FlopKey $s)
  if ($m3Idx[$k]) {
    foreach ($t in $m3Idx[$k]) {
      if ($t.recommendedAction -like 'check_raise*') { $twinKind = 'c'; $twinId = $t.id; break }
      elseif ($t.recommendedAction -eq 'fold') { $twinKind = 'b'; $twinId = $t.id; break }
    }
  }
  if ($twinKind) { $c1Found += ((HK $s) + '|' + (FlopKey $s) + '|' + $twinKind) }
  # ARR.P: overlap / partition scan
  $ans = $s.answer
  $all = @($ans.best) + @($ans.acceptable) + @($ans.bad) + @($ans.critical)
  $overlap = ($all.Count -ne ($all | Select-Object -Unique).Count)
  $choices = @($s.question.choices)
  $covered = (($all | Select-Object -Unique | Sort-Object) -join ',') -eq (($choices | Sort-Object) -join ',')
  $verdict = if ($isA) { 'REWORK-(a)' } elseif ($twinKind -eq 'c') { 'REWORK-(c)*' } elseif ($twinKind -eq 'b') { 'REWORK-(b)*' } else { 'REVIEW' }
  $rows += [pscustomobject]@{
    id = $s.id; cls = $cls; board = ((FlopKey $s) + '/' + $s.board.turnCard)
    reason = $s.actionReason; best = $s.recommendedAction; diff = $s.difficulty
    verdict = $verdict; twin = $twinId
    overlap = $(if ($overlap) { 'OVERLAP' } elseif (-not $covered) { 'PARTIAL' } else { 'ok' })
    mixedWL = $(if ($null -ne $_PF_MIXED) { '' } else { '' })
  }
}

# ---- reproduce-or-abort gates ----
$aTotal = 0; foreach ($k in $legA.Keys) { $aTotal += $legA[$k] }
$aOk = ($aTotal -eq 18)
foreach ($k in $EXPECT_A.Keys) { if ($legA[$k] -ne $EXPECT_A[$k]) { $aOk = $false } }
if (-not $aOk) {
  Write-Output ('ARR.A REPRODUCTION FAILED: found ' + (($legA.GetEnumerator() | ForEach-Object { $_.Key + ':' + $_.Value }) -join ' '))
  throw 'ABORT: leg-(a) lint does not reproduce the banked 18 -- lint bug or data drift.'
}
$c1Sorted = @($c1Found | Sort-Object)
$e1Sorted = @($EXPECT_C1 | Sort-Object)
if (($c1Sorted -join ';') -ne ($e1Sorted -join ';')) {
  Write-Output ('ARR.C1 found: ' + ($c1Sorted -join ' | '))
  Write-Output ('ARR.C1 expected: ' + ($e1Sorted -join ' | '))
  throw 'ABORT: self-inconsistency lint does not reproduce the banked 6 pairs.'
}

# ---- emit results ----
$overlapCount = @($rows | Where-Object { $_.overlap -eq 'OVERLAP' }).Count
$md = @()
$md += '# v4.6.1 M4 Arrival Lint Results (mechanical pass)'
$md += ''
$md += ('Generated from production (542, blob 54f134f5). ARR.A reproduced 18/18 banked leg-(a) rows; ARR.C1 reproduced 6/6 banked pairs. ARR.P found **' + $overlapCount + ' rows with tier-array OVERLAP** (defect class discovered on the V1 row).')
$md += ''
$md += '| id | class | board | reason | best | D | verdict | overlap | M3 twin |'
$md += '|---|---|---|---|---|---|---|---|---|'
foreach ($r in ($rows | Sort-Object verdict, id)) {
  $md += ('| `' + $r.id.Replace('pf_btn_v_bb_srp_100bb_turn_','') + '` | ' + $r.cls + ' | ' + $r.board + ' | ' + $r.reason + ' | ' + $r.best + ' | ' + $r.diff + ' | ' + $r.verdict + ' | ' + $r.overlap + ' | ' + $(if ($r.twin) { '`' + $r.twin.Replace('pf_btn_v_bb_srp_100bb_flop_','') + '`' } else { '' }) + ' |')
}
[System.IO.File]::WriteAllLines((Join-Path $root 'docs\specs\postflop-v4.6.1-m4-arrival-lint-results.md'), $md, [System.Text.UTF8Encoding]::new($false))

Write-Output '=== M4 ARRIVAL LINT ==='
Write-Output ('Rows: ' + $m4.Count)
Write-Output ('ARR.A leg-(a): ' + $aTotal + ' (reproduced banked 18 exactly: ' + (($legA.GetEnumerator() | Sort-Object Key | ForEach-Object { $_.Key + ':' + $_.Value }) -join ' ') + ')')
Write-Output ('ARR.C1 pairs: ' + $c1Found.Count + ' (reproduced banked 6 exactly: 5x REWORK-(c) + 1x REWORK-(b))')
Write-Output ('ARR.P tier-overlap rows: ' + $overlapCount)
Write-Output ('REVIEW rows remaining for manual legs-(b)/(c): ' + @($rows | Where-Object { $_.verdict -eq 'REVIEW' }).Count)
Write-Output 'RESULT: PASS (reproduction gates held)'
