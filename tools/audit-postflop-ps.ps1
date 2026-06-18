# tools/audit-postflop-ps.ps1
# PowerShell port of postflop/postflop_audit_rules.js. Implements all 17 rules
# with identical semantics. Used for fast local re-audit when Node.js is not
# available. The browser viewer (postflop/postflop_audit.html) and the Node CLI
# (tools/audit-postflop.js) remain canonical for shipping audits.
#
# Run from repo root:
#   powershell -ExecutionPolicy Bypass -File tools/audit-postflop-ps.ps1
#
# Exit code 0 if no errors, 1 if any errors.
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$scenPath = Join-Path $repoRoot 'postflop/postflop_scenarios.json'
$taxPath  = Join-Path $repoRoot 'postflop/postflop_taxonomy.json'
$conPath  = Join-Path $repoRoot 'postflop/postflop_concepts.json'

$data = Get-Content -Raw $scenPath | ConvertFrom-Json
$tax  = Get-Content -Raw $taxPath  | ConvertFrom-Json
$con  = Get-Content -Raw $conPath  | ConvertFrom-Json

$validRanks = @('A','K','Q','J','T','9','8','7','6','5','4','3','2')
$validSuits = @('s','h','d','c')
$rankIdx = @{}; for($i=0;$i -lt $validRanks.Count;$i++){ $rankIdx[$validRanks[$i]] = (12 - $i) }
$highCardDeriv = @{}; foreach($k in $tax.highCardDerivation.PSObject.Properties.Name){ if($k -ne '_comment'){ $highCardDeriv[$k] = $tax.highCardDerivation.$k } }
$knownConcepts = New-Object System.Collections.Generic.HashSet[string]
foreach($c in $con.concepts){ [void]$knownConcepts.Add($c.key) }
$validTexture = New-Object System.Collections.Generic.HashSet[string]
foreach($t in $tax.textureTags){ [void]$validTexture.Add($t) }
$validRA = New-Object System.Collections.Generic.HashSet[string]; foreach($v in $tax.rangeAdvantage){ [void]$validRA.Add($v) }
$validNA = New-Object System.Collections.Generic.HashSet[string]; foreach($v in $tax.nutAdvantage){ [void]$validNA.Add($v) }
$validSC = New-Object System.Collections.Generic.HashSet[string]; foreach($v in $tax.sourceConfidenceLevels){ [void]$validSC.Add($v) }

$idCounts = @{}
foreach($s in $data.scenarios){ if($s.id){ if(-not $idCounts.ContainsKey($s.id)){ $idCounts[$s.id]=0 }; $idCounts[$s.id]++ } }

$issues = New-Object System.Collections.ArrayList
$perScenario = @{}

function Add-Issue($list, $rule, $sev, $sid, $msg){
  $issue = [PSCustomObject]@{ rule=$rule; severity=$sev; scenarioId=$sid; message=$msg }
  [void]$list.Add($issue)
  return $issue
}

