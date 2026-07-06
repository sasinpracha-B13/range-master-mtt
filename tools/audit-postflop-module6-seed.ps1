# audit-postflop-module6-seed.ps1 -- v4.5.1 M6 seed auditor (24 rows expected).
# Validates docs/specs/postflop-v4.5.1-module6-seeds.json ONLY (planning file).
# Production postflop_scenarios.json is never read or written.
# Rule blocks M6.R01-M6.R30. HARD = error, WARN = warning. ASCII-only, PS 5.1.
#
# Key G4 ruling enforcement:
#   R10 verdictBasis mandatory enum; solver_required = HARD FAIL (blocked).
#   R11 stakeBasis mandatory enum small|medium|large|overbet (never none).
#   R12 bet-best rows: stakeBasis == heroRiverSizing == best line's size.
#   R13 check_back-best rows: heroRiverSizing == none; stakeBasis = declared
#       temptation size and that size MUST appear in bad[] or critical[].
#   R14 mixed rows: verdictBasis == mixed_nudge; acceptable exactly 2 entries;
#       stakeBasis == size of FIRST acceptable entry (primary member);
#       mixedWhitelistChoices present and equal to acceptable set.
#   R15 non-mixed rows must NOT carry mixedWhitelistChoices.
#   R20-R22 Range Reveal prose lints (WARN): negator within 40 chars before a
#       band phrase; the word flush-dense anywhere; band phrase inventory log.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$path = Join-Path $root 'docs\specs\postflop-v4.5.1-module6-seeds.json'
$doc = [System.IO.File]::ReadAllText($path, [System.Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
$ALLROWS = @($doc.scenarios)
$errors = @(); $warns = @()
function Err($id,$rule,$msg){ $script:errors += ($rule + ' [' + $id + '] ' + $msg) }
function Warn($id,$rule,$msg){ $script:warns += ($rule + ' [' + $id + '] ' + $msg) }

$szMap = @{ small='bet_small'; medium='bet_medium'; large='bet_big'; overbet='overbet' }
$actEnum = @('check_back','bet_small','bet_big','overbet','mixed')
$reasonEnum = @('value_bet_thick_river','value_bet_thin_river','polar_overbet_nut_river','blocker_bluff_river','give_up_no_equity_river','check_back_showdown_river','check_back_trap_risk_river','sizing_merge_small_river','sizing_polar_big_river','blocker_sidedness_mix_river','unblock_fold_region_river','story_consistency_bluff_river')
$vbEnum = @('clear_direction','mixed_nudge')   # solver_required intentionally absent => HARD fail
$stakeEnum = @('small','medium','large','overbet')
$hrsEnum = @('small','medium','large','overbet','none')
$purposeEnum = @('thick_value','thin_value','bluff','give_up','showdown_check','mixed_line')
$negRx = "(?:\bnot\b|n't\b|\bnever\b|\brarely\b|\bno longer\b)"
$bandRx = '(bluff-heavy|over-?bluff\w*|toward bluffs|too few value|value-heavy|value-rich|value-weighted|toward (?:his )?value|bluff-light|too few bluffs|flush-dense|polar(?:ized|izing)?\b|value-or-bluff|nuts?-or-air|maximally polar|merged|thin value|bets? thin)'

# R01 count / R02 unique ids / module constants
if ($ALLROWS.Count -ne 24) { Err '-' 'M6.R01' ('expected 24 scenarios, got ' + $ALLROWS.Count) }
$ids = @{}
$rankMap = @{ '2'=2;'3'=3;'4'=4;'5'=5;'6'=6;'7'=7;'8'=8;'9'=9;'T'=10;'J'=11;'Q'=12;'K'=13;'A'=14 }

foreach ($row in $ALLROWS) {
  $id = $row.id
  if ($ids.ContainsKey($id)) { Err $id 'M6.R02' 'duplicate id' } else { $ids[$id] = $true }
  if ($row.module -ne 'pf_river_value_ip') { Err $id 'M6.R03' 'module must be pf_river_value_ip' }
  if ($row.street -ne 'river') { Err $id 'M6.R03' 'street must be river' }
  if ($row.schemaVersion -ne '1.4.0') { Err $id 'M6.R03' 'schemaVersion must be 1.4.0' }
  if ($row.spot.heroPosition -ne 'BTN' -or $row.spot.villainPosition -ne 'BB') { Err $id 'M6.R04' 'hero must be BTN (bettor side), villain BB' }
  if ($row.spot.riverAction -ne 'BB checks river') { Err $id 'M6.R04' 'riverAction must be "BB checks river"' }
  if ($row.auditStatus -ne 'review_pending') { Err $id 'M6.R05' 'seed auditStatus must be review_pending' }
  if ($row.sourceConfidence -ne 'expert_judgment' -and $row.sourceConfidence -ne 'consensus_gto') { Err $id 'M6.R05' 'bad sourceConfidence' }
  if ($row.difficulty -lt 1 -or $row.difficulty -gt 5) { Err $id 'M6.R05' 'difficulty out of range' }

  # R06 board integrity: 5 distinct cards, cards[] == flop+turn+river, no hero collision
  $cards = @($row.board.cards)
  if ($cards.Count -ne 5) { Err $id 'M6.R06' 'board must have 5 cards' }
  $all = $cards + @($row.heroHand)
  if (($all | Select-Object -Unique).Count -ne 7) { Err $id 'M6.R06' 'card collision among board+hero' }
  $expected = @($row.board.flopCards) + @($row.board.turnCard, $row.board.riverCard)
  if (($expected -join ',') -ne ($cards -join ',')) { Err $id 'M6.R06' 'cards[] != flop+turn+river' }

  # R07 question/choices
  $ch = @($row.question.choices)
  if ($row.question.qtype -eq 'action_choice') {
    foreach ($c in $ch) { if ($actEnum -notcontains $c) { Err $id 'M6.R07' ('unknown action choice ' + $c) } }
    if ($ch -notcontains 'check_back') { Err $id 'M6.R07' 'action rows must offer check_back' }
    if ($ch.Count -lt 4) { Err $id 'M6.R07' 'need >= 4 choices' }
  } elseif ($row.question.qtype -eq 'reason_choice') {
    foreach ($c in $ch) { if ($reasonEnum -notcontains $c) { Err $id 'M6.R07' ('unknown reason choice ' + $c) } }
    if ($ch.Count -ne 4) { Err $id 'M6.R07' 'reason rows need exactly 4 choices' }
  } else { Err $id 'M6.R07' 'qtype must be action_choice|reason_choice' }

  # R08 answer partition: exact cover of choices, no overlap
  $ans = @($row.answer.best) + @($row.answer.acceptable) + @($row.answer.bad) + @($row.answer.critical)
  $ansSorted = ($ans | Sort-Object) -join ','
  $chSorted = ($ch | Sort-Object) -join ','
  if ($ansSorted -ne $chSorted) { Err $id 'M6.R08' ('answer arrays must exactly partition choices: [' + $ansSorted + '] vs [' + $chSorted + ']') }
  if (($ans | Select-Object -Unique).Count -ne $ans.Count) { Err $id 'M6.R08' 'tier overlap' }

  # R09 recommendedAction/actionReason coherence
  if ($row.question.qtype -eq 'action_choice') {
    if ($row.answer.best -ne $row.recommendedAction) { Err $id 'M6.R09' 'answer.best != recommendedAction' }
  } else {
    if ($row.answer.best -ne $row.actionReason) { Err $id 'M6.R09' 'reason rows: answer.best must equal actionReason' }
  }
  if ($reasonEnum -notcontains $row.actionReason) { Err $id 'M6.R09' 'actionReason not in M6 vocab' }

  # R10 verdictBasis
  if (-not $row.verdictBasis) { Err $id 'M6.R10' 'verdictBasis missing' }
  elseif ($vbEnum -notcontains $row.verdictBasis) { Err $id 'M6.R10' ('verdictBasis "' + $row.verdictBasis + '" not approvable (solver_required is hard-blocked from production)') }

  # R11 stakeBasis
  if (-not $row.stakeBasis) { Err $id 'M6.R11' 'stakeBasis missing' }
  elseif ($stakeEnum -notcontains $row.stakeBasis) { Err $id 'M6.R11' 'stakeBasis must be small|medium|large|overbet (never none)' }
  if ($hrsEnum -notcontains $row.heroRiverSizing) { Err $id 'M6.R11' 'heroRiverSizing invalid' }
  if ($purposeEnum -notcontains $row.betPurpose) { Err $id 'M6.R11' 'betPurpose invalid' }

  # R12-R14 stake-basis PIN coherence (action rows; reason rows keyed on underlying best line)
  $rec = $row.recommendedAction
  if ($row.question.qtype -eq 'reason_choice') {
    # reason rows: recommendedAction stores the underlying best ACTION
    if ($actEnum -notcontains $rec) { Err $id 'M6.R12' 'reason rows must still declare underlying recommendedAction' }
  }
  if ($rec -in @('bet_small','bet_big','overbet')) {
    if ($szMap[$row.stakeBasis] -ne $rec) { Err $id 'M6.R12' ('bet-best rows: stakeBasis (' + $row.stakeBasis + ') must match best line ' + $rec) }
    if ($szMap[$row.heroRiverSizing] -ne $rec) { Err $id 'M6.R12' 'heroRiverSizing must equal best bet size' }
  } elseif ($rec -eq 'check_back') {
    if ($row.heroRiverSizing -ne 'none') { Err $id 'M6.R13' 'check-best rows: heroRiverSizing must be none' }
    if ($row.question.qtype -eq 'action_choice') {
      $tempAct = $szMap[$row.stakeBasis]
      $punished = @($row.answer.bad) + @($row.answer.critical)
      if ($punished -notcontains $tempAct) { Err $id 'M6.R13' ('temptation bet ' + $tempAct + ' (stakeBasis ' + $row.stakeBasis + ') must be graded bad or critical') }
    }
  } elseif ($rec -eq 'mixed') {
    if ($row.verdictBasis -ne 'mixed_nudge') { Err $id 'M6.R14' 'mixed rows must be verdictBasis=mixed_nudge' }
    $acc = @($row.answer.acceptable)
    if ($acc.Count -ne 2) { Err $id 'M6.R14' 'mixed rows: exactly 2 acceptable members' }
    $primary = $acc[0]
    if ($primary -eq 'check_back') { Err $id 'M6.R14' 'primary (first) member must be the bet member/nudged side' }
    if ($szMap[$row.stakeBasis] -ne $primary) { Err $id 'M6.R14' ('stakeBasis must match primary member ' + $primary) }
    if ($szMap[$row.heroRiverSizing] -ne $primary) { Err $id 'M6.R14' 'heroRiverSizing must match primary member' }
    $wl = @($row.mixedWhitelistChoices)
    if ($wl.Count -eq 0) { Err $id 'M6.R14' 'mixed rows must carry mixedWhitelistChoices' }
    elseif ((($wl | Sort-Object) -join ',') -ne (($acc | Sort-Object) -join ',')) { Err $id 'M6.R14' 'mixedWhitelistChoices must equal acceptable set' }
  } else {
    Err $id 'M6.R12' ('unexpected recommendedAction ' + $rec)
  }
  if ($rec -ne 'mixed' -and $null -ne $row.mixedWhitelistChoices) { Err $id 'M6.R15' 'non-mixed rows must not carry mixedWhitelistChoices' }
  if ($row.verdictBasis -eq 'mixed_nudge' -and $rec -ne 'mixed') { Err $id 'M6.R15' 'mixed_nudge requires recommendedAction=mixed' }

  # R16 mixed offered => graded: if choices contain mixed and best!=mixed, mixed must be in bad
  if ($row.question.qtype -eq 'action_choice' -and $ch -contains 'mixed' -and $rec -ne 'mixed') {
    if (@($row.answer.bad) -notcontains 'mixed') { Err $id 'M6.R16' 'offered mixed distractor must be graded bad on clear rows' }
  }

  # R24 CHECK-BACK-NUTS scope bound (owner flag-ruling 1, v4.5.1 review):
  # critical may contain check_back ONLY for nuts/effective-nuts heroes;
  # thin-value check-backs grade bad, never critical.
  if (@($row.answer.critical) -contains 'check_back') {
    if ($row.heroHandRole -ne 'nutted_value' -or $row.showdownValue -ne 'nutted') {
      Err $id 'M6.R24' 'critical check_back allowed only when heroHandRole=nutted_value AND showdownValue=nutted'
    }
  }

  # R25 CHECK-BACK-NUTS reverse-lint (owner v4.5.1 line-review ruling 1):
  # schema semantics: showdownValue 'nutted' + heroHandRole 'nutted_value'
  # formally mean ZERO combos in villain's range beat hero. Such rows that
  # best a bet while offering check_back MUST grade check_back critical
  # (forfeit full value at zero risk; IP check closes the action).
  # Rows beaten by >=1 combo (e.g. F4 quads-2) must NOT carry nutted_value
  # and their check_back caps at bad.
  if ($row.heroHandRole -eq 'nutted_value' -and $row.question.qtype -eq 'action_choice' -and
      $row.recommendedAction -in @('bet_small','bet_big','overbet') -and
      @($row.question.choices) -contains 'check_back') {
    if (@($row.answer.critical) -notcontains 'check_back') {
      Err $id 'M6.R25' 'nutted_value row with non-critical check_back -- zero-combos-beaten rows must grade the check-back as a full punt (or the row is not nutted_value)'
    }
  }

  # R26-R28 production-convention guards (added after v4.5.2 first-merge lint):
  # R26 highCardClass/boardKind = top rank of the FULL 5-card runout (R02 mirror)
  $ranks26 = @()
  foreach ($c26 in @($row.board.cards)) { $ranks26 += $rankMap[$c26.Substring(0, $c26.Length - 1)] }
  $topRank = ($ranks26 | Measure-Object -Maximum).Maximum
  $topName = @{2='low';3='low';4='low';5='low';6='low';7='low';8='low';9='low';10='T_high';11='J_high';12='Q_high';13='K_high';14='A_high'}[[int]$topRank]
  if ($row.board.highCardClass -ne $topName) { Err $id 'M6.R26' ('highCardClass "' + $row.board.highCardClass + '" but full-runout top rank derives "' + $topName + '"') }
  # R27 textureTags restricted to the production-taxonomy set (R09 mirror)
  foreach ($t in @($row.board.textureTags)) {
    if (@('dry','wet','paired','disconnected','connected') -notcontains $t) { Err $id 'M6.R27' ('textureTag "' + $t + '" not in production taxonomy') }
  }
  # R28 self-correction artifacts (R105 mirror)
  $prose28 = (@($row.explanation.short,$row.explanation.riverLogic,$row.explanation.rangeContext,$row.explanation.handLogic,$row.explanation.sizingLogic,$row.explanation.commonMistake,$row.explanation.takeaway,$row.blockerNote) -join ' ').ToLowerInvariant()
  foreach ($p28 in @(' wait ', ' wait,', ' wait.', '... wait', '...wait', 'actually impossible')) {
    if ($prose28.Contains($p28)) { Err $id 'M6.R28' ('prose contains self-correction artifact "' + $p28.Trim() + '"') ; break }
  }

  # R17 bluff rows need a real blockerNote
  if ($row.betPurpose -eq 'bluff' -and ($row.blockerNote -eq $null -or $row.blockerNote.Length -lt 40)) { Err $id 'M6.R17' 'bluff rows require a substantive blockerNote' }

  # R18 explanation completeness (sizingLogic mandatory for M6)
  foreach ($f in @('short','riverLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')) {
    if (-not $row.explanation.$f -or $row.explanation.$f.Length -lt 20) { Err $id 'M6.R18' ('explanation.' + $f + ' missing/too short') }
  }

  # R19 text integrity: no mojibake / doubled apostrophes / non-ASCII
  $prose = @($row.explanation.short,$row.explanation.riverLogic,$row.explanation.rangeContext,$row.explanation.handLogic,$row.explanation.sizingLogic,$row.explanation.commonMistake,$row.explanation.takeaway,$row.blockerNote,$row.question.prompt) -join ' '
  if ($prose -match "''") { Err $id 'M6.R19' 'doubled apostrophe artifact' }
  if ($prose -match '[^\x20-\x7E]') { Err $id 'M6.R19' 'non-ASCII character in prose' }

  # R20 Range Reveal negation lint (WARN): negator within 40 chars before band phrase in same sentence
  foreach ($p in @($row.explanation.riverLogic,$row.explanation.rangeContext,$row.explanation.handLogic,$row.blockerNote)) {
    if (-not $p) { continue }
    foreach ($sent in [regex]::Split($p, '(?<=[.!?])\s+|\s--\s')) {
      $m = [regex]::Match($sent, $bandRx, 'IgnoreCase')
      if ($m.Success) {
        $win = $sent.Substring([Math]::Max(0, $m.Index - 40), [Math]::Min(40, $m.Index))
        if ($win -match $negRx) { Warn $id 'M6.R20' ('negator before band phrase "' + $m.Value + '" -- verify suppression is INTENDED: ...' + $sent.Trim().Substring(0, [Math]::Min(90, $sent.Trim().Length))) }
      }
    }
  }
  # R21 flush-dense ban (HARD in M6 authoring)
  if ($prose -match 'flush-dense') { Err $id 'M6.R21' 'flush-dense is banned in M6 prose (texture-leak risk)' }

  # R22 straight/flush board claims: recompute straight possibility and flush possibility
  $ranks = @(); $suits = @{}
  foreach ($c in $cards) {
    $r = $c.Substring(0, $c.Length - 1); $su = $c.Substring($c.Length - 1)
    $ranks += $rankMap[$r]
    if (-not $suits.ContainsKey($su)) { $suits[$su] = 0 }
    $suits[$su]++
  }
  $flushPossible = ($suits.Values | Measure-Object -Maximum).Maximum -ge 3
  # straight possible: any 5-window with >=3 board ranks (2-card completion), ace low counted
  $rset = $ranks | Select-Object -Unique
  $rAug = @($rset); if ($rset -contains 14) { $rAug += 1 }
  $straightPossible = $false
  for ($lo = 1; $lo -le 10; $lo++) {
    $inWin = @($rAug | Where-Object { $_ -ge $lo -and $_ -le ($lo + 4) } | Select-Object -Unique)
    if ($inWin.Count -ge 3) { $straightPossible = $true; break }
  }
  # informational only unless prose contradicts:
  if (-not $flushPossible -and $prose -match '(makes|completes|holds) (the |a )?flush' ) { Warn $id 'M6.R22' 'flush language on a no-flush board -- verify' }
  if (-not $straightPossible -and $prose -match 'straight' -and $prose -notmatch '(no straight|never (arrives|comes|completes)|stayed incomplete|missed)') { Warn $id 'M6.R22' 'straight language on a no-straight board -- verify' }
}

# R23 batch-level distribution checks
$mixedRows = @($ALLROWS | Where-Object { $_.recommendedAction -eq 'mixed' })
if ($mixedRows.Count -ne 4) { Err '-' 'M6.R23' ('mixed_nudge rows must be exactly 4, got ' + $mixedRows.Count) }
$reasonRows = @($ALLROWS | Where-Object { $_.question.qtype -eq 'reason_choice' })
if ($reasonRows.Count -ne 6) { Err '-' 'M6.R23' ('reason rows must be 6, got ' + $reasonRows.Count) }
$obStake = @($ALLROWS | Where-Object { $_.stakeBasis -eq 'overbet' })
if ($obStake.Count -lt 2) { Err '-' 'M6.R23' 'need >= 2 overbet-stake rows (owner ruling)' }
$d45 = @($ALLROWS | Where-Object { $_.difficulty -ge 4 })
if ($d45.Count -lt 8) { Err '-' 'M6.R23' ('need >= 8 rows at difficulty 4-5 for FT, got ' + $d45.Count) }
$reasonsUsed = @($ALLROWS | ForEach-Object { $_.actionReason } | Select-Object -Unique)
$unused = @($reasonEnum | Where-Object { $reasonsUsed -notcontains $_ })
if ($unused.Count -gt 0) { Warn '-' 'M6.R23' ('unused actionReason vocab: ' + ($unused -join ', ')) }

# ---- report ----
Write-Output '=== M6 v4.5.1 Seed Audit ==='
Write-Output ('Scenarios: ' + $ALLROWS.Count)
Write-Output ('Errors: ' + $errors.Count)
Write-Output ('Warnings: ' + $warns.Count)
foreach ($e in $errors) { Write-Output ('ERROR ' + $e) }
foreach ($w in $warns) { Write-Output ('WARN  ' + $w) }
Write-Output '--- Stats ---'
Write-Output ('  qtype action_choice: ' + @($ALLROWS | Where-Object { $_.question.qtype -eq 'action_choice' }).Count)
Write-Output ('  qtype reason_choice: ' + $reasonRows.Count)
foreach ($vb in @('clear_direction','mixed_nudge')) { Write-Output ('  verdictBasis ' + $vb + ': ' + @($ALLROWS | Where-Object { $_.verdictBasis -eq $vb }).Count) }
foreach ($st in $stakeEnum) { Write-Output ('  stakeBasis ' + $st + ': ' + @($ALLROWS | Where-Object { $_.stakeBasis -eq $st }).Count) }
foreach ($bp in $purposeEnum) { Write-Output ('  betPurpose ' + $bp + ': ' + @($ALLROWS | Where-Object { $_.betPurpose -eq $bp }).Count) }
foreach ($d in 1..5) { Write-Output ('  diff ' + $d + ': ' + @($ALLROWS | Where-Object { $_.difficulty -eq $d }).Count) }
foreach ($r in $reasonEnum) { Write-Output ('  reason ' + $r + ': ' + @($ALLROWS | Where-Object { $_.actionReason -eq $r }).Count) }
if ($errors.Count -eq 0) { Write-Output 'RESULT: PASS' } else { Write-Output 'RESULT: FAIL' }
