# ============================================================
# tools/audit-postflop-module4-continuation-v4.3.2.ps1
# v4.3.2 M4 Coverage Continuation Seed Auditor
#
# Validates docs/specs/postflop-v4.3.2-module4-continuation-seeds.json
# against M4 schema rules + continuation-specific guards.
#
# Mirrors tools/audit-postflop-module4-polish-v4.3.0D.ps1 with
# continuation-aware adjustments:
#   - id pattern ends with _v432
#   - reviewStatus = v4.3.2_continuation_candidate
#   - cross-corpus duplicate-ID check vs production AND vs v4.3.0D polish AND vs v4.3.0C expansion
#   - cross-corpus drift check (CR.R03 style; meaningful pre AND post migration)
#   - bidirectional nut_flush_draw WARN (R71)
#   - text-integrity HARD on self-correction artifacts (R72)
#   - reason_choice answer-id integrity HARD (R44b; mirrors prod R04)
#
# Safety: ASCII-only, no Invoke-Expression, no Remove-Item.
# ============================================================

$ErrorActionPreference = 'Stop'
$utf8nb = [System.Text.UTF8Encoding]::new($false)

$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$contPath      = Join-Path $repoRoot 'docs\specs\postflop-v4.3.2-module4-continuation-seeds.json'
$polishPath    = Join-Path $repoRoot 'docs\specs\postflop-v4.3.0D-module4-polish-seeds.json'
$expansionPath = Join-Path $repoRoot 'docs\specs\postflop-v4.3.0C-module4-expansion-seeds.json'
$productionPath = Join-Path $repoRoot 'postflop\postflop_scenarios.json'

$hardErrors = New-Object System.Collections.Generic.List[string]
$warnings   = New-Object System.Collections.Generic.List[string]

function Add-Hard([string]$rule, [string]$where, [string]$msg) {
  $hardErrors.Add("[$rule] HARD -- $where -- $msg") | Out-Null
}
function Add-Warn([string]$rule, [string]$where, [string]$msg) {
  $warnings.Add("[$rule] WARN -- $where -- $msg") | Out-Null
}

# ---------- Load files ----------
foreach ($p in @($contPath, $polishPath, $expansionPath, $productionPath)) {
  if (-not (Test-Path $p)) {
    Write-Host "[CR.R01] HARD -- TOP -- file not found: $p" -ForegroundColor Red
    exit 1
  }
}

$contText      = [System.IO.File]::ReadAllText($contPath, $utf8nb)
$polishText    = [System.IO.File]::ReadAllText($polishPath, $utf8nb)
$expansionText = [System.IO.File]::ReadAllText($expansionPath, $utf8nb)
$prodText      = [System.IO.File]::ReadAllText($productionPath, $utf8nb)
$cont = $null; $polish = $null; $expansion = $null; $prod = $null
try { $cont      = $contText      | ConvertFrom-Json } catch { Add-Hard 'CR.R01' 'TOP' "continuation JSON parse failed: $_" }
try { $polish    = $polishText    | ConvertFrom-Json } catch { Add-Hard 'CR.R01' 'TOP' "polish JSON parse failed: $_" }
try { $expansion = $expansionText | ConvertFrom-Json } catch { Add-Hard 'CR.R01' 'TOP' "expansion JSON parse failed: $_" }
try { $prod      = $prodText      | ConvertFrom-Json } catch { Add-Hard 'CR.R01' 'TOP' "production JSON parse failed: $_" }
if ($hardErrors.Count -gt 0) {
  foreach ($e in $hardErrors) { Write-Host $e -ForegroundColor Red }
  exit 1
}

