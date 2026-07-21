# build-m4-arrival-reworks-v4.6.1.ps1 -- M4 Arrival reworks: V1 PILOT ONLY.
# PLANNING-ONLY: writes docs/specs/postflop-v4.6.1-m4-rework-seeds.json.
# Production postflop_scenarios.json is NEVER touched by this script.
# Remaining reworks are authored here AFTER batches 2-3 complete (owner
# knob (d)); the pilot proves the pipeline at seed-review strictness.
#
# V1: pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_AcKh_v432 (AKo = ruled
# non-member) -> hero swap to AhJh (AJs = member), preserving board,
# turnCategory, actionReason (value_check_raise_turn) and difficulty per the
# rework policy. Owner paste-gate conditions baked:
#  (i)  hearts honesty: Ah is a RANK blocker only -- with just the 4h on
#       board no flush is possible by the river; no suit equity is claimed.
#  (ii) full per-street arrival re-derive for AJ on the entire line
#       (preflop chart flat; flop call = the street's best for TPGK).
# Also fixes the row's ARR.P defect: the original graded fold and
# check_raise_big in BOTH bad and critical (overlap); the rework ships a
# clean partition, with fold/CR-big at bad per the enumerated-critical
# taxonomy (v4.4.1B demotion + the A4/F1 discipline: critical is reserved
# for fold-nuts / call-zero-SDV / raise-into-crush / check-back-nuts).

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$outPath = Join-Path $root 'docs\specs\postflop-v4.6.1-m4-rework-seeds.json'

$v1 = [ordered]@{
  id = 'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_AhJh_v461'
  replaces = 'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_AcKh_v432'
  reworkClass = 'REWORK-(a)'
  version = 'v4.6.1'
  game = 'NLH_MTT'
  module = 'pf_turn_barrel_oop_def'
  moduleName = 'Facing Turn Barrel OOP'
  street = 'turn'
  schemaVersion = '1.2.0'
  actionHistory = @()
  scoring = [ordered]@{ best = 1; acceptable = 0.5; bad = 0; critical = 0 }
  difficulty = 3
  spot = [ordered]@{
    format='NLH_MTT'; stackDepth='100BB'; potType='SRP'
    preflopAction='BTN open 2.5x, BB call'
    flopAction='BTN cbet small (~33%), BB call'
    turnAction='BTN barrel'
    street='turn'; heroPosition='BB'; villainPosition='BTN'
    heroRole='flop_check_caller_oop'; villainRole='turn_barreler_ip'
  }
  board = [ordered]@{
    flopCards=@('Ac','7d','2s'); turnCard='4h'
    cards=@('Ac','7d','2s','4h')
    boardKind='A_high'; suitTextureFlop='rainbow'; suitTextureTurn='rainbow'
    textureTags=@('dry','disconnected'); highCardClass='A_high'
    turnCategory='brick'; boardChange='brick'; equityShift='neutral'
    drawCompletion='none'; pairStatusChange='no_change'
  }
  heroHand = @('Ah','Jh')
  handClass = 'top_pair_good_kicker'
  heroHandRole = 'strong_value'
  drawCategory = 'none'
  showdownValue = 'high'
  blockerNote = 'TPGK holding the ace of hearts. The Ah works as a RANK blocker only: it thins villain AA and the Ah-x aces. The hearts themselves are decoration -- with just the 4h on board, no flush is possible by the river, so no suit equity is claimed.'
  arrivalDerivation = 'Preflop: AJs is a chart flat -- a member, outside the locked 3-bet set {QQ+, AK, AQs, part A2s-A5s} (banked baseline, audit-plan sec 2). Flop Ac 7d 2s vs a small c-bet: top pair good kicker CALLS as the street best line under M3 logic (raising is thin, folding absurd) -- the continue grades best, not merely acceptable, and no check-raise node was missed. The turn node is this scenario. Arrival legitimate at every leg.'
  recommendedAction = 'check_raise_small'
  actionReason = 'value_check_raise_turn'
  question = [ordered]@{
    qtype = 'action_choice'
    prompt = 'Flop Ac 7d 2s; turn 4h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Ah Jh?'
    choices = @('fold','call','check_raise_small','check_raise_big','mixed')
  }
  answer = [ordered]@{
    best = 'check_raise_small'
    acceptable = @('call')
    bad = @('fold','mixed','check_raise_big')
    critical = @()
  }
  explanation = [ordered]@{
    short = 'TPGK with the A-blocker on an A-high brick turn -- a thin value check-raise.'
    turnLogic = 'The 4h is a brick that changes no ranges. Villain barrels A-7-2 wide: weaker aces, mid pairs, and air that keeps firing. The small check-raise charges AT/A9/A8-type call-downs and folds the air out -- thinner than the same raise with AK, which is precisely the lesson: the dominated-ace pool is wide enough that the raise still prints, and the A-blocker trims the top of what can punish it.'
    rangeContext = 'BB arrives here legitimately at every street: AJs flats the open by the chart, and top pair good kicker calls the small c-bet as the flop best line -- no earlier node was misplayed and no check-raise was missed. On the turn brick, hero range is well ahead of a wide barreling range on A-high dry boards.'
    handLogic = 'AhJh beats AT, A9, A8 and every weaker ace, all underpairs, and all air. It loses to AK/AQ, the rare turned two-pair (A7, A4, A2), and sets 77/44/22. The K-kicker cushion of an AK hand is gone -- which is exactly what keeps this raise thin rather than automatic, and why the J-kicker version is the better teaching hand for the spot.'
    sizingLogic = 'Small keeps the dominated aces in while risking the minimum against the rare two-pair and set region; the big raise bloats the pot against exactly that region; calling is an acceptable pot-controlled line that underpays against villain call-down aces. Folding top pair good kicker to one barrel on a brick surrenders far too much, but it is an over-fold, not a catastrophe -- the critical list stays reserved for the enumerated punt classes.'
    commonMistake = 'Auto-calling every top pair good kicker to keep the pot small: against a wide barreling range the small raise prints against the dominated aces that call down.'
    takeaway = 'On dry A-high brick turns, top pair good kicker with the ace blocker upgrades to a small value check-raise.'
  }
  conceptTags = @('turn_check_raise_value','turn_blocker_pressure','second_barrel_defense')
  sourceConfidence = 'expert_judgment'
  auditStatus = 'review_pending'
  reviewStatus = 'v4.6.1_seed'
}

# ============================================================================
# GATE-1 BATCH (owner plan approval 2026-07-21): 26 standard rows -- 17 leg-(a)
# + 1 leg-(b) + 7 leg-(c) + #18 content re-derive. Clone-from-production keeps
# board/spot/scoring/difficulty/actionReason byte-faithful (RW.R03 domain);
# authored fields overwrite. bad[] is MECHANICALLY filled as the partition
# remainder so RW.R06 exactness holds by construction.
# ============================================================================
$prodAll = ([System.IO.File]::ReadAllText((Join-Path $root 'postflop\postflop_scenarios.json'), [System.Text.UTF8Encoding]::new($false)) | ConvertFrom-Json).scenarios
$rows = New-Object System.Collections.ArrayList
$PFX = 'pf_btn_v_bb_srp_100bb_turn_'

function NewRework($o) {
  $old = $prodAll | Where-Object { $_.id -eq ($PFX + $o.replaces) } | Select-Object -First 1
  if (-not $old) { throw ('replaced row not found: ' + $o.replaces) }
  $c = $old | ConvertTo-Json -Depth 12 | ConvertFrom-Json
  $c.id = $PFX + $o.id
  $c.version = 'v4.6.1'
  $c.schemaVersion = '1.2.0'
  $c.heroHand = @($o.hero)
  $c.handClass = $o.cls
  $c.heroHandRole = $o.role
  $c.drawCategory = $o.draw
  $c.showdownValue = $o.sdv
  $c.blockerNote = $o.blocker
  $c.recommendedAction = $o.rec
  $c.question.prompt = $o.prompt
  $c.answer.best = $o.best
  $c.answer.acceptable = @($o.acc)
  $c.answer.critical = @($o.crit)
  $c.answer.bad = @(@($c.question.choices) | Where-Object { $_ -ne $o.best -and (@($o.acc) -notcontains $_) -and (@($o.crit) -notcontains $_) })
  if ($o.board) { $c.board = $o.board }
  if ($o.diff) { $c.difficulty = $o.diff }
  foreach ($k in $o.expl.Keys) { $c.explanation.$k = $o.expl[$k] }
  $c.auditStatus = 'review_pending'
  $c.reviewStatus = 'v4.6.1_seed'
  $c | Add-Member -NotePropertyName replaces -NotePropertyValue ($PFX + $o.replaces) -Force
  $c | Add-Member -NotePropertyName reworkClass -NotePropertyValue $o.rw -Force
  $c | Add-Member -NotePropertyName arrivalDerivation -NotePropertyValue $o.arrival -Force
  [void]$script:rows.Add($c)
}

# --- R01 b1-2: AA -> JJ | reason | mixed_indifference | 7s5d3h/4c | WL row ---
NewRework @{
  replaces = '7s5d3h_4c_m4_reason_AhAd_v432'; id = '7s5d3h_4c_m4_reason_JhJd_v461'; rw = 'REWORK-(a)'
  hero = @('Jh','Jd'); cls = 'overpair'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'mixed'; best = 'mixed_indifference_turn'; acc = @(); crit = @()
  prompt = 'Flop 7s 5d 3h; turn 4c. BB faces the BTN turn barrel with Jh Jd. What is the primary reason behind the correct line?'
  blocker = 'Jh Jd holds no six and no board pair card -- zero removal against the completed straights, so the pair plays on raw showdown value. No suit story on the four-suit runout.'
  arrival = 'Preflop: JJ is a chart flat from the BB vs the 2.5x open -- a member outside the locked 3-bet set. Flop 7s 5d 3h vs the small c-bet: the overpair calls as the clear best line; raising folds out everything worse and opens a shove node OOP, and no check-raise was missed on the static low flop. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'The 4c completes every low straight and turns the big overpair into a mixed defend, not a value hand.'
    turnLogic = 'Any six now plays 3-4-5-6-7 off the board, and 75/53/44-type two pair plus sets were always live. Villain barrels that region and keeps barreling overcard air; JJ beats exactly the air and the rare underpair value.'
    rangeContext = 'BB reaches the turn with pairs, sevens, and give-ups; JJ sits near the top yet still catches rather than values on this runout. BTN polarizes hard once the straight card lands.'
    handLogic = 'JJ loses to every six, every set, and the low two pair, while beating all unpaired barrels. That balance sheet is the definition of indifference: the call and the fold have nearly identical EV.'
    sizingLogic = 'Because the EV gap is near zero, mixing is the point -- always calling over-defends into the straights, always folding surrenders too much vs the air share. Raising any size only isolates against the hands that beat JJ.'
    commonMistake = 'Reading a big pocket pair as a mandatory call on a runout where the board-wide straight family completed.'
    takeaway = 'When the turn completes the whole low-straight family, big overpairs become mix candidates -- indifference is the lesson, not strength.'
  }
}

