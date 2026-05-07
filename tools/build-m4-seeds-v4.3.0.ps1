# tools/build-m4-seeds-v4.3.0.ps1
# v4.3.0 - Module 4 Turn Defense OOP seed builder.
#
# Authors 24 planning-only seed scenarios across 6 turn categories
# (4 each) and writes them to
# docs/specs/postflop-v4.3.0-module4-seed-scenarios.json.
#
# auditStatus = planning_only
# reviewStatus = v4.3.0_seed_candidate
#
# ASCII-only (no em-dash, no approx symbol) to avoid CP874 mojibake
# during PowerShell script parsing.

$ErrorActionPreference = 'Stop'
$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$outPath  = Join-Path $repoRoot 'docs\specs\postflop-v4.3.0-module4-seed-scenarios.json'

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
    reviewStatus      = 'v4.3.0_seed_candidate'
    uniquenessNote    = $uniquenessNote
  })
}
function Q-Action($hero, $boardStr, $turn) {
  # NOTE: ${hero} braces are required because '$hero?' parses as a single
  # variable name 'hero?' in PowerShell (the '?' is a valid name character),
  # which silently expands to empty. v4.3.0-preA fix.
  return New-Question 'action_choice' "Flop $boardStr; turn $turn. BTN c-bet small flop, BB called, BTN now barrels. What is BB's best action with ${hero}?" $actionChoices
}
function Q-Reason($action, $hero, $boardStr, $turn) {
  return New-Question 'reason_choice' "Flop $boardStr; turn $turn. BB $action with $hero vs BTN's turn barrel. What is the primary reason?" $reasonChoices
}
function BoardStr($cards) { return ($cards -join ' ') }


# ====== Boards ======

# Cat 1: Brick turn after dry A-high flop
$b1Flop = @('As','8d','3h'); $b1Turn = '2c'
$b1 = New-Board $b1Flop $b1Turn 'A_high' 'A_high' 'rainbow' 'rainbow' @('dry','disconnected') 'brick' 'brick' 'neutral' 'none' 'no_change'
$b1Str = BoardStr $b1Flop

# Cat 2: Overcard turn after mid-board flop
$b2Flop = @('9d','8c','6h'); $b2Turn = 'Kc'
$b2 = New-Board $b2Flop $b2Turn 'low' 'K_high' 'rainbow' 'two_tone' @('wet','semi_connected') 'overcard' 'range_shift_btn' 'favors_btn' 'none' 'no_change'
$b2Str = BoardStr $b2Flop

# Cat 3: Flush-completing turn
$b3Flop = @('Ks','8s','3d'); $b3Turn = '2s'
$b3 = New-Board $b3Flop $b3Turn 'K_high' 'K_high' 'two_tone' 'monotone' @('wet','disconnected') 'flush_complete' 'polarizing' 'completes_bb_draws' 'flush_completed' 'no_change'
$b3Str = BoardStr $b3Flop

# Cat 4: Straight-completing turn
$b4Flop = @('Qs','Ts','6d'); $b4Turn = 'Jc'
$b4 = New-Board $b4Flop $b4Turn 'Q_high' 'Q_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'straight_complete' 'polarizing' 'completes_bb_draws' 'straight_completed' 'no_change'
$b4Str = BoardStr $b4Flop

# Cat 5: Board-pairing turn (paired flop, turn pairs second card)
$b5Flop = @('8c','8d','3s'); $b5Turn = '3h'
$b5 = New-Board $b5Flop $b5Turn 'low' 'low' 'rainbow' 'rainbow' @('dry','paired') 'board_pair' 'counterfeit' 'counterfeits_bb_pairs' 'none' 'flop_card_paired'
$b5Str = BoardStr $b5Flop

# Cat 6: Dynamic blank / draw-intensifier
$b6Flop = @('Ts','9s','5d'); $b6Turn = '6h'
$b6 = New-Board $b6Flop $b6Turn 'T_high' 'T_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'draw_intensifier' 'draw_added' 'improves_bb_draws' 'oesd_added' 'no_change'
$b6Str = BoardStr $b6Flop


# ====== Scenarios ======

$scenarios = @()

# ---- Cat 1: Brick turn after dry A-high flop (As 8d 3h, 2c) ----

