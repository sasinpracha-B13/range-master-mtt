# v4.0.12 — Postflop Drill Weak Spots Button

**Status:** ✅ Implemented + verified live. Awaiting commit/push.
**Date:** 2026-05-04
**Trigger:** v4.0.11 added a "Recommended next move" line that says "Replay weak spots first" but the only available action started a normal fresh session. v4.0.12 closes the loop with an actual button.

---

## What was added

### 1. "🎯 Drill Weak Spots" button on the completion summary
Renders **only** when the just-completed session had at least one bad/critical answer (the "weak profile" must include `hardMisses > 0`). Sits next to the existing "▶ Drill again" button.

When the player has no bad/critical answers, the button is hidden and a small italic note appears: *"No weak spots detected this session."* (Positive feedback rather than a disabled-button anti-pattern.)

The button is amber-styled (`.pf-weak-btn`) to differentiate it from the standard restart action.

### 2. "🎯 Review Mode · Weak Spots" badge on the question screen
When a weak-spot review session is active, an amber badge appears above the existing "Learn Mode · explanations enabled" tag with subcopy: *"Focused on concepts and board families missed last session."* Shown only when `App.state.postflopDrill.mode === 'weak_spots'`.

### 3. "Review session complete" header on completion of a weak-spot session
When `mode === 'weak_spots'`, the completion screen header copy changes:
- Context label: `🧪 Board Texture Trainer · Review session complete` (was "Complete")
- Headline: `REVIEW SESSION SUMMARY` (was "SESSION LEARNING SUMMARY")

All other summary blocks (quality label / strongest concepts / review signals / family notes / next move) work identically.

---

## How weak profile is derived

`_pfCurrentSessionWeakProfile(answers, scenarios)` returns either `null` (no weakness) or:
```js
{
  mode: 'weak_spots',
  sourceSessionId: 'session_<timestamp>',
  hardMisses: <count of bad+critical answers>,
  targetScenarioIds: [<scenarioIds the player got wrong>],
  targetConceptTags: [<concept tags from those scenarios>],
  targetFamilyKeys:  [<board family keys via _pfBoardFamilyKey()>]
}
```

Logic:
1. Walk `answers[]`. Each `tier === 'bad'` or `tier === 'critical'` adds the scenario id, its conceptTags, and its `_pfBoardFamilyKey(board)`.
2. **Soft fallback**: if `hardMisses < 2`, also walk `tier === 'acceptable'` answers — those contribute scenarios + tags + families with weight 0.5. Lets the player still get a useful focused queue when the session was strong overall but had a few "could be better" reads.
3. Returns `null` only if NONE of scenario ids / concept tags / family keys ended up populated (i.e. perfect best-only session with no acceptable either, or empty input).

The "weak button visibility" check additionally requires `hardMisses > 0` — soft fallback profiles still produce a queue if the player explicitly asks (via the falling-back-to-weak path) but the button is hidden when there are no bad/critical answers.

---

## How focused queue is built

`_pfBuildWeakSpotQueue(weakProfile, allScenarios, targetLen=12)` returns a queue of scenarios:

1. **Score every scenario** via `_pfWeakScenarioScore`:
   - `+100` if scenario.id is in `targetScenarioIds` (exact missed scenario)
   - `+60` if `_pfBoardFamilyKey(board)` is in `targetFamilyKeys`
   - `+40` if any of `scenario.conceptTags` is in `targetConceptTags`
   - `−30` if scenario was in the immediately previous local-history session (avoid recent repeats)
   - `+0..10` randomness for variety

2. **Filter weak hits**: scenarios with score > 30 (excludes scenarios that only got the randomness bonus).

3. **Sort weak hits by score desc, take up to `targetLen` unique scenarios.**

4. **Fill if too small**: if weak pool produced < `targetLen` scenarios, fill with normal-priority scenarios from the rest of the pool, scored at 30 ± 20 randomness with −50 penalty for recent-session repeats. Always avoids duplicate scenario ids.

5. **Always returns an array** (possibly empty). Never throws.

Live-verified queue properties on a 10-hard-miss session:
- 12 scenarios returned, all unique
- 9 of 9 missed scenarios from the source session included
- 12/12 (100%) family-coverage with the weak family list
- The remaining 3 slots filled with same-family scenarios

---

## How fallback behavior works

`startPostflopWeakSpotReview()` falls back to a normal `startPostflopDrill('pf_board_texture')` session when:

