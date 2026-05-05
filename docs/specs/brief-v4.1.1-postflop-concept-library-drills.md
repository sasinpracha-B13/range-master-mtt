# v4.1.1 — Postflop Concept Library Drill Actions

**Status:** Implemented + verified live. Awaiting commit/push.
**Date:** 2026-05-05
**Trigger:** Make the v4.1.0 Concept Library actionable. Each of the 10 read-only concept cards becomes a one-tap entry point into a focused 12-question Module 1 drill that emphasises that concept's scenarios.

---

## What was added

### 1. Actionable Concept Library cards (10 cards, was display-only)
Each card in the v4.1.0 library now ships with a `🎯 Drill this concept` button on its footer. Tapping it builds a concept-focused 12-question queue and starts a Module 1 session in `concept` mode. Card structure also gains a head/foot layout so the new button has a stable home next to the existing `trained in Module 1` tag.

### 2. Optional `🚨 Review signal` pill on weak concepts
When the latest Module 1 session contains bad/critical answers tagged with a concept's primary or related tag, that concept's card lights up with a small `🚨 Review signal` pill and a subtle border-tint. Pure UX nudge — the drill button still works on every card regardless of signal state.

### 3. Concept Drill mode for `App.state.postflopDrill`
`startPostflopConceptDrill(conceptKey)` initialises:
```js
App.state.postflopDrill = {
  active: true,
  module: 'pf_board_texture',
  mode: 'concept',
  conceptKey: '<key>',
  conceptDisplayName: '<friendly name>',
  conceptPoolSize: <int>,
  conceptFillUsed: <bool>,
  queue: [<12 scenarios>],
  ...
};
```

### 4. Concept-mode badge on the question screen
A blue-accent badge (mirrors the v4.0.12 weak-spot orange badge) above the spot card:
```
🎯 Concept Drill · <Display Name>
Focused on scenarios that train this concept.
```
If the focused pool was too small and the queue had to fill from below-threshold scenarios, the subcopy switches to:
```
Focused on this concept, with related boards added for variety.
```

### 5. Dedicated Concept Drill summary surfaces
On the completion screen:
- **Context label**: `🎯 Concept Drill · <Display Name> · Complete`
- **Eyebrow** (new): `CONCEPT DRILL SUMMARY` (10px caps, blue)
- **Headline**: `Concept drill complete`
- **Card class**: `.postflop-summary-card.pf-concept-summary` (blue top accent)

All other summary blocks (learning quality, tier counts, learning summary, concept mastery breakdown, critical leaks, drill again button) are reused unchanged.

---

## Concept → scenario mapping (10 entries)

Each `_PF_CONCEPT_LIBRARY` entry now carries `key`, `tags`, `relatedTags`, `questionTypes`, `suitTextures`, `textureTags`. Display copy (name, def) is unchanged from v4.1.0.

| Key | Display name | Primary tags | Question types | Suit / texture |
|---|---|---|---|---|
| `range_advantage` | Range Advantage | `range_advantage` | `range_advantage` | `high_card_dominant`, `broadway_heavy`, `ace_high_dry` |
| `nut_advantage` | Nut Advantage | `nut_advantage` | `nut_advantage` | — |
| `board_texture` | Board Texture | `board_texture_recognition` | `range_advantage`, `nut_advantage`, `dynamic_level` | `high_card_dominant`, `low_heavy`, `middle_heavy`, `broadway_heavy` |
| `static_dynamic` | Static vs Dynamic | `static_board`, `dynamic_board` | `dynamic_level` | `very_wet`, `wet`, `dry`, `semi_dry`, `straightening` |
| `cbet_freq` | C-bet Frequency | `small_cbet_freq` | `frequency_strategy` | — |
| `sizing_family` | Sizing Family | `cbet_size_selection`, `polar_big_strategy`, `mixed_small_check` | `sizing_family` | — |
| `monotone` | Monotone Boards | `monotone_board_strategy` | — | `monotone` (suitTexture + textureTag) |
| `paired` | Paired Boards | `paired_board_strategy` | — | `paired` (textureTag) |
| `low_connected` | Low Connected Boards | `low_connected_caution` | — | `low_connected`, `low_heavy`, `highly_connected`, `connected` |
| `two_tone` | Two-tone Boards | `two_tone_board_strategy` | — | `two_tone` (suitTexture), `flushing` (textureTag) |

## Scoring rubric (`_pfConceptScenarioScore`)

| Match | Points |
|---|---|
| `scenario.conceptTags` includes any of `config.tags` | **+100** |
| `scenario.question.type` matches any of `config.questionTypes` | **+70** |
| `scenario.board.suitTexture` matches any of `config.suitTextures` **OR** `scenario.board.textureTags` shares any of `config.textureTags` | **+60** (counted once per scenario) |
| `scenario.conceptTags` includes any of `config.relatedTags` (only if exact tag did not already match) | **+40** |
| `scenario.id` is in the immediately previous session's IDs | **−30** |
| Tie-breaker randomness | **+0..10** |

