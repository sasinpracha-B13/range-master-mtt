# Postflop v4.2.4 — Module 3 Limited Beta Runtime Wire

**Status:** Implemented and shipped.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.3B-module3-data-polish.md`, `postflop-v4.2.3A-module3-data-expansion.md`, `postflop-v4.2.3-module3-migration.md`
**Builds on:** v4.2.3B (Module 3 Data Polish + Thin-Bucket Completion 62→85, commit `e72eef6`)

---

## 1. Goal

Wire Module 3 (Facing C-bet OOP) into runtime as **"Limited Beta · 85 scenarios"** with the full learning loop — start route, question rendering, answer grading, feedback, concept library, weak-spot review, mastery checklist, mobile QA — while preserving M1/M2 behavior. Ship M3 honestly: "Limited Beta," scaled mastery thresholds, no overclaiming.

**Critical constraint:** No new M3 scenarios. No strategy/answer-key/conceptTag changes. No M1/M2 strategy field edits.

---

## 2. Why M3 is ready for Limited Beta

| Health metric | v4.2.3B | Limited Beta target | Status |
|---|---:|---|---|
| Total M3 scenarios | 85 | 80–85 | ✓ at target |
| Distinct boards | 19 | 12+ | ✓ |
| All 9 actionReasons ≥3 | 4 / 5 / 6 / 7 / 9 / 11 / 15 / 19 / 23 | yes | ✓ |
| Difficulty spread | 8 / 59 / 15 / 3 across 2 / 3 / 4 / 5 | yes | ✓ |
| sourceConfidence variety | 70 expert + 15 consensus_gto | yes | ✓ |
| 7 M3-native concepts represented | 5 / 6 / 6 / 11 / 13 / 13 / 19 (any-position) | yes | ✓ |
| Audit gates | 385 / 0 / 0 PASS, R29=0 | clean | ✓ |

---

## 3. Runtime wiring summary

| Layer | Change |
|---|---|
| Scenario pool | NEW `getModule3Scenarios()` filtering `module === 'pf_flop_cbet_oop_def' && auditStatus === 'approved'` |
| Schema normalization | NEW `_pfNormalizePostflopChoices(scenario)` + `_pfNormalizePostflopAnswer(answer)` handle string-form M3 schema and array/object-form M1/M2 schema uniformly |
| Pretty labels | NEW `_PF_M3_ACTION_LABELS` (5 actions) + `_PF_M3_REASON_LABELS` (9 reasons) for human-readable choice rendering |
| Classifier | `classifyPostflopAnswer` now routes through normalizer (works for M3 string-best AND M1/M2 array-best) |
| `_findChoiceLabel` | Routes through normalizer to label string-form M3 choices |
| Drill engine | `startPostflopDrill('pf_flop_cbet_oop_def', N)` — default queue 10, M3 pool only, postflop beta gated |
| Concept drill | `startPostflopConceptDrill(key)` extended for `module: 'm3'` concepts; M3 pool, queue 10 |
| Weak-spot review | `startPostflopWeakSpotReview()` extended to route by previous module (M1/M2/M3 pools never cross-contaminate); M3 weak queue 10 |
| Question prompt | `_pfBuildQuestionPrompt` extended with M3 BB-defending framing — "BB has X on board ... BTN c-bets ~33% pot. What is BB's best action?" — explicitly distinct from M2's "What should BTN do?" |
| Choice guide | `_pfChoiceGuide` extended with `action_choice_m3` + `reason_choice_m3` — different vocabulary from M2 IP-c-bet |
| Question render | `renderPostflopQuestion` detects M3, renders BB hand row with handClass / heroHandRole / drawCategory / showdownValue chips, BB-OOP spot tag row, M3 context label + Limited Beta badge |
| Answer feedback | NEW `_pfM3TeachingFeedbackBlocksHtml(scenario)` — Recommended Action (BB OOP), **Defense Logic** (M3-defining field, prominent), Hand Logic, Sizing Logic, Blocker note, Range Context (collapsed), Takeaway, Common Mistake. Hides empty fields. |
| Concept Library | 10 new M3 concept entries (7 native + 3 alias). NEW M3 group header in `_pfConceptLibraryHtml` |
| Session aggregation | NEW `_pfM3RenderSessionAggregations` — handClass / heroHandRole / actionReason breakdowns. Reuses `_pfM2GroupAnswersBy` (module-agnostic). |
| Mastery checklist | NEW `_pfM3MasteryStats` + `_pfM3MasteryProgressHtml` with Limited Beta thresholds (3 sessions / 75% in 2 / all 9 reasons / weak-review used / no critical) |
| Academy panel | `_pfAcademyHomeHtml` extended to render M3 mastery section below M2 |
| Curriculum card | `_PF_CURRICULUM` m3 entry → status `beta` + 85 scenarios + 8-line syllabus + `▶ Start Module 3 Limited Beta` button |
| TCC tile | `TRAINING_MODES.postflop.actions.m3` flipped from `kind: 'preview'`, `route: null`, `icon: '🔒'` → `kind: 'secondary'`, `route: 'postflop:m3'`, `icon: '🛡️'`, `badge: 'BETA'`, `hint: '85 OOP defense scenarios · Limited Beta'` |
| Route | NEW `case 'postflop:m3'` in `runTrainingModeAction` → `startPostflopDrill('pf_flop_cbet_oop_def', 10)` (gated by Postflop Beta toggle) |
| Module status | `_pfModuleStatus('m3')` → `'beta'` (was `'locked'`) |
| Concept Library hint | "15" → "25" (10 M1 + 5 M2 + 10 M3) |
| Renderer label updates | `renderPostflopComplete` / question screen / answer screen all show "🛡️ Module 3 · BB Defense OOP · Limited Beta" context label |

---

## 4. Schema normalization — M1/M2 vs M3

| Field | M1 / M2 schema | M3 schema | Normalizer output |
|---|---|---|---|
| `question.choices` | `[{id, label}, ...]` | `["fold", "call", "check_raise_small", ...]` | always `[{id, label}, ...]` |
| `answer.best` | `["bet_small"]` (array) | `"call"` (string) | always `[string]` (array) |
| `answer.acceptable/bad/critical` | `[string]` | `[string]` (already array) | passthrough |

The 2 normalization helpers are pure functions and never mutate source data. M1/M2 grading + rendering are byte-identical because passthrough preserves their shapes.

---

## 5. M3 route behavior

```
Training Command Center → Postflop mode → tap "Module 3 · BB Defense OOP · BETA"
  ↓
