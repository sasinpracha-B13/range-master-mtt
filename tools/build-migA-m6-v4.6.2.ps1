# build-migA-m6-v4.6.2.ps1 -- Migration A: the P3 suit-selection pair (2 NEW
# M6 rows on ONE node). PLANNING-ONLY: writes
# docs/specs/postflop-v4.6.2-migA-m6-seeds.json. Production never touched.
# Node: Ts6s2d / 3c / Ad, BB checks river, BTN decision.
# Evidence (solver, library sizes 108%/107% -- the only sizes on this
# texture): QsJs jam 1.4 / check 98.6; QhJh jam 100 / QdJd 99.7 / QcJc 100.
# The suit-selection direction is combo logic (owner ruling: sizing-robust).
# A5/C5/D5 same-node precedent: the two rows cross-reference as one lesson.
# P2 is NOT authored here: re-park recommendation (canonical-line arrival
# ~0 for A-high-with-SDV -- the P1 tree-shape class) goes to the gate.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$outPath = Join-Path $root 'docs\specs\postflop-v4.6.2-migA-m6-seeds.json'
$prodAll = ([System.IO.File]::ReadAllText((Join-Path $root 'postflop\postflop_scenarios.json'), [System.Text.UTF8Encoding]::new($false)) | ConvertFrom-Json).scenarios
$template = $prodAll | Where-Object { $_.id -like '*river_Ac7d4s_2c_m6_action_AhJh_v451' } | Select-Object -First 1
if (-not $template) { throw 'M6 template row not found' }
$rows = New-Object System.Collections.ArrayList
$SREF = 'GTO Wizard MTTGeneral_8m ChipEV 100bb, 2026-07-21, board Ts6s2d3cAd, line flop X-R7-C turn X-R21.9-C river X (library sizes; canonical 33/50-66 unpriceable on this texture)'

$M6_REASONS = @('blocker_bluff_river','blocker_sidedness_mix_river','check_back_showdown_river','check_back_trap_risk_river','give_up_no_equity_river','polar_overbet_nut_river','sizing_merge_small_river','sizing_polar_big_river','story_consistency_bluff_river','unblock_fold_region_river','value_bet_thick_river','value_bet_thin_river')

function NewM6($o) {
  $c = $template | ConvertTo-Json -Depth 12 | ConvertFrom-Json
  $c.id = 'pf_btn_v_bb_srp_100bb_river_Ts6s2d_Ad_m6_action_' + $o.hand + '_v462'
  $c.version = 'v4.6.2'
  $c.difficulty = 4  # deliberate (suit-selection nuance = D4); never inherit template D (F2 lesson)
  $c.heroHand = @($o.hero)
  $c.handClass = 'queen_high'
  $c.heroHandRole = $o.role
  $c.drawCategory = 'none'
  $c.showdownValue = 'none'
  $c.blockerNote = $o.blocker
  $c.recommendedAction = $o.rec
  $c.actionReason = $o.reason
  $c.verdictBasis = 'clear_direction'
  $c.stakeBasis = $o.stakeBasis
  $c.heroRiverSizing = $o.hrs
  $c.betPurpose = $o.purpose
  $c.board = [ordered]@{
    flopCards = @('Ts','6s','2d'); turnCard = '3c'; riverCard = 'Ad'
    cards = @('Ts','6s','2d','3c','Ad')
    # 5-card basis per house convention (live analog Th7d2s+Ac row) + validator R02
    boardKind = 'A_high'; suitTextureFlop = 'two_tone'; suitTextureTurn = 'two_tone'; suitTextureRiver = 'two_tone'
    textureTags = @('wet','semi_connected'); highCardClass = 'A_high'
    riverCategory = 'overcard'; boardChange = 'range_shift_btn'; runoutTexture = 'straight_possible'; riverDrawCompletion = 'none'
  }
  $c.question.prompt = 'Flop Ts 6s 2d; turn 3c; river Ad. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with ' + $o.pretty + '?'
  $c.question.choices = @('check_back','bet_small','bet_big','overbet','mixed')
  $c.answer.best = $o.best
  $c.answer.acceptable = @($o.acc)
  $c.answer.critical = @($o.crit)
  $c.answer.bad = @(@($c.question.choices) | Where-Object { $_ -ne $o.best -and (@($o.acc) -notcontains $_) -and (@($o.crit) -notcontains $_) })
  foreach ($k in $o.expl.Keys) { $c.explanation.$k = $o.expl[$k] }
  $c.conceptTags = @($o.tags)
  $c.sourceConfidence = 'consensus_gto'
  $c.auditStatus = 'review_pending'
  $c.reviewStatus = 'v4.6.2_seed'
  if ($c.PSObject.Properties['mixedWhitelistChoices']) { $c.PSObject.Properties.Remove('mixedWhitelistChoices') }
  $c | Add-Member -NotePropertyName solverRunRef -NotePropertyValue $SREF -Force
  $c | Add-Member -NotePropertyName solverNote -NotePropertyValue $o.snote -Force
  # inline seed asserts (paste-gate support; full R94-R107 runs at dry-run)
  if ($M6_REASONS -notcontains $c.actionReason) { throw ('bad reason ' + $c.actionReason) }
  $ans = @($c.answer.best) + @($c.answer.acceptable) + @($c.answer.bad) + @($c.answer.critical)
  if ((($ans | Sort-Object) -join ',') -ne ((@($c.question.choices) | Sort-Object) -join ',')) { throw ('partition mismatch ' + $c.id) }
  $all = @($c.board.cards) + @($c.heroHand)
  if (($all | Select-Object -Unique).Count -ne $all.Count) { throw ('card collision ' + $c.id) }
  [void]$script:rows.Add($c)
}