# --- R02 b1-3: AA -> JJ | action | mixed_indifference | 9s8d4c/7h | WL row ---
NewRework @{
  replaces = '9s8d4c_7h_m4_action_AhAd_v430C'; id = '9s8d4c_7h_m4_action_JcJh_v461'; rw = 'REWORK-(a)'
  hero = @('Jc','Jh'); cls = 'overpair'; role = 'marginal_made_hand'; draw = 'none'; sdv = 'high'
  rec = 'mixed'; best = 'mixed'; acc = @('call','fold'); crit = @('check_raise_big')
  prompt = 'Flop 9s 8d 4c; turn 7h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Jc Jh?'
  blocker = 'Jc Jh removes half the JT straight combos -- real removal that keeps the call side of the mix alive. Beyond that the hand holds no six or ten, and no suit story exists on the four-suit runout.'
  arrival = 'Preflop: JJ is a chart flat from the BB -- a member outside the locked 3-bet set. Flop 9s 8d 4c vs the small c-bet: the overpair calls as the clear best line; raising OOP folds out worse and bloats against better, and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'The 7h completes JT, T6 and 65 -- the overpair drops to a mixed catcher with meaningful JT removal.'
    turnLogic = 'Three straight families arrive at once on 9-8-7 texture. Villain barrels those plus sets and two pair, and keeps firing overcard air; JJ beats only the air share and thin 9x value.'
    rangeContext = 'BTN polarizes on the straight-completing turn. BB caps at overpairs and 9x, so JJ is a top-of-range catcher rather than a value hand -- exactly the shape that mixes.'
    handLogic = 'Holding two jacks halves villain JT, which measurably raises the calling EV vs a straight-heavy value region -- and that removal is why the mix leans call rather than fold.'
    sizingLogic = 'Mixed is best because call and fold sit within noise of each other; both are acceptable pure lines. The big check-raise is the punt: it isolates against completed straights and sets with a one-pair hand -- raise-into-crush.'
    commonMistake = 'Auto-calling the overpair without registering that the 7h connected three straight families at once.'
    takeaway = 'Count the straight families a turn card completes before you rate an overpair; removal of the top one decides which way to lean the mix.'
  }
}

# --- R03 b1-4: AA -> KQo (KhQc; Qs is a board card -- suit-corrected from the
# plan string KhQs) | action | protection_CR | Qs7d3c/3h ---
NewRework @{
  replaces = 'Qs7d3c_3h_m4_action_AhAd_v430C'; id = 'Qs7d3c_3h_m4_action_KhQc_v461'; rw = 'REWORK-(a)'
  hero = @('Kh','Qc'); cls = 'top_pair_good_kicker'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('call'); crit = @()
  prompt = 'Flop Qs 7d 3c; turn 3h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Kh Qc?'
  blocker = 'Kh Qc carries mixed removal: the K trims AK float combos that would pay a raise, while the Q halves the worse-Qx region hero wants to charge. The raise therefore leans on range math, not blockers. No suit story on the rainbow-paired runout.'
  arrival = 'Preflop: KQo defends the BB vs the 2.5x open by chart -- a member. Flop Qs 7d 3c vs the small c-bet: top pair good kicker calls as the street best line; raising is thin against the continuing range and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'The paired 3h changes nothing structurally -- top pair with the K kicker upgrades to a small protection raise.'
    turnLogic = 'Villain barrels worse Qx, 7x, gutters like 45 and 64, and overcard floats such as AK and AJ that own six live outs. The small raise values the first group and taxes the rest out of their equity.'
    rangeContext = 'The 3 pairing hits nobody in either range, so the flop strategic picture carries forward -- and BB holding KQ sits above the whole barrel-continue region except AQ and the rare trips.'
    handLogic = 'KQ beats QJ, QT, Q9s, all 7x and every float; it loses to AQ, 33, 77 and Q3s-type oddities. That ratio is comfortably in favor of raising for value plus protection.'
    sizingLogic = 'Small denies the overcard floats their price while keeping worse Qx in; big only folds the exact hands hero profits from and stacks off against the trips region. Calling is a fine pot-controlled second choice; folding top pair here is a plain over-fold.'
    commonMistake = 'Flatting again and letting AK-type floats realize six outs for free on a board where protection is cheap.'
    takeaway = 'On static paired turns, top pair good kicker raises small: value from worse top pair, tax on the floats.'
  }
}

# --- R04 b1-5: AA -> AJo | action | protection_CR | JdTd5s/2c (twin of R06 by
# explicit owner ruling -- authored as the PROTECTION lens of the pair) ---
NewRework @{
  replaces = 'JdTd5s_2c_m4_action_AhAd_v430C'; id = 'JdTd5s_2c_m4_action_AhJs_v461'; rw = 'REWORK-(a)'
  hero = @('Ah','Js'); cls = 'top_pair_top_kicker'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('call'); crit = @()
  prompt = 'Flop Jd Td 5s; turn 2c. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Ah Js?'
  blocker = 'Ah Js holds no diamond: villain flush draws keep every combo, and the raise charges them rather than removing them. The A rank card trims AJ above hero and the aces-up region; net removal favors raising.'
  arrival = 'Preflop: AJo is a ruled member of the defend range (it dominates the explicit member ATo). Flop Jd Td 5s vs the small c-bet: top pair top kicker calls as the street best line under the M3 frame -- the raise there belongs to sets and combo draws -- and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'A brick 2c after a draw-heavy flop: TPTK raises small, with equity denial doing the heavy lifting.'
    turnLogic = 'Villain still barrels every flush draw, KQ and 98-type straight draws, and worse Jx. All of that either pays the raise or surrenders equity it was owed -- the definition of a protection raise on a wet-static turn.'
    rangeContext = 'The 2c changes no draws and no pair order, so the flop equity map is intact: many live draws against a top-pair hand that is well ahead of the barrel-continue region.'
    handLogic = 'AJ beats KJ, QJ, JT-lite, Tx and all draws; it loses to JT two pair, 55/TT/JJ sets and overpairs above. The winning region continues against a small raise far more often than the losing region appears.'
    sizingLogic = 'Small is the protection price: draws pay wrong immediately or fold. Big folds the draws hero profits from; calling gives every draw a free look at half its outs. Folding TPTK to a single barrel here is a plain over-fold.'
    commonMistake = 'Calling down passively with TPTK and letting eight-plus-out draws realize for free on the one street where the tax is cheap.'
    takeaway = 'Wet flop, brick turn: top pair top kicker raises small primarily to deny equity -- the value is real but the denial is the reason.'
  }
}

# --- R05 b1-6: KK -> TT (amended from JJ -- JJ collides with R02 board family;
# owner-approved amendment TcTh) | action | bluff_catch | 9s8d4c/7h ---
NewRework @{
  replaces = '9s8d4c_7h_m4_action_KsKc_v432'; id = '9s8d4c_7h_m4_action_TcTh_v461'; rw = 'REWORK-(a)'
  hero = @('Tc','Th'); cls = 'overpair'; role = 'bluff_catcher'; draw = 'none'; sdv = 'high'
  rec = 'call'; best = 'call'; acc = @('check_raise_small','mixed'); crit = @()
  prompt = 'Flop 9s 8d 4c; turn 7h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Tc Th?'
  blocker = 'Tc Th removes two of the four tens: JT and T6 straight combos are halved, which is precisely what keeps the call profitable on a straight-completing turn. No suit story on the four-suit runout.'
  arrival = 'Preflop: TT is a chart flat from the BB -- a member. Flop 9s 8d 4c vs the small c-bet: the overpair calls as the clear best line; raising OOP forfeits the bluff region it beats, and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'The 7h completes JT, T6 and 65 -- but two tens in hand gut the first two families, so TT calls once.'
    turnLogic = 'Villain barrels completed straights, sets, and two pair for value plus a wide overcard-air region that cannot stop firing. TT beats the entire air share and the thin 9x value bets.'
    rangeContext = 'BB reaches this turn with overpairs, 9x, 8x and draw-misses; TT with double straight-blockers is one of the best pure catchers in the range -- ahead of the same hand without the removal.'
    handLogic = 'TT loses to JT, T6, 65, sets and 98-type two pair, and beats everything unpaired plus 9x. The ten removal shifts roughly half the JT and T6 combos out of the losing column before the call is made.'
    sizingLogic = 'Calling once is the plan. The small raise and the mix are defensible against a max-aggro villain profile, but the big raise turns a catcher into a bluff against a region that never folds a straight -- the classic punt shape, avoided here only because the removal keeps this at bad-adjacent rather than mandatory-fold.'
    commonMistake = 'Folding every non-straight the moment 9-8-7 connects, or worse, raising big and isolating against exactly the completed straights.'
    takeaway = 'Straight-completing turns are removal questions: two tens turn TT from a fold candidate into the range anchor catcher.'
  }
}

# --- R06 b1-7: KK -> AJo | action | value_CR | JdTd5s/2c (twin of R04 -- the
# VALUE lens of the owner-ruled AJo pair; suits differ, AhJc) ---
NewRework @{
  replaces = 'JdTd5s_2c_m4_action_KsKh_v430D'; id = 'JdTd5s_2c_m4_action_AhJc_v461'; rw = 'REWORK-(a)'
  hero = @('Ah','Jc'); cls = 'top_pair_top_kicker'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('call'); crit = @()
  prompt = 'Flop Jd Td 5s; turn 2c. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Ah Jc?'
  blocker = 'Ah Jc holds no diamond, so the flush draws hero wants paying keep every combo. The A trims AA and AJ above; the J halves KJ and QJ -- a small tax on the value target, outweighed by the draw-charging math.'
  arrival = 'Preflop: AJo is a ruled member of the defend range (it dominates the explicit member ATo). Flop Jd Td 5s vs the small c-bet: top pair top kicker calls as the street best line -- flop raises belong to sets and combo draws -- and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'Brick turn after the draw-heavy flop: TPTK raises small for value -- the worse-Jx and draw region pays.'
    turnLogic = 'KJ, QJ, J9s, second-pair Tx and every diamond or straight draw continues the barrel line. The small raise gets value from all of it now, instead of letting the draws price themselves on the river.'
    rangeContext = 'Villain reps a wide barrel on this texture because so many draws exist -- which is exactly why a top-pair hand that beats the barrel-continue region should be raising rather than flatting.'
    handLogic = 'AJ loses only to JT two pair, sets and the overpairs above it; it beats every other continue. Against a small raise the worse region calls wide, which is the definition of a value raise.'
    sizingLogic = 'Small keeps dominated Jx and second pair in while charging draws wrong; big folds out the entire pay region. Calling is acceptable pot control that leaves river guesswork; folding TPTK to one barrel is a plain over-fold.'
    commonMistake = 'Waiting for the river to raise -- by then the draws have either arrived or priced out, and the value window has closed.'
    takeaway = 'When the barrel-continue region is dominated hands plus draws, top pair top kicker raises the turn for value, not later.'
  }
}

