# migrate-module6-v4.5.2.ps1 -- M6 (River Betting IP) production migration.
# 510 -> 534: appends the 24 owner-approved v4.5.1 seeds to production
# postflop_scenarios.json (flip review_pending -> approved, version v4.5.2)
# and splices 12 module6 concepts into postflop_concepts.json (63 -> 75).
# Idempotent: safe to re-run (verify-only when M6 already migrated).
# Atomic UTF-8 no-BOM writes. Non-M6 rows verified data-identical post-merge.
# ASCII-only, PS 5.1 safe. No Invoke-Expression.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$prodPath = Join-Path $root 'postflop\postflop_scenarios.json'
$seedPath = Join-Path $root 'docs\specs\postflop-v4.5.1-module6-seeds.json'
$concPath = Join-Path $root 'postflop\postflop_concepts.json'
$utf8 = [System.Text.UTF8Encoding]::new($false)

function Read-Json($p) { [System.IO.File]::ReadAllText($p, $utf8) | ConvertFrom-Json }
function Write-Atomic($p, $text) {
  $tmp = $p + '.tmp'
  [System.IO.File]::WriteAllText($tmp, $text, $utf8)
  Move-Item -Force $tmp $p
}

# ---------- Phase 1: scenarios ----------
$prod = Read-Json $prodPath
$seeds = Read-Json $seedPath
$existingM6 = @($prod.scenarios | Where-Object { $_.module -eq 'pf_river_value_ip' })

if ($existingM6.Count -eq 24 -and $prod.scenarios.Count -eq 534) {
  Write-Output 'SCENARIOS: already migrated (534 with 24 M6) -- verify-only mode.'
} elseif ($existingM6.Count -ne 0) {
  throw ('ABORT: partial M6 state (' + $existingM6.Count + ' rows) -- manual inspection required.')
} else {
  if ($prod.scenarios.Count -ne 510) { throw ('ABORT: expected 510 production scenarios, found ' + $prod.scenarios.Count) }
  if (@($seeds.scenarios).Count -ne 24) { throw ('ABORT: expected 24 seeds, found ' + @($seeds.scenarios).Count) }

  # Pre-flight: no id collisions; every seed review_pending; module correct.
  $prodIds = @{}
  foreach ($s in $prod.scenarios) { $prodIds[$s.id] = $true }
  foreach ($s in $seeds.scenarios) {
    if ($prodIds.ContainsKey($s.id)) { throw ('ABORT: id collision ' + $s.id) }
    if ($s.module -ne 'pf_river_value_ip') { throw ('ABORT: bad module on ' + $s.id) }
    if ($s.auditStatus -ne 'review_pending') { throw ('ABORT: seed not review_pending: ' + $s.id) }
    if (@('clear_direction','mixed_nudge') -notcontains $s.verdictBasis) { throw ('ABORT: unapprovable verdictBasis on ' + $s.id) }
  }

  # Preservation snapshot: compact per-scenario JSON of all 510 BEFORE merge.
  $before = @{}
  foreach ($s in $prod.scenarios) { $before[$s.id] = ($s | ConvertTo-Json -Depth 12 -Compress) }

  # Flip + append.
  foreach ($s in $seeds.scenarios) {
    $s.auditStatus = 'approved'
    $s.reviewStatus = 'v4.5.1_strategic_reviewed'
    $s.version = 'v4.5.2'
  }
  $prod.scenarios = @($prod.scenarios) + @($seeds.scenarios)
  $prod.description = 'v4.5.2 - Module 6 FT content drop (+24). Total 534 scenarios: 251 M1 (board texture) + 49 M2 (flop c-bet IP) + 85 M3 (flop defense OOP) + 92 M4 (turn defense OOP) + 33 M5 (river defense OOP) + 24 M6 (river betting IP). M6 = BTN river bet/check decision IP after BB checks (seat mirror of M5), schemaVersion 1.4.0 per-scenario (verdictBasis + stakeBasis owner PINs). Debuts inside Tournament at Final Table depth via the pf_river_value_ip hook; curriculum wire follows in v4.5.3. Spot context: BTN open 2.5x vs BB call, 100BB SRP, NLH MTT chipEV.'

  $out = $prod | ConvertTo-Json -Depth 12

  # Post-merge verification BEFORE write: parse back, verify counts + preservation.
  $check = $out | ConvertFrom-Json
  if (@($check.scenarios).Count -ne 534) { throw 'ABORT: post-merge count != 534' }
  $m6 = @($check.scenarios | Where-Object { $_.module -eq 'pf_river_value_ip' })
  if ($m6.Count -ne 24) { throw 'ABORT: post-merge M6 != 24' }
  foreach ($s in $m6) {
    if ($s.auditStatus -ne 'approved') { throw ('ABORT: M6 not approved post-merge: ' + $s.id) }
  }
  $drift = 0
  foreach ($s in $check.scenarios) {
    if ($s.module -eq 'pf_river_value_ip') { continue }
    $now = ($s | ConvertTo-Json -Depth 12 -Compress)
    if ($before[$s.id] -ne $now) { $drift++; Write-Output ('DRIFT: ' + $s.id) }
  }
  if ($drift -ne 0) { throw ('ABORT: ' + $drift + ' non-M6 scenarios drifted -- write cancelled.') }

  Write-Atomic $prodPath $out
  Write-Output ('SCENARIOS: migrated 510 -> 534 (24 M6 approved; 510 non-M6 verified data-identical).')
}

