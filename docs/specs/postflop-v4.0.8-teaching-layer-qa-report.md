# v4.0.8 — Postflop Teaching Layer: Extended QA + UX Review

**Status:** Review only. No production code changed. No commit. No push.
**Date:** 2026-05-04
**Reviewer:** Claude (offline test simulation)
**Tester away — autonomous QA pass**

---

## 1. Executive Summary

v4.0.8 is **production-grade for the core flow**. All 26 regression checks pass on local + Netlify live. Audit clean (262/0/0). Mobile 375px renders without overflow. Postflop full-session flow + summary + repeat control + history all functional. Beta toggle correctly hides/shows postflop UI without affecting preflop systems.

**Teaching layer quality verdict**: **Good but not great.** The 5-block feedback works as designed and the pattern label / hint / takeaway helpers correctly fire on the highest-impact families (A/K-high dry, low-connected two-tone, monotone, paired_mid, broadway-connected). However, **Q/J/T-high non-paired non-monotone disconnected boards (about 30-40 scenarios) fall back to GENERIC hints + GENERIC takeaways**, which weakens teaching for nearly 1/8 of the pool. Also `low_dry_two_tone` takeaway recommends "small high-frequency c-bet" which contradicts the actual `mixed_small_check` answer for those boards.

**Recommendation**: 🟢 **Polish needed (v4.0.9), not hotfix.** Ship as-is for tester. Plan v4.0.9 to fix the 2 medium-severity teaching gaps identified below. No critical or high-severity issues found. **Safe for tester to play immediately.**

---

## 2. Deployment / Version Check

| Check | Local | Live (Netlify) |
|---|---|---|
| Service-worker `VERSION` | `v4.0.8` ✅ | `v4.0.8` ✅ |
| `appVersion` in index.html | `4.0.8` ✅ | `4.0.8` ✅ |
| `_pfPatternLabel` helper present | ✅ | ✅ (text grep confirms) |
| `pf-teach-pattern-label` CSS class present | ✅ | ✅ |
| "Board Reading Checklist" string present | ✅ | ✅ |
| Total bytes index.html | 1,510,106 | 1,510,106 ✅ identical |

**Conclusion**: Live Netlify deploy = local. Zero v4.0.7 stale UI being served. Cache-bust via service-worker VERSION change should propagate cleanly.

---

## 3. Regression QA Checklist

All 26 checks executed via local browser (Claude Preview MCP, port 8766).

### A. App baseline
| # | Check | Result |
|---|---|---|
| 1 | App loads without console errors | ✅ |
| 2 | All 5 tabs render (drill / mastery / progress / browse / settings) | ✅ |
| 3 | Settings tab populated | ✅ |
| 4 | Beta OFF hides postflop UI (no `.postflop-betalab-section`) | ✅ |
| 5 | Beta ON shows Beta Lab section | ✅ |

### B. Postflop Module 1 flow
| # | Check | Result |
|---|---|---|
| 6 | Start Board Texture Trainer | ✅ |
| 7 | Question screen renders all teaching elements | ✅ |
| 8 | Answer buttons work (`data-choice-id` delegated handler) | ✅ |
| 9 | Feedback screen renders all 5 blocks | ✅ |
| 10 | Next question advances correctly | ✅ |
| 11 | Full 15-question session can complete | ✅ (15/15 with all blocks) |
| 12 | Summary renders (score 15.0/15.0, tier counts, restart button) | ✅ |
| 13 | Exit/back works cleanly | ✅ |
| 14 | No duplicate scenarios in single session (`new Set(ids).size === 15`) | ✅ |
| 15 | localStorage history saves without throwing | ✅ (15 scenarios + 17 concepts + 1 session tracked) |
| Bonus | Repeat control: 0% overlap with previous session | ✅ (theoretical minimum) |

### C. Preflop regression
| # | Check | Result |
|---|---|---|
| 16 | Existing preflop drill still works (`startDrill('quick')` → 15-q queue, FOLD/CALL/4-BET buttons render) | ✅ |
| 17 | Boss gate / mastery UI still renders boss content | ✅ (boss strings present in mastery tab) |
| 18 | Browse ranges tab populated | ✅ |
| 19 | Wardrobe state present (`profile.wardrobe`, `profile.ownedItemIds`, `profile.cosmeticGrantHistory`) | ✅ |
| 20 | Chips display intact (`profile.chips=15`) | ✅ |

