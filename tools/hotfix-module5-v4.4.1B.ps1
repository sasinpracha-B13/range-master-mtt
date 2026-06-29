# ============================================================
# tools/hotfix-module5-v4.4.1B.ps1
# v4.4.1B Module 5 content/correctness hotfix (production count UNCHANGED: 509).
#
# Applies a consultant-reviewed + implementer-verified patch to 7 existing M5
# scenarios. NO scenarios added/removed. Idempotent (re-running sets the same
# values). UTF-8 NO-BOM, atomic tmp+Move-Item, no Invoke-Expression / unsafe rm.
#
# FIX 1  -- "critical" reserved for severe punts only. Downgrade one-pair
#           fold/call from critical -> bad (set answer.critical = []). 4 ids.
# FIX 2  -- Monotonicity on Ad 8s 5c 2h Kd overbet: the stronger ace (AhQc)
#           must continue >= the weaker ace (AhJc). Was reversed (AhJc=call,
#           AhQc=mixed). Now AhQc=call, AhJc=mixed.
# FIX 3  -- #12 (Ah9c on a 3-heart board) sizing large -> medium.
#
# IMPLEMENTER CORRECTIONS to the brief's stated math (verdicts kept; reasoning
# fixed): (a) hero's Ah does NOT block villain AK on Ad8s5c2hKd -- villain's AK
# uses Ac/As (Ad is on the board, Ah is hero's); the Ah only reduces villain AA.
# (b) On a 3-heart board a flush needs TWO hearts in hand, not one; the Ah blocks
# only the nut-flush (Ah-x) combos = a weak value-blocker. Explanations rewritten
# accordingly.
# ============================================================

[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)
$repo = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$target = Join-Path $repo 'postflop\postflop_scenarios.json'

$data = [System.IO.File]::ReadAllText($target, $utf8nb) | ConvertFrom-Json
$before = $data.scenarios.Count
function Get-Scn($id) { $s = $data.scenarios | Where-Object { $_.id -eq $id }; if (-not $s) { throw "Hotfix aborted: scenario not found: $id" }; return $s }

$P = 'pf_btn_v_bb_srp_100bb_river_'

# ---------------- FIX 1 -- critical -> [] (one-pair fold/call) ----------------
$fix1 = @(
  @{ id = ($P + 'Ks9d4c_7s_m5_action_KdQh_v440'); mustBeInBad = 'fold' },
  @{ id = ($P + 'Js8d5c_Ac_m5_action_KcJd_v440'); mustBeInBad = 'call' },
  @{ id = ($P + 'Qh9h4c_7h_m5_action_QcJs_v440'); mustBeInBad = 'call' },
  @{ id = ($P + '9d8c4h_7h_m5_action_Ad8d_v440'); mustBeInBad = 'call' },
  # found by the acceptance sweep "no one-pair fold/call carries critical" (consultant
  # listed only the 4 above; these 2 are the same pattern -- one-pair call, fold=critical):
  @{ id = ($P + 'Kd7s3c_7d_m5_action_KhJc_v440'); mustBeInBad = 'fold' },
  @{ id = ($P + 'Kd7s3c_7d_m5_action_QcJd_v440'); mustBeInBad = 'fold' }
)
foreach ($f in $fix1) {
  $s = Get-Scn $f.id
  $bad = @($s.answer.bad)
  if ($bad -notcontains $f.mustBeInBad) { $bad += $f.mustBeInBad }   # defensive; already present
  $s.answer.bad = [string[]]$bad
  $s.answer.critical = [string[]]@()
  $s.version = 'v4.4.1B'
}

