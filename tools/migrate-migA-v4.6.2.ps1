# migrate-migA-v4.6.2.ps1 -- THE single Migration A (v4.6.2) script.
# Order (owner-approved at the item-4 spec + A1/A2 gates):
#   assert start blob -> replace 5 M4 rework rows (2 leg-(a) AQo hero swaps +
#   1 leg-(b) suit fix + 2 EV-REDERIVE) -> append 2 M6 P3-pair rows ->
#   annotate 14 WL rows with solver status -> apostrophe fix (1 M3 row) ->
#   index.html: WL withdraw 2 + dated comment + M6 copy 32->34 (7 spots) ->
#   SW cache v4.6.1->v4.6.2.
# P2 RE-PARKED (A2 ruling) -> M6 = 34 not 35; corpus 542 -> 544.
# DRY-RUN by default: writes migrated corpus + patched index/sw to scratch and
# stages the validator + the converted arrival regression lint there.
# -Apply performs the real writes (only after owner confirms the dry-run).
# Zero-drift proof: per-row compressed-JSON compare vs an explicit manifest.

param([switch]$Apply)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = [System.Text.UTF8Encoding]::new($false)
$prodPath = Join-Path $root 'postflop\postflop_scenarios.json'
$seedPath = Join-Path $root 'docs\specs\postflop-v4.6.2-migA-rework-seeds.json'
$m6Path   = Join-Path $root 'docs\specs\postflop-v4.6.2-migA-m6-seeds.json'
$idxPath  = Join-Path $root 'index.html'
$swPath   = Join-Path $root 'service-worker.js'
$scratch  = 'C:\Users\PC\AppData\Local\Temp\claude\C--Users-PC-Desktop-BAY-TD-range-master-mtt\0a681972-9fa1-48cc-93b2-4d63851846d8\scratchpad\migA'

$START_BLOB = '87df6d9c4bfa2a576ad638fef09359ec085912b7'
$PFX = 'pf_btn_v_bb_srp_100bb_'
$CD = [char]0x00B7  # middot in index.html copy

# ---- 0. assert start state ----
$blob = (& git -C $root hash-object 'postflop/postflop_scenarios.json').Trim()
if ($blob -ne $START_BLOB) { throw ('ABORT: corpus blob ' + $blob + ' != expected ' + $START_BLOB) }
Write-Output ('[0] start blob asserted: ' + $blob)

$prod = [System.IO.File]::ReadAllText($prodPath, $utf8) | ConvertFrom-Json
$seeds = ([System.IO.File]::ReadAllText($seedPath, $utf8) | ConvertFrom-Json).reworks
$m6seeds = ([System.IO.File]::ReadAllText($m6Path, $utf8) | ConvertFrom-Json).reworks
if (@($prod.scenarios).Count -ne 542) { throw 'ABORT: pre-count != 542' }
if (@($seeds).Count -ne 5) { throw ('ABORT: rework seeds != 5, got ' + @($seeds).Count) }
if (@($m6seeds).Count -ne 2) { throw ('ABORT: M6 seeds != 2, got ' + @($m6seeds).Count) }

$before = @{}
foreach ($s in $prod.scenarios) { $before[$s.id] = ($s | ConvertTo-Json -Depth 12 -Compress) }

# ---- 1. replace the 5 M4 rework rows (positional; strip seed fields; flip status) ----
$replacedOld = @()
$newIds = @()
$scen = [System.Collections.ArrayList]@($prod.scenarios)
foreach ($seed in $seeds) {
  $oldId = $seed.replaces
  if (-not $oldId) { throw ('ABORT: seed missing replaces: ' + $seed.id) }
  $idx = -1
  for ($i = 0; $i -lt $scen.Count; $i++) { if ($scen[$i].id -eq $oldId) { $idx = $i; break } }
  if ($idx -lt 0) { throw ('ABORT: replaced row not found in production: ' + $oldId) }
  if ($before.ContainsKey($seed.id)) { throw ('ABORT: new id already exists: ' + $seed.id) }
  $new = $seed | ConvertTo-Json -Depth 12 | ConvertFrom-Json
  $new.PSObject.Properties.Remove('replaces')
  $new.PSObject.Properties.Remove('reworkClass')
  $new.auditStatus = 'approved'
  $new.reviewStatus = 'v4.6.2_strategic_reviewed'
  $scen[$idx] = $new
  $replacedOld += $oldId
  $newIds += $new.id
}
Write-Output ('[1] replaced M4 rows: ' + $newIds.Count + ' (2x leg-(a) AQo->KhQd/QhJh, 1x leg-(b) Tc9c->Td9d, 2x EV-REDERIVE 9c9d/8d8c best=call)')

