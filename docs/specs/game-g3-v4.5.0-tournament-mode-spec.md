# G3 · v4.5.0-game Tournament Mode — Design Spec (FOR REVIEW · nothing built)

**Status:** APPROVED & BUILT (v4.5.0-game). PIN 1 closed via schedule-invariant proof §(c); PIN 2 built with owner amendments + full 510 hit-list line-reviewed (see `game-g3-range-reveal-hitlist.md`); line-review rulings applied 2026-07-05.
**Date:** 2026-07-05
**Scope:** the flagship run-based mode. Data byte-identical; validator 510/0/0; FX via v4.4.3 pipeline. This spec answers the seven advisor criteria (a)–(g) explicitly, in order.

---

## 0. Run shape (context for everything below)

- **8 blind levels × 5 hands = 40-hand run.** Start stack **100 BB**. Bust = stack ≤ 0.
- Arc labels: L1–L2 "Early", L3–L4 "Money Bubble" (survive L4 = in the money), L5–L6 "Deep Run", **L7–L8 "FINAL TABLE"**, complete L8 = 🏆 WIN.
- Hands are dealt from **action_choice M2–M5** with a difficulty/street ramp (§b); **Table Read interludes** (1 M1/reason question, Score-only) fire between levels as a breather — never counted among the 5 level hands, never move Stack.
- Per-hand screen shows: Tournament strip (Stack · blind level · hands-to-next-level) — replaces the Session-EV strip inside this mode only.

## (a) AMBIENT DRIFT INTEGRITY

**Rule: at a decision point, the ONLY Stack movement is the v4.4.3 regret delta. Drift applies exclusively in the between-hands transition.**

- **When:** drift is applied at the "🎰 blinds pass" beat — after the answer screen is dismissed and *before* the next question renders. It is shown as its own labeled chip animation (`🎰 Blinds: −2.0 BB`), on its own screen beat, never merged with the answer's delta.
- **Formula (fully deterministic, answer-independent):** `driftPerHand(level)` from the fixed schedule in §(c). It depends on the level number ONLY — not on tiers, streaks, score, or anything the player did. Two players at the same level always bleed identically.
- **Why a player can never mis-attribute:** (1) temporal separation — decision delta lands on the answer screen with its "est. EV" label; drift lands on a separate transition beat with the "🎰 Blinds" label; (2) determinism — drift is printable in advance (the intro screen shows the full blind schedule), so nothing about it carries information; (3) accounting separation — the run summary reports `ΣdecisionEV` and `Σblinds` as two separate lines that reconcile to the final stack.

## (b) BLIND LADDER ≠ STAKE INFLATION

**Per-decision regret magnitudes are NEVER scaled by level.** The delta at every decision = `tierFactor × stakeBB(scenario)` exactly as in the v4.4.3 derived-stake table — the authored line math. No tournament multiplier exists in the code path (QA will assert the decision delta of the same scenario is identical inside and outside Tournament).

Late-run decisions cost more **only** because the dealt pool ramps to later streets, whose *authored* stakes are bigger:

| Levels | Pool (action_choice) | Authored stake range |
|---|---|---|
| L1–L2 | M2 + M3 (flop) | 2–3 BB |
| L3–L4 | + M4 (turn) | 2–5 BB |
| L5–L6 | M4-weighted + M5 small/medium | 5–13 BB |
| L7–L8 (FT) | M5-weighted, all sizings incl. overbet | 7–30 BB |

Within-level picks also prefer higher `difficulty` as levels rise (D1-2 → D3 → D4-5), so the FT is hard because the *spots* are hard — the poker truth carries the pressure.

## (c) ELIMINATION MATH — worked survival curves

**Drift schedule (BB per hand, fixed):** L1 **+1.0** · L2 **+0.5** · L3 **0** · L4 **−1.0** · L5 **−2.0** · L6 **−3.5** · L7 **−5.0** · L8 **−7.0**. (Fiction: early tables are soft — your steals cover the blinds; late blinds eat everyone.)

