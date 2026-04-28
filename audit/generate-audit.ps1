# audit/generate-audit.ps1
# Produce two audit-friendly views of ranges.json:
#   audit/ranges-summary.md  -- per-scenario digest (continue%, mix counts,
#                              pure ranges, top mixed hands)
#   audit/ranges-flat.csv    -- one row per (scenario, hand), columns are
#                              freqs per action -- for spreadsheet audit
#
# Both outputs are gitignored (see audit/.gitignore). They're regenerated
# fresh from ranges.json on demand:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\audit\generate-audit.ps1

# Resolve project root (one level up from this script).
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$j = Get-Content ranges.json -Raw | ConvertFrom-Json
$keys = $j.PSObject.Properties.Name | Where-Object { $_ -notin 'version','last_updated' } | Sort-Object {
    $s = $j.$_
    "{0:D3}_{1}_{2}" -f $s.stack, $s.position, $s.action
}

# ---- CSV (flat) ----------------------------------------------------------
$ALL_ACTIONS = @('fold','call','check','limp','raise','threebet','fourbet','shove')
$csv = New-Object System.Collections.Generic.List[string]
$csv.Add(("scenario,stack,position,action,hand," + ($ALL_ACTIONS -join ',') + ",max_freq,is_mixed"))

foreach ($k in $keys) {
    $s = $j.$k
    $hands = $s.hands.PSObject.Properties.Name
    foreach ($h in $hands) {
        $f = $s.hands.$h
        $row = @($k, $s.stack, $s.position, $s.action, $h)
        $vals = @()
        $maxF = 0.0
        foreach ($a in $ALL_ACTIONS) {
            $v = if ($f.PSObject.Properties.Name -contains $a) { [double]$f.$a } else { 0.0 }
            $vals += ("{0:F2}" -f $v)
            if ($v -gt $maxF) { $maxF = $v }
        }
        $row += $vals
        $row += ("{0:F2}" -f $maxF)
        $row += $(if ($maxF -lt 0.95) { 'TRUE' } else { 'FALSE' })
        $csv.Add(($row -join ','))
    }
}
Set-Content -Path 'audit/ranges-flat.csv' -Value ($csv -join "`n") -Encoding UTF8
Write-Host "Wrote audit/ranges-flat.csv ($($csv.Count - 1) rows)"

# ---- Markdown summary ----------------------------------------------------
$md = New-Object System.Collections.Generic.List[string]
$md.Add("# Range Audit -- ranges.json v$($j.version)")
$md.Add("")
$md.Add("- Last updated: $($j.last_updated)")
$md.Add("- Total scenarios: $($keys.Count)")
$md.Add("- Generated: $((Get-Date).ToString('yyyy-MM-dd HH:mm'))")
$md.Add("")
$md.Add("## Continue% matrix")
$md.Add("")
$md.Add("| Stack | Position | Action | Continue% | Hands | Actions |")
$md.Add("|---|---|---|---:|---:|---|")
foreach ($k in $keys) {
    $s = $j.$k
    $md.Add("| $($s.stack)BB | $($s.position) | $($s.action) | $($s.target_percentage)% | $($s.hand_count) | $($s.valid_actions -join '/') |")
}
$md.Add("")
$md.Add("---")
$md.Add("")
$md.Add("## Per-scenario detail")
$md.Add("")