# ---- 2. append the 2 M6 P3-pair rows (end of array = end of M6 block) ----
foreach ($seed in $m6seeds) {
  if ($before.ContainsKey($seed.id)) { throw ('ABORT: M6 id already exists: ' + $seed.id) }
  $new = $seed | ConvertTo-Json -Depth 12 | ConvertFrom-Json
  $new.auditStatus = 'approved'
  $new.reviewStatus = 'v4.6.2_strategic_reviewed'
  [void]$scen.Add($new)
  $newIds += $new.id
}
$prod.scenarios = $scen.ToArray()
Write-Output '[2] appended M6 rows: 2 (P3 suit-selection pair QsJs/QhJh on Ts6s2d-3c-Ad)'

# ---- 3. annotate the 14 surviving WL rows with solver status ----
$SREF_KHQD = 'GTO Wizard MTTGeneral_8m ChipEV 100bb, 2026-07-21, board Jh8h4h, line flop X-R2.1 (exact 32 percent node)'
$NOTE_KHQD = 'Phase-2 WL sweep 2026-07-21: mix CONFIRMED at the exact corpus node - Bet2.1 68.2 / Check 31.8. First solver-verified indifference in the corpus; WL entry stands.'
$NOTE_M6_TPL = 'Phase-2 WL sweep 2026-07-21: direction half-confirmed - solver bets 100 at the library single size (75 percent); the {0} size claim is unverifiable-at-line (library sizing). No rework per owner ruling (direction-only annotation); first in queue when a pricing-capable line exists.'
$NOTE_UNVER = 'Phase-2 WL sweep 2026-07-21: unverifiable-at-line (library sizing) - the corpus line cannot be priced in the MTT General library tree. PASS-conditional on combo logic per owner ruling (no contagion assumption); first in queue when a pricing-capable line exists.'

$ANNOT = @(
  @{ id = 'flop_Jh8h4h_m2_action_KhQd_v412';      kind = 'confirmed' },
  @{ id = 'river_Ac7d4s_2c_m6_action_AhJh_v451';  kind = 'm6'; size = 'bet_small' },
  @{ id = 'river_Th7d2s_2h_m6_action_TsTc_v451';  kind = 'm6'; size = 'overbet' },
  @{ id = 'turn_9s8d4c_7h_m4_action_JcJh_v461';   kind = 'unver' },
  @{ id = 'turn_JdTd5s_2c_m4_action_9c9d_v430C';  kind = 'unver' },
  @{ id = 'turn_Ah9d4d_7h_m4_reason_TdTs_v430D';  kind = 'unver' },
  @{ id = 'turn_7s5d3h_4c_m4_reason_JhJd_v461';   kind = 'unver' },
  @{ id = 'turn_7s5d3h_4c_m4_action_JsTs_v432';   kind = 'unver' },
  @{ id = 'river_Js8d5c_Ac_m5_action_AdTh_v440';  kind = 'unver' },
  @{ id = 'river_Ad8s5c_Kd_m5_reason_AhJc_v440';  kind = 'unver' },
  @{ id = 'river_Kh9h5c_2h_m5_action_KcTd_v441a'; kind = 'unver' },
  @{ id = 'river_Jc9d8s_2c_m5_reason_Th9h_v441c'; kind = 'unver' },
  @{ id = 'river_Qd7c4h_2d_m6_action_AhTd_v451';  kind = 'unver' },
  @{ id = 'river_AhJd6s_7h_m6_action_AsKs_v451';  kind = 'unver' }
)
$annotIds = @()
foreach ($a in $ANNOT) {
  $row = $prod.scenarios | Where-Object { $_.id -eq ($PFX + $a.id) } | Select-Object -First 1
  if (-not $row) { throw ('ABORT: annotation row missing: ' + $a.id) }
  if ($a.kind -eq 'confirmed') {
    $row.sourceConfidence = 'consensus_gto'
    $row | Add-Member -NotePropertyName solverRunRef -NotePropertyValue $SREF_KHQD -Force
    $row | Add-Member -NotePropertyName solverNote -NotePropertyValue $NOTE_KHQD -Force
  } elseif ($a.kind -eq 'm6') {
    $row | Add-Member -NotePropertyName solverNote -NotePropertyValue ($NOTE_M6_TPL -f $a.size) -Force
  } else {
    $row | Add-Member -NotePropertyName solverNote -NotePropertyValue $NOTE_UNVER -Force
  }
  $annotIds += $row.id
}
Write-Output ('[3] annotated rows: ' + $annotIds.Count + ' (1 confirmed consensus_gto + 2 M6 direction-only + 11 unverifiable-at-line)')

