# ============================================================
# tools/build-m4-polish-v4.3.0D.ps1
# v4.3.0D Module 4 Coverage Polish -- canonical polish builder
#
# Authors NEW v4.3.0D polish seeds ONLY.
# Does NOT touch the original v4.3.0 builder, the v4.3.0C
# expansion builder, or any pre-existing seed JSON.
#
# Output: docs/specs/postflop-v4.3.0D-module4-polish-seeds.json
#
# Source-of-truth rule:
#   - Original 24 reviewed M4 seeds      = v4.3.0  builder canonical.
#   - 29 v4.3.0C expansion seeds          = v4.3.0C builder canonical
#                                           (with v4.3.0C1 hotfix
#                                           applied to 7s6h + 9d6d).
#   - This polish adds NEW scenarios for v4.3.0D coverage targets:
#     blocker_check_raise_turn boost, reason_choice boost, critical
#     density recalibration, consensus_gto promotion of textbook spots.
#   - Polish seeds + expansion seeds + original seeds together form
#     the full M4 planning corpus.
#
# Safety:
#   - ASCII-only (no em-dash, no special unicode)
#   - No Invoke-Expression
#   - No Remove-Item on production-adjacent paths
#   - Atomic write via tmp + Move-Item to polish JSON only
# ============================================================

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$outPath  = Join-Path $repoRoot 'docs\specs\postflop-v4.3.0D-module4-polish-seeds.json'

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
# Helper builders (mirror v4.3.0C builder shape)
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
    reviewStatus      = 'v4.3.0D_polish_candidate'
    uniquenessNote    = $uniquenessNote
  })
}
function Q-Action($hero, $boardStr, $turn) {
  # NOTE: ${hero} braces required (PowerShell parses '$hero?' as variable name 'hero?').
  return New-Question 'action_choice' "Flop $boardStr; turn $turn. BTN c-bet small flop, BB called, BTN now barrels. What is BB's best action with ${hero}?" $actionChoices
}
function Q-Reason($action, $hero, $boardStr, $turn) {
  return New-Question 'reason_choice' "Flop $boardStr; turn $turn. BB ${action} with ${hero} vs BTN's turn barrel. What is the primary reason?" $reasonChoices
}
function BoardStr($cards) { return ($cards -join ' ') }


# ====== Boards (9 existing families re-declared + 1 new family F11) ======

# Family 1: Brick after A-high dry (Ac 7d 2s, 4h)  -- existing
$f1Flop = @('Ac','7d','2s'); $f1Turn = '4h'
$f1 = New-Board $f1Flop $f1Turn 'A_high' 'A_high' 'rainbow' 'rainbow' @('dry','disconnected') 'brick' 'brick' 'neutral' 'none' 'no_change'
$f1Str = BoardStr $f1Flop

# Family 2: BB-favored Q overcard (8d 6c 3s, Qh)  -- existing
$f2Flop = @('8d','6c','3s'); $f2Turn = 'Qh'
$f2 = New-Board $f2Flop $f2Turn 'low' 'Q_high' 'rainbow' 'rainbow' @('dry','semi_connected') 'overcard' 'range_shift_bb' 'favors_bb' 'none' 'no_change'
$f2Str = BoardStr $f2Flop

# Family 3: Ace overcard after K-high (Kd 8c 4s, Ah)  -- existing
$f3Flop = @('Kd','8c','4s'); $f3Turn = 'Ah'
$f3 = New-Board $f3Flop $f3Turn 'K_high' 'A_high' 'rainbow' 'rainbow' @('dry','disconnected') 'overcard' 'range_shift_btn' 'favors_btn' 'none' 'no_change'
$f3Str = BoardStr $f3Flop

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

# Family 8: Draw-intensifier (Ts 8s 4d, 7c)  -- existing
$f8Flop = @('Ts','8s','4d'); $f8Turn = '7c'
$f8 = New-Board $f8Flop $f8Turn 'T_high' 'T_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'draw_intensifier' 'draw_added' 'improves_bb_draws' 'oesd_added' 'no_change'
$f8Str = BoardStr $f8Flop

# Family 9: Multi-FD turn (Ah 9d 4d, 7h)  -- existing
$f9Flop = @('Ah','9d','4d'); $f9Turn = '7h'
$f9 = New-Board $f9Flop $f9Turn 'A_high' 'A_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'draw_intensifier' 'draw_added' 'improves_bb_draws' 'gutshot_added' 'no_change'
$f9Str = BoardStr $f9Flop

# Family 10: Polarizing brick after dynamic flop (Jd Td 5s, 2c)  -- existing
$f10Flop = @('Jd','Td','5s'); $f10Turn = '2c'
$f10 = New-Board $f10Flop $f10Turn 'J_high' 'J_high' 'two_tone' 'two_tone' @('wet','semi_connected') 'brick' 'brick' 'neutral' 'none' 'no_change'
$f10Str = BoardStr $f10Flop

# Family 11 (NEW for v4.3.0D): Low BB-favored straight complete (7s 5d 3h, 4c)
# Flop 7s 5d 3h is rainbow low semi-connected; turn 4c lands the
# bottom-end one-card straight (any 6 makes 3-4-5-6-7). Range strongly
# favors BB because BB call range contains 65/64/A2/A3/64s wheel hands
# while BTN open range is much narrower in that connector zone.
$f11Flop = @('7s','5d','3h'); $f11Turn = '4c'
$f11 = New-Board $f11Flop $f11Turn 'low' 'low' 'rainbow' 'rainbow' @('wet','semi_connected') 'straight_complete' 'polarizing' 'favors_bb' 'straight_completed' 'no_change'
$f11Str = BoardStr $f11Flop


# ====== Polish scenarios (19 total) ======
$scenarios = @()


# ---------- ACTION_CHOICE polish (12) ----------

