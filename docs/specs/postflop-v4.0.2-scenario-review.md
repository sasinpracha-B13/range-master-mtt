# Scenario Review — v4.0.2 Module 1 (Board Texture Trainer)

> **Owner**: Data / GTO Review Subagent (independent reviewer, fresh context).
> **Status**: review complete. Findings consolidated by Orchestrator into the implementation-ready brief.
> **Files reviewed (read-only)**: `postflop_scenarios.json`, `postflop_concepts.json`, `postflop_taxonomy.json`.
> **Scope**: 20 Module 1 scenarios (`module === "pf_board_texture"`).

---

# Module 1 (Board Texture Trainer) — Independent Review for v4.0.2

**Reviewer role:** Data/GTO independence pass.
**Spot context:** NLH MTT, BTN open 2.5x vs BB call, 100BB SRP, ChipEV.
**Scope:** 20 scenarios (`module === "pf_board_texture"`).
**Date:** 2026-05-04.

---

## A. Per-Scenario Grade Table

Scoring: each dimension 1–5; Total / 25. Recommendation: SHIP-FIRST | SHIP-LATER | HOLD.

| # | id (short) | Q-type | Diff | GTO | Clarity | Choices | Tags | Friend | Total | Recommendation |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `AhKd5c_rangeadv` | range_advantage | 1 | 5 | 5 | 5 | 5 | 5 | **25** | SHIP-FIRST |
| 2 | `KhTd2s_nutadv` | nut_advantage | 2 | 5 | 5 | 4 | 5 | 4 | **23** | SHIP-FIRST |
| 3 | `JhTs9c_rangeadv` | range_advantage | 2 | 4 | 5 | 4 | 5 | 4 | **22** | SHIP-FIRST |
| 4 | `5h4d3c_rangeadv` | range_advantage | 2 | 5 | 5 | 4 | 5 | 5 | **24** | SHIP-FIRST |
| 5 | `AhAd6s_rangeadv` | range_advantage | 2 | 5 | 4 | 5 | 5 | 4 | **23** | SHIP-FIRST |
| 6 | `8h7c6s_dynamic` | dynamic_level | 1 | 5 | 5 | 5 | 4 | 5 | **24** | SHIP-FIRST |
| 7 | `9c5d2h_rangeadv` | range_advantage | 2 | 4 | 4 | 4 | 5 | 4 | **21** | SHIP-FIRST |
| 8 | `KhKd7s_rangeadv` | range_advantage | 1 | 5 | 5 | 4 | 5 | 5 | **24** | SHIP-FIRST |
| 9 | `AhKd5d_freq` | frequency_strategy | 2 | 5 | 5 | 5 | 5 | 4 | **24** | SHIP-FIRST |
| 10 | `Qh9d6s_freq` | frequency_strategy | 3 | 4 | 4 | 4 | 4 | 3 | **19** | SHIP-LATER |
| 11 | `Th8h3h_nutadv` | nut_advantage | 3 | 3 | 4 | 4 | 5 | 3 | **19** | SHIP-LATER |
| 12 | `8s7s5s_rangeadv` | range_advantage | 2 | 5 | 4 | 4 | 5 | 4 | **22** | SHIP-FIRST |
| 13 | `JhTh4d_dynamic` | dynamic_level | 1 | 5 | 5 | 5 | 5 | 5 | **25** | SHIP-FIRST |
| 14 | `Qd9c4h_rangeadv` | range_advantage | 3 | 4 | 4 | 4 | 4 | 3 | **19** | SHIP-LATER |
| 15 | `AhJh3s_sizing` | sizing_family | 2 | 4 | 4 | 4 | 5 | 4 | **21** | SHIP-FIRST |
| 16 | `9h8c7d_freq` | frequency_strategy | 2 | 5 | 5 | 5 | 5 | 4 | **24** | SHIP-FIRST |
| 17 | `KhJc8s_rangeadv` | range_advantage | 2 | 4 | 4 | 4 | 4 | 4 | **20** | SHIP-FIRST |
| 18 | `Tc9d2s_dynamic` | dynamic_level | 2 | 4 | 4 | 4 | 4 | 4 | **20** | SHIP-FIRST |
| 19 | `6c5c4s_sizing` | sizing_family | 2 | 5 | 5 | 5 | 5 | 4 | **24** | SHIP-FIRST |
| 20 | `7d7s3c_rangeadv` | range_advantage | 4 | 3 | 3 | 3 | 4 | 2 | **15** | HOLD |