# 1.1 - mid pair + BDFD that didn't complete; bluff-catch close; best=fold (small barrel)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_As8d3h_2c_m4_action_Th8h_v430' `
  -board $b1 -heroHand @('Th','8h') `
  -handClass 'mid_pair' -heroHandRole 'dominated_marginal' -drawCategory 'backdoor_only' -showdownValue 'low' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_turn_fold' `
  -question (Q-Action 'Th 8h' $b1Str '2c') `
  -answer (New-Answer 'fold' @('call') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Mid pair on dry A-high after brick turn -- fold; range disadvantage compounds.' `
    'The 2c is a brick: no draws complete, no overcards arrive. BTN barrel range narrows to A-x value + a few bluffs. Mid pair is below threshold.' `
    'After BB called the flop and BTN bets again, BTN is signaling stronger A-x or strong bluffs with backdoors that picked up. Brick 2c removes the bluffs that needed equity.' `
    'Th8h has middle pair only; no flush draw equity (heart BDFD was alive on flop, 2c kills it).' `
    'Folding is correct vs typical small barrel; calling vs over-bluffy villain is acceptable as exploit.' `
    'Stationing mid pair on bricked turns vs BTN A-high range bleeds chips.' `
    'Mid pair bricked turn on range-disadvantaged board = fold.') `
  -conceptTags @('turn_range_disadvantage','turn_pot_odds','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Brick turn after dry A-high flop: mid pair fold lesson. Tests recognition that brick turns favor BTN barrel range narrowing toward stronger A-x.'

# 1.2 - TPGK bluff-catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_As8d3h_2c_m4_action_AdQd_v430' `
  -board $b1 -heroHand @('Ad','Qd') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'backdoor_only' -showdownValue 'high' `
  -blockerNote 'Q kicker beats 80% of villain TPx (AT/AJ/A9 etc.); A blocker reduces villain AA value combos.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action 'Ad Qd' $b1Str '2c') `
  -answer (New-Answer 'call' @() @('fold','mixed','check_raise_small','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'TPGK on dry A-high brick turn -- call to bluff-catch barrel range.' `
    '2c brick keeps ranges static. BTN barrel still contains AK/AQ/AJ value + some semi-bluff air; AQ beats most of the air bucket.' `
    'BB flatted preflop with AQ; flop call was easy. Turn call captures villain bluffs without bloating vs AK.' `
    'AdQd has TPGK + backdoor diamond + A blocker on AA. Strong continue.' `
    'Calling preserves villain bluffs; raising folds them out and isolates AK.' `
    'Folding TPGK on dry brick turns over-folds vs villain bluff frequency.' `
    'TPGK on dry brick = call (do not fold and do not raise).') `
  -conceptTags @('turn_bluff_catcher','second_barrel_defense','turn_pot_odds') `
  -difficulty 3 `
  -uniquenessNote 'TPGK call lesson on brick turn. Distinct from M3 because BB has now committed an extra street; the call equity calculus differs from flop bluff-catch.'

# 1.3 - flopped set, slowplay reason_choice
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_As8d3h_2c_m4_reason_8c8h_v430' `
  -board $b1 -heroHand @('8c','8h') `
  -handClass 'set' -heroHandRole 'slowplay_trap' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Hero blocks 88 cooler combos (only one 8 left in deck).' `
  -recommendedAction 'call' -actionReason 'slowplay_turn_call' `
  -question (Q-Reason 'calls' '8c 8h' $b1Str '2c') `
  -answer (New-Answer 'slowplay_turn_call' @('value_check_raise_turn') @('bluff_catch_turn','equity_realization_turn_call','board_change_fold','domination_turn_fold','range_disadvantage_turn_fold','protection_check_raise_turn','semi_bluff_check_raise_turn','blocker_check_raise_turn','mixed_indifference_turn','pot_odds_turn_call') @()) `
  -explanation (New-Explanation `
    'Set of 8s on dry A-high brick turn -- slowplay to keep villain bluff range alive.' `
    '2c brick means AA/AK/AQ/AJ value range stays largely the same; BTN-air-with-equity dies. Slowplay collects barrel chips.' `
    'BB flat-called the flop with 88 (set). On brick turn, value check-raise folds out the bluffs that pay off river barrels.' `
    'Set of 8s loses only to AA (improbable here as raise pre would be common); has near-100% equity vs barrel range.' `
    'Calling lets BTN keep firing river. Raising small is acceptable to charge AK/AQ but loses river barrel value.' `
    'Auto-raising flopped set on brick turns folds out the wide bluff bucket.' `
    'Set on brick turn = slowplay call by default; small raise acceptable.') `
  -conceptTags @('turn_slowplay_call','second_barrel_defense','turn_check_raise_value') `
  -difficulty 4 `
  -uniquenessNote 'Reason_choice testing slowplay vs raise distinction on brick turn. Tests recognition that brick turns reduce villain equity bluff range -- slowplay > raise.'

# 1.4 - bricked float, fold critical
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_As8d3h_2c_m4_action_JsTh_v430' `
  -board $b1 -heroHand @('Js','Th') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'board_change_fold' `
  -question (Q-Action 'Js Th' $b1Str '2c') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'JT no draw after brick turn -- fold; no equity, no path forward.' `
    '2c brick kills any backdoor draw JT had on the flop (no spade/club shared). Hero is now drawing dead vs Ax value.' `
    'BB flop float with JT was thin; brick turn turns it into pure giveaway.' `
    'JsTh has no pair, no draw, no flush blocker; 6 overcard outs that often pair villain kicker.' `
    'Folding is automatic; calling commits chips with zero equity into A-x heavy range.' `
    'Continuing turn floats with no equity is the most expensive postflop leak.' `
    'Bricked float = fold (do not call to "see one more card").') `
  -conceptTags @('turn_board_change','turn_range_disadvantage','second_barrel_defense') `
  -difficulty 2 `
  -uniquenessNote 'CRITICAL teaching: bricked float fold. Distinct lesson: turn brick removes the only equity (backdoor) the float had; calling is uniquely worst.'


# ---- Cat 2: Overcard turn (9d 8c 6h, Kc) ----

# 2.1 - top set on flop, K overcard, slowplay vs raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9d8c6h_Kc_m4_action_9c9s_v430' `
  -board $b2 -heroHand @('9c','9s') `
  -handClass 'set' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'protection_check_raise_turn' `
  -question (Q-Action '9c 9s' $b2Str 'Kc') `
  -answer (New-Answer 'check_raise_small' @('check_raise_big','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Top set 9s on K-overcard turn -- raise for value AND protection.' `
    'Kc overcard SHIFTS range advantage to BTN (more K-x value combos), but top set still way ahead. Many turns next street kill action; raise now while villain has K-x to call.' `
    'BB flopped middle set; turn K turns it into still-strong but no longer top set. Villain now has Kx + KK / TT / JJ / QQ / sets / straights more weighted.' `
    '99 makes set on 9-8-6; Kc only beats us in Kx hands which we mostly want to charge. Loses only to KK, sets above (rare), straight (T7, 75 rare).' `
    'Small raise charges Kx; big raise also viable on dynamic turns.' `
    'Slowplaying flopped set on overcard turn surrenders value vs Kx that pays off raise.' `
    'Top set on overcard turn = raise (protection + value); call also fine.') `
  -conceptTags @('turn_check_raise_value','turn_equity_shift','turn_board_change') `
  -difficulty 3 `
  -uniquenessNote 'Overcard turn protection-raise lesson with set. Tests that overcard turn shifts range but does not eliminate top-set value -- raise > slowplay because Kx now exists to charge.'

# 2.2 - made nut straight on K-overcard turn, value check-raise
# v4.3.0-preA fix: Tc7c on 9d 8c 6h ALREADY makes the nut straight (6-7-8-9-T)
# on the flop. Reclassified from OESD/semi-bluff to nut_straight/value_raise.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9d8c6h_Kc_m4_reason_Tc7c_v430' `
  -board $b2 -heroHand @('Tc','7c') `
  -handClass 'straight' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Hero made nut straight 6-7-8-9-T on the flop. Tc adds bonus club FD redraw on river clubs.' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Reason 'check-raises small' 'Tc 7c' $b2Str 'Kc') `
  -answer (New-Answer 'value_check_raise_turn' @('equity_realization_turn_call','slowplay_turn_call') @('semi_bluff_check_raise_turn','protection_check_raise_turn','blocker_check_raise_turn','bluff_catch_turn','board_change_fold','domination_turn_fold','range_disadvantage_turn_fold','mixed_indifference_turn','pot_odds_turn_call') @()) `
  -explanation (New-Explanation `
    'Made nut straight on K-overcard turn -- value check-raise.' `
    'Kc turn does not change Tc7c equity -- hero already made the nut straight 6-7-8-9-T on the flop. Villain barrel range heavy in Kx pair-types is dominated; raising extracts value.' `
    'BB flop call with T7s landed the nut straight on flop; Kc adds Kx hands to villain barrel range, all of which are dominated by hero straight.' `
    'Tc7c has the nut straight (6-7-8-9-T) plus a club FD redraw (4 clubs vs 1 needed on river).' `
    'Small check-raise extracts value from Kx and protects against runout pairing the board to give villain a higher straight or boat draw.' `
    'Identifying as semi-bluff misses that hero ALREADY has the made nut straight; raise mechanism is value, not fold equity.' `
    'Made nut straight on overcard turn = value check-raise vs Kx-heavy barrel range.') `
  -conceptTags @('turn_check_raise_value','turn_equity_shift','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Reason_choice testing value_check_raise_turn on a made nut straight vs other raise reasons. Tests that nut made hand drives value raise, not bluff/protection/blocker (note: T7 makes 6-7-8-9-T straight already on the flop).'

# 2.3 - middle pair on overcard turn, fold lesson
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9d8c6h_Kc_m4_action_9h7h_v430' `
  -board $b2 -heroHand @('9h','7h') `
  -handClass 'mid_pair' -heroHandRole 'dominated_marginal' -drawCategory 'gutshot' -showdownValue 'decent' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'board_change_fold' `
  -question (Q-Action '9h 7h' $b2Str 'Kc') `
  -answer (New-Answer 'fold' @('call') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Mid pair 9 weak kicker on K-overcard turn -- fold; range advantage shifted hard.' `
    'Kc overcard means BTN now has every K-x in barrel range, including KQ/KJ/AK; hero 9-pair (now middle pair below the K) drops below the bluff-catch threshold.' `
    'BB flop call with top-pair-9 + gutshot was fine on the flop; turn K shifts range hard and demotes 9-pair from top pair to middle pair.' `
    '9h7h had top pair 9 on the flop, but after the K turn the 9 is middle pair. K barrel range turns this into a clear underdog vs Kx-anchored value.' `
    'Folding closes action; calling chases dominated outs into K-x heavy range.' `
    'Stationing top-pair-weak-kicker on overcard turns is the prototypical M4 leak.' `
    'Top pair on overcard turn that brings villain range advantage = fold.') `
  -conceptTags @('turn_board_change','turn_domination_fold','turn_range_disadvantage') `
  -difficulty 3 `
  -uniquenessNote 'Overcard turn board-change-fold lesson. Distinct from brick-turn fold because the trigger is the K turn shifting villain range rather than equity simply not existing.'

# 2.4 - naked overcards no equity, critical fold
# v4.3.0-preA fix: AdJs on 9d 8c 6h Kc has NO straight draw -- T alone does
# not complete a straight (would need 7-T or T-Q or Q-T-something to make
# 5 consecutive, but hero only has J + board 9-8-6-K). Reclassified from
# gutshot to no_pair_no_draw / pure overcards.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9d8c6h_Kc_m4_action_AdJs_v430' `
  -board $b2 -heroHand @('Ad','Js') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_turn_fold' `
  -question (Q-Action 'Ad Js' $b2Str 'Kc') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'AJ no pair no draw on K-overcard turn -- fold; six overcards are mostly dominated.' `
    'Kc turn does not help AdJs at all -- hero misses every flop card and has no straight or flush draw. Villain barrel range is range-advantaged + nut-advantaged on this runout.' `
    'BB flop call with AdJs on 9d 8c 6h was already thin (overcards only, no draw). Turn K shifts range hard to villain Kx.' `
    'AdJs has no pair, no draw. Six overcard outs (3 aces + 3 jacks) but villain Kx range dominates Jx and many Ax pair outs lose to better Kings.' `
    'Folding closes action and saves chips; raising as a bluff has near-zero fold equity vs Kx-anchored barrel range.' `
    'Calling AJ on overcard turns hoping to hit one of six outs ignores the mostly-dominated reality and burns chips.' `
    'Naked overcards with no draw on overcard turn = fold; raise with no fold equity is a punt.') `
  -conceptTags @('turn_range_disadvantage','turn_domination_fold','turn_board_change') `
  -difficulty 3 `
  -uniquenessNote 'CRITICAL teaching: naked overcards + no draw fold on overcard turn. Distinct from 2.3 (top-pair-weak-kicker fold) because here hero has zero made-hand value and overcard outs are dominated; tests that overcard equity alone does not rescue range disadvantage.'


# ---- Cat 3: Flush-completing turn (Ks 8s 3d, 2s) ----

# 3.1 - made low flush, bluff-catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ks8s3d_2s_m4_action_6s5s_v430' `
  -board $b3 -heroHand @('6s','5s') `
  -handClass 'flush' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action '6s 5s' $b3Str '2s') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'Made low flush on flush-completing turn -- call; raising bloats vs higher flushes.' `
    '2s completes flush; BTN barrel range now contains AsX/QsX higher flushes + air with no spade.' `
    'BB flopped low flush draw + small straight draw, called flop. Turn 2s makes flush; raising commits vs Ax-of-spades.' `
    '6s5s has made 6-high flush; only 1 card on river remaining so no further straight redraws apply.' `
    'Calling captures villain air-bluffs without bloating vs nut flush. Small raise occasionally to charge worse flushes.' `
    'Auto-raising any flush on monotone turns commits OOP into nut-flush range.' `
    'Made low flush on flush-complete turn = call (raise small as alt; never big).') `
  -conceptTags @('turn_bluff_catcher','turn_draw_completion','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'Made low flush bluff-catch lesson on flush-complete turn. Tests not over-bloating with non-nut flush vs villain Ax-of-suit.'

# 3.2 - TPTK + nut flush blocker, call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ks8s3d_2s_m4_action_AsKd_v430' `
  -board $b3 -heroHand @('As','Kd') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'nut_flush_draw' -showdownValue 'high' `
  -blockerNote 'As is the nut-flush card; blocks every Ax-of-spades flush combo in BTN range.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action 'As Kd' $b3Str '2s') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'TPTK with nut-flush blocker on flush-complete turn -- call; nut blocker turns this into bluff-catcher.' `
    '2s completes flush; As blocks nut-flush combos and reduces villain barrel value range.' `
    'BB flat with AK pre, flop call with TPTK was easy. Turn flush threat looks scary, but As blocker = villain has no nut flush.' `
    'AsKd has TPTK + As nut FD blocker + 2nd-nut redraw potential.' `
    'Calling captures villain air; raising acceptable to charge K-flush combos but bloats OOP.' `
    'Folding TPTK on flush-complete turns when holding the As blocker over-folds vs villain barrel range.' `
    'TPTK + nut-flush blocker on flush-complete turn = call (do not fold).') `
  -conceptTags @('turn_bluff_catcher','turn_blocker_pressure','turn_draw_completion') `
  -difficulty 3 `
  -uniquenessNote 'TPTK + nut blocker bluff-catch lesson on flush-complete turn. Tests recognition that nut blocker turns scary turn into call spot.'

# 3.3 - nut spade blocker, blocker check-raise reason
# v4.3.0-preA fix: replaced AhJs with AsJd. AhJs has heart Ace (not the nut
# spade blocker) and Js is one spade (not the nut FD; needs As of clubs/etc.).
# AsJd holds the actual nut spade blocker (As) without making the flush itself.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ks8s3d_2s_m4_reason_AsJd_v430' `
  -board $b3 -heroHand @('As','Jd') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'nut_flush_draw' -showdownValue 'low' `
  -blockerNote 'As is the nut-spade blocker AND gives hero the nut flush draw on river spades; hero removes every Ax-spade nut-flush combo from villain barrel range while retaining nut-flush redraw equity.' `
  -recommendedAction 'check_raise_small' -actionReason 'blocker_check_raise_turn' `
  -question (Q-Reason 'check-raises small' 'As Jd' $b3Str '2s') `
  -answer (New-Answer 'blocker_check_raise_turn' @() @('equity_realization_turn_call','semi_bluff_check_raise_turn','value_check_raise_turn','protection_check_raise_turn','bluff_catch_turn','board_change_fold','domination_turn_fold','range_disadvantage_turn_fold','slowplay_turn_call','mixed_indifference_turn','pot_odds_turn_call') @()) `
  -explanation (New-Explanation `
    'Nut spade blocker + nut FD redraw on flush-complete turn -- blocker check-raise (advanced; solver mixes).' `
    '2s completes flush; As is the nut spade blocker (removes Ax-spade nut-flush combos) AND gives hero a nut-flush redraw on river spades. The raise mechanism is primarily blocker pressure, with nut-FD redraw as a secondary backup.' `
    'BB flop call with AsJd was natural (broadway high cards, A-blocker presence). Turn 2s makes the line a leveraged blocker check-raise with nut-flush redraw.' `
    'AsJd has no current made hand or pair, but As provides (a) the nut spade blocker against villain Ax-spade combos, and (b) a nut flush redraw if river is a spade.' `
    'Small check-raise size leverages the nut blocker; large raise risks too much when called by lower flushes.' `
    'Identifying as semi-bluff misses that the primary raise mechanism is the nut-spade blocker (the FD redraw is secondary backup, not the trigger). Identifying as value misses that hero has no made hand.' `
    'Nut spade blocker + nut FD on flush-complete turn = blocker check-raise (advanced; mix-frequency line).') `
  -conceptTags @('turn_check_raise_bluff','turn_blocker_pressure','turn_draw_completion') `
  -difficulty 5 `
  -uniquenessNote 'Reason_choice testing blocker_check_raise_turn vs semi_bluff_check_raise_turn. Tests that the PRIMARY raise mechanism on flush-complete turn with As is blocker pressure -- the nut FD redraw is secondary backup, not the trigger. Distinct from 3.2 because hero is bluff-catching with TPTK there; here hero has no made hand and the raise is leveraged purely on the As blocker plus nut-FD redraw.'

# 3.4 - no spade no equity on flush turn, critical fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ks8s3d_2s_m4_action_Tc9c_v430' `
  -board $b3 -heroHand @('Tc','9c') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'board_change_fold' `
  -question (Q-Action 'Tc 9c' $b3Str '2s') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'No spade no draw on flush-complete turn -- fold; zero flush equity and dominated overcards.' `
    '2s completes flush; without a spade, hero has no flush threat and faces a polarized barrel range (flushes + air-with-no-spade).' `
    'BB flop call with T9 on K-high two-tone was already thin (overcards + backdoor potential only). Turn 2s eliminates the runner-runner equity and adds a flush hero cannot make.' `
    'Tc9c has no spade, no pair, no current draw. Any straight would require Q+J on the runout (5-card 9-T-J-Q-K needs both Q and J), but only one card remains, so no straight is achievable. Pure give-up.' `
    'Folding closes action; calling on flush turn with zero flush equity is uniquely worst.' `
    'Continuing turn with no spade on flush-completing turns is the prototypical leak.' `
    'No spade + no draw on flush turn = fold.') `
  -conceptTags @('turn_board_change','turn_range_disadvantage','turn_draw_completion') `
  -difficulty 2 `
  -uniquenessNote 'CRITICAL teaching: no-spade fold on flush-complete turn. Distinct lesson: turn polarization eliminates equity for hands without flush card.'


