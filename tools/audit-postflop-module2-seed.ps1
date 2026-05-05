# tools/audit-postflop-module2-seed.ps1
#
# Module 2 (Flop C-bet IP) SEED auditor. Audits the v4.1.2 planning seed
# JSON at docs/specs/postflop-v4.1.2-module2-seed-scenarios.json against the
# rules defined in docs/specs/postflop-v4.1.2-module2-audit-plan.md.
#
# This script is intentionally separate from tools/audit-postflop-ps.ps1
# (which audits production data and must stay 262/0/0). The reason: the
# 11 baseline Module 2 scenarios in production data use the older
# `bet_33`/`check` choice ids and lack the v4.1.2 schema additions
# (heroHandRole, drawCategory, recommendedAction, actionReason, etc.).
# Adding Module 2 hard rules to the production auditor would fail those
# 11 baseline scenarios. Until they are migrated, this script handles
# Module 2 audits.
#
# Run from repo root:
#   powershell -ExecutionPolicy Bypass -File tools/audit-postflop-module2-seed.ps1
#
# Optional argument:
#   -Path <path>  Override the default seed path
#
# Exit code:
#   0 if no hard errors
#   1 if any hard errors
#
# Output:
#   Per-scenario hard errors (if any)
#   Per-scenario warnings
#   PASS/WARN/FAIL summary
#   Coverage report
#
# Source intentionally pure ASCII to avoid CP874 / UTF-8 mojibake risks
# during PowerShell parsing. Any text-content checks for mojibake are
# done via codepoint scans, not literal patterns.
#
param(
    [string]$Path = 'docs/specs/postflop-v4.1.2-module2-seed-scenarios.json'
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$seedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $repoRoot $Path }
$conceptsPath = Join-Path $repoRoot 'postflop/postflop_concepts.json'

if (-not (Test-Path $seedPath)) {
    Write-Output ('ERROR: Seed file not found: ' + $seedPath)
    exit 1
}

# Read with explicit UTF-8 to avoid system-codepage mis-decoding (CP874 etc.).
# Default Get-Content -Raw uses the system codepage and will introduce
# phantom mojibake on non-Latin locales.
$seedText = [System.IO.File]::ReadAllText((Resolve-Path $seedPath), [System.Text.Encoding]::UTF8)
$seed = $seedText | ConvertFrom-Json
$concepts = if (Test-Path $conceptsPath) {
    $cText = [System.IO.File]::ReadAllText((Resolve-Path $conceptsPath), [System.Text.Encoding]::UTF8)
    $cText | ConvertFrom-Json
} else { $null }

# Build concept-key lookup
$knownConcepts = New-Object System.Collections.Generic.HashSet[string]
if ($concepts) {
    foreach ($c in $concepts.concepts) { [void]$knownConcepts.Add($c.key) }
}

# Planned concepts (per audit-plan.md s 2.24 + schema-taxonomy.md s 5.2)
$plannedConcepts = @('value_betting','pot_control','blocker_pressure','give_up_strategy','hand_class_recognition','range_advantage_stab')
foreach ($p in $plannedConcepts) { [void]$knownConcepts.Add($p) }

# Vocabulary
$validRanks = @('A','K','Q','J','T','9','8','7','6','5','4','3','2')
$validSuits = @('s','h','d','c')
$rankIdx = @{}
for ($i = 0; $i -lt $validRanks.Count; $i++) { $rankIdx[$validRanks[$i]] = (14 - $i) }

$validHandClasses = @(
    'set','straight','flush','nut_flush','top_two_pair','two_pair','overpair',
    'top_pair_top_kicker','top_pair_good_kicker','top_pair_weak_kicker',
    'second_pair','third_pair_or_lower','underpair','mid_pair',
    'combo_draw','flush_draw','nut_flush_draw','oesd','gutshot',
    'backdoor_only','no_pair_no_draw','trips'
)
$validHandRoles = @(
    'strong_value','thin_value','medium_showdown','weak_showdown',
    'nut_draw','strong_draw','weak_draw','air','blocker_bluff','trap_check'
)
$validDrawCats = @('nut_fd','fd','oesd','gutshot','combo','backdoor_only','none')
$validShowdown = @('high','medium','low','none')
$validActions = @('bet_small','bet_big','check','mixed')
$validReasons = @('value','thin_value','protection','bluff','equity_realization',
                  'pot_control','blocker_pressure','range_advantage_stab','give_up','semi_bluff')
$validQTypes = @('action_choice','reason_choice','sizing_choice','hand_class')
$validSourceConfidence = @('consensus_gto','expert_judgment','solver_verified')
$validAuditStatus = @('approved','review_pending','draft','needs_review')

# ============================================================================
# CARD / HAND HELPERS
# ============================================================================

function Get-Rank($card) { return $card.Substring(0,1) }
function Get-Suit($card) { return $card.Substring(1,1) }
function Get-RankValue($rank) { return $rankIdx[$rank] }

function Test-CardValid($card) {
    if (-not $card -or $card.Length -ne 2) { return $false }
    $r = $card.Substring(0,1); $s = $card.Substring(1,1)
    return ($validRanks -contains $r) -and ($validSuits -contains $s)
}

function Get-SuitCounts($cards) {
    $h = @{ h=0; d=0; c=0; s=0 }
    foreach ($card in $cards) {
        $suit = Get-Suit $card
        $h[$suit] = $h[$suit] + 1
    }
    return $h
}

function Get-FlushSuit($cards) {
    $sc = Get-SuitCounts $cards
    foreach ($k in 'h','d','c','s') {
        if ($sc[$k] -ge 5) { return $k }
    }
    return $null
}

function Get-FlushDrawSuit($cards) {
    $sc = Get-SuitCounts $cards
    foreach ($k in 'h','d','c','s') {
        if ($sc[$k] -eq 4) { return $k }
    }
    return $null
}

