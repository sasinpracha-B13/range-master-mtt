# v4.5.4 · Chip-on-M6 Copy Validation + Daily M2–M6 (FOR REVIEW · nothing built)

**Status:** RULED — **Option C (chip OFF for M6)** + Daily M2–M6 knob. Owner ruling 2026-07-07 recorded in §8. Building the Daily knob + closing the chip loop; commit held for owner's final-diff review.
**Date:** 2026-07-07 · **Scope:** post-launch sequence item (1). Decide whether the Range-Reveal chip turns ON for Module 6, and how. Includes the owner-accepted Daily Challenge wildcard knob (M2–M5 → M2–M6). **RUNTIME/GAME-LAYER ONLY — production data byte-identical (542, blob `54f134f5…`); validator stays 542/0/0.** v4.5.4: chip stays OFF (no chip code change); only the Daily wild pool + a documenting code comment + cache bump ship.

---

## 0. The question

Range Reveal (G3) fires a tournament drama chip `📡 Table read: this is a <band>` on M4/M5 hands, sourced from a regex over authored prose. M6 was shipped with the chip **OFF** pending: (a) validate the person-flipped copy — M6 is the **bettor's seat**, so the read is of **hero's own line**, not villain's range; (b) rerun the hit-list over the 32 M6 rows and line-review before any ON ruling. This spec delivers both and recommends.

## 1. M6 hit-list — runtime `_pfRangeRevealBand` over all 32 rows

Raw result (runtime, mirrors what the chip would show if the module gate were opened): **7 bands** (5 polarized · 2 merged/thin-value) · 0 negation-suppressed · 25 no-chip. Line-review against the seat-flip (does the band describe **hero's own line**?):

| Row (frag) | best | Raw band | Matched sentence | Verdict |
|---|---|---|---|---|
| `Qc9d5s_3c…KhJd` (A4) | overbet | polarized | "…the textbook **polar** overbet target: every made hand bluff-catches, nothing beats you." | ✅ CLEAN — hero's nut-straight polar overbet |
| `KhTh4c_2s…QhJs` (C3) | bet_big | polarized | "…tilting villain toward hands that struggle against a big **polar** bet." | ✅ CLEAN — hero's big polar blocker-bluff |
| `Th7d2s_2h…TsTc` (F4) | mixed | polarized | "…those hands upgrade themselves to 'must bluff-catch' against a **polar** river." | ✅ CLEAN — hero mixes overbet/big (both polar) |
| `AsJh7c_Jd…AdJs` (F5) | overbet | polarized | "Both regions are built to pay a **polar** bet." | ✅ CLEAN — hero's near-nut boat overbet |
| `Qd7c4h_2d…AhTd` (E4) | **mixed** | merged/thin | "Hero's pair of tens…sits exactly at the line between **thin value** and showdown-taking." | ⚠ BORDERLINE — mixed row (bet-small OR check); the phrase names the hand's marginal status, not a committed merged bet → **recommend SUPPRESS (owner's call)** |
| `Qh8s3d_4s…AsTs` (E3) | **check_back** | merged/thin | "The '**thin value**' story fails on contact…there is no value bet, at any size." | ❌ FALSE POSITIVE — hero CHECKS; sentence NEGATES thin value → **SUPPRESS** |
| `Qs8h3c_9h…AdQd` (F2) | **bet_small** | polarized | "…any **polar** size trades them away for the second." | ❌ FALSE POSITIVE — hero's line is MERGED small; "polar" is the REJECTED size → **SUPPRESS** |

## 2. Structural finding (the load-bearing result)

