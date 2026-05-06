# Postflop v4.2.2E — Final Text Integrity Repair + R29 Hardening

**Status:** Production text-integrity correction after v4.2.2D. Repaired 14 scenarios / 18 text-field edits where v4.2.2D's combo-shorthand rule produced fake suited-hand notation when applied to board-card references. Hardened R29 audit guard with 3 new patterns (board-collapse, rank-dash-X, rank-dash-slash) — verified via 6 positive + 7 negative test cases. **15-field strategic integrity check: 0 changes.** appVersion + service-worker bumped to v4.2.2E.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.2D-card-suit-notation-repair.md` (the sprint that introduced this regression).

---

## 1. Why v4.2.2D was not sufficient

v4.2.2D introduced Pattern 4: `[Rank] — [Rank] —` → `[Rank][Rank]s` (suited shorthand). The intent was to handle combo lists like `9♥6♥, J♣4♣` → `96s, J4s`. But the same regex matched **board card references** like `K — T — 2 —` (originally `Kh Td 2s`), producing the fake suited-hand string **`KTs 2`**.

Because the Pattern 4 rule ran AFTER the Pattern 3 board-rebuild (`On [R] — [R] — [R] — ` → `On [boardText]`), only the board references that were not preceded by `On ` (e.g., inline `BTN with ... on K — T — 2 — ` and explanation prose like `Top of range hands on K — T — 2 — are sets...`) escaped the board-rebuild and got hit by Pattern 4.

Three other defects also remained:
- **`[Rank] — X` / `[Rank] — X —`** flush combo notation (e.g., `Nut flush A — X is roughly even`) — never repaired by v4.2.2D because Pattern 4 required `[Rank]` on BOTH sides of the dash, and `X` is not in `[AKQJT2-9]`.
- **`[Rank] — /` / `/[Rank] — `** rank-x list separator (e.g., `5 — /7 — /8-holdings`) — same reason: slash is not a rank.
- **Trailing artifact `Kh Td 2s-are`** after the v4.2.2E rebuild — the original prose was `KTs 2-are sets`, and replacing `KTs 2` with `Kh Td 2s` left the leading hyphen attached.

R29 audit guard reported 0 warnings, falsely suggesting the data was clean. The guard's regex set covered v4.2.2D's known patterns but missed these three.

---

## 2. Raw defects found

| Pattern | Count |
|---|---:|
| `KTs 2` / `QTs 2` / `JTs 2` / `ATs 2` (board collapse) | 3 occurrences across 3 scenarios |
| `on [RR]s [R]` (general board-collapse pattern, includes the `KTs 2` cases) | 10 instances in 9 scenarios |
| `A — X` / `A — X —` | 3 |
| `K — X` / `K — X —` | 1 |
| `[Rank] — /` (rank-x list residue) | 2 |
| `/[Rank] — ` (rank-x list residue tail) | 1 |
| Total scenarios with at least one defect | **12** |
| Total text-field edits (Pass 1 + Pass 2 residual cleanup) | **18** |

---

## 3. Exact scenarios / fields touched

| Scenario ID | Board | Field defects |
|---|---|---|
| `pf_btn_v_bb_srp_100bb_flop_8s7s5s_rangeadv_001` | 8s 7s 5s | `explanation.short` (rank-dash-slash), `explanation.nutLogic` (A-em-dash-X) |
| `pf_btn_v_bb_srp_100bb_flop_AhJh3s_action_KhQh` | Ah Jh 3s | `question.prompt` (board-collapse `AJs 3`) |
| `pf_btn_v_bb_srp_100bb_flop_AhKd5c_action_55` | Ah Kd 5c | `question.prompt` (board-collapse `AKs 5`) |
| `pf_btn_v_bb_srp_100bb_flop_AhKd5c_action_76s` | Ah Kd 5c | `question.prompt` (board-collapse `AKs 5`) |
| `pf_btn_v_bb_srp_100bb_flop_AhKd5c_action_AsKc` | Ah Kd 5c | `question.prompt` (board-collapse `AKs 5`) |
| `pf_btn_v_bb_srp_100bb_flop_AhKd5c_action_QQ` | Ah Kd 5c | `question.prompt` (board-collapse `AKs 5`) |
| `pf_btn_v_bb_srp_100bb_flop_AhKd5c_action_Td9d` | Ah Kd 5c | `question.prompt` (board-collapse `AKs 5`) |
| `pf_btn_v_bb_srp_100bb_flop_JhTs9c_action_QQ` | Jh Ts 9c | `question.prompt` (board-collapse `JTs 9`) |
| `pf_btn_v_bb_srp_100bb_flop_KhTd2s_action_QJs` | Kh Td 2s | `question.prompt` (board-collapse `KTs 2`) |
| `pf_btn_v_bb_srp_100bb_flop_KhTd2s_action_TT` | Kh Td 2s | `question.prompt` (board-collapse `KTs 2`) |
| `pf_btn_v_bb_srp_100bb_flop_KhTd2s_nutadv_001` | Kh Td 2s | `explanation.nutLogic` (board-collapse `KTs 2`) |
| `pf_btn_v_bb_srp_100bb_flop_Th8h3h_nutadv_001` | Th 8h 3h | `explanation.nutLogic` (A-em-dash-X, K-em-dash-X) |

