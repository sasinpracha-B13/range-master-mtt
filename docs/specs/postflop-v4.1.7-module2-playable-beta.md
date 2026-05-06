# Postflop v4.1.7 — Module 2 Playable Beta

**Status:** Module 2 is **playable**. All 22 pre-commit gates pass. 35/35 browser QA pass. Awaiting commit/push.
**Date:** 2026-05-05
**Companion to:** `postflop-v4.1.7-final-gpt-review-of-seeds.md`, `postflop-v4.1.6-concept-library-module2-bridge.md`, `postflop-v4.1.5-baseline-migration-review.md`, `postflop-v4.1.2-module2-architecture.md`

---

## 1. Objective

Ship Module 2 as a playable beta. Players can:

1. Start a Module 2 session from the Curriculum Map.
2. Drill any of the 5 Module 2 concepts from the Concept Library.
3. Answer Module 2 `action_choice` and `reason_choice` questions with hand-aware rendering.
4. See M2-specific feedback: recommended action chip, hand logic, sizing logic, takeaway, common mistake.
5. Use Module 2 weak-spot review (M2 pool only — does not contaminate with M1 scenarios).
6. Finish Module 2 sessions with M2-aware summary header.
7. Continue using all existing Module 1 + Preflop flows without regression.

---

## 2. Runtime surfaces enabled

| Surface | Pre-v4.1.7 | Post-v4.1.7 |
|---|---|---|
| Module 2 from Curriculum Map | ❌ "📖 Preview syllabus" only | ✅ "▶ Start Module 2 Beta" + "📖 Syllabus" |
| Module 2 status pill | "Preview" | **"Beta"** (orange) |
| `startPostflopDrill('pf_flop_cbet_ip', 12)` | not called | **wired from Curriculum + Drill again button** |
| Module 2 question rendering | n/a | hero hand card row + handClass/heroHandRole chips |
| Module 2 question prompt | n/a | "With **\<hero hand\>** on **\<board\>** ..." (hand-aware) |
| Module 2 choice guide | n/a | full action_choice + reason_choice guides |
| Module 2 answer feedback | n/a | M2 5-block layout: Recommended Action / Hand Logic / Sizing Logic / Takeaway / Common Mistake |
| Module 2 concept drills (5 concepts) | locked badge | **drillable** ("🎯 Drill this concept" buttons) |
| Module 2 weak-spot review | n/a | **routes to M2 pool only** — no contamination |
| Module 2 session summary | n/a | "🎯 Module 2 · Flop C-bet IP · Complete" header + "Module 2 Session Summary" headline |
| Drill again button (on summary) | always M1 | **routes to same module just played** |
| Runtime drill pool | 262 (24 seeds filtered) | **286** (24 seeds activated) |

---

## 3. Final seed-review approval

`postflop-v4.1.7-final-gpt-review-of-seeds.md` documents the strategic re-review of all 24 v4.1.2 seeds. Verdict: **24 / 24 PASS** (all changes from v4.1.4 / v4.1.5 / v4.1.6 carried forward; no new mechanical or strategic issues found). 8 carryover audit warnings remain documented and non-blocking.

The 24 seeds were flipped from `auditStatus: review_pending` → `auditStatus: approved` in `postflop/postflop_scenarios.json` (line-level edits via PowerShell migration script; no other field changes). Effect:
- Pre-flip: runtime loads 262 (251 M1 + 11 migrated baseline; 24 seeds filtered out by `auditStatus === 'approved'` check on line 33225)
- Post-flip: runtime loads **286** (251 M1 + **35 M2** with all 24 seeds active)

---

## 4. Code changes

### 4.1 New helper: `getModule2Scenarios()`
Mirrors `getModule1Scenarios()` — filters production scenarios to `module === 'pf_flop_cbet_ip'`.

### 4.2 `startPostflopDrill(moduleId, sessionLength)`
- Routes pool by moduleId: `pf_board_texture` → `getModule1Scenarios()`; `pf_flop_cbet_ip` → `getModule2Scenarios()`.
- Default queue length: 15 for M1, **12 for M2** (mirrors v4.1.2 design intent + concept-drill length).

### 4.3 `_pfChoiceGuide(qType)`
- Enhanced `action_choice` guide with all 4 options (bet_small / bet_big / check / mixed) and rationales.
- New `reason_choice` guide covering all 9 enum values: value / thin_value / protection / bluff / equity_realization / pot_control / blocker_pressure / range_advantage_stab / give_up.

### 4.4 `_pfBuildQuestionPrompt(scenario)`
- `action_choice` cases now include hero hand: "With AhKh on As 8d 3h ..."
- New `reason_choice` case builds prompt around `recommendedAction` + hero hand: "With KsKd on 8s 7d 5h, BTN's recommended action is to check. What is the main reason?"
- Falls back to scenario's existing `question.prompt` when adequate.

