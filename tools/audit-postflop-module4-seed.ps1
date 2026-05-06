# ============================================================
# audit-postflop-module4-seed.ps1
# v4.3.0 -- Module 4 (Turn Barrel OOP Defense) seed auditor
# Validates docs/specs/postflop-v4.3.0-module4-seed-scenarios.json
# against the M4 seed audit plan rules M4.R01..M4.R49.
# Planning-only auditor -- does NOT touch production data.
# ASCII-only. UTF-8 NO-BOM read. PowerShell 5.1 compatible.
# ============================================================

$ErrorActionPreference = 'Stop'

$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$seedPath = Join-Path $repoRoot 'docs\specs\postflop-v4.3.0-module4-seed-scenarios.json'

$hardErrors = New-Object System.Collections.Generic.List[string]
$warnings   = New-Object System.Collections.Generic.List[string]

function Add-Hard([string]$rule, [string]$where, [string]$msg) {
  $hardErrors.Add("[$rule] HARD -- $where -- $msg") | Out-Null
}
function Add-Warn([string]$rule, [string]$where, [string]$msg) {
  $warnings.Add("[$rule] WARN -- $where -- $msg") | Out-Null
}

# ---------- M4.R01 -- file parseable JSON ----------
if (-not (Test-Path $seedPath)) {
  Write-Host "[M4.R01] HARD -- TOP -- seed file not found: $seedPath" -ForegroundColor Red
  exit 1
}
$rawText = $null
try {
  $rawText = [System.IO.File]::ReadAllText($seedPath, [System.Text.UTF8Encoding]::new($false))
} catch {
  Write-Host "[M4.R01] HARD -- TOP -- cannot read file: $_" -ForegroundColor Red
  exit 1
}
$j = $null
try {
  $j = $rawText | ConvertFrom-Json
} catch {
  Write-Host "[M4.R01] HARD -- TOP -- JSON parse failed: $_" -ForegroundColor Red
  exit 1
}

# ---------- M4.R02 -- required top-level keys ----------
$requiredTop = @('moduleId','moduleName','version','status','schemaVersion','generatedAt','scenarios')
$topProps = ($j.PSObject.Properties.Name)
foreach ($k in $requiredTop) {
  if ($topProps -notcontains $k) { Add-Hard 'M4.R02' 'TOP' "missing top-level key: $k" }
}

# ---------- M4.R03 -- moduleId ----------
if ($j.moduleId -ne 'pf_turn_barrel_oop_def') {
  Add-Hard 'M4.R03' 'TOP' "moduleId expected 'pf_turn_barrel_oop_def', got '$($j.moduleId)'"
}

# ---------- M4.R04 -- schemaVersion ----------
if ($j.schemaVersion -ne '1.2.0') {
  Add-Hard 'M4.R04' 'TOP' "top-level schemaVersion expected '1.2.0', got '$($j.schemaVersion)'"
}

# ---------- M4.R05 -- version starts with v4.3.0 ----------
if (-not ([string]$j.version).StartsWith('v4.3.0')) {
  Add-Hard 'M4.R05' 'TOP' "version should start with 'v4.3.0', got '$($j.version)'"
}

# ---------- M4.R06 -- status ----------
if ($j.status -ne 'planning_only') {
  Add-Hard 'M4.R06' 'TOP' "status expected 'planning_only', got '$($j.status)'"
}

# ---------- M4.R07 -- 24 scenarios ----------
if (-not ($j.scenarios -is [System.Array])) {
  Add-Hard 'M4.R07' 'TOP' "scenarios is not an array"
} elseif ($j.scenarios.Count -ne 24) {
  Add-Hard 'M4.R07' 'TOP' "scenarios count expected 24, got $($j.scenarios.Count)"
}

# ---------- approved enums ----------
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
  'oesd_added','gutshot_added','multi_draw_added'
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
$approvedSourceConfidence = @('solver_aligned','theory_consensus','expert_judgment','heuristic','mixed_uncertain')
$approvedActionMenu = @('fold','call','check_raise_small','check_raise_big','mixed')
$cardRegex = '^[2-9TJQKA][cdhs]$'
$idRegex   = '^pf_btn_v_bb_srp_100bb_turn_[a-zA-Z0-9]+_[0-9a-zA-Z]+_m4_(action|reason)_[A-Za-z0-9_]+_v430$'

# ---------- per-scenario loop ----------
$ids = New-Object System.Collections.Generic.List[string]
$catCounts = @{}
$catQtypeCounts = @{}

