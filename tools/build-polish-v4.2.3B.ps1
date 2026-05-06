# tools/build-polish-v4.2.3B.ps1
# v4.2.3B - Module 3 Data Polish Builder
#
# Authors 23 new M3 scenarios across 5 new board families plus 1
# scenario added to an existing board (8c 8d 3s for an overpair
# slowplay variant). Each scenario carries a uniquenessNote
# explaining what new strategic dimension it adds beyond v4.2.3A's 62.
#
# Thin-bucket fixes:
#   blocker_raise:    1 -> 4 (+3)
#   domination_fold:  2 -> 5 (+3)
#   nut_flush_draw:   1 -> 3 (+2)
#   slowplay_call:    3 -> 5 (+2)
#   protection_raise: 3 -> 5 (+2 ; some scenarios overlap)
#
# ASCII-only (no em-dash, no approx symbol) to avoid CP874 mojibake
# during PowerShell script parsing.

$ErrorActionPreference = 'Stop'
$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$outPath  = Join-Path $repoRoot 'docs\specs\postflop-v4.2.3B-module3-polish-seeds.json'

$spotTemplate = [ordered]@{
  format          = 'NLH_MTT'
  stackDepth      = '100BB'
  potType         = 'SRP'
  preflopAction   = 'BTN open 2.5x, BB call'
  street          = 'flop'
  heroPosition    = 'BB'
  villainPosition = 'BTN'
  heroRole        = 'preflop_caller_oop'
  villainRole     = 'preflop_raiser_ip'
  villainAction   = 'cbet'
  villainSizing   = 'small'
}
$actionChoices = @('fold', 'call', 'check_raise_small', 'check_raise_big', 'mixed')
$reasonChoices = @(
  'value_raise', 'protection_raise', 'semi_bluff_raise', 'blocker_raise',
  'bluff_catch', 'equity_realization_call', 'slowplay_call',
  'range_disadvantage_fold', 'domination_fold'
)

function New-Spot { return [PSCustomObject]([ordered]@{} + $spotTemplate) }
function New-Board($cards, $boardKind, $suit, $tags, $hcc) {
  return [PSCustomObject]([ordered]@{
    cards         = $cards
    boardKind     = $boardKind
    suitTexture   = $suit
    textureTags   = $tags
    highCardClass = $hcc
  })
}
function New-Question($qtype, $prompt, $choices) {
  return [PSCustomObject]([ordered]@{
    qtype   = $qtype
    prompt  = $prompt
    choices = $choices
  })
}
function New-Answer($best, $acceptable, $bad, $critical) {
  return [PSCustomObject]([ordered]@{
    best       = $best
    acceptable = $acceptable
    bad        = $bad
    critical   = $critical
  })
}
function New-Explanation($short, $rangeContext, $defenseLogic, $handLogic, $sizingLogic, $commonMistake, $takeaway) {
  return [PSCustomObject]([ordered]@{
    short         = $short
    rangeContext  = $rangeContext
    defenseLogic  = $defenseLogic
    handLogic     = $handLogic
    sizingLogic   = $sizingLogic
    commonMistake = $commonMistake
    takeaway      = $takeaway
  })
}
function New-Scenario {
  param(
    [string]$id, $board, $heroHand, [string]$handClass,
    [string]$heroHandRole, [string]$drawCategory, [string]$showdownValue,
    $blockerNote, [string]$recommendedAction, [string]$actionReason,
    $question, $answer, $explanation, $conceptTags,
    [string]$sourceConfidence = 'expert_judgment',
    [int]$difficulty = 3,
    [string]$uniquenessNote
  )
  return [PSCustomObject]([ordered]@{
    id                = $id
    module            = 'pf_flop_cbet_oop_def'
    moduleName        = 'Facing C-bet OOP'
    schemaVersion     = '1.1.0'
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
    reviewStatus      = 'v4.2.3B_polish'
    uniquenessNote    = $uniquenessNote
  })
}
function Q-Action($hero, $boardStr) {
  return New-Question 'action_choice' "BTN c-bets ~33% pot. What's hero's best action with $hero on $boardStr?" $actionChoices
}
function Q-Reason($action, $hero, $boardStr) {
  return New-Question 'reason_choice' "Hero $action with $hero on $boardStr vs ~33% c-bet. What is the primary reason?" $reasonChoices
}
function BoardStr($cards) { return ($cards -join ' ') }


# Boards
$bB_cards = @('Kh','Qh','4s'); $bB = New-Board $bB_cards 'K_high' 'two_tone' @('wet','semi_connected','broadway_heavy') 'K_high'; $bBs = BoardStr $bB_cards
$bC_cards = @('Kh','Jh','4h'); $bC = New-Board $bC_cards 'K_high' 'monotone'  @('wet','semi_connected','broadway_heavy','flushing') 'K_high'; $bCs = BoardStr $bC_cards
$bD_cards = @('Qd','7d','2c'); $bD = New-Board $bD_cards 'Q_high' 'two_tone' @('dry','disconnected') 'Q_high'; $bDs = BoardStr $bD_cards
$bE_cards = @('Ac','Ad','7s'); $bE = New-Board $bE_cards 'A_high' 'rainbow'  @('dry','paired') 'A_high'; $bEs = BoardStr $bE_cards
$bF_cards = @('Ts','9s','5d'); $bF = New-Board $bF_cards 'T_high' 'two_tone' @('wet','semi_connected') 'T_high'; $bFs = BoardStr $bF_cards
$bExist_cards = @('8c','8d','3s'); $bExist = New-Board $bExist_cards 'low' 'rainbow' @('dry','paired') 'low'; $bExists = BoardStr $bExist_cards


$scenarios = @()

# ========================================================================
# Board B: Kh Qh 4s (K-high two-tone, broadway, dynamic)
# ========================================================================

