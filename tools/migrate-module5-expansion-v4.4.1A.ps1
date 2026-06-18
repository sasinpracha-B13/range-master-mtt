# ============================================================
# tools/migrate-module5-expansion-v4.4.1A.ps1
# v4.4.1A Module 5 EXPANSION migration (501 -> 509).
# Migrates the 8 strategically-reviewed v4.4.1A expansion seeds from
# docs/specs/postflop-v4.4.1A-module5-expansion-seeds.json into
# production postflop/postflop_scenarios.json, PRESERVING the existing
# 24 v4.4.1 M5 scenarios (add-not-replace).
#
# Idempotent: safe to re-run (removes-then-re-adds the 8 by id).
# UTF-8 NO-BOM I/O. ASCII-clean. No Invoke-Expression / unsafe Remove-Item.
# Two-phase: default auditStatus=review_pending; -FlipApproved -> approved.
#
# Transform (per seed): add version=v4.4.1A, game=NLH_MTT, street=river,
#   actionHistory=[], scoring={best:1,acceptable:0.5,bad:0,critical:0},
#   difficulty (from difficultyHint), auditStatus, reviewStatus=
#   v4.4.1A_strategic_reviewed; strip difficultyHint, uniquenessNote;
#   preserve all M5 content fields.
# ============================================================