foreach ($s in $j.scenarios) {
  $id = if ($s.id) { $s.id } else { '<no id>' }
  $sid = $id

  # M4.R08 -- id present (uniqueness checked after loop)
  if (-not $s.id) { Add-Hard 'M4.R08' $sid 'missing id' }
  else { $ids.Add($s.id) | Out-Null }

  # M4.R09 -- id naming
  if ($s.id -and ($s.id -notmatch $idRegex)) {
    Add-Hard 'M4.R09' $sid "id does not match expected pattern"
  }

  # M4.R10 -- module field
  if ($s.module -ne 'pf_turn_barrel_oop_def') {
    Add-Hard 'M4.R10' $sid "module expected 'pf_turn_barrel_oop_def', got '$($s.module)'"
  }

  # M4.R11 -- schemaVersion
  if ($s.schemaVersion -ne '1.2.0') {
    Add-Hard 'M4.R11' $sid "schemaVersion expected '1.2.0', got '$($s.schemaVersion)'"
  }

  # M4.R12 -- auditStatus
  if ($s.auditStatus -ne 'planning_only') {
    Add-Hard 'M4.R12' $sid "auditStatus expected 'planning_only', got '$($s.auditStatus)'"
  }

  # M4.R13 -- reviewStatus
  if ($s.reviewStatus -ne 'v4.3.0_seed_candidate') {
    Add-Hard 'M4.R13' $sid "reviewStatus expected 'v4.3.0_seed_candidate', got '$($s.reviewStatus)'"
  }

  # M4.R14 -- uniquenessNote
  if (-not $s.uniquenessNote) {
    Add-Hard 'M4.R14' $sid 'missing uniquenessNote'
  } elseif ($s.uniquenessNote.Length -lt 20) {
    Add-Hard 'M4.R14' $sid "uniquenessNote too short ($($s.uniquenessNote.Length) chars)"
  }

  # ----- spot block -----
  if (-not $s.spot) {
    Add-Hard 'M4.R15' $sid 'missing spot block'
  } else {
    $spotReq = @('format','stackDepth','potType','preflopAction','flopAction','turnAction',
                 'street','heroPosition','villainPosition','heroRole','villainRole')
    $spotProps = $s.spot.PSObject.Properties.Name
    foreach ($k in $spotReq) {
      if ($spotProps -notcontains $k) { Add-Hard 'M4.R15' $sid "spot missing key: $k" }
    }
    # M4.R16 -- format + stackDepth
    if ($s.spot.format -ne 'NLH_MTT') { Add-Hard 'M4.R16' $sid "spot.format expected 'NLH_MTT', got '$($s.spot.format)'" }
    if ($s.spot.stackDepth -ne '100BB') { Add-Hard 'M4.R16' $sid "spot.stackDepth expected '100BB', got '$($s.spot.stackDepth)'" }
    # M4.R17 -- hero/villain position
    if ($s.spot.heroPosition -ne 'BB') { Add-Hard 'M4.R17' $sid "spot.heroPosition expected 'BB', got '$($s.spot.heroPosition)'" }
    if ($s.spot.villainPosition -ne 'BTN') { Add-Hard 'M4.R17' $sid "spot.villainPosition expected 'BTN', got '$($s.spot.villainPosition)'" }
    # M4.R18 -- street + potType
    if ($s.spot.street -ne 'turn') { Add-Hard 'M4.R18' $sid "spot.street expected 'turn', got '$($s.spot.street)'" }
    if ($s.spot.potType -ne 'SRP') { Add-Hard 'M4.R18' $sid "spot.potType expected 'SRP', got '$($s.spot.potType)'" }
    # M4.R19 -- roles
    if ($s.spot.heroRole -ne 'flop_check_caller_oop') { Add-Hard 'M4.R19' $sid "spot.heroRole expected 'flop_check_caller_oop', got '$($s.spot.heroRole)'" }
    if ($s.spot.villainRole -ne 'turn_barreler_ip') { Add-Hard 'M4.R19' $sid "spot.villainRole expected 'turn_barreler_ip', got '$($s.spot.villainRole)'" }
  }

  # ----- board block -----
  if (-not $s.board) {
    Add-Hard 'M4.R20' $sid 'missing board block'
  } else {
    $boardReq = @('flopCards','turnCard','cards','boardKind','suitTextureFlop','suitTextureTurn',
                  'turnCategory','boardChange','equityShift','drawCompletion','pairStatusChange')
    $bProps = $s.board.PSObject.Properties.Name
    foreach ($k in $boardReq) {
      if ($bProps -notcontains $k) { Add-Hard 'M4.R20' $sid "board missing key: $k" }
    }

    # M4.R21 -- flopCards
    $fc = @($s.board.flopCards)
    if ($fc.Count -ne 3) {
      Add-Hard 'M4.R21' $sid "board.flopCards count expected 3, got $($fc.Count)"
    } else {
      foreach ($c in $fc) {
        if ($c -notmatch $cardRegex) { Add-Hard 'M4.R21' $sid "invalid flop card: '$c'" }
      }
    }
    # M4.R22 -- turnCard
    if ($s.board.turnCard -notmatch $cardRegex) {
      Add-Hard 'M4.R22' $sid "invalid turnCard: '$($s.board.turnCard)'"
    }
    # M4.R23 -- cards = flop + turn
    $cards = @($s.board.cards)
    if ($cards.Count -ne 4) {
      Add-Hard 'M4.R23' $sid "board.cards count expected 4, got $($cards.Count)"
    } else {
      $expected = @($fc) + @($s.board.turnCard)
      $expectedJoin = ($expected -join ',')
      $actualJoin = ($cards -join ',')
      if ($expectedJoin -ne $actualJoin) {
        Add-Hard 'M4.R23' $sid "board.cards != flopCards+turnCard ($actualJoin vs $expectedJoin)"
      }
    }
    # M4.R24 -- no card collision
    $allBoardCards = $cards
    $u = ($allBoardCards | Sort-Object -Unique).Count
    if ($u -ne $allBoardCards.Count) {
      Add-Hard 'M4.R24' $sid "duplicate cards in board: $($allBoardCards -join ',')"
    }

    # M4.R25 -- turnCategory
    if ($approvedTurnCategory -notcontains $s.board.turnCategory) {
      Add-Hard 'M4.R25' $sid "turnCategory '$($s.board.turnCategory)' not in approved enum"
    } else {
      if (-not $catCounts.ContainsKey($s.board.turnCategory)) { $catCounts[$s.board.turnCategory] = 0 }
      $catCounts[$s.board.turnCategory]++
    }

    # M4.R26 -- boardChange
    if ($approvedBoardChange -notcontains $s.board.boardChange) {
      Add-Hard 'M4.R26' $sid "boardChange '$($s.board.boardChange)' not in approved enum"
    }
    # M4.R27 -- equityShift
    if ($approvedEquityShift -notcontains $s.board.equityShift) {
      Add-Hard 'M4.R27' $sid "equityShift '$($s.board.equityShift)' not in approved enum"
    }
    # M4.R28 -- drawCompletion
    if ($approvedDrawCompletion -notcontains $s.board.drawCompletion) {
      Add-Hard 'M4.R28' $sid "drawCompletion '$($s.board.drawCompletion)' not in approved enum"
    }
    # M4.R29 -- pairStatusChange
    if ($approvedPairStatusChange -notcontains $s.board.pairStatusChange) {
      Add-Hard 'M4.R29' $sid "pairStatusChange '$($s.board.pairStatusChange)' not in approved enum"
    }
  }

  # ----- hero hand + role -----
  $hh = @($s.heroHand)
  if ($hh.Count -ne 2) {
    Add-Hard 'M4.R30' $sid "heroHand count expected 2, got $($hh.Count)"
  } else {
    foreach ($c in $hh) {
      if ($c -notmatch $cardRegex) { Add-Hard 'M4.R30' $sid "invalid hero card: '$c'" }
    }
    # M4.R31 -- hero/board collision
    if ($s.board -and $s.board.cards) {
      $boardSet = @($s.board.cards)
      foreach ($hc in $hh) {
        if ($boardSet -contains $hc) { Add-Hard 'M4.R31' $sid "hero card '$hc' collides with board" }
      }
    }
  }
  # M4.R32 -- heroHandRole
  if ($approvedHeroHandRole -notcontains $s.heroHandRole) {
    Add-Hard 'M4.R32' $sid "heroHandRole '$($s.heroHandRole)' not in approved vocab"
  }

  # ----- question -----
  $qtype = $null
  if (-not $s.question) {
    Add-Hard 'M4.R33' $sid 'missing question block'
  } else {
    $qReq = @('qtype','prompt','choices')
    $qProps = $s.question.PSObject.Properties.Name
    foreach ($k in $qReq) {
      if ($qProps -notcontains $k) { Add-Hard 'M4.R33' $sid "question missing key: $k" }
    }
    $qtype = $s.question.qtype
    # M4.R34 -- qtype enum
    if ($qtype -ne 'action_choice' -and $qtype -ne 'reason_choice') {
      Add-Hard 'M4.R34' $sid "qtype '$qtype' not in {action_choice,reason_choice}"
    }
    # M4.R35 -- 5-action menu for action_choice
    if ($qtype -eq 'action_choice') {
      $ch = @($s.question.choices) | Sort-Object
      $exp = $approvedActionMenu | Sort-Object
      if (($ch -join ',') -ne ($exp -join ',')) {
        Add-Hard 'M4.R35' $sid "action_choice choices mismatch: got [$($s.question.choices -join ',')]"
      }
    }
    # M4.R36 -- reason_choice 3..12 strings, all in actionReason vocab
    if ($qtype -eq 'reason_choice') {
      $ch = @($s.question.choices)
      if ($ch.Count -lt 3 -or $ch.Count -gt 12) {
        Add-Hard 'M4.R36' $sid "reason_choice choices count $($ch.Count) outside [3,12]"
      } else {
        foreach ($c in $ch) {
          if (-not ($c -is [string])) {
            Add-Hard 'M4.R36' $sid "reason_choice non-string element"
          } elseif ($approvedActionReason -notcontains $c) {
            Add-Hard 'M4.R36' $sid "reason_choice option '$c' not in actionReason vocab"
          }
        }
      }
    }

    # category x qtype tally
    if ($s.board -and $s.board.turnCategory -and $qtype) {
      $key = "$($s.board.turnCategory)/$qtype"
      if (-not $catQtypeCounts.ContainsKey($key)) { $catQtypeCounts[$key] = 0 }
      $catQtypeCounts[$key]++
    }
  }

  # ----- recommendedAction + actionReason -----
  if ($approvedActionMenu -notcontains $s.recommendedAction) {
    Add-Hard 'M4.R37' $sid "recommendedAction '$($s.recommendedAction)' not in 5-action menu"
  }
  if ($approvedActionReason -notcontains $s.actionReason) {
    Add-Hard 'M4.R38' $sid "actionReason '$($s.actionReason)' not in M4-approved vocab"
  }

  # ----- answer -----
  if (-not $s.answer) {
    Add-Hard 'M4.R39' $sid 'missing answer block'
  } else {
    $ansReq = @('best','acceptable','bad','critical')
    $aProps = $s.answer.PSObject.Properties.Name
    foreach ($k in $ansReq) {
      if ($aProps -notcontains $k) { Add-Hard 'M4.R39' $sid "answer missing key: $k" }
    }

    if ($qtype -eq 'action_choice') {
      # M4.R40 -- best is single string in 5-action menu
      if (-not ($s.answer.best -is [string])) {
        Add-Hard 'M4.R40' $sid "answer.best not a string"
      } elseif ($approvedActionMenu -notcontains $s.answer.best) {
        Add-Hard 'M4.R40' $sid "answer.best '$($s.answer.best)' not in 5-action menu"
      }
      # M4.R41 -- recommendedAction == answer.best
      if ($s.recommendedAction -ne $s.answer.best) {
        Add-Hard 'M4.R41' $sid "recommendedAction '$($s.recommendedAction)' != answer.best '$($s.answer.best)'"
      }
      # M4.R43 -- partition coverage = full menu via best+acc+bad
      $bestArr = @()
      if ($s.answer.best -is [string]) { $bestArr = @($s.answer.best) }
      $accArr  = @($s.answer.acceptable) | Where-Object { $_ }
      $badArr  = @($s.answer.bad) | Where-Object { $_ }
      $coverage = ($bestArr + $accArr + $badArr) | Sort-Object -Unique
      $expSorted = $approvedActionMenu | Sort-Object
      if (($coverage -join ',') -ne ($expSorted -join ',')) {
        Add-Hard 'M4.R43' $sid "best+acceptable+bad don't cover 5-action menu (got [$($coverage -join ',')])"
      }

      # M4.R42a -- best/acceptable/bad disjoint
      $primary = $bestArr + $accArr + $badArr
      $dups = $primary | Group-Object | Where-Object { $_.Count -gt 1 }
      foreach ($d in $dups) {
        Add-Hard 'M4.R42' $sid "action '$($d.Name)' appears in multiple primary partitions (best/acceptable/bad)"
      }
      # M4.R42b -- critical is subset of bad
      $critArr = @($s.answer.critical) | Where-Object { $_ }
      foreach ($c in $critArr) {
        if ($badArr -notcontains $c) {
          Add-Hard 'M4.R42' $sid "critical action '$c' is not in 'bad' (critical must be subset of bad)"
        }
      }
    } elseif ($qtype -eq 'reason_choice') {
      # M4.R44 -- best is one of the choices
      if ($s.question -and $s.question.choices) {
        $choicesSet = @($s.question.choices)
        if (-not ($choicesSet -contains $s.answer.best)) {
          Add-Hard 'M4.R44' $sid "answer.best '$($s.answer.best)' not in question.choices"
        }
      }
    }
  }

  # ----- explanation -----
  if (-not $s.explanation) {
    Add-Hard 'M4.R45' $sid 'missing explanation block'
  } else {
    $expReq = @('short','turnLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')
    $eProps = $s.explanation.PSObject.Properties.Name
    foreach ($k in $expReq) {
      if ($eProps -notcontains $k) { Add-Hard 'M4.R45' $sid "explanation missing key: $k" }
    }
    if ($s.explanation.turnLogic -and $s.explanation.turnLogic.Length -lt 60) {
      Add-Warn 'M4.R45' $sid "turnLogic short ($($s.explanation.turnLogic.Length) chars)"
    }
  }

  # ----- conceptTags -----
  $ct = @($s.conceptTags)
  if ($ct.Count -lt 1 -or $ct.Count -gt 4) {
    Add-Hard 'M4.R46' $sid "conceptTags count $($ct.Count) outside [1,4]"
  } else {
    foreach ($t in $ct) {
      if ($approvedConceptTags -notcontains $t) {
        Add-Hard 'M4.R46' $sid "conceptTag '$t' not in approved vocab"
      }
    }
  }

  # ----- sourceConfidence -----
  if ($approvedSourceConfidence -notcontains $s.sourceConfidence) {
    Add-Hard 'M4.R47' $sid "sourceConfidence '$($s.sourceConfidence)' not in approved set"
  }
}

