# tools/build-m5-seeds-v4.4.0.ps1
# v4.4.0 - Module 5 River Defense OOP seed builder.
#
# Authors 24 planning-only seed scenarios across 6 river categories
# (4 each) and writes them to
# docs/specs/postflop-v4.4.0-module5-seed-scenarios.json.
#
# auditStatus  = planning_only
# reviewStatus = v4.4.0_seed_candidate
#
# Hand tree: BTN open 2.5x, BB call -> BTN cbet small, BB call ->
#            BTN barrel, BB call -> BTN bets river -> BB decision OOP.
#
# RIVER IS SHOWDOWN-ONLY: no draw equity. Calls are bluff-catches /
# thin value / MDF defense; busted draws are bluff-raise-or-fold.
#
# ASCII-only (no em-dash, no approx symbol) to avoid CP874 mojibake.

$ErrorActionPreference = 'Stop'
$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$outPath  = Join-Path $repoRoot 'docs\specs\postflop-v4.4.0-module5-seed-scenarios.json'

$spotTemplate = [ordered]@{
  format          = 'NLH_MTT'
  stackDepth      = '100BB'
  potType          = 'SRP'
  preflopAction   = 'BTN open 2.5x, BB call'
  flopAction      = 'BTN cbet small (~33%), BB call'
  turnAction      = 'BTN barrel (~50-66%), BB call'
  riverAction     = 'BTN bets river'
  street          = 'river'
  heroPosition    = 'BB'
  villainPosition = 'BTN'
  heroRole        = 'turn_check_caller_oop'
  villainRole     = 'river_barreler_ip'
}
$actionChoices = @('fold','call','check_raise_small','check_raise_big','mixed')
$reasonChoices = @(
  'pot_odds_river_call','bluff_catch_river','blocker_bluff_catch_river','mdf_defense_river',
  'thin_value_call_river','value_raise_river','bluff_raise_river','range_disadvantage_river_fold',
  'domination_river_fold','board_change_river_fold','missed_draw_give_up','mixed_indifference_river'
)

function New-Spot { return [PSCustomObject]([ordered]@{} + $spotTemplate) }

function New-Board($flopCards, $turnCard, $riverCard, $boardKind, $hcc, $stFlop, $stTurn, $stRiver, $tags, $cat, $boardChange, $runout, $drawComp, $sizing) {
  $cards = $flopCards + @($turnCard) + @($riverCard)
  return [PSCustomObject]([ordered]@{
    flopCards           = $flopCards
    turnCard            = $turnCard
    riverCard           = $riverCard
    cards               = $cards
    boardKind           = $boardKind
    suitTextureFlop     = $stFlop
    suitTextureTurn     = $stTurn
    suitTextureRiver    = $stRiver
    textureTags         = $tags
    highCardClass       = $hcc
    riverCategory       = $cat
    boardChange         = $boardChange
    runoutTexture       = $runout
    riverDrawCompletion = $drawComp
    villainRiverSizing  = $sizing
  })
}

function New-Question($qtype, $prompt, $choices) {
  return [PSCustomObject]([ordered]@{ qtype = $qtype; prompt = $prompt; choices = $choices })
}
function New-Answer($best, $acc, $bad, $crit) {
  return [PSCustomObject]([ordered]@{ best = $best; acceptable = $acc; bad = $bad; critical = $crit })
}
function New-Explanation($short, $riverLogic, $rangeContext, $handLogic, $sizingLogic, $commonMistake, $takeaway) {
  return [PSCustomObject]([ordered]@{
    short         = $short
    riverLogic    = $riverLogic
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
    module            = 'pf_river_barrel_oop_def'
    moduleName        = 'Facing River Barrel OOP'
    schemaVersion     = '1.3.0'
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
    reviewStatus      = 'v4.4.0_seed_candidate'
    uniquenessNote    = $uniquenessNote
  })
}
function Q-Action($hero, $boardStr, $turn, $river) {
  # NOTE: ${hero} braces required (PowerShell parses '$hero?' as a name).
  return New-Question 'action_choice' "Flop $boardStr; turn $turn; river $river. BTN c-bet small flop, BB called; BTN barrelled turn, BB called; BTN now bets the river. What is BB's best action with ${hero}?" $actionChoices
}
function Q-Reason($action, $hero, $boardStr, $turn, $river) {
  return New-Question 'reason_choice' "Flop $boardStr; turn $turn; river $river. BB ${action} with ${hero} vs BTN's river barrel. What is the primary reason?" $reasonChoices
}
function BoardStr($cards) { return ($cards -join ' ') }


# ====== Boards (6 river categories) ======

# R1: brick river (Ks 9d 4c / 2h / 7s) -- dry, no flush, no straight, unpaired. Sizing medium.
$r1Flop = @('Ks','9d','4c'); $r1Turn='2h'; $r1River='7s'
$r1 = New-Board $r1Flop $r1Turn $r1River 'K_high' 'K_high' 'rainbow' 'rainbow' 'rainbow' @('dry','disconnected') 'brick' 'brick' 'dry_unpaired' 'none' 'medium'
$r1Str = BoardStr $r1Flop

# R2: overcard river (Js 8d 5c / 3h / Ac) -- A overcard arrives; no flush, no straight. Sizing large.
$r2Flop = @('Js','8d','5c'); $r2Turn='3h'; $r2River='Ac'
$r2 = New-Board $r2Flop $r2Turn $r2River 'J_high' 'A_high' 'rainbow' 'rainbow' 'rainbow' @('dry','disconnected') 'overcard' 'range_shift_btn' 'dry_unpaired' 'overcard_blank' 'large'
$r2Str = BoardStr $r2Flop

# R3: flush-complete river (Qh 9h 4c / 2s / 7h) -- 3rd heart completes a flush. Sizing large.
$r3Flop = @('Qh','9h','4c'); $r3Turn='2s'; $r3River='7h'
$r3 = New-Board $r3Flop $r3Turn $r3River 'Q_high' 'Q_high' 'two_tone' 'two_tone' 'flush_possible' @('wet','flush_possible') 'flush_complete' 'draw_resolved' 'flush_possible' 'flush_completed' 'large'
$r3Str = BoardStr $r3Flop

# R4: straight-complete river (9d 8c 4h / 2s / 7h) -- 7 completes 5-6-7-8-9 / 7-8-9-T-J. Sizing medium.
$r4Flop = @('9d','8c','4h'); $r4Turn='2s'; $r4River='7h'
$r4 = New-Board $r4Flop $r4Turn $r4River 'low' '9_high' 'rainbow' 'rainbow' 'rainbow' @('wet','straight_possible') 'straight_complete' 'polarizing' 'straight_possible' 'straight_completed' 'medium'
$r4Str = BoardStr $r4Flop