**Distribution:** 16 SHIP-FIRST, 3 SHIP-LATER, 1 HOLD.

---

## B. Concerns Log

### B1. GTO Disagreements / Reservations

**#11 `Th8h3h_nutadv` (T-high monotone, "BTN has nut advantage")** — *Mild disagreement.*
The dataset marks `best: preflop_raiser` with `acceptable: neutral` (3/5). My read: this should arguably flip to `best: neutral`, `acceptable: preflop_raiser`. On T-high monotone, BB's flatting range contains substantial mid-suited connectors that include a heart (T9hh, 9h8h, 8h7h, 7h6h-type combos). BTN does have more A♥X♥ and K♥X♥ at the very top of nut flush, but BB picks up many flopped flushes outside that. Solver work I'm familiar with shows monotone T-high closer to neutral with only a slight raiser edge. The current answer is *defensible* but presented too confidently as "best." The `commonMistake` text correctly notes the nuance, but the answer key doesn't reflect that nuance. **Recommendation:** keep as SHIP-LATER and consider downgrading `best` certainty in a future revision.

**#20 `7d7s3c_rangeadv` (paired low, "split")** — *Disagreement.*
Marked `best: split` with `acceptable: neutral, preflop_raiser`. The explanation itself contains a confused passage: *"Trips-7 even (both have 77 — wait, 77 impossible; 7-x distribution slightly favors BB due to wider flatting range with 87s, 76s, 97s)"* — that "wait" is a leftover authoring artifact and signals this scenario wasn't fully cleaned. More substantively: on 7-7-3, the BTN range still has a meaningful overpair lean (88-AA come down at full BTN frequency vs BB 3-betting QQ+) and BB's 7-x density isn't as crushing as the explanation suggests. Modern solver work typically grades 7-7-3 as a slight BTN edge or true neutral — calling it "split" with `caller` as the only `bad` answer is a defensible choice but the framing is muddled. The acceptable list (`neutral`, `preflop_raiser`) being so wide is a sign that the question doesn't have a crisp answer for a learner. **Difficulty 4 is correct.**

**#3 `JhTs9c_rangeadv`** — *Minor.* `best: caller` is correct, but I'd argue `acceptable: neutral` understates how close JT9 is to neutral in some solver runs (BTN has overpairs + many gutters). Still, "caller" leans correct enough; rating GTO 4/5.

**#7 `9c5d2h_rangeadv`** — *Minor.* `best: preflop_raiser` is right but the edge is *thin*. `acceptable: neutral` properly hedges. Some pros would call this near-neutral. GTO 4/5.

**#10 `Qh9d6s_freq`** — *Minor.* The `mixing` distribution `range_small: 0.30, mixed_small_check: 0.55` means range_small fires meaningfully in solver runs. `acceptable: range_small` gets partial credit, which is correct. The "best" mixed_small_check reading is defensible but learners may legitimately object — sourceConfidence "consensus_gto" is a slight overclaim.

### B2. Confusing Explanations

- **#20** — the parenthetical *"both have 77 — wait, 77 impossible"* is an obvious draft artifact. Must clean before any UI ship.
- **#9** — `nutLogic` says *"AdKd-type combos are now blockers to BB's flushes"* — this is true but reads as a side-note that may distract a beginner. Consider trimming.
- **#11** — `rangeLogic` is incomplete (`"BB's range has many low/mid hearts ... but BTN's wider range still picks up many flush combos."`) — doesn't actually argue why BTN nut advantage holds, only restates the conclusion.
- **#10, #14** — `commonMistake` is generic ("don't default to small high-freq"). Could name a concrete combo example.

### B3. Awkward Choice Phrasings

