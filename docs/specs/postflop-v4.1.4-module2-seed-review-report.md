# Postflop v4.1.4 — Module 2 Seed Review Report

**Status:** Review complete. **20 PASS / 4 WARN / 0 FAIL** strategic verdict on 24 seeds. Audit clean.
**Date:** 2026-05-05
**Companion to:** `postflop-v4.1.4-module2-baseline-migration-plan.md`, `postflop-v4.1.2-module2-architecture.md`, `postflop-v4.1.2-module2-schema-taxonomy.md`, `postflop-v4.1.2-module2-seed-scenarios.json`, `postflop-v4.1.3-module2-audit-tooling-report.md`

---

## 1. Executive summary

The 24 v4.1.2 Module 2 seed scenarios were re-reviewed strategically (each scenario: action, reason, explanation tone) on top of the v4.1.3 mechanical audit. Result:

| Verdict | Count | Scenarios |
|---|---|---|
| **PASS** (strategic + mechanical) | 20 | #1, #2, #3, #4, #5, #6, #7, #8, #10, #11, #13, #14, #15, #16, #18, #19, #21, #22, #23, #24 |
| **WARN** (defensible but reviewer-sensitive) | 4 | #9, #12, #17, #20 |
| **FAIL** | 0 | — |

The 11 mechanical-audit warnings reported by `tools/audit-postflop-module2-seed.ps1` are **partly subsumed** by this strategic review (some scenarios have audit warnings AND strategic-WARN; others have audit warnings but strategic-PASS because the warnings are about labeling precision, not strategic correctness).

