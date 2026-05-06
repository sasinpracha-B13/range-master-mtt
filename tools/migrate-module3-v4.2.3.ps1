# tools/migrate-module3-v4.2.3.ps1
# v4.2.3 - Module 3 Migration to Production Data
#
# Reads docs/specs/postflop-v4.2.0-module3-seed-scenarios.json,
# normalizes each of the 24 M3 seeds to the production scenario schema,
# and appends them to postflop/postflop_scenarios.json.
#
# Production additions per M3 scenario:
#   - version:        "1.0.0"
#   - game:           "NLH_MTT"
#   - street:         "flop"            (top-level, mirrors spot.street)
#   - actionHistory:  []                (matches M2 default)
#   - scoring:        { best: 1.0, acceptable: 0.5, bad: 0, critical: 0 }
#   - difficulty:     3                 (intermediate; reviewer can re-tune)
#
# Stripped on migration:
#   - reviewStatus    (planning-only sentinel)
#
# Status flip:
#   - auditStatus:    "planning_only" -> "review_pending" (this script)
#                     "review_pending" -> "approved"      (subsequent flip)
#
# Encoding: UTF-8 NO-BOM via [System.IO.File]::WriteAllText to avoid CP874
# mojibake on Windows PowerShell 5.1.

$ErrorActionPreference = 'Stop'

$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$seedPath = Join-Path $repoRoot 'docs\specs\postflop-v4.2.0-module3-seed-scenarios.json'
$prodPath = Join-Path $repoRoot 'postflop\postflop_scenarios.json'

Write-Output "Loading seed: $seedPath"
$seedRaw = [System.IO.File]::ReadAllText($seedPath, [System.Text.UTF8Encoding]::new($false))
$seed    = $seedRaw | ConvertFrom-Json

Write-Output "Loading production: $prodPath"
$prodRaw = [System.IO.File]::ReadAllText($prodPath, [System.Text.UTF8Encoding]::new($false))
$prod    = $prodRaw | ConvertFrom-Json

$preCount = $prod.scenarios.Count
Write-Output "Pre-migration scenario count: $preCount"
$m3Existing = @($prod.scenarios | Where-Object { $_.module -eq 'pf_flop_cbet_oop_def' }).Count
Write-Output "Pre-migration M3 count: $m3Existing"
if ($m3Existing -gt 0) {
  Write-Output 'ERROR: M3 already migrated. Aborting to prevent duplicates.'
  exit 1
}

$seedCount = $seed.scenarios.Count
Write-Output "Seed M3 scenario count: $seedCount"

# Build production scenarios list
$newProductionList = New-Object System.Collections.ArrayList
foreach ($scen in $prod.scenarios) { [void]$newProductionList.Add($scen) }

$idsSeen = @{}
foreach ($scen in $prod.scenarios) {
  if ($scen.id) { $idsSeen[$scen.id] = $true }
}

# Per-board enrichment: connectedness, pairedStatus, dynamicLevel,
# rangeAdvantage, nutAdvantage. Required by R09/R10/R13. Static for the
# 6 M3 board families.
$boardMeta = @{
  'As,8d,3h' = @{ connectedness='disconnected';     pairedStatus='unpaired'; dynamicLevel=1; rangeAdvantage='preflop_raiser'; nutAdvantage='preflop_raiser' }
  'Kh,9c,4s' = @{ connectedness='disconnected';     pairedStatus='unpaired'; dynamicLevel=1; rangeAdvantage='preflop_raiser'; nutAdvantage='preflop_raiser' }
  'Kc,Kd,7s' = @{ connectedness='disconnected';     pairedStatus='paired';   dynamicLevel=1; rangeAdvantage='preflop_raiser'; nutAdvantage='preflop_raiser' }
  '8s,7d,5h' = @{ connectedness='highly_connected'; pairedStatus='unpaired'; dynamicLevel=4; rangeAdvantage='caller';         nutAdvantage='caller' }
  'Qh,Jh,6c' = @{ connectedness='semi_connected';   pairedStatus='unpaired'; dynamicLevel=3; rangeAdvantage='split';          nutAdvantage='split' }
  'Jh,8h,4h' = @{ connectedness='semi_connected';   pairedStatus='unpaired'; dynamicLevel=3; rangeAdvantage='split';          nutAdvantage='split' }
}

