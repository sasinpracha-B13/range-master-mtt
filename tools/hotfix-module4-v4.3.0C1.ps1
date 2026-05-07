# ============================================================
# tools/hotfix-module4-v4.3.0C1.ps1
# v4.3.0C1 Module 4 Expansion Raw Content Hotfix -- Production Sync
#
# Re-syncs ONLY 2 specific scenarios from the corrected expansion source
#   docs/specs/postflop-v4.3.0C-module4-expansion-seeds.json
# into production
#   postflop/postflop_scenarios.json
#
# Target IDs (and only these IDs):
#   - pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_7s6h_v430C
#       (false-gutshot fix; drawCategory none, actionReason bluff_catch_turn)
#   - pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_action_9d6d_v430C
#       (wait-prose fix; T-high straight clarified, JT removed as higher straight)
#
# Idempotent: safe to re-run. The tool overwrites the strategy + prose fields
# of the 2 target IDs in production with the corrected expansion source values
# and preserves all other production scenarios byte-identical.
#
# Safety:
#   - ASCII-only (no em-dash, no special unicode)
#   - NO Invoke-Expression (lesson: v4.3.0B helper-script delete bug)
#   - NO Remove-Item on production-adjacent paths
#   - Atomic write via tmp + Move-Item -Force
#   - UTF-8 NO-BOM I/O via [System.IO.File]::WriteAllText/ReadAllText
#   - Pre-flight verification:
#       * production total = 438
#       * production M4 count = 53
#       * all 53 M4 scenarios have auditStatus=approved
#       * the 2 target IDs exist in production
#       * the 2 target IDs exist in expansion source
#       * expansion source has exactly 29 scenarios
#   - Post-write verification:
#       * production total still 438
#       * production M4 still 53 / all approved
#       * the 2 target IDs in production now match expansion source on the
#         strategy + prose field set
#       * no other production scenario changed by id; non-M4 untouched
#
# Mode flags:
#   default   apply the fix
#   -DryRun   verify pre-flight + diff, do not write
# ============================================================

