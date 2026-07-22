# audit-migA-rework-v4.6.2.ps1 -- validates the Migration A rework seeds.
# Reads docs/specs/postflop-v4.6.2-migA-rework-seeds.json ONLY.
# Rule set = the v4.6.1 RW.R01-R12 discipline (v2 branches included) PLUS:
#   - baseline non-member set now INCLUDES AQo (solver closure, owner-ruled)
#   - reworkClass EV-REDERIVE: board+hero PRESERVED, actionReason MUST change,
#     answer.best MUST change, difficulty preserved, solverRunRef + solverNote
#     REQUIRED, and the prose must carry the EV story (owner condition: teach
#     why call wins outright, not merely assert the verdict).
# ASCII-only, PS 5.1 safe ($row/$ALLROWS naming -- the $s/$S lesson).

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = [System.Text.UTF8Encoding]::new($false)
$doc = [System.IO.File]::ReadAllText((Join-Path $root 'docs\specs\postflop-v4.6.2-migA-rework-seeds.json'), $utf8) | ConvertFrom-Json
$prod = ([System.IO.File]::ReadAllText((Join-Path $root 'postflop\postflop_scenarios.json'), $utf8) | ConvertFrom-Json).scenarios
$errors = @(); $warns = @()
function Err($id,$rule,$msg){ $script:errors += ($rule + ' [' + $id + '] ' + $msg) }
function Warn($id,$rule,$msg){ $script:warns += ($rule + ' [' + $id + '] ' + $msg) }

$order = '23456789TJQKA'
function Canon($hand) {
  $a=$hand[0]; $b=$hand[1]
  $r1=$a.Substring(0,1); $r2=$b.Substring(0,1); $s1=$a.Substring(1,1); $s2=$b.Substring(1,1)
  if ($order.IndexOf($r1) -lt $order.IndexOf($r2)) { $t=$r1; $r1=$r2; $r2=$t }
  if ($r1 -eq $r2) { return $r1+$r2 }
  return $r1+$r2+$(if($s1 -eq $s2){'s'}else{'o'})
}
# v4.6.2 baseline: AQo joins the non-member set (solver: 3bet 100%)
$NONMEMBER = @('AA','KK','QQ','AKs','AKo','AQs','AQo')
$m4Actions = @('fold','call','check_raise_small','check_raise_big','mixed')
$m4Reasons = @('pot_odds_turn_call','equity_realization_turn_call','bluff_catch_turn','board_change_fold',
               'domination_turn_fold','range_disadvantage_turn_fold','value_check_raise_turn',
               'protection_check_raise_turn','semi_bluff_check_raise_turn','blocker_check_raise_turn',
               'slowplay_turn_call','mixed_indifference_turn')