Threshold: any scenario scoring **> 30** enters the focused pool. Pure-random ceiling is 10, so the threshold cleanly excludes scenarios that don't match anything. Below-threshold scenarios are used only as fallback fill if the focused pool can't hit `targetLen` (12).

---

## Helpers added (6 pure functions, all `_pf*` namespaced + 1 entry point)

| Function | Purpose |
|---|---|
| `_pfConceptDrillConfig(conceptKey)` | Returns normalised `{key, displayName, tags, relatedTags, questionTypes, suitTextures, textureTags}` config or `null` for unknown keys |
| `_pfConceptDisplayName(conceptKey)` | Friendly name lookup with fallback to the key itself |
| `_pfConceptScenarioScore(scenario, config, lastSessionIds)` | Pure scorer per the rubric above |
| `_pfBuildConceptQueue(conceptKey, allScenarios, targetLen)` | Returns `{queue, poolSize, fillUsed, displayName, conceptKey}`; queue length capped at `targetLen` (default 12) |
| `_pfConceptReviewSignal(conceptKey, academyStats)` | Returns `true` when concept's primary or related tags appear in the latest session's weak concepts |
| `startPostflopConceptDrill(conceptKey)` | Entry point wired to each library card's drill button. Falls back to normal Module 1 drill if the concept is unknown / pool empty |

`_pfConceptLibraryHtml` was upgraded to render the new card layout (head/foot, optional review pill, drill button) and call `_pfConceptReviewSignal` for each card.

All helpers are defensive against:
- Missing or unknown `conceptKey`
- Missing `_PF_CONCEPT_LIBRARY` (typeof guard)
- Missing `scenario.conceptTags`, `scenario.board`, `scenario.board.textureTags`
- Missing `localStorage` (try/catch on history load)
- Missing `_pfHistoryLoad`, `_pfAcademyStats`, `getModule1Scenarios`, `getPostflopReady`

---

## QA result (35 checks pass — 4 over the 31 minimum)

### Data integrity (5)
| # | Check | Result |
|---|---|---|
| 1 | Postflop audit 262/0/0 (data unchanged) | ✅ |
| 2 | `postflop/postflop_scenarios.json` untouched | ✅ |
| 3 | `postflop/postflop_audit_rules.js` untouched | ✅ |
| 4 | `tools/generate-postflop-module1.ps1` untouched | ✅ |
| 5 | `ranges.json`, `manifest.json` untouched | ✅ |

### Helpers + library (6)
| # | Check | Result |
|---|---|---|
| 6 | All 6 new helpers + entry point defined as functions | ✅ |
| 7 | `_PF_CONCEPT_LIBRARY` has 10 entries, each with `key` + drill mapping fields | ✅ |
| 8 | `_pfConceptDrillConfig` returns valid config for all 10 keys | ✅ |
| 9 | `_pfConceptDrillConfig` returns `null` for unknown key | ✅ |
| 10 | `_pfBuildConceptQueue` returns 12 unique scenarios for all 10 keys | ✅ |
| 11 | All queue scenarios are in Module 1 pool (no Module 2 leakage) | ✅ |

### UI rendering (5)
| # | Check | Result |
|---|---|---|
| 12 | Beta OFF hides Postflop Academy + Concept Library | ✅ |
| 13 | Beta ON shows Postflop Academy + Concept Library | ✅ |
| 14 | Library renders 10 cards + 10 drill buttons | ✅ |
| 15 | All 10 buttons wired to correct conceptKey via onclick | ✅ |
| 16 | Cards include name, def, head, foot, "trained in Module 1" tag | ✅ |

### Concept drill flow — all 10 concepts (10)
| # | Concept (key) | Pool ≥ 12 | Top 12 focused | Result |
|---|---|---|---|---|
| 17 | `range_advantage` | 195 | n/a (sample) | ✅ |
| 18 | `nut_advantage` | 145 | n/a (sample) | ✅ |
| 19 | `board_texture` | 251 | n/a (sample) | ✅ |
| 20 | `static_dynamic` | 222 | n/a (sample) | ✅ |
| 21 | `cbet_freq` | 132 | 12/12 train concept | ✅ |
| 22 | `sizing_family` | 185 | n/a (sample) | ✅ |
| 23 | `monotone` | 176 | 12/12 monotone scenarios | ✅ |
| 24 | `paired` | 142 | 12/12 paired scenarios | ✅ |
| 25 | `low_connected` | 140 | n/a (sample) | ✅ |
| 26 | `two_tone` | 181 | 12/12 two-tone/flushing scenarios | ✅ |

