# build-m6-expansion-v4.5.2A.ps1 -- Module 6 expansion batch (+8: 24 -> 32).
# PLANNING-ONLY: writes docs/specs/postflop-v4.5.2A-module6-expansion-seeds.json.
# Production postflop_scenarios.json is NEVER touched by this script.
# Same regime as v4.5.1 (owner: "no new rulings needed"): verdictBasis
# discipline, stakeBasis PIN, R24-R28 bounds, Range-Reveal prose hygiene.
# Batch shape: 6 action (4 at D>=4 feeding the FT pool) + 2 reason;
# 0 new mixed_nudge (no candidate survived the nudge-direction test);
# 0 new solver_required parks. ASCII-only. PS 5.1 safe.
#
# Coverage this batch adds (gaps in the 24):
#   - RIVER-completed flush from the bettor seat, all three roles on ONE
#     runout (Jh6h2c-Qs-8h): A5 nut-flush value / C5 Kh-blocker bluff /
#     D5 no-blocker give-up  -- the three-seat lesson.
#   - Bottom-card-pairing river as thin-value CONTRAST to E2 (B5).
#   - River-completed straight bluff w/ made-hand blocker (C6, vs C2's
#     turn-completed version).
#   - Double-low-connector runout give-up w/ club front-door live (D6).
#   - Jacks-full-of-aces overbet: ZERO combos beat (Js blocks quads,
#     AA range-excluded) => CHECK-BACK-NUTS critical, A5/F1-class (F5).

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$outPath = Join-Path $root 'docs\specs\postflop-v4.5.2A-module6-expansion-seeds.json'

function New-M6 {
  param($idFrag,$diff,$flop,$turn,$river,$boardKind,$stf,$stt,$str,$tags,$rivCat,$bChange,$runout,
        $hero,$handClass,$role,$sdv,$blocker,$rec,$reason,$vBasis,$stake,$hrs,$purpose,
        $qtype,$prompt,$choices,$best,$acc,$bad,$crit,
        $short,$rivLogic,$rangeCtx,$handLogic,$sizLogic,$mistake,$takeaway,$concepts,$mixedWl)
  $o = [ordered]@{
    id = 'pf_btn_v_bb_srp_100bb_river_' + $idFrag + '_v452a'
    version = 'v4.5.2A'
    game = 'NLH_MTT'
    module = 'pf_river_value_ip'
    moduleName = 'River Betting IP'
    street = 'river'
    schemaVersion = '1.4.0'
    actionHistory = @()
    scoring = [ordered]@{ best = 1; acceptable = 0.5; bad = 0; critical = 0 }
    difficulty = $diff
    spot = [ordered]@{
      format = 'NLH_MTT'; stackDepth = '100BB'; potType = 'SRP'
      preflopAction = 'BTN open 2.5x, BB call'
      flopAction = 'BTN cbet small (~33%), BB call'
      turnAction = 'BTN barrel (~50-66%), BB call'
      riverAction = 'BB checks river'
      street = 'river'; heroPosition = 'BTN'; villainPosition = 'BB'
      heroRole = 'river_bettor_ip'; villainRole = 'river_check_caller_oop'
    }
    board = [ordered]@{
      flopCards = $flop; turnCard = $turn; riverCard = $river
      cards = @($flop) + @($turn, $river)
      boardKind = $boardKind
      suitTextureFlop = $stf; suitTextureTurn = $stt; suitTextureRiver = $str
      textureTags = $tags
      highCardClass = $boardKind
      riverCategory = $rivCat; boardChange = $bChange
      runoutTexture = $runout; riverDrawCompletion = $(if ($rivCat -eq 'flush_complete') { 'flush_completed' } elseif ($rivCat -eq 'straight_complete') { 'straight' } elseif ($rivCat -eq 'board_pair') { 'board_paired' } else { 'none' })
    }
    heroHand = $hero
    handClass = $handClass
    heroHandRole = $role
    drawCategory = 'none'
    showdownValue = $sdv
    blockerNote = $blocker
    recommendedAction = $rec
    actionReason = $reason
    verdictBasis = $vBasis
    stakeBasis = $stake
    heroRiverSizing = $hrs
    betPurpose = $purpose
    question = [ordered]@{ qtype = $qtype; prompt = $prompt; choices = $choices }
    answer = [ordered]@{ best = $best; acceptable = $acc; bad = $bad; critical = $crit }
    explanation = [ordered]@{
      short = $short; riverLogic = $rivLogic; rangeContext = $rangeCtx
      handLogic = $handLogic; sizingLogic = $sizLogic
      commonMistake = $mistake; takeaway = $takeaway
    }
    conceptTags = $concepts
    sourceConfidence = 'expert_judgment'
    auditStatus = 'review_pending'
    reviewStatus = 'v4.5.2A_seed'
  }
  if ($null -ne $mixedWl) { $o['mixedWhitelistChoices'] = $mixedWl }
  return $o
}

