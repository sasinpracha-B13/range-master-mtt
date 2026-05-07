# ============================================================
# tools/migrate-module4-v4.3.2.ps1
# v4.3.2 Module 4 Coverage Continuation -- Production Migration
#
# Migrates 20 NEW v4.3.2 continuation seeds from
#   docs/specs/postflop-v4.3.2-module4-continuation-seeds.json
# into production
#   postflop/postflop_scenarios.json
# (appending to existing 72 M4 scenarios = 24 baseline + 29 expansion + 19 polish).
#
# Idempotent: safe to re-run without producing duplicates.
# UTF-8 NO-BOM I/O. ASCII-clean.
#
# Pipeline:
#   1. Verify continuation source has expected planning_only seeds.
#   2. Verify production has exactly 72 M4 (24 baseline + 29 expansion + 19 polish)
#      and all of those approved.
#   3. Verify no continuation ID already exists in production with mismatching content.
#   4. Transform each continuation seed into production scenario.
#   5. Append to production; preserve 385 non-M4 + 72 existing M4.
#   6. Atomic write via tmp + Move-Item.
#
# Modes:
#   default        writes M4 continuation scenarios with auditStatus=review_pending
#   -FlipApproved  flips the continuation scenarios to auditStatus=approved
#                  (run after production audit at review_pending passes).
#   -DryRun        print plan without writing.
#
# Safety: NO Invoke-Expression, NO unsafe Remove-Item.
# ============================================================

