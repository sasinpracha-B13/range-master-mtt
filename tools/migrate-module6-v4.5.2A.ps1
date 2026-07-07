# migrate-module6-v4.5.2A.ps1 -- M6 expansion migration: 534 -> 542 (+8).
# Appends the 8 owner-approved v4.5.2A expansion seeds to production
# postflop_scenarios.json (flip review_pending -> approved, version v4.5.2A).
# ZERO-DRIFT verification on ALL 534 pre-existing rows (compact-JSON equality,
# abort-on-drift). Idempotent (verify-only when 542/32 already present).
# No concepts phase: the batch's conceptTags are a subset of the 12 shipped
# module6 concepts. Atomic UTF-8 no-BOM. ASCII-only, PS 5.1 safe.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$prodPath = Join-Path $root 'postflop\postflop_scenarios.json'
$seedPath = Join-Path $root 'docs\specs\postflop-v4.5.2A-module6-expansion-seeds.json'
$utf8 = [System.Text.UTF8Encoding]::new($false)

$prod = [System.IO.File]::ReadAllText($prodPath, $utf8) | ConvertFrom-Json
$seeds = [System.IO.File]::ReadAllText($seedPath, $utf8) | ConvertFrom-Json
$m6Now = @($prod.scenarios | Where-Object { $_.module -eq 'pf_river_value_ip' })

if ($prod.scenarios.Count -eq 542 -and $m6Now.Count -eq 32) {
  Write-Output 'SCENARIOS: already migrated (542 with 32 M6) -- verify-only mode.'
} elseif ($prod.scenarios.Count -ne 534 -or $m6Now.Count -ne 24) {
  throw ('ABORT: expected 534 production / 24 M6, found ' + $prod.scenarios.Count + ' / ' + $m6Now.Count)
} else {
  if (@($seeds.scenarios).Count -ne 8) { throw ('ABORT: expected 8 expansion seeds, found ' + @($seeds.scenarios).Count) }
  $prodIds = @{}
  foreach ($s in $prod.scenarios) { $prodIds[$s.id] = $true }
  foreach ($s in $seeds.scenarios) {
    if ($prodIds.ContainsKey($s.id)) { throw ('ABORT: id collision ' + $s.id) }
    if ($s.module -ne 'pf_river_value_ip') { throw ('ABORT: bad module on ' + $s.id) }
    if ($s.auditStatus -ne 'review_pending') { throw ('ABORT: seed not review_pending: ' + $s.id) }
    if (@('clear_direction','mixed_nudge') -notcontains $s.verdictBasis) { throw ('ABORT: unapprovable verdictBasis on ' + $s.id) }
  }
  $before = @{}
  foreach ($s in $prod.scenarios) { $before[$s.id] = ($s | ConvertTo-Json -Depth 12 -Compress) }
  foreach ($s in $seeds.scenarios) {
    $s.auditStatus = 'approved'
    $s.reviewStatus = 'v4.5.2A_strategic_reviewed'
    $s.version = 'v4.5.2A'
  }
  $prod.scenarios = @($prod.scenarios) + @($seeds.scenarios)
  $prod.description = 'v4.5.2A - Module 6 expansion (+8). Total 542 scenarios: 251 M1 (board texture) + 49 M2 (flop c-bet IP) + 85 M3 (flop defense OOP) + 92 M4 (turn defense OOP) + 33 M5 (river defense OOP) + 32 M6 (river betting IP). M6 = BTN river bet/check decision IP after BB checks (seat mirror of M5), schemaVersion 1.4.0 per-scenario (verdictBasis + stakeBasis owner PINs; R94-R107 production rules incl. the boat-or-better recompute lint). Lives in Tournament at Final Table depth via the pf_river_value_ip hook; curriculum wire follows in v4.5.3. Spot context: BTN open 2.5x vs BB call, 100BB SRP, NLH MTT chipEV.'

  $out = $prod | ConvertTo-Json -Depth 12
  $check = $out | ConvertFrom-Json
  if (@($check.scenarios).Count -ne 542) { throw 'ABORT: post-merge count != 542' }
  $m6 = @($check.scenarios | Where-Object { $_.module -eq 'pf_river_value_ip' })
  if ($m6.Count -ne 32) { throw 'ABORT: post-merge M6 != 32' }
  foreach ($s in $m6) { if ($s.auditStatus -ne 'approved') { throw ('ABORT: M6 not approved post-merge: ' + $s.id) } }
  $drift = 0
  foreach ($s in $check.scenarios) {
    if (-not $before.ContainsKey($s.id)) { continue }
    $now = ($s | ConvertTo-Json -Depth 12 -Compress)
    if ($before[$s.id] -ne $now) { $drift++; Write-Output ('DRIFT: ' + $s.id) }
  }
  if ($drift -ne 0) { throw ('ABORT: ' + $drift + ' pre-existing scenarios drifted -- write cancelled.') }

  $tmp = $prodPath + '.tmp'
  [System.IO.File]::WriteAllText($tmp, $out, $utf8)
  Move-Item -Force $tmp $prodPath
  Write-Output 'SCENARIOS: migrated 534 -> 542 (8 M6 expansion approved; all 534 pre-existing rows verified data-identical).'
}
Write-Output 'MIGRATION COMPLETE.'
