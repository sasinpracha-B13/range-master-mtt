# tools/audit-postflop-module3-seed.ps1
#
# Module 3 (Facing C-bet OOP) SEED auditor. Audits the v4.2.0 planning seed
# JSON at docs/specs/postflop-v4.2.0-module3-seed-scenarios.json against the
# rules defined in docs/specs/postflop-v4.2.0-module3-audit-plan.md.
#
# Intentionally separate from tools/audit-postflop-ps.ps1 (production) and
# tools/audit-postflop-module2-seed.ps1 (M2 seed). M3 has its own vocabulary:
#  - villainAction / villainSizing fields (new vs M2)
#  - 5-action decision set: fold / call / check_raise_small / check_raise_big / mixed
#  - 8-reason set: value_raise / protection_raise / semi_bluff_raise / blocker_raise
#                  / bluff_catch / equity_realization_call
#                  / range_disadvantage_fold / domination_fold
#  - 2 new heroHandRole values: bluff_catcher, dominated_marginal
#
# Run from repo root:
#   powershell -ExecutionPolicy Bypass -File tools/audit-postflop-module3-seed.ps1
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
#   Per-scenario warnings (if any)
#   PASS/WARN/FAIL summary
#   Distribution stats
#
# Source intentionally pure ASCII to avoid CP874 / UTF-8 mojibake during
# PowerShell parsing on Thai-locale Windows.

param(
    [string]$Path = 'docs/specs/postflop-v4.2.0-module3-seed-scenarios.json'
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$seedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $repoRoot $Path }

if (-not (Test-Path $seedPath)) {
    Write-Output ('ERROR: Seed file not found: ' + $seedPath)
    exit 1
}

# UTF-8 explicit read to avoid system codepage mojibake
$seedText = [System.IO.File]::ReadAllText((Resolve-Path $seedPath), [System.Text.Encoding]::UTF8)
try {
    $seed = $seedText | ConvertFrom-Json
} catch {
    Write-Output ('ERROR: JSON parse failed: ' + $_)
    exit 1
}

# ============================================================================
# VOCABULARY (mirrors docs/specs/postflop-v4.2.0-module3-schema-taxonomy.md)
# ============================================================================

$validRanks = @('A','K','Q','J','T','9','8','7','6','5','4','3','2')
$validSuits = @('s','h','d','c')
$rankIdx = @{}
for ($i = 0; $i -lt $validRanks.Count; $i++) { $rankIdx[$validRanks[$i]] = (14 - $i) }

# M2 + M3 reused handClass (per schema doc s 6)
$validHandClasses = @(
    'set','straight','flush','nut_flush','top_two_pair','two_pair','overpair',
    'top_pair_top_kicker','top_pair_good_kicker','top_pair_weak_kicker',
    'second_pair','third_pair_or_lower','underpair','mid_pair','bottom_pair',
    'combo_draw','flush_draw','nut_flush_draw','oesd','gutshot',
    'backdoor_only','no_pair_no_draw','trips','full_house'
)

# M2 set + 2 M3-specific (per schema doc s 7)
$validHandRoles = @(
    'nutted_value','strong_value','marginal_made_hand','bluff_catcher',
    'semi_bluff_combo','pure_draw','blocker_bluff','give_up','dominated_marginal',
    'thin_value','medium_showdown','weak_showdown','nut_draw','strong_draw',
    'weak_draw','air','trap_check'
)

# M2 reused (per schema doc s 8)
$validDrawCats = @('none','backdoor_only','gutshot','oesd','flush_draw','combo_draw','nut_flush_draw','nut_fd','fd','combo')

# M2 reused (per schema doc s 9)
$validShowdown = @('none','low','decent','high','nutted','medium')

# M3-specific (per schema doc s 4)
$validActions = @('fold','call','check_raise_small','check_raise_big','mixed')

# M3-specific 8 reasons (per schema doc s 5)
$validReasons = @(
    'value_raise','protection_raise','semi_bluff_raise','blocker_raise',
    'bluff_catch','equity_realization_call','range_disadvantage_fold','domination_fold'
)

$validQTypes = @('action_choice','reason_choice')

$validSourceConfidence = @('expert_judgment','consensus_gto','solver_run','solver_verified')

$validAuditStatus = @('planning_only','approved','review_pending','draft')

$validReviewStatus = @('v4.2.0_seed_candidate','v4.2.0_seed_reviewed','v4.2.0_final','v4.2.0_gpt_reviewed')

