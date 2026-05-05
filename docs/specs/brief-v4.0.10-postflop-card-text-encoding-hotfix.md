# v4.0.10 — Postflop Card Text Encoding Hotfix

**Status:** ✅ Implemented + verified live. Awaiting commit/push.
**Date:** 2026-05-04
**Trigger:** Human tester reported broken suit characters in Postflop Module 1 question text.

---

## Root cause

The v4.0.0 baseline scenarios in `postflop/postflop_scenarios.json` have **CP874 (Thai Windows) → UTF-8 mojibake** in `question.prompt` AND `explanation.*` fields. At some point during authoring/round-tripping the file was decoded as CP874 then re-encoded as UTF-8, splitting each multi-byte UTF-8 char into 2-3 separate Thai/Latin codepoints.

### Concrete corruption pattern

| Original char | Original UTF-8 bytes | After CP874 decode + UTF-8 encode | What user sees |
|---|---|---|---|
| `♥` (U+2665) | `E2 99 A5` | U+0E42 + U+0099 + U+0E05 | `โฅ` |
| `♦` (U+2666) | `E2 99 A6` | U+0E42 + U+0099 + U+0E06 | `โฆ` |
| `♠` (U+2660) | `E2 99 A0` | U+0E42 + U+0099 + U+00A0 | `โ ` |
| `♣` (U+2663) | `E2 99 A3` | U+0E42 + U+0099 + U+0E03 | `โฃ` |
| `—` (U+2014) | `E2 80 94` | U+0E42 + U+20AC + U+201D | `โ€"` |

