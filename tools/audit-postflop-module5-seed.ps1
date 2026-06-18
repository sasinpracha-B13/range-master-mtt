# ============================================================
# audit-postflop-module5-seed.ps1
# v4.4.0 -- Module 5 (River Barrel OOP Defense) seed auditor
# Validates docs/specs/postflop-v4.4.0-module5-seed-scenarios.json
# against the M5 seed audit plan rules M5.R01..M5.R49 + R50..R58.
# Planning-only auditor -- does NOT touch production data.
# ASCII-only. UTF-8 NO-BOM read. PowerShell 5.1 compatible.
# ============================================================

$ErrorActionPreference = 'Stop'

$repoRoot = 'C:\Users\PC\Desktop\BAY TD\range-master-mtt'
$seedPath = Join-Path $repoRoot 'docs\specs\postflop-v4.4.0-module5-seed-scenarios.json'

$hardErrors = New-Object System.Collections.Generic.List[string]
$warnings   = New-Object System.Collections.Generic.List[string]

function Add-Hard([string]$rule, [string]$where, [string]$msg) {
  $hardErrors.Add("[$rule] HARD -- $where -- $msg") | Out-Null
}
function Add-Warn([string]$rule, [string]$where, [string]$msg) {
  $warnings.Add("[$rule] WARN -- $where -- $msg") | Out-Null
}

# ---------- M5.R01 -- file parseable JSON ----------
if (-not (Test-Path $seedPath)) {
  Write-Host "[M5.R01] HARD -- TOP -- seed file not found: $seedPath" -ForegroundColor Red
  exit 1
}
$rawText = $null
try {
  $rawText = [System.IO.File]::ReadAllText($seedPath, [System.Text.UTF8Encoding]::new($false))
} catch {
  Write-Host "[M5.R01] HARD -- TOP -- cannot read file: $_" -ForegroundColor Red
  exit 1
}
$j = $null
try {
  $j = $rawText | ConvertFrom-Json
} catch {
  Write-Host "[M5.R01] HARD -- TOP -- JSON parse failed: $_" -ForegroundColor Red
  exit 1
}

# ---------- M5.R02 -- required top-level keys ----------
$requiredTop = @('moduleId','moduleName','version','status','schemaVersion','generatedAt','scenarios')
$topProps = ($j.PSObject.Properties.Name)
foreach ($k in $requiredTop) {
  if ($topProps -notcontains $k) { Add-Hard 'M5.R02' 'TOP' "missing top-level key: $k" }
}

# ---------- M5.R03 -- moduleId ----------
if ($j.moduleId -ne 'pf_river_barrel_oop_def') {
  Add-Hard 'M5.R03' 'TOP' "moduleId expected 'pf_river_barrel_oop_def', got '$($j.moduleId)'"
}

# ---------- M5.R04 -- schemaVersion ----------
if ($j.schemaVersion -ne '1.3.0') {
  Add-Hard 'M5.R04' 'TOP' "top-level schemaVersion expected '1.3.0', got '$($j.schemaVersion)'"
}

# ---------- M5.R05 -- version starts with v4.4.0 ----------
if (-not ([string]$j.version).StartsWith('v4.4.0')) {
  Add-Hard 'M5.R05' 'TOP' "version should start with 'v4.4.0', got '$($j.version)'"
}

# ---------- M5.R06 -- status ----------
if ($j.status -ne 'planning_only') {
  Add-Hard 'M5.R06' 'TOP' "status expected 'planning_only', got '$($j.status)'"
}

# ---------- M5.R07 -- 24 scenarios ----------
if (-not ($j.scenarios -is [System.Array])) {
  Add-Hard 'M5.R07' 'TOP' "scenarios is not an array"
} elseif ($j.scenarios.Count -ne 24) {
  Add-Hard 'M5.R07' 'TOP' "scenarios count expected 24, got $($j.scenarios.Count)"
}

