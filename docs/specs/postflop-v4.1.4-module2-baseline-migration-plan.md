# Postflop v4.1.4 — Module 2 Baseline Migration Plan

**Status:** Decision documented. **No production JSON changes** in this patch.
**Date:** 2026-05-05
**Companion to:** `postflop-v4.1.4-module2-seed-review-report.md`, `postflop-v4.1.2-module2-architecture.md`, `postflop-v4.1.2-module2-schema-taxonomy.md`, `postflop-v4.1.3-module2-audit-tooling-report.md`

---

## 1. Current baseline-11 status

`postflop/postflop_scenarios.json` ships **11 legacy Module 2 scenarios** (`module: pf_flop_cbet_ip`) authored during the v4.0.0 baseline package. They are part of the production 262 / 0 / 0 audit and have been live since the beginning of the postflop epic.

### 1.1 Per-scenario summary

| # | Board | Hero | handClass | Best | Acceptable | Bad | conceptTags | sourceConfidence |
|---|---|---|---|---|---|---|---|---|
| 1 | Ah Kd 5c | Ah Kc | top_two_pair | bet_33 | bet_75 | check | small_cbet_freq, thin_value, dry_high_card, range_advantage | consensus_gto |
| 2 | Ah Kd 5c | Qs Qd | underpair | bet_33 | check | bet_75 | small_cbet_freq, thin_value, protection, dry_high_card | consensus_gto |
| 3 | Ah Kd 5c | 7h 6h | no_pair_no_draw | bet_33 | check | bet_75 | small_cbet_freq, semi_bluff, dry_high_card | consensus_gto |
| 4 | Ah Kd 5c | Td 9d | backdoor_only | bet_33 | check | bet_75 | small_cbet_freq, semi_bluff, dry_high_card | consensus_gto |
| 5 | Kh Td 2s | Qc Jc | gutshot | bet_33 | — | bet_75, check | small_cbet_freq, semi_bluff, dry_high_card | consensus_gto |
| 6 | 8h 7c 6s | Ah As | overpair | check | bet_75 | bet_33 | check_strategy, protection, low_connected, dynamic | consensus_gto |
| 7 | Jh Ts 9c | Qc Qs | overpair | check | bet_75 | bet_33 | check_strategy, protection, low_connected, wet | consensus_gto |
| 8 | Ah Jh 3s | Kh Qh | combo_draw | bet_33 | bet_75 | check | semi_bluff, small_cbet_freq, polar_big, two_tone | consensus_gto |
| 9 | 6c 5c 4s | Kh Ks | overpair | check | bet_75 | bet_33 | check_strategy, protection, low_connected, wet | consensus_gto |
| 10 | Kh Td 2s | Tc Th | set | bet_33 | bet_75 | check | small_cbet_freq, thin_value, dry_high_card | consensus_gto |
| 11 | Ah Kd 5c | 5h 5s | set | bet_33 | bet_75 | check | small_cbet_freq, thin_value, dry_high_card | consensus_gto |

### 1.2 What the baseline-11 looks like vs. v4.1.2 schema

| Aspect | Baseline-11 | v4.1.2 seeds |
|---|---|---|
| `module` | `pf_flop_cbet_ip` | same ✅ |
| `street` | `flop` | same ✅ |
| `spot` | BTN/BB SRP 100BB | same ✅ |
| `board.cards` etc. | full | same ✅ |
| `heroHand` | populated | same ✅ |
| `handClass` | populated (set, overpair, top_two_pair, underpair, combo_draw, gutshot, backdoor_only, no_pair_no_draw) | populated, slightly extended vocab |
| `question.type` | only `action_choice` | `action_choice` + `reason_choice` |
| `question.choices` ids | `check, bet_33, bet_75` (3 sizes) | `bet_small, bet_big, check, mixed` (4 family ids) |
| `answer.critical` | always empty | populated in 18 of 24 |
| `conceptTags` | populated | populated |
| `sourceConfidence` | `consensus_gto` | `expert_judgment` |
| `auditStatus` | `approved` | `review_pending` |
| `heroHandRole` | **missing** | populated |
| `recommendedAction` | **missing** | populated |
| `actionReason` | **missing** | populated |
| `drawCategory` | **missing** | populated |
| `showdownValue` | **missing** | populated |
| `blockerNote` | **missing** | optional |
| `explanation.short` | populated | populated |
| `explanation.handLogic` | sometimes populated | always populated |
| `explanation.sizingLogic` | sometimes populated | required when betting |
| `explanation.commonMistake` | sometimes populated | required when critical present |
| `explanation.takeaway` | **missing** | always populated |

