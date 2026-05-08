# Postflop v4.3.2C Option A -- M4 Beta Lab User-Signal Review

**Date:** 2026-05-07
**Sprint type:** Doc-only Option A signal review on top of v4.3.2C (no code change).
**Predecessor HEAD (entry):** `c22ccc8` (v4.3.2C-doc reconcile)
**Substantive predecessor:** `090f21f` (v4.3.2C signal-persistence fix)
**Status:** complete; decision rule applied; **STAY OPTION A** (thresholds NOT met).

## 1. Baseline state at entry (v4.3.2C)

```
HEAD                       = origin/main = c22ccc8
Production count           = 477  (251 M1 + 49 M2 + 85 M3 + 92 M4)
M4 status                  = Limited Beta, 92 approved, all instrumented
appVersion                 = 4.3.2C
SW VERSION                 = v4.3.2C
Signal-persistence fix     = LIVE (session.answers[] + session.mode persisted)
working tree               = clean
```

## 2. Data gathering method

The Beta Lab dashboard (`_pfBetaQAStatsForModule('pf_turn_barrel_oop_def')`) reads its inputs from `localStorage['rmtt_postflop_history']` -- a per-browser, client-side store. There is no server-side aggregation. To inspect the data the dev opens the live Netlify URL in a browser and either:

- Reads the dashboard panel directly (top of the M4 mastery section), or
- Runs `App.postflopHistorySummary()` in DevTools, or
- Inspects `localStorage.getItem('rmtt_postflop_history')` directly.

This review inspects the Chrome MCP browser instance that has been used for v4.3.1B / v4.3.2 / v4.3.2A / v4.3.2B / v4.3.2C smoke tests. Those QA tests did NOT play full M4 sessions on Netlify -- they only inspected `appVersion`, `getModule4Scenarios().length`, and per-scenario field values via `eval(...)`. So the inspected browser carries the natural state of "v4.3.2C deployed, no M4 sessions played."

**Important caveat.** This review reflects exactly one browser instance (the QA Chrome MCP). The project owner may have additional browser instances with M4 history that are not reachable from the dev environment. Before finalizing the v4.3.3-vs-v4.4.0 decision, the project owner should also export their own dashboard snapshot via the M4 Beta Lab "Copy M4 Beta QA Snapshot" button and merge those signals into this review.

## 3. Live data probe (Chrome MCP, post-v4.3.2C deploy)

```
Netlify  https://range-master-mtt.netlify.app/
appVersion                          : 4.3.2C
M4 pool size at runtime              : 92
localStorage keys                    : [rmtt_streaks, rmtt_profile,
                                        rmtt_progress, rmtt_settings,
                                        rmtt_stats, rmtt_disclaimer]
localStorage['rmtt_postflop_history'] : MISSING (0 bytes)

_pfM4BetaQAStats() output:
  sessionCount         = 0
  questionCount        = 0
  latestPctScore       = null
  averagePctScore      = null
  criticalCount        = 0
  criticalRate         = 0
  weakReviewUsed       = false
  rowsByActionReason   = []
  rowsByRecommendedAction = []
  rowsByHeroHandRole   = []
  rowsByHandClass      = []
  weakConcepts         = []
  weakActionReasons    = []
  last3Sessions        = []
  criticalScenarioIds  = []
  lastWeakProfile      = null
```

**Interpretation:** the v4.3.2C signal-persistence fix is live (verified during v4.3.2C Netlify smoke -- `_pfHistoryRecordSession.toString()` contains `compactAnswers` and `mode: s.mode || 'normal'`). The dashboard correctly returns the empty state because no sessions have populated history. There is no instrumentation bug to investigate; the data simply has not yet been generated.

## 4. Threshold check

Per the v4.3.2C decision framework:

| # | Threshold | Required | Actual (Chrome MCP) | Pass |
|---|---|---|---|---|
| 1 | M4 sessions completed | >= 5 | 0 | NO |
| 2 | M4 hands answered | >= 60 | 0 | NO |
| 3 | actionReason coverage in user history | >= 8 of 12 | 0 of 12 | NO |
| 4 | conceptTag coverage in user history | >= 8 of 12 | 0 of 12 | NO |
| 5 | critical mistake buckets distinct | >= 3 | 0 | NO |
| 6 | weak-spot review used | >= 1 | 0 | NO |
| 7 | reason_choice volume share | >= 30% | n/a | NO |
| 8 | action_choice volume share | >= 30% | n/a | NO |

**8 of 8 thresholds NOT met.**

## 5. Per-axis weakness analysis

Cannot be performed: zero data. Reserved for the next signal-review sprint once thresholds are satisfied. The dashboard's per-axis tables (rowsByActionReason / rowsByRecommendedAction / rowsByHeroHandRole / rowsByHandClass / weakConcepts / weakActionReasons / weakHeroHandRoles) are empty arrays; the lastWeakProfile is null; the last3Sessions array is empty.

When data does exist, the analysis pipeline is mechanical -- the dashboard already computes:

- weakest actionReasons via `out.weakActionReasons` (filter: `critCount > 0 || badCount >= 2 || (seen >= 2 && pct < 50)`)
- weakest conceptTags via `out.weakConcepts` (latest-session bad/critical answers grouped by tag, count-sorted)
- weakest heroHandRoles via `out.weakHeroHandRoles` (same filter as actionReasons)
- weakest recommendedActions (over/under-frequency proxy) via `out.weakRecommendedActions`
- critical mistake concentration via `out.criticalCount`, `out.criticalRate`, `out.criticalScenarioIds`
- weak-spot review usage via `out.weakReviewUsed` (true if any session has `mode='weak_spots'`)
- repeat-session improvement trend via `out.last3Sessions[].pct`

For reason_choice vs action_choice accuracy split, the dashboard does NOT yet break out by qtype (deferred per v4.3.2C review Section 4.1). When data exists, this can be computed by re-grouping `allAnswers.filter(a => a.questionType === 'reason_choice')` vs `'action_choice'` -- the per-answer field is now persisted in v4.3.2C.

## 6. Decision rule application

```
if (M4 sessions < 5)                       -> Option A   <-- TRIGGERED
elif (concentrated weakness)               -> Option B
elif (M4 mature signals)                   -> Option C
else                                       -> Option A
```

**Decision: STAY OPTION A.**

Rationale: the gating threshold (>= 5 M4 sessions completed) is not satisfied. All other thresholds are downstream of session count and likewise unsatisfied. There is no evidence base on which to evaluate Option B (which requires identifying "concentrated weakness in 1-3 buckets") or Option C (which requires "M4 signals look mature"). Auto-starting either would be authorial-intuition-driven content authoring, which the v4.3.2C brief explicitly forbids ("DO NOT auto-start v4.3.3 or v4.4.0 without user-signal data").

## 7. What is still needed before re-evaluation

### 7.1 Direct data requirements

The minimum dataset to re-run this threshold check meaningfully:

- **>= 5 M4 sessions**, each completing the 12-question default queue (so >= 60 hands answered).
- Sessions distributed across **>= 2 calendar days** to surface repeat-session improvement-trend signal (rather than a single binge).
- **>= 1 weak-spot review session played** (after at least 1 normal session that produces bad/critical misses to feed the weak profile).
- **>= 1 concept drill session played** (any of the 12 M4 concepts, but `turn_blocker_pressure` or `turn_check_raise_value` are the most data-rich and would produce earliest signal).

This corresponds to roughly 1-2 hours of focused M4 play by a single user, OR distributed play across multiple beta testers over a 1-2 week window.

### 7.2 Indirect requirements

- **Beta tester recruitment.** If the project relies on external beta users (rather than just the project owner) to generate signals, those users need to be invited to play M4 and prompted to play across multiple sessions. v4.3.2C ships with the Limited Beta gate already in place (`App.state.settings.postflopBeta` toggle + Beta Lab section), so testers don't need any additional code change.
- **Data export channel.** The M4 Beta Lab dashboard already exposes a "Copy M4 Beta QA Snapshot" button (`_pfM4BetaQACopySnapshotClick`) that emits a clipboard-only JSON dump. Beta testers can paste their snapshot into a shared doc / GitHub issue / chat thread; the project owner can aggregate snapshots manually. This flow is sufficient for Limited Beta -- no telemetry pipeline needed at this stage.

