# tools/migrate-polish-v4.2.3B.ps1
# v4.2.3B - Module 3 Polish Migration to Production
#
# Reads docs/specs/postflop-v4.2.3B-module3-polish-seeds.json,
# normalizes each polish scenario to production schema, and APPENDS
# them to postflop/postflop_scenarios.json.
#
# Behavior mirrors v4.2.3A migration: enrich board with connectedness/
# pairedStatus/dynamicLevel/rangeAdvantage/nutAdvantage, add production
# fields (version, game, street top-level, actionHistory, scoring,
# difficulty), strip planning-only fields (reviewStatus, uniquenessNote,
# difficultyHint).
#
# Initial auditStatus: review_pending. Flip to approved happens after
# production audit passes.

$ErrorActionPreference = 'Stop'
$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$polishPath = Join-Path $repoRoot 'docs\specs\postflop-v4.2.3B-module3-polish-seeds.json'
$prodPath   = Join-Path $repoRoot 'postflop\postflop_scenarios.json'

Write-Output "Loading polish seeds: $polishPath"
$polishRaw = [System.IO.File]::ReadAllText($polishPath, [System.Text.UTF8Encoding]::new($false))
$polish    = $polishRaw | ConvertFrom-Json

Write-Output "Loading production: $prodPath"
$prodRaw = [System.IO.File]::ReadAllText($prodPath, [System.Text.UTF8Encoding]::new($false))
$prod    = $prodRaw | ConvertFrom-Json

$preCount   = $prod.scenarios.Count
$preM3Count = @($prod.scenarios | Where-Object { $_.module -eq 'pf_flop_cbet_oop_def' }).Count
Write-Output "Pre-migration: $preCount scenarios (M3 = $preM3Count)"
Write-Output "Polish to add: $($polish.scenarios.Count)"

# Per-board enrichment for v4.2.3B's 5 new boards + 1 extension
# Existing v4.2.3A boards already enriched in production; only NEW boards need entries.
$boardMeta = @{
  'Kh,Qh,4s' = @{ connectedness='semi_connected'; pairedStatus='unpaired'; dynamicLevel=3; rangeAdvantage='preflop_raiser'; nutAdvantage='preflop_raiser' }
  'Kh,Jh,4h' = @{ connectedness='semi_connected'; pairedStatus='unpaired'; dynamicLevel=3; rangeAdvantage='split';          nutAdvantage='split' }
  'Qd,7d,2c' = @{ connectedness='disconnected';   pairedStatus='unpaired'; dynamicLevel=2; rangeAdvantage='preflop_raiser'; nutAdvantage='preflop_raiser' }
  'Ac,Ad,7s' = @{ connectedness='disconnected';   pairedStatus='paired';   dynamicLevel=1; rangeAdvantage='preflop_raiser'; nutAdvantage='preflop_raiser' }
  'Ts,9s,5d' = @{ connectedness='semi_connected'; pairedStatus='unpaired'; dynamicLevel=3; rangeAdvantage='caller';         nutAdvantage='split' }
  '8c,8d,3s' = @{ connectedness='disconnected';   pairedStatus='paired';   dynamicLevel=1; rangeAdvantage='caller';         nutAdvantage='caller' }
}

$newProductionList = New-Object System.Collections.ArrayList
foreach ($scen in $prod.scenarios) { [void]$newProductionList.Add($scen) }

$idsSeen = @{}
foreach ($scen in $prod.scenarios) { if ($scen.id) { $idsSeen[$scen.id] = $true } }

$migrated = 0
foreach ($s in $polish.scenarios) {
  if ($idsSeen.ContainsKey($s.id)) {
    Write-Output "ERROR: polish id '$($s.id)' collides with existing production id"
    exit 1
  }
  $idsSeen[$s.id] = $true

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

Write-Output "Migrated $migrated polish scenarios"

$prod.scenarios   = $newProductionList.ToArray()
$prod.description = "v4.2.3B - Module 3 polish (Facing C-bet OOP). Total $($prod.scenarios.Count) scenarios: 251 M1 + 49 M2 + $($preM3Count + $migrated) M3. v4.2.3B polish adds $migrated scenarios across 5 new board families + 1 extended board, targeting thin coverage buckets (blocker_raise, domination_fold, nut_flush_draw, slowplay_call, protection_raise). All M3 scenarios start at auditStatus=review_pending and flip to approved once production audit passes. Module 3 remains data-loaded but NOT runtime-wired in v4.2.3B. Spot context: BTN open 2.5x vs BB call, 100BB SRP, flop only, NLH MTT chipEV."
$prod.generatedAt = '2026-05-06'

$postCount = $prod.scenarios.Count
Write-Output "Post-migration: $postCount scenarios"

if ($postCount -ne ($preCount + $migrated)) {
  Write-Output "ERROR: count mismatch ($preCount + $migrated != $postCount)"
  exit 1
}

Write-Output 'Serializing JSON (Depth 100)...'
$json = $prod | ConvertTo-Json -Depth 100
Write-Output 'Writing UTF-8 NO-BOM...'
[System.IO.File]::WriteAllText($prodPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Output ''
Write-Output '=== Migration complete ==='
Write-Output "Pre:  $preCount scenarios (M3 = $preM3Count)"
Write-Output "Add:  $migrated polish scenarios (auditStatus=review_pending)"
Write-Output "Post: $postCount scenarios (M3 = $($preM3Count + $migrated))"
