# tools/migrate-expansion-v4.2.3A.ps1
# v4.2.3A - Module 3 Expansion Migration to Production
#
# Reads docs/specs/postflop-v4.2.3A-module3-expansion-seeds.json,
# normalizes each expansion scenario to production schema, and APPENDS
# them to postflop/postflop_scenarios.json.
#
# Behavior mirrors v4.2.3 migration: enrich board with connectedness/
# pairedStatus/dynamicLevel/rangeAdvantage/nutAdvantage, add production
# fields (version, game, street top-level, actionHistory, scoring,
# difficulty), strip planning-only fields (reviewStatus, uniquenessNote,
# difficultyHint).
#
# Initial auditStatus: review_pending. Flip to approved happens in a
# separate step after production audit confirms 0 errors.
#
# UTF-8 NO-BOM via [System.IO.File]::WriteAllText.

$ErrorActionPreference = 'Stop'

$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$expPath  = Join-Path $repoRoot 'docs\specs\postflop-v4.2.3A-module3-expansion-seeds.json'
$prodPath = Join-Path $repoRoot 'postflop\postflop_scenarios.json'

Write-Output "Loading expansion seeds: $expPath"
$expRaw = [System.IO.File]::ReadAllText($expPath, [System.Text.UTF8Encoding]::new($false))
$exp    = $expRaw | ConvertFrom-Json

Write-Output "Loading production: $prodPath"
$prodRaw = [System.IO.File]::ReadAllText($prodPath, [System.Text.UTF8Encoding]::new($false))
$prod    = $prodRaw | ConvertFrom-Json

$preCount   = $prod.scenarios.Count
$preM3Count = @($prod.scenarios | Where-Object { $_.module -eq 'pf_flop_cbet_oop_def' }).Count
Write-Output "Pre-migration scenarios: $preCount (M3 = $preM3Count)"
Write-Output "Expansion to add: $($exp.scenarios.Count)"

# Per-board enrichment (8 NEW boards in v4.2.3A on top of v4.2.3's 6)
$boardMeta = @{
  # v4.2.3A new boards
  'As,9s,4d' = @{ connectedness='disconnected';   pairedStatus='unpaired'; dynamicLevel=2; rangeAdvantage='preflop_raiser'; nutAdvantage='preflop_raiser' }
  'Ks,8s,3d' = @{ connectedness='disconnected';   pairedStatus='unpaired'; dynamicLevel=2; rangeAdvantage='preflop_raiser'; nutAdvantage='preflop_raiser' }
  'Qs,Ts,6d' = @{ connectedness='semi_connected'; pairedStatus='unpaired'; dynamicLevel=3; rangeAdvantage='split';          nutAdvantage='split' }
  '7s,5s,3s' = @{ connectedness='connected';      pairedStatus='unpaired'; dynamicLevel=3; rangeAdvantage='caller';         nutAdvantage='split' }
  '8c,8d,3s' = @{ connectedness='disconnected';   pairedStatus='paired';   dynamicLevel=1; rangeAdvantage='caller';         nutAdvantage='caller' }
  '9d,8c,6h' = @{ connectedness='semi_connected'; pairedStatus='unpaired'; dynamicLevel=3; rangeAdvantage='caller';         nutAdvantage='caller' }
  'Tc,Th,6s' = @{ connectedness='disconnected';   pairedStatus='paired';   dynamicLevel=1; rangeAdvantage='split';          nutAdvantage='split' }
  '6c,3d,2h' = @{ connectedness='disconnected';   pairedStatus='unpaired'; dynamicLevel=1; rangeAdvantage='preflop_raiser'; nutAdvantage='caller' }
}

# Build production scenarios list
$newProductionList = New-Object System.Collections.ArrayList
foreach ($scen in $prod.scenarios) { [void]$newProductionList.Add($scen) }

$idsSeen = @{}
foreach ($scen in $prod.scenarios) {
  if ($scen.id) { $idsSeen[$scen.id] = $true }
}

$migrated = 0
foreach ($s in $exp.scenarios) {
  # ID collision check
  if ($idsSeen.ContainsKey($s.id)) {
    Write-Output "ERROR: expansion id '$($s.id)' collides with existing production id"
    exit 1
  }
  $idsSeen[$s.id] = $true

  # Enrich board
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

  # Pull difficulty from difficultyHint if present, default 3
  $diff = 3
  if ($s.PSObject.Properties.Name -contains 'difficultyHint' -and $s.difficultyHint) {
    $diff = [int]$s.difficultyHint
  }

  $prodScen = [ordered]@{
    id                = $s.id
    version           = '1.0.0'
    schemaVersion     = '1.0.0'
    game              = 'NLH_MTT'
    module            = $s.module
    moduleName        = $s.moduleName
    street            = if ($s.spot -and $s.spot.street) { $s.spot.street } else { 'flop' }
    spot              = $s.spot
    board             = [PSCustomObject]$enrichedBoard
    heroHand          = $s.heroHand
    handClass         = $s.handClass
    heroHandRole      = $s.heroHandRole
    drawCategory      = $s.drawCategory
    showdownValue     = $s.showdownValue
    blockerNote       = $s.blockerNote
    recommendedAction = $s.recommendedAction
    actionReason      = $s.actionReason
    actionHistory     = @()
    question          = $s.question
    answer            = $s.answer
    scoring           = [ordered]@{ best = 1.0; acceptable = 0.5; bad = 0; critical = 0 }
    explanation       = $s.explanation
    conceptTags       = $s.conceptTags
    difficulty        = $diff
    sourceConfidence  = $s.sourceConfidence
    auditStatus       = 'review_pending'
  }

  [void]$newProductionList.Add([PSCustomObject]$prodScen)
  $migrated++
}

Write-Output "Migrated $migrated expansion scenarios"

# Update top-level metadata
$prod.scenarios   = $newProductionList.ToArray()
$prod.description = "v4.2.3A - Module 3 expansion (Facing C-bet OOP). Total $($prod.scenarios.Count) scenarios: 251 M1 + 49 M2 + $($preM3Count + $migrated) M3. M3 expansion adds $migrated new scenarios across 8 new board families targeting coverage gaps (pot_odds_defense, blocker_raise, slowplay_call, protection_raise, domination_fold, bluff_catch, nut_flush_draw). All M3 scenarios start at auditStatus=review_pending and flip to approved once production audit passes. Module 3 remains data-loaded but NOT runtime-wired in v4.2.3A. Spot context: BTN open 2.5x vs BB call, 100BB SRP, flop only, NLH MTT chipEV. Audited per audit-postflop-ps.ps1 (R01-R28 base + R29 card-notation guard + R30-R41 Module 3 schema)."
$prod.generatedAt = '2026-05-06'

$postCount = $prod.scenarios.Count
Write-Output "Post-migration: $postCount scenarios"

if ($postCount -ne ($preCount + $migrated)) {
  Write-Output "ERROR: count mismatch ($preCount + $migrated != $postCount)"
  exit 1
}

# Serialize and write
Write-Output 'Serializing JSON (Depth 100)...'
$json = $prod | ConvertTo-Json -Depth 100

Write-Output 'Writing UTF-8 NO-BOM...'
[System.IO.File]::WriteAllText($prodPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Output ''
Write-Output '=== Migration complete ==='
Write-Output "Pre:  $preCount scenarios (M3 = $preM3Count)"
Write-Output "Add:  $migrated M3 expansion scenarios (auditStatus=review_pending)"
Write-Output "Post: $postCount scenarios (M3 = $($preM3Count + $migrated))"