# Concept tags - M3 native + M2 reusable (per audit-plan doc s 3.10)
$validConceptTags = @(
    'oop_defense_threshold','check_raise_value','check_raise_bluff',
    'bluff_catchers','equity_realization_oop','range_disadvantage','pot_odds_defense',
    'pot_control','value_raise','protection_raise','semi_bluff_raise'
)
$m3NativeTags = @(
    'oop_defense_threshold','check_raise_value','check_raise_bluff',
    'bluff_catchers','equity_realization_oop','range_disadvantage','pot_odds_defense'
)

$validBoardKinds = @('A_high','K_high','Q_high','J_high','T_high','low')
$validSuitTextures = @('rainbow','two_tone','monotone')
$validTextureTags = @('dry','static','semi_dry','wet','very_wet','connected','paired','broadway_heavy','low')

# ============================================================================
# HELPERS
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

# ============================================================================
# PER-SCENARIO RULES
# ============================================================================

$hardErrors = @()
$warnings   = @()

function Add-HardError($scenarioId, $rule, $msg) {
    $script:hardErrors += [PSCustomObject]@{ Id=$scenarioId; Rule=$rule; Message=$msg }
}
function Add-Warning($scenarioId, $rule, $msg) {
    $script:warnings += [PSCustomObject]@{ Id=$scenarioId; Rule=$rule; Message=$msg }
}

# Distribution counters
$boardCount = @{}
$qtypeCount = @{}
$bestActionCount = @{}
$reasonCount = @{}
$auditStatusCount = @{}
$reviewStatusCount = @{}
$bigRaiseCount = 0
$mixedBestCount = 0
$missingDefenseLogicCount = 0

# ============================================================================
# ITERATE SCENARIOS
# ============================================================================

if (-not $seed.scenarios) {
    Write-Output 'ERROR: seed JSON has no .scenarios array'
    exit 1
}

$total = $seed.scenarios.Count

