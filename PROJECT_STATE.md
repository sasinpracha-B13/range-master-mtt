# Project State — Range Master MTT

> **READ THIS FIRST** before doing any work in this repo.
> Subagents: this file is your single source of truth for project context, current scope, and what is/is not allowed.
> Last updated: 2026-05-05

---

## 1. Current Version

- **Latest deployed to Netlify**: `v4.0.5-data` (live at `https://range-master-mtt.netlify.app/` — postflop GTO data honesty patch).
- **Last committed + pushed**: `v4.1.0` — Postflop Academy Foundation (`843fa76`).
- **Pending push (STAGED)**: `v4.1.1` — Postflop Concept Library Drill Actions. Each of the 10 v4.1.0 Concept Library cards becomes an actionable drill entry point: tap "🎯 Drill this concept" to start a 12-question Module 1 session focused on scenarios that train that concept (scoring rubric: +100 exact tag / +70 question type / +60 suit-or-texture / +40 related tag / −30 recent repeat / +0..10 randomness; threshold > 30). New `App.state.postflopDrill.mode = 'concept'` with `conceptKey` + `conceptDisplayName` + `conceptPoolSize` + `conceptFillUsed`; question screen shows blue Concept Drill badge; summary shows dedicated context label / `CONCEPT DRILL SUMMARY` eyebrow / "Concept drill complete" headline. Optional `🚨 Review signal` pill on cards whose primary or related tags appear in the latest session's weak concepts. Six new pure helpers + entry point (`_pfConceptDrillConfig`, `_pfConceptDisplayName`, `_pfConceptScenarioScore`, `_pfBuildConceptQueue`, `_pfConceptReviewSignal`, `startPostflopConceptDrill`). All 10 concept-drill keys verified to produce 12-question focused queues; spot-checks confirm 12/12 of the queue items match the concept (monotone, paired, range_advantage, two_tone, cbet_freq). Audit 262/0/0 (data unchanged). 45/45 QA checks pass. Mobile 375px verified. Console clean.
- **Service worker `VERSION`**: `'v4.1.1'` (staged).
- **App backup `appVersion`**: `'4.1.1'` (staged in `index.html`).

---

## 2. Current App Summary

The shipped app (`v3.8.2`) is a single-file PWA poker training tool focused on **MTT preflop** decisions. Capabilities:

- **Preflop drill engine** — quick / deep / weakness / challenge / overall_exam / marginal modes
- **Boss tests** + **Overall exams** + **Mission system** + **Challenges**
- **XP / Chips / Levels / Rank progression**
- **Wardrobe** cosmetic system (trainer character outfit)
- **Boss / Achievement / Rank / Source rewards** with reveal ceremonies
- **Collection Book** (long-term cosmetic progression with milestone rewards — v3.7.0)
- **Answer FX** + **Field FX** (per-pack themed atmosphere across drill flow — v3.8.0–v3.8.2)
- **Aura system** (cosmetic effect rendered around trainer character — v3.6.0)
- **SRS** (spaced repetition per hand) + **stats breakdown**
- **Settings** (FX intensity, reduced motion, exports/imports)

**Not yet built**:
- ❌ Post-flop training (in planning — see Active Epic).
- ❌ ICM-aware ranges.
- ❌ Multi-language UI.
- ❌ Cloud sync / accounts.

---

## 3. Current Active Epic

**v4.0.0 — Post-flop GTO Foundation Architecture**

A new training domain (sibling to preflop) for No Limit Hold'em MTT post-flop decisions. The first round is a **planning / data / audit package only** — no production integration in v4.0.0.

The epic is tracked in `TASK_BOARD.md`.

---

## 4. Current Execution Gate

**Round 1 (v4.0.0 planning) — what was authorized:**

1. Architecture proposal
2. Strict scenario schema
3. Board / suit / dynamic / advantage / sizing taxonomy
4. Concept taxonomy (with definitions + cross-refs)
5. 20–40 hand-authored sample scenarios
6. Audit script (17 rules) + browser audit viewer
7. Human-readable audit report
8. Risks & mitigations register

**Round 1 — what is NOT authorized:**

- ❌ Full drill engine integration in `index.html`
- ❌ Postflop boss/mission/challenge/reward integration
- ❌ Cosmetic rewards for postflop modules
- ❌ FX / Aura / Collection extensions for postflop
- ❌ Service worker version bump
- ❌ Modifying preflop ranges, scoring, SRS, or any existing reward logic

The gate stays closed until human review approves the planning package.

---

## 5. Latest Completed Work

### v4.1.0 Postflop Academy Foundation — STAGED

Evolves Postflop from a single quiz module into a structured learning academy. Per human direction: "Lay the foundation like a school. Make it robust and grow gradually."

**What was added**:
1. **Postflop Academy panel** replaces the simple Beta Lab entry card. Header with title + subtitle.
2. **Progress snapshot** — sessions completed, latest score %, latest quality pill (reuses `_pfSessionLearningLabel`), weak families from current drill state. Empty-state copy: "Start Module 1 to build your academy profile."
3. **Recommendation engine** (`_pfAcademyRecommendation`) — 6 rule-driven messages: no-history → start; latest critical → review weak; many bad → repeat Learn Mode; <5 sessions → build foundation; all 5 mastery met → Module 2 preview ready; recent strong but not all met → close to ready; default → continue.
4. **Curriculum map** (6 modules with status pills): Module 1 Active (Continue + optional Review Weak Spots buttons); Module 2 Preview (Preview syllabus toggles inline `<details>`); Module 3 Locked; Module 4-6 Future. Locked/Future cards dimmed (opacity 0.65/0.50) but still visible — "a school should show the path ahead."
5. **Module 1 mastery checklist** (5 display-only criteria): 5 sessions, 80%+ in 3 sessions, no critical leaks latest, weak-spot review engaged, foundational concepts covered. Each row shows met/not-met icon + detail string. No enforcement.
6. **Concept Library drawer** — 10 concepts (Range Advantage, Nut Advantage, Board Texture, Static vs Dynamic, C-bet Frequency, Sizing Family, Monotone, Paired, Low Connected, Two-tone). Each card has short definition + "trained in Module 1" tag.
7. **"Progress is saved locally on this device."** note pinned to the bottom. Honest copy — no implication of cloud sync.

