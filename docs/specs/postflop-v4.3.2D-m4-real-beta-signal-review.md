# Postflop v4.3.2D -- M4 Real Beta Signal Review After Owner Usage

**Date:** 2026-05-07
**Sprint type:** Doc-only signal-review attempt on top of v4.3.2C-optionA.
**Predecessor HEAD (entry):** `e739545` (v4.3.2C-optionA review)
**Substantive predecessor:** `090f21f` (v4.3.2C signal-persistence fix)
**Status:** complete; **BLOCKED on data access** -- owner's M4 play sessions are not in the Chrome MCP QA browser; threshold check cannot be evaluated; **STAY OPTION A** pending owner snapshot export.

## 1. Baseline status

```
HEAD                       = origin/main = e739545
Production count           = 477  (251 M1 + 49 M2 + 85 M3 + 92 M4)
M4 status                  = Limited Beta, 92 approved
appVersion                 = 4.3.2C
SW VERSION                 = v4.3.2C
Signal-persistence fix     = LIVE (verified during v4.3.2C smoke and again in this sprint)
working tree               = clean
```

### 1.1 Baseline audits (all PASS, unchanged from v4.3.2C / v4.3.2C-optionA)

```
production audit                  : 477 / 0 / 0  PASS
M4 continuation seed (v4.3.2)     :  20 / 0 / 0  PASS
M4 polish seed (v4.3.0D)          :  19 / 0 / 0  PASS
M4 expansion seed (v4.3.0C)       :  29 / 0 / 0  PASS
M4 original seed (v4.3.0)         :  24 / 0 / 0  PASS
M3 seed                           :  24 / 0 / 0  PASS clean
M2 seed                           :  24 / 0 / 8  PASS
R29 / R71 / R72 / R44b            : 0 fires across 92 M4
M4.R73 / M4.R74 / M4.R75          : 0 fires across 20 v4.3.2 continuation
```

No regression. Audits remained green between v4.3.2C-optionA and v4.3.2D (no scenarios touched).

## 2. Data source

**Browser/device inspected:** Chrome MCP browser instance connected to this Claude Code session at `https://range-master-mtt.netlify.app/`.

**Source attempted:**
1. Live dashboard read via `_pfM4BetaQAStats()`.
2. Direct `localStorage.getItem('rmtt_postflop_history')` inspection.
3. Enumeration of all localStorage keys via `for (var i = 0; i < localStorage.length; i++)`.

**Snapshot button (`Copy M4 Beta QA Snapshot`):** would require navigating to the M4 Beta Lab section and clicking the snapshot button -- but with 0 sessions the snapshot would be empty regardless. Not collected.

## 3. Live data probe (Chrome MCP, this sprint)

```
Netlify    https://range-master-mtt.netlify.app/
appVersion                          : 4.3.2C        (correct deployed version)
M4 pool size                         : 92            (correct production count)
v4.3.2C signal-persistence fix      : LIVE          (compactAnswers + mode in source)

localStorage keys present:
  - rmtt_streaks       (93 bytes; preflop streak data)
  - rmtt_profile       (2114 bytes; profile metadata)
  - rmtt_progress      (3197 bytes; preflop module-1 range-form keys like
                        10BB_BB_vs_raise_K5o, 80BB_MP_vs_raise_AKo, etc.
                        -- ALL preflop, NO postflop keys, NO m4Mastery)
  - rmtt_settings      (232 bytes)
  - rmtt_stats         (89 bytes; preflop global stats: totalHands,
                        totalTime, dailyHistory)
  - rmtt_disclaimer    (1 byte)

localStorage key MISSING:
  - rmtt_postflop_history  (this is the key the BetaQA dashboard reads)

_pfM4BetaQAStats() output:
  sessionCount = 0
  questionCount = 0
  all per-axis row arrays empty
  lastWeakProfile = null
```

**Interpretation:** the Chrome MCP browser shows extensive preflop module-1 usage (3+ KB of preflop range-form progress) but **zero postflop / M4 sessions**. The postflop beta flag and M4 routing were never exercised on this browser.

This Chrome MCP browser is a development / QA browser. It is reasonable for it to have no M4 play history -- a developer typically tests via DevTools and code inspection rather than completing 12-question drill sessions.

## 4. BLOCKER -- owner data is on a different browser/device

The brief explicitly stated:
> Project owner now says M4 has been tried/played, so use the owner's active browser/device data.

Per the brief Section B:
> If using Chrome MCP and it still has 0 sessions:
> - Do NOT conclude no data exists globally.
> - Ask the owner to paste/export the M4 Beta QA Snapshot from the device/browser where they played.
> - Do not make a v4.3.3/v4.4.0 decision from a fresh QA browser.

Per the brief Section I:
> If no useful data exists because owner data is inaccessible:
> - Do not fake a decision.
> - Document blocker and ask owner to paste/export M4 Beta QA Snapshot.

