# build-m6-seeds-v4.5.1.ps1 -- Module 6 (River Betting IP) 24-seed builder.
# PLANNING-ONLY: writes docs/specs/postflop-v4.5.1-module6-seeds.json.
# Production postflop_scenarios.json is NEVER touched by this script.
# Source of truth for the v4.5.1 seed batch. ASCII-only. PS 5.1 safe.
#
# OWNER RULINGS ENCODED (G4 architecture approval, 2026-07-05):
#  - verdictBasis mandatory: clear_direction | mixed_nudge (solver_required
#    is HARD-BLOCKED from approvable rows by the seed auditor).
#  - stakeBasis mandatory (PIN): bet-best rows = best line's sizing;
#    check_back-best rows = designated temptation bet's sizing;
#    mixed rows = primary bet member's sizing (first acceptable entry).
#  - mixed rows carry mixedWhitelistChoices (game-tier promotion entries
#    ship in the SAME migration, never retrofitted).
#  - overbet stake rows in seed: A4, C1 (best) + F4 (mix primary) + D4
#    (temptation) => stake spread reaches 30 BB from day one.
# Range Reveal prose discipline: whitelist phrases used only where true;
# no negator within ~40 chars before a band phrase unless intended;
# "flush-dense" never used for board texture (not used at all in v4.5.1).

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$outPath = Join-Path $root 'docs\specs\postflop-v4.5.1-module6-seeds.json'

function New-M6 {
  param($idFrag,$diff,$flop,$turn,$river,$boardKind,$stf,$stt,$str,$tags,$rivCat,$bChange,$runout,
        $hero,$handClass,$role,$sdv,$blocker,$rec,$reason,$vBasis,$stake,$hrs,$purpose,
        $qtype,$prompt,$choices,$best,$acc,$bad,$crit,
        $short,$rivLogic,$rangeCtx,$handLogic,$sizLogic,$mistake,$takeaway,$concepts,$mixedWl)
  $o = [ordered]@{
    id = 'pf_btn_v_bb_srp_100bb_river_' + $idFrag + '_v451'
    version = 'v4.5.1'
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
      runoutTexture = $runout; riverDrawCompletion = $(if ($rivCat -eq 'straight_complete') { 'straight' } elseif ($rivCat -eq 'board_pair') { 'board_paired' } else { 'none' })
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
    reviewStatus = 'v4.5.1_seed'
  }
  if ($null -ne $mixedWl) { $o['mixedWhitelistChoices'] = $mixedWl }
  return $o
}

$S = @()

# ---------- CAT A: THICK VALUE ----------

$S += New-M6 -idFrag 'Kh8d3s_2d_m6_action_Kc8c' -diff 2 `
  -flop @('Kh','8d','3s') -turn '6c' -river '2d' -boardKind 'K_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('Kc','8c') -handClass 'two_pair' -role 'strong_value' -sdv 'high' `
  -blocker 'Holding a K and an 8 slightly thins the Kx and 8x calling regions, but the value region left (KQ, KJ, KT, K9) is wide enough that the bet stands on its own.' `
  -rec 'bet_big' -reason 'value_bet_thick_river' -vBasis 'clear_direction' -stake 'large' -hrs 'large' -purpose 'thick_value' `
  -qtype 'action_choice' `
  -prompt 'Flop Kh 8d 3s; turn 6c; river 2d. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Kc 8c?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'bet_big' -acc @('bet_small') -bad @('check_back','mixed') -crit @() `
  -short 'Top two on a brick runout: bet big and charge every Kx.' `
  -rivLogic 'The 2d is a pure brick: no flush arrives (two diamonds only) and no straight completes -- 54 needed to get there via 2-3-4-5-6 but 54 never had a one-card draw on the K-8-3 flop, so the line filtered it out. Ranges are frozen from the turn and hero still holds the best two-pair.' `
  -rangeCtx 'BB check-called twice on a dry board, which caps the range around Kx one-pair, 8x, and the odd stubborn pocket pair. Slow-played sets of 3s or 6s exist but are rare and part check-raise earlier.' `
  -handLogic 'K8 beats every one-pair hand that took this line -- KQ, KJ, KT, K9 and all 8x -- and beats the turned two-pair K6 as well (8 outkicks 6 as the second pair). Only 33, 66 and the rare 22 that peeled twice beat it.' `
  -sizLogic 'Big sizing (~75%) is the point: Kx has bluff-catch equity against the missed-draw story and pays a large bet after calling two streets. Small sizing leaves a full street of value unclaimed against a range that rarely folds a K.' `
  -mistake 'Betting small "to keep everything in" -- the hands that call small (Kx) also call big here, so the discount is pure lost value.' `
  -takeaway 'When the runout bricks and your two-pair beats the whole calling region, size up: the third barrel is where the money is made.' `
  -concepts @('river_value_threshold','sizing_polarity')

$S += New-M6 -idFrag 'As9h5d_2h_m6_action_9s9c' -diff 3 `
  -flop @('As','9h','5d') -turn 'Qc' -river '2h' -boardKind 'A_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('9s','9c') -handClass 'set' -role 'strong_value' -sdv 'high' `
  -blocker 'The two 9s remove most 9x two-pair combos from BB, concentrating the calling range on Ax -- exactly the region a big bet targets.' `
  -rec 'bet_big' -reason 'value_bet_thick_river' -vBasis 'clear_direction' -stake 'large' -hrs 'large' -purpose 'thick_value' `
  -qtype 'action_choice' `
  -prompt 'Flop As 9h 5d; turn Qc; river 2h. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with 9s 9c?' `
  -choices @('check_back','bet_small','bet_big','overbet','mixed') `
  -best 'bet_big' -acc @('overbet') -bad @('bet_small','check_back','mixed') -crit @() `
  -short 'Set of 9s under the ace: big value bet into the Ax-heavy check-call range.' `
  -rivLogic 'The 2h changes almost nothing: the only new arrival is the rare 43-suited wheel (A-2-3-4-5) that peeled a bare gutter on the flop and then faced a turn barrel -- a heavily discounted holding. Hero''s set is effectively the top of the ranges that reach this river.' `
  -rangeCtx 'BB''s check-call check-call line on an A-high board is saturated with Ax: AJ, AT, weak suited aces, plus some Qx that picked up the turn pair. All of it bluff-catches; none of it beats a set.' `
  -handLogic 'Middle set beats every Ax one-pair, every Qx, and both two-pair combos (AQ, A9 is blocked). Only 55 played this passively ever beats hero, and most sets check-raise before the river.' `
  -sizLogic 'Big (~75%) extracts from Ax which feels pot-committed after two calls. An overbet is a defensible polar alternative -- villain''s Ax is a strong catcher -- but big keeps the weaker aces in. Small is a clear underperformance against a range this sticky.' `
  -mistake 'Checking back the set because "the wheel got there" -- a one-combo-class scare against dozens of Ax combos is exactly the over-caution the river rewards you for ignoring.' `
  -takeaway 'Count the region that pays you (all Ax) against the region that beats you (rare slow-played sets): when the ratio is this lopsided, bet big.' `
  -concepts @('river_value_threshold','sizing_polarity')

$S += New-M6 -idFrag 'AhKc7d_3s_m6_reason_AdKs' -diff 2 `
  -flop @('Ah','Kc','7d') -turn '7h' -river '3s' -boardKind 'A_high' -stf 'rainbow' -stt 'two_tone' -str 'two_tone' `
  -tags @('dry','paired') -rivCat 'brick' -bChange 'brick' -runout 'paired_board' `
  -hero @('Ad','Ks') -handClass 'two_pair' -role 'strong_value' -sdv 'high' `
  -blocker 'Holding an A and a K removes the strongest bluff-catch combos (other AK) and leaves the calling range weighted to AQ/AJ/AT -- all of which hero beats.' `
  -rec 'bet_big' -reason 'value_bet_thick_river' -vBasis 'clear_direction' -stake 'large' -hrs 'large' -purpose 'thick_value' `
  -qtype 'reason_choice' `
  -prompt 'Flop Ah Kc 7d; turn 7h; river 3s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. BTN holds Ad Ks and the best line is a big bet. WHY?' `
  -choices @('value_bet_thick_river','check_back_trap_risk_river','sizing_merge_small_river','polar_overbet_nut_river') `
  -best 'value_bet_thick_river' -acc @() -bad @('check_back_trap_risk_river','sizing_merge_small_river','polar_overbet_nut_river') -crit @() `
  -short 'Top two on A-K-7-7-3: the Ax region check-calls twice and pays a third big bet.' `
  -rivLogic 'The 3s is a blank on a board that paired its third card. AK''s two pair (aces and kings) still beats every one-pair Ax that took the check-call check-call line: AQ, AJ, AT and the suited wheel aces that peeled.' `
  -rangeCtx 'Trips are the only real threat and the combos are thin: 7x that check-calls an A-K-high flop is basically 76s/75s. Most 7x folded the flop, and A7s/K7s two-pairs part check-raise the turn when the 7 pairs.' `
  -handLogic 'Beats all Ax one-pair; loses only to the few surviving 7x-trips and slow-played boats. The dominated calling region is several times wider than the beaten one.' `
  -sizLogic 'Big sizing charges AQ/AJ maximum; they are near the top of villain''s range and do not fold to one more barrel. Overbetting is unnecessary risk against the trips tail; small sizing gives the dominated aces a discount they would never demand.' `
  -mistake 'Freezing at the paired 7 and checking back -- surrendering a full street from the widest value region in the tree because of two or three suited combos.' `
  -takeaway 'A paired mid-card rarely turns a thick-value river into a check: count the trips combos before you downgrade the hand.' `
  -concepts @('river_value_threshold','trap_risk_paired_river')