# ---------- approved enums ----------
$approvedRiverCategory = @(
  'brick','overcard','flush_complete','straight_complete','board_pair','scare_card',
  'blank_runout','double_pair','range_shift_card'
)
$approvedBoardChange = @(
  'brick','range_shift_btn','range_shift_bb','polarizing','draw_resolved','counterfeit','boat_possible'
)
$approvedRunoutTexture = @(
  'dry_unpaired','flush_possible','straight_possible','double_draw_possible',
  'paired_board','paired_flush_possible','double_paired','monotone_board'
)
$approvedRiverDrawCompletion = @(
  'none','flush_completed','straight_completed','board_paired','flush_and_straight','overcard_blank'
)
$approvedVillainRiverSizing = @('small','medium','large','overbet')
$approvedHeroHandRole = @(
  'nutted_value','strong_value','thin_value','bluff_catcher','dominated_bluff_catcher',
  'marginal_made_hand','blocker_bluff','missed_draw','give_up'
)
$approvedDrawCategory = @('none','busted_flush_draw','busted_straight_draw','busted_combo_draw')
$approvedActionReason = @(
  'pot_odds_river_call','bluff_catch_river','blocker_bluff_catch_river','mdf_defense_river',
  'thin_value_call_river','value_raise_river','bluff_raise_river','range_disadvantage_river_fold',
  'domination_river_fold','board_change_river_fold','missed_draw_give_up','mixed_indifference_river'
)
$approvedConceptTags = @(
  'river_bluff_catcher','river_polarization','river_mdf','river_blocker_defense',
  'river_value_raise','river_bluff_raise','river_thin_value','river_missed_draw',
  'river_range_disadvantage','river_board_change','river_overfold_trap','third_barrel_defense'
)
$approvedSourceConfidence = @('solver_aligned','theory_consensus','expert_judgment','heuristic','mixed_uncertain')
$approvedActionMenu = @('fold','call','check_raise_small','check_raise_big','mixed')
$cardRegex = '^[2-9TJQKA][cdhs]$'
$idRegex   = '^pf_btn_v_bb_srp_100bb_river_[a-zA-Z0-9]+_[0-9a-zA-Z]+_m5_(action|reason)_[A-Za-z0-9_]+_v440$'

# ---------- per-scenario loop ----------
$ids = New-Object System.Collections.Generic.List[string]
$catCounts = @{}
$catQtypeCounts = @{}