**This is exactly the blocker case.** The Chrome MCP browser does not have access to the owner's M4 play sessions. The owner played M4 on a different browser (or different device entirely) where localStorage is isolated from the Chrome MCP origin/profile.

## 5. Threshold check (not performed; awaiting data)

| # | Threshold | Required | Actual | Status |
|---|---|---|---|---|
| 1 | M4 sessions completed | >= 5 | n/a | **AWAITING OWNER SNAPSHOT** |
| 2 | M4 hands answered | >= 60 | n/a | **AWAITING OWNER SNAPSHOT** |
| 3 | actionReason coverage | >= 8 of 12 | n/a | **AWAITING OWNER SNAPSHOT** |
| 4 | conceptTag coverage | >= 8 of 12 | n/a | **AWAITING OWNER SNAPSHOT** |
| 5 | critical-mistake buckets distinct | >= 3 | n/a | **AWAITING OWNER SNAPSHOT** |
| 6 | weak-spot review used | >= 1 | n/a | **AWAITING OWNER SNAPSHOT** |
| 7 | reason_choice volume | >= 30% | n/a | **AWAITING OWNER SNAPSHOT** |
| 8 | action_choice volume | >= 30% | n/a | **AWAITING OWNER SNAPSHOT** |

The threshold check would be a meaningless exercise from the Chrome MCP browser (all 8 rows would report `0` and `FAIL`, but that reflects browser-instance state, not the owner's actual M4 usage).

## 6. Decision

**STAY OPTION A. Do not author. Do not start v4.3.3 or v4.4.0.**

This decision is forced by the data-access blocker, NOT by an evaluated threshold. It is NOT a verdict that the owner's M4 play was insufficient -- it is a deferral pending data export.

Rationale (per brief Section F):
- `sessions < 5` is unprovable but is the default state of the data we can inspect.
- Decision rule reads: `if (sessions < 5 OR hands < 60) -> Option A`.
- Without data, the AND/OR evaluation cannot proceed to Option B / Option C branches.

## 7. Exact next request to the project owner

To unblock the v4.3.3 vs v4.4.0 decision, the owner needs to provide the M4 Beta QA Snapshot from the browser/device where they actually played M4. There are three ways to do this; **any one is sufficient**.

### 7.1 Method A -- click the M4 Beta Lab "Copy M4 Beta QA Snapshot" button (RECOMMENDED)

1. Open `https://range-master-mtt.netlify.app/` in the browser/device that has M4 play history.
2. Navigate to the **Home tab → Postflop Academy → M4 BetaQA dashboard** section.
3. Click the **Copy M4 Beta QA Snapshot** button. This copies a JSON blob to clipboard (privacy-safe: clipboard-only, no network call).
4. Paste the JSON blob into the next conversation message.

### 7.2 Method B -- DevTools console direct snapshot

1. Open `https://range-master-mtt.netlify.app/` in the browser/device that has M4 play history.
2. Open DevTools console (F12 -> Console).
3. Paste and run:

```javascript
JSON.stringify({
  appVersion: (typeof buildBackupPayload === 'function') ? buildBackupPayload().appVersion : null,
  m4Stats: _pfM4BetaQAStats(),
  m4Sessions: ((_pfHistoryLoad() || {}).sessions || []).filter(function (s) {
    return s && s.module === 'pf_turn_barrel_oop_def';
  }),
  conceptTagAggregates: (_pfHistoryLoad() || {}).concepts || {},
  scenarioAggregates_M4_only: (function () {
    var all = (_pfHistoryLoad() || {}).scenarios || {};
    var out = {};
    Object.keys(all).forEach(function (k) {
      if (k.indexOf('_m4_') !== -1) out[k] = all[k];
    });
    return out;
  })()
}, null, 2);
```

4. Paste the resulting JSON string into the next conversation message.

### 7.3 Method C -- DevTools console threshold snippet (from v4.3.2C-optionA Section 8)

1. Open `https://range-master-mtt.netlify.app/` in the browser/device that has M4 play history.
2. Open DevTools console.
3. Paste the threshold-check snippet from `docs/specs/postflop-v4.3.2C-option-a-signal-review.md` Section 8.
4. The `console.table` will show the 8-row threshold check with the owner's actual data.
5. Copy the table output and paste into the next conversation message.

### 7.4 What to do if the owner played M4 on a private/incognito tab

Private/incognito tabs do NOT persist localStorage. If the owner played M4 in an incognito session, the data is irrecoverably lost when the tab closed. In that case the owner would need to play several more M4 sessions in a normal (non-incognito) browser tab and then export.

### 7.5 What to do if the owner used a different device

localStorage is per-browser-profile-per-origin. M4 history on a phone Safari does not appear on a desktop Chrome and vice versa. The export must come from the specific browser+device combination where M4 was played. If the owner is unsure, exporting from each candidate browser/device is harmless (most will return empty).

## 8. Why this matters (rationale for not faking a decision)

A v4.3.3 sprint authored without real signal data would consist of guessed gap-fills -- exactly what the v4.3.2 / v4.3.2A / v4.3.2B / v4.3.2C process discipline has been working to avoid. The strategic-review-after-mechanical-audit pattern is valuable BECAUSE it relies on real evidence rather than authorial intuition. Auto-starting v4.3.3 from a fresh QA browser's 0-session data would:

- Use authorial intuition (the worst signal available) to pick weak buckets
- Burn engineering cycles authoring 8-18 new scenarios in buckets that may not actually be weak
- Force a cache bump (v4.3.3 / v4.3.3 SW VERSION) on every deployed PWA without justifying benefit
- Erode the discipline that has kept the corpus quality high through 5+ consecutive content-correction sprints

Similarly, auto-starting v4.4.0 (Module 5 River Defense architecture) without M4 maturity confirmation would commit weeks of engineering to a new module while M4 may still have hidden weak spots that real users would surface.

The right move is to wait, even if waiting feels unproductive. The exact next action is a 30-second copy-paste from the owner's browser.

## 9. Files modified in this Option A continuation

```
A docs/specs/postflop-v4.3.2D-m4-real-beta-signal-review.md  (this doc)
M PROJECT_STATE.md       (state-doc reconcile noting blocker)
M TASK_BOARD.md          (state-doc reconcile)
```

**No code change. No version bump.** appVersion stays `4.3.2C`; SW VERSION stays `v4.3.2C`; `postflop_scenarios.json` byte-identical; all M4 builders / auditors / migration / hotfix tools byte-identical; M1/M2/M3 strategy fields byte-identical; `postflop_concepts.json` + `postflop_taxonomy.json` byte-identical; `index.html` + `service-worker.js` byte-identical.

## 10. Forbidden files unchanged (byte-identical)

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
v4.3.2 / v4.3.2A / v4.3.2B / v4.3.2C docs        -- byte-identical
v4.3.2C-optionA doc                              -- byte-identical
index.html                                        -- byte-identical
service-worker.js                                 -- byte-identical
```

## 11. Recommendation

**Action required from project owner:** export the M4 Beta QA Snapshot using Method A, B, or C in Section 7 above, then paste the result into the next conversation.

**Action required from dev:** wait. Do not author. Do not start v4.3.3 or v4.4.0. STAY OPTION A.

Once the owner snapshot arrives:
- A follow-up signal-review sprint will parse the snapshot.
- Apply the v4.3.2C decision-framework thresholds against real data.
- Decide Option A (still collecting), Option B (v4.3.3 user-signal-driven), or Option C (v4.4.0 M5).

## 12. Next-sprint prompt draft (for after owner snapshot arrives)

```
Resume v4.3.2D -- M4 Real Beta Signal Review with owner's exported snapshot.

QUALITY ENFORCEMENT:
- Do not auto-author scenarios.
- Do not start v4.3.3 / v4.4.0 until thresholds evaluated against the
  pasted snapshot data.

BASELINE:
- HEAD must be origin/main = <latest> (clean descendant of v4.3.2C-optionA).
- v4.3.2C is the runtime baseline (appVersion=4.3.2C, SW=v4.3.2C).
- Production count: 477; M4 count: 92.
- Signal-persistence fix is live.

INPUT:
- A JSON blob pasted by the owner via Section 7 Method A / B / C of
  docs/specs/postflop-v4.3.2D-m4-real-beta-signal-review.md.

PROCESS:
1. Parse the snapshot.
2. Compute the v4.3.2C decision-framework threshold table:
   - sessions, hands, actionReason coverage, conceptTag coverage,
     critical buckets, weak-spot usage, reason_choice volume,
     action_choice volume.
3. Per-axis weakness analysis if thresholds met:
   - weakest actionReasons (with attempts, accuracy, critical count)
   - weakest conceptTags
   - weakest heroHandRoles
   - weakest handClasses
   - critical-mistake concentration
   - reason_choice vs action_choice accuracy split
   - last-3-session trend
4. Apply decision rule:
   - sessions < 5 OR hands < 60   -> Option A
   - concentrated weakness 1-3 buckets -> Option B (v4.3.3, target buckets only)
   - mature signals                -> Option C (v4.4.0 M5 architecture)
5. Document outcome in
   docs/specs/postflop-v4.3.2E-m4-signal-review-after-snapshot.md.

DO NOT:
- Author scenarios in this sprint (Option B identifies target buckets only).
- Start v4.4.0 without explicit owner approval.
- Touch any v4.3.0/C/D/v4.3.2 builder, auditor, hotfix tool, or seed JSON.
- Change M1/M2/M3 strategy fields.
- Bump appVersion / SW VERSION (no runtime change unless a real bug surfaces).

STOP after the signal-review report.
```