foreach ($row in @($doc.reworks)) {
  $id = $row.id
  if ($row.module -ne 'pf_turn_barrel_oop_def' -or $row.street -ne 'turn' -or $row.schemaVersion -ne '1.2.0') { Err $id 'RW.R01' 'module/street/schemaVersion must match the M4 corpus' }
  if ($row.auditStatus -ne 'review_pending') { Err $id 'RW.R01' 'seed auditStatus must be review_pending' }
  $old = $prod | Where-Object { $_.id -eq $row.replaces } | Select-Object -First 1
  if (-not $old) { Err $id 'RW.R02' ('replaced row not found: ' + $row.replaces) }
  else {
    $isEvRederive = ($row.reworkClass -eq 'EV-REDERIVE')
    if ($isEvRederive) {
      # RW.R03-EV: board+hero preserved; reason and best MUST change; D preserved
      if ((@($old.board.cards) -join ',') -ne (@($row.board.cards) -join ',')) { Err $id 'RW.R03' 'EV-REDERIVE must preserve the board' }
      if ((@($old.heroHand) -join '') -ne (@($row.heroHand) -join '')) { Err $id 'RW.R03' 'EV-REDERIVE must preserve the hero (answer-layer rework only)' }
      if ($old.actionReason -eq $row.actionReason) { Err $id 'RW.R03' 'EV-REDERIVE must CHANGE actionReason (the falsified label may not survive)' }
      if ((@($old.answer.best) -join ',') -eq (@($row.answer.best) -join ',')) { Err $id 'RW.R03' 'EV-REDERIVE must change answer.best' }
      if ($old.difficulty -ne $row.difficulty) { Err $id 'RW.R03' 'difficulty must be preserved' }
      if (-not $row.solverRunRef -or -not $row.solverNote) { Err $id 'RW.R03' 'EV-REDERIVE requires solverRunRef AND solverNote' }
      if ($row.solverNote -notmatch 'EV-lens') { Err $id 'RW.R03' 'solverNote must carry the EV-lens citation' }
      $evProse = (@($row.explanation.rangeContext,$row.explanation.sizingLogic,$row.explanation.short) | Where-Object { $_ }) -join ' '
      if ($evProse -notmatch 'bb') { Err $id 'RW.R03' 'prose must teach the EV story (cite the bb numbers -- owner condition)' }
    } else {
      if ((@($old.board.cards) -join ',') -ne (@($row.board.cards) -join ',')) { Err $id 'RW.R03' 'board must be preserved (hero-swap only)' }
      if ($old.board.turnCategory -ne $row.board.turnCategory) { Err $id 'RW.R03' 'turnCategory must be preserved' }
      if ($old.actionReason -ne $row.actionReason) { Err $id 'RW.R03' 'actionReason must be preserved' }
      if ($old.difficulty -ne $row.difficulty) { Err $id 'RW.R03' 'difficulty must be preserved' }
      if ((@($old.heroHand) -join '') -eq (@($row.heroHand) -join '')) { Err $id 'RW.R03' 'hero must actually change' }
    }
  }
  $cls = Canon $row.heroHand
  if ($NONMEMBER -contains $cls) { Err $id 'RW.R04' ('new hero ' + $cls + ' is a non-member (baseline incl. AQo)') }
  $all = @($row.board.cards) + @($row.heroHand)
  if (($all | Select-Object -Unique).Count -ne $all.Count) { Err $id 'RW.R04' 'card collision board+hero' }
  $hk = (@($row.heroHand) | Sort-Object) -join ''
  $fk = (@($row.board.flopCards) -join '')
  $twin = $prod | Where-Object { $_.module -eq 'pf_flop_cbet_oop_def' -and ((@($_.heroHand) | Sort-Object) -join '') -eq $hk -and ((@($_.board.cards) -join '')) -eq $fk } | Select-Object -First 1
  if ($twin -and $twin.recommendedAction -ne 'call') { Err $id 'RW.R05' ('M3 twin best is ' + $twin.recommendedAction + ' -- self-inconsistency') }
  $ans = @($row.answer.best) + @($row.answer.acceptable) + @($row.answer.bad) + @($row.answer.critical)
  if (($ans | Select-Object -Unique).Count -ne $ans.Count) { Err $id 'RW.R06' 'tier overlap' }
  if ((($ans | Sort-Object) -join ',') -ne ((@($row.question.choices) | Sort-Object) -join ',')) { Err $id 'RW.R06' 'answer arrays must exactly partition choices' }
  $isReasonRow = (@($row.question.choices) -contains 'bluff_catch_turn')
  if ($isReasonRow) {
    $lblMap = @{ 'value_check_raise_turn'='check_raise_small'; 'protection_check_raise_turn'='check_raise_small';
                 'semi_bluff_check_raise_turn'='check_raise_small'; 'blocker_check_raise_turn'='check_raise_small';
                 'slowplay_turn_call'='call'; 'pot_odds_turn_call'='call'; 'equity_realization_turn_call'='call';
                 'bluff_catch_turn'='call'; 'board_change_fold'='fold'; 'domination_turn_fold'='fold';
                 'range_disadvantage_turn_fold'='fold'; 'mixed_indifference_turn'='mixed' }
    if ($lblMap[[string]$row.answer.best] -ne $row.recommendedAction) { Err $id 'RW.R06' 'reason-row recommendedAction must map from best label' }
  } else {
    if ($row.answer.best -ne $row.recommendedAction) { Err $id 'RW.R06' 'best != recommendedAction' }
  }
  $vocab = $m4Actions; if ($isReasonRow) { $vocab = $m4Reasons }
  foreach ($c in @($row.question.choices)) { if ($vocab -notcontains $c) { Err $id 'RW.R07' ('bad choice ' + $c) } }
  if ($m4Reasons -notcontains $row.actionReason) { Err $id 'RW.R07' 'actionReason not in M4 vocab' }
  foreach ($c in @($row.answer.critical)) { Warn $id 'RW.R08' ('critical entry ' + $c + ' -- verify against the enumerated punt classes') }
  $prose = (@($row.explanation.short,$row.explanation.turnLogic,$row.explanation.rangeContext,$row.explanation.handLogic,$row.explanation.sizingLogic,$row.explanation.commonMistake,$row.explanation.takeaway,$row.blockerNote,$row.arrivalDerivation) | Where-Object { $_ }) -join ' '
  $suitCnt = @{}
  foreach ($bc in @($row.board.cards)) { $su = $bc.Substring($bc.Length-1); if ($suitCnt[$su]) { $suitCnt[$su] = $suitCnt[$su] + 1 } else { $suitCnt[$su] = 1 } }
  $maxSuit = 0; foreach ($v in $suitCnt.Values) { if ($v -gt $maxSuit) { $maxSuit = $v } }
  $flushReachable = ($maxSuit -ge 2)
  if ($prose -match '(?i)no flush is possible' -and $flushReachable) { Err $id 'RW.R09' 'claims no-flush but a flush IS reachable' }
  if (-not $flushReachable) {
    if ($prose -match '(?i)flush draw|backdoor') { Err $id 'RW.R09' 'flush-dead board: no draw claims allowed' }
    foreach ($sw in @('heart','spade','diamond','club')) {
      if ($prose -match ('(?i)' + $sw) -and $prose -notmatch '(?i)no flush is possible|no suit story|no suit equity') { Err $id 'RW.R09' ($sw + 's mentioned without a no-flush disclosure'); break }
    }
  } else {
    $heroSuits = @($row.heroHand | ForEach-Object { $_.Substring($_.Length-1) })
    if ($heroSuits[0] -eq $heroSuits[1] -and $suitCnt[$heroSuits[0]] -ge 2) {
      $suitWord = @{ 's'='spade'; 'h'='heart'; 'd'='diamond'; 'c'='club' }[$heroSuits[0]]
      if ($prose -notmatch ('(?i)' + $suitWord + '|flush')) { Err $id 'RW.R09' 'real flush draw unmentioned (silent-suit)' }
    }
  }
  if (-not $row.arrivalDerivation -or $row.arrivalDerivation.Length -lt 120) { Err $id 'RW.R10' 'arrivalDerivation missing/too short' }
  if ($row.arrivalDerivation -notmatch 'Preflop' -or $row.arrivalDerivation -notmatch 'Flop') { Err $id 'RW.R10' 'arrivalDerivation must cover preflop AND flop' }
  if ($prose -match "''") { Err $id 'RW.R11' 'doubled-apostrophe artifact' }
  if ($prose -match '[^\x20-\x7E]') { Err $id 'RW.R11' 'non-ASCII in prose' }
  foreach ($p in @(' wait ', '... no --', 'wait,', ' actually,', 'actually impossible')) {
    if ($prose.ToLowerInvariant().Contains($p)) { Err $id 'RW.R11' ('artifact "' + $p.Trim() + '"'); break }
  }
  foreach ($f in @('short','turnLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')) {
    if (-not $row.explanation.$f -or $row.explanation.$f.Length -lt 20) { Err $id 'RW.R12' ('explanation.' + $f + ' missing/too short') }
  }
}

Write-Output '=== MIGRATION A REWORK SEED AUDIT (v4.6.2) ==='
Write-Output ('Reworks: ' + @($doc.reworks).Count)
Write-Output ('Errors: ' + $errors.Count)
Write-Output ('Warnings: ' + $warns.Count)
foreach ($e in $errors) { Write-Output ('ERROR ' + $e) }
foreach ($w in $warns) { Write-Output ('WARN  ' + $w) }
if ($errors.Count -eq 0) { Write-Output 'RESULT: PASS' } else { Write-Output 'RESULT: FAIL' }