The two false positives + one borderline are **not authoring slips** — they are a **seat-flip structural mismatch**. The band regexes were built for M5, where prose describes **villain's range**. M6 prose describes **hero's own sizing decision**, and good bettor-seat teaching routinely names the **rejected** option to explain the choice: *"any polar size trades them away"*, *"the thin-value story fails"*, *"a big bet isolates against exactly…"*. The negation guard (tokens: not / n't / never / rarely / no longer) cannot catch these because the negation is **semantic** ("fails", "trades away", "isolates against"), not a token. So M6's false-positive rate is structurally higher than M5's and will recur on any future M6 authoring — suppressions would be a permanent, growing maintenance tail, not a one-time cleanup.

Also note: after suppressing the 3, **all 4 surviving bands are "polarized"** (the merged/thin signals were exactly the false positives). A chip that can only ever say one word on M6, on ~4 of 32 rows, only at Final-Table depth, is thin drama for real mislabel risk.

## 3. Three options

**Option A — prose-regex band + person-flip copy (the literal "validate the current mechanism" path).**
Copy: `📡 Your line reads: <band>` (hero's own bet, never villain's). Requires seeding `_PF_REVEAL_SUPPRESS` with E3 + F2 (and E4 if the owner agrees), and opening the module gate in `_pfRangeRevealChipHtml` to include `pf_river_value_ip`. Ships ~4 always-"polarized" bands. **Carries the permanent structural false-positive tail (§2).**

**Option B — metadata-driven chip from authored `betPurpose` (recommended IF a chip is wanted).**
M6, unlike M5, carries an **authored field describing hero's own line**: `betPurpose ∈ {thick_value, thin_value, bluff, give_up, showdown_check, mixed_line}`. A chip sourced from it is **100% accurate by construction** — no regex, no prose false positives, no suppression list, zero maintenance tail — because it reads authored intent, not narrative. Copy map: thick_value → "Your line reads: **value**"; thin_value → "**thin value**"; bluff → "**a bluff**"; mixed_line → "**a mix**"; give_up / showdown_check → **no chip** (there is no bet to read). Covers all bettable rows, stays numberless, never shows a villain hand. Trade-off: it reads as a **confirmation label** of what hero just did rather than a "reveal" of hidden info — arguably less dramatic than the villain-range read on M4/M5, but honest and maintenance-free. (This is M6-only; M4/M5 keep the prose-regex mechanism unchanged.)

**Option C — keep the chip OFF for M6 (the safe default).**
M6's full teaching blocks already state the line composition explicitly (River Logic + Sizing Logic every hand). The chip adds little the answer screen doesn't already teach, and OFF carries zero mislabel risk. No code change beyond leaving the gate as-is.

## 4. Recommendation

**Option C as the default, Option B if the owner wants a Final-Table drama beat on M6.** Option A is not recommended — it buys the least (4 one-word bands) for the most (a permanent structural suppression tail). If the owner picks B, I'll bring the full `betPurpose → copy` table and the exact fire conditions (tourney-only, bettable rows only) as the build step. If A, I'll bring the E3/F2(/E4) suppression entries + the person-flip copy. Either ON path stays tournament-only and numberless; the drill/curriculum surfaces never show the chip.

## 5. Daily Challenge wildcard M2–M5 → M2–M6 (owner-accepted knob — independent of the chip decision)

The Daily builder's 5 fixed slots stay `[M1, M3, M4, M5, wildcard]` (formula locked). Only the **wildcard pool** changes: `actionOnly(M2 ∪ M3 ∪ M4 ∪ M5)` → `… ∪ M6`. One added `.concat(actionOnly(getModule6Scenarios()))`. Deterministic FNV/xorshift selection unchanged; the wild slot simply can now surface an M6 bettor-side hand. Ships regardless of the chip ruling. QA: a fixed seed date that lands the wild slot on M6 renders correctly through the daily flow; determinism preserved (same date → same queue).

## 6. Gates

Data byte-identical (blob `54f134f5…`) · validator 542/0/0 · chip (if ON) tournament-only + numberless + no villain hand + drill/curriculum chip-free · Daily determinism preserved · 320×700 on any new chip surface · 0 console errors · appVersion + SW bump on build.

## 7. Knobs for owner ruling

(a) **Chip decision: A / B / C** (recommend C default, B if a beat is wanted) · (b) if A: whether E4 joins E3+F2 in suppression · (c) if B: the `betPurpose→copy` wording · (d) Daily M2–M6 knob confirmed ON (accepted) — ships either way.

---

## 8. OWNER RULING (2026-07-07) — Option C

**Chip-on-M6 = OPTION C (OFF as default).** Recorded rationale:

- **Structural finding accepted** as a seat-flip mismatch, not row-level slips: M6 prose describes hero's OWN sizing and good teaching names the REJECTED option, producing **semantic-negation** false positives (E3 *"fails"*, F2 *"trades away"*) that the token-based negation guard cannot catch. **This recurs on every future M6 batch** — so any ON path via the prose-regex carries a permanent, growing suppression tail.
- **Option A rejected** — least drama (4 always-"polarized" bands) for the most cost (permanent suppression-tail maintenance).
- **Option B rejected** for a subtler reason: echoing authored `betPurpose` only **restates** what the answer screen's River Logic + Sizing Logic already teach every hand (a confirmation label, not a hidden-info reveal), and labeling "this is a value bet" post-choice on the bettor seat carries **mild results-oriented risk**. Low value, nonzero risk.
- **Option C chosen** — ZERO mislabel risk and forfeits no teaching (line composition is already taught on every M6 answer screen).

**No band chip renders for M6 under any mode.** The Range-Reveal regex path stays dormant for `pf_river_value_ip`: `_pfRangeRevealChipHtml` gates to `pf_turn_barrel_oop_def` / `pf_river_barrel_oop_def` only, so M6 is excluded in tourney and never reached in drill/curriculum/boss/daily (chip is tourney-only regardless). A documenting code comment marks the M6 exclusion as an intentional owner ruling so no future dev opens the gate without re-review.

**PARKED FOLLOW-UP (not now; needs authored prose):** a *true* M6 drama beat would reveal **BB's CHECKING RANGE** — the information the player genuinely can't see — mirroring G3's aggressor-range reveal from the other seat. This requires NEW authored, band-compatible prose describing BB's check-range (the current M6 prose describes hero's own line, which is why the naive chip mislabels). Logged as an **expansion-batch candidate** for a future M6 sprint; do NOT build now.

**Daily wildcard M2→M6: ACCEPTED as built** — the 5-slot formula `[M1, M3, M4, M5, wild]` stays locked; only the wild pool gains `∪ M6`; deterministic FNV/xorshift selection unchanged. Ships with this sprint (v4.5.4).

## 9. Build + QA evidence (v4.5.4, commit held)

**Built (index.html + SW; cache 4.5.3 → 4.5.4):**
- Daily wild pool `+ actionOnly(getModule6Scenarios())` — 5-slot formula `[M1, M3, M4, M5, wild]` untouched.
- `_pfRangeRevealChipHtml` gains a documenting comment: M6 deliberately excluded (Option C, structural reason), "do not open the gate without re-review; a true M6 chip needs BB-check-range prose." **No functional change — M6 was already excluded; the comment prevents a future accidental enable.**
- appVersion 4.5.3 → 4.5.4; SW v4.5.3 → v4.5.4.

**QA (fresh SW, real engine):** appVersion 4.5.4 rendered · data blob `54f134f5…` byte-identical · validator 542/0/0. Daily: `_pfDailyPickQueue` **deterministic** (same date → identical queue), **5-slot** preserved, wild pool now surfaces M6 (2026-07-06 wild slot = `…Ac7d4s_2c_m6_action_AhJh` B4). Forced-date daily run: mode daily, queue 5, M6 hand renders the **seat-flip** ("BB checks river · you act", "Your Hand (BTN)") inside the mixed-module daily queue (renderer is module-driven — same path proven in the v4.5.3 M6 drill QA). **Chip-loop closed:** `_pfRangeRevealChipHtml` returns '' for the M6 scenario in BOTH `tourney` and `daily` modes. **0 console errors.**

**STOP: Daily knob + chip-loop comment built and QA'd; commit held for owner's final-diff review. Advancing to ledger item (2) M4 audit under ARRIVAL LEGITIMACY — spec-first, below.**
