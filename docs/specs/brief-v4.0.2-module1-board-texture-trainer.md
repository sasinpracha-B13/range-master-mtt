# Brief — v4.0.2: Post-flop Module 1 — Board Texture Trainer UI (Architecture)

> **Owner**: Architecture Subagent (planning); DEV Integration Agent (future implementation).
> **Status**: planning only. Awaiting consolidation with UX / Scenario Review / QA into `brief-v4.0.2-implementation-ready.md`, then human approval.
> **Builds on**: v4.0.1 commit `2593e5c` (frozen `App.postflop` namespace live in production).

---

## 1. Goal

Ship the **first visible postflop UI surface**: a single new training module — **Board Texture Trainer** — that consumes the already-live `App.postflop` namespace, renders board-only questions about range/nut advantage and sizing family, and surfaces the multi-tier scoring + multi-section explanation that v4.0.0 designed.

Player visible result: a new entry point on the Home tab → enters a Board Texture session → answers 10–20 board questions → sees feedback per question → finishes with a summary screen.

**Deliberately narrow**:
- ONE module only (Board Texture Trainer = `pf_board_texture` in the data).
- NO hero-hand questions (Module 2 is v4.0.3+).
- NO postflop boss / mission / challenge / cosmetic / FX integration.
- NO modification to existing preflop drill engine.

---

## 2. How v4.0.2 should consume `App.postflop`

The runtime API shipped in v4.0.1 is **frozen** and read-only:

```
App.postflop = Object.freeze({
  ready: true,
  schemaVersion: '1.0.0',
  scenarios: Object.freeze([ ... 31 approved scenarios ... ]),
  taxonomy: Object.freeze({ ... }),
  concepts: Object.freeze({ concepts: [...] }),
  stats: Object.freeze({ total, approved, skipped }),
  error: null
})
```

### Access pattern (read-only)

v4.0.2 code MUST treat `App.postflop` as immutable. All accessors are read-only. The pattern is:

```js
function getPostflopReady() {
  return !!(window.App && App.postflop && App.postflop.ready === true);
}

function getModule1Scenarios() {
  if (!getPostflopReady()) return [];
  return App.postflop.scenarios.filter(function (s) {
    return s.module === 'pf_board_texture';
  });
}

function getConceptByKey(key) {
  if (!getPostflopReady()) return null;
  var entry = App.postflop.concepts.concepts.find(function (c) {
    return c.key === key;
  });
  return entry || null;
}
```

No code in v4.0.2 ever calls `Object.defineProperty`, `Object.assign`, `splice`, `push`, etc. on anything under `App.postflop`. The frozen API throws if you try (verified in v4.0.1 QA).

### Data flow

```
  postflop_scenarios.json  (committed, audited)
            │
            ▼ fetched at boot by loadPostflopData()  ← v4.0.1
            │
            ▼ Object.freeze + filter to auditStatus === 'approved'
            │
   App.postflop.scenarios   ← frozen array of 31 scenarios
            │
            ▼ getModule1Scenarios() [v4.0.2 — pure filter]
            │
   moduleScenarios          ← array of `pf_board_texture` only (currently 20/31)
            │
            ▼ buildPostflopQueue(moduleScenarios, sessionLength) [v4.0.2 — pure builder]
            │
   App.state.postflopDrill.queue   ← session-scoped state (mutable)
            │
            ▼ render functions [v4.0.2]
            │
   DOM: question card / answer choices / feedback card
```

The only mutable layer is **session state** (`App.state.postflopDrill`). The data layer (`App.postflop`) stays frozen forever.

---

## 3. Module entry point

Two surfaces grow a single new entry point each. **Both surfaces are gated by `App.state.settings.postflopBeta === true`.** Default is `false` — players see no change unless they opt in via DevTools console (settings UI for the toggle is v4.0.4).

### Surface 1 — Home (Mastery) tab

Append a new card below the existing "MASTERY PATH" section:

```
┌────────────────────────────────────────────┐
│ 🧪 POSTFLOP BETA                            │
│  Module 1 — Board Texture Trainer          │
│  Read board class, range/nut advantage,    │
│  c-bet sizing family.                      │
│                                            │
│  20 scenarios · ~10 min                    │
│                                            │
│  [ ▶ Start Board Texture Drill ]           │
└────────────────────────────────────────────┘
```