# --- R07 b1-8: KK (kings full) -> KQo | action | value_CR | Kd8s3c/8h.
# SIZE SHIFT disclosed: original best check_raise_big belonged to the boat;
# top pair good kicker cannot carry that sizing -- best becomes CRS. ---
NewRework @{
  replaces = 'Kd8s3c_8h_m4_action_KsKc_v430C'; id = 'Kd8s3c_8h_m4_action_KhQd_v461'; rw = 'REWORK-(a)'
  hero = @('Kh','Qd'); cls = 'top_pair_good_kicker'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('call'); crit = @()
  prompt = 'Flop Kd 8s 3c; turn 8h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Kh Qd?'
  blocker = 'Kh Qd blocks KQ ties and trims AK slightly; holding no 8 leaves the trips region every combo. The small size, not removal, is what manages that risk. No suit story on the four-suit runout.'
  arrival = 'Preflop: KQo defends the BB vs the 2.5x open -- a member. Flop Kd 8s 3c vs the small c-bet: top pair good kicker calls as the street best line; raising is thin and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'The pairing 8h thins the danger zone -- top pair strong kicker raises small for thin value.'
    turnLogic = 'Villain keeps barreling dominated Kx -- KJ, KT, K9s -- plus underpairs and give-up air. The paired 8 makes 8x trips possible but rarer than the dominated region, and the small raise prices exactly that ratio.'
    rangeContext = 'Second barrels on K-8-3-8 stay wide because the K-high board favors the opener; hero KQ sits above everything in the continue region except AK and the trips.'
    handLogic = 'KQ beats KJ, KT, K9s, 99-QQ-type underpairs and all air; it loses to AK, 8x trips and slowplayed monsters. The winning column both outnumbers and out-continues the losing one at small sizing.'
    sizingLogic = 'Small extracts from dominated Kx while losing the minimum when the 8 is out there; the original boat sizing -- the big raise -- bloats the pot against only AK and trips, so it grades bad for this hand. Calling is fine pot control; folding top pair to one barrel is an over-fold.'
    commonMistake = 'Copying monster sizing with a one-pair hand: the raise size must shrink when the hand quality does.'
    takeaway = 'Paired turns reward thin value at small sizing -- the raise targets dominated top pair, and the size caps the trips risk.'
  }
}

# --- R08 b1-9: QQ -> 99 (amended from JJ -- JJ exists on this board as a PASS
# row) | reason | bluff_catch | Ts8s4d/7c ---
NewRework @{
  replaces = 'Ts8s4d_7c_m4_reason_QcQd_v432'; id = 'Ts8s4d_7c_m4_reason_9h9d_v461'; rw = 'REWORK-(a)'
  hero = @('9h','9d'); cls = 'underpair'; role = 'bluff_catcher'; draw = 'none'; sdv = 'decent'
  rec = 'call'; best = 'bluff_catch_turn'; acc = @('pot_odds_turn_call'); crit = @()
  prompt = 'Flop Ts 8s 4d; turn 7c. BB calls the turn barrel with 9h 9d. What is the primary reason?'
  blocker = 'Two nines remove half the J9 and 96 straight combos the 7c just created -- direct removal of the new value region. Hero holds no spade, so villain flush draws keep every combo on the two-spade board.'
  arrival = 'Preflop: 99 is a chart flat from the BB -- a member. Flop Ts 8s 4d vs the small c-bet: the underpair to the top card calls as the standard priced defend; folding is too tight and raising turns a made hand into a bluff, so no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'The 7c connects J9 and 65 -- but double nine removal plus live spades keep 99 a clear one-street catcher.'
    turnLogic = 'Villain barrels completed straights, Tx value and every spade draw, plus the overcard air that cannot stop. 99 beats the air, the naked draws and 8x -- and the nines in hand gut the J9 family before the count starts.'
    rangeContext = 'BB holds many pocket pairs and 8x here; 99 with straight-blockers is the best of the underpair catchers, which is why it defends while smaller pairs let go.'
    handLogic = 'The call banks against the bluff share: every unpaired barrel and bare flush draw pays 99 at showdown or gives up on the river. The losing column -- Tx, straights, sets -- was discounted by removal.'
    sizingLogic = 'The catch frame, not the odds line, is primary: pot odds alone would defend too many worse pairs. Raising any size turns a catcher into a bluff into the region that never folds; the fold surrenders a profitable call.'
    commonMistake = 'Lumping 99 with the small pairs and folding -- the two nines change the villain value count enough to flip the decision.'
    takeaway = 'Catch with the pairs that block the new straights; fold the ones that do not. Removal is the tiebreaker under the top card.'
  }
}

# --- R09 b1-10: AKo(+As NFD) -> KQo | action | bluff_catch | Ks8s3d/2s.
# Hero-driven partition delta disclosed: no spade in hand demotes the original
# CRS-acceptable (it was NFD-driven) to bad -- pure no-blocker MDF catch. ---
NewRework @{
  replaces = 'Ks8s3d_2s_m4_action_AsKd_v430'; id = 'Ks8s3d_2s_m4_action_KhQc_v461'; rw = 'REWORK-(a)'
  hero = @('Kh','Qc'); cls = 'top_pair_good_kicker'; role = 'bluff_catcher'; draw = 'none'; sdv = 'high'
  rec = 'call'; best = 'call'; acc = @(); crit = @()
  prompt = 'Flop Ks 8s 3d; turn 2s. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Kh Qc?'
  blocker = 'Kh Qc holds no spade: zero removal of the completed flushes and zero blocker credit for raising -- which is exactly why the hand calls once and never raises. The K rank card trims AK and the KQ ties.'
  arrival = 'Preflop: KQo defends the BB vs the 2.5x open -- a member. Flop Ks 8s 3d vs the small c-bet: top pair good kicker calls as the street best line and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'The third spade completes the flopped draws -- top pair without a spade drops to a single MDF catch.'
    turnLogic = 'Villain barrels made flushes and AK for value, and keeps firing gutters, worse Kx and spade-blocker air as bluffs. The barrel range stays wide enough that top pair must defend once.'
    rangeContext = 'BB reaches this turn with Kx, 8x, pocket pairs and its own draws; KQ without a spade is the textbook catcher -- strong enough to beat every bluff, blind to the flush region.'
    handLogic = 'KQ beats worse Kx, all air and the naked one-spade bluffs; it loses to flushes, AK and two pair. With no spade in hand the flush count runs at full weight -- call once, re-evaluate rivers.'
    sizingLogic = 'Calling is the whole plan. Raising any size with no spade folds out the bluffs hero beats and gets action only from flushes -- small is bad, big is the raise-into-crush shape. Folding top pair immediately overfolds against a range still full of one-pair value and air.'
    commonMistake = 'Raising to protect against a fourth spade -- protection logic has no meaning against a range whose value is already ahead of you.'
    takeaway = 'On three-flush turns without a blocker, top pair is one call -- never a raise, not yet a fold.'
  }
}

# --- R10 b1-11: AKo -> KTo (amended from KQo -- KQo collides with R07 board
# family) | action | bluff_catch | Kd8s3c/8h. CRS demoted (AK kicker carried
# the original acc; KT does not). Fold stays acceptable: kicker-ladder low end. ---
NewRework @{
  replaces = 'Kd8s3c_8h_m4_action_AdKh_v430C'; id = 'Kd8s3c_8h_m4_action_KhTc_v461'; rw = 'REWORK-(a)'
  hero = @('Kh','Tc'); cls = 'top_pair_weak_kicker'; role = 'bluff_catcher'; draw = 'none'; sdv = 'high'
  rec = 'call'; best = 'call'; acc = @('fold'); crit = @('check_raise_big')
  prompt = 'Flop Kd 8s 3c; turn 8h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Kh Tc?'
  blocker = 'Kh Tc: the K trims AK and KQ barrels; no 8 in hand leaves the trips region whole, and the T kicker loses the ladder to KQ and KJ. Call once, understand the fold, never raise. No suit story on the four-suit runout.'
  arrival = 'Preflop: KTo defends the BB vs the 2.5x open -- a member (the KTo float family is corpus-established). Flop Kd 8s 3c vs the small c-bet: top pair calls as the street best line; no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'Paired 8h, kicker trouble: KT catches one street as the low rung of the Kx ladder.'
    turnLogic = 'Villain barrels AK and KQ for value, 8x for trips, and keeps bluffing underpair give-ups and overcard air. KT beats the air and little else -- but the air share alone funds one call.'
    rangeContext = 'The barrel range on K-8-3-8 is value-lean but not value-only; MDF says the Kx family defends, and the kicker decides how deep each rung goes.'
    handLogic = 'KT loses the kicker war to every better Kx that barrels and to all trips; it beats bluffs only. That is a real but thin catch -- which is why the fold is acceptable here while KJ one rung up must call.'
    sizingLogic = 'The call is the anchor; the fold is a defensible surrender at this kicker. The small raise is bad -- dominated when called, no fold equity vs trips -- and the big raise is the punt: a catcher bloating the pot into a region that crushes it.'
    commonMistake = 'Raising to find out where you are: with KT the answer always costs a stack fraction and never improves the hand.'
    takeaway = 'Kicker sets the depth of the Kx defense: KT is the last rung that calls, and the first where folding is fine.'
  }
}