$S += New-M6 -idFrag 'Qc9d5s_3c_m6_action_KhJd' -diff 3 `
  -flop @('Qc','9d','5s') -turn 'Th' -river '3c' -boardKind 'Q_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('Kh','Jd') -handClass 'straight' -role 'nutted_value' -sdv 'nutted' `
  -blocker 'Hero holds a K and a J, halving villain''s KJ (chop) combos; QJ and JT two-pair-or-pair regions are also thinned. That trims some calls, but the nut hand still demands maximum pressure.' `
  -rec 'overbet' -reason 'polar_overbet_nut_river' -vBasis 'clear_direction' -stake 'overbet' -hrs 'overbet' -purpose 'thick_value' `
  -qtype 'action_choice' `
  -prompt 'Flop Qc 9d 5s; turn Th; river 3c. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Kh Jd?' `
  -choices @('check_back','bet_small','bet_big','overbet','mixed') `
  -best 'overbet' -acc @('bet_big') -bad @('bet_small','mixed') -crit @('check_back') `
  -short 'Turned nut straight, brick river: overbet the capped check-call range.' `
  -rivLogic 'The 3c is a total brick. Hero''s K-high straight (K-Q-J-T-9) made on the turn is still the pure nuts: no flush is possible and no higher straight exists because the board never brings the A-K connection needed.' `
  -rangeCtx 'BB''s two check-calls cap the range at one pair, two pair (QT, Q9, T9) and stubborn draws that missed. A range this capped against the literal nuts is the textbook polar overbet target: every made hand bluff-catches, nothing beats you.' `
  -handLogic 'The nuts win against 100% of villain''s continues. The only "cost" is the chop against KJ, which hero''s own K and J make rare.' `
  -sizLogic 'A pot-sized-plus bet is polar and villain knows it -- but two-pair and strong Qx still pay it off at a meaningful frequency after committing two streets. Any smaller size sells the best possible hand at a discount.' `
  -mistake 'Checking back the nuts "to be tricky" -- there is no later street; the river is the last chance to be paid and the check burns the entire bet for zero information gain.' `
  -takeaway 'Nut hand + capped range + brick river = overbet. The polar sizing is the whole point of having barrelled.' `
  -concepts @('sizing_polarity','river_value_threshold','nut_blocker_leverage')

# ---------- CAT B: THIN VALUE ----------

$S += New-M6 -idFrag 'Ac8h5d_7s_m6_action_AhJc' -diff 3 `
  -flop @('Ac','8h','5d') -turn '2c' -river '7s' -boardKind 'A_high' -stf 'rainbow' -stt 'two_tone' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'straight_complete' -bChange 'range_shift_minor' -runout 'dry_unpaired' `
  -hero @('Ah','Jc') -handClass 'top_pair' -role 'thin_value' -sdv 'medium' `
  -blocker 'No relevant removal: hero''s J touches nothing in villain''s continue range. The bet is justified by kicker domination, not blockers.' `
  -rec 'bet_small' -reason 'value_bet_thin_river' -vBasis 'clear_direction' -stake 'small' -hrs 'small' -purpose 'thin_value' `
  -qtype 'action_choice' `
  -prompt 'Flop Ac 8h 5d; turn 2c; river 7s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ah Jc?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'bet_small' -acc @('check_back') -bad @('bet_big','mixed') -crit @() `
  -short 'Top pair J-kicker: small value bet targets the wide dominated Ax region.' `
  -rivLogic 'The 7s completes only the deep-gutter straights (46, 96) that check-called the flop with four-out draws and then faced a turn barrel -- a thin, heavily filtered slice. The card leaves the Ax ladder untouched, and that ladder is where the money is.' `
  -rangeCtx 'BB''s check-call check-call range on A-8-5-2 is dense with dominated aces: AT, A9, A6s, A4s, A3s all reach the river and all beat a bluff, so they call one modest bet. The two-pair promotions (A8, A7, A5s, A2s) are real but partly check-raise earlier streets.' `
  -handLogic 'AJ beats AT, A9, A6s, A4s, A3s and every 8x. It loses to AQ/AK (which mostly bet-raise earlier or were 3-bet preflop), the promoted two-pairs, and the rare rivered 46s/96s. The dominated region is clearly wider.' `
  -sizLogic 'A third-pot bet is the merge price: dominated Ax calls it almost universally, while a big bet folds exactly the hands hero beats and keeps exactly the ones that beat him. Thin value lives or dies on sizing discipline.' `
  -mistake 'Blasting 75% "because top pair" -- against this calling range the big bet turns a value hand into a self-isolation play.' `
  -takeaway 'Thin value wants a wide net and a low price: bet small enough that every dominated ace pays.' `
  -concepts @('thin_value_discipline','merged_sizing')

$S += New-M6 -idFrag 'AdTd6c_8s_m6_action_AcQh' -diff 4 `
  -flop @('Ad','Td','6c') -turn '3h' -river '8s' -boardKind 'A_high' -stf 'two_tone' -stt 'two_tone' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'straight_complete' -bChange 'range_shift_minor' -runout 'dry_unpaired' `
  -hero @('Ac','Qh') -handClass 'top_pair' -role 'thin_value' -sdv 'medium' `
  -blocker 'Hero''s Q blocks QJ/QT floats that already folded; no meaningful removal of the calling range. The case rests on the kicker ladder.' `
  -rec 'bet_small' -reason 'value_bet_thin_river' -vBasis 'clear_direction' -stake 'small' -hrs 'small' -purpose 'thin_value' `
  -qtype 'action_choice' `
  -prompt 'Flop Ad Td 6c; turn 3h; river 8s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ac Qh?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'bet_small' -acc @('check_back') -bad @('bet_big','mixed') -crit @() `
  -short 'AQ on a runout that promoted a few two-pairs: still a small-bet value spot.' `
  -rivLogic 'The 8s brings 97 in for the 6-7-8-9-T straight, but 97 held a bare gutter on the flop and faced a turn barrel with nothing -- the line has filtered most of it out. The 8 also promotes A8s to two pair. Both arrivals are thin; the dominated-ace ladder below AQ is not.' `
  -rangeCtx 'Villain''s river check range keeps AJ, A9s, A7s and similar dominated aces plus Tx that refuses to fold. AT flopped two pair but check-raises the flop or turn often enough to be discounted here.' `
  -handLogic 'AQ beats AJ, A9s, A7s, A5s-type aces and all Tx. It loses to AK (partly 3-bet preflop), AT, the rivered A8s and the rare 97s. Combo for combo the dominated callers still outnumber the promoted hands.' `
  -sizLogic 'Small keeps AJ/A9s/Tx in the calling pool. Sizing up folds the dominated aces and isolates against exactly the promoted two-pair region -- the classic thin-value sizing error.' `
  -mistake 'Letting the 8 scare you into checking: the promoted combos are few and the ladder below you still pays a third of pot.' `
  -takeaway 'Rank the arrivals against the ladder you dominate; when the ladder is wider, keep betting -- just keep it small.' `
  -concepts @('thin_value_discipline','merged_sizing','river_value_threshold')

$S += New-M6 -idFrag 'Qd7s4c_2s_m6_reason_KcQc' -diff 3 `
  -flop @('Qd','7s','4c') -turn 'Jh' -river '2s' -boardKind 'Q_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('Kc','Qc') -handClass 'top_pair' -role 'thin_value' -sdv 'medium' `
  -blocker 'Hero''s Q reduces the QJ two-pair combos that beat him; the K blocks KQ (chop) and some KJ floats. Net removal slightly favors betting.' `
  -rec 'bet_small' -reason 'value_bet_thin_river' -vBasis 'clear_direction' -stake 'small' -hrs 'small' -purpose 'thin_value' `
  -qtype 'reason_choice' `
  -prompt 'Flop Qd 7s 4c; turn Jh; river 2s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. BTN holds Kc Qc and the best line is a small bet. WHY?' `
  -choices @('value_bet_thin_river','check_back_trap_risk_river','sizing_polar_big_river','polar_overbet_nut_river') `
  -best 'value_bet_thin_river' -acc @() -bad @('check_back_trap_risk_river','sizing_polar_big_river','polar_overbet_nut_river') -crit @() `
  -short 'KQ top pair: the Qx/Jx ladder calls one small bet; only QJ and slow-plays beat it.' `
  -rivLogic 'The 2s is a brick. The turn J is the card that mattered: it promoted QJ to two pair and gave JT/J9s a pair to check-call with. Hero''s KQ still sits above the entire one-pair field.' `
  -rangeCtx 'Villain check-called twice, holding Qx (QT, Q9s), now Jx (JT, J9s), and busted gutters like T9/AT that fold to any bet. Sets of 7s or 4s that never raised are rare.' `
  -handLogic 'KQ dominates QT, Q9s and beats every Jx. It loses to QJ, AQ (partly 3-bet preflop) and slow-played sets -- a short list against a wide dominated region.' `
  -sizLogic 'The dominated Qx/Jx hands call a third of pot and fold to most larger sizes; polar sizing here would fold out the entire region hero profits from while isolating against QJ exactly.' `
  -mistake 'Checking back because "QJ got there" -- surrendering value to a two-combo-class fear while QT/Q9s/JT are ready to pay a small bet.' `
  -takeaway 'Thin value is a counting exercise: dominated callers wide, beating hands narrow, price small.' `
  -concepts @('thin_value_discipline','merged_sizing')

$S += New-M6 -idFrag 'Ac7d4s_2c_m6_action_AhJh' -diff 5 `
  -flop @('Ac','7d','4s') -turn '9h' -river '2c' -boardKind 'A_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('Ah','Jh') -handClass 'top_pair' -role 'mixed_region' -sdv 'medium' `
  -blocker 'The J kicker beats the AT/A8s slice that calls a small bet; hero blocks none of the promoted two-pair combos (A9, A7, A4, A2), which is what keeps the spot at indifference rather than a pure bet.' `
  -rec 'mixed' -reason 'blocker_sidedness_mix_river' -vBasis 'mixed_nudge' -stake 'small' -hrs 'small' -purpose 'mixed_line' `
  -qtype 'action_choice' `
  -prompt 'Flop Ac 7d 4s; turn 9h; river 2c. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ah Jh?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'mixed' -acc @('bet_small','check_back') -bad @('bet_big') -crit @() `
  -short 'AJ at the exact thin-value boundary: bet small and check back are both fine.' `
  -rivLogic 'The 2c is a brick on the same runout where BB students learn to defend 88 against a small bet -- this is the bettor''s seat of that spot. The question is whether AJ still clears the thin-value bar, and the honest answer is: only just.' `
  -rangeCtx 'The dominated callers are AT, A8s, A6s, A5s and stubborn 9x. The promoted two-pairs are A9 (the big one -- A9o defends preflop and the turn 9 made it two pair), A7, A4s, A2s. Part of the A9 region check-raises the turn, which is what keeps the bet alive at all.' `
  -handLogic 'AJ beats AT/A8s/A6s/A5s/9x/88-type hands and loses to A9/A7/A4s/A2s plus AQ/AK remnants. The two regions are close enough in weight that neither pure line is an error.' `
  -sizLogic 'If betting, it must be small: the dominated slice calls a third of pot and nothing wider. Big sizing flips the spot into pure self-isolation and is the one real mistake available.' `
  -mistake 'Treating a genuine mix as a forced bet and then reaching for a big size "since we are betting anyway".' `
  -takeaway 'Some rivers are decided by one kicker step: AJ here is a coin-flip between small bet and check -- both are professional; big is not.' `
  -concepts @('mixed_indifference_ip','thin_value_discipline') `
  -mixedWl @('bet_small','check_back')

