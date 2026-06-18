# tools/build-m5-expansion-v4.4.1A.ps1
# v4.4.1A - Module 5 River Defense OOP EXPANSION seed builder.
#
# Authors 8 gap-first planning-only seed scenarios on 2 NEW boards and
# writes them to docs/specs/postflop-v4.4.1A-module5-expansion-seeds.json.
#
# Gap-first targets (vs the existing 24 M5 production scenarios):
#   - pot_odds_river_call        (was 0)   -> A.1
#   - domination_river_fold      (was 0)   -> A.3
#   - mdf_defense_river          (was 2)   -> A.2
#   - range_disadvantage_river_fold (was 2)-> A.4
#   - bluff_raise_river          (was 1)   -> B.1   (role blocker_bluff, was 1)
#   - blocker_bluff_catch_river  (was 1)   -> B.2
#   - mixed_indifference_river   (was 2)   -> B.3
#   - thin_value_call_river role (thin_value role was 1) -> B.4
# Also lifts reason_choice share (was 6/24 -> +3) and recalibrates the
# critical-flag density downward (only the two genuine punts flagged).
#
# auditStatus  = planning_only
# reviewStatus = v4.4.1A_expansion_candidate
#
# Hand tree: BTN open 2.5x, BB call -> BTN cbet small, BB call ->
#            BTN barrel, BB call -> BTN bets river -> BB decision OOP.
# RIVER IS SHOWDOWN-ONLY: no draw equity. Each prompt states the river
# bet size (a clarity improvement over the v4.4.0 generic prompts).
# ASCII-only (no em-dash, no approx symbol) to avoid CP874 mojibake.

$ErrorActionPreference = 'Stop'
$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$outPath  = Join-Path $repoRoot 'docs\specs\postflop-v4.4.1A-module5-expansion-seeds.json'

$spotTemplate = [ordered]@{
  format          = 'NLH_MTT'
  stackDepth      = '100BB'
  potType         = 'SRP'
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
    reviewStatus      = 'v4.4.1A_expansion_candidate'
    uniquenessNote    = $uniquenessNote
  })
}

# Board A: A-high dry double-blank brick (Ac 7d 4s / 9h / 2c). One physical
# board, bet at different sizes across its scenarios (size is per-hand).
function BoardA($sizing) {
  return New-Board @('Ac','7d','4s') '9h' '2c' 'A_high' 'A_high' 'rainbow' 'rainbow' 'two_tone' @('dry','disconnected') 'brick' 'brick' 'dry_unpaired' 'none' $sizing
}
# Board B: flush-completing river (Kh 9h 5c / 4d / 2h), three hearts.
function BoardB($sizing) {
  return New-Board @('Kh','9h','5c') '4d' '2h' 'K_high' 'K_high' 'two_tone' 'two_tone' 'two_tone' @('wet','flushing') 'flush_complete' 'draw_resolved' 'flush_possible' 'flush_completed' $sizing
}

$scenarios = @()