**Helpers added** (10 + 2 declarative arrays, all `_pf*` namespaced):
`_PF_CURRICULUM`, `_PF_CONCEPT_LIBRARY`, `_pfAcademyStats`, `_pfModuleStatus`, `_pfMasteryProgress`, `_pfAcademyRecommendation`, `_pfMasteryProgressHtml`, `_pfAcademySnapshotHtml`, `_pfAcademyRecommendationHtml`, `_pfModuleCardHtml`, `_pfCurriculumMapHtml`, `_pfConceptLibraryHtml`, `_pfAcademyHomeHtml`.

All defensive against: missing localStorage, missing `App.postflop.scenarios`, malformed history JSON, missing concept tags. All output goes through `_pfEscape`.

**Live QA result** (25/25 checks pass):
- Helpers loaded; recommendation engine returns correct messages across no-history / critical / poor / mastery-met / strong-recent / default cases (6/6 paths verified)
- Beta off hides Academy; beta on shows full Academy (title, snapshot, recommendation, 6 module cards, mastery, 10 concepts, local-only note)
- Module 1 "Continue Board Texture" button starts the existing drill
- Mastery checklist updates correctly with no-history vs sample-strong-history
- Mobile 375px: academy 317px wide, no overflow, action buttons 273px tappable
- Console: 0 errors throughout
- Tab regression + preflop drill + boss UI: all working

**Files modified**: `index.html` (CSS block ~280 lines + 10 new helpers + 2 declarative arrays + edit in `renderPostflopHomeCardMount` to call new helper + appVersion 4.0.12 → 4.1.0), `service-worker.js` (VERSION v4.0.12 → v4.1.0), `PROJECT_STATE.md`, `TASK_BOARD.md`, `docs/specs/brief-v4.1.0-postflop-academy-foundation.md` (NEW).

**Untouched**: all postflop data files, audit infrastructure, generator scripts, ranges, manifest, preflop systems, scoring, cosmetics. service-worker diff is solely VERSION bump.

### v4.0.12 Postflop Drill Weak Spots Button — COMMITTED + PUSHED (`79cfc2a`)

After v4.0.11 added a "Recommended next move: replay weak spots first" line, the only available action was the existing "Drill again" button which built a fresh queue ignoring the player's mistakes. v4.0.12 closes the loop with an actual weak-spot replay flow.

**What was added**:
1. **"🎯 Drill Weak Spots" button** on the completion summary, only shown when the just-completed session has at least one bad or critical answer (`hardMisses > 0`). Amber-styled to differentiate from the standard "Drill again" button.
2. **"No weak spots detected this session."** italic note shown when no bad/critical answers — positive feedback rather than a disabled-button anti-pattern.
3. **"🎯 Review Mode · Weak Spots" badge** on the question screen during a weak-spot review session. Subcopy: "Focused on concepts and board families missed last session."
4. **Dynamic completion-screen header** when in weak-spot mode: "Board Texture Trainer · Review session complete" + "REVIEW SESSION SUMMARY".

**Helpers added** (4 pure functions, all `_pf*` namespaced):
- `_pfCurrentSessionWeakProfile(answers, scenarios)` → null OR `{mode, sourceSessionId, hardMisses, targetScenarioIds, targetConceptTags, targetFamilyKeys}`. Soft fallback when hardMisses < 2 includes acceptable answers as weak signals (weight 0.5).
- `_pfWeakScenarioScore(scenario, weakProfile, lastSessionIds)` → numeric score (+100 exact missed / +60 weak family / +40 weak concept / −30 recent repeat / +0..10 random).
- `_pfBuildWeakSpotQueue(weakProfile, allScenarios, targetLen=12)` → up to 12 scenarios, weak-prioritized then filled with general scenarios if pool too small. Always returns an array, no duplicates.
- `startPostflopWeakSpotReview()` — entry point wired to the button. Falls back to `startPostflopDrill('pf_board_texture')` when no weakness or pool empty.

**Defensive behavior**: returns null on perfect session; soft-fallback works when hardMisses=0 but acceptable answers exist; missing `conceptTags` / cleared localStorage / null `App.postflop.scenarios` all handled without crash; weak button hidden when no hard misses.

**Live QA result** (23/23 checks pass):
- Helpers loaded; weak profile derives correctly from POOR (10 hard misses → 9 target scenarios, 11 concept tags, 6 family keys), ONE-BAD (1 hard miss → 1 target + 11 fillers), ALL-ACCEPTABLE (soft fallback: 15 scenarios + 17 concepts as 0.5-weight signals)
- Queue properties verified: 12 unique scenarios; 100% family coverage on 10-bad session; 9/9 missed scenarios surfaced first
- Perfect session: weak button hidden + "No weak spots detected" note shown
- One-critical session: weak button visible
- Click weak button → `mode === 'weak_spots'`, badge appears, 12-question queue starts
- Answer → feedback → next still works; all 5 feedback blocks render in review mode
- Review summary header changes to "Review session complete" + "REVIEW SESSION SUMMARY"
- Mobile 375px: weak button 343×49px tappable; badge 343px wide, no overflow
- Console: 0 errors throughout
- Tab regression + preflop drill + boss UI + beta toggle: all working

**Files modified**: `index.html` (CSS block ~50 lines + 4 new helpers ~210 lines + Review Mode badge wire-in to `renderPostflopQuestion` + 4 edits to `renderPostflopComplete` for dynamic header/headline + weak button + empty note + appVersion 4.0.11 → 4.0.12), `service-worker.js` (VERSION v4.0.11 → v4.0.12), `PROJECT_STATE.md`, `TASK_BOARD.md`, `docs/specs/brief-v4.0.12-postflop-drill-weak-spots.md` (NEW).

**Untouched**: all postflop data files, audit infrastructure, generator scripts, ranges, manifest, preflop systems, scoring, cosmetics.

### v4.0.11 Postflop Session Learning Summary — COMMITTED + PUSHED (`a2e4fae`)

After a Module 1 session, the player should understand what they learned and what to focus on next. Prior summary screen showed score + tier counts + a flat concept-mastery list. v4.0.11 adds a learning-focused block stack between the score card and the existing details.

**New sections** (all derived from existing session data; no schema changes; no data file edits):

