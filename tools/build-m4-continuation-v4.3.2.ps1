# ============================================================
# tools/build-m4-continuation-v4.3.2.ps1
# v4.3.2 Module 4 Coverage Continuation -- canonical continuation builder
#
# Authors NEW v4.3.2 continuation seeds ONLY.
# Does NOT touch the original v4.3.0 builder, the v4.3.0C
# expansion builder, the v4.3.0D polish builder, or any
# pre-existing seed JSON.
#
# Output: docs/specs/postflop-v4.3.2-module4-continuation-seeds.json
#
# Source-of-truth rule:
#   - Original 24 reviewed M4 seeds      = v4.3.0  builder canonical.
#   - 29 v4.3.0C expansion seeds          = v4.3.0C builder canonical
#                                           (+ v4.3.0C1 hotfix on
#                                           7s6h + 9d6d).
#   - 19 v4.3.0D polish seeds             = v4.3.0D builder canonical.
#   - This continuation adds NEW scenarios for v4.3.2 coverage:
#     reason_choice depth boost (priority 1), blocker_check_raise
#     depth (priority 2), mixed depth (priority 3), one new
#     check_raise_big spot (priority 4), gap-fills across the
#     existing actionReason buckets, and one NEW board family F12
#     (low straight-complete-adjacent connector turn) plus one
#     NEW board family F13 (low overcard demote pattern).
#   - Continuation seeds + polish + expansion + original together
#     form the full M4 planning corpus.
#
# Safety:
#   - ASCII-only (no em-dash, no special unicode)
#   - No Invoke-Expression
#   - No Remove-Item on production-adjacent paths
#   - Atomic write via tmp + Move-Item to continuation JSON only
# ============================================================

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$outPath  = Join-Path $repoRoot 'docs\specs\postflop-v4.3.2-module4-continuation-seeds.json'

# ----------------------------------------------------------------
# Constants (mirror v4.3.0D builder shape)
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
# Helper builders
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
    reviewStatus      = 'v4.3.2_continuation_candidate'
    uniquenessNote    = $uniquenessNote
  })
}
function Q-Action($hero, $boardStr, $turn) {
  return New-Question 'action_choice' "Flop $boardStr; turn $turn. BTN c-bet small flop, BB called, BTN now barrels. What is BB's best action with ${hero}?" $actionChoices
}
function Q-Reason($action, $hero, $boardStr, $turn) {
  return New-Question 'reason_choice' "Flop $boardStr; turn $turn. BB ${action} with ${hero} vs BTN's turn barrel. What is the primary reason?" $reasonChoices
}
function BoardStr($cards) { return ($cards -join ' ') }


# ====== Boards (existing F1-F11 redeclared + 2 NEW for v4.3.2) ======

# Family 1: Brick after A-high dry (Ac 7d 2s, 4h)  -- existing
$f1Flop = @('Ac','7d','2s'); $f1Turn = '4h'
$f1 = New-Board $f1Flop $f1Turn 'A_high' 'A_high' 'rainbow' 'rainbow' @('dry','disconnected') 'brick' 'brick' 'neutral' 'none' 'no_change'
$f1Str = BoardStr $f1Flop

# Family 4: Flush-complete Q-high (Qs 8s 4d, 2s)  -- existing
$f4Flop = @('Qs','8s','4d'); $f4Turn = '2s'
$f4 = New-Board $f4Flop $f4Turn 'Q_high' 'Q_high' 'two_tone' 'monotone' @('wet','disconnected') 'flush_complete' 'polarizing' 'completes_bb_draws' 'flush_completed' 'no_change'
$f4Str = BoardStr $f4Flop

# Family 5: BB-favored straight complete (9s 8d 4c, 7h)  -- existing
$f5Flop = @('9s','8d','4c'); $f5Turn = '7h'
$f5 = New-Board $f5Flop $f5Turn 'low' 'low' 'rainbow' 'rainbow' @('wet','semi_connected') 'straight_complete' 'polarizing' 'favors_bb' 'straight_completed' 'no_change'
$f5Str = BoardStr $f5Flop

# Family 6: Board-pair high (Kd 8s 3c, 8h)  -- existing
$f6Flop = @('Kd','8s','3c'); $f6Turn = '8h'
$f6 = New-Board $f6Flop $f6Turn 'K_high' 'K_high' 'rainbow' 'rainbow' @('dry','paired') 'board_pair' 'counterfeit' 'counterfeits_bb_pairs' 'none' 'flop_card_paired'
$f6Str = BoardStr $f6Flop

# Family 7: Board-pair low second-pair (Qs 7d 3c, 3h)  -- existing
$f7Flop = @('Qs','7d','3c'); $f7Turn = '3h'
$f7 = New-Board $f7Flop $f7Turn 'Q_high' 'Q_high' 'rainbow' 'rainbow' @('dry','paired') 'board_pair' 'counterfeit' 'counterfeits_bb_pairs' 'none' 'flop_card_paired'
$f7Str = BoardStr $f7Flop

# Family 8: Draw-intensifier (Ts 8s 4d, 7c)  -- existing label kept for
# scenarios whose strategic verdict treats the turn primarily as
# draw-intensifying (NFD semi-bluff A5; top-set value-raise A7). The
# 7c turn IS technically straight-completing too (lands J9/96/65 made
# straights -- see $f8R1 below), but A5 and A7 emphasize the draw axis.
$f8Flop = @('Ts','8s','4d'); $f8Turn = '7c'
$f8 = New-Board $f8Flop $f8Turn 'T_high' 'T_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'draw_intensifier' 'draw_added' 'improves_bb_draws' 'oesd_added' 'no_change'
$f8Str = BoardStr $f8Flop

# Family 8 (R1 variant, v4.3.2B metadata hotfix): Same physical board
# Ts 8s 4d / 7c, but classified by its STRAIGHT-COMPLETING aspect
# (J9 = 7-8-9-T-J made; 96 = 6-7-8-9-T made; 65 = 4-5-6-7-8 made).
# Used by R1 (QcQd overpair as bluff-catch on this polar straight-
# complete turn). Scenarios whose strategic verdict treats the turn
# as bluff-catch territory should use this metadata variant instead
# of the draw-intensifier $f8 variant.
# Taxonomy validation:
#   turnCategory   : straight_complete (in approved enum)
#   boardChange    : polarizing        (in approved enum;
#                                       'draw_completed' not approved)
#   equityShift    : polarizes_btn     (in approved enum;
#                                       'polarizes_range' not approved)
#   drawCompletion : straight_completed (in approved enum)
$f8R1 = New-Board $f8Flop $f8Turn 'T_high' 'T_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'straight_complete' 'polarizing' 'polarizes_btn' 'straight_completed' 'no_change'

# Family 9: Multi-FD turn (Ah 9d 4d, 7h)  -- existing
$f9Flop = @('Ah','9d','4d'); $f9Turn = '7h'
$f9 = New-Board $f9Flop $f9Turn 'A_high' 'A_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'draw_intensifier' 'draw_added' 'improves_bb_draws' 'gutshot_added' 'no_change'
$f9Str = BoardStr $f9Flop

# Family 10: Polarizing brick after dynamic flop (Jd Td 5s, 2c)  -- existing
$f10Flop = @('Jd','Td','5s'); $f10Turn = '2c'
$f10 = New-Board $f10Flop $f10Turn 'J_high' 'J_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'brick' 'brick' 'neutral' 'none' 'no_change'
$f10Str = BoardStr $f10Flop

# Family 11: Low BB-favored straight complete (7s 5d 3h, 4c)  -- existing v4.3.0D
$f11Flop = @('7s','5d','3h'); $f11Turn = '4c'
$f11 = New-Board $f11Flop $f11Turn 'low' 'low' 'rainbow' 'rainbow' @('wet','semi_connected') 'straight_complete' 'polarizing' 'favors_bb' 'straight_completed' 'no_change'
$f11Str = BoardStr $f11Flop

# Family 12 (NEW for v4.3.2): Mid-board overcard demote
# Flop Kc 7s 2d is K-high rainbow disconnected; turn Qh adds an
# overcard between K and the second-pair line and adds gutshot
# threats (any J makes K-Q-J-T or A-K-Q-J variants for villain).
# Distinct from F3 (Kd 8c 4s, Ah) because here turn is Q (NOT A),
# which still demotes K-pair-with-weak-kicker but keeps villain
# range structure different (more KQ value, fewer AA combos).
$f12Flop = @('Kc','7s','2d'); $f12Turn = 'Qh'
$f12 = New-Board $f12Flop $f12Turn 'K_high' 'K_high' 'rainbow' 'rainbow' @('dry','disconnected') 'overcard' 'range_shift_btn' 'favors_btn' 'gutshot_added' 'no_change'
$f12Str = BoardStr $f12Flop