[CmdletBinding()]
param(
  [switch]$FlipApproved,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$repoRoot   = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$sourcePath = Join-Path $repoRoot 'docs\specs\postflop-v4.4.1A-module5-expansion-seeds.json'
$targetPath = Join-Path $repoRoot 'postflop\postflop_scenarios.json'

function Read-Utf8Json([string]$p) {
  if (-not (Test-Path $p)) { throw "File not found: $p" }
  return ([System.IO.File]::ReadAllText($p, $utf8nb) | ConvertFrom-Json)
}
function Write-Utf8Json($obj, [string]$p) {
  $json = $obj | ConvertTo-Json -Depth 100
  [System.IO.File]::WriteAllText($p, $json, $utf8nb)
}

# ---- Step 1: read + verify source ----
Write-Host "Step 1 -- read expansion seed JSON" -ForegroundColor Cyan
$src = Read-Utf8Json $sourcePath
$srcM5 = @($src.scenarios | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' })
Write-Host "  Source M5 expansion seeds: $($srcM5.Count)"
if ($srcM5.Count -ne 8) { throw "Migration aborted: expected 8 expansion seeds, got $($srcM5.Count)." }
$badAudit = @($srcM5 | Where-Object { $_.auditStatus -ne 'planning_only' })
if ($badAudit.Count -gt 0) { throw "Migration aborted: $($badAudit.Count) source seeds not planning_only." }
$badReview = @($srcM5 | Where-Object { $_.reviewStatus -ne 'v4.4.1A_expansion_candidate' })
if ($badReview.Count -gt 0) { throw "Migration aborted: $($badReview.Count) source seeds not v4.4.1A_expansion_candidate." }
$expIds = @($srcM5 | ForEach-Object { [string]$_.id })

# ---- Step 2: read target + idempotency ----
Write-Host "Step 2 -- read production JSON" -ForegroundColor Cyan
$tgt = Read-Utf8Json $targetPath
$tgtAll = @($tgt.scenarios)
Write-Host "  Production total: $($tgtAll.Count)"
$expSet = @{}; foreach ($id in $expIds) { $expSet[$id] = $true }
$keep = @($tgtAll | Where-Object { -not $expSet.ContainsKey([string]$_.id) })
$present = $tgtAll.Count - $keep.Count
Write-Host "  Expansion ids already in production: $present (0=fresh, 8=re-run)"
if ($present -ne 0 -and $present -ne 8) {
  throw "Migration aborted: $present of 8 expansion ids present -- inconsistent. Expected 0 (fresh) or 8 (re-run)."
}
# keep must be the stable base: 477 non-M5 + 24 v4.4.1 M5 = 501
$keepM5 = @($keep | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' })
if ($keep.Count -ne 501) { throw "Migration aborted: base (non-expansion) count is $($keep.Count), expected 501. Production drift; aborting." }
if ($keepM5.Count -ne 24) { throw "Migration aborted: base has $($keepM5.Count) M5 scenarios, expected 24 (the v4.4.1 batch). Aborting." }

# ---- Step 3: transform ----
Write-Host "Step 3 -- transform expansion seeds" -ForegroundColor Cyan
$targetAuditStatus = if ($FlipApproved) { 'approved' } else { 'review_pending' }
Write-Host "  Target auditStatus: $targetAuditStatus"
$migrated = @()
foreach ($s in $srcM5) {
  $diffHint = if ($null -ne $s.difficultyHint -and $s.difficultyHint -gt 0) { [int]$s.difficultyHint } else { 3 }
  $prod = [ordered]@{
    id                = $s.id
    version           = 'v4.4.1A'
    game              = 'NLH_MTT'
    module            = 'pf_river_barrel_oop_def'
    moduleName        = 'Facing River Barrel OOP'
    street            = 'river'
    schemaVersion     = '1.3.0'
    actionHistory     = @()
    scoring           = [ordered]@{ best = 1; acceptable = 0.5; bad = 0; critical = 0 }
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
    reviewStatus      = 'v4.4.1A_strategic_reviewed'
  }
  $migrated += [PSCustomObject]$prod
}
Write-Host "  Migrated: $($migrated.Count)"

# ---- Step 4: reassemble (keep 501 + 8 = 509) ----
Write-Host "Step 4 -- reassemble" -ForegroundColor Cyan
$newScenarios = $keep + $migrated
Write-Host "  New total: $($newScenarios.Count)  (expect 509)"
if ($newScenarios.Count -ne 509) { throw "Migration aborted: post-merge count $($newScenarios.Count), expected 509." }
$newM5 = @($newScenarios | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' })
if ($newM5.Count -ne 32) { throw "Migration aborted: M5 count $($newM5.Count), expected 32." }

$m5Desc = 'v4.4.1A - Module 5 (Facing River Barrel OOP) expansion. Total 509 scenarios: 251 M1 (board texture) + 49 M2 (flop c-bet IP) + 85 M3 (flop defense OOP) + 92 M4 (turn defense OOP) + 32 M5 (river defense OOP). M5 = BB river defense vs BTN third barrel, schemaVersion 1.3.0 per-scenario (5-card board, river showdown-only). Data-loaded + approved; M5 runtime-wired in v4.4.2. Spot context: BTN open 2.5x vs BB call, 100BB SRP, NLH MTT chipEV.'
$newTarget = [ordered]@{}
foreach ($p in $tgt.PSObject.Properties) {
  if ($p.Name -eq 'scenarios') { $newTarget[$p.Name] = $newScenarios }
  elseif ($p.Name -eq 'description') { $newTarget[$p.Name] = $m5Desc }
  else { $newTarget[$p.Name] = $p.Value }
}

# ---- Step 5: write ----
if ($DryRun) {
  Write-Host "Step 5 -- DRY RUN, not writing" -ForegroundColor Yellow
} else {
  Write-Host "Step 5 -- write production JSON" -ForegroundColor Cyan
  $tmp = "$targetPath.tmp"
  Write-Utf8Json ([PSCustomObject]$newTarget) $tmp
  Move-Item -LiteralPath $tmp -Destination $targetPath -Force
  Write-Host "  Wrote: $targetPath  ($((Get-Item $targetPath).Length) bytes)"
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " MIGRATION SUMMARY -- v4.4.1A Module 5 Expansion" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ("  Source expansion seeds:  {0}  (expected 8)" -f $srcM5.Count)
Write-Host ("  Production before:        {0}  (M5: {1})" -f $tgtAll.Count, (@($tgtAll | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' }).Count))
Write-Host ("  Production after:         {0}  (M5: {1})" -f $newScenarios.Count, $newM5.Count)
Write-Host ("  M5 auditStatus written:  {0}" -f $targetAuditStatus)
Write-Host ("  Mode:                    {0}" -f $(if ($FlipApproved) { 'FlipApproved' } else { 'review_pending' }))
Write-Host ("  DryRun:                  {0}" -f $DryRun)
if (-not $DryRun) {
  Write-Host ""
  Write-Host "Next: run tools/audit-postflop-ps.ps1 (expect 509/0/0); if PASS and not yet approved, re-run with -FlipApproved." -ForegroundColor Cyan
}