This card only renders when `App.state.settings.postflopBeta === true && App.postflop.ready === true && getModule1Scenarios().length > 0`.

### Surface 2 — Settings → Beta Features

Add ONE row to the existing settings panel (under "FX & Animation" or a new "Beta Features" section):

```
[ ☐ ] Enable post-flop beta modules
       Adds Board Texture Trainer to Home tab.
       Scenarios: 20 · Audited: 2026-05-04
       Hidden by default (alpha quality)
```

Toggling this updates `App.state.settings.postflopBeta` and persists via existing `App.saveSettings()` mechanism.

---

## 4. Minimal allowed UI integration in `index.html`

The brief enumerates the **exact** new code allowed. DEV Integration Agent must not exceed this scope.

### Code additions (all in one fenced v4.0.2 block at end of `<script>`, before `App.init()`)

```js
// =================================================================
// v4.0.2 — POSTFLOP MODULE 1 (Board Texture Trainer) — UI surface
// Reads frozen App.postflop. Renders module entry on Home tab when
// postflopBeta flag is on. Renders question + feedback screens via
// new postflop drill state. Does NOT touch preflop drill engine,
// classifyAnswer, getSRSKey, or any existing render path.
// =================================================================

// --- Read-only data accessors ---
function getPostflopReady()           { ... }
function getModule1Scenarios()         { ... }
function getConceptByKey(key)          { ... }
function getTaxonomyEnum(name)         { ... }

// --- Session state (separate namespace from App.state.drill) ---
App.state.postflopDrill = {
  active: false,
  module: null,
  queue: [],
  currentIndex: 0,
  answers: [],
  startTime: null,
  phase: 'setup'
};

// --- Builders ---
function buildPostflopQueue(scenarios, sessionLength) { ... }
function startPostflopDrill(moduleId, sessionLength)  { ... }
function classifyPostflopAnswer(scenario, choiceId)   { ... }
function recordPostflopAnswer(scenario, choiceId, cls){ ... }

// --- Renderers ---
function renderPostflopHomeCard()        { ... }   // appended to Home tab
function renderPostflopQuestion()        { ... }   // mounts in #postflopScreen
function renderPostflopAnswer(...)       { ... }
function renderPostflopComplete(...)     { ... }

// --- Navigation ---
function showPostflopScreen()            { ... }   // hide tab-mastery, show #postflopScreen
function exitPostflopScreen()            { ... }   // back to Home tab

// --- Settings UI integration ---
function renderPostflopBetaToggle()      { ... }   // appends to Settings panel
function togglePostflopBeta(enabled)     { ... }

// --- Boot wiring ---
// On render of Home tab: call renderPostflopHomeCard() if postflopBeta on.
// On render of Settings tab: call renderPostflopBetaToggle().
// =================================================================
// END v4.0.2 — POSTFLOP MODULE 1
// =================================================================
```

### HTML additions (one new container)

```html
<!-- v4.0.2: postflop drill screen container; default display:none -->
<div id="postflopScreen" class="container" style="display:none"></div>
```

Inserted as a sibling to existing `#drillScreen` and `#drillComplete` containers under `.main-content`.

### CSS additions (small block, scoped to postflop classes)

Approximately 60–100 lines of CSS for:

- `.postflop-home-card` (entry point card on Home)
- `.postflop-question-card`, `.postflop-board-row`, `.postflop-board-card`
- `.postflop-choice-list`, `.postflop-choice-button`
- `.postflop-feedback-card`, `.postflop-explanation-section` (collapsible)
- `.postflop-progress-bar`, `.postflop-stats-row`
- `.postflop-beta-toggle` (Settings)

All class names prefixed `postflop-` so they cannot collide with existing preflop styles.

### Existing files NOT modified

- `classifyAnswer()`, `handleAnswer()`, `renderDrillQuestion()`, `renderAnswerScreen()`, `getSRSKey()`, `updateSRS()`, `buildDrillQueue()`, `startDrill()`, `App.state.drill.*`
- `renderMastery()` is touched only via a one-line append at the bottom of its render output (call `renderPostflopHomeCard()`); the rest of Mastery render is untouched.
- `renderSettings()` is touched only via a one-line append (call `renderPostflopBetaToggle()`).
- All boss / mission / challenge / overall-exam code paths.
- All cosmetic / FX / Aura / Collection code.

### Data files NOT modified

