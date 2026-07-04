# ============================================================
# audit-postflop-module5-expansion-v4.4.1C.ps1
# v4.4.1C -- Module 5 EXPANSION seed auditor.
# Validates docs/specs/postflop-v4.4.1C-module5-expansion-seeds.json
# against the SAME rule set the production auditor applies to M5
# (audit-postflop-ps.ps1 R76-R93), minus the migration-added fields
# (street/game/version/scoring), PLUS a cross-corpus duplicate-ID check
# vs production and vs the v4.4.0 seeds.
# Planning-only auditor; does NOT touch production data.
# ASCII-only. UTF-8 NO-BOM read. PowerShell 5.1 compatible.
# ============================================================

[CmdletBinding()]
param([string]$SeedPath)

$ErrorActionPreference = 'Stop'
$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
if (-not $SeedPath) { $SeedPath = Join-Path $repoRoot 'docs\specs\postflop-v4.4.1C-module5-expansion-seeds.json' }
$prodPath = Join-Path $repoRoot 'postflop\postflop_scenarios.json'
$v440Path = Join-Path $repoRoot 'docs\specs\postflop-v4.4.0-module5-seed-scenarios.json'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$hard = New-Object System.Collections.Generic.List[string]
$warn = New-Object System.Collections.Generic.List[string]
function Add-Hard($r,$w,$m){ $hard.Add("[$r] HARD -- $w -- $m") | Out-Null }
function Add-Warn($r,$w,$m){ $warn.Add("[$r] WARN -- $w -- $m") | Out-Null }

function Read-Json($p){ if(-not(Test-Path $p)){ throw "not found: $p" }; return ([System.IO.File]::ReadAllText($p,$utf8nb) | ConvertFrom-Json) }

$j = Read-Json $SeedPath

# Vocab (mirrors audit-postflop-ps.ps1 R76-R93)
$validRanks = @('A','K','Q','J','T','9','8','7','6','5','4','3','2')
$validSuits = @('s','h','d','c')
$vActions  = @('fold','call','check_raise_small','check_raise_big','mixed')
$vReasons  = @('pot_odds_river_call','bluff_catch_river','blocker_bluff_catch_river','mdf_defense_river','thin_value_call_river','value_raise_river','bluff_raise_river','range_disadvantage_river_fold','domination_river_fold','board_change_river_fold','missed_draw_give_up','mixed_indifference_river')
$vQTypes   = @('action_choice','reason_choice')
$vRoles    = @('nutted_value','strong_value','thin_value','bluff_catcher','dominated_bluff_catcher','marginal_made_hand','blocker_bluff','missed_draw','give_up')
$vHandClass= @('set','top_two_pair','two_pair','overpair','underpair','top_pair_top_kicker','top_pair_good_kicker','top_pair_weak_kicker','second_pair','third_pair_or_lower','mid_pair','bottom_pair','no_pair_no_draw','straight','flush','nut_flush','trips','full_house','quads')
$vDrawCats = @('none','busted_flush_draw','busted_straight_draw','busted_combo_draw')
$vShowdown = @('none','low','decent','high','nutted')
$vConcepts = @('river_bluff_catcher','river_polarization','river_mdf','river_blocker_defense','river_value_raise','river_bluff_raise','river_thin_value','river_missed_draw','river_range_disadvantage','river_board_change','river_overfold_trap','third_barrel_defense')
$vRiverCats= @('brick','overcard','flush_complete','straight_complete','board_pair','scare_card','blank_runout','double_pair','range_shift_card')
$vBoardChg = @('brick','range_shift_btn','range_shift_bb','polarizing','draw_resolved','counterfeit','boat_possible')
$vRunout   = @('dry_unpaired','flush_possible','straight_possible','double_draw_possible','paired_board','paired_flush_possible','double_paired','monotone_board')
$vDrawComp = @('none','flush_completed','straight_completed','board_paired','flush_and_straight','overcard_blank')
$vSizing   = @('small','medium','large','overbet')
$vSuitRiver= @('rainbow','two_tone','monotone','four_flush')

