# tools/build-m5-expansion-v4.4.1C.ps1
# v4.4.1C - Module 5 straight-blocker mix seed builder (1 scenario).
#
# Ships the straight-blocker lesson HONESTLY as mixed_indifference_river
# (NOT blocker_bluff_catch_river): a straight-blocker is a two-sided ~25%
# nudge, never the one-sided 100% lock of the nut-flush Ah.
#
# Board Jc 9d 8s / 4h / 2c, hero Th 9h. Independent derivation (implementer):
#   - Straights on J-9-8-4-2: QT (Q-J-T-9-8, nut) and T7 (J-T-9-8-7) ONLY;
#     both require a ten; no one-card straights; all other straights need
#     3+ hand cards. Hero's Th removes 1 of 4 tens = ~25% of each.
#   - TWO-SIDED: busted open-enders KT / AT use the same tens, so the
#     blocker removes bluffs too; the value:bluff ratio barely moves.
#   - Suit lock: flop Jc 9d 8s is RAINBOW -> no flush draw ever existed on
#     this runout; hero hearts touch only the 4h. Lesson is straight-only.
#   - Hero = pair of nines (second pair under the J), NO straight
#     (J-T-9-8 was an open-ender needing Q or 7; the 2c missed it).
#   - Verdict: beats every busted draw, loses to every value hand, below
#     the median bluff-catcher (Jx/TT) at the ~29% medium-bet price ->
#     genuine call/fold mix.
#   - T9s is a pure BB flat vs a BTN 2.5x open; flop pair+OESD and turn
#     OESD-live make the two calls automatic, so the river spot is real.
#
# auditStatus  = planning_only
# reviewStatus = v4.4.1C_expansion_candidate
# ASCII-only (no em-dash) to avoid CP874 mojibake.

$ErrorActionPreference = 'Stop'
$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$outPath  = Join-Path $repoRoot 'docs\specs\postflop-v4.4.1C-module5-expansion-seeds.json'

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
$reasonChoices = @(
  'pot_odds_river_call','bluff_catch_river','blocker_bluff_catch_river','mdf_defense_river',
  'thin_value_call_river','value_raise_river','bluff_raise_river','range_disadvantage_river_fold',
  'domination_river_fold','board_change_river_fold','missed_draw_give_up','mixed_indifference_river'
)

$board = [PSCustomObject]([ordered]@{
  flopCards           = @('Jc','9d','8s')
  turnCard            = '4h'
  riverCard           = '2c'
  cards               = @('Jc','9d','8s','4h','2c')
  boardKind           = 'J_high'
  suitTextureFlop     = 'rainbow'
  suitTextureTurn     = 'rainbow'
  suitTextureRiver    = 'two_tone'
  textureTags         = @('connected','wet')
  highCardClass       = 'J_high'
  riverCategory       = 'brick'
  boardChange         = 'brick'
  runoutTexture       = 'straight_possible'
  riverDrawCompletion = 'none'
  villainRiverSizing  = 'medium'
})