# ---------- CAT C: BLUFF SELECTION ----------

$S += New-M6 -idFrag 'KhTh4c_2s_m6_action_Ah5s' -diff 4 `
  -flop @('Kh','Th','4c') -turn '7h' -river '2s' -boardKind 'K_high' -stf 'two_tone' -stt 'monotone' -str 'monotone' `
  -tags @('wet') -rivCat 'brick' -bChange 'brick' -runout 'flush_turn' `
  -hero @('Ah','5s') -handClass 'ace_high' -role 'air_bluff_candidate' -sdv 'low' `
  -blocker 'The Ah is the key card: it removes every Ah-x nut flush from villain''s range, so the strongest hands that could pay or trap simply do not exist. Hero''s own missed nut-flush draw is also the most credible flush he can represent.' `
  -rec 'overbet' -reason 'blocker_bluff_river' -vBasis 'clear_direction' -stake 'overbet' -hrs 'overbet' -purpose 'bluff' `
  -qtype 'action_choice' `
  -prompt 'Flop Kh Th 4c; turn 7h; river 2s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ah 5s?' `
  -choices @('check_back','bet_small','bet_big','overbet','mixed') `
  -best 'overbet' -acc @('bet_big') -bad @('check_back','bet_small','mixed') -crit @() `
  -short 'Busted nut-flush draw with the Ah: the premier polar bluff on a three-heart board.' `
  -rivLogic 'The 2s changes nothing; the hand was decided on the 7h turn that completed the flush hero was drawing to. Having barrelled the turn with the nut draw, hero arrives with ace-high and the single best card to hold when bluffing: the Ah itself.' `
  -rangeCtx 'Villain''s check-call check-call range is pairs (Kx, Tx) plus modest flushes that chose not to raise, plus a few one-heart floats that missed. Against the pair-heavy core, ace-high wins almost nothing at showdown -- the check-back realizes close to zero.' `
  -handLogic 'A5 has no pair and beats only the rare busted Q-high float. The choice is between giving up a hand with near-zero showdown value and betting it as the top of the bluff ladder. The Ah makes it the top: villain can never hold the nut flush.' `
  -sizLogic 'The overbet tells the one story consistent with the whole line: hero barrelled a flush draw and got there. Flushes and sets bet huge here; pairs face an impossible price. Smaller sizes let Kx call profitably and waste the blocker.' `
  -mistake 'Checking back "because ace-high sometimes wins" -- against a range that check-called two streets, it almost never does; the hand''s value is its blocker, not its showdown weight.' `
  -takeaway 'Bluff the combos whose cards delete villain''s best calls: the Ah on a three-heart board is the classic.' `
  -concepts @('bluff_candidate_selection','nut_blocker_leverage','story_consistency')

$S += New-M6 -idFrag 'Qs9d4h_2s_m6_action_KcJc' -diff 4 `
  -flop @('Qs','9d','4h') -turn '8c' -river '2s' -boardKind 'Q_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('Kc','Jc') -handClass 'king_high' -role 'air_bluff_candidate' -sdv 'low' `
  -blocker 'The J halves villain''s JT combos -- the turned nut straight that check-calls to trap -- and the K removes KQ, the sturdiest top-pair bluff-catcher. Both of villain''s best continues are cut before the bet is even made.' `
  -rec 'bet_big' -reason 'blocker_bluff_river' -vBasis 'clear_direction' -stake 'large' -hrs 'large' -purpose 'bluff' `
  -qtype 'action_choice' `
  -prompt 'Flop Qs 9d 4h; turn 8c; river 2s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Kc Jc?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'bet_big' -acc @() -bad @('check_back','bet_small','mixed') -crit @() `
  -short 'Busted double-gutter with K and J blockers: bet big, both key blockers working.' `
  -rivLogic 'The 2s bricks a runout where the 8 completed JT''s straight (8-9-T-J-Q). Hero''s KJ missed its own gutter to the same T and holds king-high -- no pair, no showdown value against a range that called two streets.' `
  -rangeCtx 'Villain''s river checks are Qx pairs, 9x/8x pairs and the occasional slow-played JT straight. The straights and the best Qx (KQ) are exactly the combos hero''s own cards deplete.' `
  -handLogic 'King-high beats nothing that check-called twice. With zero showdown value the only question is bluff quality, and KJ ranks near the top: it blocks the trap (JT) and the stubbornest call (KQ) simultaneously.' `
  -sizLogic 'Big polar sizing pressures the one-pair core (Qx, 9x) that must decide whether hero has the straight he is representing. Small sizing offers those pairs a price they will always take.' `
  -mistake 'Giving up because the 8 "got there for villain" -- the same card is hero''s story, and hero''s blockers make villain''s version of it rare.' `
  -takeaway 'The best bluffs block the calls AND the traps: when both of your cards do work, apply maximum pressure.' `
  -concepts @('bluff_candidate_selection','nut_blocker_leverage','story_consistency')

$S += New-M6 -idFrag 'KhTh4c_2s_m6_reason_QhJs' -diff 4 `
  -flop @('Kh','Th','4c') -turn '7h' -river '2s' -boardKind 'K_high' -stf 'two_tone' -stt 'monotone' -str 'monotone' `
  -tags @('wet') -rivCat 'brick' -bChange 'brick' -runout 'flush_turn' `
  -hero @('Qh','Js') -handClass 'queen_high' -role 'air_bluff_candidate' -sdv 'low' `
  -blocker 'The Qh removes every Qh-x second-nut flush from villain''s range; combined with the busted open-ender there is no showdown value to protect.' `
  -rec 'bet_big' -reason 'blocker_bluff_river' -vBasis 'clear_direction' -stake 'large' -hrs 'large' -purpose 'bluff' `
  -qtype 'reason_choice' `
  -prompt 'Flop Kh Th 4c; turn 7h; river 2s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. BTN holds Qh Js and the best line is a big bet. WHY?' `
  -choices @('blocker_bluff_river','check_back_showdown_river','sizing_merge_small_river','value_bet_thin_river') `
  -best 'blocker_bluff_river' -acc @() -bad @('check_back_showdown_river','sizing_merge_small_river','value_bet_thin_river') -crit @() `
  -short 'Busted combo-draw holding the Qh: the second-nut-flush blocker makes the bluff.' `
  -rivLogic 'Hero barrelled the turn with the second-nut flush draw plus an open-ender and missed everything. Queen-high never wins against a range that check-called two streets on this board; the hand''s entire remaining equity is fold equity.' `
  -rangeCtx 'Villain holds Kx/Tx pairs, medium flushes that flatted the turn, and one-heart floats that missed. The Qh strips the QhXh flushes out of that middle band, tilting villain toward hands that struggle against a big polar bet.' `
  -handLogic 'No pair, no showdown value; the combo is either a bluff or dead money. Its blocker quality (second-nut flush card) puts it clearly on the bluff side of the give-up line.' `
  -sizLogic 'Flushes bet big on this river, so the bluff bets big; a small "cheap" bluff tells a story no value hand tells and gets called by every pair. Thin value is obviously not an available interpretation with queen-high.' `
  -mistake 'Checking with the idea that queen-high "might win": the check-call check-call range is pair-dense; it does not.' `
  -takeaway 'On flush-completed rivers, rank your bluffs by the flush cards you hold: nut blocker first, second-nut blocker close behind.' `
  -concepts @('bluff_candidate_selection','nut_blocker_leverage','story_consistency')

