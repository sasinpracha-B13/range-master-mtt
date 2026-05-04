# v4.0.8 — Postflop Teaching Layer (brief)

**Status:** Implemented + QA'd live in browser.
**Date:** 2026-05-04
**Scope:** Module 1 (Board Texture Trainer) UI only. No data changes, no answer-key changes, no scoring/economy changes, no Module 2 work.

## Why

After v4.0.7 (Module 1 expanded to 251 scenarios), human tester reported:

> "I can play it now, but I do not understand the principles behind the answers."

The app was asking questions but not teaching the underlying board-reading framework. Players needed to learn **how to think**, not just **whether they were right**.

## What was added (5 teaching components)

### 1. Pattern Label
A short human-readable header above each board: e.g. "🎯 J-high two-tone semi-dry" with meta-line "two_tone · disconnected · semi-static". Derived from `board.highCardClass`, `board.suitTexture`, `board.textureTags`, `board.pairedStatus`, `board.dynamicLevel` via new `_pfPatternLabel(board)` helper. No data schema changes.

### 2. Board Reading Checklist
Collapsible 7-item educational framework, same for every scenario (teaches the reading process, not the answer):
1. High card: A / K / Q / J / T / low?
2. Texture: dry / semi-dry / wet?
3. Connectivity: disconnected / connected / very connected?
4. Suit: rainbow / two-tone / monotone?
5. Who has range advantage?
6. Who has nut advantage?
7. What does that imply for c-bet frequency / sizing?

### 3. Pre-answer Hint
"💭 Need a hint?" button reveals a non-spoiler thinking-prompt based on board family. Examples:
- A-high dry: "Ask: does BTN have more A-x or K-x combos than BB has in the calling range?"
- Low connected two-tone: "Ask: does BB have BOTH straight density AND flush-draw density?"
- Monotone: "Ask: who has more made flushes already, and who has the nut-flush blockers?"
- Paired mid: "Ask: does BB have more trips combos with the paired rank? And does BTN overpair density (JJ-AA) compensate?"

Hints never directly state the answer.

### 4. 5-block Feedback Layout
Restructured `renderPostflopAnswer` into clear sections:
- **A. Result** — your pick, GTO best, tier, score (existing)
- **B. Board Pattern** — pattern label + meta
- **C. Core Reason** — concatenated rangeLogic + nutLogic + sizingLogic from existing `explanation`
- **D. 💡 Takeaway** — one-sentence generalizable lesson (highlighted blue)
- **E. ⚠️ Common Mistake** — existing `explanation.commonMistake` (highlighted red, only shown if non-empty)

Replaces the previous separate `<details>` per logic strand — same content surfaced more readably.

### 5. Takeaway Generator
`_pfTakeawayForBoard(board)` produces a one-sentence lesson based on board family. Examples:
- "High-card dry boards usually favor BTN because the raiser has more top-pair and overpair density."
- "Low connected two-tone boards are dangerous for BTN: BB has straight density AND flush-draw density combined."
- "Monotone boards require caution because made flushes and nut-flush blockers matter more than simple top-pair advantage."

### 6. Mode tag (small copy)
"LEARN MODE · EXPLANATIONS ENABLED" pill above the spot card. No mode switch yet — full Test Mode reserved for v4.0.9 if needed.

## How it's wired

All new code is additive in a single fenced v4.0.8 block:
- **CSS** (~150 lines, all `.pf-teach-*` namespaced) inserted just before `</style>` after the v4.0.6 block.
- **JS helpers** (~200 lines) inserted just before `_pfChoiceGuide`. Helpers: `_pfPatternLabel`, `_pfBoardMetaLine`, `_pfHintForBoard`, `_pfTakeawayForBoard`, `_pfBoardChecklistHtml`, `_pfPatternLabelHtml`, `_pfHintRowHtml`, `_pfTeachingToggleHint`, `_pfTeachingFeedbackBlocksHtml`. Each is a pure function reading scenario fields.
- **renderPostflopQuestion** modified to insert: mode tag, pattern label inside the board card, checklist inside the board card, hint row above choices.
- **renderPostflopAnswer** modified to call `_pfTeachingFeedbackBlocksHtml(scenario)` for blocks B/C/D/E. The previous per-strand `<details>` sections (rangeLogic / nutLogic / handLogic / sizingLogic) are no longer rendered — same content lives in Core Reason. `commonMistake` lives in block E only (no double-display).

## QA results (all pass)

- ✅ Postflop audit: 262 / 0 / 0 (data unchanged)
- ✅ Module 1 loads (251 scenarios)
- ✅ All 8 teaching helpers loaded
- ✅ Beta OFF: postflop screen hidden, no Beta Lab section
- ✅ Beta ON: question screen shows pattern label + checklist + hint button + mode tag
- ✅ Hint toggles open/close; does NOT leak the answer
- ✅ Choice click → feedback screen renders with all 5 blocks (Result / Board Pattern / Core Reason / Takeaway / Common Mistake)
- ✅ Pattern label and takeaway match board family across all 5 sample classes (A-high dry, low connected two-tone, low monotone, paired mid, broadway connected)
- ✅ Mobile 375px: no horizontal overflow; pattern label, checklist, hint, all blocks render cleanly
- ✅ All 5 tabs (drill / mastery / progress / browse / settings) render
- ✅ Preflop drill functions still defined; postflop and preflop independent
- ✅ Console clean — 0 errors / 0 warnings

## Files changed

- `index.html` — CSS block + JS helpers + 2 render-fn modifications + appVersion bump (4.0.6 → 4.0.8)
- `service-worker.js` — VERSION bump (v4.0.7 → v4.0.8) for cache-bust
- `PROJECT_STATE.md` — section update
- `TASK_BOARD.md` — status row + recently completed
- `docs/specs/brief-v4.0.8-postflop-teaching-layer.md` — this file

**Untouched** (verified): `ranges.json`, `manifest.json`, `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`, `tools/audit-postflop.js`, all postflop/*.json data files, all postflop/*.ps1 generators.

## Remaining teaching gaps (v4.0.9+ candidates)

1. **No per-board specific checklist values.** The checklist is the same static framework for every scenario. v4.0.9 could derive checklist answers (e.g., "High card: ✅ Ace") from the board fields when the question doesn't ask about that field.
2. **No Test Mode toggle.** Currently always Learn Mode. A future Test Mode would hide hints, pattern labels, and detailed reason blocks — useful for self-assessment.
3. **No teaching for Module 2 (Flop C-bet IP).** This patch is Module 1 only. Module 2 has different question types (action_choice) and would need its own teaching templates.
4. **Pattern label is rule-based, not solver-derived.** Captures broad family but might call a borderline board the "wrong" name. E.g. T98 two-tone is currently labeled "Low connected two-tone" because top card is below J — defensible but a different reviewer might prefer "Broadway connected wet board".
5. **No interactive walkthrough for first-session users.** Could add a 1-question guided tutorial that walks through the checklist step-by-step.