# --- R11 b1-12: AKo -> KJo | action | bluff_catch | Kd8s3c/8h. CRS demoted as
# R10; CRB unified to critical with R10 (judgment upgrade beyond the mechanical
# dup-resolution, disclosed: near-identical catchers must not split tiers). ---
NewRework @{
  replaces = 'Kd8s3c_8h_m4_action_AdKh_v430D'; id = 'Kd8s3c_8h_m4_action_KcJd_v461'; rw = 'REWORK-(a)'
  hero = @('Kc','Jd'); cls = 'top_pair_weak_kicker'; role = 'bluff_catcher'; draw = 'none'; sdv = 'high'
  rec = 'call'; best = 'call'; acc = @(); crit = @('check_raise_big')
  prompt = 'Flop Kd 8s 3c; turn 8h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Kc Jd?'
  blocker = 'Kc Jd: the K trims the AK and KQ value barrels, the J adds nothing structural. No 8 in hand keeps the trips region whole -- the call rests on the bluff share, not on removal. No suit story on the four-suit runout.'
  arrival = 'Preflop: KJo defends the BB vs the 2.5x open -- a member. Flop Kd 8s 3c vs the small c-bet: top pair calls as the street best line; no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'One kicker above KT the fold disappears: KJ is a mandatory single catch on the paired turn.'
    turnLogic = 'The value that barrels -- AK, KQ, 8x -- beats KJ exactly as it beats KT; the bluff share is identical too. What changes is the dominated region: KT and K9s barrels now pay hero.'
    rangeContext = 'Each kicker rung converts part of the villain value column into the pay column. At the J kicker the arithmetic clears the call threshold with room, so surrendering becomes a real error.'
    handLogic = 'KJ beats KT, K9s, underpair give-ups and all air; it loses to AK, KQ and trips. That win column is wide enough that folding overfolds -- the rung below could fold, this one cannot.'
    sizingLogic = 'Call once and re-evaluate. The small raise stays bad -- dominated when called with no fold equity against trips -- and the big raise stays the punt for the same reason it is one rung down: a catcher isolating against the crush region.'
    commonMistake = 'Treating KJ and KT as the same hand: one kicker decides whether the fold is an option or an error.'
    takeaway = 'Walk the kicker ladder one rung at a time -- the barrel-defense boundary between KT and KJ is the lesson of the paired turn.'
  }
}

# --- R12 b1-13: AKo(As NFD) -> AJo with the NUT SPADE (AsJd -- suit-corrected
# from the plan string AhJc: the A-high catch lesson requires the As; without
# it the best flips to fold and the row dies) | action | bluff_catch | Qs8s4d/2s ---
NewRework @{
  replaces = 'Qs8s4d_2s_m4_action_AsKc_v430C'; id = 'Qs8s4d_2s_m4_action_AsJd_v461'; rw = 'REWORK-(a)'
  hero = @('As','Jd'); cls = 'no_pair_no_draw'; role = 'bluff_catcher'; draw = 'nut_flush_draw'; sdv = 'low'
  rec = 'call'; best = 'call'; acc = @('check_raise_small'); crit = @()
  prompt = 'Flop Qs 8s 4d; turn 2s. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with As Jd?'
  blocker = 'The As is the whole hand: villain can never hold the nut flush, hero draws to it on any river spade, and every naked-spade bluff villain fires is one hero can beat by calling. Rank-wise the A also trims AQ value combos.'
  arrival = 'Preflop: AJo is a ruled member of the defend range. Flop Qs 8s 4d vs the small c-bet: ace-high with two overs and the backdoor nut spade continues as a standard priced float -- at or above acceptable with no raise node missed (the A-family float standard from the audit). The turn node is this scenario.'
  expl = [ordered]@{
    short = 'Third spade, and hero holds the As: an ace-high catch built entirely on the nut blocker.'
    turnLogic = 'Villain value on Q-8-4-2 spades is flushes and Qx-up -- but hero owning the As deletes the top of that column and caps how thick the value share can run. What remains is a barrel range fat with one-spade bluffs and gutter give-ups.'
    rangeContext = 'BB holds every flush and Qx too, so villain over-barrels the blocker bluffs into a range that beats them -- hero at the As simply refuses to release the hand that polices exactly those bluffs.'
    handLogic = 'AJ-high beats every unpaired bluff and chops or loses the rest -- and it improves to the nuts on nine rivers. Low showdown value plus the nut draw plus max removal is the canonical ace-high defend.'
    sizingLogic = 'Calling banks the bluff share and keeps the nut-river implied odds. The small raise is an acceptable blocker-leverage line at low frequency; the big raise spends a stack fraction repping what hero blocks himself. Folding the As here surrenders the best catcher in the range.'
    commonMistake = 'Folding ace-high by hand strength alone -- on three-flush turns the As is a range card, not a kicker problem.'
    takeaway = 'Catch with the nut blocker, fold without it: the As turns ace-high into the last hand that releases on a spade turn.'
  }
}

# --- R13 b1-14: AKo -> AJo | reason | bluff_catch | 8c8d3s/3h ---
NewRework @{
  replaces = '8c8d3s_3h_m4_reason_AdKc_v430'; id = '8c8d3s_3h_m4_reason_AhJd_v461'; rw = 'REWORK-(a)'
  hero = @('Ah','Jd'); cls = 'no_pair_no_draw'; role = 'bluff_catcher'; draw = 'none'; sdv = 'low'
  rec = 'call'; best = 'bluff_catch_turn'; acc = @('pot_odds_turn_call','equity_realization_turn_call'); crit = @()
  prompt = 'Flop 8c 8d 3s; turn 3h. BB calls the turn barrel with Ah Jd. What is the primary reason?'
  blocker = 'Ah Jd holds no 8 and no 3: no trips removal either way, which keeps the catch honest -- hero beats exactly the unpaired bluffs and nothing else. The A rank card trims A8 and the ace-high bluffs villain also barrels. No suit story on this runout.'
  arrival = 'Preflop: AJo is a ruled member of the defend range. Flop 8c 8d 3s vs the small c-bet: ace-high with two overs floats the range-bet as the standard priced defend -- the double-paired board smashes neither range and folding every unpaired hand overfolds; no raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'Double-paired and blank: the board plays for both sides, so ace-high polices the bluff share.'
    turnLogic = 'The 3h changes nothing -- villain value is 8x, overpairs and little more, and the barrel range is stuffed with unpaired broadway that has to keep firing to win. A-high beats all of it at showdown.'
    rangeContext = 'On boards that miss both ranges the defense burden falls to high cards; if ace-high folds here, villain profits by barreling any two, which is the exploit the call denies.'
    handLogic = 'AJ beats KQ, KJ, QJ-type barrels and ties or better against ace-high; it loses to any pair. The bluff share of the barrel range is what funds the call -- the equity math and the odds are supporting frames, not the reason.'
    sizingLogic = 'The catch frame is primary; the pot-odds and realization reads arrive at the same call and grade acceptable. Every raise reason fails: there is nothing to value, nothing to protect, and nothing to semi-bluff with on a dead board.'
    commonMistake = 'Folding all air because the board is paired -- paired-and-dead boards are where air must defend most, not least.'
    takeaway = 'When a runout misses both ranges, the bluff-catch frame governs: high cards call because only bluffs bet worse.'
  }
}

# --- R14 b1-15: AKs -> AJs | action | value_CR | Ah9d4d/7h ---
NewRework @{
  replaces = 'Ah9d4d_7h_m4_action_AsKs_v430D'; id = 'Ah9d4d_7h_m4_action_AsJs_v461'; rw = 'REWORK-(a)'
  hero = @('As','Js'); cls = 'top_pair_good_kicker'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('call'); crit = @()
  prompt = 'Flop Ah 9d 4d; turn 7h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with As Js?'
  blocker = 'As Js holds neither diamond nor a second heart: both live draw suits keep every combo, so the raise is priced by range math while the As trims AA and the better aces. Honest minus: AK and AQ own the kicker war when they call.'
  arrival = 'Preflop: AJs is a chart flat -- a member outside the locked 3-bet set. Flop Ah 9d 4d vs the small c-bet: top pair good kicker calls as the street best line; raising is thin against the continuing range and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'Second flush suit arrives live: top pair with the J kicker raises small to charge two draw families at once.'
    turnLogic = 'The 7h keeps the flopped diamond draws drawing and opens turned heart draws behind them. Villain barrels every one of those plus worse aces and 9x -- a continue region that either pays now or folds equity it owned.'
    rangeContext = 'A-high boards belong to the barrel range, so villain fires wide here; that width is what the raise taxes. Hero caps none of his own value by raising -- the range holds the same aces villain fears.'
    handLogic = 'AJ beats AT through A2, 9x, 4x and all draws; it loses to AK, AQ, the turned 77 set and two-pair combos. The pay region is far wider than the punish region, and both draw suits pay wrong immediately.'
    sizingLogic = 'Small charges twelve-plus draw combos their worst price while keeping dominated aces in. Big folds the draws and isolates the kicker war; calling gives two suits a free river card. Folding top pair here is a plain over-fold.'
    commonMistake = 'Flat-calling because a second draw suit feels dangerous -- live draws against a made hand are a reason to raise, not to hide.'
    takeaway = 'When a turn multiplies the live draws, top pair good kicker raises small: every added draw family raises the price of protection villain must pay.'
  }
}

# --- R15 b1-16: AKs(NFD) -> KQs | action | equity_realization_call | Ts8s4d/7c.
# Non-nut honesty: the As stays live above hero -- ceiling stated in prose. ---
NewRework @{
  replaces = 'Ts8s4d_7c_m4_action_AsKs_v430C'; id = 'Ts8s4d_7c_m4_action_KsQs_v461'; rw = 'REWORK-(a)'
  hero = @('Ks','Qs'); cls = 'flush_draw'; role = 'combo_draw'; draw = 'flush_draw'; sdv = 'low'
  rec = 'call'; best = 'call'; acc = @('check_raise_small'); crit = @()
  prompt = 'Flop Ts 8s 4d; turn 7c. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Ks Qs?'
  blocker = 'Ks Qs is a live flush draw but not the nut one: the As stays in villain range, so a river spade usually wins the pot and sometimes loses the stack. That honest ceiling -- second-nut outs plus two overcards -- is why the call beats the raise.'
  arrival = 'Preflop: KQs is a chart flat -- a member. Flop Ts 8s 4d vs the small c-bet: the flush draw with two overs calls as a fully standard line (the semi-bluff raise is also standard, so no node was missed and the continue sits at or above acceptable per the audit criterion). The turn node is this scenario.'
  expl = [ordered]@{
    short = 'Nine flush outs plus two overs on a barrel street: call to realize the equity at the quoted price.'
    turnLogic = 'The 7c adds straight texture around 9x and 65, which thickens the villain value share; hero equity is unchanged -- nine spades plus the overcard pairs that sometimes win unimproved.'
    rangeContext = 'Villain barrels made Tx-up, new straights and his own draws. Against that mix hero is the one drawing: the call keeps every villain bluff barrel in while paying once for the river card.'
    handLogic = 'K-high flush outs face one real discount -- the As above -- and the K and Q overs add outs only against the one-pair region. Rich equity, weak current hand: the textbook realization call.'
    sizingLogic = 'Calling prices the draw exactly. The small check-raise is an acceptable semi-bluff at frequency -- it folds some better one-pair hands -- but it inflates a pot hero usually has to hit to win. The big raise does that at double cost, and folding nine-plus outs at this price burns equity outright.'
    commonMistake = 'Semi-bluffing every strong draw by default: with a non-nut suit and showdown-poor overs, realizing beats repping.'
    takeaway = 'Draw quality picks the line: nut draws can raise, second-nut draws call and realize -- the As you do not hold is the difference.'
  }
}

