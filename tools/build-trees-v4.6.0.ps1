# build-trees-v4.6.0.ps1 -- G6 Continuous Hand: 3 authored hand-trees (12 nodes).
# PLANNING-ONLY: writes docs/specs/game-g6-v4.6.0-tree-seeds.json.
# Production postflop_scenarios.json is NEVER touched by this script.
# Source of truth for the v4.6.0 tree batch. ASCII-only. PS 5.1 safe.
#
# OWNER SPINE CONDITIONS BAKED IN (G6 spec approval, 2026-07-07):
#  - Tree A river: self-verifying stone-nuts enumeration in prose (straight
#    flushes impossible: board hearts K/6/Q span 7 ranks, never consecutive;
#    royal blocked by hero's Ah; KQJT9-SF blocked by hero's 9h -- both blocks
#    stated). Turn call authored as DRAW-PLAY (outs + implied); the raise
#    semibluff graded acceptable as derived. NO trap/slowplay language.
#  - Tree B river: check-raise choices present, graded bad (small) and
#    critical (big) -- the tree closes leg-(c) inside itself. Fold = best ->
#    Saved-BB banner beat.
#  - Tree C turn: equity sources named explicitly (made TPTK value + denial
#    vs spade draws and gutters); verdict stays combo-decidable.
#  - Preflop node included on every tree; verdict cited from the locked
#    chart (Trees A/B: banked BB-vs-BTN baseline, audit-plan sec 2;
#    Tree C: ranges.json 100BB_BTN_RFI).
# Stake per node = the locked street-stake ladder (v4.4.3): preflop 2,
# flop 3, turn 5, river by sizing 7/13/20/30 (defender: villain sizing;
# bettor: best-line sizing per the M6 stakeBasis PIN).

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$outPath = Join-Path $root 'docs\specs\game-g6-v4.6.0-tree-seeds.json'

function New-Node {
  param($street,$facing,$prompt,$choices,$best,$acc,$bad,$crit,$vBasis,$reason,$stakeBasis,$stakeBB,
        $short,$streetLogic,$rangeCtx,$handLogic,$sizLogic,$mistake,$takeaway,$blocker)
  $o = [ordered]@{
    street = $street
    facing = $facing
    prompt = $prompt
    choices = $choices
    answer = [ordered]@{ best = $best; acceptable = $acc; bad = $bad; critical = $crit }
    verdictBasis = $vBasis
    actionReason = $reason
    stakeBasis = $stakeBasis
    stakeBB = $stakeBB
    explanation = [ordered]@{
      short = $short; streetLogic = $streetLogic; rangeContext = $rangeCtx
      handLogic = $handLogic; sizingLogic = $sizLogic
      commonMistake = $mistake; takeaway = $takeaway
    }
  }
  if ($null -ne $blocker) { $o['blockerNote'] = $blocker }
  return $o
}

$trees = @()