### D. Mobile (375 × 812)
| # | Check | Result |
|---|---|---|
| 21 | Mobile question screen — no horizontal overflow | ✅ |
| 22 | Mobile hint expand — no overflow | ✅ |
| 23 | Mobile feedback screen — no overflow + 4-5 blocks render | ✅ |
| 24 | Mobile answer buttons tappable (≥36px tall, ≤375px wide) | ✅ |
| 25 | Mobile summary readable | ✅ |

### E. Audit
| # | Check | Result |
|---|---|---|
| 26 | Postflop audit | ✅ **262 / 0 errors / 0 warnings** |

**Console errors throughout entire session**: 0.

**Verdict**: All 26 regression checks pass. No critical regressions from v4.0.8 introduction.

---

## 4. Teaching-Layer Review Results

The 5 components plus their derivation logic were reviewed against 30 sampled scenarios.

### Pattern Label
- **Coverage**: ~95% of scenarios get a meaningful label.
- **Issues found**:
  - **L1**: J-high disconnected dyn=3 boards (e.g., `Js9d4h`) get label "J-high board" with no qualifier (no "dry", no "wet"). Other J-high boards get "J-high dry board" or "J-high two-tone semi-dry". Visually inconsistent.
  - **OK**: Q/J/T-high two-tone correctly labeled "Q-high two-tone semi-dry", "T-high two-tone semi-dry". Broadway-connected correctly labeled "Broadway connected wet board". Low-connected two-tone correctly labeled "Low connected two-tone". Monotone correctly labeled "Low monotone board" / "A-high monotone board" etc.

### Board Reading Checklist
- **Coverage**: same static 7-item framework on every scenario.
- **Issues found**:
  - **None at v4.0.8 scope.** Working as designed.
  - **Gap (deferred)**: doesn't show derived values per board. Could become checklist with checkmarks ("High card: ✅ Ace") in v4.0.9.

### Hint
- **Coverage**: Family-specific hints fire correctly for: A-high, K-high, monotone, paired (any rank), low-connected (rainbow + two_tone), broadway-connected, A/K-high two-tone, generic two-tone.
- **Issues found**:
  - **M1 (Medium)**: Q-high, J-high, T-high disconnected NON-paired NON-monotone boards (rainbow only) fall through to **generic fallback hint**: *"Ask: how does high-card density, connectivity, and suit texture shift range and nut advantage on this board?"* This is unhelpful for ~30-40 Q/J/T-high rainbow disconnected scenarios.
  - **Verified non-spoiler**: tested hint text against `/best is|the answer is|preflop_raiser|caller is best/` — no leaks.

### Core Reason
- **Coverage**: Every scenario shows the relevant logic strand from `explanation.rangeLogic`, `explanation.nutLogic`, `explanation.sizingLogic` (whichever are populated).
- **Issues found**:
  - **M2 (Medium-Low)**: Core Reason concatenates ALL non-null logic strands. Some scenarios have all 3 populated, producing 100+ word Core Reason blocks (max observed 206 total feedback words). Could feel heavy on mobile after multiple questions.
  - **OK**: Logic-strand-to-question-type matching is correct (rangeLogic shown for range questions because the templates correctly populate only the relevant strand). I.e. there is no "irrelevant logic" leaking through.

### Takeaway
- **Coverage**: Family-specific takeaway fires correctly for: paired (any rank), monotone, low_connected_two_tone, two_tone+A/K high, low_connected rainbow, broadway_connected rainbow, A/K-high dry, low rainbow disconnected, very-wet rainbow.
- **Issues found**:
  - **M3 (Medium)**: Q/J/T-high non-paired non-monotone disconnected scenarios get the **generic fallback takeaway**: *"Focus on how high-card density, connectivity, and suit texture shift range and nut advantage on this board."* This is the same as the generic hint and provides no real lesson. Affects ~30-40 scenarios.
  - **M4 (Medium)**: `low_dry_two_tone` takeaway says *"Low disconnected boards still favor BTN because overpairs (TT-AA) dominate; small high-frequency c-bet works."* — but the actual best `sizing_family` answer for `low_dry_two_tone` boards is `mixed_small_check`, NOT range_small. **The takeaway contradicts the answer for sizing/frequency questions** on this family. Affects ~6 scenarios. Root cause: `_pfTakeawayForBoard` reuses the rainbow low-disconnected takeaway instead of having a `low_dry_two_tone` branch.