# Batch-level
if (-not ([string]$j.version).StartsWith('v4.4.1C')) { Add-Hard 'X01' 'TOP' "version should start v4.4.1C, got '$($j.version)'" }
$scn = @($j.scenarios)
if ($scn.Count -lt 1) { Add-Hard 'X01' 'TOP' "no scenarios" }

$rankOrder = @('2','3','4','5','6','7','8','9','T','J','Q','K','A')
function Test-Flush($cards){ foreach($s in 'cdhs'.ToCharArray()){ $sc=[string]$s; $c=(@($cards)|Where-Object{$_.Length -eq 2 -and $_.Substring(1,1) -eq $sc}).Count; if($c -ge 5){return $true} }; return $false }
function Test-Straight($cards){ $set=New-Object System.Collections.Generic.HashSet[int]; foreach($c in $cards){ if($c.Length -ge 2){ $i=$rankOrder.IndexOf($c.Substring(0,1)); if($i -ge 0){[void]$set.Add($i)} } }; foreach($st in 0..8){ $all=$true; foreach($k in 0..4){ if(-not $set.Contains($st+$k)){$all=$false;break} }; if($all){return $true} }; if($set.Contains(12)-and $set.Contains(0)-and $set.Contains(1)-and $set.Contains(2)-and $set.Contains(3)){return $true}; return $false }