- **Several scenarios** include `split` as a choice with editorialized hint text (e.g., #5 *"Split — overpairs vs flushes"*). This is mildly leading. Choice labels should be neutral; explanations are where reasoning lives. Consider stripping the dash-phrases from choice labels for ship.
- **#1, #5, #7, #8** — choice labels include rationale ("more A-x", "overpair-heavy", "much more K-x"). For Module 1 first-time players this is a *helpful hint* but inconsistent across scenarios. Either always provide hints or never.
- **#4** — choice id `preflop_raiser` labeled *"Preflop raiser (BTN) — overpairs dominate"* — again a hint that biases the test. Decide on a consistent UI policy.
- **#3** — `split` label *"Split — BTN has overpairs but BB has more connectors"* essentially gives away why both ranges have something. Acceptable but inconsistent.

### B4. Missing / Wrong Concept Tags

- **#2 (`KhTd2s`)** — missing `dry_high_card_strategy` tag (it's a textbook dry K-high spot).
- **#6 (`8h7c6s` dynamic)** — missing `nut_advantage_shift` (this scenario directly teaches that low connected boards swing nut advantage). Currently only tagged `dynamic_board, wet_board, board_texture_recognition, low_connected_caution`.
- **#11 (`Th8h3h`)** — missing `nut_advantage_shift` would be reasonable; also missing a cross-link to `polar_big_strategy` since the implication of monotone nut adv is sizing.
- **#13 (`JhTh4d`)** — could add `polar_big_strategy` since two-tone wet flop is the canonical polar candidate when BTN bets.
- **#14 (`Qd9c4h`)** — only tagged `range_advantage, dry_board, board_texture_recognition`. Should add `static_board` (it's static-leaning) and/or `mixed_small_check` since solver actually mixes here.
- **#17 (`KhJc8s`)** — missing `static_board` or `dry_high_card_strategy`. Currently feels under-tagged for what it teaches.
- **#19 (`6c5c4s` sizing)** — could add `nut_advantage` since the explanation discusses nut distribution.

### B5. Difficulty Mis-Rating

- **#5 (`AhAd6s_rangeadv`)** rated 2 — fine, but on a paired ace the answer "BTN" is essentially given by the choice label hint *"much more A-x"*. This reads as difficulty 1.
- **#8 (`KhKd7s_rangeadv`)** rated 1 — same issue: choice label gives the answer. Either keep the hint and call it diff 1, or strip the hint and bump to diff 2. Inconsistent with #5.
- **#10 (`Qh9d6s_freq`)** rated 3 — correct for content, but for a *first-session smoke set* this is the upper bound of what beginners can absorb. Tag as harder.
- **#20 (`7d7s3c_rangeadv`)** rated 4 — correct difficulty rating, which is exactly why it shouldn't be in a smoke set targeting first-time users.
- **#11 (`Th8h3h_nutadv`)** rated 3 — correct; this is genuinely an intermediate concept and shouldn't be one of the first 5 scenarios shown.

---

## C. Recommended v4.0.2 Smoke Set (15 scenarios, in order)

**Curation principles:**
1. Open with a textbook range-adv question on the cleanest board (build confidence).
2. Establish the BTN-favored class first, then the BB-favored class, before mixing.
3. Cycle through all 5 question types so the UI exercises every code path.
4. Stay ≤ difficulty 2 for the first 10 scenarios; allow one diff-3 in the back half.
5. End with a frequency/sizing question so the player exits having committed to an action, not just labeled ranges.
6. Exclude the only HOLD (#20) and defer the two GTO-borderline scenarios (#10, #11) and one redundant rangeadv (#14).

| Order | Scenario id | Q-type | Diff | Why this slot |
|---|---|---|---|---|
| 1 | #1 `AhKd5c_rangeadv` | range_advantage | 1 | Canonical opener — every player intuits this. Builds momentum. |
| 2 | #6 `8h7c6s_dynamic` | dynamic_level | 1 | Introduces the dynamic-vs-static dimension early. Fast win. |
| 3 | #8 `KhKd7s_rangeadv` | range_advantage | 1 | Paired-board concept, still BTN-favored. |
| 4 | #13 `JhTh4d_dynamic` | dynamic_level | 1 | Second dynamic question on a different texture (two-tone). |
| 5 | #4 `5h4d3c_rangeadv` | range_advantage | 2 | First "BB owns this board" pivot. Critical lesson. |
| 6 | #2 `KhTd2s_nutadv` | nut_advantage | 2 | Introduces nut-advantage axis, on a familiar K-high. |
| 7 | #3 `JhTs9c_rangeadv` | range_advantage | 2 | Highly connected broadway — different flavor of caller advantage. |
| 8 | #5 `AhAd6s_rangeadv` | range_advantage | 2 | Trips-style paired board, reinforces "BTN's wider range" mental model. |
| 9 | #9 `AhKd5d_freq` | frequency_strategy | 2 | First action question. Familiar board (variant of #1). |
| 10 | #16 `9h8c7d_freq` | frequency_strategy | 2 | Direct contrast to #9 — "now check heavy." Drives home the lesson. |
| 11 | #12 `8s7s5s_rangeadv` | range_advantage | 2 | Monotone caller-favored — covers the suit dimension. |
| 12 | #15 `AhJh3s_sizing` | sizing_family | 2 | First sizing question. Familiar A-high theme. |
| 13 | #19 `6c5c4s_sizing` | sizing_family | 2 | Sizing question on the opposite class — closes the loop. |
| 14 | #18 `Tc9d2s_dynamic` | dynamic_level | 2 | Adds nuance: not every connected board is "dynamic." |
| 15 | #7 `9c5d2h_rangeadv` | range_advantage | 2 | Closing scenario — quiet low-dry board, BTN edge is subtle but real. |

**Excluded with reasons:**
- **#10 `Qh9d6s_freq`** (diff 3, mixed answer with thin gap between top two) — defer to v4.0.3 once players have intuition.
- **#11 `Th8h3h_nutadv`** (GTO answer is debatable) — needs review pass before shipping.
- **#14 `Qd9c4h_rangeadv`** (diff 3, redundant teaching with #2/#7) — adds little distinct value.
- **#17 `KhJc8s_rangeadv`** (redundant K-high range-adv with #2) — could swap in if a slot opens, but #15 K-high spots already covered.
- **#20 `7d7s3c_rangeadv`** (HOLD — explanation has "wait" artifact + answer is genuinely fuzzy).

**Q-type coverage of smoke set:** range_advantage × 7, nut_advantage × 1, dynamic_level × 3, frequency_strategy × 2, sizing_family × 2. Every question type fires at least once.

**Concept coverage:** range_advantage, nut_advantage, dry_high_card_strategy, low_connected_caution, dynamic_board, static_board, paired_board_strategy, monotone_board_strategy, two_tone_board_strategy, small_cbet_freq, polar_big_strategy, check_strategy, common_leaks. All foundation + strategy concepts touched.

---

## D. Top 3 Strengths

1. **Range vs nut decomposition is the right pedagogical spine.** Forcing the player to separately answer *whose range is broader-equity* and *whose range has the nuts* — before any action question — is exactly the mental model needed for postflop decisions. Most training apps collapse these. This dataset earns real value here.
2. **The "common mistake" sections are concrete and corrective.** They name the specific leak (e.g., "BTN players who 'always c-bet small' on monotone get punished — solver: BTN c-bets ~15-25%"), tying conceptual lessons to behavioral fixes. This is far more valuable than generic GTO platitudes.
3. **Board diversity is well-balanced.** 20 scenarios cover: A-high dry, K-high dry, K-high broadway, Q-high semi-dry, J-high wet broadway, T-high monotone, T-high semi-static, low-dry, low-connected (×3 different versions), paired (×3: AA, KK, 77), monotone (×2), two-tone (×2 different families). For a smoke set this is excellent class coverage.

---

## E. Top 3 Risks (not obvious from per-scenario review)

1. **Hint-text inconsistency in choice labels will confuse first-time UX.** Some choices include a parenthetical hint ("BTN — much more K-x"), others don't. A first-time player will either lean on the hints (when present) and get wrong-footed when they're absent, or feel the test is uneven. Either commit to *always* hint or *never* hint, and document the choice. This is a small dataset edit but a UX risk if not addressed before v4.0.2 ship.

2. **The dataset clusters difficulty 1-2 heavily and only spikes at #20.** 14 of 20 are diff 1-2, four are diff 2-3, and only one is diff 4. There's no diff-5 in Module 1 at all. This is correct for a smoke set but means the module has *no graduation path* — a player who masters all 20 has nothing harder to chase. Not a v4.0.2 blocker but a v4.1 content-debt flag. The taxonomy supports diff 1-5; the data only uses 1-4.

3. **`sourceConfidence: consensus_gto` is overclaimed on a few scenarios.** Specifically #10 and #11 have answers that are genuinely contested in solver work or depend on the specific sim parameters (BB defense range definition, mixed strategies in solver output). Marking these as `consensus_gto` rather than `expert_judgment` (#11 is correctly `expert_judgment`; #10 is `consensus_gto` and probably shouldn't be) sets up an exposure: if a knowledgeable user disputes the "best" answer with a defensible alternative line, the trainer's authority is undermined. Recommend an audit pass downgrading borderline scenarios to `expert_judgment` and surfacing this distinction in the UI ("solver mix" badge vs "consensus" badge).

---

**Reviewer summary:** Module 1 is in solid shape for a v4.0.2 smoke ship. 16 of 20 scenarios are SHIP-FIRST quality. One scenario (#20) needs a cleanup pass (the "wait" artifact in the explanation) and should hold. Two scenarios (#10, #11) have GTO answers that are defensible but presented with more confidence than warranted — defer rather than block. The recommended 15-scenario smoke set above gives the cleanest first-session arc and exercises every question type and major board class.