# ---------- Approved enums (mirror v4.3.0D polish auditor) ----------
$approvedTurnCategory = @(
  'brick','overcard','flush_complete','flush_draw_added','straight_complete','straight_draw_added',
  'board_pair','draw_intensifier','top_pair_changer','ace_overcard','low_blank','high_blank'
)
$approvedBoardChange = @(
  'brick','range_shift_btn','range_shift_bb','polarizing','counterfeit',
  'draw_added','static','dynamic'
)
$approvedEquityShift = @(
  'neutral','favors_btn','favors_bb','polarizes_btn',
  'improves_bb_draws','completes_bb_draws','counterfeits_bb_pairs'
)
$approvedDrawCompletion = @(
  'none','flush_completed','straight_completed','flush_draw_added','straight_draw_added',
  'oesd_added','gutshot_added','multi_draw_added','no_change'
)
$approvedPairStatusChange = @(
  'no_change','flop_card_paired','paired_top','paired_middle','paired_bottom',
  'double_paired','trips_possible'
)
$approvedHeroHandRole = @(
  'strong_value','nutted_value','bluff_catcher','marginal_made_hand','dominated_marginal',
  'combo_draw','draw','give_up','air','bluff_candidate','blocker_bluff',
  'slowplay_trap','protection_needed'
)
$approvedActionReason = @(
  'pot_odds_turn_call','equity_realization_turn_call','bluff_catch_turn',
  'board_change_fold','domination_turn_fold','range_disadvantage_turn_fold',
  'value_check_raise_turn','protection_check_raise_turn','semi_bluff_check_raise_turn',
  'blocker_check_raise_turn','slowplay_turn_call','mixed_indifference_turn'
)
$approvedConceptTags = @(
  'turn_equity_shift','second_barrel_defense','turn_pot_odds','turn_bluff_catcher',
  'turn_domination_fold','turn_board_change','turn_draw_completion',
  'turn_check_raise_value','turn_check_raise_bluff','turn_blocker_pressure',
  'turn_slowplay_call','turn_range_disadvantage'
)
$approvedSourceConfidence = @('solver_aligned','theory_consensus','consensus_gto','expert_judgment','heuristic','mixed_uncertain')
$approvedActionMenu = @('fold','call','check_raise_small','check_raise_big','mixed')
$approvedHandClass = @('set','top_two_pair','two_pair','overpair','underpair',
                       'top_pair_top_kicker','top_pair_good_kicker','top_pair_weak_kicker',
                       'second_pair','third_pair_or_lower','mid_pair','bottom_pair',
                       'combo_draw','oesd','gutshot','flush_draw','nut_flush_draw',
                       'backdoor_only','no_pair_no_draw','straight','flush','nut_flush','trips','full_house')
$approvedDrawCats  = @('none','backdoor_only','gutshot','oesd','flush_draw','combo_draw','nut_flush_draw',
                       'straight_draw_added','flush_draw_added','oesd_added','gutshot_added','multi_draw_added')
$approvedShowdown  = @('none','low','decent','high','nutted')
$cardRegex = '^[2-9TJQKA][cdhs]$'
$idRegex   = '^pf_btn_v_bb_srp_100bb_turn_[a-zA-Z0-9]+_[0-9a-zA-Z]+_m4_(action|reason)_[A-Za-z0-9_]+_v432$'

# ---------- TOP-level checks ----------
if ($cont.moduleId -ne 'pf_turn_barrel_oop_def') { Add-Hard 'CR.R02' 'TOP' "moduleId expected pf_turn_barrel_oop_def, got '$($cont.moduleId)'" }
if ($cont.schemaVersion -ne '1.2.0') { Add-Hard 'CR.R02' 'TOP' "schemaVersion expected '1.2.0'" }
if (-not ([string]$cont.version).StartsWith('v4.3.2')) { Add-Hard 'CR.R02' 'TOP' "version expected to start with v4.3.2, got '$($cont.version)'" }
if ($cont.status -ne 'planning_only') { Add-Hard 'CR.R02' 'TOP' "status expected 'planning_only', got '$($cont.status)'" }
if (-not ($cont.scenarios -is [System.Array])) { Add-Hard 'CR.R02' 'TOP' "scenarios is not an array" }

$contScenarios = @($cont.scenarios)
$polishScenarios = @($polish.scenarios)
$expansionScenarios = @($expansion.scenarios)
$prodScenarios = @($prod.scenarios)
$prodIds = $prodScenarios | ForEach-Object { $_.id }
$contIds = $contScenarios | ForEach-Object { $_.id }
$polishIds = $polishScenarios | ForEach-Object { $_.id }
$expansionIds = $expansionScenarios | ForEach-Object { $_.id }