[CmdletBinding()]
param(
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$repoRoot   = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$sourcePath = Join-Path $repoRoot 'docs\specs\postflop-v4.3.0C-module4-expansion-seeds.json'
$targetPath = Join-Path $repoRoot 'postflop\postflop_scenarios.json'

$targetIds = @(
  'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_7s6h_v430C',
  'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_action_9d6d_v430C'
)

# Field set re-synced (other production-only fields preserved):
$syncFields = @(
  'handClass','heroHandRole','drawCategory','showdownValue','blockerNote',
  'recommendedAction','actionReason','question','answer','explanation',
  'conceptTags'
)

function Read-Utf8Json([string]$p) {
  if (-not (Test-Path $p)) { throw "File not found: $p" }
  $text = [System.IO.File]::ReadAllText($p, $utf8nb)
  return ($text | ConvertFrom-Json)
}

function Write-Utf8Json($obj, [string]$p) {
  $json = $obj | ConvertTo-Json -Depth 100
  [System.IO.File]::WriteAllText($p, $json, $utf8nb)
}

function Test-Equal($a, $b) {
  $ja = ($a | ConvertTo-Json -Depth 100 -Compress)
  $jb = ($b | ConvertTo-Json -Depth 100 -Compress)
  return ($ja -ceq $jb)
}

# ----------------------------------------------------------------
# Step 1 -- Read + verify expansion source
# ----------------------------------------------------------------
Write-Host "Step 1 -- read expansion source JSON" -ForegroundColor Cyan
$src = Read-Utf8Json $sourcePath
$srcExp = @($src.scenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
Write-Host "  Source scenarios:        $($src.scenarios.Count)"
Write-Host "  Source M4 expansion:     $($srcExp.Count)"
if ($srcExp.Count -ne 29) {
  throw "Hotfix aborted: expected 29 expansion scenarios in source, got $($srcExp.Count)."
}

$srcById = @{}
foreach ($s in $srcExp) { $srcById[$s.id] = $s }
foreach ($tid in $targetIds) {
  if (-not $srcById.ContainsKey($tid)) {
    throw "Hotfix aborted: target id $tid not present in expansion source."
  }
}

# ----------------------------------------------------------------
# Step 2 -- Read target production JSON + verify baseline
# ----------------------------------------------------------------
Write-Host "Step 2 -- read target production JSON" -ForegroundColor Cyan
$tgt = Read-Utf8Json $targetPath
$tgtAll = @($tgt.scenarios)
$tgtM4 = @($tgtAll | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
$tgtNonM4 = @($tgtAll | Where-Object { $_.module -ne 'pf_turn_barrel_oop_def' })

Write-Host "  Target total:            $($tgtAll.Count)"
Write-Host "  Target M4:               $($tgtM4.Count)"
Write-Host "  Target non-M4:           $($tgtNonM4.Count)"

if ($tgtAll.Count -ne 438) {
  throw "Hotfix aborted: expected production total 438, got $($tgtAll.Count)."
}
if ($tgtM4.Count -ne 53) {
  throw "Hotfix aborted: expected production M4 count 53, got $($tgtM4.Count)."
}
if ($tgtNonM4.Count -ne 385) {
  throw "Hotfix aborted: expected production non-M4 count 385, got $($tgtNonM4.Count)."
}

$nonApproved = @($tgtM4 | Where-Object { $_.auditStatus -ne 'approved' })
if ($nonApproved.Count -gt 0) {
  throw "Hotfix aborted: $($nonApproved.Count) of 53 M4 scenarios are not auditStatus=approved."
}

$tgtById = @{}
foreach ($s in $tgtAll) { $tgtById[$s.id] = $s }
foreach ($tid in $targetIds) {
  if (-not $tgtById.ContainsKey($tid)) {
    throw "Hotfix aborted: target id $tid not present in production. Expected post-v4.3.0C state."
  }
}

# ----------------------------------------------------------------
# Step 3 -- Build diff plan + apply per-id field sync
# ----------------------------------------------------------------
Write-Host "Step 3 -- build per-id field-sync plan" -ForegroundColor Cyan

# Snapshot id-order so reassembly preserves array order exactly.
$origOrder = @($tgtAll | ForEach-Object { $_.id })

$applied = @{}
$plan = @()
foreach ($tid in $targetIds) {
  $srcS = $srcById[$tid]
  $tgtS = $tgtById[$tid]
  $changedFields = @()
  $newProps = [ordered]@{}
  foreach ($p in $tgtS.PSObject.Properties) { $newProps[$p.Name] = $p.Value }
  foreach ($f in $syncFields) {
    $srcVal = $srcS.$f
    $tgtVal = $tgtS.$f
    if (-not (Test-Equal $tgtVal $srcVal)) {
      $newProps[$f] = $srcVal
      $changedFields += $f
    }
  }
  $appliedScenario = [PSCustomObject]$newProps
  $applied[$tid] = $appliedScenario
  $plan += [PSCustomObject]@{ id = $tid; fields = $changedFields }
  Write-Host ("  {0}" -f $tid)
  if ($changedFields.Count -eq 0) {
    Write-Host "    (no diff -- already in sync)" -ForegroundColor DarkGray
  } else {
    Write-Host ("    fields to update: {0}" -f ($changedFields -join ', '))
  }
}

if ($DryRun) {
  Write-Host ""
  Write-Host "DRY RUN -- not writing." -ForegroundColor Yellow
  exit 0
}

# ----------------------------------------------------------------
# Step 4 -- Reassemble production preserving array order
# ----------------------------------------------------------------
Write-Host "Step 4 -- reassemble production scenarios" -ForegroundColor Cyan
$newScenariosArr = @()
foreach ($id in $origOrder) {
  if ($applied.ContainsKey($id)) {
    $newScenariosArr += ,$applied[$id]
  } else {
    $newScenariosArr += ,$tgtById[$id]
  }
}
if ($newScenariosArr.Count -ne 438) {
  throw "Hotfix aborted: post-rebuild count is $($newScenariosArr.Count), expected 438."
}

$newTarget = [ordered]@{}
foreach ($p in $tgt.PSObject.Properties) {
  if ($p.Name -eq 'scenarios') {
    $newTarget[$p.Name] = $newScenariosArr
  } else {
    $newTarget[$p.Name] = $p.Value
  }
}

# ----------------------------------------------------------------
# Step 5 -- Atomic write (no Invoke-Expression, no unsafe Remove-Item)
# ----------------------------------------------------------------
Write-Host "Step 5 -- write production JSON" -ForegroundColor Cyan
$tmpPath = "$targetPath.tmp"
Write-Utf8Json ([PSCustomObject]$newTarget) $tmpPath
Move-Item -LiteralPath $tmpPath -Destination $targetPath -Force
$newSize = (Get-Item $targetPath).Length
Write-Host "  Wrote: $targetPath  ($newSize bytes)"

# ----------------------------------------------------------------
# Step 6 -- Post-write verification
# ----------------------------------------------------------------
Write-Host "Step 6 -- verify post-write state" -ForegroundColor Cyan
$ver = Read-Utf8Json $targetPath
$verAll = @($ver.scenarios)
$verM4 = @($verAll | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
$verNonM4 = @($verAll | Where-Object { $_.module -ne 'pf_turn_barrel_oop_def' })
if ($verAll.Count -ne 438) { throw "Post-write verification failed: total $($verAll.Count) (expected 438)." }
if ($verM4.Count -ne 53)   { throw "Post-write verification failed: M4 $($verM4.Count) (expected 53)." }
if ($verNonM4.Count -ne 385) { throw "Post-write verification failed: non-M4 $($verNonM4.Count) (expected 385)." }
$verNonApproved = @($verM4 | Where-Object { $_.auditStatus -ne 'approved' })
if ($verNonApproved.Count -gt 0) { throw "Post-write verification failed: $($verNonApproved.Count) M4 not approved." }

# Verify the 2 target IDs in production now match the expansion source on syncFields
$verById = @{}
foreach ($s in $verAll) { $verById[$s.id] = $s }
foreach ($tid in $targetIds) {
  $vs = $verById[$tid]
  $ss = $srcById[$tid]
  foreach ($f in $syncFields) {
    if (-not (Test-Equal $vs.$f $ss.$f)) {
      throw "Post-write verification failed: id $tid field '$f' in production does not match expansion source after write."
    }
  }
}

# Verify no other scenario changed: original vs new array order identical
$verOrder = @($verAll | ForEach-Object { $_.id })
if ($verOrder.Count -ne $origOrder.Count) {
  throw "Post-write verification failed: scenario order length changed."
}
for ($i = 0; $i -lt $verOrder.Count; $i++) {
  if ($verOrder[$i] -cne $origOrder[$i]) {
    throw "Post-write verification failed: scenario order drift at index $i."
  }
}
foreach ($id in $origOrder) {
  if ($targetIds -contains $id) { continue }
  $vs = $verById[$id]
  $os = $tgtById[$id]
  if (-not (Test-Equal $vs $os)) {
    throw "Post-write verification failed: non-target scenario $id changed."
  }
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " HOTFIX SUMMARY -- v4.3.0C1 M4 Content Hotfix" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ("  Source:                  {0}" -f (Split-Path $sourcePath -Leaf))
Write-Host ("  Target:                  {0}" -f (Split-Path $targetPath -Leaf))
Write-Host ("  Production total before: 438  (verified)")
Write-Host ("  Production total after:  {0}" -f $verAll.Count)
Write-Host ("  Production M4 after:     {0}  (all approved)" -f $verM4.Count)
foreach ($entry in $plan) {
  if ($entry.fields.Count -eq 0) {
    Write-Host ("  [{0}] no diff" -f $entry.id)
  } else {
    Write-Host ("  [{0}] updated: {1}" -f $entry.id, ($entry.fields -join ', '))
  }
}
Write-Host ""
Write-Host "Next: re-run production auditor + expansion auditor to confirm 0 errors." -ForegroundColor Cyan