foreach ($k in $keys) {
    $s = $j.$k
    $md.Add("### $k")
    $md.Add("")
    $md.Add("**Stack** $($s.stack)BB · **Position** $($s.position) · **Action** $($s.action)")
    $md.Add("")
    $md.Add("**Continue%** $($s.target_percentage) · **Hands** $($s.hand_count) · **Valid actions** $($s.valid_actions -join ', ')")
    $md.Add("")
    if ($s.notes) { $md.Add("> $($s.notes)"); $md.Add("") }

    # Bucket each hand by primary action and pure/mixed
    $byAction = @{}
    foreach ($a in $ALL_ACTIONS) { $byAction[$a] = @() }
    $mixedHands = @()
    $hands = $s.hands.PSObject.Properties.Name
    foreach ($h in $hands) {
        $f = $s.hands.$h
        $best = 'fold'; $bestV = 0.0; $maxV = 0.0
        foreach ($a in $ALL_ACTIONS) {
            $v = if ($f.PSObject.Properties.Name -contains $a) { [double]$f.$a } else { 0.0 }
            if ($v -gt $bestV) { $bestV = $v; $best = $a }
            if ($v -gt $maxV) { $maxV = $v }
        }
        if ($maxV -ge 0.95) {
            if ($best -ne 'fold' -and $best -ne 'check') { $byAction[$best] += $h }
        } else {
            # Build mix description
            $parts = @()
            foreach ($a in $ALL_ACTIONS) {
                $v = if ($f.PSObject.Properties.Name -contains $a) { [double]$f.$a } else { 0.0 }
                if ($v -gt 0) { $parts += ("{0} {1}%" -f $a, [int]([math]::Round($v * 100))) }
            }
            $mixedHands += ("- {0,-4} -> {1}" -f $h, ($parts -join ' / '))
        }
    }

    foreach ($a in $ALL_ACTIONS) {
        if ($a -eq 'fold' -or $a -eq 'check') { continue }
        if ($byAction[$a].Count -gt 0) {
            $md.Add("**Pure $a** ($($byAction[$a].Count) hands): " + (($byAction[$a] | Sort-Object) -join ', '))
            $md.Add("")
        }
    }
    if ($mixedHands.Count -gt 0) {
        $md.Add("**Mixed hands** ($($mixedHands.Count)):")
        $md.Add("")
        # Limit to 60 to keep readable; tell user if truncated
        $shown = if ($mixedHands.Count -gt 60) { $mixedHands[0..59] } else { $mixedHands }
        foreach ($line in $shown) { $md.Add($line) }
        if ($mixedHands.Count -gt 60) {
            $md.Add("- _(... $($mixedHands.Count - 60) more -- see CSV for full list)_")
        }
        $md.Add("")
    }
    $md.Add("---")
    $md.Add("")
}

Set-Content -Path 'audit/ranges-summary.md' -Value ($md -join "`n") -Encoding UTF8
Write-Host "Wrote audit/ranges-summary.md"

# ---- Quick monotonicity sanity check -------------------------------------
Write-Host ""
Write-Host "=== Monotonicity check ==="
Write-Host "BB defense by stack and opener position (continue%):"
$bbDef = $keys | Where-Object {
    $s = $j.$_
    $s.position -eq 'BB' -and $s.action -like 'vs_raise*'
} | ForEach-Object {
    [PSCustomObject]@{
        Stack = $j.$_.stack
        Opener = $j.$_.action -replace 'vs_raise_',''
        Cont = $j.$_.target_percentage
    }
}

$pivot = @{}
foreach ($r in $bbDef) {
    if (-not $pivot.ContainsKey($r.Stack)) { $pivot[$r.Stack] = @{} }
    $pivot[$r.Stack][$r.Opener] = $r.Cont
}
$openers = @('lj','hj','co','btn','sb')
$line = "  Stack |"
foreach ($o in $openers) { $line += (" {0,5} |" -f $o) }
Write-Host $line
Write-Host ("        +" + ("-" * 8 + "+") * $openers.Count)
foreach ($st in ($pivot.Keys | Sort-Object)) {
    $line = "  {0,4}BB |" -f $st
    foreach ($o in $openers) {
        if ($pivot[$st].ContainsKey($o)) {
            $line += (" {0,5} |" -f $pivot[$st][$o])
        } else {
            $line += (" {0,5} |" -f '--')
        }
    }
    Write-Host $line
}
Write-Host ""
Write-Host "(should monotonically widen left -> right within each row: LJ < HJ < CO < BTN < SB)"