# B.1 - TPGK on dynamic two-tone broadway: protection_raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_KhQh4s_m3_action_KcJc_v423b' `
  -board $bB -heroHand @('Kc','Jc') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'strong_value' -drawCategory 'backdoor_only' -showdownValue 'high' `
  -blockerNote 'J blocks BTN QJ straight-draw combos.' `
  -recommendedAction 'check_raise_small' -actionReason 'protection_raise' `
  -question (Q-Action 'Kc Jc' $bBs) `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'TPGK on dynamic K-Q-4 two-tone -- raise for protection from FDs and straight draws.' `
    "BTN c-bets K-Q-4 two-tone wide with overpairs, weaker K-x, JT/T9 straight draws, and FD bluffs." `
    'Top pair good kicker is ahead now but vulnerable on hearts, J/T straight cards, and overcards; raising charges everything.' `
    'KcJc has top pair K + J kicker + backdoor club + gutshot to A (T-J-Q-K-A).' `
    'Small raise charges FDs/straight-draws and gets called by KT/KQ kicker hands and FDs; big raise also defensible.' `
    'Auto-calling TPGK on a wet two-tone broadway lets straight + flush draws complete cheaply.' `
    'TPGK on wet two-tone broadway = raise for protection (call only on disconnected K-high two-tone).') `
  -conceptTags @('check_raise_value','protection_raise','value_raise') `
  -difficulty 3 `
  -uniquenessNote 'PROTECTION_RAISE on dynamic two-tone BROADWAY (vs Ks 8s 3d KcJh on disconnected two-tone). Broadway connectivity adds straight-draw protection layer absent on disconnected K-high.'

# B.2 - Nut FD + Ace overcard on K-high two-tone: semi_bluff_raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_KhQh4s_m3_action_Ah9h_v423b' `
  -board $bB -heroHand @('Ah','9h') `
  -handClass 'nut_flush_draw' -heroHandRole 'semi_bluff_combo' -drawCategory 'nut_flush_draw' -showdownValue 'low' `
  -blockerNote 'Ah is the nut-flush card; blocks all of BTN nut-flush combos.' `
  -recommendedAction 'check_raise_small' -actionReason 'semi_bluff_raise' `
  -question (Q-Action 'Ah 9h' $bBs) `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Nut FD + Ace overcard + Ah blocker on K-high two-tone -- premium semi-bluff raise.' `
    "BTN c-bets K-Q-4 two-tone wide with K-x value, FD bluffs, and air; semi-bluff applies fold equity + equity." `
    '9 nut-FD outs + 3 overcard outs + Ah blocker reducing villain value combos = ~40% effective equity.' `
    'Ah9h has nut FD (4 hearts visible) + A overcard + Ah blocks BTN AhX nut-flush combos.' `
    'Small raise applies pressure now; the nut blocker reduces villain calls with 2nd-nut FD combos.' `
    'Just calling nut FD + overcard + blocker OOP wastes premium fold equity vs a wide c-bet range.' `
    'Nut FD + overcard + blocker on two-tone = semi-bluff raise (the equity is real, not just blocker).') `
  -conceptTags @('check_raise_bluff','semi_bluff_raise','equity_realization_oop') `
  -difficulty 4 `
  -uniquenessNote 'NUT_FLUSH_DRAW #2 (after Ks 8s 3d AsQs). Distinct: K-high two-tone broadway adds straight-draw considerations (gutshot to T) that the disconnected K-high lacks. Different equity composition.'

