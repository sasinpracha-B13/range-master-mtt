# tools/range-builder.ps1
# Shared helpers for ranges.json patch scripts.
#
# USAGE in a patch script:
#   . "$PSScriptRoot\tools\range-builder.ps1"
#   $scen = Build-Scenario -stack 40 -position 'BB' -action 'vs_raise_co' ...
#   Add-NewScenario -Json $json -Key '40BB_BB_vs_raise_co' -Scenario $scen
#   Replace-Scenario -Json $json -Key '20BB_BB_vs_raise_co' -Scenario $newScen
#
# Why this exists: v1.5.3 had a key collision -- it called Add-Member -Force on
# 20BB_BB_vs_raise_co which had been added in v1.5.1. The result was a silent
# overwrite that we only caught later via scenario count. The Add-NewScenario
# helper THROWS on duplicate keys; Replace-Scenario THROWS when the key is
# missing. This forces every patch script to declare intent explicitly.

# ---------- Hand universe ---------------------------------------------------
$script:RANKS = @('2','3','4','5','6','7','8','9','T','J','Q','K','A')
$script:ALL_HANDS = @()
foreach ($r in $script:RANKS) { $script:ALL_HANDS += ($r + $r) }
for ($i = 12; $i -gt 0; $i--) {
    for ($j = $i - 1; $j -ge 0; $j--) {
        $script:ALL_HANDS += ($script:RANKS[$i] + $script:RANKS[$j] + 's')
    }
}
for ($i = 12; $i -gt 0; $i--) {
    for ($j = $i - 1; $j -ge 0; $j--) {
        $script:ALL_HANDS += ($script:RANKS[$i] + $script:RANKS[$j] + 'o')
    }
}

# ---------- Token expansion (e.g. "TT+", "AJs-A8s", "22-77") ---------------
function Expand-Token {
    param([string]$tok)
    $tok = $tok.Trim()
    if (!$tok) { return @() }
    if ($tok -match '^([2-9TJQKA])([2-9TJQKA])\+$' -and $matches[1] -eq $matches[2]) {
        $idx = $script:RANKS.IndexOf($matches[1])
        return ($idx..12) | ForEach-Object { $script:RANKS[$_] + $script:RANKS[$_] }
    }
    if ($tok -match '^([2-9TJQKA])([2-9TJQKA])$' -and $matches[1] -eq $matches[2]) { return @($tok) }
    if ($tok -match '^([2-9TJQKA])\1-([2-9TJQKA])\2$') {
        $hi=$script:RANKS.IndexOf($matches[1]); $lo=$script:RANKS.IndexOf($matches[2])
        if ($hi -lt $lo) { $t=$hi; $hi=$lo; $lo=$t }
        return ($lo..$hi) | ForEach-Object { $script:RANKS[$_] + $script:RANKS[$_] }
    }
    if ($tok -match '^([2-9TJQKA])([2-9TJQKA])(s|o)\+$') {
        $high=$matches[1]; $low=$matches[2]; $type=$matches[3]
        $hi=$script:RANKS.IndexOf($high); $lo=$script:RANKS.IndexOf($low)
        if ($hi -le $lo) { return @() }
        return ($lo..($hi-1)) | ForEach-Object { $high + $script:RANKS[$_] + $type }
    }
    if ($tok -match '^([2-9TJQKA])([2-9TJQKA])(s|o)-([2-9TJQKA])([2-9TJQKA])(s|o)$') {
        $h1=$matches[1]; $l1=$matches[2]; $t1=$matches[3]; $h2=$matches[4]; $l2=$matches[5]; $t2=$matches[6]
        if ($h1 -ne $h2 -or $t1 -ne $t2) { return @() }
        $lo_a=$script:RANKS.IndexOf($l1); $lo_b=$script:RANKS.IndexOf($l2)
        if ($lo_a -lt $lo_b) { $t=$lo_a; $lo_a=$lo_b; $lo_b=$t }
        return ($lo_b..$lo_a) | ForEach-Object { $h1 + $script:RANKS[$_] + $t1 }
    }
    if ($tok -match '^([2-9TJQKA])([2-9TJQKA])(s|o)$') { return @($tok) }
    return @()
}

function Parse-Range {
    param([string]$rangeStr)
    $hands = [System.Collections.Generic.HashSet[string]]::new()
    if (-not [string]::IsNullOrWhiteSpace($rangeStr)) {
        foreach ($tok in ($rangeStr -split ',')) {
            foreach ($h in (Expand-Token $tok)) { [void]$hands.Add($h) }
        }
    }
    return ,$hands
}