# ---------------- FIX 2a -- AhQc: mixed -> call ----------------
$s = Get-Scn ($P + 'Ad8s5c_Kd_m5_action_AhQc_v440')
$s.recommendedAction = 'call'
$s.actionReason = 'bluff_catch_river'
$s.answer.best = 'call'
$s.answer.acceptable = [string[]]@('mixed')
$s.answer.bad = [string[]]@('fold','check_raise_small','check_raise_big')
$s.answer.critical = [string[]]@()
$s.blockerNote = "Top pair of aces, Q kicker, holding the Ah. The Ah removes two of villain's three remaining AA combos (Ad is on the board); it does NOT block AK, which uses Ac/As. AQ's edge over AJ is the kicker -- it beats villain's worse-ace value and chops AQ, so it is the stronger continue."
$s.explanation.short = "Top-pair ace, Q kicker: the stronger ace bluff-catches the K-scare overbet. AQ beats villain's worse-ace value and the bluffs, so folding over-folds."
$s.explanation.riverLogic = "The Kd is the second overcard; villain's overbet (~150% pot, BB needs ~37.5%) is polar -- AK two pair, sets and the rare AA/KK for value, plus busted draws. AQ beats every worse ace, every king-pair and all the bluffs, losing only to two-pair-plus. The Ah removes two of villain's three AA combos (it does not block AK, which never uses the Ah). AQ sits ABOVE the overbet threshold; AhJc, which also loses to villain AQ, is the hand right on it -- so calling is the higher-EV line."
$s.explanation.rangeContext = "BB called two streets with AQ. The overbet on the K is exactly where players over-fold; the strong kicker keeps AQ clearly in the continue region rather than a fold."
$s.explanation.handLogic = "AhQc is top pair, good kicker. Against the polar overbet it beats the bluffs and every worse ace villain can value-bet; only the kicker separates it from AJ, and that is enough to clear the threshold and call."
$s.explanation.commonMistake = "Auto-folding top pair to the K overbet is the leak; the stronger ace has to defend at this price."
$s.explanation.takeaway = "The stronger ace clears the overbet threshold -- call AQ; the weaker AJ is only a mix."
$s.version = 'v4.4.1B'

# ---------------- FIX 2b -- AhJc: call -> mixed ----------------
$s = Get-Scn ($P + 'Ad8s5c_Kd_m5_reason_AhJc_v440')
$s.recommendedAction = 'mixed'
$s.actionReason = 'mixed_indifference_river'
$s.answer.best = 'mixed_indifference_river'
$s.answer.acceptable = [string[]]@('bluff_catch_river')
$s.answer.critical = [string[]]@()
# answer.bad intentionally unchanged
$s.blockerNote = "Top pair of aces, J kicker, with the Ah. The Ah removes most of villain's AA combos (Ad on board); it does not block AK. AJ also loses to villain's AQ, so it is the weaker ace -- right at the overbet threshold."
$s.explanation.short = "Top pair, weak kicker (AJ) with the Ah vs a K-scare overbet -- the bottom of the defending ace class, a genuine call/fold mix."
$s.explanation.riverLogic = "The Kd overbet (~150% pot, BB needs ~37.5%) is polar: AK/sets/AA-KK for value, busted draws as bluffs. AhJc beats the bluffs and the worse aces, but unlike AhQc it also loses to villain's AQ value. The Ah reduces villain AA (it does not block AK). That extra losing combo puts AJ right at the ~37.5% indifference line -- a true call/fold mix, not a clean call."
$s.explanation.rangeContext = "AJ is the bottom of BB's defending ace class here. Folding it entirely over-folds; calling it always over-defends; the solver mixes. The over-fold trap is the secondary lesson -- the scariest sizing is where folding too much costs the most."
$s.explanation.handLogic = "AhJc is top pair, weak kicker. It is a clear notch below AQ -- it loses to villain AQ where AQ chops or wins -- so it sits at indifference: mix call and fold."
$s.explanation.commonMistake = "Treating AJ as a pure call or a pure fold -- at the overbet threshold it is genuinely mixed."
$s.explanation.takeaway = "The weakest defending ace vs an overbet is a mix, not a clean call; only the stronger kicker (AQ) clears the threshold outright."
$s.version = 'v4.4.1B'

