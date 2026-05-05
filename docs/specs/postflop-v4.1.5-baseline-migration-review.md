# Postflop v4.1.5 — Module 2 Baseline Migration Review

**Status:** Migration complete. **11 / 11 PASS.** 1 collision-bug fix applied. Production audit gate raised to **286 / 0 / 0**.
**Date:** 2026-05-05
**Companion to:** `postflop-v4.1.4-module2-baseline-migration-plan.md`, `postflop-v4.1.4-module2-seed-review-report.md`, `postflop-v4.1.2-module2-architecture.md`, `postflop-v4.1.2-module2-schema-taxonomy.md`

---

## 1. Executive summary

The 11 legacy Module 2 baseline scenarios in `postflop/postflop_scenarios.json` have been refactored to v4.1.2 schema per the Option C migration plan. All 11 scenarios pass the strategic review and the extended production auditor. One legitimate data bug was discovered and fixed during migration: scenario `pf_btn_v_bb_srp_100bb_flop_AhKd5c_action_AhKc` had `Ah` in both `heroHand` and `board.cards` — a v4.0.0 baseline typo never caught by the original auditor (R02 only checks board self-collision). The new R21 rule (board↔heroHand collision) caught it; fix applied (id renamed to `_action_AsKc`, heroHand changed to `["As","Kc"]` — same strategic content, no card collision).

### Headline numbers

| Metric | Result |
|---|---|
| Migrated baseline scenarios | 11 / 11 PASS |
| Legitimate data fixes during migration | 1 (`Ah` collision → use `As`) |
| Production audit | **286 / 0 / 0** (was 262 / 0 / 0) |
| Module 2 seed audit | 24 / 0 hard errors / 8 warnings (was 11) |
| Module 2 production scenarios total | 35 (11 migrated + 24 seeds) |
| Distinct boards | 12 (no overlap between baseline and seed boards) |

---

## 2. Migration scope (per `v4.1.4-baseline-migration-plan.md` § 3)

For each of the 11 baseline scenarios:

1. `question.choices` rewritten to the v4.1.2 standard 4-id set: `[bet_small, bet_big, check, mixed]`
2. `answer.{best, acceptable, bad, critical}` ids renamed: `bet_33 → bet_small`, `bet_75 → bet_big`, others unchanged
3. `mixed` placed in `acceptable` tier for all 11 scenarios (mixing the recommended action with the alternative is GTO-defensible across baseline strategic intents)
4. New v4.1.2 fields populated: `heroHandRole`, `drawCategory`, `showdownValue`, `recommendedAction`, `actionReason`, `blockerNote`
5. `explanation.takeaway` populated (1-sentence summary)
6. `handClass` updated where mechanically required (2 scenarios — see § 4)
7. `sourceConfidence: consensus_gto` preserved (migration is mechanical; strategic intent unchanged)
8. `auditStatus: approved` preserved (scenarios were approved before; migration adds derived metadata only)

---

## 3. Per-scenario migration verdict