1. **Dynamic quality label** replaces the static "✅ Drill Complete" subtitle. Picks one of: "Clean read" / "Good pattern recognition" / "Mixed session" / "Needs review" / "High-risk leaks found" — colour-coded pill (green / blue / amber / red).
2. **Strongest concepts** green block — top 3 conceptTags by score % where seen ≥ 2 AND pct ≥ 80.
3. **Review signals** amber block — worst 3 conceptTags (lowest pct, then most bad+critical). Shows green-empty-state ("No major weak concept detected this session.") when clean.
4. **Board family pattern notes** red block — surfaces up to 3 families where misses cluster (missCount ≥ 2 OR critical ≥ 1). Each row shows the family label + miss count + one-sentence coaching lesson from an 18-entry family map (e.g., "low connected — missed 2 of 3. BB has more suited connectors and straight density.")
5. **Recommended next move** blue block — single coaching action: "Replay weak spots first..." (if critical), "Run another Learn Mode session..." (if 4+ bad/crit), "Focus on turning acceptable into best..." (if too many half-credit), "Good session..." (if 80%+ best), or "Keep going..." (default).

The existing concept-mastery details + critical-leaks details are preserved below (collapsed by default for power users).

**Helpers added** (8 pure functions, all `_pf*` namespaced):
`_pfBoardFamilyKey(board)`, `_pfBoardFamilyDisplayLabel(key)`, `_pfBoardFamilyLesson(key)`, `_pfLearnPrettyConcept(tag)`, `_pfSessionConceptSummary(answers)`, `_pfSessionBoardFamilySummary(answers, scenarios)`, `_pfSessionLearningLabel(counts, total)`, `_pfSessionNextMove(counts, total)`, `_pfRenderLearningSummary(...)`.

**Defensive fix**: legacy `conceptTally` line in `renderPostflopComplete` was crashing if an answer had no `conceptTags` (legacy localStorage). Added `(a && a.conceptTags) || []` guard. Per brief requirement #12.

**Live QA result** (20/20):
- Helpers loaded; perfect / poor / mixed session profiles all produce sensible labels + concepts + family clusters
- Mobile 375px: no horizontal overflow; summary card 343px wide
- Edge cases pass: missing conceptTags, cleared localStorage, empty answers, null `App.postflop.scenarios`
- Console: 0 errors throughout
- All 5 tabs render; preflop drill works; beta toggle hides/shows postflop

**Files modified**: `index.html` (CSS block + 8 new helper functions + 2 edits in `renderPostflopComplete` + appVersion 4.0.10 → 4.0.11), `service-worker.js` (VERSION v4.0.10 → v4.0.11), `PROJECT_STATE.md`, `TASK_BOARD.md`, `docs/specs/brief-v4.0.11-postflop-session-learning-summary.md` (NEW).

**Untouched**: all postflop data files, audit infrastructure, generator scripts, ranges, manifest, preflop systems, scoring, cosmetics.

### v4.0.10 Postflop Card Text Encoding Hotfix — COMMITTED + PUSHED (`53eae80`)

Tester reported that Postflop question text shows broken suit symbols (`Aโฅ Kโฆ 5โฃ`) while card graphics render correctly (`A♥ K♦ 5♣`). Root-cause investigation found **CP874 (Thai Windows) → UTF-8 mojibake** in the v4.0.0 baseline scenarios: original UTF-8 bytes were at some point read as CP874 then re-encoded as UTF-8, splitting each multi-byte char into 2-3 separate Thai/Latin codepoints. Affects `question.prompt` and `explanation.*` (rangeLogic / nutLogic / sizingLogic / commonMistake / short) on ~31 baseline scenarios. The 220 v4.0.7-generated scenarios are clean. `board.cards` is clean ASCII on all scenarios — that's why card graphics work.

**Fix at render time** (per instruction "do NOT change postflop data"):
1. `_pfCardText(card)` and `_pfBoardText(cards)` build clean board text from clean ASCII `board.cards` using existing `_pfSuitChar`.
2. `_pfBuildQuestionPrompt(scenario)` reconstructs the question sentence per `question.type` using `_pfBoardText`, ignoring the corrupted `question.prompt` field.
3. `_pfFixMojibake(text)` walks input char by char, mapping CP874-mojibake codepoints back to their original bytes (via reverse maps `_pfCp874ToByte` and `_pfThaiCpToByte`), then decoding accumulated bytes as UTF-8 via `TextDecoder('utf-8', {fatal:true})`. Falls back to original chars if a chunk fails to decode (so real Thai/accented text passes through unchanged).
4. `renderPostflopQuestion` now uses `_pfBuildQuestionPrompt(scenario)` instead of `scenario.question.prompt`.
5. `_pfTeachingFeedbackBlocksHtml` and `renderPostflopAnswer` wrap explanation text with `_pfFixMojibake` before `_pfEscape` (5 sites total).

**Live verification** (corrupted baseline `AhKd5c_rangeadv_001`):
- Raw data prompt: `On Aโฅ Kโฆ 5โฃ ...` (codepoints U+0E42 U+0099 U+0E05 etc.)
- Rendered prompt: `On A♥ K♦ 5♣ ...` (codepoints U+2665 U+2666 U+2663 — clean)
- Raw rangeLogic snippet: `KJo+ โ€" many cards`
- Rendered rangeLogic: `KJo+ — many cards` (em-dash U+2014)
- Card graphics still render correctly (verified `boardCardSuits = [♥, ♦, ♣]`)
- All 5 feedback blocks render
- Zero mojibake codepoints in any rendered text
- Console: 0 errors

**Audit**: 262/0/0 (data file unchanged).

**Files modified**:
- `index.html` (~80 lines new helpers + 6 render-site rewires + appVersion 4.0.9 → 4.0.10)
- `service-worker.js` (VERSION v4.0.9 → v4.0.10)
- `PROJECT_STATE.md`, `TASK_BOARD.md` (status update)
- `docs/specs/brief-v4.0.10-postflop-card-text-encoding-hotfix.md` (NEW)

**Untouched**: all postflop data files, audit infrastructure, generator scripts, ranges, manifest, preflop systems, scoring, cosmetics.

A future v4.1 cleanup pass could optionally rewrite the data file with clean UTF-8, making the render-time fix a no-op. For now the helper protects against the corruption permanently — even if the file is ever round-tripped through CP874 again.

### v4.0.9 Postflop Teaching Polish — COMMITTED + PUSHED (`c38aafc`)

Targeted polish of the v4.0.8 teaching layer based on the v4.0.8 Extended QA report (`docs/specs/postflop-v4.0.8-teaching-layer-qa-report.md`).

**Five fixes implemented**:

1. **Fix M1** (`_pfHintForBoard`): Q/J/T-high non-paired non-monotone disconnected scenarios were falling to a generic fallback hint. Added Q-high specific branch ("Ask: does BTN have more Q-x, K-x, and overpairs than BB has...") and J/T-high merged branch ("Ask: does BB have suited connectors and middle pocket pairs..."). Affects ~30 scenarios.