### 7.3 Suggested next-review timing

- **Minimum:** 7 calendar days of beta usage with project owner playing >= 1 session/day, OR 3 calendar days with >= 2 external testers playing.
- **Comfortable:** 14 calendar days; if the project owner's session count + external snapshots aggregates to 8+ sessions, run a second Option A review.
- **Hard ceiling before forcing the question:** 30 calendar days. If signal volume remains thin after 30 days, the right next sprint is NOT Option B or C -- it's a UX / discoverability sprint to figure out why beta testers are not playing more M4 sessions.

## 8. Pre-built threshold-evaluation snippet (for owner DevTools paste)

When the project owner has played enough sessions, this DevTools snippet emits a formatted threshold report identical to Section 4 of this doc, sourced from the owner's own browser:

```javascript
(function () {
  if (typeof _pfM4BetaQAStats !== 'function') {
    console.error('_pfM4BetaQAStats not in scope -- is the page loaded?');
    return;
  }
  var stats = _pfM4BetaQAStats();
  var allReasons = ['pot_odds_turn_call','equity_realization_turn_call','bluff_catch_turn',
    'board_change_fold','domination_turn_fold','range_disadvantage_turn_fold',
    'value_check_raise_turn','protection_check_raise_turn','semi_bluff_check_raise_turn',
    'blocker_check_raise_turn','slowplay_turn_call','mixed_indifference_turn'];
  var allConcepts = ['turn_equity_shift','second_barrel_defense','turn_pot_odds','turn_bluff_catcher',
    'turn_domination_fold','turn_board_change','turn_draw_completion',
    'turn_check_raise_value','turn_check_raise_bluff','turn_blocker_pressure',
    'turn_slowplay_call','turn_range_disadvantage'];
  var hist = (typeof _pfHistoryLoad === 'function') ? _pfHistoryLoad() : { sessions: [] };
  var modSessions = (hist.sessions || []).filter(function (s) { return s && s.module === 'pf_turn_barrel_oop_def'; });
  var allAnswers = [];
  modSessions.forEach(function (s) { (s.answers || []).forEach(function (a) { allAnswers.push(a); }); });
  var pool = (App.postflop && App.postflop.scenarios) ? App.postflop.scenarios : [];
  var byId = {};
  pool.forEach(function (s) { byId[s.id] = s; });
  var hitReasons = {};
  var hitConcepts = {};
  var critBuckets = {};
  var rcCount = 0, acCount = 0;
  allAnswers.forEach(function (a) {
    var sc = byId[a.scenarioId];
    if (sc && sc.actionReason) hitReasons[sc.actionReason] = true;
    (a.conceptTags || []).forEach(function (t) { hitConcepts[t] = true; });
    if (a.tier === 'critical' && sc && sc.actionReason) critBuckets[sc.actionReason] = true;
    if (a.questionType === 'reason_choice') rcCount++;
    if (a.questionType === 'action_choice') acCount++;
  });
  var pctReason = allAnswers.length > 0 ? Math.round(100 * rcCount / allAnswers.length) : 0;
  var pctAction = allAnswers.length > 0 ? Math.round(100 * acCount / allAnswers.length) : 0;
  var rows = [
    ['1. Sessions',          stats.sessionCount,                '>= 5',  stats.sessionCount >= 5],
    ['2. Hands answered',     stats.questionCount,               '>= 60', stats.questionCount >= 60],
    ['3. ActionReason cov',   Object.keys(hitReasons).length + ' of 12', '>= 8 of 12', Object.keys(hitReasons).length >= 8],
    ['4. ConceptTag cov',     Object.keys(hitConcepts).length + ' of 12','>= 8 of 12', Object.keys(hitConcepts).length >= 8],
    ['5. Critical buckets',   Object.keys(critBuckets).length,   '>= 3',  Object.keys(critBuckets).length >= 3],
    ['6. Weak review used',   stats.weakReviewUsed ? 'yes' : 'no','>= 1', stats.weakReviewUsed],
    ['7. reason_choice vol',  pctReason + '%',                   '>= 30%', pctReason >= 30],
    ['8. action_choice vol',  pctAction + '%',                   '>= 30%', pctAction >= 30]
  ];
  console.log('=== M4 Beta Signal Threshold Check ===');
  console.table(rows.map(function (r) { return { metric: r[0], actual: r[1], required: r[2], pass: r[3] ? 'YES' : 'no' }; }));
  var passed = rows.filter(function (r) { return r[3]; }).length;
  console.log('Passed: ' + passed + ' of 8');
  if (passed === 8) {
    console.log('All thresholds MET. Run weakness-concentration analysis to choose Option B vs C.');
  } else {
    console.log('Thresholds not met. STAY OPTION A.');
  }
  return { passed: passed, total: 8, rows: rows };
})();
```