foreach($s in $data.scenarios){
  $sid = if($s.id){ $s.id } else { '<unknown>' }
  $local = New-Object System.Collections.ArrayList

  # R01 required fields
  $req = @('id','version','schemaVersion','game','module','street','spot','board','actionHistory','question','answer','scoring','explanation','conceptTags','difficulty','sourceConfidence','auditStatus')
  foreach($f in $req){
    if(-not ($s.PSObject.Properties.Name -contains $f)){
      Add-Issue $local 'R01' 'error' $sid "Missing required field: $f" | Out-Null
    }
  }

  # R02 board cards valid
  if(-not $s.board -or -not $s.board.cards){
    Add-Issue $local 'R02' 'error' $sid 'board.cards missing or not an array' | Out-Null
  } else {
    $expected = @{ flop=3; turn=4; river=5 }[$s.street]
    if($expected -and $s.board.cards.Count -ne $expected){
      Add-Issue $local 'R02' 'error' $sid "Board has $($s.board.cards.Count) cards but street=$($s.street) requires $expected" | Out-Null
    }
    $seen = @{}
    $parsed = @()
    foreach($cs in $s.board.cards){
      if(-not $cs -or $cs.Length -ne 2){ Add-Issue $local 'R02' 'error' $sid "Invalid card string: `"$cs`"" | Out-Null; continue }
      $r = $cs.Substring(0,1); $u = $cs.Substring(1,1)
      if($validRanks -notcontains $r){ Add-Issue $local 'R02' 'error' $sid "Invalid rank in card `"$cs`"" | Out-Null }
      if($validSuits -notcontains $u){ Add-Issue $local 'R02' 'error' $sid "Invalid suit in card `"$cs`"" | Out-Null }
      if($seen.ContainsKey($cs)){ Add-Issue $local 'R02' 'error' $sid "Duplicate board card: `"$cs`"" | Out-Null }
      $seen[$cs] = $true
      $parsed += @{ rank=$r; suit=$u; str=$cs }
    }
    if($parsed.Count -gt 0){
      $best = -1; $bestRank = $null
      foreach($p in $parsed){ if($rankIdx[$p.rank] -gt $best){ $best = $rankIdx[$p.rank]; $bestRank = $p.rank } }
      $expCls = $highCardDeriv[$bestRank]
      if($expCls -and $s.board.highCardClass -ne $expCls){
        Add-Issue $local 'R02' 'error' $sid "highCardClass=`"$($s.board.highCardClass)`" but top board rank derives `"$expCls`"" | Out-Null
      }
    }
  }

  # R03 duplicate ids
  if($idCounts[$s.id] -gt 1){
    Add-Issue $local 'R03' 'error' $sid "Duplicate id appears $($idCounts[$s.id]) times in dataset" | Out-Null
  }

  # R04 choices include answers
  # v4.2.3: Module 3 (pf_flop_cbet_oop_def) uses string-form choices and string-form
  # answer.best (vs M1/M2 which use {id, label} objects + array best). R04 handles
  # both forms. Module 3 also has a separate authoritative R31/R32/R34 check.
  if(-not $s.question -or -not $s.question.choices){
    Add-Issue $local 'R04' 'error' $sid 'question.choices missing' | Out-Null
  } elseif(-not $s.answer){
    Add-Issue $local 'R04' 'error' $sid 'answer missing' | Out-Null
  } else {
    $choiceIds = @{}
    foreach($c in $s.question.choices){
      if($c -is [string]){ $choiceIds[$c] = $true }
      elseif($c -and $c.id){ $choiceIds[$c.id] = $true }
    }
    foreach($tier in @('best','acceptable','bad','critical')){
      $list = $s.answer.$tier
      if($null -eq $list){ Add-Issue $local 'R04' 'error' $sid "answer.$tier must be an array" | Out-Null; continue }
      # Normalize string-form best (M3) to a 1-element list for iteration
      if($tier -eq 'best' -and $list -is [string]){ $list = @($list) }
      foreach($id in $list){
        if(-not $choiceIds.ContainsKey($id)){
          Add-Issue $local 'R04' 'error' $sid "answer.$tier references unknown choice id `"$id`"" | Out-Null
        }
      }
    }
  }

  # R05 best exists
  # M3 best is a string; M1/M2 best is an array. Both pass when non-empty.
  if(-not $s.answer -or $null -eq $s.answer.best){
    Add-Issue $local 'R05' 'error' $sid 'answer.best must be a non-empty value' | Out-Null
  } elseif($s.answer.best -is [string]){
    if($s.answer.best.Trim().Length -eq 0){
      Add-Issue $local 'R05' 'error' $sid 'answer.best must be a non-empty value' | Out-Null
    }
  } elseif($s.answer.best.Count -eq 0){
    Add-Issue $local 'R05' 'error' $sid 'answer.best must be a non-empty array' | Out-Null
  }

  # R06 short explanation
  if(-not $s.explanation -or -not $s.explanation.short -or $s.explanation.short.Trim().Length -eq 0){
    Add-Issue $local 'R06' 'error' $sid 'explanation.short must be a non-empty string' | Out-Null
  }

  # R07 concept tags
  if($s.conceptTags){
    foreach($tag in $s.conceptTags){
      if(-not $knownConcepts.Contains($tag)){
        Add-Issue $local 'R07' 'error' $sid "Unknown concept tag: `"$tag`"" | Out-Null
      }
    }
  }

  # R08 difficulty valid
  if($s.difficulty -isnot [int] -or $s.difficulty -lt 1 -or $s.difficulty -gt 5){
    if(-not ($s.difficulty -is [long])){
      Add-Issue $local 'R08' 'error' $sid "difficulty must be integer 1-5, got $($s.difficulty)" | Out-Null
    } elseif($s.difficulty -lt 1 -or $s.difficulty -gt 5){
      Add-Issue $local 'R08' 'error' $sid "difficulty must be integer 1-5, got $($s.difficulty)" | Out-Null
    }
  }

  # R09 texture tags
  if($s.board -and $s.board.textureTags){
    foreach($tg in $s.board.textureTags){
      if(-not $validTexture.Contains($tg)){
        Add-Issue $local 'R09' 'error' $sid "Unknown textureTag: `"$tg`"" | Out-Null
      }
    }
  }

  # R10 advantage enums (FLOP-MODULES ONLY)
  # M4 (pf_turn_barrel_oop_def) uses turn-board structure with equityShift
  # instead of board.rangeAdvantage / board.nutAdvantage. R10 is scoped to
  # flop modules; M4 has its own R55+ rules for board validation.
  # v4.4.1: M5 (pf_river_barrel_oop_def) also excluded -- river 5-card board uses
  # riverCategory / runoutTexture / villainRiverSizing, not rangeAdvantage/nutAdvantage.
  if($s.board -and $s.module -ne 'pf_turn_barrel_oop_def' -and $s.module -ne 'pf_river_barrel_oop_def'){
    if(-not $validRA.Contains($s.board.rangeAdvantage)){
      Add-Issue $local 'R10' 'error' $sid "Invalid board.rangeAdvantage: `"$($s.board.rangeAdvantage)`"" | Out-Null
    }
    if(-not $validNA.Contains($s.board.nutAdvantage)){
      Add-Issue $local 'R10' 'error' $sid "Invalid board.nutAdvantage: `"$($s.board.nutAdvantage)`"" | Out-Null
    }
  }

  # R11 scoring tiers
  if(-not $s.scoring){
    Add-Issue $local 'R11' 'error' $sid 'scoring missing' | Out-Null
  } else {
    if($s.scoring.best -ne 1.0){ Add-Issue $local 'R11' 'error' $sid "scoring.best must be 1.0, got $($s.scoring.best)" | Out-Null }
    if(@(0.25,0.5,0.75) -notcontains $s.scoring.acceptable){ Add-Issue $local 'R11' 'error' $sid "scoring.acceptable must be 0.25, 0.5, or 0.75; got $($s.scoring.acceptable)" | Out-Null }
    if($s.scoring.bad -ne 0){ Add-Issue $local 'R11' 'error' $sid "scoring.bad must be 0, got $($s.scoring.bad)" | Out-Null }
    if($s.scoring.critical -ne 0){ Add-Issue $local 'R11' 'error' $sid "scoring.critical must be 0, got $($s.scoring.critical)" | Out-Null }
  }

  # R12 critical -> commonMistake (warning)
  if($s.answer -and $s.answer.critical -and $s.answer.critical.Count -gt 0){
    if(-not $s.explanation -or -not $s.explanation.commonMistake -or $s.explanation.commonMistake.Trim().Length -eq 0){
      Add-Issue $local 'R12' 'warning' $sid 'Scenario has critical answers but explanation.commonMistake is empty' | Out-Null
    }
  }

  # R13 contradictory tags + suit consistency (FLOP-MODULES ONLY)
  # M4 uses suitTextureFlop + suitTextureTurn instead of single suitTexture;
  # M4 board has 4 cards (3 flop + 1 turn) so the flop-only "derive suit
  # texture from board.cards" check does not apply. M4 has its own R55+
  # rules. Scope this rule to flop modules.
  # v4.4.1: M5 (pf_river_barrel_oop_def) also excluded -- river board has 5 cards
  # and uses suitTextureFlop/Turn/River, not a single suitTexture; M5 has its own R76+ rules.
  if($s.board -and $s.board.textureTags -and $s.module -ne 'pf_turn_barrel_oop_def' -and $s.module -ne 'pf_river_barrel_oop_def'){
    $tagSet = @{}; foreach($t in $s.board.textureTags){ $tagSet[$t] = $true }
    foreach($pair in $tax.contradictoryPairs){
      if($tagSet.ContainsKey($pair[0]) -and $tagSet.ContainsKey($pair[1])){
        Add-Issue $local 'R13' 'error' $sid "Contradictory textureTags: `"$($pair[0])`" + `"$($pair[1])`"" | Out-Null
      }
    }
    $st = $s.board.suitTexture
    if($st -eq 'monotone' -and $tagSet.ContainsKey('rainbow')){ Add-Issue $local 'R13' 'error' $sid 'suitTexture=monotone but textureTags include rainbow' | Out-Null }
    if($st -eq 'monotone' -and $tagSet.ContainsKey('two_tone')){ Add-Issue $local 'R13' 'error' $sid 'suitTexture=monotone but textureTags include two_tone' | Out-Null }
    if($st -eq 'rainbow' -and $tagSet.ContainsKey('monotone')){ Add-Issue $local 'R13' 'error' $sid 'suitTexture=rainbow but textureTags include monotone' | Out-Null }
    if($st -eq 'rainbow' -and $tagSet.ContainsKey('two_tone')){ Add-Issue $local 'R13' 'error' $sid 'suitTexture=rainbow but textureTags include two_tone' | Out-Null }
    if($st -eq 'two_tone' -and $tagSet.ContainsKey('rainbow')){ Add-Issue $local 'R13' 'error' $sid 'suitTexture=two_tone but textureTags include rainbow' | Out-Null }
    if($st -eq 'two_tone' -and $tagSet.ContainsKey('monotone')){ Add-Issue $local 'R13' 'error' $sid 'suitTexture=two_tone but textureTags include monotone' | Out-Null }
    if($s.board.cards -and $s.board.cards.Count -ge 3){
      $suits = @(); foreach($c in $s.board.cards){ if($c -and $c.Length -eq 2){ $suits += $c.Substring(1,1) } }
      $unique = ($suits | Sort-Object -Unique).Count
      $derived = if($unique -eq 1){'monotone'} elseif($unique -eq 2){'two_tone'} else {'rainbow'}
      if($st -ne $derived){
        Add-Issue $local 'R13' 'error' $sid "suitTexture=`"$st`" but board cards derive `"$derived`"" | Out-Null
      }
    }
  }

  # R14 plausibility
  if($s.board -and $s.question -and $s.answer){
    $isFreq = ($s.question.type -eq 'frequency_strategy' -or $s.question.type -eq 'sizing_family')
    if($isFreq){
      $tagSet = @{}; if($s.board.textureTags){ foreach($t in $s.board.textureTags){ $tagSet[$t]=$true } }
      $best = @{}; if($s.answer.best){ foreach($b in $s.answer.best){ $best[$b]=$true } }
      $isDryHi = ($s.board.highCardClass -in @('A_high','K_high')) -and ($tagSet.ContainsKey('dry') -or $tagSet.ContainsKey('semi_dry')) -and $tagSet.ContainsKey('disconnected')
      $isWetLow = ($s.board.highCardClass -eq 'low') -and ($tagSet.ContainsKey('wet') -or $tagSet.ContainsKey('very_wet')) -and ($tagSet.ContainsKey('highly_connected') -or $tagSet.ContainsKey('connected') -or $tagSet.ContainsKey('low_connected'))
      if($isDryHi -and $s.board.rangeAdvantage -eq 'preflop_raiser' -and $best.ContainsKey('check_heavy')){
        Add-Issue $local 'R14' 'warning' $sid 'Dry high-card board with raiser range adv should not be check_heavy as best' | Out-Null
      }
      if($isWetLow -and $s.board.rangeAdvantage -eq 'caller' -and $best.ContainsKey('range_small')){
        Add-Issue $local 'R14' 'warning' $sid 'Wet low-connected board favoring caller should not be range_small as best' | Out-Null
      }
    }
  }

  # R15 critical not mixed
  if($s.answer){
    $crit = @{}; if($s.answer.critical){ foreach($c in $s.answer.critical){ $crit[$c]=$true } }
    if($s.answer.best){ foreach($b in $s.answer.best){ if($crit.ContainsKey($b)){ Add-Issue $local 'R15' 'error' $sid "Choice `"$b`" is in both best and critical" | Out-Null } } }
    if($s.answer.acceptable){ foreach($a in $s.answer.acceptable){ if($crit.ContainsKey($a)){ Add-Issue $local 'R15' 'error' $sid "Choice `"$a`" is in both acceptable and critical" | Out-Null } } }
    $bad = @{}; if($s.answer.bad){ foreach($x in $s.answer.bad){ $bad[$x]=$true } }
    if($s.answer.best){ foreach($b in $s.answer.best){ if($bad.ContainsKey($b)){ Add-Issue $local 'R15' 'error' $sid "Choice `"$b`" is in both best and bad" | Out-Null } } }
  }

  # R17 sourceConfidence
  if(-not $validSC.Contains($s.sourceConfidence)){
    Add-Issue $local 'R17' 'error' $sid "Invalid sourceConfidence: `"$($s.sourceConfidence)`"" | Out-Null
  }
  if($s.sourceConfidence -eq 'experimental' -and $s.auditStatus -eq 'approved'){
    Add-Issue $local 'R17' 'warning' $sid 'sourceConfidence=experimental + auditStatus=approved - needs justification' | Out-Null
  }

  # ========================================================================
  # R18-R30 — Module 2 (pf_flop_cbet_ip) v4.1.2 schema rules
  # Apply only to Module 2 scenarios. Mirror the hard-error subset of
  # tools/audit-postflop-module2-seed.ps1 (M2.H01-H14 + M2.SC01-SC03 +
  # M2.HC01-HC07). Pedagogical / labeling-precision warnings (HC08-HC11,
  # SC04, SC05, S01-S04, H14-soft) intentionally excluded — those live in
  # the seed auditor only and are reviewer guidance, not production gates.
  # ========================================================================
  if ($s.module -eq 'pf_flop_cbet_ip') {
    $m2ValidHandClasses = @('set','straight','flush','nut_flush','top_two_pair','two_pair','overpair',
      'top_pair_top_kicker','top_pair_good_kicker','top_pair_weak_kicker',
      'second_pair','third_pair_or_lower','underpair','mid_pair',
      'combo_draw','flush_draw','nut_flush_draw','oesd','gutshot',
      'backdoor_only','no_pair_no_draw','trips')
    $m2ValidHandRoles = @('strong_value','thin_value','medium_showdown','weak_showdown',
      'nut_draw','strong_draw','weak_draw','air','blocker_bluff','trap_check')
    $m2ValidDrawCats = @('nut_fd','fd','oesd','gutshot','combo','backdoor_only','none')
    $m2ValidShowdown = @('high','medium','low','none')
    $m2ValidActions = @('bet_small','bet_big','check','mixed')
    $m2ValidReasons = @('value','thin_value','protection','bluff','equity_realization',
      'pot_control','blocker_pressure','range_advantage_stab','give_up','semi_bluff')
    $m2ValidQTypes = @('action_choice','reason_choice','sizing_choice','hand_class')

    # R18 — required Module 2 fields
    $m2Req = @('heroHand','handClass','heroHandRole','drawCategory','showdownValue','recommendedAction','actionReason')
    foreach ($f in $m2Req) {
      if (-not ($s.PSObject.Properties.Name -contains $f) -or $null -eq $s.$f) {
        Add-Issue $local 'R18' 'error' $sid ("Module 2 required field missing: " + $f) | Out-Null
      }
    }

    # R19 — Module 2 spot assumption (BTN-vs-BB SRP IP 100BB flop)
    if ($s.street -ne 'flop') {
      Add-Issue $local 'R19' 'error' $sid ("Module 2 expects street=flop, got " + $s.street) | Out-Null
    }
    if ($s.spot) {
      if ($s.spot.heroPosition    -and $s.spot.heroPosition    -ne 'BTN') { Add-Issue $local 'R19' 'error' $sid ("Module 2 expects spot.heroPosition=BTN, got " + $s.spot.heroPosition) | Out-Null }
      if ($s.spot.villainPosition -and $s.spot.villainPosition -ne 'BB')  { Add-Issue $local 'R19' 'error' $sid ("Module 2 expects spot.villainPosition=BB, got " + $s.spot.villainPosition) | Out-Null }
      if ($s.spot.potType         -and $s.spot.potType         -ne 'SRP') { Add-Issue $local 'R19' 'error' $sid ("Module 2 expects spot.potType=SRP, got " + $s.spot.potType) | Out-Null }
      if ($s.spot.effectiveStackBB -and $s.spot.effectiveStackBB -ne 100) { Add-Issue $local 'R19' 'error' $sid ("Module 2 expects spot.effectiveStackBB=100, got " + $s.spot.effectiveStackBB) | Out-Null }
    }

    # R20 — heroHand structure (2 valid distinct cards)
    if ($s.heroHand) {
      if ($s.heroHand.Count -ne 2) {
        Add-Issue $local 'R20' 'error' $sid ("heroHand has " + $s.heroHand.Count + " cards, expected 2") | Out-Null
      } else {
        $heroSeen = @{}
        foreach ($c in $s.heroHand) {
          if (-not $c -or $c.Length -ne 2) { Add-Issue $local 'R20' 'error' $sid ("invalid hero card '" + $c + "'") | Out-Null; continue }
          $r = $c.Substring(0,1); $u = $c.Substring(1,1)
          if ($validRanks -notcontains $r) { Add-Issue $local 'R20' 'error' $sid ("invalid rank in hero card '" + $c + "'") | Out-Null }
          if ($validSuits -notcontains $u) { Add-Issue $local 'R20' 'error' $sid ("invalid suit in hero card '" + $c + "'") | Out-Null }
          if ($heroSeen.ContainsKey("$c")) { Add-Issue $local 'R20' 'error' $sid ("duplicate hero card '" + $c + "'") | Out-Null }
          $heroSeen["$c"] = $true
        }
      }
    }

    # R21 — heroHand vs board collision
    if ($s.heroHand -and $s.board -and $s.board.cards) {
      $boardSet = @{}
      foreach ($c in $s.board.cards) { $boardSet["$c"] = $true }
      foreach ($c in $s.heroHand) {
        if ($boardSet.ContainsKey("$c")) {
          Add-Issue $local 'R21' 'error' $sid ("hero card '" + $c + "' also on board") | Out-Null
        }
      }
    }

    # R22 — question.type valid for Module 2
    $qtype = $null
    if ($s.question -and $s.question.type) {
      $qtype = $s.question.type
      if ($m2ValidQTypes -notcontains $qtype) {
        Add-Issue $local 'R22' 'error' $sid ("Module 2 question.type '" + $qtype + "' not in valid set") | Out-Null
      }
    }

    # R23 — choice id set per question type
    if ($qtype -eq 'action_choice') {
      $choiceIds = if ($s.question.choices) { @($s.question.choices | ForEach-Object { $_.id }) } else { @() }
      $missing = @($m2ValidActions | Where-Object { $choiceIds -notcontains $_ })
      $extra = @($choiceIds | Where-Object { $m2ValidActions -notcontains $_ })
      if ($missing.Count -gt 0) {
        Add-Issue $local 'R23' 'error' $sid ("action_choice missing required ids: " + ($missing -join ',')) | Out-Null
      }
      if ($extra.Count -gt 0) {
        Add-Issue $local 'R23' 'error' $sid ("action_choice has unexpected ids: " + ($extra -join ',')) | Out-Null
      }
    } elseif ($qtype -eq 'reason_choice') {
      $choiceIds = if ($s.question.choices) { @($s.question.choices | ForEach-Object { $_.id }) } else { @() }
      $invalid = @($choiceIds | Where-Object { $m2ValidReasons -notcontains $_ })
      if ($invalid.Count -gt 0) {
        Add-Issue $local 'R23' 'error' $sid ("reason_choice has invalid ids: " + ($invalid -join ',')) | Out-Null
      }
    }

    # R24 — handClass / heroHandRole / drawCategory / showdownValue vocab
    if ($s.handClass     -and ($m2ValidHandClasses -notcontains $s.handClass))     { Add-Issue $local 'R24' 'error' $sid ("handClass '" + $s.handClass + "' not in v4.1.2 vocab") | Out-Null }
    if ($s.heroHandRole  -and ($m2ValidHandRoles   -notcontains $s.heroHandRole))  { Add-Issue $local 'R24' 'error' $sid ("heroHandRole '" + $s.heroHandRole + "' not in v4.1.2 vocab") | Out-Null }
    if ($s.drawCategory  -and ($m2ValidDrawCats    -notcontains $s.drawCategory))  { Add-Issue $local 'R24' 'error' $sid ("drawCategory '" + $s.drawCategory + "' not in v4.1.2 vocab") | Out-Null }
    if ($s.showdownValue -and ($m2ValidShowdown    -notcontains $s.showdownValue)) { Add-Issue $local 'R24' 'error' $sid ("showdownValue '" + $s.showdownValue + "' not in v4.1.2 vocab") | Out-Null }

    # R25 — recommendedAction / actionReason vocab + consistency with answer.best
    if ($s.recommendedAction -and ($m2ValidActions -notcontains $s.recommendedAction)) {
      Add-Issue $local 'R25' 'error' $sid ("recommendedAction '" + $s.recommendedAction + "' not in valid set") | Out-Null
    }
    if ($s.actionReason -and ($m2ValidReasons -notcontains $s.actionReason)) {
      Add-Issue $local 'R25' 'error' $sid ("actionReason '" + $s.actionReason + "' not in valid set") | Out-Null
    }
    if ($qtype -eq 'action_choice' -and $s.recommendedAction -and $s.answer -and $s.answer.best) {
      if (@($s.answer.best) -notcontains $s.recommendedAction) {
        Add-Issue $local 'R25' 'error' $sid ("recommendedAction '" + $s.recommendedAction + "' not in answer.best (" + ((@($s.answer.best)) -join ',') + ")") | Out-Null
      }
    }
    if ($qtype -eq 'reason_choice' -and $s.actionReason -and $s.answer -and $s.answer.best) {
      if (@($s.answer.best) -notcontains $s.actionReason) {
        Add-Issue $local 'R25' 'error' $sid ("actionReason '" + $s.actionReason + "' not in answer.best for reason_choice") | Out-Null
      }
    }

    # R26 — explanation completeness for Module 2
    if ($s.explanation) {
      if (-not $s.explanation.handLogic) {
        Add-Issue $local 'R26' 'error' $sid 'Module 2 explanation.handLogic missing' | Out-Null
      }
      if (-not $s.explanation.takeaway) {
        Add-Issue $local 'R26' 'error' $sid 'Module 2 explanation.takeaway missing' | Out-Null
      }
      # sizingLogic required only for action_choice with bet recommendedAction
      if ($qtype -eq 'action_choice' -and $s.recommendedAction -in @('bet_small','bet_big')) {
        if (-not $s.explanation.sizingLogic) {
          Add-Issue $local 'R26' 'error' $sid ("Module 2 explanation.sizingLogic required when recommendedAction=" + $s.recommendedAction) | Out-Null
        }
      }
    }

    # R27 — suit-count discipline (made flush vs flush draw)
    if ($s.heroHand -and $s.board -and $s.board.cards -and $s.heroHand.Count -eq 2 -and $s.board.cards.Count -eq 3) {
      $allCards = @() + $s.board.cards + $s.heroHand
      $valid = $true
      foreach ($c in $allCards) { if (-not $c -or $c.Length -ne 2 -or ($validRanks -notcontains $c.Substring(0,1)) -or ($validSuits -notcontains $c.Substring(1,1))) { $valid = $false } }
      if ($valid) {
        $sc = @{ h=0; d=0; c=0; s=0 }
        foreach ($cd in $allCards) { $sc[$cd.Substring(1,1)] += 1 }
        $maxSuitCount = 0
        $flushSuit = $null
        foreach ($k in 'h','d','c','s') { if ($sc[$k] -gt $maxSuitCount) { $maxSuitCount = $sc[$k]; $flushSuit = $k } }
        # Made flush requires >=5 of one suit
        if ($s.handClass -in @('flush','nut_flush')) {
          if ($maxSuitCount -lt 5) {
            Add-Issue $local 'R27' 'error' $sid ("handClass='" + $s.handClass + "' but max suit count is " + $maxSuitCount + " (need 5+)") | Out-Null
          } elseif ($s.handClass -eq 'nut_flush' -and $flushSuit) {
            $aceOfSuit = "A$flushSuit"
            if (@($s.heroHand) -notcontains $aceOfSuit) {
              Add-Issue $local 'R27' 'error' $sid ("handClass='nut_flush' but hero does not hold " + $aceOfSuit) | Out-Null
            }
          }
        }
        # Flush draw requires exactly 4 of one suit
        if ($s.handClass -in @('flush_draw','nut_flush_draw')) {
          if ($maxSuitCount -ne 4) {
            Add-Issue $local 'R27' 'error' $sid ("handClass='" + $s.handClass + "' but max suit count is " + $maxSuitCount + " (need exactly 4)") | Out-Null
          } elseif ($s.handClass -eq 'nut_flush_draw' -and $flushSuit) {
            $aceOfSuit = "A$flushSuit"
            if (@($s.heroHand) -notcontains $aceOfSuit) {
              Add-Issue $local 'R27' 'error' $sid ("handClass='nut_flush_draw' but hero does not hold " + $aceOfSuit) | Out-Null
            }
          }
        }
        # drawCategory consistency
        if ($s.drawCategory -in @('fd','nut_fd')) {
          if ($maxSuitCount -ne 4) {
            Add-Issue $local 'R27' 'error' $sid ("drawCategory='" + $s.drawCategory + "' but max suit count is " + $maxSuitCount + " (need exactly 4)") | Out-Null
          } elseif ($s.drawCategory -eq 'nut_fd' -and $flushSuit) {
            $aceOfSuit = "A$flushSuit"
            if (@($s.heroHand) -notcontains $aceOfSuit) {
              Add-Issue $local 'R27' 'error' $sid ("drawCategory='nut_fd' but hero does not hold " + $aceOfSuit) | Out-Null
            }
          }
        }
      }
    }

    # R28 — sourceConfidence/auditStatus honesty for Module 2
    # sourceConfidence already validated by R17. Add: solver_verified requires solverRunRef.
    if ($s.sourceConfidence -eq 'solver_verified' -and -not $s.solverRunRef) {
      Add-Issue $local 'R28' 'error' $sid 'sourceConfidence=solver_verified requires solverRunRef field' | Out-Null
    }
  }

  # ========================================================================
  # R30-R41 — Module 3 (pf_flop_cbet_oop_def) v4.2.0 schema rules
  # Apply only to Module 3 scenarios. Mirror the hard-error subset of the
  # M3 seed audit plan (docs/specs/postflop-v4.2.0-module3-audit-plan.md
  # rules M3-R11..R43). Coverage warnings (M3-R45..R49) are excluded —
  # those are seed-only checks. R29 is reserved for the v4.2.2D/E
  # card-notation guard, so M3 production rules begin at R30.
  #
  # Schema differs from M2: question.choices is an array of strings (not
  # objects with id), and answer.best is a single string (not an array).
  # ========================================================================
  if ($s.module -eq 'pf_flop_cbet_oop_def') {
    $m3ValidActions   = @('fold','call','check_raise_small','check_raise_big','mixed')
    $m3ValidReasons   = @('value_raise','protection_raise','semi_bluff_raise','blocker_raise',
                          'bluff_catch','equity_realization_call','slowplay_call',
                          'range_disadvantage_fold','domination_fold')
    $m3ValidQTypes    = @('action_choice','reason_choice')
    $m3ValidHandRoles = @('nutted_value','strong_value','marginal_made_hand','bluff_catcher',
                          'semi_bluff_combo','pure_draw','blocker_bluff','give_up','dominated_marginal')
    $m3ValidHandClass = @('set','top_two_pair','two_pair','overpair','underpair',
                          'top_pair_top_kicker','top_pair_good_kicker','top_pair_weak_kicker',
                          'second_pair','third_pair_or_lower','mid_pair','bottom_pair',
                          'combo_draw','oesd','gutshot','flush_draw','nut_flush_draw',
                          'backdoor_only','no_pair_no_draw','straight','flush','nut_flush','trips','full_house')
    $m3ValidDrawCats  = @('none','backdoor_only','gutshot','oesd','flush_draw','combo_draw','nut_flush_draw')
    $m3ValidShowdown  = @('none','low','decent','high','nutted')
    $m3ValidConcepts  = @('oop_defense_threshold','check_raise_value','check_raise_bluff',
                          'bluff_catchers','equity_realization_oop','range_disadvantage','pot_odds_defense',
                          'pot_control','value_raise','protection_raise','semi_bluff_raise',
                          'value_betting','blocker_pressure','give_up_strategy','range_advantage_stab',
                          'thin_value_betting','semi_bluff_with_equity','protection_betting',
                          'common_leaks','equity_realization')

    # R30 — spot assumption (NLH_MTT, 100BB, SRP, BB vs BTN, cbet small)
    if ($s.street -ne 'flop') {
      Add-Issue $local 'R30' 'error' $sid ("Module 3 expects street=flop, got " + $s.street) | Out-Null
    }
    if ($s.spot) {
      if ($s.spot.format          -and $s.spot.format          -ne 'NLH_MTT') { Add-Issue $local 'R30' 'error' $sid ("Module 3 expects spot.format=NLH_MTT, got " + $s.spot.format) | Out-Null }
      if ($s.spot.stackDepth      -and $s.spot.stackDepth      -ne '100BB')   { Add-Issue $local 'R30' 'error' $sid ("Module 3 expects spot.stackDepth=100BB, got " + $s.spot.stackDepth) | Out-Null }
      if ($s.spot.potType         -and $s.spot.potType         -ne 'SRP')     { Add-Issue $local 'R30' 'error' $sid ("Module 3 expects spot.potType=SRP, got " + $s.spot.potType) | Out-Null }
      if ($s.spot.heroPosition    -and $s.spot.heroPosition    -ne 'BB')      { Add-Issue $local 'R30' 'error' $sid ("Module 3 expects spot.heroPosition=BB, got " + $s.spot.heroPosition) | Out-Null }
      if ($s.spot.villainPosition -and $s.spot.villainPosition -ne 'BTN')     { Add-Issue $local 'R30' 'error' $sid ("Module 3 expects spot.villainPosition=BTN, got " + $s.spot.villainPosition) | Out-Null }
    }

    # R31 — action_choice schema: choices array exactly equals m3ValidActions
    $m3qtype = $null
    if ($s.question -and $s.question.qtype) { $m3qtype = $s.question.qtype }
    if (-not $m3qtype -and $s.question -and $s.question.type) { $m3qtype = $s.question.type }
    if ($m3qtype -and ($m3ValidQTypes -notcontains $m3qtype)) {
      Add-Issue $local 'R31' 'error' $sid ("Module 3 question.qtype '" + $m3qtype + "' not in valid set") | Out-Null
    }
    if ($m3qtype -eq 'action_choice') {
      if (-not $s.question.choices) {
        Add-Issue $local 'R31' 'error' $sid 'Module 3 action_choice requires question.choices' | Out-Null
      } else {
        $m3choices = @($s.question.choices)
        $missing = @($m3ValidActions | Where-Object { $m3choices -notcontains $_ })
        $extra   = @($m3choices | Where-Object { $m3ValidActions -notcontains $_ })
        if ($missing.Count -gt 0) { Add-Issue $local 'R31' 'error' $sid ("M3 action_choice missing required: " + ($missing -join ',')) | Out-Null }
        if ($extra.Count   -gt 0) { Add-Issue $local 'R31' 'error' $sid ("M3 action_choice has unexpected: " + ($extra -join ',')) | Out-Null }
      }
      if ($s.recommendedAction -and ($m3ValidActions -notcontains $s.recommendedAction)) {
        Add-Issue $local 'R31' 'error' $sid ("M3 recommendedAction '" + $s.recommendedAction + "' not in valid set") | Out-Null
      }
      if ($s.answer -and $s.answer.best -and $s.recommendedAction -and ($s.answer.best -ne $s.recommendedAction)) {
        Add-Issue $local 'R31' 'error' $sid ("M3 answer.best '" + $s.answer.best + "' != recommendedAction '" + $s.recommendedAction + "'") | Out-Null
      }
    }

    # R32 — reason_choice schema: choices subset of m3ValidReasons
    if ($m3qtype -eq 'reason_choice') {
      if (-not $s.question.choices) {
        Add-Issue $local 'R32' 'error' $sid 'Module 3 reason_choice requires question.choices' | Out-Null
      } else {
        $m3rc = @($s.question.choices)
        $invalid = @($m3rc | Where-Object { $m3ValidReasons -notcontains $_ })
        if ($invalid.Count -gt 0) { Add-Issue $local 'R32' 'error' $sid ("M3 reason_choice has invalid: " + ($invalid -join ',')) | Out-Null }
      }
      if ($s.actionReason -and ($m3ValidReasons -notcontains $s.actionReason)) {
        Add-Issue $local 'R32' 'error' $sid ("M3 actionReason '" + $s.actionReason + "' not in valid set") | Out-Null
      }
      if ($s.answer -and $s.answer.best -and $s.actionReason -and ($s.answer.best -ne $s.actionReason)) {
        Add-Issue $local 'R32' 'error' $sid ("M3 answer.best '" + $s.answer.best + "' != actionReason '" + $s.actionReason + "' for reason_choice") | Out-Null
      }
    }

    # R33 — heroHand structure + handClass / heroHandRole / drawCategory / showdownValue vocab
    if (-not $s.heroHand) {
      Add-Issue $local 'R33' 'error' $sid 'Module 3 requires heroHand' | Out-Null
    } elseif ($s.heroHand.Count -ne 2) {
      Add-Issue $local 'R33' 'error' $sid ("M3 heroHand has " + $s.heroHand.Count + " cards, expected 2") | Out-Null
    } else {
      $m3HeroSeen = @{}
      foreach ($c in $s.heroHand) {
        if (-not $c -or $c.Length -ne 2) { Add-Issue $local 'R33' 'error' $sid ("M3 invalid hero card '" + $c + "'") | Out-Null; continue }
        $r = $c.Substring(0,1); $u = $c.Substring(1,1)
        if ($validRanks -notcontains $r) { Add-Issue $local 'R33' 'error' $sid ("M3 invalid rank in hero card '" + $c + "'") | Out-Null }
        if ($validSuits -notcontains $u) { Add-Issue $local 'R33' 'error' $sid ("M3 invalid suit in hero card '" + $c + "'") | Out-Null }
        if ($m3HeroSeen.ContainsKey("$c")) { Add-Issue $local 'R33' 'error' $sid ("M3 duplicate hero card '" + $c + "'") | Out-Null }
        $m3HeroSeen["$c"] = $true
      }
    }
    if ($s.handClass     -and ($m3ValidHandClass -notcontains $s.handClass))     { Add-Issue $local 'R33' 'error' $sid ("M3 handClass '" + $s.handClass + "' not in v4.2.0 vocab") | Out-Null }
    if ($s.heroHandRole  -and ($m3ValidHandRoles -notcontains $s.heroHandRole))  { Add-Issue $local 'R33' 'error' $sid ("M3 heroHandRole '" + $s.heroHandRole + "' not in v4.2.0 vocab") | Out-Null }
    if ($s.drawCategory  -and ($m3ValidDrawCats  -notcontains $s.drawCategory))  { Add-Issue $local 'R33' 'error' $sid ("M3 drawCategory '" + $s.drawCategory + "' not in v4.2.0 vocab") | Out-Null }
    if ($s.showdownValue -and ($m3ValidShowdown  -notcontains $s.showdownValue)) { Add-Issue $local 'R33' 'error' $sid ("M3 showdownValue '" + $s.showdownValue + "' not in v4.2.0 vocab") | Out-Null }

    # R34 — answer consistency: best is single string; acceptable/bad/critical disjoint from best
    if ($s.answer) {
      if ($null -eq $s.answer.best) {
        Add-Issue $local 'R34' 'error' $sid 'M3 answer.best is required' | Out-Null
      } elseif ($s.answer.best -isnot [string]) {
        Add-Issue $local 'R34' 'error' $sid ("M3 answer.best must be a string, got " + $s.answer.best.GetType().Name) | Out-Null
      }
      $m3best = $s.answer.best
      $m3acc  = @(); if ($s.answer.acceptable) { $m3acc  = @($s.answer.acceptable) }
      $m3bad  = @(); if ($s.answer.bad)        { $m3bad  = @($s.answer.bad) }
      $m3crit = @(); if ($s.answer.critical)   { $m3crit = @($s.answer.critical) }
      if ($m3best -and ($m3acc -contains $m3best)) {
        Add-Issue $local 'R34' 'error' $sid ("M3 answer.best '" + $m3best + "' also appears in acceptable") | Out-Null
      }
      if ($m3best -and ($m3bad -contains $m3best)) {
        Add-Issue $local 'R34' 'error' $sid ("M3 answer.best '" + $m3best + "' also appears in bad") | Out-Null
      }
      foreach ($a in $m3acc) {
        if ($m3bad -contains $a) {
          Add-Issue $local 'R34' 'error' $sid ("M3 acceptable choice '" + $a + "' also appears in bad") | Out-Null
        }
      }
      foreach ($c in $m3crit) {
        if (-not ($m3bad -contains $c)) {
          Add-Issue $local 'R34' 'error' $sid ("M3 critical choice '" + $c + "' must also appear in bad") | Out-Null
        }
      }
      # All choices in best/acceptable/bad/critical must be valid for the qtype
      $m3choiceUniverse = if ($m3qtype -eq 'action_choice') { $m3ValidActions } elseif ($m3qtype -eq 'reason_choice') { $m3ValidReasons } else { @() }
      if ($m3choiceUniverse.Count -gt 0) {
        $allM3 = @($m3best) + $m3acc + $m3bad + $m3crit | Where-Object { $_ }
        foreach ($id in $allM3) {
          if ($m3choiceUniverse -notcontains $id) {
            Add-Issue $local 'R34' 'error' $sid ("M3 answer references invalid id '" + $id + "' for qtype " + $m3qtype) | Out-Null
          }
        }
      }
    }

    # R35 — explanation completeness: short / rangeContext / handLogic / takeaway / defenseLogic required
    if ($s.explanation) {
      foreach ($fld in @('short','rangeContext','handLogic','takeaway','defenseLogic')) {
        $v = $s.explanation.$fld
        if (-not $v -or ($v -is [string] -and $v.Trim().Length -eq 0)) {
          Add-Issue $local 'R35' 'error' $sid ("M3 explanation." + $fld + " is required") | Out-Null
        }
      }
    } else {
      Add-Issue $local 'R35' 'error' $sid 'M3 explanation block missing' | Out-Null
    }

    # R36 — concept tags: 1-4 entries, all from M3 + reusable M2 vocabulary
    if (-not $s.conceptTags -or $s.conceptTags.Count -eq 0) {
      Add-Issue $local 'R36' 'error' $sid 'M3 conceptTags must be non-empty' | Out-Null
    } else {
      if ($s.conceptTags.Count -gt 4) {
        Add-Issue $local 'R36' 'error' $sid ("M3 conceptTags has " + $s.conceptTags.Count + " entries (max 4)") | Out-Null
      }
      foreach ($tg in $s.conceptTags) {
        if ($m3ValidConcepts -notcontains $tg) {
          Add-Issue $local 'R36' 'error' $sid ("M3 conceptTag '" + $tg + "' not in M3 + reusable M2 vocabulary") | Out-Null
        }
      }
    }

    # R37 — sourceConfidence honesty: solver_verified requires solverRunRef
    if ($s.sourceConfidence -eq 'solver_verified' -and -not $s.solverRunRef) {
      Add-Issue $local 'R37' 'error' $sid 'M3 sourceConfidence=solver_verified requires solverRunRef field' | Out-Null
    }

    # R38 — villainAction must be 'cbet'
    if ($s.spot -and $s.spot.villainAction -and $s.spot.villainAction -ne 'cbet') {
      Add-Issue $local 'R38' 'error' $sid ("M3 spot.villainAction must be 'cbet', got '" + $s.spot.villainAction + "'") | Out-Null
    }

    # R39 — villainSizing must match the c-bet sizing trained (currently 'small' only in v4.2.0)
    if ($s.spot -and $s.spot.villainSizing -and $s.spot.villainSizing -ne 'small') {
      Add-Issue $local 'R39' 'error' $sid ("M3 spot.villainSizing must be 'small' in v4.2.3, got '" + $s.spot.villainSizing + "'") | Out-Null
    }

    # R40 — heroHand vs board collision (explicit M3 re-check)
    if ($s.heroHand -and $s.board -and $s.board.cards) {
      $m3BoardSet = @{}
      foreach ($c in $s.board.cards) { $m3BoardSet["$c"] = $true }
      foreach ($c in $s.heroHand) {
        if ($m3BoardSet.ContainsKey("$c")) {
          Add-Issue $local 'R40' 'error' $sid ("M3 hero card '" + $c + "' also on board") | Out-Null
        }
      }
    }

    # R41 — moduleId consistency (trivial guard against typos)
    if ($s.module -ne 'pf_flop_cbet_oop_def') {
      Add-Issue $local 'R41' 'error' $sid ("M3 expects module='pf_flop_cbet_oop_def', got '" + $s.module + "'") | Out-Null
    }
  }

  # ========================================================================
  # R55-R75 -- Module 4 (pf_turn_barrel_oop_def) v4.3.0B production rules
  # Apply only to Module 4 scenarios. Mirror the hard-error subset of the
  # M4 seed audit plan (docs/specs/postflop-v4.3.0-module4-audit-plan.md
  # rules M4.R01..R49 + R50..R54). Numbering: R55 onwards to avoid the
  # R29 (card-notation guard) and R30-R41 (M3) ranges.
  # ========================================================================
  if ($s.module -eq 'pf_turn_barrel_oop_def') {
    $m4ValidActions   = @('fold','call','check_raise_small','check_raise_big','mixed')
    $m4ValidReasons   = @('pot_odds_turn_call','equity_realization_turn_call','bluff_catch_turn',
                          'board_change_fold','domination_turn_fold','range_disadvantage_turn_fold',
                          'value_check_raise_turn','protection_check_raise_turn','semi_bluff_check_raise_turn',
                          'blocker_check_raise_turn','slowplay_turn_call','mixed_indifference_turn')
    $m4ValidQTypes    = @('action_choice','reason_choice')
    $m4ValidHandRoles = @('strong_value','nutted_value','bluff_catcher','marginal_made_hand',
                          'dominated_marginal','combo_draw','draw','give_up','air',
                          'bluff_candidate','blocker_bluff','slowplay_trap','protection_needed')
    $m4ValidHandClass = @('set','top_two_pair','two_pair','overpair','underpair',
                          'top_pair_top_kicker','top_pair_good_kicker','top_pair_weak_kicker',
                          'second_pair','third_pair_or_lower','mid_pair','bottom_pair',
                          'combo_draw','oesd','gutshot','flush_draw','nut_flush_draw',
                          'backdoor_only','no_pair_no_draw','straight','flush','nut_flush','trips','full_house')
    $m4ValidDrawCats  = @('none','backdoor_only','gutshot','oesd','flush_draw','combo_draw','nut_flush_draw',
                          'straight_draw_added','flush_draw_added','oesd_added','gutshot_added','multi_draw_added')
    $m4ValidShowdown  = @('none','low','decent','high','nutted')
    $m4ValidConcepts  = @('turn_equity_shift','second_barrel_defense','turn_pot_odds','turn_bluff_catcher',
                          'turn_domination_fold','turn_board_change','turn_draw_completion',
                          'turn_check_raise_value','turn_check_raise_bluff','turn_blocker_pressure',
                          'turn_slowplay_call','turn_range_disadvantage')
    $m4ValidTurnCats  = @('brick','overcard','flush_complete','flush_draw_added','straight_complete',
                          'straight_draw_added','board_pair','draw_intensifier','top_pair_changer',
                          'ace_overcard','low_blank','high_blank')
    $m4ValidAuditStat = @('approved','review_pending','planning_only','draft','needs_review','deprecated')

    # R55 -- module id + street + game lock
    if ($s.module -ne 'pf_turn_barrel_oop_def') {
      Add-Issue $local 'R55' 'error' $sid ("M4 expects module='pf_turn_barrel_oop_def', got '" + $s.module + "'") | Out-Null
    }
    if ($s.street -ne 'turn') {
      Add-Issue $local 'R55' 'error' $sid ("M4 expects street=turn, got " + $s.street) | Out-Null
    }
    if ($s.game -and $s.game -ne 'NLH_MTT') {
      Add-Issue $local 'R55' 'error' $sid ("M4 expects game=NLH_MTT, got " + $s.game) | Out-Null
    }
    if ($s.schemaVersion -and $s.schemaVersion -ne '1.2.0') {
      Add-Issue $local 'R55' 'error' $sid ("M4 expects schemaVersion=1.2.0, got " + $s.schemaVersion) | Out-Null
    }

    # R56 -- spot block matches BB-vs-BTN turn-defense lock
    if ($s.spot) {
      if ($s.spot.format          -and $s.spot.format          -ne 'NLH_MTT')                { Add-Issue $local 'R56' 'error' $sid ("M4 expects spot.format=NLH_MTT, got " + $s.spot.format) | Out-Null }
      if ($s.spot.stackDepth      -and $s.spot.stackDepth      -ne '100BB')                  { Add-Issue $local 'R56' 'error' $sid ("M4 expects spot.stackDepth=100BB, got " + $s.spot.stackDepth) | Out-Null }
      if ($s.spot.potType         -and $s.spot.potType         -ne 'SRP')                    { Add-Issue $local 'R56' 'error' $sid ("M4 expects spot.potType=SRP, got " + $s.spot.potType) | Out-Null }
      if ($s.spot.heroPosition    -and $s.spot.heroPosition    -ne 'BB')                     { Add-Issue $local 'R56' 'error' $sid ("M4 expects spot.heroPosition=BB, got " + $s.spot.heroPosition) | Out-Null }
      if ($s.spot.villainPosition -and $s.spot.villainPosition -ne 'BTN')                    { Add-Issue $local 'R56' 'error' $sid ("M4 expects spot.villainPosition=BTN, got " + $s.spot.villainPosition) | Out-Null }
      if ($s.spot.heroRole        -and $s.spot.heroRole        -ne 'flop_check_caller_oop')  { Add-Issue $local 'R56' 'error' $sid ("M4 expects spot.heroRole=flop_check_caller_oop, got " + $s.spot.heroRole) | Out-Null }
      if ($s.spot.villainRole     -and $s.spot.villainRole     -ne 'turn_barreler_ip')       { Add-Issue $local 'R56' 'error' $sid ("M4 expects spot.villainRole=turn_barreler_ip, got " + $s.spot.villainRole) | Out-Null }
      if ($s.spot.street          -and $s.spot.street          -ne 'turn')                   { Add-Issue $local 'R56' 'error' $sid ("M4 expects spot.street=turn, got " + $s.spot.street) | Out-Null }
    } else {
      Add-Issue $local 'R56' 'error' $sid 'M4 spot block missing' | Out-Null
    }

    # R57 -- 4-card board structure (flopCards + turnCard + cards)
    if (-not $s.board) {
      Add-Issue $local 'R57' 'error' $sid 'M4 board block missing' | Out-Null
    } else {
      $fc = @($s.board.flopCards)
      if ($fc.Count -ne 3) {
        Add-Issue $local 'R57' 'error' $sid ("M4 board.flopCards count " + $fc.Count + ", expected 3") | Out-Null
      }
      if (-not $s.board.turnCard) {
        Add-Issue $local 'R57' 'error' $sid 'M4 board.turnCard missing' | Out-Null
      } elseif ($s.board.turnCard.Length -ne 2) {
        Add-Issue $local 'R57' 'error' $sid ("M4 board.turnCard '" + $s.board.turnCard + "' invalid format") | Out-Null
      } else {
        $r = $s.board.turnCard.Substring(0,1); $u = $s.board.turnCard.Substring(1,1)
        if ($validRanks -notcontains $r) { Add-Issue $local 'R57' 'error' $sid ("M4 turnCard rank invalid '" + $r + "'") | Out-Null }
        if ($validSuits -notcontains $u) { Add-Issue $local 'R57' 'error' $sid ("M4 turnCard suit invalid '" + $u + "'") | Out-Null }
      }
      $cards = @($s.board.cards)
      if ($cards.Count -ne 4) {
        Add-Issue $local 'R57' 'error' $sid ("M4 board.cards count " + $cards.Count + ", expected 4") | Out-Null
      } else {
        # cards must equal flopCards + turnCard
        $expected = @()
        if ($fc.Count -eq 3) { $expected = @($fc) + @($s.board.turnCard) }
        $expectedJoin = ($expected -join ',')
        $actualJoin = ($cards -join ',')
        if ($expected.Count -eq 4 -and $expectedJoin -ne $actualJoin) {
          Add-Issue $local 'R57' 'error' $sid ("M4 board.cards != flopCards+turnCard ('" + $actualJoin + "' vs '" + $expectedJoin + "')") | Out-Null
        }
        # No duplicate cards
        $u2 = ($cards | Sort-Object -Unique).Count
        if ($u2 -ne $cards.Count) {
          Add-Issue $local 'R57' 'error' $sid ("M4 board has duplicate cards: " + ($cards -join ',')) | Out-Null
        }
      }
    }

    # R58 -- M4-specific board enums
    if ($s.board) {
      if ($s.board.turnCategory -and ($m4ValidTurnCats -notcontains $s.board.turnCategory)) {
        Add-Issue $local 'R58' 'error' $sid ("M4 turnCategory '" + $s.board.turnCategory + "' not in valid set") | Out-Null
      }
    }

    # R59 -- heroHand 2 cards + no hero/board collision
    if (-not $s.heroHand) {
      Add-Issue $local 'R59' 'error' $sid 'M4 requires heroHand' | Out-Null
    } elseif ($s.heroHand.Count -ne 2) {
      Add-Issue $local 'R59' 'error' $sid ("M4 heroHand has " + $s.heroHand.Count + " cards, expected 2") | Out-Null
    } else {
      foreach ($c in $s.heroHand) {
        if (-not $c -or $c.Length -ne 2) { Add-Issue $local 'R59' 'error' $sid ("M4 invalid hero card '" + $c + "'") | Out-Null; continue }
        $r = $c.Substring(0,1); $u = $c.Substring(1,1)
        if ($validRanks -notcontains $r) { Add-Issue $local 'R59' 'error' $sid ("M4 invalid rank in hero card '" + $c + "'") | Out-Null }
        if ($validSuits -notcontains $u) { Add-Issue $local 'R59' 'error' $sid ("M4 invalid suit in hero card '" + $c + "'") | Out-Null }
      }
      if ($s.board -and $s.board.cards) {
        $boardSet = @{}
        foreach ($c in $s.board.cards) { $boardSet["$c"] = $true }
        foreach ($c in $s.heroHand) {
          if ($boardSet.ContainsKey("$c")) {
            Add-Issue $local 'R59' 'error' $sid ("M4 hero card '" + $c + "' also on board") | Out-Null
          }
        }
      }
    }

    # R60 -- handClass / heroHandRole / drawCategory / showdownValue vocab
    if ($s.handClass     -and ($m4ValidHandClass -notcontains $s.handClass))     { Add-Issue $local 'R60' 'error' $sid ("M4 handClass '" + $s.handClass + "' not in v4.3.0B vocab") | Out-Null }
    if ($s.heroHandRole  -and ($m4ValidHandRoles -notcontains $s.heroHandRole))  { Add-Issue $local 'R60' 'error' $sid ("M4 heroHandRole '" + $s.heroHandRole + "' not in v4.3.0B vocab") | Out-Null }
    if ($s.drawCategory  -and ($m4ValidDrawCats  -notcontains $s.drawCategory))  { Add-Issue $local 'R60' 'error' $sid ("M4 drawCategory '" + $s.drawCategory + "' not in v4.3.0B vocab") | Out-Null }
    if ($s.showdownValue -and ($m4ValidShowdown  -notcontains $s.showdownValue)) { Add-Issue $local 'R60' 'error' $sid ("M4 showdownValue '" + $s.showdownValue + "' not in v4.3.0B vocab") | Out-Null }

    # R61 -- question schema (qtype + choices)
    $m4qtype = $null
    if ($s.question -and $s.question.qtype) { $m4qtype = $s.question.qtype }
    if ($m4qtype -and ($m4ValidQTypes -notcontains $m4qtype)) {
      Add-Issue $local 'R61' 'error' $sid ("M4 question.qtype '" + $m4qtype + "' not in valid set") | Out-Null
    }
    if ($m4qtype -eq 'action_choice') {
      if (-not $s.question.choices) {
        Add-Issue $local 'R61' 'error' $sid 'M4 action_choice requires question.choices' | Out-Null
      } else {
        $m4choices = @($s.question.choices)
        $missing = @($m4ValidActions | Where-Object { $m4choices -notcontains $_ })
        $extra   = @($m4choices | Where-Object { $m4ValidActions -notcontains $_ })
        if ($missing.Count -gt 0) { Add-Issue $local 'R61' 'error' $sid ("M4 action_choice missing required: " + ($missing -join ',')) | Out-Null }
        if ($extra.Count   -gt 0) { Add-Issue $local 'R61' 'error' $sid ("M4 action_choice has unexpected: " + ($extra -join ',')) | Out-Null }
      }
      if ($s.recommendedAction -and ($m4ValidActions -notcontains $s.recommendedAction)) {
        Add-Issue $local 'R61' 'error' $sid ("M4 recommendedAction '" + $s.recommendedAction + "' not in valid set") | Out-Null
      }
      if ($s.answer -and $s.answer.best -and $s.recommendedAction -and ($s.answer.best -ne $s.recommendedAction)) {
        Add-Issue $local 'R61' 'error' $sid ("M4 answer.best '" + $s.answer.best + "' != recommendedAction '" + $s.recommendedAction + "'") | Out-Null
      }
      # R62 -- prompt completeness: must not end with 'with ' and must contain both hero cards
      if ($s.question.prompt -match 'with\s*$') {
        Add-Issue $local 'R62' 'error' $sid "M4 action_choice prompt ends with 'with ' (hero hand lost)" | Out-Null
      }
      if ($s.heroHand -and $s.heroHand.Count -eq 2 -and $s.question.prompt) {
        $promptText = $s.question.prompt
        $foundBoth = $true
        foreach ($c in $s.heroHand) {
          if ($promptText -notmatch [regex]::Escape($c)) { $foundBoth = $false; break }
        }
        if (-not $foundBoth) {
          Add-Issue $local 'R62' 'error' $sid ("M4 action_choice prompt does not contain both hero cards '" + ($s.heroHand -join "','") + "'") | Out-Null
        }
      }
    }

    # R63 -- reason_choice schema: choices subset of m4ValidReasons; actionReason matches answer.best
    if ($m4qtype -eq 'reason_choice') {
      if (-not $s.question.choices) {
        Add-Issue $local 'R63' 'error' $sid 'M4 reason_choice requires question.choices' | Out-Null
      } else {
        $m4rc = @($s.question.choices)
        $invalid = @($m4rc | Where-Object { $m4ValidReasons -notcontains $_ })
        if ($invalid.Count -gt 0) { Add-Issue $local 'R63' 'error' $sid ("M4 reason_choice has invalid: " + ($invalid -join ',')) | Out-Null }
      }
      if ($s.actionReason -and ($m4ValidReasons -notcontains $s.actionReason)) {
        Add-Issue $local 'R63' 'error' $sid ("M4 actionReason '" + $s.actionReason + "' not in valid set") | Out-Null
      }
      if ($s.answer -and $s.answer.best -and $s.actionReason -and ($s.answer.best -ne $s.actionReason)) {
        Add-Issue $local 'R63' 'error' $sid ("M4 answer.best '" + $s.answer.best + "' != actionReason '" + $s.actionReason + "' for reason_choice") | Out-Null
      }
    }
    # actionReason vocab check (also applies to action_choice scenarios where actionReason is present)
    if ($s.actionReason -and ($m4ValidReasons -notcontains $s.actionReason)) {
      Add-Issue $local 'R63' 'error' $sid ("M4 actionReason '" + $s.actionReason + "' not in v4.3.0B vocab") | Out-Null
    }

    # R64 -- answer partition consistency: best/acceptable/bad disjoint; critical subset of bad
    if ($s.answer) {
      if ($null -eq $s.answer.best) {
        Add-Issue $local 'R64' 'error' $sid 'M4 answer.best is required' | Out-Null
      } elseif ($s.answer.best -isnot [string]) {
        Add-Issue $local 'R64' 'error' $sid ("M4 answer.best must be a string, got " + $s.answer.best.GetType().Name) | Out-Null
      }
      $m4best = $s.answer.best
      $m4acc  = @(); if ($s.answer.acceptable) { $m4acc  = @($s.answer.acceptable) }
      $m4bad  = @(); if ($s.answer.bad)        { $m4bad  = @($s.answer.bad) }
      $m4crit = @(); if ($s.answer.critical)   { $m4crit = @($s.answer.critical) }
      if ($m4best -and ($m4acc -contains $m4best)) {
        Add-Issue $local 'R64' 'error' $sid ("M4 answer.best '" + $m4best + "' also appears in acceptable") | Out-Null
      }
      if ($m4best -and ($m4bad -contains $m4best)) {
        Add-Issue $local 'R64' 'error' $sid ("M4 answer.best '" + $m4best + "' also appears in bad") | Out-Null
      }
      foreach ($a in $m4acc) {
        if ($m4bad -contains $a) {
          Add-Issue $local 'R64' 'error' $sid ("M4 acceptable choice '" + $a + "' also appears in bad") | Out-Null
        }
      }
      foreach ($c in $m4crit) {
        if (-not ($m4bad -contains $c)) {
          Add-Issue $local 'R64' 'error' $sid ("M4 critical choice '" + $c + "' must also appear in bad") | Out-Null
        }
      }
      $m4choiceUniverse = if ($m4qtype -eq 'action_choice') { $m4ValidActions } elseif ($m4qtype -eq 'reason_choice') { $m4ValidReasons } else { @() }
      if ($m4choiceUniverse.Count -gt 0) {
        $allM4 = @($m4best) + $m4acc + $m4bad + $m4crit | Where-Object { $_ }
        foreach ($id in $allM4) {
          if ($m4choiceUniverse -notcontains $id) {
            Add-Issue $local 'R64' 'error' $sid ("M4 answer references invalid id '" + $id + "' for qtype " + $m4qtype) | Out-Null
          }
        }
      }
    }

    # R65 -- explanation completeness: short / turnLogic / rangeContext / handLogic / sizingLogic / commonMistake / takeaway
    if ($s.explanation) {
      foreach ($fld in @('short','turnLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')) {
        $v = $s.explanation.$fld
        if (-not $v -or ($v -is [string] -and $v.Trim().Length -eq 0)) {
          Add-Issue $local 'R65' 'error' $sid ("M4 explanation." + $fld + " is required") | Out-Null
        }
      }
    } else {
      Add-Issue $local 'R65' 'error' $sid 'M4 explanation block missing' | Out-Null
    }

    # R66 -- conceptTags: 1-4 entries, no duplicates, all in M4 concept vocab
    if (-not $s.conceptTags -or $s.conceptTags.Count -eq 0) {
      Add-Issue $local 'R66' 'error' $sid 'M4 conceptTags must be non-empty' | Out-Null
    } else {
      if ($s.conceptTags.Count -gt 4) {
        Add-Issue $local 'R66' 'error' $sid ("M4 conceptTags has " + $s.conceptTags.Count + " entries (max 4)") | Out-Null
      }
      $tagSeen = @{}
      foreach ($tg in $s.conceptTags) {
        if ($m4ValidConcepts -notcontains $tg) {
          Add-Issue $local 'R66' 'error' $sid ("M4 conceptTag '" + $tg + "' not in M4 concept vocab") | Out-Null
        }
        if ($tagSeen.ContainsKey("$tg")) {
          Add-Issue $local 'R66' 'error' $sid ("M4 duplicate conceptTag '" + $tg + "'") | Out-Null
        }
        $tagSeen["$tg"] = $true
      }
    }

    # R67 -- auditStatus + sourceConfidence
    if ($s.auditStatus -and ($m4ValidAuditStat -notcontains $s.auditStatus)) {
      Add-Issue $local 'R67' 'error' $sid ("M4 auditStatus '" + $s.auditStatus + "' not in valid set") | Out-Null
    }
    if ($s.sourceConfidence -eq 'solver_verified' -and -not $s.solverRunRef) {
      Add-Issue $local 'R67' 'error' $sid 'M4 sourceConfidence=solver_verified requires solverRunRef field' | Out-Null
    }

    # R68 -- nut_flush_draw invariant: drawCategory='nut_flush_draw' requires hero to hold A of a 4-suited suit
    if ($s.drawCategory -eq 'nut_flush_draw' -and $s.heroHand -and $s.board -and $s.board.cards) {
      $hh = @($s.heroHand)
      $bc = @($s.board.cards)
      $foundNutFD = $false
      foreach ($suit in 'cdhs'.ToCharArray()) {
        $sc = [string]$suit
        $heroHasA = ($hh -contains "A$sc")
        $heroSuitCount = (@($hh) | Where-Object { $_.Length -eq 2 -and $_.Substring(1,1) -eq $sc }).Count
        $boardSuitCount = (@($bc) | Where-Object { $_.Length -eq 2 -and $_.Substring(1,1) -eq $sc }).Count
        $totalSuit = $heroSuitCount + $boardSuitCount
        if ($heroHasA -and $totalSuit -eq 4) { $foundNutFD = $true; break }
      }
      if (-not $foundNutFD) {
        Add-Issue $local 'R68' 'error' $sid "M4 drawCategory=nut_flush_draw but hero does not hold A of a suit with exactly 4 of that suit across hero+board" | Out-Null
      }
    }

    # R69 -- "nut-<suit>" blocker invariant: blockerNote claiming nut-<color> requires hero A of that suit
    if ($s.heroHandRole -eq 'blocker_bluff' -and $s.blockerNote -and $s.heroHand) {
      $hh = @($s.heroHand)
      $bn = $s.blockerNote
      $suitMap = @{ 'spade'='s'; 'heart'='h'; 'club'='c'; 'diamond'='d' }
      foreach ($word in $suitMap.Keys) {
        $rxFull = "nut[- ]$word"
        if ($bn -match $rxFull) {
          $sc = $suitMap[$word]
          if (-not ($hh -contains "A$sc")) {
            Add-Issue $local 'R69' 'error' $sid ("M4 blockerNote claims 'nut-" + $word + "' blocker but hero does not hold A" + $sc) | Out-Null
          }
        }
      }
    }

    # R70 -- handClass='straight' invariant: 5 consecutive ranks (or A-2-3-4-5) in hero+board
    if ($s.handClass -eq 'straight' -and $s.heroHand -and $s.board -and $s.board.cards) {
      $hh = @($s.heroHand)
      $bc = @($s.board.cards)
      $allCards = $hh + $bc
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
        Add-Issue $local 'R70' 'error' $sid "M4 handClass=straight but no 5 consecutive ranks (or A-2-3-4-5) in hero+board" | Out-Null
      }
    }

    # R71 -- BIDIRECTIONAL nut_flush_draw invariant (NEW for v4.3.0B)
    # If hero has A-of-suit AND total suit count is exactly 4 across hero+board AND
    # hero is not already classified as nut_flush_draw / flush / nut_flush, AND
    # handClass is not flush-class -- then drawCategory should be nut_flush_draw.
    # WARN-only because of edge cases (hand may simultaneously have stronger value;
    # in M4 v4.3.0B all relevant cases produce nut_flush_draw classification).
    if ($s.heroHand -and $s.board -and $s.board.cards -and $s.drawCategory -ne 'nut_flush_draw' `
        -and $s.handClass -ne 'flush' -and $s.handClass -ne 'nut_flush' -and $s.handClass -ne 'full_house' `
        -and $s.handClass -ne 'set' -and $s.handClass -ne 'two_pair' -and $s.handClass -ne 'top_two_pair' `
        -and $s.handClass -ne 'straight' -and $s.handClass -ne 'trips') {
      $hh = @($s.heroHand)
      $bc = @($s.board.cards)
      foreach ($suit in 'cdhs'.ToCharArray()) {
        $sc = [string]$suit
        $heroHasA = ($hh -contains "A$sc")
        if (-not $heroHasA) { continue }
        $heroSuitCount = (@($hh) | Where-Object { $_.Length -eq 2 -and $_.Substring(1,1) -eq $sc }).Count
        $boardSuitCount = (@($bc) | Where-Object { $_.Length -eq 2 -and $_.Substring(1,1) -eq $sc }).Count
        $totalSuit = $heroSuitCount + $boardSuitCount
        if ($totalSuit -eq 4) {
          Add-Issue $local 'R71' 'warning' $sid ("M4 hero holds A" + $sc + " with 4 of suit across hero+board (nut FD pattern) but drawCategory='" + $s.drawCategory + "' (expected nut_flush_draw)") | Out-Null
          break
        }
      }
    }

    # R72 -- TEXT-INTEGRITY guard (NEW for v4.3.0C1)
    # Hard error if explanation prose or blockerNote contains unresolved
    # self-correction artifacts that signal authoring drafts shipped without
    # revision (e.g. "wait need 3+5", "wait needs J actually impossible").
    # Patterns are case-insensitive Contains() against lowercased text.
    $r72Patterns = @(
      ' wait ', ' wait,', ' wait.', ' wait;', ' wait:', ' wait?', ' wait!',
      'wait needs', 'wait need ', 'actually impossible', '... wait', '...wait'
    )
    if ($s.explanation) {
      foreach ($k72 in 'short','turnLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway') {
        $v72 = $s.explanation.$k72
        if ($null -ne $v72 -and ($v72 -is [string]) -and $v72.Length -gt 0) {
          $v72Lower = $v72.ToLowerInvariant()
          foreach ($pat72 in $r72Patterns) {
            if ($v72Lower.Contains($pat72.ToLowerInvariant())) {
              Add-Issue $local 'R72' 'error' $sid ("M4 explanation." + $k72 + " contains self-correction artifact '" + $pat72.Trim() + "' -- unresolved authoring draft prose") | Out-Null
              break
            }
          }
        }
      }
    }
    if ($null -ne $s.blockerNote -and ($s.blockerNote -is [string]) -and $s.blockerNote.Length -gt 0) {
      $bn72Lower = $s.blockerNote.ToLowerInvariant()
      foreach ($pat72 in $r72Patterns) {
        if ($bn72Lower.Contains($pat72.ToLowerInvariant())) {
          Add-Issue $local 'R72' 'error' $sid ("M4 blockerNote contains self-correction artifact '" + $pat72.Trim() + "' -- unresolved authoring draft prose") | Out-Null
          break
        }
      }
    }
  }

  # ========================================================================
  # R76-R93 -- Module 5 (pf_river_barrel_oop_def) v4.4.1 production rules
  # Apply only to Module 5 scenarios. Mirror the hard-error subset of the
  # M5 seed audit (tools/audit-postflop-module5-seed.ps1 rules M5.R01..R58)
  # and the M5 schema-taxonomy (docs/specs/postflop-v4.4.0-module5-schema-
  # taxonomy.md). River is showdown-only: no live draws, no equity to realize.
  # Numbering: R76 onwards (R55-R75 = M4; R29 = card-notation; R30-R41 = M3).
  # ========================================================================
  if ($s.module -eq 'pf_river_barrel_oop_def') {
    $m5ValidActions   = @('fold','call','check_raise_small','check_raise_big','mixed')
    $m5ValidReasons   = @('pot_odds_river_call','bluff_catch_river','blocker_bluff_catch_river',
                          'mdf_defense_river','thin_value_call_river','value_raise_river',
                          'bluff_raise_river','range_disadvantage_river_fold','domination_river_fold',
                          'board_change_river_fold','missed_draw_give_up','mixed_indifference_river')
    $m5ValidQTypes    = @('action_choice','reason_choice')
    $m5ValidHandRoles = @('nutted_value','strong_value','thin_value','bluff_catcher',
                          'dominated_bluff_catcher','marginal_made_hand','blocker_bluff',
                          'missed_draw','give_up')
    $m5ValidHandClass = @('set','top_two_pair','two_pair','overpair','underpair',
                          'top_pair_top_kicker','top_pair_good_kicker','top_pair_weak_kicker',
                          'second_pair','third_pair_or_lower','mid_pair','bottom_pair',
                          'no_pair_no_draw','straight','flush','nut_flush','trips','full_house','quads')
    $m5ValidDrawCats  = @('none','busted_flush_draw','busted_straight_draw','busted_combo_draw')
    $m5ValidShowdown  = @('none','low','decent','high','nutted')
    $m5ValidConcepts  = @('river_bluff_catcher','river_polarization','river_mdf','river_blocker_defense',
                          'river_value_raise','river_bluff_raise','river_thin_value','river_missed_draw',
                          'river_range_disadvantage','river_board_change','river_overfold_trap','third_barrel_defense')
    $m5ValidRiverCats = @('brick','overcard','flush_complete','straight_complete','board_pair',
                          'scare_card','blank_runout','double_pair','range_shift_card')
    $m5ValidBoardChg  = @('brick','range_shift_btn','range_shift_bb','polarizing','draw_resolved',
                          'counterfeit','boat_possible')
    $m5ValidRunout    = @('dry_unpaired','flush_possible','straight_possible','double_draw_possible',
                          'paired_board','paired_flush_possible','double_paired','monotone_board')
    $m5ValidDrawComp  = @('none','flush_completed','straight_completed','board_paired',
                          'flush_and_straight','overcard_blank')
    $m5ValidSizing    = @('small','medium','large','overbet')
    $m5ValidSuitRiver = @('rainbow','two_tone','monotone','four_flush')
    $m5ValidAuditStat = @('approved','review_pending','planning_only','draft','needs_review','deprecated')

    # R76 -- module id + street + game + schemaVersion lock
    if ($s.module -ne 'pf_river_barrel_oop_def') {
      Add-Issue $local 'R76' 'error' $sid ("M5 expects module='pf_river_barrel_oop_def', got '" + $s.module + "'") | Out-Null
    }
    if ($s.street -ne 'river') {
      Add-Issue $local 'R76' 'error' $sid ("M5 expects street=river, got " + $s.street) | Out-Null
    }
    if ($s.game -and $s.game -ne 'NLH_MTT') {
      Add-Issue $local 'R76' 'error' $sid ("M5 expects game=NLH_MTT, got " + $s.game) | Out-Null
    }
    if ($s.schemaVersion -and $s.schemaVersion -ne '1.3.0') {
      Add-Issue $local 'R76' 'error' $sid ("M5 expects schemaVersion=1.3.0, got " + $s.schemaVersion) | Out-Null
    }

    # R77 -- spot block matches BB-vs-BTN river-defense lock
    if ($s.spot) {
      if ($s.spot.format          -and $s.spot.format          -ne 'NLH_MTT')                 { Add-Issue $local 'R77' 'error' $sid ("M5 expects spot.format=NLH_MTT, got " + $s.spot.format) | Out-Null }
      if ($s.spot.stackDepth      -and $s.spot.stackDepth      -ne '100BB')                   { Add-Issue $local 'R77' 'error' $sid ("M5 expects spot.stackDepth=100BB, got " + $s.spot.stackDepth) | Out-Null }
      if ($s.spot.potType         -and $s.spot.potType         -ne 'SRP')                     { Add-Issue $local 'R77' 'error' $sid ("M5 expects spot.potType=SRP, got " + $s.spot.potType) | Out-Null }
      if ($s.spot.heroPosition    -and $s.spot.heroPosition    -ne 'BB')                      { Add-Issue $local 'R77' 'error' $sid ("M5 expects spot.heroPosition=BB, got " + $s.spot.heroPosition) | Out-Null }
      if ($s.spot.villainPosition -and $s.spot.villainPosition -ne 'BTN')                     { Add-Issue $local 'R77' 'error' $sid ("M5 expects spot.villainPosition=BTN, got " + $s.spot.villainPosition) | Out-Null }
      if ($s.spot.heroRole        -and $s.spot.heroRole        -ne 'turn_check_caller_oop')   { Add-Issue $local 'R77' 'error' $sid ("M5 expects spot.heroRole=turn_check_caller_oop, got " + $s.spot.heroRole) | Out-Null }
      if ($s.spot.villainRole     -and $s.spot.villainRole     -ne 'river_barreler_ip')       { Add-Issue $local 'R77' 'error' $sid ("M5 expects spot.villainRole=river_barreler_ip, got " + $s.spot.villainRole) | Out-Null }
      if ($s.spot.street          -and $s.spot.street          -ne 'river')                   { Add-Issue $local 'R77' 'error' $sid ("M5 expects spot.street=river, got " + $s.spot.street) | Out-Null }
    } else {
      Add-Issue $local 'R77' 'error' $sid 'M5 spot block missing' | Out-Null
    }

    # R78 -- 5-card board structure (flopCards + turnCard + riverCard + cards)
    if (-not $s.board) {
      Add-Issue $local 'R78' 'error' $sid 'M5 board block missing' | Out-Null
    } else {
      $fc = @($s.board.flopCards)
      if ($fc.Count -ne 3) {
        Add-Issue $local 'R78' 'error' $sid ("M5 board.flopCards count " + $fc.Count + ", expected 3") | Out-Null
      }
      foreach ($cardField in @('turnCard','riverCard')) {
        $cv = $s.board.$cardField
        if (-not $cv) {
          Add-Issue $local 'R78' 'error' $sid ("M5 board." + $cardField + " missing") | Out-Null
        } elseif ($cv.Length -ne 2) {
          Add-Issue $local 'R78' 'error' $sid ("M5 board." + $cardField + " '" + $cv + "' invalid format") | Out-Null
        } else {
          $r = $cv.Substring(0,1); $u = $cv.Substring(1,1)
          if ($validRanks -notcontains $r) { Add-Issue $local 'R78' 'error' $sid ("M5 " + $cardField + " rank invalid '" + $r + "'") | Out-Null }
          if ($validSuits -notcontains $u) { Add-Issue $local 'R78' 'error' $sid ("M5 " + $cardField + " suit invalid '" + $u + "'") | Out-Null }
        }
      }
      $cards = @($s.board.cards)
      if ($cards.Count -ne 5) {
        Add-Issue $local 'R78' 'error' $sid ("M5 board.cards count " + $cards.Count + ", expected 5") | Out-Null
      } else {
        $expected = @()
        if ($fc.Count -eq 3 -and $s.board.turnCard -and $s.board.riverCard) { $expected = @($fc) + @($s.board.turnCard) + @($s.board.riverCard) }
        $expectedJoin = ($expected -join ',')
        $actualJoin = ($cards -join ',')
        if ($expected.Count -eq 5 -and $expectedJoin -ne $actualJoin) {
          Add-Issue $local 'R78' 'error' $sid ("M5 board.cards != flopCards+turnCard+riverCard ('" + $actualJoin + "' vs '" + $expectedJoin + "')") | Out-Null
        }
        $u2 = ($cards | Sort-Object -Unique).Count
        if ($u2 -ne $cards.Count) {
          Add-Issue $local 'R78' 'error' $sid ("M5 board has duplicate cards: " + ($cards -join ',')) | Out-Null
        }
      }
    }

    # R79 -- M5-specific board enums (villainRiverSizing is the M5-defining field)
    if ($s.board) {
      if ($s.board.riverCategory       -and ($m5ValidRiverCats -notcontains $s.board.riverCategory))       { Add-Issue $local 'R79' 'error' $sid ("M5 riverCategory '" + $s.board.riverCategory + "' not in valid set") | Out-Null }
      if ($s.board.boardChange         -and ($m5ValidBoardChg  -notcontains $s.board.boardChange))         { Add-Issue $local 'R79' 'error' $sid ("M5 boardChange '" + $s.board.boardChange + "' not in valid set") | Out-Null }
      if ($s.board.runoutTexture       -and ($m5ValidRunout    -notcontains $s.board.runoutTexture))       { Add-Issue $local 'R79' 'error' $sid ("M5 runoutTexture '" + $s.board.runoutTexture + "' not in valid set") | Out-Null }
      if ($s.board.riverDrawCompletion -and ($m5ValidDrawComp  -notcontains $s.board.riverDrawCompletion)) { Add-Issue $local 'R79' 'error' $sid ("M5 riverDrawCompletion '" + $s.board.riverDrawCompletion + "' not in valid set") | Out-Null }
      if ($s.board.villainRiverSizing  -and ($m5ValidSizing    -notcontains $s.board.villainRiverSizing))  { Add-Issue $local 'R79' 'error' $sid ("M5 villainRiverSizing '" + $s.board.villainRiverSizing + "' not in valid set") | Out-Null }
      if ($s.board.suitTextureRiver    -and ($m5ValidSuitRiver -notcontains $s.board.suitTextureRiver))    { Add-Issue $local 'R79' 'error' $sid ("M5 suitTextureRiver '" + $s.board.suitTextureRiver + "' not in valid set") | Out-Null }
      if (-not $s.board.villainRiverSizing) { Add-Issue $local 'R79' 'error' $sid 'M5 board.villainRiverSizing is required (drives MDF)' | Out-Null }
    }

    # R80 -- heroHand 2 cards + no hero/board collision
    if (-not $s.heroHand) {
      Add-Issue $local 'R80' 'error' $sid 'M5 requires heroHand' | Out-Null
    } elseif ($s.heroHand.Count -ne 2) {
      Add-Issue $local 'R80' 'error' $sid ("M5 heroHand has " + $s.heroHand.Count + " cards, expected 2") | Out-Null
    } else {
      foreach ($c in $s.heroHand) {
        if (-not $c -or $c.Length -ne 2) { Add-Issue $local 'R80' 'error' $sid ("M5 invalid hero card '" + $c + "'") | Out-Null; continue }
        $r = $c.Substring(0,1); $u = $c.Substring(1,1)
        if ($validRanks -notcontains $r) { Add-Issue $local 'R80' 'error' $sid ("M5 invalid rank in hero card '" + $c + "'") | Out-Null }
        if ($validSuits -notcontains $u) { Add-Issue $local 'R80' 'error' $sid ("M5 invalid suit in hero card '" + $c + "'") | Out-Null }
      }
      if ($s.board -and $s.board.cards) {
        $boardSet = @{}
        foreach ($c in $s.board.cards) { $boardSet["$c"] = $true }
        foreach ($c in $s.heroHand) {
          if ($boardSet.ContainsKey("$c")) {
            Add-Issue $local 'R80' 'error' $sid ("M5 hero card '" + $c + "' also on board") | Out-Null
          }
        }
      }
    }

    # R81 -- handClass / heroHandRole / drawCategory / showdownValue vocab
    if ($s.handClass     -and ($m5ValidHandClass -notcontains $s.handClass))     { Add-Issue $local 'R81' 'error' $sid ("M5 handClass '" + $s.handClass + "' not in v1.3.0 vocab") | Out-Null }
    if ($s.heroHandRole  -and ($m5ValidHandRoles -notcontains $s.heroHandRole))  { Add-Issue $local 'R81' 'error' $sid ("M5 heroHandRole '" + $s.heroHandRole + "' not in v1.3.0 vocab") | Out-Null }
    if ($s.drawCategory  -and ($m5ValidDrawCats  -notcontains $s.drawCategory))  { Add-Issue $local 'R81' 'error' $sid ("M5 drawCategory '" + $s.drawCategory + "' not in river set (none/busted_*)") | Out-Null }
    if ($s.showdownValue -and ($m5ValidShowdown  -notcontains $s.showdownValue)) { Add-Issue $local 'R81' 'error' $sid ("M5 showdownValue '" + $s.showdownValue + "' not in v1.3.0 vocab") | Out-Null }

    # R82 -- question schema (action_choice) + recommendedAction match + prompt completeness
    $m5qtype = $null
    if ($s.question -and $s.question.qtype) { $m5qtype = $s.question.qtype }
    if ($m5qtype -and ($m5ValidQTypes -notcontains $m5qtype)) {
      Add-Issue $local 'R82' 'error' $sid ("M5 question.qtype '" + $m5qtype + "' not in valid set") | Out-Null
    }
    if ($m5qtype -eq 'action_choice') {
      if (-not $s.question.choices) {
        Add-Issue $local 'R82' 'error' $sid 'M5 action_choice requires question.choices' | Out-Null
      } else {
        $m5choices = @($s.question.choices)
        $missing = @($m5ValidActions | Where-Object { $m5choices -notcontains $_ })
        $extra   = @($m5choices | Where-Object { $m5ValidActions -notcontains $_ })
        if ($missing.Count -gt 0) { Add-Issue $local 'R82' 'error' $sid ("M5 action_choice missing required: " + ($missing -join ',')) | Out-Null }
        if ($extra.Count   -gt 0) { Add-Issue $local 'R82' 'error' $sid ("M5 action_choice has unexpected: " + ($extra -join ',')) | Out-Null }
      }
      if ($s.recommendedAction -and ($m5ValidActions -notcontains $s.recommendedAction)) {
        Add-Issue $local 'R82' 'error' $sid ("M5 recommendedAction '" + $s.recommendedAction + "' not in valid set") | Out-Null
      }
      if ($s.answer -and $s.answer.best -and $s.recommendedAction -and ($s.answer.best -ne $s.recommendedAction)) {
        Add-Issue $local 'R82' 'error' $sid ("M5 answer.best '" + $s.answer.best + "' != recommendedAction '" + $s.recommendedAction + "'") | Out-Null
      }
      if ($s.question.prompt -match 'with\s*$') {
        Add-Issue $local 'R82' 'error' $sid "M5 action_choice prompt ends with 'with ' (hero hand lost)" | Out-Null
      }
      if ($s.heroHand -and $s.heroHand.Count -eq 2 -and $s.question.prompt) {
        $promptText = $s.question.prompt
        $foundBoth = $true
        foreach ($c in $s.heroHand) {
          if ($promptText -notmatch [regex]::Escape($c)) { $foundBoth = $false; break }
        }
        if (-not $foundBoth) {
          Add-Issue $local 'R82' 'error' $sid ("M5 action_choice prompt does not contain both hero cards '" + ($s.heroHand -join "','") + "'") | Out-Null
        }
      }
    }

    # R83 -- reason_choice schema + actionReason vocab + match to answer.best
    if ($m5qtype -eq 'reason_choice') {
      if (-not $s.question.choices) {
        Add-Issue $local 'R83' 'error' $sid 'M5 reason_choice requires question.choices' | Out-Null
      } else {
        $m5rc = @($s.question.choices)
        $invalid = @($m5rc | Where-Object { $m5ValidReasons -notcontains $_ })
        if ($invalid.Count -gt 0) { Add-Issue $local 'R83' 'error' $sid ("M5 reason_choice has invalid: " + ($invalid -join ',')) | Out-Null }
      }
      if ($s.actionReason -and ($m5ValidReasons -notcontains $s.actionReason)) {
        Add-Issue $local 'R83' 'error' $sid ("M5 actionReason '" + $s.actionReason + "' not in valid set") | Out-Null
      }
      if ($s.answer -and $s.answer.best -and $s.actionReason -and ($s.answer.best -ne $s.actionReason)) {
        Add-Issue $local 'R83' 'error' $sid ("M5 answer.best '" + $s.answer.best + "' != actionReason '" + $s.actionReason + "' for reason_choice") | Out-Null
      }
    }
    if ($s.actionReason -and ($m5ValidReasons -notcontains $s.actionReason)) {
      Add-Issue $local 'R83' 'error' $sid ("M5 actionReason '" + $s.actionReason + "' not in v1.3.0 vocab") | Out-Null
    }

    # R84 -- answer partition consistency: best/acceptable/bad disjoint; critical subset of bad
    if ($s.answer) {
      if ($null -eq $s.answer.best) {
        Add-Issue $local 'R84' 'error' $sid 'M5 answer.best is required' | Out-Null
      } elseif ($s.answer.best -isnot [string]) {
        Add-Issue $local 'R84' 'error' $sid ("M5 answer.best must be a string, got " + $s.answer.best.GetType().Name) | Out-Null
      }
      $m5best = $s.answer.best
      $m5acc  = @(); if ($s.answer.acceptable) { $m5acc  = @($s.answer.acceptable) }
      $m5bad  = @(); if ($s.answer.bad)        { $m5bad  = @($s.answer.bad) }
      $m5crit = @(); if ($s.answer.critical)   { $m5crit = @($s.answer.critical) }
      if ($m5best -and ($m5acc -contains $m5best)) {
        Add-Issue $local 'R84' 'error' $sid ("M5 answer.best '" + $m5best + "' also appears in acceptable") | Out-Null
      }
      if ($m5best -and ($m5bad -contains $m5best)) {
        Add-Issue $local 'R84' 'error' $sid ("M5 answer.best '" + $m5best + "' also appears in bad") | Out-Null
      }
      foreach ($a in $m5acc) {
        if ($m5bad -contains $a) {
          Add-Issue $local 'R84' 'error' $sid ("M5 acceptable choice '" + $a + "' also appears in bad") | Out-Null
        }
      }
      foreach ($c in $m5crit) {
        if (-not ($m5bad -contains $c)) {
          Add-Issue $local 'R84' 'error' $sid ("M5 critical choice '" + $c + "' must also appear in bad") | Out-Null
        }
      }
      $m5choiceUniverse = if ($m5qtype -eq 'action_choice') { $m5ValidActions } elseif ($m5qtype -eq 'reason_choice') { $m5ValidReasons } else { @() }
      if ($m5choiceUniverse.Count -gt 0) {
        $allM5 = @($m5best) + $m5acc + $m5bad + $m5crit | Where-Object { $_ }
        foreach ($id in $allM5) {
          if ($m5choiceUniverse -notcontains $id) {
            Add-Issue $local 'R84' 'error' $sid ("M5 answer references invalid id '" + $id + "' for qtype " + $m5qtype) | Out-Null
          }
        }
      }
    }

    # R85 -- explanation completeness: short/riverLogic/rangeContext/handLogic/commonMistake/takeaway
    #        always required; sizingLogic required only when recommendedAction is a check-raise.
    if ($s.explanation) {
      foreach ($fld in @('short','riverLogic','rangeContext','handLogic','commonMistake','takeaway')) {
        $v = $s.explanation.$fld
        if (-not $v -or ($v -is [string] -and $v.Trim().Length -eq 0)) {
          Add-Issue $local 'R85' 'error' $sid ("M5 explanation." + $fld + " is required") | Out-Null
        }
      }
      if ($s.recommendedAction -eq 'check_raise_small' -or $s.recommendedAction -eq 'check_raise_big') {
        $sz = $s.explanation.sizingLogic
        if (-not $sz -or ($sz -is [string] -and $sz.Trim().Length -eq 0)) {
          Add-Issue $local 'R85' 'error' $sid 'M5 explanation.sizingLogic is required when recommendedAction is a check-raise' | Out-Null
        }
      }
    } else {
      Add-Issue $local 'R85' 'error' $sid 'M5 explanation block missing' | Out-Null
    }

    # R86 -- conceptTags: 1-4 entries, no duplicates, all in M5 concept vocab
    if (-not $s.conceptTags -or $s.conceptTags.Count -eq 0) {
      Add-Issue $local 'R86' 'error' $sid 'M5 conceptTags must be non-empty' | Out-Null
    } else {
      if ($s.conceptTags.Count -gt 4) {
        Add-Issue $local 'R86' 'error' $sid ("M5 conceptTags has " + $s.conceptTags.Count + " entries (max 4)") | Out-Null
      }
      $tagSeen = @{}
      foreach ($tg in $s.conceptTags) {
        if ($m5ValidConcepts -notcontains $tg) {
          Add-Issue $local 'R86' 'error' $sid ("M5 conceptTag '" + $tg + "' not in M5 concept vocab") | Out-Null
        }
        if ($tagSeen.ContainsKey("$tg")) {
          Add-Issue $local 'R86' 'error' $sid ("M5 duplicate conceptTag '" + $tg + "'") | Out-Null
        }
        $tagSeen["$tg"] = $true
      }
    }

    # R87 -- auditStatus + sourceConfidence
    if ($s.auditStatus -and ($m5ValidAuditStat -notcontains $s.auditStatus)) {
      Add-Issue $local 'R87' 'error' $sid ("M5 auditStatus '" + $s.auditStatus + "' not in valid set") | Out-Null
    }
    if ($s.sourceConfidence -eq 'solver_verified' -and -not $s.solverRunRef) {
      Add-Issue $local 'R87' 'error' $sid 'M5 sourceConfidence=solver_verified requires solverRunRef field' | Out-Null
    }

    # R88 -- handClass='flush'/'nut_flush' invariant: >=5 of one suit across hero+board
    if (($s.handClass -eq 'flush' -or $s.handClass -eq 'nut_flush') -and $s.heroHand -and $s.board -and $s.board.cards) {
      $allFlush = @($s.heroHand) + @($s.board.cards)
      $foundFlush = $false
      foreach ($suit in 'cdhs'.ToCharArray()) {
        $sc = [string]$suit
        $cnt = (@($allFlush) | Where-Object { $_.Length -eq 2 -and $_.Substring(1,1) -eq $sc }).Count
        if ($cnt -ge 5) { $foundFlush = $true; break }
      }
      if (-not $foundFlush) {
        Add-Issue $local 'R88' 'error' $sid "M5 handClass=flush but no suit has 5+ cards across hero+board" | Out-Null
      }
    }

    # R89 -- handClass='straight' invariant: 5 consecutive ranks (or A-2-3-4-5) in hero+board
    if ($s.handClass -eq 'straight' -and $s.heroHand -and $s.board -and $s.board.cards) {
      $allStr = @($s.heroHand) + @($s.board.cards)
      $rankOrder = @('2','3','4','5','6','7','8','9','T','J','Q','K','A')
      $rankSet = New-Object System.Collections.Generic.HashSet[int]
      foreach ($c in $allStr) {
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
        Add-Issue $local 'R89' 'error' $sid "M5 handClass=straight but no 5 consecutive ranks (or A-2-3-4-5) in hero+board" | Out-Null
      }
    }

    # R90 -- busted-draws-never-call (river is showdown-only; the M5 signature rule)
    $m5Busted = ($s.heroHandRole -eq 'missed_draw') -or `
                ($s.drawCategory -eq 'busted_flush_draw') -or `
                ($s.drawCategory -eq 'busted_straight_draw') -or `
                ($s.drawCategory -eq 'busted_combo_draw')
    if ($m5Busted) {
      if ($s.recommendedAction -eq 'call') {
        Add-Issue $local 'R90' 'error' $sid "M5 busted draw has recommendedAction='call' -- busted draws never call on the river" | Out-Null
      }
      if ($s.answer -and $s.answer.best -eq 'call') {
        Add-Issue $local 'R90' 'error' $sid "M5 busted draw has answer.best='call' -- busted draws never call" | Out-Null
      }
      if ($s.answer -and (@($s.answer.acceptable) -contains 'call')) {
        Add-Issue $local 'R90' 'error' $sid "M5 busted draw lists 'call' as acceptable -- busted draws never call" | Out-Null
      }
      $m5CallReasons = @('pot_odds_river_call','bluff_catch_river','blocker_bluff_catch_river','mdf_defense_river','thin_value_call_river')
      if ($m5CallReasons -contains $s.actionReason) {
        Add-Issue $local 'R90' 'error' $sid ("M5 busted draw has a call-flavored actionReason '" + $s.actionReason + "' -- busted draws are fold or bluff-raise only") | Out-Null
      }
    }

    # R91 -- blocker_bluff blockerNote claiming nut-<suit> requires hero A of that suit
    if ($s.heroHandRole -eq 'blocker_bluff' -and $s.blockerNote -and $s.heroHand) {
      $hh5 = @($s.heroHand)
      $bn5 = $s.blockerNote
      $suitMap5 = @{ 'spade'='s'; 'heart'='h'; 'club'='c'; 'diamond'='d' }
      foreach ($word in $suitMap5.Keys) {
        if ($bn5 -match "nut[- ]$word") {
          $sc = $suitMap5[$word]
          if (-not ($hh5 -contains "A$sc")) {
            Add-Issue $local 'R91' 'error' $sid ("M5 blockerNote claims 'nut-" + $word + "' blocker but hero does not hold A" + $sc) | Out-Null
          }
        }
      }
    }

    # R92 -- no draw-equity-realization language in river explanations (WARN)
    if ($s.explanation) {
      $m5banPhrases = @('equity realization','realize equity','equity_realization','realize the equity','realise equity')
      foreach ($f in @('short','riverLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')) {
        $v = $s.explanation.$f
        if ($null -ne $v -and ($v -is [string])) {
          $vl = $v.ToLowerInvariant()
          foreach ($p in $m5banPhrases) {
            if ($vl.Contains($p)) {
              Add-Issue $local 'R92' 'warning' $sid ("M5 explanation." + $f + " uses draw-equity-realization phrasing '" + $p + "' -- river is showdown-only") | Out-Null
              break
            }
          }
        }
      }
    }

    # R93 -- text-integrity: no unresolved self-correction artifacts (HARD)
    $m5r93 = @(' wait ', ' wait,', ' wait.', 'wait needs', 'wait need ', 'actually impossible', '... wait', '...wait')
    if ($s.explanation) {
      foreach ($f in @('short','riverLogic','rangeContext','handLogic','sizingLogic','commonMistake','takeaway')) {
        $v = $s.explanation.$f
        if ($null -ne $v -and ($v -is [string]) -and $v.Length -gt 0) {
          $vl = $v.ToLowerInvariant()
          foreach ($p in $m5r93) {
            if ($vl.Contains($p.ToLowerInvariant())) {
              Add-Issue $local 'R93' 'error' $sid ("M5 explanation." + $f + " contains self-correction artifact '" + $p.Trim() + "'") | Out-Null
              break
            }
          }
        }
      }
    }
  }

  # R29 (v4.2.2D + v4.2.2E hardening) — Card/suit notation guard. Warning-only.
  # Detects suspicious em-dash and collapsed-board patterns inside text fields
  # that suggest a CP874 mojibake cleanup over-normalized suit symbols.
  #
  # Patterns flagged (v4.2.2D originals):
  #   "[Rank] - -[xX]"             (was "[Rank][suit]-x" with suit destroyed)
  #   "[Rank] - [Rank] -"          (was "[Rank][suit][Rank][suit]")
  #   "BTN with [Rank] - [Rank] -" (was "BTN with [hero hand]")
  #
  # New v4.2.2E patterns:
  #   "on [R][R]s [R]"             (board collapsed: "Kh Td 2s" -> "KTs 2")
  #   "[Rank] em-dash X"           (flush combo "A - X" residue, was "A-X")
  #   "[Rank] em-dash /"           (rank-x list "5 - /7 -" residue, was "5x / 7x")
  #
  # Em-dashes used as legitimate sentence punctuation (between lowercase
  # letters/words/numbers) are NOT flagged.
  $emDashChar = [char]0x2014
  $rankClass = '[AKQJT2-9]'
  $suspiciousPatterns = @(
    @{ name = 'rank_dash_dash_x';     pattern = "$rankClass\s+$emDashChar\s+-[xX]" },
    @{ name = 'rank_dash_rank_dash';  pattern = "$rankClass\s+$emDashChar\s+$rankClass\s+$emDashChar" },
    @{ name = 'btn_with_dash_pair';   pattern = "BTN with $rankClass\s+$emDashChar\s+$rankClass" },
    # v4.2.2E additions:
    @{ name = 'board_collapse';       pattern = "\bon [AKQJT][AKQJT2-9]s [2-9AKQJT]\b" },
    @{ name = 'rank_dash_X';          pattern = "[AKQJT]\s+$emDashChar\s+X(?!s)\b" },
    @{ name = 'rank_dash_slash';      pattern = "[2-9AKQJT]\s+$emDashChar\s+/" }
  )
  $textFieldsToCheck = @()
  if ($s.question -and $s.question.prompt) { $textFieldsToCheck += @{ field='question.prompt'; text=$s.question.prompt } }
  if ($s.explanation) {
    foreach ($fldName in @('short','rangeLogic','nutLogic','handLogic','sizingLogic','commonMistake','takeaway','rangeContext','defenseLogic')) {
      $val = $s.explanation.$fldName
      if ($val -is [string]) { $textFieldsToCheck += @{ field="explanation.$fldName"; text=$val } }
    }
  }
  if ($s.blockerNote -is [string]) { $textFieldsToCheck += @{ field='blockerNote'; text=$s.blockerNote } }
  foreach ($entry in $textFieldsToCheck) {
    foreach ($p in $suspiciousPatterns) {
      if ([regex]::IsMatch($entry.text, $p.pattern)) {
        Add-Issue $local 'R29' 'warning' $sid ("suspicious card/suit notation pattern '" + $p.name + "' in " + $entry.field + " (likely v4.2.2C-style over-normalization of suit symbols)") | Out-Null
      }
    }
  }

  # R16 finalizer
  $errs = @($local | Where-Object { $_.severity -eq 'error' })
  if($s.auditStatus -eq 'approved' -and $errs.Count -gt 0){
    Add-Issue $local 'R16' 'error' $sid "Scenario marked auditStatus=approved but has $($errs.Count) error(s) from R01-R15" | Out-Null
  }

  $perScenario[$sid] = $local
  foreach($i in $local){ [void]$issues.Add($i) }
}

$totalErrors = @($issues | Where-Object { $_.severity -eq 'error' }).Count
$totalWarn = @($issues | Where-Object { $_.severity -eq 'warning' }).Count
$totalScen = $data.scenarios.Count
$failed = 0
foreach($sid in $perScenario.Keys){ if(@($perScenario[$sid] | Where-Object { $_.severity -eq 'error' }).Count -gt 0){ $failed++ } }

Write-Output ''
Write-Output ('=== Postflop Audit ===')
Write-Output ('Total scenarios: ' + $totalScen)
Write-Output ('Errors: ' + $totalErrors)
Write-Output ('Warnings: ' + $totalWarn)
Write-Output ('Scenarios with errors: ' + $failed)

if($totalErrors -gt 0){
  Write-Output ''
  Write-Output '--- First 30 errors ---'
  $issues | Where-Object { $_.severity -eq 'error' } | Select-Object -First 30 | ForEach-Object {
    Write-Output ('[' + $_.rule + '] ' + $_.scenarioId + ' :: ' + $_.message)
  }
}
if($totalWarn -gt 0){
  Write-Output ''
  Write-Output '--- All warnings (first 30) ---'
  $issues | Where-Object { $_.severity -eq 'warning' } | Select-Object -First 30 | ForEach-Object {
    Write-Output ('[' + $_.rule + '] ' + $_.scenarioId + ' :: ' + $_.message)
  }
}

Write-Output ''
Write-Output '--- Stats ---'
$data.scenarios | Group-Object module | Sort-Object Name | ForEach-Object { Write-Output ('  module ' + $_.Name + ': ' + $_.Count) }
$m1 = @($data.scenarios | Where-Object { $_.module -eq 'pf_board_texture' })
Write-Output ('  Module 1 total: ' + $m1.Count)
$m1 | Group-Object { $_.question.type } | Sort-Object Name | ForEach-Object { Write-Output ('    qtype ' + $_.Name + ': ' + $_.Count) }
$m1 | Group-Object difficulty | Sort-Object Name | ForEach-Object { Write-Output ('    diff ' + $_.Name + ': ' + $_.Count) }
$m1 | Group-Object { $_.board.suitTexture } | Sort-Object Name | ForEach-Object {
  $pct = [math]::Round(100 * $_.Count / $m1.Count, 1)
  Write-Output ('    suit ' + $_.Name + ': ' + $_.Count + ' (' + $pct + '%)')
}
$m1 | Group-Object { $_.board.highCardClass } | Sort-Object Name | ForEach-Object { Write-Output ('    hcc ' + $_.Name + ': ' + $_.Count) }
$m1 | Group-Object sourceConfidence | Sort-Object Name | ForEach-Object {
  $pct = [math]::Round(100 * $_.Count / $m1.Count, 1)
  Write-Output ('    src ' + $_.Name + ': ' + $_.Count + ' (' + $pct + '%)')
}
$m1 | Group-Object auditStatus | Sort-Object Name | ForEach-Object { Write-Output ('    status ' + $_.Name + ': ' + $_.Count) }

# Duplicate check: same board cards used multiple times
$boardKeys = @{}
foreach($s in $m1){
  if($s.board -and $s.board.cards){
    $k = ($s.board.cards | Sort-Object) -join ','
    if(-not $boardKeys.ContainsKey($k)){ $boardKeys[$k] = 0 }
    $boardKeys[$k]++
  }
}
$dupBoards = $boardKeys.GetEnumerator() | Where-Object { $_.Value -gt 1 } | Sort-Object Value -Descending
Write-Output ('  Boards used >1 time: ' + $dupBoards.Count)
if($dupBoards.Count -gt 0){
  $dupBoards | Select-Object -First 10 | ForEach-Object { Write-Output ('    ' + $_.Key + ' x' + $_.Value) }
}

# Duplicate (board, qtype) combos
$boardQTypes = @{}
foreach($s in $m1){
  if($s.board -and $s.board.cards -and $s.question){
    $k = (($s.board.cards | Sort-Object) -join ',') + '|' + $s.question.type
    if(-not $boardQTypes.ContainsKey($k)){ $boardQTypes[$k] = 0 }
    $boardQTypes[$k]++
  }
}
$dupBQ = $boardQTypes.GetEnumerator() | Where-Object { $_.Value -gt 1 } | Sort-Object Value -Descending
Write-Output ('  Board+qtype combos used >1 time: ' + $dupBQ.Count)
if($dupBQ.Count -gt 0){
  $dupBQ | Select-Object -First 10 | ForEach-Object { Write-Output ('    ' + $_.Key + ' x' + $_.Value) }
}

# needs_review count
$nr = @($m1 | Where-Object { $_.auditStatus -eq 'needs_review' }).Count
Write-Output ('  needs_review: ' + $nr)

# v4.2.3 — Module 3 stats block
$m3 = @($data.scenarios | Where-Object { $_.module -eq 'pf_flop_cbet_oop_def' })
if ($m3.Count -gt 0) {
  Write-Output ''
  Write-Output ('  Module 3 total: ' + $m3.Count)
  $m3 | Group-Object { $_.question.qtype } | Sort-Object Name | ForEach-Object { Write-Output ('    qtype ' + $_.Name + ': ' + $_.Count) }
  $m3 | Group-Object { $_.board.suitTexture } | Sort-Object Name | ForEach-Object { Write-Output ('    suit ' + $_.Name + ': ' + $_.Count) }
  $m3 | Group-Object { $_.board.highCardClass } | Sort-Object Name | ForEach-Object { Write-Output ('    hcc ' + $_.Name + ': ' + $_.Count) }
  $m3 | Group-Object recommendedAction | Sort-Object Name | ForEach-Object { Write-Output ('    action ' + $_.Name + ': ' + $_.Count) }
  $m3 | Group-Object auditStatus | Sort-Object Name | ForEach-Object { Write-Output ('    status ' + $_.Name + ': ' + $_.Count) }
}

# v4.3.0B -- Module 4 stats block
$m4 = @($data.scenarios | Where-Object { $_.module -eq 'pf_turn_barrel_oop_def' })
if ($m4.Count -gt 0) {
  Write-Output ''
  Write-Output ('  Module 4 total: ' + $m4.Count)
  $m4 | Group-Object { $_.question.qtype } | Sort-Object Name | ForEach-Object { Write-Output ('    qtype ' + $_.Name + ': ' + $_.Count) }
  $m4 | Group-Object { $_.board.turnCategory } | Sort-Object Name | ForEach-Object { Write-Output ('    turnCategory ' + $_.Name + ': ' + $_.Count) }
  $m4 | Group-Object { $_.board.highCardClass } | Sort-Object Name | ForEach-Object { Write-Output ('    hcc ' + $_.Name + ': ' + $_.Count) }
  $m4 | Group-Object recommendedAction | Sort-Object Name | ForEach-Object { Write-Output ('    action ' + $_.Name + ': ' + $_.Count) }
  $m4 | Group-Object auditStatus | Sort-Object Name | ForEach-Object { Write-Output ('    status ' + $_.Name + ': ' + $_.Count) }
}

# v4.4.1 -- Module 5 stats block
$m5 = @($data.scenarios | Where-Object { $_.module -eq 'pf_river_barrel_oop_def' })
if ($m5.Count -gt 0) {
  Write-Output ''
  Write-Output ('  Module 5 total: ' + $m5.Count)
  $m5 | Group-Object { $_.question.qtype } | Sort-Object Name | ForEach-Object { Write-Output ('    qtype ' + $_.Name + ': ' + $_.Count) }
  $m5 | Group-Object { $_.board.riverCategory } | Sort-Object Name | ForEach-Object { Write-Output ('    riverCategory ' + $_.Name + ': ' + $_.Count) }
  $m5 | Group-Object { $_.board.villainRiverSizing } | Sort-Object Name | ForEach-Object { Write-Output ('    sizing ' + $_.Name + ': ' + $_.Count) }
  $m5 | Group-Object { $_.board.highCardClass } | Sort-Object Name | ForEach-Object { Write-Output ('    hcc ' + $_.Name + ': ' + $_.Count) }
  $m5 | Group-Object recommendedAction | Sort-Object Name | ForEach-Object { Write-Output ('    action ' + $_.Name + ': ' + $_.Count) }
  $m5 | Group-Object auditStatus | Sort-Object Name | ForEach-Object { Write-Output ('    status ' + $_.Name + ': ' + $_.Count) }
}

if($totalErrors -gt 0){ exit 1 } else { exit 0 }