# --- Row A: QsJs -- the BLOCKED bluff checks back ---
NewM6 @{
  hand = 'QsJs'; hero = @('Qs','Js'); pretty = 'Qs Js'
  role = 'air_give_up'; rec = 'check_back'; reason = 'give_up_no_equity_river'
  stakeBasis = 'overbet'; hrs = 'none'; purpose = 'give_up'
  best = 'check_back'; acc = @(); crit = @('overbet')
  snote = 'P3 pair, row 1 of 2 (suit-selection lesson; cross-ref the QhJh row on this same node). Solver at library sizes: QsJs overbet-jam 1.4 / check 98.6 -- the busted spades BLOCK the folded-FD region the bluff needs. Direction is combo logic and sizing-robust (owner ruling 2026-07-21); stakeBasis = designated temptation (the jam this combo must not make).'
  blocker = 'Qs Js removes two of the busted spade draws that populate the BB folding region -- the exact hands an overbet needs villain to still hold. Blocking the folds kills the bluff; the showdown share of checking beats the priced-out jam.'
  tags = @('give_up_discipline','unblock_fold_region','bluff_candidate_selection')
  expl = [ordered]@{
    short = 'The busted flush draw looks like the natural bluff -- and is the single worst one: your spades sit in the folding half of the villain range.'
    riverLogic = 'The Ad closes the board with every draw dead. The BB check range is stuffed with exactly the hands that missed: spade draws that peeled twice and broadways that never paired. An overbet folds those out -- but Qs Js holds two of the spades that make up that folding region, so the bluff removes its own customers. The solver jams this combo 1.4 percent and checks 98.6.'
    rangeContext = 'Bluff selection on blocked rivers is a subtraction exercise: every fold you need is a combo villain must be able to hold. The no-spade QJ -- the twin row on this exact node -- jams at full frequency because it leaves the folding region intact. Same ranks, opposite verdict: the suits are the entire decision.'
    handLogic = 'Queen-high never wins at showdown against a range that called two streets, so checking wins only the pots where BB gave up too -- a small but real share. Jamming wins nothing extra: the hands that fold are the ones these spades block, and the hands that call all beat queen-high.'
    sizingLogic = 'No size fixes a blocked bluff: small gets called by every pair, big folds the same nothing, and the overbet is the expensive version of the mistake -- the punt tier here. Check, collect the give-up pots, and leave the bluffing to the twin combo with the right suits.'
    commonMistake = 'Bluffing BECAUSE the draw missed: a busted draw is not a bluffing licence -- it is a removal profile, and this one points the wrong way.'
    takeaway = 'Pick bluffs by what they unblock, not by what they missed: the busted-spade QJ checks while its no-spade twin jams -- suits, not ranks, decide.'
  }
}