### 4.5 `renderPostflopQuestion()`
- Detects M2 via `scenario.module === 'pf_flop_cbet_ip'`.
- Renders **hero hand card row** (`.postflop-hero-row` with 2 `.postflop-hero-card` elements) — orange-tinted border to differentiate from board cards.
- Renders **hand-class + hero-hand-role chips** (`🃏 top_pair_top_kicker` + `🎯 strong_value`).
- M2 context label: `🎯 Module 2 · Flop C-bet IP · Q N/12` (M1 unchanged: `🧪 Board Texture Trainer · Q N/15`).
- Suppresses board-only `_pfBoardChecklistHtml` for M2 (board reading is assumed; M2 focuses on hand action).
- Keeps `_pfPatternLabelHtml` and `_pfHintRowHtml` for both — both modules benefit from board pattern context.

### 4.6 New: `_pfM2TeachingFeedbackBlocksHtml(scenario)`
M2-specific 5-block feedback layout:
1. **🎯 Recommended Action** — orange-tinted block showing recommended action label + actionReason chip
2. **Hand Logic** — from `explanation.handLogic`
3. **Range / Board Context** (collapsed details) — from `explanation.rangeContext`
4. **Sizing Logic** — from `explanation.sizingLogic` (when present)
5. **Action Logic** — from `explanation.actionLogic` (alternative slot for reason_choice)
6. **💡 Takeaway** — from `explanation.takeaway`
7. **⚠️ Common Mistake** — from `explanation.commonMistake` (when present)

### 4.7 `renderPostflopAnswer()`
- Detects M2 and routes to `_pfM2TeachingFeedbackBlocksHtml(scenario)` instead of the M1 `_pfTeachingFeedbackBlocksHtml(scenario)`.
- Result row, concept tags, and Next button unchanged.

### 4.8 `renderPostflopComplete()`
- Detects M2 via `d.module === 'pf_flop_cbet_ip'`.
- M2 context label: `🎯 Module 2 · Flop C-bet IP · Complete`
- M2 summary headline: `Module 2 Session Summary` (M1: `Session Learning Summary`).
- Drill again button routes to same module just played (`pf_flop_cbet_ip` for M2 with 12 questions; `pf_board_texture` for M1 with 15).

### 4.9 `startPostflopConceptDrill(conceptKey)`
- v4.1.6 preview-only guard removed (kept the `if (entry.previewOnly)` check as defense-in-depth in case any future entry is marked preview).
- Routes the scenario pool by concept's `module`: `m2` → `getModule2Scenarios()`; otherwise `getModule1Scenarios()`.
- Sets `App.state.postflopDrill.module` to the corresponding moduleId so the answer/summary surfaces detect M2.

### 4.10 `_pfBuildConceptQueue` (no signature change)
Unchanged — module-agnostic. Caller now passes the correct pool.

### 4.11 `_pfModuleStatus(moduleKey, stats)`
- M2 returns `'beta'` instead of `'preview'`.

