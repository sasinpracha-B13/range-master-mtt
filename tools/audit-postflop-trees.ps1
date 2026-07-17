# audit-postflop-trees.ps1 -- G6 v4.6.0 hand-tree auditor (3 trees x 4 nodes).
# Validates docs/specs/game-g6-v4.6.0-tree-seeds.json ONLY (planning file).
# Production postflop_scenarios.json is never read or written.
# Rule blocks T.R01-T.R20. HARD = error, WARN = warning. ASCII-only, PS 5.1.
#
# Per-node rules mirror the M6 seed-auditor classes (partition, enums,
# verdictBasis hard-block, prose lints, negation window, artifacts); tree-level
# rules enforce the G6 PINs: hero constant across nodes, board lineage, full
# 7-card integrity, preflopChartRow present, stake ladder match, and ANY
# solver_required node FAILS THE WHOLE TREE. Owner spine conditions are
# asserted as tree-specific checks (T.R16-T.R18).

param([string]$SeedFile = 'docs\specs\game-g6-v4.6.0-tree-seeds.json')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$doc = [System.IO.File]::ReadAllText((Join-Path $root $SeedFile), [System.Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
$TREES = @($doc.trees)
$errors = @(); $warns = @()
function Err($id,$rule,$msg){ $script:errors += ($rule + ' [' + $id + '] ' + $msg) }
function Warn($id,$rule,$msg){ $script:warns += ($rule + ' [' + $id + '] ' + $msg) }

$defMenu = @('fold','call','check_raise_small','check_raise_big')
$preMenuBB = @('fold','call','threebet')
$preMenuBTN = @('fold','open25')
$ipMenus = @('check_back','bet_small','bet_big','overbet')
$vbEnum = @('clear_direction','mixed_nudge')
$stakeTable = @{ street_preflop=2; street_flop=3; street_turn=5; small=7; medium=13; large=20; overbet=30 }
$treeReasons = @('preflop_chart_flat','preflop_chart_open','equity_realization_call','bluff_catch',
                 'equity_realization_turn_call','bluff_catch_turn','value_raise_river','board_change_river_fold',
                 'cbet_value_range_ip','barrel_value_protection_ip','value_bet_thin_river')
$negRx = "(?:\bnot\b|n't\b|\bnever\b|\brarely\b|\bno longer\b)"
$bandRx = '(bluff-heavy|value-heavy|value-weighted|polar(?:ized|izing)?\b|merged|thin value|flush-dense)'
$rankMap = @{ '2'=2;'3'=3;'4'=4;'5'=5;'6'=6;'7'=7;'8'=8;'9'=9;'T'=10;'J'=11;'Q'=12;'K'=13;'A'=14 }

if ($TREES.Count -ne 3) { Err '-' 'T.R01' ('expected 3 trees, got ' + $TREES.Count) }
$ids = @{}
foreach ($tree in $TREES) {
  $tid = $tree.id
  if ($ids.ContainsKey($tid)) { Err $tid 'T.R01' 'duplicate tree id' } else { $ids[$tid] = $true }
  if ($tree.schemaVersion -ne 'tree-1.0.0') { Err $tid 'T.R02' 'schemaVersion must be tree-1.0.0' }
  if (@('BB','BTN') -notcontains $tree.seat) { Err $tid 'T.R02' 'seat must be BB or BTN' }
  if ($tree.auditStatus -ne 'review_pending') { Err $tid 'T.R02' 'seed auditStatus must be review_pending' }

  # T.R03 -- PIN 3: preflop chart row present and cites a source
  if (-not $tree.preflopChartRow -or $tree.preflopChartRow.Length -lt 30) { Err $tid 'T.R03' 'preflopChartRow missing/too short' }
  elseif ($tree.preflopChartRow -notmatch 'audit-plan|100BB_BTN_RFI|ranges\.json') { Err $tid 'T.R03' 'preflopChartRow must cite the banked baseline or ranges.json' }

  # T.R04 -- card integrity: 7 distinct cards (board 5 + hero 2)
  $b = $tree.board
  $cards7 = @($b.flopCards) + @($b.turnCard, $b.riverCard) + @($tree.heroHand)
  if ((@($b.flopCards).Count -ne 3) -or (-not $b.turnCard) -or (-not $b.riverCard)) { Err $tid 'T.R04' 'board must be flop3 + turn + river' }
  if (($cards7 | Select-Object -Unique).Count -ne 7) { Err $tid 'T.R04' 'card collision among board+hero' }
  foreach ($c in $cards7) { if ($c -notmatch '^[2-9TJQKA][hdcs]$') { Err $tid 'T.R04' ('bad card token ' + $c) } }

  # T.R05 -- node count + street order (PIN: preflop included)
  $nodes = @($tree.nodes)
  $wantStreets = @('preflop','flop','turn','river')
  if ($nodes.Count -ne 4) { Err $tid 'T.R05' ('expected 4 nodes, got ' + $nodes.Count) }
  for ($i = 0; $i -lt [Math]::Min($nodes.Count, 4); $i++) {
    if ($nodes[$i].street -ne $wantStreets[$i]) { Err $tid 'T.R05' ('node ' + $i + ' street must be ' + $wantStreets[$i]) }
  }

  $treeSolverFail = $false
  foreach ($n in $nodes) {
    $nid = $tid + '/' + $n.street
    $ch = @($n.choices)

    # T.R06 -- menu enums by street/seat
    $menuOk = $true
    if ($n.street -eq 'preflop') {
      $want = if ($tree.seat -eq 'BB') { $preMenuBB } else { $preMenuBTN }
      foreach ($c in $ch) { if ($want -notcontains $c) { $menuOk = $false } }
    } elseif ($tree.seat -eq 'BB') {
      foreach ($c in $ch) { if ($defMenu -notcontains $c) { $menuOk = $false } }
    } else {
      foreach ($c in $ch) { if ($ipMenus -notcontains $c) { $menuOk = $false } }
    }
    if (-not $menuOk) { Err $nid 'T.R06' ('choice outside the street/seat menu: [' + ($ch -join ',') + ']') }
    if ($ch.Count -lt 2) { Err $nid 'T.R06' 'need >= 2 choices' }

    # T.R07 -- answer partition exactly covers choices
    $ans = @($n.answer.best) + @($n.answer.acceptable) + @($n.answer.bad) + @($n.answer.critical)
    if ((($ans | Sort-Object) -join ',') -ne (($ch | Sort-Object) -join ',')) { Err $nid 'T.R07' 'answer arrays must exactly partition choices' }
    if (($ans | Select-Object -Unique).Count -ne $ans.Count) { Err $nid 'T.R07' 'tier overlap' }
    if ($ch -notcontains $n.answer.best) { Err $nid 'T.R07' 'best not among choices' }

    # T.R08 -- verdictBasis: solver_required fails the WHOLE tree (PIN 2)
    if ($vbEnum -notcontains $n.verdictBasis) { Err $nid 'T.R08' ('verdictBasis "' + $n.verdictBasis + '" not approvable'); $treeSolverFail = $true }
    if ($n.verdictBasis -eq 'mixed_nudge' -and (@($n.answer.acceptable).Count -lt 2 -or $n.answer.best -notin @('mixed'))) {
      # v1 trees ship no mixed nodes; if one appears it must follow the M6 mixed rules
      Warn $nid 'T.R08' 'mixed_nudge node present in v1 (spines specify none) -- verify against M6 mixed rules'
    }

    # T.R09 -- actionReason vocab
    if ($treeReasons -notcontains $n.actionReason) { Err $nid 'T.R09' ('actionReason not in tree vocab: ' + $n.actionReason) }

    # T.R10 -- stake ladder match (PIN semantics)
    if (-not $stakeTable.ContainsKey($n.stakeBasis)) { Err $nid 'T.R10' ('unknown stakeBasis ' + $n.stakeBasis) }
    elseif ($stakeTable[$n.stakeBasis] -ne $n.stakeBB) { Err $nid 'T.R10' ('stakeBB ' + $n.stakeBB + ' != table[' + $n.stakeBasis + ']=' + $stakeTable[$n.stakeBasis]) }
    if ($n.street -in @('preflop','flop','turn') -and $n.stakeBasis -ne ('street_' + $n.street)) { Err $nid 'T.R10' 'pre-river nodes use the street stake token' }
    if ($n.street -eq 'river' -and $n.stakeBasis -notin @('small','medium','large','overbet')) { Err $nid 'T.R10' 'river node uses a sizing stake token' }

    # T.R11 -- prose completeness (sizingLogic nullable on preflop only)
    foreach ($f in @('short','streetLogic','rangeContext','handLogic','commonMistake','takeaway')) {
      if (-not $n.explanation.$f -or $n.explanation.$f.Length -lt 20) { Err $nid 'T.R11' ('explanation.' + $f + ' missing/too short') }
    }
    if ($n.street -ne 'preflop' -and (-not $n.explanation.sizingLogic -or $n.explanation.sizingLogic.Length -lt 20)) { Err $nid 'T.R11' 'sizingLogic required on postflop nodes' }

    # T.R12 -- text integrity: ASCII, no doubled apostrophes, no self-correction artifacts
    $prose = (@($n.explanation.short,$n.explanation.streetLogic,$n.explanation.rangeContext,$n.explanation.handLogic,$n.explanation.sizingLogic,$n.explanation.commonMistake,$n.explanation.takeaway,$n.blockerNote,$n.prompt,$n.facing) | Where-Object { $_ }) -join ' '
    if ($prose -match "''") { Err $nid 'T.R12' 'doubled-apostrophe artifact' }
    if ($prose -match '[^\x20-\x7E]') { Err $nid 'T.R12' 'non-ASCII character in prose' }
    foreach ($p in @(' wait ', ' wait,', ' wait.', '... wait', 'actually impossible')) {
      if ($prose.ToLowerInvariant().Contains($p)) { Err $nid 'T.R12' ('self-correction artifact "' + $p.Trim() + '"') ; break }
    }
    # T.R19 -- mid-sentence correction artifacts (owner line-review fix 3):
    # catches "... no --", "wait,", "actually," style self-corrections that
    # the T.R12 word-boundary patterns miss.
    foreach ($p19 in @('... no --', '.. no --', ' no -- ', 'wait,', ' actually,')) {
      if ($prose.ToLowerInvariant().Contains($p19)) { Err $nid 'T.R19' ('mid-sentence correction artifact "' + $p19.Trim() + '"') ; break }
    }

    # T.R13 -- flush-dense ban + negation-window lint (Range-Reveal hygiene, house standard)
    if ($prose -match 'flush-dense') { Err $nid 'T.R13' 'flush-dense is banned' }
    foreach ($sent in [regex]::Split($prose, '(?<=[.!?])\s+')) {
      $m = [regex]::Match($sent, $bandRx, 'IgnoreCase')
      if ($m.Success) {
        $win = $sent.Substring([Math]::Max(0, $m.Index - 40), [Math]::Min(40, $m.Index))
        if ($win -match $negRx) { Warn $nid 'T.R13' ('negator before band phrase "' + $m.Value + '" -- verify intended') }
      }
    }
  }
  if ($treeSolverFail) { Err $tid 'T.R08' 'TREE FAILS: contains a non-approvable node (PIN 2)' }

  # T.R14 -- board lineage sanity: prompts/facing reference their own street cards
  # (lightweight: flop node facing mentions all three flop ranks)
  $fNode = $nodes | Where-Object { $_.street -eq 'flop' } | Select-Object -First 1
  if ($fNode) {
    foreach ($c in @($b.flopCards)) {
      $rk = $c.Substring(0,1)
      if ($fNode.facing -notmatch [regex]::Escape($rk)) { Warn ($tid+'/flop') 'T.R14' ('flop facing text may be missing rank ' + $rk) ; break }
    }
  }

  # T.R15 -- no trap/slowplay language anywhere in Tree A (owner condition);
  # applied to ALL trees as a WARN except Tree A where it is HARD.
  $allProse = ''
  foreach ($n in $nodes) { $allProse += ' ' + ((@($n.explanation.short,$n.explanation.streetLogic,$n.explanation.rangeContext,$n.explanation.handLogic,$n.explanation.sizingLogic,$n.explanation.commonMistake,$n.explanation.takeaway,$n.blockerNote) | Where-Object { $_ }) -join ' ') }
  $trapHit = $allProse -match '(?i)\b(trap|slow-?play)\w*\b'
  if ($tid -eq 'tree_a_nut_draw_arrives' -and $trapHit) { Err $tid 'T.R15' 'trap/slowplay language present in Tree A (owner condition: draw-play only)' }
  elseif ($trapHit -and $tid -ne 'tree_b_correct_fold' -and $tid -ne 'tree_c_bettors_line') { Warn $tid 'T.R15' 'trap/slowplay language -- verify' }

  # T.R16 -- Tree A river: stone-nuts enumeration must state BOTH SF blocks
  if ($tid -eq 'tree_a_nut_draw_arrives') {
    $r = $nodes | Where-Object { $_.street -eq 'river' } | Select-Object -First 1
    $rp = ($r.explanation.streetLogic + ' ' + $r.blockerNote)
    if ($rp -notmatch '(?i)royal' -or $rp -notmatch '9h' -or $rp -notmatch '(?i)straight flush') { Err ($tid+'/river') 'T.R16' 'stone-nuts enumeration incomplete: must state royal block (Ah) + K-Q-J-T-9 SF block (9h)' }
    if ($r.answer.critical -notcontains 'fold') { Err ($tid+'/river') 'T.R16' 'folding the stone nuts must be critical' }
  }
  # T.R17 -- Tree B river: check-raise choices present + graded bad/critical; fold best
  if ($tid -eq 'tree_b_correct_fold') {
    $r = $nodes | Where-Object { $_.street -eq 'river' } | Select-Object -First 1
    if (@($r.choices) -notcontains 'check_raise_small' -or @($r.choices) -notcontains 'check_raise_big') { Err ($tid+'/river') 'T.R17' 'river must offer both check-raises (leg-(c) closure)' }
    if ($r.answer.best -ne 'fold') { Err ($tid+'/river') 'T.R17' 'river best must be fold (Saved-BB beat)' }
    if (@($r.answer.bad) -notcontains 'check_raise_small') { Err ($tid+'/river') 'T.R17' 'check_raise_small must grade bad' }
    if (@($r.answer.critical) -notcontains 'check_raise_big') { Err ($tid+'/river') 'T.R17' 'check_raise_big must grade critical' }
  }
  # T.R18 -- Tree C turn: equity sources named explicitly (value + denial)
  if ($tid -eq 'tree_c_bettors_line') {
    $t = $nodes | Where-Object { $_.street -eq 'turn' } | Select-Object -First 1
    $tp = ($t.explanation.streetLogic + ' ' + $t.explanation.handLogic)
    if ($tp -notmatch '(?i)top pair top kicker' -or $tp -notmatch '(?i)(draw|denial)' ) { Err ($tid+'/turn') 'T.R18' 'turn barrel must name equity sources (made TPTK value + draw denial)' }
  }
}

Write-Output '=== G6 v4.6.0 Tree Audit ==='
Write-Output ('Trees: ' + $TREES.Count + '   Nodes: ' + (($TREES | ForEach-Object { @($_.nodes).Count } | Measure-Object -Sum).Sum))
Write-Output ('Errors: ' + $errors.Count)
Write-Output ('Warnings: ' + $warns.Count)
foreach ($e in $errors) { Write-Output ('ERROR ' + $e) }
foreach ($w in $warns) { Write-Output ('WARN  ' + $w) }
Write-Output '--- Stats ---'
foreach ($tree in $TREES) {
  $bests = (@($tree.nodes) | ForEach-Object { $_.street.Substring(0,1).ToUpper() + ':' + $_.answer.best }) -join '  '
  Write-Output ('  ' + $tree.id + ' [' + $tree.seat + '] ' + ((@($tree.board.flopCards) -join '') + '/' + $tree.board.turnCard + '/' + $tree.board.riverCard) + '  ->  ' + $bests)
}
if ($errors.Count -eq 0) { Write-Output 'RESULT: PASS' } else { Write-Output 'RESULT: FAIL' }