foreach ($s in $seed.scenarios) {
    $sid = if ($s.id) { $s.id } else { '<missing-id>' }

    # M3-R01..R04: Mechanical card validity
    if (-not $s.board -or -not $s.board.cards) {
        Add-HardError $sid 'M3-R01' 'board.cards missing'
        continue
    }
    if ($s.board.cards.Count -ne 3) {
        Add-HardError $sid 'M3-R02' ('board.cards count = ' + $s.board.cards.Count + ' (must be 3)')
    }
    foreach ($c in $s.board.cards) {
        if (-not (Test-CardValid $c)) { Add-HardError $sid 'M3-R01' ('invalid board card: ' + $c) }
    }
    if (-not $s.heroHand) {
        Add-HardError $sid 'M3-R03' 'heroHand missing'
        continue
    }
    if ($s.heroHand.Count -ne 2) {
        Add-HardError $sid 'M3-R03' ('heroHand count = ' + $s.heroHand.Count + ' (must be 2)')
    }
    foreach ($c in $s.heroHand) {
        if (-not (Test-CardValid $c)) { Add-HardError $sid 'M3-R01' ('invalid hero card: ' + $c) }
    }

    # M3-R04, R05: Card collision (board cards distinct, hero cards distinct, no cross-collision)
    $allCards = @()
    $allCards += $s.board.cards
    $allCards += $s.heroHand
    $cardSet = @{}
    $dupFound = $false
    foreach ($c in $allCards) {
        if ($cardSet.ContainsKey($c)) {
            Add-HardError $sid 'M3-R05' ('duplicate card across board+hero: ' + $c)
            $dupFound = $true
        }
        $cardSet[$c] = $true
    }

    # M3-R06: card suits/ranks valid (covered by Test-CardValid above)

    # M3-R07: boardKind
    if ($s.board.boardKind -and ($validBoardKinds -notcontains $s.board.boardKind)) {
        Add-HardError $sid 'M3-R07' ('invalid boardKind: ' + $s.board.boardKind)
    }
    # M3-R08: suitTexture
    if ($s.board.suitTexture -and ($validSuitTextures -notcontains $s.board.suitTexture)) {
        Add-HardError $sid 'M3-R08' ('invalid suitTexture: ' + $s.board.suitTexture)
    }
    # M3-R09: textureTags subset
    if ($s.board.textureTags) {
        foreach ($t in $s.board.textureTags) {
            if ($validTextureTags -notcontains $t) {
                Add-HardError $sid 'M3-R09' ('invalid textureTag: ' + $t)
            }
        }
    }
    # M3-R10: highCardClass matches highest board rank (warning only)
    if ($s.board.highCardClass) {
        $bvals = $s.board.cards | ForEach-Object { Get-RankValue (Get-Rank $_) }
        $maxV = ($bvals | Sort-Object -Descending)[0]
        $expectedHcc = switch ($maxV) {
            14 { 'A_high' }
            13 { 'K_high' }
            12 { 'Q_high' }
            11 { 'J_high' }
            10 { 'T_high' }
            default { 'low' }
        }
        if ($s.board.highCardClass -ne $expectedHcc) {
            Add-Warning $sid 'M3-R10' ('highCardClass=' + $s.board.highCardClass + ' but board top is ' + $expectedHcc)
        }
    }

    # M3-R11..R15: Spot assumption
    if (-not $s.spot) { Add-HardError $sid 'M3-R11' 'spot missing'; continue }
    if ($s.spot.format -ne 'NLH_MTT') { Add-HardError $sid 'M3-R11' ('spot.format=' + $s.spot.format) }
    if ($s.spot.stackDepth -ne '100BB') { Add-HardError $sid 'M3-R12' ('spot.stackDepth=' + $s.spot.stackDepth) }
    if ($s.spot.potType -ne 'SRP') { Add-HardError $sid 'M3-R13' ('spot.potType=' + $s.spot.potType) }
    if ($s.spot.heroPosition -ne 'BB' -or $s.spot.villainPosition -ne 'BTN') {
        Add-HardError $sid 'M3-R14' ('positions mismatch: hero=' + $s.spot.heroPosition + ' villain=' + $s.spot.villainPosition)
    }
    if ($s.spot.villainAction -ne 'cbet') {
        Add-HardError $sid 'M3-R15' ('villainAction=' + $s.spot.villainAction + ' (must be cbet)')
    }
    if ($s.spot.villainSizing -ne 'small' -and $s.spot.villainSizing -ne 'big') {
        Add-HardError $sid 'M3-R15' ('villainSizing=' + $s.spot.villainSizing + ' (must be small or big)')
    }

    # M3-R16: question.choices for action_choice
    $qtype = if ($s.question) { $s.question.qtype } else { $null }
    if (-not $qtype) {
        Add-HardError $sid 'M3-R16' 'question.qtype missing'
    } elseif ($validQTypes -notcontains $qtype) {
        Add-HardError $sid 'M3-R16' ('invalid qtype: ' + $qtype)
    }

    if ($qtype -eq 'action_choice') {
        $expected = @('fold','call','check_raise_small','check_raise_big','mixed')
        $actual = $s.question.choices
        if ($actual.Count -ne 5) {
            Add-HardError $sid 'M3-R16' ('action_choice choices count=' + $actual.Count + ' (must be 5)')
        } else {
            for ($i = 0; $i -lt 5; $i++) {
                if ($actual[$i] -ne $expected[$i]) {
                    Add-HardError $sid 'M3-R16' ('action_choice choices[' + $i + ']=' + $actual[$i] + ' (expected ' + $expected[$i] + ')')
                }
            }
        }
    }

    # M3-R17: recommendedAction valid
    if ($validActions -notcontains $s.recommendedAction) {
        Add-HardError $sid 'M3-R17' ('invalid recommendedAction: ' + $s.recommendedAction)
    }

    # M3-R18: answer.best == recommendedAction (action_choice only)
    if ($qtype -eq 'action_choice' -and $s.answer.best -ne $s.recommendedAction) {
        Add-HardError $sid 'M3-R18' ('answer.best=' + $s.answer.best + ' != recommendedAction=' + $s.recommendedAction)
    }

    # M3-R19, R20: reason_choice + actionReason
    if ($qtype -eq 'reason_choice') {
        $actual = $s.question.choices
        foreach ($c in $actual) {
            if ($validReasons -notcontains $c) {
                Add-HardError $sid 'M3-R19' ('reason_choice contains invalid reason: ' + $c)
            }
        }
    }
    if ($validReasons -notcontains $s.actionReason) {
        Add-HardError $sid 'M3-R20' ('invalid actionReason: ' + $s.actionReason)
    }

    # M3-R21: answer.best == actionReason (reason_choice only)
    if ($qtype -eq 'reason_choice' -and $s.answer.best -ne $s.actionReason) {
        Add-HardError $sid 'M3-R21' ('answer.best=' + $s.answer.best + ' != actionReason=' + $s.actionReason)
    }

    # M3-R22: handClass
    if ($validHandClasses -notcontains $s.handClass) {
        Add-HardError $sid 'M3-R22' ('invalid handClass: ' + $s.handClass)
    }
    # M3-R23: drawCategory
    if ($validDrawCats -notcontains $s.drawCategory) {
        Add-HardError $sid 'M3-R23' ('invalid drawCategory: ' + $s.drawCategory)
    }
    # M3-R24: showdownValue
    if ($validShowdown -notcontains $s.showdownValue) {
        Add-HardError $sid 'M3-R24' ('invalid showdownValue: ' + $s.showdownValue)
    }
    # M3-R25: heroHandRole
    if ($s.heroHandRole -and ($validHandRoles -notcontains $s.heroHandRole)) {
        Add-HardError $sid 'M3-R25' ('invalid heroHandRole: ' + $s.heroHandRole)
    }

    # M3-R26: set sanity (warning)
    if ($s.handClass -eq 'set') {
        $heroRanks = $s.heroHand | ForEach-Object { Get-Rank $_ }
        if ($heroRanks[0] -ne $heroRanks[1]) {
            Add-Warning $sid 'M3-R26' ('handClass=set but hero is not pocket pair: ' + ($s.heroHand -join ' '))
        } else {
            $boardRanks = $s.board.cards | ForEach-Object { Get-Rank $_ }
            if ($boardRanks -notcontains $heroRanks[0]) {
                Add-Warning $sid 'M3-R26' ('handClass=set but pocket rank ' + $heroRanks[0] + ' not on board')
            }
        }
    }

    # M3-R27: flush_draw sanity (warning)
    if ($s.drawCategory -eq 'flush_draw' -or $s.drawCategory -eq 'nut_flush_draw') {
        $allSc = Get-SuitCounts ($s.board.cards + $s.heroHand)
        $maxSuit = ($allSc.Values | Sort-Object -Descending)[0]
        if ($maxSuit -lt 4) {
            Add-Warning $sid 'M3-R27' ('drawCategory=' + $s.drawCategory + ' but max suit count across hero+board is ' + $maxSuit + ' (need >=4 for true FD; 1-card FDs on monotone may be intentional)')
        }
    }

    # M3-R28..R31: answer partition
    if (-not $s.answer) {
        Add-HardError $sid 'M3-R28' 'answer missing'
    } else {
        $allChoices = if ($qtype -eq 'reason_choice') { $s.question.choices } else { @('fold','call','check_raise_small','check_raise_big','mixed') }
        if (-not $s.answer.best -or ($allChoices -notcontains $s.answer.best)) {
            Add-HardError $sid 'M3-R28' ('answer.best=' + $s.answer.best + ' not in choices')
        }
        if ($s.answer.acceptable) {
            foreach ($a in $s.answer.acceptable) {
                if ($allChoices -notcontains $a) {
                    Add-HardError $sid 'M3-R29' ('answer.acceptable contains invalid value: ' + $a)
                }
                if ($a -eq $s.answer.best) {
                    Add-HardError $sid 'M3-R29' ('answer.acceptable contains best value: ' + $a)
                }
            }
        }
        if ($s.answer.bad) {
            foreach ($b in $s.answer.bad) {
                if ($allChoices -notcontains $b) {
                    Add-HardError $sid 'M3-R30' ('answer.bad contains invalid value: ' + $b)
                }
                if ($b -eq $s.answer.best) {
                    Add-HardError $sid 'M3-R30' ('answer.bad contains best value: ' + $b)
                }
                if ($s.answer.acceptable -and ($s.answer.acceptable -contains $b)) {
                    Add-HardError $sid 'M3-R30' ('answer.bad overlaps acceptable: ' + $b)
                }
            }
        }
        if ($s.answer.critical) {
            foreach ($c in $s.answer.critical) {
                if (-not $s.answer.bad -or ($s.answer.bad -notcontains $c)) {
                    Add-HardError $sid 'M3-R31' ('answer.critical contains value not in bad: ' + $c)
                }
            }
        }
    }

    # M3-R32..R35: explanation required fields
    if (-not $s.explanation) {
        Add-HardError $sid 'M3-R32' 'explanation missing'
    } else {
        if (-not $s.explanation.short) { Add-HardError $sid 'M3-R32' 'explanation.short missing' }
        if (-not $s.explanation.rangeContext) { Add-HardError $sid 'M3-R33' 'explanation.rangeContext missing' }
        if (-not $s.explanation.handLogic) { Add-HardError $sid 'M3-R34' 'explanation.handLogic missing' }
        if (-not $s.explanation.takeaway) { Add-HardError $sid 'M3-R35' 'explanation.takeaway missing' }
        # M3-R36: defenseLogic warning if missing
        if (-not $s.explanation.defenseLogic) {
            Add-Warning $sid 'M3-R36' 'explanation.defenseLogic missing (recommended in v4.2.0; required in v4.2.4)'
            $script:missingDefenseLogicCount += 1
        }
        # M3-R37: commonMistake warning if missing
        if (-not $s.explanation.commonMistake) {
            Add-Warning $sid 'M3-R37' 'explanation.commonMistake missing (recommended for teaching value)'
        }
    }

    # M3-R38..R41: conceptTags
    if (-not $s.conceptTags -or $s.conceptTags.Count -eq 0) {
        Add-HardError $sid 'M3-R38' 'conceptTags missing or empty'
    } else {
        foreach ($t in $s.conceptTags) {
            if ($validConceptTags -notcontains $t) {
                Add-HardError $sid 'M3-R39' ('invalid conceptTag: ' + $t)
            }
        }
        if ($s.conceptTags.Count -gt 4) {
            Add-HardError $sid 'M3-R40' ('conceptTags count=' + $s.conceptTags.Count + ' (max 4)')
        }
        $hasNative = $false
        foreach ($t in $s.conceptTags) {
            if ($m3NativeTags -contains $t) { $hasNative = $true; break }
        }
        if (-not $hasNative) {
            Add-Warning $sid 'M3-R41' 'no M3-native conceptTag (only M2 reusable tags used)'
        }
    }

    # M3-R42..R44: sourceConfidence
    if ($validSourceConfidence -notcontains $s.sourceConfidence) {
        Add-HardError $sid 'M3-R42' ('invalid sourceConfidence: ' + $s.sourceConfidence)
    }
    if ($s.sourceConfidence -eq 'consensus_gto' -or $s.sourceConfidence -eq 'solver_run') {
        if (-not $s.sourceCitation) {
            Add-Warning $sid 'M3-R44' ('sourceConfidence=' + $s.sourceConfidence + ' but no sourceCitation field')
        }
    }

    # auditStatus / reviewStatus
    if ($validAuditStatus -notcontains $s.auditStatus) {
        Add-HardError $sid 'AUDITSTATUS' ('invalid auditStatus: ' + $s.auditStatus)
    }
    if ($validReviewStatus -notcontains $s.reviewStatus) {
        Add-HardError $sid 'REVIEWSTATUS' ('invalid reviewStatus: ' + $s.reviewStatus)
    }

    # Distribution counters
    $boardKey = ($s.board.cards) -join ' '
    if ($boardCount.ContainsKey($boardKey)) { $boardCount[$boardKey] += 1 } else { $boardCount[$boardKey] = 1 }
    if ($qtypeCount.ContainsKey($qtype)) { $qtypeCount[$qtype] += 1 } else { $qtypeCount[$qtype] = 1 }
    $bestKey = if ($qtype -eq 'action_choice') { $s.answer.best } else { 'reason:' + $s.answer.best }
    if ($bestActionCount.ContainsKey($bestKey)) { $bestActionCount[$bestKey] += 1 } else { $bestActionCount[$bestKey] = 1 }
    if ($reasonCount.ContainsKey($s.actionReason)) { $reasonCount[$s.actionReason] += 1 } else { $reasonCount[$s.actionReason] = 1 }
    if ($auditStatusCount.ContainsKey($s.auditStatus)) { $auditStatusCount[$s.auditStatus] += 1 } else { $auditStatusCount[$s.auditStatus] = 1 }
    if ($reviewStatusCount.ContainsKey($s.reviewStatus)) { $reviewStatusCount[$s.reviewStatus] += 1 } else { $reviewStatusCount[$s.reviewStatus] = 1 }
    if ($s.answer.best -eq 'check_raise_big') { $script:bigRaiseCount += 1 }
    if ($s.answer.best -eq 'mixed') { $script:mixedBestCount += 1 }
}