function Get-BackdoorFlushSuit($cards) {
    $sc = Get-SuitCounts $cards
    foreach ($k in 'h','d','c','s') {
        if ($sc[$k] -eq 3) { return $k }
    }
    return $null
}

function Get-MadeStraightHigh($cards) {
    $vals = ($cards | ForEach-Object { Get-RankValue (Get-Rank $_) }) | Sort-Object -Unique
    if ($vals.Count -lt 5) { return 0 }
    for ($i = 0; $i -le ($vals.Count - 5); $i++) {
        $isConsecutive = $true
        for ($j = 1; $j -lt 5; $j++) {
            if ($vals[$i+$j] -ne $vals[$i+$j-1] + 1) { $isConsecutive = $false; break }
        }
        if ($isConsecutive) { return $vals[$i+4] }
    }
    $vSet = @{}
    foreach ($v in $vals) { $vSet["$v"] = $true }
    if ($vSet.ContainsKey('14') -and $vSet.ContainsKey('2') -and $vSet.ContainsKey('3') -and $vSet.ContainsKey('4') -and $vSet.ContainsKey('5')) {
        return 5
    }
    return 0
}

function Test-OESD($cards) {
    if ((Get-MadeStraightHigh $cards) -gt 0) { return $false }
    $vals = ($cards | ForEach-Object { Get-RankValue (Get-Rank $_) }) | Sort-Object -Unique
    if ($vals.Count -lt 4) { return $false }
    $vSet = @{}
    foreach ($v in $vals) { $vSet["$v"] = $true }
    for ($i = 0; $i -le ($vals.Count - 4); $i++) {
        $isConsecutive = $true
        for ($j = 1; $j -lt 4; $j++) {
            if ($vals[$i+$j] -ne $vals[$i+$j-1] + 1) { $isConsecutive = $false; break }
        }
        if ($isConsecutive) {
            $low = $vals[$i]; $high = $vals[$i+3]
            if ($low -gt 2 -and $high -lt 14 -and -not $vSet.ContainsKey("$($low - 1)") -and -not $vSet.ContainsKey("$($high + 1)")) {
                return $true
            }
        }
    }
    return $false
}

function Test-Gutshot($cards) {
    if ((Get-MadeStraightHigh $cards) -gt 0) { return $false }
    if (Test-OESD $cards) { return $false }
    $vals = ($cards | ForEach-Object { Get-RankValue (Get-Rank $_) }) | Sort-Object -Unique
    if ($vals.Count -lt 4) { return $false }
    $vSet = @{}
    foreach ($v in $vals) { $vSet["$v"] = $true }
    for ($low = 2; $low -le 10; $low++) {
        $matched = 0
        for ($k = 0; $k -lt 5; $k++) {
            if ($vSet.ContainsKey("$($low + $k)")) { $matched++ }
        }
        if ($matched -eq 4) { return $true }
    }
    if ($vSet.ContainsKey('14')) {
        $matched = 1
        foreach ($r in 2,3,4,5) {
            if ($vSet.ContainsKey("$r")) { $matched++ }
        }
        if ($matched -eq 4) { return $true }
    }
    return $false
}

function Test-BackdoorStraight($cards) {
    if ((Get-MadeStraightHigh $cards) -gt 0) { return $false }
    if (Test-OESD $cards) { return $false }
    if (Test-Gutshot $cards) { return $false }
    $vals = ($cards | ForEach-Object { Get-RankValue (Get-Rank $_) }) | Sort-Object -Unique
    if ($vals.Count -lt 3) { return $false }
    $vSet = @{}
    foreach ($v in $vals) { $vSet["$v"] = $true }
    for ($low = 2; $low -le 10; $low++) {
        $matched = 0
        for ($k = 0; $k -lt 5; $k++) {
            if ($vSet.ContainsKey("$($low + $k)")) { $matched++ }
        }
        if ($matched -ge 3) { return $true }
    }
    if ($vSet.ContainsKey('14')) {
        $matched = 1
        foreach ($r in 2,3,4,5) { if ($vSet.ContainsKey("$r")) { $matched++ } }
        if ($matched -ge 3) { return $true }
    }
    return $false
}