# ---- 4. apostrophe cosmetics (the banked M3 v423a residue: 1 row, 2 strings) ----
$apRow = $prod.scenarios | Where-Object { $_.id -eq ($PFX + 'flop_KhJh4h_m3_action_Th9d_v423b') } | Select-Object -First 1
if (-not $apRow) { throw 'ABORT: apostrophe row missing' }
if ($apRow.explanation.handLogic -notmatch 'doesnt pair') { throw 'ABORT: handLogic doesnt-string not found' }
if ($apRow.explanation.sizingLogic -notmatch 'that wont fold') { throw 'ABORT: sizingLogic wont-string not found' }
$apRow.explanation.handLogic = $apRow.explanation.handLogic.Replace('doesnt pair', "doesn't pair")
$apRow.explanation.sizingLogic = $apRow.explanation.sizingLogic.Replace('that wont fold', "that won't fold")
$apId = $apRow.id
Write-Output '[4] apostrophe fix: 1 row (Th9d_v423b), 2 strings (doesnt/wont)'

# ---- 5. post-state asserts ----
if (@($prod.scenarios).Count -ne 544) { throw 'ABORT: post-count != 544' }
$census = @{}
foreach ($s in $prod.scenarios) { if (-not $census[$s.module]) { $census[$s.module] = 0 }; $census[$s.module]++ }
$EXPECT_CENSUS = @{ 'pf_board_texture'=251; 'pf_flop_cbet_ip'=49; 'pf_flop_cbet_oop_def'=85; 'pf_turn_barrel_oop_def'=92; 'pf_river_barrel_oop_def'=33; 'pf_river_value_ip'=34 }
foreach ($k in $EXPECT_CENSUS.Keys) { if ($census[$k] -ne $EXPECT_CENSUS[$k]) { throw ('ABORT: module census ' + $k + '=' + $census[$k] + ' != ' + $EXPECT_CENSUS[$k]) } }
$idSeen = @{}
foreach ($s in $prod.scenarios) {
  if ($idSeen[$s.id]) { throw ('ABORT: duplicate id ' + $s.id) }
  $idSeen[$s.id] = $true
  if ($s.PSObject.Properties['replaces'] -or $s.PSObject.Properties['reworkClass']) { throw ('ABORT: seed field leaked into ' + $s.id) }
}
foreach ($s in $prod.scenarios) {
  if ($s.module -ne 'pf_turn_barrel_oop_def' -and $s.module -ne 'pf_river_value_ip') { continue }
  $all = @($s.answer.best) + @($s.answer.acceptable) + @($s.answer.bad) + @($s.answer.critical)
  if ($all.Count -ne ($all | Select-Object -Unique).Count) { throw ('ABORT: tier overlap in ' + $s.id) }
  # full-coverage equality only for action rows; reason rows use the house
  # coverage allowance (R107 family) -- the scratch validator is the authority.
  if ($s.question.qtype -eq 'action_choice' -and (($all | Sort-Object) -join ',') -ne ((@($s.question.choices) | Sort-Object) -join ',')) { throw ('ABORT: partition incomplete in ' + $s.id) }
}
foreach ($ev in @('turn_Ac7d2s_4h_m4_action_9c9d_v462','turn_Qs7d3c_3h_m4_action_8d8c_v462')) {
  $r = $prod.scenarios | Where-Object { $_.id -eq ($PFX + $ev) } | Select-Object -First 1
  if ($r.recommendedAction -ne 'call' -or $r.answer.best -ne 'call') { throw ('ABORT: EV-REDERIVE row not best=call: ' + $ev) }
}
Write-Output '[5] post asserts: 544 rows, census 251/49/85/92/33/34, ids unique, M4+M6 exact-partition, EV rows best=call'