# ---- Cat 4: Straight-completing turn (Qs Ts 6d, Jc) ----

# 4.1 - made straight with 98s, value raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_QsTs6d_Jc_m4_action_9c8h_v430' `
  -board $b4 -heroHand @('9c','8h') `
  -handClass 'straight' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action '9c 8h' $b4Str 'Jc') `
  -answer (New-Answer 'check_raise_small' @('check_raise_big','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    '8-9-T-J-Q straight on straight-complete turn -- raise for value.' `
    'Jc completes straight for 98 / KT / 89; BB flop call range with OESD + flush draws hits this turn hard. Range advantage swings to BB.' `
    'BB flop call with 98 (open-ender + flush draw) was strong; turn J makes straight. Villain barrel range still has Q-x / overpairs / TPTK that pay off raise.' `
    '98 makes 8-9-T-J-Q straight; only KT/T9 (not possible with 9 in hand) and KQ-flushes beat us (rare).' `
    'Small raise gets called by Q-x and overpairs; big raise also defensible vs nut-flush combos.' `
    'Slowplaying turned straight on straight-complete turn surrenders huge value vs villain barrel range.' `
    'Made straight on straight-complete turn = raise for value.') `
  -conceptTags @('turn_check_raise_value','turn_draw_completion','turn_equity_shift') `
  -difficulty 3 `
  -uniquenessNote 'Made straight value-raise on straight-complete turn. Distinct from set-on-overcard lesson because hero hits the turn while villain range does not improve.'

# 4.2 - top pair + OESD bluff-catch / call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_QsTs6d_Jc_m4_action_KhQh_v430' `
  -board $b4 -heroHand @('Kh','Qh') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'oesd' -showdownValue 'high' `
  -blockerNote 'K blocks K-high straight combos KT/K9; hero card is part of multiple straight structures.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action 'Kh Qh' $b4Str 'Jc') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'TPGK + OESD redraw to Broadway on straight-complete turn -- call.' `
    'Jc completes some lower straights but BB Q-x with redraw remains strong. Hero KhQh now has top pair (Q) plus an open-ended straight redraw: hero+board form T-J-Q-K (4 consecutive ranks), so 9 completes 9-T-J-Q-K and A completes Broadway T-J-Q-K-A. ~8 outs to a higher straight, with A giving the nut.' `
    'BB flop call with KQ on QT6 was natural (TPGK + backdoor). Turn J adds an OESD redraw to a higher straight.' `
    'KhQh has TPGK + OESD redraw to higher straight (9 makes 9-T-J-Q-K, A makes Broadway T-J-Q-K-A).' `
    'Calling captures villain air-bluffs + leaves the OESD redraw alive. Small raise also acceptable.' `
    'Folding TPGK + OESD redraw vs straight-complete turn over-folds vs villain barrel.' `
    'TPGK + OESD redraw to higher straight on straight-complete turn = call.') `
  -conceptTags @('turn_bluff_catcher','turn_draw_completion','turn_blocker_pressure') `
  -difficulty 4 `
  -uniquenessNote 'TPGK + nut-redraw call lesson on straight-complete turn. Tests recognition that own pair + redraw to higher straight beats villain weaker top pair barrels.'

# 4.3 - close call/fold reason_choice with T9 + double-gutshot
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_QsTs6d_Jc_m4_reason_Tc9d_v430' `
  -board $b4 -heroHand @('Tc','9d') `
  -handClass 'mid_pair' -heroHandRole 'marginal_made_hand' -drawCategory 'oesd' -showdownValue 'decent' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'equity_realization_turn_call' `
  -question (Q-Reason 'calls' 'Tc 9d' $b4Str 'Jc') `
  -answer (New-Answer 'equity_realization_turn_call' @('bluff_catch_turn','pot_odds_turn_call') @('value_check_raise_turn','protection_check_raise_turn','semi_bluff_check_raise_turn','blocker_check_raise_turn','board_change_fold','domination_turn_fold','range_disadvantage_turn_fold','slowplay_turn_call','mixed_indifference_turn') @()) `
  -explanation (New-Explanation `
    'T9 with double-gutshot + middle pair on straight-complete turn -- call to realize equity.' `
    'Jc completes some straights but T9 still has equity: pair of T + double-gutshot to 8 (8-9-T-J-Q) and K (9-T-J-Q-K).' `
    'BB flop call with mid pair + gutshot was thin; turn J adds OE redraw potential.' `
    'Tc9d has middle pair (T) + 8 outs to straight (need 8 for 8-9-T-J-Q or K for 9-T-J-Q-K).' `
    'Calling realizes the multi-source equity at minimum cost. Raising too thin OOP without made hand stronger.' `
    'Folding the double-gutshot + pair under-defends vs villain barrel range that has air.' `
    'Pair + double-gutshot on straight-complete turn = call; raise too thin.') `
  -conceptTags @('turn_pot_odds','turn_bluff_catcher','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'Reason_choice testing equity_realization_turn_call vs bluff_catch_turn vs pot_odds_turn_call. Tests learner can distinguish "call to realize equity" from pure bluff-catch.'

# 4.4 - 54 nothing, fold critical
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_QsTs6d_Jc_m4_action_5h4d_v430' `
  -board $b4 -heroHand @('5h','4d') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'board_change_fold' `
  -question (Q-Action '5h 4d' $b4Str 'Jc') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    '54 no pair no draw on straight-complete turn -- fold; bottom-of-flop range has no equity post-J.' `
    'Jc completes higher straights for villain barrel range (KT/89 etc.); 54 had backdoor potential on flop, killed by J.' `
    'BB flop call with 54 on Q-T-6 two-tone was thin (gutshot to 7 for 4-5-6-7-8 only); turn J kills it.' `
    '5h4d has no pair, no draw, no blocker; backdoor that died on the J.' `
    'Folding closes action; calling commits with zero equity.' `
    'Continuing weak floats through straight-completing turns is uniquely worst.' `
    'Bricked low float on straight turn = fold.') `
  -conceptTags @('turn_board_change','turn_range_disadvantage','turn_draw_completion') `
  -difficulty 2 `
  -uniquenessNote 'CRITICAL teaching: bricked float on straight-complete turn. Distinct from 1.4 because the trigger here is a draw-completing turn that crushes BB low-end range, not a brick.'


# ---- Cat 5: Board-pairing turn (8c 8d 3s, 3h) ----

# 5.1 - full house slowplay
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_8c8d3s_3h_m4_action_Ah3d_v430' `
  -board $b5 -heroHand @('Ah','3d') `
  -handClass 'full_house' -heroHandRole 'slowplay_trap' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'slowplay_turn_call' `
  -question (Q-Action 'Ah 3d' $b5Str '3h') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'Trip 3 paired turn = full house (3s full of 8s) -- slowplay; bluff range alive.' `
    '3h pairs the 3 making BB trips into full house. BTN barrel range now contains overpairs / Ax-air / 88 (rare boats).' `
    'BB flop call with A3o (likely thin float pre but consistent) -- turn 3 makes full house.' `
    'Ah3d has full house 3s over 8s; only 88 (improbable) beats. Loses nothing on river.' `
    'Calling preserves villain bluffs for river barrel; raising folds out air.' `
    'Auto-raising boat on paired-paired turns folds bluffs that would barrel river.' `
    'Full house on board-pairing turn = slowplay (do not raise).') `
  -conceptTags @('turn_slowplay_call','turn_board_change','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'Full house slowplay on double-paired turn. Distinct lesson: turn pair makes monster, but villain range now has fewer drawing hands and many bluffs that would barrel river.'

# 5.2 - underpair counterfeited bluff-catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_8c8d3s_3h_m4_action_5h5d_v430' `
  -board $b5 -heroHand @('5h','5d') `
  -handClass 'underpair' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action '5h 5d' $b5Str '3h') `
  -answer (New-Answer 'call' @() @('fold','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Pocket 5s on double-paired turn -- bluff-catch; pair beats air despite counterfeit risk.' `
    '3h pairs board so hero plays 8-8-3-3 + 5 = two pair with 5 kicker. Counterfeited overpair to 3 but still beats every air-barrel.' `
    'BB flop call with 55 on 88-3 was bluff-catch territory; turn 3 keeps bluff catcher status (pair of 5 kicker + board two pair).' `
    '5h5d has pocket fives; final hand 8-8-3-3-5 beats all air, loses to 88 / overpairs / Ax with 3.' `
    'Calling captures villain air; raising folds bluffs and isolates better hands.' `
    'Folding small pocket pair on counterfeit-paired turns over-folds vs villain bluff-heavy range.' `
    'Counterfeited underpair on double-paired turn = call (do not fold to "scary turn").') `
  -conceptTags @('turn_bluff_catcher','turn_board_change','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Counterfeited underpair bluff-catch on board-pair turn. Distinct lesson: turn counterfeit looks scary but pair still beats air.'

# 5.3 - A-high blocker bluff-catch reason
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_8c8d3s_3h_m4_reason_AdKc_v430' `
  -board $b5 -heroHand @('Ad','Kc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote 'A and K block AA / KK overpair value combos.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Reason 'calls' 'Ad Kc' $b5Str '3h') `
  -answer (New-Answer 'bluff_catch_turn' @('pot_odds_turn_call','equity_realization_turn_call') @('value_check_raise_turn','protection_check_raise_turn','semi_bluff_check_raise_turn','blocker_check_raise_turn','board_change_fold','domination_turn_fold','range_disadvantage_turn_fold','slowplay_turn_call','mixed_indifference_turn') @()) `
  -explanation (New-Explanation `
    'AK no pair on double-paired turn -- bluff-catch; A blocks villain top of range.' `
    '3h double-pairs board; villain barrel range has overpairs + air. AK with Ace blocker beats all air.' `
    'BB flop call with AK on 88-3 was either thin float or blocker bet candidate. Turn 3 keeps bluff catch status.' `
    'AdKc has no pair, no draw, but A blocks AA top-of-range and 6 overcard outs (river A or K).' `
    'Calling captures bluffs; raising folds them out; folding under-defends.' `
    'Identifying as range_disadvantage_turn_fold misses the A-blocker bluff-catch line.' `
    'AK on counterfeit-paired turn = bluff-catch (call), not fold.') `
  -conceptTags @('turn_bluff_catcher','turn_blocker_pressure','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'Reason_choice testing bluff_catch_turn vs range_disadvantage_turn_fold. Tests learner recognizes A-blocker turns no-pair into bluff-catcher.'

# 5.4 - QJ no equity, fold critical
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_8c8d3s_3h_m4_action_QhJh_v430' `
  -board $b5 -heroHand @('Qh','Jh') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_turn_fold' `
  -question (Q-Action 'Qh Jh' $b5Str '3h') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'QJ no pair no draw on double-paired turn -- fold; no equity even on counterfeit board.' `
    '3h double-pairs board. QJ has 6 overcard outs but pair of Q or J still loses to overpairs / Ax with 3 / 88.' `
    'BB flop call with QJ on 88-3 was already thin (no pair, no draw, no relevant blocker); turn 3 keeps the situation bad.' `
    'QhJh has no pair, no draw, no blocker. 6 pair outs are dominated.' `
    'Folding closes action; calling chases dominated outs.' `
    'Floating QJ "because two overcards" on paired boards leaks chips.' `
    'Naked QJ on paired board after turn pair = fold.') `
  -conceptTags @('turn_range_disadvantage','turn_board_change','second_barrel_defense') `
  -difficulty 2 `
  -uniquenessNote 'CRITICAL teaching: naked QJ fold on counterfeit-paired turn. Distinct lesson: even paired boards have a defense floor; QJ no-blocker no-draw is below it.'


# ---- Cat 6: Dynamic blank / draw-intensifier (Ts 9s 5d, 6h) ----

# 6.1 - top set on dynamic, value/protection
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts9s5d_6h_m4_action_TcTd_v430' `
  -board $b6 -heroHand @('Tc','Td') `
  -handClass 'set' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'protection_check_raise_turn' `
  -question (Q-Action 'Tc Td' $b6Str '6h') `
  -answer (New-Answer 'check_raise_small' @('check_raise_big','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Top set T on draw-intensifier turn -- raise for protection AND value.' `
    '6h adds 7 + 8 to straight-completing rivers (5-6-7-8-9 or 6-7-8-9-T). Many rivers kill action; raise now charges draws.' `
    'BB flopped top set; turn 6 adds new straight draws to villain range (78s) and BB needs to charge.' `
    'TcTd makes top set; loses only to 99/55 sets and J-87 / 89 / 7-8 straights (rare flop call combos).' `
    'Small raise charges OE/gutshots without folding K-x air entirely; big raise also defensible.' `
    'Slowplaying top set on draw-heavy turns lets villain realize equity for free.' `
    'Top set on draw-intensifier turn = raise for protection.') `
  -conceptTags @('turn_check_raise_value','turn_equity_shift','turn_draw_completion') `
  -difficulty 3 `
  -uniquenessNote 'Top set protection-raise on draw-intensifier turn. Distinct from 2.1 because the trigger is new draws, not range shift; protection > slowplay.'

# 6.2 - turn straight, value
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts9s5d_6h_m4_action_8c7c_v430' `
  -board $b6 -heroHand @('8c','7c') `
  -handClass 'straight' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action '8c 7c' $b6Str '6h') `
  -answer (New-Answer 'check_raise_small' @('check_raise_big','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Made straight 6-7-8-9-T on draw-intensifier turn -- raise for value.' `
    '6h completes straight for 87/89; BB flop call with 87 OE was strong, turn 6 makes hand.' `
    'BB flopped strong combo (OE + flush draw); turn 6 makes nut straight on a dynamic board.' `
    '87 makes 6-7-8-9-T straight; only 8-7 (us) and J-x straight (J7-9 = 7-8-9-T-J needs J) compete (rare).' `
    'Small raise charges Tx + overpairs + draws; big raise defensible vs higher draws.' `
    'Slowplaying turned straight on draw-heavy turn lets villain realize equity.' `
    'Made straight on draw-intensifier turn = raise for value.') `
  -conceptTags @('turn_check_raise_value','turn_draw_completion','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Made-straight value-raise on draw-intensifier turn. Distinct from 4.1 because turn brings additional draws to villain range alongside straight completion.'

# 6.3 - combo (nut FD + pair + overcard) close call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts9s5d_6h_m4_action_As6s_v430' `
  -board $b6 -heroHand @('As','6s') `
  -handClass 'flush_draw' -heroHandRole 'combo_draw' -drawCategory 'nut_flush_draw' -showdownValue 'low' `
  -blockerNote 'As is the nut-flush blocker on spades.' `
  -recommendedAction 'call' -actionReason 'equity_realization_turn_call' `
  -question (Q-Action 'As 6s' $b6Str '6h') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Nut FD + pair of 6 + Ace overcard on draw-intensifier turn -- call to realize multi-source equity.' `
    '6h pairs hero turn card; nut FD still alive (4 spades visible: Ts, 9s, As, 6s -- 1 more spade on river makes nut flush). Hero now has pair of 6s plus the As overcard outs.' `
    'BB flopped nut FD + Ace overcard; turn 6 pairs hero (mid pair) and the board becomes more dynamic.' `
    'As6s has nut FD (~9 spade outs to nut flush) + pair of 6 (~5 outs to two-pair/trips) + 3 Ace overcard outs + nut spade blocker. Multi-source equity, ~50%+ to barrel range.' `
    'Calling realizes ~50% equity cheaply. Raising too thin OOP given turn deepens pot more than flop.' `
    'Folding combo equity OOP under-defends vs villain barrel.' `
    'Combo draw + pair on dynamic turn = call to realize equity.') `
  -conceptTags @('turn_pot_odds','turn_blocker_pressure','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'Combo-draw equity_realization_turn_call lesson on draw-intensifier turn. Tests that combo equity sources -> call > raise on deeper-pot turn street.'

# 6.4 - naked overcards no equity, fold critical
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts9s5d_6h_m4_reason_KhQd_v430' `
  -board $b6 -heroHand @('Kh','Qd') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'gutshot' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_turn_fold' `
  -question (Q-Reason 'folds' 'Kh Qd' $b6Str '6h') `
  -answer (New-Answer 'range_disadvantage_turn_fold' @('board_change_fold','domination_turn_fold') @('value_check_raise_turn','protection_check_raise_turn','semi_bluff_check_raise_turn','blocker_check_raise_turn','bluff_catch_turn','equity_realization_turn_call','slowplay_turn_call','mixed_indifference_turn','pot_odds_turn_call') @()) `
  -explanation (New-Explanation `
    'KQ no spade with weak gutshot on draw-intensifier turn -- fold; gutshot equity is dominated and there is no FD.' `
    '6h adds new draws to villain range; BB KhQd has no spade FD and only a 4-out gutshot to J for 9-T-J-Q-K, which is dominated by villain Tx made hands and AK ranges.' `
    'BB flop call with KQ on T-9-5 two-tone was thin (gutshot to J + backdoor potential). Turn 6h preserves the gutshot but adds villain draws and reduces relative equity.' `
    'KhQd has a 4-out gutshot to J (completes 9-T-J-Q-K) but no FD, no pair, no blocker. Pair outs (K or Q on river) are dominated by Kx/Qx in villain range.' `
    'Folding closes action cleanly; calling chases dominated outs.' `
    'Identifying as bluff_catch_turn misses that no pair / no FD / no blocker has no bluff-catch claim.' `
    'KQ no equity no blocker on dynamic turn = range_disadvantage fold (not bluff-catch).') `
  -conceptTags @('turn_range_disadvantage','turn_board_change','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'CRITICAL reason_choice teaching: distinguish range_disadvantage_turn_fold from bluff_catch_turn / board_change_fold. Tests reasoning chain on dynamic turn fold.'


# ====== Write seed JSON ======

$out = [ordered]@{
  schemaVersion  = '1.2.0'
  moduleId       = 'pf_turn_barrel_oop_def'
  moduleName     = 'Facing Turn Barrel OOP'
  version        = 'v4.3.0'
  status         = 'planning_only'
  generatedAt    = '2026-05-06'
  notes          = 'Planning seeds for Module 4 (BB Turn Defense OOP). 24 scenarios across 6 turn categories (4 each). NOT loaded at runtime. Migration to production scheduled for v4.3.1+ after seed strategic review (v4.3.0A).'
  expansionStats = [ordered]@{
    totalScenarios = $scenarios.Count
    categories     = 6
    perCategory    = 4
    actionChoice   = 18
    reasonChoice   = 6
  }
  scenarios = $scenarios
}

Write-Output ("Total scenarios authored: " + $scenarios.Count)
$json = $out | ConvertTo-Json -Depth 100
[System.IO.File]::WriteAllText($outPath, $json, [System.Text.UTF8Encoding]::new($false))
Write-Output "Wrote: $outPath"
Write-Output "Size: $((Get-Item $outPath).Length) bytes"