- `postflop/postflop_scenarios.json`
- `postflop/postflop_taxonomy.json`
- `postflop/postflop_concepts.json`
- `postflop/postflop_audit_rules.js`
- `tools/audit-postflop.js`

If a scenario edit is needed, GTO Data Subagent owns it in a separate task.

---

## 5. Scoring behavior

The multi-tier scoring designed in v4.0.0 ships in v4.0.2:

```js
function classifyPostflopAnswer(scenario, choiceId) {
  // Returns: { tier, score, isCritical }
  // tier ∈ { 'best', 'acceptable', 'bad', 'critical' }
  if (scenario.answer.best.includes(choiceId))       return { tier: 'best',       score: scenario.scoring.best,       isCritical: false };
  if (scenario.answer.acceptable.includes(choiceId)) return { tier: 'acceptable', score: scenario.scoring.acceptable, isCritical: false };
  if (scenario.answer.critical.includes(choiceId))   return { tier: 'critical',   score: scenario.scoring.critical,   isCritical: true  };
  if (scenario.answer.bad.includes(choiceId))        return { tier: 'bad',        score: scenario.scoring.bad,        isCritical: false };
  // Fallback (defensive — should not happen if R04/R15 audit holds)
  return { tier: 'bad', score: 0, isCritical: false };
}
```

This function **does not** call into preflop `classifyAnswer()`. It is its own pure function operating on the scenario object.

---

## 6. Feedback / explanation behavior

Per the design principle ("teach reasoning, not just answers"), the feedback card has **two tiers**:

### Tier 1 — Always visible (above the fold)

- Result icon + label (e.g., `✅ Best`, `≈ Acceptable`, `❌ Bad`, `🚨 Critical leak`)
- Player's choice + correct choice (label, not id)
- `explanation.short` — one-line crisp principle
- Concept tag pills (clickable in v4.1; static text in v4.0.2)

### Tier 2 — Collapsible sections (closed by default on mobile, open by default on desktop)

Renders only the sections that are non-null in the scenario:

- `▸ Range Logic`
- `▸ Nut Logic`
- `▸ Hand Logic` (skipped for Module 1 — board-texture questions have null `handLogic`)
- `▸ Sizing Logic`
- `▸ Common Mistake` (highlighted with amber accent if scenario has critical answers)

Each section is a `<details>` element with `<summary>` showing the section name. Native browser disclosure widget — no custom JS needed.

### Action row

- `[ Next →]` (primary) — advances to next question, or to summary if last
- `[ ✕ Exit ]` (secondary) — returns to Home tab, discards session progress (with confirm modal)

---

## 7. Session lifecycle

### Start
1. Player taps "Start Board Texture Drill" on Home (or in Settings → Beta).
2. `startPostflopDrill('pf_board_texture', 15)` runs:
   - Filters `App.postflop.scenarios` to module-matching subset (~20 scenarios).
   - Shuffles deterministically (Fisher-Yates with seeded RNG for reproducibility — same seed currently means same order across reloads, optional improvement v4.0.5).
   - Slices first N (15 by default; toggle 10/15/20 in Settings later).
   - Sets `App.state.postflopDrill = { active: true, module: 'pf_board_texture', queue, currentIndex: 0, answers: [], phase: 'question' }`.
   - Hides all other screens; shows `#postflopScreen`.
   - Calls `renderPostflopQuestion()`.

### Per question
1. `renderPostflopQuestion()` reads `state.queue[state.currentIndex]`, builds card markup, mounts in `#postflopScreen`.
2. Player taps a choice → onclick handler calls `handlePostflopAnswer(choiceId)`:
   - `cls = classifyPostflopAnswer(scenario, choiceId)`
   - `recordPostflopAnswer(scenario, choiceId, cls)` pushes to `state.answers[]`
   - `state.phase = 'answer'`
   - `renderPostflopAnswer(scenario, choiceId, cls)` shows feedback card.
3. Player taps `Next →`:
   - `state.currentIndex++`
   - If `currentIndex >= queue.length`: `state.phase = 'complete'`; `renderPostflopComplete()`.
   - Else: `state.phase = 'question'`; `renderPostflopQuestion()`.

### End
1. `renderPostflopComplete(state)` shows summary card:
   - Final score (sum of `score` across answers / total possible = N × 1.0)
   - Per-tier counts: best / acceptable / bad / critical
   - Concept-mastery breakdown (which concepts were tested + accuracy per concept)
   - List of critical leaks (if any) with link to scenario explanation
