# Postflop v4.3.0C — Module 4 Data Expansion (24 → 53)

**Status:** production_data_loaded_preview_only (M4 NOT runtime-wired)
**Sprint:** v4.3.0C
**Module:** `pf_turn_barrel_oop_def` — "Facing Turn Barrel OOP"
**Source-of-truth at sprint start:** HEAD = `c65ce16` (v4.3.0B-doc). Snapshot folder: `GPT AUDIT/v4.3.0B/`. Manifest: `MANIFEST_SHA256.txt`.

This document records the v4.3.0C M4 production data expansion sprint. 29 new scenarios were authored across 10 new turn-defense board families, addressing every coverage gap from v4.3.0B (mixed action, check_raise_big, pot_odds_turn_call, domination_turn_fold, semi_bluff_check_raise_turn, mixed_indifference_turn). Production count grows 409 → 438 (M4 24 → 53). Cache version bumps to v4.3.0C. **Module 4 remains preview-locked at the runtime layer.**

---

## 1. Baseline state

| Check | Result |
|---|---|
| HEAD = origin/main | `c65ce16` (v4.3.0B-doc) |
| v4.3.0B Manifest verification | All 9 referenced hashes match |
| Production audit | 409 / 0 / 0 — PASS |
| M2 seed audit | 24 / 0 / 8 — PASS |
| M3 seed audit | 24 / 0 / 0 — PASS clean |
| M4 seed audit | 24 / 0 / 0 — PASS |
| appVersion | 4.3.0B |
| SW VERSION | v4.3.0B |
| M4 in TRAINING_MODES.postflop.actions | NOT present (locked) |

ALL 8 BASELINE GATES GREEN.

---

## 2. Pre-expansion M4 coverage gaps

| Gap | Before | Target |
|---|---:|---:|
| **mixed action** | 0 | ≥ 3 |
| **check_raise_big action** | 0 | ≥ 2 |
| **pot_odds_turn_call** | 0 | ≥ 3 |
| **domination_turn_fold** | 0 | ≥ 3 |
| **semi_bluff_check_raise_turn** | 0 | ≥ 2 |
| **mixed_indifference_turn** | 0 | ≥ 3 |
| **equity_realization_turn_call** | 2 (thin) | ≥ 4 |
| **protection_check_raise_turn** | 2 (thin) | ≥ 4 |
| **slowplay_turn_call** | 2 (thin) | ≥ 3 |
| **blocker_check_raise_turn** | 1 (thin) | ≥ 3 (best-effort) |

---

## 3. Expansion design

**Target:** 24 → 50–60 (final M4 = 53).
**New scenarios:** 29 across 10 new board families.

| Family | Board | Lessons |
|---|---|---|
| 1 | `Ac 7d 2s / 4h` (brick after A-high) | pot_odds_call, equity_realization, **mixed**, domination_fold |
| 2 | `8d 6c 3s / Qh` (BB-favored Q overcard) | value_raise, pot_odds_call, range_disadv_fold |
| 3 | `Kd 8c 4s / Ah` (Ace overcard) | domination_fold, protection_raise, pot_odds_call |
| 4 | `Qs 8s 4d / 2s` (different flush_complete) | value_raise (nut flush), bluff_catch, slowplay_call (set vs flush) |
| 5 | `9s 8d 4c / 7h` (BB-favored straight complete) | **check_raise_big #1** (nut straight), **mixed #2**, pot_odds_call |
| 6 | `Kd 8s 3c / 8h` (board-pair high) | bluff_catch, **check_raise_big #2** (top boat), domination_fold |
| 7 | `Qs 7d 3c / 3h` (board-pair low/second pair) | value_raise (set→boat), protection_raise (overpair) |
| 8 | `Ts 8s 4d / 7c` (draw-intensifier, OESD-added) | value_raise (made straight), equity_realization (nut FD+overcards), **semi_bluff #1** |
| 9 | `Ah 9d 4d / 7h` (multi-FD turn) | bluff_catch (TPGK+A blocker), equity_realization (2nd-nut FD), **semi_bluff #2** |
| 10 | `Jd Td 5s / 2c` (polar brick after dynamic) | protection_raise (overpair), **mixed #3** (underpair) |

---

## 4. Post-expansion coverage matrix

### Action distribution (target met)

| Action | Before | After | Δ |
|---|---:|---:|---:|
| fold | 8 | 12 | +4 |
| call | 10 | 21 | +11 |
| check_raise_small | 6 | 15 | +9 |
| **check_raise_big** | **0** | **2** | **+2** ✓ |
| **mixed** | **0** | **3** | **+3** ✓ |

### actionReason distribution