# ---- 6. changed-manifest equality (zero drift outside) ----
$changed = @(); $added = @()
foreach ($s in $prod.scenarios) {
  if (-not $before.ContainsKey($s.id)) { $added += $s.id; continue }
  if ($before[$s.id] -ne ($s | ConvertTo-Json -Depth 12 -Compress)) { $changed += $s.id }
}
$removed = @($before.Keys | Where-Object { -not $idSeen[$_] })
$expAdded = @($newIds)                      # 5 replacements + 2 M6 = 7 new ids
$expChanged = @($annotIds) + @($apId)       # 14 annotations + 1 apostrophe = 15
$expRemoved = @($replacedOld)               # 5 old ids
if ((($added | Sort-Object) -join ';') -ne (($expAdded | Sort-Object) -join ';')) { throw ('ABORT: added-id manifest mismatch: ' + (($added | Sort-Object) -join ', ')) }
if ((($changed | Sort-Object) -join ';') -ne (($expChanged | Sort-Object) -join ';')) { throw ('ABORT: changed-id manifest mismatch: ' + (($changed | Sort-Object) -join ', ')) }
if ((($removed | Sort-Object) -join ';') -ne (($expRemoved | Sort-Object) -join ';')) { throw ('ABORT: removed-id manifest mismatch: ' + (($removed | Sort-Object) -join ', ')) }
Write-Output ('[6] manifest equality: +' + $added.Count + ' new (5 replacements + 2 M6), ~' + $changed.Count + ' modified (14 annotations + 1 apostrophe), -' + $removed.Count + ' removed (old rework ids). Zero drift outside.')

# ---- 7. top-level meta ----
$prod.generatedAt = '2026-07-22'
$prod.description = 'v4.6.2 - Migration A solver outcomes. Total 544 scenarios: 251 M1 + 49 M2 + 85 M3 + 92 M4 + 33 M5 + 34 M6. M4: 5 solver-driven reworks under the locked arrival baseline extended by the V3 AQo non-member closure (2 leg-(a) hero swaps AhQc->KhQd/QhJh, 1 leg-(b) suit fix Tc9c->Td9d, 2 EV-REDERIVE rows 9c9d/8d8c re-authored best=call per the EV-lens ruling; their mixed-whitelist entries withdrawn). M6: +2 suit-selection pair rows on Ts6s2d-3c-Ad (QsJs check_back vs QhJh overbet, consensus_gto + solverRunRef). 14 whitelist rows annotated with Phase-2 solver evidence status. Spot context: BTN open 2.5x vs BB call, 100BB SRP, NLH MTT chipEV.'