foreach ($s in $scn) {
  $sid = if($s.id){$s.id}else{'<no-id>'}
  if ($s.reviewStatus -ne 'v4.4.1C_expansion_candidate') { Add-Hard 'X02' $sid "reviewStatus expected v4.4.1C_expansion_candidate, got '$($s.reviewStatus)'" }
  if ($s.auditStatus -ne 'planning_only') { Add-Hard 'X02' $sid "auditStatus expected planning_only, got '$($s.auditStatus)'" }
  if ($s.module -ne 'pf_river_barrel_oop_def') { Add-Hard 'R76' $sid "module expected pf_river_barrel_oop_def" }
  if ($s.schemaVersion -ne '1.3.0') { Add-Hard 'R76' $sid "schemaVersion expected 1.3.0, got '$($s.schemaVersion)'" }

  # R77 spot
  if ($s.spot) {
    if ($s.spot.heroPosition -ne 'BB') { Add-Hard 'R77' $sid 'spot.heroPosition!=BB' }
    if ($s.spot.villainPosition -ne 'BTN') { Add-Hard 'R77' $sid 'spot.villainPosition!=BTN' }
    if ($s.spot.heroRole -ne 'turn_check_caller_oop') { Add-Hard 'R77' $sid 'spot.heroRole!=turn_check_caller_oop' }
    if ($s.spot.villainRole -ne 'river_barreler_ip') { Add-Hard 'R77' $sid 'spot.villainRole!=river_barreler_ip' }
    if ($s.spot.street -ne 'river') { Add-Hard 'R77' $sid 'spot.street!=river' }
  } else { Add-Hard 'R77' $sid 'spot missing' }

  # R78 5-card board
  $cards = @()
  if (-not $s.board) { Add-Hard 'R78' $sid 'board missing' }
  else {
    $fc = @($s.board.flopCards); if ($fc.Count -ne 3) { Add-Hard 'R78' $sid "flopCards count $($fc.Count)!=3" }
    if (-not $s.board.turnCard -or $s.board.turnCard.Length -ne 2) { Add-Hard 'R78' $sid 'turnCard invalid' }
    if (-not $s.board.riverCard -or $s.board.riverCard.Length -ne 2) { Add-Hard 'R78' $sid 'riverCard invalid' }
    $cards = @($s.board.cards)
    if ($cards.Count -ne 5) { Add-Hard 'R78' $sid "cards count $($cards.Count)!=5" }
    else {
      $exp = @($fc) + @($s.board.turnCard) + @($s.board.riverCard)
      if (($exp -join ',') -ne ($cards -join ',')) { Add-Hard 'R78' $sid 'cards != flop+turn+river' }
      if ((@($cards | Sort-Object -Unique)).Count -ne $cards.Count) { Add-Hard 'R78' $sid 'duplicate board cards' }
    }
  }

  # R79 board enums
  if ($s.board) {
    if ($s.board.riverCategory -and ($vRiverCats -notcontains $s.board.riverCategory)) { Add-Hard 'R79' $sid "riverCategory '$($s.board.riverCategory)'" }
    if ($s.board.boardChange -and ($vBoardChg -notcontains $s.board.boardChange)) { Add-Hard 'R79' $sid "boardChange '$($s.board.boardChange)'" }
    if ($s.board.runoutTexture -and ($vRunout -notcontains $s.board.runoutTexture)) { Add-Hard 'R79' $sid "runoutTexture '$($s.board.runoutTexture)'" }
    if ($s.board.riverDrawCompletion -and ($vDrawComp -notcontains $s.board.riverDrawCompletion)) { Add-Hard 'R79' $sid "riverDrawCompletion '$($s.board.riverDrawCompletion)'" }
    if ($s.board.suitTextureRiver -and ($vSuitRiver -notcontains $s.board.suitTextureRiver)) { Add-Hard 'R79' $sid "suitTextureRiver '$($s.board.suitTextureRiver)'" }
    if (-not $s.board.villainRiverSizing) { Add-Hard 'R79' $sid 'villainRiverSizing missing' }
    elseif ($vSizing -notcontains $s.board.villainRiverSizing) { Add-Hard 'R79' $sid "villainRiverSizing '$($s.board.villainRiverSizing)'" }
  }

  # R80 heroHand
  $hh = @($s.heroHand)
  if ($hh.Count -ne 2) { Add-Hard 'R80' $sid "heroHand count $($hh.Count)!=2" }
  else {
    foreach ($c in $hh) {
      if ($c.Length -ne 2 -or ($validRanks -notcontains $c.Substring(0,1)) -or ($validSuits -notcontains $c.Substring(1,1))) { Add-Hard 'R80' $sid "invalid hero card '$c'" }
    }
    foreach ($c in $hh) { if ($cards -contains $c) { Add-Hard 'R80' $sid "hero card '$c' also on board" } }
  }

  # R81 vocab
  if ($s.handClass -and ($vHandClass -notcontains $s.handClass)) { Add-Hard 'R81' $sid "handClass '$($s.handClass)'" }
  if ($s.heroHandRole -and ($vRoles -notcontains $s.heroHandRole)) { Add-Hard 'R81' $sid "heroHandRole '$($s.heroHandRole)'" }
  if ($s.drawCategory -and ($vDrawCats -notcontains $s.drawCategory)) { Add-Hard 'R81' $sid "drawCategory '$($s.drawCategory)'" }
  if ($s.showdownValue -and ($vShowdown -notcontains $s.showdownValue)) { Add-Hard 'R81' $sid "showdownValue '$($s.showdownValue)'" }

  # R82/R83 question + match
  $qt = if ($s.question){$s.question.qtype}else{$null}
  if ($qt -and ($vQTypes -notcontains $qt)) { Add-Hard 'R82' $sid "qtype '$qt'" }
  if ($qt -eq 'action_choice') {
    $ch = @($s.question.choices)
    foreach ($a in $vActions) { if ($ch -notcontains $a) { Add-Hard 'R82' $sid "action_choice missing '$a'" } }
    foreach ($a in $ch) { if ($vActions -notcontains $a) { Add-Hard 'R82' $sid "action_choice extra '$a'" } }
    if ($s.recommendedAction -and ($vActions -notcontains $s.recommendedAction)) { Add-Hard 'R82' $sid "recommendedAction '$($s.recommendedAction)'" }
    if ($s.answer.best -and $s.recommendedAction -and ($s.answer.best -ne $s.recommendedAction)) { Add-Hard 'R82' $sid "answer.best!=recommendedAction" }
    if ($s.question.prompt -match 'with\s*$') { Add-Hard 'R82' $sid "prompt ends with 'with '" }
    foreach ($c in $hh) { if ($s.question.prompt -notmatch [regex]::Escape($c)) { Add-Hard 'R82' $sid "prompt missing hero card '$c'" } }
  } elseif ($qt -eq 'reason_choice') {
    $ch = @($s.question.choices)
    foreach ($a in $ch) { if ($vReasons -notcontains $a) { Add-Hard 'R83' $sid "reason_choice invalid '$a'" } }
    if ($s.actionReason -and ($vReasons -notcontains $s.actionReason)) { Add-Hard 'R83' $sid "actionReason '$($s.actionReason)'" }
    if ($s.answer.best -and $s.actionReason -and ($s.answer.best -ne $s.actionReason)) { Add-Hard 'R83' $sid "answer.best!=actionReason" }
  }
  if ($s.actionReason -and ($vReasons -notcontains $s.actionReason)) { Add-Hard 'R83' $sid "actionReason vocab '$($s.actionReason)'" }

  # R84 answer partition
  if ($s.answer) {
    $best = $s.answer.best
    $acc = @(); if ($s.answer.acceptable) { $acc = @($s.answer.acceptable) }
    $bad = @(); if ($s.answer.bad) { $bad = @($s.answer.bad) }
    $crit = @(); if ($s.answer.critical) { $crit = @($s.answer.critical) }
    if (-not $best) { Add-Hard 'R84' $sid 'answer.best missing' }
    if ($best -and ($acc -contains $best)) { Add-Hard 'R84' $sid 'best in acceptable' }
    if ($best -and ($bad -contains $best)) { Add-Hard 'R84' $sid 'best in bad' }
    foreach ($a in $acc) { if ($bad -contains $a) { Add-Hard 'R84' $sid "acceptable '$a' in bad" } }
    foreach ($c in $crit) { if (-not ($bad -contains $c)) { Add-Hard 'R84' $sid "critical '$c' not in bad" } }
    $univ = if ($qt -eq 'action_choice'){$vActions}elseif($qt -eq 'reason_choice'){$vReasons}else{@()}
    if ($univ.Count -gt 0) { foreach ($id in (@($best)+$acc+$bad+$crit | Where-Object {$_})) { if ($univ -notcontains $id) { Add-Hard 'R84' $sid "answer id '$id' not in $qt universe" } } }
  } else { Add-Hard 'R84' $sid 'answer missing' }

  # R85 explanation (conditional sizingLogic)
  if ($s.explanation) {
    foreach ($f in @('short','riverLogic','rangeContext','handLogic','commonMistake','takeaway')) {
      $v = $s.explanation.$f
      if (-not $v -or ($v -is [string] -and $v.Trim().Length -eq 0)) { Add-Hard 'R85' $sid "explanation.$f required" }
    }
    if ($s.recommendedAction -eq 'check_raise_small' -or $s.recommendedAction -eq 'check_raise_big') {
      if (-not $s.explanation.sizingLogic -or ($s.explanation.sizingLogic -is [string] -and $s.explanation.sizingLogic.Trim().Length -eq 0)) { Add-Hard 'R85' $sid 'sizingLogic required for check-raise' }
    }
  } else { Add-Hard 'R85' $sid 'explanation missing' }

  # R86 conceptTags
  $ct = @($s.conceptTags)
  if ($ct.Count -lt 1) { Add-Hard 'R86' $sid 'conceptTags empty' }
  elseif ($ct.Count -gt 4) { Add-Hard 'R86' $sid "conceptTags >4 ($($ct.Count))" }
  $seen=@{}; foreach ($t in $ct) { if ($vConcepts -notcontains $t) { Add-Hard 'R86' $sid "conceptTag '$t' not in M5 vocab" }; if ($seen.ContainsKey("$t")) { Add-Hard 'R86' $sid "duplicate conceptTag '$t'" }; $seen["$t"]=$true }

  # R88 flush invariant
  if (($s.handClass -eq 'flush' -or $s.handClass -eq 'nut_flush') -and $cards.Count -eq 5) {
    if (-not (Test-Flush (@($hh)+@($cards)))) { Add-Hard 'R88' $sid 'handClass=flush but <5 of a suit hero+board' }
  }
  # R89 straight invariant
  if ($s.handClass -eq 'straight' -and $cards.Count -eq 5) {
    if (-not (Test-Straight (@($hh)+@($cards)))) { Add-Hard 'R89' $sid 'handClass=straight but no 5 consecutive hero+board' }
  }

  # R90 busted-draws-never-call
  $busted = ($s.heroHandRole -eq 'missed_draw') -or ($s.drawCategory -eq 'busted_flush_draw') -or ($s.drawCategory -eq 'busted_straight_draw') -or ($s.drawCategory -eq 'busted_combo_draw')
  if ($busted) {
    if ($s.recommendedAction -eq 'call') { Add-Hard 'R90' $sid 'busted draw recommendedAction=call' }
    if ($s.answer.best -eq 'call') { Add-Hard 'R90' $sid 'busted draw answer.best=call' }
    if (@($s.answer.acceptable) -contains 'call') { Add-Hard 'R90' $sid 'busted draw acceptable contains call' }
    $callR = @('pot_odds_river_call','bluff_catch_river','blocker_bluff_catch_river','mdf_defense_river','thin_value_call_river')
    if ($callR -contains $s.actionReason) { Add-Hard 'R90' $sid "busted draw call-flavored actionReason '$($s.actionReason)'" }
  }

  # R92 no draw-equity-realization (WARN)
  if ($s.explanation) {
    $ban = @('equity realization','realize equity','equity_realization','realize the equity','realise equity')
    foreach ($f in @('short','riverLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')) {
      $v = $s.explanation.$f
      if ($v -is [string]) { $vl=$v.ToLowerInvariant(); foreach ($p in $ban) { if ($vl.Contains($p)) { Add-Warn 'R92' $sid "draw-equity phrasing '$p' in $f"; break } } }
    }
  }
  # R93 text-integrity
  $arts = @(' wait ',' wait,',' wait.','wait needs','wait need ','actually impossible','... wait','...wait')
  if ($s.explanation) {
    foreach ($f in @('short','riverLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')) {
      $v = $s.explanation.$f
      if ($v -is [string] -and $v.Length -gt 0) { $vl=$v.ToLowerInvariant(); foreach ($p in $arts) { if ($vl.Contains($p.ToLowerInvariant())) { Add-Hard 'R93' $sid "self-correction artifact '$($p.Trim())' in $f"; break } } }
    }
  }
}