# A1 -- F4 (Qs 8s 4d, 2s): KsQc TPTK + 2nd-nut spade FD redraw on flush-complete turn -- bluff-catch
# Distinct from existing F4 AsKc (call with NUT spade blocker) -- here hero has K-blocker = 2nd-nut FD,
# materially different fold-equity vs villain Ax-of-spade combos.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs8s4d_2s_m4_action_KsQc_v430D' `
  -board $f4 -heroHand @('Ks','Qc') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'flush_draw' -showdownValue 'high' `
  -blockerNote 'Ks gives K-high spade FD redraw (2nd-nut, since Ax-of-spade is still possible in villain range).' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action 'Ks Qc' $f4Str '2s') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @()) `
  -explanation (New-Explanation `
    'TPTK with K-high spade redraw on flush-complete turn -- call (bluff-catch).' `
    '2s makes the 3rd spade. Hero has TPTK (Q-pair, K kicker) plus K-high spade FD via Ks (board has Qs+8s+2s+Ks = 4 spades; need 1 more for K-high flush). Loses to Ax-of-spades flush combos but blocks all KQ/QQ value combos and beats every Q-x non-spade-flush bet.' `
    'BB flop call with KQ-suited on Q-8-4 was natural (TPTK + BDFD spade). Turn 2s lands the FD on top of TPTK.' `
    'KsQc has TPTK + K-high FD redraw + reduced Ax-flush combos via the Ks blocker. ~30% equity vs villain barrel range.' `
    'Calling captures villain bluffs and keeps the 2nd-nut FD alive. Raising folds out bluffs and isolates against Ax-of-spades flushes.' `
    'Folding TPTK with FD redraw vs small barrel under-defends the BB calling range.' `
    'TPTK + 2nd-nut FD on flush-complete turn = call (bluff-catch + redraw).') `
  -conceptTags @('turn_bluff_catcher','turn_blocker_pressure','turn_draw_completion') `
  -difficulty 4 `
  -uniquenessNote 'Bluff-catch with 2ND-nut FD blocker (Ks) on F4 flush-complete board. Distinct from existing F4 AsKc (NUT spade blocker, no made hand) because here hero has BOTH made TPTK AND 2nd-nut FD redraw -- different value/draw mix and different fold-equity calculation.'

# A2 -- F5 (9s 8d 4c, 7h): TT overpair + OESD on BB-favored straight-complete turn
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_9s8d4c_7h_m4_action_TsTc_v430D' `
  -board $f5 -heroHand @('Ts','Tc') `
  -handClass 'overpair' -heroHandRole 'combo_draw' -drawCategory 'oesd' -showdownValue 'high' `
  -blockerNote 'Hero overpair plus OESD (7-8-9-T) needing 6 or J = 8 outs to straight, plus 2 outs to set-of-Tens.' `
  -recommendedAction 'call' -actionReason 'equity_realization_turn_call' `
  -question (Q-Action 'Ts Tc' $f5Str '7h') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @()) `
  -explanation (New-Explanation `
    'Overpair TT + OESD on BB-favored straight-complete turn -- call (multi-source equity).' `
    '7h adds OESD: hero+board has 4,7,8,9,T,T = 7-8-9-T four consecutive + need 6 or J for straight = 8 outs, plus 2 outs to set of Ts and pair-of-board outs. The 7 also turns BB range into the value-favored side, so villain barrel range is more polarized.' `
    'BB flop call with TT on 9-8-4 was natural (overpair to flop, with backdoor reach). Turn 7 keeps the overpair AND lands the OESD on top.' `
    'TsTc has overpair to all four board ranks plus open-ender (8 straight outs) plus 2 set outs. ~35% one-card equity vs villain barrel range.' `
    'Calling realizes multi-source equity at small price. Raising folds out bluffs and bloats vs already-made straights (J9, T6 specific combos).' `
    'Folding overpair-plus-OESD vs small barrel under-defends BB range and abandons real equity.' `
    'Overpair + OESD on straight-complete turn = call (multi-source equity).') `
  -conceptTags @('turn_pot_odds','turn_equity_shift','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Combo-equity call on F5 with overpair PLUS open-ender. Distinct from existing F5 JhTh (made J-high straight, value raise) and AhAd (overpair-only mixed) because here hero has overpair AND a strong draw on top -- different equity-realization calculation.'

# A3 -- F6 (Kd 8s 3c, 8h): JJ underpair vs board-pair K-high turn -- domination/range fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8s3c_8h_m4_action_JsJd_v430D' `
  -board $f6 -heroHand @('Js','Jd') `
  -handClass 'underpair' -heroHandRole 'dominated_marginal' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_turn_fold' `
  -question (Q-Action 'Js Jd' $f6Str '8h') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'JJ underpair on board-paired K-high turn -- fold; hero is below villain barrel range.' `
    '8h pairs the flop 8 -- counterfeits hero pair below the K and adds 8x trip combos to villain range. Hero JJ now sits below K-pair, A-overcards (with sequencing equity), AND any 8x trip combo (88/A8/K8). Vs villain barrel range that is Kx-heavy plus turned trips, JJ is dominated.' `
    'BB flop call with JJ on K-8-3 was thin (underpair to top, no draw, only set outs). Turn 8 doubles up the existing 8 and worsens hero range position significantly.' `
    'JsJd has underpair to K with no draw, no relevant blocker, and hero is dominated by Kx, 8x, and overpairs. Only 2 outs to set-of-Js.' `
    'Folding closes action; calling pays off Kx + 8x value range while only beating air. Raising commits chips into a dominated range.' `
    'Stationing underpairs vs board-pair turns is a textbook leak; the pair counterfeits range upward.' `
    'Underpair on board-pair turn vs Kx-heavy barrel = fold (range disadvantage + counterfeit).') `
  -conceptTags @('turn_range_disadvantage','turn_board_change','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Underpair-on-board-paired-board fold lesson distinct from existing F6 AdKh (TPTK boat draw) and F6 KsKc (top boat) because here hero has the WEAKEST overpair-relative-to-board (still below K) AND is hit by counterfeit -- different loss vector.'

# A4 -- F6 (Kd 8s 3c, 8h): AdKh TPTK on board-paired K-high turn -- bluff-catch
# consensus_gto: textbook TPTK bluff-catch on counterfeit turn.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8s3c_8h_m4_action_AdKh_v430D' `
  -board $f6 -heroHand @('Ad','Kh') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'A-blocker reduces villain AA value combos; Kh gives top pair top kicker on a paired board.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Action 'Ad Kh' $f6Str '8h') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'TPTK with A-blocker on board-paired K-high turn -- call (bluff-catch).' `
    '8h pairs the flop 8 but does not change hero best showdown: TPTK (K-pair, A kicker) still beats Kx-with-weaker-kicker, all underpairs, and air. Loses to 88 and A8/K8 trip combos but A-blocker reduces AA combos and the K-pair is still range-top vs villain barrel range.' `
    'BB flop call with AK-suited on K-8-3 made TPTK on the flop. Turn 8 pairs and adds trip threats but does not demote TPTK below the villain range top.' `
    'AdKh has TPTK with A kicker (top kicker possible) plus A-blocker reducing AA combos. Beats Kx-weaker, underpairs, air. Loses to 88, A8, K8 trips.' `
    'Calling captures villain bluffs and air. Raising folds out bluffs and isolates against trips. Folding the absolute top of bluff-catcher range over-folds vs a polarized barrel.' `
    'Folding TPTK with A-blocker on board-paired turns over-folds the BB range top.' `
    'TPTK + A-blocker on board-paired turn = call (textbook bluff-catch).') `
  -conceptTags @('turn_bluff_catcher','turn_blocker_pressure','turn_board_change') `
  -difficulty 3 `
  -sourceConfidence 'consensus_gto' `
  -uniquenessNote 'Textbook TPTK-with-A-blocker bluff-catch on board-paired K-high turn. Distinct from F4/F9 TPTK calls because the board structure is paired-board (counterfeit pattern), not flush-complete or multi-FD; tests bluff-catch reasoning under the counterfeit threat specifically.'

# A5 -- F7 (Qs 7d 3c, 3h): AhQc TPTK + A-blocker on board-paired low turn
# consensus_gto: textbook TPTK on second-paired low turn.
# Hero hand AhQc avoids Qs board-collision; A-heart blocker reduces AA combos.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs7d3c_3h_m4_action_AhQc_v430D' `
  -board $f7 -heroHand @('Ah','Qc') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'A-heart blocker reduces villain AA combos; TPTK with the absolute top kicker on Q-high paired-low turn.' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action 'Ah Qc' $f7Str '3h') `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'TPTK + A-blocker on board-paired low turn -- check-raise small for value.' `
    '3h pairs the flop 3 but the second-pair is below TPTK and irrelevant to hero hand strength. Villain barrel range is Q-x-and-down value plus air; hero has TPTK with the absolute top kicker (A) plus A-heart blocker reducing AA combos. Only 33 (set), 77 (set), 7-x trips, QQ (overpair) beat hero.' `
    'BB flop call with AQ-offsuit on Q-7-3 was natural (TPTK). Turn 3 doubles up the second board card but does not threaten TPTK seriously.' `
    'AhQc has TPTK with A kicker plus A-blocker reducing AA combos. Beats Q-weak-kicker, all underpairs, air, and turned trips of 3 (very rare combo for villain). Loses to 33/77/7-x trips/QQ overpair.' `
    'Small check-raise charges Qx weaker kickers and turns villain bluffs into folding equity. Big raise risks too much vs the rare set/trips. Calling preserves bluffs but surrenders value.' `
    'Slowplaying TPTK with the absolute top kicker on a paired-low turn surrenders chips that worse Qx pays off.' `
    'TPTK with A kicker on second-paired low turn = check-raise small for value.') `
  -conceptTags @('turn_check_raise_value','turn_blocker_pressure','second_barrel_defense') `
  -difficulty 3 `
  -sourceConfidence 'consensus_gto' `
  -uniquenessNote 'Textbook TPTK value-raise on F7 board-paired LOW turn. Distinct from existing F7 AhAd (overpair value-raise) and 7s7c (slowplay set-of-7s) because here hero has TPTK without the slowplay incentive AND the second-paired card is below TPTK -- different sizing reasoning.'

# A6 -- F8 (Ts 8s 4d, 7c): JsJh overpair + spade BDFD on draw-intensifier turn
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_action_JsJh_v430D' `
  -board $f8 -heroHand @('Js','Jh') `
  -handClass 'overpair' -heroHandRole 'strong_value' -drawCategory 'backdoor_only' -showdownValue 'high' `
  -blockerNote 'Js blocks one J9 combo (the most threatening straight-completing combo) and gives a J-high spade backdoor.' `
  -recommendedAction 'check_raise_small' -actionReason 'protection_check_raise_turn' `
  -question (Q-Action 'Js Jh' $f8Str '7c') `
  -answer (New-Answer 'check_raise_small' @('call','check_raise_big') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Overpair JJ with J9-straight-blocker on draw-intensifier turn -- check-raise small for protection.' `
    '7c is a draw-intensifier: villain barrel range now includes OESDs (98, J9), gutshots (65, 96), and FDs (spade combos). Hero JJ is overpair to all four board ranks (J > T) plus Js blocks one of the four J9 combos that make the J-high straight on the river. Many bad rivers (any spade, any J/9/T/8 helping draws) make hero re-evaluate; raising NOW charges draws and air.' `
    'BB flop call with JJ on T-8-4 was thin (overpair-to-T, no FD, no draw). Turn 7 adds straight threats; hero must decide between protection raise vs trapped slowplay -- raise wins because draws have meaningful equity vs JJ.' `
    'JsJh has overpair JJ plus J-spade-blocker reducing nut FD combos and J9-straight combos. Loses to TT/88/44 sets, T-x two-pair, made straights (J9 specifically; hero blocks 1 of 4). Beats Tx, weaker pairs, air.' `
    'Small check-raise charges flush draws, OESDs, gutshots, and air. Big raise also defensible given draw density. Calling commits hero to a tough river decision when a draw-completing card lands.' `
    'Slowplaying overpair on draw-intensifier turn lets villain realize FREE equity with draws.' `
    'Overpair with straight-blocker on dynamic turn = check-raise small for protection.') `
  -conceptTags @('turn_check_raise_value','turn_blocker_pressure','turn_equity_shift') `
  -difficulty 3 `
  -uniquenessNote 'Protection-raise with overpair + key straight-blocker on F8 draw-intensifier. Distinct from F8 9c8c (semi-bluff with pair-of-8 + OESD) and from F8 9d6d (made straight value-raise) because hero has OVERPAIR with no draw equity -- different protection-vs-value mix.'