# Family 13 (NEW for v4.3.2): Two-tone draw-intensifier with backdoor flush completion
# Flop 9c 6c 3h is mid-board two-tone semi-connected; turn 8c brings
# 3-club flush completion (backdoor FD becomes nut FD/made flush
# territory) AND straight-complete potential (5-6-7-8-9 needs 7;
# 6-7-8-9-T needs 7). Distinct from F8 (Ts 8s 4d, 7c) and F9
# (Ah 9d 4d, 7h) because here flop is two-tone and turn brings
# THE SAME suit (3rd club), so flush-complete is on same line as
# straight-complete -- new strategic axis.
$f13Flop = @('9c','6c','3h'); $f13Turn = '8c'
$f13 = New-Board $f13Flop $f13Turn 'low' 'low' 'two_tone' 'monotone' @('wet','semi_connected') 'flush_complete' 'polarizing' 'completes_bb_draws' 'flush_completed' 'no_change'
$f13Str = BoardStr $f13Flop


# ====== Continuation scenarios (20 total) ======
$scenarios = @()


# ============================================================
# REASON_CHOICE BLOCK (8 scenarios -- Priority 1)
# Each tests strategic diagnosis, not label memorization.
# ============================================================

# R1 -- F8R1 (Ts 8s 4d, 7c, STRAIGHT-COMPLETE variant): QcQd overpair as bluff-catch
# v4.3.2A: 7c on T-8-4 actually COMPLETES multiple straights via villain
#   one-pair / two-card combos:
#     65 makes 4-5-6-7-8;  96 makes 6-7-8-9-T;  J9 makes 7-8-9-T-J.
#   98 has pair-of-8 + OESD (4-card 7-8-9-T needing 6 or J).
#   T9 has top-pair + OESD.
# v4.3.2B: board metadata corrected from draw_intensifier (stale) to
#   straight_complete / polarizing / polarizes_btn / straight_completed
#   via the new $f8R1 variant (see board declaration above).
# QQ on this board is BEHIND every made straight (65/96/J9) and every set
# (TT/88/44). QQ is overpair-to-T but in BLUFF-CATCH territory, NOT protection-raise:
# raising folds out air and isolates vs straights that crush us.
# Strategic verdict: CALL with bluff_catch_turn.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_reason_QcQd_v432' `
  -board $f8R1 -heroHand @('Qc','Qd') `
  -handClass 'overpair' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Overpair QQ to T-high board on a straight-completing turn; no relevant straight-blocker (Qc Qd does not block 65/96/J9 made-straight combos).' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Reason 'calls' 'Qc Qd' $f8Str '7c') `
  -answer (New-Answer 'bluff_catch_turn' @('pot_odds_turn_call') @('protection_check_raise_turn','value_check_raise_turn','equity_realization_turn_call','semi_bluff_check_raise_turn','slowplay_turn_call','mixed_indifference_turn','blocker_check_raise_turn','board_change_fold','domination_turn_fold','range_disadvantage_turn_fold') @()) `
  -explanation (New-Explanation `
    'Overpair QQ on straight-complete turn -- call (bluff-catch); raising folds air and isolates vs straights.' `
    '7c lands the connector that completes multiple straights on T-8-4: 65 makes 4-5-6-7-8, 96 makes 6-7-8-9-T, J9 makes 7-8-9-T-J. Plus 98 has pair-of-8 + OESD and T9 has top pair + OESD. The made-straight density in villain barrel range is significant; QQ is now overpair-to-T but BEHIND every made straight + every set, sitting in bluff-catch territory only.' `
    'BB flop call with QQ on T-8-4 was natural overpair. Turn 7 polarizes villain barrel: the value side now contains made straights (65/96/J9) and sets/two-pair; the bluff side contains failed broadway gutshots and missed overcards. QQ does not interact with any of the straight-completing combos, so blocker effects are minimal.' `
    'QcQd has overpair below only KK/AA. Beats all Tx pairs, all 8x pairs, all underpairs, all bluffs and air. Loses to 65/96/J9 made straights, TT/88/44 sets, T8/T4/84 two-pair (rare combos in BTN flop call range).' `
    'Calling captures the air/bluff portion of the polarized barrel range and reaches showdown. Small check-raise folds out air and isolates against the straight portion that crushes QQ -- bad EV. Big raise even worse. Folding is too tight given QQ still beats every bluff.' `
    'Hard-coding overpair = "always raise for protection on draw turns" without checking which DRAWS actually completed leads to raising into completed-straight density. The 7c here is straight-complete, not draw-intensifier.' `
    'Overpair on straight-complete turn vs polar barrel = call (bluff-catch); not protection-raise.') `
  -conceptTags @('turn_bluff_catcher','turn_draw_completion','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'reason_choice diagnosing BLUFF-CATCH (not protection) on F8 STRAIGHT-COMPLETE turn. Trains the lesson that 7c on T-8-4 is a straight-complete (65/96/J9 all make), NOT a draw-intensifier. Distinct from F8 JsJh action_choice (overpair value-raise) because here the overpair is BEHIND completed straights -- the same overpair classification leads to opposite actions on this turn category. Tests the discrimination protection_check_raise_turn (wrong here) vs bluff_catch_turn (correct here).'

# R2 -- F13 NEW (9c 6c 3h, 8c): 7s5s bottom straight on flush-complete monotone turn
# v4.3.2A correction: hero has bottom straight 5-6-7-8-9 (NINE-HIGH), but the turn 8c
#   completes a 3-card club flush AND there is a higher straight T7 (T-7 + board
#   6-8-9 = 6-7-8-9-T = T-high straight). Hero has ZERO clubs (7s5s = both spades),
#   so hero has no flush blocker. Made flushes BEAT hero. T7 BEATS hero.
#   Hero cannot raise for value: raising folds out air bluffs (which we beat) and
#   gets called/raised by flushes + T7 (which beat us). The strategic verdict is
#   CALL (bluff-catch), NOT raise-for-value.
# heroHandRole reclassified: nutted_value -> bluff_catcher (hero loses to flushes
#   and to T-high straight; not nutted, only mid-strength relative to barrel range).
# showdownValue reclassified: nutted -> high (loses to material portion of barrel value).
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9c6c3h_8c_m4_reason_7s5s_v432' `
  -board $f13 -heroHand @('7s','5s') `
  -handClass 'straight' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Made 9-high straight 5-6-7-8-9 on a monotone-club turn. Hero holds ZERO clubs (7s5s = both spades) so has NO flush blocker; loses to every made flush (any Ax-clubs, any 2-club hand) and to T-high straight (T7 specifically; 6-7-8-9-T).' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Reason 'calls' '7s 5s' $f13Str '8c') `
  -answer (New-Answer 'bluff_catch_turn' @('pot_odds_turn_call','mixed_indifference_turn') @('value_check_raise_turn','protection_check_raise_turn','equity_realization_turn_call','semi_bluff_check_raise_turn','slowplay_turn_call','blocker_check_raise_turn','board_change_fold','domination_turn_fold','range_disadvantage_turn_fold') @()) `
  -explanation (New-Explanation `
    'Bottom straight 5-6-7-8-9 on flush-complete monotone turn with NO flush blocker -- call (bluff-catch); raising loses to flushes + T7.' `
    '8c lands the 9-high straight AND completes a 3-card club flush. Villain barrel range on this monotone-flush-complete turn polarizes toward made flushes (any 2-club hand: Ax-clubs nut flush, KQ-clubs, JT-clubs, etc.) plus the higher T-high straight (T7) plus air bluffs (missed overcards / failed gutshots). Hero straight is BEHIND every made flush and behind T7; ahead of every set, every two-pair, every pair, every air combo.' `
    'BB flop call with 75-suited on 9-6-3 was thin (gutshot to 8 + backdoor flush via spades). Turn 8c lands the straight but kills the spade BDFD (wrong suit) and simultaneously completes the club-flush threat against hero.' `
    '7s5s makes 5-6-7-8-9 straight (the LOWEST possible straight on this board). Loses to: every made flush (Ax-clubs, KQ-clubs, 2-club combos -- significant density on monotone turn), T7 made T-high straight (6-7-8-9-T). Beats: every set (66/99/33/88), every two-pair, every pair, every air bluff, every weaker straight (none lower exists).' `
    'Calling captures the air/bluff portion of the polarized barrel and reaches showdown without bloating vs flushes. Small check-raise is bad EV: it folds out the air bucket (which we beat) and isolates against flushes + T7 (which crush us). Mixed defensible vs sizing/opponent. Big raise commits chips against a value range we mostly lose to.' `
    'Reading made-straight as "always-value-raise" without checking the flush-complete texture or the higher-straight threat (T7) leads to raising into a value range that beats us. Bottom straight on monotone turn with no suit blocker is bluff-catch, not value-raise.' `
    'Bottom straight on monotone-flush-complete turn with no suit blocker = call (bluff-catch); not value-raise.') `
  -conceptTags @('turn_bluff_catcher','turn_draw_completion','second_barrel_defense') `
  -difficulty 5 `
  -uniquenessNote 'NEW BOARD F13 + reason_choice diagnosing BLUFF-CATCH (not value-raise) on flush-complete-monotone turn. Trains the lesson that a made straight is NOT automatically a value-raise hand -- when the same turn that lands the straight ALSO completes a 3-flush AND there is a higher straight (T7), the made straight is BEHIND the polar value range (flushes + T7) and AHEAD of only the bluff range. Distinct from F4 flush-complete scenarios (TPTK bluff-catch / NFD blocker) because here hero has the MADE STRAIGHT not made pair -- different made-hand category facing the same flush-complete texture.'

# R3 -- F1 (Ac 7d 2s, 4h): 9d8d gutshot+BDFD on brick turn
# Best = fold. Diagnose WHY: range_disadvantage_turn_fold vs board_change_fold or pot_odds.
# Brick 4h doesn't change board; villain's A-high range is unchanged; hero has only gutshot to 5 (4 outs).
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_reason_9d8d_v432' `
  -board $f1 -heroHand @('9d','8d') `
  -handClass 'backdoor_only' -heroHandRole 'give_up' -drawCategory 'backdoor_only' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_turn_fold' `
  -question (Q-Reason 'folds' '9d 8d' $f1Str '4h') `
  -answer (New-Answer 'range_disadvantage_turn_fold' @('board_change_fold','domination_turn_fold') @('bluff_catch_turn','equity_realization_turn_call','pot_odds_turn_call','semi_bluff_check_raise_turn','slowplay_turn_call','mixed_indifference_turn','protection_check_raise_turn','value_check_raise_turn','blocker_check_raise_turn') @()) `
  -explanation (New-Explanation `
    'No pair no live draw on A-high brick turn -- fold; BB range is structurally disadvantaged here.' `
    '4h is a brick. Villain A-high barrel range is unchanged from flop. Hero 9d8d has no pair; the diamond backdoor is alive but very thin (3 diamonds total: 7d on board plus hero 9d 8d -- runner-runner flush only). No live straight draw: hero 8-9 plus board 2-4-7-A produces zero one-card-straight outs.' `
    'BB flop call with 98-suited on A-7-2 was thin (backdoor flush + backdoor straight reach). Turn 4 leaves only the runner-runner backdoor diamond flush; the supposed straight reach evaporates because no single river card makes hero a five-card straight.' `
    '9d8d has no pair, no one-card draw (zero gutshot since hero+board ranks are 2,4,7,8,9,A with no five-rank window), only a runner-runner backdoor diamond flush. Effective equity vs villain barrel range is roughly 6-8%.' `
    'Folding closes action; calling pays a non-trivial price for runner-runner backdoor equity; semi-bluff raise commits chips on a board where BB range is structurally weak vs A-high barrel.' `
    'Continuing weak runner-runner backdoors on A-high BB-disfavored turns because the call price is small ignores the underlying range disadvantage.' `
    'Naked runner-runner backdoor on A-high brick turn = fold (range disadvantage; pot odds insufficient for thin backdoor equity).') `
  -conceptTags @('turn_range_disadvantage','turn_pot_odds','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'reason_choice diagnosing RANGE_DISADVANTAGE (not pot_odds or board_change) as the dominant fold motive on F1 brick. Distinct from existing F1 KdJc (overcards-only, no draw) because this hero has a runner-runner backdoor diamond flush -- the lesson is that range disadvantage trumps the thin backdoor on a board where BB has weaker absolute equity than the call price.'

# R4 -- F4 (Qs 8s 4d, 2s): Tc9c no pair no draw on flush-complete turn
# Best = fold. Diagnose WHY: board_change_fold (flush completed and hero has no pair, no FD).
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs8s4d_2s_m4_reason_Tc9c_v432' `
  -board $f4 -heroHand @('Tc','9c') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'board_change_fold' `
  -question (Q-Reason 'folds' 'Tc 9c' $f4Str '2s') `
  -answer (New-Answer 'board_change_fold' @('range_disadvantage_turn_fold') @('bluff_catch_turn','equity_realization_turn_call','pot_odds_turn_call','semi_bluff_check_raise_turn','slowplay_turn_call','mixed_indifference_turn','protection_check_raise_turn','value_check_raise_turn','blocker_check_raise_turn','domination_turn_fold') @()) `
  -explanation (New-Explanation `
    'Tc9c on flush-complete turn -- fold; the board changed against hero hand category.' `
    '2s makes the 3rd spade and completes the flush. Hero has no spade in hand, no pair, no draw. The board change collapses hero equity: every spade combo in villain range now beats hero entirely; non-spade combos still beat T-high. Pre-turn hero had backdoor flush + backdoor straight -- both are now dead.' `
    'BB flop call with T9-suited on Q-8-4-spade-spade was thin (overcards-to-8, backdoor straight, backdoor flush). Turn 2s kills BDFD (wrong suit) and BDSD (no straight reach via 2).' `
    'Tc9c has no pair, no flush, no straight draw, no relevant blocker. Zero showdown value vs every made hand and most air on a flush-complete board.' `
    'Folding closes action; calling chases dominated 6 overcards (T or 9 still loses to flushes); raising commits with no equity backbone vs villain made-flush combos.' `
    'Defending two overcards on flush-complete turns because of the small call price ignores the board change against hero range.' `
    'Naked overcards on flush-complete turn = fold (board changed against hero category, not just range disadvantage).') `
  -conceptTags @('turn_board_change','turn_draw_completion','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'reason_choice diagnosing BOARD_CHANGE (not range_disadvantage) as the dominant fold motive on F4 flush-complete. Distinct from F1 9d8d range_disadvantage fold because the F4 board CHANGED -- the third spade is the actual reason hero has no equity. Trains the discrimination skill between board_change_fold and generic range_disadvantage_fold.'

# R5 -- F6 (Kd 8s 3c, 8h): 7c7d underpair on board-pair K-high turn
# Best = fold. Diagnose WHY: domination_turn_fold (any 8x has trips; villain barrel range crushes underpairs).
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8s3c_8h_m4_reason_7c7d_v432' `
  -board $f6 -heroHand @('7c','7d') `
  -handClass 'underpair' -heroHandRole 'dominated_marginal' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'domination_turn_fold' `
  -question (Q-Reason 'folds' '7c 7d' $f6Str '8h') `
  -answer (New-Answer 'domination_turn_fold' @('range_disadvantage_turn_fold','board_change_fold') @('bluff_catch_turn','equity_realization_turn_call','pot_odds_turn_call','semi_bluff_check_raise_turn','slowplay_turn_call','mixed_indifference_turn','protection_check_raise_turn','value_check_raise_turn','blocker_check_raise_turn') @()) `
  -explanation (New-Explanation `
    'Underpair 77 on board-paired K-high turn -- fold; dominated by 8x trips and Kx top pair.' `
    '8h pairs the 8 and gives villain trip-8 combos (88/A8/K8/Q8). Hero 77 is underpair-below-the-second-board-pair (since the turned 8 is now its own pair-holding category) and crushed by Kx top pair plus 8x trips. The villain barrel range concentrates on Kx-strong-kicker plus turned 8x trips; underpair-to-K is dominated structurally.' `
    'BB flop call with 77 on K-8-3 was thin (underpair to top, ahead only of T9-air). Turn 8 doubles the second board card and adds trip combos to villain range.' `
    '7c7d has underpair to K, dominated by every Kx in villain range, every 8x trips combo (88/A8/K8/Q8), and all overpairs. Only 2 outs to set-of-7s.' `
    'Folding closes action; calling pays off Kx + 8x value with only 2 outs to set; raising commits chips into a dominated range with no fold-equity story (no relevant blocker).' `
    'Stationing underpairs vs board-pair turns because pot odds look small ignores the trips threat that fundamentally dominates the spot.' `
    'Underpair on board-pair turn vs Kx-heavy barrel = fold (dominated, not just range disadvantage).') `
  -conceptTags @('turn_domination_fold','turn_board_change','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'reason_choice diagnosing DOMINATION (not range_disadvantage or board_change) as the dominant fold motive on F6 board-paired. Distinct from existing F6 polish JsJd (underpair fold with range_disadvantage emphasis) because here hero pair is BELOW the second board pair (8 > 7), making the domination dynamic structural rather than range-based. Trains discrimination between domination_turn_fold and range_disadvantage_turn_fold.'

# R6 -- F10 (Jd Td 5s, 2c): As9s no pair no draw on polar brick turn
# Best = check_raise_small (semi-bluff with A-high blocker on polar brick).
# Diagnose WHY: blocker_check_raise_turn (A-blocker reduces villain's nut FD + AA value combos on polar brick where BB range advantage permits a thin bluff).
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_JdTd5s_2c_m4_reason_As9s_v432' `
  -board $f10 -heroHand @('As','9s') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'backdoor_only' -showdownValue 'none' `
  -blockerNote 'As-blocker reduces villain AA combos. Spade BDFD via 9s; 9 also gives gutshot to 8 for 8-9-T-J + need Q? No: 9 + T-J on board = need 7-8 OR Q-K for straight; 9 alone does not give a one-card straight.' `
  -recommendedAction 'check_raise_small' -actionReason 'blocker_check_raise_turn' `
  -question (Q-Reason 'check-raises small' 'As 9s' $f10Str '2c') `
  -answer (New-Answer 'blocker_check_raise_turn' @('semi_bluff_check_raise_turn') @('bluff_catch_turn','equity_realization_turn_call','pot_odds_turn_call','protection_check_raise_turn','slowplay_turn_call','mixed_indifference_turn','value_check_raise_turn','board_change_fold','domination_turn_fold','range_disadvantage_turn_fold') @()) `
  -explanation (New-Explanation `
    'As9s no pair on polar brick turn -- check-raise small (blocker bluff using A-blocker).' `
    '2c is a polar brick. Villain barrel range is wedged: nutted Tx/Jx/two-pair/sets vs total air. Hero As9s has zero made-hand value but the A-blocker reduces villain AA value combos AND the polar brick combined with BB range advantage on J-T-5 lets hero credibly represent JT/TT/55 sets. The 9 adds modest backdoor straight reach; the spade BDFD is dead via the 2c.' `
    'BB flop call with A9-suited on J-T-5 was natural (overcard A + backdoor flush + backdoor gutshot). Turn 2 brick changes nothing but unlocks a polar bluff line for hero.' `
    'As9s has no made hand, no live FD (BDFD dead via 2c brick), only modest gutshot reach through future cards. The lesson is the BLOCKER + range structure, not equity.' `
    'Small check-raise leverages BB range advantage on J-T-5 plus A-blocker; calling surrenders the line. Big raise risks too much without made-hand backbone.' `
    'Reading this as semi_bluff_check_raise (when BDFD is actually dead) inflates the equity story; the dominant motive is the BLOCKER + range advantage.' `
    'A-blocker bluff on polar brick where BB range is favored = blocker_check_raise (not semi-bluff).') `
  -conceptTags @('turn_blocker_pressure','turn_check_raise_bluff','second_barrel_defense') `
  -difficulty 5 `
  -uniquenessNote 'reason_choice diagnosing BLOCKER_CHECK_RAISE (not semi_bluff_check_raise) on F10 polar brick. The discrimination is critical: with BDFD dead, the equity story collapses but the blocker story remains. Trains the lesson that blocker bluffs do not need a live draw when BB range advantage on a polar brick supports the line. Distinct from existing F10 scenarios (set/overpair/mixed underpair) because this is the ONLY F10 reason_choice testing the blocker_check_raise diagnosis.'

# R7 -- F5 (9s 8d 4c, 7h): 5h5d underpair turned set, BB-favored straight-complete
# Best = call. Diagnose WHY: slowplay_turn_call (set is nutted-equity but raising chases air; villain barrel range polarizes; calling traps).
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9s8d4c_7h_m4_reason_5h5d_v432' `
  -board $f5 -heroHand @('5h','5d') `
  -handClass 'set' -heroHandRole 'slowplay_trap' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Set of 5s on board where 5-6-7-8-9 straight already completed via any 6 in villain range. Hero set is the second-tier nutted region (loses to 6-x straights only).' `
  -recommendedAction 'call' -actionReason 'slowplay_turn_call' `
  -question (Q-Reason 'calls' '5h 5d' $f5Str '7h') `
  -answer (New-Answer 'slowplay_turn_call' @('value_check_raise_turn') @('bluff_catch_turn','equity_realization_turn_call','pot_odds_turn_call','protection_check_raise_turn','semi_bluff_check_raise_turn','mixed_indifference_turn','blocker_check_raise_turn','board_change_fold','domination_turn_fold','range_disadvantage_turn_fold') @()) `
  -explanation (New-Explanation `
    'Set of 5s on BB-favored straight-complete turn -- call to slowplay; raising chases the polarized barrel range air bucket.' `
    '7h lands the 5-6-7-8-9 straight via any 6. Hero set of 5s is very strong (top portion of made-hand region) but raising charges only T+ value combos (rare on flop call) and folds out the entire bluff bucket immediately. Calling traps villain bluffs and lets villain barrel a third street with weaker hands.' `
    'BB flop call with 55 on 9-8-4 was natural (underpair + set draw). Turn 7 lands the straight on the BB-favored side and brings villain barrel range toward polar (T-high made or air).' `
    '5h5d makes set of 5s. Loses only to 6-x straight combos (rare on flop call: 65, 64s, A5-A4 wheel hands). Beats every weaker pair, every two-pair, all bluffs. Vs villain barrel, ahead of every air combo and every Tx weaker.' `
    'Calling slowplays and traps the bluff range. Small check-raise is value-raise but folds out the bluff bucket immediately, surrendering river barrel value. Big raise even worse.' `
    'Auto-raising sets on polar straight-complete turns chases out the air range and surrenders river value.' `
    'Set on BB-favored polar straight-complete turn vs polarized barrel = call (slowplay) -- not value-raise.') `
  -conceptTags @('turn_slowplay_call','turn_check_raise_value','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'reason_choice diagnosing SLOWPLAY (not value_check_raise) on F5 BB-favored straight-complete. The discrimination is critical because the same set hand could be raised on a less polarized board for value, but on this polarized turn the slowplay maximizes EV by trapping bluffs. Trains slowplay_turn_call vs value_check_raise_turn discrimination on a board where both are defensible but slowplay dominates.'

# R8 -- F3 used board (Kd 8c 4s, Ah from existing) -- DIFFERENT ID via new hero
# Wait F3 is in v4.3.0 builder; let me use a CONFIRMED-AS-USED board with NEW hero.
# Use F11 (7s 5d 3h, 4c) -- existing v4.3.0D family. Hero AhAd.
# Best = mixed (true indifference between value-raise and slowplay-call).
# Diagnose WHY: mixed_indifference_turn (close call vs raise; sizing-and-population sensitive).
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_7s5d3h_4c_m4_reason_AhAd_v432' `
  -board $f11 -heroHand @('Ah','Ad') `
  -handClass 'overpair' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Overpair AA with one A in each red suit; no flush blocker because flop+turn are 7s 5d 3h 4c (rainbow). Diamond-blocker reduces 6-of-diamonds river straight-completion combos slightly.' `
  -recommendedAction 'mixed' -actionReason 'mixed_indifference_turn' `
  -question (Q-Reason 'plays a mixed strategy' 'Ah Ad' $f11Str '4c') `
  -answer (New-Answer 'mixed_indifference_turn' @() @('bluff_catch_turn','equity_realization_turn_call','pot_odds_turn_call','protection_check_raise_turn','semi_bluff_check_raise_turn','slowplay_turn_call','blocker_check_raise_turn','board_change_fold','domination_turn_fold','range_disadvantage_turn_fold','value_check_raise_turn') @()) `
  -explanation (New-Explanation `
    'Overpair AA on low BB-favored straight-complete turn -- mixed strategy: value-raise vs slowplay-call are both defensible.' `
    '4c lands the bottom straight (3-4-5-6-7 needs 6). Hero AA overpair beats every made hand except 6-x straight combos. The mix tension: value-raising charges 7-x value-call combos but folds bluffs; slowplay-calling traps bluffs but lets sky-rivers (6) potentially redirect. On a BB-favored board where villain barrel range polarizes toward straight-value vs air, the EV-difference between raise-small and call is razor-thin.' `
    'BB flop call with AA on 7-5-3 was thin (overpair to all four board ranks, no draw). Turn 4 favors BB structurally but also brings made-straight redirection.' `
    'AhAd has overpair AA, the absolute top non-set non-straight hand. Loses to 65/64/A5 wheel-hand straights (rare BTN combo on flop call); beats every 7x, every weaker pair, every air. Hero diamond-blocker is irrelevant since the board is rainbow.' `
    'Mixed strategy reflects that small check-raise and call have similar EV: small raise extracts from 7x and air-bluffs but folds the air bucket immediately; calling traps bluffs and reaches the river with deception. Population/opponent tendencies tip the right strategy.' `
    'Hard-coding EITHER value-raise OR slowplay misses the indifference -- this is exactly where mixed reflects the math.' `
    'Overpair on BB-favored polar straight-complete turn = mixed (the right strategy is opponent-and-sizing dependent).') `
  -conceptTags @('turn_check_raise_value','turn_slowplay_call','second_barrel_defense') `
  -difficulty 5 `
  -uniquenessNote 'reason_choice diagnosing MIXED_INDIFFERENCE on F11 BB-favored straight-complete turn. Trains the lesson that mixed reflects real strategy tension, not arbitrary indifference. Distinct from existing F11 6h6d (made straight value-raise) and 8d7d (combo-equity call) because here hero has OVERPAIR with no straight made and no draw -- different equity profile that genuinely sits between value-raise and slowplay-call.'


# ============================================================
# ACTION_CHOICE BLOCK (12 scenarios -- Priority 2-6 + gap-fills)
# ============================================================

# A1 -- F4 (Qs 8s 4d, 2s): As8d Q-blocker not strong, 8 second-pair on flush turn
# Best = fold. Bluff-catch fold lesson: A-spade-blocker is too weak with second-pair on flush-complete turn.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs8s4d_2s_m4_action_As8d_v432' `
  -board $f4 -heroHand @('As','8d') `
  -handClass 'mid_pair' -heroHandRole 'dominated_marginal' -drawCategory 'nut_flush_draw' -showdownValue 'low' `
  -blockerNote 'A-spade gives the nut flush draw (4 spades on board+hand) AND blocks villain nut-flush combos. But the 8d second-pair is dominated by every Qx made hand and most overpairs.' `
  -recommendedAction 'fold' -actionReason 'domination_turn_fold' `
  -question (Q-Action 'As 8d' $f4Str '2s') `
  -answer (New-Answer 'fold' @('call') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'A8 second-pair-with-NFD on flush-complete turn -- fold (call defensible with the NFD); second-pair is dominated and the FD just barely meets pot odds against a value-heavy barrel.' `
    '2s makes the third spade. Hero As8d has nut FD via Ace-of-spades (need one more spade) plus second-pair (8) on Q-high. The NFD has live equity (~19% one-card) but second-pair is dominated by all Qx, every overpair, every Q-x two-pair, plus made flushes that include hero outs sometimes. Combined hot/cold equity is below the call threshold given range disadvantage.' `
    'BB flop call with A8-offsuit on Q-8-4 with backdoor spade was thin (second-pair + BDFD via the A-spade card path). Turn 2s lands the FD but on a board where flush already completes -- meaningful only as nut-blocker not as primary equity.' `
    'As8d has second-pair (8) plus NFD (need 1 more spade). Beats Tx-with-no-spade and air bluffs. Loses to all Qx, all overpairs, all made flushes (Ax-of-spades hero is the nut-flush-blocker but villain still has KQ-spades, JT-spades, etc).' `
    'Folding closes action; calling pays off Qx + flushes too often given the 8-pair dominated portion; raising commits with no value and no clear bluff story (NFD is small fraction of hero range).' `
    'Calling A-x with NFD-redraw on flush-complete turns when the made-hand portion is dominated under-defends-value the BB range too thinly.' `
    'Second-pair plus NFD on flush-complete turn = fold (dominated; FD not enough at small price + range disadvantage).') `
  -conceptTags @('turn_domination_fold','turn_blocker_pressure','turn_draw_completion') `
  -difficulty 4 `
  -uniquenessNote 'F4 fold lesson with NFD-blocker that DOES NOT save the spot. Distinct from existing F4 KsQc (TPTK + 2nd-nut FD = call) and F4 AsKc (nut-spade-blocker bluff-catch with TPTK) because here hero has SECOND-PAIR (8 on Q-high) which is dominated even with NFD. Trains the discrimination that NFD-blocker is not enough when paired with a dominated made-hand portion.'