Plus 2 additional scenarios in Pass 2 residual word-glue cleanup.

---

## 4. Before / after samples

### Sample 1: M1 nutadv prompt + nutLogic

**Before (v4.2.2D state):**
> "prompt": "On Kh Td 2s, who has nut advantage?"
> "nutLogic": "Top of range hands on KTs 2-are sets (KK, TT, 22), top two (KT)..."

**After (v4.2.2E):**
> "prompt": "On Kh Td 2s, who has nut advantage?"
> "nutLogic": "Top of range hands on Kh Td 2s are sets (KK, TT, 22), top two (KT)..."

Board reference rebuilt from `scenario.board.cards = ["Kh","Td","2s"]`; trailing `-` glued to `are` cleaned.

### Sample 2: M2 set scenario prompt

**Before:**
> "prompt": "BTN with TcTh (set of T) on KTs 2. Action?"

**After:**
> "prompt": "BTN with TcTh (set of T) on Kh Td 2s. Action?"

Board now reads cleanly as actual cards. Hero hand TcTh is preserved (it's a real pair, the "set of T" annotation matches the Td on board).

### Sample 3: Monotone nut flush prose

**Before:**
> "nutLogic": "The nut flush is A-X — BTN's range (A2s-AKs all suited) contains all suited Aces, and many of those are with hearts. BB's flatting range has fewer A — X combos because BB 3-bets ATs+, AJs+ at high frequency. BTN holds the nut flush (A — X — ) more often. Second-nut flush (K — X)..."

**After:**
> "nutLogic": "The nut flush is A-X — BTN's range (A2s-AKs all suited) contains all suited Aces, and many of those are with hearts. BB's flatting range has fewer A-X combos because BB 3-bets ATs+, AJs+ at high frequency. BTN holds the nut flush (A-X) more often. Second-nut flush (K-X)..."

`A — X` and `K — X` collapsed to canonical `A-X` / `K-X` flush combo notation. Sentence em-dashes (`is A-X — BTN's range`) preserved.

### Sample 4: Low monotone rank-x list

**Before:**
> "short": "Caller (BB) crushes this board. BB has more low pairs, more 5 — /7 — /8-holdings, and more flush combos."

**After:**
> "short": "Caller (BB) crushes this board. BB has more low pairs, more 5x / 7x / 8x holdings, and more flush combos."

Rank-x list now reads as standard poker shorthand `5x / 7x / 8x`.

### Sample 5: M2 set scenario fully verified strategic intent

**Before/After identical in structure; only the board text changed:**
> Hero: TcTh, Board: Kh Td 2s
> handLogic: "Set on dry K-high is huge — only AA, KK ahead. Most turns are completely safe (A might give BB top pair = more value). Big sizing acceptable for second-line value, but small with this dry texture is fine..."
> best: bet_small | reason: value

Strategic intent (set-on-dry-K → bet_small for value) preserved; only the board notation was repaired.

---

## 5. Poker-semantic verification (5 critical scenarios manually inspected)

| ID | Board | Hero | Best Action | Verification |
|---|---|---|---|---|
| `KhTd2s_nutadv_001` | Kh Td 2s | — | preflop_raiser nut adv | NutLogic correctly identifies sets (KK/TT/22), top two (KT), TPGK (AK/KQ) for the rebuilt board. ✅ |
| `KhTd2s_action_TT` | Kh Td 2s | TcTh | bet_small (value) | Hero has middle set (T on T-high board → middle set actually is a set of T because board has Td). HandLogic: "Set on dry K-high is huge — only AA, KK ahead." Strategy preserved. ✅ |
| `KhTd2s_action_QJs` | Kh Td 2s | QcJc | bet_small (semi-bluff) | QJ on K-T-2 has gutshot to A-K-Q-J-T (need A) and gutshot to Q-J-T-9-? (need 9). HandLogic: "QJ: open-ended (any A or 9 makes a straight) + Q/J overcards for pair showdown value." Mathematically correct + strategically defensible. ✅ |
| `Th8h3h_nutadv_001` | Th 8h 3h | — | preflop_raiser | Monotone heart board. NutLogic correctly states "The nut flush is A-X — BTN's range (A2s-AKs all suited) contains all suited Aces, and many of those are with hearts." A-X notation reads cleanly; em-dash is sentence punctuation. ✅ |
| `8s7s5s_rangeadv_001` | 8s 7s 5s | — | caller (BB) | Low monotone spade. Short: "BB has more low pairs, more 5x / 7x / 8x holdings, and more flush combos." NutLogic: "low-spade flush combos (e.g., 96s, J4s if in flatting range)." Strategically defensible — BB does crush this board with caller-favored low spades. ✅ |

**All 5 spot-checks PASS.** No card notation contradicts board.cards. No hand class confusion (TcTh is a set on Kh-Td-2s; QcJc is a semi-bluff; A-X is generic flush combo; 5x/7x/8x is rank-with-anything shorthand).

---

## 6. R29 guard hardening

Updated `tools/audit-postflop-ps.ps1` R29 to add 3 new pattern detectors on top of the original 3 from v4.2.2D:

| Rule | Pattern | Catches | Status |
|---|---|---|---|
| `rank_dash_dash_x` (v4.2.2D) | `[AKQJT2-9]\s+—\s+-[xX]` | "[Rank] — -x" residue | retained |
| `rank_dash_rank_dash` (v4.2.2D) | `[AKQJT2-9]\s+—\s+[AKQJT2-9]\s+—` | "K — K —" hero-hand notation | retained |
| `btn_with_dash_pair` (v4.2.2D) | `BTN with [AKQJT2-9]\s+—\s+[AKQJT2-9]` | "BTN with K — K —" | retained |
| **`board_collapse` (NEW v4.2.2E)** | `\bon [AKQJT][AKQJT2-9]s [2-9AKQJT]\b` | `"on KTs 2"` board-as-suited-hand | **added** |
| **`rank_dash_X` (NEW v4.2.2E)** | `[AKQJT]\s+—\s+X(?!s)\b` | "A — X" / "K — X" flush combo residue | **added** |
| **`rank_dash_slash` (NEW v4.2.2E)** | `[2-9AKQJT]\s+—\s+/` | "5 — /7 — /8" rank-x list residue | **added** |

R29 remains warning-only (does not fail production audit) and applies to: `question.prompt`, all `explanation.*` text fields, and `blockerNote`.

---

## 7. R29 positive / negative test result

Inline test suite verified all 6 patterns against 13 sample inputs:

### POSITIVE cases (must be flagged) — **6/6 PASS**

| Input | Detected by |
|---|---|
| `BTN with TcTh on KTs 2. Action?` | `board_collapse` ✅ |
| `Top of range hands on KTs 2-are sets` | `board_collapse` ✅ |
| `Nut flush A — X is roughly even` | `rank_dash_X` ✅ |
| `5 — /7 — /8-holdings` | `rank_dash_slash` ✅ |
| `BTN with K — K — on the board` | `rank_dash_rank_dash, btn_with_dash_pair` ✅ |
| `K — X — similarly favors BTN` | `rank_dash_X` ✅ |

### NEGATIVE cases (must NOT be flagged) — **7/7 PASS**

| Input | Result |
|---|---|
| `KTs is in BTN range` | (no flag) ✅ — no surrounding "on" context |
| `JTs, T9s, 98s` | (no flag) ✅ — comma list, not "on RR-s R" |
| `BTN — slight edge` | (no flag) ✅ — em-dash punctuation |
| `25 — 35% frequency` | (no flag) ✅ — numeric range |
| `They don't — sets are rare` | (no flag) ✅ — sentence punctuation |
| `On Ah Kd 5c, who has range advantage?` | (no flag) ✅ — clean board notation |
| `With AhKh on As 8d 3h` | (no flag) ✅ — clean hero+board notation |

R29 distinguishes legitimate em-dash punctuation from card-notation defects via word-boundary anchors and context-specific patterns (e.g., `\bon` prefix for the board-collapse rule).

---

## 8. Strategy fields untouched verification

Per-scenario object-by-object diff vs HEAD across 15 strategic fields:

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

**All strategic fields verified untouched.** Only text fields (`question.prompt`, `explanation.*`, `blockerNote`) were modified.

Scenario count unchanged: **300** (251 M1 + 49 M2 + 0 M3).

---

## 9. Audit results

| Audit | Pre-v4.2.2E | Post-v4.2.2E | Status |
|---|---|---|---|
| Production audit | 300 / 0 / 0 | **300 / 0 / 0** | ✅ unchanged |
| R29 warnings (hardened with new patterns) | 0 (false negative — defects existed but old rule didn't catch) | **0** (true negative — data is now clean) | ✅ guard now accurate |
| M2 seed audit | 24 PASS / 0 hard / 8 warnings | **24 PASS / 0 hard / 8 warnings** | ✅ unchanged |
| M3 seed audit | 24 / 0 hard / 0 warnings | **24 / 0 hard / 0 warnings** | ✅ unchanged |

---

## 10. Text-integrity post-check

Final exhaustive scan across `postflop/postflop_scenarios.json`:

| Pattern | Count |
|---|---:|
| `KTs 2` / `QTs 2` / `JTs 2` / `ATs 2` | **0** |
| `on [RR]s [R]` (any board collapse) | **0** |
| `A — X` / `K — X` flush combo residue | **0** |
| `[Rank] — /` rank-x list residue | **0** |
| `[Rank] — [Rank] —` hero-hand residue | **0** |
| `[Rank] — -[xX]` blocker shorthand residue | **0** |
| Thai mojibake (U+0E00-U+0E7F) | **0** |
| Replacement char (`�`) | **0** |
| Total em-dashes (legitimate punctuation) | ~180 (preserved) |

Cross-verified at runtime via Claude Preview MCP — `App.postflop.scenarios` (300 scenarios) shows 0 occurrences of all 6 defective pattern categories.

---

## 11. Browser / mobile QA result

Verified via Claude Preview MCP:

| Surface | Result |
|---|---|
| App loads at v4.2.2E | ✅ |
| Console errors | ✅ 0 |
| `App.postflop.ready === true` | ✅ |
| `App.postflop.scenarios.length === 300` | ✅ |
| All 6 defective pattern categories in runtime DOM | ✅ 0 each |
| M1 prompt `Kh Td 2s` reads "On Kh Td 2s, who has nut advantage?" | ✅ |
| M2 prompt `KhTd2s_TT` reads "BTN with TcTh (set of T) on Kh Td 2s. Action?" | ✅ |
| Monotone Th8h3h prose: "The nut flush is A-X — BTN's range..." | ✅ |
| Low-monotone 8s7s5s prose: "5x / 7x / 8x holdings" | ✅ |

Mobile 375×812 visual confirmation queued (preview window timeout on screenshot from earlier session, but DOM eval on same viewport confirmed all text reads correctly). The earlier v4.2.2D mobile screenshot pattern still applies — no horizontal overflow, install banner respects safe-area-inset.

---

## 12. Recommendation for v4.2.3

**v4.2.3 — Module 3 Migration to Production Data** can now safely resume. All preconditions met:

- Production text is fully clean (mojibake-free + card-notation-correct + flush-combo-readable + rank-x-list-readable).
- Strategic fields verified untouched (no risk of accidental regression in strategy).
- Production audit gate solid at 300 / 0 / 0.
- R29 guard hardened to 6 patterns covering all known notation defect classes — will catch any recurrence in v4.2.3 migration or future seed authoring.
- M3 seed JSON (24 scenarios at `v4.2.0_final`) untouched and ready.

**Heads-up for v4.2.3:** R29 still occupies the rule-number slot reserved for M3 production rules in the M3 audit-plan doc. v4.2.3 should renumber M3 production rules to **R30-R41** and update `postflop-v4.2.0-module3-audit-plan.md` accordingly.

**Suggested sprint sequence:**
1. **v4.2.3** — Migrate 24 M3 seeds to production (300 → 324 scenarios). Add 7 M3 concepts to `postflop_concepts.json`. Add 2 new heroHandRole values + 1 actionReason to `postflop_taxonomy.json`. Implement R30-R41 production rules.
2. **v4.2.3A (recommended)** — Module 3 data expansion (24 → 40-60 scenarios) before playable beta.
3. **v4.2.4** — Module 3 playable beta runtime wire.

---

## 13. Sign-off

**Production data is now text-clean, semantically correct, and poker-strategically defensible. R29 guard catches all known notation defect classes via 6 patterns verified against 13 positive/negative test cases. Strategic fields verified untouched. Card notation reads naturally — boards as `Kh Td 2s`, hero hands as `TcTh`, generic flush combos as `A-X` / `K-X`, rank-x lists as `5x / 7x / 8x`.**

**v4.2.2E deliberately did NOT:**
- Productionize Module 3 (still planning-only at v4.2.0_final).
- Append M3 to production data.
- Add M3 concepts to `postflop_concepts.json`.
- Add new heroHandRole values to `postflop_taxonomy.json`.
- Change any answer key, recommendedAction, actionReason, conceptTags, auditStatus, or sourceConfidence.
- Touch ranges.json (no defects there from v4.2.2C/v4.2.2D).
- Touch preflop trainer logic, gamification, shop, Field FX.
- Modify the M2 seed auditor or M3 seed auditor.
- Change runtime UI logic (only appVersion + SW VERSION bumped + R29 hardened in production auditor).
- Start v4.2.3 migration.