# ---- 8. index.html: WL withdraw 2 + dated comment + M6 copy sweep 32->34 ----
$idxTxt = [System.IO.File]::ReadAllText($idxPath, $utf8)
$WL_REMOVE = @(
  'pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_9c9d_v430C',
  'pf_btn_v_bb_srp_100bb_turn_Qs7d3c_3h_m4_action_8d8c_v432'
)
foreach ($id in $WL_REMOVE) {
  $n = ([regex]::Matches($idxTxt, [regex]::Escape($id))).Count
  if ($n -ne 1) { throw ('ABORT: WL id ' + $id + ' occurrence count ' + $n + ' != 1') }
  $lineRx = "(?m)^[ \t]*'" + [regex]::Escape($id) + "'[^\r\n]*\r?\n"
  if (([regex]::Matches($idxTxt, $lineRx)).Count -ne 1) { throw ('ABORT: WL line pattern not found for ' + $id) }
  $idxTxt = [regex]::Replace($idxTxt, $lineRx, '')
  if (([regex]::Matches($idxTxt, [regex]::Escape($id))).Count -ne 0) { throw ('ABORT: WL id survives removal: ' + $id) }
}
foreach ($evNew in @('pf_btn_v_bb_srp_100bb_turn_Ac7d2s_4h_m4_action_9c9d_v462','pf_btn_v_bb_srp_100bb_turn_Qs7d3c_3h_m4_action_8d8c_v462')) {
  if ($idxTxt.Contains($evNew)) { throw ('ABORT: EV-REDERIVE new id must NOT be whitelisted: ' + $evNew) }
}
$khqdLine = "  'pf_btn_v_bb_srp_100bb_flop_Jh8h4h_m2_action_KhQd_v412':      ['mixed', 'bet_small', 'check'],"
if (([regex]::Matches($idxTxt, [regex]::Escape($khqdLine))).Count -ne 1) { throw 'ABORT: KhQd WL anchor line not found exactly once' }
$wlComment = @(
  "  // v4.6.2 EV-lens (owner ruling 2026-07-21): the M4 9c9d_v430C and 8d8c_v432",
  "  // entries are WITHDRAWN - solver EV shows call is clear value (+1.87bb /",
  "  // +2.63bb vs fold), not indifference; both rows re-authored as _v462 best=call.",
  "  // Surviving-row solver statuses recorded in-row (solverNote); KhQd mix is",
  "  // solver-CONFIRMED (consensus_gto)."
) -join "`n"
$idxTxt = $idxTxt.Replace($khqdLine, $khqdLine + "`n" + $wlComment)

$copySwaps = @(
  @{ old = '32 approved (24 v4.5.1 + 8 v4.5.2A).'; new = '34 approved (24 v4.5.1 + 8 v4.5.2A + 2 v4.6.2).' },
  @{ old = '32 approved bettor-side river scenarios'; new = '34 approved bettor-side river scenarios' },
  # line-wrapped comment (38672): phrase breaks at 'river' -- runs AFTER the
  # full-phrase swap above so exactly one occurrence remains
  @{ old = '32 approved bettor-side river'; new = '34 approved bettor-side river' },
  @{ old = '32 approved scenarios).'; new = '34 approved scenarios).' },
  @{ old = '32 approved scenarios. Honest'; new = '34 approved scenarios. Honest' },
  @{ old = '32 bettor-side river scenarios'; new = '34 bettor-side river scenarios' },
  @{ old = '32 scenarios.</strong>'; new = '34 scenarios.</strong>' },
  @{ old = ($CD + ' 32 scenarios ' + $CD + ' ALL'); new = ($CD + ' 34 scenarios ' + $CD + ' ALL') },
  @{ old = ($CD + ' 32 scenarios ' + $CD + ' more'); new = ($CD + ' 34 scenarios ' + $CD + ' more') },
  # curriculum-panel numeric field (in-app QA catch: rendered as "N scenarios"
  # at the mod-detail line; m6 is the only scenarioCount 32 in the file)
  @{ old = 'scenarioCount: 32,'; new = 'scenarioCount: 34,' },
  # RIDER (owner-approved at the commit gate): the two stale sibling counts in
  # the same curriculum array -- m2 true count 49, m4 true count 92 (the same
  # debt's remnant the v4.6.1 72->92 About sweep missed). Values 35/72 are
  # unique in the file (count-asserted like every swap).
  @{ old = 'scenarioCount: 35,'; new = 'scenarioCount: 49,' },
  @{ old = 'scenarioCount: 72,'; new = 'scenarioCount: 92,' }
)
foreach ($c in $copySwaps) {
  $n = ([regex]::Matches($idxTxt, [regex]::Escape($c.old))).Count
  if ($n -ne 1) { throw ('ABORT: M6 copy string "' + $c.old + '" occurrence count ' + $n + ' != 1') }
  $idxTxt = $idxTxt.Replace($c.old, $c.new)
}
foreach ($res in @('32 approved', '32 bettor-side', ' 32 scenarios')) {
  if (([regex]::Matches($idxTxt, [regex]::Escape($res))).Count -ne 0) { throw ('ABORT: M6 copy residue "' + $res + '" survives') }
}
Write-Output '[8] index.html: 2 WL entries withdrawn + dated comment; M6 copy 32->34 at 10 spots (comments x4 incl. one line-wrapped, About, hub hint, boss-pool, masteryNote, progress title, curriculum scenarioCount) + rider m2 35->49 / m4 72->92; residue scan clean.'

