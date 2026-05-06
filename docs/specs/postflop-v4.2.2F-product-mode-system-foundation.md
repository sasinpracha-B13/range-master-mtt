# Postflop v4.2.2F — Product Mode System Foundation + Premium Home Command Center

**Status:** UX architecture sprint. Replaces v4.1.8 misleading home tabs with a proper Training Command Center built on a real mode-state foundation. New `TRAINING_MODES` registry + 4 helper functions + safe CTA routing through `runTrainingModeAction()`. Mode persists across sessions via existing `rmtt_settings` localStorage. M3 explicitly preview-only ("SOON" badge). Bottom-nav rewrite intentionally deferred.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.2E-final-text-integrity-repair.md` (text cleanup chain that preceded this).

---

## 1. UX root cause

The v4.1.8 "Home Mode Tabs" shipped two tiles labeled `Preflop` and `Postflop Academy` that looked like top-level mode navigation but weren't:

- **Preflop tile:** `onclick="switchTab('drill')"` — collapsed the entire Preflop product (Quick Drill, Deep Drill, Weakness, Marginal, Boss Tests, Missions, Challenges, Browse, Mastery, Overall Exam) into a single jump to the Drill tab. Users tapped expecting a "Preflop hub" and got dumped into one specific surface.
- **Postflop tile:** `onclick="(function(){ document.querySelector('.postflop-betalab-section')?.scrollIntoView(...); })()"` — pure scroll. No navigation feedback. On mobile, often the user couldn't tell anything happened.

User feedback (paraphrased, Thai → English):
> "Tap Preflop and it links to a Drill page. Does Preflop only have a Drill page? And tap Postflop and it just scrolls down. Is this what a professional app should be?"

The criticism was correct. v4.1.8 had built the **UI for mode tabs** without building the **state foundation underneath**. The tiles had no real "mode" concept to switch between — they were just shortcut buttons dressed up as navigation.

---

## 2. Option analysis — why B+ was chosen

The original brief offered three options:

| Option | Description | Verdict |
|---|---|---|
| A — Inline accordion | Tile expands to show sub-options on Home, no state | Solves the visible bug, doesn't fix architecture, doesn't scale to M3+ |
| B — Persistent mode context (full bottom-nav refactor) | `App.state.mode` filters whole nav; each mode has its own home/tabs | Right long-term, but multi-sprint, regression risk on existing Preflop UX |
| C — Roll back tabs | Remove tiles, make Home sections bigger | Safe but doesn't fix the user's mental model — users still want a clear two-world separation |

**B+ chosen** (improved hybrid):
- Build the **mode-state foundation now** (registry + helpers + persistence + safe routing) — the missing piece from v4.1.8
- Build the **Premium Home Command Center** (real selector + mode-aware panel) on top of that foundation
- **Defer bottom-nav rewrite** until v4.2.4+ once M3 is migrated and we can validate the foundation under more modules

The advantage of B+ over raw B: **no regression risk on existing Preflop flows.** All existing Drill / Browse / Settings / Boss / Mission / Challenge surfaces continue to work unchanged. The Command Center is a *new* layer on Home; it doesn't replace anything below.

The advantage of B+ over A: **the foundation is real.** When v4.2.4 wants to wire mode-aware bottom nav, the registry and helpers are already there — no rewrite of the home tile system needed. v4.1.8's mistake (UI without foundation) is permanently avoided.

---

## 3. Product development principle (documented permanently)

**Going forward, every UX addition that introduces a "mode," "world," "tab," or "context" concept must define five things up front:**

| # | Property | What it means |
|---|---|---|
| 1 | **Visual promise** | What does this UI element tell the user it will do? (e.g., "this is a training mode selector") |
| 2 | **Actual behavior** | What does it actually do when interacted with? Must match the promise. |
| 3 | **User mental model** | How will a typical user explain this element to a friend? Must align with #1 + #2. |
| 4 | **Routing destination** | Where does each action go? Must be a real existing function or surface. |
| 5 | **Fallback if route is not ready** | If destination doesn't exist, show "preview / coming soon" — never a fake active button. |

**v4.1.8 violated #2, #3, and #5.** v4.2.2F satisfies all five.

This principle is now part of the project's permanent UX rules. Any future UX agent that creates a button/tile/tab must answer all five before code review.

---

## 4. Lessons learned from v4.1.8 (permanent)

| Anti-pattern | Why it failed | Replacement rule |
|---|---|---|
| Tile that looks like a mode switch but only calls `switchTab` | Users expect mode tiles to reveal context, not jump | A mode tile must change Home content visibly without forcing tab change |
| Scroll-only behavior for primary navigation | No feedback on mobile; users can't tell anything happened | Primary CTAs must produce a clear visual state change (panel swap / new screen / loading state) |
| Collapsing a complex product area into one default action | Hides the breadth of available training | Every mode panel must surface 4+ secondary actions, not just one primary |
| Missing fallback for unimplemented routes | A button that says "Module 3" when M3 doesn't exist is dishonest | Use `kind: 'preview'` + "SOON" badge + null route — visually distinct, not clickable |
| UI without state foundation | Tiles act like nav but have no `App.state.mode` to switch between | Build the state foundation first; the UI is just the rendered view of state |

---

## 5. Mode metadata registry implementation

New `TRAINING_MODES` constant (single source of truth for both modes):

```js
var TRAINING_MODES = {
  preflop: {
    id, title, shortTitle, icon, accent, subtitle, description,
    actions: [
      { id, label, hint, icon, kind: 'primary'|'secondary'|'preview', route: 'preflop:quick'|...|null, badge? }
    ]
  },
  postflop: { ... }
};
```

**Preflop actions (6):**
- `quick` (primary) — Quick Drill · 15 hands → `preflop:quick`
- `deep` — Deep Drill · 30 hands → `preflop:deep`
- `weakness` — Weakness Review → `preflop:weakness`
- `marginal` — Marginal Spots → `preflop:marginal`
- `browse` — Browse Ranges → `preflop:browse`
- `mastery` — Boss Tests · Missions → `preflop:drillsetup` (opens Drill tab; user picks Boss/Mission/Exam from setup screen)

**Postflop actions (6):**
- `m1` (primary) — Module 1 · Board Texture · 251 scenarios → `postflop:m1`
- `m2` (BETA badge) — Module 2 · Flop C-bet IP · 49 scenarios → `postflop:m2`
- `concepts` — Concept Library → `postflop:concepts` (scrolls to library inside Academy panel)
- `weakspot` — Weak Spot Review → `postflop:weakspot`
- `progress` — Postflop Progress → `postflop:progress`
- `m3` (preview, SOON badge) — Module 3 · BB Defense OOP → `null` (clickable but routes to a "coming soon" toast, no destination)

**Honesty enforced via the registry itself:** `m3.kind: 'preview'` + `m3.route: null` → the `runTrainingModeAction` helper short-circuits and shows a toast. There's no way to accidentally wire M3 to a real destination by editing one file.

---

## 6. Mode state foundation

```js
function getTrainingMode()                  // returns 'preflop' (default) or 'postflop'
function setTrainingMode(mode)              // persists to App.state.settings.trainingMode + re-renders
function getTrainingModeMeta(mode)          // returns the registry entry
function runTrainingModeAction(mode, id)    // single safe routing entry point
```

**Persistence:** uses the existing `App.state.settings` object (key `trainingMode`), which is already saved to `localStorage.rmtt_settings` via `App.saveProgress()`. No new localStorage key. Selected mode survives across sessions.

**Default:** `preflop` (the existing app's home).

**Re-render:** `setTrainingMode` triggers `renderHomeCommandCenterMount()` if user is on the Home (mastery) tab — instant visual feedback, no full page reload.

---

## 7. Home Command Center implementation

New `renderHomeCommandCenterMount()` replaces the body of `renderHomeModeTabsMount()` (alias kept for the existing call site at line ~30945).

**Structure:**

```
.tcc-shell
├─ .tcc-header
│   ├─ .tcc-eyebrow ("TRAINING COMMAND CENTER")
│   ├─ .tcc-title ("Choose your training world")
│   └─ .tcc-helper (one-line copy)
├─ .tcc-selector
│   ├─ .tcc-mode-btn.is-preflop  (Preflop selector card)
│   └─ .tcc-mode-btn.is-postflop (Postflop selector card)
└─ .tcc-panel.is-{mode}
    ├─ .tcc-panel-hero
    │   ├─ .tcc-panel-mode-label (pill)
    │   ├─ .tcc-panel-mode-title
    │   └─ .tcc-panel-mode-desc
    ├─ .tcc-panel-status      (honest status pills: rank, scenario counts)
    └─ .tcc-action-grid       (1 primary + 5 secondary tiles, mobile 2-col / tablet 3-col)