# M3-R45..R49: distribution warnings
if ($total -ne 24) { Add-Warning '<global>' 'M3-R45' ('total scenarios = ' + $total + ' (target 24)') }
if ($qtypeCount['action_choice'] -ne 18) { Add-Warning '<global>' 'M3-R46' ('action_choice count = ' + $qtypeCount['action_choice'] + ' (target 18)') }
if ($qtypeCount['reason_choice'] -ne 6) { Add-Warning '<global>' 'M3-R46' ('reason_choice count = ' + $qtypeCount['reason_choice'] + ' (target 6)') }
foreach ($k in $boardCount.Keys) {
    if ($boardCount[$k] -ne 4) { Add-Warning '<global>' 'M3-R47' ('board "' + $k + '" used ' + $boardCount[$k] + ' times (target 4)') }
}
if ($boardCount.Keys.Count -ne 6) { Add-Warning '<global>' 'M3-R47' ('distinct boards = ' + $boardCount.Keys.Count + ' (target 6)') }
foreach ($a in @('fold','call','check_raise_small','check_raise_big')) {
    if (-not $bestActionCount.ContainsKey($a) -or $bestActionCount[$a] -eq 0) {
        Add-Warning '<global>' 'M3-R48' ('action "' + $a + '" not used as best in any scenario')
    }
}
if ($bigRaiseCount -gt 2) {
    Add-Warning '<global>' 'M3-R49' ('check_raise_big used ' + $bigRaiseCount + ' times (target <=2)')
}
if ($mixedBestCount -gt 0) {
    Add-Warning '<global>' 'MIXED_BEST' ('mixed used as best in ' + $mixedBestCount + ' scenarios (consider concrete answer)')
}

