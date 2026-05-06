# Postflop v4.2.6 — Postflop Academy Beta Feedback Loop + M3 Runtime QA Dashboard

**Status:** Implemented and shipped.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.5-module3-limited-beta-ux-polish.md`, `postflop-v4.2.4-module3-limited-beta-wire.md`
**Builds on:** v4.2.5 (Module 3 Limited Beta UX Polish, commit `55fa676`) + v4.2.5-doc reconciliation (`8b80b37`)

---

## 1. Goal

Add an internal-facing **Postflop Beta QA Feedback Loop** centered on Module 3 — without changing any poker data, scenarios, strategy fields, or audit rules. The loop should let the project owner answer:

1. What is the learner getting wrong in M3?
2. Are mistakes clustering by `actionReason`, `conceptTag`, `handClass`, `heroHandRole`, or `recommendedAction`?
3. Are critical mistakes too concentrated?
4. Is weak-spot review actually targeting the right leaks?
5. Can a clean local QA snapshot be exported for offline review?
6. Is the M3 runtime stable enough to use as the template for Module 4+?

Pure observability. No new content. No data edits. Zero network calls.

---

## 2. Why v4.2.6 BEFORE v4.3.0 (Module 4)

Module 3 just became the first full Postflop Limited Beta learning loop. Before designing Module 4 architecture (a multi-week planning sprint), we need a way to evaluate whether M3 is actually teaching well — and a reusable infrastructure pattern that future modules can inherit.

The QA dashboard helpers are intentionally module-agnostic:
- `_pfBetaQAStatsForModule(moduleId)` accepts any postflop module id
- `_pfM3BetaQAStats()` is a thin wrapper that passes `'pf_flop_cbet_oop_def'`
- M4+ can mirror this pattern with `_pfM4BetaQAStats()` once Module 4 ships

This is the "build once, reuse 3+ times" principle that prevents one-off M3 hacks from blocking M4/M5 future work.

---

## 3. Volume gates

| Gate | v4.2.5 | v4.2.6 |
|---|---|---|
| Total production scenarios | 385 | 385 (unchanged) |
| M1 / M2 / M3 | 251 / 49 / 85 | 251 / 49 / 85 (unchanged) |
| Production audit | 385 / 0 / 0 | **385 / 0 / 0** |
| R29 card-notation guard | 0 warnings | 0 warnings |
| M2 seed audit | PASS (8 warnings) | PASS (8 warnings, unchanged) |
| M3 seed audit | 24 / 0 / 0 PASS clean | 24 / 0 / 0 PASS clean (unchanged) |
| `check_raise_big` critical rate | 26/85 (30.6%) | 26/85 (30.6%) (unchanged) |

---

## 4. QA Dashboard / Panel Summary (Section B)

### 4.1 Placement

Dashboard mounted **inside the Postflop Academy panel**, after the M3 mastery section, before the Concept Library. Wrapped in a `<details>` element collapsed by default — does NOT dominate the Academy panel for normal learners.

### 4.2 Empty state (no M3 history)

```
🛡️ Module 3 Beta QA dashboard (project-owner view)
└─ Play Module 3 sessions to generate beta feedback.
```

Verified in browser: empty state renders correctly when `_pfM3SessionCount() === 0`.

### 4.3 Populated state (M3 history present)

When M3 history exists, the dashboard renders:

| Section | Content |
|---|---|
| Sample-size honesty banner | Shows when sessionCount < 3 OR questionCount < 30. Copy: "⚠ Early signal — N sessions, M answers. Needs more sessions for confident readings." |
| Top metrics row (6-col grid) | sessions / answers / latest pct / avg pct / critical count / crit rate % |
| 🔍 Weak-spot review would target (top 3 reasons) | For each top-3 weak actionReason: lifetime miss count + candidate scenario count |
| ⚡ Critical-mistake monitor | Total critical, crb-habit count, by-selected-action breakdown, by-scenario-actionReason breakdown |
| 🎯 By actionReason | Top 6 actionReasons with pct/seen/critCount |
| 🛡️ By recommendedAction | Top 6 recommendedActions |
| 🃏 By heroHandRole | Top 6 heroHandRoles |
| 🪜 By handClass | Top 6 handClasses |
| 🕘 Last 3 sessions | Compact one-line summary per session: pct + (best/acc/bad/crit counts) + mode |
| 📋 Copy M3 Beta QA Snapshot | Button + privacy footer |

### 4.4 Verified rendering with simulated 3-session, 15-answer, 1-critical, weak-review-used history

| Section | Verified output |
|---|---|
| Top metrics | sessions=3 / answers=15 / latest=90% / avg=80% / critical=1 / crit rate=6.7% |
| Sample warning | "⚠ Early signal — 3 sessions, 15 answers. Needs more sessions for confident readings." |
| Weak-spot preview | blocker_raise: 2 misses, 4 candidate scenarios |
| Critical monitor | totalCritical=1, crbHabitCount=1, by-selected-action: check_raise_big×1, by-reason: domination_fold×1 |
| Last 3 sessions | All 3 rendered with correct counts |

---

## 5. Export Snapshot (Section C)

### 5.1 Format

JSON copied to clipboard via `navigator.clipboard.writeText` (with `document.execCommand('copy')` legacy fallback). Schema:

```json
{
  "kind": "rmtt-m3-beta-qa-snapshot",
  "schema": "1.0.0",
  "appVersion": "4.2.6",
  "moduleId": "pf_flop_cbet_oop_def",
  "timestampISO": "2026-05-06T...",
  "sessionCount": 3,
  "questionCount": 15,
  "latestPctScore": 90,
  "averagePctScore": 80,
  "criticalCount": 1,
  "criticalRatePct": 6.7,
  "weakReviewUsed": true,
  "weakActionReasons": [...],
  "weakHeroHandRoles": [...],
  "weakRecommendedActions": [...],
  "weakConcepts": [...],
  "weakSpotReviewWouldTarget": [...],
  "criticalMonitor": {
    "totalCritical": 1,
    "crbHabitCount": 1,
    "bySelectedAction": {...},
    "byScenarioReason": {...},
    "latestCritIds": [...]
  },
  "betaMastery": { ... },
  "last3Sessions": [...],
  "_privacy": "Local-only snapshot. Generated from browser localStorage M3 session history. No network upload."
}
```

### 5.2 Verified copy operation

Programmatic test (clipboard mocked) — JSON length 2,445 chars, all expected fields present, button state changed to "✓ Copied to clipboard" for 1.8s after success.

### 5.3 Suggested workflow

1. Player completes 3+ M3 sessions
2. Project owner opens Postflop Academy → expands "🛡️ Module 3 Beta QA dashboard"
3. Reviews per-axis breakdowns + weak-spot targets + critical monitor
4. Clicks "📋 Copy M3 Beta QA Snapshot"
5. Pastes JSON into a doc / spreadsheet / GPT review for offline analysis
6. No data leaves the device unless the owner manually pastes/sends it

---

## 6. ActionReason Weak-Spot Effectiveness Signal (Section D)

The dashboard's "🔍 Weak-spot review would target (top 3 reasons)" block is the **observable verification** that the v4.2.5 actionReason-keyed weak-spot engine works.

For each top-3 weak actionReason in `latestSession.weakProfile.targetActionReasons`:
- **lifetimeMisses** — total bad+critical answers on that actionReason across all M3 sessions
- **candidates** — count of approved M3 scenarios with that actionReason in production data

**Worked example** (verified in QA):
- Player makes 2 bad answers on `blocker_raise` scenarios across 3 sessions
- Dashboard shows: "Blocker Raise (2 misses, 4 candidate scenarios)"
- This means weak-spot review would prioritize blocker_raise scenarios + has 4 to choose from
- Project owner can see at-a-glance whether the engine has enough material per weak reason

When the candidate count is low (e.g., 1-2 scenarios for a weak reason), it's a content-gap signal: future content sprints should add more scenarios for that reason.

---

## 7. Critical Mistake Monitor (Section E)

```
⚡ Critical-mistake monitor
Total critical: N · check-raise-big habit: M