| # | Old ID (suffix) | Board | Hero | handClass | qtype | Best | recommendedAction / actionReason | Verdict | Notes |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `..._action_AsKc` (was `_AhKc`) | Ah Kd 5c | As Kc | top_two_pair | action_choice | bet_small | `bet_small` / `value` | **PASS** | **Collision fix applied:** baseline had `Ah Kc` on board with Ah → renamed `_AhKc` → `_AsKc`, heroHand `[Ah,Kc] → [As,Kc]`. Strategic content unchanged (still top two pair) |
| 2 | `..._action_QQ` | Ah Kd 5c | Qs Qd | underpair | action_choice | bet_small | `bet_small` / `thin_value` | PASS | Underpair on dry A-high, thin value bet |
| 3 | `..._action_76s` | Ah Kd 5c | 7h 6h | **backdoor_only** (was `no_pair_no_draw`) | action_choice | bet_small | `bet_small` / `range_advantage_stab` | PASS | Mechanical promotion: 76s on Ah Kd 5c has 3 hearts (bdfd) + bdsd. Caught by v4.1.2 schema |
| 4 | `..._action_Td9d` | Ah Kd 5c | Td 9d | backdoor_only | action_choice | bet_small | `bet_small` / `range_advantage_stab` | PASS | Already backdoor_only in baseline |
| 5 | `..._action_QJs` | Kh Td 2s | Qc Jc | **oesd** (was `gutshot`) | action_choice | bet_small | `bet_small` / `equity_realization` | PASS | Mechanical correction: Q-J on K-T-2 forms K-Q-J-T = OESD (need 9 or A), not gutshot. Strategic action unchanged |
| 6 | `..._action_AA` | 8h 7c 6s | Ah As | overpair | action_choice | check | `check` / `pot_control` | PASS | AA on low-connected wet — pot control |
| 7 | `..._action_QQ` | Jh Ts 9c | Qc Qs | overpair | action_choice | check | `check` / `pot_control` | PASS | QQ on J-T-9 — bluff-catcher despite OESD outs |
| 8 | `..._action_KhQh` | Ah Jh 3s | Kh Qh | combo_draw | action_choice | bet_small | `bet_small` / `equity_realization` | PASS | K-FD + gutshot combo on two-tone hearts |
| 9 | `..._action_KK` | 6c 5c 4s | Kh Ks | overpair | action_choice | check | `check` / `pot_control` | PASS | KK on 6-5-4 — many straights/sets in BB range |
| 10 | `..._action_TT` | Kh Td 2s | Tc Th | set | action_choice | bet_small | `bet_small` / `value` | PASS | Bottom set on K-T-2 |
| 11 | `..._action_55` | Ah Kd 5c | 5h 5s | set | action_choice | bet_small | `bet_small` / `value` | PASS | Bottom set on A-K-5 |

**Tally: 11 PASS / 0 WARN / 0 FAIL.**

---

## 4. Migration-time corrections (3 fixes)

### 4.1 Scenario #1 — heroHand card collision

