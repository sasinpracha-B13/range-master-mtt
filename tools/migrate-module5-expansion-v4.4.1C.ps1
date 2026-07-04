# ============================================================
# tools/migrate-module5-expansion-v4.4.1C.ps1
# v4.4.1C Module 5 straight-blocker-mix migration (509 -> 510).
# Migrates the 1 reviewed v4.4.1C seed from
# docs/specs/postflop-v4.4.1C-module5-expansion-seeds.json into
# production postflop/postflop_scenarios.json, PRESERVING the existing
# 32 M5 scenarios (add-not-replace).
#
# Idempotent (removes-then-re-adds the 1 id). UTF-8 NO-BOM, atomic
# tmp+Move-Item, no Invoke-Expression / unsafe Remove-Item.
# Two-phase: default review_pending; -FlipApproved -> approved.
# ============================================================

[CmdletBinding()]
param(
  [switch]$FlipApproved,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$repoRoot   = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$sourcePath = Join-Path $repoRoot 'docs\specs\postflop-v4.4.1C-module5-expansion-seeds.json'
$targetPath = Join-Path $repoRoot 'postflop\postflop_scenarios.json'

function Read-Utf8Json([string]$p) {
  if (-not (Test-Path $p)) { throw "File not found: $p" }
  return ([System.IO.File]::ReadAllText($p, $utf8nb) | ConvertFrom-Json)
}
function Write-Utf8Json($obj, [string]$p) {
  $json = $obj | ConvertTo-Json -Depth 100
  [System.IO.File]::WriteAllText($p, $json, $utf8nb)
}

Write-Host "Step 1 -- read v4.4.1C seed JSON" -ForegroundColor Cyan
$src = Read-Utf8Json $sourcePath
$srcM5 = @($src.scenarios | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' })
if ($srcM5.Count -ne 1) { throw "Migration aborted: expected 1 v4.4.1C seed, got $($srcM5.Count)." }
$badAudit = @($srcM5 | Where-Object { $_.auditStatus -ne 'planning_only' })
if ($badAudit.Count -gt 0) { throw "Migration aborted: source seed not planning_only." }
$badReview = @($srcM5 | Where-Object { $_.reviewStatus -ne 'v4.4.1C_expansion_candidate' })
if ($badReview.Count -gt 0) { throw "Migration aborted: source seed not v4.4.1C_expansion_candidate." }
$expIds = @($srcM5 | ForEach-Object { [string]$_.id })

Write-Host "Step 2 -- read production JSON" -ForegroundColor Cyan
$tgt = Read-Utf8Json $targetPath
$tgtAll = @($tgt.scenarios)
Write-Host "  Production total: $($tgtAll.Count)"
$expSet = @{}; foreach ($id in $expIds) { $expSet[$id] = $true }
$keep = @($tgtAll | Where-Object { -not $expSet.ContainsKey([string]$_.id) })
$present = $tgtAll.Count - $keep.Count
Write-Host "  v4.4.1C ids already in production: $present (0=fresh, 1=re-run)"
if ($present -ne 0 -and $present -ne 1) { throw "Migration aborted: inconsistent state." }
$keepM5 = @($keep | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' })
if ($keep.Count -ne 509) { throw "Migration aborted: base (non-v4.4.1C) count is $($keep.Count), expected 509." }
if ($keepM5.Count -ne 32) { throw "Migration aborted: base M5 is $($keepM5.Count), expected 32." }

Write-Host "Step 3 -- transform" -ForegroundColor Cyan
$targetAuditStatus = if ($FlipApproved) { 'approved' } else { 'review_pending' }
Write-Host "  Target auditStatus: $targetAuditStatus"
$migrated = @()
foreach ($s in $srcM5) {
  $diffHint = if ($null -ne $s.difficultyHint -and $s.difficultyHint -gt 0) { [int]$s.difficultyHint } else { 3 }
  $prod = [ordered]@{
    id                = $s.id
    version           = 'v4.4.1C'
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
    reviewStatus      = 'v4.4.1C_strategic_reviewed'
  }
  $migrated += [PSCustomObject]$prod
}

Write-Host "Step 4 -- reassemble" -ForegroundColor Cyan
$newScenarios = $keep + $migrated
if ($newScenarios.Count -ne 510) { throw "Migration aborted: post-merge $($newScenarios.Count), expected 510." }
$newM5 = @($newScenarios | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' })
if ($newM5.Count -ne 33) { throw "Migration aborted: M5 $($newM5.Count), expected 33." }

$desc = 'v4.4.1C - Module 5 straight-blocker mix (+1). Total 510 scenarios: 251 M1 (board texture) + 49 M2 (flop c-bet IP) + 85 M3 (flop defense OOP) + 92 M4 (turn defense OOP) + 33 M5 (river defense OOP). M5 = BB river defense vs BTN third barrel, schemaVersion 1.3.0 per-scenario (5-card board, river showdown-only). Data-loaded + approved; M5 runtime-wired in v4.4.2. Spot context: BTN open 2.5x vs BB call, 100BB SRP, NLH MTT chipEV.'
$newTarget = [ordered]@{}
foreach ($p in $tgt.PSObject.Properties) {
  if ($p.Name -eq 'scenarios') { $newTarget[$p.Name] = $newScenarios }
  elseif ($p.Name -eq 'description') { $newTarget[$p.Name] = $desc }
  else { $newTarget[$p.Name] = $p.Value }
}

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
Write-Host ("SUMMARY v4.4.1C: before {0} (M5 {1}) -> after {2} (M5 {3}); auditStatus={4}; DryRun={5}" -f `
  $tgtAll.Count, (@($tgtAll | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' }).Count), `
  $newScenarios.Count, $newM5.Count, $targetAuditStatus, $DryRun) -ForegroundColor Cyan
