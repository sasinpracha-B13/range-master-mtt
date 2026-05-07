# ============================================================
# tools/build-m4-expansion-v4.3.0C.ps1
# v4.3.0C Module 4 Data Expansion -- canonical expansion builder
#
# Authors NEW v4.3.0C expansion seeds ONLY.
# Does NOT touch the original v4.3.0 builder or seed JSON.
#
# Output: docs/specs/postflop-v4.3.0C-module4-expansion-seeds.json
#
# Source-of-truth rule:
#   - Original 24 reviewed M4 seeds live in
#     docs/specs/postflop-v4.3.0-module4-seed-scenarios.json
#     (canonical builder: tools/build-m4-seeds-v4.3.0.ps1).
#   - This expansion adds NEW scenarios for v4.3.0C.
#   - Expansion seeds + original seeds together are the planning corpus.
#
# Safety:
#   - ASCII-only (no em-dash, no special unicode)
#   - No Invoke-Expression
#   - No Remove-Item on production-adjacent paths
#   - Atomic write via tmp + Move-Item to expansion JSON only
# ============================================================

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$outPath  = Join-Path $repoRoot 'docs\specs\postflop-v4.3.0C-module4-expansion-seeds.json'

# ----------------------------------------------------------------
# Constants
# ----------------------------------------------------------------
$spotTemplate = [ordered]@{
  format          = 'NLH_MTT'
  stackDepth      = '100BB'
  potType          = 'SRP'
  preflopAction   = 'BTN open 2.5x, BB call'
  flopAction      = 'BTN cbet small (~33%), BB call'
  turnAction      = 'BTN barrel'
  street          = 'turn'
  heroPosition    = 'BB'
  villainPosition = 'BTN'
  heroRole        = 'flop_check_caller_oop'
  villainRole     = 'turn_barreler_ip'
}
$actionChoices = @('fold','call','check_raise_small','check_raise_big','mixed')
$reasonChoices = @(
  'pot_odds_turn_call','equity_realization_turn_call','bluff_catch_turn',
  'board_change_fold','domination_turn_fold','range_disadvantage_turn_fold',
  'value_check_raise_turn','protection_check_raise_turn',
  'semi_bluff_check_raise_turn','blocker_check_raise_turn',
  'slowplay_turn_call','mixed_indifference_turn'
)

# ----------------------------------------------------------------
# Helper builders (mirror v4.3.0 builder shape)
# ----------------------------------------------------------------
function New-Spot { return [PSCustomObject]([ordered]@{} + $spotTemplate) }

function New-Board($flopCards, $turnCard, $boardKind, $hcc, $stFlop, $stTurn, $tags, $cat, $boardChange, $eqShift, $drawComp, $pairChange) {
  $cards = $flopCards + @($turnCard)
  return [PSCustomObject]([ordered]@{
    flopCards         = $flopCards
    turnCard          = $turnCard
    cards             = $cards
    boardKind         = $boardKind
    suitTextureFlop   = $stFlop
    suitTextureTurn   = $stTurn
    textureTags       = $tags
    highCardClass     = $hcc
    turnCategory      = $cat
    boardChange       = $boardChange
    equityShift       = $eqShift
    drawCompletion   = $drawComp
    pairStatusChange = $pairChange
  })
}

function New-Question($qtype, $prompt, $choices) {
  return [PSCustomObject]([ordered]@{ qtype = $qtype; prompt = $prompt; choices = $choices })
}
function New-Answer($best, $acc, $bad, $crit) {
  return [PSCustomObject]([ordered]@{ best = $best; acceptable = $acc; bad = $bad; critical = $crit })
}
function New-Explanation($short, $turnLogic, $rangeContext, $handLogic, $sizingLogic, $commonMistake, $takeaway) {
  return [PSCustomObject]([ordered]@{
    short         = $short
    turnLogic     = $turnLogic
    rangeContext  = $rangeContext
    handLogic     = $handLogic
    sizingLogic   = $sizingLogic
    commonMistake = $commonMistake
    takeaway      = $takeaway
  })
}
function New-Scenario {
  param(
    [string]$id, $board, $heroHand, [string]$handClass, [string]$heroHandRole,
    [string]$drawCategory, [string]$showdownValue, $blockerNote,
    [string]$recommendedAction, [string]$actionReason,
    $question, $answer, $explanation, $conceptTags,
    [string]$sourceConfidence = 'expert_judgment',
    [int]$difficulty = 3,
    [string]$uniquenessNote
  )
  return [PSCustomObject]([ordered]@{
    id                = $id
    module            = 'pf_turn_barrel_oop_def'
    moduleName        = 'Facing Turn Barrel OOP'
    schemaVersion     = '1.2.0'
    spot              = (New-Spot)
    board             = $board
    heroHand          = $heroHand
    handClass         = $handClass
    heroHandRole      = $heroHandRole
    drawCategory      = $drawCategory
    showdownValue     = $showdownValue
    blockerNote       = $blockerNote
    recommendedAction = $recommendedAction
    actionReason      = $actionReason
    question          = $question
    answer            = $answer
    explanation       = $explanation
    conceptTags       = $conceptTags
    sourceConfidence  = $sourceConfidence
    difficultyHint    = $difficulty
    auditStatus       = 'planning_only'
    reviewStatus      = 'v4.3.0C_expansion_candidate'
    uniquenessNote    = $uniquenessNote
  })
}
function Q-Action($hero, $boardStr, $turn) {
  # NOTE: ${hero} braces required (PowerShell parses '$hero?' as variable name 'hero?').
  return New-Question 'action_choice' "Flop $boardStr; turn $turn. BTN c-bet small flop, BB called, BTN now barrels. What is BB's best action with ${hero}?" $actionChoices
}
function Q-Reason($action, $hero, $boardStr, $turn) {
  return New-Question 'reason_choice' "Flop $boardStr; turn $turn. BB $action with $hero vs BTN's turn barrel. What is the primary reason?" $reasonChoices
}
function BoardStr($cards) { return ($cards -join ' ') }


# ====== New Boards (10 families) ======

# Family 1: Brick after A-high dry (Ac 7d 2s, 4h)
$f1Flop = @('Ac','7d','2s'); $f1Turn = '4h'
$f1 = New-Board $f1Flop $f1Turn 'A_high' 'A_high' 'rainbow' 'rainbow' @('dry','disconnected') 'brick' 'brick' 'neutral' 'none' 'no_change'
$f1Str = BoardStr $f1Flop

# Family 2: BB-favored Q overcard (8d 6c 3s, Qh)
$f2Flop = @('8d','6c','3s'); $f2Turn = 'Qh'
$f2 = New-Board $f2Flop $f2Turn 'low' 'Q_high' 'rainbow' 'rainbow' @('dry','semi_connected') 'overcard' 'range_shift_bb' 'favors_bb' 'none' 'no_change'
$f2Str = BoardStr $f2Flop

# Family 3: Ace overcard after K-high (Kd 8c 4s, Ah)
$f3Flop = @('Kd','8c','4s'); $f3Turn = 'Ah'
$f3 = New-Board $f3Flop $f3Turn 'K_high' 'A_high' 'rainbow' 'rainbow' @('dry','disconnected') 'overcard' 'range_shift_btn' 'favors_btn' 'none' 'no_change'
$f3Str = BoardStr $f3Flop

# Family 4: Flush-complete Q-high (Qs 8s 4d, 2s)
$f4Flop = @('Qs','8s','4d'); $f4Turn = '2s'
$f4 = New-Board $f4Flop $f4Turn 'Q_high' 'Q_high' 'two_tone' 'monotone' @('wet','disconnected') 'flush_complete' 'polarizing' 'completes_bb_draws' 'flush_completed' 'no_change'
$f4Str = BoardStr $f4Flop

# Family 5: BB-favored straight complete (9s 8d 4c, 7h)
$f5Flop = @('9s','8d','4c'); $f5Turn = '7h'
$f5 = New-Board $f5Flop $f5Turn 'low' 'low' 'rainbow' 'rainbow' @('wet','semi_connected') 'straight_complete' 'polarizing' 'favors_bb' 'straight_completed' 'no_change'
$f5Str = BoardStr $f5Flop