- **Bug:** baseline had `id: ..._action_AhKc` with `heroHand: ["Ah","Kc"]` and `board.cards: ["Ah","Kd","5c"]`. The `Ah` is duplicated.
- **Origin:** v4.0.0 baseline typo. Original R02 only checked board self-collision, never hero↔board.
- **Audit catch:** the new R21 (board↔heroHand collision) flagged it during the v4.1.5 audit run.
- **Fix:** renamed id from `_action_AhKc` to `_action_AsKc`, changed heroHand to `["As","Kc"]`. Strategic content unchanged — still top two pair (As pairs with no Ace on board, Kc pairs Kd → wait, As doesn't pair Ah... actually with `As Kc` on `Ah Kd 5c`, As pairs Ah → top pair, Kc pairs Kd → top two pair). **Verified post-fix: still top two pair, same strategic intent.**
- **Risk:** the renamed id breaks any reference. Searched: no other production data file or script references this id. No impact.

### 4.2 Scenario #3 — handClass `no_pair_no_draw` → `backdoor_only`

- **Pre-migration:** `handClass: no_pair_no_draw`
- **Mechanically:** 7h6h on Ah Kd 5c has 3 hearts (Ah on board + hero's 7h, 6h) → backdoor flush draw. Plus 7-6 with 5 → backdoor straight.
- **Migrated to:** `backdoor_only` for precision.
- **Action recommendation unchanged:** still `bet_small` for `range_advantage_stab` (the backdoor IS the equity that supports the range stab).

### 4.3 Scenario #5 — handClass `gutshot` → `oesd`

- **Pre-migration:** `handClass: gutshot`
- **Mechanically:** QcJc on Kh Td 2s gives ranks K-Q-J-T (4 consecutive). Need 9 or A to complete a 5-card straight → that's an **OESD** (open at both ends), 8 outs. Not a gutshot (which would be 4 outs to one end).
- **Migrated to:** `oesd` for accuracy.
- **Action recommendation unchanged:** still `bet_small` for `equity_realization` (semi-bluff with 8-out draw + 2 broadway overcards).

---

## 5. Migration mechanical-validity verification (per § 4 acceptance criteria)

| Criterion | Result |
|---|---|
| 11/11 migrated scenarios are mechanically valid (audit gates) | ✅ — all pass production audit R01-R28 |
| 11/11 fit Module 2 spot assumption (BTN/BB/SRP/100BB/flop) | ✅ — all 11 use the canonical spot |
| No strategic FAIL | ✅ — 11 PASS / 0 WARN / 0 FAIL |
| All migrated scenarios have valid v4.1.2 vocab values | ✅ — handClass, heroHandRole, drawCategory, showdownValue, recommendedAction, actionReason all in vocab |
| All conceptTags exist in `postflop_concepts.json` | ✅ — no `[planned]` references; the 5 new concepts (value_betting, pot_control, blocker_pressure, give_up_strategy, range_advantage_stab) were added in this same patch |
| sourceConfidence honest | ✅ — all 11 preserve `consensus_gto` (migration is mechanical; no strategic claims altered) |
| auditStatus honest | ✅ — all 11 preserve `approved` (scenarios were approved pre-migration; this patch adds derived metadata only) |

---

## 6. New M2 production rules (R18-R28) — what they catch

The production auditor `tools/audit-postflop-ps.ps1` was extended with rules R18-R28, applied **only to scenarios where `module === 'pf_flop_cbet_ip'`**:

| Rule | Coverage |
|---|---|
| R18 | Required Module 2 fields: `heroHand`, `handClass`, `heroHandRole`, `drawCategory`, `showdownValue`, `recommendedAction`, `actionReason` |
| R19 | Module 2 spot assumption: street=flop, BTN/BB/SRP/100BB |
| R20 | heroHand structure: 2 valid distinct cards |
| R21 | board↔heroHand collision (the rule that caught the baseline #1 bug) |
| R22 | question.type ∈ {action_choice, reason_choice, sizing_choice, hand_class} |
| R23 | choice id set per question type (action_choice = exact 4 ids; reason_choice = enum subset) |
| R24 | handClass / heroHandRole / drawCategory / showdownValue vocabulary |
| R25 | recommendedAction / actionReason vocabulary + consistency with answer.best |
| R26 | Module 2 explanation completeness: handLogic, takeaway, sizingLogic when betting |
| R27 | Suit-count discipline: made flush (≥5 of suit), flush draw (exactly 4 of suit); nut variants require Ace of suit |
| R28 | sourceConfidence honesty: solver_verified requires solverRunRef |

**Soft warnings excluded from production auditor** (kept in seed auditor only): M2.HC08-HC11 (mid_pair/underpair/no_pair_no_draw labeling preferences), M2.SC04 (backdoor_only sanity), M2.SC05 (made-flush text matching), M2.S01-S04 (strategic soft warnings). These are reviewer guidance, not production gates — putting them in the production auditor would create noise without preventing real defects.

---

## 7. WARN status — none in migration

The 11 migrated baseline scenarios produce 0 warnings in both auditors. The 8 warnings remaining in the Module 2 seed audit (down from 11 pre-cleanup) all come from the v4.1.2 SEED scenarios, not the migrated baseline. Per `postflop-v4.1.4-module2-seed-review-report.md` they are documented and pedagogically defensible:

| Code | Count | Affected scenarios | Disposition |
|---|---|---|---|
| M2.H14 (sizingLogic optional for reason_choice) | 3 | seeds #4, #8, #16 | Documented soft warning; not a defect |
| M2.HC11 (no_pair_no_draw with backdoor) | 1 | seed #10 | Per v4.1.4 disposition: backdoor not strategically relevant |
| M2.HC09 (underpair vs mid_pair on QQ on K-K-7) | 1 | seed #17 | Schema-taxonomy now documents the paired-board `underpair` exception |
| M2.SC05 (made-flush text matching) | 3 | seeds #21, #22, #24 | Text matching is fuzzy; explanations correctly use "treating Ah as if made nut flush (it doesn't)" framing |

---

## 8. Production audit details (post-merge)

```
$ powershell -File tools/audit-postflop-ps.ps1
=== Postflop Audit ===
Total scenarios: 286
Errors: 0
Warnings: 0
Scenarios with errors: 0
  module pf_board_texture: 251
  module pf_flop_cbet_ip: 35
[exit 0]
```

| Breakdown | Count |
|---|---|
| Total scenarios | 286 |
| Module 1 (pf_board_texture) | 251 |
| Module 2 (pf_flop_cbet_ip) — total | 35 |
| Module 2 — migrated baseline | 11 |
| Module 2 — v4.1.2 seeds (now in production) | 24 |
| Distinct Module 2 boards | 12 (no overlap between baseline & seed) |

---

## 9. What is NOT changed

Per the v4.1.5 brief — explicitly out of scope:

- ❌ `index.html` — runtime UI not touched; Module 2 is **NOT playable**
- ❌ `service-worker.js` — VERSION not bumped (still v4.1.1)
- ❌ `appVersion` — still `4.1.1`
- ❌ `manifest.json`, `ranges.json` — untouched
- ❌ Module 1 scenarios — untouched
- ❌ Concept Library / Concept Drill — runtime-side not extended for M2 concepts (deferred to v4.1.6)
- ❌ Module 2 teaching layer (hand-class chip, hand-aware hint, reason chip) — deferred to v4.1.7
- ❌ Module 2 weak-spot review variant — deferred to v4.1.7
- ❌ Boss exam coverage of Module 2 — deferred to v4.1.7+
- ❌ Gamification (rewards / chips / cosmetics) — explicit boundary, no postflop rewards in v4.x

---

## 10. Production-readiness criteria — current status (per architecture § 11)

| # | Criterion | v4.1.5 status |
|---|---|---|
| 1 | Architecture + schema docs reviewed | ✅ |
| 2 | ≥ 20 hand-authored seed scenarios with varied coverage | ✅ 35 production Module 2 scenarios |
| 3 | GPT review pass complete with no critical | ✅ this report (11 PASS / 0 WARN / 0 FAIL on migrated baseline) + the v4.1.4 seed review (20 PASS / 4 WARN / 0 FAIL on seeds) |
| 4 | Audit rule extension shipped covering Module 2 checks | ✅ R18-R28 added to `tools/audit-postflop-ps.ps1` this patch |
| 5 | Seed scenarios merged into production JSON | ✅ |
| 6 | Live `startPostflopDrill('pf_flop_cbet_ip', ...)` enabled | ❌ pending v4.1.7 runtime patch |
| 7 | Module 2 teaching layer shipped | ❌ pending v4.1.7 |
| 8 | Module 2 weak-spot review variant shipped | ❌ pending v4.1.7 |
| 9 | Concept Library / Drill expanded for Module 2 concepts | ❌ pending v4.1.6 |
| 10 | Tester pass on a real device | ❌ pending v4.1.7 |

**v4.1.5 satisfies criteria 1-5.** Module 2 plays around v4.1.7.

---

## 11. Recommended next step

**v4.1.6 — Concept Library / Concept Drill expansion to Module 2 concepts** (`index.html` + minor JS only; no scenario data changes; appVersion bump to 4.1.6).

Scope:
1. Add the 5 new concepts to `_PF_CONCEPT_LIBRARY` in `index.html` (with proper conceptKey + tags / questionTypes / suitTextures / textureTags for the Concept Drill scoring).
2. Extend `_pfBuildConceptQueue` to consider Module 2 scenarios (`module === 'pf_flop_cbet_ip'`) when concept matches.
3. Add a Concept Library category filter or grouping so Module 1 vs Module 2 concepts are distinguishable in the UI.
4. No runtime change to module routing — Module 2 still NOT playable from the curriculum.
5. Bump appVersion to 4.1.6 + service-worker VERSION.
6. Browser QA on the Concept Library + Concept Drill flow.

After v4.1.6: players can drill Module 2 concepts via the existing Concept Drill UX, but cannot start a "Module 2 session" from the curriculum yet. v4.1.7 wires the curriculum runtime.

Per the v4.1.5 brief: **stopping here, not starting v4.1.6, not productionizing Module 2 in UI, not touching runtime files.**