# ---- A.1 pot_odds_river_call (small) ----
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ac7d4s_2c_m5_action_8d8c_v441a' `
  -board (BoardA 'small') -heroHand @('8d','8c') `
  -handClass 'underpair' -heroHandRole 'marginal_made_hand' -drawCategory 'none' -showdownValue 'low' `
  -blockerNote 'No relevant blockers; with a tiny price the underpair only needs to beat the busted-barrel bluffs.' `
  -recommendedAction 'call' -actionReason 'pot_odds_river_call' `
  -question (New-Question 'action_choice' 'Flop Ac 7d 4s; turn 9h; river 2c. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BTN now bets about a third of pot (small) on the river. What is BB best action with 8d 8c?' $actionChoices) `
  -answer (New-Answer 'call' @() @('fold','mixed','check_raise_small','check_raise_big') @()) `
  -explanation (New-Explanation `
    'Underpair vs a tiny river bet -- the price alone makes it a call.' `
    'The 2c is a double blank: no flush (only two clubs), no straight, no new pair. Ranges are unchanged from the turn. At about a third of pot BTN can bet a wide, bluff-heavy range, so the small price (about 4-to-1) is the whole story.' `
    'BB arrives capped after calling two streets, but a third-pot bet only asks BB to defend the very bottom of its range; an underpair clears that bar easily.' `
    '88 beats every busted barrel (KQ/KJ/QJ/JT that whiffed) and the occasional thin 7x. It loses to Ax, 9x and sets, but at 4-to-1 it needs to be good only about one time in five.' `
    $null `
    'Folding small pairs to a tiny river bet -- over-folding to cheap sizings hands BTN an automatic profit.' `
    'Small sizing, small required equity: price an underpair in as a pure pot-odds call.') `
  -conceptTags @('river_bluff_catcher','river_mdf','third_barrel_defense') -difficulty 3 `
  -uniquenessNote 'The pot-odds (price-driven) call: a hand too weak to be a confident bluff-catcher still calls a tiny bet purely on the 4-to-1 price.'

# ---- A.2 mdf_defense_river (weak ace, medium, reason_choice) ----
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ac7d4s_2c_m5_reason_Ad6c_v441a' `
  -board (BoardA 'medium') -heroHand @('Ad','6c') `
  -handClass 'top_pair_weak_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'decent' `
  -blockerNote 'Holds an ace, so it blocks a little BTN value, but the call is driven by MDF, not by card removal.' `
  -recommendedAction 'call' -actionReason 'mdf_defense_river' `
  -question (New-Question 'reason_choice' 'Flop Ac 7d 4s; turn 9h; river 2c. BB calls Ad 6c vs BTN two-thirds-pot river bet. What is the primary reason?' $reasonChoices) `
  -answer (New-Answer 'mdf_defense_river' @('bluff_catch_river') @('domination_river_fold','missed_draw_give_up') @()) `
  -explanation (New-Explanation `
    'Weak top pair calls a two-thirds barrel to meet minimum defense frequency.' `
    'The 2c is a blank on Ac 7d 4s 9h: no flush, no straight. Versus two-thirds pot BB must continue with roughly 60% of its range, and its many aces are the backbone of that defense.' `
    'BB holds a lot of aces by the river. Folding the weak ones would drop BB far below MDF and let BTN barrel any two cards profitably, so the bottom of the Ax class still defends a two-thirds bet.' `
    'A6 beats worse aces, every pair below it and all busted bluffs; it loses to better aces and sets. The smaller size pulls in more bluffs, so defending top pair keeps BB at MDF rather than over-folding a hand this strong.' `
    $null `
    'Folding all your weak aces to a manageable barrel -- that defends well below MDF and prints money for a triple-barreller.' `
    'MDF over hand-love: a weak ace is still top pair, and you cannot fold the top-pair class to a two-thirds bet without over-folding.') `
  -conceptTags @('river_mdf','river_bluff_catcher','river_overfold_trap') -difficulty 3 `
  -uniquenessNote 'Isolates the MDF reason: the call is justified by defense-frequency math on the top-pair class, distinguishing it from a price-driven (A.1) or blocker-driven call.'

# ---- A.3 bluff_catch_river / over-fold trap (top pair good kicker, pot) ----
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ac7d4s_2c_m5_action_AsQc_v441a' `
  -board (BoardA 'large') -heroHand @('As','Qc') `
  -handClass 'top_pair_good_kicker' -heroHandRole 'bluff_catcher' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Holds the As (blocks some AK/AQ value) and the Qc; a strong top pair that must not be folded to a polar bet.' `
  -recommendedAction 'call' -actionReason 'bluff_catch_river' `
  -question (New-Question 'action_choice' 'Flop Ac 7d 4s; turn 9h; river 2c. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BTN now bets pot (large) on the river. What is BB best action with As Qc?' $actionChoices) `
  -answer (New-Answer 'call' @() @('fold','mixed','check_raise_small','check_raise_big') @()) `
  -explanation (New-Explanation `
    'Top pair, good kicker is a mandatory call versus a pot-sized third barrel -- folding over-folds.' `
    'The 2c bricks Ac 7d 4s 9h: no flush, no straight. A pot-sized bet is polar -- strong aces and sets for value, busted broadways and gutshots as bluffs -- and a balanced BTN must bluff enough that a strong ace has to call.' `
    'BB is capped but holds plenty of aces. AQ sits near the top of that bluff-catching class; if BB folds hands this strong it defends far too little and BTN auto-profits.' `
    'AQ beats AJ, AT, every worse ace BTN might bet thin, and the entire busted-bluff bucket. It loses only to AK and sets, so versus a pot bet that must contain bluffs to stay balanced it is a clear call.' `
    $null `
    'Folding good top pair to a big river bet "because it looks scary" -- the classic over-fold leak that makes barrelling free.' `
    'Big bet, strong bluff-catcher: call. Over-folding top pair is exactly what a polar barreller wants.') `
  -conceptTags @('river_bluff_catcher','river_overfold_trap','third_barrel_defense') -difficulty 3 `
  -uniquenessNote 'The over-fold-trap call versus a pot bet: pairs with A.2 (a weak ace defends a two-thirds bet on MDF) to show the top-pair class defends across sizings, while pure air (A.4) folds.'

# ---- A.4 range_disadvantage_river_fold (large, reason_choice) ----
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Ac7d4s_2c_m5_reason_KcQd_v441a' `
  -board (BoardA 'large') -heroHand @('Kc','Qd') `
  -handClass 'no_pair_no_draw' -heroHandRole 'give_up' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote 'KQ blocks a few BTN value combos (AK/KK/QQ) but holds no pair and beats nothing that bets; it is a pure give-up.' `
  -recommendedAction 'fold' -actionReason 'range_disadvantage_river_fold' `
  -question (New-Question 'reason_choice' 'Flop Ac 7d 4s; turn 9h; river 2c. BB folds Kc Qd vs BTN pot-sized river bet. What is the primary reason?' $reasonChoices) `
  -answer (New-Answer 'range_disadvantage_river_fold' @() @('bluff_catch_river','pot_odds_river_call') @()) `
  -explanation (New-Explanation `
    'King-high air folds to a big barrel -- a capped range cannot manufacture a call here.' `
    'The 2c bricks the dry board. KQ never made a pair and never had a draw; it is simply the bottom of a capped calling range that arrives with no showdown value.' `
    'BB called flop and turn with pairs and draws; by the river the missed broadway combos are the worst hands BB holds, and BTN attacks exactly them.' `
    'KQ beats nothing BTN value-bets and only ties or loses to other air. There is nothing to bluff-catch with -- holding the K and Q is a tiny blocker note, not a reason to call.' `
    $null `
    'Talking yourself into a "blocker" call with two overcards -- blocking a few value combos does not give a no-pair hand a price to call a pot bet.' `
    'When your range is capped and your hand is air, fold; blockers do not turn no-pair into a call.') `
  -conceptTags @('river_range_disadvantage','third_barrel_defense') -difficulty 2 `
  -uniquenessNote 'Diagnoses the give-up: distinguishes range_disadvantage (capped air folds) from a bluff-catch or pot-odds call, which require actual showdown value.'

