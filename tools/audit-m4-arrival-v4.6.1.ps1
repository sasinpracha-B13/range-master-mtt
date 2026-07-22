# audit-m4-arrival-v4.6.1.ps1 -- M4 ARRIVAL LEGITIMACY lint.
# Deterministic, reproducible, zero judgment (R29/R107 precedent).
# v4.6.1: the audit's mechanical pass (reproduced the banked pre-migration
# state: 18 leg-(a) rows, 6 C1 pairs -- see the committed
# postflop-v4.6.1-m4-arrival-lint-results.md).
# v4.6.2 CONVERSION (migration A): the audit closed 92/92, so the banked-state
# reproduction gates can never hold again -- the lint is now the STANDING
# REGRESSION GUARD asserting the post-audit invariants:
#   ARR.A  -- ZERO non-member arrivals. Non-member set gains AQo per the V3
#             solver closure (owner, 2026-07-21): {AA,KK,QQ,AKs,AKo,AQs,AQo}.
#   ARR.C1 -- ZERO self-inconsistency pairs (M4 hero+flop whose M3 twin
#             verdict is check_raise_*/fold).
#   ARR.P  -- answer-array partition/overlap scan (informational column).
# Writes docs/specs/postflop-m4-arrival-regression-lint.md. Never mutates data.

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

$NONMEMBER = @('AA','KK','QQ','AKs','AKo','AQs','AQo')
# Post-audit invariants (v4.6.2): zero non-member arrivals, zero C1 pairs.
# (Historical pre-migration state: 18 leg-(a) rows / 6 pairs -- committed
# in postflop-v4.6.1-m4-arrival-lint-results.md.)

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

# ---- regression gates (post-audit invariants) ----
$aTotal = 0; foreach ($k in $legA.Keys) { $aTotal += $legA[$k] }
if ($aTotal -ne 0) {
  Write-Output ('ARR.A REGRESSION: non-member arrivals found: ' + (($legA.GetEnumerator() | ForEach-Object { $_.Key + ':' + $_.Value }) -join ' '))
  throw 'ABORT: post-audit invariant broken -- non-member hero arrived in an M4 row.'
}
if (@($c1Found).Count -ne 0) {
  Write-Output ('ARR.C1 REGRESSION: self-inconsistency pairs found: ' + (@($c1Found | Sort-Object) -join ' | '))
  throw 'ABORT: post-audit invariant broken -- M4 row contradicts its M3 twin verdict.'
}

# ---- emit results ----
$overlapCount = @($rows | Where-Object { $_.overlap -eq 'OVERLAP' }).Count
$md = @()
$md += '# M4 Arrival Regression Lint (standing post-audit guard)'
$md += ''
$md += ('Generated from production (' + @($S).Count + ' scenarios). ARR.A: 0 non-member arrivals (set incl. AQo per V3 closure). ARR.C1: 0 self-inconsistency pairs. ARR.P tier-array OVERLAP rows: **' + $overlapCount + '**.')
$md += ''
$md += '| id | class | board | reason | best | D | verdict | overlap | M3 twin |'
$md += '|---|---|---|---|---|---|---|---|---|'
foreach ($r in ($rows | Sort-Object verdict, id)) {
  $md += ('| `' + $r.id.Replace('pf_btn_v_bb_srp_100bb_turn_','') + '` | ' + $r.cls + ' | ' + $r.board + ' | ' + $r.reason + ' | ' + $r.best + ' | ' + $r.diff + ' | ' + $r.verdict + ' | ' + $r.overlap + ' | ' + $(if ($r.twin) { '`' + $r.twin.Replace('pf_btn_v_bb_srp_100bb_flop_','') + '`' } else { '' }) + ' |')
}
[System.IO.File]::WriteAllLines((Join-Path $root 'docs\specs\postflop-m4-arrival-regression-lint.md'), $md, [System.Text.UTF8Encoding]::new($false))

Write-Output '=== M4 ARRIVAL REGRESSION LINT ==='
Write-Output ('Rows: ' + $m4.Count)
Write-Output ('ARR.A non-member arrivals: ' + $aTotal + ' (invariant 0; set = AA,KK,QQ,AKs,AKo,AQs,AQo)')
Write-Output ('ARR.C1 self-inconsistency pairs: ' + @($c1Found).Count + ' (invariant 0)')
Write-Output ('ARR.P tier-overlap rows: ' + $overlapCount)
Write-Output 'RESULT: PASS (post-audit invariants hold)'