runTrainingModeAction('postflop', 'm3')
  ↓ checks postflopBeta gate
  ↓ on
startPostflopDrill('pf_flop_cbet_oop_def', 10)
  ↓
filters approved M3 scenarios → 85
  ↓ buildPostflopQueue(history-aware, capped at 10)
App.state.postflopDrill = { active: true, module: 'pf_flop_cbet_oop_def', queue, ... }
  ↓
showPostflopScreen() + renderPostflopQuestion()
```

Default session length 10 (vs M1=15, M2=12) — shorter to keep mobile sessions tight while content matures during Limited Beta.

---

## 6. M3 question rendering (BB OOP framing)

| Element | Behavior |
|---|---|
| Context label | `🛡️ Module 3 · BB Defense OOP · Limited Beta · Q N/10` |
| Spot tags | `100BB`, `BB (hero, OOP)`, `BTN (villain, IP)`, `SRP`, `cbet small` |
| Hero hand section | "Your Hand (BB)" — BB-explicit framing distinct from M2's "Hero Hand" |
| Hand chips | handClass + heroHandRole + drawCategory + showdownValue (4-axis chip row when populated) |
| Board section | board cards + pattern label + hint (board-only checklist suppressed for hand-aware modules) |
| Question prompt | "BB has [hero] on [board] (BTN open 2.5x, BB call, 100BB SRP). BTN c-bets ~33% pot. What is BB's best action?" |
| Choice guide | M3-flavored `action_choice_m3` summary + collapsible details (5 actions explained from BB-OOP angle) |
| Choices | 5 buttons rendered from M3's string-form choices via normalizer + `_PF_M3_ACTION_LABELS` |

For `reason_choice` scenarios, the prompt prefers the data prompt (which already commits the action context) and falls back to "BB chooses to [action]. What is the primary reason?" The 9 reason buttons render via `_PF_M3_REASON_LABELS`.

---

## 7. M3 feedback rendering

`_pfM3TeachingFeedbackBlocksHtml` produces the following block sequence (each hidden if source field empty):

1. **Result row** — ✅ BEST / ≈ ACCEPTABLE / ❌ BAD / 🚨 CRITICAL with score + your-pick + GTO-best
2. **Short explanation** — `explanation.short` (one-line takeaway)
3. **🛡️ Recommended Action (BB OOP)** — pretty action label + reason chip
4. **🎯 Defense Logic** — prominent (M3-defining field; highlights the OOP defense math)
5. **Hand Logic** — strategic frame for THIS hand
6. **Sizing Logic** — when raising, sizing rationale
7. **🃏 Blocker note** — when `scenario.blockerNote` populated (M3 leverages blockers heavily)
8. **Range / Board Context** — collapsed by default (broader frame)
9. **💡 Takeaway** — one-sentence pattern note
10. **⚠️ Common Mistake** — only when populated; auto-opened on critical leaks
11. **Concept tags** — chip row

---

## 8. M3 Concept Library integration

10 M3 concept entries added to `_PF_CONCEPT_LIBRARY` (each carries `module: 'm3'`, `previewOnly: false`):

**7 native concepts:**
1. oop_defense_threshold
2. check_raise_value
3. check_raise_bluff
4. bluff_catchers
5. equity_realization_oop
6. range_disadvantage
7. pot_odds_defense

**3 alias concepts (M3-flavored OOP raise framing):**
8. value_raise
9. protection_raise
10. semi_bluff_raise

Renders as a 3rd group in `_pfConceptLibraryHtml`: **Module 3 — BB Defense OOP (10 · Limited Beta)**. Each card has a working "🎯 Drill this concept" button calling `startPostflopConceptDrill(key)`. M3 concept drills:
- filter to `pf_flop_cbet_oop_def` pool
- queue length 10
- never mix with M1/M2 concept drills
- review-signal pill fires when concept is in latest session's weak fingerprint

---

## 9. M3 weak-spot review behavior

`startPostflopWeakSpotReview` extended:
- routes by previously-played module (M1 / M2 / M3 pools never cross-contaminate)
- M3 weak queue length 10
- empty-state fallback: when no prior M3 session has any bad/critical answers, `_pfCurrentSessionWeakProfile` returns null → falls back to a normal M3 drill in the same module
- when no live session is in progress + no M3 history exists, the toast / fallback prevents broken empty-state crashes

---

## 10. M3 Limited Beta mastery thresholds (display only)

Scaled vs M1's full-module thresholds — 5 criteria, lower bar to match the 85-scenario beta scope:

1. **Complete 3 Module 3 sessions** (vs 5 for M1/M2)
2. **Hit 75%+ quality in 2 M3 sessions** (vs 80% in 3)
3. **See all 9 M3 actionReasons at least once** — derived live by scanning M3 session answers + cross-referencing scenario.actionReason
4. **Engage with M3 weak-spot review at least once** (after mistakes exist)
5. **No critical leaks in latest M3 session**

Title: "🛡️ Module 3 Limited Beta progress (display only)" — explicitly NOT "Module 3 mastery." Honest copy reinforces the Limited Beta framing.

---

## 11. QA results

### 11.1 Desktop QA (1280×800)

| Check | Result |
|---|---|
| App loads, 0 console errors | ✓ |
| TCC shows M3 tile with BETA badge + 🛡️ icon + Limited Beta hint | ✓ |
| Click M3 tile starts session | ✓ |
| Session has 10 questions | ✓ |
| Question renders board + hero hand + 5 choices | ✓ |
| All 5 actions selectable + grade correctly | ✓ (verified 10 spot-checks) |
| Grading handles M3 string-best | ✓ |
| Feedback shows defenseLogic | ✓ (rendered in test) |
| Concept Library M3 grouping renders 10 concepts | ✓ |
| M3 concept drill starts with M3 pool | ✓ (oop_defense_threshold drill = 10 M3 questions) |
| M3 mastery checklist renders with Limited Beta thresholds | ✓ |
| Weak-spot empty state works (falls back to normal drill) | ✓ |
| M1 still works | ✓ (regression-tested classifier + choices) |
| M2 still works | ✓ (regression-tested classifier + choices) |
| Browse / Preflop unchanged | ✓ (no edits to those code paths) |

### 11.2 Mobile 375×812 QA

| Check | Result |
|---|---|
| No horizontal overflow | ✓ (TCC + question/answer screens both fit) |
| TCC M3 tile readable | ✓ (tile shows label + hint + BETA badge cleanly) |
| Session question readable | ✓ (board cards + hero cards + spot tags all wrap properly) |
| 5 choices tappable | ✓ |
| Feedback panel not cramped | ✓ (M3 teaching blocks stack vertically; collapsibles work) |
| Hand chips wrap cleanly | ✓ (4-chip row wraps at narrow viewport) |
| Bottom nav not overlapped | ✓ |
| Install banner safe-area unchanged | ✓ (no edits to install banner CSS) |

### 11.3 Poker learning-product QA (10 M3 scenarios)

| # | Theme | Best | Score | Defense Logic? | Verdict |
|---|---|---|---|---|---|
| 1 | fold range_disadvantage (KQ on As9s4d) | fold | 1.00 BEST | ✓ | correct |
| 2 | fold domination (QJ on Ks8s3d) | fold | 1.00 BEST | ✓ | correct |
| 3 | call equity_realization (Th8h on As8d3h) | call | 1.00 BEST | ✓ | correct |
| 4 | call bluff_catch (55 on 8c8d3s) | call | 1.00 BEST | ✓ | correct |
| 5 | crs value top set (99 on Kh9c4s) | check_raise_small | 1.00 BEST | ✓ | correct |
| 6 | crs protection (TT top set on Ts9s5d) | check_raise_small | 1.00 BEST | ✓ | correct |
| 7 | crb made flush low monotone (8s6s on 7s5s3s) | check_raise_big | 1.00 BEST | ✓ | correct |
| 8 | crb nut flush monotone (AhKh on Jh8h4h) | check_raise_big | 1.00 BEST | ✓ | correct |
| 9 | slowplay trips paired-A (Ah7h on AcAd7s) | call | 1.00 BEST | ✓ | correct |
| 10 | reason_choice blocker_raise (AsKh on 7s5s3s) | blocker_raise | 1.00 BEST | ✓ | correct |

Plus regression: 1 M1 (range_advantage) + 1 M2 (action_choice) both grade BEST 1.00 with normalizer passthrough.

**0 spot-check FAILs.**

---

## 12. Audit results (final)

| Audit | Result |
|---|---|
| Production audit | **385 / 0 / 0** PASS |
| R29 card-notation guard | **0 warnings** |
| M2 seed audit | PASS (8 warnings, unchanged) |
| M3 seed audit | 24 / 0 / 0 PASS clean (unchanged — original v4.2.0 planning seeds) |
| Text integrity (postflop_scenarios.json) | thai=0 repl=0 |
| Text integrity (index.html) | 19 thai chars (all 19 pre-existing legitimate content: user-feedback comment + mojibake-doc examples) — **0 NEW mojibake introduced by v4.2.4 edits** |

---

## 13. Files modified

| File | Type of change |
|---|---|
| `index.html` | +798 lines (M3 wiring across 6 batches: helpers, drill, render, concept lib, mastery, TCC); -61 lines (replaced preview-only m3 entry, expanded concept library hint, etc.) |
| `service-worker.js` | 1 line (VERSION `v4.2.3B` → `v4.2.4`) |
| `docs/specs/postflop-v4.2.4-module3-limited-beta-wire.md` | NEW (this document) |
| `PROJECT_STATE.md` | sprint status update |
| `TASK_BOARD.md` | task close-out |
| `GPT AUDIT/v4.2.4/` | NEW snapshot |

**Forbidden files untouched:**
- `postflop/postflop_scenarios.json` byte-identical
- `postflop/postflop_concepts.json` byte-identical
- `postflop/postflop_taxonomy.json` byte-identical
- `tools/audit-postflop-ps.ps1` byte-identical
- `tools/audit-postflop-module3-seed.ps1` byte-identical
- `ranges.json`, `manifest.json` byte-identical
- preflop / gamification / shop / wardrobe / field-fx systems byte-identical
- M1 / M2 scenario strategy fields byte-identical

---

## 14. Known limitations

1. **Limited Beta volume (85 scenarios).** Per-concept primary-tag depth is healthy (5–13 per native concept) but still below the M1 standard of 30+. Mastery thresholds are scaled accordingly.
2. **No `consensus_gto` promotion for M3 v4.2.4.** All 15 M3 consensus_gto promotions happened in v4.2.3B; v4.2.4 doesn't promote any new ones. Future v4.2.5+ can promote more after solver review.
3. **`reason_choice` only 12 of 85 (14%).** Most M3 sessions will be action_choice. Reason_choice volume is intentional minority but could be expanded in future polish.
4. **M3 weak-spot review draws from the v4.0.12 `_pfCurrentSessionWeakProfile` engine** — this is M1-tuned. M3-specific weak-spot routing (by actionReason / heroHandRole) could be added in a future sprint; for v4.2.4 the generic profile is sufficient.
5. **Critical-mistake distribution is heavily `check_raise_big`** (most fold scenarios mark big-raise as critical). This is acceptable for Limited Beta but a future polish pass could rebalance.
6. **M3 mastery threshold #3 (all 9 actionReasons)** requires the player to encounter scenarios across many sessions. With 85 scenarios and a 10-question session, this typically takes 3–4 sessions to satisfy organically. Acceptable for Limited Beta scope.

---

## 15. Recommended next sprint

After v4.2.4 ships:

**Option A — `v4.2.5` UI Polish** (recommended): collect early-user feedback on the M3 Limited Beta and fix the highest-impact UX issues. Likely candidates: rebalance critical-mistake distribution, surface actionReason-keyed weak-spot review, polish mobile chip wrapping at extreme widths, add a "Why is BB out of position?" explainer for new learners.

**Option B — `v4.2.6` content expansion** (optional): add 15–20 more M3 scenarios to push past 100 toward "stable beta" thresholds. Focus on `reason_choice` depth (currently 14% of M3) and additional `consensus_gto` promotions.

**Option C — `v4.3.0` Module 4 (Turn Strategy)**: declare M3 stable enough to leave Limited Beta as-is and move forward. The TRAINING_MODES + concept library + mastery patterns are now reusable for any future module.

**Recommended:** Option A — give Limited Beta breathing room before adding more content.

---

## 16. Sign-off checklist

- [x] M3 tile in TCC: kind=secondary, route=postflop:m3, BETA badge, 🛡️ icon, "85 OOP defense scenarios · Limited Beta" hint
- [x] postflop:m3 route added to runTrainingModeAction
- [x] startPostflopDrill('pf_flop_cbet_oop_def', 10) wired
- [x] String-form choices render correctly
- [x] String-form answer.best grades correctly
- [x] M3 feedback shows defenseLogic prominently
- [x] M3 Concept Library group renders 10 concepts (7 native + 3 alias)
- [x] M3 concept drill works (oop_defense_threshold tested → 10 M3 questions)
- [x] M3 weak-spot review extended for M3 module pool
- [x] M3 Limited Beta mastery checklist renders with scaled thresholds (3/2/9/weak/critical)
- [x] M3 session aggregation by handClass / heroHandRole / actionReason
- [x] Curriculum card shows "▶ Start Module 3 Limited Beta" with Beta status
- [x] Module status m3 → 'beta'
- [x] Concept Library hint "Browse 25 concept drills"
- [x] M1 unchanged; M2 unchanged
- [x] Desktop QA clean
- [x] Mobile 375 QA clean (no overflow)
- [x] 12-scenario poker QA: all 12 PASS (10 M3 + 1 M1 + 1 M2 regression)
- [x] Production audit 385/0/0; R29=0
- [x] Text integrity: 0 NEW mojibake
- [x] appVersion + SW VERSION = 4.2.4 / v4.2.4
- [x] No forbidden files modified
- [x] Documentation complete
- [x] v4.2.5 not started

**Status: SHIPPED.**