2. `[ Back to Home ]` button returns to Home tab; postflop session state is cleared.

### Exit early
- `[ ✕ Exit ]` from question or feedback screen shows confirm modal.
- On confirm: clear `App.state.postflopDrill`, hide `#postflopScreen`, return to Home tab.

---

## 8. Read-only data access pattern (defensive coding)

Every postflop function MUST defend against:

- `App.postflop` not present yet (loader still running or failed)
- `App.postflop.ready === false` (load failed)
- `App.postflop.scenarios.length === 0` (empty dataset)
- `App.state.settings.postflopBeta === false` (beta off — should not even reach renderer, but defend)

Pattern:

```js
function startPostflopDrill(moduleId, sessionLength) {
  if (!getPostflopReady()) {
    showToast('Post-flop data not loaded. Try again in a moment.');
    return;
  }
  if (!App.state.settings.postflopBeta) {
    showToast('Post-flop beta is disabled in Settings.');
    return;
  }
  var pool = getModule1Scenarios();
  if (pool.length === 0) {
    showToast('No scenarios available for this module.');
    return;
  }
  // ... rest
}
```

The renderers also defend — if state is missing, they render a "Beta unavailable" placeholder (silently degrades; never throws).

---

## 9. Avoiding the existing preflop drill engine

Hard rules:

| Existing function | v4.0.2 may call? | Why |
|---|---|---|
| `classifyAnswer(userAction, freqs)` | ❌ NO | Preflop-only signature; postflop uses tier-based scoring |
| `handleAnswer(userAction)` | ❌ NO | Mutates `App.state.drill` (preflop state) |
| `renderDrillQuestion()` | ❌ NO | Preflop UI |
| `renderAnswerScreen(...)` | ❌ NO | Preflop UI |
| `buildDrillQueue(...)` | ❌ NO | Preflop pool builder |
| `startDrill(mode)` | ❌ NO | Preflop drill state init |
| `getSRSKey(stack, pos, action, hand)` | ❌ NO | Preflop SRS key format |
| `updateSRS(key, score, isPure, ...)` | ❌ NO | Preflop SRS storage; postflop SRS is v4.0.4 territory |
| `getModuleZone(moduleId)` | ✅ READ-ONLY OK | Pure function; can reuse for module display info |
| `formatActionLabel(action)` | ✅ READ-ONLY OK | Pure formatting function |
| `showToast(text)` | ✅ OK | Generic UI helper |
| `renderMastery()` | ✅ APPEND-ONLY | Single line at end to mount postflop home card |
| `renderSettings()` | ✅ APPEND-ONLY | Single line at end to mount beta toggle |
| `App.saveProgress()` / `App.saveSettings()` | ✅ OK | Saves whole state; postflopDrill cleared before save (or excluded — see § 10) |

The preflop tab navigation (`switchTab('drill')`) is NOT touched; postflop has its own screen routing via `showPostflopScreen()` / `exitPostflopScreen()` that hides the active tab panel and shows `#postflopScreen`.

---

## 10. Storage isolation (no preflop SRS pollution)

