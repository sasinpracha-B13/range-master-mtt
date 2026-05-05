# v4.1.0 — Postflop Academy Foundation

**Status:** ✅ Implemented + verified live. Awaiting commit/push.
**Date:** 2026-05-04
**Trigger:** Evolve Postflop from a single quiz module into a structured learning academy. "Lay the foundation like a school. Make it robust and grow gradually."

---

## What was added

### 1. Postflop Academy panel (replaces simple Beta Lab entry card)
The Beta Lab area now hosts a curriculum-style **Postflop Academy** with a header, progress snapshot, recommendation, curriculum map (6 modules), Module 1 mastery checklist, and a 10-concept Concept Library. The simple v4.0.2 entry card remains as a defensive fallback if the Academy helper is unavailable.

### 2. Curriculum map (6 modules)
| Module | Status | Action |
|---|---|---|
| **Module 1 — Board Texture Foundations** | Active (green pill) | "▶ Continue Board Texture" + optional "🎯 Review Weak Spots" |
| **Module 2 — Flop C-bet IP** | Preview (amber pill) | "📖 Preview syllabus" toggles inline `<details>` with 5-line syllabus |
| **Module 3 — Facing C-bet OOP** | Locked | Disabled "🔒 Locked until foundation is stronger" |
| **Module 4 — Turn Strategy** | Future | Same |
| **Module 5 — River Strategy** | Future | Same |
| **Module 6 — Postflop Boss Exams** | Future | Same |

Each card shows: name, status pill, focus concepts, scenario count, mastery note, action button(s). Locked/Future cards are dimmed (opacity 0.65 / 0.50) but still visible — "a school should show the path ahead."

### 3. Module 1 mastery checklist
5 criteria displayed with met/not-met state. Display only — no enforcement (player can keep using Module 1 regardless of mastery state).

| Criterion | Met when |
|---|---|
| Complete 5 sessions | `sessionCount >= 5` |
| Hit 80%+ quality in 3 sessions | At least 3 sessions with `score/answered >= 0.80` |
| No critical leaks in latest session | `latestSession.critical === 0` |
| Engage with weak-spot review | Has any session with bad+critical > 0 AND sessionCount ≥ 2 (best-effort proxy) |
| Cover the 5 foundational concepts | History tracks: range_advantage, nut_advantage, small_cbet_freq, cbet_size_selection, static_board (each seen ≥ 1) |

### 4. Academy Progress Snapshot
Reads localStorage `rmtt_postflop_history`. Shows sessions completed, latest score %, latest quality pill (reuses `_pfSessionLearningLabel` for the colour-coded label), weak families (from current drill state if available). Empty state: *"Start Module 1 to build your academy profile."*

### 5. Recommendation Engine — `_pfAcademyRecommendation(stats)`
Picks one of 6 messages based on history + latest session:

| Condition | Message |
|---|---|
| No history | "Start with Board Texture Foundations." |
| Latest critical > 0 | "Review weak spots before continuing — at least one critical leak fired last session." |
| Latest bad+critical ≥ 4 | "Repeat Learn Mode — let the patterns settle before moving on." |
| sessionCount < 5 | "Build foundation: complete more Module 1 sessions (X / 5)." |
| All 5 mastery criteria met | "Module 1 foundation looks strong. Module 2 preview is recommended." |
| Recent strong (latest ≥ 80% AND no crit) but not all mastery met | "You are close to Module 2 readiness. Knock out the remaining mastery criteria." |
| Default | "Continue Module 1 — the more boards you read, the cleaner the patterns become." |

### 6. Concept Library (10 concepts)
Collapsible `<details>` drawer at the bottom of the Academy. 10 concept cards: Range Advantage, Nut Advantage, Board Texture, Static vs Dynamic, C-bet Frequency, Sizing Family, Monotone Boards, Paired Boards, Low Connected Boards, Two-tone Boards. Each card has name + short definition + "trained in Module 1" tag. Concise — no textbook-length explanations.

### 7. "Progress is saved locally on this device." note
Pinned to the bottom of the Academy panel. Honest copy — no implication of cloud sync or accounts.

---

## Helpers added (10 pure functions, all `_pf*` namespaced)

- `_PF_CURRICULUM` — declarative array of 6 module definitions
- `_PF_CONCEPT_LIBRARY` — declarative array of 10 concept definitions
- `_pfAcademyStats()` — pulls localStorage history + current drill state, returns aggregated stats object
- `_pfModuleStatus(moduleKey, stats)` — returns `'active' | 'preview' | 'locked' | 'future'`
- `_pfMasteryProgress(stats)` — returns 5 mastery items with met flags + detail strings
- `_pfAcademyRecommendation(stats)` — returns `{title, body}` recommendation
- `_pfMasteryProgressHtml(stats)` — collapsible mastery checklist HTML
- `_pfAcademySnapshotHtml(stats)` — progress snapshot HTML (empty state when no history)
- `_pfAcademyRecommendationHtml(stats)` — featured recommendation block HTML
- `_pfModuleCardHtml(mod, stats)` — single module card HTML
- `_pfCurriculumMapHtml(stats)` — full curriculum grid HTML
- `_pfConceptLibraryHtml()` — collapsible concept library HTML
- `_pfAcademyHomeHtml()` — top-level orchestrator (assembles all sections)