### 1.3 Why baseline-11 fails the new audit

The Module 2 seed auditor (`tools/audit-postflop-module2-seed.ps1`) would, if pointed at the baseline-11, report:

- **M2.H06**: action_choice expects ids `{bet_small, bet_big, check, mixed}` — baseline-11 uses `{check, bet_33, bet_75}` → **HARD ERROR**
- **M2.H11**: missing fields `heroHandRole, recommendedAction, actionReason, drawCategory, showdownValue, explanation.takeaway` → **HARD ERROR (6 per scenario)**
- **M2.H13**: `auditStatus = approved` — warning ("planning seed should be review_pending")

That's why the v4.1.3 audit script audits the seeds at `docs/specs/...` only, not the production data — adding these rules to the production auditor would regress the 262 / 0 / 0 gate.

---

## 2. Chosen migration model: **C — Refactor / Migrate**

The brief presented three options:

- **A. Replace** — Drop the 11; ship only v4.1.2 schema.
- **B. Coexist** — Keep both schemas in production (dual answer-id sets).
- **C. Refactor / Migrate** — Convert the 11 to v4.1.2 schema; preserve strategic intent.

**Decision: C — Refactor / Migrate.**

### 2.1 Why C (and not A or B)

| Factor | A (Replace) | B (Coexist) | C (Refactor) |
|---|---|---|---|
| Preserve `consensus_gto` work | ❌ lost | ✅ kept | ✅ kept |
| Schema consistency | ✅ clean | ❌ two answer-id sets | ✅ clean |
| Production audit gate | drops to 251/0/0 (loses 11) | adds dual-rule complexity | stays 262/0/0 (after migration), then grows |
| Runtime UI complexity | trivial | needs to handle `bet_33`+`bet_small` parallel | trivial |
| Migration effort | none (drop) | none (no change) | moderate (per-scenario field-by-field) |
| Pedagogical coverage | loses 6 baseline boards (AhKd5c, KhTd2s, 8h7c6s, JhTs9c, AhJh3s, 6c5c4s) | full coverage | full coverage |
| Risk of strategic regressions | none (loses content) | none (no change) | low (mapping is mostly mechanical) |
| Total Module 2 production set after this work | 0 (until v4.1.5 ships seeds) → 24 (after v4.1.5) | 11 baseline + 24 seeds = 35, but with 2 schemas | **11 migrated + 24 seeds = 35 in one schema** |

C wins because:
1. The 11 baseline scenarios are tagged `consensus_gto` — they were authored with strong confidence. Discarding them (A) wastes that work.
2. The board coverage of the baseline-11 (6 boards) does **not overlap** with the v4.1.2 seed boards (6 different boards). Combining → 12 boards × ~3 hands/board on average. That's a good production base.
3. Field mapping is largely mechanical: `bet_33 → bet_small`, `bet_75 → bet_big`, `handClass` already valid v4.1.2 vocab in most cases, conceptTags compatible. The judgment-required fields (`heroHandRole`, `actionReason`) can be derived from existing explanations + handClass.
4. Schema unification means v4.1.5+ data sprints can use one auditor, one runtime parser, one teaching layer.

### 2.2 What C does NOT do (in this patch)

This patch is **planning only**. The actual refactor happens in a future patch (recommended: **v4.1.5** baseline-migration sprint):

- `postflop/postflop_scenarios.json` is **not edited** in v4.1.4.
- `tools/audit-postflop-ps.ps1` is **not extended** in v4.1.4.
- `index.html`, `service-worker.js` are **not touched** in v4.1.4.
- The 11 baseline scenarios stay exactly as they are; production still says 262 / 0 / 0.

---