function Get-PairAnalysis($heroCards, $boardCards) {
    $heroRanks = $heroCards | ForEach-Object { Get-Rank $_ }
    $boardRanks = $boardCards | ForEach-Object { Get-Rank $_ }
    $boardVals = $boardRanks | ForEach-Object { Get-RankValue $_ } | Sort-Object -Descending
    $topBoardRank = ($boardRanks | Sort-Object -Property @{ Expression = { Get-RankValue $_ } } -Descending)[0]
    $topBoardVal = Get-RankValue $topBoardRank
    $bottomBoardVal = (Get-RankValue ($boardRanks | Sort-Object -Property @{ Expression = { Get-RankValue $_ } })[0])

    $isPocketPair = ($heroRanks[0] -eq $heroRanks[1])
    $pocketPairVal = if ($isPocketPair) { Get-RankValue $heroRanks[0] } else { 0 }

    $boardRankCounts = @{}
    foreach ($r in $boardRanks) { if ($boardRankCounts.ContainsKey("$r")) { $boardRankCounts["$r"]++ } else { $boardRankCounts["$r"] = 1 } }
    $boardPairedRank = $null
    foreach ($k in $boardRankCounts.Keys) { if ($boardRankCounts[$k] -ge 2) { $boardPairedRank = $k } }

    $heroPairsBoard = @()
    foreach ($hr in $heroRanks) {
        if ($boardRankCounts.ContainsKey("$hr")) { $heroPairsBoard += $hr }
    }

    $analysis = @{
        isPocketPair = $isPocketPair
        pocketPairVal = $pocketPairVal
        topBoardVal = $topBoardVal
        bottomBoardVal = $bottomBoardVal
        topBoardRank = $topBoardRank
        boardPaired = ($null -ne $boardPairedRank)
        boardPairedRank = $boardPairedRank
        heroPairsBoardRanks = $heroPairsBoard
        derivedClass = $null
        derivedKickerVal = 0
    }

    if ($isPocketPair) {
        $ppVal = $pocketPairVal
        if ($boardRankCounts.ContainsKey("$($heroRanks[0])")) {
            $analysis.derivedClass = 'set'
        } elseif ($ppVal -gt $topBoardVal) {
            $analysis.derivedClass = 'overpair'
        } elseif ($ppVal -lt $bottomBoardVal) {
            $analysis.derivedClass = 'underpair'
        } else {
            $analysis.derivedClass = 'mid_pair'
        }
    } elseif ($heroPairsBoard.Count -ge 2) {
        $sortedBoardVals = $boardVals
        if ($sortedBoardVals.Count -ge 2) {
            $top2 = @($sortedBoardVals[0], $sortedBoardVals[1])
            $heroPairVals = ($heroPairsBoard | ForEach-Object { Get-RankValue $_ }) | Sort-Object -Descending
            if ($heroPairVals.Count -ge 2 -and $heroPairVals[0] -eq $top2[0] -and $heroPairVals[1] -eq $top2[1]) {
                $analysis.derivedClass = 'top_two_pair'
            } else {
                $analysis.derivedClass = 'two_pair'
            }
        }
    } elseif ($heroPairsBoard.Count -eq 1) {
        $pairedRank = $heroPairsBoard[0]
        $pairedVal = Get-RankValue $pairedRank
        if ($boardPairedRank -eq $pairedRank) {
            $analysis.derivedClass = 'trips'
        } else {
            # Pick the hero card that did NOT pair the board.
            # Use explicit indexing to avoid PowerShell array-vs-scalar pipeline quirks.
            $kicker = if ($heroRanks[0] -eq $pairedRank) { $heroRanks[1] } else { $heroRanks[0] }
            $kickerVal = Get-RankValue $kicker
            $analysis.derivedKickerVal = $kickerVal

            if ($pairedVal -eq $topBoardVal) {
                $isTopKicker = $false
                if ($pairedRank -eq 'A') {
                    $isTopKicker = ($kicker -eq 'K')
                } else {
                    $isTopKicker = ($kicker -eq 'A')
                }
                if ($isTopKicker) {
                    $analysis.derivedClass = 'top_pair_top_kicker'
                } elseif ($kickerVal -ge 11) {
                    $analysis.derivedClass = 'top_pair_good_kicker'
                } else {
                    $analysis.derivedClass = 'top_pair_weak_kicker'
                }
            } else {
                $sortedBoardValsDesc = $boardVals
                $secondVal = if ($sortedBoardValsDesc.Count -ge 2) { $sortedBoardValsDesc[1] } else { 0 }
                if ($pairedVal -eq $secondVal) {
                    $analysis.derivedClass = 'second_pair'
                } else {
                    $analysis.derivedClass = 'third_pair_or_lower'
                }
            }
        }
    } else {
        $analysis.derivedClass = $null
    }
    return $analysis
}

# Mojibake detection by codepoint scan (no literal mojibake in source).
function Test-MojibakeText($text) {
    if (-not $text) { return $null }
    foreach ($ch in $text.ToCharArray()) {
        $code = [int]$ch
        # Thai range U+0E00..U+0E7F is the standard CP874 mojibake artifact
        if ($code -ge 0x0E00 -and $code -le 0x0E7F) { return 'thai_range' }
        # Replacement character U+FFFD indicates broken decoding
        if ($code -eq 0xFFFD) { return 'replacement_char' }
    }
    return $null
}

# ============================================================================
# AUDIT EXECUTION
# ============================================================================

$totalErrors = 0
$totalWarnings = 0
$scenarioStatus = @{}
$allErrors = New-Object System.Collections.ArrayList
$allWarnings = New-Object System.Collections.ArrayList

function Add-AuditError($sid, $rule, $msg) {
    $obj = [PSCustomObject]@{ scenarioId = $sid; rule = $rule; message = $msg }
    [void]$allErrors.Add($obj)
}
function Add-AuditWarn($sid, $rule, $msg) {
    $obj = [PSCustomObject]@{ scenarioId = $sid; rule = $rule; message = $msg }
    [void]$allWarnings.Add($obj)
}

if (-not $seed.scenarios) {
    Write-Output 'ERROR: seed JSON has no .scenarios array'
    exit 1
}