All helpers defensive against: missing localStorage, missing `App.postflop.scenarios`, missing concept tags on session records, malformed history JSON. All use `_pfEscape` for output.

---

## QA result (25/25 checks pass)

| # | Check | Result |
|---|---|---|
| 1 | Postflop audit 262/0/0 (data unchanged) | ✅ |
| 2 | App loads | ✅ |
| 3 | Beta OFF hides Postflop Academy | ✅ |
| 4 | Beta ON shows Postflop Academy | ✅ |
| 5 | Academy Home renders (title, subtitle, snapshot, recommendation, curriculum, mastery, concept library) | ✅ |
| 6 | Curriculum Map renders all 6 modules | ✅ |
| 7 | Module 1 card is Active and "Continue Board Texture" button starts the drill | ✅ |
| 8 | Weak Spots button still works in completion summary (existing flow unchanged) | ✅ |
| 9 | Module 2+ cards are Preview/Locked/Future and do NOT start broken flows (preview just toggles inline syllabus, locked is disabled) | ✅ |
| 10 | Mastery criteria display correctly with no history (all 5 not met, sessionCount=0) | ✅ |
| 11 | Mastery criteria display correctly with sample history (5 met when injected) | ✅ |
| 12 | Recommendation changes correctly across no-history / critical / poor / mastery-met / strong-recent / default cases (6/6 paths verified) | ✅ |
| 13 | Concept Library renders with 10 cards | ✅ |
| 14 | "Progress is saved locally on this device." note appears | ✅ |
| 15 | Existing Module 1 full session still completes | ✅ (existing flow unchanged) |
| 16 | Summary still works | ✅ |
| 17 | Drill Weak Spots still works | ✅ |
| 18 | Mobile 375px Academy readable (academyW=317px, no overflow) | ✅ |
| 19 | Mobile 375px Module cards readable (cardW=295px, button=273px) | ✅ |
| 20 | No horizontal overflow on mobile | ✅ |
| 21 | Console: 0 errors throughout | ✅ |
| 22 | Existing preflop drill works (`startDrill('quick')` returns 15-q queue) | ✅ |
| 23 | Boss UI present in mastery tab (string check) | ✅ |
| 24 | All 5 tabs render | ✅ |
| 25 | Diff scope: only `index.html` + `service-worker.js` modified, all forbidden files clean | ✅ |

---

## Files changed

| File | Change |
|---|---|
| `index.html` | New CSS block (`.pf-academy-*`, `.pf-module-*`, `.pf-concept-*`, `.pf-mastery-*`, `.pf-status-pill`, ~280 lines). New JS block (10 helpers + 2 declarative arrays, ~360 lines) inserted before `renderPostflopHomeCardMount`. Edit in `renderPostflopHomeCardMount` (1 site): READY-state body now calls `_pfAcademyHomeHtml()` with simple-card fallback. appVersion bump 4.0.12 → 4.1.0. |
| `service-worker.js` | VERSION v4.0.12 → v4.1.0 (cache-bust) |
| `PROJECT_STATE.md`, `TASK_BOARD.md` | Status update |
| `docs/specs/brief-v4.1.0-postflop-academy-foundation.md` | This file (NEW) |

**Untouched** (verified clean): `postflop/postflop_scenarios.json`, `postflop/postflop_taxonomy.json`, `postflop/postflop_concepts.json`, `tools/generate-postflop-module1.ps1`, `tools/audit-postflop-ps.ps1`, `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`, `tools/audit-postflop.js`, `ranges.json`, `manifest.json`. service-worker diff is solely VERSION v4.0.12 → v4.1.0.

---

## Remaining academy gaps

1. **Module 2+ are display-only** — locked actions show "🔒 Locked until foundation is stronger" but no actual mastery enforcement (player can still use Module 1 even without mastery). Future patch could add a mastery gate on Module 2 unlock.
2. **No persistent academy profile** — stats are computed on-demand from `rmtt_postflop_history`. No separate academy/curriculum schema. Would be needed for "academy XP" or per-module progression tracking.
3. **No Test Mode toggle** — still deferred per scope-out rules across patches.
4. **No multi-session trend visualization** — snapshot shows latest only. Could surface "you've improved on monotone over 3 sessions" insights.
5. **No tappable concept-from-library → drill that concept** — Concept Library is read-only. Could become an entry point for "drill range_advantage scenarios only" in a future patch.
6. **No per-module mastery for future modules** — only Module 1 has mastery criteria spelled out. When Module 2 ships, similar criteria need to be defined.

---

## Recommended next step

**Hand v4.1.0 to the tester.** The Postflop Academy foundation is in place — the player now has a clear curriculum view, knows where they are, what to do next, and what's coming. Wait for tester feedback before scoping further:

- If tester wants **Module 2 production-ready scenarios** → `v4.1.1`-style data sprint to expand Module 2 from 11 seed scenarios to ~150 production scenarios using the same generator pattern as v4.0.7. **Big work.**
- If tester wants **mastery gating** (lock Module 1 deep features behind progress) → small UI patch.
- If tester wants **per-concept drill from Library** → small UI patch (~50 lines + queue filter).
- If tester is satisfied with foundation as-is → short break before next sprint.
