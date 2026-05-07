# ============================================================
# tools/migrate-module4-v4.3.0D.ps1
# v4.3.0D Module 4 Coverage Polish -- Production Migration
#
# Migrates 19 NEW v4.3.0D polish seeds from
#   docs/specs/postflop-v4.3.0D-module4-polish-seeds.json
# into production
#   postflop/postflop_scenarios.json
# (appending to existing 53 M4 scenarios = 24 baseline + 29 expansion).
#
# Idempotent: safe to re-run without producing duplicates.
# UTF-8 NO-BOM I/O. ASCII-clean.
#
# Pipeline:
#   1. Verify polish source has expected planning_only seeds.
#   2. Verify production has exactly 53 M4 (24 baseline + 29 expansion)
#      and all of those approved.
#   3. Verify no polish ID already exists in production with mismatching content.
#   4. Transform each polish seed into production scenario.
#   5. Append to production; preserve 385 non-M4 + 53 existing M4.
#   6. Atomic write via tmp + Move-Item.
#
# Modes:
#   default        writes M4 polish scenarios with auditStatus=review_pending
#   -FlipApproved  flips the polish scenarios to auditStatus=approved
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
$sourcePath = Join-Path $repoRoot 'docs\specs\postflop-v4.3.0D-module4-polish-seeds.json'
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
# Step 1 - Read + verify polish source
# ----------------------------------------------------------------
Write-Host "Step 1 -- read polish source JSON" -ForegroundColor Cyan
$src = Read-Utf8Json $sourcePath
$srcPolish = @($src.scenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
Write-Host "  Source scenarios:        $($src.scenarios.Count)"
Write-Host "  Source M4 polish:        $($srcPolish.Count)"
if ($srcPolish.Count -lt 1) {
  throw "Migration aborted: source has $($srcPolish.Count) M4 polish seeds. Expected at least 1."
}

$badAudit = @($srcPolish | Where-Object { $_.auditStatus -ne 'planning_only' })
if ($badAudit.Count -gt 0) {
  throw "Migration aborted: $($badAudit.Count) source scenarios have auditStatus != 'planning_only'. Sources must be planning_only."
}
$badReview = @($srcPolish | Where-Object { $_.reviewStatus -ne 'v4.3.0D_polish_candidate' })
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
#   A. Baseline: 53 M4 (24 baseline + 29 expansion, no polish yet) -- fresh migration
#   B. Re-run:   53 + 19 polish already migrated -- idempotent rebuild
$srcIds = @($srcPolish | ForEach-Object { $_.id })
$tgtPolishInProd = @($tgtM4 | Where-Object { $srcIds -contains $_.id })
$tgtBaselineM4   = @($tgtM4 | Where-Object { $srcIds -notcontains $_.id })

Write-Host "  Target M4 baseline (non-polish):       $($tgtBaselineM4.Count)"
Write-Host "  Target M4 polish-IDs already in prod:  $($tgtPolishInProd.Count)"

if ($tgtBaselineM4.Count -ne 53) {
  throw "Migration aborted: expected 53 baseline M4 (non-polish), got $($tgtBaselineM4.Count). Aborting."
}
$baselineNonApproved = @($tgtBaselineM4 | Where-Object { $_.auditStatus -ne 'approved' })
if ($baselineNonApproved.Count -gt 0) {
  throw "Migration aborted: $($baselineNonApproved.Count) of 53 baseline M4 scenarios are not auditStatus=approved."
}
if ($tgtPolishInProd.Count -ne 0 -and $tgtPolishInProd.Count -ne $srcPolish.Count) {
  throw "Migration aborted: production has $($tgtPolishInProd.Count) of $($srcPolish.Count) polish IDs (partial state). Aborting."
}
if ($tgtPolishInProd.Count -eq $srcPolish.Count -and -not $FlipApproved) {
  Write-Host "  (info) production already has all $($srcPolish.Count) polish scenarios -- re-run mode. Will rebuild polish block idempotently." -ForegroundColor Yellow
}

# ----------------------------------------------------------------
# Step 3 - Transform each polish seed -> production scenario
# ----------------------------------------------------------------
Write-Host "Step 3 -- transform M4 polish seeds into production scenarios" -ForegroundColor Cyan

$targetAuditStatus = if ($FlipApproved) { 'approved' } else { 'review_pending' }
Write-Host "  Target auditStatus:      $targetAuditStatus"

$migratedPolish = @()
foreach ($s in $srcPolish) {
  $diffHint = if ($null -ne $s.difficultyHint -and $s.difficultyHint -gt 0) { [int]$s.difficultyHint } else { 3 }

  $prodScenario = [ordered]@{
    id                = $s.id
    version           = 'v4.3.0D'
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
    reviewStatus      = 'v4.3.0D_strategic_reviewed'
  }
  $migratedPolish += [PSCustomObject]$prodScenario
}
Write-Host "  Migrated polish count:   $($migratedPolish.Count)"

# ----------------------------------------------------------------
# Step 4 - Reassemble production: 385 non-M4 + 53 baseline M4 + N polish
# ----------------------------------------------------------------
Write-Host "Step 4 -- reassemble production scenarios" -ForegroundColor Cyan
$newScenarios = $tgtNonM4 + $tgtBaselineM4 + $migratedPolish
$expectedTotal = 385 + 53 + $srcPolish.Count
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
  if ($verM4.Count -ne (53 + $srcPolish.Count)) { throw "Post-write verification failed: M4 $($verM4.Count) (expected $(53 + $srcPolish.Count))." }
  $verPolishInProd = @($verM4 | Where-Object { $srcIds -contains $_.id })
  if ($verPolishInProd.Count -ne $srcPolish.Count) { throw "Post-write verification failed: polish IDs in prod $($verPolishInProd.Count) (expected $($srcPolish.Count))." }
  $verBaseline = @($verM4 | Where-Object { $srcIds -notcontains $_.id })
  if ($verBaseline.Count -ne 53) { throw "Post-write verification failed: baseline M4 in prod $($verBaseline.Count) (expected 53)." }
  $verBaseNonApproved = @($verBaseline | Where-Object { $_.auditStatus -ne 'approved' })
  if ($verBaseNonApproved.Count -gt 0) { throw "Post-write verification failed: $($verBaseNonApproved.Count) baseline M4 scenarios changed away from approved." }
  $verPolishNotMatchingStatus = @($verPolishInProd | Where-Object { $_.auditStatus -ne $targetAuditStatus })
  if ($verPolishNotMatchingStatus.Count -gt 0) { throw "Post-write verification failed: $($verPolishNotMatchingStatus.Count) polish scenarios not at target auditStatus '$targetAuditStatus'." }
}