# ---------------- FIX 3 -- Ah9c: large -> medium ----------------
$s = Get-Scn ($P + 'Qh9h4c_7h_m5_reason_Ah9c_v440')
$s.board.villainRiverSizing = 'medium'
$s.blockerNote = "Ah is the nut-flush blocker. On this three-heart board a flush needs TWO hearts in hand, so villain has many flush combos; the Ah removes only his nut-flush (Ah-x) combos -- a weak value-blocker, since his King-high and lower flushes remain."
$s.explanation.short = "Pair of nines holding the Ah on a three-heart river -- a blocker-driven call, but only against the medium sizing."
$s.explanation.riverLogic = "The 7h puts a third heart out; a flush now needs TWO hearts in hand, so villain has many flush combos. Hero's Ah blocks only the nut-flush (Ah-x) combos -- a weak value-blocker, because the King-high and lower flushes are unblocked. Pair of nines beats only the busted-heart and missed-straight bluffs."
$s.explanation.rangeContext = "Among equal bluff-catchers the one holding the key blocker continues -- but here the blocker is weak, so the sizing decides whether the call clears its price."
$s.explanation.sizingLogic = "Against a MEDIUM bet (~66% pot, BB needs ~29%) the pair-of-9 plus the nut-flush blocker clears the threshold by beating the busted bluffs. Against a POT bet the value range is too flush-dense for one weak blocker to matter -- there it would be a fold."
$s.explanation.handLogic = "Ah9c is only middle pair; the Ah is its whole case. Without it the hand folds; with it, against the medium sizing, villain has too few unblocked value combos relative to his bluffs, so hero defends."
$s.explanation.commonMistake = "Calling this versus a pot-sized bet 'because I hold the Ah' -- one weak blocker does not beat a flush-dense value range; the call is sizing-dependent."
$s.explanation.takeaway = "A weak nut-flush blocker turns second pair into a call against a medium bet, but not against a pot-sized one."
$s.version = 'v4.4.1B'

# ---------------- integrity + write ----------------
if ($data.scenarios.Count -ne $before) { throw "Hotfix aborted: scenario count changed ($before -> $($data.scenarios.Count))." }
$m5 = @($data.scenarios | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' })
if ($m5.Count -ne 32) { throw "Hotfix aborted: M5 count $($m5.Count), expected 32." }
if ($before -ne 509) { throw "Hotfix aborted: production base is $before, expected 509." }

# refresh top-level description to reflect the v4.4.1B correction layer
$desc = 'v4.4.1B - Module 5 correction layer on the v4.4.1A 509-scenario base (count unchanged). Fixes: critical-tier reserved for severe punts (one-pair fold/call downgraded to bad); AhQc/AhJc overbet monotonicity (stronger ace = call, weaker = mix) on Ad8s5c2hKd; #12 Ah9c sizing large->medium with corrected 3-heart-flush combinatorics. Total 509: 251 M1 + 49 M2 + 85 M3 + 92 M4 + 32 M5. M5 = BB river defense vs BTN third barrel, schemaVersion 1.3.0 per-scenario. Data-loaded + approved; M5 runtime-wired in v4.4.2. Spot context: BTN open 2.5x vs BB call, 100BB SRP, NLH MTT chipEV.'

if ($DryRun) {
  Write-Host "DRY RUN -- not writing. Patched 9 scenarios in memory; count=$($data.scenarios.Count), M5=$($m5.Count)." -ForegroundColor Yellow
} else {
  $newTarget = [ordered]@{}
  foreach ($p in $data.PSObject.Properties) {
    if ($p.Name -eq 'description') { $newTarget[$p.Name] = $desc }
    else { $newTarget[$p.Name] = $p.Value }
  }
  $json = ([PSCustomObject]$newTarget) | ConvertTo-Json -Depth 100
  $tmp = "$target.tmp"
  [System.IO.File]::WriteAllText($tmp, $json, $utf8nb)
  Move-Item -LiteralPath $tmp -Destination $target -Force
  Write-Host "Wrote $target ($((Get-Item $target).Length) bytes). Patched 9 scenarios. count=$($data.scenarios.Count) M5=$($m5.Count)." -ForegroundColor Cyan
}
