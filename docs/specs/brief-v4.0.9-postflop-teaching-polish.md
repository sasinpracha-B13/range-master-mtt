# v4.0.9 — Postflop Teaching Polish (planning brief + implementation log)

**Status:** ✅ Implemented. Audit clean. Awaiting commit/push.
**Date:** 2026-05-04
**Trigger:** Issues M1, M2, M3, M4, L1 identified in v4.0.8 QA report.
**Scope:** Teaching-layer polish in `index.html` only. Same data, same answer keys, same audit, same scoring/economy. UI helper functions only.

## Implementation summary (added 2026-05-04 after planning)

All four required fixes implemented + the optional Fix M2 (smarter Core Reason composition).

| Fix | Status | Implementation |
|---|---|---|
| M1: Q/J/T-high disconnected hint | ✅ | Added Q-high specific branch + J/T-high merged branch in `_pfHintForBoard` between `if (st === 'two_tone')` and `if (hcc === 'low'...)`. |
| M3: Q/J/T-high disconnected takeaway | ✅ | Added matching branches in `_pfTakeawayForBoard` between low-disconnected and the generic fallback. |
| M4: low_dry_two_tone takeaway | ✅ | Added `if (hcc === 'low' && st === 'two_tone' && !has('highly_connected'))` branch BEFORE the rainbow low-disconnected branch in `_pfTakeawayForBoard`. New takeaway: "Low disconnected two-tone boards can still retain BTN overpair advantage, but the flush draw makes pure range-small less automatic; mixed small/check is usually safer." |
| L1: pattern label semi-wet/medium | ✅ | (a) Two-tone with `dyn>=3` now → "X two-tone medium board" (was "X two-tone semi-dry"). (b) Final fallback (rainbow disconnected non-paired non-monotone with no `dry` tag and `dyn>=3`) now returns "X semi-wet board" or "X semi-connected board" (was "X board" without qualifier). |
| M2 (optional): smart Core Reason | ✅ | New `_pfPickPrimaryLogic(qtype, explanation)` picks question-type-relevant strand (rangeLogic for ra, nutLogic for na, sizingLogic for fs/sf/dl). `_pfTeachingFeedbackBlocksHtml` shows ONLY the primary strand in Core Reason. Other strands collapsed in a "More logic strands" `<details>` block. Heavy multi-strand scenario went from ~200 words to ~80 words primary + collapsed remainder. |

## Verified post-implementation

| Test board | Pre-v4.0.9 (v4.0.8) | Post-v4.0.9 (this build) |
|---|---|---|
| Qh7d2s rangeadv | Generic hint + generic takeaway | "Ask: does BTN have more Q-x, K-x..." + "Q-high boards still favor BTN..." |
| Js9d4h nutadv | Pattern "J-high board" + generic | Pattern "J-high semi-wet board" + J/T-high specific takeaway |
| Th7d2s_dyn | Generic hint + generic takeaway | J/T-high merged hint + J/T-high takeaway |
| 9h6h2c rangeadv | Takeaway said "small high-frequency c-bet works" | "Low disconnected two-tone boards can still retain BTN overpair advantage, but the flush draw makes pure range-small less automatic; mixed small/check is usually safer." |
| 7h3h2s_freq | Pattern "Low two-tone semi-dry" | Pattern "Low two-tone medium board" (dyn=3) + corrected takeaway |
| Th9h3c | Pattern "T-high two-tone semi-dry" | Pattern "T-high two-tone medium board" |
| AhKd5d_freq_001 | Core Reason 200+ words (range + nut + sizing inline) | Core Reason 47 words (sizing primary), "More logic strands" collapsed with range + nut |
| AsAh5d_rangeadv | Core Reason had range + nut + sizing inline | Core Reason has rangeLogic only (~31 words), no "More logic" needed |
| Ah7d2s rangeadv (regression) | Unchanged baseline | Unchanged ✓ |
| 6h4h3s_sizing (regression) | low_connected_two_tone — best-in-class | Unchanged ✓ |
| TsTh6d_nutadv (regression) | paired_mid w/ neutral acceptable | Unchanged ✓ |

---

## TL;DR

v4.0.8 ships with 5 teaching components that work correctly on ~57% of scenarios. The remaining ~43% (mostly Q/J/T-high disconnected non-paired non-monotone boards, plus a few `low_dry_two_tone` scenarios) get **generic fallback hints + generic fallback takeaways** that don't teach the right principle. v4.0.9 fills these gaps in the existing helper functions (`_pfHintForBoard`, `_pfTakeawayForBoard`, `_pfPatternLabel`) without changing UI structure or data.

---

## Recommended option: **Compact Feedback Mode + Targeted Helper Fixes (Option C + targeted polish)**

Of the four options the user listed (per-board checklist values, interactive walkthrough, compact feedback, glossary), the **highest ROI for the lowest implementation risk** is:

**(a) Targeted helper-function fixes** for M1/M3/M4/L1 — surgical edits to existing `_pf*` functions.
**(b) Optional smarter Core Reason composition (M2 Option B)** — show only the question-type-relevant logic strand by default.

This combination resolves all medium-severity issues without restructuring the UI, without adding new state, and without touching data.

The other three options the user listed are deferred:
- **Per-board checklist values** (Option A): nice-to-have, but not addressing a real teaching gap. The static framework is acceptable.
- **Interactive walkthrough** (Option B): heavy implementation; better suited to a v4.1 first-time-user onboarding sprint.
- **Concept Glossary** (Option D): the existing Choice Guide v2 already provides per-question-type explanations on every screen. A separate glossary is duplicative.

---

## Detailed fix specs

### Fix 1: Q/J/T-high disconnected branches in `_pfHintForBoard` and `_pfTakeawayForBoard` (resolves M1 + M3)

**Current behavior**: any non-paired, non-monotone, non-broadway-connected, non-low-connected, non-A/K-high board falls through to:
- Hint: "Ask: how does high-card density, connectivity, and suit texture shift range and nut advantage on this board?"
- Takeaway: "Focus on how high-card density, connectivity, and suit texture shift range and nut advantage on this board."

This affects Q-high, J-high, T-high disconnected rainbow boards (e.g., Qh7d2s, Jd5s3c, Th7d2s) and also the corresponding two-tone variants for non-sizing question types. ~30-40 scenarios.

**Proposed addition** to `_pfHintForBoard`, inserted BEFORE the generic fallback:

```javascript
// Q-high disconnected (rainbow or two-tone): BTN range edge but smaller than A/K
if (hcc === 'Q_high' && !paired && st !== 'monotone') {
  return 'Ask: does BTN have more Q-x, K-x, and overpairs than BB has in the calling range? Q-high boards favor BTN but the edge is smaller than A/K-high.';
}
// J-high disconnected (rainbow): close to neutral; suited connectors hit BB's range
if (hcc === 'J_high' && !paired && st === 'rainbow') {
  return 'Ask: does BB have suited connectors and pocket pairs that connect with this J-high board (T9s, JTs, 88-TT)? J-high disconnected is closer to neutral than A/K-high.';
}
// T-high disconnected (rainbow): even closer to neutral
if (hcc === 'T_high' && !paired && st === 'rainbow') {
  return 'Ask: does BB have more T-x and pocket pairs (88-99-TT) and suited connectors than BTN? T-high boards lean toward neutral.';
}
```

**Proposed addition** to `_pfTakeawayForBoard`, inserted BEFORE the generic fallback:

```javascript
if (hcc === 'Q_high' && !paired && st !== 'monotone') {
  return 'Q-high boards still favor BTN but the edge is smaller than A/K-high; BB has more middle pairs and connectors.';
}
if ((hcc === 'J_high' || hcc === 'T_high') && !paired && st === 'rainbow') {
  return 'J/T-high disconnected boards are closer to neutral; BB\'s suited connectors and middle pairs connect well, so range betting is less automatic.';
}
```

Affects scenarios: Qh7d2s, Qd8s3c, Qh6c2d, Qs7h3d, Qh8d4c, Qh7s4d, Qs8h2c, Qh4s2d, Jd5s3c, Js8c4d, Jh4d2c, Th7d2s, Td6s3c, Th5c2d, Td7c2h, Ts4d2c, Td3s2h, Jh7d2s, Jd8s3c, Js9d4h (the J-high "neutral" ra), Jh6c2d (the J-high "neutral" na), and the corresponding J/T two-tone disconnected variants for nut_advantage.

### Fix 2: `low_dry_two_tone` takeaway branch (resolves M4)

**Current**: low_dry_two_tone boards get the rainbow low-disconnected takeaway: "*Low disconnected boards still favor BTN because overpairs (TT-AA) dominate; small high-frequency c-bet works.*" — but the actual `sizing_family` answer for these boards is `mixed_small_check`.

**Proposed addition** to `_pfTakeawayForBoard`, inserted BEFORE the generic low-disconnected branch:

```javascript
if (st === 'two_tone' && hcc === 'low' && !paired && !has('highly_connected')) {
  return 'Low disconnected two-tone boards still favor BTN because overpairs (TT-AA) dominate, but the flush draw shifts sizing to mixed small/check rather than range-betting small.';
}
```

Affects scenarios: 9h6h2c, 8s4s2d, 7h3h2s, 9d5d3c, 8c4c3s, 9d6d3s (the 6 low_dry_two_tone family boards used in the plan).

### Fix 3: J-high pattern label consistency (resolves L1)

**Current**: `_pfPatternLabel` for J-high disconnected dyn=3 hits the final fallback `hcLabel + ' board'` which yields "J-high board" with no qualifier.