# B.3 - Pure nut blocker, no FD: blocker_raise (THIN-BUCKET TARGET)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_KhQh4s_m3_reason_Ah7c_v423b' `
  -board $bB -heroHand @('Ah','7c') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'backdoor_only' -showdownValue 'none' `
  -blockerNote 'Ah is the nut-flush card; blocks every AhX nut-flush combo in BTNs c-bet range. No real FD (only backdoor heart needing both turn + river hearts).' `
  -recommendedAction 'check_raise_small' -actionReason 'blocker_raise' `
  -question (Q-Reason 'check-raises small' 'Ah 7c' $bBs) `
  -answer (New-Answer 'blocker_raise' @('equity_realization_call') @('value_raise','protection_raise','semi_bluff_raise','bluff_catch','range_disadvantage_fold','domination_fold') @()) `
  -explanation (New-Explanation `
    'A-high check-raise on K-high two-tone -- primary reason is the Ah nut-flush blocker.' `
    "BTN c-bet range is heavy on K-x value, hearts FD bluffs, and air; the Ah blocks nut-flush combos and reduces villain pressure." `
    'The check-raise EV comes from BLOCKING value, not from outs. Ah7c has no pair, no real FD (backdoor only), and only 6 overcard outs.' `
    'Hero has Ah (nut-flush blocker) + 7c offsuit kicker. With 3 hearts visible, 2 more hearts needed for flush = backdoor only, not a real FD.' `
    'Small raise leverages the blocker; do not size big since fold equity drops vs polar value.' `
    'Identifying this as semi_bluff_raise mis-attributes the EV -- the equity is from the blocker, not the draw.' `
    'OOP raise with the nut-flush blocker but no real FD = blocker_raise (not semi_bluff).') `
  -conceptTags @('check_raise_bluff','range_disadvantage','oop_defense_threshold') `
  -difficulty 5 `
  -uniquenessNote 'BLOCKER_RAISE #2 (after AsKh on 7s 5s 3s monotone). Distinct: this is on a TWO-TONE board where backdoor flush is much weaker than monotone, so the blocker effect must carry the entire EV without flush-equity backup. Tests purer blocker-vs-semi-bluff distinction.'

# B.4 - Middle pair + gutshot on dynamic two-tone broadway
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_KhQh4s_m3_action_QdTd_v423b' `
  -board $bB -heroHand @('Qd','Td') `
  -handClass 'mid_pair' -heroHandRole 'marginal_made_hand' -drawCategory 'backdoor_only' -showdownValue 'decent' `
  -blockerNote 'Qd pairs the Q on board for middle pair; Td gives gutshot to A (T-J-Q-K-A) plus backdoor diamond.' `
  -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action 'Qd Td' $bBs) `
  -answer (New-Answer 'call' @() @('fold','check_raise_small','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'Middle pair (Q) + gutshot to A + backdoor diamond on K-Q-4 two-tone -- call to realize equity.' `
    "BTN c-bets K-Q-4 two-tone wide; Q-pair + gutshot + backdoor diamond is well above defense threshold." `
    'Pair of Q + 4-out gutshot + backdoor diamond + 6 outs to two-pair = strong combo equity to defend.' `
    'QdTd has middle pair (Q matched on board) + gutshot to A for K-Q-J-T-A + backdoor diamond runner-runner.' `
    'Calling realizes equity at minimum cost; raising bloats vs K-x value and folds out air bluffs.' `
    'Folding Q-pair with gutshot + backdoor on a wide c-bet board over-folds vs villain bluff range.' `
    'Middle pair Q-kicker + gutshot + backdoor on dynamic two-tone broadway = call.') `
  -conceptTags @('bluff_catchers','equity_realization_oop','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'Middle pair Q-kicker call on K-high TWO-TONE BROADWAY (vs existing Q-pair scenarios on disconnected boards). Adds the gutshot-to-A dimension which exists only on broadway boards.'

# B.5 - Top pair Q with bad kicker - DOMINATION_FOLD (THIN-BUCKET TARGET)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_KhQh4s_m3_action_Qc9c_v423b' `
  -board $bB -heroHand @('Qc','9c') `
  -handClass 'top_pair_weak_kicker' -heroHandRole 'dominated_marginal' -drawCategory 'backdoor_only' -showdownValue 'decent' `
  -blockerNote 'Q-pair is dominated by KQ, AQ, QJ, QT in BTNs range; 9 kicker is weakest possible.' `
  -recommendedAction 'fold' -actionReason 'domination_fold' `
  -question (Q-Action 'Qc 9c' $bBs) `
  -answer (New-Answer 'fold' @('call') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Top pair Q with 9 kicker on K-Q-4 two-tone -- fold; dominated by villains entire Q-pair value range.' `
    "BTN c-bet range is K-x heavy plus QQ/AQ/KQ/QJ/QT; hero Q-9 loses to all of these and to overpairs." `
    'Pair of Q with 9 kicker is dominated; reverse implied odds on a multi-street pot make this an early fold.' `
    'Qc9c has top pair Q (paired with board Q) + 9 kicker + backdoor club. Pair outs (5 outs) are dominated.' `
    'Folding closes action cleanly; calling forces tough turn decisions vs dominated kicker.' `
    'Calling Q-pair-bad-kicker on K-Q boards -because top pair- bleeds chips vs dominated range.' `
    'Top pair weak kicker on broadway boards facing range pressure = fold (acceptable to call vs over-bluffy villains).') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 4 `
  -uniquenessNote 'DOMINATION_FOLD #3 - top pair WITH bad kicker (vs existing AhQs/QdJh which were no-pair domination). Tests recognition that a pair can still be dominated and folded; harder lesson than fold-with-no-pair.'


# ========================================================================
# Board C: Kh Jh 4h (K-high monotone)
# ========================================================================

# C.1 - Pure nut blocker on monotone, no FD: blocker_raise (THIN-BUCKET)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_KhJh4h_m3_reason_AhTd_v423b' `
  -board $bC -heroHand @('Ah','Td') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'backdoor_only' -showdownValue 'none' `
  -blockerNote 'Ah is the nut-flush card on monotone hearts. Hero has 1-card backdoor heart only (no real FD).' `
  -recommendedAction 'check_raise_small' -actionReason 'blocker_raise' `
  -question (Q-Reason 'check-raises small' 'Ah Td' $bCs) `
  -answer (New-Answer 'blocker_raise' @('equity_realization_call') @('value_raise','protection_raise','semi_bluff_raise','bluff_catch','range_disadvantage_fold','domination_fold') @()) `
  -explanation (New-Explanation `
    'A-high check-raise on K-high monotone -- primary reason is Ah nut-flush blocker.' `
    "BTN c-bet range on monotone is polarized (made flushes + air); Ah blocks every flush combo BTN could have." `
    'The raise EV comes from removing villain flush value, not from outs. Hero has 0 made hand and only backdoor heart.' `
    'AhTd has no pair, no draw on Kh Jh 4h (Td is offsuit and gives no straight). Ah is the nut-flush blocker.' `
    'Small raise leverages the blocker; sizing big over-faces villains nut-flush range that does not fold.' `
    'Identifying as semi_bluff_raise misses that there is no real FD here -- pure blocker pressure.' `
    'A-high with the nut-flush card on monotone but no flush draw of own = blocker_raise.') `
  -conceptTags @('check_raise_bluff','range_disadvantage','oop_defense_threshold') `
  -difficulty 5 `
  -uniquenessNote 'BLOCKER_RAISE #3 - clean blocker case on K-high monotone (vs B.3 on K-high two-tone, vs existing AsKh on 7s5s3s low monotone). Distinct: K-high monotone has even more value-heavy BTN range than low monotone (because BTN raises high-suited Broadway combos preflop), making blocker pressure even more important.'

# C.2 - Middle pair + Q-FD on monotone: protection_raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_KhJh4h_m3_action_QhJc_v423b' `
  -board $bC -heroHand @('Qh','Jc') `
  -handClass 'mid_pair' -heroHandRole 'strong_value' -drawCategory 'flush_draw' -showdownValue 'high' `
  -blockerNote 'Jc pairs Jh on board for middle pair (J); Qh gives Q-high flush draw and blocks BTN second-nut flushes.' `
  -recommendedAction 'check_raise_small' -actionReason 'protection_raise' `
  -question (Q-Action 'Qh Jc' $bCs) `
  -answer (New-Answer 'check_raise_small' @('call','check_raise_big') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Middle pair J + Q-high FD + Qh blocker on K-high monotone -- raise for protection + value.' `
    "BTN c-bets K-J-4 monotone with made flushes, K-x with hearts, J-x with hearts, plus air; Q-FD plus pair has strong value." `
    'Pair of J + 9 outs to Q-flush + Qh blocker on second-nut flush = strong combo equity above villain calling threshold.' `
    'QhJc has middle pair J + 4-card Q-flush draw + Qh blocking BTN AhQh/KhQh/QhTh second-nut combos.' `
    'Small raise charges weaker FDs and gets called by K-x and Q-x combos; big raise also defensible.' `
    'Just calling middle pair + Q-FD + blocker on monotone misses value vs weaker draws and pairs.' `
    'Pair + Q-flush draw + blocker on K-high monotone = raise for value AND protection.') `
  -conceptTags @('check_raise_value','protection_raise','value_raise') `
  -difficulty 4 `
  -uniquenessNote 'PROTECTION_RAISE #4 with combined pair + FD + blocker on monotone. Distinct: existing protection_raise scenarios are on rainbow (5c5d on 875, 9c9s on 986) or two-tone (KcJh on Ks8s3d); this is the first PROTECTION_RAISE on a MONOTONE board, where protection is for villain calling FDs vs raising worse pairs.'

# C.3 - T-high one-card FD on monotone: equity_realization_call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_KhJh4h_m3_action_Th9d_v423b' `
  -board $bC -heroHand @('Th','9d') `
  -handClass 'flush_draw' -heroHandRole 'pure_draw' -drawCategory 'flush_draw' -showdownValue 'low' `
  -blockerNote 'Th is one-card FD on monotone (4 hearts visible). No relevant blocker on flush combos above T-high.' `
  -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action 'Th 9d' $bCs) `
  -answer (New-Answer 'call' @() @('fold','check_raise_small','mixed','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Naked T-high flush draw on K-high monotone -- call to realize cheap FD equity.' `
    "BTN c-bets monotone polarized (made flushes + air); Th gives 9 outs to a flush but ranks behind A/K/Q-high flushes." `
    'Pure FD with no pair and no blocker; calling realizes 9 FD outs at minimum cost.' `
    'Th9d has 1-card flush draw to T-high flush + 9 doesnt pair the board.' `
    'Calling captures FD equity cheaply; raising as semi-bluff bloats vs nut-flush combos that wont fold.' `
    'Folding mid-FD on monotone over-folds vs the air portion of villains range that pays off.' `
    'Mid-strength flush draw on monotone without overcards or blocker = call (raise rare).') `
  -conceptTags @('equity_realization_oop','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'Mid-strength flush draw on monotone (vs existing 9h8c on Jh8h4h which had pair too). Tests pure-draw defense without a pair component or blocker -- different equity calculation.'

# C.4 - Bottom pair + low FD on monotone
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_KhJh4h_m3_action_5h4c_v423b' `
  -board $bC -heroHand @('5h','4c') `
  -handClass 'bottom_pair' -heroHandRole 'marginal_made_hand' -drawCategory 'flush_draw' -showdownValue 'decent' `
  -blockerNote $null `
  -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action '5h 4c' $bCs) `
  -answer (New-Answer 'call' @() @('fold','check_raise_small','mixed','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Bottom pair (4) + low one-card flush draw on K-high monotone -- call to defend.' `
    "BTN c-bet range on monotone has flushes + air; bottom pair plus low FD beats the entire air bucket." `
    '5 pair outs + 9 FD outs = strong combined equity even though both made-hand and FD are low-ranked.' `
    '5h4c has bottom pair (4 paired) + 5h adds 1-card flush draw (4 hearts visible).' `
    'Calling realizes both pair and FD equity cheaply; raising offers no fold equity vs flushes.' `
    'Folding any pair + FD on monotone over-folds vs the wide stab range.' `
    'Bottom pair + low FD on monotone = call (the equity comes from combined sources).') `
  -conceptTags @('bluff_catchers','equity_realization_oop','pot_odds_defense') `
  -difficulty 3 `
  -uniquenessNote 'Bottom pair + low FD COMBINATION on monotone -- distinct from C.3 (pure FD) and C.2 (mid pair + Q-FD). Tests pair + FD defense at the WEAKEST end of the made-hand spectrum.'

# C.5 - Naked overcards no heart - range_disadvantage_fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_KhJh4h_m3_action_Ad8c_v423b' `
  -board $bC -heroHand @('Ad','8c') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote 'Ad does NOT block heart flushes; offsuit Ace has no relevant blocker effect on monotone.' `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_fold' `
  -question (Q-Action 'Ad 8c' $bCs) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Ace-high no-heart no-blocker on K-high monotone -- fold; no equity, no relevant blocker.' `
    "BTN c-bets monotone polarized; without a heart hero has zero flush equity AND Ad does not block hearts." `
    'Zero flush outs + 6 overcard outs (often dominated by K-pair) = below threshold.' `
    'Ad8c has no heart on Kh Jh 4h, so no FD; Ad is a diamond and does NOT block heart flushes.' `
    'Folding closes action; calling burns chips against polarized range without relevant equity.' `
    'Confusing Ace-high blocker rules: only Ace OF THE FLUSH SUIT blocks (Ah on hearts board).' `
    'Naked A-high without the heart on monotone hearts = fold (Ad is not a blocker).') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'NO-HEART A-high FOLD on monotone hearts -- tests the critical distinction that only the SUITED ace (Ah) blocks the nut flush. This is THE crucial monotone defense lesson and is missing from existing M3 (where 6c5d on Jh8h4h was just naked low cards).'


# ========================================================================
# Board D: Qd 7d 2c (Q-high two-tone, dry, disconnected)
# ========================================================================

# D.1 - Nut blocker on dry two-tone: blocker_raise (THIN-BUCKET)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Qd7d2c_m3_reason_AdTc_v423b' `
  -board $bD -heroHand @('Ad','Tc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'backdoor_only' -showdownValue 'none' `
  -blockerNote 'Ad is the nut-FD card on diamonds; blocks BTN AdX nut-flush-draw combos. Hero has no real FD (only backdoor diamond needing 2 more diamonds).' `
  -recommendedAction 'check_raise_small' -actionReason 'blocker_raise' `
  -question (Q-Reason 'check-raises small' 'Ad Tc' $bDs) `
  -answer (New-Answer 'blocker_raise' @('equity_realization_call','range_disadvantage_fold') @('value_raise','protection_raise','semi_bluff_raise','bluff_catch','domination_fold') @()) `
  -explanation (New-Explanation `
    'A-high check-raise on Q-high two-tone -- primary reason is the Ad nut-FD blocker.' `
    "BTN c-bets Q-high two-tone wide with Q-x value, FD bluffs, and air; Ad blocks the entire nut-FD bucket." `
    'No pair, no real FD. The raise EV comes from removing villain nut-FD value, not from outs.' `
    'AdTc has no pair, only backdoor diamond (3 visible diamonds, need 2 more = backdoor only). Ad is the nut-FD blocker.' `
    'Small raise leverages the blocker; sizing big folds out only air without gaining vs Qx value.' `
    'Calling without the made-hand component is also fine; raising is the alternate solver-mix line.' `
    'A-high nut-FD blocker on dry two-tone = blocker_raise (mixed line; call also defensible).') `
  -conceptTags @('check_raise_bluff','range_disadvantage','oop_defense_threshold') `
  -difficulty 4 `
  -uniquenessNote 'BLOCKER_RAISE #4 on a DRY two-tone (vs B.3 on dynamic two-tone broadway, vs C.1 on monotone). Tests blocker pressure on the texture where BTN range is widest and most-c-bets-with-air -- different fold-equity calculation than wet textures.'

# D.2 - Top pair top kicker on dry Q-high: value_raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Qd7d2c_m3_action_AhQh_v423b' `
  -board $bD -heroHand @('Ah','Qh') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'strong_value' -drawCategory 'backdoor_only' -showdownValue 'high' `
  -blockerNote 'A blocks AA overpair; Q is top pair with top kicker.' `
  -recommendedAction 'check_raise_small' -actionReason 'value_raise' `
  -question (Q-Action 'Ah Qh' $bDs) `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'AQ on Q-high two-tone -- top pair top kicker, raise for value.' `
    "BTN c-bets Q-high two-tone with QQ/AQ/KQ/QJ value, FD bluffs, and air; AQ value-raises QJ/QT/KQ-with-FD calls." `
    'TPTK is far ahead of villains marginal Qx and air; raising builds the pot before bad turns.' `
    'AhQh has top pair Q + Ace kicker + backdoor heart. Only AA, KK, QQ sets, and 22/77 sets beat hero.' `
    'Small raise gets called by KQ/QJ/Qx with FD; big raise folds out worse Q-x.' `
    'Slowplaying TPTK on dry two-tone Q-high misses thin value from QJ/QT/Qx-FD that pay off small raise.' `
    'TPTK on dry Q-high two-tone = small raise for value (do not slowplay).') `
  -conceptTags @('check_raise_value','value_raise','protection_raise') `
  -difficulty 3 `
  -uniquenessNote 'TPTK value raise on Q-high two-tone (vs existing top-set/two-pair scenarios). Tests TPTK-specific reasoning: how it differs from sets (smaller raise to keep worse Qx in) and from QJ/QT (which are hero-side value calls).'

# D.3 - Top pair Q with weak kicker: domination_fold (THIN-BUCKET)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Qd7d2c_m3_action_Qh9h_v423b' `
  -board $bD -heroHand @('Qh','9h') `
  -handClass 'top_pair_weak_kicker' -heroHandRole 'dominated_marginal' -drawCategory 'backdoor_only' -showdownValue 'decent' `
  -blockerNote 'Q-pair dominated by AQ, KQ, QJ in BTN value range; 9 kicker is among the weakest possible.' `
  -recommendedAction 'fold' -actionReason 'domination_fold' `
  -question (Q-Action 'Qh 9h' $bDs) `
  -answer (New-Answer 'fold' @('call') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Top pair Q with 9 kicker on Q-7-2 -- fold; dominated by villains Q-x value range.' `
    "BTN c-bet range here is Q-x value (AQ/KQ/QJ/QT) + overpairs + air; Q9 loses to all of those." `
    'Pair of Q with 9 kicker dominated; reverse implied odds make folding now correct.' `
    'Qh9h has top pair Q + 9 kicker + backdoor heart. 5 outs to two-pair are dominated outs.' `
    'Folding closes action cleanly; calling chases dominated kicker into a multi-street pot.' `
    'Calling top pair weak kicker -because it pairs the board- ignores domination by villain Qx-better-kicker.' `
    'Top pair weak kicker on Q-high facing range pressure = fold (the kicker matters).') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'DOMINATION_FOLD #4 with WEAK Qx (vs B.5 Qc9c on K-high two-tone where Q is middle pair, vs existing AhQs no-pair). Distinct: weak Qx ON the Q-high board where Q-x is BTNs primary value -- different domination vector.'

# D.4 - Top pair Q with OK kicker: bluff_catch close call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Qd7d2c_m3_action_QhJc_v423b' `
  -board $bD -heroHand @('Qh','Jc') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'backdoor_only' -showdownValue 'high' `
  -blockerNote 'J kicker is mid-strength; QJ blocks KJ/AJ/JJ in BTN range.' `
  -recommendedAction 'call' -actionReason 'bluff_catch' `
  -question (Q-Action 'Qh Jc' $bDs) `
  -answer (New-Answer 'call' @('fold') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'QJ top pair J kicker on Q-7-2 -- call to bluff-catch (close fold).' `
    "BTN c-bet range has Q-x value (AQ/KQ/QQ) + air; QJ beats all the air and ties some Q-low kickers." `
    'Pair of Q with J kicker is at threshold: dominated by AQ/KQ but ahead of QT/Qx-air.' `
    'QhJc has top pair Q + J kicker + backdoor heart. 3 outs to two-pair (J) + occasional kicker showdown wins.' `
    'Calling captures villain air bluffs; folding is also defensible vs strong villains who c-bet only Qx-better.' `
    'Auto-folding QJ on Qx -because dominated- under-defends vs villain wide stab; auto-raising bloats vs better Qx.' `
    'TPGK on dry Q-high facing wide stab = call (close to fold; depends on opponent).') `
  -conceptTags @('bluff_catchers','oop_defense_threshold','pot_odds_defense') `
  -difficulty 4 `
  -uniquenessNote 'CLOSE FOLD/CALL with QJ on Q-high (vs D.3 weak Q9 fold and D.2 strong AQ raise). Tests middle of the spectrum: kicker matters but QJ is on the bubble. Distinct difficulty and decision vs the cleaner fold/raise lessons.'

# D.5 - Naked K-high no equity - range_disadvantage_fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Qd7d2c_m3_action_KcTc_v423b' `
  -board $bD -heroHand @('Kc','Tc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'backdoor_only' -showdownValue 'none' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_fold' `
  -question (Q-Action 'Kc Tc' $bDs) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'KT no pair on Q-7-2 -- fold; pure overcards realize too little OOP.' `
    "BTN c-bet range is Q-x heavy plus overpairs; KT has no draw, no FD, no relevant blocker." `
    '6 pair outs that are often dominated; backdoor club is too thin to anchor a defense.' `
    'KcTc has no pair, no straight draw, no flush draw on Q-7-2 -- only backdoor club + 6 overcards.' `
    'Folding closes action; calling chases dominated outs into a polarized range.' `
    '-KT is too good to fold- thinking on Q-high boards bleeds chips vs Qx-heavy range.' `
    'Naked overcards no equity on Q-high disconnected = fold.') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 2 `
  -uniquenessNote 'KT-no-equity FOLD on Q-high two-tone (vs existing JTo on As8d3h, vs Q1.5 KcQc on As9s4d). KT specifically tests overcard fold when overcards are NOT both above the board; the K is overcard but T is not -- partial-overcard folding lesson.'


# ========================================================================
# Board E: Ac Ad 7s (A-high paired)
# ========================================================================

# E.1 - Trips A on paired A: slowplay_call (THIN-BUCKET)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_AcAd7s_m3_action_Ah7h_v423b' `
  -board $bE -heroHand @('Ah','7h') `
  -handClass 'full_house' -heroHandRole 'nutted_value' -drawCategory 'backdoor_only' -showdownValue 'nutted' `
  -blockerNote 'Hero holds the case Ace (only one in deck after Ac, Ad on board, hero Ah, leaving As); blocks all villain Ax combos.' `
  -recommendedAction 'call' -actionReason 'slowplay_call' `
  -question (Q-Action 'Ah 7h' $bEs) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'Aces full of sevens (Ah for trip A + 7 paired with board 7) -- slowplay because BTN c-bets paired-A wide with overpairs/air.' `
    "BTN c-bets paired-A heavily with overpairs (KK-22) and air; raising folds out the air and isolates overpairs/Ax." `
    'Hero is far ahead of villains entire range; calling preserves the bluff bucket for later streets.' `
    'Ah7h makes Aces full of Sevens (top of board): hero pairs the 7 on board + has trips Ace; only AAA77/A77 (impossible) beat us.' `
    'Calling lets BTN barrel air and overpairs on later streets; raising small folds out everything except KK-AA which played through.' `
    'Auto-raising the absolute nuts on paired-A folds out the wide air range and forfeits multi-street value.' `
    'Full house on paired-A = slowplay call; raising is correct only if villain massively overbluffs.') `
  -conceptTags @('bluff_catchers','equity_realization_oop') `
  -difficulty 4 `
  -uniquenessNote 'SLOWPLAY_CALL #4 on paired ACE board (vs existing 8h7h on 8c8d3s paired LOW + Td9d on TcTh6s paired T). Different range dynamics: paired-A BTN range is overpair-heavy because BTN raises Ax preflop infrequently; slowplay must keep overpairs IN to extract value over multiple streets.'

# E.2 - Pocket 8s underpair to A on paired A: bluff_catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_AcAd7s_m3_action_8h8s_v423b' `
  -board $bE -heroHand @('8h','8s') `
  -handClass 'underpair' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'decent' `
  -blockerNote $null `
  -recommendedAction 'call' -actionReason 'bluff_catch' `
  -question (Q-Action '8h 8s' $bEs) `
  -answer (New-Answer 'call' @() @('fold','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Pocket 8s underpair on paired-A board -- call to bluff-catch villains air c-bets.' `
    "BTN c-bets paired-A wide with overcards/air and overpairs; pocket 8s beats the air range and ties weaker pocket pairs." `
    'Underpair to A but overpair to 7; only Ax, 7x, and overpairs (99-AA) beat hero.' `
    '88 has no draw, just an underpair on Ac Ad 7s. Beats KK-air, J-high air, etc.' `
    'Calling preserves villains bluffs; raising isolates overpairs and Ax that crush hero.' `
    'Folding small overpairs on paired-A over-folds vs the wide air-stab range.' `
    'Mid pocket pair on paired-A = call (bluff-catch).') `
  -conceptTags @('bluff_catchers','equity_realization_oop') `
  -difficulty 3 `
  -uniquenessNote 'UNDERPAIR BLUFF-CATCH on paired ACE (vs existing 5h5d on 8c8d3s, 8d8s on KcKd7s, 8h8d on TcTh6s). Distinct: paired-ACE makes the bluff-catch tighter because BTN range has more overpairs than on paired-low boards.'

# E.3 - KT no pair on paired A: domination_fold (THIN-BUCKET)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_AcAd7s_m3_action_KsTs_v423b' `
  -board $bE -heroHand @('Ks','Ts') `
  -handClass 'no_pair_no_draw' -heroHandRole 'dominated_marginal' -drawCategory 'backdoor_only' -showdownValue 'none' `
  -blockerNote 'KT does NOT block Ax value; pair outs (K, T) often pair villains kicker.' `
  -recommendedAction 'fold' -actionReason 'domination_fold' `
  -question (Q-Action 'Ks Ts' $bEs) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'KT no pair on paired-A -- fold; dominated by villains Ax pair-outs.' `
    "BTN c-bet range here has Ax (AK, AT included), overpairs, and air; KT pair outs are often dominated." `
    '6 pair outs but K-pair loses to AK and T-pair loses to AT; reverse implied odds confirm fold.' `
    'KsTs has no pair, no draw on Ac Ad 7s. Backdoor spade only. K and T overcards face dominated kickers.' `
    'Folding closes action; calling chases dominated outs into the multi-street pot.' `
    'Calling KT on paired-A -because two overcards- ignores domination by Ax that paired BTNs preflop range.' `
    'Two overcards dominated by villains Ax range = fold even on paired-A.') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'DOMINATION_FOLD #5 with KT on paired-A (vs B.5 Q9 weak Qx, vs D.3 Q9 weak Qx, vs Ks 8s 3d QdJh). Distinct: domination by Ax kicker on paired-A board -- different domination vector than Q-x on Q-high boards.'


# ========================================================================
# Board F: Ts 9s 5d (mid-connected two-tone, dynamic)
# ========================================================================

# F.1 - Top set on dynamic two-tone: protection_raise (THIN-BUCKET)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Ts9s5d_m3_action_TcTd_v423b' `
  -board $bF -heroHand @('Tc','Td') `
  -handClass 'set' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null `
  -recommendedAction 'check_raise_small' -actionReason 'protection_raise' `
  -question (Q-Action 'Tc Td' $bFs) `
  -answer (New-Answer 'check_raise_small' @('check_raise_big','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Top set T on dynamic mid-connected two-tone -- raise for protection AND value.' `
    "BTN c-bets T-9-5 two-tone with overpairs, top pair, FDs, OE/gutshots; many turns are bad for top set." `
    'Top set is huge but vulnerable to spades, J/8/6/7/Q/K turns; raising charges all the draws.' `
    'TcTd makes top set (3 Ts including board Ts); only 99/55 sets and JxQx straights (very rare) beat us.' `
    'Small raise charges FDs and OE/gutshots while getting called by overpairs and weaker top-pair; big raise also defensible.' `
    'Slowplaying top set on a wet two-tone broadway lets straights and flushes complete cheaply.' `
    'Top set on dynamic mid-connected two-tone = raise (small or big) for value AND protection.') `
  -conceptTags @('check_raise_value','protection_raise','value_raise') `
  -difficulty 3 `
  -uniquenessNote 'PROTECTION_RAISE #5 with TOP SET on mid-connected TWO-TONE (vs existing top set 9c9s on 9d8c6h rainbow). Distinct: two-tone adds FD-protection layer absent on rainbow connected boards.'

# F.2 - OE + BDFD + 2 overcards on dynamic two-tone: equity_realization_call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Ts9s5d_m3_action_8c7c_v423b' `
  -board $bF -heroHand @('8c','7c') `
  -handClass 'oesd' -heroHandRole 'pure_draw' -drawCategory 'oesd' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action '8c 7c' $bFs) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Open-ended (need 6 or J) + backdoor club on T-9-5 two-tone -- call to realize equity.' `
    "BTN c-bets T-9-5 two-tone wide with top pair / overpair / FDs / air; OE + BDFD has strong equity vs the range." `
    '8 OE outs + 3 backdoor clubs + 1 backdoor straight extension = strong combo equity to defend.' `
    '8c7c has open-ender to 6 (5-6-7-8-9 straight) or J (7-8-9-T-J) + backdoor club FD on Ts9s5d.' `
    'Calling realizes the OE equity cheaply; raising semi-bluff also defensible against over-folders.' `
    'Folding strong OE on dynamic two-tone over-folds vs the FD-heavy bluff bucket.' `
    'OE + BDFD on dynamic two-tone = call (raise occasionally as semi-bluff vs over-folders).') `
  -conceptTags @('equity_realization_oop','oop_defense_threshold','pot_odds_defense') `
  -difficulty 3 `
  -uniquenessNote 'OE + BDFD pure-draw call on mid-connected two-tone (vs existing OE scenarios on rainbow). Different from JsTh on 9d8c6h because hero has BDFD + the boards spade FD threat changes the equity-realization math.'

# F.3 - Nut FD + Ace + wheel gutshot on mid-connected two-tone: semi_bluff_raise (THIN-BUCKET nut FD)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Ts9s5d_m3_action_As6s_v423b' `
  -board $bF -heroHand @('As','6s') `
  -handClass 'nut_flush_draw' -heroHandRole 'semi_bluff_combo' -drawCategory 'nut_flush_draw' -showdownValue 'low' `
  -blockerNote 'As is the nut-flush card on spades; blocks BTN AsX nut-flush combos.' `
  -recommendedAction 'check_raise_small' -actionReason 'semi_bluff_raise' `
  -question (Q-Action 'As 6s' $bFs) `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Nut FD + Ace overcard + wheel-gutshot backdoor on T-9-5 two-tone -- semi-bluff raise.' `
    "BTN c-bets T-9-5 two-tone wide; nut-FD + overcard + blocker = strong semi-bluff vs the c-bet range." `
    '9 nut-FD outs + 3 overcard outs + As blocks villain nut FD = ~36% raw equity + significant fold equity.' `
    'As6s has nut FD (4 spades visible) + Ace overcard + backdoor wheel straight (3-4-5-6-7 needs 3+4 = backdoor).' `
    'Small raise applies pressure now and sets up turn barrels on overcards or spade turns.' `
    'Just calling nut-FD + overcard + blocker OOP wastes premium fold equity vs a wide stab range.' `
    'Nut FD + overcard + blocker on dynamic two-tone = semi-bluff raise.') `
  -conceptTags @('check_raise_bluff','semi_bluff_raise','equity_realization_oop') `
  -difficulty 3 `
  -uniquenessNote 'NUT_FLUSH_DRAW #3 (after AsQs on Ks 8s 3d, Ah9h on Kh Qh 4s). Distinct: T-high two-tone is BB-favored texture (vs K-high two-tone which is BTN-favored), so the semi-bluff raise EV calculation is different (more fold equity vs BTNs weaker overpairs).'

# F.4 - Naked overcards on mid-connected two-tone: range_disadvantage_fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Ts9s5d_m3_action_KdQd_v423b' `
  -board $bF -heroHand @('Kd','Qd') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'backdoor_only' -showdownValue 'none' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_fold' `
  -question (Q-Action 'Kd Qd' $bFs) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'KQ no spade on T-9-5 two-tone -- fold; gutshot to J + 6 overcards is below threshold.' `
    "BTN c-bets T-9-5 two-tone wide; KQ has gutshot but no spade and 6 overcards that often pair villains kicker." `
    '4 gutshot outs (J makes K-Q-J-T-9) + 6 overcards (often dominated) + backdoor diamond = below threshold.' `
    'KdQd has gutshot to J + backdoor diamond + no spade; pair outs face dominated kickers.' `
    'Folding closes action cleanly; calling chases dominated outs.' `
    '-KQ has the broadway gutshot- thinking is correct on connected boards; here range disadvantage outweighs the gutshot.' `
    'KQ with gutshot on BB-favored connected board = fold (gutshot is not enough alone).') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'KQ-with-gutshot FOLD on mid-connected two-tone (vs existing AdQs on 9d8c6h rainbow). Distinct: KQ has actual gutshot here unlike AdQs which had nothing; tests that gutshot alone is insufficient on BB-favored textures.'


# ========================================================================
# Existing board (8c 8d 3s) - NEW SCENARIO
# ========================================================================

# Add JJ overpair as slowplay_call lesson - distinct from existing 8c8d3s scenarios
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_8c8d3s_m3_action_JcJh_v423b' `
  -board $bExist -heroHand @('Jc','Jh') `
  -handClass 'overpair' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote $null `
  -recommendedAction 'call' -actionReason 'slowplay_call' `
  -question (Q-Action 'Jc Jh' $bExists) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'Pocket Jacks overpair on 8c 8d 3s paired -- slowplay because BTN c-bet range is air-heavy.' `
    "BTN c-bets paired-low wide with overcards/air and overpairs; raising folds out the air range." `
    'JJ is way ahead of villains air bluffs and ties / beats most of the overpair range below QQ.' `
    'JcJh is overpair to all of 8-8-3 (J > 8 > 3); only QQ-AA, 88 (case 8s), and 33 sets beat us.' `
    'Calling preserves villain air bluffs for turn/river barrels; raising isolates QQ-AA and folds everything else.' `
    'Auto-raising overpairs on paired-low folds out air and isolates better hands; the air would have paid off slowplay.' `
    'Mid-range overpair on paired-low (where BTN range is air-heavy) = slowplay call.') `
  -conceptTags @('bluff_catchers','equity_realization_oop') `
  -difficulty 3 `
  -uniquenessNote 'SLOWPLAY_CALL #5 with OVERPAIR (vs existing 8h7h on same board which is TRIPS slowplay, vs Td9d/Ah7h trips slowplay on other paired boards). Distinct hand class: overpair vs trips on the SAME paired-low board -- tests that slowplay reasoning extends from trips to overpair on air-heavy textures.'


# ========================================================================
# Write seed JSON
# ========================================================================

$out = [ordered]@{
  schemaVersion  = '1.1.0'
  moduleId       = 'pf_flop_cbet_oop_def'
  moduleName     = 'Facing C-bet OOP'
  version        = 'v4.2.3B'
  status         = 'planning_only'
  generatedAt    = '2026-05-06'
  notes          = 'Polish expansion seeds for v4.2.3B. 23 new M3 scenarios across 5 new board families (Kh Qh 4s, Kh Jh 4h, Qd 7d 2c, Ac Ad 7s, Ts 9s 5d) + 1 added to existing 8c 8d 3s. Authored to fill thin coverage buckets from v4.2.3A baseline (blocker_raise 1->4, domination_fold 2->5, nut_flush_draw 1->3, slowplay_call 3->5, protection_raise 3->5+). Each scenario carries a uniquenessNote explaining the new strategic dimension it adds.'
  expansionStats = [ordered]@{
    newScenarios     = $scenarios.Count
    newBoards        = 5
    extendedBoards   = 1
    productionBefore = 62
    productionAfter  = 85
  }
  scenarios = $scenarios
}

Write-Output ("Total scenarios authored: " + $scenarios.Count)
$json = $out | ConvertTo-Json -Depth 100
[System.IO.File]::WriteAllText($outPath, $json, [System.Text.UTF8Encoding]::new($false))
Write-Output "Wrote: $outPath"
Write-Output "Size: $((Get-Item $outPath).Length) bytes"