foreach ($s in $seed.scenarios) {
    $sid = if ($s.id) { $s.id } else { '<unknown>' }
    $sErrors = 0
    $sWarnings = 0

    # M2.H01 board cards
    if (-not $s.board -or -not $s.board.cards) {
        Add-AuditError $sid 'M2.H01' 'board.cards missing'; $sErrors++
    } else {
        if ($s.board.cards.Count -ne 3) {
            Add-AuditError $sid 'M2.H01' ('board has ' + $s.board.cards.Count + ' cards, expected 3'); $sErrors++
        }
        $boardSeen = @{}
        foreach ($c in $s.board.cards) {
            if (-not (Test-CardValid $c)) {
                Add-AuditError $sid 'M2.H01' ("invalid board card '" + $c + "'"); $sErrors++
            }
            if ($boardSeen.ContainsKey("$c")) {
                Add-AuditError $sid 'M2.H01' ("duplicate board card '" + $c + "'"); $sErrors++
            }
            $boardSeen["$c"] = $true
        }
    }

    # M2.H02 hero hand
    if (-not $s.heroHand) {
        Add-AuditError $sid 'M2.H02' 'heroHand missing'; $sErrors++
    } else {
        if ($s.heroHand.Count -ne 2) {
            Add-AuditError $sid 'M2.H02' ('heroHand has ' + $s.heroHand.Count + ' cards, expected 2'); $sErrors++
        }
        $heroSeen = @{}
        foreach ($c in $s.heroHand) {
            if (-not (Test-CardValid $c)) {
                Add-AuditError $sid 'M2.H02' ("invalid hero card '" + $c + "'"); $sErrors++
            }
            if ($heroSeen.ContainsKey("$c")) {
                Add-AuditError $sid 'M2.H02' ("duplicate hero card '" + $c + "'"); $sErrors++
            }
            $heroSeen["$c"] = $true
        }
    }

    # M2.H03 collision
    if ($s.board -and $s.board.cards -and $s.heroHand) {
        $boardSet = @{}
        foreach ($c in $s.board.cards) { $boardSet["$c"] = $true }
        foreach ($c in $s.heroHand) {
            if ($boardSet.ContainsKey("$c")) {
                Add-AuditError $sid 'M2.H03' ("hero card '" + $c + "' also on board"); $sErrors++
            }
        }
    }

    # M2.H04 module / spot
    if ($s.module -ne 'pf_flop_cbet_ip') {
        Add-AuditError $sid 'M2.H04' ("module is '" + $s.module + "', expected 'pf_flop_cbet_ip'"); $sErrors++
    }
    if ($s.street -ne 'flop') {
        Add-AuditError $sid 'M2.H04' ("street is '" + $s.street + "', expected 'flop'"); $sErrors++
    }
    if ($s.spot) {
        if ($s.spot.heroPosition -and $s.spot.heroPosition -ne 'BTN') {
            Add-AuditWarn $sid 'M2.H04' ("spot.heroPosition is '" + $s.spot.heroPosition + "', v4.1.2 expects 'BTN'"); $sWarnings++
        }
        if ($s.spot.villainPosition -and $s.spot.villainPosition -ne 'BB') {
            Add-AuditWarn $sid 'M2.H04' ("spot.villainPosition is '" + $s.spot.villainPosition + "', v4.1.2 expects 'BB'"); $sWarnings++
        }
        if ($s.spot.potType -and $s.spot.potType -ne 'SRP') {
            Add-AuditWarn $sid 'M2.H04' ("spot.potType is '" + $s.spot.potType + "', v4.1.2 expects 'SRP'"); $sWarnings++
        }
        if ($s.spot.effectiveStackBB -and $s.spot.effectiveStackBB -ne 100) {
            Add-AuditWarn $sid 'M2.H04' ('spot.effectiveStackBB is ' + $s.spot.effectiveStackBB + ', v4.1.2 expects 100'); $sWarnings++
        }
    }

    # M2.H05 question type
    $qtype = $null
    if ($s.question -and $s.question.type) {
        $qtype = $s.question.type
        if ($validQTypes -notcontains $qtype) {
            Add-AuditError $sid 'M2.H05' ("question.type '" + $qtype + "' not in valid set"); $sErrors++
        }
    } else {
        Add-AuditError $sid 'M2.H05' 'question.type missing'; $sErrors++
    }

    # M2.H06 / M2.H07 choice ids
    if ($qtype -eq 'action_choice') {
        $choiceIds = if ($s.question.choices) { ($s.question.choices | ForEach-Object { $_.id }) } else { @() }
        $missing = $validActions | Where-Object { $choiceIds -notcontains $_ }
        $extra = $choiceIds | Where-Object { $validActions -notcontains $_ }
        if ($missing.Count -gt 0) {
            Add-AuditError $sid 'M2.H06' ('action_choice missing required ids: ' + ($missing -join ',')); $sErrors++
        }
        if ($extra.Count -gt 0) {
            Add-AuditError $sid 'M2.H06' ('action_choice has unexpected ids: ' + ($extra -join ',')); $sErrors++
        }
    } elseif ($qtype -eq 'reason_choice') {
        $choiceIds = if ($s.question.choices) { ($s.question.choices | ForEach-Object { $_.id }) } else { @() }
        $invalid = $choiceIds | Where-Object { $validReasons -notcontains $_ }
        if ($invalid.Count -gt 0) {
            Add-AuditError $sid 'M2.H07' ('reason_choice has invalid ids: ' + ($invalid -join ',')); $sErrors++
        }
        if ($choiceIds.Count -lt 3 -or $choiceIds.Count -gt 4) {
            Add-AuditWarn $sid 'M2.H07' ('reason_choice has ' + $choiceIds.Count + ' choices; expected 3 or 4'); $sWarnings++
        }
    }

    # M2.H08 answer tier integrity
    if (-not $s.answer) {
        Add-AuditError $sid 'M2.H08' 'answer missing'; $sErrors++
    } else {
        $best = if ($s.answer.best) { $s.answer.best } else { @() }
        $accept = if ($s.answer.acceptable) { $s.answer.acceptable } else { @() }
        $bad = if ($s.answer.bad) { $s.answer.bad } else { @() }
        $crit = if ($s.answer.critical) { $s.answer.critical } else { @() }

        if ($best.Count -eq 0) {
            Add-AuditError $sid 'M2.H08' 'answer.best is empty'; $sErrors++
        }
        $seen = @{}
        foreach ($t in @('best','acceptable','bad','critical')) {
            $arr = $s.answer.$t
            if ($arr) {
                foreach ($id in $arr) {
                    if ($seen.ContainsKey("$id")) {
                        Add-AuditError $sid 'M2.H08' ("choice id '" + $id + "' appears in multiple tiers (" + $seen[$id] + " and " + $t + ")"); $sErrors++
                    }
                    $seen["$id"] = $t
                }
            }
        }
        if ($s.question -and $s.question.choices) {
            $choiceIds = @{}
            foreach ($c in $s.question.choices) { $choiceIds[$c.id] = $true }
            $allIds = New-Object System.Collections.ArrayList
            foreach ($t in @('best','acceptable','bad','critical')) {
                $arr = $s.answer.$t
                if ($arr) {
                    foreach ($id in @($arr)) { [void]$allIds.Add($id) }
                }
            }
            foreach ($id in $allIds) {
                if (-not $choiceIds.ContainsKey($id)) {
                    Add-AuditError $sid 'M2.H08' ("answer references unknown choice id '" + $id + "'"); $sErrors++
                }
            }
        }
    }

    # M2.H09 recommendedAction consistency
    if ($qtype -eq 'action_choice' -and $s.recommendedAction) {
        if ($validActions -notcontains $s.recommendedAction) {
            Add-AuditError $sid 'M2.H09' ("recommendedAction '" + $s.recommendedAction + "' not in valid set"); $sErrors++
        } elseif ($s.answer.best -notcontains $s.recommendedAction) {
            Add-AuditError $sid 'M2.H09' ("recommendedAction '" + $s.recommendedAction + "' not in answer.best (" + ($s.answer.best -join ',') + ")"); $sErrors++
        }
    }

    # M2.H10 actionReason consistency
    if ($qtype -eq 'reason_choice' -and $s.actionReason) {
        if ($validReasons -notcontains $s.actionReason) {
            Add-AuditError $sid 'M2.H10' ("actionReason '" + $s.actionReason + "' not in valid set"); $sErrors++
        } elseif ($s.answer.best -notcontains $s.actionReason) {
            Add-AuditError $sid 'M2.H10' ("actionReason '" + $s.actionReason + "' not in answer.best for reason_choice"); $sErrors++
        }
    }

    # M2.H11 required fields
    $requiredFields = @('id','module','street','spot','board','heroHand','handClass','heroHandRole','question','answer','explanation','conceptTags','difficulty','sourceConfidence','auditStatus','recommendedAction','actionReason')
    foreach ($f in $requiredFields) {
        if (-not ($s.PSObject.Properties.Name -contains $f)) {
            Add-AuditError $sid 'M2.H11' ("missing required field '" + $f + "'"); $sErrors++
        }
    }

    # M2.H11b vocabulary
    if ($s.handClass -and ($validHandClasses -notcontains $s.handClass)) {
        Add-AuditError $sid 'M2.H11' ("handClass '" + $s.handClass + "' not in vocabulary"); $sErrors++
    }
    if ($s.heroHandRole -and ($validHandRoles -notcontains $s.heroHandRole)) {
        Add-AuditError $sid 'M2.H11' ("heroHandRole '" + $s.heroHandRole + "' not in vocabulary"); $sErrors++
    }
    if ($s.drawCategory -and ($validDrawCats -notcontains $s.drawCategory)) {
        Add-AuditError $sid 'M2.H11' ("drawCategory '" + $s.drawCategory + "' not in vocabulary"); $sErrors++
    }
    if ($s.showdownValue -and ($validShowdown -notcontains $s.showdownValue)) {
        Add-AuditError $sid 'M2.H11' ("showdownValue '" + $s.showdownValue + "' not in vocabulary"); $sErrors++
    }

    # M2.H12 sourceConfidence honesty
    if ($s.sourceConfidence) {
        if ($validSourceConfidence -notcontains $s.sourceConfidence) {
            Add-AuditError $sid 'M2.H12' ("sourceConfidence '" + $s.sourceConfidence + "' invalid"); $sErrors++
        } elseif ($s.sourceConfidence -eq 'solver_verified' -and -not $s.solverRunRef) {
            Add-AuditError $sid 'M2.H12' 'sourceConfidence=solver_verified requires solverRunRef field'; $sErrors++
        }
    }

    # M2.H13 auditStatus
    if ($s.auditStatus) {
        if ($validAuditStatus -notcontains $s.auditStatus) {
            Add-AuditError $sid 'M2.H13' ("auditStatus '" + $s.auditStatus + "' invalid"); $sErrors++
        }
        if ($s.auditStatus -eq 'approved') {
            Add-AuditWarn $sid 'M2.H13' 'auditStatus=approved on a v4.1.2 seed scenario; planning seeds should use review_pending'; $sWarnings++
        }
    }

    # M2.H14 explanation completeness
    if (-not $s.explanation) {
        Add-AuditError $sid 'M2.H14' 'explanation missing'; $sErrors++
    } else {
        if (-not $s.explanation.short) { Add-AuditError $sid 'M2.H14' 'explanation.short missing'; $sErrors++ }
        if (-not $s.explanation.handLogic) { Add-AuditError $sid 'M2.H14' 'explanation.handLogic missing'; $sErrors++ }
        if (-not $s.explanation.takeaway) { Add-AuditError $sid 'M2.H14' 'explanation.takeaway missing'; $sErrors++ }
        # sizingLogic strictly required only for action_choice scenarios where the
        # question is "what to do" — for reason_choice scenarios the question is
        # "why" and sizingLogic is optional.
        if ($qtype -eq 'action_choice' -and $s.recommendedAction -in @('bet_small','bet_big')) {
            if (-not $s.explanation.sizingLogic) {
                Add-AuditError $sid 'M2.H14' ('explanation.sizingLogic required when recommendedAction=' + $s.recommendedAction); $sErrors++
            }
        } elseif ($qtype -eq 'reason_choice' -and $s.recommendedAction -in @('bet_small','bet_big')) {
            if (-not $s.explanation.sizingLogic) {
                Add-AuditWarn $sid 'M2.H14' ('explanation.sizingLogic optional but recommended for reason_choice with recommendedAction=' + $s.recommendedAction); $sWarnings++
            }
        }
        if ($s.answer -and $s.answer.critical -and $s.answer.critical.Count -gt 0) {
            if (-not $s.explanation.commonMistake) {
                Add-AuditError $sid 'M2.H14' 'explanation.commonMistake required when answer.critical is non-empty'; $sErrors++
            }
        }
    }

    # M2.H15 mojibake
    $textsToCheck = @()
    if ($s.question -and $s.question.prompt) { $textsToCheck += $s.question.prompt }
    if ($s.explanation) {
        foreach ($f in 'short','rangeContext','handLogic','sizingLogic','commonMistake','takeaway') {
            if ($s.explanation.$f) { $textsToCheck += $s.explanation.$f }
        }
    }
    foreach ($t in $textsToCheck) {
        $hit = Test-MojibakeText $t
        if ($hit) {
            Add-AuditError $sid 'M2.H15' ('mojibake detected (' + $hit + ')'); $sErrors++
            break
        }
    }

    # M2.H16 concept tag validity
    if ($s.conceptTags) {
        foreach ($tag in $s.conceptTags) {
            if (-not $knownConcepts.Contains($tag)) {
                Add-AuditWarn $sid 'M2.H16' ("conceptTag '" + $tag + "' not in postflop_concepts.json or [planned] list"); $sWarnings++
            }
        }
    }

    # SUIT-COUNT DISCIPLINE + HAND-CLASS DERIVATION + STRATEGIC WARNINGS
    if ($s.board -and $s.board.cards -and $s.heroHand -and $s.heroHand.Count -eq 2) {
        $allCards = @()
        foreach ($c in $s.board.cards) { $allCards += $c }
        foreach ($c in $s.heroHand) { $allCards += $c }
        $allValid = $true
        foreach ($c in $allCards) { if (-not (Test-CardValid $c)) { $allValid = $false } }
        if ($allValid) {
            $combinedSuitCounts = Get-SuitCounts $allCards
            $flushSuit = Get-FlushSuit $allCards
            $flushDrawSuit = Get-FlushDrawSuit $allCards
            $backdoorSuit = Get-BackdoorFlushSuit $allCards

            # M2.SC01 made flush requires 5+ of suit
            if ($s.handClass -in @('flush','nut_flush')) {
                if (-not $flushSuit) {
                    $maxSuit = ($combinedSuitCounts.GetEnumerator() | Sort-Object -Property Value -Descending)[0]
                    Add-AuditError $sid 'M2.SC01' ("handClass='" + $s.handClass + "' but combined suit count max is " + $maxSuit.Value + " (need 5)"); $sErrors++
                }
                if ($s.handClass -eq 'nut_flush' -and $flushSuit) {
                    $aceOfSuit = "A$flushSuit"
                    if ($s.heroHand -notcontains $aceOfSuit) {
                        Add-AuditError $sid 'M2.SC01' ("handClass='nut_flush' but hero does not hold " + $aceOfSuit); $sErrors++
                    }
                }
            }

            # M2.SC02 flush draw requires exactly 4 of suit
            if ($s.handClass -in @('flush_draw','nut_flush_draw')) {
                if (-not $flushDrawSuit) {
                    if ($flushSuit) {
                        Add-AuditError $sid 'M2.SC02' ("handClass='" + $s.handClass + "' but combined suit count is " + $combinedSuitCounts[$flushSuit] + " (already a made flush)"); $sErrors++
                    } else {
                        $maxSuit = ($combinedSuitCounts.GetEnumerator() | Sort-Object -Property Value -Descending)[0]
                        Add-AuditError $sid 'M2.SC02' ("handClass='" + $s.handClass + "' but combined suit count max is " + $maxSuit.Value + " (need exactly 4 for FD)"); $sErrors++
                    }
                }
                if ($s.handClass -eq 'nut_flush_draw' -and $flushDrawSuit) {
                    $aceOfSuit = "A$flushDrawSuit"
                    if ($s.heroHand -notcontains $aceOfSuit) {
                        Add-AuditError $sid 'M2.SC02' ("handClass='nut_flush_draw' but hero does not hold " + $aceOfSuit); $sErrors++
                    }
                }
            }

            # M2.SC03 drawCategory consistency
            if ($s.drawCategory -in @('fd','nut_fd')) {
                if (-not $flushDrawSuit) {
                    Add-AuditError $sid 'M2.SC03' ("drawCategory='" + $s.drawCategory + "' but combined suit count does not match (need exactly 4 of one suit)"); $sErrors++
                }
                if ($s.drawCategory -eq 'nut_fd' -and $flushDrawSuit) {
                    $aceOfSuit = "A$flushDrawSuit"
                    if ($s.heroHand -notcontains $aceOfSuit) {
                        Add-AuditError $sid 'M2.SC03' ("drawCategory='nut_fd' but hero does not hold " + $aceOfSuit); $sErrors++
                    }
                }
            }

            # M2.SC04 backdoor_only sanity
            if ($s.handClass -eq 'backdoor_only') {
                if ($flushSuit) {
                    Add-AuditWarn $sid 'M2.SC04' "handClass='backdoor_only' but a made flush is present"; $sWarnings++
                }
                if ($flushDrawSuit) {
                    Add-AuditWarn $sid 'M2.SC04' "handClass='backdoor_only' but a real flush draw is present"; $sWarnings++
                }
            }

            # M2.SC05 explanation 'made flush' wording sanity check.
            # WARN (not error) — text matching is fuzzy. Skip if text contains
            # negation phrases like "not made flush" or "no made flush" or
            # "doesn't make a flush" because those are intentional contrasts.
            if ($s.explanation) {
                $allText = ''
                foreach ($f in 'short','rangeContext','handLogic','sizingLogic','commonMistake','takeaway') {
                    if ($s.explanation.$f) { $allText += $s.explanation.$f.ToLower() + ' ' }
                }
                $hasMadeFlushClaim = $allText -match 'made (nut |k-high |a-high )?flush'
                $hasNegation = $allText -match '(not |no |never |without |doesn''t |does not )(give us a |have a |have the |get a |make a )?(made |a )?(nut |k-high |a-high )?flush'
                if ($hasMadeFlushClaim -and -not $flushSuit -and -not $hasNegation) {
                    Add-AuditWarn $sid 'M2.SC05' "explanation text mentions 'made flush' but no 5-of-suit present (text matching is fuzzy; review wording)"; $sWarnings++
                }
            }

            # HAND-CLASS DERIVATION
            $straightHigh = Get-MadeStraightHigh $allCards
            $oesd = Test-OESD $allCards
            $gutshot = Test-Gutshot $allCards
            $pairAnalysis = Get-PairAnalysis $s.heroHand $s.board.cards

            # M2.HC01 straight requires 5 consecutive
            if ($s.handClass -eq 'straight') {
                if ($straightHigh -eq 0) {
                    Add-AuditError $sid 'M2.HC01' "handClass='straight' but no made straight detected"; $sErrors++
                }
            }

            # M2.HC02 set
            if ($s.handClass -eq 'set') {
                if ($pairAnalysis.derivedClass -ne 'set') {
                    Add-AuditError $sid 'M2.HC02' ("handClass='set' but mechanically derived class is '" + $pairAnalysis.derivedClass + "'"); $sErrors++
                }
            }

            # M2.HC03 trips
            if ($s.handClass -eq 'trips') {
                if ($pairAnalysis.derivedClass -ne 'trips') {
                    Add-AuditError $sid 'M2.HC03' ("handClass='trips' but mechanically derived class is '" + $pairAnalysis.derivedClass + "'"); $sErrors++
                }
            }

            # M2.HC04 overpair
            if ($s.handClass -eq 'overpair') {
                if ($pairAnalysis.derivedClass -ne 'overpair') {
                    Add-AuditError $sid 'M2.HC04' ("handClass='overpair' but mechanically derived class is '" + $pairAnalysis.derivedClass + "'"); $sErrors++
                }
            }

            # M2.HC05 top_pair_*
            if ($s.handClass -in @('top_pair_top_kicker','top_pair_good_kicker','top_pair_weak_kicker')) {
                if ($pairAnalysis.derivedClass -notlike 'top_pair_*') {
                    Add-AuditError $sid 'M2.HC05' ("handClass='" + $s.handClass + "' but mechanically derived class is '" + $pairAnalysis.derivedClass + "'"); $sErrors++
                } elseif ($pairAnalysis.derivedClass -ne $s.handClass) {
                    Add-AuditWarn $sid 'M2.HC05' ("handClass='" + $s.handClass + "' but mechanical derivation suggests '" + $pairAnalysis.derivedClass + "'"); $sWarnings++
                }
            }

            # M2.HC06 combo_draw
            if ($s.handClass -eq 'combo_draw') {
                $hasFD = ($flushDrawSuit -ne $null)
                $hasSD = $oesd -or ($gutshot -and $hasFD)
                if (-not $hasFD -or (-not $hasSD)) {
                    Add-AuditError $sid 'M2.HC06' ('handClass=combo_draw but mechanical: hasFD=' + $hasFD + ' hasOESD=' + $oesd + ' hasGutshot=' + $gutshot); $sErrors++
                }
            }

            # M2.HC07 oesd
            if ($s.handClass -eq 'oesd') {
                if (-not $oesd) {
                    Add-AuditError $sid 'M2.HC07' "handClass='oesd' but no OESD detected"; $sErrors++
                }
            }

            # M2.HC08 gutshot
            if ($s.handClass -eq 'gutshot') {
                if (-not $gutshot) {
                    Add-AuditWarn $sid 'M2.HC08' "handClass='gutshot' but mechanical detection found no gutshot"; $sWarnings++
                }
            }

            # M2.HC09 underpair
            if ($s.handClass -eq 'underpair') {
                if ($pairAnalysis.derivedClass -ne 'underpair') {
                    Add-AuditWarn $sid 'M2.HC09' ("handClass='underpair' but mechanically derived '" + $pairAnalysis.derivedClass + "'"); $sWarnings++
                }
            }

            # M2.HC10 mid_pair
            if ($s.handClass -eq 'mid_pair') {
                if ($pairAnalysis.derivedClass -ne 'mid_pair') {
                    Add-AuditWarn $sid 'M2.HC10' ("handClass='mid_pair' but mechanically derived '" + $pairAnalysis.derivedClass + "'"); $sWarnings++
                }
            }

            # M2.HC11 no_pair_no_draw
            if ($s.handClass -eq 'no_pair_no_draw') {
                if ($pairAnalysis.derivedClass) {
                    Add-AuditWarn $sid 'M2.HC11' ("handClass='no_pair_no_draw' but mechanically '" + $pairAnalysis.derivedClass + "'"); $sWarnings++
                } elseif ($oesd -or $gutshot -or $flushDrawSuit -or $backdoorSuit -or (Test-BackdoorStraight $allCards)) {
                    Add-AuditWarn $sid 'M2.HC11' "handClass='no_pair_no_draw' but a draw or backdoor exists; consider 'backdoor_only'"; $sWarnings++
                }
            }

            # STRATEGIC WARNINGS
            $textureTags = if ($s.board.textureTags) { $s.board.textureTags } else { @() }
            $bestArr = if ($s.answer.best) { $s.answer.best } else { @() }

            # S01 overpair on low_connected with bet_big best
            if ($pairAnalysis.derivedClass -eq 'overpair' -and ($textureTags -contains 'low_connected') -and ($bestArr -contains 'bet_big')) {
                Add-AuditWarn $sid 'M2.S01' 'Overpair on low_connected board with bet_big best - solver-sensitive; review framing'; $sWarnings++
            }

            # S02 air on dry A-high check-only
            if ($pairAnalysis.derivedClass -eq $null -and ($textureTags -contains 'ace_high_dry') -and $bestArr.Count -eq 1 -and $bestArr -contains 'check' -and -not ($flushDrawSuit -or $oesd)) {
                Add-AuditWarn $sid 'M2.S02' 'Air on ace_high_dry with check-only best - small range stab is the modern preference'; $sWarnings++
            }

            # S03 naked air on monotone betting
            if ($s.board.suitTexture -eq 'monotone' -and $pairAnalysis.derivedClass -eq $null -and -not $flushDrawSuit -and -not $backdoorSuit -and ($bestArr -contains 'bet_small' -or $bestArr -contains 'bet_big')) {
                Add-AuditWarn $sid 'M2.S03' 'Naked air on monotone with bet best - usually checks; review intent'; $sWarnings++
            }

            # S04 top_pair_top_kicker bet_big on dry
            if ($s.handClass -eq 'top_pair_top_kicker' -and ($textureTags -contains 'dry') -and ($bestArr -contains 'bet_big') -and -not ($bestArr -contains 'bet_small')) {
                Add-AuditWarn $sid 'M2.S04' 'Top pair top kicker on dry board with bet_big best - small high-frequency dominates here'; $sWarnings++
            }
        }
    }

    if ($sErrors -gt 0) {
        $scenarioStatus[$sid] = 'FAIL'
        $totalErrors += $sErrors
    } elseif ($sWarnings -gt 0) {
        $scenarioStatus[$sid] = 'WARN'
    } else {
        $scenarioStatus[$sid] = 'PASS'
    }
    $totalWarnings += $sWarnings
}

