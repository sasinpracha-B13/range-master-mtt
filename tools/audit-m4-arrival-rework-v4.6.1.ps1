# audit-m4-arrival-rework-v4.6.1.ps1 -- validates the v4.6.1 rework seeds.
# Reads docs/specs/postflop-v4.6.1-m4-rework-seeds.json ONLY. Rules RW.R01-R12:
# M4 shape/enums, CLEAN partition (no ARR.P overlap), rework-policy checks
# (board/turnCategory/actionReason/difficulty preserved vs the replaced row in
# PRODUCTION), arrival legs for the NEW hero (ARR.A member + ARR.C1 no twin),
# hearts-honesty lint, prose lints (ASCII/artifacts), enumerated-critical
# taxonomy check. ASCII-only, PS 5.1 safe.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = [System.Text.UTF8Encoding]::new($false)
$doc = [System.IO.File]::ReadAllText((Join-Path $root 'docs\specs\postflop-v4.6.1-m4-rework-seeds.json'), $utf8) | ConvertFrom-Json
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
$NONMEMBER = @('AA','KK','QQ','AKs','AKo','AQs')
$m4Actions = @('fold','call','check_raise_small','check_raise_big','mixed')
$m4Reasons = @('pot_odds_turn_call','equity_realization_turn_call','bluff_catch_turn','board_change_fold',
               'domination_turn_fold','range_disadvantage_turn_fold','value_check_raise_turn',
               'protection_check_raise_turn','semi_bluff_check_raise_turn','blocker_check_raise_turn',
               'slowplay_turn_call','mixed_indifference_turn')