The owner pastes this into DevTools console on `https://range-master-mtt.netlify.app/`. Output is a formatted `console.table` plus a return object suitable for snapshotting into a follow-up review doc.

## 9. Issues found

None. v4.3.2C signal-persistence fix is live and working as designed; the empty-state on the inspected browser correctly reflects "no sessions played yet" rather than any persistence regression. No new auditor rule needed; no scenario data touched; no runtime change required.

## 10. Fixes applied

None. This is a docs-only sprint per the brief's Option A "stay collecting / no code changes" path.

## 11. Version / cache decision

**No version bump.** No `index.html` / `service-worker.js` changes. Only docs/state files modified. Existing `appVersion = 4.3.2C` and `SW VERSION = v4.3.2C` retained. Cache lifecycle unchanged.

## 12. Files modified

```
A docs/specs/postflop-v4.3.2C-option-a-signal-review.md  (this doc)
M PROJECT_STATE.md      (state-doc reconcile noting Option A review complete)
M TASK_BOARD.md         (state-doc reconcile)
```

No GPT AUDIT snapshot needed (docs-only update under the v4.3.2C umbrella; v4.3.2C snapshot folder remains the canonical state for runtime files).

## 13. Forbidden files unchanged (byte-identical)

```
postflop/postflop_scenarios.json                 -- byte-identical
all v4.3.0 / v4.3.0C / v4.3.0D / v4.3.2 builders -- byte-identical
all migration tools (B/C/D/v4.3.2)               -- byte-identical
all hotfix tools (v4.3.0C1/v4.3.2A/B)            -- byte-identical
audit-postflop-ps.ps1 (R55-R72 unchanged)        -- byte-identical
M2/M3/M4 seed auditors                           -- byte-identical
audit-postflop-module4-continuation-v4.3.2.ps1   -- byte-identical
ranges.json, manifest.json, preflop data         -- byte-identical
gamification/shop/wardrobe/field-fx              -- byte-identical
M1/M2/M3 strategy fields                         -- byte-identical
postflop/postflop_concepts.json                  -- byte-identical
postflop/postflop_taxonomy.json                  -- byte-identical
v4.3.2 / v4.3.2A / v4.3.2B / v4.3.2C-base docs   -- byte-identical
index.html                                        -- byte-identical (no runtime change)
service-worker.js                                 -- byte-identical
```

## 14. Recommendation

**STAY OPTION A. Do not author. Do not start the next major sprint.**

- The signal-persistence fix shipped in v4.3.2C is verified live on Netlify and ready to capture user data.
- The Beta Lab dashboard returns the correct empty state when no sessions exist.
- Re-run this signal review after the data-requirements thresholds in Section 7.1 are satisfied (recommended cadence: 7-14 calendar days of beta usage, then re-evaluate).
- If after 30 calendar days signal volume is still thin, pivot to a UX/discoverability sprint (figure out why beta testers are not playing M4 more often) BEFORE forcing a content-authoring decision.

The right next action is **NOT a code or content sprint -- it is a wait for usage data to accumulate.**
