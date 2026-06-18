# ============================================================
# tools/migrate-module5-v4.4.1.ps1
# v4.4.1 Module 5 Production Migration
# Migrates 24 reviewed Module 5 planning seeds from
# docs/specs/postflop-v4.4.0-module5-seed-scenarios.json
# into production postflop/postflop_scenarios.json.
#
# Idempotent: safe to re-run without producing duplicates.
# UTF-8 NO-BOM I/O. ASCII-clean.
#
# Migration source: post-strategic-review v4.4.0A seeds (HEAD a41a171+).
# Migration target: postflop/postflop_scenarios.json (477 -> 501 scenarios).
#
# Pipeline:
#   1. Verify source seed JSON has exactly 24 M5 scenarios (all planning_only).
#   2. Verify production JSON has 0 existing M5 scenarios (clean append) OR
#      24 existing M5 scenarios (re-run idempotency).
#   3. Transform each seed into a production scenario:
#      - Add: version=v4.4.1, game=NLH_MTT, street=river,
#             actionHistory=[], scoring={best:1,acceptable:0.5,bad:0,critical:0},
#             difficulty (from difficultyHint or 3),
#             auditStatus=review_pending (initial; flipped to approved by
#             re-running with -FlipApproved after audit passes)
#      - Strip: difficultyHint, uniquenessNote
#      - Set: reviewStatus='v4.4.0A_strategic_reviewed' (production convention)
#      - Preserve: id, module, moduleName, schemaVersion (=1.3.0),
#                  spot, board (5-card structure with M5 river fields),
#                  heroHand, handClass, heroHandRole, drawCategory,
#                  showdownValue, blockerNote, recommendedAction,
#                  actionReason, question, answer, explanation (with
#                  riverLogic), conceptTags, sourceConfidence
#   4. Append to production JSON; preserve existing 477 scenarios byte-identical.
#   5. Write production JSON atomically (tmp + Move-Item).
#
# Mode flag (-FlipApproved): if set, also flip auditStatus on all 24
# M5 scenarios to 'approved'. Run this AFTER production audit passes
# at 501/0/0 with auditStatus=review_pending. Idempotent.
# ============================================================