$migrated = 0
foreach ($s in $seed.scenarios) {
  # ID collision check
  if ($idsSeen.ContainsKey($s.id)) {
    Write-Output "WARNING: M3 seed id '$($s.id)' collides with existing production id"
    continue
  }
  $idsSeen[$s.id] = $true

  # Enrich board with M2-equivalent structural fields
  $boardKey = ($s.board.cards) -join ','
  $meta = $boardMeta[$boardKey]
  if (-not $meta) {
    Write-Output "ERROR: no boardMeta for board '$boardKey' on $($s.id)"
    exit 1
  }
  $enrichedBoard = [ordered]@{
    cards          = $s.board.cards
    boardKind      = $s.board.boardKind
    suitTexture    = $s.board.suitTexture
    textureTags    = $s.board.textureTags
    highCardClass  = $s.board.highCardClass
    connectedness  = $meta.connectedness
    pairedStatus   = $meta.pairedStatus
    dynamicLevel   = $meta.dynamicLevel
    rangeAdvantage = $meta.rangeAdvantage
    nutAdvantage   = $meta.nutAdvantage
  }

  # Build production scenario by augmenting the seed object
  $prodScen = [ordered]@{
    id              = $s.id
    version         = '1.0.0'
    schemaVersion   = '1.0.0'
    game            = 'NLH_MTT'
    module          = $s.module
    moduleName      = $s.moduleName
    street          = if ($s.spot -and $s.spot.street) { $s.spot.street } else { 'flop' }
    spot            = $s.spot
    board           = [PSCustomObject]$enrichedBoard
    heroHand        = $s.heroHand
    handClass       = $s.handClass
    heroHandRole    = $s.heroHandRole
    drawCategory    = $s.drawCategory
    showdownValue   = $s.showdownValue
    blockerNote     = $s.blockerNote
    recommendedAction = $s.recommendedAction
    actionReason    = $s.actionReason
    actionHistory   = @()
    question        = $s.question
    answer          = $s.answer
    scoring         = [ordered]@{ best = 1.0; acceptable = 0.5; bad = 0; critical = 0 }
    explanation     = $s.explanation
    conceptTags     = $s.conceptTags
    difficulty      = 3
    sourceConfidence = $s.sourceConfidence
    auditStatus     = 'review_pending'
  }

  $obj = [PSCustomObject]$prodScen
  [void]$newProductionList.Add($obj)
  $migrated++
}

Write-Output "Migrated $migrated M3 scenarios"

# Update top-level metadata
$prod.scenarios = $newProductionList.ToArray()
$prod.description = "v4.2.3 - Module 3 (Facing C-bet OOP) migrated from v4.2.0 seeds. Total 324 scenarios: 251 M1 (Board Texture Trainer) + 49 M2 (Flop C-bet IP) + 24 M3 (Facing C-bet OOP, BB vs BTN). M3 starts at auditStatus=review_pending and flips to approved once production audit passes 324/0/0. Module 3 is data-loaded but NOT runtime-wired in v4.2.3 - TRAINING_MODES still kind=preview, route=null. Spot context: BTN open 2.5x vs BB call, 100BB SRP, flop only, NLH MTT chipEV. All scenarios audited per audit-postflop-ps.ps1 (R01-R28 base + R29 card-notation guard + R30-R41 Module 3 schema)."
$prod.generatedAt = '2026-05-06'

$postCount = $prod.scenarios.Count
Write-Output "Post-migration scenario count: $postCount"

if ($postCount -ne ($preCount + $migrated)) {
  Write-Output "ERROR: count mismatch ($preCount + $migrated != $postCount)"
  exit 1
}

# Serialize and write back as UTF-8 NO-BOM
Write-Output 'Serializing JSON (Depth 100)...'
$json = $prod | ConvertTo-Json -Depth 100

Write-Output 'Writing UTF-8 NO-BOM...'
[System.IO.File]::WriteAllText($prodPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Output ''
Write-Output '=== Migration complete ==='
Write-Output "Pre:  $preCount scenarios"
Write-Output "Add:  $migrated M3 scenarios (auditStatus=review_pending)"
Write-Output "Post: $postCount scenarios"
