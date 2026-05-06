# Postflop v4.2.2B — Module 3 Post-Commit Raw Verification + Migration Readiness Gate

**Status:** Verification + repair sprint. Validates v4.2.2 claims against raw seed JSON. **3 defects found and fixed in-place.** All v4.2.2 strategic claims confirmed correct after repairs. **Migration readiness: Path A — proceed to v4.2.3 with documented training-volume caveat.**
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.2-module3-final-review.md`, `postflop-v4.2.1-module3-seed-review.md`, `postflop-v4.2.0-module3-architecture.md`, `postflop-v4.2.0-module3-schema-taxonomy.md`, `postflop-v4.2.0-module3-audit-plan.md`, `postflop-v4.2.0-module3-seed-scenarios.json`

---

## 1. Files inspected

| # | File | Status |
|---|---|---|
| 1 | `docs/specs/postflop-v4.2.0-module3-seed-scenarios.json` | inspected; 2 scenarios + summary block repaired |
| 2 | `docs/specs/postflop-v4.2.2-module3-final-review.md` | inspected; claims verified |
| 3 | `docs/specs/postflop-v4.2.1-module3-seed-review.md` | inspected; cross-checked v4.2.1 fixes still hold |
| 4 | `docs/specs/postflop-v4.2.0-module3-gpt-review-package.md` | inspected; review prompts cross-checked |
| 5 | `docs/specs/postflop-v4.2.0-module3-architecture.md` | inspected; reason set §6 verified post-v4.2.2 |
| 6 | `docs/specs/postflop-v4.2.0-module3-schema-taxonomy.md` | inspected; reason set §5 verified |
| 7 | `docs/specs/postflop-v4.2.0-module3-audit-plan.md` | inspected; M3-R19/R20 verified |
| 8 | `tools/audit-postflop-module3-seed.ps1` | inspected; `$validReasons` verified |

---

## 2. Raw verification result

### 2.1 Per-scenario mechanical validity

All 24 scenarios pass:
- Valid board cards (3 each) ✓
- Valid hero hand (2 each) ✓
- No board/hero card collision ✓
- module = `pf_flop_cbet_oop_def` ✓ (24/24)
- spot.villainAction = `cbet` ✓ (24/24)
- spot.villainSizing = `small` ✓ (24/24)
- question.qtype valid ✓
- choices subset rules satisfied ✓
- answer.best in choices ✓
- acceptable/bad/critical partitions clean (no overlap; critical ⊆ bad) ✓
- recommendedAction aligns with answer.best (action_choice scenarios) ✓
- actionReason in current 9-value M3 reason vocabulary ✓
- handClass / heroHandRole / drawCategory / showdownValue all valid ✓
- conceptTags non-empty + valid ✓
- auditStatus = `planning_only` ✓ (24/24)
- reviewStatus = `v4.2.0_final` ✓ (24/24)

**M3 seed audit final: 24 / 0 hard errors / 0 warnings = PASS clean.**

---

## 3. Claim verification table (v4.2.2 report vs raw JSON)

| Claim | Source | Raw JSON state | Verdict |
|---|---|---|---|
| F1.3 critical=[semi_bluff_raise] | v4.2.2 §3 fix #1 | `critical: [semi_bluff_raise]`, sizingLogic explicitly says "raising as a semi-bluff is too thin OOP" | ✅ MATCH |
| F5.3 critical=[semi_bluff_raise], blocker_raise acceptable | v4.2.2 §3 fix #2 | `critical: [semi_bluff_raise]`, `acceptable: [blocker_raise]`, sizingLogic distinguishes call(ER) vs raise(blocker) | ✅ MATCH |
| F6.2 best=call, slowplay_call reason | v4.2.2 §3 fix #3 | `best: call`, `recommendedAction: call`, `actionReason: slowplay_call`, `acceptable: [check_raise_small]`, `critical: [fold]`, explanation rewritten for slowplay framing | ✅ MATCH |
| F6.2 conceptTags consistent with slowplay lesson | implied by v4.2.2 brief | **`[check_raise_value, value_raise]`** — implies check-raise is primary lesson | ❌ **DEFECT** (fixed below) |
| F3.3 acceptable: [protection_raise, equity_realization_call] | v4.2.1/v4.2.2 retained | confirmed `[protection_raise, equity_realization_call]` | ⚠️ AMBIGUOUS — explanation never frames protection as benefit; project-owner default = remove (fixed below) |
| F5.4 reason kept range_disadvantage_fold, no RIO | v4.2.2 §4 | `actionReason: range_disadvantage_fold`, no reverse_implied_odds_fold in vocab | ✅ MATCH |
| F6.4 best=fold, call acceptable, critical=check_raise_big | v4.2.2 §6 | confirmed exactly | ✅ MATCH |
| slowplay_call vocab in 5 locations | v4.2.2 §2.2 | **all 5 verified**: auditor `$validReasons`, architecture §6, schema-taxonomy §5, audit-plan M3-R19+R20, final review doc | ✅ MATCH |
| All 24 reviewStatus = v4.2.0_final | v4.2.2 §9 | confirmed 24/24 | ✅ MATCH |
| Summary metadata block matches reality | implied | **STALE — reflects v4.2.0 state, not post-v4.2.2** | ❌ **DEFECT** (fixed below) |

**Aggregate: 7 of 10 claims verified clean. 3 defects found.**

---

## 4. F1.3 decision

**Verdict: KEEP v4.2.2 fix as-is. No further change.**

`critical: [semi_bluff_raise]` is justified by:
- sizingLogic: "Calling sees a cheap turn; raising as a semi-bluff is too thin OOP because villain's value calls dominate."
- commonMistake: "Check-raising wheel gutshots OOP looks creative but bleeds chips long-term."
- The takeaway "OOP draws on dry boards prefer call over raise" generalizes the lesson.

The UN-soften from v4.2.1's overly-generous removal of critical was the right call. Raising 5h4h on dry A-high vs ~33% c-bet is near-zero solver frequency (≤3%); flagging it as critical teaches the discipline cleanly.

---

## 5. F5.3 decision

**Verdict: KEEP v4.2.2 fix as-is. No further change.**

`critical: [semi_bluff_raise]` is justified by the conceptual distinction:
- F5.3 is a `reason_choice` scenario asking "What is the primary reason for **calling** Kh-Qc on monotone J-8-4?"
- Choosing `semi_bluff_raise` as the answer means the player is selecting a *raise reason* to explain a *call decision* — that's conceptual confusion.
- The raise option DOES exist on this hand (`blocker_raise` is correctly in `acceptable`), but its reason is *blocker pressure*, not *semi-bluff*.
- sizingLogic explicitly distinguishes: "Calling realizes equity at minimum cost; raising as a blocker bluff is acceptable but bloats OOP into Ah-x flushes."

Picking `semi_bluff_raise` here genuinely indicates the player doesn't understand which combo is what — critical is appropriate.

---

## 6. F6.2 slowplay_call verification

### 6.1 Raw scenario state (post-v4.2.2)

| Field | Value |
|---|---|
| `answer.best` | `call` ✓ |
| `recommendedAction` | `call` ✓ |
| `actionReason` | `slowplay_call` ✓ |
| `answer.acceptable` | `[check_raise_small]` ✓ |
| `answer.bad` | `[fold, check_raise_big, mixed]` ✓ |
| `answer.critical` | `[fold]` ✓ |
| `explanation.short` | "Trip K, nut kicker on paired board - slowplay to keep bluffs in." ✓ |
| `explanation.takeaway` | "Trip K + nut kicker on paired-K = slowplay (raise acceptable)." ✓ |
| **`conceptTags` (BEFORE v4.2.2B fix)** | **`[check_raise_value, value_raise]`** ❌ |
| **`conceptTags` (AFTER v4.2.2B fix)** | **`[bluff_catchers, pot_control, value_raise]`** ✅ |

### 6.2 Defect explanation

The v4.2.2 sprint flipped F6.2's best action from `check_raise_small` → `call` and changed the reason to `slowplay_call`, but **never updated the conceptTags**. The legacy tags `check_raise_value` and `value_raise` (carried over from v4.2.0 when best was raise) misleadingly imply check-raise is the primary lesson. Per the v4.2.2B brief: "conceptTags do NOT misleadingly imply check-raise is the primary lesson."

### 6.3 Fix applied

`conceptTags: [check_raise_value, value_raise] → [bluff_catchers, pot_control, value_raise]`

Reasoning:
- **`bluff_catchers`** (M3 native) — slowplaying nuts to keep villain's bluffs in is structurally a bluff-catch dynamic (let the bluff in, beat it).
- **`pot_control`** (M2 reusable) — slowplaying preserves pot size for value extraction over multiple streets.
- **`value_raise`** (M2 reusable) — kept as a tertiary tag because the *acceptable* raise option does target value; tag remains relevant but no longer primary.

The first tag (primary) is now `bluff_catchers`, matching the slowplay teaching focus.

### 6.4 Vocabulary consistency check (slowplay_call across 5 locations)

| Location | Mention | Status |
|---|---|---|
| `tools/audit-postflop-module3-seed.ps1` | `$validReasons += slowplay_call` | ✅ present |
| `docs/specs/postflop-v4.2.0-module3-architecture.md` §6 | reason table row + body text | ✅ present |
| `docs/specs/postflop-v4.2.0-module3-schema-taxonomy.md` §5 | reason table row | ✅ present |
| `docs/specs/postflop-v4.2.0-module3-audit-plan.md` M3-R19/R20 | enumeration | ✅ present |
| `docs/specs/postflop-v4.2.2-module3-final-review.md` | per-scenario discussion | ✅ present |
| **Raw seed JSON F6.2 actionReason** | `slowplay_call` | ✅ present |
| **Summary metadata byActionReason** | (initially missing — pre-v4.2.2B) → `slowplay_call: 1` (post-v4.2.2B) | ✅ fixed |

**`slowplay_call` is consistent across all 6 locations after v4.2.2B repair.**

---

## 7. F3.3 acceptable reason decision

### 7.1 Defect explanation

After v4.2.1 the F3.3 acceptable list was `[protection_raise, equity_realization_call]`. The v4.2.2B brief default says: "Remove `protection_raise` if it adds noise. Keep it only if explanation clearly frames protection/denial as a secondary benefit of the semi-bluff raise."

Reading F3.3's full explanation:
- handLogic: "Td9d has open-ender to 6 or J, plus T/9 overs and a backdoor diamond." → no mention of protection
- sizingLogic: "Small raise as semi-bluff applies fold equity now and sets up a barrel on the right turns." → no mention of protection
- commonMistake: "Just calling with strong combo draws OOP misses fold equity vs villain's air." → no mention of protection

Protection (denying equity to a made hand) doesn't apply here because **Td9d has no made hand to protect.** It's a pure draw. The explanation correctly never invokes protection. The acceptable=[protection_raise] is noise.

### 7.2 Fix applied

`acceptable: [protection_raise, equity_realization_call] → [equity_realization_call]`
`bad: [...] → [..., protection_raise]` (moved from acceptable to bad — protection_raise is now bad, not acceptable, since it doesn't fit Td9d's profile)

This sharpens the teaching: the only acceptable alternative reason for raising Td9d is `equity_realization_call` (player rationalizing as "I'm calling for equity" — second-best read but defensible). `protection_raise` is now correctly flagged as bad reasoning.

---

## 8. Summary metadata consistency result

### 8.1 Defect explanation

The `summary` block at the bottom of the seed JSON was **hand-written in v4.2.0** and never updated through v4.2.1 or v4.2.2. After v4.2.1 (F6.1 actionReason flip) and v4.2.2 (F6.2 best+reason flip + slowplay_call introduction + 24 reviewStatus flips), the summary became significantly out of sync.

### 8.2 Defects in pre-v4.2.2B summary

| Field | Stale value | Recomputed truth | Delta |
|---|---|---|---|
| `byBestAction.call` | 10 | 11 | +1 (F6.2 flip) |
| `byBestAction.check_raise_small` | 7 | 6 | -1 (F6.2 flip) |
| `byActionReason.value_raise` | 4 | 4 | (was wrong in v4.2.0 too — actually 5 then; offsetting error from v4.2.2's -1 brings it to 4) |
| `byActionReason.equity_realization_call` | 9 | 8 | -1 (F6.1 v4.2.1 flip) |
| `byActionReason.bluff_catch` | 1 | 2 | +1 (F6.1 v4.2.1 flip) |
| `byActionReason.slowplay_call` | (missing) | 1 | NEW (F6.2 v4.2.2) |
| `byActionReason.blocker_raise_acceptable_only` | 1 | (removed) | not actually an actionReason; was a v4.2.0 placeholder |
| `byReviewStatus.v4.2.0_seed_candidate` | 24 | 0 | -24 (all flipped through v4.2.1 → v4.2.0_seed_reviewed → v4.2.2 → v4.2.0_final) |
| `byReviewStatus.v4.2.0_final` | (missing) | 24 | NEW |

### 8.3 Fix applied

Recomputed the entire `summary` block from the actual scenarios. Final summary block now includes a `metadataRecomputedAt: 2026-05-06_v4.2.2B` field as a freshness marker, so future sprints can tell at a glance whether the summary is current.

### 8.4 Final recomputed summary block

| Field | Value |
|---|---|
| `totalScenarios` | 24 |
| `byBoardFamily` | 6 keys × 4 each = 24 |
| `byQuestionType.action_choice` | 18 |
| `byQuestionType.reason_choice` | 6 |
| `byBestAction.fold` | 6 |
| `byBestAction.call` | 11 (7 action + 3 ER reason + 1 BC reason; SP reason is a call) |
| `byBestAction.check_raise_small` | 6 (4 action + 2 SB reason) |
| `byBestAction.check_raise_big` | 1 |
| `byBestAction.mixed` | 0 |
| `byActionReason.equity_realization_call` | 8 |
| `byActionReason.value_raise` | 4 |
| `byActionReason.range_disadvantage_fold` | 5 |
| `byActionReason.semi_bluff_raise` | 2 |
| `byActionReason.protection_raise` | 1 |
| `byActionReason.bluff_catch` | 2 |
| `byActionReason.domination_fold` | 1 |
| `byActionReason.slowplay_call` | 1 |
| `byAuditStatus.planning_only` | 24 |
| `byReviewStatus.v4.2.0_final` | 24 |
| `metadataRecomputedAt` | `2026-05-06_v4.2.2B` |

All counts verified by independent recompute matching the auditor output.

---

## 9. Training volume assessment

### 9.1 Per-question answers (the brief's 11 questions)

| # | Question | Answer | Justification |
|---|---|---|---|
| 1 | Is 24 enough for planning final lock? | **YES** | That was the v4.2.2 goal; achieved cleanly. |
| 2 | Is 24 enough for migration into production data as review_pending/approved? | **YES, conditionally** | Acceptable only if Module 3 stays NOT playable until expansion. Migration unlocks production-audit testing of M3 schema rules. |
| 3 | Is 24 enough for a playable beta? | **NO** | Below the 40–60 minimum. Each board only seen 4 times → repeat risk after 2–3 sessions. |
| 4 | Should v4.2.4 playable beta proceed with only 24 scenarios? | **NO — must label as Limited Beta OR delay until expansion** | Honest UX requires explicit "BETA · 24 scenarios" labeling and scaled mastery promises. Better to expand first. |
| 5 | Recommended minimum for M3 Limited Beta | **40–60 scenarios** | Per Training Quality principle. |
| 6 | Recommended for healthy M3 Beta | **60–100 scenarios** | Per Training Quality principle. |
| 7 | Recommended for stable M3 | **100–150+ scenarios** | Mirrors M2 trajectory. |
| 8 | Which board families need expansion? | **All 6 (each currently 4 scenarios; target 6–10 per family for healthy)** | Particularly: Dry A-high (no semi-bluff seed), Paired (only 1 slowplay seed). |
| 9 | Which action reasons need expansion? | **`slowplay_call` (1), `protection_raise` (1), `domination_fold` (1), `bluff_catch` (2)** | All severely underrepresented; need 4–6 each for solid teaching. |
| 10 | Which conceptTags need ≥8–12 primary-tag scenarios? | **`pot_odds_defense` (0), `check_raise_bluff` (2), `check_raise_value` (3 — F6.2 removed it as primary in v4.2.2B), `bluff_catchers` (5 after F6.2 retag), `range_disadvantage` (6)** | Only `equity_realization_oop` (8) is at threshold. |
| 11 | v4.2.3: migrate 24 only, or insert v4.2.3A expansion first? | **Migrate 24 in v4.2.3 → expand in v4.2.3A or v4.3.0 BEFORE v4.2.4** | Migration should not wait — it unlocks production-audit verification of M3 R29-R40 rules. Expansion comes after migration but before runtime wire. |

### 9.2 Training Quality + Volume principle aggregate verdict

**Module 3 v4.2.0_final state: ACCEPTABLE for planning lock; ACCEPTABLE for production migration as planning data; NOT YET ACCEPTABLE for stable runtime exposure.**

**Recommended sprint sequence after v4.2.2B:**
- v4.2.3 — Migrate 24 seeds to production (auditStatus=review_pending → approved per-seed). Add 7 M3 concepts to concepts.json. Add 2 new heroHandRole values to taxonomy.json. Extend production auditor with R29-R40. Bump appVersion + SW. Production audit raises 300/0/0 → 324/0/0. **No runtime wire.**
- **v4.2.3A — Module 3 Data Expansion (NEW SUGGESTED SPRINT)** — add 16-24 new M3 scenarios targeting the depth gaps in §9.1 question 9-10. Target post-expansion total: 40-48 scenarios. Mirrors v4.1.9's expansion-after-migration pattern from M2.
- v4.2.4 — Module 3 playable beta runtime wire (parallel to v4.1.7 for M2). Label clearly as "BETA" or "LIMITED BETA" depending on whether v4.2.3A landed.

---

## 10. Migration readiness decision

### 10.1 Path evaluation

| Path | Description | Verdict |
|---|---|---|
| **A — Proceed to v4.2.3 migration** | raw JSON matches claims, summary fixed, audit clean, vocab consistent, training volume documented | **CHOSEN** ✅ |
| B — Run v4.2.3A data expansion before migration | only if 24 too thin for next UX step | Rejected — migration is needed first to unlock production-audit testing of M3 rules; expansion is cleaner against production data. |
| C — Repair before migration | only if mismatches remain | Was the state at start of v4.2.2B; **resolved by 3 fixes in this sprint**. |

### 10.2 Path A justification

After the 3 v4.2.2B fixes (F6.2 conceptTags, F3.3 acceptable, summary metadata recompute):
- ✅ Raw JSON matches all v4.2.2 claims
- ✅ Summary metadata fully synced with actual scenarios
- ✅ M3 seed audit passes 24 / 0 hard / 0 warnings
- ✅ slowplay_call vocab consistent across 6 locations (auditor + 4 docs + JSON)
- ✅ Training volume caveat clearly documented (this doc §9)
- ✅ All 24 scenarios at reviewStatus = v4.2.0_final

**Migration to production data (v4.2.3) is GREEN-LIT** with the explicit constraint that:
- v4.2.3 is migration only (data + concepts + taxonomy + audit-extension, plus appVersion/SW bump for cache invalidation)
- v4.2.3 does NOT runtime-wire M3
- v4.2.4 (playable beta) MUST NOT proceed until either (a) v4.2.3A expansion brings M3 to ≥40 scenarios, OR (b) UI explicitly labels M3 as "Limited Beta · 24 scenarios" with scaled mastery expectations

---

## 11. Fixes applied in v4.2.2B (3 in-place edits)

| # | Target | Change |
|---|---|---|
| 1 | F6.2 (`KcKd7s_m3_action_AhKh_v420`) `conceptTags` | `[check_raise_value, value_raise] → [bluff_catchers, pot_control, value_raise]` (slowplay lesson primary; value_raise kept as tertiary for acceptable raise option) |
| 2 | F3.3 (`8s7d5h_m3_reason_Td9d_v420`) `answer.acceptable` + `answer.bad` | `acceptable: [protection_raise, equity_realization_call] → [equity_realization_call]`; `protection_raise` moved to `bad` (no made hand to protect — Td9d is pure draw) |
| 3 | Top-level `summary` block | Full recompute: byBestAction (call:11/check_raise_small:6 — fixed F6.2 flip impact); byActionReason (equity_realization_call:8/bluff_catch:2/slowplay_call:1/dropped blocker_raise_acceptable_only); byReviewStatus (v4.2.0_final:24); added `metadataRecomputedAt: 2026-05-06_v4.2.2B` freshness marker |

No vocabulary additions or removals. No new auditor rules. No changes to any other scenario. No production-data files touched.

---

## 12. Audit + verification gate summary

| Gate | Pre-v4.2.2B | Post-v4.2.2B | Status |
|---|---|---|---|
| Production audit | 300 / 0 / 0 | 300 / 0 / 0 | ✅ unchanged |
| M2 seed audit | 24 PASS / 0 hard / 8 warnings | 24 PASS / 0 hard / 8 warnings | ✅ unchanged |
| M3 seed audit | 24 / 0 hard / 0 warnings | **24 / 0 hard / 0 warnings** | ✅ clean (post-fixes) |
| F6.2 conceptTags consistent | ❌ misleading | ✅ matches slowplay lesson | repaired |
| F3.3 acceptable matches explanation | ⚠️ noisy | ✅ tight | repaired |
| Summary metadata block | ❌ stale (v4.2.0) | ✅ recomputed (v4.2.2B) | repaired |
| slowplay_call vocab in 6 locations | ✅ already consistent | ✅ confirmed | unchanged |
| All 24 reviewStatus = v4.2.0_final | ✅ already set | ✅ confirmed | unchanged |

---

## 13. Sign-off

**Verification complete. 3 defects in v4.2.2 outputs identified and repaired in-place. All v4.2.2 strategic claims verified correct. Module 3 seed JSON is clean, internally consistent, and matches all referenced docs.**

**Migration to v4.2.3 is GREEN-LIT.** Honest training-volume disclosure documented for v4.2.4 playable-beta planning: a v4.2.3A data expansion sprint is recommended between v4.2.3 (migration) and v4.2.4 (runtime wire) to bring M3 from 24 → 40+ scenarios. If v4.2.3A is skipped, v4.2.4 must label M3 as "Limited Beta" with clear UX caveats.

**v4.2.2B deliberately did NOT:**
- Productionize M3 (no scenarios in `postflop/postflop_scenarios.json`)
- Add M3 concepts to `postflop/postflop_concepts.json`
- Add new heroHandRole values to `postflop/postflop_taxonomy.json`
- Bump appVersion or service-worker VERSION
- Touch any runtime file
- Modify M2 seed auditor or production auditor
- Add any new vocabulary (slowplay_call was already present from v4.2.2)
- Start v4.2.3 migration work