# --- R16 b1-17: AQs -> ATo (amended from AJo -- V1 makes AJ the thin-value
# RAISER on the A-brick texture; AT one kicker down is the coherent CATCHER) |
# action | bluff_catch | As8d3h/2c ---
NewRework @{
  replaces = 'As8d3h_2c_m4_action_AdQd_v430'; id = 'As8d3h_2c_m4_action_AhTd_v461'; rw = 'REWORK-(a)'
  hero = @('Ah','Td'); cls = 'top_pair_good_kicker'; role = 'bluff_catcher'; draw = 'none'; sdv = 'high'
  rec = 'call'; best = 'call'; acc = @(); crit = @('check_raise_big')
  prompt = 'Flop As 8d 3h; turn 2c. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Ah Td?'
  blocker = 'Ah Td: the A rank card trims AA and splits the kicker ladder -- everything from AJ up beats hero, everything below pays hero. No suit story on this runout.'
  arrival = 'Preflop: ATo is an explicit chart member -- the baseline anchor hand of the defend range. Flop As 8d 3h vs the small c-bet: top pair calls as the street best line and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'One kicker below the raise threshold: AT calls the brick turn instead of raising it.'
    turnLogic = 'The 2c changes nothing. Villain barrels better aces for value and keeps firing broadway air and 8x-lite; AT beats the entire bluff share plus the dominated aces below it.'
    rangeContext = 'This texture is where AJ upgrades to a thin value raise -- one kicker up, the dominated pool is wide enough to fund it. At the T kicker the pool thins: A9 through A2 pay, AJ and AQ now punish. The raise stops printing exactly here.'
    handLogic = 'AT beats A9-A2, 8x, 3x and all air; it loses to AJ, AQ, AK and the turned sets. Calling keeps every dominated ace and every bluff in; raising folds the first group and doubles against the second.'
    sizingLogic = 'The call is the line. The small raise grades bad at this kicker -- it builds a pot only the better aces continue into -- and the big raise is the punt: a catcher isolating against exactly AJ-plus. Folding top pair on a brick is a plain over-fold.'
    commonMistake = 'Copying the AJ raise with AT: the one-kicker difference flips the dominated-ace arithmetic from profit to punishment.'
    takeaway = 'Kickers draw the raise line on static A-high turns: AJ raises thin, AT catches -- know which side of the line you hold.'
  }
}

# --- R17 b1-18: AQs(NFD) -> QJs | action | semi_bluff_CR | Ts8s4d/7c ---
NewRework @{
  replaces = 'Ts8s4d_7c_m4_action_AsQs_v432'; id = 'Ts8s4d_7c_m4_action_QsJs_v461'; rw = 'REWORK-(a)'
  hero = @('Qs','Js'); cls = 'combo_draw'; role = 'combo_draw'; draw = 'combo_draw'; sdv = 'none'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('call','mixed'); crit = @()
  prompt = 'Flop Ts 8s 4d; turn 7c. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Qs Js?'
  blocker = 'Qs Js draws to the second and third nut flush -- the As and the Ks stay live above it -- while the 9 completes a queen-high straight that stands over the J9 family. Twelve-ish clean outs with a stated ceiling: strong enough to raise, honest enough to size small.'
  arrival = 'Preflop: QJs is a chart flat -- a member. Flop Ts 8s 4d vs the small c-bet: the flush draw with a gutter and two live overcards continues as a standard priced call; the raise is also standard there, so no node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'Flush draw plus turned gutter: the combo draw semi-bluff raises the barrel small.'
    turnLogic = 'The 7c that helps villain also hands hero the 9-straight window on top of nine spades. Twelve-ish outs with two overs behind them is enough equity to play for fold-out now plus the pot when it arrives.'
    rangeContext = 'Villain barrels Tx, new straights and worse draws. The small raise folds the one-pair region that beats QJ-high today, and the hands that continue are exactly the ones hero out-draws.'
    handLogic = 'Unimproved QJ-high wins nothing at showdown -- every fold the raise buys is pure profit, and the equity backstop converts the called pots often enough to close the loop.'
    sizingLogic = 'Small risks the minimum for the fold-out and keeps the stack behind for the river card; calling to realize is acceptable, as is a mixed split between them. The big raise overpays for the same folds and burns the ceiling honesty -- second-nut outs should not build maximum pots.'
    commonMistake = 'Flatting every draw on the barrel street: with zero showdown value and live overs, the fold-out share is worth paying a small price for.'
    takeaway = 'Combo draws with no showdown value semi-bluff small: buy the folds cheap, keep the equity as the backstop.'
  }
}

# --- R18 b1-24: 54o -> 87s | action | board_change_fold | QsTs6d/Jc.
# Critical=call preserved: call-zero-SDV is the enumerated punt (RW.R08 warn
# expected and justified). ---
NewRework @{
  replaces = 'QsTs6d_Jc_m4_action_5h4d_v430'; id = 'QsTs6d_Jc_m4_action_8d7d_v461'; rw = 'REWORK-(b)'
  hero = @('8d','7d'); cls = 'gutshot'; role = 'give_up'; draw = 'gutshot'; sdv = 'none'
  rec = 'fold'; best = 'fold'; acc = @(); crit = @('call')
  prompt = 'Flop Qs Ts 6d; turn Jc. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with 8d 7d?'
  blocker = '8d 7d still has one card to a straight -- and that is the trap: any 9 gives hero the J-high straight while AK and K9 already hold higher ones on this runout. A dominated draw with no pair is removal-blind and future-poor.'
  arrival = 'Preflop: 87s is a chart flat -- a member. Flop Qs Ts 6d vs the small c-bet: the gutter to the 9 plus backdoor diamonds makes the peel priced and legitimate -- at or above acceptable with no raise node missed. The turn node is this scenario: the Jc is the card that changes the answer.'
  expl = [ordered]@{
    short = 'The Jc turns broadway one card wide -- the gutter that was live on the flop is now drawing dead-adjacent.'
    turnLogic = 'AK and K9 completed outright, 98 completed underneath them, and every AQ, KQ and KJ float turned pairs plus straight draws. The barrel range just lapped hero: the 9 outs now build second-best hands.'
    rangeContext = 'BB floats like this one exist to catch bricks; when the turn is the single best card for the barrel range, the float family folds as a bloc -- that range-level shift is the lesson.'
    handLogic = 'Eight-high has no showdown value, the diamond backdoor died at the turn, and the only straight hero can make loses to K9 and AK the moment it arrives. Nothing in the hand earns the price.'
    sizingLogic = 'Folding is the whole answer. Calling with zero showdown value and a dominated draw is the enumerated punt -- money in with no way to win at showdown and reverse implied odds on the out card. Raising either size bluffs into the one range segment that just got there.'
    commonMistake = 'Seeing a straight out and paying for it -- count whose straight the out card completes before calling it an out.'
    takeaway = 'When the turn is the best card in the deck for the barrel range, live-looking draws are folds: dominated outs are debts, not equity.'
  }
}

# --- R19 b1-19: 99(set) -> K9s TOP TWO (amended from TcTd: a TT raise into the
# Kx-heavy barrel range is incoherent at seed strictness; K9s makes the
# protection raise genuinely best) | action | protection_CR | 9d8c6h/Kc ---
NewRework @{
  replaces = '9d8c6h_Kc_m4_action_9c9s_v430'; id = '9d8c6h_Kc_m4_action_Ks9s_v461'; rw = 'REWORK-(c)'
  hero = @('Ks','9s'); cls = 'top_two_pair'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('check_raise_big','call'); crit = @()
  prompt = 'Flop 9d 8c 6h; turn Kc. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Ks 9s?'
  blocker = 'Ks 9s: the 9 in hand halves villain T9 and 98 continues -- a real minus for the value side -- while the K trims the AK and KQ barrels. Hero holds no club, so the turned club draws keep every combo; the raise leans on equity denial, which is exactly the protection frame.'
  arrival = 'Preflop: K9s defends the BB vs the 2.5x open by chart -- a member. Flop 9d 8c 6h vs the small c-bet: top pair top kicker calls as the street best line (flop raises belong to sets and two pair in the M3 frame) and no check-raise node was missed. The turn Kc pairs the kicker -- this scenario.'
  expl = [ordered]@{
    short = 'The Kc converts top pair into top two on a board where straights are live and every draw got heavier.'
    turnLogic = 'T7 and 57 straights are possible, JT and QJ picked up double draws, and the Kc opened club draws behind them. Villain barrels new Kx top pair plus all of that -- top two raises to end the equity auction now.'
    rangeContext = 'The K is a barrel card for villain -- AK, KQ, KJ fire it -- which is precisely what hero values: the raise gets paid by the Kx region while taxing the draw cloud.'
    handLogic = 'K9 beats every Kx one-pair, 9x, 8x and all draws; it loses to T7, 57, sets and nothing else that continues. The pay region is wide and the punish region narrow -- and the hand blocks part of its own competition at two pair.'
    sizingLogic = 'Small is the primary: value from Kx plus a tax every draw pays wrong. Big is acceptable on this many live draws -- the equity-denial premium is real. Calling is acceptable pot control that risks the auction running another street; folding top two is a plain over-fold.'
    commonMistake = 'Flatting top two to keep bluffs in while three draw families draw at their own price -- protection has a value cost here and it is cheap.'
    takeaway = 'When the turn pairs your kicker on a live board, top two raises: end the equity auction while the barrel range still pays.'
  }
}

