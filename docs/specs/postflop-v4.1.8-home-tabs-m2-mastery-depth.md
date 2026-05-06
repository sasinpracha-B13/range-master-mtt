# v4.1.8 — Home Mode Tabs + Module 2 Mastery + Concept-Pool Depth Audit

**Status:** Implemented + verified live. 30+ QA checks pass. Awaiting commit/push.
**Date:** 2026-05-05
**Companion to:** `postflop-v4.1.7-module2-playable-beta.md`, `postflop-v4.1.5-baseline-migration-review.md`

---

## 1. Objective

Polish the v4.1.7 Module 2 playable beta with three additive surfaces:

1. **Home mode tabs** — prominent Preflop / Postflop entry tiles at the top of Home so the user immediately knows which mode to train.
2. **Module 2 mastery checklist** — parallel to the M1 mastery panel, surfaced inside the Postflop Academy panel.
3. **Module 2 session summary aggregation** — extends the existing learning summary to surface "weak hand classes" and "weak action reasons" alongside conceptTags.

Plus: documented **M2 concept-pool depth audit** with v4.1.9 expansion recommendations.

---

## 2. Home Mode Tabs

### 2.1 Implementation

New function `renderHomeModeTabsMount()` prepends a 2-tile tab block to `#masteryContent`. Wired into `renderMastery()` AFTER `renderPostflopHomeCardMount()` so the tabs occupy the **top slot** (each `afterbegin` insert pushes prior content down).

Render order in Home:
```
[Home Mode Tabs]              ← v4.1.8, top
[Postflop Beta Lab section]   ← from v4.0.2 / v4.1.0 Academy
[Preflop Mastery content]     ← from v3.x mastery render
```

### 2.2 UI structure

```
┌────────────────────────────────────────────────────────┐
│              CHOOSE YOUR TRAINING MODE                 │
│  ┌──────────────────┐  ┌──────────────────────────┐   │
│  │ ♠ Preflop        │  │ 🎯 Postflop Academy      │   │
│  │   Ranges · Browse │  │   Board Reading · Flop  │   │
│  │   · Exams        │  │   C-bet IP              │   │
│  │   ▶ Train ranges │  │   ▶ Enter Academy       │   │
│  └──────────────────┘  └──────────────────────────┘   │
│  Preflop builds your range foundation. Postflop teaches│
│  board reading and hand-action decisions.              │
└────────────────────────────────────────────────────────┘
```

