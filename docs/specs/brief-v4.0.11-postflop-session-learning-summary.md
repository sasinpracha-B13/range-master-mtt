# v4.0.11 — Postflop Session Learning Summary

**Status:** ✅ Implemented + verified live. Awaiting commit/push.
**Date:** 2026-05-04
**Trigger:** Close the learning loop — after a Postflop Module 1 session, players should understand what they learned and what to focus on next.

---

## What was added

A new **Session Learning Summary** appears on the Postflop Module 1 completion screen. Six components, all derived from existing session data (no schema changes, no data file edits, no new storage):

### 1. Session Learning Summary headline + dynamic quality label
The existing "✅ Drill Complete" subtitle is replaced with:
- A "SESSION LEARNING SUMMARY" eyebrow label
- A coloured quality pill: **Clean read** / **Good pattern recognition** / **Mixed session** / **Needs review** / **High-risk leaks found**

Pill color codes: green (q-clean) / blue (q-good) / amber (q-review) / red (q-leaks). Selection rule:
- `critical > 0` → "High-risk leaks found"
- `(bad+critical)/total ≥ 40%` → "Needs review"
- `best/total ≥ 80%` → "Clean read"
- `(best+acceptable)/total ≥ 70%` → "Good pattern recognition"
- otherwise → "Mixed session"

### 2. Strongest Concepts (green block)
Top 3 conceptTags by score % where `seen ≥ 2` AND `pct ≥ 80`. Each row shows the prettified tag + "(94% over 5)" detail. Skipped if no qualifying concepts.

### 3. Review Signals (amber block, or green-empty when nothing flagged)
Bottom 3 conceptTags ranked worst-first (lowest pct, then most bad+critical). Includes any concept with at least one bad/critical answer OR pct < 50. Each row shows count of bad/critical or pct. If session is clean, shows "No major weak concept detected this session."

### 4. Board Family Pattern Notes (red block)
Groups answers by board family using new `_pfBoardFamilyKey(board)` helper (mirrors `_pfPatternLabel` but returns stable keys). Surfaces families where `missCount ≥ 2 OR critCount ≥ 1`. Each row shows: `**low connected** — missed 2 of 3 (critical). BB has more suited connectors and straight density.` Up to 3 families shown, sorted by miss-rate.

### 5. Recommended Next Move (blue block)
A single coaching-style action picked per these rules:
- `critical > 0` → "Replay weak spots first — at least one critical leak fired this session."
- `(bad+critical) ≥ 4` → "Run another Learn Mode session before moving on; let the patterns stick."
- `acceptable > best AND best/total < 60%` → "Focus on turning acceptable reads into best reads — read the family signal more decisively."
- `best/total ≥ 80%` → "Good session. Continue to the next pool, or revisit the weakest family below."
- otherwise → "Keep going — vary the boards and re-test the families you missed."

### 6. Existing concept-mastery details preserved
Below the new blocks, the old "Concept mastery (this session)" details and "Critical leaks (N)" details remain (collapsed by default for power users who want the full breakdown).

---

## How derivations work

| Block | Helper | Inputs | Logic |
|---|---|---|---|
| Quality label | `_pfSessionLearningLabel(counts, total)` | tier counts | rule cascade (above) |
| Strongest concepts | `_pfSessionConceptSummary(answers).strong` | `answers[].conceptTags`, `tier`, `score` | tally per tag → filter `seen≥2 AND pct≥80` → top 3 by pct then seen |
| Review signals | `_pfSessionConceptSummary(answers).weak` | same | tally per tag → filter `(bad+crit≥1) OR pct<50` → top 3 worst-first |
| Board family notes | `_pfSessionBoardFamilySummary(answers, scenarios)` | answers + scenario lookup | group by `_pfBoardFamilyKey(board)` → filter `missCount≥2 OR critCount≥1` → top 3 by miss-rate |
| Next move | `_pfSessionNextMove(counts, total)` | tier counts | rule cascade (above) |
| Family lesson | `_pfBoardFamilyLesson(key)` | family key | lookup in 18-entry coaching map |

All helpers are pure functions and defensive against missing fields (`conceptTags ?? []`, optional chaining).

---

## Defensive fixes applied

QA found one pre-existing crash in `renderPostflopComplete`: line `a.conceptTags.forEach(...)` would throw if `conceptTags` was missing on an answer (e.g. legacy localStorage from before v4.0.6). Per brief requirement #12, patched to:
```js
var tags = (a && a.conceptTags) || [];
tags.forEach(function (tag) { ... });
```
This is the only edit to existing v4.0.6 code; new helpers were already defensive.