All bytes 0xE2 in any 3-byte UTF-8 sequence become U+0E42 (Thai O Ang) because CP874 maps 0xE2→U+0E42. Continuation bytes 80-9F map to undefined (passing through as U+0080-U+009F controls) or to specific symbols (€, "), and A0-FA map to Thai range.

### Scope of corruption

- **31 baseline scenarios** (v4.0.0 seed, ids ending in `_001`/`_002`/etc.) all have mojibake in `question.prompt` and most `explanation.*` fields.
- **220 v4.0.7-generated scenarios** (ids ending in `_v407`) are clean (PowerShell generator wrote correct UTF-8 bytes).
- **`board.cards`** is clean ASCII (`"Ah"`, `"Kd"`, `"5c"`) on all scenarios — that's why card graphics render correctly.

User instruction: do NOT change postflop data. So fix at render time.

---

## Fix implemented

Added 7 new helpers in `index.html` under a fenced "v4.0.10 — POSTFLOP CARD TEXT ENCODING HOTFIX" block right after `_pfSuitChar`:

1. **`_pfCardText(card)`** — converts `"6c"` → `"6♣"` using `_pfSuitChar`.
2. **`_pfBoardText(cards)`** — converts `["6c","5c","4s"]` → `"6♣ 5♣ 4♠"`.
3. **`_pfBuildQuestionPrompt(scenario)`** — reconstructs the full prompt sentence from `board.cards` + `question.type` (range_advantage / nut_advantage / frequency_strategy / sizing_family / dynamic_level / action_choice). Uses clean suit chars from JS source.
4. **`_pfCp874ToByte`** map — reverse of CP874 byte→codepoint for non-Thai range (€, ', ", —, etc.).
5. **`_pfThaiCpToByte(cp)`** — reverse of CP874 byte→Thai codepoint for U+0E01..U+0E5B range.
6. **`_pfMaybeMojibakeByte(cp)`** — returns the original CP874 byte for a given codepoint, or `null` if the codepoint isn't a recognized mojibake source.
7. **`_pfFixMojibake(text)`** — walks input text char by char. Codepoints that look like CP874 mojibake accumulate as bytes; ASCII chars / unrecognized chars trigger a flush via `TextDecoder('utf-8', {fatal:true})`. Failed decodes fall back to original chars (so real Thai text or other valid Unicode passes through unchanged).

### Render-path rewires

| Site | Before | After |
|---|---|---|
| `renderPostflopQuestion` line ~33618 (question prompt) | `_pfEscape(question.prompt \|\| '')` | `_pfEscape(_pfBuildQuestionPrompt(scenario))` |
| `_pfTeachingFeedbackBlocksHtml` Core Reason primary | `_pfEscape(pick.primary.text)` | `_pfEscape(_pfFixMojibake(pick.primary.text))` |
| `_pfTeachingFeedbackBlocksHtml` Core Reason fallback | `_pfEscape(explanation.short)` | `_pfEscape(_pfFixMojibake(explanation.short))` |
| `_pfTeachingFeedbackBlocksHtml` More logic secondary | `_pfEscape(s.text)` | `_pfEscape(_pfFixMojibake(s.text))` |
| `_pfTeachingFeedbackBlocksHtml` Common Mistake | `_pfEscape(explanation.commonMistake)` | `_pfEscape(_pfFixMojibake(explanation.commonMistake))` |
| `renderPostflopAnswer` short-explain row | `_pfEscape(explanation.short)` | `_pfEscape(_pfFixMojibake(explanation.short))` |

Pattern label, hint, takeaway, choice-guide, summary — none use the corrupted fields, so unchanged.

---

## Before / after examples (live verified)

### Question text

**Required test cases**:

| Cards | Before (data) | After (rendered) |
|---|---|---|
| `Ah Kd 5c` | `On Aโฅ Kโฆ 5โฃ ...` | `On A♥ K♦ 5♣ ...` ✓ |
| `6c 5c 4s` | (v407 already clean) | `On 6♣ 5♣ 4♠ ...` ✓ |
| `7d 7s 3c` | (depends on baseline vs v407) | `On 7♦ 7♠ 3♣ ...` ✓ |
| `Jh Td 9s` (mixed h/d/s) | varies | `On J♥ T♦ 9♠ ...` ✓ |
| `Qc 8h 3d` (mixed c/h/d) | varies | `On Q♣ 8♥ 3♦ ...` ✓ |

### Explanation text (Common Mistake from `AhKd5c_rangeadv_001`)

| | Text | Codepoints (non-ASCII) |
|---|---|---|
| Before | `s out. They don't โ€" sets of 5 are rare in both r` | U+0E42 U+20AC U+201D |
| After | `s out. They don't — sets of 5 are rare in both ran` | U+2014 (em-dash) ✓ |

### Range Logic from same scenario

| | Text | Codepoints |
|---|---|---|
| Before | `+, KJo+ โ€" many cards that connect with A or K. B` | U+0E42 U+20AC U+201D |
| After | `+, KJo+ — many cards that connect with A or K. BB` | U+2014 ✓ |

---

## QA result

| # | Check | Result |
|---|---|---|
| 1 | Postflop audit 262 / 0 / 0 (data unchanged) | ✅ |
| 2 | Module 1 loads + 5 helpers loaded | ✅ |
| 3 | Question text renders clean suits on `6c 5c 4s`, `Ah Kd 5c`, `7d 7s 3c`, mixed h/d/s/c | ✅ |
| 4 | Zero mojibake codepoints (U+0E42, U+0099, U+0E05, U+0E06, U+0E03, U+20AC, U+201D) in rendered question OR feedback text | ✅ |
| 5 | Card graphics still render correctly (boardCardSuits = `[♥, ♦, ♣]`) | ✅ |
| 6 | Feedback screen all 5 blocks render (Result / Pattern / Reason / Takeaway / Mistake) on baseline corrupted scenario | ✅ |
| 7 | Em-dash recovery works in rangeLogic + commonMistake (CP874 reverse decode) | ✅ |
| 8 | Console: 0 errors throughout reload + render path | ✅ |
| 9 | All forbidden files clean (data, audit infra, generators, ranges, manifest) | ✅ |
| 10 | service-worker diff is solely `v4.0.9` → `v4.0.10` | ✅ |

---

## Files changed

| File | Change |
|---|---|
| `index.html` | New v4.0.10 helper block (~70 lines): `_pfCardText`, `_pfBoardText`, `_pfBuildQuestionPrompt`, `_pfCp874ToByte` map, `_pfThaiCpToByte`, `_pfMaybeMojibakeByte`, `_pfFixMojibake`. Render-path rewires in `renderPostflopQuestion` (1 line), `_pfTeachingFeedbackBlocksHtml` (4 sites), `renderPostflopAnswer` (1 site). appVersion bump 4.0.9 → 4.0.10. |
| `service-worker.js` | VERSION v4.0.9 → v4.0.10 (cache-bust) |
| `PROJECT_STATE.md`, `TASK_BOARD.md` | Status update |
| `docs/specs/brief-v4.0.10-postflop-card-text-encoding-hotfix.md` | This file (NEW) |

**Untouched** (verified clean): `ranges.json`, `manifest.json`, all postflop data files, audit infrastructure, generator scripts, preflop systems, scoring, cosmetics.

No data file edits. No answer-key edits. No scenario regeneration.

---

## Why not fix the data?

Three reasons not to edit `postflop/postflop_scenarios.json`:

1. **User instruction**: "Do NOT change postflop data."
2. **Risk**: A bulk find-and-replace on 31 baseline scenarios could miss edge cases or introduce new corruption. Render-time fix is safer.
3. **Forward compatibility**: If anyone else round-trips the file through PowerShell on Windows-Thai locale in the future, the bug will reappear. Render-time fix is robust against this.

A future v4.1 data-cleanup pass could optionally rewrite the file with clean UTF-8 (then the render-time fix becomes a no-op). Until then, the helper protects against the corruption.

---

## Future considerations

- **`_pfFixMojibake` is opt-in per render site.** If a future render path adds new explanation-text rendering, it must use `_pfFixMojibake` to stay corruption-safe. The new helpers are namespaced under `_pf*` for discoverability.
- **The dead `sections` array in `renderPostflopAnswer`** (~lines 33721-33734) still uses raw `_pfEscape(explanation.X)` without mojibake fix. It's currently unused (was replaced by `_pfTeachingFeedbackBlocksHtml` in v4.0.8) but if anyone re-enables it, they should add `_pfFixMojibake`.
- **Performance**: `_pfFixMojibake` runs on every render. For typical scenario text (< 500 chars), this is sub-millisecond and not a concern.