v4.0.2 does **not** introduce postflop SRS yet (that's v4.0.4). Per-session results live only in memory (`App.state.postflopDrill.answers[]`) and are discarded when the session ends.

If session-history persistence is desired in v4.0.2 (still TBD — see Open Questions), it would use a NEW localStorage key:

```
localStorage.rmtt_postflop_history = {
  schema: 'postflop-history-v1',
  sessions: [
    { sessionId, module, startedAt, completedAt, answers: [...] }
  ]
}
```

This namespace is separate from `rmtt_progress` (preflop SRS) and `rmtt_settings`. Backup export already includes `data.settings`; if `rmtt_postflop_history` is added, the backup builder needs ONE additional key. (Decision deferred — see Open Questions.)

`App.state.postflopDrill` is **explicitly excluded** from `App.saveProgress()` and the backup builder — it's session-scoped, not durable state.

---

## 11. Rollback strategy

v4.0.2 is gated three ways, so rollback is granular:

| Trigger | Effect | Player visible |
|---|---|---|
| `App.postflop.ready === false` | Home card not rendered; entry not reachable | Same as v3.x — no postflop UI at all |
| `App.state.settings.postflopBeta === false` (default) | Home card not rendered; entry not reachable | Same as v3.x |
| Settings toggle off | Home card removed on next render | Reverts to v3.x view |
| Critical bug in v4.0.2 production | Hot-fix: set `App.postflop.ready = false` via console (frozen — must reload to override); OR ship a patch that early-returns from `renderPostflopHomeCard()` | Beta UI disappears |

For an **emergency revert** (catastrophic UI bug), the fastest path is to `git revert <v4.0.2-hash>` and redeploy — leaves v4.0.1 loader intact, just removes the UI surface. This is a clean revert because v4.0.2 is purely additive.

---

## 12. Summary screen design

After the last question, `renderPostflopComplete()` shows:

```
┌────────────────────────────────────────────┐
│ ✅ Board Texture Drill Complete            │
│                                            │
│ Score: 13.5 / 15  (90%)                    │
│ ──────────────────────────────────────────│
│ Best         12  ✅                        │
│ Acceptable    1  ≈                         │
│ Bad           1  ❌                        │
│ Critical      1  🚨  ← amber if non-zero  │
│                                            │
│ ▸ Concept mastery (this session)            │
│   range_advantage     5/5   100%   ✅      │
│   nut_advantage       3/3   100%   ✅      │
│   dry_high_card_strat 2/3    67%   ≈      │
│   low_connected_caut  1/2    50%   ❌      │
│                                            │
│ 🚨 Critical leaks                          │
│   • pf_btn_v_bb_srp_100bb_flop_5h4d3c_001  │
│     "Caller (BB) on 5♥4♦3♣ — you picked    │
│      preflop_raiser"                       │
│      [ Re-read explanation ]                │
│                                            │
│ [ ▶ Drill again ] [ ← Back to Home ]       │
└────────────────────────────────────────────┘
```

No XP / Chips / cosmetic grant in v4.0.2 (that's v4.1 territory). Just feedback.

---

## 13. Defer to v4.0.3+ (explicit)

| Item | Why deferred |
|---|---|
| Module 2 — Flop C-bet IP Trainer (hero-hand questions) | UI complexity (hero hand + action choices); ship Module 1 first to validate the architecture |
| Module 3 — BB Defense | Data not ready (planned v4.1 data expansion) |
| Postflop SRS storage | Adds new localStorage schema; v4.0.4 |
| Postflop session history persistence | Open question — see § 14 |
| XP / Chips for postflop | Economy balance not designed for postflop yet; v4.1 |
| Postflop boss tests | Requires module mastery before bossing; v4.2 |
| Cosmetic rewards for postflop completions | Out of scope until module shows engagement; v4.2+ |
| Concept tag click → concept page modal | UI sub-feature; v4.0.5 |
| Real solver verification per scenario | Author tooling; v4.1 |
| Custom session length picker UI | Default 15 hard-coded in v4.0.2; UI in v4.0.4 |

---

## 14. Open questions for human review

Before consolidation:

1. **Session history persistence** — store completed sessions in `localStorage.rmtt_postflop_history` (new namespace) or keep session-only in v4.0.2?
2. **Default session length** — 10, 15, or 20 questions for v4.0.2 default?
3. **Beta toggle visibility** — show the beta toggle on Settings panel (v4.0.2) or hide until v4.0.4 (toggle only via DevTools console for v4.0.2)?
4. **Critical-leak summary** — list per-leak in summary card (current proposal) or aggregate count only?
5. **Re-read explanation** in summary — re-renders the feedback card in a modal, or links back into a "review mode" of the session?
6. **Reduced motion** — postflop UI should respect existing `App.state.settings.fxRespectMotion` (no new toggle)? (Recommended: yes.)
7. **Mobile chart for stats** — render the per-tier breakdown as bars or just numbers? (Recommended: just numbers in v4.0.2; bars in v4.0.5 polish.)

---

## 15. Stop condition

Architecture Subagent stops after producing this brief. The Orchestrator consolidates this with the UX plan, scenario review, and QA plan into a single implementation-ready brief.

Architecture Subagent does NOT:
- Write any code
- Edit `index.html` or `service-worker.js`
- Modify postflop data files
- Commit or push

**Next step**: UX Subagent designs the screens; Scenario Review Subagent grades the seed data; QA Subagent designs the test plan; Orchestrator consolidates.

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | Architecture Subagent | Initial publication |