**Proposed**: replace the final fallback in `_pfPatternLabel` from:
```javascript
return hcLabel + ' board';
```
to:
```javascript
// Semi-wet / semi-dry catch-all for non-paired non-monotone non-broadway-connected boards
return hcLabel + (dyn >= 3 ? ' semi-wet board' : ' semi-dry board');
```

Affects: any scenario whose pattern label currently lacks a qualifier (specifically J/T-high disconnected with dyn=3).

### Fix 4 (optional): Smarter Core Reason composition (addresses M2)

**Current**: `_pfTeachingFeedbackBlocksHtml` builds Core Reason as `rangeLogic + nutLogic + sizingLogic` concatenated, prefixed with "Range logic:" / "Nut logic:" / "Sizing logic:" labels. When all 3 strands populate, the block can hit 200+ words.

**Proposed**: pick the most relevant strand by question type; relegate the other two strands to an expandable "More logic" `<details>` block.

```javascript
function _pfPickPrimaryLogic(qtype, explanation) {
  if (qtype === 'range_advantage') return { primary: explanation.rangeLogic, label: 'Range logic' };
  if (qtype === 'nut_advantage')   return { primary: explanation.nutLogic, label: 'Nut logic' };
  if (qtype === 'sizing_family' || qtype === 'frequency_strategy') return { primary: explanation.sizingLogic, label: 'Sizing logic' };
  if (qtype === 'dynamic_level')   return { primary: explanation.sizingLogic || explanation.short, label: 'Dynamic logic' };
  return { primary: explanation.short, label: 'Short' };
}
```

Then in `_pfTeachingFeedbackBlocksHtml`, the Core Reason block uses only the primary strand. A new "More logic" block (collapsed by default) holds the remaining strands.

Effect: Core Reason drops from ~150 words avg to ~60-80 words avg. Reading load on mobile cuts roughly in half for heavy scenarios.

### Fix 5 (optional): Session-end concept summary (resolves L2)

**Current**: `renderPostflopComplete` shows score, tier counts, restart button. No teaching synthesis.

**Proposed**: existing code already does conceptTally aggregation (line ~33178+ in `index.html` based on prior reads). Add a small "Concepts to revisit" block listing the 1-2 conceptTags with the lowest accuracy this session.

Defer to v4.0.9 implementation if scope allows.

---

## Files affected (v4.0.9)

| File | Change |
|---|---|
| `index.html` | Edits in `_pfHintForBoard`, `_pfTakeawayForBoard`, `_pfPatternLabel`, optional `_pfTeachingFeedbackBlocksHtml`. Optional `renderPostflopComplete` end-of-session concept summary. |
| `service-worker.js` | VERSION bump v4.0.8 → v4.0.9. |
| `PROJECT_STATE.md`, `TASK_BOARD.md` | Status update. |
| `docs/specs/brief-v4.0.9-postflop-teaching-polish.md` | This file. |

**Untouched** (will remain): all postflop data, audit infrastructure, generator scripts, preflop systems, scoring, cosmetics.

---

## QA expected after v4.0.9

| Check | Expected |
|---|---|
| Postflop audit | 262 / 0 errors / 0 warnings (data unchanged) |
| Re-run 30-scenario sample review | 0 generic-fallback hints; 0 generic-fallback takeaways for Q/J/T-high; M4 contradiction resolved |
| Re-run heavy-feedback scenarios | Avg feedback word count drops from ~145 to ~95-100 (with optional Fix 4) |
| Mobile 375px | No new overflow |
| Beta on/off | Same behavior as v4.0.8 |
| Console | 0 errors |

---

## Estimated implementation

- **Required fixes (1-3)**: ~30 lines of JS, no CSS changes. ~30 minutes implementation + 15 min QA. Low risk.
- **Optional Fix 4 (Core Reason compaction)**: ~25 lines of JS, ~10 lines CSS for the new "More logic" `<details>` block. ~30 minutes. Low risk.
- **Optional Fix 5 (concept summary)**: ~30 lines of JS in `renderPostflopComplete`. Reads existing conceptTally. ~20 minutes. Low risk.

**Total v4.0.9 effort**: 1-2 hours implementation + 30 minutes QA. Single commit, single push.

---

## Recommendation

Implement Fixes 1, 2, 3 (required) plus Fix 4 (compact Core Reason — highest UX ROI). Defer Fix 5 to v4.1 unless the tester specifically requests session-end teaching after using v4.0.8.

**Do not implement v4.0.9 until tester has confirmed v4.0.8 reception.** The teaching gaps identified are real but not blocking. If the tester reports v4.0.8 already feels much better than v4.0.7, scope v4.0.9 conservatively (Fixes 1+2+3 only). If the tester reports remaining confusion specifically on Q/J/T boards, Fixes 1+3 directly address it. If feedback is "too much text", Fix 4 directly addresses it.