- `getPostflopReady()` is false (data not loaded) — also shows toast
- `App.state.settings.postflopBeta` is false — also shows toast
- `App.state.postflopDrill` has no answers (button shouldn't normally render but defensive)
- `_pfCurrentSessionWeakProfile()` returns `null` (perfect-best session with no acceptable either)
- `_pfBuildWeakSpotQueue()` returns empty array (no scenarios in pool, etc.)

Throughout, all field accesses are guarded (`(a && a.conceptTags) || []`) and all helpers wrapped in try/catch where they touch external state (history, scenarios). No path crashes the completion screen.

---

## QA result (23/23 checks pass)

| # | Check | Result |
|---|---|---|
| 1 | Postflop audit 262/0/0 (data unchanged) | ✅ |
| 2 | Module 1 loads | ✅ |
| 3 | Full normal 15-question session completes | ✅ (existing flow unchanged) |
| 4 | Summary shows "Drill Weak Spots" only when weak signals exist | ✅ |
| 5 | Perfect session: button hidden + "No weak spots detected" note shown | ✅ |
| 6 | All-acceptable session: button hidden (no hard misses) + note shown | ✅ |
| 7 | One-critical session: button visible | ✅ |
| 8 | Click weak button starts review session with `mode === 'weak_spots'` | ✅ |
| 9 | Queue prioritizes exact missed scenarios first | ✅ (verified queueIds[0] matches first missed scenario) |
| 10 | Queue includes related family/concept scenarios | ✅ (100% family coverage on 12-q queue) |
| 11 | Queue has no duplicate scenario IDs | ✅ |
| 12 | Queue fills to target length when weak pool too small | ✅ (one-bad session → 12-scenario queue) |
| 13 | Review Mode badge appears on question screen during weak session | ✅ |
| 14 | Badge title + subcopy render correctly | ✅ |
| 15 | Answer click → feedback flow works in review mode (5-block feedback) | ✅ |
| 16 | Review mode summary shows "Review session complete" + "REVIEW SESSION SUMMARY" | ✅ |
| 17 | No crash if conceptTags missing on answers | ✅ |
| 18 | No crash if local postflop history missing/cleared | ✅ |
| 19 | Empty scenarios pool → empty queue (no crash) | ✅ |
| 20 | Mobile 375px: weak button 343×49px tappable, no overflow | ✅ |
| 21 | Mobile 375px: review badge renders 343px wide, no overflow | ✅ |
| 22 | Console: 0 errors throughout | ✅ |
| 23 | Preflop drill regression: `startDrill('quick')` still works; all 5 tabs render; boss UI intact; beta toggle works | ✅ |

---

## Files changed

| File | Change |
|---|---|
| `index.html` | New CSS block (`.pf-review-mode-badge`, `.pf-weak-btn`, `.pf-weak-empty-note`) ~50 lines. New JS helper block (4 functions): `_pfCurrentSessionWeakProfile`, `_pfWeakScenarioScore`, `_pfBuildWeakSpotQueue`, `startPostflopWeakSpotReview`. Edits in `renderPostflopQuestion` (added `reviewModeBadge` variable + 1 line in HTML output). Edits in `renderPostflopComplete` (4 changes: `isWeakReview` flag, dynamic context label, dynamic headline, weak button + empty note in actions row). appVersion bump 4.0.11 → 4.0.12. |
| `service-worker.js` | VERSION v4.0.11 → v4.0.12 (cache-bust) |
| `PROJECT_STATE.md`, `TASK_BOARD.md` | Status update |
| `docs/specs/brief-v4.0.12-postflop-drill-weak-spots.md` | This file (NEW) |

**Untouched** (verified clean): `postflop/postflop_scenarios.json`, `postflop/postflop_taxonomy.json`, `postflop/postflop_concepts.json`, `tools/generate-postflop-module1.ps1`, `tools/audit-postflop-ps.ps1`, `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`, `tools/audit-postflop.js`, `ranges.json`, `manifest.json`. service-worker diff is solely VERSION v4.0.11 → v4.0.12.

---

## Remaining learning gaps

1. **No persistent weak-spot history across sessions** — the weak profile is computed per-session from the most recent answers. A future patch could merge with `localStorage.rmtt_postflop_history` to surface "you've now missed monotone in 3 consecutive sessions" insights.
2. **No "drill specific concept" button** — only family + scenario + concept aggregate is supported. A future patch could let the player tap "Review Signals: monotone_board_strategy" to drill that exact concept.
3. **No Test Mode toggle** — still deferred per scope-out rules. Could be v4.0.13 or v4.1.
4. **No per-question replay link from Critical Leaks list** — still shows missed boards + Q-numbers but no jump-back action.
5. **No Module 2 weak-spot integration** — Module 2 (Flop C-bet IP) has 11 scenarios and uses the `action_choice` qtype. The weak-spot helpers would mostly work but the family taxonomy and concept tags differ. Out of scope per instruction.

---

## Recommended next step

**Hand v4.0.12 to the tester.** The end-to-end loop is now closed:
- Player finishes session → sees learning summary →
- If they have weak spots → taps "🎯 Drill Weak Spots" →
- Gets a 12-scenario queue focused on their missed concepts/families →
- Sees "Review Mode · Weak Spots" badge to know they're in focused review →
- Completes the review → sees "Review Session Summary" → can start another normal session or another review.

Wait for tester feedback before scoping further:
- If they want **persistent multi-session tracking** → next patch could merge weak profile with localStorage history.
- If they want **per-concept drill buttons** → next patch could make Review Signals tappable.
- If they're satisfied with Module 1 → **Module 2 expansion** is v4.1 territory.
