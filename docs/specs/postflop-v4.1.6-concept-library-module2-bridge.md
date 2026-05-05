# Postflop v4.1.6 — Concept Library Module 2 Bridge

**Status:** Implemented + verified live. Awaiting commit/push.
**Date:** 2026-05-05
**Companion to:** `postflop-v4.1.5-baseline-migration-review.md`, `postflop-v4.1.4-module2-baseline-migration-plan.md`

---

## 1. Objective

Bridge the 5 newly productionized Module 2 concepts (`value_betting`, `pot_control`, `blocker_pressure`, `give_up_strategy`, `range_advantage_stab`) into the in-app **Concept Library** UI without exposing Module 2 as playable from the Curriculum Map.

This is a **runtime UI bridge sprint** — index.html + service-worker only. No scenario data changes, no audit script changes, no Module 2 curriculum activation.

---

## 2. Implementation choice — Path A (preview-only)

The brief offered two paths:

- **Path A (preview-only):** Module 2 concepts visible in the library; drill button replaced by a "Coming in Module 2 Beta" lock badge. Existing Module 1 concept drills unchanged.
- **Path B (controlled drill):** Allow Module 2 concept drills, expand the queue pool to include `pf_flop_cbet_ip` scenarios.

**Decision: Path A.**

### 2.1 Why Path A

Code inspection of the existing concept-drill flow showed Path B requires substantial runtime work to be safe:

1. **`renderPostflopQuestion`** is heavily Module-1-flavored. It renders the spot card with `heroLine = 'Hero: — (board read)'` for Module 1 board-only scenarios. Module 2 question prompts include hero hand context that needs different rendering.
2. **`_pfChoiceGuide(question.type)`** has hardcoded guide copy for Module 1 question types (`range_advantage`, `nut_advantage`, `sizing_family`, etc.). Module 2 question types (`action_choice`, `reason_choice`) have no guide copy — buttons render but the educational guide is empty.
3. **`renderPostflopAnswer`** displays explanation sections (`rangeLogic`, `nutLogic`, `dynamicLogic`, `sizingLogic`, `commonMistake`). Module 2 scenarios use a different field set (`handLogic`, `sizingLogic`, `actionLogic`, `takeaway`, `commonMistake`) and need different section labels.
4. **Teaching layer** (`_pfPatternLabelHtml`, `_pfBoardChecklistHtml`, `_pfHintRowHtml`) is board-only. Module 2 needs a hand-class chip and hand-aware hint rows.
5. **`_pfBuildConceptQueue`** uses `getModule1Scenarios()` exclusively. Pool expansion to include `pf_flop_cbet_ip` requires a parallel `getModule2Scenarios()` helper and per-concept routing.
6. **Session summary** (`renderPostflopComplete`) aggregates by Module 1 concept tags; Module 2 concept aggregation needs separate handling.

Rough estimate: **~200+ lines of safe rendering changes** plus ~30 QA items. That's a v4.1.7 patch, not v4.1.6.

