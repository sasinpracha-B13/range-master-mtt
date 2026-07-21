# migrate-v4.6.1-m4-rework.ps1 -- THE single v4.6.1 migration (owner knob (d)).
# Order (owner-approved at plan + dry-run gates):
#   assert start blob -> 4 retags BEFORE the ARR.P resolver -> replace 31
#   authored rows (V1 + gate-1 26 + gate-2 family 4) -> partition-fix the 40
#   overlap rows -> WL id swap (2 of 7 M4 entries) -> SW cache bump.
# DRY-RUN by default: writes the migrated corpus + patched index.html/sw to
# the scratch dir and runs a scratch copy of the full validator there.
# -Apply performs the real writes (only after owner confirms the dry-run).
# Zero-drift proof: per-row compressed-JSON compare; any row outside the
# 71-row manifest that changes aborts the migration (v4.5.2A pattern).

param([switch]$Apply)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = [System.Text.UTF8Encoding]::new($false)
$prodPath = Join-Path $root 'postflop\postflop_scenarios.json'
$seedPath = Join-Path $root 'docs\specs\postflop-v4.6.1-m4-rework-seeds.json'
$idxPath  = Join-Path $root 'index.html'
$swPath   = Join-Path $root 'service-worker.js'
$scratch  = 'C:\Users\PC\AppData\Local\Temp\claude\C--Users-PC-Desktop-BAY-TD-range-master-mtt\0a681972-9fa1-48cc-93b2-4d63851846d8\scratchpad\mig'

$START_BLOB = '54f134f58f2cb595874c2a680893baf9801ab92b'
$PFX = 'pf_btn_v_bb_srp_100bb_turn_'

# ---- 0. assert start state ----
$blob = (& git -C $root hash-object 'postflop/postflop_scenarios.json').Trim()
if ($blob -ne $START_BLOB) { throw ('ABORT: corpus blob ' + $blob + ' != expected ' + $START_BLOB) }
Write-Output ('[0] start blob asserted: ' + $blob)

$prod = [System.IO.File]::ReadAllText($prodPath, $utf8) | ConvertFrom-Json
$seeds = ([System.IO.File]::ReadAllText($seedPath, $utf8) | ConvertFrom-Json).reworks
if (@($prod.scenarios).Count -ne 542) { throw 'ABORT: pre-count != 542' }
if (@($seeds).Count -ne 31) { throw ('ABORT: seeds != 31, got ' + @($seeds).Count) }

$before = @{}
foreach ($s in $prod.scenarios) { $before[$s.id] = ($s | ConvertTo-Json -Depth 12 -Compress) }

# ---- 1. retags (BEFORE the resolver consumes tags; owner order) ----
$RETAGS = @(
  @{ sfx = 'Ts8s4d_7c_m4_action_9d6d_v430C'; role = 'strong_value'; sdv = 'high' },
  @{ sfx = 'QsTs6d_Jc_m4_action_9c8h_v430';  role = 'strong_value'; sdv = 'high' },
  @{ sfx = '7s5d3h_4c_m4_action_6h6d_v430D'; role = 'strong_value'; sdv = 'high' },
  @{ sfx = '8c8d3s_3h_m4_action_Ah3d_v430';  role = '';             sdv = 'high' }
)
$nRetag = 0
foreach ($rt in $RETAGS) {
  $row = $prod.scenarios | Where-Object { $_.id -eq ($PFX + $rt.sfx) } | Select-Object -First 1
  if (-not $row) { throw ('ABORT: retag row missing ' + $rt.sfx) }
  if ($rt.role -ne '') { $row.heroHandRole = $rt.role }
  $row.showdownValue = $rt.sdv
  $nRetag++
}
Write-Output ('[1] retags applied: ' + $nRetag + ' (3x role+sdv, 1x sdv-only)')

# ---- 2. replace 31 authored rows (positional; strip seed fields; flip status) ----
$replacedOld = @{}
$newIds = @()
$scen = [System.Collections.ArrayList]@($prod.scenarios)
foreach ($seed in $seeds) {
  $oldId = $seed.replaces
  $idx = -1
  for ($i = 0; $i -lt $scen.Count; $i++) { if ($scen[$i].id -eq $oldId) { $idx = $i; break } }
  if ($idx -lt 0) { throw ('ABORT: replaced row not found in production: ' + $oldId) }
  if ($before.ContainsKey($seed.id)) { throw ('ABORT: new id already exists: ' + $seed.id) }
  $new = $seed | ConvertTo-Json -Depth 12 | ConvertFrom-Json
  $new.PSObject.Properties.Remove('replaces')
  $new.PSObject.Properties.Remove('reworkClass')
  $new.auditStatus = 'approved'
  if ($new.PSObject.Properties['reviewStatus']) { $new.reviewStatus = 'v4.6.1_strategic_reviewed' }
  else { $new | Add-Member -NotePropertyName reviewStatus -NotePropertyValue 'v4.6.1_strategic_reviewed' }
  $scen[$idx] = $new
  $replacedOld[$oldId] = $true
  $newIds += $new.id
}
$prod.scenarios = $scen.ToArray()
Write-Output ('[2] replaced rows: ' + $newIds.Count + ' (old ids removed, new _v461 ids in place)')