$S = @()

# A5 -- nut flush on the river-completed flush board: CHECK-BACK-NUTS exemplar
$S += New-M6 -idFrag 'Jh6h2c_8h_m6_action_AhKh' -diff 3 `
  -flop @('Jh','6h','2c') -turn 'Qs' -river '8h' -boardKind 'Q_high' -stf 'two_tone' -stt 'two_tone' -str 'monotone' `
  -tags @('wet') -rivCat 'flush_complete' -bChange 'range_shift_btn' -runout 'flush_possible' `
  -hero @('Ah','Kh') -handClass 'nut_flush' -role 'nutted_value' -sdv 'nutted' `
  -blocker 'Hero holds the Ah and Kh: every other flush is smaller by definition, and villain''s strongest holdings (QhXh-type flushes, sets) all bluff-catch. Zero combos beat the hand.' `
  -rec 'bet_big' -reason 'value_bet_thick_river' -vBasis 'clear_direction' -stake 'large' -hrs 'large' -purpose 'thick_value' `
  -qtype 'action_choice' `
  -prompt 'Flop Jh 6h 2c; turn Qs; river 8h. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ah Kh?' `
  -choices @('check_back','bet_small','bet_big','overbet','mixed') `
  -best 'bet_big' -acc @('overbet') -bad @('bet_small','mixed') -crit @('check_back') `
  -short 'The nut flush arrives on the river: bet big -- smaller flushes and top pair pay.' `
  -rivLogic 'The 8h completes the front-door flush hero drew to with the nut cards. The board never pairs, so no boat exists: A-high flush is the stone nuts. The T9 straight that also arrived (8-9-T-J-Q) now pays a big bet instead of winning the pot.' `
  -rangeCtx 'BB''s check-call check-call range holds smaller flushes that chose not to lead, Jx and Qx pairs, and the rivered T9 straight. Every one of those hands bluff-catches or pays; none of them beats hero.' `
  -handLogic 'Nut flush on an unpaired board: 100% of villain''s continues lose. The only question is price extraction from the flush-and-straight region that just got there.' `
  -sizLogic 'Big (~75%) is the primary: smaller flushes and T9 call it almost always, and Qx/Jx still pay it often after two streets of commitment. The overbet is a defensible polar alternative. Checking the stone nuts back forfeits the entire street at zero risk -- the definitional full punt.' `
  -mistake 'Slowplaying the nuts on the last street: there is no later street; the river check wins exactly what the pot already holds.' `
  -takeaway 'When your draw arrives with the nut cards, the work is done -- charge the region that arrived with you.' `
  -concepts @('river_value_threshold','nut_blocker_leverage','sizing_polarity')

# B5 -- bottom-card pairing river: thin value SURVIVES (contrast with E2)
$S += New-M6 -idFrag 'Kc9s2h_2d_m6_action_KhQs' -diff 4 `
  -flop @('Kc','9s','2h') -turn '5d' -river '2d' -boardKind 'K_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'board_pair' -bChange 'brick' -runout 'paired_board' `
  -hero @('Kh','Qs') -handClass 'top_pair_good_kicker' -role 'thin_value' -sdv 'medium' `
  -blocker 'Hero''s K thins the K9/K5s two-pair combos that beat him; the Q blocks nothing relevant. The dominated KJ/KT ladder is untouched -- exactly the hands a small bet wants.' `
  -rec 'bet_small' -reason 'value_bet_thin_river' -vBasis 'clear_direction' -stake 'small' -hrs 'small' -purpose 'thin_value' `
  -qtype 'action_choice' `
  -prompt 'Flop Kc 9s 2h; turn 5d; river 2d. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Kh Qs?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'bet_small' -acc @('check_back') -bad @('bet_big','mixed') -crit @() `
  -short 'The river pairs the BOTTOM card: nobody improved -- the thin bet stays on.' `
  -rivLogic 'The 2d pairs the deuce. Contrast this with a paired MIDDLE card: the 9x hands that check-called this flop are still one pair, because BB''s range holds almost no 2x -- deuces folded preflop or on the K-9-2 flop. Pairing the bottom card is functionally a brick.' `
  -rangeCtx 'Villain''s range is Kx (KJ, KT dominated; K9 flopped two pair but check-raises part of the time), 9x that refuses to fold, and busted gutters. The improvement region from the river card is essentially empty.' `
  -handLogic 'KQ beats KJ, KT and every 9x; it loses to K9, K5s and slow-played sets -- the same short list as before the river. When the river adds nothing to villain''s range, the pre-river value count still stands.' `
  -sizLogic 'Small keeps KJ/KT/9x calling. The lesson pair with the AQ check-back on K-7-3-Q-7: there the river 7 promoted villain''s mid pairs to trips and deleted the market; here the 2 promotes nobody. Same-looking card, opposite recount.' `
  -mistake 'Treating every paired river as a trips scare: ask WHICH rank paired and whether villain''s line holds it. Bottom cards usually pair nobody.' `
  -takeaway 'Recount the callers after every river -- and when the answer is "unchanged", keep the thin bet in the lineup.' `
  -concepts @('thin_value_discipline','trap_risk_paired_river','river_value_threshold')

# B6 -- reason row: thin value through a scare-turn runout
$S += New-M6 -idFrag 'Ah8c4d_6s_m6_reason_AcJd' -diff 3 `
  -flop @('Ah','8c','4d') -turn 'Kd' -river '6s' -boardKind 'A_high' -stf 'rainbow' -stt 'two_tone' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'straight_complete' -bChange 'range_shift_minor' -runout 'dry_unpaired' `
  -hero @('Ac','Jd') -handClass 'top_pair_good_kicker' -role 'thin_value' -sdv 'medium' `
  -blocker 'Hero''s J beats the AT/A9 kicker ladder; no meaningful removal either way. The bet rests on the ladder, not on blockers.' `
  -rec 'bet_small' -reason 'value_bet_thin_river' -vBasis 'clear_direction' -stake 'small' -hrs 'small' -purpose 'thin_value' `
  -qtype 'reason_choice' `
  -prompt 'Flop Ah 8c 4d; turn Kd; river 6s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. BTN holds Ac Jd and the best line is a small bet. WHY?' `
  -choices @('value_bet_thin_river','check_back_trap_risk_river','sizing_polar_big_river','polar_overbet_nut_river') `
  -best 'value_bet_thin_river' -acc @() -bad @('check_back_trap_risk_river','sizing_polar_big_river','polar_overbet_nut_river') -crit @() `
  -short 'The K turn scared nobody who matters: dominated aces still pay a small river bet.' `
  -rivLogic 'The 6s completes only the 57 gutter that peeled the flop four-out and then faced a turn barrel -- a filtered sliver. The turn K is the card players over-respect: BB''s check-call range was built on the A-high flop, so it is Ax-dense and nearly K-free.' `
  -rangeCtx 'Kx that would beat nothing here mostly folded the A-high flop. What check-calls twice is dominated Ax (AT, A9, A7s, A5s), which AJ out-kicks, plus the promoted A8/A4/A6s two-pairs that part check-raise earlier.' `
  -handLogic 'AJ beats the AT/A9/A7s/A5s ladder; it loses to AK/AQ remnants and the promoted two-pairs. The dominated pool remains clearly wider -- the K on the turn did not change the count, only the nerves.' `
  -sizLogic 'A third of pot keeps every dominated ace in. The trap-risk reason is the over-respect error dressed up as discipline; both polar reasons mis-class a one-pair hand.' `
  -mistake 'Downgrading top pair because a broadway turned: check whose range the card actually hit before surrendering the street.' `
  -takeaway 'Scare cards scare ranges, not rankings: if villain''s line cannot hold the card, keep betting the ladder you dominate.' `
  -concepts @('thin_value_discipline','river_value_threshold','merged_sizing')

# C5 -- Kh-blocker bluff on the river-completed flush (same runout as A5)
$S += New-M6 -idFrag 'Jh6h2c_8h_m6_action_KhTs' -diff 4 `
  -flop @('Jh','6h','2c') -turn 'Qs' -river '8h' -boardKind 'Q_high' -stf 'two_tone' -stt 'two_tone' -str 'monotone' `
  -tags @('wet') -rivCat 'flush_complete' -bChange 'range_shift_btn' -runout 'flush_possible' `
  -hero @('Kh','Ts') -handClass 'king_high' -role 'air_bluff_candidate' -sdv 'low' `
  -blocker 'The Kh removes every KhXh flush from villain''s range -- the second-nut tier -- while hero''s busted open-ender has no showdown value to protect. One key blocker plus zero equity puts the combo on the bluff side of the line, one sizing tier below the Ah version of this spot.' `
  -rec 'bet_big' -reason 'blocker_bluff_river' -vBasis 'clear_direction' -stake 'large' -hrs 'large' -purpose 'bluff' `
  -qtype 'action_choice' `
  -prompt 'Flop Jh 6h 2c; turn Qs; river 8h. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Kh Ts?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'bet_big' -acc @() -bad @('check_back','bet_small','mixed') -crit @() `
  -short 'Busted open-ender holding the Kh: the second-nut-flush blocker bets big.' `
  -rivLogic 'The 8h completes the flush hero was drawing around: the K-T open-ender (9 or A) missed, leaving king-high with one heart. On this runout the hand''s remaining value is the Kh itself -- villain can never hold the second-nut flush.' `
  -rangeCtx 'Villain''s river checks are Jx/Qx pairs, modest flushes that flatted rather than led, and the rivered T9 straight. Hero''s Kh trims the strong-flush tier; the pairs and the straight now face a big bet that credibly comes from the flushes hero barrelled toward.' `
  -handLogic 'King-high wins essentially no showdown after two streets of calls on a wet board. Zero showdown value plus a tier-one blocker is the classic convert-to-bluff profile.' `
  -sizLogic 'Big -- the size real flushes use here. The Ah version of this combo overbets (nut blocker); the Kh version sizes one tier down, mirroring the nut/second-nut ladder from the turn-flush board. Small tells a story no value hand tells.' `
  -mistake 'Giving up every missed draw on a completed-flush river: the ones holding top flush cards are exactly the ones that should keep firing.' `
  -takeaway 'Rank your busted draws by the flush cards they hold -- the blocker tier sets the bluff size.' `
  -concepts @('bluff_candidate_selection','nut_blocker_leverage','story_consistency')

# C6 -- river-completed straight bluff: T blocks the made hand, K blocks the calls
$S += New-M6 -idFrag 'QdJc5s_8s_m6_action_KcTc' -diff 4 `
  -flop @('Qd','Jc','5s') -turn '4h' -river '8s' -boardKind 'Q_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','connected') -rivCat 'straight_complete' -bChange 'range_shift_bb' -runout 'dry_unpaired' `
  -hero @('Kc','Tc') -handClass 'king_high' -role 'air_bluff_candidate' -sdv 'low' `
  -blocker 'Hero''s T halves the T9 combos that just made the straight (the trap region), and the K removes KQ/KJ -- the sturdiest top-pair calls. Both of villain''s best responses to a big bet are thinned before it is made.' `
  -rec 'bet_big' -reason 'blocker_bluff_river' -vBasis 'clear_direction' -stake 'large' -hrs 'large' -purpose 'bluff' `
  -qtype 'action_choice' `
  -prompt 'Flop Qd Jc 5s; turn 4h; river 8s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Kc Tc?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'bet_big' -acc @() -bad @('check_back','bet_small','mixed') -crit @() `
  -short 'The 8 completes T9 -- and hero''s own T and K make the bluff, not the fold.' `
  -rivLogic 'The 8s lands the 8-9-T-J-Q straight for T9, which peeled the flop open-ended. Hero''s KT drew to the same ladder from above (9 or A) and missed. King-high has no showdown value against two streets of calls -- but it holds one card of the arrived straight and one card of the stubbornest pairs.' `
  -rangeCtx 'Villain''s range: Qx and Jx pairs, the rivered T9, and busted low gutters that fold to anything. The 76 straight (4-5-6-7-8) is line-excluded: 76 had nothing on the Q-J-5 flop and never called. So the trap region is T9 alone -- and hero''s T cuts it in half.' `
  -handLogic 'Zero showdown value makes the choice bluff-or-surrender. The removal profile answers it: blocking the trap (T9) and the top calls (KQ/KJ) simultaneously is the double-duty shape that ranks a bluff first in line.' `
  -sizLogic 'Big pressure on the one-pair core, representing the straight hero can credibly hold. The turn-completed version of this lesson lives on Q-9-4-8; this is the river-completed mirror -- same blockers, later arrival, same conclusion.' `
  -mistake 'Reading "the straight card got there" as a stop sign: when your own cards hold the straight and the calls, the card got there for YOU.' `
  -takeaway 'Completion cards cut both ways -- count your copies of the arrived hand before surrendering the pot.' `
  -concepts @('bluff_candidate_selection','nut_blocker_leverage','story_consistency')

# D5 -- no-blocker give-up on the river-completed flush (same runout as A5/C5)
$S += New-M6 -idFrag 'Jh6h2c_8h_m6_action_AsKd' -diff 4 `
  -flop @('Jh','6h','2c') -turn 'Qs' -river '8h' -boardKind 'Q_high' -stf 'two_tone' -stt 'two_tone' -str 'monotone' `
  -tags @('wet') -rivCat 'flush_complete' -bChange 'range_shift_bb' -runout 'flush_possible' `
  -hero @('As','Kd') -handClass 'ace_high' -role 'air_give_up' -sdv 'low' `
  -blocker 'No heart: villain''s flushes -- the calling region -- are fully intact, while hero''s A and K block AJ/KJ/AQ/KQ, the one-pair hands that could fold. Unblocked calls plus blocked folds is the reverse of what a bluff needs.' `
  -rec 'check_back' -reason 'give_up_no_equity_river' -vBasis 'clear_direction' -stake 'large' -hrs 'none' -purpose 'give_up' `
  -qtype 'action_choice' `
  -prompt 'Flop Jh 6h 2c; turn Qs; river 8h. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with As Kd?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'check_back' -acc @() -bad @('bet_small','mixed') -crit @('bet_big') `
  -short 'Same river, no heart: the story exists but the blockers refute it -- give up.' `
  -rivLogic 'The 8h completes the flush without hero: the royal gutter to the ten missed, and ace-high holds no heart. Hero DID barrel the line a flush would barrel, so the story is available -- but a story is only half a bluff.' `
  -rangeCtx 'The flush-heavy side of villain''s range -- every two-heart holding that check-called -- is untouched by hero''s cards and never folds. The foldable side is one-pair Jx/Qx with a big kicker, and hero''s own A and K delete a chunk of exactly those combos.' `
  -handLogic 'Compare the three seats of this runout: AhKh arrived (value), KhTs holds the second-nut blocker (bluff), AsKd holds nothing (give up). Identical line, identical river -- the holding decides, and this holding fails the removal test in both directions.' `
  -sizLogic 'The big barrel is the punished temptation at 20 BB: maximum money into an unblocked calling region. Ace-high''s sliver of showdown value against stray K-high floats costs nothing to keep by checking.' `
  -mistake 'Bluffing because "I would bet my flushes here" -- range logic without combo logic. Your specific cards must cooperate, not just your line.' `
  -takeaway 'One runout, three verdicts: the line tells the story, but the blockers decide who gets to tell it.' `
  -concepts @('give_up_discipline','unblock_fold_region','story_consistency')

# D6 -- reason row: double low connectors + live club front-door = give up
$S += New-M6 -idFrag 'Jc8d4s_5c_m6_reason_Th9h' -diff 4 `
  -flop @('Jc','8d','4s') -turn '6c' -river '5c' -boardKind 'J_high' -stf 'rainbow' -stt 'two_tone' -str 'monotone' `
  -tags @('wet','connected') -rivCat 'straight_complete' -bChange 'range_shift_bb' -runout 'straight_possible' `
  -hero @('Th','9h') -handClass 'queen_high' -role 'air_give_up' -sdv 'none' `
  -blocker 'Hero''s T and 9 sit in the busted-gutter region villain folds (QT, T9-adjacent floats) and the 9 clips part of the 97 straights -- the same both-directions-wrong profile as the J-T-3-8-4 give-up, with a third strike: hero holds no club while the rivered club flush is live.' `
  -rec 'check_back' -reason 'give_up_no_equity_river' -vBasis 'clear_direction' -stake 'large' -hrs 'none' -purpose 'give_up' `
  -qtype 'reason_choice' `
  -prompt 'Flop Jc 8d 4s; turn 6c; river 5c. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. BTN holds Th 9h and the best line is to check back. WHY?' `
  -choices @('give_up_no_equity_river','sizing_polar_big_river','blocker_bluff_river','check_back_showdown_river') `
  -best 'give_up_no_equity_river' -acc @() -bad @('sizing_polar_big_river','blocker_bluff_river','check_back_showdown_river') -crit @() `
  -short 'Two low connectors and a third club: villain''s peels got there, hero''s draw did not.' `
  -rivLogic 'Hero barrelled the open-ender (7 or Q) and bricked while the runout worked entirely for the check-caller: the turn 6 completed 75, the river 5 completed 97, and the 5c is the third club, so two-club peels made a flush. Ten-high cannot beat a single made hand.' `
  -rangeCtx 'BB''s low-card peel range (75s, 97s, 76s, club draws) is exactly what check-calls a J-8-4 flop cheaply -- and every group just improved. The foldable region is busted QT/KT-type gutters, which hero''s own T inhabits and blocks.' `
  -handLogic 'The right-action-wrong-reason trap is "check because ten-high sometimes wins" -- it wins nothing here. The check is right because the BLUFF is wrong: three separate arrival waves (75, 97, clubs) left the range uncapped, and the blockers point the wrong way.' `
  -sizLogic 'The polar-big temptation ("the 5 is scary, rep the straight") fails the whose-card test: consecutive low connectors land in the PEELER''s range, not the barreler''s. Hero''s line never credibly holds 75 or 97.' `
  -mistake 'Repping cards that complete villain''s draws, not yours: if the arrival waves favor the check-caller, the scare card is theirs.' `
  -takeaway 'Ask who the runout worked for. Three waves for villain, zero for you -- close the wallet and move on.' `
  -concepts @('give_up_discipline','story_consistency','unblock_fold_region')