**Recommendation: productionize after a small seed cleanup pass (3 backdoor_only relabels + #20 reword).** No FAIL means the seed is qualitatively ready; the cleanup is precision-only.

---

## 2. Audit results

### 2.1 Production audit (gates the existing 262 scenarios)

```
$ powershell -File tools/audit-postflop-ps.ps1
Total scenarios: 262
Errors: 0
Warnings: 0
[exit 0]
```

**262 / 0 / 0 — unchanged.** Production data is intact.

### 2.2 Module 2 seed audit (gates the 24 v4.1.2 seeds)

```
$ powershell -File tools/audit-postflop-module2-seed.ps1
Scenarios: 24
PASS: 15
WARN: 9
FAIL: 0
Total hard errors:  0
Total warnings:     11
RESULT: PASS (11 warnings)
[exit 0]
```

**24 / 0 hard errors / 11 warnings.** All warnings categorized in § 4 below.

---

## 3. PASS / WARN / FAIL table — 24 seeds

> "Audit warnings" column shows what `tools/audit-postflop-module2-seed.ps1` reports per scenario. "Strategic verdict" is the qualitative review on top.

| # | Board | Hero | handClass | qtype | Best | Audit warnings | Strategic verdict | Reasoning |
|---|---|---|---|---|---|---|---|---|
| 1 | As 8d 3h | AhKh | top_pair_top_kicker | action | bet_small | — | **PASS** | Top pair top kicker on dry A-high → small high-frequency bet for value; bet_big as critical is the textbook leak |
| 2 | As 8d 3h | 7c6c | backdoor_only | action | bet_small | — | **PASS** | Air with bdfd + bdsd → range stab; small high-freq c-bet candidate |
| 3 | As 8d 3h | 9d9s | mid_pair | action | check | — | **PASS** | Mid pocket pair on A-high → check, accept showdown |
| 4 | As 8d 3h | QcJh | no_pair_no_draw | reason | range_advantage_stab | M2.HC11, M2.H14 | **PASS** | Reason "range advantage" is correct frame for the small bet with QJ on dry A-high. Audit warns about backdoor_only label (HC11) — fixable, but not strategic concern |
| 5 | Kh 9c 4s | KsQc | top_pair_good_kicker | action | bet_small | — | **PASS** | Top pair good kicker on K-high; small bet for value/protection |
| 6 | Kh 9c 4s | JdTd | gutshot | action | bet_small | — | **PASS** | Gutshot + bdfd + 2 overcards → semi-bluff small range bet |
| 7 | Kh 9c 4s | 7h7c | mid_pair | action | check | — | **PASS** | Small underpair below 9 → check (post-v4.1.3 mid_pair fix applied) |
| 8 | Kh 9c 4s | AcQh | no_pair_no_draw | reason | range_advantage_stab | M2.HC11, M2.H14 | **PASS** | Same reason frame as #4. Audit warning about backdoor_only is precision, not strategy |
| 9 | 8s 7d 5h | JhJc | overpair | action | check | — | **WARN** | "JJ on 8-7-5 → check" is right; "bet_big as critical" is the strongest pedagogical claim in the seed. Some players defend bet_big "for protection" — see § 5.1 |
| 10 | 8s 7d 5h | AhQc | no_pair_no_draw | action | check | M2.HC11 | **PASS** | Air on BB-favored low connected → check, give up. Audit warning about backdoor_only — but the backdoor isn't strategically relevant here, no_pair_no_draw stands |
| 11 | 8s 7d 5h | 9c6c | straight | action | bet_big | — | **PASS** | Made 9-high straight on wet connected → bet big polar (post-v4.1.2 fix-pass: handClass corrected from combo_draw to straight) |
| 12 | 8s 7d 5h | KsKd | overpair | reason | pot_control | — | **WARN** | "Pot control" as reason for the KK check is correct; "protection as critical" teaches against the textbook leak. Reviewer-sensitive — see § 5.2 |
| 13 | Th 6h 2c | AhKc | backdoor_only | action | bet_small | — | **PASS** | This was the major v4.1.2 fix (was wrongly NFD; now correctly backdoor with overcards + ace blocker). Bet small range stab is correct |
| 14 | Th 6h 2c | Tc8s | top_pair_weak_kicker | action | bet_small | — | **PASS** | Top pair weak kicker on two-tone → small for thin value + protection |
| 15 | Th 6h 2c | 4d4c | mid_pair | action | check | — | **PASS** | Small pair on FD board → check, accept showdown (post-v4.1.3 mid_pair fix) |
| 16 | Th 6h 2c | 9h8h | combo_draw | reason | equity_realization | M2.H14 | **PASS** | Real combo draw (FD + gutshot, verified suit count). "Equity realization" reason is correct semi-bluff frame; "value" critical teaches against the wrong frame |
| 17 | Kc Kd 7s | QhQc | underpair | action | bet_small (check acceptable) | M2.HC09 | **WARN** | QQ on K-K-7: best=bet_small with check upgraded to acceptable in fix-pass. Audit suggests `mid_pair` over `underpair`. Solver mixes; current state is defensible — see § 5.3 |
| 18 | Kc Kd 7s | AsQs | no_pair_no_draw | action | bet_small | M2.HC11 | **PASS** | A blocker + bdfd → small range stab (actionReason corrected to range_advantage_stab in fix-pass). HC11 warning is precision |
| 19 | Kc Kd 7s | 6c6d | underpair | action | check | — | **PASS** | Small underpair on paired K-high → check, accept showdown |
| 20 | Kc Kd 7s | AhKh | trips | reason | value | — | **WARN** | Trips top kicker, action=mixed (check + bet_small). Reason "value" for the check line is forced (the action is check, but the check is for delayed value). Could rewrite as "trap" — see § 5.4 |
| 21 | Jh 8h 4h | AhTd | nut_flush_draw | action | bet_small | M2.SC05 | **PASS** | NFD on monotone (post-v4.1.2 fix from "set"). Bet small is solver-dominant. SC05 warning is text-matching false positive (negation context) |
| 22 | Jh 8h 4h | KhQd | flush_draw | action | mixed | M2.SC05 | **PASS** | K-FD on monotone, action=mixed (post-v4.1.2 fix from bet_small). SC05 warning same false positive |
| 23 | Jh 8h 4h | 9d9c | mid_pair | action | check | — | **PASS** | Mid pair, no flush card on monotone → check (post-v4.1.3 mid_pair fix) |
| 24 | Jh 8h 4h | 6h5c | flush_draw | reason | give_up | M2.SC05 | **PASS** | Low FD reverse-dominated; reason=give_up correct (post-v4.1.2 fix from pot_control). SC05 warning same false positive |

**Tally:** 20 PASS / 4 WARN / 0 FAIL.

---

## 4. Detailed review of remaining audit warnings

The audit reports 11 warnings across 9 scenarios. Categorized:

### 4.1 M2.HC11 — `no_pair_no_draw` claimed but backdoor exists (4 scenarios)

| # | Hero | Board | Backdoor type | Strategic relevance | Recommended fix |
|---|---|---|---|---|---|
| 4 | QcJh | As 8d 3h | bdfd (Jh + 3h) + bdsd | Backdoor IS the equity that supports range-stab | **Change `handClass` to `backdoor_only`** (precision matters) |
| 8 | AcQh | Kh 9c 4s | bdfd (Ac + 9c) + bdsd | Backdoor + ace blocker → relevant | **Change to `backdoor_only`** |
| 10 | AhQc | 8s 7d 5h | Backdoor straight from board (8-7-5) — hero contributes minimally | Action is check; backdoor is irrelevant | **Keep `no_pair_no_draw`** — the backdoor doesn't drive the action |
| 18 | AsQs | Kc Kd 7s | bdfd (As/Qs + 7s) + ace blocker | Backdoor + blocker → drives the bet | **Change to `backdoor_only`** |

**Recommendation:** in v4.1.5 seed cleanup, change scenarios #4, #8, #18 from `no_pair_no_draw` → `backdoor_only`. Keep #10 as `no_pair_no_draw` (the backdoor is board-driven and doesn't influence the check decision).

### 4.2 M2.HC09 — `underpair` vs `mid_pair` on QQ on K-K-7 (1 scenario)

Scenario #17: QhQc on Kc Kd 7s.

- **Mechanically:** Q is between paired top (K) and bottom (7), so the `mid_pair` definition fits.
- **Pedagogically:** Calling QQ on a K-paired board "underpair to top" matches how players naturally describe it.
- **Audit:** flags `underpair` as inconsistent with the schema vocab definition.

**Options:**
1. Add new vocab `underpair_to_paired_top` to schema-taxonomy. → Overengineered for one scenario.
2. Loosen the `underpair` definition in schema-taxonomy to include "below the dominant rank on paired boards." → Slight ambiguity but pragmatic.
3. Just change #17 to `mid_pair`. → Loses the pedagogical "underpair to KK" framing.

**Recommendation:** Option 2 — extend the `underpair` definition with a paired-board exception in `postflop-v4.1.2-module2-schema-taxonomy.md` § 4.1, then update the audit's `M2.HC09` rule to recognize this exception. Document in the v4.1.5 cleanup.

### 4.3 M2.H14 — `sizingLogic` optional but recommended for reason_choice with bet (3 scenarios)

Scenarios #4, #8, #16: `recommendedAction` is `bet_small` or `bet_big` but the question is `reason_choice` (asking "why" not "what to do"). The audit currently flags missing `sizingLogic` as a warning.

Schema position: sizingLogic is required for **action_choice** scenarios where the action is bet. For **reason_choice**, the question is about reason, not sizing.

**Recommendation:** Keep the audit warning as documentation reminder. Optionally add a `actionLogic` schema field that covers the "why this action" rationale for reason_choice scenarios; require `sizingLogic` OR `actionLogic` (not both). Document in v4.1.5 schema refinement.

For now (v4.1.4): no action. Warnings stand as soft advisories.

### 4.4 M2.SC05 — "made flush" wording in negation/contrast contexts (3 scenarios)

Scenarios #21, #22, #24: explanations contain phrases like "treating Ah as if made nut flush (it doesn't)" — pedagogically correct but the audit's regex matches "made nut flush" without fully parsing the negation.

**Options:**
1. Reword the explanations to avoid "made flush" entirely (e.g., "treating Ah as if it gave us the flush already"). Sterile but safer.
2. Improve the audit regex to detect more negation patterns.
3. Leave as-is; the warning serves as a precision reminder.

**Recommendation:** Option 3 — leave as-is for v4.1.5. The warnings document a real source of confusion (mojibake-prone, encoding-prone). When the in-browser auditor (`postflop/postflop_audit_rules.js`) gets Module 2 rules, port the same M2.SC05 rule with the same disposition.

---

## 5. Strategic WARN scenarios — disposition

The 4 strategic WARN scenarios are pedagogically defensible but reviewer-sensitive. Each has a clear disposition.

### 5.1 #9 JhJc on 8s 7d 5h — `bet_big` as critical leak

**Setup:** Overpair JJ on 8-7-5 (low-connected, BB-favored). Best=check, critical=bet_big.

**Why it's a WARN:** Modern PIO mostly checks JJ here (~70-80%), small bet ~10-20%, big bet <5%. Bet_big is a textbook protection-bet leak. But some players will defend bet_big "to charge draws."

**Disposition:**
- **Keep critical=bet_big.** This IS a textbook leak. The pedagogical claim is correct.
- Confirmed: Module 1 concept `low_connected_caution` (`postflop/postflop_concepts.json` lines 187-198) explicitly calls out "Over-c-betting these boards is a common leak."
- For learners, marking bet_big as critical is the correct teaching hammer.

**Recommendation:** No change before production.

### 5.2 #12 KsKd on 8s 7d 5h reason_choice — `protection` as critical

**Setup:** KK on 8-7-5. Action=check. reason_choice question: "Why does BTN check?" Best=pot_control. Critical=protection.

**Why it's a WARN:** Forcing learners to call this "pot control" and not "protection" is the central pedagogical lever.

**Disposition:**
- **Keep critical=protection.** Same reasoning as #9. The "protection" frame is the leak; pot_control is the correct frame.
- This is the canonical lesson of "don't bet overpairs on low connected boards for protection."

**Recommendation:** No change before production.

### 5.3 #17 QhQc on Kc Kd 7s — `bet_small` best vs `mixed` best

**Setup:** QQ on K-K-7. Best=bet_small. Acceptable=mixed, check.

**Why it's a WARN:** Solver outputs mix QQ between bet_small (~50%) and check (~50%) on this exact texture. Calling bet_small "best" is one defensible position; calling "mixed" best with bet_small acceptable is another.

**Disposition:**
- **Current state is defensible.** bet_small is the modal action; check is acceptable.
- Could change to best=mixed, acceptable=bet_small + check, but that changes the pedagogical signal from "lean toward bet" to "the lines are equal."
- For an early-Module-2 learner, "lean small with QQ on paired Kx" is more actionable than "it's a mix."

**Recommendation:** Keep current state. Document in GPT review for reviewer to opine.

### 5.4 #20 AhKh on Kc Kd 7s reason_choice — `value` reason for check line

**Setup:** Trips top kicker on K-K-7. Action=mixed (bet_small + check). reason_choice question: "When BTN does check, what is the main reason?" Best=value. Acceptable=pot_control.

**Why it's a WARN:** "Value" feels off because the action is *check*, not bet. The intent is "delayed value via induced action" or "trap" — but those framings aren't in the reason_choice enum.

**Disposition:**
- The current "value" answer is forced.
- **Recommended fix:** rewrite the question prompt to make the "delayed/trap value" framing explicit, OR change best to `pot_control` with "value" as acceptable. Either improves clarity.

**Recommendation:** **Reword in v4.1.5 seed cleanup.** Either:
- (a) Change the prompt to "When BTN checks back trip Ks for the trap, what is the main reason?" with `value` as best
- (b) Change best to `pot_control` (more natural for a check action)

Suggested: option (a) preserves the trap-value teaching point.

---

## 6. Recommended seed fixes before production

### 6.1 Mechanical fixes (low-risk, high-value)

| # | Field | Current | Recommended | Rule |
|---|---|---|---|---|
| 4 | handClass | `no_pair_no_draw` | `backdoor_only` | Backdoor is strategically relevant |
| 8 | handClass | `no_pair_no_draw` | `backdoor_only` | Backdoor is strategically relevant |
| 18 | handClass | `no_pair_no_draw` | `backdoor_only` | Backdoor is strategically relevant |
| 17 | handClass | `underpair` | (keep + extend vocab in schema doc) | Pragmatic — paired top → "underpair to paired top" |
| 20 | question.prompt | "When BTN does check, what is the main reason?" | "When BTN checks trip Ks back as a trap, what is the main reason?" | Make trap framing explicit |

### 6.2 Schema doc refinement

- `postflop-v4.1.2-module2-schema-taxonomy.md` § 4.1: extend `underpair` definition to include "below the dominant rank on paired boards."

### 6.3 Audit script refinement (optional, v4.1.6+)

- M2.HC09: recognize the paired-board exception so QQ on K-K-7 doesn't warn.
- M2.SC05: improve negation detection in regex.

---

## 7. Recommendation: production readiness verdict

### 7.1 Verdict

**PRODUCTIONIZE AFTER MINOR SEED FIXES.**

The 24 seeds are strategically sound. After:
1. Three `backdoor_only` relabels (#4, #8, #18) — purely mechanical
2. One reword (#20 prompt) — pedagogical clarity
3. Schema doc refinement on `underpair` definition

…the seeds are ready to enter the production audit gate as part of the v4.1.5 baseline-migration sprint.

### 7.2 What "ready to productionize" means here

It does **not** mean "ready to play." It means:

- **Ready** to be merged into `postflop/postflop_scenarios.json` alongside the migrated baseline-11.
- **Ready** to be enforced by an extended `tools/audit-postflop-ps.ps1` rule set.
- **Ready** to be cited as `consensus_gto`-quality reference data once the GPT review pass completes.

It does **not** mean:
- Wired into the runtime drill engine (`startPostflopDrill('pf_flop_cbet_ip', ...)`)
- Surfaced in the Academy curriculum as Active
- Producing player sessions
- Tested on a real device

The runtime integration is a **separate later patch** (recommended: v4.1.7+ "runtime productionization") that must come after the data + audit is solid.

---

## 8. Exact next action for v4.1.5

**v4.1.5 — Module 2 Seed Cleanup + Baseline Migration + Audit Extension**

Scope (executed in this order):

1. **Seed cleanup** (in `docs/specs/postflop-v4.1.2-module2-seed-scenarios.json`):
   - Change handClass on #4, #8, #18 to `backdoor_only`.
   - Reword question.prompt on #20.
   - Re-run seed auditor; confirm warning count drops by ~3.
2. **Schema-taxonomy refinement** (in `postflop-v4.1.2-module2-schema-taxonomy.md`):
   - Extend `underpair` definition with paired-board note.
   - Document the `actionLogic` field as optional alternative to `sizingLogic` for reason_choice scenarios.
3. **Concept additions** (in `postflop/postflop_concepts.json`):
   - Add the 5 `[planned]` concepts: `value_betting`, `pot_control`, `blocker_pressure`, `give_up_strategy`, `range_advantage_stab`. Each gets full schema entry (key, displayName, category, shortDef, longDef, examples, relatedConcepts) consistent with existing concept entries.
4. **Baseline-11 migration** (in `postflop/postflop_scenarios.json`):
   - Per `postflop-v4.1.4-module2-baseline-migration-plan.md` § 3.
   - Each scenario: choice ids renamed, new fields populated, takeaway added, sizingLogic completed, sourceConfidence kept or downgraded per § 3.6.
   - Production count: 251 (M1) + 24 (v4.1.2 seeds, freshly added) + 11 (migrated) = **286 scenarios**.
5. **Production auditor extension** (in `tools/audit-postflop-ps.ps1`):
   - Port M2.H01–H16 + M2.SC01–SC05 + M2.HC01–HC11 + M2.S01–S04 from the seed auditor.
   - Apply Module 2 rules only to scenarios where `module === 'pf_flop_cbet_ip'`.
   - Target gate: 286 / 0 / 0 (with documented warnings allowed if any).
6. **Audit run gates the merge:**
   - Production auditor: 286 / 0 / 0.
   - Seed auditor (now reading production): 24 + 11 = 35 scenarios / 0 hard errors / N warnings.
7. **GPT review pass** on the migrated 11 scenarios; produce `postflop-v4.1.5-baseline-migration-review.md` with PASS/WARN/FAIL.
8. **Commit + push** as one atomic change.
9. **Stop.** Do not productionize Module 2 in v4.1.5.

After v4.1.5 ships:
- Production gate is 286 / 0 / 0
- Module 2 is `consensus_gto`-quality data in production JSON
- Module 2 is **still not playable** (runtime not wired)
- Curriculum still shows Module 2 as Preview
- Next sprint (v4.1.6+) adds the in-browser auditor extension and concept library expansion
- Sprint after that (v4.1.7+) wires Module 2 into the drill engine

---

## 9. What MUST be true before Module 2 becomes playable

Per `postflop-v4.1.2-module2-architecture.md` § 11 (production readiness criteria), the playable threshold requires **all 10**:

| # | Criterion | Status |
|---|---|---|
| 1 | Architecture + schema docs reviewed | ✅ v4.1.2 + v4.1.4 review |
| 2 | ≥ 20 hand-authored seed scenarios with varied coverage | ✅ 24 seeds + 11 baseline = 35 (after migration) |
| 3 | GPT review pass complete with no critical | ⏸️ pending — package prepared, review not yet run |
| 4 | Audit rule extension shipped covering Module 2 checks | ⏸️ pending v4.1.5 (production auditor extension) |
| 5 | Seed scenarios merged into production JSON | ⏸️ pending v4.1.5 (the merge) |
| 6 | Live `startPostflopDrill('pf_flop_cbet_ip', ...)` enabled | ❌ pending v4.1.7+ runtime patch |
| 7 | Module 2 teaching layer (hand-class chip, hand-aware hint, reason chip) shipped | ❌ pending v4.1.7+ runtime patch |
| 8 | Module 2 weak-spot review variant shipped | ❌ pending v4.1.7+ runtime patch |
| 9 | Concept Library / Concept Drill expanded for Module 2 concepts | ❌ pending v4.1.6+ |
| 10 | Tester pass on a real device | ❌ pending v4.1.7+ |

**v4.1.5 satisfies #4 and #5.**
**v4.1.6 should satisfy #9** (Concept Library / Drill expansion to M2 concepts).
**v4.1.7 satisfies #6, #7, #8, #10** (the runtime patch).

Module 2 becomes playable around v4.1.7 — not earlier. v4.1.4 + v4.1.5 + v4.1.6 are foundational data + audit + concept work.
