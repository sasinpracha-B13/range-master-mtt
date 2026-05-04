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
  if(-not $s.question -or -not $s.question.choices){
    Add-Issue $local 'R04' 'error' $sid 'question.choices missing' | Out-Null
  } elseif(-not $s.answer){
    Add-Issue $local 'R04' 'error' $sid 'answer missing' | Out-Null
  } else {
    $choiceIds = @{}
    foreach($c in $s.question.choices){ if($c -and $c.id){ $choiceIds[$c.id] = $true } }
    foreach($tier in @('best','acceptable','bad','critical')){
      $list = $s.answer.$tier
      if($null -eq $list){ Add-Issue $local 'R04' 'error' $sid "answer.$tier must be an array" | Out-Null; continue }
      foreach($id in $list){
        if(-not $choiceIds.ContainsKey($id)){
          Add-Issue $local 'R04' 'error' $sid "answer.$tier references unknown choice id `"$id`"" | Out-Null
        }
      }
    }
  }

  # R05 best exists
  if(-not $s.answer -or -not $s.answer.best -or $s.answer.best.Count -eq 0){
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

  # R10 advantage enums
  if($s.board){
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

  # R13 contradictory tags + suit consistency
  if($s.board -and $s.board.textureTags){
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

if($totalErrors -gt 0){ exit 1 } else { exit 0 }