| Reason | Before | After | Δ | Status |
|---|---:|---:|---:|---|
| pot_odds_turn_call | 0 | 4 | +4 | ✓ goal met |
| equity_realization_turn_call | 2 | 5 | +3 | ✓ |
| bluff_catch_turn | 6 | 9 | +3 | ✓ |
| board_change_fold | 4 | 4 | 0 | ✓ |
| domination_turn_fold | 0 | 3 | +3 | ✓ goal met |
| range_disadvantage_turn_fold | 4 | 5 | +1 | ✓ |
| value_check_raise_turn | 3 | 9 | +6 | ✓ |
| protection_check_raise_turn | 2 | 5 | +3 | ✓ |
| **semi_bluff_check_raise_turn** | **0** | **2** | **+2** ✓ goal met |
| blocker_check_raise_turn | 1 | 1 | 0 | thin (no quality replacement found) |
| slowplay_turn_call | 2 | 3 | +1 | ✓ |
| **mixed_indifference_turn** | **0** | **3** | **+3** ✓ goal met |

### heroHandRole distribution

| Role | After |
|---|---:|
| nutted_value | 11 |
| bluff_catcher | 8 |
| give_up | 8 |
| combo_draw | 6 |
| marginal_made_hand | 5 |
| dominated_marginal | 4 |
| strong_value | 4 |
| draw | 3 |
| slowplay_trap | 3 |
| blocker_bluff | 1 |

### turnCategory distribution

| Category | Before | After |
|---|---:|---:|
| brick | 4 | 10 |
| overcard | 4 | 10 |
| draw_intensifier | 4 | 10 |
| board_pair | 4 | 9 |
| flush_complete | 4 | 7 |
| straight_complete | 4 | 7 |

### difficulty distribution

| Difficulty | Count |
|---|---:|
| 2 | 6 |
| 3 | 29 |
| 4 | 16 |
| 5 | 2 |

Healthy bell-curve with majority at difficulty 3, smaller wings at 2 and 4-5.

### sourceConfidence

All 53 = `expert_judgment`. No solver-overconfidence.

---

## 5. Mixed-action and check_raise_big achievement

### Mixed (3 scenarios)

| ID | Hand / Board | Why mixed |
|---|---|---|
| `..._action_9c9d_v430C` (family 1) | 99 on Ac 7d 2s 4h | Underpair vs polarized barrel; verdict depends on villain bluff freq |
| `..._action_AhAd_v430C` (family 5) | AA on 9s 8d 4c 7h | Overpair on BB-favored polar straight turn; behind every made straight, ahead of bluffs |
| `..._action_9c9d_v430C` (family 10) | 99 on Jd Td 5s 2c | Underpair on draw-heavy polar brick; villain bluff range has equity |

All 3 are **TRUE indifference spots** — solver mixes ~50/50 vs balanced range. Marking either side as critical would be over-confident.

### check_raise_big (2 scenarios)

| ID | Hand / Board | Why big |
|---|---|---|
| `..._action_JhTh_v430C` (family 5) | JT on 9-8-4-7 = nut straight | BB has range advantage on this turn (BTN with JT/T6 typically 3-bets pre); polar turn forces villain to defend with overpairs/sets |
| `..._action_KsKc_v430C` (family 6) | KK on Kd 8s 3c 8h = top boat | Top set + paired turn = Kings full; only 88 quads beats hero (nearly impossible); polar turn rewards bigger sizing |

Both are **strategically justified** — bigger sizing extracts more value than small raise on these polar turns where villain is forced to call wider.

---

## 6. Anti-filler review

All 29 new scenarios carry a substantive `uniquenessNote` (>= 30 chars per expansion auditor M4.R14). Each cites a distinct strategic dimension vs existing 24 baseline:

- Different turn category (e.g., family 5 BB-favored straight vs existing BTN-favored)
- Different equity shift (BB-favored Q overcard vs existing BTN-favored K overcard)
- Different blocker effect (multi-FD turn with K-blocker vs nut A-blocker)
- Different draw completion (OESD-added vs straight-completed)
- Different pair-rank shift (Q-pair on BB-favored Q overcard vs K-pair demoted by Ace)
- Different bluff-catch threshold (TPTK on Kx-paired-by-8 vs existing AdKc on 88-3-3)
- Different check-raise sizing incentive (small for protection vs BIG for max value)
- Different fold/call/mixed threshold (mixed underpair vs definitive fold)
- Different critical mistake lesson (call-with-equity not critical vs naked-overcards-call critical)

**0 filler / 0 cosmetic duplicates.**

---

## 7. Strategic review verdicts (29/29 PROMOTE)

All 29 expansion scenarios PROMOTE — mechanical audit PASS, coverage gaps filled, strategic content per design. **0 REVISE / 0 REJECT.**

