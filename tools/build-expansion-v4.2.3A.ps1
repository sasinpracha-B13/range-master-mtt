# tools/build-expansion-v4.2.3A.ps1
# v4.2.3A - Module 3 Data Expansion Builder
#
# Authors 38 new M3 scenarios across 8 new board families and writes them
# to docs/specs/postflop-v4.2.3A-module3-expansion-seeds.json (planning
# format mirroring v4.2.0 seed file). Each scenario carries a
# uniquenessNote explaining what new strategic dimension it adds.
#
# This script is the canonical authoring artifact. The seed file it
# produces is the reviewable planning JSON; production migration is a
# separate script (migrate-expansion-v4.2.3A.ps1).

$ErrorActionPreference = 'Stop'
$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$outPath  = Join-Path $repoRoot 'docs\specs\postflop-v4.2.3A-module3-expansion-seeds.json'

# Standard spot block for all M3 scenarios
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

# Standard action_choice choices array
$actionChoices = @('fold', 'call', 'check_raise_small', 'check_raise_big', 'mixed')

# Standard reason_choice choices array (full M3 reason vocab)
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
    reviewStatus      = 'v4.2.3A_expansion'
    uniquenessNote    = $uniquenessNote
  })
}

# Convenience: build standard action_choice prompt
function Q-Action($hero, $boardStr) {
  return New-Question 'action_choice' "BTN c-bets ~33% pot. What's hero's best action with $hero on $boardStr?" $actionChoices
}
# Convenience: build reason_choice prompt
function Q-Reason($action, $hero, $boardStr) {
  return New-Question 'reason_choice' "Hero $action with $hero on $boardStr vs ~33% c-bet. What is the primary reason?" $reasonChoices
}

# Convenience: pretty board string from card array
function BoardStr($cards) { return ($cards -join ' ') }


# ========================================================================
# Board family definitions
# ========================================================================

# Board 1: As 9s 4d (A-high two-tone, dry) -- BTN range adv (preflop_raiser)
$b1cards = @('As','9s','4d')
$b1board = New-Board $b1cards 'A_high' 'two_tone' @('dry','disconnected') 'A_high'
$b1str = BoardStr $b1cards

# Board 2: Ks 8s 3d (K-high two-tone, dry) -- BTN range adv
$b2cards = @('Ks','8s','3d')
$b2board = New-Board $b2cards 'K_high' 'two_tone' @('dry','disconnected') 'K_high'
$b2str = BoardStr $b2cards

# Board 3: Qs Ts 6d (Q-high two-tone, semi-connected, dynamic) -- split
$b3cards = @('Qs','Ts','6d')
$b3board = New-Board $b3cards 'Q_high' 'two_tone' @('wet','semi_connected') 'Q_high'
$b3str = BoardStr $b3cards

# Board 4: 7s 5s 3s (Low monotone, low connected) -- caller has low flushes; BTN has Ah blocker
$b4cards = @('7s','5s','3s')
$b4board = New-Board $b4cards 'low' 'monotone' @('wet','low_connected') 'low'
$b4str = BoardStr $b4cards

# Board 5: 8c 8d 3s (Paired low rainbow) -- caller has more 8x in flat range
$b5cards = @('8c','8d','3s')
$b5board = New-Board $b5cards 'low' 'rainbow' @('dry','paired') 'low'
$b5str = BoardStr $b5cards

# Board 6: 9d 8c 6h (Low semi-connected rainbow) -- caller has straights/two-pair edge
$b6cards = @('9d','8c','6h')
$b6board = New-Board $b6cards 'low' 'rainbow' @('wet','semi_connected') 'low'
$b6str = BoardStr $b6cards

# Board 7: Tc Th 6s (Paired T rainbow) -- split; BB has more T-x in flat range
$b7cards = @('Tc','Th','6s')
$b7board = New-Board $b7cards 'T_high' 'rainbow' @('dry','paired') 'T_high'
$b7str = BoardStr $b7cards

# Board 8: 6c 3d 2h (Very dry low rag rainbow) -- caller has wheel cards but BTN has overpair adv
$b8cards = @('6c','3d','2h')
$b8board = New-Board $b8cards 'low' 'rainbow' @('dry','disconnected') 'low'
$b8str = BoardStr $b8cards


# ========================================================================
# Scenario list (38 scenarios)
# ========================================================================

$scenarios = @()

# ---- Board 1: As 9s 4d ----

# 1.1 - Top two on A-high two-tone (NEW LESSON: TWO-TONE protection layer absent on rainbow As8d3h)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_As9s4d_m3_action_Ah9c_v423a' `
  -board $b1board -heroHand @('Ah','9c') `
  -handClass 'top_two_pair' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'value_raise' `
  -question (Q-Action 'Ah 9c' $b1str) `
  -answer (New-Answer 'check_raise_small' @('check_raise_big','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Top two on A-high two-tone -- raise for value AND protection from FDs.' `
    "BTN c-bets A-high two-tone wide; calling range contains many A-x and FD bluffs that pay off." `
    'Top two is far ahead of villain''s range; raising builds the pot before turns kill action.' `
    'A9 makes top two pair (As + 9s blocked). Worse hands: Ax weaker kickers, 99/44 sets are rare; FD calls a small raise.' `
    'Small raise charges A-x and FDs; big raise also defensible vs FD-heavy range to deny equity.' `
    'Slowplaying top two on a TWO-TONE board lets the FD complete cheaply on the turn.' `
    'Top two on two-tone = raise (small or big), not call.') `
  -conceptTags @('check_raise_value','value_raise','protection_raise') `
  -difficulty 3 `
  -uniquenessNote 'Top two pair lesson on A-high TWO-TONE (vs existing top-set lesson on As8d3h rainbow). Two-tone adds protection-from-FD dimension absent on rainbow.'