## 3. Migration mapping

When v4.1.5 (or later) executes the refactor, each baseline scenario follows this mapping:

### 3.1 Choice id mapping

| Baseline id | v4.1.2 id | Note |
|---|---|---|
| `check` | `check` | unchanged |
| `bet_33` | `bet_small` | family-level (~25–33% pot) |
| `bet_75` | `bet_big` | family-level (~66–100% pot) |
| `mix` / `mixed` | `mixed` | (none in baseline-11; allowed for future) |

### 3.2 Question.choices restructure

Baseline `question.choices`:
```json
[
  { "id": "check",  "label": "Check back" },
  { "id": "bet_33", "label": "Bet 33% pot" },
  { "id": "bet_75", "label": "Bet 75% pot" }
]
```

v4.1.2 `question.choices`:
```json
[
  { "id": "bet_small", "label": "Bet small (~33% pot)" },
  { "id": "bet_big",   "label": "Bet big (~75-100% pot)" },
  { "id": "check",     "label": "Check back" },
  { "id": "mixed",     "label": "Mixed (split between two actions)" }
]
```

The migration must add the `mixed` choice and rename `bet_33`/`bet_75` to `bet_small`/`bet_big`.

### 3.3 Answer tier rewrite

For each baseline scenario, rewrite `answer.{best,acceptable,bad,critical}` arrays using the new ids. Example:

Baseline #6 (Ah Kd 5c, AhKc, top_two_pair):
```json
"answer": { "best": ["bet_33"], "acceptable": ["bet_75"], "bad": ["check"], "critical": [] }
```

Migrated:
```json
"answer": { "best": ["bet_small"], "acceptable": ["mixed"], "bad": ["check"], "critical": ["bet_big"] }
```

> Note the migration also has the chance to add `critical` answers where appropriate (the baseline never populated critical). This is judgment-required per scenario.

### 3.4 New required fields — derivation rules

| Field | How to derive |
|---|---|
| `heroHandRole` | From `handClass` + best-action signal: `set` / `overpair` (high SDV) + bet → `strong_value`; `top_two_pair` + bet → `strong_value`; `underpair` + check → `weak_showdown`; `combo_draw` + bet → `strong_draw`; `gutshot` + bet → `weak_draw`; `no_pair_no_draw` + bet → `air` (or `blocker_bluff` if has key blocker); `backdoor_only` + bet → `air` |
| `recommendedAction` | Equal to mapped `answer.best[0]` (after id renaming). For multi-best scenarios, pick the most-common-frequency action. |
| `actionReason` | From `conceptTags` + action: `thin_value_betting` → `thin_value`; `protection_betting` + bet → `protection`; `semi_bluff_with_equity` → `equity_realization` or `semi_bluff`; `check_strategy` + check on low-connected → `pot_control`; `small_cbet_freq` + bet on dry → `range_advantage_stab` or `value`; etc. Per-scenario judgment. |
| `drawCategory` | Mechanical from board + heroHand: 4 of one suit → `fd` (or `nut_fd` if hero has Ace of suit); 3 of one suit → `backdoor_only`; OESD → `oesd`; gutshot → `gutshot`; combo (FD+OESD or FD+gutshot) → `combo`; nothing → `none`. |
| `showdownValue` | From `handClass`: set / top_two_pair / overpair / top_pair_top_kicker → `high`; top_pair_good_kicker / mid_pair → `medium`; underpair / top_pair_weak_kicker → `low`; no_pair_no_draw / backdoor_only / draws → `none`. |
| `blockerNote` | Optional; populate when hero holds a key blocker (e.g., Ah on monotone hearts; Ace on paired Ax board). |
| `explanation.takeaway` | Required: 1-sentence summary line. Derive from existing `explanation.short` if present. |
| `explanation.handLogic` | Required: paragraph on the hand's role here. May already exist in baseline; otherwise lift from `explanation.short`. |
| `explanation.sizingLogic` | Required when `recommendedAction ∈ {bet_small, bet_big}`. May already exist; otherwise compose. |
| `explanation.commonMistake` | Required when `answer.critical` is populated. May need new content. |

### 3.5 conceptTags

