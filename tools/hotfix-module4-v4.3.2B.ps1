# ============================================================
# tools/hotfix-module4-v4.3.2B.ps1
# v4.3.2B Module 4 R1 Metadata Consistency Hotfix -- Production Sync
#
# Re-syncs ONLY 1 specific scenario's BOARD METADATA from the corrected
# continuation source
#   docs/specs/postflop-v4.3.2-module4-continuation-seeds.json
# into production
#   postflop/postflop_scenarios.json
#
# Target ID (and only this ID):
#   - pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_reason_QcQd_v432
#       (R1 metadata fix: board carries stale draw_intensifier /
#        draw_added / improves_bb_draws / oesd_added classification
#        despite v4.3.2A correcting the strategic verdict to bluff-catch
#        on a straight-completing turn. Re-sync to straight_complete /
#        polarizing / polarizes_btn / straight_completed.)
#
# This hotfix touches ONLY the `board` sub-document of the target scenario.
# All other fields (recommendedAction, actionReason, heroHandRole, prose,
# answer partitions, conceptTags, etc. -- already corrected in v4.3.2A)
# are preserved byte-identical.
#
# Idempotent: safe to re-run. UTF-8 NO-BOM I/O. ASCII-clean.
#
# Safety:
#   - ASCII-only (no em-dash, no special unicode)
#   - NO Invoke-Expression
#   - NO Remove-Item on production-adjacent paths
#   - Atomic write via tmp + Move-Item -Force
#   - UTF-8 NO-BOM I/O via [System.IO.File]::WriteAllText/ReadAllText
#   - Pre-flight verification:
#       * production total = 477
#       * production M4 count = 92
#       * all 92 M4 scenarios have auditStatus=approved
#       * the 1 target ID exists in production
#       * the 1 target ID exists in continuation source
#       * continuation source has exactly 20 scenarios
#   - Post-write verification:
#       * production total still 477
#       * production M4 still 92 / all approved
#       * the 1 target ID's board sub-document in production now matches
#         the continuation source
#       * the 91 non-target M4 scenarios are byte-identical pre/post
#       * non-M4 scenarios untouched
#       * scenario-array order preserved
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
$sourcePath = Join-Path $repoRoot 'docs\specs\postflop-v4.3.2-module4-continuation-seeds.json'
$targetPath = Join-Path $repoRoot 'postflop\postflop_scenarios.json'

$targetIds = @(
  'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_reason_QcQd_v432'
)