---

## QA result (20/20)

| # | Check | Result |
|---|---|---|
| 1 | Postflop audit 262/0/0 (data unchanged) | ✅ |
| 2 | Module 1 loads | ✅ |
| 3 | Full 15-question session completes | ✅ (existing flow unchanged) |
| 4 | Summary screen shows Session Learning Summary headline | ✅ |
| 5 | Strongest Concepts renders when applicable | ✅ (perfect & mixed sessions) |
| 6 | Weakest Concepts / Review Signals renders when applicable | ✅ (poor & mixed); empty-state when clean |
| 7 | Board Family Pattern Notes render when mistakes cluster | ✅ (poor: 3 families; mixed: 2 families) |
| 8 | Recommended Next Move always renders | ✅ |
| 9 | Perfect session: "Clean read" + "Good session..." next move + no family clusters | ✅ |
| 10 | Poor session (15 critical): "High-risk leaks found" + "Replay weak spots first..." | ✅ |
| 11 | Mixed session (6 best/5 acc/3 bad/1 crit): "High-risk leaks found" + family clusters surface | ✅ |
| 12 | No crash if conceptTags missing on answers | ✅ (legacy line patched) |
| 13 | No crash if local postflop history missing (cleared localStorage) | ✅ |
| 14 | No crash on empty answers array | ✅ |
| 15 | No crash if App.postflop.scenarios is null | ✅ |
| 16 | Mobile 375px: no horizontal overflow; summary card 343px wide; Next button 343px wide | ✅ |
| 17 | Console: 0 errors throughout | ✅ |
| 18 | Existing answer → feedback → next flow works (renderPostflopAnswer untouched) | ✅ |
| 19 | Preflop drill regression: startDrill('quick') still works | ✅ |
| 20 | Beta off hides postflop UI; beta on shows it; all 5 tabs render | ✅ |

---

## Files changed

| File | Change |
|---|---|
| `index.html` | New CSS block (`.pf-learn-*`, ~70 lines), new helper block (8 functions, ~210 lines) inserted before `renderPostflopComplete`. Two edits inside `renderPostflopComplete`: defensive guard on `conceptTags` (4 lines) + new sections wired into the HTML output. appVersion bump 4.0.10 → 4.0.11. |
| `service-worker.js` | VERSION v4.0.10 → v4.0.11 (cache-bust) |
| `PROJECT_STATE.md`, `TASK_BOARD.md` | Status update |
| `docs/specs/brief-v4.0.11-postflop-session-learning-summary.md` | This file (NEW) |

**Untouched** (verified clean): `postflop/postflop_scenarios.json`, `postflop/postflop_taxonomy.json`, `postflop/postflop_concepts.json`, `tools/generate-postflop-module1.ps1`, `tools/audit-postflop-ps.ps1`, `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`, `tools/audit-postflop.js`, `ranges.json`, `manifest.json`. No edits to scoring, preflop systems, cosmetics, Chips/XP, scenario data, audit rules, or generator scripts.

---

## Remaining learning gaps / not built (intentional)

1. **Test Mode toggle** — not implemented this patch (per scope-out). Future v4.0.12 candidate if user requests self-assessment mode.
2. **Review Soon list from history** — described as "Optional: skip UI but leave helper function ready." The new `_pfBoardFamilyKey` is the building block; a future patch could call `_pfHistoryLoad()` and surface low-pct scenarios from prior sessions. Not built in v4.0.11 to avoid overbuilding.
3. **Replay Weak Spots button action** — Recommended Next Move says "Replay weak spots first" but the only button is the existing "Drill again" which builds a fresh queue. A future patch could add a "Drill weak spots" button that filters the queue to under-performing concepts/families.
4. **Per-question replay link** — Critical Leaks list shows the missed Q-numbers + boards but doesn't link directly back to that scenario. Could be added.
5. **Session-over-session trend** — only the current session is summarized; the local history could power a "you missed monotone last session AND this session" insight in a future patch.

---

## Recommended next step

**Hand v4.0.11 to the tester.** The learning loop is now closed for the most common case (player finishes session → gets clear feedback on what to study). Wait for tester feedback before scoping further:
- If tester reports the summary helps but they want a "Drill weak spots" action → v4.0.12 could add weak-family-only queue.
- If tester reports they want session-over-session trends → v4.0.12 could surface history-based insights.
- If tester reports the summary is enough and they want Module 2 → that's v4.1 territory.
