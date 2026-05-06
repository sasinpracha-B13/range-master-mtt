# Postflop v4.2.2D — Card / Suit Notation Semantic Repair

**Status:** Production text-integrity repair after v4.2.2C. Repaired 263 scenarios (525 text-field edits across two repair passes) where the v4.2.2C mojibake cleanup over-normalized destroyed suit symbols into em-dashes, leaving semantically broken card notation like "K — K —", "A — -x", and "On A — K — 5 — ". Used context-aware reconstruction from `board.cards` + `heroHand` arrays. Added R29 audit guard rule to detect any recurrence. **Strategic fields verified 0 changes across 15-field integrity check.** appVersion + service-worker bumped to v4.2.2D.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.2C-runtime-text-encoding-hotfix.md` (the sprint that introduced this regression).

---

## 1. Root cause

v4.2.2C cleaned CP874 mojibake by replacing any contiguous run of mojibake-class characters with ` — ` (em-dash). That replacement was too aggressive. The original baseline data had two distinct mojibake sources:

1. **Em-dash separators in flowing prose** — original `—` (U+2014) inside sentences. These genuinely needed an em-dash replacement.
2. **Suit symbols in card notation** — original `♥♦♣♠` (U+2660-2666) inside hand/board references like "BTN with K♥K♠" or "On A♥K♦5♣". These should NOT have been replaced with em-dashes — they should have been replaced with the structured card text from `board.cards` / `heroHand`.

Result of the v4.2.2C blanket replacement:
- "BTN with K♥K♠" → "BTN with K — K —" (broken)
- "On A♥K♦5♣" → "On A — K — 5 —" (broken; runtime rebuilt from board.cards anyway, but data text is misleading)
- "A♥-x" (meaning "any Ace with anything") → "A — -x" (broken)
- "9♥6♥, J♣4♣" (suited combo list) → "9 — 6 — , J — 4 —" (broken)

Mojibake was eliminated, but card notation became semantically unreadable.

---

## 2. Files inspected

| File | Inspected | Mojibake? | Card notation defect? |
|---|---|---|---|
| `postflop/postflop_scenarios.json` | yes | 0 | **YES — 263 scenarios affected** |
| `ranges.json` | yes | 0 | NO (only 8 position labels touched in v4.2.2C; clean prose, no card notation in those lines) |
| `index.html` | yes | runtime fix from v4.2.2C in place | NO |
| `service-worker.js` | yes | n/a | n/a |
| `tools/audit-postflop-ps.ps1` | yes | n/a | extended in this sprint with R29 guard |
| `tools/audit-postflop-module2-seed.ps1` | yes (read-only) | n/a | not modified |
| `tools/audit-postflop-module3-seed.ps1` | yes (read-only) | n/a | not modified |

---

## 3. Invalid patterns found (before v4.2.2D repair)

| Pattern | Count |
|---|---:|
| `[Rank] — -x` / `[Rank] — -X` (suit destroyed in "any-X" notation) | 6 |
| `[Rank] — [Rank] —` (consecutive cards with destroyed suits — the most common defect) | 281 |
| `On [Rank] — [Rank] — [Rank] —` (board reference in prompts) | 253 |
| `BTN with [Rank] — [Rank] —` (hero hand reference) | 11 |
| `[Card][suit] — ,` and `[Card][suit] — )` and `[Card][suit] — ?` (trailing residual after card prompts) | 188 + 3 + handful |
| Total em-dashes pre-repair | 1022 |

After repair: total em-dashes = **186** (the legitimate sentence-punctuation usages). All 4 suspicious-pattern categories: **0**.

---

## 4. Valid em-dash patterns preserved

The repair was deliberately **context-aware**. Em-dashes used as legitimate sentence punctuation were untouched. Examples preserved:

- Mid-sentence aside: "They don't — sets of 5 are rare in both ranges"
- Mid-sentence aside: "K9s+, KJo+ — many cards that connect with A or K"
- Numeric range: "BTN c-betting only ~25 — 35% of range here"
- Conditional clause: "BTN's range — slight edge"

**Heuristic:** em-dash between two lowercase letters / words / digits = legitimate punctuation, KEEP. Em-dash between/after card ranks (A K Q J T 2-9) = damaged suit symbol, REPAIR.

The new R29 audit guard distinguishes these cases by pattern matching (see §11).

---

## 5. Repair method

Two-pass `.tmp-repair-notation.ps1` script (removed after run) performed targeted, context-aware substitutions:

### Pass 1 — Six pattern-specific replacements per scenario

For each scenario, used `scenario.board.cards` and `scenario.heroHand` arrays to reconstruct meaning:

| Pattern detected | Replacement strategy |
|---|---|
| `[Rank] — -[xX]` | `[Rank]-[xX]` (collapses to canonical "any-Rank-with-anything" notation) |
| `BTN with [Rank] — [Rank] — ` | `BTN with [heroHand text]` using `scenario.heroHand` (e.g., `BTN with KhKs`) |
| `On [Rank] — [Rank] — [Rank] — ` | `On [boardText]` using `scenario.board.cards` (e.g., `On Ah Kd 5c`) |
| `[Rank] — [Rank] —` (standalone, in lists) | `[Rank][Rank]s` (suited shorthand for combo references like "96s, J4s") |
| `[Rank] — [,)\.]` | `[Rank][punctuation]` (trailing residual) |
| `[Rank] — [a-z]` | `[Rank]-[a-z]` (lowercase-following residual, treated as hyphen-prefix) |

### Pass 2 — Trailing residual cleanup after the rebuilt board prompts

After Pass 1 reconstructed prompts like "On Ah Kd 5c — , who has nut advantage?", a second pass cleaned the lingering ` — ` between the rebuilt card text and punctuation:

| Pattern | Replacement |
|---|---|
| `[Card][suit] — ,` | `[Card][suit],` |
| `[Card][suit] — )` | `[Card][suit] )` (kept space before paren for readability) |
| `[Card][suit] — ?` | `[Card][suit]?` |
| `[Card][suit] — ` (trailing whitespace + dash) | `[Card][suit]` |

Pass 2 cleaned 251 additional residual instances.

**Total: 525 text-field edits across 263 scenarios.**

---

## 6. Number of scenarios / fields touched

| Metric | Value |
|---|---:|
| Scenarios with at least one repair | **263** of 300 |
| Scenarios untouched | 37 (all v4.0.7+ generated scenarios that had clean text from the start) |
| Total text-field edits (pass 1 + pass 2) | **525** |
| Strategic field changes | **0** (verified per §8) |
| Scenario count change | 0 (still 300) |
| Module count change | 0 (251 M1 + 49 M2 + 0 M3) |
| auditStatus changes | 0 (all 300 still `approved`) |

---

## 7. Sample before / after

### M1 board reference

**Before (v4.2.2C state):**
> "prompt": "On A — K — 5 — (BTN open vs BB call, 100BB SRP), who has range advantage?"

**After (v4.2.2D):**
> "prompt": "On Ah Kd 5c (BTN open vs BB call, 100BB SRP), who has range advantage?"

Reconstructed from `scenario.board.cards = ["Ah","Kd","5c"]`.

### M1 commonMistake (em-dash punctuation preserved)

**Before:**
> "Some players answer 'neutral' assuming pocket pairs and connectors balance things out. They don't — sets of 5 are rare in both ranges..."

**After:**
> "Some players answer 'neutral' assuming pocket pairs and connectors balance things out. They don't — sets of 5 are rare in both ranges..."

Identical. The em-dash here is sentence punctuation, not a damaged suit symbol — correctly left alone.

### M1 nut-advantage prompt

**Before:**
> "On K — T — 2 — , who has nut advantage?"

**After:**
> "On Kh Td 2s, who has nut advantage?"

### Suit-blocker reference inside text

**Before:**
> "BTN holds A — -X for nut flush blockers"

**After:**
> "BTN holds A-X for nut flush blockers"

### Suited combo list

**Before:**
> "made flush combos (e.g., 9 — 6 — , J — 4 — if in flatting range)"

**After:**
> "made flush combos (e.g., 96s, J4s if in flatting range)"

(The "s" suffix is suited shorthand — readable and unambiguous in poker notation.)

### M2 hero hand prompt

**Before (v4.2.2C state, only one of the 11 affected):**
> "BTN with K — K — on 6 — 5 — 4 — . Action?"

**After:**
> "BTN with KhKs on 6c 5c 4s . Action?"

(Reconstructed from `heroHand = ["Kh","Ks"]` and `board.cards = ["6c","5c","4s"]`.)

---

## 8. Strategic fields untouched verification

Per-scenario object-by-object diff comparing HEAD (pre-v4.2.2D) vs working tree (post-v4.2.2D) across 15 strategic fields:

| Field | Changes |
|---|---:|
| `id` | **0** |
| `module` | **0** |
| `auditStatus` | **0** |
| `sourceConfidence` | **0** |
| `recommendedAction` | **0** |
| `actionReason` | **0** |
| `answer.best` | **0** |
| `answer.acceptable` | **0** |
| `answer.bad` | **0** |
| `answer.critical` | **0** |
| `conceptTags` | **0** |
| `handClass` | **0** |
| `heroHandRole` | **0** |
| `drawCategory` | **0** |
| `showdownValue` | **0** |

**Verified by independent PowerShell pre/post comparison loop.** Only text fields (`question.prompt`, `explanation.*`, `blockerNote`) were modified.

---

## 9. Audit results

| Audit | Pre-v4.2.2D | Post-v4.2.2D | Status |
|---|---|---|---|
| Production audit | 300 / 0 / 0 | **300 / 0 / 0** | ✅ unchanged |
| M2 seed audit | 24 PASS / 0 hard / 8 warnings | **24 PASS / 0 hard / 8 warnings** | ✅ unchanged |
| M3 seed audit | 24 / 0 hard / 0 warnings | **24 / 0 hard / 0 warnings** | ✅ unchanged |
| New R29 (card-notation guard) | n/a | 0 warnings (data is clean) | ✅ defensive guard active |

---

## 10. Text-integrity post-check

Final scan across `postflop/postflop_scenarios.json`:

| Pattern | Count |
|---|---:|
| Thai-range mojibake (U+0E00-U+0E7F) | **0** |
| Replacement char (`�`) | **0** |
| `[Rank] — -[xX]` | **0** |
| `[Rank] — [Rank] —` | **0** |
| `BTN with [Rank] — [Rank]` | **0** |
| `On [Rank] — [Rank] — [Rank] —` | **0** |
| `[Card][suit] — [,.\)]` (trailing residual) | **0** |
| Legitimate em-dash punctuation count | 186 (preserved) |

Cross-verified at runtime via Claude Preview MCP browser session — `App.postflop.scenarios` (300 scenarios) shows 0 Thai mojibake and 0 suspicious card-notation patterns; sample DOM render shows clean prompts and clean explanation prose.

---

## 11. R29 audit guard rule (added in this sprint)

Added to `tools/audit-postflop-ps.ps1` as a **warning-only** rule (does not break production audit; surfaces regressions early). Detects three suspicious card-notation patterns inside text fields:

| Pattern name | Regex |
|---|---|
| `rank_dash_dash_x` | `[AKQJT2-9]\s+—\s+-[xX]` |
| `rank_dash_rank_dash` | `[AKQJT2-9]\s+—\s+[AKQJT2-9]\s+—` |
| `btn_with_dash_pair` | `BTN with [AKQJT2-9]\s+—\s+[AKQJT2-9]` |

Scans `question.prompt`, all `explanation.*` text fields, and `blockerNote`. Em-dashes used as legitimate sentence punctuation (between lowercase words) are NOT flagged.

If a future cleanup or seed authoring slip-up reintroduces these patterns, the R29 warning fires immediately during the regular production audit run, preventing the defect from shipping silently.

---

## 12. Cache / version bump

| Field | Pre | Post |
|---|---|---|
| `index.html` `appVersion` | `'4.2.2C'` | `'4.2.2D'` |
| `service-worker.js` `VERSION` | `'v4.2.2C'` | `'v4.2.2D'` |

Forces cache invalidation so the repaired data + R29 audit guard ship together. No runtime UI logic changed in this sprint.

---

## 13. Recommendation for v4.2.3

**v4.2.3 (Module 3 Migration to Production Data) can now safely resume.** All preconditions met:
- Production data text is semantically clean (mojibake-free + card-notation-correct).
- Strategy fields verified untouched (no risk of accidental regression in answer keys or scenario classifications).
- Production audit gate solid at 300 / 0 / 0.
- R29 guard rule will catch any recurrence of the v4.2.2C-style over-normalization in future sprints (including v4.2.3 migration).
- M3 seed JSON (24 / v4.2.0_final) untouched and ready.
- v4.2.2B Path A migration decision still in force.

**Suggested sprint sequence:**
1. **v4.2.3** — Migrate 24 M3 seeds to production (300 → 324 scenarios). Add 7 M3 concepts + 2 heroHandRole values + 1 actionReason to vocabulary files. Extend production auditor with R29-R40 (Note: R29 is now taken by the card-notation guard, so M3 production rules should start at R30 or rename M3 audit-plan rules).
2. **v4.2.3A (optional but recommended)** — Module 3 data expansion (24 → 40-60 scenarios) targeting concept-depth gaps before playable beta.
3. **v4.2.4** — Module 3 playable beta runtime wire (Limited Beta if v4.2.3A skipped).

**Heads-up for v4.2.3:** the new R29 rule in `tools/audit-postflop-ps.ps1` occupies the rule-number slot that the M3 audit-plan reserved. v4.2.3 should renumber M3 production rules to R30-R41 (or add the M3 ones in a new range like R50+) to avoid collision. Update `postflop-v4.2.0-module3-audit-plan.md` accordingly.

---

## 14. Sign-off

**Card and suit notation in production data is now semantically correct. Em-dashes only appear as legitimate sentence punctuation. Card references like "BTN with KhKs on 6c 5c 4s" read naturally. Suit-blocker shorthand like "A-X for nut flush blockers" is canonical. Suited-combo lists like "96s, J4s" use standard poker notation. R29 guard rule prevents recurrence.**

**v4.2.2D deliberately did NOT:**
- Productionize Module 3 (still planning-only).
- Change any answer key, recommendedAction, actionReason, conceptTags, auditStatus, or sourceConfidence.
- Modify ranges.json (already clean from v4.2.2C).
- Modify any preflop, gamification, or shop logic.
- Touch the M2 seed auditor or M3 seed auditor.
- Change runtime UI logic (only appVersion + SW VERSION bumped for cache invalidation).
- Start v4.2.3 migration.