# ---------- M4.R08 -- id uniqueness ----------
$dupIds = $ids | Group-Object | Where-Object { $_.Count -gt 1 }
foreach ($d in $dupIds) {
  Add-Hard 'M4.R08' 'TOP' "duplicate id '$($d.Name)' x$($d.Count)"
}

# ---------- M4.R48 -- six categories x 4 ----------
$expectedCats = @('brick','overcard','flush_complete','straight_complete','board_pair','draw_intensifier')
foreach ($cat in $expectedCats) {
  $count = if ($catCounts.ContainsKey($cat)) { $catCounts[$cat] } else { 0 }
  if ($count -ne 4) {
    Add-Hard 'M4.R48' 'TOP' "turnCategory '$cat' expected 4 scenarios, got $count"
  }
}

# ---------- M4.R49 -- category x qtype distribution ----------
foreach ($cat in $expectedCats) {
  $aKey = "$cat/action_choice"
  $rKey = "$cat/reason_choice"
  $aN = if ($catQtypeCounts.ContainsKey($aKey)) { $catQtypeCounts[$aKey] } else { 0 }
  $rN = if ($catQtypeCounts.ContainsKey($rKey)) { $catQtypeCounts[$rKey] } else { 0 }
  if ($aN -lt 2) { Add-Hard 'M4.R49' 'TOP' "category '$cat' has $aN action_choice (expected >= 2)" }
  if ($rN -lt 1) { Add-Hard 'M4.R49' 'TOP' "category '$cat' has $rN reason_choice (expected >= 1)" }
  if ($aN -gt 4) { Add-Warn 'M4.R49' 'TOP' "category '$cat' has $aN action_choice (uneven coverage)" }
  if ($rN -gt 4) { Add-Warn 'M4.R49' 'TOP' "category '$cat' has $rN reason_choice (uneven coverage)" }
}