$S += New-M6 -idFrag '9h8h3d_2c_m6_action_7s6s' -diff 5 `
  -flop @('9h','8h','3d') -turn 'Kc' -river '2c' -boardKind 'K_high' -stf 'two_tone' -stt 'two_tone' -str 'two_tone' `
  -tags @('wet','connected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('7s','6s') -handClass 'seven_high' -role 'air_bluff_candidate' -sdv 'none' `
  -blocker 'Hero holds no heart: every busted heart draw villain check-folds with is still in the range, keeping the fold region at full width. Holding a heart here would block the very hands that fold -- the counterintuitive reason 76s with no heart outranks a random busted heart as a bluff.' `
  -rec 'bet_big' -reason 'unblock_fold_region_river' -vBasis 'clear_direction' -stake 'large' -hrs 'large' -purpose 'bluff' `
  -qtype 'action_choice' `
  -prompt 'Flop 9h 8h 3d; turn Kc; river 2c. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with 7s 6s?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'bet_big' -acc @() -bad @('check_back','bet_small','mixed') -crit @() `
  -short 'Busted open-ender with no heart: unblocking the folds is the hidden edge.' `
  -rivLogic 'The 2c misses every draw: hearts never came and the 9-8 straights stayed incomplete. Hero''s 76s open-ender is now seven-high -- literally unable to win at showdown against any hand that called two streets.' `
  -rangeCtx 'Villain''s river check range splits into made pairs (9x, 8x, some Kx that got there on the turn) and busted heart draws that check-call flop, peel some turns, and check-fold the river. The bluff profits exactly when that second group is as wide as possible.' `
  -handLogic 'Seven-high has zero showdown value, so checking realizes nothing. Betting wins whenever villain folds, and hero''s specific combo -- no heart, no 9, no 8 -- leaves villain''s folding hands untouched while barely touching the calls.' `
  -sizLogic 'Big sizing pressures the one-pair core into a genuine decision against the flush-and-straight story hero has told since the flop. Small invites every pair to call and turns the bluff into a donation.' `
  -mistake 'Picking bluffs by "I have a draw blocker" alone: holding a heart here would REMOVE villain''s folding hands -- the exact opposite of what a bluff wants.' `
  -takeaway 'A great bluff unblocks the folds. No-pair, no-blocker-of-folds combos like this are better candidates than they look.' `
  -concepts @('unblock_fold_region','bluff_candidate_selection')

# ---------- CAT D: GIVE-UP DISCIPLINE ----------

$S += New-M6 -idFrag 'JdTh3c_4d_m6_action_7c6c' -diff 3 `
  -flop @('Jd','Th','3c') -turn '8s' -river '4d' -boardKind 'J_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('wet','connected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('7c','6c') -handClass 'seven_high' -role 'air_give_up' -sdv 'none' `
  -blocker 'Hero''s 7 and 6 sit inside villain''s own busted-draw region (76, 65 folded or never arrived), thinning the folds, and the 7c also clips a share of the 97 turned straights. Trimming a value combo or two does not uncap the range -- Q9 straights, J8/T8 two pairs and the remaining 97 all still check to trap -- while the foldable region stays thin AND partly blocked. Net profile: still a bad bluff.' `
  -rec 'check_back' -reason 'give_up_no_equity_river' -vBasis 'clear_direction' -stake 'large' -hrs 'none' -purpose 'give_up' `
  -qtype 'action_choice' `
  -prompt 'Flop Jd Th 3c; turn 8s; river 4d. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with 7c 6c?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'check_back' -acc @() -bad @('bet_small','mixed') -crit @('bet_big') `
  -short 'Missed gutter on a straight-heavy runout: this is a give-up, not a hero bluff.' `
  -rivLogic 'The 4d is a brick, but the damage is structural: the turn 8 completed 9-7 and Q-9 straights that live comfortably inside BB''s check-call range, and BB''s two-pair region (J8, T8) grew on the same card. The river check from villain is not weakness here -- it is often a trap posture on a board that smashed the check-call line.' `
  -rangeCtx 'Villain''s range is uncapped: turned straights and two-pairs check to induce, while the folding region -- busted low gutters -- is thin and partly blocked by hero''s own cards.' `
  -handLogic 'Seven-high never wins at showdown, but that alone does not make a bluff right: betting needs folds, and this range does not fold enough. The combo also fails the blocker test in both directions.' `
  -sizLogic 'There is no good size for a bad bluff. The big barrel is the expensive version of the mistake, which is why it grades worst; the small stab is the cheaper version of the same leak.' `
  -mistake 'Auto-bluffing every missed draw "because we have no showdown value" -- give-up discipline is folding the bluff itself when the range and blockers say no.' `
  -takeaway 'Bluff selection has a reject pile. Uncapped villain range plus fold-region blockers means check and move on.' `
  -concepts @('give_up_discipline','unblock_fold_region')

$S += New-M6 -idFrag 'AhQd7s_3c_m6_action_KsTs' -diff 4 `
  -flop @('Ah','Qd','7s') -turn '7d' -river '3c' -boardKind 'A_high' -stf 'rainbow' -stt 'two_tone' -str 'two_tone' `
  -tags @('dry','paired') -rivCat 'brick' -bChange 'brick' -runout 'paired_board' `
  -hero @('Ks','Ts') -handClass 'king_high' -role 'air_give_up' -sdv 'none' `
  -blocker 'The K and T block KJ, JT and T9-type busted broadways -- on this dry runout those are most of what villain can fold. Blocking the fold region is the disqualifier.' `
  -rec 'check_back' -reason 'give_up_no_equity_river' -vBasis 'clear_direction' -stake 'large' -hrs 'none' -purpose 'give_up' `
  -qtype 'action_choice' `
  -prompt 'Flop Ah Qd 7s; turn 7d; river 3c. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ks Ts?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'check_back' -acc @() -bad @('bet_small','mixed') -crit @('bet_big') `
  -short 'Busted royal gutter into an Ax-heavy range: the folds are blocked, give up.' `
  -rivLogic 'The 3c is a blank on A-Q-7-7. Hero barrelled the gutter to the jack and missed; king-high loses to every pair in a range built almost entirely of Ax, Qx and the surviving 7x trips.' `
  -rangeCtx 'BB''s check-call check-call range on an A-Q-high board is top-heavy with aces that do not fold to a third barrel at any reasonable price -- they beat the missed-draw story too easily. The hands that CAN fold are busted KJ/JT/T9 broadway draws, and hero holds two of the four key cards himself.' `
  -handLogic 'No pair, no showdown value, no fold equity worth buying: the three reasons to put money in are all absent at once.' `
  -sizLogic 'A big bet into an uncapped, ace-rich range is the costliest available action -- that is the critical grade. The small stab fares little better; it just loses less.' `
  -mistake 'Talking yourself into "one more barrel" because you hold overcards to the middle card: overcards to a paired, ace-high board are not equity.' `
  -takeaway 'When your own cards shrink villain''s folding range, your bluff is pre-refuted. Check and keep the 20 BB.' `
  -concepts @('give_up_discipline','unblock_fold_region')

$S += New-M6 -idFrag 'Kd9h5s_6c_m6_reason_QhJh' -diff 4 `
  -flop @('Kd','9h','5s') -turn '6h' -river '6c' -boardKind 'K_high' -stf 'rainbow' -stt 'two_tone' -str 'two_tone' `
  -tags @('dry','paired') -rivCat 'board_pair' -bChange 'counterfeit' -runout 'paired_board' `
  -hero @('Qh','Jh') -handClass 'queen_high' -role 'air_give_up' -sdv 'none' `
  -blocker 'The Q and J block QT/JT busted gutters -- villain''s main folding hands on this runout -- while the completed 87 straight and the new 6x trips are untouched. Wrong-direction blockers again.' `
  -rec 'check_back' -reason 'give_up_no_equity_river' -vBasis 'clear_direction' -stake 'large' -hrs 'none' -purpose 'give_up' `
  -qtype 'reason_choice' `
  -prompt 'Flop Kd 9h 5s; turn 6h; river 6c. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. BTN holds Qh Jh and the best line is to check back. WHY?' `
  -choices @('give_up_no_equity_river','sizing_polar_big_river','blocker_bluff_river','check_back_showdown_river') `
  -best 'give_up_no_equity_river' -acc @() -bad @('sizing_polar_big_river','blocker_bluff_river','check_back_showdown_river') -crit @() `
  -short 'Busted flush draw plus gutter on a paired river: every reason to bluff fails.' `
  -rivLogic 'The 6c pairs the turn card. The 6h turn had completed 8-7''s straight (5-6-7-8-9) and handed 76s/86s a pair that just became trips; the river makes villain''s check range MORE trappy, not less. Hero''s combo missed the hearts and the ten.' `
  -rangeCtx 'Villain check-called twice and now holds Kx, 9x, turned straights and fresh trips. The folding region is busted QT/JT gutters and one-heart floats -- thin, and hero''s own Q and J block a chunk of it.' `
  -handLogic 'Queen-high wins no showdown that matters. The right-action-wrong-reason trap is "check because queen-high sometimes wins" -- it does not against this range; the check is right because the BLUFF is wrong: uncapped range, blocked folds, no credible story.' `
  -sizLogic 'The tempting line is a big scare-card barrel at the paired 6, but the 6 is villain''s card, not hero''s: it improves the check-call range and the story collapses.' `
  -mistake 'Bluffing at every paired river "because it looks scary" -- pairing the TURN card strengthens exactly the hands that check-called the turn.' `
  -takeaway 'Before bluffing, ask whose range the river card helped. If the answer is villain, give up.' `
  -concepts @('give_up_discipline','story_consistency','trap_risk_paired_river')

$S += New-M6 -idFrag 'Th9d3c_7d_m6_action_KdQd' -diff 5 `
  -flop @('Th','9d','3c') -turn 'As' -river '7d' -boardKind 'A_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('wet','connected') -rivCat 'straight_complete' -bChange 'range_shift_major' -runout 'dry_unpaired' `
  -hero @('Kd','Qd') -handClass 'king_high' -role 'air_give_up' -sdv 'none' `
  -blocker 'The K and Q block QJ and KJ -- the busted gutters villain folds -- while the 8-6 straight the river completed and the Ax region are unblocked. The overbet temptation runs into the worst possible removal profile.' `
  -rec 'check_back' -reason 'story_consistency_bluff_river' -vBasis 'clear_direction' -stake 'overbet' -hrs 'none' -purpose 'give_up' `
  -qtype 'action_choice' `
  -prompt 'Flop Th 9d 3c; turn As; river 7d. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Kd Qd?' `
  -choices @('check_back','bet_small','bet_big','overbet','mixed') `
  -best 'check_back' -acc @() -bad @('bet_small','bet_big','mixed') -crit @('overbet') `
  -short 'The polar overbet story fails on every axis: improved range, blocked folds, no rep.' `
  -rivLogic 'The 7d completes 8-6 (6-7-8-9-T) inside villain''s peel range and fills the board''s low connection. Meanwhile the turn A -- the card hero leaned on to barrel -- made top pair for the Ax hands that called, so the range checking to hero on the river is stronger than it was a street earlier.' `
  -rangeCtx 'Villain holds Ax top pairs that called the turn on purpose, Tx/9x that refuse to fold, and the rivered straight. The folding region is busted QJ/KJ/AQ-without-a-pair -- and hero blocks the first two.' `
  -handLogic 'King-high, no pair, no showdown value. The overbet "rep AK/AA" temptation fails the story test: hands that strong mostly bet this river themselves earlier in the range tree, and villain''s actual calling region (Ax) is precisely the one that never folds to the rep.' `
  -sizLogic 'The overbet is the punished choice at 30 BB of stake: maximum money behind a story the calling range does not believe. Smaller bluffs share the flaw at lower cost.' `
  -mistake 'Escalating the bluff size when the earlier barrels did not work -- the range that kept calling is telling you it connected.' `
  -takeaway 'A bluff needs a believable story AND an audience that can fold. Missing both, the only professional line is the free showdown you cannot win -- check and lose the minimum.' `
  -concepts @('give_up_discipline','story_consistency','unblock_fold_region')

# ---------- CAT E: CHECK-BACK SHOWDOWN ----------

$S += New-M6 -idFrag 'Qh8s3d_4s_m6_action_AhJh' -diff 3 `
  -flop @('Qh','8s','3d') -turn 'Kc' -river '4s' -boardKind 'K_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('Ah','Jh') -handClass 'ace_high' -role 'showdown_value' -sdv 'medium' `
  -blocker 'Hero blocks AJ-type floats villain rarely has and none of the pairs; removal is irrelevant next to the showdown math: ace-high beats every busted draw and loses to every pair.' `
  -rec 'check_back' -reason 'check_back_showdown_river' -vBasis 'clear_direction' -stake 'large' -hrs 'none' -purpose 'showdown_check' `
  -qtype 'action_choice' `
  -prompt 'Flop Qh 8s 3d; turn Kc; river 4s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ah Jh?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'check_back' -acc @() -bad @('bet_small','mixed') -crit @('bet_big') `
  -short 'Ace-high with real showdown value: betting turns a winner into a loser.' `
  -rivLogic 'The 4s is a brick after hero barrelled the royal gutter on the K turn and missed. What remains is ace-high -- and on this runout that is a hand, not air: villain''s busted JT/T9 gutters and missed backdoors all lose to it at showdown.' `
  -rangeCtx 'Villain''s check-call check-call range is Qx and 8x pairs plus those busted draws. The pairs never fold to one more bet at a workable price, and the draws hero beats fold to any bet -- so a bluff folds out only the hands hero already beats.' `
  -handLogic 'This is the defining showdown-value shape: beat all the folds, lose to all the calls. Betting any amount converts a hand that wins the busted-draw showdowns into a bluff that isolates against pairs.' `
  -sizLogic 'No size fixes the shape. The big barrel is the expensive version -- 20 BB behind a bet that only better hands call -- hence the critical grade.' `
  -mistake 'Counting ace-high as "no showdown value" and auto-barrelling: against capped, draw-heavy check-call ranges, ace-high IS the bluff-catcher-beater.' `
  -takeaway 'Before turning a missed draw into a bluff, ask what you beat at showdown. If the answer is "everything that folds", check.' `
  -concepts @('checkback_showdown','give_up_discipline')

$S += New-M6 -idFrag 'Kd7s3c_7d_m6_action_AcQc' -diff 4 `
  -flop @('Kd','7s','3c') -turn 'Qh' -river '7d' -boardKind 'K_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','paired') -rivCat 'board_pair' -bChange 'counterfeit' -runout 'paired_board' `
  -hero @('Ac','Qc') -handClass 'second_pair' -role 'showdown_value' -sdv 'medium' `
  -blocker 'The A blocks AK, the strongest Kx that pays nothing anyway; the Q blocks QJ/QT, the exact hands a thin bet would want to be called by. The removal argues against betting.' `
  -rec 'check_back' -reason 'check_back_trap_risk_river' -vBasis 'clear_direction' -stake 'small' -hrs 'none' -purpose 'showdown_check' `
  -qtype 'action_choice' `
  -prompt 'Flop Kd 7s 3c; turn Qh; river 7d. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ac Qc?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'check_back' -acc @() -bad @('bet_small','bet_big','mixed') -crit @() `
  -short 'Second pair on the paired river: the thin bet has no customers left.' `
  -rivLogic 'The 7d pairs the board -- the same runout BB students face from the other seat against a small bet. From the bettor''s chair the lesson inverts: the 7 promotes villain''s 7x mid-pairs to trips, and the thin-value bet AQ wanted to make just lost its market.' `
  -rangeCtx 'Villain''s check-call check-call range is Kx (never folding, always beating AQ), 7x that just made trips, and Qx worse than hero''s -- but hero''s own Q blocks most of that last region. What is left to call a bet and lose? Almost nothing.' `
  -handLogic 'AQ still beats the busted gutters (65-type) and the weaker Qx at showdown; checking realizes that equity for free. Betting collects from a region hero mostly blocks while paying off Kx and the new trips.' `
  -sizLogic 'The small bet is the designated temptation here (stake basis: small): it looks like a value bet but the callers-worse are blocked and the callers-better multiplied. Bigger sizes only deepen the error.' `
  -mistake 'Betting "thin value" by hand strength alone: value is defined by who calls, and the paired river rewrote that list.' `
  -takeaway 'A paired river can delete your thin-value market. Recount the callers before you bet -- and when they are gone, take the showdown.' `
  -concepts @('trap_risk_paired_river','checkback_showdown','thin_value_discipline')

$S += New-M6 -idFrag 'Qh8s3d_4s_m6_reason_AsTs' -diff 3 `
  -flop @('Qh','8s','3d') -turn 'Kc' -river '4s' -boardKind 'K_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('As','Ts') -handClass 'ace_high' -role 'showdown_value' -sdv 'medium' `
  -blocker 'The T blocks a share of the JT/T9 busted draws hero beats at showdown -- mildly unwelcome -- but the core logic is unchanged: ace-high beats the folds and loses to the calls.' `
  -rec 'check_back' -reason 'check_back_showdown_river' -vBasis 'clear_direction' -stake 'large' -hrs 'none' -purpose 'showdown_check' `
  -qtype 'reason_choice' `
  -prompt 'Flop Qh 8s 3d; turn Kc; river 4s. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. BTN holds As Ts and the best line is to check back. WHY?' `
  -choices @('check_back_showdown_river','value_bet_thin_river','sizing_polar_big_river','check_back_trap_risk_river') `
  -best 'check_back_showdown_river' -acc @() -bad @('value_bet_thin_river','sizing_polar_big_river','check_back_trap_risk_river') -crit @() `
  -short 'Ace-high beats every hand that would fold: the check realizes real equity.' `
  -rivLogic 'Hero barrelled the gutter to the jack on the K turn and bricked. Ace-high remains, and against villain''s check-call check-call range -- Qx, 8x, busted JT/T9 -- it wins exactly the showdowns against the busted draws.' `
  -rangeCtx 'The "thin value" story fails on contact: the hands below ace-high that might call are 8x -- and 8x is a PAIR; it beats ace-high. There is no worse hand that calls, so there is no value bet, at any size.' `
  -handLogic 'Beats all busted draws (they fold to any bet -- so betting wins nothing extra from them); loses to all pairs (they call -- so betting loses extra to them). The check dominates.' `
  -sizLogic 'Sizing is irrelevant to a structurally wrong bet; the polar option merely maximizes the damage. The trap-risk reason is the right ACTION with the wrong logic -- ace-high fears no check-raise; it fears the call.' `
  -mistake 'Believing "8x calls and we beat it": 8x is a pair of eights; ace-high does not beat it. Verify the ladder before labelling a bet thin value.' `
  -takeaway 'No worse hand calls, no better hand folds: the two-question test that ends most river mistakes before they happen.' `
  -concepts @('checkback_showdown','river_value_threshold')

$S += New-M6 -idFrag 'Qd7c4h_2d_m6_action_AhTd' -diff 5 `
  -flop @('Qd','7c','4h') -turn 'Th' -river '2d' -boardKind 'Q_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('Ah','Td') -handClass 'second_pair' -role 'mixed_region' -sdv 'medium' `
  -blocker 'With the Qd and Th on the board, villain''s QT starts at 3x3 = nine combos; hero''s Td cuts it to 3x2 = six. QT is the top-pair hand that calls a small bet and wins, so trimming a third of it is the nudge that keeps the thin bet alive alongside the check.' `
  -rec 'mixed' -reason 'blocker_sidedness_mix_river' -vBasis 'mixed_nudge' -stake 'small' -hrs 'small' -purpose 'mixed_line' `
  -qtype 'action_choice' `
  -prompt 'Flop Qd 7c 4h; turn Th; river 2d. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ah Td?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'mixed' -acc @('bet_small','check_back') -bad @('bet_big') -crit @() `
  -short 'Second pair top kicker at the boundary: small bet and check split the combo.' `
  -rivLogic 'The 2d is a brick on a runout with no straights and no flush. Hero''s pair of tens with the ace kicker sits exactly at the line between thin value and showdown-taking.' `
  -rangeCtx 'The callers-worse are T9s/T8s (same pair, worse kicker) and stubborn 7x; the callers-better are Qx and the JJ-type overpairs-to-the-ten that check-called twice. The two pools are close in weight, and hero''s own T thins the QT slice of the better pool.' `
  -handLogic 'AT beats the busted gutters and the worse Tx; it loses to any Qx and JJ. Neither betting small nor checking is an error -- the combo genuinely splits.' `
  -sizLogic 'If betting, small only: the worse-Tx-and-7x pool calls a third of pot and vanishes against anything larger, while Qx calls everything. Big sizing is the one clearly losing line.' `
  -mistake 'Forcing a pure answer where the ranges do not give one -- and especially "betting bigger to find out", which pays the better hands to tell you.' `
  -takeaway 'When callers-worse and callers-better balance, both small-bet and check are professional; note the blocker that tips you and move on.' `
  -concepts @('mixed_indifference_ip','thin_value_discipline','checkback_showdown') `
  -mixedWl @('bet_small','check_back')