$scenario = [PSCustomObject]([ordered]@{
  id                = 'pf_btn_v_bb_srp_100bb_river_Jc9d8s_2c_m5_reason_Th9h_v441c'
  module            = 'pf_river_barrel_oop_def'
  moduleName        = 'Facing River Barrel OOP'
  schemaVersion     = '1.3.0'
  spot              = [PSCustomObject]([ordered]@{} + $spotTemplate)
  board             = $board
  heroHand          = @('Th','9h')
  handClass         = 'second_pair'
  heroHandRole      = 'marginal_made_hand'
  drawCategory      = 'none'
  showdownValue     = 'low'
  blockerNote       = 'Holds the Th: the only straights on this board (QT, T7) both need a ten, so hero trims each by about a quarter. But the busted open-enders KT and AT use the same tens, so the blocker cuts bluffs too -- a two-sided nudge, unlike the Ah on a flush board.'
  recommendedAction = 'mixed'
  actionReason      = 'mixed_indifference_river'
  question          = [PSCustomObject]([ordered]@{
    qtype   = 'reason_choice'
    prompt  = "Flop Jc 9d 8s; turn 4h; river 2c. BB calls Th 9h vs BTN's two-thirds-pot river bet. What is the primary reason?"
    choices = $reasonChoices
  })
  answer            = [PSCustomObject]([ordered]@{
    best       = 'mixed_indifference_river'
    acceptable = @('bluff_catch_river')
    bad        = @('pot_odds_river_call','blocker_bluff_catch_river','mdf_defense_river','thin_value_call_river',
                   'value_raise_river','bluff_raise_river','range_disadvantage_river_fold','domination_river_fold',
                   'board_change_river_fold','missed_draw_give_up')
    critical   = @()
  })
  explanation       = [PSCustomObject]([ordered]@{
    short         = 'Second pair with the T straight-blocker vs a medium third barrel -- a genuine call/fold mix; the blocker is a nudge, not the reason.'
    riverLogic    = 'The 2c is a brick: no flush ever existed on this rainbow-flop runout, and the only straights (QT and T7, both live since the J-9-8 flop) need a ten. Hero''s Th removes one of villain''s four tens -- about a quarter of the QT and T7 value -- but the busted open-enders KT and AT use the same tens, so the blocker removes bluffs as well. Value and bluffs shrink together and the ratio barely moves: pair of nines beats every busted draw, loses to every value hand, and sits right at the ~29% price a two-thirds bet sets. That is indifference, not a blocker-driven call.'
    rangeContext  = 'Vs a medium bet BB defends roughly 60% of its range, filled first by straights, two pair, Jx and TT. Pair of nines is below that median, exactly where MDF runs out -- the textbook mixing region.'
    handLogic     = 'T9s arrived as second pair plus an open-ended draw (J-T-9-8 needed a Q or a 7), called flop and turn naturally, and missed. At showdown it is a pure bluff-catcher: it beats KQ, AQ, KT, AT, 76 and every other busted draw, and loses to all Jx, TT, two pair, sets and straights. Compare Q9s: same pair of nines, and its Q still trims the QT nut straight -- both hands end up mixing, which shows that no single straight-card removes enough combos to flip a verdict.'
    sizingLogic   = $null
    commonMistake = 'Treating the Th like the Ah on a three-flush board and calling purely because of the blocker. Picking blocker_bluff_catch_river here overrates a two-sided 25% effect: on a flush board the Ah deletes 100% of the nut flush and blocks no bluffs; a straight-blocker cuts a quarter of the straights AND a share of the busted open-enders.'
    takeaway      = 'A straight-blocker is one of four cards and sits on both sides of villain''s range -- a two-sided ~25% nudge that turns close hands into mixes, never the one-sided 100% lock of the nut-flush Ah.'
  })
  conceptTags       = @('river_blocker_defense','river_bluff_catcher','third_barrel_defense')
  sourceConfidence  = 'expert_judgment'
  difficultyHint    = 4
  auditStatus       = 'planning_only'
  reviewStatus      = 'v4.4.1C_expansion_candidate'
  uniquenessNote    = 'The straight-blocker analogue of the Ah lesson taught HONESTLY as a mix: two-sided ~25% removal is a nudge, contrasting the one-sided 100% nut-flush blocker (Ah9c scenario). Also the first M5 brick river on a straight-possible runout.'
})

$root = [ordered]@{
  schemaVersion  = '1.3.0'
  moduleId       = 'pf_river_barrel_oop_def'
  moduleName     = 'Facing River Barrel OOP'
  version        = 'v4.4.1C'
  status         = 'planning_only'
  generatedAt    = '2026-06-18'
  notes          = 'v4.4.1C single-seed layer: the straight-blocker lesson shipped honestly as mixed_indifference_river (blocker = two-sided ~25% nudge), closing the straight-blocker curriculum gap without overstating blocker_bluff_catch_river. NOT loaded at runtime. Migration to production after review.'
  expansionStats = [ordered]@{ totalScenarios = 1; boards = 1; actionChoice = 0; reasonChoice = 1 }
  scenarios      = @($scenario)
}

$json = $root | ConvertTo-Json -Depth 100
$utf8nb = [System.Text.UTF8Encoding]::new($false)
$tmp = "$outPath.tmp"
[System.IO.File]::WriteAllText($tmp, $json, $utf8nb)
Move-Item -LiteralPath $tmp -Destination $outPath -Force
Write-Host ("Wrote 1 v4.4.1C seed to " + $outPath)