# 1.2 - TPGK + BDFD on A-high two-tone (NEW: the BDFD changes equity realization)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_As9s4d_m3_action_AdQd_v423a' `
  -board $b1board -heroHand @('Ad','Qd') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'strong_value' -drawCategory 'backdoor_only' -showdownValue 'high' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action 'Ad Qd' $b1str) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'TPGK + backdoor diamond on A-high two-tone -- call to keep BTN bluffs in.' `
    "BTN's c-bet range contains many bluffs and worse Ax; calling preserves value from both." `
    'AQ with backdoor diamond comfortably defends; raising folds out air without thin-value gain.' `
    'AdQd has top pair + Q kicker + backdoor diamond runner-runner.' `
    'Small raise possible vs over-bluffy villains, but call is the higher-EV default OOP.' `
    'Auto-raising TPGK OOP isolates worse made hands and folds out the bluff bucket.' `
    'TPGK + BDFD on A-high two-tone = call default, raise vs over-bluffy villains.') `
  -conceptTags @('bluff_catchers','equity_realization_oop') `
  -difficulty 3 `
  -uniquenessNote 'TPGK call lesson with BACKDOOR FD on two-tone (vs existing mid-pair calls on rainbow). Backdoor diamond gives runner-runner equity that anchors the call.'

# 1.3 - Mid pair no FD on A-high two-tone (NEW: pot-odds defense barely cleared)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_As9s4d_m3_action_9h8h_v423a' `
  -board $b1board -heroHand @('9h','8h') `
  -handClass 'mid_pair' -heroHandRole 'marginal_made_hand' -drawCategory 'none' -showdownValue 'decent' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action '9h 8h' $b1str) `
  -answer (New-Answer 'call' @() @('fold','check_raise_small','mixed','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Mid pair (9) on A-high two-tone -- call; equity barely above defense threshold.' `
    "BTN c-bet range here is wide with A-x and FD bluffs; mid pair beats most of the bluff bucket." `
    'Pair of 9s clears the ~25% defense threshold by a thin margin; raise folds out bluffs and isolates Ax.' `
    '98o has middle pair (9) with no flush draw, no straight draw, just 5 outs to two-pair/trips.' `
    'Calling realizes equity at minimum cost; raising or folding both lose EV.' `
    'Folding mid pair to a small c-bet on A-high over-folds vs villain''s wide stab range.' `
    'Mid pair without backup on A-high two-tone = call (don''t fold, don''t raise).') `
  -conceptTags @('pot_odds_defense','bluff_catchers','equity_realization_oop') `
  -difficulty 3 `
  -uniquenessNote 'Pot-odds defense lesson -- mid pair NO backdoor on two-tone (existing Th8h on rainbow As8d3h has BDFD). Tests whether hero understands defense threshold without backup equity.'

# 1.4 - Suited Broadway FD on A-high two-tone (NEW: equity realization via FD outs)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_As9s4d_m3_action_JsTs_v423a' `
  -board $b1board -heroHand @('Js','Ts') `
  -handClass 'flush_draw' -heroHandRole 'pure_draw' -drawCategory 'flush_draw' -showdownValue 'low' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action 'Js Ts' $b1str) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Suited Broadway FD + 2 overcards on A-high two-tone -- call to realize equity.' `
    "BTN c-bets A-high two-tone with many A-x value; check-raising as semi-bluff bloats vs Ax." `
    '9 outs to flush + 6 overcard outs = strong combo equity well above threshold.' `
    'JsTs has spade FD + J/T overcard outs on As9s4d.' `
    'Calling captures equity cheaply; raising forces a tough decision vs Ax that won''t fold.' `
    'Auto-raising FD + overcards OOP forces folds from BTN''s air bluffs that pay off the call.' `
    'Suited Broadway FD on A-high two-tone = call (raise occasionally vs over-folders).') `
  -conceptTags @('equity_realization_oop','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'FD + overcards CALL lesson on A-high two-tone. Distinct from monotone Jh8h4h FD scenarios; here FD + overcard equity must overcome BTN''s strong A-x bucket.'

# 1.5 - Naked overcards no equity on A-high two-tone (NEW: domination fold layer)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_As9s4d_m3_action_KcQc_v423a' `
  -board $b1board -heroHand @('Kc','Qc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_fold' `
  -question (Q-Action 'Kc Qc' $b1str) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'KQ no-equity on A-high two-tone -- fold; range disadvantage compounds with no draw.' `
    "BTN's c-bet range is A-x heavy with FDs that crush hero." `
    '6 outs to dominated pair on a board where range disadvantage is severe; defense fails.' `
    'KcQc has no pair, no flush draw, no straight draw -- just 6 overcard outs that often pair villain''s kicker.' `
    'Folding closes action cleanly; calling forces tough turn decisions with no plan.' `
    '"KQ is too pretty to fold" is the most common BB leak on dry A-high.' `
    'KQ no equity on dry A-high = automatic fold.') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 2 `
  -uniquenessNote 'KQ-no-equity fold on A-high TWO-TONE. Distinct from existing JTo on As8d3h rainbow (different overcard combo, different blocker effect -- KQ blocks AK/KQ value combos in BTN range while JTo blocks none).'


# ---- Board 2: Ks 8s 3d ----

# 2.1 - Mid pair + BDFD on K-high two-tone
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Ks8s3d_m3_action_8h7h_v423a' `
  -board $b2board -heroHand @('8h','7h') `
  -handClass 'mid_pair' -heroHandRole 'marginal_made_hand' -drawCategory 'backdoor_only' -showdownValue 'decent' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action '8h 7h' $b2str) `
  -answer (New-Answer 'call' @() @('fold','check_raise_small','mixed','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Mid pair (8) + backdoor heart on K-high two-tone -- call.' `
    "BTN c-bets K-high two-tone wide with K-x value, FD bluffs, and air." `
    'Pair of 8s + backdoor heart equity comfortably defends vs small c-bet.' `
    '8h7h has middle pair + BDFD + 2-card backdoor straight (4-5-6-7-8 needs runner-runner).' `
    'Calling realizes equity cheaply; raising bloats OOP vs K-x value that doesn''t fold.' `
    'Folding mid pair on K-high two-tone over-folds vs the FD-heavy bluff bucket.' `
    'Mid pair + BDFD on K-high two-tone = call.') `
  -conceptTags @('bluff_catchers','equity_realization_oop','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'Mid pair on K-high TWO-TONE with BDFD (vs existing 9d8d on Kh9c4s rainbow). Two-tone adds FD-bluff weight to BTN''s c-bet range, raising the EV of calling.'

# 2.2 - Naked low FD on K-high two-tone (NEW: FD-only call without overcard)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Ks8s3d_m3_action_6s5s_v423a' `
  -board $b2board -heroHand @('6s','5s') `
  -handClass 'flush_draw' -heroHandRole 'pure_draw' -drawCategory 'flush_draw' -showdownValue 'low' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action '6s 5s' $b2str) `
  -answer (New-Answer 'call' @() @('fold','check_raise_small','mixed','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Naked low FD on K-high two-tone -- call to realize FD equity.' `
    "BTN c-bets K-high two-tone wide; calling preserves FD equity vs the entire range." `
    '9 outs to flush = ~36% raw equity, well above defense threshold.' `
    '6s5s has 9 outs to a low flush + a backdoor straight (3-4-5-6-7 needs 4 + 7).' `
    'Calling realizes FD cheaply; raising is too thin OOP without an overcard or made hand.' `
    'Auto-raising bare low FDs OOP bloats the pot vs K-x that won''t fold to a small raise.' `
    'Naked low FD on K-high two-tone = call (raise rare without overcard or made hand).') `
  -conceptTags @('equity_realization_oop','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'Naked LOW FD without overcards (vs existing FD scenarios that had overcards). Tests pure FD-equity defense without backup pair outs.'

# 2.3 - Nut FD + 2 overcards on K-high two-tone (NEW: nut_flush_draw drawCategory + semi-bluff)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Ks8s3d_m3_action_AsQs_v423a' `
  -board $b2board -heroHand @('As','Qs') `
  -handClass 'nut_flush_draw' -heroHandRole 'semi_bluff_combo' -drawCategory 'nut_flush_draw' -showdownValue 'low' `
  -blockerNote 'As blocks BTN''s nut FD combos; weakens BTN''s spade-FD bluffing range.' `
  -recommendedAction 'check_raise_small' -actionReason 'semi_bluff_raise' `
  -question (Q-Action 'As Qs' $b2str) `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Nut FD + 2 overcards on K-high two-tone -- premium semi-bluff raise.' `
    "BTN c-bets K-high two-tone wide; semi-bluff applies fold equity to weak K-x and air." `
    '9 nut FD outs + 6 overcard outs + As blocker = ~50% equity when called and big fold equity.' `
    'AsQs has nut FD + 2 overcards + As blocks BTN''s nut FD combos.' `
    'Small raise applies pressure now; nut blocker reduces villain''s value bluff-catchers.' `
    'Just calling with nut FD + overcards OOP wastes premium fold equity vs a wide c-bet.' `
    'Nut FD + overcards on K-high two-tone = semi-bluff raise.') `
  -conceptTags @('check_raise_bluff','semi_bluff_raise','equity_realization_oop') `
  -difficulty 4 `
  -uniquenessNote 'NUT FLUSH DRAW with blocker (first nut_flush_draw drawCategory in M3). Distinct semi-bluff lesson combining max equity + nut blocker -- different from monotone Jh8h4h scenarios because nut FD with overcards on TWO-TONE has more fold equity.'

# 2.4 - TPGK on K-high two-tone (NEW: protection_raise vs rainbow K-high call line)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Ks8s3d_m3_action_KcJh_v423a' `
  -board $b2board -heroHand @('Kc','Jh') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'protection_raise' `
  -question (Q-Action 'Kc Jh' $b2str) `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'TPGK on K-high TWO-TONE -- raise for protection from flush draws.' `
    "BTN c-bets K-high two-tone with K-x weaker kickers, FDs, and air; raising charges FDs and gets called by Kx weaker." `
    'Top pair good kicker is ahead of BTN''s range but vulnerable to FD turns; raising charges draws.' `
    'KcJh has top pair K + J kicker; FD turns kill action and let weaker Kx call cheaply.' `
    'Small raise charges FDs and extracts thin value from weaker K-x and FD calls.' `
    'Just calling TPGK on a TWO-TONE lets FDs see free turns and pay off thin.' `
    'TPGK on K-high two-tone = raise for protection (call only on rainbow textures).') `
  -conceptTags @('check_raise_value','protection_raise','value_raise') `
  -difficulty 3 `
  -uniquenessNote 'PROTECTION_RAISE lesson with TPGK on TWO-TONE (vs rainbow K-high where TPGK calls). Tests recognition that suit texture changes raise/call decision for the same hand class.'

# 2.5 - QJ no-equity on K-high two-tone (NEW: domination_fold lesson)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_Ks8s3d_m3_action_QdJh_v423a' `
  -board $b2board -heroHand @('Qd','Jh') `
  -handClass 'no_pair_no_draw' -heroHandRole 'dominated_marginal' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote 'No relevant blockers; Q and J both pair to dominated kickers vs BTN''s K-x.' `
  -recommendedAction 'fold' -actionReason 'domination_fold' `
  -question (Q-Action 'Qd Jh' $b2str) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'QJ no-equity on K-high two-tone -- fold; pair outs are dominated.' `
    "BTN c-bet range is K-x heavy with FD bluffs; QJ has no draw and dominated pair outs." `
    '6 pair outs but Q-pair loses to KQ, J-pair loses to KJ; reverse implied odds confirm fold.' `
    'QJ has no pair, no FD, no straight draw on K-8-3 (gutshot to T is too thin); pair outs face KQ/KJ dominance.' `
    'Folding closes action; calling chases dominated outs into a multi-street pot.' `
    'Calling QJ on K-high "because two overcards" bleeds chips to dominated K-x.' `
    'Two overcards dominated by villain''s K-x range = fold despite seeming "live" outs.') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'DOMINATION_FOLD lesson with QJ (vs existing AhQs domination on Kh9c4s). Different overcard combo -- QJ on K-high two-tone has even worse domination because both Q-pair and J-pair lose to top-pair-better-kicker more often.'


# ---- Board 3: Qs Ts 6d ----

# 3.1 - Combo draw OE+FD (15 outs) on dynamic Q-high two-tone
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_QsTs6d_m3_action_KsJs_v423a' `
  -board $b3board -heroHand @('Ks','Js') `
  -handClass 'combo_draw' -heroHandRole 'semi_bluff_combo' -drawCategory 'combo_draw' -showdownValue 'low' `
  -blockerNote 'Ks blocks K-high flushes; Js blocks J-x straight combos.' `
  -recommendedAction 'check_raise_small' -actionReason 'semi_bluff_raise' `
  -question (Q-Action 'Ks Js' $b3str) `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Combo draw -- OE + FD + 2 overcards (~15 outs) -- premium semi-bluff raise.' `
    "BTN c-bets Q-high two-tone wide; combo equity exceeds 50% vs much of BTN''s range." `
    '9 spade outs + 8 straight outs (some overlap) = ~15 unique outs ~ near coin-flip equity.' `
    'KsJs has spade FD + open-ender (need A or 9 for straight) + 2 overcards.' `
    'Small raise applies pressure now and sets up turn barrels on the right cards.' `
    'Just calling with 15-out combo draws OOP misses premium fold equity.' `
    'Combo draws (FD + OE + overcards) on Q-high two-tone = semi-bluff raise.') `
  -conceptTags @('check_raise_bluff','semi_bluff_raise') `
  -difficulty 3 `
  -uniquenessNote 'COMBO DRAW SEMI-BLUFF on Q-high two-tone (vs existing 9h8h on QhJh6c which had FD+gutshot, ~12 outs). KsJs has FD + OE = ~15 outs; tests max-combo-equity raise lesson.'

# 3.2 - Top two on dynamic Q-high two-tone
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_QsTs6d_m3_action_QcTd_v423a' `
  -board $b3board -heroHand @('Qc','Td') `
  -handClass 'top_two_pair' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'value_raise' `
  -question (Q-Action 'Qc Td' $b3str) `
  -answer (New-Answer 'check_raise_small' @('check_raise_big') @('fold','call','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Top two on dynamic Q-high two-tone -- raise for value AND protection.' `
    "BTN c-bets Q-high two-tone with overpairs, Q-x, J-x with FD, and air; many turns kill action." `
    'Top two is far ahead but vulnerable to FD/OE turns; raising builds the pot now.' `
    'QcTd makes top two pair (Q + T); only QQ/TT/66 sets and JxXs straights beat it (rare).' `
    'Small raise charges FDs/OE draws and gets called by Qx + overpairs; big raise also defensible.' `
    'Slowplaying top two on a wet two-tone lets straight + flush draws complete cheaply.' `
    'Top two on dynamic two-tone = raise (small or big) for value + protection.') `
  -conceptTags @('check_raise_value','value_raise','protection_raise') `
  -difficulty 3 `
  -uniquenessNote 'Top two value+protection on Q-high TWO-TONE (vs existing top-set QcQd on QhJh6c). Top TWO is more vulnerable than top SET, so the protection layer is even more important.'

# 3.3 - FD + gutshot (no overcard) on Q-high two-tone
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_QsTs6d_m3_action_9s8s_v423a' `
  -board $b3board -heroHand @('9s','8s') `
  -handClass 'flush_draw' -heroHandRole 'pure_draw' -drawCategory 'flush_draw' -showdownValue 'low' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action '9s 8s' $b3str) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'FD + gutshot (no overcard) on Q-high two-tone -- call to realize equity cheaply.' `
    "BTN c-bets Q-high two-tone wide; calling preserves equity at minimum cost." `
    '9 spade outs + 4 gutshot outs = strong combo equity; no overcard equity reduces fold-equity value of raising.' `
    '9s8s has spade FD + gutshot to 7 (5-6-7-8-9 straight).' `
    'Calling realizes 13 outs cheaply; raising is too thin without overcards to add fold equity.' `
    'Auto-raising every FD OOP folds out air bluffs that pay off the call.' `
    'FD + gutshot WITHOUT overcards on dynamic two-tone = call (raise needs overcard backup).') `
  -conceptTags @('equity_realization_oop','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'FD + gutshot WITHOUT overcards (vs Board 3.1 KsJs which has overcards). Tests recognition that overcard backup matters for raise EV -- without overcards, call is the higher-EV line.'

# 3.4 - AK with BDFD on Q-high two-tone (NEW: pot odds defense via overcards + BDFD)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_QsTs6d_m3_action_AcKc_v423a' `
  -board $b3board -heroHand @('Ac','Kc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'marginal_made_hand' -drawCategory 'backdoor_only' -showdownValue 'low' `
  -blockerNote 'Ace blocks AQ value; K blocks KQ value.' `
  -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action 'Ac Kc' $b3str) `
  -answer (New-Answer 'call' @('fold') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'AK with BDFD + gutshot + overcards on Q-high two-tone -- call (close decision).' `
    "BTN c-bets Q-high two-tone wide; AK has multiple equity sources to defend." `
    'Gutshot to J + 6 overcard outs + backdoor club = ~24% equity, just clearing defense threshold.' `
    'AcKc has gutshot (J makes broadway) + 6 overcards + backdoor clubs.' `
    'Calling realizes the multi-source equity; folding is also defensible vs strong villains.' `
    'Auto-folding AK with backdoor + gutshot under-defends; auto-raising bloats vs Q-x.' `
    'AK with multi-source backdoor equity on Q-high = call (close to fold threshold).') `
  -conceptTags @('pot_odds_defense','equity_realization_oop','range_disadvantage') `
  -difficulty 4 `
  -uniquenessNote 'POT-ODDS DEFENSE lesson with AK on dynamic board where equity is borderline. Tests close call/fold decision with multi-source backdoor equity vs simple "fold AK no pair."'

# 3.5 - Bottom gutshot no FD on Q-high two-tone (NEW: dominated draw fold)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_QsTs6d_m3_action_5h4d_v423a' `
  -board $b3board -heroHand @('5h','4d') `
  -handClass 'gutshot' -heroHandRole 'give_up' -drawCategory 'gutshot' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_fold' `
  -question (Q-Action '5h 4d' $b3str) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Bottom gutshot (need 3 or 7) no FD on Q-high two-tone -- fold; dominated draw.' `
    "BTN c-bet range here is Q-x value + FD bluffs; 5-4 is dominated by both." `
    '4 gutshot outs (~9% equity) is far below defense threshold; no overcards or backdoor to lean on.' `
    '54o has gutshot to 3 (3-4-5-6-7) on Qs Ts 6d -- 4 outs, no other equity.' `
    'Folding closes action cleanly; calling chases dominated outs.' `
    '"Any pair will do" thinking with 5-4 on broadway boards bleeds chips.' `
    'Bottom gutshot without backdoor on broadway boards = fold.') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 2 `
  -uniquenessNote 'BOTTOM GUTSHOT FOLD on dynamic broadway. Distinct from existing 8c4c on QhJh6c (backdoor only) -- 5-4 has actual gutshot but still fails because of dominated outs and severe range disadvantage.'


# ---- Board 4: 7s 5s 3s ----

# 4.1 - A-blocker + wheel gutshot on monotone (no spade)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_7s5s3s_m3_action_As6h_v423a' `
  -board $b4board -heroHand @('As','6h') `
  -handClass 'gutshot' -heroHandRole 'bluff_catcher' -drawCategory 'gutshot' -showdownValue 'low' `
  -blockerNote 'As blocks BTN''s nut flush combos AND nut FD bluffs.' `
  -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action 'As 6h' $b4str) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'A-blocker + wheel gutshot on monotone -- call leveraging the As blocker.' `
    "BTN c-bets monotone polarized (flushes vs air); As blocks all of BTN''s nut flush combos." `
    'Wheel gutshot (need 4) + A-overcard + As blocker reduces villain''s value, raising defense EV.' `
    'As6h has the As blocker + gutshot to 4 (3-4-5-6-7) + 6 outs to top pair (rare to win at SD).' `
    'Calling preserves the blocker''s bluff-catching value; raising can fold out air but is variance-heavy.' `
    'Folding the As-blocker on monotone over-folds vs villain''s polar bluff range.' `
    'A-blocker on monotone with no spade = call (raise occasionally as blocker pressure).') `
  -conceptTags @('bluff_catchers','equity_realization_oop','oop_defense_threshold') `
  -difficulty 4 `
  -uniquenessNote 'A-blocker bluff-catch on MONOTONE without spade (first lesson of this kind in M3). Existing monotone Jh8h4h has 9h8c with 1-card FD -- completely different blocker dynamic.'

# 4.2 - Made middle flush + OESD on monotone
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_7s5s3s_m3_action_8s6s_v423a' `
  -board $b4board -heroHand @('8s','6s') `
  -handClass 'flush' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Holds 8s + 6s blocks BTN''s 86s gut-straight combos.' `
  -recommendedAction 'check_raise_big' -actionReason 'value_raise' `
  -question (Q-Action '8s 6s' $b4str) `
  -answer (New-Answer 'check_raise_big' @('check_raise_small','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Made middle flush + OESD redraw on monotone -- raise BIG for value.' `
    "BTN c-bets monotone with worse flushes, big spade combos, and air; raising gets called by worse." `
    'Made flush + 4-out OESD redraw to straight flush -- far ahead of villain''s value.' `
    '8s6s has middle flush + open-ender to straight flush (need 4 or 9 of spades = straight flush).' `
    'Big raise (~4x) targets weaker spade flushes that pay off; small raise also acceptable.' `
    'Slowplaying middle flush on monotone misses value vs weaker flush combos that call.' `
    'Made flush on monotone OOP = raise (small or big) for value.') `
  -conceptTags @('check_raise_value','value_raise') `
  -difficulty 3 `
  -uniquenessNote 'MADE FLUSH value raise on monotone (vs existing Ah Kh nut flush on Jh8h4h). 8s6s is middle flush -- teaches that not every flush is the nuts; sizing differs from nut flush (small/medium more often than big).'

# 4.3 - Mid pair no spade on monotone (close fold)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_7s5s3s_m3_action_6h5h_v423a' `
  -board $b4board -heroHand @('6h','5h') `
  -handClass 'mid_pair' -heroHandRole 'dominated_marginal' -drawCategory 'gutshot' -showdownValue 'low' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_fold' `
  -question (Q-Action '6h 5h' $b4str) `
  -answer (New-Answer 'fold' @('call') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Mid pair (5) + gutshot, no spade on monotone -- fold; equity realization too low.' `
    "BTN c-bets monotone polarized; pair of 5s loses to all flushes and is dominated by 6x and 7x." `
    'Pair + gutshot raw equity ~25% but realized equity OOP on monotone is much lower.' `
    '6h5h has middle pair (5) + gutshot to 4 (need 4 for wheel); no flush blocker or draw.' `
    'Folding closes the variance; calling forces tough turn decisions vs the polar range.' `
    'Calling every "pair + gutshot" without a spade on monotone over-defends vs polar ranges.' `
    'Pair + gutshot WITHOUT spade on monotone = fold (close decision; depends on opponent).') `
  -conceptTags @('pot_odds_defense','range_disadvantage') `
  -difficulty 4 `
  -uniquenessNote 'POT-ODDS DEFENSE FAIL lesson -- pair + gutshot looks playable on raw equity but realized equity OOP on monotone is below threshold. Distinct close-fold lesson with marginal pair without flush blocker.'

# 4.4 - Naked overcards no spade on monotone
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_7s5s3s_m3_action_KhQh_v423a' `
  -board $b4board -heroHand @('Kh','Qh') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_fold' `
  -question (Q-Action 'Kh Qh' $b4str) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'KQ no spade on monotone low -- automatic fold; zero flush equity.' `
    "BTN c-bets monotone with flushes and air; without a spade hero has no flush equity at all." `
    'Zero flush outs + 6 overcard outs that often lose to higher pair = far below threshold.' `
    'KhQh has no spade, no pair, no straight draw on 7s5s3s -- purely overcard equity.' `
    'Folding is automatic; calling with zero flush equity bleeds chips into a polar range.' `
    'Floating big overcards "because they''re Broadway" without a spade on monotone is a major leak.' `
    'No spade + overcards on monotone = fold (regardless of overcard rank).') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 2 `
  -uniquenessNote 'NO-SPADE OVERCARDS FOLD on monotone. Distinct from existing 6c5d on Jh8h4h (different overcard rank class -- KQ are higher overcards but still dominated; tests that overcard rank doesn''t rescue a no-equity hand on monotone).'

# 4.5 - As Kh blocker_raise reason_choice on monotone
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_7s5s3s_m3_reason_AsKh_v423a' `
  -board $b4board -heroHand @('As','Kh') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote 'As is the nut-flush blocker on monotone spades; folds out BTN''s flush draws and bluffs.' `
  -recommendedAction 'check_raise_small' -actionReason 'blocker_raise' `
  -question (Q-Reason 'check-raises small' 'As Kh' $b4str) `
  -answer (New-Answer 'blocker_raise' @('equity_realization_call') @('value_raise','protection_raise','semi_bluff_raise','bluff_catch','range_disadvantage_fold','domination_fold') @()) `
  -explanation (New-Explanation `
    'A-high check-raise on monotone -- primary reason is the nut-flush blocker.' `
    "BTN's c-bet range on monotone is polarized (made flushes + air); the As blocks villain''s flush combos." `
    'The check-raise''s EV comes from blocker pressure, not made-hand strength or draw equity.' `
    'AsKh has no pair, no draw -- but As removes the nut-flush combos and most FD bluffs from BTN''s value range.' `
    'Small raise (~3x) leverages the blocker; sizing should not be big since fold equity drops vs polar value.' `
    'Identifying this as semi_bluff_raise misses the mechanism -- the equity is from BLOCKING value, not from outs.' `
    'OOP raise with the nut-flush blocker on monotone = blocker_raise (not semi_bluff).') `
  -conceptTags @('check_raise_bluff','range_disadvantage','oop_defense_threshold') `
  -difficulty 5 `
  -uniquenessNote 'BLOCKER_RAISE actionReason (FIRST in M3 -- current count is 0). Tests advanced concept that some OOP raises are reason="blocker" not "semi-bluff" -- important distinction for solver-aware play.'


# ---- Board 5: 8c 8d 3s ----

# 5.1 - Trips with kicker on paired low -- slowplay
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_8c8d3s_m3_action_8h7h_v423a' `
  -board $b5board -heroHand @('8h','7h') `
  -handClass 'trips' -heroHandRole 'nutted_value' -drawCategory 'backdoor_only' -showdownValue 'nutted' `
  -blockerNote 'Holds the case 8 (only one in deck after 8c, 8d); blocks BTN''s 8x almost entirely.' `
  -recommendedAction 'call' -actionReason 'slowplay_call' `
  -question (Q-Action '8h 7h' $b5str) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'Trips on paired LOW board -- slowplay because BTN c-bets paired-low wide with air.' `
    "BTN c-bets paired low boards heavily with air (overcard hands, overpairs); raising folds the air out." `
    'Trips is far ahead of villain''s range; calling preserves the bluff bucket for turn/river barrels.' `
    '8h7h has trips + a backdoor heart flush + backdoor straight draw (5-6-7-8-9 needs 5+6 or 9).' `
    'Calling lets BTN barrel air on later streets; raising small folds out almost everything that doesn''t have 88.' `
    'Auto-raising trips on paired-low folds out the wide air range and isolates better hands (rare).' `
    'Trips on paired LOW = slowplay call; raise only on dynamic boards where protection matters.') `
  -conceptTags @('bluff_catchers','equity_realization_oop') `
  -difficulty 4 `
  -uniquenessNote 'SLOWPLAY_CALL with TRIPS on paired LOW (vs existing AhKh trips on KcKd7s paired HIGH). Different board context -- paired LOW shifts BTN range toward more air vs paired HIGH where BTN has K-x value combos.'

# 5.2 - Underpair to paired-low -- bluff catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_8c8d3s_m3_action_5h5d_v423a' `
  -board $b5board -heroHand @('5h','5d') `
  -handClass 'underpair' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'decent' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'bluff_catch' `
  -question (Q-Action '5h 5d' $b5str) `
  -answer (New-Answer 'call' @() @('fold','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Pocket fives underpair on 88x -- call to bluff-catch villain''s air c-bets.' `
    "BTN c-bets paired-low with overcards and air; pocket 5s beats the entire bluff range." `
    'Pair beats most of villain''s c-bet range; raise folds out the bluffs that pay off the call.' `
    '55 has an underpair to 8 but overpair to 3; only 88, 99-AA, and 8x beat us.' `
    'Calling preserves villain''s bluff bucket; raising isolates better hands (overpairs, 8x).' `
    'Folding any pair on paired-low boards over-folds vs villain''s wide stab range.' `
    'Any small pair on paired-low = call (bluff-catch).') `
  -conceptTags @('bluff_catchers','equity_realization_oop') `
  -difficulty 3 `
  -uniquenessNote 'UNDERPAIR BLUFF-CATCH on paired LOW (vs existing 8d8s on KcKd7s paired HIGH). Different range dynamics -- paired-low BTN range is air-heavier, making the bluff-catch even more profitable.'

# 5.3 - AK no draw on paired low -- bluff catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_8c8d3s_m3_action_AhKs_v423a' `
  -board $b5board -heroHand @('Ah','Ks') `
  -handClass 'no_pair_no_draw' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote 'A and K block BTN''s top-of-range overpair value (AA, KK).' `
  -recommendedAction 'call' -actionReason 'bluff_catch' `
  -question (Q-Action 'Ah Ks' $b5str) `
  -answer (New-Answer 'call' @('fold') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'AK no pair on paired-low -- call as a bluff-catcher; A blocks villain''s top value.' `
    "BTN c-bets paired-low wide with air; AK with A-blocker beats the entire air range." `
    '6 overcard outs + ace-high showdown beats villain''s air; A blocks AA and AK value.' `
    'AhKs has no pair on 8c8d3s but A blocks AA top-of-range and 6 overcards can pair best.' `
    'Calling captures villain''s air bluffs; folding under-defends vs the wide stab range.' `
    'Auto-folding AK on paired-low because "no pair" misses the A-blocker bluff-catch line.' `
    'AK on paired-low = call (bluff-catch with A-blocker), not fold.') `
  -conceptTags @('bluff_catchers','equity_realization_oop','range_disadvantage') `
  -difficulty 4 `
  -uniquenessNote 'AK NO-PAIR BLUFF-CATCH on paired-low. Distinct from existing AhKc fold on 8s7d5h connected board -- paired-low is range-stab-heavy texture where AK has bluff-catching equity; connected-low is BB-favored texture where AK should fold. Different board class teaches different defense math.'

# 5.4 - T9 + BDFD on paired low -- pot odds defense
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_8c8d3s_m3_action_Tc9c_v423a' `
  -board $b5board -heroHand @('Tc','9c') `
  -handClass 'no_pair_no_draw' -heroHandRole 'marginal_made_hand' -drawCategory 'backdoor_only' -showdownValue 'low' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action 'Tc 9c' $b5str) `
  -answer (New-Answer 'call' @('fold') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'T9 with backdoor club + 2 overcards on paired-low -- call to realize backdoor equity.' `
    "BTN c-bets paired-low with mostly air; T9 with 2 overcards + backdoor FD beats much of that range." `
    '6 overcard outs + backdoor club + backdoor straight = ~22% combined equity, just clearing threshold.' `
    'Tc9c has 6 overcard pair outs, backdoor club FD, and backdoor straight (5-6-7-8-9 or 6-7-8-9-T).' `
    'Calling captures villain''s air at minimum cost; folding over-folds; raising bloats vs no fold equity.' `
    'Folding T9 with backdoor on paired-low under-defends vs villain''s wide stab.' `
    'T9 with multi-source backdoor on paired-low = call (close to fold threshold).') `
  -conceptTags @('pot_odds_defense','bluff_catchers','equity_realization_oop') `
  -difficulty 4 `
  -uniquenessNote 'POT-ODDS DEFENSE with TWO overcards + BDFD on paired-low. Tests recognition that backdoor equity matters at the defense threshold -- distinct from "auto-fold no pair" instinct on paired boards.'

# 5.5 - QJ no equity on paired low -- fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_8c8d3s_m3_action_QdJh_v423a' `
  -board $b5board -heroHand @('Qd','Jh') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_fold' `
  -question (Q-Action 'Qd Jh' $b5str) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'QJ no equity on paired-low -- fold; even paired boards have a defense floor.' `
    "BTN c-bet range still has overpairs and 8-x; QJ has no draw, no FD, no relevant blocker." `
    '6 pair outs minus dominated by villain''s overpairs (KK/QQ blocks J-pair) = below threshold.' `
    'QJo on 8c8d3s has no pair, no FD, no straight draw, no relevant blocker.' `
    'Folding closes action; calling chases dominated outs into a polarized range.' `
    'Believing "any two cards defends paired boards" is a frequency leak.' `
    'Even on paired low boards, naked overcards without backup = fold.') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 2 `
  -uniquenessNote 'PAIRED-LOW FOLD lesson -- proves paired boards still have a defense floor. Distinct from #5.3 (AhKs) by lacking the A-blocker; tests that not every "two overcards" defends.'


# ---- Board 6: 9d 8c 6h ----

# 6.1 - Top set on connected rainbow -- protection
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_9d8c6h_m3_action_9c9s_v423a' `
  -board $b6board -heroHand @('9c','9s') `
  -handClass 'set' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'protection_raise' `
  -question (Q-Action '9c 9s' $b6str) `
  -answer (New-Answer 'check_raise_small' @('check_raise_big','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Top set on connected rainbow -- raise for protection from straights and overpairs.' `
    "BTN c-bets connected boards with overpairs, top pair, and many straight draws." `
    'Top set is huge but vulnerable on a board with 7-T straights coming; protection is essential.' `
    '9c9s makes top set on 9d8c6h; only 88, 66, T7 straights beat us (rare).' `
    'Small raise charges OE/gutshots and gets called by overpairs; big raise also defensible.' `
    'Slowplaying top set on connected boards lets straight draws complete cheaply.' `
    'Top set on connected boards = raise (small or big) for value AND protection.') `
  -conceptTags @('check_raise_value','protection_raise','value_raise') `
  -difficulty 3 `
  -uniquenessNote 'TOP SET PROTECTION on connected rainbow (vs existing 5c5d BOTTOM set on 8s7d5h). Different position on board -- top set is best by amount but more vulnerable to straight completions; lesson tests recognition that even top set needs protection on connected textures.'

# 6.2 - Top + bottom pair + gutshot on connected
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_9d8c6h_m3_action_8h6c_v423a' `
  -board $b6board -heroHand @('8h','6c') `
  -handClass 'two_pair' -heroHandRole 'strong_value' -drawCategory 'gutshot' -showdownValue 'high' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'value_raise' `
  -question (Q-Action '8h 6c' $b6str) `
  -answer (New-Answer 'check_raise_small' @('check_raise_big','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Two pair (8 + 6) + gutshot to 7 on connected rainbow -- raise for value + protection.' `
    "BTN c-bets connected with overpairs, top pair, and many draws; two pair is way ahead but vulnerable." `
    'Two pair is far ahead now but loses to 7-x straight on the turn; raising charges those draws.' `
    '86o makes top + bottom pair (8 + 6) + gutshot to 7 (5-6-7-8-9 straight).' `
    'Small raise gets called by overpairs and 9-x and folds OE/gutshot draws; big also acceptable.' `
    'Slowplaying two pair on a wet connected board folds to a 7 turn most of the time.' `
    'Two pair on connected boards = raise for value + protection from completing straights.') `
  -conceptTags @('check_raise_value','value_raise','protection_raise') `
  -difficulty 3 `
  -uniquenessNote 'TWO-PAIR with gutshot value-raise on connected board. Distinct from set lessons -- two pair is more vulnerable than set, requiring more aggressive protection.'

# 6.3 - OE + BDFD semi-bluff on connected
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_9d8c6h_m3_reason_Tc7c_v423a' `
  -board $b6board -heroHand @('Tc','7c') `
  -handClass 'oesd' -heroHandRole 'semi_bluff_combo' -drawCategory 'oesd' -showdownValue 'low' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'semi_bluff_raise' `
  -question (Q-Reason 'check-raises small' 'Tc 7c' $b6str) `
  -answer (New-Answer 'semi_bluff_raise' @('equity_realization_call') @('value_raise','protection_raise','blocker_raise','bluff_catch','range_disadvantage_fold','domination_fold') @()) `
  -explanation (New-Explanation `
    'OE + backdoor club + middle pair on connected -- semi-bluff raise.' `
    "BTN c-bets connected wide; T7 with multiple equity sources is a balanced semi-bluff." `
    '8 OE outs + 3 backdoor clubs + middle pair (7) = strong combined equity.' `
    'Tc7c has open-ender (need 5 or T for straight) + middle pair + backdoor club FD on 9d8c6h.' `
    'Small raise applies fold equity + sets up turn barrels; calling also defensible to realize equity.' `
    'Identifying as protection_raise misses the lesson -- middle pair is too weak to be the value engine.' `
    'OE + middle pair + BDFD on connected = semi_bluff_raise (the OE drives the EV).') `
  -conceptTags @('check_raise_bluff','semi_bluff_raise') `
  -difficulty 4 `
  -uniquenessNote 'SEMI-BLUFF REASON_CHOICE with mid-pair component (vs existing Td9d on 8s7d5h which was OE+overcards). Tests distinguishing semi_bluff_raise from protection_raise when hand has both draw and made-hand components.'

# 6.4 - JT overcards + OESD on connected -- call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_9d8c6h_m3_action_JsTh_v423a' `
  -board $b6board -heroHand @('Js','Th') `
  -handClass 'oesd' -heroHandRole 'pure_draw' -drawCategory 'oesd' -showdownValue 'low' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action 'Js Th' $b6str) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'JT with OESD + 2 overcards on connected rainbow -- call to realize equity.' `
    "BTN c-bets connected wide; JT has multiple equity sources well above defense threshold." `
    '8 OE outs (need 7 or Q) + 6 overcard outs = strong combined equity.' `
    'JsTh has open-ender to 7 or Q on 9d8c6h + 2 overcards.' `
    'Calling realizes the equity at minimum cost; raising semi-bluff also defensible.' `
    'Folding JT with OE + overcards on connected over-folds vs villain''s wide range.' `
    'OE + overcards on connected boards = call (raise as alt vs over-bluffy villains).') `
  -conceptTags @('equity_realization_oop','oop_defense_threshold') `
  -difficulty 3 `
  -uniquenessNote 'OE + OVERCARDS CALL on connected (vs Board 6.3 reason_choice for raise line). Different from existing 9c8c on 8s7d5h (top pair + gutshot -- has made hand) -- JT is pure-draw + overcards, tests pure equity-realization defense.'

# 6.5 - AQ no equity on connected -- fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_9d8c6h_m3_action_AdQs_v423a' `
  -board $b6board -heroHand @('Ad','Qs') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_fold' `
  -question (Q-Action 'Ad Qs' $b6str) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'AQ no draw on connected low rainbow -- fold; range disadvantage with no equity.' `
    "BTN c-bets connected with overpairs, top pair, draws -- AQ has no equity to defend." `
    '6 overcard outs that often lose to better pair; no straight or flush equity.' `
    'AdQs has no pair, no draw, no relevant blocker on 9d8c6h.' `
    'Folding cleanly avoids variance; calling chases dominated outs.' `
    'Floating AQ "because the cards are big" on connected boards bleeds chips.' `
    'Naked AQ on connected low = fold (range disadvantage compounds with no equity).') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 2 `
  -uniquenessNote 'AQ NO-EQUITY FOLD on connected (similar lesson to AhKc on 8s7d5h but with different overcard pair AQ vs AK). AQ is even worse because Q-pair more often dominated than K-pair.'


# ---- Board 7: Tc Th 6s ----

# 7.1 - Trips weak kicker on paired T -- slowplay
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_TcTh6s_m3_action_Td9d_v423a' `
  -board $b7board -heroHand @('Td','9d') `
  -handClass 'trips' -heroHandRole 'nutted_value' -drawCategory 'backdoor_only' -showdownValue 'nutted' `
  -blockerNote 'Holds the case T (only one in deck after Tc, Th); blocks BTN''s T-x almost entirely.' `
  -recommendedAction 'call' -actionReason 'slowplay_call' `
  -question (Q-Action 'Td 9d' $b7str) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold','check_raise_big')) `
  -explanation (New-Explanation `
    'Trips with weak kicker on paired T -- slowplay because BTN''s c-bet range is air-heavy.' `
    "BTN c-bets paired T wide with overpairs and air; raising folds out the air bluffs." `
    'Trips dominates villain''s c-bet range; calling preserves villain''s bluff bucket for turn/river barrels.' `
    'Td9d has trips + a backdoor diamond + backdoor straight (need 7+8 for 6-7-8-9-T).' `
    'Calling lets BTN barrel air on later streets; raising small folds out almost everything.' `
    'Auto-raising trips on paired boards isolates better hands and folds out the wide bluff bucket.' `
    'Trips on paired board (especially weak kicker) = slowplay call.') `
  -conceptTags @('bluff_catchers','equity_realization_oop') `
  -difficulty 4 `
  -uniquenessNote 'SLOWPLAY_CALL with TRIPS WEAK KICKER on paired T (vs existing AhKh trips top-kicker on KcKd7s). Weak-kicker trips has even more reason to slowplay because raising loses value on the few hands that pay off.'

# 7.2 - Bottom pair + BDFD on paired T -- bluff catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_TcTh6s_m3_action_6c5c_v423a' `
  -board $b7board -heroHand @('6c','5c') `
  -handClass 'bottom_pair' -heroHandRole 'bluff_catcher' -drawCategory 'backdoor_only' -showdownValue 'decent' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'bluff_catch' `
  -question (Q-Action '6c 5c' $b7str) `
  -answer (New-Answer 'call' @() @('fold','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Bottom pair (6) + backdoor club on paired T -- bluff-catch villain''s air.' `
    "BTN c-bets paired T wide with overcards and air; pair of 6s beats the entire bluff range." `
    'Pair + BDFD comfortably defends vs the air-heavy stab range.' `
    '6c5c has bottom pair + backdoor club FD + backdoor straight (need 4+7 for 4-5-6-7-8 -- wait that''s 6-card; correct: 4-5-6-7-8 only with both 4 and 8 = runner-runner OE).' `
    'Calling captures bluffs; raising folds them out and isolates better hands (overpairs, T-x).' `
    'Folding any pair on paired T over-folds vs villain''s stab range.' `
    'Bottom pair + backdoor on paired T = call (bluff-catch).') `
  -conceptTags @('bluff_catchers','equity_realization_oop') `
  -difficulty 3 `
  -uniquenessNote 'BOTTOM-PAIR BLUFF-CATCH on paired T (distinct from underpair bluff-catches and from mid-pair on Kc Kd 7s). Specifically tests defense with bottom pair, which is a different value class.'

# 7.3 - AK no draw on paired T -- bluff catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_TcTh6s_m3_action_AhKc_v423a' `
  -board $b7board -heroHand @('Ah','Kc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote 'A and K block BTN''s top-of-range overpair value.' `
  -recommendedAction 'call' -actionReason 'bluff_catch' `
  -question (Q-Action 'Ah Kc' $b7str) `
  -answer (New-Answer 'call' @('fold') @('mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'AK no pair on paired T -- call as a bluff-catcher; A blocks villain''s top value.' `
    "BTN c-bets paired T wide with air; AK with A-blocker beats the air range." `
    '6 overcard outs + ace-high showdown; A blocks AA/AT and reduces villain''s value.' `
    'AhKc has no pair on Tc Th 6s but A blocks AA top-of-range and 6 overcards can pair best.' `
    'Calling captures villain''s air bluffs; folding under-defends vs the wide stab range.' `
    'Auto-folding AK on paired boards because "no pair" misses the A-blocker bluff-catch line.' `
    'AK on paired-T = call (bluff-catch with A-blocker).') `
  -conceptTags @('bluff_catchers','range_disadvantage','equity_realization_oop') `
  -difficulty 3 `
  -uniquenessNote 'AK BLUFF-CATCH on paired T (distinct from #5.3 AhKs on paired LOW). Different paired board context -- paired T is closer to BTN range parity than paired LOW, making the call slightly tighter.'

# 7.4 - Pocket 8s underpair to paired T
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_TcTh6s_m3_action_8h8d_v423a' `
  -board $b7board -heroHand @('8h','8d') `
  -handClass 'underpair' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'decent' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'bluff_catch' `
  -question (Q-Action '8h 8d' $b7str) `
  -answer (New-Answer 'call' @() @('fold','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Pocket 8s underpair on paired T -- bluff-catch; raise folds out worse.' `
    "BTN c-bets paired T wide with overcards and air; 88 beats the entire bluff range." `
    'Underpair to T but overpair to 6; only better overpairs and T-x beat us (rare in BTN c-bet range).' `
    '88 has an underpair to top board card but is well above the air range.' `
    'Calling preserves villain''s bluffs; raising isolates overpairs and folds out air.' `
    'Folding small overpairs on paired-T over-folds vs the air-heavy stab range.' `
    'Mid pocket pair on paired-T = call (bluff-catch), not raise/fold.') `
  -conceptTags @('bluff_catchers','equity_realization_oop') `
  -difficulty 3 `
  -uniquenessNote 'POCKET-PAIR UNDERPAIR BLUFF-CATCH on paired T (distinct from 5h5d on paired LOW). Different middle pair on different paired board -- tests recognition that paired-board defense extends to underpairs.'


# ---- Board 8: 6c 3d 2h ----

# 8.1 - OESD + BDFD on rag -- pot odds defense
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_6c3d2h_m3_action_5d4d_v423a' `
  -board $b8board -heroHand @('5d','4d') `
  -handClass 'oesd' -heroHandRole 'pure_draw' -drawCategory 'oesd' -showdownValue 'low' `
  -blockerNote $null -recommendedAction 'call' -actionReason 'equity_realization_call' `
  -question (Q-Action '5d 4d' $b8str) `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'OESD + BDFD on rag board -- call; equity comfortably above pot-odds threshold.' `
    "BTN c-bets rag boards with overpairs and air; 54 has multiple equity sources to defend." `
    '8 OE outs (3-4-5-6-7 needs 7; 4-5-6-7-8 needs 7 and 8 = wait needs 7 only for one straight; or need 5 or A for wheel) + backdoor diamond + 5-overcard.' `
    '5d4d has open-ender (need 5 or A for wheel/8 for top straight) + backdoor diamond.' `
    'Calling realizes equity cheaply; raising can fold out air but bloats vs overpairs.' `
    'Folding OESD on rag boards over-folds vs villain''s wide stab.' `
    'OESD + BDFD on rag = call (one of the strongest defense candidates on dry boards).') `
  -conceptTags @('pot_odds_defense','equity_realization_oop') `
  -difficulty 3 `
  -uniquenessNote 'POT-ODDS DEFENSE with OESD + BDFD on RAG board (no overcards, just draw equity). Distinct from existing OESD scenarios on connected boards which had overcard backup.'

# 8.2 - Top set on dry rag
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_6c3d2h_m3_action_6h6d_v423a' `
  -board $b8board -heroHand @('6h','6d') `
  -handClass 'set' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'value_raise' `
  -question (Q-Action '6h 6d' $b8str) `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Top set on rag board -- raise small for value; overpairs pay off.' `
    "BTN c-bet range here is overpair-heavy (TT-AA) plus air; overpairs call a small raise." `
    'Top set is far ahead of villain''s range; sizing should be small to keep overpairs in.' `
    '66 makes top set on 6-3-2; only 33, 22 sets and 5-4 straights beat us (rare).' `
    'Small raise gets called by overpairs and air with showdown; big raise folds out worse.' `
    'Slowplaying top set on rag is acceptable but small raise extracts thin value from overpairs.' `
    'Top set on rag = small raise for value (big raise sizing-error vs the overpair-heavy range).') `
  -conceptTags @('check_raise_value','value_raise') `
  -difficulty 2 `
  -uniquenessNote 'TOP SET on RAG (vs existing 8c8h top set on As8d3h with A high). Different range interaction -- rag-board BTN range is overpair-heavy, requiring small raise sizing vs A-high where the value targets are A-x.'

# 8.3 - AA overpair on rag -- value raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_6c3d2h_m3_action_AhAs_v423a' `
  -board $b8board -heroHand @('Ah','As') `
  -handClass 'overpair' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote $null -recommendedAction 'check_raise_small' -actionReason 'value_raise' `
  -question (Q-Action 'Ah As' $b8str) `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'AA overpair on rag board -- raise for value; lower overpairs pay off.' `
    "BTN c-bets rag boards with overpairs (KK, QQ, JJ, TT, 99) and air; lower overpairs call a small raise." `
    'AA dominates villain''s c-bet range; raising extracts value from KK-99 that won''t fold.' `
    'AhAs has overpair (no FD, no draws available); only sets of 6/3/2 and rare 5-4 straights beat us.' `
    'Small raise charges lower overpairs and gets called by air with showdown; big raise folds out worse.' `
    'Slowplaying AA on rag misses thin value from KK-99 that pay off the small raise.' `
    'AA on rag = small raise (do NOT slowplay overpairs on dry boards; thin value matters).') `
  -conceptTags @('check_raise_value','value_raise') `
  -difficulty 3 `
  -uniquenessNote 'AA OVERPAIR value-raise on RAG. Distinct from set lessons -- overpair sizing logic differs (smaller because overpair vulnerability is lower than set vulnerability on dynamic boards).'

# 8.4 - KQ no equity on rag -- fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_flop_6c3d2h_m3_action_KsQc_v423a' `
  -board $b8board -heroHand @('Ks','Qc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null -recommendedAction 'fold' -actionReason 'range_disadvantage_fold' `
  -question (Q-Action 'Ks Qc' $b8str) `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'KQ no equity on rag board -- fold; pure overcards realize too little OOP.' `
    "BTN c-bets rag with overpair-heavy range; KQ has no draw, no flush, no relevant blocker." `
    '6 pair outs that often lose to dominating Q-pair (KQ) or K-pair (KK); pot-odds defense fails.' `
    'KsQc has no pair, no FD, no straight draw on 6c3d2h.' `
    'Folding closes action cleanly; calling burns chips bluff-catching with no equity.' `
    '"KQ is too pretty to fold" leaks chips on rag boards where overpairs dominate.' `
    'Naked KQ on rag boards = fold (no equity, no realization).') `
  -conceptTags @('range_disadvantage','oop_defense_threshold') `
  -difficulty 2 `
  -uniquenessNote 'KQ NO-EQUITY FOLD on RAG (vs Board 1.5 KcQc on As9s4d which is A-high). RAG board has overpair-heavy BTN range vs A-high which has A-x heavy -- different domination vector but same conclusion: fold.'


# ========================================================================
# Write the seed JSON
# ========================================================================

$out = [ordered]@{
  schemaVersion  = '1.1.0'
  moduleId       = 'pf_flop_cbet_oop_def'
  moduleName     = 'Facing C-bet OOP'
  version        = 'v4.2.3A'
  status         = 'planning_only'
  generatedAt    = '2026-05-06'
  notes          = 'Planning expansion seeds for v4.2.3A. 38 new M3 scenarios across 8 new board families. Authored to fill priority coverage gaps from v4.2.3 baseline (pot_odds_defense, blocker_raise, slowplay_call, protection_raise, domination_fold, bluff_catch, nut_flush_draw). Each scenario carries a uniquenessNote explaining the new strategic dimension it adds. Migration to production via tools/migrate-expansion-v4.2.3A.ps1.'
  expansionStats = [ordered]@{
    newScenarios   = $scenarios.Count
    newBoards      = 8
    productionBefore = 24
    productionAfter  = 62
  }
  scenarios = $scenarios
}

Write-Output ("Total scenarios authored: " + $scenarios.Count)

$json = $out | ConvertTo-Json -Depth 100
[System.IO.File]::WriteAllText($outPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Output "Wrote: $outPath"
Write-Output "Size: $((Get-Item $outPath).Length) bytes"