# ---- 9. service-worker cache bump ----
$sw = [System.IO.File]::ReadAllText($swPath, $utf8)
$oldVer = "const VERSION = 'v4.6.1';"
if (([regex]::Matches($sw, [regex]::Escape($oldVer))).Count -ne 1) { throw 'ABORT: SW version marker not found exactly once' }
$sw = $sw.Replace($oldVer, "const VERSION = 'v4.6.2';")
Write-Output '[9] SW cache: v4.6.1 -> v4.6.2'

# ---- 10. serialize + write ----
$outJson = $prod | ConvertTo-Json -Depth 12
$check = $outJson | ConvertFrom-Json
if (@($check.scenarios).Count -ne 544) { throw 'ABORT: serialized count != 544' }

if ($Apply) {
  foreach ($t in @(@($prodPath, $outJson), @($idxPath, $idxTxt), @($swPath, $sw))) {
    $tmp = $t[0] + '.tmp'
    [System.IO.File]::WriteAllText($tmp, $t[1], $utf8)
    Move-Item -Force $tmp $t[0]
  }
  Write-Output 'APPLIED: production corpus + index.html + service-worker.js written.'
} else {
  New-Item -ItemType Directory -Force (Join-Path $scratch 'postflop') | Out-Null
  New-Item -ItemType Directory -Force (Join-Path $scratch 'tools') | Out-Null
  New-Item -ItemType Directory -Force (Join-Path $scratch 'docs\specs') | Out-Null
  [System.IO.File]::WriteAllText((Join-Path $scratch 'postflop\postflop_scenarios.json'), $outJson, $utf8)
  [System.IO.File]::WriteAllText((Join-Path $scratch 'index.html'), $idxTxt, $utf8)
  [System.IO.File]::WriteAllText((Join-Path $scratch 'service-worker.js'), $sw, $utf8)
  foreach ($f in (Get-ChildItem (Join-Path $root 'postflop') -Filter '*.json')) {
    if ($f.Name -ne 'postflop_scenarios.json') { Copy-Item $f.FullName (Join-Path $scratch ('postflop\' + $f.Name)) -Force }
  }
  Copy-Item (Join-Path $root 'tools\audit-postflop-ps.ps1') (Join-Path $scratch 'tools\audit-postflop-ps.ps1') -Force
  Copy-Item (Join-Path $root 'tools\audit-m4-arrival-v4.6.1.ps1') (Join-Path $scratch 'tools\audit-m4-arrival-v4.6.1.ps1') -Force
  Write-Output ('DRY-RUN: migrated files written to scratch. Production untouched (blob still ' + $START_BLOB + ').')
  Write-Output 'DRY-RUN: run the scratch validator + scratch arrival regression lint next.'
}