# ---------- Cross-corpus content sync / drift check (CR.R03) ----------
$prodById = @{}
foreach ($ps in $prodScenarios) { if ($ps.id) { $prodById[$ps.id] = $ps } }

function Compare-ScalarField($a, $b) {
  if ($null -eq $a -and $null -eq $b) { return $true }
  if ($null -eq $a -or  $null -eq $b) { return $false }
  return ([string]$a -ceq [string]$b)
}
function Compare-ArrayField($a, $b) {
  $aa = @($a); $bb = @($b)
  if ($aa.Count -ne $bb.Count) { return $false }
  for ($i = 0; $i -lt $aa.Count; $i++) {
    if (-not (Compare-ScalarField $aa[$i] $bb[$i])) { return $false }
  }
  return $true
}

foreach ($contId in $contIds) {
  if (-not ($prodIds -contains $contId)) { continue }
  $ps = $prodById[$contId]
  $contS = $contScenarios | Where-Object { $_.id -eq $contId } | Select-Object -First 1
  if ($null -eq $ps -or $null -eq $contS) { continue }
  $diffs = New-Object System.Collections.Generic.List[string]
  if (-not (Compare-ScalarField $ps.recommendedAction $contS.recommendedAction)) { $diffs.Add('recommendedAction') | Out-Null }
  if (-not (Compare-ScalarField $ps.actionReason      $contS.actionReason))      { $diffs.Add('actionReason') | Out-Null }
  if (-not (Compare-ScalarField $ps.drawCategory      $contS.drawCategory))      { $diffs.Add('drawCategory') | Out-Null }
  if (-not (Compare-ScalarField $ps.handClass         $contS.handClass))         { $diffs.Add('handClass') | Out-Null }
  if (-not (Compare-ScalarField $ps.heroHandRole      $contS.heroHandRole))      { $diffs.Add('heroHandRole') | Out-Null }
  if (-not (Compare-ScalarField $ps.showdownValue     $contS.showdownValue))     { $diffs.Add('showdownValue') | Out-Null }
  if (-not (Compare-ScalarField $ps.blockerNote       $contS.blockerNote))       { $diffs.Add('blockerNote') | Out-Null }
  if ($ps.explanation -and $contS.explanation) {
    foreach ($k in 'short','turnLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway') {
      if (-not (Compare-ScalarField $ps.explanation.$k $contS.explanation.$k)) { $diffs.Add("explanation.$k") | Out-Null }
    }
  } elseif ($null -ne $ps.explanation -or $null -ne $contS.explanation) {
    $diffs.Add('explanation') | Out-Null
  }
  if (-not (Compare-ArrayField $ps.conceptTags $contS.conceptTags)) { $diffs.Add('conceptTags') | Out-Null }
  if ($diffs.Count -gt 0) {
    Add-Hard 'CR.R03' $contId ("continuation source / production drift on fields: " + ($diffs -join ','))
  }
}

# Within-continuation duplicate ID check
$dupContIds = $contIds | Group-Object | Where-Object { $_.Count -gt 1 }
foreach ($d in $dupContIds) {
  Add-Hard 'CR.R04' 'TOP' "duplicate id within continuation '$($d.Name)' x$($d.Count)"
}

# Cross-corpus duplicate vs v4.3.0C expansion + v4.3.0D polish (HARD: continuation IDs must not collide)
foreach ($contId in $contIds) {
  if ($expansionIds -contains $contId) {
    Add-Hard 'CR.R05' $contId "continuation ID collides with v4.3.0C expansion ID"
  }
  if ($polishIds -contains $contId) {
    Add-Hard 'CR.R05' $contId "continuation ID collides with v4.3.0D polish ID"
  }
}

# ---------- Per-scenario loop ----------
$catCounts = @{}
$catQtypeCounts = @{}