# --- R20 b1-20: T7s(straight) -> KQs (amended from JhTh: JT is still drawing
# on the K turn and cannot carry a value label; KQ turns top pair and can) |
# reason | value_CR | 9d8c6h/Kc ---
NewRework @{
  replaces = '9d8c6h_Kc_m4_reason_Tc7c_v430'; id = '9d8c6h_Kc_m4_reason_KhQh_v461'; rw = 'REWORK-(c)'
  hero = @('Kh','Qh'); cls = 'top_pair_good_kicker'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'value_check_raise_turn'; acc = @('protection_check_raise_turn'); crit = @()
  prompt = 'Flop 9d 8c 6h; turn Kc. BB check-raises the turn barrel small with Kh Qh. What is the primary reason?'
  blocker = 'Kh Qh turned top pair with the queen kicker. Hero holds no club, so the turned club draws stay whole -- part of why raising, not calling, is the line: draws pay now or release. The K and Q rank cards trim KQ ties and QJ continues.'
  arrival = 'Preflop: KQs is a chart flat -- a member. Flop 9d 8c 6h vs the small c-bet: two live overcards with a heart backdoor continue as a standard priced float -- at or above acceptable under the MDF-core standard, with no raise node missed. The turn Kc pairs hero -- this scenario.'
  expl = [ordered]@{
    short = 'The float turned top pair on a draw-heavy card: the raise is for value first, protection second.'
    turnLogic = 'Villain barrels 9x and 8x made hands, JT and QJ draws, and new club draws -- a continue region top pair with the Q kicker beats almost entirely. Raising now values that region at its widest.'
    rangeContext = 'The K helps the barrel range too -- AK and KJ fire it -- but hero KQ sits above the majority of what continues, and the draws that call are paying wrong. That EV edge is what makes value the primary label.'
    handLogic = 'KQ beats KJ-lite, 9x, 8x, and every draw that calls; it loses to AK, T7, 57 and sets. The winning column dwarfs the losing one among hands that actually continue against a small raise.'
    sizingLogic = 'The value frame is primary because the raise profits even if no draw exists -- worse made hands pay it. The protection reading is the acceptable second lens: the same raise also taxes three draw families. Fold-based and catch-based frames all misread a hand this far ahead of the barrel range.'
    commonMistake = 'Calling the turn because the flop was a float -- the K changed the hand class, and the line must change with it.'
    takeaway = 'When a float turns top pair on a wet card, raise for value: the draw tax is the bonus, the worse continues are the reason.'
  }
}

# --- R21 b1-22: TT(set) -> JJ | action | protection_CR | Ts9s5d/6h.
# CRB demoted from the original acceptable (set sizing does not transfer to an
# overpair -- disclosed). ---
NewRework @{
  replaces = 'Ts9s5d_6h_m4_action_TcTd_v430'; id = 'Ts9s5d_6h_m4_action_JsJc_v461'; rw = 'REWORK-(c)'
  hero = @('Js','Jc'); cls = 'overpair'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('call'); crit = @()
  prompt = 'Flop Ts 9s 5d; turn 6h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Js Jc?'
  blocker = 'Js Jc: the Js removes a slice of villain spade-draw combos -- real removal on a two-spade board -- while the two jacks trim JT top-pair continues, a small tax on the value side. Net, the raise leans on equity denial.'
  arrival = 'Preflop: JJ is a chart flat -- a member outside the locked 3-bet set. Flop Ts 9s 5d vs the small c-bet: the overpair calls as the street best line; raising OOP forfeits the stab region, and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'The 6h completes 87 but multiplies the draw field -- the overpair raises small to end the auction.'
    turnLogic = 'Villain barrels Tx, spade draws, QJ and 87-adjacent straight hands. Only 87 itself and sets beat JJ among the continues; everything else pays the raise or surrenders live equity.'
    rangeContext = 'The barrel range on T-9-5-6 is draw-dense by construction -- which is exactly when an overpair stops flatting: every street of patience sells equity to the field at a discount.'
    handLogic = 'JJ beats Tx, 9x, two-pair-lite and all draws; it loses to 87, TT/99/55/66 sets and nothing else. The spade in hand shaves the draw region that pays, but the remaining field is wide enough to fund the raise twice over.'
    sizingLogic = 'Small charges the whole draw cloud while losing the minimum to 87; the big raise -- the original set sizing -- overpays for protection an overpair does not need at this ratio and grades bad. Calling is acceptable pot control; folding the overpair to one barrel is a plain over-fold.'
    commonMistake = 'Flatting the overpair on a completed-straight card as if it were a catcher -- one made straight family does not turn a value hand into a bluff-catcher.'
    takeaway = 'Draw-dense turns are raise turns for overpairs: tax the field small, and let 87 be the rare bad news.'
  }
}

# --- R22 #33: JJ(top set) -> KJo | action | value_CR | JdTd5s/2c D2.
# Partition deltas from the set original disclosed: call promoted bad->acc
# (standard for TPGK), CRB demoted acc->bad (set sizing does not transfer). ---
NewRework @{
  replaces = 'JdTd5s_2c_m4_action_JhJs_v430D'; id = 'JdTd5s_2c_m4_action_KhJs_v461'; rw = 'REWORK-(c)'
  hero = @('Kh','Js'); cls = 'top_pair_good_kicker'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('call'); crit = @()
  prompt = 'Flop Jd Td 5s; turn 2c. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Kh Js?'
  blocker = 'Kh Js: the J in hand halves villain JT two pair and the QJ/KJ continues -- mixed removal -- and hero holds no diamond, so the flush draws that pay the raise keep every combo. The K kicker is what turns this Jx into a raise instead of a call.'
  arrival = 'Preflop: KJo defends the BB vs the 2.5x open -- a member. Flop Jd Td 5s vs the small c-bet: top pair good kicker calls as the street best line and no check-raise node was missed. The turn node is this scenario.'
  expl = [ordered]@{
    short = 'Brick 2c on the wet flop: top pair with the K kicker raises small for value against a draw-heavy barrel range.'
    turnLogic = 'Villain keeps firing diamond draws, KQ and 98 straight draws, and worse Jx. All of it either pays the raise now or gives up equity it was owed a card for -- the easy version of the turn raise decision.'
    rangeContext = 'On this texture the barrel range is stuffed with draws, so a top-pair hand that beats the entire draw region and the dominated Jx raises rather than guesses on rivers.'
    handLogic = 'KJ beats QJ, J9s, Tx and every draw; it loses to AJ, JT two pair and sets. Against a small raise the worse region continues wide -- the same value logic as AJ one kicker up, at a friendlier price point.'
    sizingLogic = 'Small keeps the dominated hands and draws in; calling is acceptable pot control at this kicker. The big raise folds the pay region for no gain, and folding top pair to one barrel on a brick is a plain over-fold.'
    commonMistake = 'Rating KJ as a call-only hand: on draw-heavy textures the K kicker plus draw tax clears the raise threshold.'
    takeaway = 'The turn raise threshold on wet boards sits at good-kicker top pair -- KJ is the floor of the value raise, not the ceiling of the call.'
  }
}

# --- R23 #38: 88(set) -> A4s ACES UP (amended from AcJd: a thin one-pair raise
# into AK/AQ cannot be best; aces-up carries the raise and the LABEL STAYS
# protection_check_raise_turn -- the relabel question resolves as KEEP) |
# action | protection_CR | Kd8c4s/Ah ---
NewRework @{
  replaces = 'Kd8c4s_Ah_m4_action_8d8h_v430C'; id = 'Kd8c4s_Ah_m4_action_Ac4c_v461'; rw = 'REWORK-(c)'
  hero = @('Ac','4c'); cls = 'two_pair'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('call'); crit = @()
  prompt = 'Flop Kd 8c 4s; turn Ah. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with Ac 4c?'
  blocker = 'Ac 4c: the Ac trims AK and AA above hero; the 4 side of the two pair is invisible to villain, which keeps every worse ace paying. No suit story -- four suits on board mean no flush is possible by the river, and no draw claims are made.'
  arrival = 'Preflop: A4s is a member by the A2s-A5s ruling -- part of the three-bet mix, still a member of the defend range. Flop Kd 8c 4s vs the small c-bet: bottom pair with the ace overcard calls as the standard priced peel; folding is too tight and raising is nothing, so no node was missed. The turn Ah pairs the ace -- this scenario.'
  expl = [ordered]@{
    short = 'The turn ace makes hidden aces-up -- a vulnerable two pair that raises small before the kicker outs arrive.'
    turnLogic = 'Villain barrels the ace hard: AQ, AJ, AT for new top pair, Kx second pair, and QJ/QT gutters around the broadway cards. Aces-up beats all of it today and hates most rivers -- the raise converts that edge now.'
    rangeContext = 'The Ah is the classic barrel card for the opener, so the range that fires is wide and top-pair heavy -- exactly the customer list for a disguised two pair.'
    handLogic = 'A4 beats every one-pair ace, all Kx and the gutters; it loses to AK aces-up-bigger, 44-trips oddities and slowplayed sets. The pay region is wide now and shrinks with every safe river villain checks back.'
    sizingLogic = 'Small gets value from the aces that just arrived while denying Kx and the gutters their five-out rivers -- vulnerability is why the raise happens on this street. Big folds the worse aces hero profits from; calling lets every kicker out peel free. Folding two pair is a plain over-fold.'
    commonMistake = 'Slow-calling hidden two pair on the barrel card -- the disguise is worth the most on the street villain still holds top pair wide.'
    takeaway = 'Vulnerable hidden two pair raises the barrel card small: protection with a value engine, priced while the worse hands still pay.'
  }
}

# --- R24 #49: 77(sevens full) -> A3s TRIPS (top kicker; role/sdv deliberately
# strong_value/high NOT nutted -- QQ trips and 77 boats stay live, per the
# within-category precheck standard) | action | value_CR | Qs7d3c/3h ---
NewRework @{
  replaces = 'Qs7d3c_3h_m4_action_7s7c_v430C'; id = 'Qs7d3c_3h_m4_action_As3s_v461'; rw = 'REWORK-(c)'
  hero = @('As','3s'); cls = 'trips'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_small'; best = 'check_raise_small'; acc = @('call','check_raise_big'); crit = @()
  prompt = 'Flop Qs 7d 3c; turn 3h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with As 3s?'
  blocker = 'As 3s leaves exactly one 3 in the deck: villain pocket 33 is impossible, and every other trips holding loses the kicker war to the ace. The value region hero targets -- Qx -- keeps every combo. No suit story on this runout.'
  arrival = 'Preflop: A3s is a member by the A2s-A5s ruling. Flop Qs 7d 3c vs the small c-bet: bottom pair with the ace overcard calls as the standard priced peel -- the same street logic the audit passed for the 88 row on this board -- and no raise node was missed. The turn 3h makes trips: this scenario.'
  expl = [ordered]@{
    short = 'The board pairs hero out of nowhere: top-kicker trips raise the barrel for value.'
    turnLogic = 'Villain barrels Qx top pair, 77-adjacent value and broadway air on the blank-looking 3. Trips with the ace kicker beats everything that continues except the rare boats -- and the raise gets Qx to pay while it still believes.'
    rangeContext = 'The 3h looks like a brick from the barrel seat, so ranges do not slow down -- which is precisely the moment a hidden trips hand extracts. Villain reads the raise as Qx-or-bluff and continues accordingly.'
    handLogic = 'A3 beats every Qx, 7x and air combo; it loses to QQ trips-over, 77 boats and Q3-type oddities -- all rare, and 33 is card-dead impossible. The kicker war among trips goes to hero every time.'
    sizingLogic = 'Small keeps the whole Qx region in -- the raise is value, not protection, on a board this static. Big is acceptable with a hand this far ahead; the trips discount for QQ and 77 is what keeps small primary. Calling to trap is acceptable but underpays vs one-street stabs; folding trips would be absurd and mixed just mislabels a clear spot.'
    commonMistake = 'Flatting trips on the paired turn to be tricky -- the barrel range pays raises now and checks rivers back.'
    takeaway = 'Hidden trips on a brick-looking pair card raise small: extract from top pair while the story still reads as bluff-or-worse.'
  }
}