### 4.12 `_pfModuleCardHtml(mod, stats)`
- M2 actions: `▶ Start Module 2 Beta` (primary) + `📖 Syllabus` (secondary).
- Status pill maps `beta` → "Beta" with orange styling.
- Syllabus copy updated: removed "Production-ready Module 2 will arrive in a future patch" (it's here).

### 4.13 `_PF_CURRICULUM` Module 2 entry
- `scenarioCount: 11 → 35` (matches new production count).
- `masteryNote` updated to "Beta · 35 scenarios · all 5 M2 concepts drillable."
- Syllabus list updated to v4.1.2 vocabulary (bet_small/bet_big, pot control, give-up, range-stab).

### 4.14 `_PF_CONCEPT_LIBRARY` 5 M2 entries
- `previewOnly: true` → `previewOnly: false` for all 5 (`value_betting`, `pot_control`, `blocker_pressure`, `give_up_strategy`, `range_advantage_stab`).
- Lock badges replaced with drill buttons in `_pfConceptLibraryHtml`.

### 4.15 `_pfConceptLibraryHtml()`
- Module 2 group header text: `(5 · preview)` → `(5 · beta)`.
- Summary text: `(15 concepts · 10 M1 + 5 M2 preview)` → `(15 concepts · 10 M1 + 5 M2)`.

### 4.16 `startPostflopWeakSpotReview()`
- Routes pool by previously-played module. Module 2 weak-spot review now draws from M2 pool only — no M1 contamination.
- Falls back to normal session in same module if no weak profile.

### 4.17 New CSS
- `.postflop-hero-row` + `.postflop-hero-card` (orange border tint, 44×60px desktop / 40×56px mobile)
- `.pf-m2-hand-chips`, `.pf-m2-hand-chip`, `.pf-m2-handrole-chip` (orange/blue chips)
- `.pf-fb-m2-action`, `.pf-m2-rec-action`, `.pf-m2-action-reason` (M2 recommended-action feedback block)
- `.pf-status-pill.is-beta` (orange Beta pill)
- `.pf-module-card.is-beta` (orange left border)
- `.pf-module-action-btn.is-secondary` (subdued secondary button for Syllabus)

### 4.18 Version bumps
- `appVersion`: `'4.1.6'` → `'4.1.7'`
- `service-worker.js VERSION`: `'v4.1.6'` → `'v4.1.7'`

---

## 5. QA result (35/35 PASS)

| # | Check | Result |
|---|---|---|
| 1 | Production audit (286 / 0 / 0) | ✅ |
| 2 | Module 2 seed audit (24 / 0 hard / 8 warnings) | ✅ |
| 3 | App loads | ✅ |
| 4 | Runtime loads 286 scenarios (251 M1 + 35 M2 all approved) | ✅ |
| 5 | All 35 M2 scenarios `auditStatus === approved` | ✅ |
| 6 | `_PF_CONCEPT_LIBRARY` count = 15 (10 M1 + 5 M2) | ✅ |
| 7 | All 5 M2 concepts have `previewOnly: false` | ✅ |
| 8 | M2 curriculum card status = `beta` | ✅ |
| 9 | M2 curriculum card has Start button calling `startPostflopDrill('pf_flop_cbet_ip', 12)` | ✅ |
| 10 | Concept Library has 15 drill buttons (no locked badges) | ✅ |
| 11 | Start M2 from curriculum builds 12-q queue, all M2 | ✅ |
| 12 | M2 question screen renders hero hand card row | ✅ |
| 13 | M2 question screen renders hand-class + heroHandRole chips | ✅ |
| 14 | M2 context label: `🎯 Module 2 · Flop C-bet IP · Q N/12` | ✅ |
| 15 | M2 question prompt includes hero hand: "With T♣ T♥ on K♥ T♦ 2♠ ..." | ✅ |
| 16 | M2 action_choice has 4 choices (bet_small/bet_big/check/mixed) | ✅ |
| 17 | M2 reason_choice scenario rendered correctly (KsKd on 8-7-5 — best=pot_control) | ✅ |
| 18 | M2 answer feedback shows Recommended Action block ("Check back" + "Reason: pot control") | ✅ |
| 19 | M2 answer feedback has 4 blocks: Recommended Action / Hand Logic / Takeaway / Common Mistake | ✅ |
| 20 | M2 result tier rendered (`✅ BEST · 1.00 pts`) | ✅ |
| 21 | Concept tags rendered (pot_control, check_strategy, low_connected_caution, common_leaks) | ✅ |
| 22 | M2 session summary renders: `🎯 Module 2 · Flop C-bet IP · Complete` + `Module 2 Session Summary` | ✅ |
| 23 | M2 weak-spot review button shown when misses present | ✅ |
| 24 | **M2 weak-spot review queue is 12/12 M2 scenarios (no M1 contamination)** | ✅ (fixed during QA) |
| 25 | M2 concept drill (`value_betting`) works: mode=concept, queue=12, all M2 | ✅ |
| 26 | Drill again button on M2 summary routes to `pf_flop_cbet_ip` (12 q) | ✅ |
| 27 | M1 normal drill still works: 5-q queue, all M1, M1 context label | ✅ |
| 28 | M1 concept drill (`range_advantage`) still works: queue=12, all M1 | ✅ |
| 29 | Preflop drill works (`startDrill('quick')` → 15-q queue) | ✅ |
| 30 | Mobile 375px: no horizontal overflow | ✅ |
| 31 | Mobile 375px: M2 curriculum card 295px, Start button 271px | ✅ |
| 32 | Mobile 375px: hero card 40px (compact) | ✅ |
| 33 | Mobile 375px: hand chip renders | ✅ |
| 34 | Console: 0 errors throughout entire QA pass | ✅ |
| 35 | appVersion = `4.1.7`, service-worker VERSION = `v4.1.7` | ✅ |

**Plus the 1 mid-QA fix:** M2 weak-spot review was initially pulling from the M1 pool (because `startPostflopWeakSpotReview` hardcoded `getModule1Scenarios()`). Fixed by routing pool by `prevDrill.module` — now M2 weak-spot review stays in M2 pool. Re-tested → 12/12 M2 ✓.

---

## 6. Files changed (5 total)

| File | Change |
|---|---|
| `index.html` | (a) `getModule2Scenarios()` helper. (b) `startPostflopDrill` routes pool by moduleId + default len. (c) `_pfChoiceGuide` + `reason_choice` enum. (d) `_pfBuildQuestionPrompt` hand-aware for action_choice + reason_choice. (e) `renderPostflopQuestion` M2 hero-hand row + chips + context. (f) `_pfM2TeachingFeedbackBlocksHtml` (NEW). (g) `renderPostflopAnswer` routes M2 to new feedback. (h) `renderPostflopComplete` M2 module label + drill again routing. (i) `startPostflopConceptDrill` removes preview guard + routes pool by concept module. (j) `_pfModuleStatus` returns `beta` for m2. (k) `_pfModuleCardHtml` Start + Syllabus buttons for m2. (l) `_PF_CURRICULUM` m2 entry: scenarioCount 11→35 + new mastery note + syllabus. (m) `_PF_CONCEPT_LIBRARY` 5 M2 entries: previewOnly false. (n) `_pfConceptLibraryHtml` group header `preview` → `beta`. (o) `startPostflopWeakSpotReview` routes pool by prev module. (p) New CSS (~110 lines): hero card row, M2 chips, M2 action block, beta status pill, secondary button. (q) `appVersion: '4.1.6' → '4.1.7'`. |
| `service-worker.js` | `VERSION 'v4.1.6' → 'v4.1.7'` (cache-bust) |
| `postflop/postflop_scenarios.json` | 24 v4.1.2 seed scenarios: `auditStatus: 'review_pending' → 'approved'`. No other field changes. |
| `docs/specs/postflop-v4.1.7-final-gpt-review-of-seeds.md` | NEW — 24/24 PASS verdict + warning disposition |
| `docs/specs/postflop-v4.1.7-module2-playable-beta.md` | NEW — this file |
| `PROJECT_STATE.md`, `TASK_BOARD.md` | status update |

**Untouched (verified):**
- `postflop/postflop_taxonomy.json`, `postflop/postflop_concepts.json`
- `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`
- `tools/audit-postflop-ps.ps1`, `tools/audit-postflop-module2-seed.ps1`, `tools/audit-postflop.js`, `tools/generate-postflop-module1.ps1`
- `manifest.json`, `ranges.json`
- All preflop systems / Boss / Mission / Wardrobe / Shop / Field FX

---

## 7. Known limitations (non-blocking)

1. **M2 history aggregation by handClass / heroHandRole / actionReason** — the v4.0.11 session summary aggregates by `conceptTags` only. M2-specific aggregations ("you struggled with `overpair` on `low_connected`") are deferred to v4.1.8.
2. **No M2 mastery checklist** — `_pfMasteryProgress` only knows about M1 mastery criteria. M2 mastery criteria + checklist UI deferred to v4.1.8.
3. **Mixed concept-tag pool** — M2 concept drills score against M2 pool only (35 scenarios). Some concepts have small effective pool (e.g., `give_up_strategy` matches ~6 scenarios); the `_pfBuildConceptQueue` fill-fallback fills the queue from below-threshold M2 scenarios, which works but reduces concept focus on those drills. Pool depth fix is data-side (more M2 scenarios in v4.1.8+).
4. **8 carryover seed-audit warnings** — M2.HC09 (1), M2.HC11 (1), M2.H14 (3), M2.SC05 (3). All documented in `postflop-v4.1.7-final-gpt-review-of-seeds.md` § 4. Non-blocking.
5. **No audit-status flip in seed JSON** — the planning seed JSON at `docs/specs/postflop-v4.1.2-module2-seed-scenarios.json` still carries `auditStatus: 'review_pending'`. Only the production copies were flipped. This keeps the seed-audit reading honest about its planning origin.
6. **No service-worker update banner update** — the existing v3.x update banner handles v4.1.7. Tested via cache-clear + reload in browser QA.

---

## 8. Recommended next step

**v4.1.8 — M2 mastery + concept depth + tester pass.** Polish patch.

Scope:
1. **M2 mastery checklist** — add 5 mastery criteria for Module 2 (analogous to M1's: complete N M2 sessions, 80%+ quality, no critical leaks, weak-spot review used, all 5 M2 concepts seen).
2. **M2 session summary aggregation** — extend `_pfRenderLearningSummary` (or M2 variant) to surface "weak hand classes" and "weak action reasons" in addition to conceptTags.
3. **M2 concept-pool depth audit** — for each of the 5 M2 concepts, log scenario count after `_pfBuildConceptQueue` scoring. Concepts with <10 strong matches get flagged for v4.1.9 data expansion.
4. **Tester pass on a real device** — collect feedback on M2 question rendering clarity, hand-card visibility, choice guide readability, M2 weak-spot review usefulness.
5. **Bump appVersion + SW VERSION** to v4.1.8 (only if patch ships polish; if it's mostly QA + docs, hold version).

**v4.1.9+ — M2 data expansion** when concept-pool depth audit shows gaps. Authoring pattern same as v4.0.7.

Per the v4.1.7 brief: **stopping here, not starting v4.1.8, not productionizing Module 3.**