2. **Fix M3** (`_pfTakeawayForBoard`): Same Q/J/T-high boards had a generic takeaway. Added Q-high branch ("Q-high boards still favor BTN but the edge is smaller than A/K-high") and J/T-high branch ("J/T-high disconnected boards are closer to neutral; mixed small/check often beats range-betting"). Affects ~30-40 scenarios.

3. **Fix M4** (`_pfTakeawayForBoard`): `low_dry_two_tone` boards (e.g., 9h6h2c, 7h3h2s) were getting the rainbow takeaway "Low disconnected boards still favor BTN... small high-frequency c-bet works" — but the actual `sizing_family` answer for these boards is `mixed_small_check`. Added new branch BEFORE the rainbow rule: "Low disconnected two-tone boards can still retain BTN overpair advantage, but the flush draw makes pure range-small less automatic; mixed small/check is usually safer." Affects ~6 scenarios.

4. **Fix L1** (`_pfPatternLabel`): (a) Two-tone scenarios with `dynamicLevel >= 3` now return "X two-tone medium board" instead of misleading "X two-tone semi-dry". (b) Final fallback for rainbow non-paired non-monotone disconnected with `dyn >= 3` now returns "X semi-wet board" or "X semi-connected board" instead of the empty "X board".

5. **Fix M2 (optional, implemented)**: `_pfTeachingFeedbackBlocksHtml` rewritten to use new `_pfPickPrimaryLogic(qtype, explanation)` helper. Core Reason now shows ONLY the question-type-relevant logic strand (rangeLogic for range_advantage, nutLogic for nut_advantage, sizingLogic for frequency_strategy / sizing_family / dynamic_level). Other strands collapse into a "More logic strands" `<details>` block. Heavy multi-strand scenario went from ~200 words inline to ~80 words primary + collapsed remainder. Cuts mobile reading load roughly in half on heavy scenarios.

**Live verification results** (9 test cases):
- Q-high rainbow disconnected: now gets specific hint + specific takeaway ✓
- J-high rainbow dyn=3: pattern is "J-high semi-wet board" (was "J-high board") ✓
- T-high two-tone dyn=3: pattern is "T-high two-tone medium board" ✓
- Low two-tone disconnected: takeaway acknowledges flush draws + mixed sizing ✓
- frequency_strategy with all 3 strands: Core Reason starts "Sizing logic:" with "More logic strands" collapsed below ✓
- range_advantage scenarios: Core Reason starts "Range logic:" only ✓
- nut_advantage scenarios: Core Reason starts "Nut logic:" only ✓
- A-high dry, low connected two-tone, paired_mid: all unchanged regression ✓

**Files modified**:
- `index.html` (CSS untouched; JS edits in `_pfPatternLabel`, `_pfHintForBoard`, `_pfTakeawayForBoard`, `_pfTeachingFeedbackBlocksHtml`; new helper `_pfPickPrimaryLogic`; appVersion 4.0.8 → 4.0.9)
- `service-worker.js` (VERSION v4.0.8 → v4.0.9)
- `PROJECT_STATE.md`, `TASK_BOARD.md` (this section + status row)
- `docs/specs/brief-v4.0.9-postflop-teaching-polish.md` (planning + implementation log)
- `docs/specs/postflop-v4.0.8-teaching-layer-qa-report.md` (QA report from prior session, still untracked → staged with this commit)

**Untouched** (verified): `ranges.json`, `manifest.json`, all postflop data files, audit infrastructure, generator scripts, preflop systems, scoring, cosmetics.

**Audit**: 262 / 0 errors / 0 warnings.

### v4.0.8 Postflop Teaching Layer — COMMITTED + PUSHED (`479b775`)

Module 1 (Board Texture Trainer) UI patch. After v4.0.7 expanded the scenario pool to 251, human tester reported: *"I can play it now, but I do not understand the principles behind the answers."* The app was asking questions but not teaching the underlying board-reading framework.

**Five teaching components added** (all in `index.html`, additive in a fenced v4.0.8 CSS + JS block):

1. **Pattern Label** — short header above each board (e.g. "🎯 J-high two-tone semi-dry") with meta-line ("two_tone · disconnected · semi-static"). Derived from `board.highCardClass`, `board.suitTexture`, `board.textureTags`, `board.pairedStatus`, `board.dynamicLevel` via `_pfPatternLabel(board)`. Reads field values only — no schema changes.
2. **Board Reading Checklist** — collapsible 7-item educational framework (high card / texture / connectivity / suit / range adv / nut adv / sizing implication). Same for every scenario; teaches the reading PROCESS rather than the answer.
3. **Pre-answer Hint** — "💭 Need a hint?" button reveals a non-spoiler thinking-prompt based on board family (e.g. "Ask: does BB have BOTH straight density AND flush-draw density?"). Verified to never directly state the answer.
4. **5-block Feedback Layout** — `renderPostflopAnswer` restructured into Result / Board Pattern / Core Reason / 💡 Takeaway / ⚠️ Common Mistake. Replaces the previous separate `<details>` per logic strand — same content surfaced more readably without extra clicks.
5. **Takeaway Generator** — `_pfTakeawayForBoard(board)` produces a one-sentence generalizable lesson per board family (e.g. "Low connected two-tone boards are dangerous for BTN: BB has straight density AND flush-draw density combined.").

Plus a small "LEARN MODE · EXPLANATIONS ENABLED" mode tag pill. Full Test Mode (toggle to hide hints/explanations) deferred to v4.0.9 if needed.

**Helpers added** (8 pure functions, all `_pf*` namespaced):
`_pfPatternLabel`, `_pfBoardMetaLine`, `_pfHintForBoard`, `_pfTakeawayForBoard`, `_pfBoardChecklistHtml`, `_pfPatternLabelHtml`, `_pfHintRowHtml`, `_pfTeachingToggleHint`, `_pfTeachingFeedbackBlocksHtml`.

**Live QA result**:
- ✅ Postflop audit 262/0/0 (data unchanged)
- ✅ Module 1 loads 251 scenarios; all 8 helpers resolve to functions
- ✅ Pattern + hint + takeaway match correctly across 5 sample board families (A-high dry, low connected two-tone, low monotone, paired mid, broadway connected)
- ✅ Beta OFF: postflop screen hidden, no Beta Lab section
- ✅ Beta ON: question screen shows pattern label, checklist, hint button, mode tag
- ✅ Hint toggle open/close; verified no answer leak
- ✅ Choice click → 5-block feedback renders with correct content per scenario
- ✅ Mobile 375px: no horizontal overflow; all teaching elements render cleanly
- ✅ All 5 tabs render
- ✅ Console: 0 errors