Path A delivers the **bridge** (concepts visible in the library, players can see what's coming) without committing to the full runtime rendering work.

### 2.2 What Path A delivers

- 5 Module 2 concepts visible in the Concept Library, grouped under "Module 2 — Flop C-bet IP · Hand Action".
- Each concept card shows: name, definition, "trained in Module 2" tag (orange), and a "🔒 Coming in Module 2 Beta" lock badge instead of a drill button.
- Module 1 concepts (10) unchanged — same grouping, same drill buttons, same behavior.
- Defense-in-depth: `startPostflopConceptDrill()` rejects any preview-only concept key with a toast, even if the lock badge is bypassed.
- Curriculum Map's Module 2 card stays in **Preview** state; "Preview syllabus" button still only toggles the inline syllabus details — no `startPostflopDrill('pf_flop_cbet_ip', ...)` call introduced anywhere.

---

## 3. Concept list added

| key | name | category | conceptTag mapping |
|---|---|---|---|
| `value_betting` | Value Betting | M2 strategic | tags: value_betting; relatedTags: thin_value_betting, small_cbet_freq, range_advantage |
| `pot_control` | Pot Control | M2 strategic | tags: pot_control; relatedTags: check_strategy, low_connected_caution, ip_advantage |
| `blocker_pressure` | Blocker Pressure | M2 strategic | tags: blocker_pressure; relatedTags: semi_bluff_with_equity, polar_big_strategy, common_leaks |
| `give_up_strategy` | Give-up Strategy | M2 strategic | tags: give_up_strategy; relatedTags: check_strategy, low_connected_caution, pot_control |
| `range_advantage_stab` | Range-Advantage Stab | M2 strategic | tags: range_advantage_stab; relatedTags: range_advantage, small_cbet_freq, dry_high_card_strategy |

Each entry carries the same drill-mapping shape as Module 1 entries (`tags`, `relatedTags`, `questionTypes`, `suitTextures`, `textureTags`) so a future v4.1.7 patch can flip `previewOnly: false` without restructuring the entry.

---

## 4. UI behavior (live-verified)

### 4.1 Concept Library expandable
- Summary text: `📖 Concept Library (15 concepts · 10 M1 + 5 M2 preview) · tap to drill`
- Tap to expand → grouped grid

### 4.2 Module 1 group
- Header: `MODULE 1 — BOARD READING (10)` — small caps, neutral color, bottom border
- 10 concept cards (unchanged)
- Each card: name, def, "trained in Module 1" tag, "🎯 Drill this concept" button
- Drilling a concept builds a 12-question Module 1 queue (`module === 'pf_board_texture'`) and starts the drill — exactly as v4.1.1

### 4.3 Module 2 group
- Header: `MODULE 2 — FLOP C-BET IP · HAND ACTION (5 · preview)` — small caps, orange-tinted, bottom border
- 5 concept cards
- Each card: name, def, **orange "trained in Module 2" tag**, **"🔒 Coming in Module 2 Beta" lock badge** (no drill button)
- Card has subtle orange tint (border-left + background) to differentiate from M1 cards
- Cursor over the lock badge: not-allowed, with tooltip "Module 2 concept drill ships in v4.1.7 once hand-aware question rendering lands."

### 4.4 Defense-in-depth guard
If any code path attempts `startPostflopConceptDrill('value_betting')` (or any other preview-only key):
- Function checks `_PF_CONCEPT_LIBRARY` for the key
- If `previewOnly: true`, returns early with toast: "Module 2 concept drill is in preview. Coming in v4.1.7."
- No drill state mutations, no rendering changes

### 4.5 Curriculum Map untouched
- Module 2 card still shows "Preview" status pill
- Action button is "📖 Preview syllabus" (toggles inline syllabus `<details>`, no drill start)
- No new "Start Module 2" button added
- `startPostflopDrill('pf_flop_cbet_ip', ...)` does not appear anywhere in `index.html`

---

## 5. Runtime limitations (intentional)

Module 2 is **NOT playable** in v4.1.6:

| Surface | v4.1.6 status |
|---|---|
| Module 2 from Curriculum Map | ❌ still Preview / syllabus only |
| Module 2 concept drill | ❌ preview-only / locked badge |
| `startPostflopDrill('pf_flop_cbet_ip', ...)` | ❌ never called from runtime |
| Module 2 hand-aware question rendering | ❌ deferred to v4.1.7 |
| Module 2 hand-class teaching layer | ❌ deferred to v4.1.7 |
| Module 2 weak-spot review variant | ❌ deferred to v4.1.7 |
| Module 2 session summary | ❌ deferred to v4.1.7 |

The 24 v4.1.2 seeds that were appended to `postflop/postflop_scenarios.json` in v4.1.5 carry `auditStatus: 'review_pending'`. The runtime loader (line 33225 of `index.html`) filters scenarios by `auditStatus === 'approved'`, so the seeds are physically in production JSON but **inert at runtime**. Only the 11 migrated baseline scenarios (`auditStatus: approved`, post-migration) and the 251 Module 1 scenarios actually load — total **262 scenarios in the runtime drill pool**.

This is the intended safety: data is in production but not yet activated until v4.1.7 (runtime patch + audit-status flip).

---

## 6. QA checklist (all PASS)

| # | Check | Result |
|---|---|---|
| 1 | Production audit | ✅ 286 / 0 / 0 (251 M1 + 35 M2) |
| 2 | Module 2 seed audit | ✅ 24 / 0 hard errors / 8 warnings (PASS) |
| 3 | Working tree starts clean | ✅ |
| 4 | App loads without errors | ✅ |
| 5 | `_PF_CONCEPT_LIBRARY` count = 15 (10 M1 + 5 M2) | ✅ |
| 6 | Concept Library expands | ✅ |
| 7 | M1 group header rendered with neutral styling | ✅ |
| 8 | M2 group header rendered with orange-tinted styling | ✅ |
| 9 | 10 drill buttons (M1) + 5 lock badges (M2) | ✅ |
| 10 | M2 cards have `pf-concept-card-locked` styling | ✅ |
| 11 | M2 tags use `pf-concept-tag-m2` orange styling | ✅ |
| 12 | Summary text shows correct breakdown | ✅ |
| 13 | M1 concept drill (`range_advantage`) starts → mode='concept', queue=12, all M1 | ✅ |
| 14 | M2 concept drill (`value_betting`) refused → not active, empty queue | ✅ |
| 15 | Curriculum M2 button text still "📖 Preview syllabus" | ✅ |
| 16 | Curriculum M2 onclick does NOT contain `pf_flop_cbet_ip` drill route | ✅ |
| 17 | Preflop drill works (`startDrill('quick')` → 15-q queue) | ✅ |
| 18 | Mobile 375px: no horizontal overflow | ✅ |
| 19 | Mobile 375px: locked badge fits (247px wide) | ✅ |
| 20 | Mobile 375px: M2 card 269px wide | ✅ |
| 21 | Console: 0 errors | ✅ |
| 22 | appVersion = `4.1.6` (in backup schema) | ✅ |
| 23 | service-worker VERSION = `v4.1.6` | ✅ |
| 24 | No scenario data changed (`git diff -- postflop/postflop_scenarios.json` empty) | ✅ |
| 25 | No taxonomy / concepts / audit script changed (apart from v4.1.5 commits) | ✅ |

---

## 7. Files changed (4 total)

| File | Change |
|---|---|
| `index.html` | (a) `_PF_CONCEPT_LIBRARY` extended with 5 M2 entries (each carrying `module: 'm2'` + `previewOnly: true`). (b) `_pfConceptLibraryHtml` rewritten to render M1/M2 grouping + locked badge for previewOnly entries. (c) `startPostflopConceptDrill` gains a defense-in-depth check refusing previewOnly keys. (d) New CSS block for `.pf-concept-group-header*`, `.pf-concept-card-locked`, `.pf-concept-tag-m2`, `.pf-concept-locked-badge` (~70 lines, namespaced). (e) `appVersion: '4.1.1' → '4.1.6'` in the backup schema function. |
| `service-worker.js` | `VERSION = 'v4.1.1' → 'v4.1.6'` (cache-bust on next page load). |
| `PROJECT_STATE.md`, `TASK_BOARD.md` | Status update |
| `docs/specs/postflop-v4.1.6-concept-library-module2-bridge.md` | This file (NEW) |

**Untouched (verified):**
- `postflop/postflop_scenarios.json` — 286 scenarios unchanged from v4.1.5
- `postflop/postflop_taxonomy.json`, `postflop/postflop_concepts.json` — unchanged from v4.1.5
- `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html` — unchanged
- `tools/audit-postflop-ps.ps1`, `tools/audit-postflop-module2-seed.ps1`, `tools/audit-postflop.js`, `tools/generate-postflop-module1.ps1` — unchanged
- `manifest.json`, `ranges.json` — unchanged
- All preflop systems / Boss / Mission / Wardrobe / Shop / Field FX — unchanged

---

## 8. Risks + next step

### 8.1 Risks
1. **Service worker cache invalidation:** Users with the v4.1.1 SW cached will see the new VERSION, install the v4.1.6 SW, and must reload to activate. Standard PWA flow; existing update banner handles this. No special action needed.
2. **Lock badge tap behavior on mobile:** The `pf-concept-locked-badge` is a `<span>` not a button. Tapping does nothing (no onclick). Acceptable — clearly signaled as locked.
3. **Path B regret:** If users complain that they can see Module 2 concepts but can't drill them, v4.1.7 ships immediately. The bridge surface is honest about the lock state ("Coming in Module 2 Beta"), so this should be a small risk.

### 8.2 Recommended next step

**v4.1.7 — Module 2 Curriculum Playable Beta** (full runtime patch).

Atomic scope:
1. **Hand-aware question rendering** — extend `renderPostflopQuestion` + `_pfChoiceGuide` to handle `action_choice` and `reason_choice` types; render hero hand chip; render appropriate choice guide copy.
2. **Module 2 explanation rendering** — extend `renderPostflopAnswer` to display `handLogic`, `actionLogic`, `takeaway`, etc. with appropriate section labels.
3. **Module 2 teaching layer** — add hand-class chip + hand-aware hint row.
4. **Pool expansion** — add `getModule2Scenarios()` + extend `_pfBuildConceptQueue` to draw from M2 pool when concept is M2-tagged.
5. **`startPostflopDrill('pf_flop_cbet_ip')` route** — wire `Module 2` curriculum card "Start Module 2 Beta" button.
6. **Audit-status flip** — for the 24 seeds, run final GPT review pass and flip `auditStatus: review_pending → approved` so they enter the live drill pool. Production audit gate becomes 286/0/0 with 286 scenarios actually loaded at runtime.
7. **Flip `previewOnly: false`** for all 5 M2 concept library entries; remove the lock badge.
8. **Browser QA + mobile QA** on every Module 2 surface.
9. **Bump `appVersion` and service-worker VERSION** to `v4.1.7`.
10. **Tester pass on a real device** before committing.

Module 2 becomes playable at v4.1.7.