# ---------- CAT F: SIZING POLARITY ----------

$S += New-M6 -idFrag '8d5c2h_Qh_m6_action_8s8h' -diff 3 `
  -flop @('8d','5c','2h') -turn 'Kc' -river 'Qh' -boardKind 'K_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'overcard' -bChange 'range_shift_minor' -runout 'dry_unpaired' `
  -hero @('8s','8h') -handClass 'set' -role 'nutted_value' -sdv 'nutted' `
  -blocker 'Hero''s two 8s remove the 8x hands villain would call with lightest, tilting the calling range toward Kx/Qx broadways -- which argues for the bigger size, not the smaller one.' `
  -rec 'bet_big' -reason 'sizing_polar_big_river' -vBasis 'clear_direction' -stake 'large' -hrs 'large' -purpose 'thick_value' `
  -qtype 'action_choice' `
  -prompt 'Flop 8d 5c 2h; turn Kc; river Qh. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with 8s 8h?' `
  -choices @('check_back','bet_small','bet_big','overbet','mixed') `
  -best 'bet_big' -acc @('overbet') -bad @('bet_small','mixed') -crit @('check_back') `
  -short 'Top set, and the runout delivered customers: the small bet is the leak here.' `
  -rivLogic 'The K turn and Q river look scary but they are hero''s gift: villain''s check-call range was full of overcard broadways (KJ, KT, QJ, QT, KQ) that just made pairs and two pair. No straight completes (the J-T bridge never arrives) and no flush exists.' `
  -rangeCtx 'Villain now holds Kx and Qx pairs plus KQ two pair -- all genuine bluff-catchers against hero''s line, all beaten by the flopped set. Nothing beats hero: KK and QQ three-bet preflop in the baseline, no straight or flush is possible, and the board never pairs -- top set is the effective nuts with zero combos above it, which is why checking it back grades as a full punt.' `
  -handLogic 'Top set beats every pair and every two pair on the final board. The value question is not whether to bet -- it is how much the new Kx/Qx pairs will pay.' `
  -sizLogic 'They pay big: hands that just paired on the last two cards after calling two streets do not fold to 75%. The small bet -- fine on some rivers -- is THE mistake on this one: it charges the richest calling range of the whole tree a bottom-tier price. Overbet is a reasonable polar alternative.' `
  -mistake 'Reflex-sizing down "because the board ran out high" -- the high cards are what built villain''s calling range.' `
  -takeaway 'Size to the range the runout created, not to the flop you remember: when the scare cards hit VILLAIN''s range, bet bigger.' `
  -concepts @('sizing_polarity','river_value_threshold')