# R5: board-pair river (Kd 7s 3c / Qh / 7d) -- river pairs the 7. Sizing small.
$r5Flop = @('Kd','7s','3c'); $r5Turn='Qh'; $r5River='7d'
$r5 = New-Board $r5Flop $r5Turn $r5River 'K_high' 'K_high' 'rainbow' 'rainbow' 'rainbow' @('dry','paired') 'board_pair' 'counterfeit' 'paired_board' 'board_paired' 'small'
$r5Str = BoardStr $r5Flop

# R6: scare-card river (Ad 8s 5c / 2h / Kd) -- K overcard scare on A-high; villain overbets. Sizing overbet.
$r6Flop = @('Ad','8s','5c'); $r6Turn='2h'; $r6River='Kd'
$r6 = New-Board $r6Flop $r6Turn $r6River 'A_high' 'A_high' 'rainbow' 'rainbow' 'rainbow' @('dry','disconnected') 'scare_card' 'range_shift_btn' 'dry_unpaired' 'overcard_blank' 'overbet'
$r6Str = BoardStr $r6Flop


# ====== Scenarios ======
$scenarios = @()

# ---------- R1: brick river (Ks 9d 4c / 2h / 7s), medium sizing ----------

# 1.1 action -- KQ top pair top kicker, mandatory bluff-catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ks9d4c_7s_m5_action_KdQh_v440' `
  -board $r1 -heroHand @('Kd','Qh') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'K-pair with Q kicker; beats every worse Kx and the entire busted-bluff bucket.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_river' `
  -question (Q-Action 'Kd Qh' $r1Str '2h' '7s') `
  -answer (New-Answer 'call' @() @('fold','mixed','check_raise_small','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'TPTK on a brick river -- call to bluff-catch the polar third barrel.' `
    'The 7s is a brick: no flush (two spades only), no straight, no pair. Ranges are exactly what they were on the turn. BTN bets a medium river polarized into value Kx-strong / sets / overpairs and busted barrel-bluffs; KQ beats every bluff and every worse Kx.' `
    'After calling flop and turn OOP, BB arrives capped but with plenty of one-pair bluff-catchers. Vs a medium polar bet, MDF (~60%) is filled mostly by top-pair hands; KQ is the top of that class.' `
    'KdQh is top pair with the second-best kicker; loses only to AK, K9-two-pair, sets and overpairs. There is no draw equity to think about -- it is purely a showdown call.' `
    $null `
    'Over-folding TPTK to a third barrel is the single biggest river leak; villain auto-profits bluffing if BB folds its bluff-catchers.' `
    'TPTK on a brick river = call; folding over-folds, raising turns a showdown hand into a bluff.') `
  -conceptTags @('river_bluff_catcher','river_overfold_trap','third_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Brick-river TPTK bluff-catch. The over-fold-trap baseline: a strong one-pair hand that MUST call a medium polar barrel; teaches that the river is a showdown call, not a fold or a raise.'

# 1.2 action -- set, value raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ks9d4c_7s_m5_action_9c9h_v440' `
  -board $r1 -heroHand @('9c','9h') `
  -handClass 'set' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Set of nines; holding two of the four 9s reduces villain 9x two-pair combos.' `
  -recommendedAction 'check_raise_small' -actionReason 'value_raise_river' `
  -question (Q-Action '9c 9h' $r1Str '2h' '7s') `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Middle set on a brick river -- check-raise small for value.' `
    'The 7s brick leaves BTN value-betting Kx-strong and overpairs that pay a raise. Set of nines beats AK, KQ, K9-two-pair and the lower 44/77 sets; it loses only to the rare KK.' `
    'BB flatted 99 pre, called two streets, and arrives with a hand that crushes the value-betting range. The brick means villain still has thin value (Kx) that calls a small raise.' `
    '9c9h is a set with near-100% equity vs the value range. There is no protection concern on the river -- the raise is pure value extraction.' `
    'Small check-raise targets Kx value-bets that call one more; a big raise folds out everything but KK and leaves value on the table.' `
    'Calling (slowplay) is acceptable but a small raise extracts more from Kx; auto-folding or over-raising are both wrong.' `
    'A set on a brick river = check-raise small for value; size to keep worse Kx in.') `
  -conceptTags @('river_value_raise','third_barrel_defense','river_thin_value') `
  -difficulty 3 `
  -uniquenessNote 'Brick-river set value-raise. Distinct from the TPTK call: hero is FAR ahead and raises for value rather than bluff-catching. Teaches river value-raise sizing (small to keep Kx in).'

# 1.3 action -- busted overcards, give up
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ks9d4c_7s_m5_action_JhTd_v440' `
  -board $r1 -heroHand @('Jh','Td') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_river_fold' `
  -question (Q-Action 'Jh Td' $r1Str '2h' '7s') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'J-high air on a brick river -- fold; there is no showdown value and no blocker to bluff-raise with.' `
    'The 7s completes nothing. JhTd never paired and has no flush. At the river it cannot beat even a bluff at showdown (both have nothing, but BB checked and faces a bet, so J-high is 0% to be good).' `
    'BB floated two streets with overcards and a backdoor that died. On the river this hand has exactly two options: bluff-raise (needs a blocker and a story) or fold. It holds neither a nut blocker nor a credible value story.' `
    'JhTd has no pair, no flush, no straight; it is pure air with no removal of villain value.' `
    $null `
    'Calling J-high on the river is pure spew -- it can never be good; raising without a blocker has no fold equity vs a polar range.' `
    'Busted air with no blocker on the river = fold; never call, only bluff-raise with a blocker.') `
  -conceptTags @('river_range_disadvantage','third_barrel_defense','river_missed_draw') `
  -difficulty 2 `
  -uniquenessNote 'Brick-river give-up. Teaches that air on the river is fold-or-bluff-raise, never a call; the call is flagged critical to drill the no-equity-on-river lesson.'

# 1.4 reason -- AK premium bluff-catcher
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ks9d4c_7s_m5_reason_AhKc_v440' `
  -board $r1 -heroHand @('Ah','Kc') `
  -handClass 'top_pair_top_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'A kicker; blocks AK-better-kicker chops and AA value combos.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_river' `
  -question (Q-Reason 'calls' 'Ah Kc' $r1Str '2h' '7s') `
  -answer (New-Answer 'bluff_catch_river' @('pot_odds_river_call') @('value_raise_river','thin_value_call_river','blocker_bluff_catch_river','mdf_defense_river','bluff_raise_river','range_disadvantage_river_fold','domination_river_fold','board_change_river_fold','missed_draw_give_up','mixed_indifference_river') @()) `
  -explanation (New-Explanation `
    'Top pair top kicker on a brick river -- the primary reason to call is bluff-catching, not value-raising.' `
    'The 7s brick keeps villain polar. AK beats every busted bluff and every worse Kx; it loses to the small slice of sets / K9-two-pair / overpairs.' `
    'AK is the best one-pair bluff-catcher BB can hold here. Raising it would fold out all the bluffs (which it beats) and only get called by the hands that beat it.' `
    'AhKc has top pair, top kicker, and an A-blocker that reduces villain AA. It is a call BECAUSE it catches bluffs -- not because it is raising for value (it is not ahead of the value-betting range enough to raise).' `
    $null `
    'Mislabelling this a value_raise_river is the error: AK raised here only gets called by better and folds out the bluffs it dominates.' `
    'Best one-pair bluff-catcher on a brick = call to bluff-catch (not raise).') `
  -conceptTags @('river_bluff_catcher','river_polarization','third_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Reason_choice distinguishing bluff_catch_river from value_raise_river with a premium one-pair holding. Teaches that even AK on K-high is a bluff-catch, not a value-raise, vs a polar barrel.'


# ---------- R2: overcard river (Js 8d 5c / 3h / Ac), large sizing ----------

# 2.1 action -- pair of jacks, A-river domination fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Js8d5c_Ac_m5_action_KcJd_v440' `
  -board $r2 -heroHand @('Kc','Jd') `
  -handClass 'mid_pair' -heroHandRole 'dominated_bluff_catcher' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'board_change_river_fold' `
  -question (Q-Action 'Kc Jd' $r2Str '3h' 'Ac') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call')) `
  -explanation (New-Explanation `
    'Pair of jacks after an Ace river vs a big bet -- fold; the river shifted the range to BTN.' `
    'The Ac is an overcard that hits BTN hard: he now value-bets every Ax he barrelled, plus he can credibly rep the A as a bluff card. The pot-sized bet is value-weighted; pair of jacks beats only the busted bluffs and is now below them in frequency.' `
    'BB called two streets with a J-x pair that was top pair on the flop. The A demotes it to a third-best pair and arms villain with a stack of new value combos.' `
    'KcJd is now second pair on an A-high board with no blocker to the value cards. Vs a pot-sized polar bet it is below the bluff-catch threshold.' `
    $null `
    'Stationing pair of jacks because it was top pair on the flop ignores that the A river flipped the range -- this is the station trap.' `
    'A pair demoted by an overcard river, vs a big bet = fold (board changed against you).') `
  -conceptTags @('river_board_change','river_range_disadvantage','third_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Overcard-river demotion fold. The station-trap counterpart to R1.1: a pair that was strong on the flop becomes a fold once the river overcard arms villain with value. Calling is flagged critical.'

# 2.2 action -- rivered top pair of aces, bluff-catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Js8d5c_Ac_m5_action_AdTh_v440' `
  -board $r2 -heroHand @('Ad','Th') `
  -handClass 'top_pair_weak_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'A in hand makes top pair AND blocks villain AA / strong-Ax value combos.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_river' `
  -question (Q-Action 'Ad Th' $r2Str '3h' 'Ac') `
  -answer (New-Answer 'call' @('mixed') @('fold','check_raise_small','check_raise_big') @()) `
  -explanation (New-Explanation `
    'The Ace river paired hero (A-high) -- call to bluff-catch; the A is a blocker, not a fold signal.' `
    'The Ac gives hero a pair of aces on the river. Crucially hero holds an A, which blocks villain AA and reduces his strong-Ax value combos -- so more of his pot-sized betting range is busted bluffs that hero now beats.' `
    'BB floated ATs two streets (overcard + backdoors) and rivered top pair on the scare card that everyone else fears. The A in hand is the reason this is a call, not a fold.' `
    'AdTh is top pair (weak kicker) plus the A-blocker. It loses to AK/AQ/AJ and two-pair/sets, but the blocker tilts villain range toward bluffs.' `
    $null `
    'Folding the rivered ace because the board looks scary over-folds; the very card that scares others gave hero a pair and a value-blocker.' `
    'When the scare card pairs YOU and blocks villain value, the bluff-catch gets stronger, not weaker -- call.') `
  -conceptTags @('river_bluff_catcher','river_blocker_defense','river_overfold_trap') `
  -difficulty 4 `
  -uniquenessNote 'Overcard river that HELPS hero (rivers a pair + a value-blocker). Contrasts directly with 2.1 (same river, opposite conclusion) to teach that the overcards effect depends on whether it pairs/blocks for you.'

# 2.3 action -- set of jacks, value raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Js8d5c_Ac_m5_action_JdJh_v440' `
  -board $r2 -heroHand @('Jd','Jh') `
  -handClass 'set' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Set of jacks; beats every Ax value-bet, loses only to a set of aces.' `
  -recommendedAction 'check_raise_big' -actionReason 'value_raise_river' `
  -question (Q-Action 'Jd Jh' $r2Str '3h' 'Ac') `
  -answer (New-Answer 'check_raise_big' @('call') @('fold','mixed','check_raise_small') @('fold')) `
  -explanation (New-Explanation `
    'Set of jacks under an Ace river -- check-raise big for value vs a value-heavy pot-sized bet.' `
    'The Ac armed villain with a wide Ax value range that bets big and calls a raise. Set of jacks beats every Ax, every two-pair, and the lower 55/88 sets; only a set of aces (one A on board, so AA in hand) beats it.' `
    'BB flatted JJ pre and arrives with the effective nuts on a board where villain just turned a stack of Ax into value bets that pay off a raise.' `
    'JdJh is a set with near-100% equity vs the betting range; the A river creates the perfect spot to raise because villain is over-valuing his new top pairs.' `
    'A big check-raise maximizes value from the inelastic Ax value range; a small raise leaves money on the table on a board this wet with villain value.' `
    'Slow-playing the set is acceptable but raising big extracts the most from the Ax range the river just created.' `
    'Set under a value-flooding overcard river = check-raise big; villain pays with all his new top pairs.') `
  -conceptTags @('river_value_raise','river_board_change','third_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Overcard-river value raise. The river that demotes one-pair hands (2.1) simultaneously creates a premium raise spot for a set, because it floods villain with payable Ax value. Teaches reading the same river two ways by hand class.'

# 2.4 reason -- KQ busted overcards, capped fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Js8d5c_Ac_m5_reason_KhQd_v440' `
  -board $r2 -heroHand @('Kh','Qd') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_river_fold' `
  -question (Q-Reason 'folds' 'Kh Qd' $r2Str '3h' 'Ac') `
  -answer (New-Answer 'range_disadvantage_river_fold' @('board_change_river_fold','missed_draw_give_up') @('pot_odds_river_call','bluff_catch_river','blocker_bluff_catch_river','mdf_defense_river','thin_value_call_river','value_raise_river','bluff_raise_river','domination_river_fold','mixed_indifference_river') @()) `
  -explanation (New-Explanation `
    'KQ-high after an Ace river vs a big bet -- fold; capped range with no pair and no useful blocker.' `
    'The Ac favors BTN heavily and the pot-sized bet is value-weighted. KhQd never made a pair, has no flush, and does not block villain key value combos in a way that supports a bluff-raise.' `
    'BB floated two overcards that bricked. On a board where the river armed villain with value and BB stays capped, there is nothing to continue with.' `
    'KhQd has zero showdown value (loses to any pair, including the busted bluffs that occasionally have a pair). It is a clean fold.' `
    $null `
    'Calling KQ-high to "bluff-catch" misreads the hand -- it has no pair, so it loses to literally everything villain value-bets and most of what he bluffs with.' `
    'No pair, no blocker, capped range, big bet = range-disadvantage fold (not a bluff-catch).') `
  -conceptTags @('river_range_disadvantage','river_board_change','third_barrel_defense') `
  -difficulty 2 `
  -uniquenessNote 'Reason_choice separating range_disadvantage_river_fold from bluff_catch_river: a no-pair hand cannot bluff-catch (it loses to everything). Teaches that bluff-catching requires an actual made hand.'


# ---------- R3: flush-complete river (Qh 9h 4c / 2s / 7h), large sizing ----------

# 3.1 action -- second-nut flush, thin value call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Qh9h4c_7h_m5_action_KhJh_v440' `
  -board $r3 -heroHand @('Kh','Jh') `
  -handClass 'flush' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'K-high flush; does NOT block the nut flush (no Ah), so villain can still hold the Ah flush.' `
  -recommendedAction 'call' -actionReason 'thin_value_call_river' `
  -question (Q-Action 'Kh Jh' $r3Str '2s' '7h') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'K-high flush on a flush-complete river vs a big bet -- call; do not raise into the nut flush.' `
    'The 7h puts three hearts out; BB made a K-high flush (Kh Jh + Qh 9h 7h). Vs a pot-sized polar bet this flush beats every non-flush value bet and every bluff, but it is NOT the nuts -- the Ah flush beats it.' `
    'BB held two hearts through two streets and got there. Raising only folds out everything worse and is called by the one hand that beats it (the Ah flush), so the flush plays as a strong bluff-catcher: call.' `
    'KhJh is the second-nut flush. Because hero does not hold the Ah, villain still has nut-flush combos; check-raising is thin and loses value to exactly the hands that continue.' `
    'A small check-raise is a defensible thin-value line vs an over-bluffy opponent, but the GTO line is to call -- raising big into the nut flush is the punt.' `
    'Folding the second-nut flush is a severe over-fold; raising big into the only hand that beats you is a punt.' `
    'Non-nut flush on a flush river vs a big bet = call (thin value), not raise.') `
  -conceptTags @('river_thin_value','river_bluff_catcher','river_board_change') `
  -difficulty 4 `
  -uniquenessNote 'Flush-complete thin-value call. Teaches the call-don-t-raise distinction at the top of the bluff-catch class: the 2nd-nut flush is strong enough to never fold but too weak to raise (only better continues).'

# 3.2 action -- nut-flush blocker bluff raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Qh9h4c_7h_m5_action_Ah8c_v440' `
  -board $r3 -heroHand @('Ah','8c') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'busted_combo_draw' -showdownValue 'none' `
  -blockerNote 'Ah is the nut-flush blocker on hearts; villain cannot hold the nut flush, and hero credibly reps it.' `
  -recommendedAction 'check_raise_small' -actionReason 'bluff_raise_river' `
  -question (Q-Action 'Ah 8c' $r3Str '2s' '7h') `
  -answer (New-Answer 'check_raise_small' @('fold') @('call','mixed','check_raise_big') @('call')) `
  -explanation (New-Explanation `
    'A-high with the lone Ah on a flush river -- check-raise small as a blocker bluff.' `
    'The 7h completes the flush. Hero holds the Ah (one heart, no flush) which blocks villain nut flush combos AND lets hero credibly represent the nut flush. Villain bet-folds his one-pair value and his missed bluffs to a raise.' `
    'BB arrives with a busted hand that has the single most powerful card on the board for a bluff: the nut-flush blocker. This is the river-defining blocker bluff-raise.' `
    'Ah8c has no made hand and no showdown value -- calling is impossible (it beats nothing). But the Ah makes it the ideal candidate to turn into a raise-bluff.' `
    'A small raise is enough to fold out villain bet-folds (Qx/9x value and busted bluffs); a big raise risks more chips than the fold equity is worth.' `
    'Calling A-high here is the punt (zero showdown value); the only profitable non-fold is the blocker raise.' `
    'On a flush river, the nut-flush blocker is a bluff-raise (or fold) -- never a call.') `
  -conceptTags @('river_bluff_raise','river_blocker_defense','river_missed_draw') `
  -difficulty 5 `
  -uniquenessNote 'Flush-river blocker bluff-raise -- the river-defining bluff line. Teaches that a busted hand with the nut blocker is a raise, never a call; the call is flagged critical.'

# 3.3 action -- non-flush top pair, station-trap fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Qh9h4c_7h_m5_action_QcJs_v440' `
  -board $r3 -heroHand @('Qc','Js') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'dominated_bluff_catcher' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote 'No heart in hand -- does not block any flush; pair of queens is behind the flush-weighted betting range.' `
  -recommendedAction 'fold' -actionReason 'board_change_river_fold' `
  -question (Q-Action 'Qc Js' $r3Str '2s' '7h') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call')) `
  -explanation (New-Explanation `
    'Top pair, no heart, on a flush-complete river vs a big bet -- fold; the flush got there and you hold no blocker.' `
    'The 7h completes the front-door flush. Villain pot-sized betting range is now flush-heavy (he barrelled flush draws that just got there) plus his made value; QcJs (pair of queens, no heart) beats only the few pure-air bluffs that bricked even the flush.' `
    'BB held a non-flush top pair through two streets. The river is the worst card for it: the draw villain was barrelling completed, and BB cannot block any of it.' `
    'QcJs has top pair but no heart, so it does not block a single flush combo. Vs a big bet on a three-flush board it is a dominated bluff-catcher.' `
    $null `
    'Calling top pair because "it is top pair" ignores that the flush completed and you block none of it -- this is the classic station trap.' `
    'Non-flush pair on a flush-complete river vs a big bet = fold; with no flush blocker you beat almost nothing.') `
  -conceptTags @('river_board_change','river_blocker_defense','third_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Flush-river station-trap fold. Top pair with no flush blocker must fold to a big bet on a completed-flush board; contrasts with 3.4 where the SAME pair strength + a flush blocker becomes a call.'

# 3.4 reason -- blocker bluff-catch (the river-defining call)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Qh9h4c_7h_m5_reason_Ah9c_v440' `
  -board $r3 -heroHand @('Ah','9c') `
  -handClass 'mid_pair' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote 'Ah blocks villain nut-flush combos, shifting his big-bet range toward non-flush value and busted bluffs.' `
  -recommendedAction 'call' -actionReason 'blocker_bluff_catch_river' `
  -question (Q-Reason 'calls' 'Ah 9c' $r3Str '2s' '7h') `
  -answer (New-Answer 'blocker_bluff_catch_river' @('bluff_catch_river','mdf_defense_river') @('pot_odds_river_call','thin_value_call_river','value_raise_river','bluff_raise_river','range_disadvantage_river_fold','domination_river_fold','board_change_river_fold','missed_draw_give_up','mixed_indifference_river') @()) `
  -explanation (New-Explanation `
    'Pair of nines holding the Ah on a flush river -- call BECAUSE the Ah blocks villain nut flushes.' `
    'The 7h completes the flush, but hero holds the Ah. That single card removes a large chunk of villain nut-flush value combos, tilting his big-bet range toward non-flush value (which hero ties/loses small) and busted bluffs (which hero beats). The blocker is what turns a weak pair into a defensible call.' `
    'This is the central river skill: among equal-strength bluff-catchers, the one holding the key blocker continues. Pair of nines alone is a fold; pair of nines WITH the Ah is a call.' `
    'Ah9c is only middle pair, but the Ah is the nut-flush blocker. Without it this hand folds (see 3.3); with it, villain has too few flushes to bet for value profitably, so hero defends.' `
    $null `
    'Folding because "it is only second pair" ignores the blocker -- the Ah is the entire reason to call.' `
    'On a flush river, pick your bluff-catchers by blocker: the hand holding the Ah calls, the same-strength hand without it folds.') `
  -conceptTags @('river_blocker_defense','river_bluff_catcher','river_polarization') `
  -difficulty 5 `
  -uniquenessNote 'Reason_choice showcasing blocker_bluff_catch_river -- the M5-defining skill. A second-pair hand that folds without the blocker (3.3) becomes a call WITH the nut-flush blocker; isolates blocker-driven defense from raw hand strength.'


# ---------- R4: straight-complete river (9d 8c 4h / 2s / 7h), medium sizing ----------

# 4.1 action -- nut straight (JT), value raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_9d8c4h_7h_m5_action_JcTd_v440' `
  -board $r4 -heroHand @('Jc','Td') `
  -handClass 'straight' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'J-T makes the nut straight 7-8-9-T-J; no higher straight exists on this board.' `
  -recommendedAction 'check_raise_big' -actionReason 'value_raise_river' `
  -question (Q-Action 'Jc Td' $r4Str '2s' '7h') `
  -answer (New-Answer 'check_raise_big' @('check_raise_small','call') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'Nut straight on a straight-complete river -- check-raise big for value.' `
    'The 7h fills the board 9-8-4-2-7; J-T makes 7-8-9-T-J, the nut straight (no T-J-Q-K-A or higher is possible). Villain still value-bets sets, two-pair and lower straights (T-6, 6-5) that pay a raise.' `
    'BB flatted JT pre, called two barrels with an open-ender, and rivered the nuts. Villain has plenty of second-best value (lower straights, sets) that cannot fold.' `
    'JcTd is the stone nuts; there is no protection or reverse-implied concern -- raise as big as villain will pay.' `
    'A big check-raise maximizes value from sets and lower straights; sizing down only sacrifices value since hero never needs to fold out worse.' `
    'Just calling the nuts leaves enormous value uncollected; folding it would be an absurd punt.' `
    'The nut straight on the river = check-raise big; charge the lower straights and sets the maximum.') `
  -conceptTags @('river_value_raise','river_board_change','third_barrel_defense') `
  -difficulty 2 `
  -uniquenessNote 'Straight-complete nut value-raise. The clean value baseline for the straight board; contrasts with 4.2/4.4 where strong-looking hands are only thin value because higher straights exist.'

# 4.2 action -- set on straight board, thin value call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_9d8c4h_7h_m5_action_9h9s_v440' `
  -board $r4 -heroHand @('9h','9s') `
  -handClass 'set' -heroHandRole 'thin_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Set of nines; blocks 9-x straights and two-pair slightly, but loses to any made straight.' `
  -recommendedAction 'call' -actionReason 'thin_value_call_river' `
  -question (Q-Action '9h 9s' $r4Str '2s' '7h') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('check_raise_big')) `
  -explanation (New-Explanation `
    'Set of nines on a straight-complete river -- call for thin value; do not raise into the made straights.' `
    'The 7h completes 5-6-7-8-9, 6-7-8-9-T and 7-8-9-T-J. Set of nines beats every two-pair, every lower set and all bluffs, but it loses to any T-J, T-6, or 6-5 straight. Vs a medium bet it is a call: it beats the non-straight value and the bluffs, but raising only folds those out and is called by straights.' `
    'BB arrives with a set that was a monster on the turn and is now a medium bluff-catcher because the obvious draw got there.' `
    '9h9s is a set, but on a four-to-a-straight runout it has slipped to thin-value/bluff-catch status -- strong enough to never fold, too weak to raise.' `
    'A small check-raise is a thin-value option vs a station, but the standard line is call -- a big raise into the straights is a punt that only worse folds to.' `
    'Raising the set here folds out everything it beats and gets called only by the straights that beat it -- over-raising is the critical error.' `
    'A set on a four-to-a-straight river is thin value: call, do not raise.') `
  -conceptTags @('river_thin_value','river_board_change','river_bluff_catcher') `
  -difficulty 4 `
  -uniquenessNote 'Straight-river thin-value set. Teaches that a set demotes to a call (not a raise) when a straight completes; the over-raise is flagged critical to drill the call-don-t-raise discipline.'

# 4.3 action -- middle pair, board-change fold
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_9d8c4h_7h_m5_action_Ad8d_v440' `
  -board $r4 -heroHand @('Ad','8d') `
  -handClass 'mid_pair' -heroHandRole 'dominated_bluff_catcher' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'board_change_river_fold' `
  -question (Q-Action 'Ad 8d' $r4Str '2s' '7h') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call')) `
  -explanation (New-Explanation `
    'Pair of eights on a straight-complete river vs a medium bet -- fold; the straight got there and the pair is dominated.' `
    'The 7h completes the obvious straights villain was barrelling (T-J, T-6, 6-5). Pair of eights with an A kicker beats only the pure-air bluffs that bricked the straight too; villain value range is straight- and overpair-heavy.' `
    'BB called two streets with middle pair plus an A. The river is the card the draws were chasing -- it favors the betting range, not the bluff-catcher.' `
    'Ad8d is second pair; it does not block any straight (no 6, no T, no J) and loses to all of villain made value. The A kicker does not help on the river.' `
    $null `
    'Calling middle pair because "I have a pair and an ace" ignores that the straight completed and the pair blocks none of villain value -- station trap.' `
    'Middle pair on a completed-straight river, no straight blocker = fold.') `
  -conceptTags @('river_board_change','river_range_disadvantage','third_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Straight-river domination fold. The middle-pair station trap on the straight board; pairs with no straight-blocker fold. Calling is flagged critical.'

# 4.4 reason -- low straight, thin value call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_9d8c4h_7h_m5_reason_6h5d_v440' `
  -board $r4 -heroHand @('6h','5d') `
  -handClass 'straight' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Makes the low straight 5-6-7-8-9; loses to 6-7-8-9-T (T-6) and 7-8-9-T-J (J-T).' `
  -recommendedAction 'call' -actionReason 'thin_value_call_river' `
  -question (Q-Reason 'calls' '6h 5d' $r4Str '2s' '7h') `
  -answer (New-Answer 'thin_value_call_river' @('value_raise_river','bluff_catch_river') @('pot_odds_river_call','blocker_bluff_catch_river','mdf_defense_river','bluff_raise_river','range_disadvantage_river_fold','domination_river_fold','board_change_river_fold','missed_draw_give_up','mixed_indifference_river') @()) `
  -explanation (New-Explanation `
    'The low end of the straight (5-6-7-8-9) -- call for thin value; raising runs into the higher straights.' `
    'The 7h makes hero a straight, but it is the lowest possible one. It beats sets, two-pair and all bluffs, but loses to T-6 and J-T straights. A raise gets called only by the better straights and folds out everything worse -- so call.' `
    'BB flatted 65-suited, called two streets with a combo draw, and rivered the bottom straight. It is a made hand, but the worst version of it on this board.' `
    '6h5d is a straight, yet against the value-betting range it plays like a thin-value hand: never fold, but never raise (higher straights exist).' `
    $null `
    'Calling it value_raise_river is the error -- raising the bottom straight only folds worse and is called by better. The reason to call is thin value, not a value raise.' `
    'Even a made straight can be only a thin value call when higher straights are possible -- call, do not raise.') `
  -conceptTags @('river_thin_value','river_board_change','river_value_raise') `
  -difficulty 4 `
  -uniquenessNote 'Reason_choice separating thin_value_call_river from value_raise_river with the bottom straight. Teaches that hand-class (straight) does not determine the line -- relative rank within made hands does.'


# ---------- R5: board-pair river (Kd 7s 3c / Qh / 7d), small sizing ----------

# 5.1 action -- top pair vs small bet, MDF call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Kd7s3c_7d_m5_action_KhJc_v440' `
  -board $r5 -heroHand @('Kh','Jc') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Top pair, K with J kicker; the paired board mainly kills BB draws, not this made hand.' `
  -recommendedAction 'call' -actionReason 'mdf_defense_river' `
  -question (Q-Action 'Kh Jc' $r5Str 'Qh' '7d') `
  -answer (New-Answer 'call' @('mixed') @('fold','check_raise_small','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Top pair vs a small river bet on a paired board -- call to meet minimum defense frequency.' `
    'The 7d pairs the board. Trips (any 7) are rare in villain river-barrelling range, so the pair mainly counterfeits BB busted draws. Vs a small (~33%) bet, MDF is ~75% -- BB must defend almost everything that beats a bluff, and top pair clears that bar easily.' `
    'BB called two streets with KJ. The small sizing screams thin value / give-ups; folding top pair here lets villain auto-profit by betting small with any two.' `
    'KhJc is top pair good kicker; it loses only to better Kx, the rare 7x trips, and full houses (K7/Q7/33). Vs a small bet that is far above the call threshold (~20%).' `
    $null `
    'Folding top pair to a small bet because the board paired is a huge over-fold -- the small sizing is exactly when you must defend widest.' `
    'Top pair vs a small bet = call; small sizings demand the highest defense frequency (MDF ~75%).') `
  -conceptTags @('river_mdf','river_bluff_catcher','river_overfold_trap') `
  -difficulty 3 `
  -uniquenessNote 'Small-bet MDF call. Teaches the sizing-to-MDF mapping: a small river bet requires defending ~75%, so even a board-pairing scare card does not justify folding top pair.'

# 5.2 action -- second pair vs small bet, MDF call
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Kd7s3c_7d_m5_action_QcJd_v440' `
  -board $r5 -heroHand @('Qc','Jd') `
  -handClass 'second_pair' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote 'Pair of queens (turned); beats the busted-draw bluffs that a small bet is loaded with.' `
  -recommendedAction 'call' -actionReason 'mdf_defense_river' `
  -question (Q-Action 'Qc Jd' $r5Str 'Qh' '7d') `
  -answer (New-Answer 'call' @('mixed') @('fold','check_raise_small','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Second pair vs a small river bet on a paired board -- call; MDF and the busted-draw-heavy range say defend.' `
    'The 7d pairs the board and bricks the draws (the Q turn gave BB plenty of Qx and busted broadway draws). Vs a small bet, villain is betting thin value and a stack of give-ups; pair of queens beats all the give-ups.' `
    'BB turned a pair of queens and faces the smallest sizing. The river barrel range at 33% is bluff-heavy because villain bets small to deny equity cheaply or to value-bet thin; second pair is comfortably above the call threshold.' `
    'QcJd is middle pair; it loses to Kx and 7x but beats every busted draw. At ~20% needed equity vs a small bet, it is a clear call.' `
    $null `
    'Folding second pair to a small bet is the canonical over-fold -- the smaller the bet, the more bluff-catchers must continue.' `
    'Second pair vs a small bet on a draw-bricking river = call; over-folding small bets is the most common river leak.') `
  -conceptTags @('river_mdf','river_overfold_trap','river_bluff_catcher') `
  -difficulty 4 `
  -uniquenessNote 'Small-bet second-pair MDF call. Pushes the over-fold lesson further than 5.1: even SECOND pair must defend vs a small bet. Distinct sizing-driven defense lesson.'

# 5.3 action -- trips, value raise
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Kd7s3c_7d_m5_action_7h6h_v440' `
  -board $r5 -heroHand @('7h','6h') `
  -handClass 'trips' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Trip sevens; holding a 7 reduces villain trips and lets hero raise for value with little reverse risk.' `
  -recommendedAction 'check_raise_small' -actionReason 'value_raise_river' `
  -question (Q-Action '7h 6h' $r5Str 'Qh' '7d') `
  -answer (New-Answer 'check_raise_small' @('call') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Trip sevens on the board-pair river -- check-raise small for value.' `
    'The 7d pairs the board and hands hero trips. Trips beat every Kx and Qx value-bet and all bluffs; only K7/Q7/77 full houses and 33 beat hero, and those are a tiny slice of a river-barrelling range. The small bet means BB is the one who should raise for value here.' `
    'BB called two streets with 76-suited (pair + backdoor) and rivered trips when the board paired. Villain bet small with thin value and give-ups -- the perfect range to raise.' `
    '7h6h is trip sevens; it crushes the value-betting range and only loses to rare full houses. There is no reason to slow-play vs a small bet.' `
    'A small check-raise gets called by Kx that bet thin and induces hero-calls; a big raise folds out the very value it wants to charge.' `
    'Just calling trips vs a small bet leaves value uncollected; trips want to raise here.' `
    'Trips on a board-pair river vs a small bet = check-raise small for value.') `
  -conceptTags @('river_value_raise','third_barrel_defense','river_thin_value') `
  -difficulty 3 `
  -uniquenessNote 'Board-pair trips value-raise. The value counterpart on the paired board: when the river pairs and gives hero trips, raise the small bet for value. Distinct from the MDF calls 5.1/5.2.'

# 5.4 reason -- busted OESD, give up
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Kd7s3c_7d_m5_reason_JsTh_v440' `
  -board $r5 -heroHand @('Js','Th') `
  -handClass 'no_pair_no_draw' -heroHandRole 'missed_draw' -drawCategory 'busted_straight_draw' -showdownValue 'none' `
  -blockerNote $null `
  -recommendedAction 'fold' -actionReason 'missed_draw_give_up' `
  -question (Q-Reason 'folds' 'Js Th' $r5Str 'Qh' '7d') `
  -answer (New-Answer 'missed_draw_give_up' @('range_disadvantage_river_fold') @('pot_odds_river_call','bluff_catch_river','blocker_bluff_catch_river','mdf_defense_river','thin_value_call_river','value_raise_river','bluff_raise_river','domination_river_fold','board_change_river_fold','mixed_indifference_river') @()) `
  -explanation (New-Explanation `
    'A busted open-ender (JT) on the board-pair river -- fold; it is a missed draw with no showdown value and no blocker.' `
    'On K-7-3 with a Q turn, JT had an open-ended straight draw (any A or 9 made K-Q-J-T-?). The 7d river pairs the board and completes nothing -- the draw is dead. JT is now J-high air that cannot beat even a bluff.' `
    'BB peeled two streets with the straight draw. The river bricked AND paired; the only question is bluff-raise or fold, and JT holds no useful blocker (it does not block 7x trips or the top Kx value).' `
    'JsTh is a busted straight draw -- zero showdown value, zero pair. It is the textbook missed-draw give-up.' `
    $null `
    'Calling a busted draw because "I have two overcards" is pure spew -- it can never win at showdown. Even on small sizings, air is a fold, not a call.' `
    'A busted draw on the river is a give-up (fold) -- never a call; only bluff-raise it with a real blocker.') `
  -conceptTags @('river_missed_draw','river_range_disadvantage','third_barrel_defense') `
  -difficulty 3 `
  -uniquenessNote 'Reason_choice showcasing missed_draw_give_up. The busted-draw lesson: a missed OESD is a fold (or blocker bluff-raise), never a call -- separates it from the bluff-catch reasons that require a made hand.'


# ---------- R6: scare-card river (Ad 8s 5c / 2h / Kd), overbet sizing ----------

# 6.1 action -- top pair vs overbet, close mix
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ad8s5c_Kd_m5_action_AhQc_v440' `
  -board $r6 -heroHand @('Ah','Qc') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'marginal_made_hand' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Top pair of aces, Q kicker; A-blocker reduces villain AA / AK value, the cards an overbet most represents.' `
  -recommendedAction 'mixed' -actionReason 'mixed_indifference_river' `
  -question (Q-Action 'Ah Qc' $r6Str '2h' 'Kd') `
  -answer (New-Answer 'mixed' @('call','fold') @('check_raise_small','check_raise_big') @()) `
  -explanation (New-Explanation `
    'Top pair facing a K-scare overbet -- a genuine call/fold mix; do not auto-fold.' `
    'The Kd is a scare card that lets villain rep AK/KK with an overbet (~150% pot). Vs an overbet, BB needs ~37.5% to call. AQ (pair of aces) beats the busted-draw bluffs and is helped by the A-blocker, which removes AA and some AK -- pushing villain range toward bluffs. The result is close: solver mixes call and fold.' `
    'BB called two streets with AQ for top pair. The overbet on the K is exactly the spot players over-fold; the A-blocker is what keeps it close rather than a clear fold.' `
    'AhQc is top pair good kicker with the A-blocker. Vs a polar overbet it is right at the indifference threshold -- neither a pure call nor a pure fold.' `
    $null `
    'Auto-folding top pair to the K overbet is the leak; auto-calling ignores that the overbet is value-weighted. The honest answer is a mix.' `
    'Top pair vs a scare-card overbet is often a true mix -- the A-blocker keeps it from being an auto-fold.') `
  -conceptTags @('river_mdf','river_polarization','river_overfold_trap') `
  -difficulty 5 `
  -uniquenessNote 'Scare-card overbet mix. The honest mixed_indifference spot: top pair vs an overbet is close, not an auto-fold; the A-blocker is the swing factor. Teaches that overbets do not mean fold everything.'

# 6.2 action -- top two pair vs overbet, call (do not raise)
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ad8s5c_Kd_m5_action_AcKh_v440' `
  -board $r6 -heroHand @('Ac','Kh') `
  -handClass 'two_pair' -heroHandRole 'strong_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Aces and kings (top two pair); the A and K reduce villain AA / KK set combos, the nutted hands an overbet represents.' `
  -recommendedAction 'call' -actionReason 'thin_value_call_river' `
  -question (Q-Action 'Ac Kh' $r6Str '2h' 'Kd') `
  -answer (New-Answer 'call' @('check_raise_small') @('fold','mixed','check_raise_big') @('fold')) `
  -explanation (New-Explanation `
    'Top two pair facing a K-scare overbet -- call; the overbet is polar, so do not raise into it.' `
    'The Kd rivered hero a second pair (aces and kings). Vs a polar overbet, villain holds either the nuts (AA, KK, 88, 55 sets) or busted bluffs. Two pair beats every bluff and every one-pair value-bet, but raising only folds those out and is called by the sets that beat it -- so call.' `
    'BB called two streets with AK and rivered top two pair on the scare card. Against the polar overbet the hand is a strong bluff-catcher, not a raise.' `
    'AcKh is top two pair with the A and K blockers that remove some of villain AA/KK. It beats the entire bluff bucket; raising is thin and loses to the only continues.' `
    'A small check-raise is a thin-value option vs a bluff-heavy overbetter, but the GTO line is call -- a big raise into a polar overbet only gets value-owned by sets.' `
    'Folding top two pair to the overbet is a severe over-fold; raising big into a polar nutted-or-air range is a punt.' `
    'Top two pair vs a polar overbet = call (strong bluff-catch); do not raise into nutted-or-air.') `
  -conceptTags @('river_thin_value','river_bluff_catcher','river_blocker_defense') `
  -difficulty 4 `
  -uniquenessNote 'Scare-card overbet bluff-catch with top two pair. Teaches that vs a polar overbet even a strong made hand calls rather than raises (raising only folds worse, is called by better).'

# 6.3 action -- busted backdoor, give up
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ad8s5c_Kd_m5_action_QdJd_v440' `
  -board $r6 -heroHand @('Qd','Jd') `
  -handClass 'no_pair_no_draw' -heroHandRole 'missed_draw' -drawCategory 'busted_combo_draw' -showdownValue 'none' `
  -blockerNote 'No nut blocker for this runout (does not block AA/KK/sets); the Qd-Jd backdoor flush and gutshot both bricked.' `
  -recommendedAction 'fold' -actionReason 'missed_draw_give_up' `
  -question (Q-Action 'Qd Jd' $r6Str '2h' 'Kd') `
  -answer (New-Answer 'fold' @() @('call','mixed','check_raise_small','check_raise_big') @('call','check_raise_big')) `
  -explanation (New-Explanation `
    'A busted backdoor (QJ-suited) facing a K overbet -- fold; no showdown value and no nut blocker to raise with.' `
    'QdJd picked up a backdoor diamond draw and a gutshot along the way; the Kd river makes neither (four diamonds is not a flush, and there is no straight). It is Q-high air. Vs a polar overbet it can only bluff-raise or fold.' `
    'BB floated with backdoor equity that all bricked. To bluff-raise an overbet hero needs to block villain nutted combos (AA/KK/sets) -- QdJd blocks none of them, so the raise has no credible story.' `
    'QdJd has no pair, no flush (only four diamonds), no straight, and no relevant blocker. It is a pure give-up.' `
    $null `
    'Calling Q-high to "see a showdown" is impossible -- it beats nothing; bluff-raising without a nut blocker into an overbet is stack suicide.' `
    'Busted air with no nut blocker, vs an overbet = fold; no showdown value means no call, and no blocker means no raise.') `
  -conceptTags @('river_missed_draw','river_range_disadvantage','river_bluff_raise') `
  -difficulty 3 `
  -uniquenessNote 'Scare-card busted give-up. Reinforces that a bluff-raise needs a NUT blocker (here QJ has none), so a busted hand without one simply folds -- distinct from 3.2 where the Ah blocker enabled the raise.'

# 6.4 reason -- top pair, do-not-overfold bluff-catch
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ad8s5c_Kd_m5_reason_AhJc_v440' `
  -board $r6 -heroHand @('Ah','Jc') `
  -handClass 'top_pair_weak_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Top pair of aces, J kicker; A-blocker removes AA and reduces strong-Ax / AK value combos.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_river' `
  -question (Q-Reason 'calls' 'Ah Jc' $r6Str '2h' 'Kd') `
  -answer (New-Answer 'bluff_catch_river' @('mdf_defense_river','mixed_indifference_river') @('pot_odds_river_call','blocker_bluff_catch_river','thin_value_call_river','value_raise_river','bluff_raise_river','range_disadvantage_river_fold','domination_river_fold','board_change_river_fold','missed_draw_give_up') @()) `
  -explanation (New-Explanation `
    'Top pair with the A-blocker vs a K-scare overbet -- the reason to call is bluff-catching the over-bluffed line.' `
    'The Kd overbet looks terrifying, but villain over-barrels rivers in practice and the A-blocker removes a chunk of his AA / strong-Ax value. AJ (pair of aces) beats the busted-draw bluffs, which make up enough of an overbet to clear the ~37.5% needed.' `
    'This is the over-fold trap at its sharpest: the biggest sizing on the scariest card is exactly where players fold too much. The blocker plus villain bluff frequency makes the call correct.' `
    'AhJc is top pair, weak kicker, with the A-blocker. It is a clear notch below AQ (6.1) but the blocker and the over-bluffed overbet still make calling the primary line.' `
    $null `
    'Folding top pair to the overbet because it is big is the leak; the bluff-catch reason -- beats the bluffs, blocks the value -- is why this calls.' `
    'Against an over-bluffed overbet, top pair with the A-blocker calls -- the scariest sizing is where over-folding costs the most.') `
  -conceptTags @('river_bluff_catcher','river_overfold_trap','river_blocker_defense') `
  -difficulty 5 `
  -uniquenessNote 'Reason_choice on the over-fold trap vs an overbet: top pair + A-blocker is a bluff_catch_river call, not a fold. Closes the module on the single most important river lesson -- do not over-fold to big sizings.'


# ====== Write seed JSON ======

$out = [ordered]@{
  schemaVersion  = '1.3.0'
  moduleId       = 'pf_river_barrel_oop_def'
  moduleName     = 'Facing River Barrel OOP'
  version        = 'v4.4.0'
  status         = 'planning_only'
  generatedAt    = '2026-06-18'
  notes          = 'Planning seeds for Module 5 (BB River Defense OOP). 24 scenarios across 6 river categories (4 each). River is showdown-only: no draw equity. NOT loaded at runtime. Migration to production scheduled for v4.4.1+ after seed strategic review (v4.4.0A).'
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
$utf8nb = [System.Text.UTF8Encoding]::new($false)
$tmp = "$outPath.tmp"
[System.IO.File]::WriteAllText($tmp, $json, $utf8nb)
Move-Item -LiteralPath $tmp -Destination $outPath -Force
Write-Output ("Wrote " + $outPath)