### Question + summary screens (8)
| # | Check | Result |
|---|---|---|
| 27 | `App.state.postflopDrill` has `mode='concept'`, `conceptKey`, `conceptDisplayName`, `conceptPoolSize`, `conceptFillUsed` | ✅ |
| 28 | Concept badge renders with title `🎯 Concept Drill · <Name>` | ✅ |
| 29 | Concept badge subcopy: default copy when `fillUsed=false` | ✅ |
| 30 | Summary context label: `🎯 Concept Drill · <Name> · Complete` | ✅ |
| 31 | Summary eyebrow: `CONCEPT DRILL SUMMARY` | ✅ |
| 32 | Summary headline: `Concept drill complete` | ✅ |
| 33 | Summary card has `pf-concept-summary` class (blue top accent) | ✅ |
| 34 | Review-signal pill renders when latest session has weak matching concepts | ✅ (5/10 cards lit on injected weak history) |

### Regression (4)
| # | Check | Result |
|---|---|---|
| 35 | Regular drill (`startPostflopDrill`) shows neither concept nor weak-spot badge | ✅ |
| 36 | Weak-spot drill still shows the orange weak-spot badge, not concept | ✅ |
| 37 | All 5 main tabs render (drill, progress, browse, settings, mastery) | ✅ |
| 38 | Existing preflop drill works (`startDrill('quick')` → `App.state.drill.queue.length === 15`) | ✅ |

### Robustness + mobile + console (7)
| # | Check | Result |
|---|---|---|
| 39 | Unknown `conceptKey` falls back to normal drill (no crash, no concept mode) | ✅ |
| 40 | Empty pool returns `{queue: [], poolSize: 0}` | ✅ |
| 41 | Mobile 375px: no horizontal overflow (bodyScrollW=375) | ✅ |
| 42 | Mobile 375px: academy section 317px wide, card 269px wide | ✅ |
| 43 | Mobile 375px: drill button 140×29px (readable + tappable) | ✅ |
| 44 | Mobile 375px: concept badge fits at 343×51px | ✅ |
| 45 | Console: 0 errors and 0 warnings throughout entire QA pass | ✅ |

> All 45 checks pass — 14 over the 31-check minimum specified in the brief.

---

## Files changed

| File | Change |
|---|---|
| `index.html` | (a) `_PF_CONCEPT_LIBRARY` enriched with `key` + drill mapping fields per entry. (b) New v4.1.1 helper block (~190 lines) with 6 pure helpers + `startPostflopConceptDrill` entry point. (c) `_pfConceptLibraryHtml` rewritten to render head/foot layout, optional review pill, drill button. (d) `renderPostflopQuestion` `else if (mode === 'concept')` branch added to badge logic. (e) `renderPostflopComplete` reworked with `isConceptDrill` branch for context label / eyebrow / headline / card class. (f) New v4.1.1 CSS block (~95 lines): `.pf-concept-card-head/foot`, `.pf-concept-card-review`, `.pf-concept-review-pill`, `.pf-concept-drill-btn`, `.pf-concept-mode-badge`, `.pf-concept-summary-eyebrow`, `.postflop-summary-card.pf-concept-summary` + 480px overrides. (g) `appVersion` 4.1.0 → 4.1.1. |
| `service-worker.js` | `VERSION` v4.1.0 → v4.1.1 (cache-bust only) |
| `PROJECT_STATE.md`, `TASK_BOARD.md` | Status update |
| `docs/specs/brief-v4.1.1-postflop-concept-library-drills.md` | This file (NEW) |

**Untouched** (verified clean): `postflop/postflop_scenarios.json`, `postflop/postflop_taxonomy.json`, `postflop/postflop_concepts.json`, `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`, `tools/generate-postflop-module1.ps1`, `tools/audit-postflop-ps.ps1`, `tools/audit-postflop.js`, `ranges.json`, `manifest.json`.

`git diff --stat HEAD`: `index.html` +472 / −30, `service-worker.js` +1 / −1.

---

## Remaining gaps (deferred)

1. **No persistent concept-drill XP / per-concept history** — sessions still log to a single `rmtt_postflop_history` blob; concept-drill sessions aren't separately bucketed for "you've drilled monotone 4× this week" analytics.
2. **No queue length toggle** — fixed at 12 questions; could add a 6 / 12 / 24 slider.
3. **No Test Mode** — Concept drill stays in Learn Mode (hints + explanations on). Per scope-out across patches.
4. **Review-signal threshold is binary** — pill lights up the moment a tag appears in any bad/critical answer; doesn't distinguish "1 miss" vs "5 misses". A counter or severity hint could come later.
5. **Module 2+ are still display-only**. Concept drills remain Module 1 only (the brief's allowed scope).

---

## Recommended next step

**Hand v4.1.1 to the tester.** The Concept Library now teaches the player to recognise their weak concept patterns and immediately drill them in 12-question targeted sessions. Wait for tester feedback before scoping further:
- If tester wants **per-concept session history / streaks** → small data sprint adding a `conceptKey` column to history sessions and an Academy snapshot row.
- If tester wants **adjustable queue length** → trivial UI patch (slider above each library card or a global default).
- If tester wants **Module 2 production-ready scenarios** → larger data sprint mirroring the v4.0.7 generator pattern.
- If tester is satisfied → short break before Module 2 implementation begins.
