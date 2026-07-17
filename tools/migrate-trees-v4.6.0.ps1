# migrate-trees-v4.6.0.ps1 -- G6: publish line-reviewed trees to the runtime.
# Copies docs/specs/game-g6-v4.6.0-tree-seeds.json -> postflop/postflop_trees.json
# with auditStatus review_pending -> approved + reviewStatus flip.
# postflop_scenarios.json is NEVER touched. Idempotent. UTF-8 no-BOM atomic.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$seedPath = Join-Path $root 'docs\specs\game-g6-v4.6.0-tree-seeds.json'
$outPath  = Join-Path $root 'postflop\postflop_trees.json'
$utf8 = [System.Text.UTF8Encoding]::new($false)

$doc = [System.IO.File]::ReadAllText($seedPath, $utf8) | ConvertFrom-Json
if (@($doc.trees).Count -ne 3) { throw ('ABORT: expected 3 trees, found ' + @($doc.trees).Count) }
$nodeCount = (@($doc.trees) | ForEach-Object { @($_.nodes).Count } | Measure-Object -Sum).Sum
if ($nodeCount -ne 12) { throw ('ABORT: expected 12 nodes, found ' + $nodeCount) }
foreach ($t in $doc.trees) {
  if ($t.auditStatus -notin @('review_pending','approved')) { throw ('ABORT: bad auditStatus on ' + $t.id) }
  $t.auditStatus = 'approved'
  $t.reviewStatus = 'v4.6.0_line_reviewed'
}
$doc.description = 'G6 v4.6.0 Continuous Hand -- 3 owner-line-reviewed hand-trees (12 nodes), RUNTIME data. Read-only; loaded by index.html alongside the scenario corpus. Source of truth: tools/build-trees-v4.6.0.ps1; auditor: tools/audit-postflop-trees.ps1 (T.R01-T.R19).'
$json = $doc | ConvertTo-Json -Depth 14
$check = $json | ConvertFrom-Json
if (@($check.trees).Count -ne 3) { throw 'ABORT: post-serialize verify failed' }
foreach ($t in $check.trees) { if ($t.auditStatus -ne 'approved') { throw ('ABORT: flip failed on ' + $t.id) } }
$tmp = $outPath + '.tmp'
[System.IO.File]::WriteAllText($tmp, $json, $utf8)
Move-Item -Force $tmp $outPath
Write-Output ('PUBLISHED ' + $outPath + ' trees=3 nodes=12 (approved, v4.6.0_line_reviewed)')