# ============================================================================
# OUTPUT
# ============================================================================

Write-Output ''
Write-Output '============================================================'
Write-Output ' Module 3 Seed Audit'
Write-Output ' Source: docs/specs/postflop-v4.2.0-module3-seed-scenarios.json'
Write-Output '============================================================'
Write-Output ''
Write-Output ('Total scenarios: ' + $total)
Write-Output ('Hard errors: ' + $hardErrors.Count)
Write-Output ('Warnings: ' + $warnings.Count)
Write-Output ''

if ($hardErrors.Count -gt 0) {
    Write-Output '--- HARD ERRORS ---'
    foreach ($e in $hardErrors) {
        Write-Output ('  [' + $e.Rule + '] ' + $e.Id + ' :: ' + $e.Message)
    }
    Write-Output ''
}

if ($warnings.Count -gt 0) {
    Write-Output '--- WARNINGS ---'
    foreach ($w in $warnings) {
        Write-Output ('  [' + $w.Rule + '] ' + $w.Id + ' :: ' + $w.Message)
    }
    Write-Output ''
}

Write-Output '--- Distribution ---'
Write-Output '  By board:'
foreach ($k in $boardCount.Keys | Sort-Object) {
    Write-Output ('    ' + $k + ': ' + $boardCount[$k])
}
Write-Output '  By qtype:'
foreach ($k in $qtypeCount.Keys | Sort-Object) {
    Write-Output ('    ' + $k + ': ' + $qtypeCount[$k])
}
Write-Output '  By answer.best:'
foreach ($k in $bestActionCount.Keys | Sort-Object) {
    Write-Output ('    ' + $k + ': ' + $bestActionCount[$k])
}
Write-Output '  By actionReason:'
foreach ($k in $reasonCount.Keys | Sort-Object) {
    Write-Output ('    ' + $k + ': ' + $reasonCount[$k])
}
Write-Output '  By auditStatus:'
foreach ($k in $auditStatusCount.Keys | Sort-Object) {
    Write-Output ('    ' + $k + ': ' + $auditStatusCount[$k])
}
Write-Output '  By reviewStatus:'
foreach ($k in $reviewStatusCount.Keys | Sort-Object) {
    Write-Output ('    ' + $k + ': ' + $reviewStatusCount[$k])
}
Write-Output ('  Scenarios missing defenseLogic: ' + $missingDefenseLogicCount)
Write-Output ''
Write-Output '============================================================'
if ($hardErrors.Count -eq 0) {
    if ($warnings.Count -eq 0) {
        Write-Output ' RESULT: PASS (clean)'
    } else {
        Write-Output (' RESULT: PASS (' + $warnings.Count + ' warnings)')
    }
    exit 0
} else {
    Write-Output (' RESULT: FAIL (' + $hardErrors.Count + ' hard errors)')
    exit 1
}