# ============================================================================
# OUTPUT
# ============================================================================

Write-Output ''
Write-Output '============================================================'
Write-Output ' Module 2 SEED audit'
Write-Output '============================================================'
Write-Output ('Source:    ' + $seedPath)
Write-Output ('Version:   ' + $seed.version)
Write-Output ('Scenarios: ' + $seed.scenarios.Count)
Write-Output ''

if ($allErrors.Count -gt 0) {
    Write-Output '--- HARD ERRORS ---'
    $byScenario = $allErrors | Group-Object scenarioId
    foreach ($g in $byScenario) {
        Write-Output ('  [' + $g.Name + ']')
        foreach ($e in $g.Group) {
            Write-Output ('    ' + $e.rule + ': ' + $e.message)
        }
    }
    Write-Output ''
}

if ($allWarnings.Count -gt 0) {
    Write-Output '--- WARNINGS ---'
    $byScenario = $allWarnings | Group-Object scenarioId
    foreach ($g in $byScenario) {
        Write-Output ('  [' + $g.Name + ']')
        foreach ($w in $g.Group) {
            Write-Output ('    ' + $w.rule + ': ' + $w.message)
        }
    }
    Write-Output ''
}

$pass = ($scenarioStatus.Values | Where-Object { $_ -eq 'PASS' }).Count
$warn = ($scenarioStatus.Values | Where-Object { $_ -eq 'WARN' }).Count
$fail = ($scenarioStatus.Values | Where-Object { $_ -eq 'FAIL' }).Count