Baseline tags are mostly already in `postflop_concepts.json`. No removal required. May add planned tags (`value_betting`, `pot_control`, `blocker_pressure`, `give_up_strategy`, `range_advantage_stab`) where applicable — these need to land in `postflop/postflop_concepts.json` first.

### 3.6 sourceConfidence + auditStatus

| Baseline | After migration |
|---|---|
| `sourceConfidence: consensus_gto` | **Keep `consensus_gto`** if migration preserves strategic intent without alteration |
| `sourceConfidence: consensus_gto` | **Downgrade to `expert_judgment`** if the migration adds critical answers / changes acceptable tier |
| `auditStatus: approved` | **Downgrade to `review_pending`** during migration; only flip back to `approved` after GPT/human review of migrated scenario |

---

## 4. Audit gates before merging migrated baseline-11 into production

Before the migrated 11 join `postflop/postflop_scenarios.json`:

1. **Production audit must still pass 262 / 0 / 0** when run *before* the migration commit (sanity check).
2. **The migrated 11 scenarios must pass the Module 2 seed auditor** (`tools/audit-postflop-module2-seed.ps1`) with `-Path` pointed at the staging file. Target: 11 / 0 hard errors / N warnings (warnings allowed if documented).
3. **The combined 35-scenario set** (24 seeds + 11 migrated) must pass the seed auditor as a single file. Same target.
4. **The production auditor must be extended** at the same time to enforce v4.1.2 Module 2 rules. Target after this combined commit: production audit 251 (M1) + 35 (M2 v4.1.2) = 286 scenarios / 0 errors / 0 warnings.
5. **No regressions** in Module 1 audit (251 / 0 / 0 within the M1 subset must still hold).

---

## 5. GPT review gates before merging migrated baseline-11

The GPT review package (`postflop-v4.1.2-module2-gpt-review-package.md`) currently asks 13 questions about the 24 seeds. For the migration sprint, an analogous review pass against the 11 migrated scenarios is required:

1. Reviewer confirms each migrated `recommendedAction` / `actionReason` matches the original strategic intent.
2. Reviewer confirms each new `heroHandRole` is the correct strategic frame.
3. Reviewer confirms each new `drawCategory` / `showdownValue` is mechanically correct.
4. Reviewer confirms newly-added `critical` answers (if any) are textbook leaks.
5. Reviewer confirms new `explanation.takeaway` lines are clear and pedagogically clean.

Output: a `postflop-v4.1.5-baseline-migration-review.md` doc with PASS/WARN/FAIL per migrated scenario. Same template as `postflop-v4.1.4-module2-seed-review-report.md`.

---

## 6. How migrated baseline-11 will coexist with the 24 seeds

After the migration sprint, the production Module 2 set is:

- **24 v4.1.2 seeds** (boards: As 8d 3h, Kh 9c 4s, 8s 7d 5h, Th 6h 2c, Kc Kd 7s, Jh 8h 4h)
- **11 migrated baseline scenarios** (boards: Ah Kd 5c, Kh Td 2s, 8h 7c 6s, Jh Ts 9c, Ah Jh 3s, 6c 5c 4s)
- **= 35 total scenarios across 12 distinct boards**, no board overlap.

Coverage analysis post-merge:

| Board family | Boards | Scenarios |
|---|---|---|
| A-high dry | Ah Kd 5c (5), As 8d 3h (4) | 9 |
| K-high semi-dry | Kh 9c 4s (4), Kh Td 2s (2) | 6 |
| Q-high — | (none yet) | 0 |
| J-high wet/connected | Jh Ts 9c (1) | 1 |
| Low connected | 8h 7c 6s (1), 6c 5c 4s (1), 8s 7d 5h (4) | 6 |
| Two-tone | Ah Jh 3s (1), Th 6h 2c (4) | 5 |
| Paired | Kc Kd 7s (4) | 4 |
| Monotone | Jh 8h 4h (4) | 4 |

Distribution is reasonable for an early Module 2 production base. Q-high and J-high are under-represented and should be priority targets for the v4.1.6+ data sprint.

---

## 7. Whether to keep original scenario IDs or create new IDs