# --- Row B: QhJh -- the UNBLOCKED jam ---
NewM6 @{
  hand = 'QhJh'; hero = @('Qh','Jh'); pretty = 'Qh Jh'
  role = 'air_bluff_candidate'; rec = 'overbet'; reason = 'unblock_fold_region_river'
  stakeBasis = 'overbet'; hrs = 'overbet'; purpose = 'bluff'
  best = 'overbet'; acc = @('bet_big'); crit = @()
  snote = 'P3 pair, row 2 of 2 (suit-selection lesson; cross-ref the QsJs row on this same node). Solver at library sizes: no-spade QJ overbet-jams 99.7-100 (QhJh 100 / QdJd 99.7 / QcJc 100) while QsJs checks 98.6. Holding no spade leaves the BB folded-FD region fully intact. Direction is combo logic and sizing-robust (owner ruling 2026-07-21); stakeBasis = best-line sizing.'
  blocker = 'Qh Jh holds no spade: the busted-FD region of the BB range keeps all its combos, and every one of them folds to the jam. Zero removal of the fold region -- the ideal bluff profile on this runout.'
  tags = @('unblock_fold_region','bluff_candidate_selection','sizing_polarity')
  expl = [ordered]@{
    short = 'Same ranks, no spade: this queen-high holds the perfect removal profile, and the solver turns it into a full-frequency overbet bluff.'
    riverLogic = 'The Ad river lets BTN rep the ace after barrelling twice, and the BB check range is dense with busted spades and unpaired broadways that cannot continue. Qh Jh blocks none of that folding region -- every fold the jam needs remains in the villain range -- so the overbet prints at full frequency in the solver.'
    rangeContext = 'This node runs a strict suit test: the spade version of these exact ranks checks back 98.6 percent -- the twin row -- because it blocks the folds. Unblocked, the same queen-high becomes the range bluff of choice. Nothing about hand strength changed; only the removal did.'
    handLogic = 'Queen-high has zero showdown value against two streets of calls, which makes it a perfect bluff candidate: no value is wasted by jamming, the A-high story is credible from the barrel line, and the fold-out region -- pairs under pressure plus every busted draw -- stays fully populated.'
    sizingLogic = 'The overbet is the point: maximum pressure on a capped check range that just watched the scare card land. The big bet is the acceptable smaller version; the small bet invites hero-calls, and checking back surrenders a bluff the solver plays at full frequency -- a plain leak with a hand that can never win otherwise.'
    commonMistake = 'Checking the twin of a good bluff: after learning the spade combo checks, over-applying the lesson -- the discipline is per-suit, not per-rank.'
    takeaway = 'When the scare card lands and your suits unblock the folds, air with the right removal jams -- selection by suit is the whole edge.'
  }
}

$doc = [ordered]@{
  description = 'Migration A (v4.6.2) M6 additions -- the P3 suit-selection pair (2 rows, one node, cross-referenced; A5/C5/D5 precedent). consensus_gto + solverRunRef. P2 re-parked (canonical-line arrival ~0 for A-high-with-SDV -- tree-shape class, P1 precedent) pending owner ruling. Production untouched by this script.'
  generatedBy = 'tools/build-migA-m6-v4.6.2.ps1'
  seedVersion = 'v4.6.2'
  count = $rows.Count
  reworks = @($rows.ToArray())
}
$json = $doc | ConvertTo-Json -Depth 12
$tmp = $outPath + '.tmp'
[System.IO.File]::WriteAllText($tmp, $json, [System.Text.UTF8Encoding]::new($false))
Move-Item -Force $tmp $outPath
Write-Output ('WROTE ' + $outPath + ' rows=' + $rows.Count + ' (P3 pair; inline asserts passed)')