$S += New-M6 -idFrag 'Qs8h3c_9h_m6_reason_AdQd' -diff 4 `
  -flop @('Qs','8h','3c') -turn '2d' -river '9h' -boardKind 'Q_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'straight_complete' -bChange 'range_shift_minor' -runout 'dry_unpaired' `
  -hero @('Ad','Qd') -handClass 'top_pair' -role 'thin_value' -sdv 'high' `
  -blocker 'Hero''s Q blocks QJ/QT -- unfortunately those are the CALLERS a value bet wants, which is exactly why the size must stay small enough to keep the rest of the pool in.' `
  -rec 'bet_small' -reason 'sizing_merge_small_river' -vBasis 'clear_direction' -stake 'small' -hrs 'small' -purpose 'thin_value' `
  -qtype 'reason_choice' `
  -prompt 'Flop Qs 8h 3c; turn 2d; river 9h. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. BTN holds Ad Qd and the best line is a small bet. WHY?' `
  -choices @('sizing_merge_small_river','polar_overbet_nut_river','check_back_trap_risk_river','sizing_polar_big_river') `
  -best 'sizing_merge_small_river' -acc @() -bad @('polar_overbet_nut_river','check_back_trap_risk_river','sizing_polar_big_river') -crit @() `
  -short 'TPTK after the 9 completes JT: merge small, do not polarize into the improved region.' `
  -rivLogic 'The 9h completes 8-9-T-J-Q for JT (which peeled a gutter on the flop) and promotes Q9 to two pair. AQ is still the best one-pair hand and still beats the Qx ladder -- but the hands that improved are precisely the ones a big bet isolates against.' `
  -rangeCtx 'Villain''s river checks contain QJ/QT (call a modest bet, lose), Q9/JT (call anything, win), 8x and busted gutters (fold to everything). The composition screams merge: there is a real but price-sensitive value market.' `
  -handLogic 'AQ beats QJ, QT and the stubborn 8x that peels a small bet; it loses to Q9, JT and slow-played sets. Small keeps the first group in; any polar size trades them away for the second.' `
  -sizLogic 'Merged small (~33%) is the only size whose calling pool is majority-worse. "Overbet -- TPTK is the nuts here" fails (JT/Q9/sets exist); "check -- the 9 kills all value" over-corrects (QJ/QT still pay); "bet big to charge draws" is a category error -- there are no draws on a river.' `
  -mistake 'Polar-sizing a merged hand: the bigger the bet, the purer the calling range that beats you.' `
  -takeaway 'After a connecting river, downshift: the merge price keeps the dominated callers your hand was built to beat.' `
  -concepts @('merged_sizing','sizing_polarity','thin_value_discipline')

