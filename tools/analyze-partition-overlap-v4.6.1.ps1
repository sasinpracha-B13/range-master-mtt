# analyze-partition-overlap-v4.6.1.ps1 -- ARR.P resolution + corpus diagnostic.
# READ-ONLY analysis (no data mutation). Owner ruling 2026-07-07:
#   - exact partition = CORPUS standard (adopted from M6);
#   - M4 overlap rows not being reworked get a PARTITION-FIX-ONLY batch;
#     mechanical resolution: a duplicated action resolves to critical ONLY if
#     it belongs to an enumerated punt class (fold-nuts / call-zero-SDV /
#     raise-into-crush / check-back-nuts), else bad. Mechanical proxies use
#     AUTHORED metadata; anything not covered => FLAG for owner review.
#   - diagnostic overlap counts for M1/M2/M3/M5 (no remediation this sprint).

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$data = [System.IO.File]::ReadAllText((Join-Path $root 'postflop\postflop_scenarios.json'), [System.Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
$S = $data.scenarios

function OverlapInfo($s) {
  # v4.6.1 fix: return ,@() wrapping so single-element results never unroll
  # (the original form undercounted rows in Where-Object .Count checks).
  $a = $s.answer
  $best = @($a.best); $acc = @($a.acceptable); $bad = @($a.bad); $crit = @($a.critical)
  $dups = @()
  foreach ($x in $bad)  { if ($crit -contains $x) { $dups += [pscustomobject]@{ act = $x; where = 'bad+critical' } } }
  foreach ($x in $acc)  { if ($bad -contains $x) { $dups += [pscustomobject]@{ act = $x; where = 'acceptable+bad' } }
                          if ($crit -contains $x) { $dups += [pscustomobject]@{ act = $x; where = 'acceptable+critical' } } }
  foreach ($x in $best) { if ($acc -contains $x -or $bad -contains $x -or $crit -contains $x) { $dups += [pscustomobject]@{ act = $x; where = 'best+other' } } }
  return ,@($dups)
}

# ---- diagnostic counts per module ----
Write-Output '=== ARR.P CORPUS DIAGNOSTIC (overlap rows per module; counts only) ==='
$mods = @('pf_board_texture','pf_flop_cbet_ip','pf_flop_cbet_oop_def','pf_turn_barrel_oop_def','pf_river_barrel_oop_def','pf_river_value_ip')
foreach ($m in $mods) {
  $rows = @($S | Where-Object { $_.module -eq $m })
  $bad = @($rows | Where-Object { (OverlapInfo $_).Count -gt 0 })
  Write-Output ('  ' + $m + ': ' + $bad.Count + ' / ' + $rows.Count)
}

# ---- M4 mechanical resolution ----
$CATCH_ROLES = @('bluff_catcher','dominated_bluff_catcher','marginal_made_hand')
$m4 = @($S | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
$res = @(); $flagged = @()
foreach ($s in $m4) {
  $dups = OverlapInfo $s
  if ($dups.Count -eq 0) { continue }
  foreach ($d in $dups) {
    if ($d.where -ne 'bad+critical') { $flagged += [pscustomobject]@{ id = $s.id; act = $d.act; why = ('overlap involves ' + $d.where) }; continue }
    $to = ''; $why = ''
    if ($d.act -eq 'fold') {
      if ($s.heroHandRole -eq 'nutted_value') { $to = 'critical'; $why = 'fold-nuts (role nutted_value)' }
      else { $to = 'bad'; $why = 'over-fold, not an enumerated punt (v4.4.1B precedent)' }
    } elseif ($d.act -eq 'call') {
      if ($s.showdownValue -eq 'none') { $to = 'critical'; $why = 'call with zero SDV' }
      else { $to = 'bad'; $why = 'over-call, not an enumerated punt' }
    } elseif ($d.act -like 'check_raise*') {
      if ($CATCH_ROLES -contains $s.heroHandRole) { $to = 'critical'; $why = 'raise-into-crush (bluff-catcher-class hero raising)' }
      else { $to = 'bad'; $why = 'aggression/sizing error -- not an enumerated punt for this role (V1 precedent)' }
    } elseif ($d.act -eq 'mixed') {
      $to = 'bad'; $why = 'mislabeling a clear spot as mixed is never a punt class'
    } else {
      $flagged += [pscustomobject]@{ id = $s.id; act = $d.act; why = 'no mechanical rule' }; continue
    }
    $res += [pscustomobject]@{ id = $s.id; act = $d.act; role = $s.heroHandRole; sdv = $s.showdownValue; resolveTo = $to; why = $why }
  }
}
Write-Output ''
Write-Output '=== M4 MECHANICAL RESOLUTION (duplicated actions in bad+critical) ==='
Write-Output ('  duplicated-action instances: ' + $res.Count + '   flagged (not mechanical): ' + $flagged.Count)
$g = $res | Group-Object resolveTo
foreach ($grp in $g) { Write-Output ('  resolve -> ' + $grp.Name + ': ' + $grp.Count) }
$g2 = $res | Group-Object act
foreach ($grp in $g2) { Write-Output ('  by action ' + $grp.Name + ': ' + $grp.Count) }
Write-Output ''
Write-Output '--- 10-row sample (id | act | role | sdv | -> tier | why) ---'
$res | Select-Object -First 10 | ForEach-Object {
  Write-Output ('  ' + $_.id.Replace('pf_btn_v_bb_srp_100bb_turn_','') + ' | ' + $_.act + ' | ' + $_.role + ' | ' + $_.sdv + ' | -> ' + $_.resolveTo + ' | ' + $_.why)
}
if ($flagged.Count -gt 0) {
  Write-Output ''
  Write-Output '--- FLAGGED for owner review (no mechanical rule) ---'
  $flagged | ForEach-Object { Write-Output ('  ' + $_.id.Replace('pf_btn_v_bb_srp_100bb_turn_','') + ' | ' + $_.act + ' | ' + $_.why) }
}