```

**Visual treatment:**
- Selected mode card has accent-colored border + glow + non-faded body
- Unselected mode card has 0.78 opacity (visual cue without being unclickable)
- Primary action spans full grid width with accent gradient
- Preview action has dashed border + 0.55 opacity + "SOON" badge
- BETA badge on M2 uses orange accent
- Mode switch is animated by CSS transitions, not JS — clean & lightweight

**Mobile-first verified at 375×812:**
- Total shell width: 343px (no overflow)
- Mode buttons: 156.5px each (2-up at 375px — fits comfortably)
- Action grid: 2-column on mobile (143.5px each), 3-column on tablet (≥720px)
- Primary CTA spans full width (295px on mobile)

---

## 8. Preflop mode content

Honest, complete coverage of the Preflop product:

| Action | Hint | Behavior |
|---|---|---|
| **Quick Drill** *(primary)* | 15 hands · standard mix | Sets `App.state.drill.mode = 'quick'`, switches to Drill tab, auto-starts drill after 60ms |
| Deep Drill | 30 hands · longer set | Same pattern, `mode = 'deep'` |
| Weakness Review | Recent leaks | Same pattern, `mode = 'weakness'` |
| Marginal Spots | Tough decisions | Same pattern, `mode = 'marginal'` |
| Browse Ranges | View charts | `switchTab('browse')` |
| Boss Tests · Missions | Open Drill setup | `switchTab('drill')` — labels the route honestly because Boss/Mission/Exam pickers live inside the Drill setup screen |

**No more "tap Preflop and end up at one mystery destination."** Users now see the breadth of Preflop training in one panel with one tap.

---

## 9. Postflop mode content

| Action | Hint | Behavior |
|---|---|---|
| **Module 1 · Board Texture** *(primary)* | 15 hands · 251 scenarios | `startPostflopDrill('pf_board_texture', 15)` |
| Module 2 · Flop C-bet IP *(BETA badge)* | 12 hands · 49 scenarios | `startPostflopDrill('pf_flop_cbet_ip', 12)` |
| Concept Library | 15 concept drills | Scrolls to `.pf-concept-library` inside existing Academy panel |
| Weak Spot Review | From recent sessions | `startPostflopWeakSpotReview()` if available, otherwise scroll to Academy |
| Postflop Progress | Mastery + history | Scrolls to `.postflop-betalab-section` |
| Module 3 · BB Defense OOP *(preview, SOON)* | Coming in v4.2.4 beta | **Null route** — toast "coming soon", no real destination |

**If Postflop Beta is off in Settings:** Module 1 / Module 2 / Concepts / Weak Spot all gracefully redirect to Settings with a toast "Enable Postflop Beta first." No fake clickable buttons.

**Status pills shown when Postflop loaded:** `M1: 251 scenarios` and `M2: 49 scenarios · BETA`. When not loaded: `Postflop Beta — enable in Settings`. Honest.

---

## 10. CTA routing table

Every visible CTA goes through one helper: `runTrainingModeAction(mode, actionId)`. No scattered onclick strings.

| Route ID | Real destination | Implemented in v4.2.2F |
|---|---|---|
| `preflop:quick` | `App.state.drill.mode='quick'; switchTab('drill'); startDrill();` | ✅ |
| `preflop:deep` | same pattern, mode='deep' | ✅ |
| `preflop:weakness` | same pattern, mode='weakness' | ✅ |
| `preflop:marginal` | same pattern, mode='marginal' | ✅ |
| `preflop:browse` | `switchTab('browse')` | ✅ |
| `preflop:drillsetup` | `switchTab('drill')` (Drill setup screen) | ✅ |
| `postflop:m1` | `startPostflopDrill('pf_board_texture', 15)` | ✅ (gated on postflopBeta=true) |
| `postflop:m2` | `startPostflopDrill('pf_flop_cbet_ip', 12)` | ✅ (gated on postflopBeta=true) |
| `postflop:concepts` | scroll to `.pf-concept-library` | ✅ (gated) |
| `postflop:weakspot` | `startPostflopWeakSpotReview()` | ✅ (gated; falls back to scroll if function missing) |
| `postflop:progress` | scroll to `.postflop-betalab-section` | ✅ |
| `null` (M3 preview) | shows toast "coming soon" | ✅ — no real destination is reachable |

---

## 11. Browser QA result

Verified via Claude Preview MCP:

| Check | Result |
|---|---|
| App loads at v4.2.2F | ✅ |
| Console errors | ✅ 0 |
| `TRAINING_MODES` registry exists | ✅ |
| All 4 helpers (`getTrainingMode`, `setTrainingMode`, `getTrainingModeMeta`, `runTrainingModeAction`) exist | ✅ `function` for all |
| `.tcc-shell` rendered on Home | ✅ |
| 2 mode buttons | ✅ |
| Default mode = `preflop` | ✅ |
| Click Postflop button → panel swaps to `tcc-panel is-postflop` | ✅ |
| Click Preflop button → panel swaps back | ✅ |
| Preflop panel: 6 actions, primary = "Quick Drill", 0 preview | ✅ |
| Postflop panel: 6 actions, primary = "Module 1 · Board Texture", 1 preview (M3) | ✅ |
| M2 BETA badge visible | ✅ |
| M3 SOON badge + non-clickable | ✅ |
| Mode persists in `App.state.settings.trainingMode` | ✅ (saved via App.saveProgress) |
| Existing Drill / Browse / Settings flows unchanged | ✅ (no other code touched) |
| Existing Postflop Academy panel still mounts below Command Center | ✅ |

## 12. Mobile QA result

375×812 viewport screenshot confirms:
- TCC shell width: 343px (no horizontal overflow)
- Mode buttons: 156.5px each, 2-up at 375px (comfortable)
- Action grid: 2-column on mobile, primary CTA spans full width
- Bottom nav not overlapped
- Install banner respects `safe-area-inset-top` (from v4.2.2C)
- Visual hierarchy: eyebrow → title → helper → selector → panel-hero → status → action grid
- Selected state immediately clear — accent border + glow + full opacity
- Preflop view: blue accent throughout
- Postflop view: orange accent throughout
- M3 preview tile visually distinct (dashed border, 0.55 opacity, "SOON" badge)

## 13. Audit results

| Audit | Result |
|---|---|
| Production audit | **300 / 0 / 0** unchanged |
| M2 seed audit | **24 PASS / 0 hard / 8 warnings** unchanged |
| M3 seed audit | **24 / 0 hard / 0 warnings** unchanged |
| R29 card-notation guard (from v4.2.2E) | **0 warnings** unchanged |

## 14. Text integrity result

No data files touched in this sprint. Production data text remains:
- 0 Thai mojibake
- 0 replacement chars (`�`)
- 0 R29 suspicious patterns

## 15. M3 not-playable confirmation

| Check | Verified |
|---|---|
| `postflop/postflop_scenarios.json` Module 3 count | **0** (still planning-only) |
| Module 3 action in `TRAINING_MODES` | `kind: 'preview'`, `route: null` |
| Click on M3 tile in UI | Shows toast "Module 3 · BB Defense OOP — coming soon", no navigation |
| `startPostflopDrill('pf_flop_cbet_oop_def', ...)` invoked anywhere in TCC | **No** — verified by source grep |

## 16. Files modified (5)

| File | Action |
|---|---|
| `index.html` | (1) Replaced `.home-mode-tabs` CSS with new `.tcc-*` styles (~210 lines). (2) Replaced v4.1.8 `renderHomeModeTabsMount()` body with new `TRAINING_MODES` registry + 4 helpers + `renderHomeCommandCenterMount()` + alias. (3) appVersion bump 4.2.2E → 4.2.2F. |
| `service-worker.js` | VERSION bump v4.2.2E → v4.2.2F (cache invalidation). |
| `docs/specs/postflop-v4.2.2F-product-mode-system-foundation.md` | NEW — this file. |
| `PROJECT_STATE.md` | v4.2.2F status block + permanent UX principle documentation. |
| `TASK_BOARD.md` | v4.2.2F staged → v4.2.2E committed. |

## 17. Forbidden files untouched verification

`git diff --name-only HEAD --` against forbidden list returned empty:
- `postflop/postflop_scenarios.json` ✅
- `postflop/postflop_concepts.json` ✅
- `postflop/postflop_taxonomy.json` ✅
- `postflop/postflop_audit_rules.js` ✅
- `postflop/postflop_audit.html` ✅
- `tools/*` (all audit scripts) ✅
- `ranges.json` ✅
- `manifest.json` ✅
- All preflop strategy data ✅
- All gamification / shop / wardrobe / Field FX ✅
- All Module 3 planning or production data ✅

## 18. Version bump result

```
appVersion:        4.2.2E → 4.2.2F ✅
SW VERSION:        v4.2.2E → v4.2.2F ✅
```

## 19. Sign-off

**Premium Home Command Center delivered.** Real mode-state foundation built. v4.1.8 mistake permanently retired with documented design principles. M3 explicitly preview-only — not playable, not migrated. v4.2.3 still paused.

**v4.2.2F deliberately did NOT:**
- Productionize Module 3
- Append M3 to production data
- Add M3 concepts/taxonomy to production
- Change any poker strategy
- Touch any data, audit script, or preflop file
- Rewrite the bottom nav (deferred to a future sprint after v4.2.4 lands and the foundation is validated under more modules)
- Add new localStorage keys (uses existing `App.state.settings`)
- Break any existing Preflop / Postflop / Drill / Browse / Settings flow

---

## 20. Recommendation for v4.2.3

**v4.2.3 — Module 3 Migration to Production Data** can now safely resume. The Command Center foundation makes M3 integration cleaner: when M3 ships in v4.2.4, the registry just needs `m3.kind: 'preview' → 'primary'` and `m3.route: null → 'postflop:m3'`, plus a route case in `runTrainingModeAction`. The visual treatment / button / panel changes are zero-effort.

**Future bottom-nav refactor sprint** (e.g., v4.3.0) can use `getTrainingMode()` to filter the bottom nav, e.g.:
- Preflop nav: Home / Drill / Browse / Progress / Settings
- Postflop nav: Home / Modules / Concepts / Review / Settings

But this is **not in scope for v4.2.2F or v4.2.3** — the current bottom nav stays unchanged.