# ---------- Phase 2: concepts (text splice, preserves existing bytes) ----------
$concRaw = [System.IO.File]::ReadAllText($concPath, $utf8)
if ($concRaw -match '"module6"') {
  Write-Output 'CONCEPTS: module6 already present -- skip.'
} else {
  $entries = @(
    '{ "key": "river_value_threshold", "displayName": "River value threshold", "category": "module6", "shortDef": "A river bet is value only if worse hands call more often than better hands; count the callers, not your hand strength.", "longDef": "The bettor-side river test: enumerate what calls each size. If the calling pool is majority-worse, bet; the wider that pool, the bigger the bet can be. Hand strength alone never justifies a value bet -- the calling range does.", "examples": ["Top two on a brick charges every Kx big.", "AQ on a paired river finds no worse callers and checks."], "relatedConcepts": ["thin_value_discipline","sizing_polarity"] }',
    '{ "key": "thin_value_discipline", "displayName": "Thin value discipline", "category": "module6", "shortDef": "Betting small enough that dominated hands still call; thin value dies the moment the size folds them out.", "longDef": "Thin value targets a narrow dominated ladder (worse kickers, worse pairs). The market is price-sensitive: a third of pot keeps the ladder in, polar sizes trade it away for exactly the hands that beat you. Always recount the ladder after connecting rivers.", "examples": ["AJ bets a third on A-8-5-2-7 to keep AT/A9 in.", "The 9 completes JT: AQ downshifts to the merge price."], "relatedConcepts": ["river_value_threshold","merged_sizing"] }',
    '{ "key": "bluff_candidate_selection", "displayName": "Bluff candidate selection", "category": "module6", "shortDef": "Rank bluffs by blockers and showdown value: zero-SDV hands that block calls and unblock folds bluff first.", "longDef": "Not every missed draw bluffs. The premier candidates hold cards that delete villain strongest continues (nut blockers) while leaving the folding region untouched, and have no showdown value to protect. Hands failing both tests go to the give-up pile.", "examples": ["Ah on a three-heart board is the classic overbet bluff.", "KJ blocks both the turned straight and the sturdiest top pair."], "relatedConcepts": ["nut_blocker_leverage","unblock_fold_region","give_up_discipline"] }',
    '{ "key": "nut_blocker_leverage", "displayName": "Nut blocker leverage", "category": "module6", "shortDef": "Holding the key card of villain strongest hand class removes it from the calling range and licenses maximum aggression.", "longDef": "On flush-completed or straight-completed rivers, the single card that makes villain nuts (the ace of the suit, the straight card) is worth more as removal than as showdown value. Nut-blocker bluffs size polar because the represented hand would.", "examples": ["Ah removes every nut flush from villain range.", "Holding the J halves villain JT turned straights."], "relatedConcepts": ["bluff_candidate_selection","sizing_polarity"] }',
    '{ "key": "unblock_fold_region", "displayName": "Unblock the fold region", "category": "module6", "shortDef": "A bluff profits from villain folds -- so the best bluffs do NOT hold the cards villain folds.", "longDef": "Counterintuitive selection rule: holding a busted-draw card that villain also uses for busted draws SHRINKS the folding region and hurts the bluff. The no-blocker busted draw is often the better candidate than the one that blocks the folds.", "examples": ["76 with no heart bluffs the missed-flush river better than a bare heart.", "KT blocking KJ/JT busted broadways disqualifies the bluff."], "relatedConcepts": ["bluff_candidate_selection","give_up_discipline"] }',
    '{ "key": "give_up_discipline", "displayName": "Give-up discipline", "category": "module6", "shortDef": "When the range is uncapped, the folds are blocked, or the story fails, the professional line is check and lose the minimum.", "longDef": "Bluff selection has a reject pile. Zero showdown value does not force a bluff: betting needs an audience that can fold and a story it believes. Give-ups keep the last bet in your stack -- in tournament terms, the difference between alive and out.", "examples": ["Missed gutter on a straight-heavy runout checks back.", "The scare-card overbet fails when villain range improved."], "relatedConcepts": ["story_consistency","unblock_fold_region"] }',
    '{ "key": "story_consistency", "displayName": "Story consistency", "category": "module6", "shortDef": "A river bet must represent a hand that would have played all three streets this way; inconsistent stories get called.", "longDef": "Every sizing tells a story. Flushes bet big on flush rivers, so flush-rep bluffs bet big; a small ''cheap'' bluff on that river tells no credible value story and gets called by every pair. Check whose range the river card helped before repping it.", "examples": ["The turned-A barrel rep fails when villain Ax called on purpose.", "Big polar sizing backs the missed-flush-draw story."], "relatedConcepts": ["give_up_discipline","sizing_polarity"] }',
    '{ "key": "sizing_polarity", "displayName": "Sizing polarity", "category": "module6", "shortDef": "Polar sizes (big/overbet) pair nut hands with bluffs; merged sizes (small) fit thin value. Match the size to the hand class.", "longDef": "The river size is a claim about your range. Near-nut hands and premier bluffs size up to press capped ranges; medium-strength value sizes down to keep dominated callers. Mis-pairing hand class and size -- polar with thin value, merge with the nuts -- is the core M6 sizing error.", "examples": ["Nut straight overbets the capped check-call range.", "TPTK downshifts after the river completes the gutter."], "relatedConcepts": ["merged_sizing","river_value_threshold","nut_blocker_leverage"] }',
    '{ "key": "merged_sizing", "displayName": "Merged sizing", "category": "module6", "shortDef": "The small-bet region that welcomes calls from many worse hands: thin value and protection-adjacent bets live here.", "longDef": "A merged bet expects to be called by a wide, mostly-worse continuum rather than to fold anything meaningful. It is the natural home of thin value. The moment the pool of worse callers narrows -- paired river, completed draws -- the merge loses its market and the hand checks.", "examples": ["A third-pot bet keeps every dominated ace in.", "KQ merges small on Q-7-4-J-2 against Qx/Jx."], "relatedConcepts": ["thin_value_discipline","sizing_polarity"] }',
    '{ "key": "checkback_showdown", "displayName": "Check-back showdown value", "category": "module6", "shortDef": "Hands that beat all the folds and lose to all the calls must check: betting converts a winner into a bluff.", "longDef": "The defining IP river shape: ace-high or a weak pair that wins exactly the showdowns against busted draws. Any bet folds out only what it already beats and gets called only by better. The two-question test -- does worse call, does better fold -- answers no twice.", "examples": ["A-high checks back and beats every busted gutter.", "Second pair with blocked callers takes the free showdown."], "relatedConcepts": ["river_value_threshold","trap_risk_paired_river"] }',
    '{ "key": "trap_risk_paired_river", "displayName": "Paired-river trap risk", "category": "module6", "shortDef": "A river that pairs a middle card promotes villain sticky mid-pairs to trips and deletes thin-value markets.", "longDef": "Paired rivers rewrite the calling list: the 7x that check-called two streets is now trips, and the thin bet that was fine on a brick now pays the trap. The bettor recounts callers on every paired runout before firing; pairing the TURN card is the worst version -- it strengthens exactly the hands that called the turn.", "examples": ["AQ checks back K-7-3-Q-7 as the 7x region turns trips.", "The paired 6 improves the check-call range, not the bluffer."], "relatedConcepts": ["checkback_showdown","thin_value_discipline"] }',
    '{ "key": "mixed_indifference_ip", "displayName": "Mixed indifference (IP river)", "category": "module6", "shortDef": "Genuine bettor-side indifference: two lines print the same, and only a combo or blocker argument nudges the split.", "longDef": "Some river combos sit exactly at the boundary -- thin-value bet vs check, or big vs small size. The app never invents frequencies for these: the verdict is ''mixed'', both members are acceptable, and the nudge is always a countable removal or kicker argument, never a percentage.", "examples": ["AJ at the thin-value boundary splits bet-small and check.", "AK splits sizes; the K-blocker tilts the mix toward big."], "relatedConcepts": ["thin_value_discipline","sizing_polarity"] }'
  )
  $conc = $concRaw | ConvertFrom-Json
  $preCount = @($conc.concepts).Count
  if ($preCount -ne 63) { throw ('ABORT: expected 63 concepts, found ' + $preCount) }
  # Splice before the closing "]\n}" tail, matching the M5 compact-line style.
  $tailRx = [regex]'\s*\]\s*\}\s*$'
  if (-not $tailRx.IsMatch($concRaw)) { throw 'ABORT: concepts tail pattern not found' }
  $joined = ($entries -join (",`n                     "))
  $insertion = ",`n                     " + $joined + "`n                 ]`n}`n"
  $newRaw = $tailRx.Replace($concRaw, $insertion, 1)
  $post = $newRaw | ConvertFrom-Json
  if (@($post.concepts).Count -ne 75) { throw ('ABORT: post-splice concepts != 75 (' + @($post.concepts).Count + ')') }
  $m6c = @($post.concepts | Where-Object { $_.category -eq 'module6' })
  if ($m6c.Count -ne 12) { throw 'ABORT: module6 concepts != 12' }
  Write-Atomic $concPath $newRaw
  Write-Output 'CONCEPTS: spliced 63 -> 75 (12 module6; existing bytes untouched above the tail).'
}
Write-Output 'MIGRATION COMPLETE.'