### Common Mistake
- **Coverage**: Always shown when `explanation.commonMistake` is non-empty (which is all scenarios except a few `dynamic_level` ones where mistakes don't apply).
- **Issues found**:
  - **None.** All sampled mistakes name the correct leak for their family. Wording is direct without being needlessly harsh.

---

## 5. 30-Scenario Sample Review Table

Stratified sample: 5 easy (diff 1) + 10 medium (diff 2-3, varied family/suit) + 10 hard (diff 4-5) + 5 highest-risk.

| # | id (short) | qtype | best | pattern | hint quality | takeaway quality | issue |
|---|---|---|---|---|---|---|---|
| 1 | Ah7d2s_rangeadv | ra | preflop_raiser | A-high dry board | ✅ specific | ✅ specific | none |
| 2 | Ad8s2c_rangeadv | ra | preflop_raiser | A-high dry board | ✅ | ✅ | none |
| 3 | As9d3h_rangeadv | ra | preflop_raiser | A-high dry board | ✅ | ✅ | none |
| 4 | Ah8c3d_rangeadv | ra | preflop_raiser | A-high dry board | ✅ | ✅ | none |
| 5 | Ad8h6c_freq | fs | range_small | A-high dry board | ✅ | ✅ | none |
| 6 | Ad9h2c_nutadv | na | preflop_raiser | A-high dry board | ✅ | ✅ | none |
| 7 | As9s4d_rangeadv | ra | preflop_raiser | A-high two-tone semi-dry | ✅ flush-draw hint | ✅ specific | none |
| 8 | Kh9c2d_nutadv | na | preflop_raiser | K-high dry board | ✅ | ✅ | none |
| 9 | Ks9s3d_rangeadv | ra | preflop_raiser | K-high two-tone semi-dry | ✅ | ✅ | none |
| 10 | Qh7d2s_rangeadv | ra | preflop_raiser | Q-high dry board | ⚠️ generic fallback | ⚠️ generic fallback | **M1+M3** |
| 11 | Qc9c3h_freq | fs | mixed_small_check | Q-high two-tone semi-dry | ✅ two-tone | ⚠️ generic fallback | **M3** |
| 12 | Qs8s3s_dyn | dl | semi_static | Q-high monotone board | ✅ | ✅ | none |
| 13 | Jd5s3c_freq | fs | mixed_small_check | J-high dry board | ⚠️ generic | ⚠️ generic | **M1+M3** |
| 14 | JhTh3c_freq | fs | mixed_small_check | J-high two-tone semi-dry | ✅ two-tone | ⚠️ generic | **M3** |
| 15 | Th7d2s_dyn | dl | semi_static | T-high dry board | ⚠️ generic | ⚠️ generic | **M1+M3** (less critical for dl) |
| 16 | Jh7d2s_rangeadv | ra | neutral | J-high dry board | ⚠️ generic | ⚠️ generic | **M1+M3** |
| 17 | Jd8s3c_rangeadv | ra | neutral | J-high dry board | ⚠️ generic | ⚠️ generic | **M1+M3** |
| 18 | Js9d4h_nutadv | na | neutral | **J-high board** (no qualifier) | ⚠️ generic | ⚠️ generic | **L1+M1+M3** |
| 19 | Jh6c2d_nutadv | na | neutral | J-high dry board | ⚠️ generic | ⚠️ generic | **M1+M3** |
| 20 | Jh4d2c_sizing | sf | mixed_small_check | J-high dry board | ⚠️ generic | ⚠️ generic | **M1+M3** |
| 21 | ThTd4c_rangeadv | ra | neutral | Paired middle board | ✅ paired_mid | ✅ paired-specific | none |
| 22 | 8h8d2c_sizing | sf | mixed_small_check | Paired middle board | ✅ paired_mid | ✅ paired-specific | none |
| 23 | ThTd5h_sizing | sf | mixed_small_check | Paired middle board | ✅ | ✅ | none |
| 24 | QhJsTd_nutadv | na | caller | Broadway connected wet board | ✅ broadway-specific | ✅ broadway-specific | none |
| 25 | QdJhTc_nutadv | na | caller | Broadway connected wet board | ✅ | ✅ | none |
| 26 | QcJc6d_nutadv | na | neutral | Q-high two-tone semi-dry | ✅ two-tone | ⚠️ generic | **M3** |
| 27 | 9c7c2c_nutadv | na | caller | Low monotone board | ✅ monotone (Axs aware) | ✅ monotone | none |
| 28 | TsTh6d_nutadv | na | caller | Paired middle board | ✅ paired_mid | ✅ paired-specific | none |
| 29 | 9h6h2c_rangeadv | ra | preflop_raiser | Low two-tone semi-dry | ✅ two-tone | ⚠️ contradicts sizing on this family | **M4** |
| 30 | 6h4h3s_sizing | sf | check_heavy | Low connected two-tone | ✅ best-in-class | ✅ best-in-class | none |

**Summary**:
- 16/30 (53%) scenarios are fully clean (specific hint + specific takeaway).
- 13/30 (43%) hit at least one of M1/M3 (generic Q/J/T-high handling).
- 1/30 hits M4 (low_dry_two_tone takeaway/answer mismatch on sizing).
- 1/30 hits L1 (J-high pattern label inconsistency).

---

## 6. High-Risk Family Review

### Family 1: `mid_two_tone_dry` (Q/J/T-high two-tone disconnected)
- **Status**: ✅ Pattern label correct, hint correct, core reason explicit, mistake names the leak.
- **One gap**: Takeaway is generic. **Issue M3**.
- **Risk to learner**: Low. The Core Reason ("BTN has overpairs and high cards but BB's flatting range is dense in suited middle hands…") and Common Mistake ("Auto range-small on Q/J/T two-tone is a leak; this is not an A/K-high board") together teach the right thing. The generic Takeaway is a missed reinforcement, not a misleading one.

### Family 2: `paired_mid` (T-T-x, 9-9-x, 8-8-x) nut_advantage
- **Status**: ✅ All teaching components correct. Wording uses "trips combos", "overpair density", and "full-house region" precisely. Soft-critical (no critical) applied. Neutral in acceptable.
- **Risk to learner**: Very low. This family is exemplary.

### Family 3: `low_dry_two_tone` (9-6-2, 8-4-2 type)
- **Status**: ⚠️ Pattern label correct, hint correct, core reason correct, mistake correct, **takeaway misleading on sizing/frequency questions**.
- **Concrete bug example**: `7h3h2s_freq` shows takeaway "*Low disconnected boards still favor BTN because overpairs (TT-AA) dominate; small high-frequency c-bet works.*" — but the actual best answer is `mixed_small_check`, and the actual Core Reason correctly says "Mixed small/check: bet ~33-50% with ~60% frequency. Slightly larger than rainbow low-dry because of BB's flush draws". The takeaway is internally inconsistent with the Core Reason. **Issue M4**.
- **Risk to learner**: Medium. A diligent learner will notice the takeaway saying "small high-frequency works" while Core Reason says "mixed small/check ~60% frequency". This is a credibility hit.

### Family 4: `low_connected_two_tone` (7-5-4, 6-4-3 type)
- **Status**: ✅ All teaching components excellent. Best-in-class. Hint specifically calls out the compounding draws. Takeaway captures the "straight density AND flush-draw density" insight. Mistake names the leak directly.
- **Risk to learner**: None. This family teaches well.

### Family 5: `monotone_low` and `monotone_high` nut_advantage
- **Status**: ✅ The v4.0.7 final-pass fix is in production. `9c7c2c_nutadv` Core Reason now reads: "BB can have higher made-flush density and more low suited connector coverage, but BTN still retains meaningful Axs nut-flush combos on the suited card." NOT "essentially zero nut combos". Hint asks about "made flushes already" + "nut-flush blockers" — accurate. Takeaway captures the lesson.
- **Risk to learner**: None.

---

## 7. Mobile UX Review

| Aspect | Measurement | Verdict |
|---|---|---|
| Question screen text load | ~95 words / 500 chars | Reasonable (~30-40 sec read) |
| Question screen line count | ~28 lines | Acceptable; checklist + hint collapsed by default |
| Feedback screen text load | ~145 words avg / 925 chars | Reasonable |
| Feedback screen max load | 206 words (when all 3 logic strands populate Core Reason) | **Heavy at the upper end** |
| Horizontal overflow at 375px | 0 | ✅ |
| Answer button tappable size | ≥36px tall / ≤375px wide | ✅ |
| Hint expand UX | Smooth toggle with state | ✅ |
| 5-block feedback hierarchy | Result / Pattern / Reason / Takeaway / Mistake clearly distinguishable visually | ✅ |
| Mode tag visibility | Small but readable | ✅ |

**Issues**:
- The Core Reason block can swell to 100+ words when all 3 logic strands populate. After 5+ questions, this could feel tiring on mobile. v4.0.9 should consider compaction.

---

## 8. First-Session Learner Simulation

Treating the user as someone who knows basic poker but not postflop GTO:

| Question | Verdict | Notes |
|---|---|---|
| Can they understand "range advantage"? | ✅ | Choice guide v2 has 1-line summary visible above buttons, plus expandable details |
| Can they understand "nut advantage"? | ✅ | Same — choice guide explains |
| Can they understand why board texture affects c-bet frequency? | ✅ | Pattern label + checklist + hint + takeaway align here |
| Can they learn from a wrong answer? | ✅ | Result + Core Reason + Takeaway + Common Mistake clearly teach |
| Does the UI feel like a lesson or a quiz? | ✅ Lesson | Learn Mode tag, Pattern Label, Checklist, Hint all signal teaching |
| Is the feedback too much text? | ⚠️ Borderline | Heavy scenarios (200+ words) could fatigue after 5-10 questions |
| Does mobile reading feel tiring? | ⚠️ Possibly | After 10-15 questions, scrolling through full Core Reason on each can wear |
| Would a user know what to focus on next session? | ⚠️ Partially | Per-question Takeaway exists; **session-end teaching synthesis is missing** — summary shows score + tier counts but doesn't say "you struggled on monotone" |

---

## 9. Issues Found by Severity

### Critical (production-breaking)
**None.**

### High (could harm learning)
**None.**

### Medium (worth fixing in v4.0.9)
- **M1**: Q/J/T-high disconnected non-paired non-monotone boards get **generic fallback hint**. Affects ~30 scenarios.
- **M2**: Core Reason can swell to 100+ words when all 3 logic strands populate. Mobile fatigue risk.
- **M3**: Q/J/T-high disconnected non-paired non-monotone boards get **generic fallback takeaway**. Affects ~30-40 scenarios.
- **M4**: `low_dry_two_tone` takeaway contradicts the actual `mixed_small_check` answer for sizing/frequency questions on this family. Affects ~6 scenarios.

### Low (polish only)
- **L1**: J-high disconnected `dynamic_level=3` boards get pattern label "J-high board" without "dry"/"wet" qualifier; other J-high boards get "J-high dry board". Inconsistent visual.
- **L2**: Session-end summary doesn't synthesize teaching (no "you struggled on family X").

---

## 10. Recommended Fixes for v4.0.9

Priority-ordered:

1. **Fix M1+M3 together** (highest ROI). Add Q/J/T-high disconnected branches to both `_pfHintForBoard` and `_pfTakeawayForBoard`. Concrete proposed wording in v4.0.9 brief.
2. **Fix M4**. Add `low_dry_two_tone` branch to `_pfTakeawayForBoard` that mentions "mixed sizing because BB picks up flush draws" rather than reusing the rainbow takeaway.
3. **Fix L1**. Make `_pfPatternLabel` always emit a qualifier ("J-high semi-dry board" for dyn=3 disconnected non-paired non-monotone).
4. **Address M2**. One of:
   - **Option A**: Compact-Feedback option — show only Pattern + Takeaway + Common Mistake by default; "More logic" expandable for Core Reason details.
   - **Option B**: Smarter Core Reason composition — show only the logic strand most relevant to the question type (rangeLogic for ra, nutLogic for na, sizingLogic for sf/fs).
5. **Address L2** (optional). Add a "Concept summary" row at the bottom of the summary screen — top 1-2 weakest concept tags from this session.

---

## 11. Recommendation

**🟢 Ship v4.0.8 as-is for tester. Plan v4.0.9 polish.**

Rationale:
- Zero critical or high-severity issues.
- All regression checks pass.
- 53% of sampled scenarios are fully clean (top-tier teaching).
- The 43% with generic-fallback hints/takeaways are still strategically correct in their Core Reason and Common Mistake — the teaching just isn't reinforced as well.
- The single contradiction (M4 — low_dry_two_tone takeaway vs sizing answer) affects ~6 scenarios; tester is unlikely to flag it unless they specifically draw a `_freq` or `_sizing` question on a low two-tone disconnected board.

**Action**: hand v4.0.8 to the tester. Use v4.0.9 to address M1-M4 + L1 with the fixes proposed in `brief-v4.0.9-postflop-teaching-polish.md`. No urgency — tester can play v4.0.8 today.

**Production files changed during this QA pass**: **0**. Only documentation files (this report + the v4.0.9 brief).