# Family 6: Board-pair high (Kd 8s 3c, 8h)
$f6Flop = @('Kd','8s','3c'); $f6Turn = '8h'
$f6 = New-Board $f6Flop $f6Turn 'K_high' 'K_high' 'rainbow' 'rainbow' @('dry','paired') 'board_pair' 'counterfeit' 'counterfeits_bb_pairs' 'none' 'flop_card_paired'
$f6Str = BoardStr $f6Flop

# Family 7: Board-pair low second-pair (Qs 7d 3c, 3h)
$f7Flop = @('Qs','7d','3c'); $f7Turn = '3h'
$f7 = New-Board $f7Flop $f7Turn 'Q_high' 'Q_high' 'rainbow' 'rainbow' @('dry','paired') 'board_pair' 'counterfeit' 'counterfeits_bb_pairs' 'none' 'flop_card_paired'
$f7Str = BoardStr $f7Flop

# Family 8: Draw-intensifier (Ts 8s 4d, 7c)
$f8Flop = @('Ts','8s','4d'); $f8Turn = '7c'
$f8 = New-Board $f8Flop $f8Turn 'T_high' 'T_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'draw_intensifier' 'draw_added' 'improves_bb_draws' 'oesd_added' 'no_change'
$f8Str = BoardStr $f8Flop

# Family 9: Multi-FD turn (Ah 9d 4d, 7h)
$f9Flop = @('Ah','9d','4d'); $f9Turn = '7h'
$f9 = New-Board $f9Flop $f9Turn 'A_high' 'A_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'draw_intensifier' 'draw_added' 'improves_bb_draws' 'gutshot_added' 'no_change'
$f9Str = BoardStr $f9Flop

# Family 10: Polarizing blank after dynamic flop (Jd Td 5s, 2c)
$f10Flop = @('Jd','Td','5s'); $f10Turn = '2c'
$f10 = New-Board $f10Flop $f10Turn 'J_high' 'J_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'brick' 'brick' 'neutral' 'none' 'no_change'
$f10Str = BoardStr $f10Flop


# ====== New Scenarios (28 total) ======

$scenarios = @()

# ---- Family 1 (Ac 7d 2s, 4h - brick) ----

