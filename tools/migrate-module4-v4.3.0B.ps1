# ============================================================
# tools/migrate-module4-v4.3.0B.ps1
# v4.3.0B Module 4 Production Migration
# Migrates 24 reviewed Module 4 planning seeds from
# docs/specs/postflop-v4.3.0-module4-seed-scenarios.json
# into production postflop/postflop_scenarios.json.
#
# Idempotent: safe to re-run without producing duplicates.
# UTF-8 NO-BOM I/O. ASCII-clean.
#
# Migration source: post-strategic-review v4.3.0A seeds (HEAD ab26aee+).
# Migration target: postflop/postflop_scenarios.json (385 -> 409 scenarios).
#
# Pipeline:
#   1. Verify source seed JSON has exactly 24 M4 scenarios.
#   2. Verify production JSON has 0 existing M4 scenarios (clean append) OR
#      has 24 existing M4 scenarios (re-run idempotency).
#   3. Transform each seed into a production scenario:
#      - Add: version=v4.3.0B, game=NLH_MTT, street=turn,
#             actionHistory=[], scoring={best:1,acceptable:0.5,bad:0,critical:0},
#             difficulty (from difficultyHint or 3),
#             auditStatus=review_pending (initial; flipped to approved by
#             a separate post-audit step OR by re-running this script)
#      - Strip: difficultyHint, uniquenessNote
#      - Set: reviewStatus='v4.3.0A_strategic_reviewed' (production convention)
#      - Preserve: id, module, moduleName, schemaVersion (=1.2.0),
#                  spot, board (4-card structure with M4 turn fields),
#                  heroHand, handClass, heroHandRole, drawCategory,
#                  showdownValue, blockerNote, recommendedAction,
#                  actionReason, question, answer, explanation (with
#                  turnLogic), conceptTags, sourceConfidence
#   4. Append to production JSON; preserve existing 385 scenarios byte-identical.
#   5. Write production JSON atomically.
#
# Mode flag (-FlipApproved): if set, also flip auditStatus on all 24
# M4 scenarios to 'approved'. Run this AFTER production audit passes
# at 409/0/0 with auditStatus=review_pending. Idempotent.
# ============================================================