# Cross-corpus duplicate-ID check (vs production + vs v4.4.0 seeds)
$myIds = @($scn | ForEach-Object { $_.id })
$dups = $myIds | Group-Object | Where-Object { $_.Count -gt 1 }
foreach ($d in $dups) { Add-Hard 'XDUP' $d.Name "duplicate id within v4.4.1C batch (x$($d.Count))" }
try {
  $prod = Read-Json $prodPath
  $prodIds = New-Object System.Collections.Generic.HashSet[string]
  foreach ($p in $prod.scenarios) { [void]$prodIds.Add([string]$p.id) }
  foreach ($id in $myIds) { if ($prodIds.Contains([string]$id)) { Add-Hard 'XDUP' $id 'id already exists in production' } }
} catch { Add-Warn 'XDUP' 'TOP' "could not read production: $_" }
try {
  $v440 = Read-Json $v440Path
  $v440Ids = New-Object System.Collections.Generic.HashSet[string]
  foreach ($p in $v440.scenarios) { [void]$v440Ids.Add([string]$p.id) }
  foreach ($id in $myIds) { if ($v440Ids.Contains([string]$id)) { Add-Hard 'XDUP' $id 'id collides with v4.4.0 seeds' } }
} catch { Add-Warn 'XDUP' 'TOP' "could not read v4.4.0 seeds: $_" }

Write-Host ''
Write-Host '================================================================'
Write-Host ' M5 EXPANSION SEED AUDIT -- v4.4.1C (planning_only)'
Write-Host '================================================================'
Write-Host ("  scenarios   = " + $scn.Count)
Write-Host ("  hard errors = " + $hard.Count)
Write-Host ("  warnings    = " + $warn.Count)
if ($hard.Count -gt 0) { Write-Host ''; Write-Host '--- HARD ---'; $hard | ForEach-Object { Write-Host "  $_" } }
if ($warn.Count -gt 0) { Write-Host ''; Write-Host '--- WARN ---'; $warn | ForEach-Object { Write-Host "  $_" } }
Write-Host ''
if ($hard.Count -gt 0) { Write-Host '  result      = FAIL'; exit 1 } else { Write-Host '  result      = PASS'; exit 0 }