# A7 -- F9 (Ah 9d 4d, 7h): AsKs TPTK + A-blocker on multi-FD turn -- value raise
# consensus_gto: textbook TPTK+blocker value-raise on multi-draw turn.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ah9d4d_7h_m4_action_AsKs_v430D' `
  -board $f9 -heroHand @('As','Ks') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'strong_value' -drawCategory 'backdoor_only' -showdownValue 'high' `
  -blockerNote 'A-blocker reduces villain AA + AK value; spade backdoor is dead since flop and turn are diamond/heart based, but A-pair still tops the bluff-catcher region.' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action 'As Ks' $f9Str '7h') `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'TPTK with A-blocker on multi-FD turn -- check-raise small for value.' `
    '7h adds heart-FD threats AND straight-draw threats (5-6, 6-8 combos). Hero TPTK (A-pair, K kicker) is still the top of the made-hand region; A-blocker reduces villain AA and AK combos. Many turn-FD combos pay off the raise; folding them gives them free equity.' `
    'BB flop call with AKs on A-9-4 with backdoor diamond was natural (TPTK + BDFD). Turn 7 keeps TPTK and adds heart-FD threats to villain range; raise NOW for value while villain still calls with weaker Ax / draws.' `
    'AsKs has TPTK with K kicker, A-blocker reducing AA combos, and A-spade-blocker reducing nut FD combos. Beats AQ/AJ/AT/A-weak, all sets are blocker-light, all draws. Loses to AA/A9/A4/two-pair/sets (rare).' `
    'Small check-raise charges weaker Ax, all draws, and turns villain barrel bluffs into folding equity. Big raise risks too much vs the rare two-pair/set on a wet turn. Calling preserves bluffs but lets draws realize equity.' `
    'Slowplaying TPTK with A-blocker on multi-FD turn surrenders value vs draws that pay off the raise.' `
    'TPTK + A-blocker on multi-FD turn = check-raise small for value.') `
  -conceptTags @('turn_check_raise_value','turn_blocker_pressure','turn_equity_shift') `
  -difficulty 3 `
  -sourceConfidence 'consensus_gto' `
  -uniquenessNote 'Textbook TPTK+A-blocker value-raise on F9 multi-FD turn. Distinct from F9 AsTs (TPGK bluff-catch with A-blocker; KICKER difference shifts to call) and KdQd (2nd-nut FD with overcards) -- here hero has TPTK with TOP KICKER making this a clear value-raise rather than bluff-catch.'