# ============================================================================
# TREE A -- "The Nut Draw Arrives" (BB defend, payoff finale)
# hero Ah 9h -- board Kh 6h 2c / 5d / Qh
# ============================================================================
$treeA = [ordered]@{
  id = 'tree_a_nut_draw_arrives'
  version = 'v4.6.0'
  game = 'NLH_MTT'
  schemaVersion = 'tree-1.0.0'
  name = 'The Nut Draw Arrives'
  seat = 'BB'
  spot = [ordered]@{ format='NLH_MTT'; stackDepth='100BB'; potType='SRP'; heroPosition='BB'; villainPosition='BTN' }
  heroHand = @('Ah','9h')
  board = [ordered]@{ flopCards=@('Kh','6h','2c'); turnCard='5d'; riverCard='Qh' }
  preflopChartRow = 'BB vs BTN 2.5x: A9s = flat member -- not in the locked 3-bet set {QQ+, AK, AQs, part A2s-A5s} (banked baseline, postflop-module4-arrival-legitimacy-audit-plan.md sec 2)'
  sourceConfidence = 'expert_judgment'
  auditStatus = 'review_pending'
  reviewStatus = 'v4.6.0_seed'
  nodes = @(
    (New-Node -street 'preflop' -facing 'BTN opens 2.5x; folded to you in the BB' `
      -prompt 'BTN opens 2.5x. You are in the big blind with Ah 9h. What is your play?' `
      -choices @('fold','call','threebet') -best 'call' -acc @() -bad @('fold','threebet') -crit @() `
      -vBasis 'clear_direction' -reason 'preflop_chart_flat' -stakeBasis 'street_preflop' -stakeBB 2 `
      -short 'A9s is a standard big-blind defend: suited, connected to the nut flush, closing the action.' `
      -streetLogic 'Closing the action with a discounted price, the big blind defends wide against a 2.5x button open. A9s sits comfortably inside the flat range: it flops nut-flush draws and top pairs that play well from check-call lines.' `
      -rangeCtx 'The locked baseline keeps the 3-bet set at QQ+, AK, AQs and part of the wheel aces; A9s is not in it. Flatting keeps the hand in a wide, board-covering defend range.' `
      -handLogic 'Suited ace with a one-card gap: dominates smaller suited aces at showdown, makes the nut flush, and the 9 adds mid-board pairs. Folding surrenders clear equity at a discount; 3-betting takes a chart hand out of its best line.' `
      -sizLogic $null `
      -mistake 'Treating every suited ace as a 3-bet: the locked chart 3-bets only part of A2s-A5s for blocker value -- A9s flats.' `
      -takeaway 'Defend the big blind by the chart, not by mood: A9s is a flat, every time, at this price.'),
    (New-Node -street 'flop' -facing 'Flop Kh 6h 2c. You check, BTN c-bets 33% pot' `
      -prompt 'Flop Kh 6h 2c. You check, BTN bets a third of pot. Your play with Ah 9h?' `
      -choices @('fold','call','check_raise_small','check_raise_big') -best 'call' -acc @('check_raise_small') -bad @('check_raise_big','fold') -crit @() `
      -vBasis 'clear_direction' -reason 'equity_realization_call' -stakeBasis 'street_flop' -stakeBB 3 `
      -short 'Nut flush draw plus an overcard never folds to a small c-bet -- call and realize.' `
      -streetLogic 'The two-tone king flop hits the button opening range, so the small range-bet is expected. Against a third-pot price the big blind continues everything with real equity -- and this hand has the most real equity a no-pair hand can hold.' `
      -rangeCtx 'BTN c-bets this texture near range at a small size. That means his bet carries plenty of air and weak equity; over-folding here hands him an automatic profit.' `
      -handLogic 'Nine outs to the NUT flush plus the overcard ace: roughly a coin-flip against one pair with two cards to come. At 4.5-to-1 immediate odds, folding the nut draw is the single most expensive mistake available on this street.' `
      -sizLogic 'Calling keeps every bluff in his range betting the turn. A small check-raise is a defensible semi-bluff with this much equity; the big raise bloats the pot out of position with no made hand.' `
      -mistake 'Raising big "to find out where you are": with a monster draw, information is not worth folding out his air or bloating the pot OOP.' `
      -takeaway 'Monster draws continue for one street at a time: the call is mandatory, the small semi-bluff raise is optional.'),
    (New-Node -street 'turn' -facing 'Turn 5d. You check, BTN barrels 66% pot' `
      -prompt 'Turn 5d. You check, BTN barrels two-thirds pot. Your play with Ah 9h?' `
      -choices @('fold','call','check_raise_small','check_raise_big') -best 'call' -acc @('check_raise_small') -bad @('fold','check_raise_big') -crit @() `
      -vBasis 'clear_direction' -reason 'equity_realization_turn_call' -stakeBasis 'street_turn' -stakeBB 5 `
      -short 'A draw-play call: nine nut outs plus ace outs, priced on odds and nut implied value.' `
      -streetLogic 'The 5d is a brick that changes no ranges. This is a pure draw-play decision: count the outs, price the call, weigh the implied value of hitting the nuts on the river.' `
      -rangeCtx 'BTN barrels two-thirds with his value (Kx, overpairs) and his best draws and air. Nothing about the 5 lets him barrel more credibly; his range is the same one that bet the flop, one street more polarized.' `
      -handLogic 'Nine hearts make the NUT flush; three non-heart aces are live against his one-pair region -- roughly twelve dirty outs. The direct price is about 29% and the raw equity sits near 25%: the small deficit is covered many times over by what the nut flush earns when it arrives. This is an odds-and-implied call, priced like any draw-play.' `
      -sizLogic 'Calling preserves his barrel range for the river. The small check-raise semi-bluff is still defensible with nut outs; the big raise turns a profitable draw into an expensive guess; folding this much equity to one bet is a clear leak, though the river fold-out makes it less than catastrophic.' `
      -mistake 'Folding a nut draw on the turn "because the bets got big" -- price it: outs plus nut implied odds beat the price here.' `
      -takeaway 'Draws are math, not feel: outs, price, implied value -- when the nut flush is the payoff, the call prices itself.'),
    (New-Node -street 'river' -facing 'River Qh -- your flush arrives. You check, BTN barrels 75% pot' `
      -prompt 'River Qh completes your flush. You check, BTN bets three-quarters pot. Your play with Ah 9h?' `
      -choices @('fold','call','check_raise_small','check_raise_big') -best 'check_raise_small' -acc @('call','check_raise_big') -bad @() -crit @('fold') `
      -vBasis 'clear_direction' -reason 'value_raise_river' -stakeBasis 'large' -stakeBB 20 `
      -short 'The nut flush raises for value: zero combos beat you, and his barrel range pays.' `
      -streetLogic 'The Qh completes the front-door flush -- and yours is the stone nuts by enumeration. The board never pairs, so no boat or quads exist. Straight flushes are impossible: the board hearts are K, 6 and Q, which span eight ranks and can never sit in one five-card window; the royal is blocked by your own Ah, and the K-Q-J-T-9 straight flush is blocked by your own 9h. Nothing beats Ah-high flush here.' `
      -rangeCtx 'BTN triple-barrels into a completed flush with worse flushes, sets, two pairs and stubborn Kx -- plus the bluffs that kept firing. Every one of those hands pays a raise; villain 4-3 even made a straight on this runout and pays too.' `
      -handLogic 'You hold the nut flush on an unpaired board: 100% of his continuing range loses. The only question left is price extraction from a range that just committed a third barrel.' `
      -sizLogic 'The small check-raise keeps worse flushes, sets and top pair in; the big raise is acceptable against a committed range; flat-calling underplays the nuts but still wins the hand. Folding the stone nuts is the definitional catastrophe.' `
      -mistake 'Flat-calling the nuts "to be safe": the safety is an illusion -- by enumeration nothing beats you, and the last bet is where value lives.' `
      -takeaway 'When the enumeration says zero combos beat you, raise: the nut draw was played for exactly this street.' `
      -blocker 'Your Ah and 9h are the enumeration: the Ah removes the royal, the 9h removes K-Q-J-T-9 -- the only two straight-flush windows a heart hand could claim on K-6-Q hearts. Holding both, your flush is the stone nuts.')
  )
}
$trees += $treeA

# ============================================================================
# TREE B -- "The Correct Fold" (BB defend, MDF lesson finale, Saved-BB beat)
# hero Qc Jc -- board Jh 8d 3s / 7c / As
# ============================================================================
$treeB = [ordered]@{
  id = 'tree_b_correct_fold'
  version = 'v4.6.0'
  game = 'NLH_MTT'
  schemaVersion = 'tree-1.0.0'
  name = 'The Correct Fold'
  seat = 'BB'
  spot = [ordered]@{ format='NLH_MTT'; stackDepth='100BB'; potType='SRP'; heroPosition='BB'; villainPosition='BTN' }
  heroHand = @('Qc','Jc')
  board = [ordered]@{ flopCards=@('Jh','8d','3s'); turnCard='7c'; riverCard='As' }
  preflopChartRow = 'BB vs BTN 2.5x: QJs = flat member -- not in the locked 3-bet set {QQ+, AK, AQs, part A2s-A5s} (banked baseline, postflop-module4-arrival-legitimacy-audit-plan.md sec 2)'
  sourceConfidence = 'expert_judgment'
  auditStatus = 'review_pending'
  reviewStatus = 'v4.6.0_seed'
  nodes = @(
    (New-Node -street 'preflop' -facing 'BTN opens 2.5x; folded to you in the BB' `
      -prompt 'BTN opens 2.5x. You are in the big blind with Qc Jc. What is your play?' `
      -choices @('fold','call','threebet') -best 'call' -acc @() -bad @('fold','threebet') -crit @() `
      -vBasis 'clear_direction' -reason 'preflop_chart_flat' -stakeBasis 'street_preflop' -stakeBB 2 `
      -short 'QJs is a premium big-blind flat: suited, connected, top-pair-making.' `
      -streetLogic 'Suited broadways are the backbone of the big-blind flat range against a button open: they make strong top pairs and straights and play clean check-call lines.' `
      -rangeCtx 'The locked baseline 3-bets QQ+, AK, AQs and part of the wheel aces. QJs is a pure flat under this chart -- taking it out of the flatting range would gut the range''s broadway coverage.' `
      -handLogic 'QJs flops top pair with a real kicker, open-enders and royal draws. At a 2.5x discount, folding is far too tight and 3-betting is off-chart.' `
      -sizLogic $null `
      -mistake 'Random light 3-bets with hands the chart flats: it caps your calling range and turns a great flat into a bloated pot OOP.' `
      -takeaway 'The chart is the discipline: QJs defends by calling, and the postflop tree starts from that line.'),
    (New-Node -street 'flop' -facing 'Flop Jh 8d 3s. You check, BTN c-bets 33% pot' `
      -prompt 'Flop Jh 8d 3s. You check, BTN bets a third of pot. Your play with Qc Jc?' `
      -choices @('fold','call','check_raise_small','check_raise_big') -best 'call' -acc @() -bad @('fold','check_raise_small','check_raise_big') -crit @() `
      -vBasis 'clear_direction' -reason 'bluff_catch' -stakeBasis 'street_flop' -stakeBB 3 `
      -short 'Top pair, good kicker: call the small bet and keep his whole range in.' `
      -streetLogic 'Top pair on a dry-ish flop against a small range-bet is the definitional check-call: you beat the majority of a wide c-betting range and lose only to the top of it.' `
      -rangeCtx 'BTN range-bets J-8-3 rainbow-ish small; his bet says almost nothing. Your Jx defends the middle of your range -- folding it would collapse your defense frequency against a third-pot price.' `
      -handLogic 'QJ beats every worse Jx, every 8x and all his air; it loses to overpairs and better Jx (AJ, KJ). That is a textbook bluff-catcher-plus: way too strong to fold, not strong enough to build a pot out of position.' `
      -sizLogic 'Raising folds his air and isolates you against the exact hands that beat you; calling keeps the range wide and the pot controlled. Both raise sizes are the same mistake at different prices.' `
      -mistake 'Check-raising top pair "for protection" on a board with almost no draws to protect against.' `
      -takeaway 'Top pair good kicker calls small c-bets: the hand is a pot-controller, not a pot-builder, from the blind.'),
    (New-Node -street 'turn' -facing 'Turn 7c. You check, BTN barrels 66% pot' `
      -prompt 'Turn 7c. You check, BTN barrels two-thirds pot. Your play with Qc Jc?' `
      -choices @('fold','call','check_raise_small','check_raise_big') -best 'call' -acc @() -bad @('fold','check_raise_small','check_raise_big') -crit @() `
      -vBasis 'clear_direction' -reason 'bluff_catch_turn' -stakeBasis 'street_turn' -stakeBB 5 `
      -short 'Still a bluff-catch: the 7 connects some draws, and top pair holds the line once more.' `
      -streetLogic 'The 7c brings T-9 to a made straight and adds 9x/6x open-enders -- the barrel range now contains those, plus his flop value, plus the air that keeps firing. Top pair remains squarely in bluff-catch territory: ahead of the air and draws, behind the top.' `
      -rangeCtx 'A two-thirds barrel asks your whole range a real question, but Jx with a queen kicker is still comfortably above the folding threshold: fold it here and BTN prints with every two-broadway hand he barrels.' `
      -handLogic 'QJ beats KQ, QT and his busted-so-far draws; it loses to overpairs, AJ/KJ and the newly-made T9. The beaten region is still the wider one against a two-street barreling range.' `
      -sizLogic 'Calling one more street realizes your bluff-catcher; raising turns a made hand into a bluff against a range that just strengthened; folding is premature -- the expensive question comes on the river, not here.' `
      -mistake 'Folding the turn to "save the river decision": you pay for that comfort by over-folding against every double barrel.' `
      -takeaway 'Bluff-catchers are street-by-street contracts: call while the price and the range still justify it -- and stay ready to let go.'),
    (New-Node -street 'river' -facing 'River As. You check, BTN fires the third barrel, 75% pot' `
      -prompt 'River As. You check, BTN bets three-quarters pot -- the third barrel. Your play with Qc Jc?' `
      -choices @('fold','call','check_raise_small','check_raise_big') -best 'fold' -acc @() -bad @('call','check_raise_small') -crit @('check_raise_big') `
      -vBasis 'clear_direction' -reason 'board_change_river_fold' -stakeBasis 'large' -stakeBB 20 `
      -short 'The ace flips the hand: second pair folds to the triple barrel -- and folding SAVES the stack.' `
      -streetLogic 'The As is the one card the barrel range owned all along: every Ax he floated or barreled just became top pair, T-9 already made its straight on the turn, and your top pair is now second pair. The board changed; the hand''s job changed with it.' `
      -rangeCtx 'A 75% third barrel on the ace is value-dense: Ax top pairs, T9 straights, sets that slow-played -- plus a thin tail of busted 9x/6x. QJ beats only that tail. This is exactly the arrived-correctly-then-fold lesson: every prior street was right, AND the river fold is right.' `
      -handLogic 'Second pair under the ace beats busted air and nothing else that bets this big. Calling pays 20 BB to catch the thin bottom of a value-heavy range; raising does the same thing at a worse price.' `
      -sizLogic 'The fold is the profit: it saves the 20 BB the call would burn. The small check-raise bluffs into a range that just improved -- bad; the big check-raise turns second pair into a giant bluff into that same range -- the classic raise-into-crush catastrophe.' `
      -mistake 'Refusing to fold "after coming this far": the chips behind are the only chips that still have a choice. Sunk streets never justify the last call.' `
      -takeaway 'Arriving correctly and folding correctly is one skill, not two: the correct fold is the win -- watch the Saved-BB line say so.' `
      -blocker 'Your Qc and Jc block KQ and QT -- genuinely busted broadways -- and the Jc blocks JT, now a mere pair of jacks that does not pay a big bet. You block NONE of the value region: T9 and Ax are untouched. Blocking the folds while missing the value makes the call strictly worse, not better.')
  )
}
$trees += $treeB