[CmdletBinding()]
param(
  [switch]$FlipApproved,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$repoRoot   = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$sourcePath = Join-Path $repoRoot 'docs\specs\postflop-v4.4.0-module5-seed-scenarios.json'
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
$srcM5 = @($src.scenarios | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' })
Write-Host "  Source scenarios:        $($src.scenarios.Count)"
Write-Host "  Source M5 (planning):    $($srcM5.Count)"
if ($srcM5.Count -ne 24) {
  throw "Migration aborted: expected 24 planning M5 seeds, got $($srcM5.Count). Will not partially migrate."
}

# Double-check planning auditStatus before touching production
$badAudit = @($srcM5 | Where-Object { $_.auditStatus -ne 'planning_only' })
if ($badAudit.Count -gt 0) {
  throw "Migration aborted: $($badAudit.Count) source scenarios have auditStatus != 'planning_only'. Sources must be planning_only at sprint start."
}
$badReview = @($srcM5 | Where-Object { $_.reviewStatus -ne 'v4.4.0_seed_candidate' })
if ($badReview.Count -gt 0) {
  Write-Host "  (info) source reviewStatus values: $(($srcM5 | Group-Object reviewStatus | ForEach-Object { "$($_.Name)x$($_.Count)" }) -join ', ')"
}

# ----------------------------------------------------------------
# Step 2 - Read target production JSON + idempotency check
# ----------------------------------------------------------------
Write-Host "Step 2 -- read target production JSON" -ForegroundColor Cyan
$tgt = Read-Utf8Json $targetPath
$tgtAll = @($tgt.scenarios)
$tgtM5   = @($tgtAll | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' })
$tgtNonM5 = @($tgtAll | Where-Object { $_.module -ne 'pf_river_barrel_oop_def' })
Write-Host "  Target scenarios total:  $($tgtAll.Count)"
Write-Host "  Target M5 existing:      $($tgtM5.Count)"
Write-Host "  Target non-M5:           $($tgtNonM5.Count)"

if ($tgtM5.Count -ne 0 -and $tgtM5.Count -ne 24) {
  throw "Migration aborted: production has $($tgtM5.Count) M5 scenarios -- inconsistent state. Expected 0 (fresh migration) or 24 (re-run/idempotent). Manual cleanup required."
}
if ($tgtM5.Count -eq 24 -and -not $FlipApproved) {
  Write-Host "  (info) production already has 24 M5 scenarios -- re-run mode. Will rebuild M5 block from source idempotently." -ForegroundColor Yellow
}
if ($tgtNonM5.Count -ne 477) {
  throw "Migration aborted: expected 477 non-M5 scenarios, got $($tgtNonM5.Count). Production may have drifted; aborting to avoid corruption."
}

# ----------------------------------------------------------------
# Step 3 - Transform each M5 seed -> production scenario
# ----------------------------------------------------------------
Write-Host "Step 3 -- transform M5 seeds into production scenarios" -ForegroundColor Cyan

# Decide auditStatus: review_pending by default; approved only if -FlipApproved
$targetAuditStatus = if ($FlipApproved) { 'approved' } else { 'review_pending' }
Write-Host "  Target auditStatus:      $targetAuditStatus"

$migratedM5 = @()
foreach ($s in $srcM5) {
  $diffHint = if ($null -ne $s.difficultyHint -and $s.difficultyHint -gt 0) { [int]$s.difficultyHint } else { 3 }

  $prodScenario = [ordered]@{
    id                = $s.id
    version           = 'v4.4.1'
    game              = 'NLH_MTT'
    module            = 'pf_river_barrel_oop_def'
    moduleName        = 'Facing River Barrel OOP'
    street            = 'river'
    schemaVersion     = '1.3.0'
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
    reviewStatus      = 'v4.4.0A_strategic_reviewed'
  }
  $migratedM5 += [PSCustomObject]$prodScenario
}
Write-Host "  Migrated M5 count:       $($migratedM5.Count)"

# ----------------------------------------------------------------
# Step 4 - Reassemble production JSON: 477 non-M5 + 24 M5 = 501
# ----------------------------------------------------------------
Write-Host "Step 4 -- reassemble production scenarios" -ForegroundColor Cyan
$newScenarios = $tgtNonM5 + $migratedM5
Write-Host "  New scenarios total:     $($newScenarios.Count)  (expect 501)"
if ($newScenarios.Count -ne 501) {
  throw "Migration aborted: post-merge count is $($newScenarios.Count), expected 501. Aborting before write."
}

# Preserve top-level keys from existing target; refresh the (previously stale)
# top-level description to reflect the current production composition. The
# runtime only reads data.schemaVersion + data.scenarios, so this is metadata
# hygiene -- but a file that self-describes as "385 scenarios" while holding 501
# is exactly the drift this project guards against. Kept in the migration script
# (not hand-edited) so the data file stays reproducible from source.
$m5Desc = 'v4.4.1 - Module 5 (Facing River Barrel OOP) production migration. Total 501 scenarios: 251 M1 (board texture) + 49 M2 (flop c-bet IP) + 85 M3 (flop defense OOP) + 92 M4 (turn defense OOP) + 24 M5 (river defense OOP). M5 = BB river defense vs BTN third barrel, schemaVersion 1.3.0 per-scenario (5-card board, river showdown-only). Data-loaded + approved; M5 runtime-wired in v4.4.2. Spot context: BTN open 2.5x vs BB call, 100BB SRP, NLH MTT chipEV.'
$newTarget = [ordered]@{}
foreach ($p in $tgt.PSObject.Properties) {
  if ($p.Name -eq 'scenarios') {
    $newTarget[$p.Name] = $newScenarios
  } elseif ($p.Name -eq 'description') {
    $newTarget[$p.Name] = $m5Desc
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
Write-Host " MIGRATION SUMMARY -- v4.4.1 Module 5 Production Migration" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ("  Source:                  {0}" -f (Split-Path $sourcePath -Leaf))
Write-Host ("  Target:                  {0}" -f (Split-Path $targetPath -Leaf))
Write-Host ("  Source M5 seeds:         {0}  (expected 24)" -f $srcM5.Count)
Write-Host ("  Production before:       {0}  (M5: {1})" -f $tgtAll.Count, $tgtM5.Count)
Write-Host ("  Production after:        {0}  (M5: {1})" -f $newScenarios.Count, ($newScenarios | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' }).Count)
Write-Host ("  M5 auditStatus written:  {0}" -f $targetAuditStatus)
Write-Host ("  Mode:                    {0}" -f $(if ($FlipApproved) { 'FlipApproved' } else { 'review_pending' }))
Write-Host ("  DryRun:                  {0}" -f $DryRun)
Write-Host ""

if (-not $DryRun) {
  Write-Host "Next steps:" -ForegroundColor Cyan
  if (-not $FlipApproved) {
    Write-Host "  1. Run production audit (tools/audit-postflop-ps.ps1)."
    Write-Host "     Expected: 501 / 0 / 0 PASS with auditStatus=review_pending."
    Write-Host "  2. If PASS, re-run THIS script with -FlipApproved to flip status to approved."
    Write-Host "  3. Re-run production audit. Expected: 501 / 0 / 0 PASS."
  } else {
    Write-Host "  1. Re-run production audit (tools/audit-postflop-ps.ps1)."
    Write-Host "     Expected: 501 / 0 / 0 PASS."
  }
}