# ---------- cross-scenario warning -- no critical anywhere ----------
$totalCrit = 0
foreach ($s in $j.scenarios) {
  if ($s.answer -and $s.answer.critical) {
    $totalCrit += @($s.answer.critical).Count
  }
}
if ($totalCrit -eq 0) {
  Add-Warn 'M4.R42' 'TOP' "no scenario has any critical action -- expected at least 6 teaching spots"
}

# ============================================================
# REPORT
# ============================================================
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " M4 SEED AUDIT -- v4.3.0 (planning_only)" -ForegroundColor Cyan
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

$scenCount = if ($j.scenarios) { $j.scenarios.Count } else { 0 }
$result = if ($hardErrors.Count -eq 0) { 'PASS' } else { 'FAIL' }
$color  = if ($hardErrors.Count -eq 0) { 'Green' } else { 'Red' }

Write-Host "M4 seed audit summary:" -ForegroundColor Cyan
Write-Host ("  scenarios   = {0}" -f $scenCount)
Write-Host ("  hard errors = {0}" -f $hardErrors.Count)
Write-Host ("  warnings    = {0}" -f $warnings.Count)
Write-Host ("  result      = {0}" -f $result) -ForegroundColor $color
Write-Host ""

if ($hardErrors.Count -gt 0) { exit 1 } else { exit 0 }