[CmdletBinding()]
param(
  [switch]$FlipApproved,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$repoRoot   = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$sourcePath = Join-Path $repoRoot 'docs\specs\postflop-v4.3.2-module4-continuation-seeds.json'
$targetPath = Join-Path $repoRoot 'postflop\postflop_scenarios.json'

function Read-Utf8Json([string]$p) {
  if (-not (Test-Path $p)) { throw "File not found: $p" }
  $text = [System.IO.File]::ReadAllText($p, $utf8nb)
  return ($text | ConvertFrom-Json)
}

function Write-Utf8Json($obj, [string]$p) {
  $json = $obj | ConvertTo-Json -Depth 100
  [System.IO.File]::WriteAllText($p, $json, $utf8nb)
}

# ----------------------------------------------------------------
# Step 1 - Read + verify continuation source
# ----------------------------------------------------------------
Write-Host "Step 1 -- read continuation source JSON" -ForegroundColor Cyan
$src = Read-Utf8Json $sourcePath
$srcCont = @($src.scenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
Write-Host "  Source scenarios:        $($src.scenarios.Count)"
Write-Host "  Source M4 continuation:  $($srcCont.Count)"
if ($srcCont.Count -lt 1) {
  throw "Migration aborted: source has $($srcCont.Count) M4 continuation seeds. Expected at least 1."
}

$badAudit = @($srcCont | Where-Object { $_.auditStatus -ne 'planning_only' })
if ($badAudit.Count -gt 0) {
  throw "Migration aborted: $($badAudit.Count) source scenarios have auditStatus != 'planning_only'. Sources must be planning_only."
}
$badReview = @($srcCont | Where-Object { $_.reviewStatus -ne 'v4.3.2_continuation_candidate' })
if ($badReview.Count -gt 0) {
  Write-Host "  WARN: $($badReview.Count) source scenarios have non-standard reviewStatus" -ForegroundColor Yellow
}

# ----------------------------------------------------------------
# Step 2 - Read target production JSON + verify baseline
# ----------------------------------------------------------------
Write-Host "Step 2 -- read target production JSON" -ForegroundColor Cyan
$tgt = Read-Utf8Json $targetPath
$tgtAll = @($tgt.scenarios)
$tgtM4   = @($tgtAll | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
$tgtNonM4 = @($tgtAll | Where-Object { $_.module -ne 'pf_turn_barrel_oop_def' })
Write-Host "  Target scenarios total:  $($tgtAll.Count)"
Write-Host "  Target M4 baseline:      $($tgtM4.Count)"
Write-Host "  Target non-M4:           $($tgtNonM4.Count)"

if ($tgtNonM4.Count -ne 385) {
  throw "Migration aborted: expected 385 non-M4 scenarios, got $($tgtNonM4.Count). Production may have drifted."
}

# Two acceptable starting states:
#   A. Baseline: 72 M4 (24 baseline + 29 expansion + 19 polish, no continuation yet)
#   B. Re-run:   72 + 20 continuation already migrated (idempotent rebuild)
$srcIds = @($srcCont | ForEach-Object { $_.id })
$tgtContInProd = @($tgtM4 | Where-Object { $srcIds -contains $_.id })
$tgtBaselineM4   = @($tgtM4 | Where-Object { $srcIds -notcontains $_.id })

Write-Host "  Target M4 baseline (non-cont):       $($tgtBaselineM4.Count)"
Write-Host "  Target M4 continuation IDs in prod:  $($tgtContInProd.Count)"

if ($tgtBaselineM4.Count -ne 72) {
  throw "Migration aborted: expected 72 baseline M4 (non-continuation), got $($tgtBaselineM4.Count). Aborting."
}
$baselineNonApproved = @($tgtBaselineM4 | Where-Object { $_.auditStatus -ne 'approved' })
if ($baselineNonApproved.Count -gt 0) {
  throw "Migration aborted: $($baselineNonApproved.Count) of 72 baseline M4 scenarios are not auditStatus=approved."
}
if ($tgtContInProd.Count -ne 0 -and $tgtContInProd.Count -ne $srcCont.Count) {
  throw "Migration aborted: production has $($tgtContInProd.Count) of $($srcCont.Count) continuation IDs (partial state). Aborting."
}
if ($tgtContInProd.Count -eq $srcCont.Count -and -not $FlipApproved) {
  Write-Host "  (info) production already has all $($srcCont.Count) continuation scenarios -- re-run mode. Will rebuild continuation block idempotently." -ForegroundColor Yellow
}

# ----------------------------------------------------------------
# Step 3 - Transform each continuation seed -> production scenario
# ----------------------------------------------------------------
Write-Host "Step 3 -- transform M4 continuation seeds into production scenarios" -ForegroundColor Cyan

$targetAuditStatus = if ($FlipApproved) { 'approved' } else { 'review_pending' }
Write-Host "  Target auditStatus:      $targetAuditStatus"

$migratedCont = @()
foreach ($s in $srcCont) {
  $diffHint = if ($null -ne $s.difficultyHint -and $s.difficultyHint -gt 0) { [int]$s.difficultyHint } else { 3 }

  $prodScenario = [ordered]@{
    id                = $s.id
    version           = 'v4.3.2'
    game              = 'NLH_MTT'
    module            = 'pf_turn_barrel_oop_def'
    moduleName        = 'Facing Turn Barrel OOP'
    street            = 'turn'
    schemaVersion     = '1.2.0'
    actionHistory     = @()
    scoring           = [ordered]@{
      best       = 1
      acceptable = 0.5
      bad        = 0
      critical   = 0
    }
    difficulty        = $diffHint
    spot              = $s.spot
    board             = $s.board
    heroHand          = $s.heroHand
    handClass         = $s.handClass
    heroHandRole      = $s.heroHandRole
    drawCategory      = $s.drawCategory
    showdownValue     = $s.showdownValue
    blockerNote       = $s.blockerNote
    recommendedAction = $s.recommendedAction
    actionReason      = $s.actionReason
    question          = $s.question
    answer            = $s.answer
    explanation       = $s.explanation
    conceptTags       = $s.conceptTags
    sourceConfidence  = $s.sourceConfidence
    auditStatus       = $targetAuditStatus
    reviewStatus      = 'v4.3.2_strategic_reviewed'
  }
  $migratedCont += [PSCustomObject]$prodScenario
}
Write-Host "  Migrated continuation count:  $($migratedCont.Count)"

# ----------------------------------------------------------------
# Step 4 - Reassemble production: 385 non-M4 + 72 baseline M4 + N continuation
# ----------------------------------------------------------------
Write-Host "Step 4 -- reassemble production scenarios" -ForegroundColor Cyan
$newScenarios = $tgtNonM4 + $tgtBaselineM4 + $migratedCont
$expectedTotal = 385 + 72 + $srcCont.Count
Write-Host "  New scenarios total:     $($newScenarios.Count)  (expect $expectedTotal)"
if ($newScenarios.Count -ne $expectedTotal) {
  throw "Migration aborted: post-merge count is $($newScenarios.Count), expected $expectedTotal."
}

$newTarget = [ordered]@{}
foreach ($p in $tgt.PSObject.Properties) {
  if ($p.Name -eq 'scenarios') {
    $newTarget[$p.Name] = $newScenarios
  } else {
    $newTarget[$p.Name] = $p.Value
  }
}

# ----------------------------------------------------------------
# Step 5 - Write atomically (no Invoke-Expression, no Remove-Item)
# ----------------------------------------------------------------
if ($DryRun) {
  Write-Host "Step 5 -- DRY RUN, not writing" -ForegroundColor Yellow
} else {
  Write-Host "Step 5 -- write production JSON" -ForegroundColor Cyan
  $tmpPath = "$targetPath.tmp"
  Write-Utf8Json ([PSCustomObject]$newTarget) $tmpPath
  Move-Item -LiteralPath $tmpPath -Destination $targetPath -Force
  $newSize = (Get-Item $targetPath).Length
  Write-Host "  Wrote: $targetPath  ($newSize bytes)"
}

# ----------------------------------------------------------------
# Step 6 - Post-write verification (skip in DryRun)
# ----------------------------------------------------------------
if (-not $DryRun) {
  Write-Host "Step 6 -- verify post-write state" -ForegroundColor Cyan
  $ver = Read-Utf8Json $targetPath
  $verAll = @($ver.scenarios)
  $verM4 = @($verAll | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
  $verNonM4 = @($verAll | Where-Object { $_.module -ne 'pf_turn_barrel_oop_def' })
  if ($verAll.Count -ne $expectedTotal) { throw "Post-write verification failed: total $($verAll.Count) (expected $expectedTotal)." }
  if ($verNonM4.Count -ne 385) { throw "Post-write verification failed: non-M4 $($verNonM4.Count) (expected 385)." }
  if ($verM4.Count -ne (72 + $srcCont.Count)) { throw "Post-write verification failed: M4 $($verM4.Count) (expected $(72 + $srcCont.Count))." }
  $verContInProd = @($verM4 | Where-Object { $srcIds -contains $_.id })
  if ($verContInProd.Count -ne $srcCont.Count) { throw "Post-write verification failed: continuation IDs in prod $($verContInProd.Count) (expected $($srcCont.Count))." }
  $verBaseline = @($verM4 | Where-Object { $srcIds -notcontains $_.id })
  if ($verBaseline.Count -ne 72) { throw "Post-write verification failed: baseline M4 in prod $($verBaseline.Count) (expected 72)." }
  $verBaseNonApproved = @($verBaseline | Where-Object { $_.auditStatus -ne 'approved' })
  if ($verBaseNonApproved.Count -gt 0) { throw "Post-write verification failed: $($verBaseNonApproved.Count) baseline M4 scenarios changed away from approved." }
  $verContNotMatchingStatus = @($verContInProd | Where-Object { $_.auditStatus -ne $targetAuditStatus })
  if ($verContNotMatchingStatus.Count -gt 0) { throw "Post-write verification failed: $($verContNotMatchingStatus.Count) continuation scenarios not at target auditStatus '$targetAuditStatus'." }
}

# ----------------------------------------------------------------
# Summary
# ----------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " MIGRATION SUMMARY -- v4.3.2 M4 Coverage Continuation" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ("  Source:                  {0}" -f (Split-Path $sourcePath -Leaf))
Write-Host ("  Target:                  {0}" -f (Split-Path $targetPath -Leaf))
Write-Host ("  Source M4 continuation:  {0}" -f $srcCont.Count)
Write-Host ("  Production before:       {0}  (M4: {1})" -f $tgtAll.Count, $tgtM4.Count)
if (-not $DryRun) {
  Write-Host ("  Production after:        {0}  (M4: {1})" -f $newScenarios.Count, ($newScenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' }).Count)
}
Write-Host ("  M4 continuation auditStatus:  {0}" -f $targetAuditStatus)
Write-Host ("  Mode:                    {0}" -f $(if ($FlipApproved) { 'FlipApproved' } else { 'review_pending' }))
Write-Host ("  DryRun:                  {0}" -f $DryRun)
Write-Host ""