By selected action:
  Check Raise Big × N1
  Fold × N2
  ...

By scenario actionReason:
  Domination Fold × M1
  Range Disadvantage Fold × M2
  ...
```

**`crbHabitCount`** is the v4.2.5-specific signal: how many critical mistakes were the player choosing `check_raise_big` (the previously-overweighted critical flag). Helps the project owner spot whether the v4.2.5 critical-flag rebalance left a healthy distribution OR whether learners are still being miscalibrated.

**Latest 5 critical scenario IDs** are stored in the snapshot for offline review (so the owner can pull up specific scenarios and inspect strategic context).

---

## 8. Session Summary Polish (Section F)

`_pfM3BetaSessionLeakHtml(d, scenarios)` adds a **"🔥 Biggest leak this session"** block to the M3 session summary when:
- The session has ≥1 weak actionReason (critCount > 0 OR badCount ≥ 2 OR pct < 50 with seen ≥ 2)
- OR specific severity thresholds are met

Honest copy:
- When sample size < 5: appends "(early signal — small sample)"
- Always frames as "Best next review: [actionReason] — open Module 3 Weak-Spot Review to drill it"
- Never claims solver-certified precision

---

## 9. Privacy / Local Data Confirmation (Section I)

| Check | Verified |
|---|---|
| All data sourced from `_pfHistoryLoad()` (localStorage `rmtt_postflop_history`) | ✓ |
| No `fetch()`, `XMLHttpRequest`, or network call in any new helper | ✓ (grep clean) |
| Copy snapshot uses `navigator.clipboard.writeText` (clipboard only) | ✓ |
| Privacy note rendered in dashboard footer + embedded in JSON `_privacy` field | ✓ |
| No personal data collected (all fields are gameplay metrics) | ✓ |
| No external tracking, no analytics, no telemetry | ✓ |

Privacy footer copy:
> "Local only · browser history · no server upload · no tracking. Snapshot is JSON copied to clipboard for offline review."

---

## 10. Browser / Mobile QA (Section H)

| Check | Desktop 1280×800 | Mobile 375×812 | Mobile 360×740 |
|---|---|---|---|
| App loads, 0 console errors | ✓ | ✓ | ✓ |
| Empty-state renders when no M3 history | ✓ | ✓ | ✓ |
| Populated dashboard renders with all 7 blocks | ✓ | ✓ | ✓ |
| 6-metric grid wraps to 3 cols at ≤480px, 2 cols at ≤360px | ✓ | ✓ | ✓ |
| No horizontal overflow | ✓ | ✓ | ✓ |
| Copy button styles + ✓ confirmation | ✓ | ✓ | ✓ |
| Sample-size warning displays below 3 sessions / 30 answers | ✓ | ✓ | ✓ |
| M1 / M2 / M3 grading regression | all best ✓ | all best ✓ | all best ✓ |
| `check_raise_big` critical rate | 30.6% (unchanged) | 30.6% (unchanged) | 30.6% (unchanged) |

**0 console errors** at any tested viewport.

---

## 11. Learning-Product QA (Section H/Q)

| Check | Verdict |
|---|---|
| actionReason labels are understandable (`_pfM2PrettyLabel` = snake_case → Title Case) | ✓ |
| Weak-spot recommendations make strategic sense (verified blocker_raise example) | ✓ |
| Critical-mistake monitor does not shame; uses neutral counts not judgmental copy | ✓ |
| Beta dashboard does not imply solver-certified precision (sample-size warning) | ✓ |
| Sample-size copy is honest ("Early signal", "Needs more sessions", "small sample") | ✓ |
| M3 remains labeled "Limited Beta" everywhere (TCC tile, header, mastery, dashboard, summary) | ✓ |

---

## 12. First-User Manual QA Script (Section G)

For the project owner to run on a real device when collecting first beta data:

| Step | Expected behavior |
|---|---|
| 1. Open app, enable Postflop Beta in Settings | App loads, beta toggle persisted |
| 2. Tap Postflop in Training Command Center → Module 3 BETA tile | M3 drill starts; first-time explainer renders on Q1 |
| 3. Play 10 M3 questions to completion | All 5 actions clickable; grading shows correct best/acceptable/bad/critical |
| 4. Review feedback panels — confirm Defense Logic appears prominently | M3 teaching block layout (Recommended Action / Defense Logic / Hand Logic / Sizing / Blocker / Range Context / Takeaway / Common Mistake) |
| 5. From session summary, tap "🎯 Drill Weak Spots" if shown | M3 weak-spot review starts; queue biased toward weak actionReasons (verifiable via 🔍 dashboard block) |
| 6. Open Postflop Academy → expand Concept Library → Module 3 group | 10 M3 concepts visible (7 native + 3 alias) |
| 7. Tap "🎯 Drill this concept" on any M3 concept | M3 concept drill starts (queue 10, M3 pool only) |
| 8. Open M3 Beta QA dashboard | Dashboard renders metrics, weak-spot preview, critical monitor, by-axis breakdowns |
| 9. Tap "📋 Copy M3 Beta QA Snapshot" | Toast confirms; JSON copied to clipboard |
| 10. Resize browser to 360px or test on real mobile | No horizontal overflow; chips wrap; explainer compact |

---

## 13. Audit results (final)

| Audit | Result |
|---|---|
| Production audit | **385 / 0 / 0** PASS (unchanged) |
| R29 card-notation guard | **0 warnings** (preserved) |
| M2 seed audit | PASS (8 warnings, unchanged) |
| M3 seed audit | 24 / 0 / 0 PASS clean (unchanged) |
| Text integrity | thai=0 repl=0 (unchanged; pre-existing legitimate Thai chars in 19 places) |

---

## 14. Files modified

| File | Diff |
|---|---|
| `index.html` | +500 lines (QA dashboard helpers + CSS + Academy panel mount + session summary leak hint); -1 line (appVersion bump) |
| `service-worker.js` | 1 line (VERSION 4.2.5 → 4.2.6) |
| `docs/specs/postflop-v4.2.6-beta-feedback-loop.md` | NEW (this document) |
| `PROJECT_STATE.md` | sprint status update |
| `TASK_BOARD.md` | task close-out |
| `GPT AUDIT/v4.2.6/` | NEW snapshot |

---

## 15. Forbidden files untouched ✓

- `postflop/postflop_scenarios.json` — byte-identical
- `postflop/postflop_concepts.json` — byte-identical
- `postflop/postflop_taxonomy.json` — byte-identical
- `tools/audit-postflop-ps.ps1` — byte-identical
- `tools/audit-postflop-module3-seed.ps1` — byte-identical
- `tools/audit-postflop-module2-seed.ps1` — byte-identical
- `ranges.json`, `manifest.json` — byte-identical
- M1 / M2 / M3 scenario strategy fields — byte-identical
- Preflop / gamification / shop / wardrobe / field-fx systems — byte-identical

**This is a runtime-only sprint.** Zero data files modified, zero strategy changed, zero audit-rule changes.

---

## 16. Known limitations

1. **Dashboard is collapsed by default and visually labeled "(project-owner view)"** — but isn't gated behind any debug-mode toggle. Any postflop-beta user with M3 history will see it. Acceptable for Limited Beta scope (the panel is informative, not destructive).
2. **`weakSpotReviewWouldTarget` shows top 3 weak reasons** but the actual queue may pull from the broader weak profile (concepts + scenarios + family + heroHandRole). The preview is a useful approximation, not a perfect simulation of `_pfBuildWeakSpotQueue`.
3. **`criticalCount` and `criticalRate` are lifetime metrics** across all M3 sessions, not per-session. Per-session crit info is in "Last 3 sessions" block.
4. **The "byScenarioReason" critical breakdown shows the SCENARIO's actionReason**, not what the player misclassified it as. Useful for "I keep critical-failing on X-reason scenarios" but doesn't show "I keep CHOOSING X-reason as my answer when I should choose Y."
5. **Snapshot JSON is ~2.5KB for typical histories.** Larger histories (50+ sessions) may push toward 5-10KB but remain well under clipboard limits.
6. **No automatic snapshot upload** — by design (privacy). The project owner must manually paste the JSON to wherever they review it (chat, doc, email).
7. **Empty-state copy is fine for first-time users** but the gating (collapsed `<details>`) means even users who never play M3 see the dashboard summary text. Acceptable since postflop beta is opt-in.

---

## 17. Recommended next sprint

### Decision matrix

| Option | Pros | Cons |
|---|---|---|
| **A — `v4.3.0` Module 4 (Turn Strategy) Architecture + Seed Plan** | Curriculum breadth growth; reusable patterns from v4.2.4-v4.2.6 are now mature templates | Requires content design + 18-24 new scenarios + new audit rules |
| **B — `v4.2.7` UX polish round 2** | Defensive: dismissible explainer, dismissible progression hint, M3 in-drill keyboard shortcuts | Low-priority UX nice-to-haves; no visible product progress |
| **C — `v4.2.7-content` add 10-15 more M3 scenarios** | Pushes M3 toward 100; deepens reason_choice (currently 14% → target 20%) | Optional defensive polish before opening M4 |

**My recommendation: Option A (start `v4.3.0` Module 4 planning).**

The v4.2.6 QA dashboard now lets the project owner observe M3 in real-world use. Curriculum breadth is the higher-value next move because:
- M3 is content-stable (85 scenarios, 19 boards, 9 actionReasons all ≥4)
- M3 is runtime-stable (v4.2.4 wire + v4.2.5 polish + v4.2.6 observability)
- M3 is honestly labeled (Limited Beta everywhere)
- The reusable QA infrastructure (`_pfBetaQAStatsForModule(moduleId)`) is now in place for M4+ to inherit
- Real player data on M3 will accumulate organically; the dashboard surfaces it without needing to ship more M3 first

Module 4 planning is `v4.3.0` — same convention as `v4.2.0` (M3 planning sprint), 5 docs (architecture, schema-taxonomy, seed scenarios, audit plan, GPT review package) without any production data or runtime wiring.

---

## 18. Sign-off checklist

- [x] No scenarios added; no answer keys / strategy / conceptTags / explanation text changed
- [x] No M1 / M2 / M3 strategy field edits
- [x] No audit-rule changes
- [x] Production audit: 385 / 0 / 0 (unchanged)
- [x] R29 / M2 seed / M3 seed audits unchanged
- [x] Text integrity: 0 mojibake / 0 broken patterns (unchanged)
- [x] M3 Beta QA dashboard mounts inside Academy panel, collapsed by default
- [x] Dashboard renders 6-metric grid + weak-spot preview + critical monitor + 4 by-axis breakdowns + last-3-sessions
- [x] Empty-state renders cleanly when no M3 history
- [x] Sample-size honesty banner appears below 3 sessions / 30 answers
- [x] Copy QA Snapshot button writes valid JSON to clipboard with privacy `_privacy` note
- [x] No fetch / XHR / network calls anywhere in the new helpers
- [x] M3 session summary surfaces "🔥 Biggest leak this session" when applicable
- [x] Mobile 375 / 360: no horizontal overflow; grid wraps
- [x] Desktop 1280: full layout works
- [x] M1 + M2 + M3 grading byte-identical (regression PASS)
- [x] Module 3 still labeled "Limited Beta" everywhere
- [x] First-user manual QA script documented (10 steps)
- [x] appVersion + SW VERSION = 4.2.6
- [x] No forbidden files modified
- [x] v4.3.0 not started

**Status: SHIPPED.**