**Decision: Keep original IDs for the 11 baseline scenarios (after migration).**

Rationale:
- Original IDs are referenced from any historical session data (not currently — postflop history doesn't yet store ids in a way that would break, but it's the safer default).
- ID format `pf_btn_v_bb_srp_100bb_flop_<board>_action_<hand>` is still readable and Module 2-flavored.
- Renaming would create a needless diff and complicate the migration audit.

Exception: if a scenario's strategic content fundamentally changes during migration (e.g., flipping `best` from `bet_33` to a different action because the migration discovered a re-evaluation is needed), then increment the id with a `_v415` suffix to make the version transition explicit.

---

## 8. Rollback plan

If the merged 35-scenario set fails audit or GPT review after the v4.1.5 migration commit:

1. **Revert the production JSON merge.** `git revert <commit>` on the `postflop/postflop_scenarios.json` change. Production audit returns to 262/0/0 with the legacy 11 still using `bet_33`/`bet_75`.
2. **Revert the production audit script extension.** Same `git revert` on the rules added to `tools/audit-postflop-ps.ps1`.
3. **Keep the migration plan + migrated staging file** in `docs/specs/` for the next iteration.
4. **Document the rollback reason** in a new `docs/specs/postflop-v4.1.5-baseline-migration-rollback.md` (or update the migration plan with the failure analysis).

The runtime is unaffected because v4.1.5 is data + audit only — no `index.html` or `service-worker.js` changes happen until a separate v4.1.6+ patch flips the runtime to actually use Module 2 in the drill engine.

---

## 9. Acceptance criteria for "baseline migration complete"

The migration sprint (v4.1.5) is "complete" when **all** of the following are true:

- [ ] `postflop/postflop_scenarios.json` has been edited: the 11 baseline scenarios now use v4.1.2 schema (choices `bet_small/bet_big/check/mixed`, fields `heroHandRole/recommendedAction/actionReason/drawCategory/showdownValue` populated, `explanation.takeaway` populated).
- [ ] Total production scenario count is **35 in pf_flop_cbet_ip module** (11 migrated + 24 seeds).
- [ ] Total production scenario count is **286 overall** (251 Module 1 + 35 Module 2).
- [ ] `tools/audit-postflop-ps.ps1` has been extended to enforce v4.1.2 Module 2 rules and reports **286 / 0 / 0**.
- [ ] `tools/audit-postflop-module2-seed.ps1` (if extended to read production JSON) reports **35 / 0 hard errors / N warnings** with all warnings documented.
- [ ] GPT-review pass complete on the 11 migrated scenarios with **0 FAIL**.
- [ ] No `index.html` / `service-worker.js` changes (Module 2 still not playable).
- [ ] All conceptTags used by migrated scenarios exist in `postflop/postflop_concepts.json` (no `[planned]` references in production).
- [ ] `PROJECT_STATE.md` and `TASK_BOARD.md` updated.
- [ ] State files note: production audit gate raised from **262/0/0** to **286/0/0**.

The migration sprint is **explicitly not** responsible for:
- Making Module 2 playable in the drill engine (that's a later runtime patch).
- Adding the in-browser auditor's Module 2 rules (`postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`).
- Concept Library / Concept Drill expansion to Module 2 concepts.
- Module 2 weak-spot review or session summary refinements.
- Any gamification (rewards, chips, cosmetics).

---

## 10. Summary

| Question | Answer |
|---|---|
| What model? | **C — Refactor / Migrate** |
| Why? | Preserves consensus_gto work, unifies schema, no board overlap with v4.1.2 seeds, mapping is mostly mechanical |
| When? | **v4.1.5** (data + audit-extension sprint; runtime untouched) |
| What's the result? | 11 migrated + 24 seeds = 35 production scenarios in pf_flop_cbet_ip module; production audit gate rises to 286/0/0 |
| Production runtime impact in v4.1.4? | **None** — this patch is planning only |
| Production runtime impact in v4.1.5? | **None** — data + audit only, no UI |
| When does Module 2 become playable? | A separate v4.1.6+ runtime patch wires `startPostflopDrill('pf_flop_cbet_ip', ...)` |