# 1.1 -- 65s OESD on brick A-high - pot odds call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_6d5d_v430C' `
  -board $f1 -heroHand @('6d','5d') `
  -handClass 'oesd' -heroHandRole 'combo_draw' -drawCategory 'oesd' -showdownValue 'low' `
  -blockerNote 'Hero turned OESD: 4-5-6-7 (4 consecutive) needs 3 OR 8 for 5-card straight = 8 outs.' `
  -recommendedAction 'call' -actionReason 'pot_odds_turn_call' `
  -question (Q-Action '6d 5d' $f1Str '4h') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @()) `
  -explanation (New-Explanation `
    'OESD on brick A-high turn -- call to realize 8-out straight equity at small price.' `
    '4h is a brick for villain Ax range but completes hero''s straight draw structure: hero+board ranks 2,4,5,6,7,A form 4-5-6-7 (4 consecutive). 3 or 8 makes the straight = 8 outs.' `
    'BB flop call with 6-5 suited on A-7-2 was thin (gutshot to 3-4-5-6-7 + BDFD). Turn 4 promotes to OESD; small barrel sizing gives clean pot odds.' `
    '6d5d has OESD (need 3 or 8) + bottom-end straight redraw via runner-runner. ~16% one-card equity matches small-bet breakeven.' `
    'Calling realizes equity cheaply. Small check-raise also defensible as semi-bluff vs over-bluffy villain.' `
    'Folding OESD vs small barrel under-defends the BB calling range.' `
    'OESD on brick A-high turn = call (pot odds + equity).') `
  -conceptTags @('turn_pot_odds','second_barrel_defense','turn_equity_shift') `
  -difficulty 3 `
  -uniquenessNote 'Pot-odds-driven OESD call on a brick A-high turn. Distinct from existing brick scenarios because hero has real 8-out draw equity rather than naked overcards or marginal pair.'

# 1.2 -- 76 mid pair + gutshot on brick A-high - equity realization
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_7s6h_v430C' `
  -board $f1 -heroHand @('7s','6h') `
  -handClass 'mid_pair' -heroHandRole 'marginal_made_hand' -drawCategory 'gutshot' -showdownValue 'decent' `
  -blockerNote $null `
  -recommendedAction 'call' -actionReason 'equity_realization_turn_call' `
  -question (Q-Action '7s 6h' $f1Str '4h') `
  -answer (New-Answer 'call' @('mixed') @('fold','check_raise_small','check_raise_big') @()) `
  -explanation (New-Explanation `
    'Middle pair 7 + gutshot to 5 on brick turn -- call to realize multi-source equity.' `
    '4h adds gutshot to hero (need 5 for 3-4-5-6-7 ... wait need 3+5; actually 4-5-6-7 + need 3 or 8 = OESD with hero 6 only? Hero has 7 + 6: 4,6,7 + need 3+5 for 3-4-5-6-7, or 5+8 for 4-5-6-7-8 -- 5 is the unique-help card making 4-5-6-7 with hero 6 contributing). 5 makes 3-4-5-6-7 needs board 3 too. Simplifies to gutshot to 5 alone. Plus middle pair 7.' `
    'BB flop call with 7-6o on A-7-2 was natural (mid pair + backdoor). Turn 4 adds the gutshot to 5 plus pair-of-7 still beats villain bluffs.' `
    '7s6h has middle pair (7) + gutshot to 5 = 4 outs straight + 5 outs trips/two-pair = ~9 effective outs. Vs barrel that contains air, multi-source equity earns the call.' `
    'Calling realizes equity cheaply. Raising too thin OOP without made strength.' `
    'Folding mid-pair + gutshot vs small barrel under-defends BB range.' `
    'Mid pair + gutshot on brick turn = call (multi-source equity).') `
  -conceptTags @('turn_pot_odds','turn_bluff_catcher','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Equity-realization call with mid pair + gutshot on brick turn. Distinct from family 1 OESD because hero combines made-pair value with thin draw rather than pure draw equity.'

# 1.3 -- 99 underpair on A-high brick - mixed call/fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_9c9d_v430C' `
  -board $f1 -heroHand @('9c','9d') `
  -handClass 'underpair' -heroHandRole 'marginal_made_hand' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'mixed' -actionReason 'mixed_indifference_turn' `
  -question (Q-Action '9c 9d' $f1Str '4h') `
  -answer (New-Answer 'mixed' @('call','fold') @('check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Pocket 9s as underpair on A-high brick turn -- mixed call/fold (genuine indifference vs bluff frequency).' `
    '4h does not change ranges meaningfully: hero remains underpair to A and 7. Vs villain barrel range (Ax value + air), pocket 9s is bluff catcher BUT below the threshold for many sizing/villain combos.' `
    'BB flop call with 99 vs BTN small c-bet on A-7-2 was bluff-catch territory. Turn 4 brick keeps the spot exactly the same -- a marginal pair vs a polarized barrel.' `
    '99 has 5 outs to set + beats villain air. Calling captures bluffs; folding avoids paying off Ax. Frequency depends on villain bluff %.' `
    'Pure call vs over-bluffy villain; pure fold vs nitty villain. Solver mixes ~50/50 vs balanced barrel range.' `
    'Marking this as critical-fold or critical-call over-confident; it is a true mixed spot.' `
    'Underpair on brick turn vs balanced range = mixed call/fold.') `
  -conceptTags @('turn_pot_odds','turn_bluff_catcher','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'TRUE mixed-action teaching spot. Pocket 99 as underpair on A-high brick is the textbook close decision where solver indifference is real -- distinct from clean call/fold scenarios because the verdict depends on opponent tendency.'

# 1.4 -- KdJc naked overcards on A-high brick - domination fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_KdJc_v430C' `
  -board $f1 -heroHand @('Kd','Jc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'domination_turn_fold' `
  -question (Q-Action 'Kd Jc' $f1Str '4h') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'KJ no pair no draw on A-high brick -- fold; pair outs are dominated by Ax range.' `
    '4h is a brick. Hero KJ has 6 overcard outs (3 K + 3 J) but villain barrel range is Ax-heavy: any K-pair on river loses to AK; any J-pair loses to AJ.' `
    'BB flop call with KJo on A-7-2 was already thin (no pair, no draw, no relevant blocker). Turn 4 keeps the situation hopeless.' `
    'KdJc has zero made-hand value, no flush draw, no straight draw. The 6 overcard outs are dominated.' `
    'Folding closes action; calling chases dominated outs.' `
    'Continuing KJ vs A-high barrels because of "two overcards" is the prototypical M4 leak.' `
    'Naked broadway + dominated overcards on A-high brick = fold.') `
  -conceptTags @('turn_domination_fold','turn_range_disadvantage','second_barrel_defense') `
  -difficulty 2 `
  -uniquenessNote 'Domination-fold teaching with naked broadway on A-high brick. Distinct from existing JsTh fold (no draw + brick) because here the dominant theme is OUT-DOMINATION (pair outs lose), not just range-disadvantage.'


# ---- Family 2 (8d 6c 3s, Qh - BB-favored Q overcard) ----

# 2.1 -- AhQc TPTK on Q overcard turn - value check-raise
# (NOTE: Qh is on the turn; hero must use Qc/Qs/Qd to avoid card collision)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_8d6c3s_Qh_m4_action_AhQc_v430C' `
  -board $f2 -heroHand @('Ah','Qc') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'A-blocker reduces villain AA value combos; Qc avoids board-turn Qh collision.' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action 'Ah Qc' $f2Str 'Qh') `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'TPTK on BB-favored Q overcard turn -- check-raise small for value.' `
    'Qh on 8-6-3 favors BB: BTN with Q-high range typically 3-bets preflop (AQ/KQ/QQ), so BTN barrel range is short on Qx value. BB call range has more Qx (suited Qx, KQs, AQs sometimes flat). Hero AhQh = TPTK and BB is value-favored on this turn.' `
    'BB flop call with AhQh on 8-6-3 with backdoor heart was natural. Turn Q makes TPTK; range advantage swings to BB.' `
    'AhQh has TPTK with A kicker. Loses only to QQ (rare since BTN often 3-bets), 88/66/33 sets (rare flop call combos).' `
    'Small check-raise charges weaker Qx (KQ, JQ if any), overpairs (TT-99 turning into bluff catcher), and air bluffs that fold. Big raise risks too much vs sets.' `
    'Slowplaying TPTK on BB-favored overcard turn surrenders value vs villain Qx call-down.' `
    'TPTK on BB-favored overcard turn = check-raise small for value.') `
  -conceptTags @('turn_check_raise_value','turn_equity_shift','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'Value check-raise on a BB-favored overcard turn. Distinct from existing overcard scenarios (9-8-6-K shifts to BTN) because Q-overcard on low-mid flop favors BB. Tests recognition that overcard direction matters.'

# 2.2 -- JdTd OESD-redraw on Q overcard - pot odds call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_8d6c3s_Qh_m4_action_JdTd_v430C' `
  -board $f2 -heroHand @('Jd','Td') `
  -handClass 'gutshot' -heroHandRole 'draw' -drawCategory 'gutshot' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'call' -actionReason 'pot_odds_turn_call' `
  -question (Q-Action 'Jd Td' $f2Str 'Qh') `
  -answer (New-Answer 'call' @('mixed') @('fold','check_raise_small','check_raise_big') @()) `
  -explanation (New-Explanation `
    'JT gutshot to 9 for 8-9-T-J-Q on Q overcard turn -- call (pot odds).' `
    'Qh adds top-of-range value for BB but also creates a gutshot for hero JT: hero+board has 8,T,J,Q + need 9 for 8-9-T-J-Q straight = 4 outs. Plus 6 overcard outs (3 K, 3 A blocked) -- some pair outs are dominated.' `
    'BB flop call with JTs on 8-6-3 was natural (overcards + BDFD). Turn Q creates the gutshot.' `
    'JdTd has gutshot to 9 (4 outs) + 3 K-overcard outs (J-pair on K turn beats some bluffs) + slim runner-runner heart FD now dead.' `
    'Calling realizes ~10% equity vs ~25% breakeven plus implied odds on straight completion.' `
    'Folding JT with new gutshot vs over-bluffy villain under-defends BB range.' `
    'Gutshot + overcards on Q turn = call (pot odds + implied odds).') `
  -conceptTags @('turn_pot_odds','turn_equity_shift','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Pot-odds gutshot call on BB-favored overcard turn. Distinct from family 1 OESD because hero has 4-out gutshot only (not 8-out OESD) but turn card creates the draw rather than just preserving it.'

# 2.3 -- 6h5h flopped pair counterfeit on Q overcard - range-disadvantage fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_8d6c3s_Qh_m4_action_6h5h_v430C' `
  -board $f2 -heroHand @('6h','5h') `
  -handClass 'mid_pair' -heroHandRole 'dominated_marginal' -drawCategory 'backdoor_only' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_turn_fold' `
  -question (Q-Action '6h 5h' $f2Str 'Qh') `
  -answer (New-Answer 'fold' @('call') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Middle pair 6 + 5 kicker on Q overcard turn -- fold; pair has been demoted.' `
    'Qh adds Qx to villain barrel range (some QJ/QT). Hero 6-pair was already weak on flop; Q overcard demotes it further -- now 6-pair sits below Q-pair, J-pair, T-pair, 8-pair AND has dominated kicker outs.' `
    'BB flop call with 6-5s on 8-6-3 was thin (mid pair + BDFD heart). Turn Q kills the BDFD (no heart) and shifts villain barrel range upward.' `
    '6h5h has middle pair 6 with 5 kicker. 5 outs to two-pair/trips but vs villain Qx/88/overpairs is far behind.' `
    'Folding closes action; calling realizes minimal equity in a range-disadvantaged spot.' `
    'Stationing weak middle pair vs overcard turn that adds villain value combos is a real leak.' `
    'Demoted weak middle pair on overcard turn = fold (range disadvantage).') `
  -conceptTags @('turn_range_disadvantage','turn_board_change','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Pair-demotion fold on overcard turn. Distinct from family 3 K-pair demotion because here the pair is mid-pair-to-mid-pair (still middle) but kicker / threshold drops below defensible. Tests recognition that overcard turns shift pair rankings.'


# ---- Family 3 (Kd 8c 4s, Ah - Ace overcard) ----

# 3.1 -- KhQh TPGK demoted on Ace overcard - domination fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8c4s_Ah_m4_action_KhQh_v430C' `
  -board $f3 -heroHand @('Kh','Qh') `
  -handClass 'mid_pair' -heroHandRole 'dominated_marginal' -drawCategory 'backdoor_only' -showdownValue 'decent' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'domination_turn_fold' `
  -question (Q-Action 'Kh Qh' $f3Str 'Ah') `
  -answer (New-Answer 'fold' @('call') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'TPGK demoted to mid pair on Ace overcard turn -- fold; K-pair is now dominated by Ax range.' `
    'Ah brings every Ax in BTN barrel range (AK / AQ / AJ / AT / AA). Hero K-pair was top pair on flop but is now SECOND pair below the A. Vs Kx-and-down hero is ahead but those rarely barrel.' `
    'BB flop call with KQ on K-8-4 was easy (TPGK). Turn A demotes the pair and shifts range hard to BTN.' `
    'KhQh has middle pair (K, below Ace) with Q kicker. Vs Ax range hero is way behind; vs air hero beats it but villain rarely barrels air on A turn.' `
    'Folding closes action cleanly; calling stations into a dominated range.' `
    'Continuing K-pair on A-overcard turn because "I had top pair on the flop" ignores the range shift.' `
    'TPGK demoted by Ace overcard = fold (domination + range disadvantage).') `
  -conceptTags @('turn_domination_fold','turn_board_change','turn_range_disadvantage') `
  -difficulty 3 `
  -uniquenessNote 'Pair-demotion fold by Ace overcard specifically. Distinct from existing 9h7h on K-overcard (overcard kills mid pair) because here the SAME hand is top-pair-on-flop demoted to second-pair-on-turn -- a more painful fold lesson.'

# 3.2 -- 8d8h trips on Kx then Ace overcard - protection raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8c4s_Ah_m4_action_8d8h_v430C' `
  -board $f3 -heroHand @('8d','8h') `
  -handClass 'set' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Hero blocks 88-cooler combos (only 1 eight remains).' `
  -recommendedAction 'check_raise_small' -actionReason 'protection_check_raise_turn' `
  -question (Q-Action '8d 8h' $f3Str 'Ah') `
  -answer (New-Answer 'check_raise_small' @('call','check_raise_big') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Set of 8s on K-then-A turn -- check-raise small for value AND protection.' `
    'Ah brings every Ax in BTN barrel range to the table (now Ax is ahead of single-pair hands but behind sets). Hero set of 8s loses only to AA + KK (very rare). Many rivers (Q, J, T paired turns, runner-runner draws) kill action -- raise NOW while villain has Kx+Ax to call.' `
    'BB flop call with 88 on K-8-4 made middle set. Turn A adds Kx-second-pair and Ax-second-pair to villain''s range -- both are still way behind set 8s.' `
    '88 makes set on 8-paired board. Beats AK/AQ/AJ/Kx/Qx etc. Loses only to AA (1 combo blocked) and KK (rare).' `
    'Small check-raise charges Ax + Kx + air. Big raise on a dynamic turn also defensible since many rivers kill action.' `
    'Slowplaying set on A-overcard turn surrenders value vs Ax that pays off raise.' `
    'Set on overcard turn = check-raise small for protection + value.') `
  -conceptTags @('turn_check_raise_value','turn_equity_shift','turn_board_change') `
  -difficulty 3 `
  -uniquenessNote 'Protection-raise with set on Ace overcard turn. Distinct from existing 99 set on K turn because here the overcard is the NUT card (A) rather than just an overcard, raising the urgency to charge value before river kills action.'

# 3.3 -- JsTs gutshot to Q on K-A turn - pot odds call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8c4s_Ah_m4_action_JsTs_v430C' `
  -board $f3 -heroHand @('Js','Ts') `
  -handClass 'gutshot' -heroHandRole 'draw' -drawCategory 'gutshot' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'call' -actionReason 'pot_odds_turn_call' `
  -question (Q-Action 'Js Ts' $f3Str 'Ah') `
  -answer (New-Answer 'call' @('mixed','fold') @('check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'JT gutshot to Q for T-J-Q-K-A on K-A turn -- call (pot odds + implied odds).' `
    'Ah completes Broadway-shape: hero+board has T,J,K,A + need Q for T-J-Q-K-A straight (the nuts) = 4 outs. Hero blocked from improvements but the gutshot to nuts is high-value when it hits.' `
    'BB flop call with JTs on K-8-4 was natural (broadway overcards + BDFD spade). Turn A creates the nut gutshot.' `
    'JsTs has gutshot to nut Broadway (4 outs to the absolute nuts). Implied odds when villain barrels into Q river are huge.' `
    'Calling captures the gutshot at small price. Folding ignores the nut redraw.' `
    'Folding gutshot to the nuts vs small barrel under-defends and gives up high implied odds.' `
    'Nut gutshot on overcard turn = call (pot odds + nut implied odds).') `
  -conceptTags @('turn_pot_odds','turn_equity_shift','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Nut-gutshot call distinct from family 2 JT gutshot because here the gutshot hits the NUT straight (T-J-Q-K-A), not just any straight, so implied odds are dramatically higher.'


# ---- Family 4 (Qs 8s 4d, 2s - flush_complete Q-high) ----

# 4.1 -- As9s nut flush - value check-raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs8s4d_2s_m4_action_As9s_v430C' `
  -board $f4 -heroHand @('As','9s') `
  -handClass 'nut_flush' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Hero holds the nut flush (As-high spade flush).' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action 'As 9s' $f4Str '2s') `
  -answer (New-Answer 'check_raise_small' @('call','check_raise_big') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Made nut flush on flush-complete turn -- check-raise small for value.' `
    '2s makes the third spade on board completing flushes for hero (As+9s+Qs+8s+2s = 5 spades). Hero has the absolute nuts vs every villain barrel value (Qx, set, two-pair) and lower flushes.' `
    'BB flop call with AsXs on Q-8-4 with 2 spades was speculative (overcard A + nut FD); turn 2s lands the nut flush.' `
    'As9s makes 5-card spade flush A-Q-9-8-2 = nut flush. Loses to nothing.' `
    'Small check-raise charges Q-pair / set / lower flushes; big raise also defensible vs villain who calls big with K-flush or set.' `
    'Slowplaying nut flush on monotone turn surrenders value vs villain who sees scary turn and shuts down on river.' `
    'Nut flush on flush-complete turn = check-raise for value.') `
  -conceptTags @('turn_check_raise_value','turn_draw_completion','turn_blocker_pressure') `
  -difficulty 3 `
  -uniquenessNote 'Made nut flush value-raise on flush-complete turn. Distinct from existing 6s5s low-flush bluff-catch because here hero has THE nuts and the line is value extraction not pot control.'

# 4.2 -- AsKc TPTK with nut FD blocker - bluff catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs8s4d_2s_m4_action_AsKc_v430C' `
  -board $f4 -heroHand @('As','Kc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'bluff_catcher' -drawCategory 'nut_flush_draw' -showdownValue 'low' `
  -blockerNote 'As is the nut spade blocker AND gives hero the nut flush draw on river spades.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action 'As Kc' $f4Str '2s') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'No pair + nut spade blocker + nut FD redraw on flush-complete turn -- call (bluff-catch).' `
    '2s completes flush. Hero has no made hand but As blocks every nut-flush combo + provides nut FD redraw on river spades. The line is bluff-catch + drawing-to-nuts hybrid.' `
    'BB flop call with AsKc on Q-8-4 was natural (nut FD + 6 overcard outs). Turn 2s makes the FD reach but unhelpful for current showdown.' `
    'AsKc has no pair, but As blocks villain Ax-spade-flush combos AND provides 1-card nut FD on river. Vs villain barrel range that contains air, hero''s blocker + redraw justifies the call.' `
    'Calling captures villain bluffs and keeps the nut FD alive. Folding over-folds vs villain bluff frequency.' `
    'Folding the As blocker on flush-complete turn over-folds vs villain barrel range.' `
    'Nut blocker + nut FD on flush turn = call (bluff-catch + redraw).') `
  -conceptTags @('turn_bluff_catcher','turn_blocker_pressure','turn_draw_completion') `
  -difficulty 3 `
  -uniquenessNote 'Bluff-catch with nut blocker AND nut FD redraw on a different flush-complete board than the existing AsKd (Ks8s3d/2s). Tests that the SAME blocker logic generalizes to a different K-vs-Q-high board family.'

# 4.3 -- 8d8h set on flush turn - slowplay call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs8s4d_2s_m4_action_8d8h_v430C' `
  -board $f4 -heroHand @('8d','8h') `
  -handClass 'set' -heroHandRole 'slowplay_trap' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Hero blocks 88 cooler set; only 1 eight left in deck.' `
  -recommendedAction 'call' -actionReason 'slowplay_turn_call' `
  -question (Q-Action '8d 8h' $f4Str '2s') `
  -answer (New-Answer 'call' @('check_raise_small','fold') @('mixed','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Middle set on flush-complete turn -- slowplay call (raising bloats vs flush).' `
    '2s completes flush. Hero set is way ahead of villain Qx / overpairs / air but BEHIND any villain hand with 2 spades (made flush). Raising commits chips into flush range.' `
    'BB flop call with 88 on Q-8-4 was easy (middle set). Turn 2s makes flush threat real.' `
    '8d8h makes set of 8s + boat draw to 8 or river-pair. Loses to AsXs flushes + KsXs / JsXs etc. Set has ~4 outs to boat (any pair on river).' `
    'Calling preserves villain bluffs for river. Raising small acceptable to charge worse hands but exposes to flush check-raise. Folding wastes the set value vs villain''s air bucket.' `
    'Auto-raising set on monotone turns commits OOP into flush range.' `
    'Set on flush-complete turn = slowplay call (do not raise into flush).') `
  -conceptTags @('turn_slowplay_call','turn_draw_completion','turn_bluff_catcher') `
  -difficulty 4 `
  -uniquenessNote 'Slowplay-call with set on flush-complete turn. Distinct from existing 88 set on dry brick (slowplay because villain bluffs intact) -- here slowplay is DEFENSIVE because raising risks flush punish, not offensive value preservation.'


# ---- Family 5 (9s 8d 4c, 7h - BB-favored straight complete) ----

# 5.1 -- JhTh nut straight - check_raise_BIG (CHECK_RAISE_BIG #1)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9s8d4c_7h_m4_action_JhTh_v430C' `
  -board $f5 -heroHand @('Jh','Th') `
  -handClass 'straight' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Hero holds the nut straight 7-8-9-T-J on a BB-favored straight-complete turn.' `
  -recommendedAction 'check_raise_big' -actionReason 'value_check_raise_turn' `
  -question (Q-Action 'Jh Th' $f5Str '7h') `
  -answer (New-Answer 'check_raise_big' @('check_raise_small') @('fold','mixed','call') @('fold')) `
  -explanation (New-Explanation `
    'Made NUT straight 7-8-9-T-J on BB-favored straight-complete turn -- check-raise BIG for max value.' `
    '7h completes straight for several BB-range hands (T6, 65, 87, JT etc.). BB is range-favored on this turn (BTN with JT/T6 typically does NOT 3-bet; BB call range catches these straights). BTN barrel range is overpair-heavy + air -- both pay off bigger sizing on a polar turn.' `
    'BB flop call with JTs on 9-8-4 with backdoor heart was natural (overcards + BDFD + gutshot to 6 or J-T-9-8-? actually JT on 984 has gutshot to 7 already on the flop which lands turn). Turn 7 makes nut straight.' `
    'JhTh makes 7-8-9-T-J = J-high straight = nuts. Beats every villain hand. Even higher straights cannot exist (would need K-Q on board).' `
    'BIG check-raise extracts max from villain overpairs, top-pair, sets that may continue. Small raise leaves value behind on a BB-favored polar turn.' `
    'Slowplaying the nut straight on a BB-favored polar turn surrenders value vs villain who is forced to defend with overpairs/sets.' `
    'Nut straight on BB-favored polar turn = check-raise BIG (rare but justified spot).') `
  -conceptTags @('turn_check_raise_value','turn_draw_completion','turn_equity_shift') `
  -difficulty 4 `
  -uniquenessNote 'CHECK_RAISE_BIG justified spot #1: nut straight on BB-favored polar turn. Distinct from existing 98 made-straight value-raise (Q-T-6-J) which uses small raise -- here BIG raise is justified because BB has range-shift advantage AND villain barrel range is forced to call wider with overpairs/sets.'

# 5.2 -- AhAd overpair on BB-favored straight turn - mixed (MIXED #1)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9s8d4c_7h_m4_action_AhAd_v430C' `
  -board $f5 -heroHand @('Ah','Ad') `
  -handClass 'overpair' -heroHandRole 'marginal_made_hand' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote $null `
  -recommendedAction 'mixed' -actionReason 'mixed_indifference_turn' `
  -question (Q-Action 'Ah Ad' $f5Str '7h') `
  -answer (New-Answer 'mixed' @('call','fold') @('check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'AA overpair on BB-favored straight-complete turn -- mixed call/fold (range-disadvantaged but still beats bluffs).' `
    '7h completes straights for many BB-range hands (T6, 65, 87, JT, 56). AA is now BEHIND every made straight but AHEAD of overpairs lower than itself + air. BTN barrel range polarized -- some KK/QQ paying off + air bluffs continuing.' `
    'BB flop call with AA vs BTN small c-bet (sometimes flat-traps overpair to mask range). Turn 7 polarizes the spot heavily.' `
    'AhAd has overpair + nothing else. Vs barrel: ahead of TT/JJ overpairs that turn into bluff catchers + air; behind every straight.' `
    'Calling captures villain bluffs/lower-overpairs. Folding avoids paying off straights. The math splits depending on villain frequency. Pure call vs over-bluffy; pure fold vs nitty.' `
    'Auto-calling AA into a polar turn that completes draws ignores how scary the runout is. Auto-folding ignores bluff frequency.' `
    'Overpair on BB-favored straight turn = mixed call/fold (true indifference).') `
  -conceptTags @('turn_pot_odds','turn_bluff_catcher','turn_range_disadvantage') `
  -difficulty 5 `
  -uniquenessNote 'TRUE mixed-action spot #1 with overpair on a BB-favored polar straight turn. Distinct from family 1 99-mixed because the hand is much stronger (AA) but the polar turn structure makes it a genuine close decision.'

# 5.3 -- KdJd gutshot on straight-complete turn - pot odds call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9s8d4c_7h_m4_action_KdJd_v430C' `
  -board $f5 -heroHand @('Kd','Jd') `
  -handClass 'gutshot' -heroHandRole 'draw' -drawCategory 'gutshot' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'call' -actionReason 'pot_odds_turn_call' `
  -question (Q-Action 'Kd Jd' $f5Str '7h') `
  -answer (New-Answer 'call' @('mixed','fold') @('check_raise_small','check_raise_big') @()) `
  -explanation (New-Explanation `
    'KJ gutshot to T for 7-8-9-T-J on BB-favored straight turn -- call (pot odds).' `
    '7h adds gutshot for KJ: hero+board has 7,8,9,J,K + need T for 7-8-9-T-J straight = 4 outs. Plus K and J overcard outs vs air range.' `
    'BB flop call with KJs on 9-8-4 was thin (overcards + BDFD diamond). Turn 7 adds the gutshot.' `
    'KdJd has gutshot to T (4 outs to second-nut-straight) + slim overcard equity. Vs barrel that contains air, multi-source equity earns the small call.' `
    'Calling realizes equity cheaply with implied odds when straight hits.' `
    'Folding new-gutshot vs small barrel under-defends BB range.' `
    'Gutshot to second-nut on BB-favored straight turn = call.') `
  -conceptTags @('turn_pot_odds','second_barrel_defense','turn_equity_shift') `
  -difficulty 3 `
  -uniquenessNote 'Pot-odds gutshot call on a BB-favored straight-complete turn (distinct from family 3 nut-Broadway gutshot because here the gutshot is to 2nd-nut not nut, but the BB-favored range context makes the call profitable).'


# ---- Family 6 (Kd 8s 3c, 8h - board pair high) ----

# 6.1 -- AdKh TPTK on Kx-paired turn - bluff catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8s3c_8h_m4_action_AdKh_v430C' `
  -board $f6 -heroHand @('Ad','Kh') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Hero blocks AK / AA combos in villain range.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action 'Ad Kh' $f6Str '8h') `
  -answer (New-Answer 'call' @('check_raise_small','fold') @('mixed','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'TPTK on board-paired (Kx + 8x paired) turn -- call (bluff-catch).' `
    '8h pairs the second board card making board K-8-8-3. Hero TPTK is still ahead of villain''s pair-of-K and air. Loses to KK (rare), 88 (3 combos), 33 (3 combos), Ax with 3 (but rare flop call). Most barrel range = bluff or pair-of-K-weaker.' `
    'BB flop call with AKo on K-8-3 was easy (TPTK). Turn 8 paired board doesn''t change relative ranking.' `
    'AdKh has TPTK + A blocker. Beats Kx-with-weaker-kicker + bluffs. Loses to KK / 88 / 33 / 8x with pair (rare).' `
    'Calling captures bluffs. Raising folds bluffs and isolates against KK/8x-trip.' `
    'Folding TPTK on paired board because "trip 8 might exist" over-folds vs villain bluff frequency.' `
    'TPTK on board-paired turn = call (bluff-catch).') `
  -conceptTags @('turn_bluff_catcher','turn_board_change','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'TPTK call on Kx-paired-by-8 turn. Distinct from existing AdKc on 88-3-3 (family 5 board-pair) because here the BOARD-PAIRED card is the SECOND-HIGHEST (8 doubles), not top -- different threat profile.'

# 6.2 -- KsKc full house - check_raise_BIG (CHECK_RAISE_BIG #2)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8s3c_8h_m4_action_KsKc_v430C' `
  -board $f6 -heroHand @('Ks','Kc') `
  -handClass 'full_house' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Hero blocks KK by holding 2 of 4 kings.' `
  -recommendedAction 'check_raise_big' -actionReason 'value_check_raise_turn' `
  -question (Q-Action 'Ks Kc' $f6Str '8h') `
  -answer (New-Answer 'check_raise_big' @('check_raise_small') @('fold','mixed','call') @('fold')) `
  -explanation (New-Explanation `
    'Top set on K then turn pairs board to 8-8 = full house Kings full of 8s -- check-raise BIG for max value.' `
    '8h pairs board (K-8-8-3) turning hero''s top set into a near-nut full house (only 88 quads beats hero, virtually impossible since only 1 eight left and villain rarely has 88 in barrel range).' `
    'BB flop call with KK vs BTN open is unusual but possible (slow-flat to mask range / disguise on K-high boards). On turn 8 paired = hero has K-K-K-8-8 = top boat.' `
    'KsKc + K-8-8-3 board = Kings full of 8s = full house. Beats every Kx, every 8x trip, every smaller boat. Loses only to 88 quads.' `
    'BIG check-raise extracts max from villain who pays off with Kx, 8x trips, AA/QQ overpairs hoping to bluff-catch. Small raise leaves value behind on a paired board where villain knows hero range is polar.' `
    'Slowplaying top boat on paired turn surrenders huge value vs villain who is calling bigger sizes with Kx + 8x trips.' `
    'Top boat on board-paired turn = check-raise BIG for max value.') `
  -conceptTags @('turn_check_raise_value','turn_board_change','turn_blocker_pressure') `
  -difficulty 3 `
  -uniquenessNote 'CHECK_RAISE_BIG justified spot #2: top boat (Kings full of 8s) on Kx-paired-by-8 turn. Distinct from family 5 nut-straight check-raise-big because here the value is BOAT not straight, and the polar-turn-board-pair structure rewards bigger sizing differently.'

# 6.3 -- QhJh naked broadway on K-paired turn - domination fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8s3c_8h_m4_action_QhJh_v430C' `
  -board $f6 -heroHand @('Qh','Jh') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'domination_turn_fold' `
  -question (Q-Action 'Qh Jh' $f6Str '8h') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'QJ no pair no draw on board-paired turn -- fold; pair outs are dominated.' `
    '8h pairs board. Hero QJ has 6 overcard outs but Q-pair / J-pair on river still loses to Kx (which villain has heavily) and to trip 8 (88 / 8x).' `
    'BB flop call with QJs on K-8-3 with backdoor heart was thin. Turn 8 paired keeps the situation hopeless for naked broadway.' `
    'QhJh has zero made-hand value, no straight draw, no flush draw (hearts dead since only 1 heart on board). Pair outs dominated.' `
    'Folding closes action; calling chases dominated outs.' `
    'Continuing QJ vs K-paired turn because of two overcards is the prototypical M4 leak.' `
    'Naked broadway on board-paired turn = fold (domination).') `
  -conceptTags @('turn_domination_fold','turn_range_disadvantage','turn_board_change') `
  -difficulty 2 `
  -uniquenessNote 'Domination-fold with naked broadway on Kx-paired-by-8. Distinct from existing QhJh on 8c8d3s/3h (low-paired) because Kx-paired barrel range is much heavier in Kx value than 8x-paired.'


# ---- Family 7 (Qs 7d 3c, 3h - board pair low + second pair) ----

# 7.1 -- 7s7c full house on second-pair turn - value raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs7d3c_3h_m4_action_7s7c_v430C' `
  -board $f7 -heroHand @('7s','7c') `
  -handClass 'full_house' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Hero blocks 77 cooler (only 1 seven left in deck).' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action '7s 7c' $f7Str '3h') `
  -answer (New-Answer 'check_raise_small' @('call','check_raise_big') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Set of 7s on Q-7-3 then 3 turn = sevens full of threes -- check-raise small for value.' `
    '3h pairs board (Q-7-3-3) turning hero set into full house. Beats every villain hand except QQ (1 combo, rare flop continuance), 33 (impossible -- 4 threes total, 2 on board), and Qx-with-3 (rare).' `
    'BB flop call with 77 on Q-7-3 made middle set. Turn 3 paired board = boat for hero.' `
    '7s7c + Q-7-3-3 board = sevens full of threes = full house. Beats Qx, overpairs, every air bluff.' `
    'Small check-raise charges Qx + air. Big raise also defensible since boat plays huge.' `
    'Slowplaying boat on paired turn surrenders value vs villain Qx + overpairs.' `
    'Set turning to boat on paired turn = check-raise for value.') `
  -conceptTags @('turn_check_raise_value','turn_board_change','turn_slowplay_call') `
  -difficulty 3 `
  -uniquenessNote 'Value raise with set-to-boat on second-pair-turn. Distinct from family 6 KK boat (top-set boat) because here hero has MIDDLE-set boat which is still nuts but the pairing card was bottom rather than middle, testing recognition that pair-of-bottom counterfeits FEWER hands.'

# 7.2 -- AhAd overpair on Q-7-3-3 - protection raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs7d3c_3h_m4_action_AhAd_v430C' `
  -board $f7 -heroHand @('Ah','Ad') `
  -handClass 'overpair' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Hero blocks AA cooler combos.' `
  -recommendedAction 'check_raise_small' -actionReason 'protection_check_raise_turn' `
  -question (Q-Action 'Ah Ad' $f7Str '3h') `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'AA overpair on bottom-paired turn (Q-7-3-3) -- check-raise small for protection + value.' `
    '3h pairs bottom card. Hero AA is still overpair to all of Q-7-3 + still ahead of Qx, mid pairs, lower overpairs. Vs Q-x and trip-3 (rare), hero is well ahead. Many rivers (broadway turns, suit completers) make villain''s hand more dangerous -- raise NOW.' `
    'BB flop call with AA vs BTN small c-bet on Q-7-3 (sometimes traps overpair to mask range). Turn 3 doesn''t change relative ranking.' `
    'AhAd has overpair to all board cards. Loses only to QQ / 77 / 33 / Q-x trips (rare). Beats every other villain hand.' `
    'Small check-raise charges Qx + lower overpairs + air. Big raise risks too much vs sets/trips.' `
    'Slowplaying overpair on paired turn surrenders value to Qx that pays off raise.' `
    'Overpair on paired turn = check-raise for protection.') `
  -conceptTags @('turn_check_raise_value','turn_board_change','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'Protection-raise with overpair on bottom-paired turn. Distinct from family 3 set-protection because here hero has VULNERABLE OVERPAIR not a set, raising the urgency to charge value before draws materialize.'


# ---- Family 8 (Ts 8s 4d, 7c - draw-intensifier 2) ----

# 8.1 -- 9d6d nut straight on draw-intensifier turn - value raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_action_9d6d_v430C' `
  -board $f8 -heroHand @('9d','6d') `
  -handClass 'straight' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Hero made T-high straight 6-7-8-9-T (second-nut behind J9).' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action '9d 6d' $f8Str '7c') `
  -answer (New-Answer 'check_raise_small' @('check_raise_big','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    '6-7-8-9-T straight on draw-intensifier turn -- check-raise small for value.' `
    '7c adds new draw lines and completes hero straight: hero+board ranks 4,6,7,8,9,T = 6-7-8-9-T = T-high straight. Loses only to JT and J9 (J9 makes 7-8-9-T-J wait needs J actually impossible without J on board). Realistically only QJ/J9 specific combos higher.' `
    'BB flop call with 96-suited on T-8-4 was thin (overcards + BDFD); turn 7 lands the straight.' `
    '9d6d makes 6-7-8-9-T = T-high straight. The only beats are J-T-9-8-7 which needs J in villain hand (rare combo on the flop call).' `
    'Small check-raise charges Tx, overpairs, sets, weaker draws. Big raise on a dynamic turn also justified vs sets that may continue.' `
    'Slowplaying nut-ish straight on dynamic turn surrenders value as runout brings new threats.' `
    'Made straight on draw-intensifier turn = check-raise for value.') `
  -conceptTags @('turn_check_raise_value','turn_draw_completion','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Made-straight value-raise on a draw-intensifier turn distinct from existing 87 straight (family 6 Ts9s5d/6h) because the straight forms via 6-7 connection rather than 7-8 connection -- different combo coverage in BB flop call range.'

# 8.2 -- AsKs nut FD + overcards on draw-intensifier - equity realization
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_action_AsKs_v430C' `
  -board $f8 -heroHand @('As','Ks') `
  -handClass 'nut_flush_draw' -heroHandRole 'combo_draw' -drawCategory 'nut_flush_draw' -showdownValue 'low' `
  -blockerNote 'Hero holds nut flush draw (As + 3 board spades = 4 spades) plus 6 overcard outs (3A + 3K).' `
  -recommendedAction 'call' -actionReason 'equity_realization_turn_call' `
  -question (Q-Action 'As Ks' $f8Str '7c') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Nut FD + 6 overcards on draw-intensifier turn -- call to realize multi-source equity.' `
    '7c does not bring spades but adds straight draw to villain''s range (98, J9 etc.). Hero still has nut FD (As + Ts/8s on board = need 1 more spade) + 6 overcard outs. ~14 outs total = ~33% one-card equity.' `
    'BB flop call with AKs (spades) on T-8-4 was natural (nut FD + 2 overcards). Turn 7 keeps the FD alive.' `
    'AsKs has nut FD (~9 spade outs) + 6 overcard outs (some dominated by A/K-pair villain hands but mostly clean). Multi-source equity earns the call vs barrel.' `
    'Calling realizes ~33% equity at small price. Raising as semi-bluff defensible vs over-bluffy villain.' `
    'Folding combo equity OOP under-defends BB range.' `
    'Nut FD + overcards on dynamic turn = call (equity realization).') `
  -conceptTags @('turn_pot_odds','turn_blocker_pressure','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Nut-FD-with-overcards combo-call on a different draw-intensifier than existing As6s on Ts9s5d/6h. Distinct because hero has 2 OVERCARDS (A,K) instead of pair-of-6, testing equity-realization with high-card draw rather than pair-plus-draw.'

# 8.3 -- 9c8c top pair + OESD - semi_bluff (SEMI_BLUFF #1)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_action_9c8c_v430C' `
  -board $f8 -heroHand @('9c','8c') `
  -handClass 'oesd' -heroHandRole 'combo_draw' -drawCategory 'oesd' -showdownValue 'decent' `
  -blockerNote $null `
  -recommendedAction 'check_raise_small' -actionReason 'semi_bluff_check_raise_turn' `
  -question (Q-Action '9c 8c' $f8Str '7c') `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Pair of 8 + OESD on draw-intensifier turn -- check-raise small as semi-bluff.' `
    '7c adds OESD: hero+board has 7,8,9,T (4 consecutive) + need J or 6 for straight = 8 outs. Plus pair of 8 (board 8) = additional outs to two-pair/trips. Plus club backdoor flush draw.' `
    'BB flop call with 9-8-suited on T-8-4 was natural (mid pair + BDFD club + OESD-on-turn-equity). Turn 7 lands the OESD.' `
    '9c8c has pair of 8 + OESD (J or 6) + 4 outs to two-pair (any 9) + slim BDFD = ~14 outs total. Strong combo equity.' `
    'Small check-raise leverages fold equity vs villain weaker overpairs (TT-99) + air, while strong made hands continue. Big raise risks too much given hero is not yet made.' `
    'Identifying as protection misses the SEMI-BLUFF nature: hero has fold equity AND draw equity.' `
    'Strong combo (pair + OESD) on dynamic turn = semi-bluff check-raise.') `
  -conceptTags @('turn_check_raise_bluff','turn_equity_shift','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'SEMI_BLUFF #1: pair + OESD combo on draw-intensifier turn. Distinct from existing OESD scenarios because hero combines made-pair value with strong draw, justifying semi-bluff with both fold equity AND realized equity backing.'


# ---- Family 9 (Ah 9d 4d, 7h - multi-FD turn) ----

# 9.1 -- AsTs TPGK on multi-FD turn - bluff catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ah9d4d_7h_m4_action_AsTs_v430C' `
  -board $f9 -heroHand @('As','Ts') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'A blocker reduces villain AA / Ax-flush combos.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action 'As Ts' $f9Str '7h') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'TPGK on multi-FD turn -- call (bluff-catch with A blocker).' `
    '7h adds heart flush-draw threats to villain range AND a few new straight draws (5-6 + 7-8 = backdoor straight tries). Hero TPGK still beats most barrel range; A blocker reduces AA top-of-range.' `
    'BB flop call with AT-suited on A-9-4 with backdoor spade was natural (TPGK + BDFD). Turn 7 keeps the spot bluff-catch territory.' `
    'AsTs has TPGK + A blocker. Beats Ax-with-weaker-kicker (A2-A8 if any), pairs of 9 / 4, air. Loses to AK/AQ/AJ/two-pair/sets.' `
    'Calling captures villain bluffs + air. Raising folds bluffs and isolates against AK+ value.' `
    'Folding TPGK + A blocker over-folds vs villain barrel range that contains heart-FD bluffs.' `
    'TPGK + A blocker on multi-FD turn = call.') `
  -conceptTags @('turn_bluff_catcher','turn_blocker_pressure','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'TPGK bluff-catch on a board with TWO live flush draws (diamond AND heart). Distinct from existing AdQd-on-As8d3h-2c (clean dry brick) because here the runout is dynamic, raising the importance of the A-blocker''s actual fold-out value.'

# 9.2 -- KdQd second-nut diamond FD + overcards - equity realization
# (NOTE: Ad is NOT on board (Ah is heart). Hero Kd is 2nd-nut diamond FD,
#  not nut, because Ad is still possible in villain hand.)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ah9d4d_7h_m4_action_KdQd_v430C' `
  -board $f9 -heroHand @('Kd','Qd') `
  -handClass 'flush_draw' -heroHandRole 'combo_draw' -drawCategory 'flush_draw' -showdownValue 'low' `
  -blockerNote 'Hero holds 2nd-nut diamond FD via Kd (Ad is still possible in villain hand since board diamond is 9d/4d). Plus K and Q overcard outs.' `
  -recommendedAction 'call' -actionReason 'equity_realization_turn_call' `
  -question (Q-Action 'Kd Qd' $f9Str '7h') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    '2nd-nut diamond FD + KQ overcards on multi-FD turn -- call to realize multi-source equity.' `
    '7h does not bring more diamonds. Hero still has K-high diamond FD (board has 9d + 4d, hero has Kd + Qd = 4 diamonds total, need 1 more for K-high flush). Loses to a villain Ad-X-of-diamonds combo on river. Plus K-overcard + Q-overcard outs.' `
    'BB flop call with KQs on A-9-4 was thin (overcards + BDFD diamond which became live FD on flop). Turn 7 keeps the FD alive.' `
    'KdQd has 2nd-nut diamond FD (~9 outs minus Ad-of-diamond which beats hero on river) + K and Q overcards (some pair outs dominated by Ax). ~11 effective outs.' `
    'Calling realizes equity at small price. Semi-bluff raise defensible vs over-bluffy villain.' `
    'Folding flush draw + overcards under-defends.' `
    'High-FD + overcards on multi-FD turn = call (equity realization).') `
  -conceptTags @('turn_pot_odds','turn_equity_shift','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote '2nd-nut diamond FD + overcards call. Distinct from family 8 AsKs (NUT FD with overcards) because here hero has 2ND-NUT FD (Kd) where Ad is still live in villain range. Tests that flush-draw classification depends on exact suit-Ace location.'

# 9.3 -- 5d6d combo OESD + FD - semi_bluff (SEMI_BLUFF #2)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ah9d4d_7h_m4_action_5d6d_v430C' `
  -board $f9 -heroHand @('5d','6d') `
  -handClass 'combo_draw' -heroHandRole 'combo_draw' -drawCategory 'combo_draw' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'check_raise_small' -actionReason 'semi_bluff_check_raise_turn' `
  -question (Q-Action '5d 6d' $f9Str '7h') `
  -answer (New-Answer 'check_raise_small' @('call','check_raise_big') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'OESD + diamond FD combo draw -- check-raise small as semi-bluff.' `
    '7h adds OESD for hero: hero+board has 4,5,6,7 (4 consecutive) + need 3 or 8 for straight = 8 outs. Plus 4 diamonds (need 1 more for flush) = ~9 FD outs. Total ~15 outs minus shared outs = ~13 effective outs = ~30% one-card equity.' `
    'BB flop call with 65-suited on A-9-4 with backdoor diamond was thin (BDFD + slim straight potential). Turn 7 lands OESD on top of FD.' `
    '5d6d has OESD + nut-block-not-applicable diamond FD. Strong combo equity vs barrel range.' `
    'Small check-raise leverages fold equity vs villain weak Ax + air. Big raise also defensible given combo equity.' `
    'Identifying as pure call misses the semi-bluff fold-equity opportunity.' `
    'OESD + FD combo on dynamic turn = semi-bluff check-raise.') `
  -conceptTags @('turn_check_raise_bluff','turn_equity_shift','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'SEMI_BLUFF #2: OESD + FD combo draw. Distinct from family 8 9c8c (pair + OESD) because here hero has pure-DRAW combo (no made pair), making the semi-bluff cleaner pure-equity-based rather than thin-value-plus-equity.'


# ---- Family 10 (Jd Td 5s, 2c - polarizing brick after dynamic flop) ----

# 10.1 -- KdQd nut FD + OESD on polar brick - semi_bluff #3
# (NOTE: dropping per design; only 2 scenarios in family 10)

# 10.1 -- AhAd overpair on polar brick - protection raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_JdTd5s_2c_m4_action_AhAd_v430C' `
  -board $f10 -heroHand @('Ah','Ad') `
  -handClass 'overpair' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote $null `
  -recommendedAction 'check_raise_small' -actionReason 'protection_check_raise_turn' `
  -question (Q-Action 'Ah Ad' $f10Str '2c') `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'AA overpair on polarizing brick after draw-heavy J-T-5 flop -- check-raise small for protection.' `
    '2c is a brick that does NOT complete any draw. Villain barrel range stays polarized: value Jx/Tx/sets + air bluffs that took the line. AA overpair is way ahead of pairs and air; behind only sets/two-pair (rare).' `
    'BB flop call with AA (sometimes flat to mask range) on J-T-5 with backdoor was natural. Turn 2 brick keeps the spot strong for AA.' `
    'AhAd has overpair to all of J-T-5-2. Loses to JJ/TT/55 sets (rare flop call combos for BTN-barrel range). Beats Jx, Tx, all draws, all air.' `
    'Small check-raise charges Jx + Tx + draws (still alive on river: many straight + flush completions). Big raise risks too much vs sets.' `
    'Slowplaying AA on draw-heavy texture surrenders value to villain who pays off raises with worse pairs.' `
    'Overpair on draw-heavy brick turn = check-raise small for protection.') `
  -conceptTags @('turn_check_raise_value','second_barrel_defense','turn_blocker_pressure') `
  -difficulty 4 `
  -uniquenessNote 'Protection-raise on polar brick after dynamic flop. Distinct from family 7 AA-on-Q73-paired because here the BOARD is dynamic (many draws live to river) rather than paired -- the urgency to charge value comes from runout rather than counterfeit.'

# 10.2 -- 9c9d underpair on dynamic brick - mixed (MIXED #2)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_JdTd5s_2c_m4_action_9c9d_v430C' `
  -board $f10 -heroHand @('9c','9d') `
  -handClass 'underpair' -heroHandRole 'marginal_made_hand' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'mixed' -actionReason 'mixed_indifference_turn' `
  -question (Q-Action '9c 9d' $f10Str '2c') `
  -answer (New-Answer 'mixed' @('call','fold') @('check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Pocket 99 underpair on draw-heavy brick turn -- mixed call/fold (genuine indifference).' `
    '2c is a brick. Hero 99 is underpair to J and T (both on board). Vs villain barrel range that contains polar value (Jx/Tx/sets) + air, hero is bluff-catcher BUT close to threshold given many bluffs are also gutshots/FDs that have real equity.' `
    'BB flop call with 99 vs BTN small c-bet on J-T-5 (sometimes flat with underpair to bluff-catch). Turn 2 brick keeps the spot exactly the same.' `
    '99 has 5 outs to set + beats villain pure air. Calling captures bluffs; folding avoids paying off Jx/Tx. The math is split.' `
    'Pure call vs over-bluffy villain; pure fold vs nitty villain. True indifference vs balanced barrel.' `
    'Marking either call or fold as critical here over-confident -- it is a real mixed spot.' `
    'Underpair on draw-heavy brick turn = mixed call/fold.') `
  -conceptTags @('turn_pot_odds','turn_bluff_catcher','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'MIXED-action #2 with pocket 99 on a draw-heavy brick. Distinct from family 1 99 (A-high brick) and family 5 AA (BB-favored polar) because here the board is DRAW-HEAVY brick where villain bluff range has equity, not pure air -- different mixed-frequency math.'


# ====== Output ======

$out = [PSCustomObject]([ordered]@{
  moduleId         = 'pf_turn_barrel_oop_def'
  moduleName       = 'Facing Turn Barrel OOP'
  version          = 'v4.3.0C'
  status           = 'planning_only'
  schemaVersion    = '1.2.0'
  generatedAt      = (Get-Date -Format 'yyyy-MM-dd')
  expansionStats   = [PSCustomObject]@{
    expansionTarget         = 'M4 production: 24 -> 24+expansion_count'
    finalProductionTarget   = '52 (24 baseline + 28 new)'
    coverageGapsAddressed   = @('mixed_action: 0 -> 3','check_raise_big: 0 -> 2','pot_odds_turn_call: 0 -> 4','domination_turn_fold: 0 -> 3','semi_bluff_check_raise_turn: 0 -> 2','mixed_indifference_turn: 0 -> 3')
    sourceConfidenceMix     = 'all expert_judgment (no overclaims)'
  }
  notes            = 'v4.3.0C expansion seed candidates. ALL auditStatus=planning_only and reviewStatus=v4.3.0C_expansion_candidate; promoted to production via tools/migrate-module4-v4.3.0C.ps1 with two-phase staged approval (review_pending then approved).'
  scenarios        = $scenarios
})

# Atomic write via tmp + Move-Item (no Invoke-Expression, no Remove-Item on production)
$jsonText = $out | ConvertTo-Json -Depth 100
$tmpPath = "$outPath.tmp"
[System.IO.File]::WriteAllText($tmpPath, $jsonText, $utf8nb)
Move-Item -LiteralPath $tmpPath -Destination $outPath -Force

Write-Host ""
Write-Host "Total scenarios authored: $($scenarios.Count)" -ForegroundColor Cyan
Write-Host "Wrote: $outPath" -ForegroundColor Cyan
Write-Host "Size: $((Get-Item $outPath).Length) bytes"