# ---- 3. partition-fix the remaining overlap rows (post-retag roles) ----
$CATCH_ROLES = @('bluff_catcher','dominated_bluff_catcher','marginal_made_hand')
$fixRows = 0; $fixInst = 0; $toBad = 0; $toCrit = 0; $fixedIds = @()
foreach ($s in $prod.scenarios) {
  if ($s.module -ne 'pf_turn_barrel_oop_def') { continue }
  if ($newIds -contains $s.id) { continue }
  $bad = [System.Collections.ArrayList]@($s.answer.bad)
  $crit = [System.Collections.ArrayList]@($s.answer.critical)
  $dups = @(); foreach ($x in $bad) { if ($crit -contains $x) { $dups += $x } }
  if ($dups.Count -eq 0) { continue }
  $fixRows++; $fixedIds += $s.id
  foreach ($d in $dups) {
    $fixInst++
    $resolveCrit = $false
    if ($d -eq 'fold') { if ($s.heroHandRole -eq 'nutted_value') { $resolveCrit = $true } }
    elseif ($d -eq 'call') { if ($s.showdownValue -eq 'none') { $resolveCrit = $true } }
    elseif ($d -like 'check_raise*') { if ($CATCH_ROLES -contains $s.heroHandRole) { $resolveCrit = $true } }
    if ($resolveCrit) { [void]$bad.Remove($d); $toCrit++ } else { [void]$crit.Remove($d); $toBad++ }
  }
  $s.answer.bad = $bad.ToArray()
  $s.answer.critical = $crit.ToArray()
}
Write-Output ('[3] partition-fix: rows=' + $fixRows + ' instances=' + $fixInst + ' -> bad=' + $toBad + ' critical=' + $toCrit)
if ($fixRows -ne 40 -or $fixInst -ne 54 -or $toBad -ne 39 -or $toCrit -ne 15) { throw 'ABORT: partition-fix numbers do not reproduce the banked 40/54/39/15' }
foreach ($rt in $RETAGS) { if ($fixedIds -notcontains ($PFX + $rt.sfx)) { throw ('ABORT: retag row not in fix set: ' + $rt.sfx) } }