foreach ($s in $contScenarios) {
  $sid = if ($s.id) { $s.id } else { '<no id>' }

  # M4.R09 -- id naming convention (v4.3.2 variant)
  if ($s.id -and ($s.id -notmatch $idRegex)) {
    Add-Hard 'M4.R09' $sid "id does not match expected pattern (must end with _v432)"
  }

  if ($s.module -ne 'pf_turn_barrel_oop_def') { Add-Hard 'M4.R10' $sid "module expected 'pf_turn_barrel_oop_def'" }
  if ($s.schemaVersion -ne '1.2.0') { Add-Hard 'M4.R11' $sid "schemaVersion expected '1.2.0'" }
  if ($s.auditStatus -ne 'planning_only') { Add-Hard 'M4.R12' $sid "auditStatus expected 'planning_only'" }
  if ($s.reviewStatus -ne 'v4.3.2_continuation_candidate') { Add-Hard 'M4.R13' $sid "reviewStatus expected 'v4.3.2_continuation_candidate', got '$($s.reviewStatus)'" }

  # uniquenessNote required (anti-filler)
  if (-not $s.uniquenessNote) {
    Add-Hard 'M4.R14' $sid 'missing uniquenessNote'
  } elseif ($s.uniquenessNote.Length -lt 30) {
    Add-Hard 'M4.R14' $sid "uniquenessNote too short ($($s.uniquenessNote.Length) chars; threshold 30)"
  }

  # Spot block
  if (-not $s.spot) { Add-Hard 'M4.R15' $sid 'missing spot' } else {
    if ($s.spot.format -ne 'NLH_MTT') { Add-Hard 'M4.R16' $sid "spot.format" }
    if ($s.spot.stackDepth -ne '100BB') { Add-Hard 'M4.R16' $sid "spot.stackDepth" }
    if ($s.spot.heroPosition -ne 'BB') { Add-Hard 'M4.R17' $sid "spot.heroPosition" }
    if ($s.spot.villainPosition -ne 'BTN') { Add-Hard 'M4.R17' $sid "spot.villainPosition" }
    if ($s.spot.street -ne 'turn') { Add-Hard 'M4.R18' $sid "spot.street" }
    if ($s.spot.heroRole -ne 'flop_check_caller_oop') { Add-Hard 'M4.R19' $sid "spot.heroRole" }
    if ($s.spot.villainRole -ne 'turn_barreler_ip') { Add-Hard 'M4.R19' $sid "spot.villainRole" }
  }

  # Board block
  if (-not $s.board) { Add-Hard 'M4.R20' $sid 'missing board' } else {
    $fc = @($s.board.flopCards)
    if ($fc.Count -ne 3) { Add-Hard 'M4.R21' $sid "flopCards count $($fc.Count) (expected 3)" }
    foreach ($c in $fc) { if ($c -notmatch $cardRegex) { Add-Hard 'M4.R21' $sid "invalid flop card '$c'" } }
    if ($s.board.turnCard -notmatch $cardRegex) { Add-Hard 'M4.R22' $sid "invalid turnCard '$($s.board.turnCard)'" }
    $cards = @($s.board.cards)
    if ($cards.Count -ne 4) { Add-Hard 'M4.R23' $sid "board.cards count $($cards.Count)" }
    $u = ($cards | Sort-Object -Unique).Count
    if ($u -ne $cards.Count) { Add-Hard 'M4.R24' $sid "duplicate cards in board" }
    if ($approvedTurnCategory -notcontains $s.board.turnCategory) { Add-Hard 'M4.R25' $sid "turnCategory '$($s.board.turnCategory)'" } else {
      if (-not $catCounts.ContainsKey($s.board.turnCategory)) { $catCounts[$s.board.turnCategory] = 0 }
      $catCounts[$s.board.turnCategory]++
    }
    if ($approvedBoardChange -notcontains $s.board.boardChange) { Add-Hard 'M4.R26' $sid "boardChange '$($s.board.boardChange)'" }
    if ($approvedEquityShift -notcontains $s.board.equityShift) { Add-Hard 'M4.R27' $sid "equityShift '$($s.board.equityShift)'" }
    if ($approvedDrawCompletion -notcontains $s.board.drawCompletion) { Add-Hard 'M4.R28' $sid "drawCompletion '$($s.board.drawCompletion)'" }
    if ($approvedPairStatusChange -notcontains $s.board.pairStatusChange) { Add-Hard 'M4.R29' $sid "pairStatusChange '$($s.board.pairStatusChange)'" }
  }

  # Hero hand
  $hh = @($s.heroHand)
  if ($hh.Count -ne 2) { Add-Hard 'M4.R30' $sid "heroHand count $($hh.Count)" } else {
    foreach ($c in $hh) { if ($c -notmatch $cardRegex) { Add-Hard 'M4.R30' $sid "invalid hero card '$c'" } }
    if ($s.board -and $s.board.cards) {
      foreach ($hc in $hh) { if (@($s.board.cards) -contains $hc) { Add-Hard 'M4.R31' $sid "hero card '$hc' collides with board" } }
    }
  }
  if ($approvedHeroHandRole -notcontains $s.heroHandRole) { Add-Hard 'M4.R32' $sid "heroHandRole '$($s.heroHandRole)'" }
  if ($s.handClass -and ($approvedHandClass -notcontains $s.handClass)) { Add-Hard 'M4.R32' $sid "handClass '$($s.handClass)'" }
  if ($s.drawCategory -and ($approvedDrawCats -notcontains $s.drawCategory)) { Add-Hard 'M4.R32' $sid "drawCategory '$($s.drawCategory)'" }
  if ($s.showdownValue -and ($approvedShowdown -notcontains $s.showdownValue)) { Add-Hard 'M4.R32' $sid "showdownValue '$($s.showdownValue)'" }

  # Question
  $qtype = $null
  if (-not $s.question) { Add-Hard 'M4.R33' $sid 'missing question' } else {
    $qtype = $s.question.qtype
    if ($qtype -ne 'action_choice' -and $qtype -ne 'reason_choice') { Add-Hard 'M4.R34' $sid "qtype '$qtype'" }
    if ($qtype -eq 'action_choice') {
      $ch = @($s.question.choices) | Sort-Object
      $exp2 = $approvedActionMenu | Sort-Object
      if (($ch -join ',') -ne ($exp2 -join ',')) { Add-Hard 'M4.R35' $sid "action_choice choices mismatch" }
      if ($s.question.prompt -match 'with\s*$') { Add-Hard 'M4.R50' $sid "prompt ends with 'with '" }
      if ($s.heroHand -and $s.heroHand.Count -eq 2 -and $s.question.prompt) {
        $foundBoth = $true
        foreach ($c in $s.heroHand) { if ($s.question.prompt -notmatch [regex]::Escape($c)) { $foundBoth = $false; break } }
        if (-not $foundBoth) { Add-Hard 'M4.R51' $sid "prompt does not contain both hero cards" }
      }
    }
    if ($qtype -eq 'reason_choice') {
      $ch = @($s.question.choices)
      if ($ch.Count -lt 3 -or $ch.Count -gt 12) { Add-Hard 'M4.R36' $sid "reason_choice count $($ch.Count)" } else {
        foreach ($c in $ch) { if ($approvedActionReason -notcontains $c) { Add-Hard 'M4.R36' $sid "reason_choice option '$c'" } }
      }
    }
    if ($s.board -and $s.board.turnCategory -and $qtype) {
      $key = "$($s.board.turnCategory)/$qtype"
      if (-not $catQtypeCounts.ContainsKey($key)) { $catQtypeCounts[$key] = 0 }
      $catQtypeCounts[$key]++
    }
  }

  # recommendedAction + actionReason
  if ($approvedActionMenu -notcontains $s.recommendedAction) { Add-Hard 'M4.R37' $sid "recommendedAction '$($s.recommendedAction)'" }
  if ($approvedActionReason -notcontains $s.actionReason) { Add-Hard 'M4.R38' $sid "actionReason '$($s.actionReason)'" }

  # Answer
  if (-not $s.answer) { Add-Hard 'M4.R39' $sid 'missing answer' } else {
    if ($qtype -eq 'action_choice') {
      if (-not ($s.answer.best -is [string])) { Add-Hard 'M4.R40' $sid "answer.best not string" }
      elseif ($approvedActionMenu -notcontains $s.answer.best) { Add-Hard 'M4.R40' $sid "answer.best '$($s.answer.best)'" }
      if ($s.recommendedAction -ne $s.answer.best) { Add-Hard 'M4.R41' $sid "recommendedAction != answer.best" }
      $bestArr = @($s.answer.best)
      $accArr  = @($s.answer.acceptable) | Where-Object { $_ }
      $badArr  = @($s.answer.bad) | Where-Object { $_ }
      $coverage = ($bestArr + $accArr + $badArr) | Sort-Object -Unique
      $expSorted = $approvedActionMenu | Sort-Object
      if (($coverage -join ',') -ne ($expSorted -join ',')) { Add-Hard 'M4.R43' $sid "best+acceptable+bad don't cover 5-action menu (got [$($coverage -join ',')])" }
      $primary = $bestArr + $accArr + $badArr
      $dups = $primary | Group-Object | Where-Object { $_.Count -gt 1 }
      foreach ($d in $dups) { Add-Hard 'M4.R42' $sid "action '$($d.Name)' in multiple primary partitions" }
      $critArr = @($s.answer.critical) | Where-Object { $_ }
      foreach ($c in $critArr) { if ($badArr -notcontains $c) { Add-Hard 'M4.R42' $sid "critical '$c' not in bad" } }
    } elseif ($qtype -eq 'reason_choice') {
      if ($s.question -and $s.question.choices -and -not (@($s.question.choices) -contains $s.answer.best)) {
        Add-Hard 'M4.R44' $sid "answer.best '$($s.answer.best)' not in question.choices"
      }
      # M4.R44b -- all answer.{acceptable, bad, critical} entries must also appear in question.choices
      if ($s.question -and $s.question.choices) {
        $rcChoices = @($s.question.choices)
        foreach ($field in 'acceptable','bad','critical') {
          $arr = @($s.answer.$field) | Where-Object { $_ }
          foreach ($v in $arr) {
            if (-not ($rcChoices -contains $v)) {
              Add-Hard 'M4.R44b' $sid "answer.$field entry '$v' not in question.choices (reason_choice answers must reference reason ids only)"
            }
          }
        }
        if (@($s.answer.critical) | Where-Object { $_ }) {
          Add-Warn 'M4.R44b' $sid 'reason_choice has non-empty answer.critical -- by convention reason_choice critical is empty (diagnostic misses are not severe punts)'
        }
      }
    }
  }

  # Explanation
  if (-not $s.explanation) { Add-Hard 'M4.R45' $sid 'missing explanation' } else {
    foreach ($k in 'short','turnLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway') {
      if (-not $s.explanation.$k) { Add-Hard 'M4.R45' $sid "explanation missing key '$k'" }
    }
    if ($s.explanation.turnLogic -and $s.explanation.turnLogic.Length -lt 60) {
      Add-Warn 'M4.R45' $sid "turnLogic short ($($s.explanation.turnLogic.Length) chars)"
    }
  }

  # conceptTags
  $ct = @($s.conceptTags)
  if ($ct.Count -lt 1 -or $ct.Count -gt 4) { Add-Hard 'M4.R46' $sid "conceptTags count $($ct.Count)" } else {
    $tagSeen = @{}
    foreach ($t in $ct) {
      if ($approvedConceptTags -notcontains $t) { Add-Hard 'M4.R46' $sid "conceptTag '$t' not in M4 vocab" }
      if ($tagSeen.ContainsKey("$t")) { Add-Hard 'M4.R46' $sid "duplicate conceptTag '$t'" }
      $tagSeen["$t"] = $true
    }
  }

  if ($approvedSourceConfidence -notcontains $s.sourceConfidence) { Add-Hard 'M4.R47' $sid "sourceConfidence '$($s.sourceConfidence)'" }

  # R52 nut_flush_draw invariant
  if ($s.drawCategory -eq 'nut_flush_draw' -and $s.heroHand -and $s.board -and $s.board.cards) {
    $hh2 = @($s.heroHand)
    $bc = @($s.board.cards)
    $foundNutFD = $false
    foreach ($suit in 'cdhs'.ToCharArray()) {
      $sc = [string]$suit
      $heroHasA = ($hh2 -contains "A$sc")
      $heroSuitCount = (@($hh2) | Where-Object { $_.Length -eq 2 -and $_.Substring(1,1) -eq $sc }).Count
      $boardSuitCount = (@($bc) | Where-Object { $_.Length -eq 2 -and $_.Substring(1,1) -eq $sc }).Count
      $totalSuit = $heroSuitCount + $boardSuitCount
      if ($heroHasA -and $totalSuit -eq 4) { $foundNutFD = $true; break }
    }
    if (-not $foundNutFD) { Add-Hard 'M4.R52' $sid "drawCategory=nut_flush_draw but no A-of-suit + 4-suit total" }
  }

  # R53 nut-suit blocker invariant
  if ($s.heroHandRole -eq 'blocker_bluff' -and $s.blockerNote -and $s.heroHand) {
    $hh3 = @($s.heroHand)
    $bn = $s.blockerNote
    $suitMap = @{ 'spade'='s'; 'heart'='h'; 'club'='c'; 'diamond'='d' }
    foreach ($word in $suitMap.Keys) {
      if ($bn -match "nut[- ]$word") {
        $sc = $suitMap[$word]
        if (-not ($hh3 -contains "A$sc")) { Add-Hard 'M4.R53' $sid "blockerNote claims nut-$word but hero doesn't hold A$sc" }
      }
    }
  }

  # R54 handClass=straight invariant
  if ($s.handClass -eq 'straight' -and $s.heroHand -and $s.board -and $s.board.cards) {
    $hh4 = @($s.heroHand)
    $bc = @($s.board.cards)
    $allCards = $hh4 + $bc
    $rankOrder = @('2','3','4','5','6','7','8','9','T','J','Q','K','A')
    $rankSet = New-Object System.Collections.Generic.HashSet[int]
    foreach ($c in $allCards) {
      if ($c.Length -ge 2) {
        $r = $c.Substring(0,1)
        $idx = $rankOrder.IndexOf($r)
        if ($idx -ge 0) { $null = $rankSet.Add($idx) }
      }
    }
    $foundStraight = $false
    foreach ($start in 0..8) {
      $allIn = $true
      foreach ($k in 0..4) { if (-not $rankSet.Contains($start + $k)) { $allIn = $false; break } }
      if ($allIn) { $foundStraight = $true; break }
    }
    if ((-not $foundStraight) -and $rankSet.Contains(12) -and $rankSet.Contains(0) -and $rankSet.Contains(1) -and $rankSet.Contains(2) -and $rankSet.Contains(3)) { $foundStraight = $true }
    if (-not $foundStraight) { Add-Hard 'M4.R54' $sid "handClass=straight but no 5 consecutive ranks" }
  }

  # R71 BIDIRECTIONAL nut_flush_draw WARN
  if ($s.heroHand -and $s.board -and $s.board.cards -and $s.drawCategory -ne 'nut_flush_draw' `
      -and $s.handClass -ne 'flush' -and $s.handClass -ne 'nut_flush' -and $s.handClass -ne 'full_house' `
      -and $s.handClass -ne 'set' -and $s.handClass -ne 'two_pair' -and $s.handClass -ne 'top_two_pair' `
      -and $s.handClass -ne 'straight' -and $s.handClass -ne 'trips') {
    $hh5 = @($s.heroHand)
    $bc = @($s.board.cards)
    foreach ($suit in 'cdhs'.ToCharArray()) {
      $sc = [string]$suit
      $heroHasA = ($hh5 -contains "A$sc")
      if (-not $heroHasA) { continue }
      $heroSuitCount = (@($hh5) | Where-Object { $_.Length -eq 2 -and $_.Substring(1,1) -eq $sc }).Count
      $boardSuitCount = (@($bc) | Where-Object { $_.Length -eq 2 -and $_.Substring(1,1) -eq $sc }).Count
      $totalSuit = $heroSuitCount + $boardSuitCount
      if ($totalSuit -eq 4) {
        Add-Warn 'M4.R71' $sid "hero holds A$sc with 4 of suit but drawCategory='$($s.drawCategory)' (expected nut_flush_draw)"
        break
      }
    }
  }

  # R72 TEXT-INTEGRITY HARD: detect unresolved self-correction artifacts
  $r72Patterns = @(
    ' wait ', ' wait,', ' wait.', ' wait;', ' wait:', ' wait?', ' wait!',
    'wait needs', 'wait need ', 'actually impossible', '... wait', '...wait'
  )
  if ($s.explanation) {
    foreach ($k in 'short','turnLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway') {
      $v = $s.explanation.$k
      if ($null -ne $v -and ($v -is [string]) -and $v.Length -gt 0) {
        $vLower = $v.ToLowerInvariant()
        foreach ($pat in $r72Patterns) {
          if ($vLower.Contains($pat.ToLowerInvariant())) {
            Add-Hard 'M4.R72' $sid ("explanation.$k contains self-correction artifact '" + $pat.Trim() + "' -- unresolved authoring draft prose")
            break
          }
        }
      }
    }
  }
  if ($null -ne $s.blockerNote -and ($s.blockerNote -is [string]) -and $s.blockerNote.Length -gt 0) {
    $bnLower = $s.blockerNote.ToLowerInvariant()
    foreach ($pat in $r72Patterns) {
      if ($bnLower.Contains($pat.ToLowerInvariant())) {
        Add-Hard 'M4.R72' $sid ("blockerNote contains self-correction artifact '" + $pat.Trim() + "' -- unresolved authoring draft prose")
        break
      }
    }
  }
}

# ============================================================
# REPORT
# ============================================================
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " M4 CONTINUATION SEED AUDIT  --  v4.3.2" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

if ($hardErrors.Count -gt 0) {
  Write-Host "HARD ERRORS:" -ForegroundColor Red
  foreach ($e in $hardErrors) { Write-Host "  $e" -ForegroundColor Red }
  Write-Host ""
}
if ($warnings.Count -gt 0) {
  Write-Host "WARNINGS:" -ForegroundColor Yellow
  foreach ($w in $warnings) { Write-Host "  $w" -ForegroundColor Yellow }
  Write-Host ""
}

$result = if ($hardErrors.Count -eq 0) { 'PASS' } else { 'FAIL' }
$color  = if ($hardErrors.Count -eq 0) { 'Green' } else { 'Red' }

Write-Host "Continuation seed audit summary:" -ForegroundColor Cyan
Write-Host ("  scenarios   = {0}" -f $contScenarios.Count)
Write-Host ("  hard errors = {0}" -f $hardErrors.Count)
Write-Host ("  warnings    = {0}" -f $warnings.Count)
Write-Host ("  result      = {0}" -f $result) -ForegroundColor $color
Write-Host ""

# Distribution outputs
Write-Host "--- Distribution ($($contScenarios.Count) continuation scenarios) ---" -ForegroundColor Cyan
Write-Host ""
Write-Host "By turnCategory:"
$contScenarios | ForEach-Object { $_.board.turnCategory } | Group-Object | Sort-Object Name | ForEach-Object { Write-Host ("  {0,-22} {1}" -f $_.Name, $_.Count) }
Write-Host ""
Write-Host "By qtype:"
$contScenarios | ForEach-Object { $_.question.qtype } | Group-Object | Sort-Object Name | ForEach-Object { Write-Host ("  {0,-22} {1}" -f $_.Name, $_.Count) }
Write-Host ""
Write-Host "By recommendedAction:"
$contScenarios | ForEach-Object { $_.recommendedAction } | Group-Object | Sort-Object Name | ForEach-Object { Write-Host ("  {0,-22} {1}" -f $_.Name, $_.Count) }
Write-Host ""
Write-Host "By actionReason:"
$contScenarios | ForEach-Object { $_.actionReason } | Group-Object | Sort-Object Name | ForEach-Object { Write-Host ("  {0,-32} {1}" -f $_.Name, $_.Count) }
Write-Host ""
Write-Host "By heroHandRole:"
$contScenarios | ForEach-Object { $_.heroHandRole } | Group-Object | Sort-Object Name | ForEach-Object { Write-Host ("  {0,-22} {1}" -f $_.Name, $_.Count) }
Write-Host ""

$critCount = (@($contScenarios | Where-Object { @($_.answer.critical).Count -gt 0 })).Count
$pct = if ($contScenarios.Count -gt 0) { [math]::Round(100.0 * $critCount / $contScenarios.Count, 1) } else { 0 }
Write-Host "Critical-flag scenarios:  $critCount of $($contScenarios.Count) ($pct%)" -ForegroundColor Cyan
Write-Host ""

if ($hardErrors.Count -gt 0) { exit 1 } else { exit 0 }
