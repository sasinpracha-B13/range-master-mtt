# Postflop v4.2.3A — Module 3 Data Expansion

**Status:** Implemented and shipped.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.3-module3-migration.md`, `postflop-v4.2.0-module3-architecture.md`, `postflop-v4.2.0-module3-schema-taxonomy.md`
**Builds on:** v4.2.3 (Module 3 Migration to Production Data, commit `e718f07`)

---

## 1. Goal

Expand Module 3 (Facing C-bet OOP) production data from the v4.2.3 baseline of 24 scenarios toward a **Limited Beta-quality content base** (target: 50–60 minimum, 60–80 preferred) before any v4.2.4 runtime wire.

**Critical constraint preserved:** Module 3 must remain NOT runtime-wired. TRAINING_MODES.postflop.actions.m3 stays `kind: 'preview'`, `route: null`. No drill engine activation. This sprint is data-only expansion plus uniqueness/quality discipline.

---

## 2. Volume gates

| Gate | v4.2.3 (before) | v4.2.3A (after) |
|---|---|---|
| Total production scenarios | 324 | **362** (+38) |
| Module 1 (pf_board_texture) | 251 | 251 (unchanged) |
| Module 2 (pf_flop_cbet_ip) | 49 | 49 (unchanged) |
| Module 3 (pf_flop_cbet_oop_def) | 24 | **62** (+38, 2.6x) |
| Distinct M3 board families | 6 | **14** (+8) |
| Production audit result | 324 / 0 / 0 | **362 / 0 / 0** |
| R29 card-notation guard | 0 warnings | **0 warnings** (preserved) |
| M2 seed audit | PASS (8 warnings) | PASS (8 warnings) |
| M3 seed audit | PASS clean (24/0/0) | PASS clean (24/0/0) — seed file unchanged |

---

## 3. New board families added (8)

Each family contributes 4–5 scenarios chosen to fill specific coverage gaps. Each scenario carries a `uniquenessNote` documenting the new strategic dimension it adds.

| # | Board | Family | Scenarios | rangeAdv | Key new lessons |
|---|---|---|---|---|---|
| 1 | As 9s 4d | A-high two-tone dry | 5 | preflop_raiser | Top two two-tone protection, TPGK + BDFD, mid-pair pot-odds defense, FD + overcards realization, dry overcards fold |
| 2 | Ks 8s 3d | K-high two-tone dry | 5 | preflop_raiser | Mid pair + BDFD, naked low FD, **NUT-FD semi-bluff with blocker** (first nut_flush_draw in M3), TPGK protection (vs rainbow K-high call), QJ domination |
| 3 | Qs Ts 6d | Q-high two-tone dynamic | 5 | split | KsJs combo draw 15 outs, top two value+protection, FD+gutshot float, AK BDFD pot-odds, bottom gutshot fold |
| 4 | 7s 5s 3s | Low monotone | 5 | caller | A-blocker bluff-catch, made middle flush, mid-pair-no-spade pot-odds fold, KQ-no-spade automatic fold, **AsKh blocker_raise reason_choice** (first blocker_raise in M3) |
| 5 | 8c 8d 3s | Paired low rainbow | 5 | caller | **Trips slowplay**, underpair bluff-catch, AK A-blocker bluff-catch, T9+BDFD pot-odds defense, QJ no-equity fold |
| 6 | 9d 8c 6h | Low semi-connected rainbow | 5 | caller | Top set protection, two-pair value+protection, OE+BDFD semi-bluff reason_choice, JT OESD realization, AQ no-equity fold |
| 7 | Tc Th 6s | Paired T rainbow | 4 | split | **Trips weak-kicker slowplay**, bottom-pair BDFD bluff-catch, AK no-draw bluff-catch, underpair bluff-catch |
| 8 | 6c 3d 2h | Very dry low rag rainbow | 4 | preflop_raiser | OESD+BDFD pot-odds defense, top set value, **AA overpair value-raise** (vs slowplay temptation), KQ no-equity fold |

**Total:** 38 new scenarios across 8 new boards. M3 grows from 24 → 62.

---

## 4. Coverage improvements (before → after)

### 4.1 actionReason coverage

| actionReason | v4.2.3 | v4.2.3A | Change |
|---|---:|---:|---|
| equity_realization_call | 8 | **19** | +11 ✓ |
| range_disadvantage_fold | 5 | **12** | +7 ✓ |
| value_raise | 4 | **10** | +6 ✓ |
| **bluff_catch** | 2 | **7** | +5 ✓ (3.5x) |
| semi_bluff_raise | 2 | **5** | +3 ✓ |
| **slowplay_call** | 1 | **3** | +2 ✓ (3x) |
| **protection_raise** | 1 | **3** | +2 ✓ (3x) |
| **domination_fold** | 1 | **2** | +1 |
| **blocker_raise** | **0** | **1** | +1 ✓ (introduced) |

All 9 M3 reasons now represented. Previously-zero `blocker_raise` is now demonstrated via the AsKh reason_choice scenario on monotone low.

### 4.2 Primary conceptTag coverage

| Concept | v4.2.3 (primary) | v4.2.3A (primary) | v4.2.3A (any-position) |
|---|---:|---:|---:|
| range_disadvantage | 6 | **13** | 18 |
| check_raise_value | 5 | **13** | 13 |
| bluff_catchers | 3 | **13** | 19 |
| equity_realization_oop | 6 | **10** | 28 |
| check_raise_bluff | 2 | **6** | 6 |
| **pot_odds_defense** | **0** | **5** | 5 |
| oop_defense_threshold | 2 | 2 | 25 |

`pot_odds_defense` introduced (was missing entirely). `oop_defense_threshold` remains lower as PRIMARY tag because it's structurally a SECONDARY tag that anchors most M3 lessons (25 any-position uses).

### 4.3 heroHandRole coverage

| Role | v4.2.3 | v4.2.3A | Change |
|---|---:|---:|---|
| nutted_value | 6 | **14** | +8 |
| give_up | 5 | **11** | +6 |
| marginal_made_hand | 4 | **8** | +4 |
| pure_draw | 3 | **8** | +5 |
| **bluff_catcher** | 1 | **7** | +6 ✓ |
| semi_bluff_combo | 2 | **5** | +3 |
| strong_value | 1 | **4** | +3 |
| dominated_marginal | 1 | **3** | +2 |
| blocker_bluff | 1 | **2** | +1 |

### 4.4 drawCategory coverage

| drawCategory | v4.2.3 | v4.2.3A | Change |
|---|---:|---:|---|
| none | 12 | **31** | +19 |
| backdoor_only | 4 | **11** | +7 |
| gutshot | 4 | **8** | +4 |
| flush_draw | 2 | **5** | +3 |
| oesd | 1 | **4** | +3 |
| combo_draw | 1 | **2** | +1 |
| **nut_flush_draw** | **0** | **1** | +1 ✓ (introduced) |

### 4.5 Difficulty distribution

| Difficulty | v4.2.3 | v4.2.3A |
|---|---:|---:|
| 2 (clear) | 0 | **7** |
| 3 (medium) | 24 | **45** |
| 4 (advanced) | 0 | **9** |
| 5 (expert) | 0 | **1** |

v4.2.3 had all 24 at difficulty 3 (no spread). v4.2.3A introduces meaningful difficulty variety: 11% diff 2 (clear lessons for foundation), 73% diff 3 (core lessons), 14% diff 4 (advanced concepts), 2% diff 5 (the AsKh blocker_raise reason_choice — recognizing why a check-raise is reason="blocker" not "semi-bluff").

---

## 5. Anti-duplicate / no-suit-swap discipline

Per the brief's anti-filler rule, every new scenario must add at least one meaningful strategic dimension beyond suit changes alone.

**Filler scan results (run before migration):**

| Check | Result |
|---|---|
| Cross-bucket boards (board-rank exists in both existing + expansion) | **0** |
| Suit-only diff collisions (same board ranks + same hero ranks + same actionReason+recAction+conceptTags) | **0** |
| Within-expansion duplicate IDs | **0** |
| Scenarios missing uniquenessNote (≥30 chars) | **0** |
| Card collisions (hero card on board) | **0** |

**Sample uniquenessNotes (12 of 38):**

1. *9h8h on As9s4d* — "Pot-odds defense lesson — mid pair NO backdoor on two-tone (existing Th8h on rainbow As8d3h has BDFD). Tests defense threshold without backup equity."
2. *KcJh on Ks8s3d* — "PROTECTION_RAISE lesson with TPGK on TWO-TONE (vs rainbow K-high where TPGK calls). Tests recognition that suit texture changes raise/call decision for the same hand class."
3. *AsQs on Ks8s3d* — "NUT FLUSH DRAW with blocker (first nut_flush_draw drawCategory in M3). Distinct semi-bluff lesson combining max equity + nut blocker."
4. *KsJs on QsTs6d* — "COMBO DRAW SEMI-BLUFF on Q-high two-tone (vs existing 9h8h on QhJh6c which had FD+gutshot ~12 outs). KsJs has FD + OE = ~15 outs; tests max-combo-equity raise lesson."
5. *AsKh on 7s5s3s* — "BLOCKER_RAISE actionReason (FIRST in M3). Tests advanced concept that some OOP raises are reason='blocker' not 'semi-bluff'."
6. *8h7h on 8c8d3s* — "SLOWPLAY_CALL with TRIPS on paired LOW (vs existing AhKh trips on KcKd7s paired HIGH). Different range dynamics — paired LOW has more BTN air."
7. *AhKs on 8c8d3s* — "AK NO-PAIR BLUFF-CATCH on paired-low. Distinct from AhKc fold on 8s7d5h connected — paired-low is range-stab-heavy texture where AK has bluff-catching equity."
8. *9c9s on 9d8c6h* — "TOP SET PROTECTION on connected rainbow (vs 5c5d BOTTOM set on 8s7d5h). Different position on board — top set is best by amount but more vulnerable."
9. *Td9d on TcTh6s* — "SLOWPLAY_CALL with TRIPS WEAK KICKER on paired T (vs AhKh top-kicker on KcKd7s). Weak-kicker trips has even more reason to slowplay."
10. *5d4d on 6c3d2h* — "POT-ODDS DEFENSE with OESD + BDFD on RAG board (no overcards, just draw equity). Distinct from existing OESD scenarios on connected boards which had overcard backup."
11. *6h5h on 7s5s3s* — "POT-ODDS DEFENSE FAIL lesson — pair + gutshot looks playable on raw equity but realized equity OOP on monotone is below threshold."
12. *KhQh on 7s5s3s* — "NO-SPADE OVERCARDS FOLD on monotone. Tests that overcard rank doesn't rescue a no-equity hand on monotone."

---

## 6. Strategic spot-check (12 scenarios)

Reviewer-verified poker correctness across the 12 strategic themes from the brief:

| # | Theme | Scenario | Verdict |
|---|---|---|---|
| 1 | pot odds CALL | 9h8h on As9s4d → call/equity_realization_call | ✓ correct |
| 2 | pot odds FOLD | 6h5h on 7s5s3s → fold (acc=call) | ✓ correct (close decision noted) |
| 3 | bluff-catcher call | 5h5d on 8c8d3s → call/bluff_catch | ✓ correct |
| 4 | dominated fold | QdJh on Ks8s3d → fold/domination_fold | ✓ correct |
| 5 | semi-bluff raise | KsJs on QsTs6d → check_raise_small/semi_bluff_raise | ✓ correct |
| 6 | protection raise | 9c9s on 9d8c6h → check_raise_small/protection_raise | ✓ correct |
| 7 | range disadv fold | KcQc on As9s4d → fold/range_disadvantage_fold | ✓ correct |
| 8 | slowplay call | 8h7h on 8c8d3s → call/slowplay_call | ✓ correct |
| 9 | paired bluff-catch | 8h8d on TcTh6s → call/bluff_catch | ✓ correct |
| 10 | monotone CALL | As6h on 7s5s3s → call (A-blocker) | ✓ correct |
| 11 | monotone FOLD | KhQh on 7s5s3s → fold (no spade) | ✓ correct |
| 12 | reason_choice blocker | AsKh on 7s5s3s reason → best=blocker_raise | ✓ correct |

**0 spot-check FAILs.** All recommendations match GTO/expert-judgment intuition for BB-vs-BTN SRP 100BB OOP defense.

---

## 7. Audit results (final)

### 7.1 Production audit
```
Total scenarios: 362
Errors: 0
Warnings: 0
Scenarios with errors: 0
R29 warnings: 0
Exit: 0
```

### 7.2 M2 seed audit
```
Total scenarios: 24
Hard errors: 0
RESULT: PASS (8 warnings) — unchanged
```

### 7.3 M3 seed audit
```
Total scenarios: 24
Hard errors: 0
Warnings: 0
RESULT: PASS clean — unchanged (the v4.2.0 seed file is the original 24; the 38 expansion seeds live in a separate planning file)
```

### 7.4 Text integrity
```
postflop_scenarios.json: thai=0 repl=0 rank--x=0 rRr=0 board=0 ax=0 slash=0
expansion seeds JSON:    thai=0 repl=0                ax=0 slash=0
```

One Thai-character mojibake was found and fixed mid-sprint (a `≈` symbol round-tripping through CP874 to U+0E42; replaced with ASCII `~`). Final state: 0 mojibake across both files.

---

## 8. Module 3 distribution snapshot (post-expansion)

### 8.1 By board (14 families)

| Board | Suit | Family | Scenarios |
|---|---|---|---:|
| As 8d 3h | rainbow | A-high dry (v4.2.3) | 4 |
| As 9s 4d | two_tone | A-high two-tone (v4.2.3A) | 5 |
| Kh 9c 4s | rainbow | K-high dry (v4.2.3) | 4 |
| Ks 8s 3d | two_tone | K-high two-tone (v4.2.3A) | 5 |
| Kc Kd 7s | rainbow | K paired (v4.2.3) | 4 |
| Tc Th 6s | rainbow | T paired (v4.2.3A) | 4 |
| Qh Jh 6c | two_tone | Q-high two-tone (v4.2.3) | 4 |
| Qs Ts 6d | two_tone | Q-high two-tone dynamic (v4.2.3A) | 5 |
| Jh 8h 4h | monotone | J-high monotone (v4.2.3) | 4 |
| 7s 5s 3s | monotone | low monotone (v4.2.3A) | 5 |
| 8s 7d 5h | rainbow | low connected (v4.2.3) | 4 |
| 9d 8c 6h | rainbow | low semi-connected (v4.2.3A) | 5 |
| 8c 8d 3s | rainbow | paired low (v4.2.3A) | 5 |
| 6c 3d 2h | rainbow | rag (v4.2.3A) | 4 |

### 8.2 By question type

| qtype | Count |
|---|---:|
| action_choice | 54 (87%) |
| reason_choice | 8 (13%) |

### 8.3 By recommendedAction

| Action | Count |
|---|---:|
| call | 29 (47%) |
| check_raise_small | 17 (27%) |
| fold | 14 (23%) |
| check_raise_big | 2 (3%) |

### 8.4 sourceConfidence

All 62 M3 scenarios are `expert_judgment`. v4.2.3B/4 may promote select scenarios to `consensus_gto` after solver review.

---

## 9. Training volume assessment

**Verdict: M3 is approaching Limited Beta readiness but not yet there.**

| Health metric | Target | v4.2.3A actual | Status |
|---|---|---|---|
| Total scenarios | 50–80 | **62** | ✓ in range |
| Distinct boards | 12+ | **14** | ✓ |
| Each major reason ≥3 | 9 reasons | 8 of 9 ≥3, blocker_raise=1 | ⚠ blocker_raise thin |
| Each M3-native concept primary tag ≥4 | 7 concepts | 6 of 7 ≥4, oop_defense_threshold=2 primary | ⚠ but covered as secondary (25 any-position) |
| Difficulty spread | 2/3/4 represented | 7/45/9 + 1 diff 5 | ✓ |
| Critical mistake distribution | balanced | check_raise_big over-represented (most "fold" scenarios mark big-raise as critical) | ⚠ noted for future review |

**Recommendation:**
- v4.2.3B (optional, +20–30 scenarios): one more expansion focused on `blocker_raise` depth (+3-5), additional turn / river OOP defense seeds if scope allows, more `consensus_gto` confidence promotions
- v4.2.4 (runtime wire) **acceptable now** if labeled honestly as **"Limited Beta · 62 scenarios"** with scaled mastery thresholds (e.g., M1's "5 sessions / 80%+ in 3 / weak-review used / all concepts seen" downscaled to "3 sessions / 75%+ in 2 / all reasons seen at least once")

The choice between v4.2.3B and v4.2.4 is a product-owner call. From a content-quality standpoint, 62 is enough to launch a beta; from a polish standpoint, +20 more would round out the thin reason buckets.

---

## 10. Files touched

| File | Change |
|---|---|
| `postflop/postflop_scenarios.json` | +38 M3 expansion scenarios (300→324→362), description updated |
| `index.html` | `appVersion` 4.2.3 → 4.2.3A (1 line) |
| `service-worker.js` | `VERSION` v4.2.3 → v4.2.3A (1 line) |
| `docs/specs/postflop-v4.2.3A-module3-expansion-seeds.json` | NEW — 38-scenario planning seed file with uniquenessNotes |
| `tools/build-expansion-v4.2.3A.ps1` | NEW — authoring script (canonical source for the 38 scenarios) |
| `tools/migrate-expansion-v4.2.3A.ps1` | NEW — one-shot migration script (UTF-8 NO-BOM) |
| `docs/specs/postflop-v4.2.3A-module3-data-expansion.md` | NEW (this document) |
| `PROJECT_STATE.md` | sprint status update |
| `TASK_BOARD.md` | task close-out |
| `GPT AUDIT/v4.2.3A/` | NEW snapshot folder per §7.5 convention |

**No data, audit-rule, runtime, or strategy files modified outside the above.** TRAINING_MODES.m3 still `kind: 'preview'`, `route: null`. `runHomeCommandCenterMount`, `runTrainingModeAction`, `startPostflopDrill` byte-identical.

---

## 11. Sign-off checklist

- [x] M3 scenario count 24 → 62 (target 50–80, achieved 62)
- [x] Production audit: 362 / 0 / 0 (target 362 / 0 / 0)
- [x] R29 card-notation guard: 0 warnings (preserved)
- [x] M2 seed audit: PASS (8 warnings, unchanged)
- [x] M3 seed audit: PASS clean (24/0/0, unchanged)
- [x] Text integrity sweep: 0 mojibake / 0 broken patterns
- [x] Filler scan: 0 cross-bucket, 0 suit-only dupes, 0 missing uniquenessNotes, 0 card collisions
- [x] 12-scenario poker spot-check: all 12 strategic verdicts correct
- [x] All 9 M3 actionReasons represented (blocker_raise introduced)
- [x] All 7 M3-native concepts represented (pot_odds_defense introduced)
- [x] Difficulty spread (was all diff 3, now 7/45/9/1 across diff 2/3/4/5)
- [x] `index.html` appVersion + `service-worker.js` VERSION bumped to 4.2.3A
- [x] TRAINING_MODES.m3 untouched (still `kind: 'preview'`, `route: null`)
- [x] Runtime helpers untouched (`runHomeCommandCenterMount`, `runTrainingModeAction`, `startPostflopDrill` byte-identical)
- [x] M3 NOT playable, NOT routable, NOT runtime-wired
- [x] Volume + quality assessment documented

**Status: SHIPPED.**