# ---- 4. post-state asserts + zero-drift manifest ----
if (@($prod.scenarios).Count -ne 542) { throw 'ABORT: post-count != 542' }
$m4 = @($prod.scenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
if ($m4.Count -ne 92) { throw 'ABORT: M4 != 92' }
foreach ($s in $m4) {
  $b = @($s.answer.bad); $c = @($s.answer.critical); $a = @($s.answer.acceptable); $bs = @($s.answer.best)
  foreach ($x in $b) { if ($c -contains $x) { throw ('ABORT: overlap survives in ' + $s.id) } }
  foreach ($x in $a) { if ($b -contains $x -or $c -contains $x) { throw ('ABORT: acc overlap in ' + $s.id) } }
  foreach ($x in $bs) { if ($a -contains $x -or $b -contains $x -or $c -contains $x) { throw ('ABORT: best overlap in ' + $s.id) } }
}
$changed = @()
foreach ($s in $prod.scenarios) {
  if (-not $before.ContainsKey($s.id)) { $changed += $s.id; continue }
  $now = ($s | ConvertTo-Json -Depth 12 -Compress)
  if ($before[$s.id] -ne $now) { $changed += $s.id }
}
$expected = @($newIds) + @($fixedIds)
$unexpected = @($changed | Where-Object { $expected -notcontains $_ })
$missing = @($expected | Where-Object { $changed -notcontains $_ })
if ($unexpected.Count -gt 0) { throw ('ABORT: rows changed OUTSIDE manifest: ' + ($unexpected -join ', ')) }
if ($missing.Count -gt 0) { throw ('ABORT: manifest rows unchanged: ' + ($missing -join ', ')) }
Write-Output ('[4] changed-id manifest: ' + $changed.Count + ' rows (31 replaced + 40 partition-fixed; 4 retag rows inside the 40). Zero drift outside.')

# ---- 5. top-level meta ----
$prod.generatedAt = '2026-07-21'
$prod.description = 'v4.6.1 - M4 Arrival-Legitimacy rework. Total 542 scenarios: 251 M1 + 49 M2 + 85 M3 + 92 M4 (turn defense OOP; 31 rows re-authored under the locked BB-vs-BTN arrival baseline: 17 leg-(a) hero swaps incl. the V1 AhJh pilot, 1 leg-(b), 7 leg-(c), the #18 content re-derive, and the 4-row BOARD-CHANGED slowplay family incl. the quads recognition row) + 33 M5 + 32 M6. Remaining 40 M4 overlap rows partition-fixed mechanically (exact-partition corpus standard, 54 instances -> 39 bad / 15 critical after 4 nutted-tag retags per the within-category principle). Spot context: BTN open 2.5x vs BB call, 100BB SRP, NLH MTT chipEV.'

# ---- 6. index.html WL id swap (2 of 7 M4 entries) ----
$idx = [System.IO.File]::ReadAllText($idxPath, $utf8)
$wlSwaps = @(
  @{ old = 'turn_7s5d3h_4c_m4_reason_AhAd_v432'; new = 'turn_7s5d3h_4c_m4_reason_JhJd_v461' },
  @{ old = 'turn_9s8d4c_7h_m4_action_AhAd_v430C'; new = 'turn_9s8d4c_7h_m4_action_JcJh_v461' }
)
foreach ($w in $wlSwaps) {
  $n = ([regex]::Matches($idx, [regex]::Escape($w.old))).Count
  if ($n -ne 1) { throw ('ABORT: WL key ' + $w.old + ' occurrence count ' + $n + ' != 1') }
  $idx = $idx.Replace($w.old, $w.new)
}
foreach ($keep in @('turn_Ac7d2s_4h_m4_action_9c9d_v430C','turn_JdTd5s_2c_m4_action_9c9d_v430C','turn_Ah9d4d_7h_m4_reason_TdTs_v430D','turn_7s5d3h_4c_m4_action_JsTs_v432','turn_Qs7d3c_3h_m4_action_8d8c_v432')) {
  if (-not $idx.Contains($keep)) { throw ('ABORT: WL unchanged key missing: ' + $keep) }
}
Write-Output '[6] WL: 2 keys swapped to _v461, 5 M4 keys verified unchanged, M2/M5/M6 untouched.'

# ---- 7. service-worker cache bump ----
$sw = [System.IO.File]::ReadAllText($swPath, $utf8)
$oldVer = "const VERSION = 'v4.6.0';"
if (([regex]::Matches($sw, [regex]::Escape($oldVer))).Count -ne 1) { throw 'ABORT: SW version marker not found exactly once' }
$sw = $sw.Replace($oldVer, "const VERSION = 'v4.6.1';")
Write-Output '[7] SW cache: v4.6.0 -> v4.6.1'

# ---- 8. write ----
$outJson = $prod | ConvertTo-Json -Depth 12
$check = $outJson | ConvertFrom-Json
if (@($check.scenarios).Count -ne 542) { throw 'ABORT: serialized count != 542' }

if ($Apply) {
  foreach ($t in @(@($prodPath, $outJson), @($idxPath, $idx), @($swPath, $sw))) {
    $tmp = $t[0] + '.tmp'
    [System.IO.File]::WriteAllText($tmp, $t[1], $utf8)
    Move-Item -Force $tmp $t[0]
  }
  Write-Output 'APPLIED: production corpus + index.html + service-worker.js written.'
} else {
  New-Item -ItemType Directory -Force (Join-Path $scratch 'postflop') | Out-Null
  New-Item -ItemType Directory -Force (Join-Path $scratch 'tools') | Out-Null
  [System.IO.File]::WriteAllText((Join-Path $scratch 'postflop\postflop_scenarios.json'), $outJson, $utf8)
  [System.IO.File]::WriteAllText((Join-Path $scratch 'index.html'), $idx, $utf8)
  [System.IO.File]::WriteAllText((Join-Path $scratch 'service-worker.js'), $sw, $utf8)
  foreach ($f in (Get-ChildItem (Join-Path $root 'postflop') -Filter '*.json')) {
    if ($f.Name -ne 'postflop_scenarios.json') { Copy-Item $f.FullName (Join-Path $scratch ('postflop\' + $f.Name)) -Force }
  }
  Copy-Item (Join-Path $root 'tools\audit-postflop-ps.ps1') (Join-Path $scratch 'tools\audit-postflop-ps.ps1') -Force
  Write-Output ('DRY-RUN: migrated files written to scratch. Production untouched (blob still ' + $START_BLOB + ').')
  Write-Output 'DRY-RUN: run the scratch validator next for the real predicted state.'
}
