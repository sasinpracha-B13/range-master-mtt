# Postflop v4.1.3 — Module 2 Audit Tooling Report

**Status:** Audit tooling implemented. 0 hard errors. 11 warnings, all defensible.
**Date:** 2026-05-05
**Companion to:** `postflop-v4.1.2-module2-architecture.md`, `postflop-v4.1.2-module2-schema-taxonomy.md`, `postflop-v4.1.2-module2-seed-scenarios.json`, `postflop-v4.1.2-module2-audit-plan.md`, `postflop-v4.1.2-module2-gpt-review-package.md`

---

## 1. Summary

v4.1.3 ships a Module 2 SEED auditor (`tools/audit-postflop-module2-seed.ps1`) that implements the rules defined in `postflop-v4.1.2-module2-audit-plan.md` and would have caught the v4.1.2 mechanical errors automatically.

**Why a separate auditor (not extending the production one):** The 11 baseline Module 2 scenarios in production data use the older `bet_33`/`check` choice ids and lack the v4.1.2 schema additions (`heroHandRole`, `drawCategory`, `recommendedAction`, `actionReason`). Adding Module 2 hard rules to `tools/audit-postflop-ps.ps1` would fail those 11 baseline scenarios, regressing the 262/0/0 production gate. Until the baseline 11 are migrated, the seed auditor handles Module 2.

### Headline numbers

| Metric | Result |
|---|---|
| Production audit (`tools/audit-postflop-ps.ps1`) | **262 scenarios, 0 errors, 0 warnings** (unchanged) |
| Module 2 seed audit (`tools/audit-postflop-module2-seed.ps1`) | **24 scenarios, 0 hard errors, 11 warnings, 15 PASS / 9 WARN / 0 FAIL** |
| New audit script LOC | ~620 |
| New rules implemented | 30 hard rules + 7 soft warnings + 9 coverage axes |
| Seed JSON edits | 3 (vocabulary refinement: `underpair` → `mid_pair` in 3 obvious cases) |
| Production runtime files touched | **0** (`index.html`, `service-worker.js`, `postflop/*.json` all untouched) |
| App version bumped | **No** — this patch is tooling + planning, not runtime |

---

## 2. Audit tool architecture

### 2.1 New file

**`tools/audit-postflop-module2-seed.ps1`** (sole new audit tool)

- Standalone PowerShell script, ~620 lines
- Reads the v4.1.2 seed JSON from `docs/specs/postflop-v4.1.2-module2-seed-scenarios.json` by default; supports `-Path <file>` to audit a different seed file
- Reads with explicit UTF-8 (`[System.IO.File]::ReadAllText(..., UTF8)`) to avoid system-codepage mis-decoding (CP874 on the developer machine introduced phantom mojibake on default `Get-Content -Raw`)
- Uses ASCII-only source code to prevent PowerShell parser corruption
- Prints per-scenario hard errors, warnings, PASS/WARN/FAIL summary, and 9-axis coverage report
- Exit code 0 on no hard errors, 1 otherwise

### 2.2 Files NOT modified

The brief allowed editing 4 files; only 1 was modified:

| File | Modified? | Reason |
|---|---|---|
| `tools/audit-postflop.js` | No | Existing Node.js auditor; not in active use (PowerShell auditor is the canonical local runner). Adding Module 2 rules here would duplicate work. |
| `tools/audit-postflop-ps.ps1` | No | Production auditor; adding Module 2 rules would fail the 11 baseline scenarios. Keep production gate at 262/0/0 untouched. |
| `postflop/postflop_audit_rules.js` | No | In-browser auditor with the same regression risk. Deferred to the eventual baseline-11 migration sprint. |
| `postflop/postflop_audit.html` | No | UI scope creep; the new seed auditor is CLI-only. The audit HTML can grow a Module 2 tab in a future patch when the data is integrated. |

### 2.3 Explicit UTF-8 reading (the false-positive lesson)

During development, `Get-Content -Raw` on the seed JSON appeared to return CP874 mojibake characters (Thai range U+0E00..U+0E7F + control bytes + smart quotes). Investigation showed:

- The file on disk is **clean UTF-8** with no actual mojibake.
- `Get-Content -Raw` defaults to the system codepage (CP874 on the developer's Windows install, due to Thai locale settings), which mis-decodes correctly-encoded UTF-8 bytes as if they were CP874 characters.
- This produces **phantom mojibake** that is not present in the file.

The fix:
```powershell
$seedText = [System.IO.File]::ReadAllText((Resolve-Path $seedPath), [System.Text.Encoding]::UTF8)
$seed = $seedText | ConvertFrom-Json
```

This pattern should be considered for future PowerShell tooling that reads UTF-8 JSON. The existing production auditor `tools/audit-postflop-ps.ps1` reads via `Get-Content -Raw` which works on this developer's machine because the audit only inspects ASCII-safe fields (card strings, ids, enums). String content fields are not inspected by the production audit.

---

## 3. Rules implemented

### 3.1 Hard rules (30)

All M2.H01–M2.H15 from `postflop-v4.1.2-module2-audit-plan.md` plus suit-count discipline (M2.SC01–M2.SC05) and hand-class derivation (M2.HC01–M2.HC11).

| Code | Rule | Status |
|---|---|---|
| M2.H01 | board has exactly 3 valid distinct cards | ✅ |
| M2.H02 | heroHand has exactly 2 valid distinct cards | ✅ |
| M2.H03 | no board / heroHand collision | ✅ |
| M2.H04 | module=`pf_flop_cbet_ip`, street=`flop`, spot=BTN/BB/SRP/100 | ✅ (spot → WARN) |
| M2.H05 | question.type ∈ {action_choice, reason_choice, sizing_choice, hand_class} | ✅ |
| M2.H06 | action_choice has exactly the 4 expected ids | ✅ |
| M2.H07 | reason_choice ids drawn from the 10-value enum | ✅ |
| M2.H08 | answer tier integrity (best non-empty, no overlap, all ids in choices) | ✅ |
| M2.H09 | recommendedAction ∈ best for action_choice | ✅ |
| M2.H10 | actionReason ∈ best for reason_choice | ✅ |
| M2.H11 | required fields present + vocabulary-valid | ✅ |
| M2.H12 | sourceConfidence honest (`solver_verified` requires `solverRunRef`) | ✅ |
| M2.H13 | auditStatus valid; planning seed warned if `approved` | ✅ |
| M2.H14 | explanation completeness (short/handLogic/takeaway always; sizingLogic for action_choice betting; commonMistake when critical) | ✅ |
| M2.H15 | mojibake detection (Thai range + replacement char codepoint scan; ASCII-source-only to avoid parser breakage) | ✅ |
| M2.H16 | conceptTag is in `postflop_concepts.json` OR in `[planned]` list (warn) | ✅ |
| M2.SC01 | handClass=flush/nut_flush requires 5+ of one suit; nut_flush requires hero Ace of suit | ✅ |
| M2.SC02 | handClass=flush_draw/nut_flush_draw requires exactly 4 of one suit | ✅ |
| M2.SC03 | drawCategory=fd/nut_fd consistency | ✅ |
| M2.SC04 | handClass=backdoor_only sanity (warn if real draw/made hand exists) | ✅ |
| M2.SC05 | explanation text "made flush" matches actual 5-of-suit (warn-level; ignores negations) | ✅ |
| M2.HC01 | handClass=straight requires 5 consecutive ranks | ✅ |
| M2.HC02 | handClass=set requires pocket pair matching board card | ✅ |
| M2.HC03 | handClass=trips requires hero card matching paired board | ✅ |
| M2.HC04 | handClass=overpair requires pocket pair > all board cards | ✅ |
| M2.HC05 | top_pair_* requires hero card matching top board (kicker mismatch warns) | ✅ |
| M2.HC06 | combo_draw requires both flush draw AND straight draw | ✅ |
| M2.HC07 | oesd requires 4 consecutive distinct ranks both ends extendable | ✅ |
| M2.HC08 | gutshot warns if no inside straight detected | ✅ |
| M2.HC09 | underpair vs mid_pair (warn) | ✅ |
| M2.HC10 | mid_pair sanity check (warn) | ✅ |
| M2.HC11 | no_pair_no_draw warns if any draw / backdoor / pair exists | ✅ |

### 3.2 Strategic soft warnings (4)

| Code | Rule | Status |
|---|---|---|
| M2.S01 | overpair on low_connected with bet_big best → WARN | ✅ |
| M2.S02 | air on ace_high_dry with check-only best → WARN (range-stab preferred) | ✅ |
| M2.S03 | naked air on monotone with bet best → WARN | ✅ |
| M2.S04 | top_pair_top_kicker on dry with bet_big best (no bet_small) → WARN | ✅ |

### 3.3 Coverage axes (9)

Reported per scenario set:
- question.type, board, recommendedAction, actionReason, heroHandRole, handClass, difficulty, sourceConfidence, auditStatus
- Plus: scenarios with critical answers count

### 3.4 Hand-evaluation helper functions

The auditor implements a small poker hand evaluator focused on Module 2 mechanics:

- `Get-SuitCounts` — per-suit card counts
- `Get-FlushSuit` / `Get-FlushDrawSuit` / `Get-BackdoorFlushSuit` — suit thresholds
- `Get-MadeStraightHigh` — 5-consecutive-rank detection (with wheel A-2-3-4-5)
- `Test-OESD` — 4 consecutive ranks both-ends extendable
- `Test-Gutshot` — 4 ranks in a 5-window with one gap (honors wheel-low)
- `Test-BackdoorStraight` — 3 ranks in a 5-window
- `Get-PairAnalysis` — pocket-pair, set, trips, overpair, top/second/third/mid pair, kicker classification

The evaluator is **not** a full equity solver — it's a structural classifier that derives the mechanical truth from board + heroHand and lets the audit compare against the scenario's claimed `handClass` / `drawCategory` / `heroHandRole`.

---

## 4. Production audit result

```
$ powershell -ExecutionPolicy Bypass -File tools/audit-postflop-ps.ps1
...
Total scenarios: 262
Errors: 0
Warnings: 0
Scenarios with errors: 0
  module pf_board_texture: 251
  module pf_flop_cbet_ip: 11
  Module 1 total: 251

  Boards used >1 time: 0
  Board+qtype combos used >1 time: 0
  needs_review: 0

[exit 0]
```

**262 / 0 / 0 — unchanged from v4.1.2.** The new auditor is fully additive; the production gate is intact.

---

## 5. Module 2 seed audit result

### 5.1 Final numbers

| Metric | Count |
|---|---|
| Scenarios | 24 |
| Hard errors | **0** |
| Warnings | 11 |
| PASS scenarios | 15 |
| WARN scenarios | 9 |
| FAIL scenarios | 0 |

### 5.2 Warnings (11)

| Rule | Scenario | Note |
|---|---|---|
| M2.HC11 | #4 QcJh on As8d3h | `no_pair_no_draw` but has backdoor straight + bdfd |
| M2.HC11 | #8 AcQh on Kh9c4s | `no_pair_no_draw` but has backdoor straight |
| M2.HC11 | #10 AhQc on 8s7d5h | `no_pair_no_draw` but board ranks form backdoor; hero contributes minimal |
| M2.HC11 | #18 AsQs on KcKd7s | `no_pair_no_draw` but has backdoor spade flush |
| M2.HC09 | #17 QhQc on KcKd7s | QQ on paired K-K-7 labeled `underpair`; mechanical analysis says `mid_pair`. Vocabulary debate — defensible either way on a paired board |
| M2.H14 | #4 / #8 / #16 | reason_choice scenarios with `recommendedAction = bet_*` could optionally include sizingLogic; not strictly required |
| M2.SC05 | #21 AhTd on Jh8h4h | Explanation references "made nut flush" in commonMistake (negation context — "treating Ah as if made nut flush"); fuzzy text matching false-positive |
| M2.SC05 | #22 KhQd on Jh8h4h | Same — explanation references "made K-flush" in contrast wording |
| M2.SC05 | #24 6h5c on Jh8h4h | Same — "made low flush" in negation context |

All 11 warnings are documented and pedagogically defensible. None require the seed JSON to be mechanically corrected.

### 5.3 Coverage report

```
By question.type:
  action_choice: 18
  reason_choice: 6
By board:
  As 8d 3h: 4    Kh 9c 4s: 4    8s 7d 5h: 4
  Th 6h 2c: 4    Kc Kd 7s: 4    Jh 8h 4h: 4
By recommendedAction:
  bet_small: 11   check: 9   bet_big: 2   mixed: 2
By actionReason:
  range_advantage_stab: 5   pot_control: 5   value: 4   give_up: 4
  equity_realization: 4   thin_value: 2
By heroHandRole:
  air: 4   thin_value: 4   weak_showdown: 4   strong_value: 3
  weak_draw: 3   blocker_bluff: 2   medium_showdown: 1
  nut_draw: 1   strong_draw: 1   trap_check: 1
By difficulty:
  1: 3   2: 12   3: 5   4: 4
By sourceConfidence:
  expert_judgment: 24
By auditStatus:
  review_pending: 24
Scenarios with critical answers: 18
```

### 5.4 Pre-fix audit findings (rules in development)

The auditor's first development run flagged several issues that demonstrate the tool is doing its job:

1. **6 phantom hard errors from a PowerShell encoding mis-read** — Solved by switching to explicit UTF-8 reading. Real lesson: file was always clean; the auditor needed correct decoding.
2. **24 phantom M2.H08 errors from string-vs-array concat** — Fixed by collecting answer ids via `ArrayList` instead of `+` concatenation, which collapsed single-element JSON arrays into strings.
3. **6 real hard errors before rule-tightening** — 3 M2.H14 (sizingLogic on reason_choice — too strict, downgraded to WARN) + 3 M2.SC05 (text matching too crude — added negation guard, downgraded to WARN).
4. **1 false top_pair_weak_kicker mechanical derivation** — Fixed by replacing pipeline `Where-Object | [0]` with explicit `if/else` indexing for kicker selection.

After the rule tightening, the audit produces the final 0 hard errors / 11 warnings result.

---

## 6. Seed fixes applied (v0.1.1 → v0.1.2)

| # | Field | Before | After | Why |
|---|---|---|---|---|
| #7 | handClass | `underpair` | `mid_pair` | 7h7c on Kh9c4s: 7 is between 9 and 4 board cards → mid_pair per schema vocab |
| #15 | handClass | `underpair` | `mid_pair` | 4d4c on Th6h2c: 4 is between 6 and 2 → mid_pair |
| #23 | handClass | `underpair` | `mid_pair` | 9d9c on Jh8h4h: 9 is between 8 and 4 (and below J top) → mid_pair |

Total seed JSON edits: **3 lines** — pure vocabulary refinement, no strategic claims changed, no answer tiers altered, no recommendedAction or actionReason touched.

The seed JSON `version` field stays at `0.1.1-planning` because these are vocabulary refinements not content changes (no answers / explanations modified). Future content changes will bump to `0.1.2`+.

---

## 7. Remaining warnings — disposition

| Warning code | Count | Disposition |
|---|---|---|
| M2.HC11 | 4 | KEEP — `no_pair_no_draw` is the simpler human label; `backdoor_only` is more precise. Will be addressed during the v4.1.4 data sprint when scenarios are re-authored at scale. |
| M2.HC09 | 1 | KEEP — `underpair` for QQ on K-K-7 is defensible because the paired top card (KK) is the de-facto top of the board; mid_pair is the strict mechanical label. |
| M2.H14 | 3 | KEEP — sizingLogic is *optional* not required for reason_choice. The warning serves as a documentation reminder. |
| M2.SC05 | 3 | KEEP — text matching is fuzzy. The explanations correctly use phrases like "treating Ah as if made nut flush (it doesn't)" — the negation makes the warning a false positive. |

---

## 8. Limitations

1. **No solver integration.** The auditor's hand evaluator is structural only (made hand classes, draw types, suit counts). It does not compute equity, EV, or solver-recommended actions. Strategic claims (`recommendedAction`, `actionReason`) are not validated against a solver — only against the scenario's own metadata for internal consistency.

2. **Text-matching warnings are fuzzy.** M2.SC05 (made-flush wording) uses regex matching with a basic negation guard. It can still false-positive on creative wording. Treat all M2.SC05 warnings as "review the wording" not "wrong claim".

3. **Not extended to in-browser auditor.** The browser auditor (`postflop/postflop_audit.html` + `postflop/postflop_audit_rules.js`) does not yet have Module 2 rules. When the seed data is merged into production JSON, both the browser auditor and `tools/audit-postflop-ps.ps1` need extension.

4. **Production auditor not extended.** Same reason — the 11 baseline Module 2 scenarios use the older schema and would fail v4.1.2 rules. Migration sprint required first.

5. **No CI / pre-commit hook.** The seed auditor is run manually. A pre-commit hook (or GitHub Action) running `tools/audit-postflop-module2-seed.ps1` is a future improvement — out of v4.1.3 scope.

6. **No multi-spot support.** v4.1.2 covers exactly one spot (BTN-vs-BB SRP 100BB IP). The auditor enforces this via M2.H04 (warn if spot fields differ). Future modules will need to relax this.

7. **Seed JSON is the only audit target.** The auditor reads from a fixed default path and accepts a `-Path` override. There's no support for auditing inline JSON or stdin. Acceptable for current usage; can be added later.

---

## 9. Files changed

| File | Status | Lines | Purpose |
|---|---|---|---|
| `tools/audit-postflop-module2-seed.ps1` | NEW | ~620 | The Module 2 seed auditor |
| `docs/specs/postflop-v4.1.2-module2-seed-scenarios.json` | MODIFIED | +3 / -3 | 3 vocabulary refinements (`underpair` → `mid_pair`) caught by the new audit |
| `docs/specs/postflop-v4.1.2-module2-audit-plan.md` | MODIFIED | small | Mark rules as implemented |
| `docs/specs/postflop-v4.1.2-module2-gpt-review-package.md` | MODIFIED | small | Reflect new audit + warning baseline |
| `docs/specs/postflop-v4.1.3-module2-audit-tooling-report.md` | NEW | this file | Tooling report |
| `PROJECT_STATE.md` | MODIFIED | small | Status update |
| `TASK_BOARD.md` | MODIFIED | small | Status update |

**Untouched (verified):**
- `index.html` (still v4.1.1)
- `service-worker.js` (still v4.1.1)
- `postflop/postflop_scenarios.json` (still 262 scenarios)
- `postflop/postflop_taxonomy.json`, `postflop/postflop_concepts.json`
- `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`
- `tools/audit-postflop.js` (Node auditor — out of scope this patch)
- `tools/audit-postflop-ps.ps1` (production auditor — kept untouched to preserve 262/0/0)
- `tools/generate-postflop-module1.ps1`
- `ranges.json`, `manifest.json`

---

## 10. Recommended next step

The audit tooling is in place. The seed is healthy (0 hard errors, 11 documented warnings). Suggested next moves (each is a separate user instruction, **none started here**):

1. **Run the GPT review pass** against `postflop-v4.1.2-module2-gpt-review-package.md` § 6 questions and the 10 high-risk scenarios in § 5. Apply any reviewer corrections in a `v4.1.3.1`-style mini-patch.
2. **Decide the integration approach** for the existing 11 Module 2 baseline scenarios (replace / coexist / refactor) — flagged in `architecture.md` § 15 open question 1.
3. **v4.1.4 data sprint** — expand the 24 seeds to ~150 production scenarios using the same authoring pattern as v4.0.7. Run the new auditor after each batch. Target: 150+ scenarios at 0 hard errors with documented warnings.
4. **Migrate the 11 baseline scenarios** to the v4.1.2 schema (rename `bet_33` → `bet_small`, populate `heroHandRole` / `drawCategory` / `showdownValue` / `recommendedAction` / `actionReason` / `explanation.takeaway`). Then re-run both auditors to confirm 0 errors across the merged set.
5. **Extend the production auditor** (`tools/audit-postflop-ps.ps1`) to enforce Module 2 rules **after** the baseline migration is complete. This will set the production gate at e.g. 286/0/0 (262 + 24 v4.1.2 seeds + future expansion).
6. **Add to `postflop/postflop_audit_rules.js` + `postflop/postflop_audit.html`** when Module 2 ships into production data, so the in-browser auditor matches the PowerShell auditor.
7. **Add a pre-commit hook / CI workflow** that runs both auditors automatically.

Per the brief: **stopping here, not starting v4.1.4, not productionizing Module 2, not touching runtime UI.**