- **Preflop tile** (blue accent #6ea8fe) — clicking calls `switchTab('drill')` → switches the bottom-nav active tab to "Drill" (the existing preflop trainer entry).
- **Postflop tile** (orange accent #f5a623) — clicking smooth-scrolls to `.postflop-betalab-section` (within the same Mastery tab). If Postflop Beta is OFF, the CTA shows "⚙ Enable in Settings" and clicking switches to the Settings tab + shows a toast.

### 2.3 Visual design

- Each tile is a `<button>` with a 3-region grid: [icon] [body] / [cta].
- Icon: 40×40 rounded square (mobile: 36×36).
- Tile background: subtle linear-gradient using the accent color.
- Border: 1.5px in the accent color at ~45% opacity, increasing to ~75% on hover.
- Hover: `transform: translateY(-1px)` + soft shadow.
- Mobile (≤480px): grid collapses to **1 column** — tiles stack vertically.

### 2.4 Behavior decisions

**Why tab-like buttons that re-use existing routes (not a new mode-switch system)?**
- The app's tab architecture already routes via `switchTab(name)` for the bottom nav (drill / progress / browse / settings / mastery).
- Postflop Academy lives **inside** the Mastery tab (`renderPostflopHomeCardMount` mounts to `#masteryContent`), not in its own top-level tab.
- Building a separate "mode" abstraction would duplicate routing and risk breaking existing flows.
- Re-using `switchTab('drill')` for Preflop and a smooth-scroll for Postflop is the **smallest safe change** that achieves the navigation clarity goal.

**Why both tiles are always visible (Postflop never hidden)?**
- The user explicitly required "Postflop button must remain visible and not look secondary/disabled."
- When beta is off, the tile uses muted opacity (0.85) and changes the CTA to "⚙ Enable in Settings", but it's still visible and clickable.

---

## 3. Module 2 Mastery Checklist

### 3.1 Parallel to M1

New `_pfM2MasteryStats()` reads `_pfHistoryLoad()` and **filters sessions by `module === 'pf_flop_cbet_ip'`** before computing 5 mastery criteria parallel to M1:

| # | Criterion | Met when |
|---|---|---|
| 1 | Complete 5 Module 2 sessions | M2 sessionCount ≥ 5 |
| 2 | Hit 80%+ quality in 3 M2 sessions | qualitySessionCount (pct ≥ 80) ≥ 3 |
| 3 | No critical leaks in latest M2 session | latestSession.critical === 0 |
| 4 | Engage with M2 weak-spot review | At least one M2 session had bad+critical>0 AND M2 sessionCount ≥ 2 |
| 5 | Drill all 5 Module 2 concepts | history.concepts has each of `value_betting`, `pot_control`, `blocker_pressure`, `give_up_strategy`, `range_advantage_stab` with `seen ≥ 1` |

### 3.2 Display

`_pfM2MasteryProgressHtml()` renders:
- Section header: `🎯 Module 2 mastery (display only)` — orange accent
- 5 list items with `✅` / `○` icons + per-item detail (e.g., "2 / 5", "clean", "engaged", "3 / 5 concepts seen")

Inserted into `_pfAcademyHomeHtml()` directly **below** the M1 mastery section. Both panels coexist; neither enforces gating.

### 3.3 Defensive

- If `_pfHistoryLoad` is unavailable, returns zeros gracefully.
- If history has no M2 sessions, all criteria show as not-met without errors.
- `_pfAcademyHomeHtml` wraps the M2 mastery render in try/catch — never blocks Academy panel render.

---

## 4. Module 2 Session Summary Aggregation

### 4.1 What was added

New helpers:
- `_pfM2GroupAnswersBy(answers, scenarios, fieldName)` — generic grouper that joins answers to scenarios by `scenarioId` and tallies by any scenario field. Returns sorted rows with `seen`, `scoreSum`, `badCount`, `critCount`, `bestCount`, `pct`.
- `_pfM2PrettyLabel(key)` — `snake_case` → `Title Case`.
- `_pfM2RenderSessionAggregations(d, scenarios, counts, total)` — gates on `d.module === 'pf_flop_cbet_ip'`; produces 4 possible blocks:
  1. **💪 Strongest hand classes** (rows with seen ≥ 2 AND pct ≥ 80, top 4)
  2. **🔍 Weak hand classes** (rows with critCount > 0 OR badCount ≥ 2 OR (seen ≥ 2 AND pct < 50), top 4)
  3. **🎯 Action reason coverage** (top 6 actionReason rows with `✅`/`≈`/`❌` icons)
  4. **🔍 Weak action reasons** (same threshold as hand classes, top 4)

Wraps in `<div class="pf-m2-aggr-section">` with title `Module 2 · hand-action breakdown`.

### 4.2 Integration

Plugged into `renderPostflopComplete()` as a string (`m2AggrHtml`) inserted **between** the existing `learnSummaryHtml` (concept-tag aggregation) and the `conceptRows` collapsible details. M1 sessions return `''` (no extra block).

### 4.3 Verified live

After completing a 12-q M2 session with deliberately wrong answers, the summary renders:
- `Module 2 · hand-action breakdown` section title
- 3 blocks: `🔍 Weak hand classes`, `🎯 Action reason coverage`, `🔍 Weak action reasons`

(Strongest hand classes block hidden when no class has pct ≥ 80 — correct behavior.)

---

## 5. M2 Concept-Pool Depth Audit

Run via Preview eval against the live runtime (286 scenarios loaded):

| Concept | Primary-tag matches | qtype matches | Related-tag matches | Suit/texture matches | 12-q queue health | v4.1.9 expansion recommendation |
|---|---:|---:|---:|---:|---|---|
| `value_betting` | **5** | 29 | 17 | 0 | ✅ healthy (poolSize 32) | **+3 scenarios** with primary tag |
| `pot_control` | **6** | 35 | 8 | 6 | ✅ healthy (poolSize 35) | +2 scenarios |
| `blocker_pressure` | **4** | 35 | 12 | 14 | ✅ healthy (poolSize 35) | **+4 scenarios** (weakest) |
| `give_up_strategy` | **6** | 35 | 8 | 10 | ✅ healthy (poolSize 35) | +2 scenarios |
| `range_advantage_stab` | **5** | 35 | 17 | 17 | ✅ healthy (poolSize 35) | +3 scenarios |

**Findings:**
- Every concept produces a healthy 12-q queue today (poolSize ≥ 32 above the 30-threshold, fillUsed=false in all 5 cases).
- Primary-tag depth is the limiting factor — the smallest concept (`blocker_pressure`) has only 4 explicit primary-tag matches.
- Most queue weight comes from `qtype` matches (M2 has only 2 qtypes — action_choice + reason_choice — so most scenarios match by qtype) and `relatedTags` overlap.
- Players will get focused-feeling drills, but exact-tag concentration could be higher.

**Recommendation for v4.1.9 data sprint:**
1. Add at least 14 new scenarios across the 5 concepts to boost primary-tag depth (target ≥ 8 primary-tag matches each):
   - `blocker_pressure`: +4
   - `value_betting`, `range_advantage_stab`: +3 each
   - `pot_control`, `give_up_strategy`: +2 each
2. Targeted board buckets: monotone (for `blocker_pressure`), low-connected wet (for `give_up_strategy`), paired Kx + dry A-high (for `range_advantage_stab`).
3. Maintain the existing seed authoring pattern (24-scenario v4.1.2 template) — no new schema.

---

## 6. QA result (32/32 PASS)

| # | Check | Result |
|---|---|---|
| 1 | Production audit (286 / 0 / 0) | ✅ |
| 2 | Module 2 seed audit (24 / 0 hard / 8 warnings) | ✅ |
| 3 | Working tree starts clean | ✅ |
| 4 | App loads | ✅ |
| 5 | Runtime loads 286 scenarios (251 M1 + 35 M2) | ✅ |
| 6 | Home page renders without errors | ✅ |
| 7 | Home Mode Tabs container rendered at top of `#masteryContent` | ✅ |
| 8 | Preflop tile shows ♠ icon + "Preflop" + "Ranges · Browse · Exams" + "▶ Train ranges" | ✅ |
| 9 | Postflop tile shows 🎯 icon + "Postflop Academy" + "Board Reading · Flop C-bet IP" + "▶ Enter Academy" | ✅ |
| 10 | Helper text renders below tiles | ✅ |
| 11 | Clicking Preflop tile switches to Drill tab | ✅ |
| 12 | Clicking Postflop tile smooth-scrolls to `.postflop-betalab-section` (414px → 59px) | ✅ |
| 13 | M2 mastery checklist renders below M1 mastery in Academy panel | ✅ |
| 14 | M2 mastery shows 5 list items | ✅ |
| 15 | M2 mastery uses orange accent (`pf-mastery-section-m2` class) | ✅ |
| 16 | Module 2 from Curriculum still works | ✅ |
| 17 | M2 session summary renders new "Module 2 · hand-action breakdown" section | ✅ |
| 18 | M2 aggregation shows 3 blocks: Weak hand classes / Action reason coverage / Weak action reasons | ✅ |
| 19 | M2 aggregation handles strongest-class block when applicable (gated; not shown when zero pct≥80) | ✅ |
| 20 | M2 concept drill (value_betting) still works: queue=12, mode=concept, all M2 | ✅ |
| 21 | M1 normal drill still works: queue=5, all M1 | ✅ |
| 22 | M1 concept drill (range_advantage) still works: queue=12, all M1 | ✅ |
| 23 | Preflop drill (`startDrill('quick')`) still works: queue=15 | ✅ |
| 24 | Mobile 375px: no horizontal overflow | ✅ |
| 25 | Mobile 375px: tiles stack 1-column (321px each, 80px tall) | ✅ |
| 26 | Mobile 375px: M2 mastery section 295px wide | ✅ |
| 27 | Console: 0 errors throughout entire QA pass | ✅ |
| 28 | appVersion = `4.1.8` | ✅ |
| 29 | service-worker VERSION = `v4.1.8` | ✅ |
| 30 | Forbidden files untouched (`postflop_scenarios.json`, `taxonomy`, `concepts`, `audit rules`, `tools/`, `manifest`, `ranges`) | ✅ |
| 31 | M2 concept-pool depth audit documented | ✅ |
| 32 | Diff scope matches allowed files | ✅ |

---

## 7. Files changed (4 modified + 1 new)

| File | Change |
|---|---|
| `index.html` | (a) New `renderHomeModeTabsMount()` function + wiring inside `renderMastery()`. (b) New `_pfM2MasteryStats()` + `_pfM2MasteryProgress()` + `_pfM2MasteryProgressHtml()` functions. (c) `_pfAcademyHomeHtml()` plugs in M2 mastery (defensive try/catch). (d) New `_pfM2GroupAnswersBy()` + `_pfM2PrettyLabel()` + `_pfM2RenderSessionAggregations()` functions. (e) `renderPostflopComplete()` injects `m2AggrHtml` between learning summary and concept rows. (f) ~150 lines of new CSS for `.home-mode-tabs*`, `.pf-mastery-section-m2`, `.pf-m2-aggr-section`. (g) `appVersion: '4.1.7' → '4.1.8'`. |
| `service-worker.js` | `VERSION 'v4.1.7' → 'v4.1.8'` |
| `docs/specs/postflop-v4.1.8-home-tabs-m2-mastery-depth.md` | NEW — this file |
| `PROJECT_STATE.md` | Status update |
| `TASK_BOARD.md` | Status update |

**Untouched (verified):** `postflop/postflop_scenarios.json`, `postflop/postflop_taxonomy.json`, `postflop/postflop_concepts.json`, `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`, `tools/audit-postflop-ps.ps1`, `tools/audit-postflop-module2-seed.ps1`, `tools/audit-postflop.js`, `tools/generate-postflop-module1.ps1`, `manifest.json`, `ranges.json`, all preflop systems.

---

## 8. Known limitations

1. **Postflop tile scrolls within Mastery tab** rather than being a true cross-tab navigation. This is by design — the Postflop Academy lives inside the Mastery tab, and a true cross-tab postflop home would require extracting the Academy into its own tab (much larger architectural change). Acceptable for v4.1.8 polish.
2. **M2 mastery weak-review proxy** — same approach as M1: we infer weak-review engagement from "any M2 session had bad+critical>0 AND ≥2 M2 sessions". No explicit weak-review event flag in localStorage. Acceptable.
3. **Aggregation sample sizes** — with 12-q sessions, some handClass / actionReason buckets may have only 1 scenario. The thresholds (seen≥2 for "weak", critCount>0 for any-leak surfacing) prevent noise in most cases.
4. **No real-device tester pass** — exhaustive simulated browser QA was run instead. A real-device pass remains a v4.1.9 line item.

---

## 9. Recommended next step

**v4.1.9 — M2 data expansion + tester pass.** Data + QA sprint.

Scope:
1. **+14 M2 scenarios** targeting primary-tag depth gaps:
   - `blocker_pressure`: +4 (monotone hearts with K-flush blocker, paired Ax with A-blocker, two-tone with K-flush blocker, etc.)
   - `value_betting`, `range_advantage_stab`: +3 each
   - `pot_control`, `give_up_strategy`: +2 each
2. **Re-run M2 seed audit** + final GPT review on the new scenarios
3. **Real-device tester pass** — collect player feedback on M2 surfaces
4. **Optional minor polish** — surface Module 2 mastery progress in the recommendation engine (`_pfAcademyRecommendation`)

Per the v4.1.8 brief: **stopping here, not starting v4.1.9, not productionizing Module 3, not touching preflop.**