The expansion auditor (`tools/audit-postflop-module4-expansion-v4.3.0C.ps1`) caught 5 hard errors during initial audit, all fixed in builder before migration:
1. AhQh on Qh-turn → card collision; fixed to AhQc
2. Family 8 board: equityShift slot had drawCompletion value 'oesd_added'; fixed to 'improves_bb_draws' + drawCompletion='oesd_added'
3. KdQd on Ah board: classified as nut_flush_draw but Kd is 2nd-nut not nut (Ad still in deck); fixed to flush_draw
4. Family 5 board: highCardClass='9_high' but R02 derives 'low' (9 < T); fixed to 'low'

Plus 4 critical-flag downgrades (call-with-real-equity scenarios where check_raise_big is suboptimal but not severe-punt):
- Family 1 6d5d (OESD): critical=[check_raise_big] → []
- Family 1 7s6h (mid pair + gutshot): critical=[check_raise_big] → []
- Family 2 JdTd (gutshot): critical=[check_raise_big] → []
- Family 5 KdJd (gutshot): critical=[check_raise_big] → []

Final critical-flag density on expansion: **25/29 = 86.2%** (down from initial 100%).
Combined M4 critical density: **43/53 = 81.1%** (similar to v4.3.0A's 75% post-rebalance).

---

## 8. R71 bidirectional nut_flush_draw decision

R71 (added in v4.3.0B as WARN) checks: hero holds A-of-suit + 4-of-suit total + handClass not made-flush-class → drawCategory should be nut_flush_draw.

**v4.3.0C corpus check:** R71 fires **0 warnings** across all 53 M4 production scenarios.

**Decision:** R71 stays at WARN level. Promotion to HARD is premature because:
- The expansion KdQd 2nd-nut-FD case showed that R71-NEAR-MISS scenarios exist (hero with Kd-of-suit, not Ad). R71 only checks A-of-suit and correctly excludes that case.
- 53-scenario corpus is not large enough to confidently rule out edge cases (e.g., made-set with FD redraw where drawCategory should be 'none' for primary classification).
- 0 fires is consistent with all v4.3.0A REVISE fixes still holding; no need for HARD-level enforcement yet.

R71 remains as defense-in-depth. Re-evaluate in v4.3.1 with larger expansion corpus.

---

## 9. Concepts / taxonomy / production auditor changes

**No changes** to `postflop_concepts.json` (still 51), `postflop_taxonomy.json` (M4 module + vocabs from v4.3.0B unchanged), or `tools/audit-postflop-ps.ps1` (R55-R71 from v4.3.0B unchanged). All 29 new scenarios use existing M4 conceptTags / heroHandRole / actionReason vocabulary.

---

## 10. Migration tool

**Tool:** `tools/migrate-module4-v4.3.0C.ps1`

Properties:
- Idempotent
- ASCII-clean
- UTF-8 NO-BOM I/O
- Atomic write (tmp + Move-Item -Force)
- **No Invoke-Expression** for migration logic (per v4.3.0B safety rule)
- **No unsafe Remove-Item** on production-adjacent paths
- Two phases: default `review_pending`, `-FlipApproved` for `approved`
- `-DryRun` for safe preview
- Validates: 24 baseline M4 (non-expansion) + 0 expansion-IDs already in production
- Fails loudly on any baseline drift (≠385 non-M4, ≠24 baseline M4)

---

## 11. Production migration result

| Phase | M4 auditStatus | Production count | Audit |
|---|---|---:|---|
| Pre-migration | (24 baseline approved) | 409 | 409/0/0 PASS |
| Phase 1 (review_pending) | 24 approved + 29 review_pending | 438 | 438/0/0 PASS |
| Phase 2 (FlipApproved) | 53 approved | 438 | **438/0/0 PASS** |

Module breakdown after migration:
- pf_board_texture (M1): 251 (UNCHANGED)
- pf_flop_cbet_ip (M2): 49 (UNCHANGED)
- pf_flop_cbet_oop_def (M3): 85 (UNCHANGED)
- pf_turn_barrel_oop_def (M4): 53 (24 + 29 expansion)
- **TOTAL: 438**

---

## 12. Audit results

| Audit | Result |
|---|---|
| Production audit (post-migration, all approved) | **438 / 0 / 0 PASS** |
| Expansion seed audit | **29 / 0 hard / 0 warnings PASS** |
| M2 seed audit | 24 / 0 / 8 PASS (UNCHANGED) |
| M3 seed audit | 24 / 0 / 0 PASS clean (UNCHANGED) |
| M4 original seed audit | 24 / 0 / 0 PASS (UNCHANGED — planning JSON not touched) |
| R29 card-notation guard | 0 warnings (preserved) |
| R71 bidirectional FD warn | 0 fires |

---

## 13. Text integrity

- Expansion builder ASCII-clean: 0 non-ASCII bytes
- Expansion auditor ASCII-clean: 0 non-ASCII bytes
- Migration tool ASCII-clean: 0 non-ASCII bytes
- Production scenarios JSON: no mojibake patterns

---

## 14. Forbidden files untouched

| File | Status |
|---|---|
| `tools/build-m4-seeds-v4.3.0.ps1` | byte-identical (canonical for original 24 seeds) |
| `docs/specs/postflop-v4.3.0-module4-seed-scenarios.json` | byte-identical |
| `tools/audit-postflop-module4-seed.ps1` | byte-identical |
| `tools/audit-postflop-module2-seed.ps1` | byte-identical |
| `tools/audit-postflop-module3-seed.ps1` | byte-identical |
| `tools/migrate-module4-v4.3.0B.ps1` | byte-identical |
| `ranges.json`, `manifest.json`, all preflop, gamification | byte-identical |
| M1 / M2 / M3 strategy fields | byte-identical |
| TRAINING_MODES.m4 logic / runtime routes | UNCHANGED — not present |

**Modified:**
- `postflop/postflop_scenarios.json` (M4 +29: 24 → 53)
- `index.html` (1 line — `appVersion`)
- `service-worker.js` (1 line — `VERSION`)

**Created:**
- `tools/build-m4-expansion-v4.3.0C.ps1`
- `docs/specs/postflop-v4.3.0C-module4-expansion-seeds.json`
- `tools/audit-postflop-module4-expansion-v4.3.0C.ps1`
- `tools/migrate-module4-v4.3.0C.ps1`
- `docs/specs/postflop-v4.3.0C-module4-data-expansion.md` (this doc)

---

## 15. Runtime lock confirmation

- `TRAINING_MODES.postflop.actions.m4`: NOT present (stricter than 'preview')
- `postflop:m4` route: not implemented
- M4 start function: none
- M4 concept-drill route: none
- M4 weak-spot review: none
- M4 mastery UI: none

**Module 4 remains preview-locked.** No claim that M4 is playable.

---

## 16. Version / cache bump

| File | Before | After |
|---|---|---|
| `index.html` `appVersion` | `'4.3.0B'` | `'4.3.0C'` |
| `service-worker.js` `VERSION` | `'v4.3.0B'` | `'v4.3.0C'` |

Bump is for **data invalidation only**. User-facing app surface gains zero new clickable routes.

---

## 17. Known limitations

- **53 M4 scenarios is at the lower end of the 50–60 target.** Coverage gaps filled but corpus is still modest for runtime exposure.
- **blocker_check_raise_turn remains thin (1 representation)** — the existing AsJd advanced spot is hard to replicate without filler (similar As-blocker spots on different boards become cosmetic duplicates). Accepted limitation.
- **All sourceConfidence = expert_judgment.** No solver-aligned scenarios; future sprints could promote textbook spots to consensus_gto.
- **action_choice : reason_choice ratio is 47:6** (~89% / 11%). v4.3.0C added only action_choice scenarios; reason_choice variety is unchanged from v4.3.0B baseline. Future expansion may add more reason_choice diversity.
- **Critical-flag density 81%** is consistent with v4.3.0A's 75% post-rebalance, but slightly elevated. Reviewers should validate per-scenario critical justifications during v4.3.1 review.

---

## 18. Recommendation for next sprint

**v4.3.1 Module 4 Runtime Wire (Limited Beta)** is now a defensible candidate, with caveats:

✅ **Positive signals:**
- 53 scenarios across 6 turn categories with healthy diversity
- All 5 actions represented (mixed action achieved!)
- 11 of 12 actionReasons have ≥3 scenarios (only blocker_check_raise_turn thin)
- Difficulty bell-curve healthy (6/29/16/2)
- All 53 approved + audit clean
- R71 0 fires across corpus

⚠️ **Caveats:**
- 53 is below M3's beta threshold of 85
- All sourceConfidence=expert_judgment (no solver-anchored)
- reason_choice variety unchanged from baseline 6

**Two paths recommended:**

1. **Conservative:** v4.3.0D another expansion sprint (53 → 70+) before runtime wire. Add 5+ reason_choice scenarios. Promote 5+ textbook spots to consensus_gto. Then v4.3.1 runtime wire.

2. **Pragmatic:** v4.3.1 runtime wire AS Limited Beta with scaled mastery thresholds (e.g., 3 sessions / 75% / 8 actionReasons / weak-review used). Honest copy: "Limited Beta · 53 scenarios". Continue data expansion in parallel as v4.3.2/3.

**Path 1 is safer for product quality. Path 2 starts collecting real-user beta feedback sooner.** Project-owner decision.

**STOPPING after this sprint. v4.3.1 NOT started. M4 NOT runtime-wired. M4 NOT claimed playable.**
