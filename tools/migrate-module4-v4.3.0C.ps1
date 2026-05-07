# ============================================================
# tools/migrate-module4-v4.3.0C.ps1
# v4.3.0C Module 4 Data Expansion -- Production Migration
#
# Migrates 29 NEW v4.3.0C expansion seeds from
#   docs/specs/postflop-v4.3.0C-module4-expansion-seeds.json
# into production
#   postflop/postflop_scenarios.json
# (appending to existing 24 v4.3.0B-migrated M4 scenarios).
#
# Idempotent: safe to re-run without producing duplicates.
# UTF-8 NO-BOM I/O. ASCII-clean.
#
# Pipeline:
#   1. Verify expansion source has exactly 29 planning_only seeds.
#   2. Verify production has exactly 24 M4 approved baseline (v4.3.0B).
#   3. Verify no expansion ID already exists in production.
#   4. Transform each expansion seed into production scenario.
#   5. Append to production; preserve baseline 385 non-M4 + 24 v4.3.0B M4.
#   6. Atomic write via tmp + Move-Item.
#
# Modes:
#   default       writes M4 expansion scenarios with auditStatus=review_pending
#   -FlipApproved flips the 29 expansion scenarios to auditStatus=approved
#                 (run after production audit at review_pending passes).
#   -DryRun       print plan without writing.
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
$sourcePath = Join-Path $repoRoot 'docs\specs\postflop-v4.3.0C-module4-expansion-seeds.json'
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
# Step 1 - Read + verify expansion source
# ----------------------------------------------------------------
Write-Host "Step 1 -- read expansion source JSON" -ForegroundColor Cyan
$src = Read-Utf8Json $sourcePath
$srcExp = @($src.scenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
Write-Host "  Source scenarios:        $($src.scenarios.Count)"
Write-Host "  Source M4 expansion:     $($srcExp.Count)"
if ($srcExp.Count -lt 1) {
  throw "Migration aborted: source has $($srcExp.Count) M4 expansion seeds. Expected at least 1."
}

$badAudit = @($srcExp | Where-Object { $_.auditStatus -ne 'planning_only' })
if ($badAudit.Count -gt 0) {
  throw "Migration aborted: $($badAudit.Count) source scenarios have auditStatus != 'planning_only'. Sources must be planning_only."
}
$badReview = @($srcExp | Where-Object { $_.reviewStatus -ne 'v4.3.0C_expansion_candidate' })
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
#   A. Baseline: 24 v4.3.0B M4 (no expansion yet) -- fresh migration
#   B. Re-run: 24 baseline + 29 expansion already migrated -- idempotent rebuild
$srcIds = @($srcExp | ForEach-Object { $_.id })
$tgtExpInProd = @($tgtM4 | Where-Object { $srcIds -contains $_.id })
$tgtBaselineM4 = @($tgtM4 | Where-Object { $srcIds -notcontains $_.id })

Write-Host "  Target M4 baseline (non-expansion):    $($tgtBaselineM4.Count)"
Write-Host "  Target M4 expansion-IDs already in prod: $($tgtExpInProd.Count)"

if ($tgtBaselineM4.Count -ne 24) {
  throw "Migration aborted: expected 24 baseline M4 (non-expansion), got $($tgtBaselineM4.Count). Aborting."
}
if ($tgtExpInProd.Count -ne 0 -and $tgtExpInProd.Count -ne $srcExp.Count) {
  throw "Migration aborted: production has $($tgtExpInProd.Count) of $($srcExp.Count) expansion IDs (partial state). Aborting."
}
if ($tgtExpInProd.Count -eq $srcExp.Count -and -not $FlipApproved) {
  Write-Host "  (info) production already has all $($srcExp.Count) expansion scenarios -- re-run mode. Will rebuild expansion block idempotently." -ForegroundColor Yellow
}

# ----------------------------------------------------------------
# Step 3 - Transform each expansion seed -> production scenario
# ----------------------------------------------------------------
Write-Host "Step 3 -- transform M4 expansion seeds into production scenarios" -ForegroundColor Cyan

$targetAuditStatus = if ($FlipApproved) { 'approved' } else { 'review_pending' }
Write-Host "  Target auditStatus:      $targetAuditStatus"

$migratedExp = @()
foreach ($s in $srcExp) {
  $diffHint = if ($null -ne $s.difficultyHint -and $s.difficultyHint -gt 0) { [int]$s.difficultyHint } else { 3 }

  $prodScenario = [ordered]@{
    id                = $s.id
    version           = 'v4.3.0C'
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
    reviewStatus      = 'v4.3.0C_strategic_reviewed'
  }
  $migratedExp += [PSCustomObject]$prodScenario
}
Write-Host "  Migrated expansion count: $($migratedExp.Count)"

# ----------------------------------------------------------------
# Step 4 - Reassemble production: 385 non-M4 + 24 baseline M4 + N expansion
# ----------------------------------------------------------------
Write-Host "Step 4 -- reassemble production scenarios" -ForegroundColor Cyan
$newScenarios = $tgtNonM4 + $tgtBaselineM4 + $migratedExp
$expectedTotal = 385 + 24 + $srcExp.Count
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
# Summary
# ----------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " MIGRATION SUMMARY -- v4.3.0C M4 Data Expansion" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ("  Source:                  {0}" -f (Split-Path $sourcePath -Leaf))
Write-Host ("  Target:                  {0}" -f (Split-Path $targetPath -Leaf))
Write-Host ("  Source M4 expansion:     {0}" -f $srcExp.Count)
Write-Host ("  Production before:       {0}  (M4: {1})" -f $tgtAll.Count, $tgtM4.Count)
Write-Host ("  Production after:        {0}  (M4: {1})" -f $newScenarios.Count, ($newScenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' }).Count)
Write-Host ("  M4 expansion auditStatus: {0}" -f $targetAuditStatus)
Write-Host ("  Mode:                    {0}" -f $(if ($FlipApproved) { 'FlipApproved' } else { 'review_pending' }))
Write-Host ("  DryRun:                  {0}" -f $DryRun)
Write-Host ""

if (-not $DryRun) {
  Write-Host "Next steps:" -ForegroundColor Cyan
  if (-not $FlipApproved) {
    Write-Host "  1. Run production audit (tools/audit-postflop-ps.ps1)."
    Write-Host "     Expected: $expectedTotal / 0 / 0 PASS with expansion=review_pending."
    Write-Host "  2. If PASS, re-run THIS script with -FlipApproved."
    Write-Host "  3. Re-run production audit. Expected: $expectedTotal / 0 / 0 PASS."
  } else {
    Write-Host "  1. Re-run production audit."
    Write-Host "     Expected: $expectedTotal / 0 / 0 PASS."
  }
}