# ============================================================================
# TREE C -- "The Bettor's Line" (BTN IP, seat-flip tree)
# hero Ad Kd -- board Ac 8s 4s / 6h / Qc
# ============================================================================
$treeC = [ordered]@{
  id = 'tree_c_bettors_line'
  version = 'v4.6.0'
  game = 'NLH_MTT'
  schemaVersion = 'tree-1.0.0'
  name = 'The Bettor''s Line'
  seat = 'BTN'
  spot = [ordered]@{ format='NLH_MTT'; stackDepth='100BB'; potType='SRP'; heroPosition='BTN'; villainPosition='BB' }
  heroHand = @('Ad','Kd')
  board = [ordered]@{ flopCards=@('Ac','8s','4s'); turnCard='6h'; riverCard='Qc' }
  preflopChartRow = 'BTN RFI 100BB: AKs = open-raise (ranges.json 100BB_BTN_RFI -- the strongest hand class in a ~46% opening range)'
  sourceConfidence = 'expert_judgment'
  auditStatus = 'review_pending'
  reviewStatus = 'v4.6.0_seed'
  nodes = @(
    (New-Node -street 'preflop' -facing 'Folded to you on the BTN' `
      -prompt 'Folded to you on the button with Ad Kd. What is your play?' `
      -choices @('fold','open25') -best 'open25' -acc @() -bad @() -crit @('fold') `
      -vBasis 'clear_direction' -reason 'preflop_chart_open' -stakeBasis 'street_preflop' -stakeBB 2 `
      -short 'AKs opens from every seat; folding it is the biggest preflop punt the game offers.' `
      -streetLogic 'The button opens roughly 46% of hands at 100BB; AKs is the strongest unpaired hand in the deck and sits at the very top of that chart.' `
      -rangeCtx 'The 100BB_BTN_RFI chart is the source of truth for this node: AKs = raise. There is no fold branch to reason about -- which is exactly why the chart, not per-hand feel, anchors the tree.' `
      -handLogic 'Suited, dominating, nut-making: AKs wins the kicker war against every Ax and Kx that continues behind.' `
      -sizLogic $null `
      -mistake 'There is none available but the catastrophic one: folding the top of your range.' `
      -takeaway 'Preflop is chart-play: the tree starts from the locked row, and every later street inherits that legitimacy.'),
    (New-Node -street 'flop' -facing 'Flop Ac 8s 4s. BB checks to you' `
      -prompt 'Flop Ac 8s 4s. BB checks. Your play with Ad Kd?' `
      -choices @('check_back','bet_small','bet_big') -best 'bet_small' -acc @() -bad @('check_back','bet_big') -crit @() `
      -vBasis 'clear_direction' -reason 'cbet_value_range_ip' -stakeBasis 'street_flop' -stakeBB 3 `
      -short 'Top pair top kicker range-bets small on the ace-high flop.' `
      -streetLogic 'A-high flops belong to the preflop raiser: the button c-bets this texture at a small size with nearly his whole range, and TPTK is the head of the value portion of that bet.' `
      -rangeCtx 'BB check-calls the small bet with worse Ax, 8x, pocket pairs and spade draws -- a wide continue range that pays three streets when it keeps top pair second-best.' `
      -handLogic 'AK on A-8-4 dominates every calling ace: AQ, AJ, AT and below all continue and all lose the kicker war. Betting starts the value clock; checking gives a free card to spades and wheels for nothing.' `
      -sizLogic 'Small is the range size on A-high boards: it taxes everything while folding out little you wanted around. Big folds out the dominated aces one street early; checking back top-top forfeits the driest value street.' `
      -mistake 'Slow-playing TPTK "to trap": on static A-high boards the trap catches nothing -- the dominated aces would have paid the small bet anyway.' `
      -takeaway 'Range-bet the ace-high flop small and let the dominated aces fund the hand.'),
    (New-Node -street 'turn' -facing 'Turn 6h. BB check-called the flop and checks again' `
      -prompt 'Turn 6h. BB called your c-bet and checks again. Your play with Ad Kd?' `
      -choices @('check_back','bet_small','bet_big') -best 'bet_big' -acc @('check_back') -bad @('bet_small') -crit @() `
      -vBasis 'clear_direction' -reason 'barrel_value_protection_ip' -stakeBasis 'street_turn' -stakeBB 5 `
      -short 'Barrel big: top-top charges the draws and the dominated aces at the same time.' `
      -streetLogic 'The 6h is close to a brick and the equity sources are explicit and countable: your MADE value is top pair top kicker, ahead of every one-pair hand that check-called; your DENIAL targets are the live spade flush draws, the 5-3 and 9-7 open-enders the low cards opened, and the bare 6x pairs that just arrived. Betting is value and protection in one motion -- no fold-equity story is needed to justify it.' `
      -rangeCtx 'BB''s check-call range is Ax-worse, 8x, spade draws and low connectors. One honest disclosure: 7-5 suited turned a straight (4-5-6-7-8) -- a thin, rare slice that check-raises part of the time; it does not outweigh the wide dominated region that pays the barrel.' `
      -handLogic 'AK beats AQ, AJ, AT, A9s and every 8x/6x; it charges Ks-Xs and 9s7s-type draws a bad price to continue. Every named region is visible combo work -- nothing about this barrel rests on a frequency.' `
      -sizLogic 'Big (~66%) is the point: the draws pay the wrong price and the dominated aces are too strong to fold. Small under-charges both; checking back is a defensible pot-control line but leaves the whole street to the draws for free.' `
      -mistake 'Barrelling "because you bet the flop": name the equity sources first -- here they are top-top value plus draw denial, which is why the barrel is clear.' `
      -takeaway 'A turn barrel should say out loud what it charges: made value plus denial, counted in combos, never in hidden frequencies.'),
    (New-Node -street 'river' -facing 'River Qc. BB check-called the turn and checks the river' `
      -prompt 'River Qc. BB called the turn barrel and now checks a third time. Your play with Ad Kd?' `
      -choices @('check_back','bet_small','bet_big','overbet') -best 'bet_small' -acc @('check_back') -bad @('bet_big','overbet') -crit @() `
      -vBasis 'clear_direction' -reason 'value_bet_thin_river' -stakeBasis 'small' -stakeBB 7 `
      -short 'Thin value, merged small: the dominated aces still pay a third of pot.' `
      -streetLogic 'The Qc promotes AQ to two pair and closes the spade story with a brick for the draws. AK is still the best one-pair hand on the board, and the bettor-seat river question is the M6 question: who calls, and at what price?' `
      -rangeCtx 'The callers-worse ladder is AJ, AT, A9s and stubborn 8x that refuses to believe you. The promoted region is AQ (rivered two pair), A6s (turned two pair) and the rare 7-5 straight; A8s/A4s flopped two pair but check-raise part of their combos earlier. The ladder below you remains the wider pool at a small price.' `
      -handLogic 'AK beats every calling ace below the queen and every pair; it loses to the short promoted list. Count, not fear: the dominated Ax combos comfortably outnumber the promotions when the price is small.' `
      -sizLogic 'A third of pot keeps AJ/AT/A9s in the calling pool -- the entire point of the hand. Big folds the ladder and isolates against AQ and better; the overbet is the worst of the sizing errors, turning three streets of clean value into a polar bet that only the hands beating you call. Checking back is acceptable but leaves the ladder untaxed.' `
      -mistake 'Sizing up on the river "to finish big": thin value dies the moment the size folds out the ladder it was built to tax.' `
      -takeaway 'The bettor''s last street is a counting exercise: dominated callers wide, promotions narrow, price small -- the M6 discipline, played at the end of a full hand.')
  )
}
$trees += $treeC

# ---------- emit ----------
$doc = [ordered]@{
  description = 'G6 v4.6.0 Continuous Hand -- 3 authored hand-trees (12 nodes), PLANNING-ONLY. Owner spine conditions baked: Tree A stone-nuts enumeration + draw-play turn (no trap language); Tree B river check-raise choices graded bad/critical + Saved-BB fold finale; Tree C turn equity sources named explicitly. Preflop nodes chart-sourced (Trees A/B: banked BB-vs-BTN baseline; Tree C: ranges.json 100BB_BTN_RFI). Production postflop_scenarios.json untouched.'
  generatedBy = 'tools/build-trees-v4.6.0.ps1'
  seedVersion = 'v4.6.0'
  schemaVersion = 'tree-1.0.0'
  count = $trees.Count
  trees = $trees
}
$json = $doc | ConvertTo-Json -Depth 14
$tmp = $outPath + '.tmp'
[System.IO.File]::WriteAllText($tmp, $json, [System.Text.UTF8Encoding]::new($false))
Move-Item -Force $tmp $outPath
Write-Output ('WROTE ' + $outPath + ' trees=' + $trees.Count + ' nodes=' + (($trees | ForEach-Object { $_.nodes.Count } | Measure-Object -Sum).Sum))