# v4.3.2B narrow scope: ONLY the `board` sub-document is re-synced.
# All other fields (already corrected in v4.3.2A) are preserved.
$syncFields = @( 'board' )

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
# Step 1 -- Read + verify continuation source
# ----------------------------------------------------------------
Write-Host "Step 1 -- read continuation source JSON" -ForegroundColor Cyan
$src = Read-Utf8Json $sourcePath
$srcCont = @($src.scenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
Write-Host "  Source scenarios:        $($src.scenarios.Count)"
Write-Host "  Source M4 continuation:  $($srcCont.Count)"
if ($srcCont.Count -ne 20) {
  throw "Hotfix aborted: expected 20 continuation scenarios in source, got $($srcCont.Count)."
}

$srcById = @{}
foreach ($s in $srcCont) { $srcById[$s.id] = $s }
foreach ($tid in $targetIds) {
  if (-not $srcById.ContainsKey($tid)) {
    throw "Hotfix aborted: target id $tid not present in continuation source."
  }
}

# Sanity-check: source R1 board metadata is the corrected v4.3.2B values.
$srcR1 = $srcById[$targetIds[0]]
if ($srcR1.board.turnCategory -ne 'straight_complete') {
  throw "Hotfix aborted: source R1 board.turnCategory='$($srcR1.board.turnCategory)' (expected 'straight_complete'). Did the builder regenerate?"
}
if ($srcR1.board.drawCompletion -ne 'straight_completed') {
  throw "Hotfix aborted: source R1 board.drawCompletion='$($srcR1.board.drawCompletion)' (expected 'straight_completed')."
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

if ($tgtAll.Count -ne 477) {
  throw "Hotfix aborted: expected production total 477, got $($tgtAll.Count)."
}
if ($tgtM4.Count -ne 92) {
  throw "Hotfix aborted: expected production M4 count 92, got $($tgtM4.Count)."
}
if ($tgtNonM4.Count -ne 385) {
  throw "Hotfix aborted: expected production non-M4 count 385, got $($tgtNonM4.Count)."
}

$nonApproved = @($tgtM4 | Where-Object { $_.auditStatus -ne 'approved' })
if ($nonApproved.Count -gt 0) {
  throw "Hotfix aborted: $($nonApproved.Count) of 92 M4 scenarios are not auditStatus=approved."
}

$tgtById = @{}
foreach ($s in $tgtAll) { $tgtById[$s.id] = $s }
foreach ($tid in $targetIds) {
  if (-not $tgtById.ContainsKey($tid)) {
    throw "Hotfix aborted: target id $tid not present in production. Expected post-v4.3.2A state."
  }
}

# ----------------------------------------------------------------
# Step 3 -- Build diff plan + apply per-id board sync
# ----------------------------------------------------------------
Write-Host "Step 3 -- build per-id board-sync plan" -ForegroundColor Cyan

# Snapshot id-order so reassembly preserves array order exactly.
$origOrder = @($tgtAll | ForEach-Object { $_.id })

# Snapshot non-target M4 scenarios for post-write byte-identity check.
$nonTargetM4Ids = @($tgtM4 | Where-Object { $targetIds -notcontains $_.id } | ForEach-Object { $_.id })

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
    Write-Host ("    board: turnCategory '{0}' -> '{1}'" -f $tgtS.board.turnCategory, $srcS.board.turnCategory)
    Write-Host ("    board: boardChange '{0}' -> '{1}'" -f $tgtS.board.boardChange, $srcS.board.boardChange)
    Write-Host ("    board: equityShift '{0}' -> '{1}'" -f $tgtS.board.equityShift, $srcS.board.equityShift)
    Write-Host ("    board: drawCompletion '{0}' -> '{1}'" -f $tgtS.board.drawCompletion, $srcS.board.drawCompletion)
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
if ($newScenariosArr.Count -ne 477) {
  throw "Hotfix aborted: post-rebuild count is $($newScenariosArr.Count), expected 477."
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
# Step 5 -- Atomic write
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
if ($verAll.Count -ne 477) { throw "Post-write verification failed: total $($verAll.Count) (expected 477)." }
if ($verM4.Count -ne 92)   { throw "Post-write verification failed: M4 $($verM4.Count) (expected 92)." }
if ($verNonM4.Count -ne 385) { throw "Post-write verification failed: non-M4 $($verNonM4.Count) (expected 385)." }
$verNonApproved = @($verM4 | Where-Object { $_.auditStatus -ne 'approved' })
if ($verNonApproved.Count -gt 0) { throw "Post-write verification failed: $($verNonApproved.Count) M4 not approved." }

# Verify the 1 target ID's board in production now matches continuation source
$verById = @{}
foreach ($s in $verAll) { $verById[$s.id] = $s }
foreach ($tid in $targetIds) {
  $vs = $verById[$tid]
  $ss = $srcById[$tid]
  foreach ($f in $syncFields) {
    if (-not (Test-Equal $vs.$f $ss.$f)) {
      throw "Post-write verification failed: id $tid field $f does not match continuation source after sync."
    }
  }
  # Sanity-spot-check the 4 metadata fields the user mandated
  if ($vs.board.turnCategory -ne 'straight_complete') { throw "Post-write: turnCategory='$($vs.board.turnCategory)' (expected straight_complete)." }
  if ($vs.board.boardChange -ne 'polarizing') { throw "Post-write: boardChange='$($vs.board.boardChange)' (expected polarizing)." }
  if ($vs.board.equityShift -ne 'polarizes_btn') { throw "Post-write: equityShift='$($vs.board.equityShift)' (expected polarizes_btn)." }
  if ($vs.board.drawCompletion -ne 'straight_completed') { throw "Post-write: drawCompletion='$($vs.board.drawCompletion)' (expected straight_completed)." }
}

# Verify non-target M4 scenarios are byte-identical pre/post (drift-prevention)
foreach ($id in $nonTargetM4Ids) {
  $pre = $tgtById[$id]
  $post = $verById[$id]
  if (-not (Test-Equal $pre $post)) {
    throw "Post-write verification failed: non-target M4 scenario $id changed (drift)."
  }
}

# Verify scenario-array order preserved
$postOrder = @($verAll | ForEach-Object { $_.id })
if (($origOrder -join '|') -ne ($postOrder -join '|')) {
  throw "Post-write verification failed: scenario-array order changed."
}

# ----------------------------------------------------------------
# Summary
# ----------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " HOTFIX SUMMARY -- v4.3.2B M4 R1 Metadata Consistency Hotfix" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ("  Source:                   {0}" -f (Split-Path $sourcePath -Leaf))
Write-Host ("  Target:                   {0}" -f (Split-Path $targetPath -Leaf))
Write-Host ("  Target IDs:               {0}" -f $targetIds.Count)
Write-Host ("  Production total:         {0}  (unchanged)" -f $verAll.Count)
Write-Host ("  Production M4:            {0}  (unchanged; all approved)" -f $verM4.Count)
Write-Host ("  Non-target M4 byte-equal: {0} of {0}" -f $nonTargetM4Ids.Count)
Write-Host ("  Non-M4 untouched:         {0}" -f $verNonM4.Count)
Write-Host ("  Mode:                     {0}" -f $(if ($DryRun) { 'DryRun' } else { 'apply' }))
Write-Host ""
foreach ($entry in $plan) {
  Write-Host ("  {0}" -f $entry.id)
  if ($entry.fields.Count -eq 0) {
    Write-Host "    (no diff)" -ForegroundColor DarkGray
  } else {
    Write-Host ("    synced fields: {0}" -f ($entry.fields -join ', '))
  }
}
Write-Host ""