# ----------------------------------------------------------------
# Summary
# ----------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " MIGRATION SUMMARY -- v4.3.0D M4 Coverage Polish" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ("  Source:                  {0}" -f (Split-Path $sourcePath -Leaf))
Write-Host ("  Target:                  {0}" -f (Split-Path $targetPath -Leaf))
Write-Host ("  Source M4 polish:        {0}" -f $srcPolish.Count)
Write-Host ("  Production before:       {0}  (M4: {1})" -f $tgtAll.Count, $tgtM4.Count)
if (-not $DryRun) {
  Write-Host ("  Production after:        {0}  (M4: {1})" -f $newScenarios.Count, ($newScenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' }).Count)
}
Write-Host ("  M4 polish auditStatus:   {0}" -f $targetAuditStatus)
Write-Host ("  Mode:                    {0}" -f $(if ($FlipApproved) { 'FlipApproved' } else { 'review_pending' }))
Write-Host ("  DryRun:                  {0}" -f $DryRun)
Write-Host ""

if (-not $DryRun) {
  Write-Host "Next steps:" -ForegroundColor Cyan
  if (-not $FlipApproved) {
    Write-Host "  1. Run production audit (tools/audit-postflop-ps.ps1)."
    Write-Host "     Expected: $expectedTotal / 0 / 0 PASS with polish=review_pending."
    Write-Host "  2. If PASS, re-run THIS script with -FlipApproved."
    Write-Host "  3. Re-run production audit. Expected: $expectedTotal / 0 / 0 PASS."
  } else {
    Write-Host "  Final state. Re-run production audit to confirm: $expectedTotal / 0 / 0 PASS."
  }
}