# --- R25 #64: TT(top set) -> 87s BOTTOM TWO | action | value_CR (big) |
# Ts8s4d/7c D4. The big-raise lesson TRANSFERS here (unlike R07): vulnerable
# two pair on a draw-rich board carries the deny-equity sizing. ---
NewRework @{
  replaces = 'Ts8s4d_7c_m4_action_TcTd_v432'; id = 'Ts8s4d_7c_m4_action_8h7h_v461'; rw = 'REWORK-(c)'
  hero = @('8h','7h'); cls = 'two_pair'; role = 'strong_value'; draw = 'none'; sdv = 'high'
  rec = 'check_raise_big'; best = 'check_raise_big'; acc = @('check_raise_small'); crit = @()
  prompt = 'Flop Ts 8s 4d; turn 7c. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with 8h 7h?'
  blocker = '8h 7h holds no spade: villain flush draws keep every combo and pay the big raise. The 8 and 7 in hand trim villain 98, 87 and T7 continues slightly -- the honest engine of the sizing is equity denial, not removal.'
  arrival = 'Preflop: 87s is a chart flat -- a member. Flop Ts 8s 4d vs the small c-bet: middle pair calls as the standard priced defend -- the same street logic the audit passed for 98s on this exact board -- and no raise node was missed. The turn 7c makes bottom two: this scenario.'
  expl = [ordered]@{
    short = 'Bottom two pair on a board where every draw is live: raise big and make the field pay full price.'
    turnLogic = 'The 7c gives hero two pair and the field more rope -- spade draws, J9 and 96 straight draws, 65, and Tx top pair all continue against a raise. Two pair is ahead of all of it and hates almost every river.'
    rangeContext = 'Villain reads the big raise as a draw or Tx-plus and continues with exactly the region hero wants: top pair pays, overpairs pay, and the draws take the worst price they will ever be quoted.'
    handLogic = 'Eights and sevens beat Tx, JJ-type overpairs, 9x and every draw; they lose to sets, 65 made and T7/T8 bigger two pair. The winning region continues wide -- and each safe river that passes shrinks it, which is why the money goes in now.'
    sizingLogic = 'Big is the point: the draw field is so wide that maximum denial IS the value line -- small underprices nine-spade and eight-straight-out hands (acceptable, but a discount). Calling invites every scare river with a hand that cannot catch up once behind; folding two pair is a plain over-fold and mixed mislabels a clear raise.'
    commonMistake = 'Raising small into a draw-rich field out of habit -- sizing is the protection lever, and this board maxes it.'
    takeaway = 'Vulnerable two pair on draw-rich turns raises BIG: when the field draws at you from three directions, the price of the card is the lesson.'
  }
}

# --- R26 #18: 5h5d(impossible "set of 5s") -> JTo NUT STRAIGHT -- the content
# re-derive. Every original tag (slowplay_trap / nutted / D4 / partition)
# becomes TRUE for this hero; only the hand and prose change. ---
NewRework @{
  replaces = '9s8d4c_7h_m4_reason_5h5d_v432'; id = '9s8d4c_7h_m4_reason_JcTd_v461'; rw = 'CONTENT-REDRIVE'
  hero = @('Jc','Td'); cls = 'straight'; role = 'slowplay_trap'; draw = 'none'; sdv = 'nutted'
  rec = 'call'; best = 'slowplay_turn_call'; acc = @('value_check_raise_turn'); crit = @()
  prompt = 'Flop 9s 8d 4c; turn 7h. BB calls the turn barrel with Jc Td. What is the primary reason?'
  blocker = 'Jc Td is the nut straight on a runout with four suits: no flush is possible, no higher straight exists, and villain JT only chops. No current villain holding is ahead -- protection is a river-management question, not a raise reason, and that absence of present danger is what licenses the slowplay.'
  arrival = 'Preflop: JTo defends the BB vs the 2.5x open by chart -- membership here is not the routed flop-float question, which concerns no-draw floats. Flop 9s 8d 4c vs the small c-bet: the double gutter -- any 7 or any Q, eight clean outs -- makes the call draw-driven, priced and clearly at or above acceptable, with no raise node missed. The turn 7h completes the nuts: this scenario.'
  expl = [ordered]@{
    short = 'The 7h lands the nut straight on a flush-dead board -- the one hand class whose best line is to keep every bluff in.'
    turnLogic = 'Villain barrels straights-beneath, sets, two pair and a fat air region on the 9-8-7 texture, and hero beats or chops every single continue today. The license has an expiry: any pairing river -- a 9, 8, 7 or 4 -- lets a slowplayed set boat past the straight, so the trap is priced for one street and paired rivers get re-evaluated. No flush runout exists on four suits.'
    rangeContext = 'Raising folds the entire air share instantly and flips villain to check-back rivers with the value-lite region. Calling keeps the barrel range whole: third-street bluffs, thin value and hopeless heroing all still arrive.'
    handLogic = 'This is the slowplay license test: nothing to protect against -- no flush suit reaches five, no higher straight exists, JT chops. Compare the set family, which fast-plays precisely because live draws exist; the dead-board nut straight is the opposite pole.'
    sizingLogic = 'The trap call is primary; the value raise is the acceptable second line -- it wins a smaller pot with certainty and is never a mistake, merely a discount. Every other frame misreads the spot: there is nothing to catch, nothing to protect, and nothing to semi-bluff when you hold the nuts.'
    commonMistake = 'Fast-playing the nuts on a dead board by reflex -- protection instincts built for sets do not transfer to unbeatable hands.'
    takeaway = 'Slowplay is licensed by absence of danger, not by hand strength: dead-board nut straights trap; vulnerable monsters raise.'
  }
}

# ============================================================================
# GATE-2: BOARD-CHANGED family (owner ruling batch-3 #3 + gate-2 pin). New
# boards chosen so each slowplay/realization lesson stands under the R26
# license principle AND the corpus M3 standard (full_house call-best 1/1,
# trips call-best 3/3, oesd call-best present in class). Monotone nut-flush
# axis converted (0 monotone flops corpus-wide + M3 NFD = CRS-best makes a
# turned-flush arrival illegal); F2 = quads conversion path (ii), D4 -> D2.
# ============================================================================

# --- F1 (b1-21): 88 slowplay As8d3h -> 88 FLOPPED BOAT on 8s5s5d/2h.
# Path (i) tension-retained: the boat-vs-live-draws INVERSION. ---
NewRework @{
  replaces = 'As8d3h_2c_m4_reason_8c8h_v430'; id = '8s5s5d_2h_m4_reason_8h8d_v461'; rw = 'BOARD-CHANGED'
  hero = @('8h','8d'); cls = 'full_house'; role = 'slowplay_trap'; draw = 'none'; sdv = 'nutted'
  rec = 'call'; best = 'slowplay_turn_call'; acc = @('value_check_raise_turn'); crit = @()
  board = [ordered]@{
    flopCards=@('8s','5s','5d'); turnCard='2h'; cards=@('8s','5s','5d','2h')
    boardKind='low'; suitTextureFlop='two_tone'; suitTextureTurn='two_tone'
    textureTags=@('paired','semi_connected'); highCardClass='low'
    turnCategory='brick'; boardChange='brick'; equityShift='neutral'
    drawCompletion='gutshot_added'; pairStatusChange='no_change'
  }
  prompt = 'Flop 8s 5s 5d; turn 2h. BB calls the turn barrel with 8h 8d. What is the primary reason?'
  blocker = 'Hero holds two of the three remaining eights, so villain trips-eight combos are nearly extinct -- the value that pays the trap is 5x trips, overpairs and floats. Hero holds no spade: the live spade draws keep every combo, and every one of them is drawing at a hand that beats its arrival. Above hero only pocket fives -- one combo of quads -- survives; no higher full house exists.'
  arrival = 'Preflop: 88 is a chart flat -- a member. Flop 8s 5s 5d vs the small c-bet: hero flops eights full, and the M3 corpus standard itself grades the flopped full house as a call (the full_house class best) -- the boat slowplay is house doctrine at the flop, so the call is the street best line and no node was missed. The turn 2h barrel is this scenario.'
  expl = [ordered]@{
    short = 'Flopped eights full on a draw-live board -- the inversion spot: every draw that gets there pays the trap.'
    turnLogic = 'The 2h looks like the blankest card in the deck while quietly adding wheel gutters that villain keeps barreling. Every live draw -- the spade flush draws, 67, the new wheel cards -- arrives dead to the boat: the inversion is that hero wants the draws to get there. Only pocket fives for quads, one combo, sits above; the license survives every river.'
    rangeContext = 'Villain barrels overcard air, 5x trips, overpairs and every draw on a board that looks like it missed the caller. Raising folds the air and the draws immediately; calling keeps the entire barrel stream alive into the river.'
    handLogic = 'Sets fast-play because live draws beat sets when they arrive. A flopped boat inverts that rule: the flush and straight cards that terrify a set are payday cards here, improving villain into second-best hands that pay off at full price.'
    sizingLogic = 'The trap call is primary; the value raise is the acceptable line and wins a real but smaller pot. Fold and catch frames misread a near-nut hand, and protection frames misread a hand with nothing to protect against -- the draws are income, not threats.'
    commonMistake = 'Applying the set rule to the boat and raising to protect -- protecting a full house against draws that lose to it burns the entire bluff stream for nothing.'
    takeaway = 'Boats invert the fast-play rule: when every draw that arrives pays you, the draws are the reason to slowplay, not the reason to raise.'
  }
}