[CmdletBinding()]
param(
  [switch]$FlipApproved,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$repoRoot   = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$sourcePath = Join-Path $repoRoot 'docs\specs\postflop-v4.3.0-module4-seed-scenarios.json'
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
# Step 1 - Read + verify source
# ----------------------------------------------------------------
Write-Host "Step 1 -- read source seed JSON" -ForegroundColor Cyan
$src = Read-Utf8Json $sourcePath
$srcM4 = @($src.scenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
Write-Host "  Source scenarios:        $($src.scenarios.Count)"
Write-Host "  Source M4 (planning):    $($srcM4.Count)"
if ($srcM4.Count -ne 24) {
  throw "Migration aborted: expected 24 planning M4 seeds, got $($srcM4.Count). Will not partially migrate."
}

# Double-check planning auditStatus before touching production
$badAudit = @($srcM4 | Where-Object { $_.auditStatus -ne 'planning_only' })
if ($badAudit.Count -gt 0) {
  throw "Migration aborted: $($badAudit.Count) source scenarios have auditStatus != 'planning_only'. Sources must be planning_only at sprint start."
}
$badReview = @($srcM4 | Where-Object { $_.reviewStatus -ne 'v4.3.0_seed_candidate' })
if ($badReview.Count -gt 0) {
  Write-Host "  (info) source reviewStatus values: $(($srcM4 | Group-Object reviewStatus | ForEach-Object { "$($_.Name)x$($_.Count)" }) -join ', ')"
}

# ----------------------------------------------------------------
# Step 2 - Read target production JSON + idempotency check
# ----------------------------------------------------------------
Write-Host "Step 2 -- read target production JSON" -ForegroundColor Cyan
$tgt = Read-Utf8Json $targetPath
$tgtAll = @($tgt.scenarios)
$tgtM4   = @($tgtAll | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
$tgtNonM4 = @($tgtAll | Where-Object { $_.module -ne 'pf_turn_barrel_oop_def' })
Write-Host "  Target scenarios total:  $($tgtAll.Count)"
Write-Host "  Target M4 existing:      $($tgtM4.Count)"
Write-Host "  Target non-M4:           $($tgtNonM4.Count)"

if ($tgtM4.Count -ne 0 -and $tgtM4.Count -ne 24) {
  throw "Migration aborted: production has $($tgtM4.Count) M4 scenarios -- inconsistent state. Expected 0 (fresh migration) or 24 (re-run/idempotent). Manual cleanup required."
}
if ($tgtM4.Count -eq 24 -and -not $FlipApproved) {
  Write-Host "  (info) production already has 24 M4 scenarios -- re-run mode. Will rebuild M4 block from source idempotently." -ForegroundColor Yellow
}
if ($tgtNonM4.Count -ne 385) {
  throw "Migration aborted: expected 385 non-M4 scenarios, got $($tgtNonM4.Count). Production may have drifted; aborting to avoid corruption."
}

# ----------------------------------------------------------------
# Step 3 - Transform each M4 seed -> production scenario
# ----------------------------------------------------------------
Write-Host "Step 3 -- transform M4 seeds into production scenarios" -ForegroundColor Cyan

# Decide auditStatus: review_pending by default; approved only if -FlipApproved
$targetAuditStatus = if ($FlipApproved) { 'approved' } else { 'review_pending' }
Write-Host "  Target auditStatus:      $targetAuditStatus"

$migratedM4 = @()
foreach ($s in $srcM4) {
  $diffHint = if ($null -ne $s.difficultyHint -and $s.difficultyHint -gt 0) { [int]$s.difficultyHint } else { 3 }

  $prodScenario = [ordered]@{
    id                = $s.id
    version           = 'v4.3.0B'
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
    reviewStatus      = 'v4.3.0A_strategic_reviewed'
  }
  $migratedM4 += [PSCustomObject]$prodScenario
}
Write-Host "  Migrated M4 count:       $($migratedM4.Count)"

# ----------------------------------------------------------------
# Step 4 - Reassemble production JSON: 385 non-M4 + 24 M4 = 409
# ----------------------------------------------------------------
Write-Host "Step 4 -- reassemble production scenarios" -ForegroundColor Cyan
$newScenarios = $tgtNonM4 + $migratedM4
Write-Host "  New scenarios total:     $($newScenarios.Count)  (expect 409)"
if ($newScenarios.Count -ne 409) {
  throw "Migration aborted: post-merge count is $($newScenarios.Count), expected 409. Aborting before write."
}

# Preserve top-level keys from existing target
$newTarget = [ordered]@{}
foreach ($p in $tgt.PSObject.Properties) {
  if ($p.Name -eq 'scenarios') {
    $newTarget[$p.Name] = $newScenarios
  } else {
    $newTarget[$p.Name] = $p.Value
  }
}

# ----------------------------------------------------------------
# Step 5 - Write atomically (or dry run)
# ----------------------------------------------------------------
if ($DryRun) {
  Write-Host "Step 5 -- DRY RUN, not writing" -ForegroundColor Yellow
  Write-Host "  Would write to: $targetPath"
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
Write-Host " MIGRATION SUMMARY -- v4.3.0B Module 4 Production Migration" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ("  Source:                  {0}" -f (Split-Path $sourcePath -Leaf))
Write-Host ("  Target:                  {0}" -f (Split-Path $targetPath -Leaf))
Write-Host ("  Source M4 seeds:         {0}  (expected 24)" -f $srcM4.Count)
Write-Host ("  Production before:       {0}  (M4: {1})" -f $tgtAll.Count, $tgtM4.Count)
Write-Host ("  Production after:        {0}  (M4: {1})" -f $newScenarios.Count, ($newScenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' }).Count)
Write-Host ("  M4 auditStatus written:  {0}" -f $targetAuditStatus)
Write-Host ("  Mode:                    {0}" -f $(if ($FlipApproved) { 'FlipApproved' } else { 'review_pending' }))
Write-Host ("  DryRun:                  {0}" -f $DryRun)
Write-Host ""

if (-not $DryRun) {
  Write-Host "Next steps:" -ForegroundColor Cyan
  if (-not $FlipApproved) {
    Write-Host "  1. Run production audit (tools/audit-postflop-ps.ps1)."
    Write-Host "     Expected: 409 / 0 / 0 PASS with auditStatus=review_pending."
    Write-Host "  2. If PASS, re-run THIS script with -FlipApproved to flip status to approved."
    Write-Host "  3. Re-run production audit. Expected: 409 / 0 / 0 PASS."
  } else {
    Write-Host "  1. Re-run production audit (tools/audit-postflop-ps.ps1)."
    Write-Host "     Expected: 409 / 0 / 0 PASS."
  }
}