$S += New-M6 -idFrag 'AhJd6s_7h_m6_action_AsKs' -diff 5 `
  -flop @('Ah','Jd','6s') -turn '2c' -river '7h' -boardKind 'A_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','disconnected') -rivCat 'brick' -bChange 'brick' -runout 'dry_unpaired' `
  -hero @('As','Ks') -handClass 'top_pair' -role 'strong_value' -sdv 'high' `
  -blocker 'Hero''s A thins the AJ two-pair combos that beat him, and the K blocks KJ -- a main caller of the SMALL size. Removal points toward the big bet targeting the Ax pool: the nudge in the mix.' `
  -rec 'mixed' -reason 'blocker_sidedness_mix_river' -vBasis 'mixed_nudge' -stake 'large' -hrs 'large' -purpose 'mixed_line' `
  -qtype 'action_choice' `
  -prompt 'Flop Ah Jd 6s; turn 2c; river 7h. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with As Ks?' `
  -choices @('check_back','bet_small','bet_big','mixed') `
  -best 'mixed' -acc @('bet_big','bet_small') -bad @('check_back') -crit @() `
  -short 'AK top-pair-top-kicker: big and small both print -- the size is the real decision.' `
  -rivLogic 'The 7h is a brick: no straight ever completes on A-J-6-2-7 and no flush arrives. AK remains the best unpaired-board hand in the tree, clearly worth a third barrel -- the only question is which price.' `
  -rangeCtx 'Two calling pools coexist: dominated Ax (AQ remnants, AT, A9s...) that pays the big size after committing two streets, and Jx (KJ, QJ, JT) that pays only the small one. The promoted two-pairs (A7s, A6s, A2s, AJ) are real but thin, and hero blocks AJ himself.' `
  -handLogic 'AK beats every one-pair hand in both pools; it loses to the short two-pair list and slow-played sets. Both bet sizes show clear profit against their pool -- a genuine size-mix, not a bet-or-check question.' `
  -sizLogic 'Big targets the Ax pool; small farms the Jx pool. Hero''s K-blocker (fewer KJ calls of the small size) plus the unblocked AT/A9s tilt the split toward big -- the mix''s primary. Checking the best kicker on a brick is the one losing line.' `
  -mistake 'Auto-checking TPTK because "two pair is possible" -- possibility is not weight; the dominated pools are far wider.' `
  -takeaway 'With hands that beat both calling pools, the mix is between prices, never between bet and check.' `
  -concepts @('mixed_indifference_ip','sizing_polarity','river_value_threshold') `
  -mixedWl @('bet_big','bet_small')

$S += New-M6 -idFrag 'Th7d2s_2h_m6_action_TsTc' -diff 4 `
  -flop @('Th','7d','2s') -turn 'Ac' -river '2h' -boardKind 'A_high' -stf 'rainbow' -stt 'rainbow' -str 'two_tone' `
  -tags @('dry','paired') -rivCat 'board_pair' -bChange 'range_shift_minor' -runout 'paired_board' `
  -hero @('Ts','Tc') -handClass 'full_house' -role 'strong_value' -sdv 'high' `
  -blocker 'Hero''s two Ts erase villain''s Tx bluff-catchers -- the natural callers of a merely big bet -- concentrating the paying range on Ax top pair. That removal is the nudge toward the overbet side of the mix.' `
  -rec 'mixed' -reason 'polar_overbet_nut_river' -vBasis 'mixed_nudge' -stake 'overbet' -hrs 'overbet' -purpose 'thick_value' `
  -qtype 'action_choice' `
  -prompt 'Flop Th 7d 2s; turn Ac; river 2h. BTN c-bet flop, BB called; BTN barrelled turn, BB called; BB now checks the river. What is BTN best action with Ts Tc?' `
  -choices @('check_back','bet_small','bet_big','overbet','mixed') `
  -best 'mixed' -acc @('overbet','bet_big') -bad @('bet_small','check_back') -crit @() `
  -short 'Tens-full on T-7-2-A-2: overbet and big bet split; the Ax pool never folds.' `
  -rivLogic 'The 2h fills hero to tens full (T-T-T-2-2). Only quad deuces beats it (AA three-bets preflop) -- a single check-call check-call combo -- so hero holds the effective nuts on a river where villain''s biggest region is Ax top pair made on the turn.' `
  -rangeCtx 'Villain called the turn A barrel with Ax on purpose; those hands upgrade themselves to "must bluff-catch" against a polar river. The 7x and A7/A2 two-pair-and-boat-adjacent hands also continue. Nothing in the range can fold an ace comfortably.' `
  -handLogic 'The boat beats every Ax, every 7x, the counterfeit two pairs, and the smaller boats (A2, 72s-type, 77 is beaten too as sevens-full-of-twos ranks below tens-full). Quads-2 alone wins -- one combo that played check-call twice.' `
  -sizLogic 'Overbet and big both profit hugely; the mix leans overbet because hero''s own Ts delete the Tx region that would call BIG but fold OVERBET -- what remains (Ax) pays either price. Anything smaller than big is a gift; checking the near-nuts is the punished passive line.' `
  -mistake 'Sizing to your fear of quads -- one combo -- instead of to the Ax region that constitutes the range.' `
  -takeaway 'When your blockers remove the price-sensitive callers, the remaining range sets the price: go polar with the near-nuts.' `
  -concepts @('sizing_polarity','nut_blocker_leverage','mixed_indifference_ip') `
  -mixedWl @('overbet','bet_big')

# ---------- emit ----------

$doc = [ordered]@{
  description = 'Module 6 (River Betting IP, pf_river_value_ip) v4.5.1 seed batch -- 24 scenarios, PLANNING-ONLY. Owner G4 rulings encoded: verdictBasis, stakeBasis PIN, mixed whitelist-with-migration, overbet spread. Production data untouched.'
  generatedBy = 'tools/build-m6-seeds-v4.5.1.ps1'
  seedVersion = 'v4.5.1'
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