# ---------- Scenario builder -----------------------------------------------
function Build-Scenario {
    param(
        [int]$stack, [string]$position, [string]$action, [string]$notes,
        [string[]]$validActions, [hashtable]$pureRanges, [hashtable]$mix
    )
    $pureMap = @{}
    foreach ($actKey in $pureRanges.Keys) {
        $set = Parse-Range $pureRanges[$actKey]
        foreach ($h in $set) { $pureMap[$h] = $actKey }
    }
    $hands = [ordered]@{}
    $counts = @{}
    foreach ($v in $validActions) { $counts[$v] = 0.0 }
    foreach ($h in $script:ALL_HANDS) {
        $entry = [ordered]@{}
        foreach ($v in $validActions) { $entry[$v] = 0.0 }
        if ($mix -and $mix.ContainsKey($h)) {
            $m = $mix[$h]; $sum = 0.0
            foreach ($k in $m.Keys) {
                if ($entry.Contains($k)) { $entry[$k] = [double]$m[$k]; $sum += [double]$m[$k] }
            }
            if ($sum -lt 0.999 -and $entry.Contains('fold')) { $entry['fold'] += (1.0 - $sum) }
            elseif ($sum -lt 0.999 -and $entry.Contains('check')) { $entry['check'] += (1.0 - $sum) }
        } elseif ($pureMap.ContainsKey($h)) {
            $entry[$pureMap[$h]] = 1.0
        } else {
            if ($entry.Contains('fold')) { $entry['fold'] = 1.0 }
            elseif ($entry.Contains('check')) { $entry['check'] = 1.0 }
        }
        foreach ($v in $validActions) { $counts[$v] += $entry[$v] }
        $hands[$h] = $entry
    }
    # Continue% counts anything not the passive default (fold OR check).
    $passive = 0.0
    foreach ($v in $validActions) { if ($v -eq 'fold' -or $v -eq 'check') { $passive += $counts[$v] } }
    $cont = 169.0 - $passive
    $pct = [math]::Round(100.0 * $cont / 169, 1)
    return [ordered]@{
        stack = $stack; position = $position; action = $action; notes = $notes
        valid_actions = $validActions; target_percentage = $pct
        hand_count = [int][math]::Round($cont); hands = $hands
    }
}

function Convert-ScenarioToObject {
    param([hashtable]$scen)
    $obj = [PSCustomObject]$scen
    $handsDict = [ordered]@{}
    foreach ($h in $scen.hands.Keys) { $handsDict[$h] = [PSCustomObject]$scen.hands[$h] }
    $obj.hands = [PSCustomObject]$handsDict
    return $obj
}

# ---------- Collision-guarded JSON mutation ---------------------------------
# THROW on duplicate. Use this for genuinely new scenarios.
function Add-NewScenario {
    param(
        [Parameter(Mandatory=$true)][PSCustomObject]$Json,
        [Parameter(Mandatory=$true)][string]$Key,
        [Parameter(Mandatory=$true)][hashtable]$Scenario
    )
    $existing = $Json.PSObject.Properties.Name
    if ($existing -contains $Key) {
        throw "Add-NewScenario: key '$Key' already exists. Use Replace-Scenario if intentional."
    }
    $Json | Add-Member -MemberType NoteProperty -Name $Key -Value (Convert-ScenarioToObject $Scenario)
}

# THROW on missing. Use this for intentional rebuilds of existing scenarios.
function Replace-Scenario {
    param(
        [Parameter(Mandatory=$true)][PSCustomObject]$Json,
        [Parameter(Mandatory=$true)][string]$Key,
        [Parameter(Mandatory=$true)][hashtable]$Scenario
    )
    $existing = $Json.PSObject.Properties.Name
    if (-not ($existing -contains $Key)) {
        throw "Replace-Scenario: key '$Key' does not exist. Use Add-NewScenario for genuinely new scenarios."
    }
    $Json.$Key = Convert-ScenarioToObject $Scenario
}

# ---------- IO helpers ------------------------------------------------------
function Load-Ranges {
    param([string]$Path = 'ranges.json')
    return Get-Content $Path -Raw | ConvertFrom-Json
}

function Save-Ranges {
    param(
        [Parameter(Mandatory=$true)][PSCustomObject]$Json,
        [string]$Path = 'ranges.json',
        [string]$Version,
        [string]$LastUpdated
    )
    if ($Version) { $Json.version = $Version }
    if ($LastUpdated) { $Json.last_updated = $LastUpdated }
    $out = $Json | ConvertTo-Json -Depth 10
    Set-Content -Path $Path -Value $out -Encoding UTF8
}
