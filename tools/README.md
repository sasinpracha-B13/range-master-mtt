# tools/

Shared scripts for working with `ranges.json`.

## `range-builder.ps1`

Helpers used by all `fix-*.ps1` patch scripts (which themselves are
gitignored — they're throwaway one-shot scripts per release).

### Why this is separated

In v1.5.3 a patch script accidentally overwrote a scenario added in v1.5.1
because both scripts had inline `Add-Member ... -Force`. The collision was
silent — only caught later by counting scenarios. To prevent recurrence:

- `Add-NewScenario` THROWS if the key already exists
- `Replace-Scenario` THROWS if the key does NOT exist

Every patch script must declare intent. No more `-Force`.

### Usage

In a patch script at repo root:

```powershell
. "$PSScriptRoot\tools\range-builder.ps1"

$json = Load-Ranges                          # reads ranges.json
$scen = Build-Scenario -stack 40 ...         # build hashtable
Add-NewScenario -Json $json -Key '40BB_SB_RFI' -Scenario $scen
Replace-Scenario -Json $json -Key '20BB_BB_vs_raise_btn' -Scenario $scen
Save-Ranges -Json $json -Version '1.5.6' -LastUpdated '2026-04-29'
```

### Run from project root

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\fix-something.ps1
```