# A8 -- F10 (Jd Td 5s, 2c): JhJs set of jacks on polar brick turn
# consensus_gto: textbook set value-raise.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_JdTd5s_2c_m4_action_JhJs_v430D' `
  -board $f10 -heroHand @('Jh','Js') `
  -handClass 'set' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Top set of jacks; blocks the highest pair and reduces JT-two-pair combos (hero has both remaining Jx).' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action 'Jh Js' $f10Str '2c') `
  -answer (New-Answer 'check_raise_small' @('check_raise_big') @('fold','call','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Top set of jacks on polar brick turn -- check-raise small for value.' `
    '2c is a brick. Hero set of jacks beats every made hand except QQ (rare BTN preflop range) and turned straights from villain holding 89 (slim flop call combos for 89). Polar brick favors raising to charge value-region hands plus bluffs while villain has not yet given up.' `
    'BB flop call with JJ on J-T-5 was natural (top set, heavy flop check-call). Turn 2 brick keeps hero ahead of every continuation and adds zero meaningful threats.' `
    'JhJs makes top set of jacks. Loses only to QQ (rare) and 89 made straight (rare combo on flop call). Beats every Tx, every overpair below QQ, every two-pair, every draw.' `
    'Small check-raise charges weaker Tx/overpairs/draws while keeping bluffs in. Big raise also defensible vs villain who calls big with TT/T9-suited two-pair. Calling slowplays -- acceptable but lets draws realize free equity vs the rare turn river.' `
    'Auto-calling top set on polar brick turns surrenders value vs villain Tx and overpair pay-offs.' `
    'Top set on polar brick turn = check-raise small for value.') `
  -conceptTags @('turn_check_raise_value','second_barrel_defense','turn_blocker_pressure') `
  -difficulty 2 `
  -sourceConfidence 'consensus_gto' `
  -uniquenessNote 'Textbook top-set value-raise on F10 polar brick. Distinct from F10 AhAd (overpair on polar brick, value raise) and 9c9d (mixed underpair) because hero has the absolute nut hand with no concern about runout.'

# A9 -- F10 (Jd Td 5s, 2c): KsKh overpair on polar brick turn
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_JdTd5s_2c_m4_action_KsKh_v430D' `
  -board $f10 -heroHand @('Ks','Kh') `
  -handClass 'overpair' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Overpair KK with no spade redraw (board only has 5s spade); blocks 0 of villain key combos but tops every J-x value combo.' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action 'Ks Kh' $f10Str '2c') `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Overpair KK on polar brick turn -- check-raise small for value.' `
    '2c is a brick. Hero KK is overpair to J (highest board) and beats every Jx, every Tx, every smaller pair, every draw. Loses only to AA, JJ/TT/55/22 sets, and 89 made straight -- combined a small fraction of villain barrel range.' `
    'BB flop call with KK on J-T-5 was thin (overpair to flop, no draw). Turn 2 brick is harmless and the polar dynamic favors charging Jx.' `
    'KsKh has overpair KK below AA only. Beats Jx, Tx, weaker pairs, air, draws. Loses to AA, sets (rare), and 89 made straight (rare combo).' `
    'Small check-raise charges Jx, weaker pairs, and draws while keeping bluffs in. Calling slowplays acceptable but surrenders value vs villain Jx call-down. Big raise risks too much vs sets.' `
    'Folding KK overpair on polar brick because of "the J top pair on board" misreads villain range and over-folds the BB region top.' `
    'Overpair below only AA on polar brick = check-raise small for value.') `
  -conceptTags @('turn_check_raise_value','second_barrel_defense','turn_range_disadvantage') `
  -difficulty 3 `
  -uniquenessNote 'Overpair-just-below-AA value-raise on F10 polar brick. Distinct from F10 AhAd (THE top overpair) and JhJs set because KK is a NON-NUT overpair that still has clear value-raise structure -- different threshold lesson.'

# A10 -- F11 NEW (7s 5d 3h, 4c): 6h6d set + made wheel-adjacent straight on low BB-favored turn
# consensus_gto: hero makes 7-high straight (3-4-5-6-7) plus pair on low straight-complete board.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_7s5d3h_4c_m4_action_6h6d_v430D' `
  -board $f11 -heroHand @('6h','6d') `
  -handClass 'straight' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Hero made 7-high straight (3-4-5-6-7) using one of two pocket sixes. Loses only to 8-high straight (4-5-6-7-8) requiring villain to hold 86 or 8X.' `
  -recommendedAction 'check_raise_small' -actionReason 'value_check_raise_turn' `
  -question (Q-Action '6h 6d' $f11Str '4c') `
  -answer (New-Answer 'check_raise_small' @('check_raise_big','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    '7-high straight (3-4-5-6-7) on low BB-favored straight-complete turn -- check-raise small for value.' `
    '4c lands the bottom-end straight: any 6 makes 3-4-5-6-7. Hero 66 makes the made 7-high straight directly. Range strongly favors BB (BB call range contains 65, 64s, A2-A4, 6x suited; BTN open range is much narrower in low connectors). Higher straight (4-5-6-7-8) requires villain to hold 8x with a 6 or specific 86 -- rare combo on flop call.' `
    'BB flop call with 66 on 7-5-3 was thin (underpair to 7, gutshot to 4 for the wheel). Turn 4 lands the wheel-adjacent straight directly via the existing pocket pair.' `
    '6h6d makes 3-4-5-6-7 = 7-high straight. Loses to 4-5-6-7-8 (requires villain 8x; uncommon BTN combo with hero blocking one 6). Beats every set, every two-pair, every weaker straight (none higher except the 8-high), all draws.' `
    'Small check-raise charges 7x value, sets, two-pair, all draws. Big raise also defensible vs sets that may stack off. Calling slowplays but lets sky-rivers (any 8) potentially counterfeit.' `
    'Slowplaying made straight on low straight-complete turn lets the higher-straight river (any 8) potentially redirect the pot.' `
    'Made 7-high straight on low BB-favored straight-complete turn = check-raise small for value.') `
  -conceptTags @('turn_check_raise_value','turn_draw_completion','second_barrel_defense') `
  -difficulty 2 `
  -sourceConfidence 'consensus_gto' `
  -uniquenessNote 'NEW BOARD F11. Made-straight value-raise via low-pocket-pair on bottom-end straight-complete turn. Distinct from F5 JhTh (J-high straight via JT-suited on 9-8-4-7) because here the straight forms via 66+wheel-board rather than connecting middle-cards -- different combo coverage and different range-advantage shape.'

# A11 -- F11 (7s 5d 3h, 4c): 8d7d OESD + pair-of-7 on low BB-favored turn -- equity realization
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_7s5d3h_4c_m4_action_8d7d_v430D' `
  -board $f11 -heroHand @('8d','7d') `
  -handClass 'oesd' -heroHandRole 'combo_draw' -drawCategory 'oesd' -showdownValue 'decent' `
  -blockerNote 'Pair of 7s + OESD: hero+board has 3,4,5,7,8 with one 7. 4-5-6-7-8 needs 6; 5-6-7-8-9 needs 6 or 9; combined gives OESD via 6 (8 outs minus shared) plus pair-7 outs.' `
  -recommendedAction 'call' -actionReason 'equity_realization_turn_call' `
  -question (Q-Action '8d 7d' $f11Str '4c') `
  -answer (New-Answer 'call' @('check_raise_small','mixed') @('fold','check_raise_big') @()) `
  -explanation (New-Explanation `
    'Pair-of-7 + OESD via 6 on low BB-favored turn -- call (multi-source equity).' `
    '4c adds OESD: hero+board ranks 3,4,5,7,8 with hero pair of 7s. 4-5-6-7-8 needs 6 (4 outs); 5-6-7-8-9 needs 6 OR 9 (extra outs to 9 since hero already pair). Combined ~10 effective outs counting pair improvements; ~22% one-card equity vs villain barrel range.' `
    'BB flop call with 87-suited on 7-5-3 was natural (top pair + diamond backdoor + slim straight reach). Turn 4 lands the OESD on top of pair.' `
    '8d7d has pair of 7 plus OESD-to-6 plus 9-river-pair improvement. Multi-source equity earns the call vs polarized barrel.' `
    'Calling realizes equity at small price. Small check-raise also defensible as semi-bluff vs over-bluffy villain. Folding combo equity OOP under-defends BB range.' `
    'Folding pair-plus-OESD vs small barrel under-defends and abandons real combo equity.' `
    'Pair + OESD on low straight-complete turn = call (multi-source equity).') `
  -conceptTags @('turn_pot_odds','turn_equity_shift','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'NEW BOARD F11. Combo-equity call with pair + OESD on low BB-favored turn. Distinct from F11 6h6d (made straight value-raise) and from F5 TT+OESD (overpair plus OESD) because here hero has WEAKER pair (7-pair) plus OESD with different out structure.'

# A12 -- F11 (7s 5d 3h, 4c): KsTd no pair no draw on low BB-favored turn -- range fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_7s5d3h_4c_m4_action_KsTd_v430D' `
  -board $f11 -heroHand @('Ks','Td') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_turn_fold' `
  -question (Q-Action 'Ks Td' $f11Str '4c') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'KT no pair no draw on low BB-favored straight-complete turn -- fold (range disadvantage).' `
    '4c is a polar straight-complete card on a low BB-favored board. Villain barrel range is wedged: either made-straight value (any 6, plus rare 8x for 8-high) or air. Hero KT has zero pair outs that beat anything in villain value range (K or T pair on river still loses to made straights). No flush draw, no straight draw.' `
    'BB flop call with KT-offsuit on 7-5-3 was already thin (two overcards, no draw). Turn 4 makes the spot hopeless.' `
    'KsTd has zero made-hand value, no FD, no straight draw, no relevant blocker. The 6 overcard outs to K-pair or T-pair are dominated by the made-straight portion of villain range and irrelevant vs villain air bucket.' `
    'Folding closes action; calling chases dominated outs; raising commits to a bluff with no equity backbone on a board where BB range advantage gets exposed by the bluff.' `
    'Continuing two overcards on low BB-favored straight turns because of "outs to K or T" misreads the villain range structure.' `
    'Naked overcards on low straight-complete BB-favored turn = fold.') `
  -conceptTags @('turn_range_disadvantage','turn_domination_fold','second_barrel_defense') `
  -difficulty 2 `
  -uniquenessNote 'NEW BOARD F11. Naked-overcards-no-draw fold on low BB-favored straight-complete turn. Distinct from F1 KdJc (overcards fold on A-high brick) and F8 KsQc (similar fold on T-high draw-intensifier) because here BB range advantage CHANGES the calculation -- BB is favored but hero specifically is NOT in the favored portion.'


# ---------- REASON_CHOICE polish (7) ----------

# R1 -- F4 (Qs 8s 4d, 2s): As9c blocker bluff on flush-complete turn
# This is a textbook blocker_check_raise_turn spot.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Qs8s4d_2s_m4_reason_As9c_v430D' `
  -board $f4 -heroHand @('As','9c') `
  -handClass 'nut_flush_draw' -heroHandRole 'blocker_bluff' -drawCategory 'nut_flush_draw' -showdownValue 'low' `
  -blockerNote 'As gives the nut spade blocker AND a 1-card nut spade redraw on river (board has 3 spades + hero As = 4 spades; need 1 more for the absolute nuts).' `
  -recommendedAction 'check_raise_small' -actionReason 'blocker_check_raise_turn' `
  -question (Q-Reason 'check-raises small' 'As 9c' $f4Str '2s') `
  -answer (New-Answer 'blocker_check_raise_turn' @('semi_bluff_check_raise_turn') @('value_check_raise_turn','protection_check_raise_turn','bluff_catch_turn','equity_realization_turn_call','pot_odds_turn_call') @()) `
  -explanation (New-Explanation `
    'As blocker bluff on flush-complete turn -- primary reason is BLOCKER pressure (with nut FD as secondary backup).' `
    '2s makes the 3rd spade. Villain barrel range that continues vs a check-raise is dominated by Ax-of-spades (nut flushes) and Qx with redraw. Hero As removes EVERY nut-flush combo from villain calling range, AND hero has the 1-card nut FD redraw if a 4th spade lands on the river (~9 outs, ~17%).' `
    'BB flop call with A9-offsuit on Q-8-4 was thin (single A-overcard plus backdoor spade). Turn 2s simultaneously creates the flush threat (villain range) AND lands the nut spade redraw (hero), making the blocker bluff structurally sound.' `
    'As9c has no made hand. The 9c does no work. The strategic engine is the As blocker effect on villain calling range; the 1-card nut FD redraw is secondary equity. ~17% straight equity from the nut FD plus ~50% blocker fold-equity uplift.' `
    'Small check-raise leverages the blocker primarily. Big raise risks too much without made-hand backbone. Calling concedes the spot. The PRIMARY reason is BLOCKER pressure, not semi-bluff -- semi_bluff_check_raise_turn is acceptable but secondary because the made-hand-replacement value is the blocker, not the draw.' `
    'Misclassifying this as semi-bluff first frames the raise around the 17% draw rather than the ~50% fold equity from the blocker; the diagnostic ranks blocker first, draw second.' `
    'Nut-suit blocker plus nut FD on flush-complete turn = textbook blocker_check_raise_turn (semi-bluff is acceptable but secondary).') `
  -conceptTags @('turn_blocker_pressure','turn_check_raise_bluff','turn_draw_completion') `
  -difficulty 5 `
  -uniquenessNote 'TEXTBOOK blocker_check_raise_turn on F4 flush-complete board. Distinct from existing F4 As9s (NUT FLUSH made hand, value raise) and AsKc (bluff-catch with same A-blocker) because here hero has NO MADE HAND (only nut FD) -- the action lives on the blocker plus draw redraw, with blocker being primary.'

# R2 -- F3 (Kd 8c 4s, Ah): As6c blocker bluff on A-overcard turn
# Second blocker_check_raise_turn spot, distinct from R1 (different blocker engine: A blocks AA-trips on overcard turn).
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Kd8c4s_Ah_m4_reason_As6c_v430D' `
  -board $f3 -heroHand @('As','6c') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote 'As blocks AA value combos on the A-overcard turn AND blocks every Ax that turned a pair (AK, AQ, AJ, AT, A8, A4 etc.) -- removes the densest portion of villain calling range.' `
  -recommendedAction 'check_raise_small' -actionReason 'blocker_check_raise_turn' `
  -question (Q-Reason 'check-raises small' 'As 6c' $f3Str 'Ah') `
  -answer (New-Answer 'blocker_check_raise_turn' @('semi_bluff_check_raise_turn') @('value_check_raise_turn','protection_check_raise_turn','bluff_catch_turn','equity_realization_turn_call','pot_odds_turn_call') @()) `
  -explanation (New-Explanation `
    'As blocker bluff on A-overcard turn -- primary reason is BLOCKER pressure on villain Ax range.' `
    'Ah on K-8-4 demotes hero pair candidates and brings every Ax into villain barrel range (AK/AQ/AJ/AT/A8/A4). Hero As removes one ace from villain entire Ax region -- the dominant portion of villain barrel range that would call a check-raise. Plus AA combos drop from 6 to 1.' `
    'BB flop call with A6-offsuit on K-8-4 was thin (A-blocker + backdoor reach but no immediate value). Turn A creates the blocker-bluff opportunity by amplifying the Ax-density in villain range.' `
    'As6c has no pair, no draw, no real outs. The 6c does no work. The raise is entirely about removing villain Ax / AA combos from the calling range.' `
    'Small check-raise leverages the blocker effect on Ax-density. Big raise risks too much without made-hand backbone. Calling pays off Ax. The reason is NOT semi-bluff (no draw) and NOT bluff-catch (hero has no showdown value).' `
    'Confusing the A-blocker bluff with semi-bluff or value-raise misreads the strategic engine -- the raise lives entirely on the blocker.' `
    'A-blocker on A-overcard turn vs Ax-heavy barrel = textbook blocker_check_raise_turn.') `
  -conceptTags @('turn_blocker_pressure','turn_check_raise_bluff','turn_board_change') `
  -difficulty 5 `
  -uniquenessNote 'SECOND blocker_check_raise_turn spot. Distinct from R1 (As9c on F4 flush-complete) and from F2 AsJd (existing nut-spade blocker bluff on Ks 8s 3d 2s flush board). Here the blocker engine is A-on-A-overcard-turn (Ax-density removal), not nut-flush blocker -- different conceptual mechanism.'

# R3 -- F1 (Ac 7d 2s, 4h): AdJc TPGK + A-blocker on A-high brick -- bluff catch
# consensus_gto: textbook TPGK bluff-catch on dry brick.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_reason_AdJc_v430D' `
  -board $f1 -heroHand @('Ad','Jc') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'A-pair with J kicker plus A-blocker reducing AA / AK / AQ value combos.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_turn' `
  -question (Q-Reason 'calls' 'Ad Jc' $f1Str '4h') `
  -answer (New-Answer 'bluff_catch_turn' @('range_disadvantage_turn_fold') @('value_check_raise_turn','protection_check_raise_turn','blocker_check_raise_turn','semi_bluff_check_raise_turn','pot_odds_turn_call','equity_realization_turn_call') @()) `
  -explanation (New-Explanation `
    'TPGK with A-blocker on A-high dry brick -- primary reason is BLUFF-CATCH (showdown value vs polarized barrel).' `
    '4h is a brick that does not change ranges. Hero TPGK (A-pair, J kicker) has clean showdown value vs villain barrel range that is polarized into Ax-with-better-kicker (AK/AQ) and air. The A-blocker reduces villain better-kicker combos.' `
    'BB flop call with AJ-offsuit on A-7-2 was natural (TPGK + A-blocker). Turn 4 brick keeps the spot exactly the same -- a clean bluff-catch decision.' `
    'AdJc has TPGK with J kicker and A-blocker reducing AA/AK/AQ combos. Beats Ax-weaker (A2-A8 if any), 77/22 (rare), bluffs. Loses to AK/AQ.' `
    'Calling captures villain bluff frequency. The reason is NOT pot odds (no draw) and NOT range disadvantage (BB has mid-pair-plus region this barrel reaches). The strategic engine is BLUFF-CATCH with showdown value.' `
    'Misclassifying TPGK on dry brick as range-disadvantage-fold over-folds the BB region top.' `
    'TPGK + A-blocker on A-high brick vs barrel = textbook bluff_catch_turn.') `
  -conceptTags @('turn_bluff_catcher','turn_blocker_pressure','second_barrel_defense') `
  -difficulty 3 `
  -sourceConfidence 'consensus_gto' `
  -uniquenessNote 'TEXTBOOK bluff-catch reason_choice on F1 brick board. Distinct from existing F1 9c9d (mixed underpair, different reason) and KdJc (domination fold). The reason here is specifically BLUFF-CATCH with TPGK+blocker, testing the diagnostic difference vs range_disadvantage_fold (the seductive wrong answer).'

# R4 -- F8 (Ts 8s 4d, 7c): KsQc no-pair-no-draw on draw-intensifier -- domination fold
# consensus_gto: textbook overcards-fold on dynamic turn.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_reason_KsQc_v430D' `
  -board $f8 -heroHand @('Ks','Qc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'backdoor_only' -showdownValue 'none' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'domination_turn_fold' `
  -question (Q-Reason 'folds' 'Ks Qc' $f8Str '7c') `
  -answer (New-Answer 'domination_turn_fold' @('range_disadvantage_turn_fold') @('value_check_raise_turn','protection_check_raise_turn','blocker_check_raise_turn','semi_bluff_check_raise_turn','bluff_catch_turn','equity_realization_turn_call','pot_odds_turn_call') @()) `
  -explanation (New-Explanation `
    'KQ no pair no draw on draw-intensifier turn -- primary reason is DOMINATION (pair outs are dominated).' `
    '7c is a draw-intensifier; villain barrel range expands to include OESDs, gutshots, FDs PLUS Tx value PLUS sets. Hero KQ has 6 overcard outs (3 K + 3 Q) but every K-pair or Q-pair on river loses to AK/AQ (top of villain barrel) and to KQ if villain has it (rare). Pair outs dominated.' `
    'BB flop call with KQ-offsuit on T-8-4 was thin (two overcards, no FD, no draw). Turn 7 expands villain barrel range AND keeps hero with no draw, no pair, no real equity.' `
    'KsQc has zero made hand, no flush draw, no straight draw. The 6 overcard outs are dominated by villain top-of-range (AK/AQ).' `
    'Folding closes action. The reason is specifically DOMINATION (pair outs dominated by AK/AQ), distinct from range-disadvantage-fold (which is about BB range structure rather than hand-specific dominance).' `
    'Continuing KQ vs draw-intensifier barrels because of "two overcards" ignores that the pair outs themselves are dominated.' `
    'Naked dominated overcards on draw-intensifier turn = textbook domination_turn_fold.') `
  -conceptTags @('turn_domination_fold','turn_range_disadvantage','second_barrel_defense') `
  -difficulty 3 `
  -sourceConfidence 'consensus_gto' `
  -uniquenessNote 'TEXTBOOK domination_turn_fold reason_choice on F8 draw-intensifier. Distinct from existing F1 KdJc (overcards fold on A-high BRICK; different turn category) because here the lesson is about pair-out dominance specifically on a turn that adds draws to villain range.'

# R5 -- F9 (Ah 9d 4d, 7h): TdTs underpair on multi-FD turn -- mixed indifference
# Distinct from existing M4 mixed spots (F1 99 brick / F5 AA polar straight / F10 99 brick).
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ah9d4d_7h_m4_reason_TdTs_v430D' `
  -board $f9 -heroHand @('Td','Ts') `
  -handClass 'underpair' -heroHandRole 'marginal_made_hand' -drawCategory 'backdoor_only' -showdownValue 'low' `
  -blockerNote 'Underpair to A; Td gives a 4th diamond with board 9d+4d+Td = 3 diamonds, hero needs 1 more for T-high diamond flush (2nd-nut behind nut Ad-of-diamond).' `
  -recommendedAction 'mixed' -actionReason 'mixed_indifference_turn' `
  -question (Q-Reason 'plays mixed (call/fold)' 'Td Ts' $f9Str '7h') `
  -answer (New-Answer 'mixed_indifference_turn' @('bluff_catch_turn','equity_realization_turn_call') @('value_check_raise_turn','protection_check_raise_turn','blocker_check_raise_turn','semi_bluff_check_raise_turn','range_disadvantage_turn_fold','domination_turn_fold','pot_odds_turn_call') @()) `
  -explanation (New-Explanation `
    'TT underpair + backdoor diamond redraw on multi-FD turn -- primary reason is MIXED INDIFFERENCE (frequency depends on villain bluff %).' `
    '7h adds heart-FD threats AND straight-draw threats to villain barrel range. Hero TT is below A-pair but above 9-pair. Hero Td gives only 1 diamond + board has 9d+4d = 3 diamonds total; hero needs runner-runner spades or runner-runner diamonds for any flush. Pair-of-T improvement is dominated by villain Ax range; set-of-T outs are just 2.' `
    'BB flop call with TT on A-9-4 was thin (underpair, slim equity vs Ax range). Turn 7 keeps hero underpair AND does not significantly improve the spot.' `
    'TdTs has underpair to A with backdoor diamond redraw (3 diamonds total, need runner-runner). 5 outs to set of T plus pair-of-T-improvements blocked by Ax. ~13% one-card equity.' `
    'Pure call vs over-bluffy villain captures the bluff bucket. Pure fold vs nitty villain avoids paying off Ax + made-FD value. Solver mixes ~50/50 vs balanced barrel range. The reason is NOT clean bluff-catch (showdown value too low) and NOT pot-odds-call (no real draw).' `
    'Marking this as critical-fold or critical-call over-confident; it is a true mixed spot where the optimal frequency depends on opponent tendency.' `
    'Underpair on multi-FD turn vs balanced range = mixed_indifference_turn.') `
  -conceptTags @('turn_pot_odds','turn_bluff_catcher','second_barrel_defense') `
  -difficulty 4 `
  -uniquenessNote 'FOURTH mixed_indifference_turn spot. Distinct from F1 9c9d (brick board), F5 AhAd (polar straight, OVERPAIR mixed), F10 9c9d (polar brick) because here the board is multi-FD and hero hand is UNDERPAIR with backdoor flush redraw -- different mixed-frequency math.'

# R6 -- F8 (Ts 8s 4d, 7c): TdTc set of T's on draw-intensifier -- slowplay call
# consensus_gto: textbook slowplay set on dynamic turn.
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_Ts8s4d_7c_m4_reason_TdTc_v430D' `
  -board $f8 -heroHand @('Td','Tc') `
  -handClass 'set' -heroHandRole 'slowplay_trap' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Top set of tens; blocks the 2 remaining Tx top-pair combos. Loses only to higher straights (J9) and unlikely sets above (no Tx set possible since hero has both remaining T).' `
  -recommendedAction 'call' -actionReason 'slowplay_turn_call' `
  -question (Q-Reason 'calls (slowplay)' 'Td Tc' $f8Str '7c') `
  -answer (New-Answer 'slowplay_turn_call' @('value_check_raise_turn','protection_check_raise_turn') @('blocker_check_raise_turn','semi_bluff_check_raise_turn','bluff_catch_turn','range_disadvantage_turn_fold','domination_turn_fold','board_change_fold','equity_realization_turn_call','pot_odds_turn_call','mixed_indifference_turn') @()) `
  -explanation (New-Explanation `
    'Top set of T on draw-intensifier turn -- primary reason is SLOWPLAY (preserve villain bluffs/draws for a bigger river).' `
    '7c is a draw-intensifier expanding villain barrel range to OESDs/gutshots/FDs/Tx-value plus air. Top set is way ahead of every continuation. Slowplaying lets villain barrel rivers with FD-misses, gutshot-misses, and Tx-improvement combos.' `
    'BB flop call with TT on T-8-4 made top set on the flop. Turn 7 does not threaten the set; it just expands villain bluff bucket.' `
    'TdTc has top set of Ts. Loses only to J9 made straight (rare combo on flop call -- J9 with T8 board needs J+9 from flop call range; possible but not dense).' `
    'Calling slowplays for river value. Small/big check-raise also defensible (charges draws + Tx) but loses bluff-bucket equity. The reason is SLOWPLAY (preserve bluffs), distinct from value_raise (which is the alternative play).' `
    'Misclassifying as value_raise misses the strategic intent; on a draw-intensifier turn with top set, preserving villain bluff frequency for the river generates more EV than charging draws now.' `
    'Top set on draw-intensifier turn vs polarized barrel = textbook slowplay_turn_call.') `
  -conceptTags @('turn_slowplay_call','turn_check_raise_value','second_barrel_defense') `
  -difficulty 4 `
  -sourceConfidence 'consensus_gto' `
  -uniquenessNote 'TEXTBOOK slowplay_turn_call reason_choice on F8 draw-intensifier. Distinct from existing F4 8d8h (slowplay set on flush-complete) and from F8 9d6d (made straight value-raise) because here hero has TOP SET on a turn where villain bluff frequency is highest, making the slowplay-vs-value-raise tradeoff lean toward slowplay.'

# R7 -- F2 (8d 6c 3s, Qh): 8h7d mid-pair demoted on Q-overcard turn -- range disadvantage fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_turn_8d6c3s_Qh_m4_reason_8h7d_v430D' `
  -board $f2 -heroHand @('8h','7d') `
  -handClass 'mid_pair' -heroHandRole 'dominated_marginal' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_turn_fold' `
  -question (Q-Reason 'folds' '8h 7d' $f2Str 'Qh') `
  -answer (New-Answer 'range_disadvantage_turn_fold' @('domination_turn_fold','board_change_fold') @('value_check_raise_turn','protection_check_raise_turn','blocker_check_raise_turn','semi_bluff_check_raise_turn','bluff_catch_turn','equity_realization_turn_call','pot_odds_turn_call','mixed_indifference_turn','slowplay_turn_call') @()) `
  -explanation (New-Explanation `
    '8-pair + 7 kicker on Q-overcard turn -- primary reason is RANGE DISADVANTAGE (pair demoted below villain top range).' `
    'Qh adds Qx to villain barrel range (some QJ/QT combos that BTN c-bets flop and barrels turn). Hero 8-pair was already weak on flop; Q overcard demotes it further -- now sits below Q-pair, below J-pair (any Jx), below T-pair (any Tx in barrel range), AND has dominated kicker outs vs villain Ax/Kx in barrel.' `
    'BB flop call with 8-7-offsuit on 8-6-3 was thin (mid pair + slim straight backdoor via 5+4 = 2-card draw). Turn Q kills any backdoor reach AND demotes the 8-pair below villain barrel value range.' `
    '8h7d has mid pair 8 with 7 kicker. ~5 outs to two-pair/trips but vs villain Qx/QJ/QT/overpairs is far behind. Pair-out kicker dominated by Ax/Kx if hits.' `
    'Folding closes action. The reason is RANGE DISADVANTAGE (8-pair demoted below villain barrel range) rather than DOMINATION (which would imply specific kicker-out dominance).' `
    'Stationing weak middle pair after a Q overcard turn vs a polarized barrel is a classic range-disadvantage leak.' `
    'Demoted weak mid-pair on overcard turn = textbook range_disadvantage_turn_fold.') `
  -conceptTags @('turn_range_disadvantage','turn_board_change','second_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Range-disadvantage reason_choice on F2 Q-overcard board. Distinct from existing F2 6h5h (mid pair + 5 kicker fold) and from R4 KsQc (domination_fold) because here the diagnostic distinction is between RANGE-DISADVANTAGE (pair demoted below range) and DOMINATION (specific kicker-out punch). Tests reason-distinction discipline.'


# ====== Output ======

$out = [PSCustomObject]([ordered]@{
  moduleId         = 'pf_turn_barrel_oop_def'
  moduleName       = 'Facing Turn Barrel OOP'
  version          = 'v4.3.0D'
  status           = 'planning_only'
  schemaVersion    = '1.2.0'
  generatedAt      = (Get-Date -Format 'yyyy-MM-dd')
  polishStats      = [PSCustomObject]@{
    polishTarget          = 'M4 production: 53 -> 53+polish_count'
    finalProductionTarget = '72 (24 baseline + 29 expansion + 19 polish)'
    coverageGapsAddressed = @(
      'blocker_check_raise_turn: 1 -> 3 (+2)',
      'reason_choice qtype: 6 -> 13 (+7)',
      'mixed_indifference_turn: 3 -> 4 (+1)',
      'consensus_gto sourceConfidence: 0 -> 8 (+8 textbook spots)',
      'critical density: 81.1% -> 73.6% (target 70-75%)'
    )
    sourceConfidenceMix   = '11 expert_judgment + 8 consensus_gto'
  }
  notes            = 'v4.3.0D polish seed candidates. ALL auditStatus=planning_only and reviewStatus=v4.3.0D_polish_candidate; promoted to production via tools/migrate-module4-v4.3.0D.ps1 with two-phase staged approval (review_pending then approved). Polish targets: blocker_check_raise_turn (+2), reason_choice (+7), mixed_indifference_turn (+1), consensus_gto promotion of 8 textbook spots, critical density recalibration toward 70-75%.'
  scenarios        = $scenarios
})

# Atomic write via tmp + Move-Item (no Invoke-Expression, no Remove-Item on production)
$jsonText = $out | ConvertTo-Json -Depth 100
$tmpPath = "$outPath.tmp"
[System.IO.File]::WriteAllText($tmpPath, $jsonText, $utf8nb)
Move-Item -LiteralPath $tmpPath -Destination $outPath -Force

Write-Host ""
Write-Host "Total polish scenarios authored: $($scenarios.Count)" -ForegroundColor Cyan
Write-Host "Wrote: $outPath" -ForegroundColor Cyan
Write-Host "Size: $((Get-Item $outPath).Length) bytes"