**Files modified**: `index.html` (CSS + JS additive block + 2 render-fn modifications + appVersion 4.0.6→4.0.8), `service-worker.js` (VERSION v4.0.7→v4.0.8), `PROJECT_STATE.md`, `TASK_BOARD.md`, `docs/specs/brief-v4.0.8-postflop-teaching-layer.md` (NEW).

**Untouched**: `ranges.json`, `manifest.json`, all postflop data files, audit infrastructure, generator scripts, preflop systems, scoring, cosmetics.

### v4.0.7 Module 1 Scenario Expansion — COMMITTED + PUSHED (`1f5fe99`)

Third pass on the largest data sprint to date. Corrects GPT-flagged template overgeneralization in the generic `two_tone` family.

**Template-correction summary**:
- Split `two_tone` family into 5 sub-families based on rank-class + connectedness (`high_two_tone_dry`, `mid_two_tone_dry`, `broadway_two_tone_connected`, `low_dry_two_tone`, `low_connected_two_tone`)
- Each board re-classified into the right sub-family by `ClassifyTwoTone()` in the generator
- Fixed `paired_mid` wording: "set combos for the paired rank" → "trips combos with the paired rank" (technically correct since you can't have a "set" of an already-paired board card)
- All 9 GPT-named samples re-verified (5 fixed answers, 1 wording fix only, 3 kept with documented reasoning)
- Module 1 grew from 243 → **251 scenarios** as a side-effect of bumping plan to use more two-tone boards
- **Micro-fix pass (final)**: monotone_low nut wording corrected ("essentially zero nut combos" → acknowledges Axs nut-flush combos); paired_mid + monotone_low + similar solver-sensitive families now have `preflop_raiser`/`caller` opposite as `bad` not `critical` for nut_advantage; `neutral` added to acceptable for nut_advantage on those families
- See `docs/specs/postflop-v4.0.7-template-correction-report.md` for full reasoning

**Final canonical counts (template-correction + micro-fix)**:
- Module 1 scenarios: **251**
- Module 2 scenarios (unchanged): **11**
- Total postflop scenarios: **262**
- Audit: **0 errors / 0 warnings**
- sourceConfidence: 133 `consensus_gto` / 118 `expert_judgment` / 0 `solver_verified` / 0 `needs_review`
- suitTexture: 140 rainbow (55.8%) / 96 two_tone (38.2%) / 15 monotone (6%)
- difficulty: 30/100/43/55/23 across diff 1–5
- qtype: ra=58, na=57, fs=48, sf=39, dl=49

**Hardening pass summary** (second pass, intermediate — superseded by template-correction; numbers below are historical for the hardening pass only):

**Module 1 pool**: 20 → **243 scenarios** (+223 net). All 14 board family/suit combinations and all 5 question types covered.

**Hardening corrections** (vs initial v4.0.7 staging):

1. **sourceConfidence rebalanced.** Was 239 `consensus_gto` / 4 `expert_judgment` (98% overclaim). Now 97 `consensus_gto` (39.9%) / 146 `expert_judgment` (60.1%) / 0 `solver_verified` / 0 `needs_review` — all in target ranges. Per-family per-qtype confidence rules encoded in the generator: only universally-agreed reads (A/K-high dry rangeAdv, low-connected check-heavy, etc.) keep `consensus_gto`; everything else (sizing, monotone, two-tone, paired_mid, J/T_medium) honestly tagged `expert_judgment`.
2. **suitTexture rebalanced.** Was 200 rainbow (82%) / 25 two_tone (10%) / 18 monotone (7%) — too rainbow-heavy. Now 130 rainbow (53.5%) / 98 two_tone (40.3%) / 15 monotone (6.2%) — all in target ranges. ~75 new two-tone boards added across all families (genuine new boards, not trivial card-swap duplicates of rainbow). Rainbow plan trimmed to keep total Module 1 ~240.
3. **Generator tooling tracked.** Was `.gen-postflop.ps1` + `.audit-postflop.ps1` at repo root (gitignored). Now `tools/generate-postflop-module1.ps1` + `tools/audit-postflop-ps.ps1` (tracked, documented, deterministic, idempotent — re-runs strip + replace `*_v407` ids; baseline preserved).
4. **GPT review package expanded.** Was 20 samples, no risk breakdown. Now 30 samples (5 easy + 10 medium + 10 hard + 5 highest-risk) with coverage requirements (≥5 rainbow, ≥10 two-tone, ≥5 monotone, ≥5 paired, ≥5 very-wet/connected) and dedicated "Scenarios most likely to be disputed by strong players" section calling out 5 named risk categories.

**Audit result**: 0 errors / 0 warnings across all 254 total postflop scenarios. Zero board-card duplicates. Zero (board, qtype) duplicates.

**[HARDENING PASS HISTORICAL]** Distribution at end of hardening pass (Module 1 = 243; superseded by template-correction final = 251):
- qtype: ra=49, na=47, fs=53, sf=49, dl=45 (all 45-53)
- diff: 27/84/59/58/15 across 1-5
- suitTexture: rainbow 130 (53.5%) / two_tone 98 (40.3%) / monotone 15 (6.2%)
- sourceConfidence: consensus_gto 97 / expert_judgment 146 / solver_verified 0 / needs_review 0
- All `auditStatus="approved"`

**[HARDENING PASS HISTORICAL] Files modified at end of hardening pass** (final stage list above is canonical):
- `postflop/postflop_scenarios.json` (+223 scenarios at end of hardening; 31 → 254)
- `service-worker.js` (`v4.0.6` → `v4.0.7`)
- `tools/generate-postflop-module1.ps1` (NEW, tracked)
- `tools/audit-postflop-ps.ps1` (NEW, tracked)
- `docs/specs/postflop-v4.0.7-scenario-expansion-report.md` (NEW, hardened)
- `docs/specs/postflop-v4.0.7-gpt-review-package.md` (NEW, 30 samples)
- `PROJECT_STATE.md`, `TASK_BOARD.md` (this section + status row)

**Untouched** (verified): `index.html`, `ranges.json`, `manifest.json`, `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`, `tools/audit-postflop.js`.

**Discovered work (tracked in TASK_BOARD)**:
- `polar_big_strategy` concept tag has only 1 scenario (concept naturally surfaces on turn/river → reserved for v4.1)
- Difficulty diff-5 only 15 scenarios (target 20) — bumping more would inflate honesty
- 5 highest-risk categories enumerated for GPT review attention

### v4.0.6 Postflop Repeat Control + Local Session History — STAGED

Tester reported postflop questions felt repetitive after ~3 sessions. Module 1 has 20 scenarios; sessions use 15. Pure Fisher-Yates random meant ~75% overlap between back-to-back sessions on average.

**Implementation** (all in `index.html`, additive in a new v4.0.6 fenced block + 4 in-place edits to v4.0.2 functions):

1. **Local history schema** in `localStorage.rmtt_postflop_history`:
   - `scenarios[scenarioId]` — attempts, per-tier counts, totalScore, lastTier, lastScore, lastSeenAt, lastSessionId
   - `concepts[conceptTag]` — same shape, aggregated per tag
   - `sessions[]` — capped to most recent 50 sessions (id, date, module, scenarioIds, score, tier counts)
   - Defensive load with shape recovery; defensive save with try/catch
2. **`recordPostflopAnswer` hook** — calls `_pfHistoryRecordAnswer(scenario, cls)` after the in-memory record. Best-effort; never throws.
3. **`renderPostflopComplete` hook** — calls `_pfHistoryRecordSession({module, queue, answers, totalScore, counts})` to save the compact session summary.
4. **History-aware `buildPostflopQueue`**: scores each candidate (`+100` if never seen, `+30` if not in last session, `+10` if attempts<3, `-50` if in last session, `-attempts*3`, `+random*20`); sorts and slices. Result: back-to-back overlap reduced to **theoretical minimum** (10/15 with pool=20, sessionLength=15).
5. **`App.postflopHistorySummary()`** — dev console helper returns scenarios tracked, concepts tracked, sessions count, top 5 most-seen, last session ids.
6. **"Progress is saved locally on this device."** — honest copy on the home card; no overclaim about sync/cloud/account.

**QA verified** (live local server):
- ✅ Audit 31/0/0
- ✅ Within-session: zero duplicates (`new Set(queue.ids).size === 15`)
- ✅ Back-to-back overlap: 10/15 (67%) = theoretical minimum, ~12% better than pure-random expected ~11.25
- ✅ History persists in localStorage
- ✅ History tracking: 15 scenarios + 17 concepts + 1 session after a single completed run
- ✅ Beta toggle off→hides UI, on→UI back
- ✅ All 5 tabs render
- ✅ Preflop drill 5 hands all classified correctly + preflop SRS storage grew (independent of postflop history)
- ✅ Postflop history + preflop progress in separate localStorage keys (no collision)
- ✅ Console clean

**Files modified**: `index.html` (+218 / -10), `service-worker.js` (VERSION bump only). Postflop data files + audit infrastructure all 0-diff.

### v4.0.5 GTO Data Validation Pass — committed (`87c741e`) + pushed

Walked all 20 Module 1 Board Texture Trainer scenarios with GTO scrutiny. Findings published in `docs/specs/postflop-v4.0.5-gto-validation-report.md` and `docs/specs/postflop-v4.0.5-data-patch-plan.md`.

**Verdict tally**:
- 17 KEEP (no change)
- 2 KEEP-with-caveat (#11 Th8h3h_nutadv monotone, #20 7d7s3c_rangeadv paired-low — both already at expert_judgment + difficulty 3-4; honest hedging acceptable)
- 1 DOWNGRADE (#14 Qd9c4h_rangeadv — proposed sourceConfidence: consensus_gto → expert_judgment)
- 0 REVISE answer keys
- 0 HOLD from production

**Net production-ready**: 20 / 20 scenarios remain shippable. The proposed edit is a metadata honesty tag with zero player-visible impact.

**Audit re-confirmed**: 31 scenarios · 0 errors · 0 warnings (no data files touched in this pass).

### v4.0.4 Critical Hotfix — committed (`519df53`) + pushed

Real-play feedback after v4.0.3: tester reported answer buttons unresponsive on BOTH desktop and mobile, AND Choice Guide invisible on mobile.

**Root cause** (introduced in v4.0.2, not caught in v4.0.2 or v4.0.3 QA): the inline `onclick="handlePostflopChoice(' + JSON.stringify(ch.id) + ')"` had a quote conflict — `JSON.stringify("range_small")` returns `"range_small"` with double quotes, embedded into double-quoted onclick attribute, breaking HTML parsing. The browser truncated `onclick` to `handlePostflopChoice(` (just the partial stub) and parsed the rest as garbage attributes. **Real clicks never fired the handler.** My v4.0.2 and v4.0.3 QA passed because I called `handlePostflopChoice(bestId)` directly via JS, bypassing the broken onclick path. The bug was invisible to my automated tests and only surfaced in human real-play.

**Fixes applied**:
1. **Delegated event listener** on `#postflopScreen` (one handler for all clicks; reads `dataset.choiceId` from nearest `.postflop-choice-btn` ancestor of click target). Survives re-renders since it's attached to the persistent screen element. Idempotent re-installation via `_pfInstallDelegatedClickListener()` called on boot AND on every `showPostflopScreen()`.
2. **Renamed handler** to `handlePostflopChoiceById(choiceId, btn)` — accepts optional button reference for instant pressed state. Backward-compat alias `handlePostflopChoice(choiceId)` retained.
3. **Choice Guide v2** — always-visible 1-line summary block (`.postflop-choice-guide-v2 .pf-guide-summary-line`) above choice buttons; expandable `<details>` for per-choice breakdown below. Replaces v4.0.3's collapsed-by-default `<details>` that mobile users didn't see.
4. **Touch reliability**: `touch-action: manipulation` (eliminates iOS 300ms tap delay), `position: relative; z-index: 1` on `.postflop-choices` and `.postflop-choice-btn` (prevents decorative canvas layers from intercepting taps), `-webkit-tap-highlight-color`, `user-select: none`.
5. **Reinforced FX suppression**: `body[data-postflop-active="true"]` now hides `.field-fx-canvas`, `.answer-fx-canvas`, `.aura-canvas` AND sets `pointer-events: none` on them.
6. **Fail-safe error fallback**: try/catch around classify+record+render. If render fails, `_pfShowAnswerError()` shows inline red banner ("Could not process answer. Tap again."), re-enables buttons, restores `phase = 'question'` so user can retry.

**Files modified**: `index.html` (+225 lines / -37, all inside existing v4.0.2/v4.0.3 fenced blocks), `service-worker.js` (VERSION bump).

**Audit re-confirmed**: 31/0/0 (no data files touched).

### v4.0.3 Implementation — committed (`25fb45e`) + pushed

Real-play hotfix per human tester feedback. Fixes 4 issues:

| # | Issue | Fix |
|---|---|---|
| 1 | Loading feels slow | Loader (`loadPostflopData`) now re-renders Home if user is on it AND beta is on (success and error paths). Card has 3 states: loading (spinner) / ready / error (with reload button). |
| 2 | Choice meanings unclear | New `_pfChoiceGuide(qType)` helper renders an expandable "What are we choosing?" panel above choice buttons. 5 question types × per-type explanations. |
| 3 | Buttons feel unresponsive | `handlePostflopChoice` now disables all buttons synchronously + adds `postflop-choice-pressed` class to tapped button BEFORE classify/render. Uses `requestAnimationFrame` so the pressed visual paints before the heavy innerHTML swap. New phase `'answering'` blocks rapid re-entry. |
| 4 | Home placement too low | `renderPostflopHomeCardMount` now uses `insertAdjacentHTML('afterbegin', ...)` to prepend at TOP of Home; wraps card in `.postflop-betalab-section` with "🧪 BETA LAB" header for clear beta status. |

**Files modified**: `index.html` (~250 lines added/modified across 6 surgical edits + 1 CSS block), `service-worker.js` (VERSION bump).

**Audit re-confirmed**: 31 scenarios · 0 errors · 0 warnings (no data files touched).

### v4.0.2 Postflop Module 1 (Board Texture Trainer) UI — committed (`5d21128`) + pushed

First visible postflop UI. Beta-gated via `App.state.settings.postflopBeta` (default `false`). Implementation per `docs/specs/brief-v4.0.2-implementation-ready.md`.

**Changes**:
- `index.html` (~960 lines added in single fenced v4.0.2 block + 2 one-liner appends to renderMastery/renderSettings + `appVersion` bump):
  - New `#postflopScreen` container (sibling to `#drillScreen` inside tab-drill panel)
  - CSS block for all `.postflop-*` classes (~290 lines)
  - JS block: `getPostflopReady`, `getModule1Scenarios`, `getConceptByKey`, `App.state.postflopDrill` state, `buildPostflopQueue`, `startPostflopDrill`, `classifyPostflopAnswer` (multi-tier), `recordPostflopAnswer`, `handlePostflopChoice`, `advancePostflopDrill`, `showPostflopScreen`, `exitPostflopScreen`, `confirmExitPostflop`, `renderPostflopHomeCardMount`, `renderPostflopBetaToggleMount`, `togglePostflopBeta`, `renderPostflopQuestion`, `renderPostflopAnswer`, `renderPostflopComplete`
  - Field FX suppression: `body[data-postflop-active="true"] .field-fx-canvas { display: none !important; }`
  - Wiring: 1-line defensive append in `renderMastery` wrapper (line 29279) + 1-line defensive append in `renderSettings` (line 31484)
- `service-worker.js`: VERSION `'v4.0.1'` → `'v4.0.2'`

**Live browser QA result** (29-item subset of 52-item matrix):
- ✅ Loader: ready=true, scenarios=31, schema=1.0.0, getModule1Count=20, all functions exist
- ✅ Beta default off: no postflop UI when off
- ✅ Toggle on: home card appears + Settings shows beta section
- ✅ Drill flow: question→feedback→advance→summary all render
- ✅ All 4 scoring tiers verified (best=1.0/best, acceptable=0.5/acceptable, critical=0/critical+flag, bad path also exercised)
- ✅ Multi-section feedback renders all 4 expandable sections + short explanation + concept tag pills
- ✅ Summary screen: score banner + per-tier counts + 17-row concept mastery + critical leaks list
- ✅ Preflop drill regression: 5 hands played, all classified correctly, progress key created, App.postflop untouched
- ✅ All 5 tabs render after postflop session
- ✅ Settings panel: existing FX/Aura/etc. controls intact + beta toggle appended
- ✅ Console clean: only the expected `[postflop] loaded 31/31 scenarios (schema 1.0.0)` from v4.0.1 loader; zero new errors/warnings
- ✅ Field FX suppression rule present in CSS (verified via stylesheet inspection)

**Implementation note**: One bug surfaced and was fixed in-flight — `#postflopScreen` lives inside `tab-drill` panel which gets hidden when other tabs become active. Fix: `showPostflopScreen()` now activates `tab-drill` panel + hides all OTHER drill sub-screens; `exitPostflopScreen()` returns to Home tab cleanly.

### v4.0.2-data Postflop Seed Fix — committed (`473ce9a`) + pushed

Pre-implementation data hygiene pass per `postflop-v4.0.2-scenario-review.md` findings + `brief-v4.0.2-implementation-ready.md` § 16. Three fix categories applied to `postflop/postflop_scenarios.json` only:

1. **Scenario #20** (`pf_btn_v_bb_srp_100bb_flop_7d7s3c_rangeadv_001`) — replaced the leftover authoring artifact `"Trips-7 even (both have 77 — wait, 77 impossible; ..."` in `nutLogic` with a clean GTO-facing explanation covering trips-7 distribution, impossible 77, full-house combinatorics, and overpair density.
2. **Choice label hint stripping** — removed all 14 rationale parentheticals from Module 1 answer-choice labels (e.g., `"Preflop raiser (BTN) — overpairs dominate"` → `"Preflop raiser (BTN)"`). Choices now have neutral labels; reasoning belongs in `explanation` fields.
3. **#10 `sourceConfidence` downgrade** — `Qh9d6s_freq_001` changed from `consensus_gto` → `expert_judgment` (the answer depends on solver-mix interpretation; confidence overclaim risk per scenario review B1/E3). #11 (`Th8h3h_nutadv_001`) was already `expert_judgment` — no change needed.

**Audit result**: 31 scenarios · 0 errors · 0 warnings. All 16 fixes applied; verified spot-checks confirm targets corrected.

**Files modified**: `postflop/postflop_scenarios.json` only. No other surface touched.

### v4.0.2 Planning Sprint — committed (`377c844`) + pushed

### v4.0.1 Postflop Schema Loader + Audit Gate — committed (`2593e5c`) + pushed

| Change | File | Diff |
|---|---|---|
| Loader block (POSTFLOP_SCHEMA_VERSION + App.postflop init + loadPostflopData + boot setTimeout) | `index.html` | +63 lines (one fenced v4.0.1 block) |
| `postflopBeta: false` in settings defaults (App.state) + confirmReset | `index.html` | +4 lines / -2 modified |
| `appVersion: '3.8.2'` → `'4.0.1'` | `index.html` | 1 string |
| `VERSION` bump + 3 postflop paths in STATIC_ASSETS | `service-worker.js` | +5 lines / -1 modified |

**Total**: 2 files modified; 71 insertions / 3 deletions in `index.html`; 6 insertions / 2 deletions in `service-worker.js`. All within the v4.0.1 brief scope.

**QA result**: audit re-confirmed clean (31/0/0); loader logic simulated successfully (`[postflop] loaded 31/31 scenarios (schema 1.0.0)`); production data files unchanged; postflop_audit_rules.js unchanged; preflop code paths untouched.

**Not yet done**: actual browser load + console verification of `App.postflop.ready === true` (requires a human or QA Agent with browser access).

### v4.0.0 Postflop Planning Package — committed (`7849741`) + pushed

| File | Purpose | Status |
|---|---|---|
| `postflop/ARCHITECTURE.md` | Full architecture proposal + module plan + integration map | ✅ Done |
| `postflop/postflop_schema.md` | Strict schema spec + scoring + UI plan | ✅ Done |
| `postflop/postflop_taxonomy.json` | Board / suit / dynamic / advantage / sizing enums | ✅ Done |
| `postflop/postflop_concepts.json` | 24 concepts with short + long defs + cross-refs | ✅ Done |
| `postflop/postflop_scenarios.json` | 31 audited seed scenarios (20 Module 1 + 11 Module 2) | ✅ Done |
| `postflop/postflop_audit_rules.js` | 17 audit rules as pure JS functions | ✅ Done |
| `postflop/postflop_audit.html` | Self-contained browser audit viewer | ✅ Done |
| `postflop/audit-report-sample.md` | Example audit output | ✅ Done |
| `postflop/RISKS.md` | 13 risks rated by severity + mitigations | ✅ Done |

**Audit result on the seed dataset**: `31 scenarios · 0 errors · 0 warnings · 31 approved` (after fixing 2 misuses of textureTags as conceptTags during the run).

### Recent shipped versions (latest 5)

- `v3.8.2` — Viewport-Dominant Field FX (canvas with 5 animated layers)
- `v3.8.1` — Anime Battle Field FX (intensity surge + page shake)
- `v3.8.0` — Field FX pivot + lifecycle bug fix
- `v3.7.4` — Aura Identity + Premium Hierarchy + 3 new auras
- `v3.7.3` — Anime FX + Premium Hierarchy

---

## 6. Hard Guardrails

The following surfaces require explicit per-task approval to modify. **Subagents cannot touch them on their own initiative.**

| Surface | File / Concept | Why locked |
|---|---|---|
| Preflop ranges | `ranges.json` | Source of truth for the entire preflop trainer; any change cascades through SRS and stats |
| Scoring formula | `classifyAnswer()` in `index.html` (line ~11219) | Touches every drill answer; regression risk to thousands of stored SRS entries |
| SRS state | `getSRSKey()` + `updateSRS()` in `index.html` (line ~12584) | Player-progress data; backward compat critical |
| Cooldowns | Boss-fail cooldowns in `index.html` (line ~28405) | Anti-grind rule that gates progression |
| Rank progression | Rank/Level XP curves | Player progression curve already tuned |
| Chips formula | Chip grant logic in `index.html` (~line 12267 area) | Economy balance |
| Existing reward grant | `_grantCosmeticByKey()` and surrounding hooks | Cosmetic ownership integrity |
| Cosmetic ownership | `App.state.profile.owned*` arrays | Player inventory; corruption is irreversible |
| Production UI shell | `index.html`, `service-worker.js` | Single-file PWA; one bad edit breaks the live deploy |
| Manifest / PWA | `manifest.json`, icon files | PWA install behavior |

**Rule**: any task touching the above must explicitly cite the surface in its scope and pass through Orchestrator before a subagent edits it.

---

## 7. File Ownership Rules

- Every subagent has an explicit **allowed file pattern** (declared in `AGENTS.md`).
- A subagent that needs to edit a file outside its pattern must **stop and request Orchestrator escalation**.
- **No subagent except DEV Integration Agent may edit `index.html` or `service-worker.js`**, and only when Orchestrator has assigned a controlled implementation task with explicit scope.
- Multiple subagents may edit different files in parallel as long as their patterns don't overlap.
- Orchestrator is the only role that may edit `PROJECT_STATE.md`, `AGENTS.md`, `TASK_BOARD.md`.

---

## 8. Open Questions (carried forward, awaiting human input)

Tagged from `postflop/postflop_schema.md` "Open questions for review":

1. **Acceptable-score granularity** — locked to `{0.25, 0.5, 0.75}`, or allow any value in `[0, 1]`?
2. **Critical-flag UI** — flag-only in stats, or block progression / force review?
3. **ICM in v4.0** — confirm out-of-scope (chipEV-only foundation)?
4. **Hand-class enum location** — separate file, or stays inside `postflop_concepts.json`?
5. **`mixing` block format** — is `{ choiceId: freq }` enough, or richer `{ freq, ev }` per choice?

Plus, before commit:

6. **Spot-check of 3–5 sample scenarios** by a human reviewer.
7. **Approval to commit** the v4.0.0 planning package.

---

## 9. Next Recommended Step

1. ✅ Workflow files created (DEC-001, etc.).
2. ✅ v4.0.0 planning package reviewed + approved + committed (`7849741`) + pushed.
3. ✅ v4.0.1 implementation (schema loader + audit gate) staged per brief.
4. ⏸️ **Human review of staged v4.0.1 diff**, then approve the commit.
5. ⏸️ On approval: stage commit message `v4.0.1: add postflop schema loader and audit gate`; commit; await separate "push" instruction.
6. ⏸️ Resolve the 5 open questions above (or defer with explicit notes).
7. ⏸️ After v4.0.1 commit: prepare `docs/specs/brief-v4.0.2-module1-board-texture-trainer.md` (planning only — actual UI work).

---

**Maintained by**: Orchestrator Agent. Update on every state change. Do not delete entries — annotate with status.