Write-Output '--- PASS / WARN / FAIL ---'
Write-Output ('  PASS: ' + $pass)
Write-Output ('  WARN: ' + $warn)
Write-Output ('  FAIL: ' + $fail)
Write-Output ''

Write-Output '--- COVERAGE ---'
Write-Output ('  Total scenarios:    ' + $seed.scenarios.Count)
Write-Output ('  Total hard errors:  ' + $totalErrors)
Write-Output ('  Total warnings:     ' + $totalWarnings)
Write-Output ''

$byQType = $seed.scenarios | Group-Object { $_.question.type }
Write-Output '  By question.type:'
foreach ($g in ($byQType | Sort-Object Name)) { Write-Output ('    ' + $g.Name + ': ' + $g.Count) }

$byBoard = $seed.scenarios | Group-Object { ($_.board.cards -join ' ') }
Write-Output '  By board:'
foreach ($g in ($byBoard | Sort-Object Name)) { Write-Output ('    ' + $g.Name + ': ' + $g.Count) }

$byAction = $seed.scenarios | Group-Object recommendedAction
Write-Output '  By recommendedAction:'
foreach ($g in ($byAction | Sort-Object Name)) { Write-Output ('    ' + $g.Name + ': ' + $g.Count) }

$byReason = $seed.scenarios | Group-Object actionReason
Write-Output '  By actionReason:'
foreach ($g in ($byReason | Sort-Object Name)) { Write-Output ('    ' + $g.Name + ': ' + $g.Count) }