# F5 -- jacks-full-of-aces: overbet clear; ZERO combos beat (Js blocks quads,
$S += New-M6 -idFrag 'AsJh7c_Jd_m6_action_AdJs' -diff 3 `
  -flop @('As','Jh','7c') -turn '3d' -river 'Jd' -boardKind 'A_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','paired') -rivCat 'board_pair' -bChange 'boat_possible' -runout 'paired_board' `
  -hero @('Ad','Js') -handClass 'full_house' -role 'nutted_value' -sdv 'nutted' `
  -blocker 'Enumeration is closed by hero''s own cards: the Js plus the board''s Jh and Jd leave only the Jc, so villain can never hold two jacks -- quad jacks is impossible. AA (aces full) three-bets preflop; 77 and 33 make smaller boats; JcAx merely chops. Zero combos beat the hand, and the Ax/Jx regions that remain never fold.' `
  -rec 'overbet' -reason 'polar_overbet_nut_river' -vBasis 'clear_direction' -stake 'overbet' -hrs 'overbet' -purpose 'thick_value' `
  -qtype 'action_choice' `
  -prompt 'Flop As Jh 7c; turn 3d; river Jd. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ad Js?' `
  -choices @('check_back','bet_small','bet_big','overbet','mixed') `
  -best 'overbet' -acc @('bet_big') -bad @('bet_small','mixed') -crit @('check_back') `
  -short 'Jacks full of aces, quads impossible: overbet the trips-and-top-pair range.' `
  -rivLogic 'The Jd fills hero to jacks full of aces (J-J-J-A-A). Quad jacks is impossible: hero''s Js and the board''s Jh and Jd leave only the Jc in the deck, and one jack does not make quads. AA (the aces-full combo) three-bets preflop in the baseline; 77 and 33 fill smaller; JcAx makes the same boat and chops. Zero combos beat hero -- the stone nuts by enumeration.' `
  -rangeCtx 'Villain''s check-call check-call range on A-J-7 is Ax top pair (now aces-and-jacks two pair that cannot fold) and Jx mid pair (now trips that will not believe hero has the case jack). Both regions are built to pay a polar bet.' `
  -handLogic 'The boat beats every Ax, every fresh Jx trips, the smaller 77 and 33 full houses, and every two pair; JcAx chops. Losing scenario: none -- the enumeration comes up empty once the Js block and the AA preflop exclusion are counted. The calling regions upgrade themselves on the very card that makes hero unbeatable.' `
  -sizLogic 'Overbet first, big bet close behind: trips and Ax bluff-catch at any price after this runout, so price is the only lever left. Betting small sells the boat at a discount; checking back the stone nuts forfeits the entire street at zero risk -- the definitional full punt (critical), same class as the other stone-nuts rows in the module.' `
  -mistake 'Sizing down "because the board paired" -- the pair card is what promoted villain''s calling range from one pair to trips.' `
  -takeaway 'When the river upgrades villain''s hand AND yours, the bigger hand sets the price: near-nut boats overbet.' `
  -concepts @('sizing_polarity','river_value_threshold','trap_risk_paired_river')

# ---------- emit ----------

$doc = [ordered]@{
  description = 'Module 6 (River Betting IP) v4.5.2A expansion batch -- +8 scenarios (24 -> 32), PLANNING-ONLY. Same regime as v4.5.1 (verdictBasis, stakeBasis PIN, R24-R28); 6 action (5 at D>=4) + 2 reason; 0 new mixed_nudge; 0 new solver_required parks. Production untouched by this script.'
  generatedBy = 'tools/build-m6-expansion-v4.5.2A.ps1'
  seedVersion = 'v4.5.2A'
  module = 'pf_river_value_ip'
  schemaVersion = '1.4.0'
  count = $S.Count
  scenarios = $S
}

$json = $doc | ConvertTo-Json -Depth 12
$tmp = $outPath + '.tmp'
[System.IO.File]::WriteAllText($tmp, $json, [System.Text.UTF8Encoding]::new($false))
Move-Item -Force $tmp $outPath
Write-Output ('WROTE ' + $outPath + ' scenarios=' + $S.Count)