foreach ($s in $j.scenarios) {
  $id = if ($s.id) { $s.id } else { '<no id>' }
  $sid = $id

  # M5.R08 -- id present
  if (-not $s.id) { Add-Hard 'M5.R08' $sid 'missing id' }
  else { $ids.Add($s.id) | Out-Null }

  # M5.R09 -- id naming
  if ($s.id -and ($s.id -notmatch $idRegex)) {
    Add-Hard 'M5.R09' $sid "id does not match expected pattern"
  }

  # M5.R10 -- module field
  if ($s.module -ne 'pf_river_barrel_oop_def') {
    Add-Hard 'M5.R10' $sid "module expected 'pf_river_barrel_oop_def', got '$($s.module)'"
  }

  # M5.R11 -- schemaVersion
  if ($s.schemaVersion -ne '1.3.0') {
    Add-Hard 'M5.R11' $sid "schemaVersion expected '1.3.0', got '$($s.schemaVersion)'"
  }

  # M5.R12 -- auditStatus
  if ($s.auditStatus -ne 'planning_only') {
    Add-Hard 'M5.R12' $sid "auditStatus expected 'planning_only', got '$($s.auditStatus)'"
  }

  # M5.R13 -- reviewStatus
  if ($s.reviewStatus -ne 'v4.4.0_seed_candidate') {
    Add-Hard 'M5.R13' $sid "reviewStatus expected 'v4.4.0_seed_candidate', got '$($s.reviewStatus)'"
  }

  # M5.R14 -- uniquenessNote
  if (-not $s.uniquenessNote) {
    Add-Hard 'M5.R14' $sid 'missing uniquenessNote'
  } elseif ($s.uniquenessNote.Length -lt 20) {
    Add-Hard 'M5.R14' $sid "uniquenessNote too short ($($s.uniquenessNote.Length) chars)"
  }

  # ----- spot block -----
  if (-not $s.spot) {
    Add-Hard 'M5.R15' $sid 'missing spot block'
  } else {
    $spotReq = @('format','stackDepth','potType','preflopAction','flopAction','turnAction','riverAction',
                 'street','heroPosition','villainPosition','heroRole','villainRole')
    $spotProps = $s.spot.PSObject.Properties.Name
    foreach ($k in $spotReq) {
      if ($spotProps -notcontains $k) { Add-Hard 'M5.R15' $sid "spot missing key: $k" }
    }
    # M5.R16 -- format + stackDepth
    if ($s.spot.format -ne 'NLH_MTT') { Add-Hard 'M5.R16' $sid "spot.format expected 'NLH_MTT', got '$($s.spot.format)'" }
    if ($s.spot.stackDepth -ne '100BB') { Add-Hard 'M5.R16' $sid "spot.stackDepth expected '100BB', got '$($s.spot.stackDepth)'" }
    # M5.R17 -- hero/villain position
    if ($s.spot.heroPosition -ne 'BB') { Add-Hard 'M5.R17' $sid "spot.heroPosition expected 'BB', got '$($s.spot.heroPosition)'" }
    if ($s.spot.villainPosition -ne 'BTN') { Add-Hard 'M5.R17' $sid "spot.villainPosition expected 'BTN', got '$($s.spot.villainPosition)'" }
    # M5.R18 -- street + potType
    if ($s.spot.street -ne 'river') { Add-Hard 'M5.R18' $sid "spot.street expected 'river', got '$($s.spot.street)'" }
    if ($s.spot.potType -ne 'SRP') { Add-Hard 'M5.R18' $sid "spot.potType expected 'SRP', got '$($s.spot.potType)'" }
    # M5.R19 -- roles
    if ($s.spot.heroRole -ne 'turn_check_caller_oop') { Add-Hard 'M5.R19' $sid "spot.heroRole expected 'turn_check_caller_oop', got '$($s.spot.heroRole)'" }
    if ($s.spot.villainRole -ne 'river_barreler_ip') { Add-Hard 'M5.R19' $sid "spot.villainRole expected 'river_barreler_ip', got '$($s.spot.villainRole)'" }
  }

  # ----- board block -----
  if (-not $s.board) {
    Add-Hard 'M5.R20' $sid 'missing board block'
  } else {
    $boardReq = @('flopCards','turnCard','riverCard','cards','boardKind','suitTextureFlop','suitTextureTurn',
                  'suitTextureRiver','riverCategory','boardChange','runoutTexture','riverDrawCompletion','villainRiverSizing')
    $bProps = $s.board.PSObject.Properties.Name
    foreach ($k in $boardReq) {
      if ($bProps -notcontains $k) { Add-Hard 'M5.R20' $sid "board missing key: $k" }
    }

    # M5.R21 -- flopCards
    $fc = @($s.board.flopCards)
    if ($fc.Count -ne 3) {
      Add-Hard 'M5.R21' $sid "board.flopCards count expected 3, got $($fc.Count)"
    } else {
      foreach ($c in $fc) {
        if ($c -notmatch $cardRegex) { Add-Hard 'M5.R21' $sid "invalid flop card: '$c'" }
      }
    }
    # M5.R22 -- turnCard + riverCard valid
    if ($s.board.turnCard -notmatch $cardRegex) {
      Add-Hard 'M5.R22' $sid "invalid turnCard: '$($s.board.turnCard)'"
    }
    if ($s.board.riverCard -notmatch $cardRegex) {
      Add-Hard 'M5.R22' $sid "invalid riverCard: '$($s.board.riverCard)'"
    }
    # M5.R23 -- cards = flop + turn + river (5)
    $cards = @($s.board.cards)
    if ($cards.Count -ne 5) {
      Add-Hard 'M5.R23' $sid "board.cards count expected 5, got $($cards.Count)"
    } else {
      $expected = @($fc) + @($s.board.turnCard) + @($s.board.riverCard)
      $expectedJoin = ($expected -join ',')
      $actualJoin = ($cards -join ',')
      if ($expectedJoin -ne $actualJoin) {
        Add-Hard 'M5.R23' $sid "board.cards != flopCards+turnCard+riverCard ($actualJoin vs $expectedJoin)"
      }
    }
    # M5.R24 -- no card collision
    $allBoardCards = $cards
    $u = ($allBoardCards | Sort-Object -Unique).Count
    if ($u -ne $allBoardCards.Count) {
      Add-Hard 'M5.R24' $sid "duplicate cards in board: $($allBoardCards -join ',')"
    }

    # M5.R25 -- riverCategory
    if ($approvedRiverCategory -notcontains $s.board.riverCategory) {
      Add-Hard 'M5.R25' $sid "riverCategory '$($s.board.riverCategory)' not in approved enum"
    } else {
      if (-not $catCounts.ContainsKey($s.board.riverCategory)) { $catCounts[$s.board.riverCategory] = 0 }
      $catCounts[$s.board.riverCategory]++
    }

    # M5.R26 -- villainRiverSizing
    if ($approvedVillainRiverSizing -notcontains $s.board.villainRiverSizing) {
      Add-Hard 'M5.R26' $sid "villainRiverSizing '$($s.board.villainRiverSizing)' not in approved enum"
    }
    # M5.R27 -- boardChange
    if ($approvedBoardChange -notcontains $s.board.boardChange) {
      Add-Hard 'M5.R27' $sid "boardChange '$($s.board.boardChange)' not in approved enum"
    }
    # M5.R28 -- runoutTexture
    if ($approvedRunoutTexture -notcontains $s.board.runoutTexture) {
      Add-Hard 'M5.R28' $sid "runoutTexture '$($s.board.runoutTexture)' not in approved enum"
    }
    # M5.R29 -- riverDrawCompletion
    if ($approvedRiverDrawCompletion -notcontains $s.board.riverDrawCompletion) {
      Add-Hard 'M5.R29' $sid "riverDrawCompletion '$($s.board.riverDrawCompletion)' not in approved enum"
    }
  }

  # ----- hero hand + role -----
  $hh = @($s.heroHand)
  if ($hh.Count -ne 2) {
    Add-Hard 'M5.R30' $sid "heroHand count expected 2, got $($hh.Count)"
  } else {
    foreach ($c in $hh) {
      if ($c -notmatch $cardRegex) { Add-Hard 'M5.R30' $sid "invalid hero card: '$c'" }
    }
    # M5.R31 -- hero/board collision
    if ($s.board -and $s.board.cards) {
      $boardSet = @($s.board.cards)
      foreach ($hc in $hh) {
        if ($boardSet -contains $hc) { Add-Hard 'M5.R31' $sid "hero card '$hc' collides with board" }
      }
    }
  }
  # M5.R32 -- heroHandRole + drawCategory
  if ($approvedHeroHandRole -notcontains $s.heroHandRole) {
    Add-Hard 'M5.R32' $sid "heroHandRole '$($s.heroHandRole)' not in approved vocab"
  }
  if ($approvedDrawCategory -notcontains $s.drawCategory) {
    Add-Hard 'M5.R32' $sid "drawCategory '$($s.drawCategory)' not in approved river set (none/busted_*)"
  }

  # ----- question -----
  $qtype = $null
  if (-not $s.question) {
    Add-Hard 'M5.R33' $sid 'missing question block'
  } else {
    $qReq = @('qtype','prompt','choices')
    $qProps = $s.question.PSObject.Properties.Name
    foreach ($k in $qReq) {
      if ($qProps -notcontains $k) { Add-Hard 'M5.R33' $sid "question missing key: $k" }
    }
    $qtype = $s.question.qtype
    # M5.R34 -- qtype enum
    if ($qtype -ne 'action_choice' -and $qtype -ne 'reason_choice') {
      Add-Hard 'M5.R34' $sid "qtype '$qtype' not in {action_choice,reason_choice}"
    }
    # M5.R35 -- 5-action menu for action_choice
    if ($qtype -eq 'action_choice') {
      $ch = @($s.question.choices) | Sort-Object
      $exp = $approvedActionMenu | Sort-Object
      if (($ch -join ',') -ne ($exp -join ',')) {
        Add-Hard 'M5.R35' $sid "action_choice choices mismatch: got [$($s.question.choices -join ',')]"
      }
    }
    # M5.R36 -- reason_choice 3..12 strings, all in actionReason vocab
    if ($qtype -eq 'reason_choice') {
      $ch = @($s.question.choices)
      if ($ch.Count -lt 3 -or $ch.Count -gt 12) {
        Add-Hard 'M5.R36' $sid "reason_choice choices count $($ch.Count) outside [3,12]"
      } else {
        foreach ($c in $ch) {
          if (-not ($c -is [string])) {
            Add-Hard 'M5.R36' $sid "reason_choice non-string element"
          } elseif ($approvedActionReason -notcontains $c) {
            Add-Hard 'M5.R36' $sid "reason_choice option '$c' not in actionReason vocab"
          }
        }
      }
    }

    # category x qtype tally
    if ($s.board -and $s.board.riverCategory -and $qtype) {
      $key = "$($s.board.riverCategory)/$qtype"
      if (-not $catQtypeCounts.ContainsKey($key)) { $catQtypeCounts[$key] = 0 }
      $catQtypeCounts[$key]++
    }
  }

  # ----- recommendedAction + actionReason -----
  if ($approvedActionMenu -notcontains $s.recommendedAction) {
    Add-Hard 'M5.R37' $sid "recommendedAction '$($s.recommendedAction)' not in 5-action menu"
  }
  if ($approvedActionReason -notcontains $s.actionReason) {
    Add-Hard 'M5.R38' $sid "actionReason '$($s.actionReason)' not in M5-approved vocab"
  }

  # ----- answer -----
  if (-not $s.answer) {
    Add-Hard 'M5.R39' $sid 'missing answer block'
  } else {
    $ansReq = @('best','acceptable','bad','critical')
    $aProps = $s.answer.PSObject.Properties.Name
    foreach ($k in $ansReq) {
      if ($aProps -notcontains $k) { Add-Hard 'M5.R39' $sid "answer missing key: $k" }
    }

    if ($qtype -eq 'action_choice') {
      # M5.R40 -- best single string in 5-action menu
      if (-not ($s.answer.best -is [string])) {
        Add-Hard 'M5.R40' $sid "answer.best not a string"
      } elseif ($approvedActionMenu -notcontains $s.answer.best) {
        Add-Hard 'M5.R40' $sid "answer.best '$($s.answer.best)' not in 5-action menu"
      }
      # M5.R41 -- recommendedAction == answer.best
      if ($s.recommendedAction -ne $s.answer.best) {
        Add-Hard 'M5.R41' $sid "recommendedAction '$($s.recommendedAction)' != answer.best '$($s.answer.best)'"
      }
      # M5.R43 -- partition coverage = full menu via best+acc+bad
      $bestArr = @()
      if ($s.answer.best -is [string]) { $bestArr = @($s.answer.best) }
      $accArr  = @($s.answer.acceptable) | Where-Object { $_ }
      $badArr  = @($s.answer.bad) | Where-Object { $_ }
      $coverage = ($bestArr + $accArr + $badArr) | Sort-Object -Unique
      $expSorted = $approvedActionMenu | Sort-Object
      if (($coverage -join ',') -ne ($expSorted -join ',')) {
        Add-Hard 'M5.R43' $sid "best+acceptable+bad don't cover 5-action menu (got [$($coverage -join ',')])"
      }

      # M5.R42a -- best/acceptable/bad disjoint
      $primary = $bestArr + $accArr + $badArr
      $dups = $primary | Group-Object | Where-Object { $_.Count -gt 1 }
      foreach ($d in $dups) {
        Add-Hard 'M5.R42' $sid "action '$($d.Name)' appears in multiple primary partitions (best/acceptable/bad)"
      }
      # M5.R42b -- critical subset of bad
      $critArr = @($s.answer.critical) | Where-Object { $_ }
      foreach ($c in $critArr) {
        if ($badArr -notcontains $c) {
          Add-Hard 'M5.R42' $sid "critical action '$c' is not in 'bad' (critical must be subset of bad)"
        }
      }
    } elseif ($qtype -eq 'reason_choice') {
      # M5.R44 -- best is one of the choices
      if ($s.question -and $s.question.choices) {
        $choicesSet = @($s.question.choices)
        if (-not ($choicesSet -contains $s.answer.best)) {
          Add-Hard 'M5.R44' $sid "answer.best '$($s.answer.best)' not in question.choices"
        }
      }
    }
  }

  # ----- explanation -----
  if (-not $s.explanation) {
    Add-Hard 'M5.R45' $sid 'missing explanation block'
  } else {
    $expReq = @('short','riverLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')
    $eProps = $s.explanation.PSObject.Properties.Name
    foreach ($k in $expReq) {
      if ($eProps -notcontains $k) { Add-Hard 'M5.R45' $sid "explanation missing key: $k" }
    }
    if ($s.explanation.riverLogic -and $s.explanation.riverLogic.Length -lt 60) {
      Add-Warn 'M5.R45' $sid "riverLogic short ($($s.explanation.riverLogic.Length) chars)"
    }
  }

  # ----- conceptTags -----
  $ct = @($s.conceptTags)
  if ($ct.Count -lt 1 -or $ct.Count -gt 4) {
    Add-Hard 'M5.R46' $sid "conceptTags count $($ct.Count) outside [1,4]"
  } else {
    foreach ($t in $ct) {
      if ($approvedConceptTags -notcontains $t) {
        Add-Hard 'M5.R46' $sid "conceptTag '$t' not in approved vocab"
      }
    }
  }

  # ----- sourceConfidence -----
  if ($approvedSourceConfidence -notcontains $s.sourceConfidence) {
    Add-Hard 'M5.R47' $sid "sourceConfidence '$($s.sourceConfidence)' not in approved set"
  }

  # ============================================================
  # M5 hardening rules R50-R58 (poker-sanity + river-specific guards)
  # ============================================================

  # ----- M5.R50 -- action_choice prompt must not end with 'with ' -----
  if ($s.question -and $s.question.qtype -eq 'action_choice') {
    if ($s.question.prompt -match 'with\s*$') {
      Add-Hard 'M5.R50' $sid "action_choice prompt ends with 'with ' -- hero hand lost during interpolation"
    }
  }

  # ----- M5.R51 -- action_choice prompt must contain heroHand cards -----
  if ($s.question -and $s.question.qtype -eq 'action_choice' -and $s.heroHand) {
    $hh2 = @($s.heroHand)
    if ($hh2.Count -eq 2) {
      $heroFound = $true
      foreach ($c in $hh2) {
        if ($s.question.prompt -notmatch [regex]::Escape($c)) { $heroFound = $false; break }
      }
      if (-not $heroFound) {
        Add-Hard 'M5.R51' $sid "action_choice prompt does not contain both hero cards ('$($hh2 -join "', '")')"
      }
    }
  }

  # ----- M5.R52 -- handClass='flush' requires >=5 of one suit across hero+board -----
  if ($s.handClass -eq 'flush' -and $s.heroHand -and $s.board -and $s.board.cards) {
    $all = @($s.heroHand) + @($s.board.cards)
    $foundFlush = $false
    foreach ($suit in 'cdhs'.ToCharArray()) {
      $sc = [string]$suit
      $cnt = (@($all) | Where-Object { $_.Length -eq 2 -and $_.Substring(1,1) -eq $sc }).Count
      if ($cnt -ge 5) { $foundFlush = $true; break }
    }
    if (-not $foundFlush) {
      Add-Hard 'M5.R52' $sid "handClass='flush' but no suit has 5+ cards across hero+board"
    }
  }

  # ----- M5.R53 -- blockerNote claiming nut-<suit> requires hero to hold A of that suit -----
  if ($s.heroHandRole -eq 'blocker_bluff' -and $s.blockerNote -and $s.heroHand) {
    $hh3 = @($s.heroHand)
    $bn = $s.blockerNote
    $suitMap = @{ 'spade'='s'; 'heart'='h'; 'club'='c'; 'diamond'='d' }
    foreach ($word in $suitMap.Keys) {
      if ($bn -match "nut[- ]$word") {
        $sc = $suitMap[$word]
        if (-not ($hh3 -contains "A$sc")) {
          Add-Hard 'M5.R53' $sid "blockerNote claims 'nut-$word' blocker but hero does not hold A$sc"
        }
      }
    }
  }

  # ----- M5.R54 -- handClass='straight' requires 5 consecutive ranks in hero+board -----
  if ($s.handClass -eq 'straight' -and $s.heroHand -and $s.board -and $s.board.cards) {
    $allCards = @($s.heroHand) + @($s.board.cards)
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
      foreach ($k in 0..4) {
        if (-not $rankSet.Contains($start + $k)) { $allIn = $false; break }
      }
      if ($allIn) { $foundStraight = $true; break }
    }
    if (-not $foundStraight) {
      if ($rankSet.Contains(12) -and $rankSet.Contains(0) -and $rankSet.Contains(1) -and $rankSet.Contains(2) -and $rankSet.Contains(3)) {
        $foundStraight = $true
      }
    }
    if (-not $foundStraight) {
      Add-Hard 'M5.R54' $sid "handClass='straight' but no 5 consecutive ranks (or A-2-3-4-5) in hero+board"
    }
  }

  # ----- M5.R55 -- busted draws never call (river is showdown-only) -----
  # If heroHandRole='missed_draw' OR drawCategory is a busted_* draw, then 'call'
  # must NOT appear in recommendedAction / answer.best / answer.acceptable, and
  # for reason_choice the actionReason must not be a call-flavored reason.
  $isBusted = ($s.heroHandRole -eq 'missed_draw') -or `
              ($s.drawCategory -eq 'busted_flush_draw') -or `
              ($s.drawCategory -eq 'busted_straight_draw') -or `
              ($s.drawCategory -eq 'busted_combo_draw')
  if ($isBusted) {
    if ($s.recommendedAction -eq 'call') {
      Add-Hard 'M5.R55' $sid "busted draw (role/drawCategory) has recommendedAction='call' -- busted draws never call on the river"
    }
    if ($s.answer -and $s.answer.best -eq 'call') {
      Add-Hard 'M5.R55' $sid "busted draw has answer.best='call' -- busted draws never call"
    }
    if ($s.answer -and (@($s.answer.acceptable) -contains 'call')) {
      Add-Hard 'M5.R55' $sid "busted draw lists 'call' as acceptable -- busted draws never call"
    }
    $callReasons = @('pot_odds_river_call','bluff_catch_river','blocker_bluff_catch_river','mdf_defense_river','thin_value_call_river')
    if ($callReasons -contains $s.actionReason) {
      Add-Hard 'M5.R55' $sid "busted draw has a call-flavored actionReason '$($s.actionReason)' -- busted draws are fold or bluff-raise only"
    }
  }

  # ----- M5.R56 -- no draw-equity-realization language in river explanations (WARN) -----
  # The river has no equity to realize; flag M4-carryover phrasing.
  if ($s.explanation) {
    $banPhrases = @('equity realization','realize equity','equity_realization','realize the equity','realise equity')
    foreach ($f in @('short','riverLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')) {
      $v = $s.explanation.$f
      if ($null -ne $v -and ($v -is [string])) {
        $vl = $v.ToLowerInvariant()
        foreach ($p in $banPhrases) {
          if ($vl.Contains($p)) {
            Add-Warn 'M5.R56' $sid "explanation.$f uses draw-equity-realization phrasing ('$p') -- river is showdown-only"
            break
          }
        }
      }
    }
  }

  # ----- M5.R57 -- riverLogic should reference river/runout (sanity) (WARN) -----
  if ($s.explanation -and $s.explanation.riverLogic) {
    $rl = $s.explanation.riverLogic.ToLowerInvariant()
    if (-not ($rl.Contains('river') -or $rl.Contains('runout') -or $rl.Contains('bet') -or $rl.Contains('flush') -or $rl.Contains('straight') -or $rl.Contains('pair') -or $rl.Contains('board'))) {
      Add-Warn 'M5.R57' $sid "riverLogic does not reference the river/runout/board -- check it describes the final-street dynamics"
    }
  }

  # ----- M5.R58 -- text-integrity: no unresolved self-correction artifacts (HARD) -----
  $r58 = @(' wait ', ' wait,', ' wait.', 'wait needs', 'wait need ', 'actually impossible', '... wait', '...wait')
  if ($s.explanation) {
    foreach ($f in @('short','riverLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')) {
      $v = $s.explanation.$f
      if ($null -ne $v -and ($v -is [string]) -and $v.Length -gt 0) {
        $vl = $v.ToLowerInvariant()
        foreach ($p in $r58) {
          if ($vl.Contains($p.ToLowerInvariant())) {
            Add-Hard 'M5.R58' $sid ("explanation.$f contains self-correction artifact '" + $p.Trim() + "'")
            break
          }
        }
      }
    }
  }
}

# ---------- M5.R08 -- id uniqueness ----------
$dupIds = $ids | Group-Object | Where-Object { $_.Count -gt 1 }
foreach ($d in $dupIds) {
  Add-Hard 'M5.R08' 'TOP' "duplicate id '$($d.Name)' x$($d.Count)"
}

# ---------- M5.R48 -- six categories x 4 ----------
$expectedCats = @('brick','overcard','flush_complete','straight_complete','board_pair','scare_card')
foreach ($cat in $expectedCats) {
  $count = if ($catCounts.ContainsKey($cat)) { $catCounts[$cat] } else { 0 }
  if ($count -ne 4) {
    Add-Hard 'M5.R48' 'TOP' "riverCategory '$cat' expected 4 scenarios, got $count"
  }
}

# ---------- M5.R49 -- category x qtype distribution ----------
foreach ($cat in $expectedCats) {
  $aKey = "$cat/action_choice"
  $rKey = "$cat/reason_choice"
  $aN = if ($catQtypeCounts.ContainsKey($aKey)) { $catQtypeCounts[$aKey] } else { 0 }
  $rN = if ($catQtypeCounts.ContainsKey($rKey)) { $catQtypeCounts[$rKey] } else { 0 }
  if ($aN -lt 2) { Add-Hard 'M5.R49' 'TOP' "category '$cat' has $aN action_choice (expected >= 2)" }
  if ($rN -lt 1) { Add-Hard 'M5.R49' 'TOP' "category '$cat' has $rN reason_choice (expected >= 1)" }
}

# ---------- cross-scenario warning -- no critical anywhere ----------
$totalCrit = 0
foreach ($s in $j.scenarios) {
  if ($s.answer -and $s.answer.critical) {
    $totalCrit += @($s.answer.critical).Count
  }
}
if ($totalCrit -eq 0) {
  Add-Warn 'M5.R42' 'TOP' "no scenario has any critical action -- expected at least 6 teaching spots"
}

# ============================================================
# REPORT
# ============================================================
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " M5 SEED AUDIT -- v4.4.0 (planning_only)" -ForegroundColor Cyan
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

Write-Host "M5 seed audit summary:" -ForegroundColor Cyan
Write-Host ("  scenarios   = {0}" -f $scenCount)
Write-Host ("  hard errors = {0}" -f $hardErrors.Count)
Write-Host ("  warnings    = {0}" -f $warnings.Count)
Write-Host ("  result      = {0}" -f $result) -ForegroundColor $color
Write-Host ""

if ($hardErrors.Count -gt 0) { exit 1 } else { exit 0 }