**Archetype decision-EV per hand** (from the v4.4.3 factors × the level's typical stake; best-mix ≈ +0.25×stake because ~half of best answers are folds/checks at 0):

| Level (stake≈) | Best (+0.25×s) | Acceptable (−0.25×s) | Bad (−0.75×s) |
|---|---|---|---|
| L1–L2 (3) | +0.75 | −0.75 | −2.25 |
| L3–L4 (5) | +1.25 | −1.25 | −3.75 |
| L5–L6 (10) | +2.50 | −2.50 | −7.50 |
| L7–L8 (18) | +4.50 | −4.50 | −13.50 |

**PIN-1 GUARANTEE (perfect play cannot bust, ANY seed):** total drift over the full run = 5×Σ(schedule) = **−85 BB**, and every best-tier decision delta is **≥ 0** (fold/check/mixed = 0; call/raise > 0). Therefore a 100%-best player's stack ≥ 100 − 85 = **+15 BB at every point of every seed, including the all-fold worst case** — no pool constraint needed; the guarantee is a schedule invariant: **Σ|net drift| (85) < starting stack (100)**. Any future drift-knob change must re-verify this inequality (stated in-code next to the table).

**Stack at end of each level (start 100; 5 hands/level; drift + decision) — numbers below are the DETERMINISTIC SIM output (pool-average stakes 3/3/5/5/10/10/18/18 by level; sim run 2026-07-05, reproduced exactly; the earlier draft's Bad row had an arithmetic slip, corrected per sim):**

| | L1 | L2 | L3 | L4 🫧 | L5 | L6 | L7 FT | L8 WIN |
|---|---|---|---|---|---|---|---|---|
| **Best** | 108.8 | 115.0 | 121.2 | 122.5 | 125.0 | 120.0 | 117.5 | **105.0 🏆** |
| **Acceptable** | 101.2 | 100.0 | 93.8 | 82.5 | 60.0 | 30.0 | **bust hand 34 (at the FT)** | — |
| **Bad** | 93.8 | 85.0 | 66.2 | 42.5 | **bust hand 25 (just after 🫧)** | — | — | — |
| **All-fold perfect (floor)** | 105 | 107.5 | 107.5 | 102.5 | 92.5 | 75.0 | 50.0 | **15.0 (survives)** |

→ the demanded separation holds: **sustained best play wins**; **acceptable cashes the bubble and dies at the Final Table** (hand 34/40); **bad busts mid-run just after the bubble** (hand 25); **perfect play cannot bust even on an all-fold seed** (+15 floor). A single late **critical** (−1.5×stake ≈ −27 at FT stakes) can still kill a healthy stack — punt drama via **anchored** regret, no inflation. QA re-runs this sim in-app plus a forced all-fold seed.

## (d) RANGE REVEAL — full phrase-mapping table (for line-by-line review)

Post-answer drama chip on turn/river At-the-Table hands **inside Tournament only**: `📡 Table read: <band>`. Source = case-insensitive regex over the scenario's **authored prose** (`explanation.riverLogic + rangeContext + handLogic + blockerNote`). **No numbers are ever displayed or invented; no villain hand is ever shown (none exists in the data — stated as a structural guarantee); no match → chip silently absent.**

| Band chip | Regex whitelist (i-flag) |
|---|---|
| `bluff-heavy line` | `bluff-heavy`, `over-?bluff`, `toward bluffs`, `tilting .* toward bluffs`, `too few value` |
| `value-heavy line` | `value-heavy`, `value-rich`, `value-weighted`, `toward (his )?value`, `bluff-light`, `too few bluffs`, `flush-dense` |
| `polarized line` | `polar(?:ized|izing|`)?, `value-or-bluff`, `nuts?-or-air`, `maximally polar` |
| `merged / thin-value line` | `merged`, `thin value`, `bets? thin` |

Priority when multiple match: `polarized` may pair with one lean → chip reads `polarized · bluff-lean` / `polarized · value-lean`; otherwise first match in table order.

**PIN-2 AMENDMENTS (owner-approved):**
1. **Negation guard:** if a negator appears within a ~40-char window (≈4 words) before the match inside the same sentence, the band is suppressed (silently absent). Negator set (also in code comment): `not`, `n't` (isn't/doesn't/don't/won't/aren't…), `never`, `rarely`, `no longer`.
2. **`flush-dense` texture guard:** counts only when the matched **sentence** also contains `range` or `value` (the phrase must describe villain's range, never board texture). If the owner's line review finds any texture leak, the phrase drops from the whitelist.
3. **Per-scenario suppression list (line-review outcome, 2026-07-05):** `_PF_REVEAL_SUPPRESS` — explicit ids only (same pattern as the mixed whitelist, no regex engineering); a listed id never shows a chip. Seeded with `…river_Ks9d4c_7s_m5_action_9c9h_v440` (matched sentence describes villain's continue-vs-raise range, not the betting line's composition). Any future false positive goes on this list, never into regex surgery.

**Hit-list format (QA evidence):** `id → band → the matched sentence (verbatim)` for all 510, **including suppressed-by-negation entries flagged `[NEG-SUPPRESSED]`** — every mapping line-reviewable against its prose. **Line-review verdict (2026-07-05): PASSED** with rulings: (i) 9c9h false positive → suppression list; (ii) KcJd value-lean upheld — authored support "The pot-sized bet is value-weighted; …"; (iii) **accepted-interpretation note:** "polar card" phrasing (`4c is a polar straight-complete card`, `2c is a polar brick`) is card-level shorthand conventionally equivalent to a range-polarity claim — accepted as banded. Final counts: **50 banded** (polarized 40 · merged/thin 4 · value-heavy 3 · bluff-heavy 2 · polarized·value-lean 1) · 2 NEG-SUPPRESSED · 1 LIST-SUPPRESSED · 460/510 no chip.

## (e) GHOST RUN

- `rmtt_tourney.bestRun = { date, endedHand, series: [stack after each hand, 1 decimal] }` — ≤ 40 numbers; plus `lastRun` same shape. **Storage bound: exactly two series ≈ <1 KB total** (older runs never accumulate).
- Drawn as an inline SVG sparkline (no lib): ghost = dashed teal line under the current run's solid line, on the between-level screen + run summary. **Display only — zero gameplay effect.** New best replaces the old (strictly by `endedHand`, tiebreak final stack).

## (f) MODE ISOLATION

Same mechanism the owner accepted for boss deferral: **strict `mode === 'tourney'` equality** gates every tournament surface (drift beat, blind strip, elimination check, Range Reveal chip, Ghost overlay, run summary). Drill/daily/boss/revenge paths contain no tourney branches at all — the tournament logic lives in its own start/transition/finish functions that other modes never call. QA asserts: same scenario answered in normal drill vs tournament produces the identical decision delta, and no drift/blind UI exists outside the mode.

## (g) M6 HOOK — FT content-drop slot (no rework later)

The level-pool builder ends with a reserved union:

```js
if (level >= 7) pool = pool.concat(allApproved('pf_river_value_ip')); // M6 — empty today, FT drop later
```

One line, keyed on the future M6 module id: today it's a no-op (module absent); when M6 ships (G4), its scenarios appear **at Final Table depth first** — "the FINAL TABLE unlocks the bettor's seat" — with zero changes to the run engine. M6 content itself is explicitly **out of G3 scope**.

---

## Rewards & storage

- Trophies by finish: 🥉 cash the bubble (L4) · 🥈 reach FT (L7) · 🏆 WIN (L8) — `rmtt_tourney.trophies` counts each; cabinet row on the Player Card; badges: 🏆 **Champion** (first win), 🎪 **Regular** (5 cashes).
- Run summary: finish + Stack line (ΣdecisionEV vs Σblinds reconciliation) + ghost compare + **killer-hand rematch** (re-drill the busting hand via the v4.4.5 redrill path) + Cash-out Receipt (mode prints TOURNAMENT).
- XP/Score: normal per-answer stream (no tournament multiplier — Score is already loud); win bonus +500 XP **first win only** (mirrors the boss first-pass precedent). *(Knob.)*
- Storage: `rmtt_tourney { bestRun, lastRun, trophies{cash,ft,win}, firstWinClaimed }` + loader round-trip (standing build gate).

## Acceptance (draft)

Decision deltas identical in/out of tournament (same scenario, assert equality) · drift only on transition beats, deterministic, labeled, schedule printed upfront · summary reconciles ΣdecisionEV + Σblinds = final stack · archetype sims reproduce §(c) curves (scripted QA run ×3) · ladder never scales regret (code has no level×delta term) · Range Reveal: hit-list report delivered, chips only in tourney on matched prose, zero numbers · Ghost bound ≤2 series · strict-mode isolation proven · M6 hook is a no-op today · 320×700 all screens · 0 console errors · data byte-identical + 510/0/0.

## Knobs

Drift schedule + level count/hands-per-level · start stack 100 · FT threshold L7 · win bonus +500 first-win-only · Table-Read interlude on/off · Range-Reveal band copy.

**STOP: awaiting owner review.**