# ---- B.1 bluff_raise_river (large) ----
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Kh9h5c_2h_m5_action_AhJc_v441a' `
  -board (BoardB 'large') -heroHand @('Ah','Jc') `
  -handClass 'no_pair_no_draw' -heroHandRole 'blocker_bluff' -drawCategory 'none' -showdownValue 'none' `
  -blockerNote 'Ah is the nut-flush blocker: BTN is far less likely to hold the nut flush (Ah-x), so a check-raise credibly represents it and folds out one-pair value and weak made hands.' `
  -recommendedAction 'check_raise_small' -actionReason 'bluff_raise_river' `
  -question (New-Question 'action_choice' 'Flop Kh 9h 5c; turn 4d; river 2h. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BTN now bets pot (large) on the river. What is BB best action with Ah Jc?' $actionChoices) `
  -answer (New-Answer 'check_raise_small' @('fold') @('call','mixed','check_raise_big') @('call')) `
  -explanation (New-Explanation `
    'A-high with the nut-flush blocker check-raises the river as a bluff -- or folds; never calls.' `
    'The 2h puts a third heart out, completing the flush draw. The board now favors whoever can credibly hold a flush; holding the Ah means BTN almost never has the nut flush, so a raise tells a believable story.' `
    'BTN bets a large polar range: made flushes and strong hands for value, plus busted hearts as bluffs. BB has no showdown value here, so the only ways to win are to raise BTN off the non-flush portion or to give up.' `
    'AhJc has no pair and cannot win at showdown, so calling is pointless. But the Ah removes BTN nut-flush combos, so a check-raise pressures his one-pair value and missed bluffs into folding.' `
    'A small check-raise is enough to fold out non-flush value and weak made hands while risking the minimum; a big raise over-invests, since the only hands that continue are the flushes that already beat us.' `
    'Flatting A-high "to see a showdown" -- with zero showdown value the choice is raise-as-a-bluff or fold, and calling just burns a bet.' `
    'Busted hand plus the right blocker: the river is for bluff-raising or folding, never calling.') `
  -conceptTags @('river_bluff_raise','river_blocker_defense','river_polarization') -difficulty 4 `
  -uniquenessNote 'The nut-flush-blocker bluff-raise on a flush-completing river: leverages card removal to attack, the opposite use of a blocker from a bluff-catch.'

# ---- B.2 value_raise_river (nut flush, large) -- polarization partner to B.1 ----
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Kh9h5c_2h_m5_action_Ah3h_v441a' `
  -board (BoardB 'large') -heroHand @('Ah','3h') `
  -handClass 'nut_flush' -heroHandRole 'nutted_value' -drawCategory 'none' -showdownValue 'nutted' `
  -blockerNote 'Holds the Ah with a second heart: this IS the nut flush (Ace-high), unbeatable on an unpaired board -- raise for maximum value.' `
  -recommendedAction 'check_raise_big' -actionReason 'value_raise_river' `
  -question (New-Question 'action_choice' 'Flop Kh 9h 5c; turn 4d; river 2h. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BTN now bets pot (large) on the river. What is BB best action with Ah 3h?' $actionChoices) `
  -answer (New-Answer 'check_raise_big' @('call','check_raise_small') @('fold','mixed') @('fold')) `
  -explanation (New-Explanation `
    'The nut flush on an unpaired board -- check-raise big for maximum value.' `
    'The 2h completes a three-flush and gives Ah-x the nut flush. The board is unpaired, so no full house is possible: the nut flush is the effective nuts and nothing beats it.' `
    'BTN large bet contains lower flushes, two pair and sets that cannot fold easily on this runout; against that calling range a raise is pure value.' `
    'Ah3h is the best possible hand. Flat-calling wins only the one street BTN already bet; check-raising charges the lower flushes and strong made hands that will pay.' `
    'Go big: BTN lower flushes and strong hands are inelastic here, so a large check-raise maximizes value; a small raise leaves money on the table against a range that would have called more.' `
    'Slow-playing the nuts on a wet board -- flat-calling forfeits a full street of value against a range full of second-best flushes.' `
    'With the effective nuts on an unpaired flush board, raise big; the only real mistake is failing to get the money in.') `
  -conceptTags @('river_value_raise','river_polarization','third_barrel_defense') -difficulty 3 `
  -uniquenessNote 'The value half of a polarization pair on one board: with the nut flush BB raises for value, while AhJc (no made hand, same Ah) raises as a bluff -- value and bluff sharing a board and a blocker.'

# ---- B.3 mixed_indifference_river (large) ----
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Kh9h5c_2h_m5_action_KcTd_v441a' `
  -board (BoardB 'large') -heroHand @('Kc','Td') `
  -handClass 'top_pair_weak_kicker' -heroHandRole 'marginal_made_hand' -drawCategory 'none' -showdownValue 'decent' `
  -blockerNote 'No flush blocker (no heart) and a weak kicker; nothing tips the spot off its knife-edge, so the solver mixes.' `
  -recommendedAction 'mixed' -actionReason 'mixed_indifference_river' `
  -question (New-Question 'action_choice' 'Flop Kh 9h 5c; turn 4d; river 2h. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BTN now bets pot (large) on the river. What is BB best action with Kc Td?' $actionChoices) `
  -answer (New-Answer 'mixed' @('call','fold') @('check_raise_small','check_raise_big') @()) `
  -explanation (New-Explanation `
    'Top pair, weak kicker, no blocker on a flush board versus a big bet -- a genuine call/fold mix.' `
    'The 2h completes the flush, so BTN large bet is polar: flushes and better for value, busted hearts as bluffs. A bare top pair beats the bluffs and loses to the value, with no blocker to break the tie.' `
    'BB must defend some top pairs versus the large bet, but not all of them; King-Ten with no heart is right on the indifference line, so it splits between call and fold.' `
    'King-Ten beats every busted heart and worse one-pair, and loses to all flushes plus better kings and two pair. Without a heart to block the nut flush nothing nudges it clearly one way, so both calling and folding are correct at some frequency.' `
    $null `
    'Treating a knife-edge hand as a pure call or pure fold -- and especially raising it, which only folds out worse and gets called by better.' `
    'When a bluff-catcher is genuinely indifferent and holds no relevant blocker, mixing call and fold is the answer; raising is the one clear error.') `
  -conceptTags @('river_bluff_catcher','river_polarization','third_barrel_defense') -difficulty 4 `
  -uniquenessNote 'A clean mixed-indifference spot driven by the ABSENCE of a blocker -- contrast with Ah9c, where the blocker resolves the same kind of marginal hand into a call.'

# ---- B.4 thin_value_call_river (non-nut flush, medium, reason_choice) ----
$scenarios += New-Scenario `
  -id 'pf_btn_v_bb_srp_100bb_river_Kh9h5c_2h_m5_reason_JhTh_v441a' `
  -board (BoardB 'medium') -heroHand @('Jh','Th') `
  -handClass 'flush' -heroHandRole 'thin_value' -drawCategory 'none' -showdownValue 'high' `
  -blockerNote 'Holds two middle hearts so it blocks some lower flushes, but not the Ah or Qh that beat it; this is a call-for-value hand, not a raise.' `
  -recommendedAction 'call' -actionReason 'thin_value_call_river' `
  -question (New-Question 'reason_choice' 'Flop Kh 9h 5c; turn 4d; river 2h. BB calls (does not raise) Jh Th vs BTN two-thirds-pot river bet. What is the primary reason?' $reasonChoices) `
  -answer (New-Answer 'thin_value_call_river' @() @('value_raise_river','bluff_catch_river','missed_draw_give_up') @()) `
  -explanation (New-Explanation `
    'A middle flush calls (does not raise) a two-thirds bet -- thin value, since only better flushes continue to a raise.' `
    'The 2h completes a three-flush. JhTh makes a middling flush: ahead of one-pair value and the busted hearts that bet, but behind the Ah and Qh flushes.' `
    'Versus a medium bet BB is not capped at the flush level; a made flush is near the top of BB range and wants to get value -- but only from worse.' `
    'JhTh beats every non-flush hand BTN bets plus the few lower flushes, and loses only to the Ah or Qh flushes. Calling collects from all of that; raising would fold out the one-pair value and get called only by the flushes that beat it.' `
    $null `
    'Raising a non-nut flush "because it is a flush" -- that turns a value hand into a bluff-catcher by folding out everything it beats.' `
    'Hold a made-but-beatable hand? Call to keep worse hands betting; do not raise into the few hands that have you crushed.') `
  -conceptTags @('river_thin_value','river_polarization','third_barrel_defense') -difficulty 3 `
  -uniquenessNote 'Thin-value call with a non-nut flush: the call-do-not-raise lesson at the flush level, complementing the existing two-pair and set thin-value spots.'

# ====== Assemble + write ======
$nAction = @($scenarios | Where-Object { $_.question.qtype -eq 'action_choice' }).Count
$nReason = @($scenarios | Where-Object { $_.question.qtype -eq 'reason_choice' }).Count
$root = [ordered]@{
  schemaVersion = '1.3.0'
  moduleId      = 'pf_river_barrel_oop_def'
  moduleName    = 'Facing River Barrel OOP'
  version       = 'v4.4.1A'
  status        = 'planning_only'
  generatedAt   = '2026-06-18'
  notes         = 'v4.4.1A gap-first expansion seeds for Module 5 (BB River Defense OOP). 8 scenarios on 2 new boards (A-high dry brick; flush-completing) targeting the coverage holes in the production 24 (pot_odds_river_call, domination_river_fold, thin bluff_raise/blocker_bluff_catch, thin_value role) and lifting reason_choice share. River is showdown-only. NOT loaded at runtime. Migration to production scheduled for v4.4.1A after strategic review.'
  expansionStats = [ordered]@{
    totalScenarios = $scenarios.Count
    boards         = 2
    actionChoice   = $nAction
    reasonChoice   = $nReason
  }
  scenarios = $scenarios
}

$json = $root | ConvertTo-Json -Depth 100
$utf8nb = [System.Text.UTF8Encoding]::new($false)
$tmp = "$outPath.tmp"
[System.IO.File]::WriteAllText($tmp, $json, $utf8nb)
Move-Item -LiteralPath $tmp -Destination $outPath -Force
Write-Host ("Wrote " + $scenarios.Count + " v4.4.1A expansion seeds to " + $outPath)
Write-Host ("  action_choice=" + $nAction + "  reason_choice=" + $nReason)