foreach ($r in @($doc.reworks)) {
  $id = $r.id
  # RW.R01 shape/module/street
  if ($r.module -ne 'pf_turn_barrel_oop_def' -or $r.street -ne 'turn' -or $r.schemaVersion -ne '1.2.0') { Err $id 'RW.R01' 'module/street/schemaVersion must match the M4 corpus' }
  if ($r.auditStatus -ne 'review_pending') { Err $id 'RW.R01' 'seed auditStatus must be review_pending' }
  # RW.R02 replaced row must exist in production and be a REWORK-class row
  $old = $prod | Where-Object { $_.id -eq $r.replaces } | Select-Object -First 1
  if (-not $old) { Err $id 'RW.R02' ('replaced row not found: ' + $r.replaces) }
  else {
    # RW.R03 policy preservation. BOARD-CHANGED family (owner ruling, batch-3
    # approval #3): board + hero may change; actionReason preserved; difficulty
    # preserved unless reworkClass is BOARD-CHANGED-CONVERTED (owner gate-2
    # path (ii): lesson conversion with difficulty re-derived).
    $isBoardChanged = ([string]$r.reworkClass -like 'BOARD-CHANGED*')
    if (-not $isBoardChanged) {
      if ((@($old.board.cards) -join ',') -ne (@($r.board.cards) -join ',')) { Err $id 'RW.R03' 'board must be preserved (hero-swap only)' }
      if ($old.board.turnCategory -ne $r.board.turnCategory) { Err $id 'RW.R03' 'turnCategory must be preserved' }
      if ($old.difficulty -ne $r.difficulty) { Err $id 'RW.R03' 'difficulty must be preserved' }
    } else {
      if ((@($old.board.cards) -join ',') -eq (@($r.board.cards) -join ',')) { Err $id 'RW.R03' 'BOARD-CHANGED row must actually change the board' }
      if (@($r.board.cards).Count -ne 4 -or ((@($r.board.flopCards) + @($r.board.turnCard)) -join ',') -ne (@($r.board.cards) -join ',')) { Err $id 'RW.R03' 'BOARD-CHANGED board object incoherent (cards != flop+turn)' }
      if ($r.reworkClass -ne 'BOARD-CHANGED-CONVERTED' -and $old.difficulty -ne $r.difficulty) { Err $id 'RW.R03' 'difficulty must be preserved (only -CONVERTED may re-derive)' }
      # v4.6.1 QA-hardening: -CONVERTED means the conversion HAPPENED -- a
      # cloned unchanged difficulty is the defect the in-app gate caught.
      if ($r.reworkClass -eq 'BOARD-CHANGED-CONVERTED' -and $old.difficulty -eq $r.difficulty) { Err $id 'RW.R03' 'CONVERTED row kept the original difficulty -- conversion not applied' }
    }
    if ($old.actionReason -ne $r.actionReason) { Err $id 'RW.R03' 'actionReason must be preserved' }
    if ((@($old.heroHand) -join '') -eq (@($r.heroHand) -join '')) { Err $id 'RW.R03' 'hero must actually change' }
  }
  # RW.R04 new hero: leg-(a) member + card collisions
  $cls = Canon $r.heroHand
  if ($NONMEMBER -contains $cls) { Err $id 'RW.R04' ('new hero ' + $cls + ' is still a non-member') }
  $all = @($r.board.cards) + @($r.heroHand)
  if (($all | Select-Object -Unique).Count -ne $all.Count) { Err $id 'RW.R04' 'card collision board+hero' }
  # RW.R05 ARR.C1: no M3 twin contradiction for the NEW hero
  $hk = (@($r.heroHand) | Sort-Object) -join ''
  $fk = (@($r.board.flopCards) -join '')
  $twin = $prod | Where-Object { $_.module -eq 'pf_flop_cbet_oop_def' -and ((@($_.heroHand) | Sort-Object) -join '') -eq $hk -and ((@($_.board.cards) -join '')) -eq $fk } | Select-Object -First 1
  if ($twin -and $twin.recommendedAction -ne 'call') { Err $id 'RW.R05' ('new hero has an M3 twin whose best is ' + $twin.recommendedAction + ' -- self-inconsistency') }
  # RW.R06 CLEAN partition, no overlap, exact cover
  $ans = @($r.answer.best) + @($r.answer.acceptable) + @($r.answer.bad) + @($r.answer.critical)
  if (($ans | Select-Object -Unique).Count -ne $ans.Count) { Err $id 'RW.R06' 'tier overlap (the ARR.P defect must not ship)' }
  if ((($ans | Sort-Object) -join ',') -ne ((@($r.question.choices) | Sort-Object) -join ',')) { Err $id 'RW.R06' 'answer arrays must exactly partition choices' }
  # RW.R06v2: reason rows keep recommendedAction as the underlying ACTION VERB
  # (corpus convention, e.g. best=bluff_catch_turn / rec=call); map label->verb.
  $isReasonRow = (@($r.question.choices) -contains 'bluff_catch_turn')
  if ($isReasonRow) {
    $lblMap = @{ 'value_check_raise_turn'='check_raise_small'; 'protection_check_raise_turn'='check_raise_small';
                 'semi_bluff_check_raise_turn'='check_raise_small'; 'blocker_check_raise_turn'='check_raise_small';
                 'slowplay_turn_call'='call'; 'pot_odds_turn_call'='call'; 'equity_realization_turn_call'='call';
                 'bluff_catch_turn'='call'; 'board_change_fold'='fold'; 'domination_turn_fold'='fold';
                 'range_disadvantage_turn_fold'='fold'; 'mixed_indifference_turn'='mixed' }
    if ($lblMap[[string]$r.answer.best] -ne $r.recommendedAction) { Err $id 'RW.R06' 'reason-row recommendedAction must be the action verb of the best label' }
  } else {
    if ($r.answer.best -ne $r.recommendedAction) { Err $id 'RW.R06' 'best != recommendedAction' }
  }
  # RW.R07v2 enums: action rows use the 5 action verbs; reason rows use the
  # 12-label vocabulary (corpus convention -- V1 was action-only, rule widened
  # for the gate-1 batch).
  $isReasonChoices = (@($r.question.choices) -contains 'bluff_catch_turn')
  $vocab = $m4Actions; if ($isReasonChoices) { $vocab = $m4Reasons }
  foreach ($c in @($r.question.choices)) { if ($vocab -notcontains $c) { Err $id 'RW.R07' ('bad choice ' + $c) } }
  if ($isReasonChoices -and @($r.question.choices).Count -ne 12) { Err $id 'RW.R07' 'reason row must carry the full 12-label choice set' }
  if ($m4Reasons -notcontains $r.actionReason) { Err $id 'RW.R07' 'actionReason not in M4 vocab' }
  # RW.R08 enumerated-critical taxonomy: critical entries must be punt-class
  foreach ($c in @($r.answer.critical)) {
    Warn $id 'RW.R08' ('critical entry ' + $c + ' -- verify against the enumerated punt classes')
  }
  # RW.R09v2 suit-truth (generalized from the V1 hearts rule for the 26-row
  # batch): claims are checked against the actual board. On flush-dead boards
  # (all four suits singleton) the V1 bans hold; on flush-reachable boards
  # real draw talk is required, not banned. False claims error either way.
  $prose = (@($r.explanation.short,$r.explanation.turnLogic,$r.explanation.rangeContext,$r.explanation.handLogic,$r.explanation.sizingLogic,$r.explanation.commonMistake,$r.explanation.takeaway,$r.blockerNote,$r.arrivalDerivation) | Where-Object { $_ }) -join ' '
  $suitCnt = @{}
  foreach ($bc in @($r.board.cards)) { $su = $bc.Substring($bc.Length-1); if ($suitCnt[$su]) { $suitCnt[$su] = $suitCnt[$su] + 1 } else { $suitCnt[$su] = 1 } }
  $maxSuit = 0; foreach ($v in $suitCnt.Values) { if ($v -gt $maxSuit) { $maxSuit = $v } }
  $flushReachable = ($maxSuit -ge 2)
  if ($prose -match '(?i)no flush is possible' -and $flushReachable) { Err $id 'RW.R09' 'claims no-flush but a flush IS reachable on this board' }
  if (-not $flushReachable) {
    if ($prose -match '(?i)flush draw|backdoor') { Err $id 'RW.R09' 'flush-dead board: no flush-draw/backdoor claims allowed' }
    foreach ($sw in @('heart','spade','diamond','club')) {
      if ($prose -match ('(?i)' + $sw) -and $prose -notmatch '(?i)no flush is possible|no suit story|no suit equity') { Err $id 'RW.R09' ($sw + 's mentioned without a no-flush disclosure on a dead board'); break }
    }
  } else {
    $heroSuits = @($r.heroHand | ForEach-Object { $_.Substring($_.Length-1) })
    if ($heroSuits[0] -eq $heroSuits[1] -and $suitCnt[$heroSuits[0]] -ge 2) {
      $suitWord = @{ 's'='spade'; 'h'='heart'; 'd'='diamond'; 'c'='club' }[$heroSuits[0]]
      if ($prose -notmatch ('(?i)' + $suitWord + '|flush')) { Err $id 'RW.R09' 'hero holds a real flush draw that the prose never mentions (silent-suit)' }
    }
  }
  # RW.R10 arrival derivation present (owner condition ii)
  if (-not $r.arrivalDerivation -or $r.arrivalDerivation.Length -lt 120) { Err $id 'RW.R10' 'arrivalDerivation missing/too short (full per-street re-derive required)' }
  if ($r.arrivalDerivation -notmatch 'Preflop' -or $r.arrivalDerivation -notmatch 'Flop') { Err $id 'RW.R10' 'arrivalDerivation must cover preflop AND flop' }
  # RW.R11 prose lints: ASCII, doubled apostrophes, artifacts
  if ($prose -match "''") { Err $id 'RW.R11' 'doubled-apostrophe artifact' }
  if ($prose -match '[^\x20-\x7E]') { Err $id 'RW.R11' 'non-ASCII in prose' }
  foreach ($p in @(' wait ', '... no --', 'wait,', ' actually,', 'actually impossible')) {
    if ($prose.ToLowerInvariant().Contains($p)) { Err $id 'RW.R11' ('artifact "' + $p.Trim() + '"') ; break }
  }
  # RW.R12 explanation completeness
  foreach ($f in @('short','turnLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')) {
    if (-not $r.explanation.$f -or $r.explanation.$f.Length -lt 20) { Err $id 'RW.R12' ('explanation.' + $f + ' missing/too short') }
  }
}

Write-Output '=== M4 REWORK SEED AUDIT (v4.6.1) ==='
Write-Output ('Reworks: ' + @($doc.reworks).Count)
Write-Output ('Errors: ' + $errors.Count)
Write-Output ('Warnings: ' + $warns.Count)
foreach ($e in $errors) { Write-Output ('ERROR ' + $e) }
foreach ($w in $warns) { Write-Output ('WARN  ' + $w) }
if ($errors.Count -eq 0) { Write-Output 'RESULT: PASS' } else { Write-Output 'RESULT: FAIL' }