$byRole = $seed.scenarios | Group-Object heroHandRole
Write-Output '  By heroHandRole:'
foreach ($g in ($byRole | Sort-Object Name)) { Write-Output ('    ' + $g.Name + ': ' + $g.Count) }

$byHC = $seed.scenarios | Group-Object handClass
Write-Output '  By handClass:'
foreach ($g in ($byHC | Sort-Object Name)) { Write-Output ('    ' + $g.Name + ': ' + $g.Count) }

$byDiff = $seed.scenarios | Group-Object difficulty
Write-Output '  By difficulty:'
foreach ($g in ($byDiff | Sort-Object Name)) { Write-Output ('    ' + $g.Name + ': ' + $g.Count) }

$bySC = $seed.scenarios | Group-Object sourceConfidence
Write-Output '  By sourceConfidence:'
foreach ($g in ($bySC | Sort-Object Name)) { Write-Output ('    ' + $g.Name + ': ' + $g.Count) }

$byAS = $seed.scenarios | Group-Object auditStatus
Write-Output '  By auditStatus:'
foreach ($g in ($byAS | Sort-Object Name)) { Write-Output ('    ' + $g.Name + ': ' + $g.Count) }

$critCount = ($seed.scenarios | Where-Object { $_.answer -and $_.answer.critical -and $_.answer.critical.Count -gt 0 }).Count
Write-Output ('  Scenarios with critical answers: ' + $critCount)

Write-Output ''
Write-Output '============================================================'
if ($totalErrors -eq 0) {
    Write-Output (' RESULT: PASS (' + $totalWarnings + ' warnings)')
    Write-Output '============================================================'
    exit 0
} else {
    Write-Output (' RESULT: FAIL (' + $totalErrors + ' hard errors)')
    Write-Output '============================================================'
    exit 1
}