# --- F2 (b3-#52): 88 slowplay Qs8s4d -> QUAD EIGHTS on Qh8s8d/4h.
# Path (ii) CONVERSION: recognizing the free slowplay; D4 -> D2. ---
NewRework @{
  replaces = 'Qs8s4d_2s_m4_action_8d8h_v430C'; id = 'Qh8s8d_4h_m4_action_8h8c_v461'; rw = 'BOARD-CHANGED-CONVERTED'
  diff = 2  # owner path (ii): recognition-level difficulty, D4 -> D2
  hero = @('8h','8c'); cls = 'quads'; role = 'slowplay_trap'; draw = 'none'; sdv = 'nutted'
  rec = 'call'; best = 'call'; acc = @('check_raise_small'); crit = @('fold')
  board = [ordered]@{
    flopCards=@('Qh','8s','8d'); turnCard='4h'; cards=@('Qh','8s','8d','4h')
    boardKind='Q_high'; suitTextureFlop='rainbow'; suitTextureTurn='two_tone'
    textureTags=@('paired','dry'); highCardClass='Q_high'
    turnCategory='brick'; boardChange='brick'; equityShift='neutral'
    drawCompletion='none'; pairStatusChange='no_change'
  }
  prompt = 'Flop Qh 8s 8d; turn 4h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with 8h 8c?'
  blocker = 'Hero holds all four eights: villain can never have trips, never a boat through an eight, and never improves past two pair except three combos of queens full that still lose. Quad eights here is the stone nuts -- with two hearts on board no straight flush exists.'
  arrival = 'Preflop: 88 is a chart flat -- a member. Flop Qh 8s 8d: hero flops quad eights; with all four eights between hand and board, villain is pair-capped forever and nothing to protect against exists -- the call is the only line that keeps a live range in the pot, so no node was missed at any street. The turn barrel is this scenario.'
  expl = [ordered]@{
    short = 'Quad eights -- the free slowplay: zero outs against, so the trap is arithmetic, not judgment.'
    turnLogic = 'The 4h adds heart draws that arrive dead and changes nothing else. Villain barrels Qx, overpairs, heart draws and air -- all of it drawing at zero outs. The license is absolute: no river card in the deck un-licenses this slowplay.'
    rangeContext = 'Villain is capped at one pair plus dead draws. Any raise at any point folds everything except QQ -- and QQ pays the river barrel anyway. The trap is not a choice between lines; it is the only line with a payout.'
    handLogic = 'Recognition is the whole lesson: count the outs against quads -- zero -- and the decision stops being a decision. The boat and trips versions of this family carry real slivers of danger and require judgment; this one is arithmetic.'
    sizingLogic = 'Call, and let villain keep betting. The small raise is acceptable -- it wins a smaller pot with certainty and is never a disaster. Folding quads is the fold-nuts punt, the exact reason the critical tier exists. The big raise and the mixed label just end the hand early for less.'
    commonMistake = 'Raising the nuts to build a pot a capped range will never build with you -- capped ranges pay barrels, not raises.'
    takeaway = 'When villain cannot outdraw you and cannot hold a piece, the slowplay is free -- recognizing that freedom is the entire skill.'
  }
}

# --- F3 (b3-#66): TT slowplay Ts8s4d -> NUT TRIPS on TsTc4d/7h, hero ATs.
# Axis converted from monotone nut-flush (mechanically unreachable: zero
# monotone flops exist corpus-wide and M3 grades NFD raise-best, making any
# turned-flush arrival illegal). M3 grades trips call-best 3/3. ---
NewRework @{
  replaces = 'Ts8s4d_7c_m4_reason_TdTc_v430D'; id = 'TsTc4d_7h_m4_reason_AhTh_v461'; rw = 'BOARD-CHANGED'
  hero = @('Ah','Th'); cls = 'trips'; role = 'slowplay_trap'; draw = 'none'; sdv = 'nutted'
  rec = 'call'; best = 'slowplay_turn_call'; acc = @('value_check_raise_turn'); crit = @()
  board = [ordered]@{
    flopCards=@('Ts','Tc','4d'); turnCard='7h'; cards=@('Ts','Tc','4d','7h')
    boardKind='T_high'; suitTextureFlop='rainbow'; suitTextureTurn='rainbow'
    textureTags=@('paired','dry'); highCardClass='T_high'
    turnCategory='draw_intensifier'; boardChange='draw_added'; equityShift='neutral'
    drawCompletion='oesd_added'; pairStatusChange='no_change'
  }
  prompt = 'Flop Ts Tc 4d; turn 7h. BB calls the turn barrel with Ah Th. What is the primary reason?'
  blocker = 'Ah Th is top trips with the top kicker: every other Tx is out-kicked, quads is card-dead -- hero and the board hold three of the four tens -- and the beats are exactly 44 and T4, six combos of boats. No suit story on this runout: the license rests on rank structure alone.'
  arrival = 'Preflop: ATs is a chart flat -- a member. Flop Ts Tc 4d vs the small c-bet: hero flops top trips with the top kicker, and the M3 corpus standard grades flopped trips as a call -- unanimous across the trips class -- so the trips slowplay is house doctrine at the flop, the call is the street best line, and no node was missed. The turn 7h barrel is this scenario.'
  expl = [ordered]@{
    short = 'Top trips, top kicker, paired board -- the bluff-stream license: trap the air-heavy barrel, pay the six-combo tax.'
    turnLogic = 'Paired boards make barrel ranges bluff-heavy: villain fires overpairs and Ax thin value plus a wide air region that must keep betting to win. The 7h adds 89 and 56 straight draws -- real outs against trips -- but a handful of drawing combos cannot outweigh an air-fat stream. The license expires if an 8, 6, J or 3 completes those straights: those rivers get re-evaluated, and the unraised pot is the built-in insurance.'
    rangeContext = 'Raising the paired board folds the air instantly and flips villain to checking back thin value -- the exact outcome the trap exists to avoid. Calling keeps overpairs valuing, Ax bluffing, and the new draws paying wrong.'
    handLogic = 'Top trips with the ace beats every Tx, every overpair, every Ax and all air; it loses to 44 and T4 -- six combos -- and nothing else today. The kicker is the license: AT traps where QT would merely catch, because QT loses the kicker war to the Tx that barrels.'
    sizingLogic = 'The trap call is primary; the value raise is acceptable and wins a smaller certain pot. Catch frames undersell a hand this far ahead, protection frames overweight six draw combos against an air-heavy stream, and fold frames are not in the conversation.'
    commonMistake = 'Fast-playing trips on the paired board to charge the straight draws -- the handful of draw combos is the tax the trap pays for the whole bluff stream.'
    takeaway = 'Paired boards license the trips slowplay: the barrel range is air-rich, the beats are countable, and the trap prices that trade correctly.'
  }
}

# --- F4 (b1-23): A6s equity_real Ts9s5d -> 98s CLEAN OESD on Tc7d2s/4h.
# Modest-draw axis: sub-top connector, no pair, no overs, eight clean outs --
# the call-only realization spot the original NFD hand could never be. ---
NewRework @{
  replaces = 'Ts9s5d_6h_m4_action_As6s_v430'; id = 'Tc7d2s_4h_m4_action_9h8h_v461'; rw = 'BOARD-CHANGED'
  hero = @('9h','8h'); cls = 'oesd'; role = 'draw'; draw = 'oesd'; sdv = 'none'
  rec = 'call'; best = 'call'; acc = @(); crit = @()
  board = [ordered]@{
    flopCards=@('Tc','7d','2s'); turnCard='4h'; cards=@('Tc','7d','2s','4h')
    boardKind='T_high'; suitTextureFlop='rainbow'; suitTextureTurn='rainbow'
    textureTags=@('dry','semi_connected'); highCardClass='T_high'
    turnCategory='brick'; boardChange='brick'; equityShift='neutral'
    drawCompletion='none'; pairStatusChange='no_change'
  }
  prompt = 'Flop Tc 7d 2s; turn 4h. BTN c-bet small flop, BB called, BTN now barrels. What is BB best action with 9h 8h?'
  blocker = '9h 8h holds eight clean straight outs -- any J makes the nut J-high straight, any 6 makes the T-high one that only 98 ties -- with no pair and no showdown value behind them. No suit story: four suits on board mean no flush is possible by the river.'
  arrival = 'Preflop: 98s is a chart flat -- a member. Flop Tc 7d 2s vs the small c-bet: the open-ended draw calls as the priced continue -- call is a graded best within the M3 oesd class and no twin exists for this board -- so no node was missed. The turn 4h brick is this scenario.'
  expl = [ordered]@{
    short = 'Eight clean outs, no showdown value, brick turn: pay the price, realize the equity -- the call is the entire plan.'
    turnLogic = 'The 4h completes nothing and changes nothing: hero still holds eight outs to straights that are clean -- the J end is the nuts outright, the 6 end loses to nothing and ties only 98. Villain barrels Tx, overpairs and air; the quoted price plus the implied odds on a hidden straight clears the call.'
    rangeContext = 'Sub-top connectors have no showdown value to defend and no blocker story to rep -- their entire turn EV is realization: pay the price, keep the range villain barrels into wide, and collect on eight cards.'
    handLogic = 'Nine-high never wins unimproved, so every aggressive line is a distortion: raising bluffs into a range that c-bet and barreled -- it folds nothing hero fears and gets called by everything that beats nine-high.'
    sizingLogic = 'Call is the whole line. The semi-bluff raise fails both tests -- no fold equity worth buying, no showdown value to protect -- so both sizes grade bad rather than acceptable. The fold burns eight clean outs at a cleared price, and mixed mislabels a spot with one right answer.'
    commonMistake = 'Semi-bluffing every draw by reflex: with no overs and no blockers, this one is a pure price-and-realize call.'
    takeaway = 'Modest draws realize -- when the outs are clean and the price is right, the call IS the strategy; aggression adds nothing.'
  }
}

$doc = [ordered]@{
  description = 'M4 Arrival-Legitimacy reworks, v4.6.1 -- V1 pilot + gate-1 batch (26 standard rows) + gate-2 BOARD-CHANGED family (4 rows: boat-inversion, quads conversion, nut-trips, clean-OESD realization). Production untouched by this script.'
  generatedBy = 'tools/build-m4-arrival-reworks-v4.6.1.ps1'
  seedVersion = 'v4.6.1'
  count = 1 + $rows.Count
  reworks = @($v1) + @($rows.ToArray())
}
$json = $doc | ConvertTo-Json -Depth 12
$tmp = $outPath + '.tmp'
[System.IO.File]::WriteAllText($tmp, $json, [System.Text.UTF8Encoding]::new($false))
Move-Item -Force $tmp $outPath
Write-Output ('WROTE ' + $outPath + ' reworks=' + (1 + $rows.Count) + ' (V1 + gate-1 batch)')