# A2 -- F12 NEW (Kc 7s 2d, Qh): KhJd K-pair-with-J-kicker on overcard turn
# Best = fold. Domination fold: Q overcard demotes K-J vs villain's KQ value range.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kc7s2d_Qh_m4_action_KhJd_v432' `
  -board $f12 -heroHand @('Kh','Jd') `
  -handClass 'top_pair_weak_kicker' -heroHandRole 'dominated_marginal' -drawCategory 'gutshot' -showdownValue 'low' `
  -blockerNote 'K-pair with J kicker; K-blocker reduces KQ/KK combos slightly but Q overcard hits villain range hard. J also gives gutshot to T for K-Q-J-T-? but needs both T and 9-or-A on river.' `
  -recommendedAction 'fold' -actionReason 'domination_turn_fold' `
  -question (Q-Action 'Kh Jd' $f12Str 'Qh') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'KJ TPWK on overcard Q turn -- fold; Q overcard hits villain KQ-AQ value cluster and hero is dominated.' `
    'Qh is an overcard between hero K kicker and villain natural barreling range (KQ specifically). Hero K-pair-with-J-kicker is now dominated by every KQ in villain range (preflop standard 2.5x range includes KQ-suited and offsuit), every AK, every QQ overpair, plus AQ that picks up TP-with-A-kicker. Hero only beats K7/K2 (not in BTN preflop range), weaker Kx (rare), and air.' `
    'BB flop call with KJ-offsuit on K-7-2 was natural (TPWK with no draw). Turn Q changes the structure: villain barrel range now leverages KQ + AQ + AK significantly.' `
    'KhJd has TPWK (K-pair, J kicker), gutshot to T-A or T-9 for K-Q-J-T-A (need T plus A or 9 in run-out -- low-effective-equity outs). Dominated by KQ, AK, AQ, KK, QQ. Beats K-low and air.' `
    'Folding closes action; calling pays off the KQ-AQ-AK cluster while only beating air; raising commits with a dominated weak-kicker top pair.' `
    'Stationing TPWK on overcard turns when the overcard hits villain barreling range hard ignores the structural domination.' `
    'TPWK on overcard turn that hits villain range = fold (dominated, not just second-best).') `
  -conceptTags @('turn_domination_fold','turn_board_change','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'NEW BOARD F12. TPWK fold on Q-overcard-after-K-flop turn. Distinct from F3 (Kd 8c 4s, Ah) AdJh-style fold because here turn is Q (not A) -- shifts villain value cluster from AA/AK to KQ/AQ/AK. Trains discrimination that KQ overcard demotes K-pair differently than A overcard.'

# A3 -- F12 NEW (Kc 7s 2d, Qh): JhTh broadway gutshot on overcard turn
# Best = call. Equity_realization: gutshot+overcards has enough one-card equity to call given backdoor straight reach.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kc7s2d_Qh_m4_action_JhTh_v432' `
  -board $f12 -heroHand @('Jh','Th') `
  -handClass 'gutshot' -heroHandRole 'draw' -drawCategory 'gutshot' -showdownValue 'none' `
  -blockerNote 'Gutshot to A makes broadway K-Q-J-T-A (4 outs to A); also gutshot to 9 makes K-Q-J-T-9 NOT broadway but gutshot variant does not exist here (hero has J-T, board K-Q-7-2; 9 in hand-or-board would not make a straight). Actually 9 makes 9-T-J-Q-K straight -- 4 outs. So total gutshot-to-A or 9 = 8 outs to two non-overlapping straights.' `
  -recommendedAction 'call' -actionReason 'equity_realization_turn_call' `
  -question (Q-Action 'Jh Th' $f12Str 'Qh') `
  -answer (New-Answer 'call' @('mixed') @('fold','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'JT broadway gutshot+gutshot OESD-equivalent on overcard Q turn -- call (multi-source equity + heart backdoor).' `
    'Qh adds K-Q-J-T two-card straight reach: any 9 makes 9-T-J-Q-K and any A makes T-J-Q-K-A. Combined 8 outs to two non-overlapping straights = ~17% one-card equity. Plus heart backdoor flush (Jh Th + Qh on board = 3 hearts; need 2 more for flush -- live runner-runner). Hero has overcards that may also pair to TP on river.' `
    'BB flop call with JTs on K-7-2 was thin (overcards + backdoor straight + backdoor flush via hearts). Turn Q lands the OESD-equivalent (two non-overlapping gutshots) directly.' `
    'JhTh has 8 gutshot outs to broadway or 9-high straight, plus heart BDFD (3 hearts), plus possible J/T pair-to-river (6 overcard outs of which J-pair might still beat air). Combined ~22% equity vs villain barrel.' `
    'Calling realizes equity at small price. Mixed defensible vs sizing/opponent. Folding combo equity OOP under-defends BB range. Big raise commits with insufficient made-hand backbone.' `
    'Folding double-gutshot-plus-BDFD vs small barrel under-defends the BB calling range and abandons real equity.' `
    'Double-gutshot + BDFD on overcard turn = call (multi-source equity).') `
  -conceptTags @('turn_pot_odds','turn_equity_shift','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'NEW BOARD F12. Double-gutshot equity-realization call on overcard Q turn. Distinct from F1 9d8d gutshot-fold because here gutshot is DOUBLE (any 9 OR any A) plus BDFD plus overcard pair outs -- combined equity exceeds the call threshold whereas single-gutshot-no-flush did not.'

# A4 -- F12 NEW (Kc 7s 2d, Qh): AsTs gutshot+nut-FD-blocker (no live FD) on overcard turn
# Best = check_raise_small as blocker bluff.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kc7s2d_Qh_m4_action_AsTs_v432' `
  -board $f12 -heroHand @('As','Ts') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'gutshot' -showdownValue 'none' `
  -blockerNote 'A-spade blocks AA value combos and reduces nut-FD-on-future-spade-rivers. Plus broadway gutshot via J for A-K-Q-J-T (4 outs).' `
  -recommendedAction 'check_raise_small' -actionReason 'blocker_check_raise_turn' `
  -question (Q-Action 'As Ts' $f12Str 'Qh') `
  -answer (New-Answer 'check_raise_small' @('mixed','call') @('fold','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'AT broadway gutshot + A-blocker on overcard Q turn -- check-raise small (blocker bluff with backbone equity).' `
    'Qh adds A-K-Q-J-T broadway reach (need J for nut straight; 4 outs ~ 9% one-card). Hero As blocks AA value (rare BTN flop call) and the A-blocker plus K-on-board reduces villain AK-strong combos. The blocker plus 4 nut-straight outs makes the bluff line credible.' `
    'BB flop call with ATs on K-7-2 was thin (overcards + backdoor straight). Turn Q gives the A-K-Q-J-T gutshot directly.' `
    'AsTs has no pair, gutshot to nut straight (4 outs ~ 9%), A-blocker reducing AA combos. The bluff is supported by the blocker structure, not by raw equity.' `
    'Small check-raise leverages A-blocker plus nut-straight redraw. Calling realizes equity passively. Folding gutshot+blocker under-defends. Big raise commits too much without a real made-hand or strong-equity backbone.' `
    'Reading this as semi_bluff_check_raise overstates the gutshot equity; the dominant motive is the A-blocker plus the nut-straight redraw together.' `
    'Nut-straight gutshot + A-blocker on overcard turn = check-raise small (blocker_check_raise).') `
  -conceptTags @('turn_blocker_pressure','turn_check_raise_bluff','second_barrel_defense') `
  -difficulty 5 `
  -uniquenessNote 'NEW BOARD F12. Action_choice blocker bluff on overcard turn. Distinct from R6 (F10 As9s blocker bluff on polar brick) because here hero has REAL nut-straight redraw equity backing the bluff, plus A-blocker on a DIFFERENT board structure (overcard demote vs polar brick). Tests blocker_check_raise across two distinct board structures.'

# A5 -- F8 (Ts 8s 4d, 7c): AsQs nut FD + gutshot + overcards on draw-intensifier
# Best = check_raise_small. Semi-bluff: NFD + gutshot + spade BDFD all live.
# Hero must hold A-of-spades to claim drawCategory=nut_flush_draw.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_action_AsQs_v432' `
  -board $f8 -heroHand @('As','Qs') `
  -handClass 'nut_flush_draw' -heroHandRole 'combo_draw' -drawCategory 'nut_flush_draw' -showdownValue 'none' `
  -blockerNote 'A-spade gives the NUT flush draw on the 2-spade flop (Ts + 8s = 2 spades; plus hero 2 spades = 4 spades total). 9 outs to nut flush plus A and Q overcard pair outs.' `
  -recommendedAction 'check_raise_small' -actionReason 'semi_bluff_check_raise_turn' `
  -question (Q-Action 'As Qs' $f8Str '7c') `
  -answer (New-Answer 'check_raise_small' @('call','mixed') @('fold','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'AQ NFD on draw-intensifier turn -- check-raise small (semi-bluff with strong nut-equity backbone).' `
    '7c expands draw density (FDs, OESDs, gutshots). Hero AsQs has nut FD via A-spade (need 1 more spade among 9 outs ~ 19%) plus overcard pair outs (A and Q over T-high board). The A-blocker also reduces villain AA value combos. Combined raw equity plus blocker dynamics support the semi-bluff line.' `
    'BB flop call with AQs on T-8-4 was natural (overcards + nut spade backdoor). Turn 7 reweights to draws-and-bluffs while hero gets the live NFD.' `
    'AsQs has no made hand, 9 outs to nut flush, plus A/Q overcard pair outs (~6 outs vs villain Tx-weaker weak made-hand portion). ~25% raw equity vs villain barrel range.' `
    'Small check-raise leverages NFD equity + fold equity vs villain weak made-hand range (Tx-weak, 8x, weak overpairs). Calling passively realizes equity but surrenders fold-equity. Folding NFD+overcards vs small barrel under-defends.' `
    'Folding NFD vs small turn barrel because of "no pair" ignores the 9-out one-card nut flush draw equity that exceeds pot odds AND fold-equity backbone.' `
    'NUT FD on draw-intensifier turn = check-raise small (semi-bluff, nut-equity backbone + A-blocker).') `
  -conceptTags @('turn_check_raise_bluff','turn_equity_shift','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'F8 NFD semi-bluff distinct from existing F8 9c8c (combo OESD+pair) and F8 KsQc (TPTK+FD bluff-catch). Here hero has NUT FD via A-spade without made-hand backbone -- pure semi-bluff with nut-blocker. Tests semi_bluff_check_raise vs blocker_check_raise discrimination on a draw-intensifier board.'

# A6 -- F1 (Ac 7d 2s, 4h): AcKh TPTK + A-blocker on brick turn
# Best = check_raise_small. Value raise: A-pair top kicker on a brick where villain barrel range is wide.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_AcKh_v432' `
  -board $f1 -heroHand @('Ah','Kc') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'TPTK with A-pair, K kicker. A-heart blocker reduces villain AA combos.' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action 'Ah Kc' $f1Str '4h') `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'TPTK with A-blocker on A-high brick turn -- check-raise small for value.' `
    '4h is a brick. Hero AhKc has TPTK on A-high disconnected dry board. Villain barrel range here is wide (Ax-weaker, mid pairs, occasional bluffs); raising charges Ax-weaker call-down and folds out air bluffs. The A-blocker further reduces villain AA + AK combos.' `
    'BB flop call with AK-offsuit on A-7-2 was natural (TPTK with no draw needed). Turn 4 brick adds nothing meaningful; hero range is favored on A-high dry boards relative to villain.' `
    'AhKc has TPTK with K kicker plus A-blocker reducing AA combos. Beats AQ/AJ/AT/A-low, all underpairs, all air. Loses only to AA (rare with hero A-blocker), A7/A4/A2 two-pair (rare combo), 77/22/44 sets.' `
    'Small check-raise charges weaker Ax and folds out air. Big raise risks too much vs the rare two-pair/set combos. Calling slowplays acceptable but surrenders value vs villain Ax call-down.' `
    'Auto-calling TPTK on A-high brick turns when villain barrel range is wide surrenders chips that worse Ax pays off.' `
    'TPTK with A-blocker on A-high brick = check-raise small for value.') `
  -conceptTags @('turn_check_raise_value','turn_blocker_pressure','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'F1 AhKc value-raise. Distinct from existing F1 scenarios (KdJc fold, 7c5c brick-adjacent). Adds the textbook TPTK value-raise on A-high brick to F1, complementing the F4/F9 TPTK value-raise spots which are on flush-complete and multi-FD boards. Tests value_check_raise_turn discrimination on the dry-brick board structure specifically.'

# A7 -- F8 (Ts 8s 4d, 7c): TcTd set-of-tens on draw-intensifier
# Best = check_raise_big. Value raise BIG: set-of-tens dominates and charges draws maximum.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_action_TcTd_v432' `
  -board $f8 -heroHand @('Tc','Td') `
  -handClass 'set' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Set of tens on draw-heavy turn. Loses only to T8/T4/T7 turned two-pair (rare BTN flop call combos) and 9-6/J-9 made straights (J-9 specifically makes 7-8-9-T-J straight -- one combo).' `
  -recommendedAction 'check_raise_big' -actionReason 'value_check_raise_turn' `
  -question (Q-Action 'Tc Td' $f8Str '7c') `
  -answer (New-Answer 'check_raise_big' @('check_raise_small') @('fold','call','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Top set on draw-intensifier turn -- check-raise BIG for value to charge draws maximum.' `
    '7c expands draw density (FDs, OESDs, gutshots). Hero set of tens is the absolute top of the made-hand region for BB on T-8-4-7. Villain barrel range now includes many strong draws (KsQs/JsQs/9c8c-style combos) that call big sizing because they have ~30%+ equity. Big raise extracts maximum from draws AND from worse made hands that may stack off.' `
    'BB flop call with TT on T-8-4 was natural (top set, slowplay candidate flopwise). Turn 7 makes raising MORE attractive because draws now have substantial equity that should be charged.' `
    'TcTd makes set of Ts. Loses only to 9-J straight (specifically J9; 1 combo blocker-light) and the very rare T8/T4 two-pair combos in BTN flop call range. Beats every overpair, every Tx, every weaker pair, every two-pair, every draw.' `
    'Big check-raise charges 9-out FDs (~25% equity), 8-out OESDs, gutshots, plus weaker made hands like overpairs/Tx that may stack off. Small check-raise also defensible but surrenders value-extraction vs draws that would call big anyway. Call slowplays but lets draws realize free river equity.' `
    'Slowplaying top set on draw-intensifier turns when draws are dense in villain range surrenders the maximum value-extraction window.' `
    'Top set on draw-heavy turn vs draw-heavy barrel = check-raise BIG (max value from draws).') `
  -conceptTags @('turn_check_raise_value','turn_equity_shift','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'F8 set-of-tens check_raise_BIG (NEW priority 4 spot for v4.3.2). Adds a third check_raise_big-best scenario to M4 (existing 2 are JT-nut-straight and KK-top-boat); this one is set-on-draw-intensifier where the BIG sizing extracts from the draws specifically. Distinct from existing 2 because the dominant motive is charging draws, not extracting from value-call-downs.'

# A8 -- F11 (7s 5d 3h, 4c): JsTs no pair on low BB-favored turn
# Best = mixed. True indifference: BB has range advantage on this turn but JT-suited has only modest equity.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_7s5d3h_4c_m4_action_JsTs_v432' `
  -board $f11 -heroHand @('Js','Ts') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote 'No pair, no draw. Two overcards but the board is low BB-favored and the overcards are of low-prevalence value vs villain range. Spade-suited but no flush draw on rainbow board.' `
  -recommendedAction 'mixed' -actionReason 'mixed_indifference_turn' `
  -question (Q-Action 'Js Ts' $f11Str '4c') `
  -answer (New-Answer 'mixed' @('fold') @('call','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'JT-suited no pair on low BB-favored straight-complete turn -- mixed: thin bluff-raise with overcard reach vs straightforward fold both defensible.' `
    '4c lands the bottom straight via 6. Villain barrel range is polarized (made-straight value vs air). Hero JT has no current equity but BB range advantage on this low board lets a mixed bluff-raise work occasionally; conversely, the made-straight density in villain value range plus zero made-hand backbone keeps fold defensible.' `
    'BB flop call with JT-suited on 7-5-3 was thin (two overcards, no pair, no draw, possible backdoor flush via spades). Turn 4 keeps draws dead and shifts villain range polar.' `
    'JsTs has no pair, no FD (rainbow board), no straight draw (J-T-7-5-4 needs 8-9 in run-out). Overcard pair outs of J or T do not beat made straights or sets. Pure bluff-or-fold spot with BB range advantage tilting toward mixed.' `
    'Mixed reflects the strategy tension: small bluff-raise leverages BB range advantage on the polar board; fold respects the thin equity backbone. Population/opponent tendencies tip the choice.' `
    'Always-folding here ignores BB range advantage; always-bluff-raising overestimates fold equity -- mixed reflects the real EV picture.' `
    'Naked overcards on low BB-favored polar turn = mixed (real strategy tension).') `
  -conceptTags @('turn_check_raise_bluff','turn_range_disadvantage','second_barrel_defense') `
  -difficulty 5 `
  -uniquenessNote 'F11 JT-suited mixed scenario distinct from existing F11 KsTd (clear fold) and 6h6d (made straight value-raise). Trains the lesson that BB range advantage on a polar straight-complete board can support a MIXED bluff-or-fold strategy with overcards, even without made-hand or draw backbone.'

# A9 -- F7 (Qs 7d 3c, 3h): 8d8c underpair on second-pair board
# Best = mixed. Close call vs fold given second-pair counterfeit and Q overcard.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs7d3c_3h_m4_action_8d8c_v432' `
  -board $f7 -heroHand @('8d','8c') `
  -handClass 'underpair' -heroHandRole 'marginal_made_hand' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote 'Underpair 88 below Q with no draw. Second-pair (3) on the board does not interact with hero pair.' `
  -recommendedAction 'mixed' -actionReason 'mixed_indifference_turn' `
  -question (Q-Action '8d 8c' $f7Str '3h') `
  -answer (New-Answer 'mixed' @('fold','call') @('check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    '88 underpair on Q-high paired-low turn -- mixed: thin bluff-catch vs fold both defensible.' `
    '3h pairs the second board card. Villain barrel range polarizes between Qx-trips-or-FH (rare combos via 33/77) and air. Hero 88 is below Q overpair territory and dominated by Qx but ahead of all air and weaker underpairs. The mix tension: bluff-catch the polarized barrel vs accept that 88 is too weak vs the value cluster.' `
    'BB flop call with 88 on Q-7-3 was thin (underpair to Q with no draw). Turn 3 doubles second board card; villain range adds rare trips combos (33/77 only since flop-call kept 33 alive).' `
    '8d8c has underpair to Q, no draw, no relevant blocker. Beats all air bluffs and any 7x-or-down. Loses to all Qx, all overpairs, all turned trip combos.' `
    'Mixed reflects opponent-and-sizing tension. Small barrel sizing tips toward call (more bluff combos in barrel range); larger sizing tips toward fold (polar value-only). Population tendency to over-bluff small sizings tips toward call slightly.' `
    'Hard-coding either always-fold OR always-call ignores the genuine close decision -- this is a real mix spot.' `
    'Underpair on Q-high board-pair-low turn = mixed (sizing-and-opponent dependent thin bluff-catch).') `
  -conceptTags @('turn_bluff_catcher','turn_pot_odds','second_barrel_defense') `
  -difficulty 5 `
  -uniquenessNote 'F7 underpair mixed scenario distinct from existing F7 AhAd (overpair value) and 7s7c (top set). Adds the underpair-mixed lesson on second-paired-low turn. Trains discrimination from straightforward folds (clear domination) and pure bluff-catches (clear-ahead-of-bluff-range).'

# A10 -- F9 (Ah 9d 4d, 7h): TdJc backdoor straight on multi-FD turn
# Best = fold. Range disadvantage: thin BDSD on A-high board where BB range is structurally weak.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ah9d4d_7h_m4_action_JcTd_v432' `
  -board $f9 -heroHand @('Jc','Td') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'gutshot' -showdownValue 'none' `
  -blockerNote 'Gutshot to 8 makes 7-8-9-T-J. 4 outs to 8. No flush draw despite the multi-FD turn (hero diamonds sit alongside 4d 9d but 7h is the turn so heart FD alive only with hearts in hand which JcTd lacks).' `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_turn_fold' `
  -question (Q-Action 'Jc Td' $f9Str '7h') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'JT no pair gutshot on A-high multi-FD turn -- fold; range disadvantage plus gutshot insufficient.' `
    '7h adds heart-FD threats but hero JT has no hearts. Hero gutshot to 8 only (4 outs ~ 9% one-card). Villain barrel range is Ax-heavy plus draws plus rare bluffs. BB range on A-high boards has fewer Ax combos than BTN preflop range; range disadvantage is structural here.' `
    'BB flop call with JT-offsuit on A-9-4 was thin (overcard J + backdoor straight via the existing 9). Turn 7 lands the gutshot but hero has no live FD.' `
    'JcTd has no pair, gutshot to 8 only (4 outs), no FD, no relevant blocker. The 8-out is dominated by villain Ax + made-flush-on-river combos.' `
    'Folding closes action; calling chases 4 outs given range disadvantage; raising commits without backbone equity.' `
    'Continuing weak gutshots on A-high multi-FD turns when BB range is structurally weak ignores both the equity insufficient and the range-disadvantage.' `
    'Naked gutshot on A-high multi-FD turn = fold (range disadvantage + insufficient pot odds).') `
  -conceptTags @('turn_range_disadvantage','turn_pot_odds','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'F9 gutshot fold lesson distinct from existing F9 9d8d (no-pair-no-draw fold) because here hero has gutshot equity and overcard reach -- yet still folds because of multi-source range disadvantage. Trains the lesson that having SOME equity is not enough on a structurally BB-disfavored A-high turn.'

# A11 -- F5 (9s 8d 4c, 7h): KsKc overpair on BB-favored straight-complete
# Best = call. Bluff-catch: overpair on a board where BB range polar makes raise-fold dynamic favor calling.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9s8d4c_7h_m4_action_KsKc_v432' `
  -board $f5 -heroHand @('Ks','Kc') `
  -handClass 'overpair' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Overpair KK on a board where straight just completed. Hero K-blocker is irrelevant here.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action 'Ks Kc' $f5Str '7h') `
  -answer (New-Answer 'call' @('check_raise_small','mixed') @('fold','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Overpair KK on BB-favored straight-complete turn -- call (bluff-catch the polarized barrel).' `
    '7h lands the 5-6-7-8-9 straight. Villain barrel range polarizes: made-straight value (any 6 in hand combinations like A6-suited, T6, 65, 64s) plus air. Hero KK overpair beats every air combo and every weaker pair (TT/JJ/QQ if villain barrels) but loses to made straights. Calling captures the air bucket; raising folds the air bucket immediately.' `
    'BB flop call with KK on 9-8-4 was natural (overpair to entire board, slowplay-flop candidate). Turn 7 polarizes villain barrel.' `
    'KsKc has overpair below only AA. Beats every weaker overpair barrel, every Tx, every weaker pair, every air. Loses to A6/T6/65/64-style straights (rare BTN preflop combos) and to AA.' `
    'Calling captures bluffs and reaches showdown vs polarized barrel. Small check-raise also defensible (charges JJ/TT/9x value while keeping bluffs in) but folds out the air bucket prematurely. Big raise terrible vs straights.' `
    'Folding KK overpair on polar straight turns because of the straight threat over-folds the BB region top.' `
    'Overpair KK on BB-favored polar straight-complete turn = call (bluff-catch the polar barrel).') `
  -conceptTags @('turn_bluff_catcher','turn_draw_completion','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'F5 KK overpair bluff-catch distinct from existing F5 TT (overpair + OESD = call for equity) and AhAd (overpair value-raise) because here hero has KK overpair with NO draw on a polar straight-complete turn. Trains the lesson that overpair-without-draw on polar turns calls (bluff-catch) rather than raises (folds out air).'

# A12 -- F6 (Kd 8s 3c, 8h): As9c second-pair-via-board-pair on K-high paired turn
# Best = call. Bluff-catch with A-blocker: A-high with second-pair coverage on board-pair turn.
# Wait: hero is As9c on K-8-3-8 board. Hero has 9-high, NOT second-pair (board pair is 8). Hero has no pair.
# Reconsider: this should be fold or thin call; let me reframe as fold for range_disadvantage_turn_fold.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8s3c_8h_m4_action_AsTd_v432' `
  -board $f6 -heroHand @('As','Td') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote 'A-spade blocks AA combos; on K-8-3-8 board the A-spade is NOT a flush-blocker (board has no flush threats) but reduces villain AA value preflop range.' `
  -recommendedAction 'check_raise_small' -actionReason 'blocker_check_raise_turn' `
  -question (Q-Action 'As Td' $f6Str '8h') `
  -answer (New-Answer 'check_raise_small' @('mixed','fold') @('call','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'AT no pair on K-high board-paired turn -- check-raise small (blocker bluff using A-blocker on counterfeit board).' `
    '8h doubles up the second board card and counterfeits villain barrel value. Hero AT has zero pair on the board but A-blocker reduces villain AA combos AND the counterfeit dynamic compresses villain Kx region toward calling-not-raising. Small check-raise leverages the polar shift toward villain having either a turned trips combo OR air -- against the air bucket the bluff has good fold equity.' `
    'BB flop call with AT-offsuit on K-8-3 was thin (overcard A + backdoor straight via Q-J for A-K-Q-J-T). Turn 8 changes nothing for hero hand value but unlocks the polar dynamic for a thin bluff-raise with the A-blocker.' `
    'AsTd has no pair, no draw, A-blocker reducing AA combos. Pure bluff-equity story leveraging the counterfeit board structure.' `
    'Small check-raise leverages the counterfeit dynamic + A-blocker. Mixed defensible vs sizing/opponent tendencies. Folding is reasonable too -- but small barrel + A-blocker on this paired structure rewards the bluff-raise in a balanced strategy.' `
    'Auto-folding A-high on board-paired turns ignores the A-blocker bluff line that this dynamic supports.' `
    'A-high no-draw on board-paired turn = check-raise small (blocker_check_raise on counterfeit dynamic).') `
  -conceptTags @('turn_blocker_pressure','turn_check_raise_bluff','second_barrel_defense') `
  -difficulty 5 `
  -uniquenessNote 'F6 AT blocker bluff distinct from existing F6 AdKh (TPTK bluff-catch with A-blocker) because here hero has NO pair and the A-blocker is the entire bluff backbone on the counterfeit board. Trains blocker_check_raise_turn on board-paired structure where the dynamic is COUNTERFEIT (different from polar brick / overcard / flush-complete blocker bluff structures already in the corpus).'


# ----------------------------------------------------------------
# Final assembly + atomic write
# ----------------------------------------------------------------
$count = $scenarios.Count
"Authored $count v4.3.2 continuation scenarios."

$payload = [PSCustomObject]([ordered]@{
  moduleId      = 'pf_turn_barrel_oop_def'
  moduleName    = 'Facing Turn Barrel OOP'
  version       = 'v4.3.2'
  status        = 'planning_only'
  schemaVersion = '1.2.0'
  generatedAt   = '2026-05-07'
  continuationStats = [ordered]@{
    newScenarioCount        = $count
    baselineProductionTotal = 457
    baselineM4Total         = 72
    finalProductionTarget   = 477
    finalM4Target           = 92
    priority1_reasonChoice  = 8
    priority2_blockerCheckRaise = 2
    priority3_mixed         = 2
    priority4_checkRaiseBig = 1
    newBoardFamilies        = @('F12 (Kc 7s 2d / Qh)','F13 (9c 6c 3h / 8c)')
  }
  notes         = 'v4.3.2 continuation seed candidates. ALL auditStatus=planning_only and reviewStatus=v4.3.2_continuation_candidate; promoted to production via tools/migrate-module4-v4.3.2.ps1 with two-phase staged approval (review_pending then approved). Continuation targets: reason_choice depth (+8), blocker_check_raise_turn depth (+2 action_choice), mixed_indifference_turn depth (+2), check_raise_big (+1 set-on-draw-intensifier), action_choice gap-fills across actionReason buckets, plus 2 NEW board families (F12 Kc 7s 2d / Qh overcard demote, F13 9c 6c 3h / 8c flush-complete on two-tone-to-monotone).'
  scenarios = $scenarios
})

$json = $payload | ConvertTo-Json -Depth 10
$tmp  = "$outPath.tmp"
[System.IO.File]::WriteAllText($tmp, $json, $utf8nb)
Move-Item -LiteralPath $tmp -Destination $outPath -Force
"Wrote $outPath ($([System.IO.File]::ReadAllBytes($outPath).Length) bytes)."
