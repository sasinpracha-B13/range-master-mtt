# G4 · M6 "River Betting IP" (`pf_river_value_ip`) — Architecture & Schema Spec (FOR REVIEW · nothing built)

**Status:** ARCHITECTURE APPROVED (owner, 2026-07-05) with 1 PIN + knob rulings — recorded in §10 below. v4.5.1 planning artifacts (builder + 24 seeds + auditor) authored per those rulings; strategic review next; NOTHING COMMITTED.
**Date:** 2026-07-05
**Program fit:** G4 of the approved roadmap — M6 re-enters as the **Tournament Final-Table content drop** (the hook `level>=7 → pool.concat(allApproved('pf_river_value_ip'))` has been live as a no-op since v4.5.0). Curriculum surface (TCC tile / drills / Academy) comes **after** the FT debut, as its own sprint.

---

## 0. The module in one line

M5 taught the BB to *defend* the river OOP under polarization. **M6 flips the seat: hero is the BTN with the betting decision after BB checks the river** — the triple-barrel completion. Defining lesson: **value-bet thresholds, blocker-driven bluff selection, sizing polarity, and the discipline to give up or check back showdown value.**

## 1. Spot definition (hand-tree mirror of M5)

- Line: BTN opens 2.5x, BB calls (SRP, 100bb). Flop: BB checks, BTN c-bets, BB calls. Turn: BB checks, BTN barrels, BB calls. **River: BB checks. Hero (BTN, IP) acts.**
- `module: 'pf_river_value_ip'` · `street: 'river'` · `spot: 'btn_river_bet_ip'` · 5-card board (existing renderer, zero change).
- History chips end **`BB checks river`** (vs M5's `BTN bets river (sizing)`).
- Hero action space (choices[] ids; labels authored per scenario):
  - `check_back` — take showdown / give up
  - `bet_small` (~33%) — merged / thin-value region
  - `bet_big` (~75–100%) — polar value/bluff region
  - `overbet` (~150%) — nut-leveraged polarization (only where authored)
  - `mixed` — genuine indifference (M5 `mixed_indifference_river` precedent, Th9h)
- Per-scenario choices stay 3–4 (the engine renders choices[] generically — **no engine change**; sizes not offered in a spot are simply absent, same as M3/M4/M5 practice).

## 2. THE CORE RESOLUTION — frequency-native vs hand-verifiable, fixed AT SCHEMA LEVEL

Bettor-side river strategy is frequency-native (solvers mix bet/check at ratios), while the app's standing rule is: **every verdict must be defensible from the visible cards + authored reasoning — exact frequencies are NEVER authored from narrative.** Schema v1.4.0 resolves the collision with a mandatory field:

```
verdictBasis: 'clear_direction' | 'mixed_nudge' | 'solver_required'
```

- **`clear_direction`** — the action is essentially pure and hand-verifiable: nut/thick value bets (worse hands call), mandatory give-ups (no showdown value, no credible story), mandatory check-backs (bluff-catcher that beats bluffs only → betting folds out worse / gets called by better — verifiable by combo reasoning). Authored as normal best/acceptable/bad/critical tiers. **This is the module's teaching backbone (~75% of scenarios).**
- **`mixed_nudge`** — genuine indifference with a *qualitatively defensible* lean (blocker sidedness, kicker asymmetry): `recommendedAction: 'mixed'`, acceptable = the two mixed members, prose explains WHY it's close and what nudges it. Mirrors the shipped M5 pattern (Th9h straight-blocker mix). **No numeric frequency ever appears in prose or verdicts.** (~15–20%.)
- **`solver_required`** — the verdict hinges on an exact ratio/threshold that cannot be derived from visible combos. **HARD-BLOCKED from production**: new auditor rule (M6 block) fails any `solver_required` scenario with `auditStatus: 'approved'`. These spots live in a parked `docs/specs/…-m6-deferred-solver-spots.json` list until a real solver run exists; if one is ever promoted, it carries `sourceConfidence: 'consensus_gto'` + a `solverRunRef` note. **Zero of these ship in G4.**

Authoring rule of thumb (goes in the builder header + audit plan): *if the explanation needs a percentage to be true, it's `solver_required`; if it needs a blocker/kicker/combo argument, it's `clear_direction` or `mixed_nudge`.*

## 3. Schema v1.4.0 (delta over M5's 1.3.0 — bettor-side fields)

| Field | Values | Note |
|---|---|---|
| `verdictBasis` | enum §2 | **mandatory, M6-only** |
| `heroRiverSizing` | `small` / `medium` / `large` / `overbet` / `none` | the sizing the *best line* uses (`none` for check_back/mixed-without-bet); drives game stake §4 |
| `betPurpose` | `thick_value` / `thin_value` / `bluff` / `give_up` / `showdown_check` / `mixed_line` | teaching axis + analytics |
| `explanation.riverLogic` | prose | reused from 1.3.0 — stays the PROMINENT teaching block |
| `blockerNote` | prose | required when `betPurpose: 'bluff'` (bluffs must name their blockers) |

Everything else (board sub-doc, tiers, difficulty, concepts, sourceConfidence, auditStatus) is inherited unchanged. actionReason vocab (12, bettor-side): `value_bet_thick_river` · `value_bet_thin_river` · `polar_overbet_nut_river` · `blocker_bluff_river` · `give_up_no_equity_river` · `check_back_showdown_river` · `check_back_trap_risk_river` · `sizing_merge_small_river` · `sizing_polar_big_river` · `blocker_sidedness_mix_river` · `unblock_calls_value_river` · `story_consistency_bluff_river`. Concepts: 12 new entries in `postflop_concepts.json` (value threshold, thin-value discipline, bluff-candidate selection, give-up hygiene, sizing polarity, story consistency, …).

## 4. FT-hook fit — ZERO engine rework (enumerated)

| Touch point | What M6 needs | Engine change? |
|---|---|---|
| Pool entry | scenarios with `module: 'pf_river_value_ip'`, `auditStatus: 'approved'` | **None** — hook already concats at L≥7 |
| Difficulty ramp | author spread incl. D4–5 (FT prefers D≥4) | **None** — existing filter |
| Question render | `qtype: 'action_choice'` / `'reason_choice'`, choices[], 5-card board | **None** — generic renderer; only the history-chip line differs (data-driven prompt builder entry, same class as M5's) |
| Regret math | stake for the two-account model | **One mapping entry**: `_PF_GAME_STAKE_MOD['pf_river_value_ip']` derived from `heroRiverSizing` (small 7 / medium 13 / large 20 / overbet 30 — same table as M5's villain sizing; `none` → 13, the leverage of the bet you correctly didn't make). Game-layer constant, not engine logic — same class as M5's entry in v4.4.3 |
| Mode isolation | none extra | **None** — tournament already strict-gated |

The only *new* runtime work in the whole program is the eventual curriculum wire (TCC tile, drills, Academy) — deliberately AFTER the FT debut per the roadmap ("the FINAL TABLE unlocks the bettor's seat").

## 5. Range Reveal phrase discipline for M6 prose (band-compatible from day one)

M6 prose describes **hero's own line** (hero is the bettor). Authoring rules, binding for every seed:

1. When a sentence claims a line composition and the claim is true, **prefer the exact whitelist phrases**: `polar` / `polarized`, `value-weighted` / `value-heavy`, `merged`, `thin value`, `bluff-heavy`. No synonyms that would silently miss the whitelist (no "unbalanced toward bluffs", no "nutted-or-nothing").
2. **Never place a negator** (`not`, `n't`, `never`, `rarely`, `no longer`) within ~40 chars before a band phrase **unless suppression is intended** — restructure the sentence instead ("this is a merged bet, not a polar one" → suppressed `polar` is fine and intended; check each case against the guard).
3. `flush-dense` only ever describes a **range** (sentence must contain `range` or `value`) — never board texture.
4. Any false positive found in review goes into `_PF_REVEAL_SUPPRESS` by id — **never regex surgery** (locked precedent from the G3 line-review).
5. Chip extension to M6 is a **knob, default OFF**: if the owner enables it at FT, the copy flips person — `📡 Your line reads: <band>` (the read is of hero's own bet, not villain's). The hit-list routine reruns over M6 rows before any enable.

## 6. Seed plan — 24 seeds, 6 categories × 4

| Cat | Theme | Mix |
|---|---|---|
| A | Thick value (bet and get called by worse) | 4 clear |
| B | Thin value threshold (bet/check borderline — kicker + unblock arguments) | 3 clear + 1 mixed_nudge |
| C | Bluff selection (blocker-driven; busted draws that block calls) | 4 clear (blockerNote mandatory) |
| D | Give-up discipline (no equity, no story — check and lose the minimum) | 4 clear |
| E | Check-back showdown value (bluff-catchers that must not bet) | 4 clear |
| F | Sizing polarity (same hand, wrong size = punished; incl. 1 overbet + 1 mixed_nudge) | 2 clear + 2 mixed_nudge |

18 action_choice + 6 reason_choice · difficulty spread 2–5 with ≥8 at D4–5 (FT-ready) · ≥2 boards shared with M5 runouts (mirror-seat teaching) · every seed passes the §2 rule of thumb before authoring begins; anything that fails goes straight to the deferred-solver list, not into the seed batch.

## 7. Sprint pipeline & versioning (each step: owner review gate; standard 2-commit + snapshot)

1. **v4.5.1 (this spec approved → planning artifacts):** builder + 24-seed JSON + M6 seed auditor (incl. `verdictBasis` HARD rules + Range-Reveal prose lints as WARN) + audit plan. PLANNING-ONLY; production byte-identical.
2. **v4.5.1A:** strategic seed review (implementer-owned combinatorial verification, consultant advisory) → PROMOTE/REVISE/REJECT per seed.
3. **v4.5.2:** production migration (510 → ~534) + M6 production rule block in `audit-postflop-ps.ps1` (R94+) + concepts merge + cache bump. **FT DEBUT IS AUTOMATIC** — the hook goes live the moment approved M6 rows exist; QA = tournament reaches L7 and deals M6; drill surfaces still absent by design.
4. **v4.5.2A/B:** gap-first expansion (24 → ~40–60) driven by category coverage, same review loop.
5. **v4.5.3:** curriculum wire (TCC tile 🎯 Limited Beta, drills, Academy section, mastery checklist) — the only runtime sprint in the program.

## 8. Invariants (standing)

Data byte-identical **until v4.5.2 migration** (then add-not-replace; M1–M5 rows byte-preserved; validator target moves 510→534/0/0) · teaching blocks render fully · no timed pressure outside opt-in · "Study tool" disclaimer untouched · loader round-trip gate for any new stored field · PIN-1 drift invariant untouched (M6 adds pool members, not schedule changes — the +15 floor claim is pool-independent by construction) · no frequencies authored from narrative, ever.

## 9. Knobs for owner review

(a) seed count 24 vs 30 · (b) mixed_nudge share (planned 4/24) · (c) overbet inclusion at seed stage vs expansion · (d) Range-Reveal-on-M6 chip (default OFF; copy variant "Your line reads") · (e) stake mapping for `heroRiverSizing: 'none'` (proposed 13) · (f) whether v4.5.3 curriculum wire waits for FT-debut telemetry or ships immediately after expansion.

---

## 10. OWNER RULINGS (2026-07-05) — binding on all M6 sprints

**PIN — STAKE BASIS FIXED PER SCENARIO.** Stake must NOT derive from the player's chosen sizing (regret magnitude must never vary by input; same-scenario-same-delta and the in/out equality QA depend on it). Schema field **`stakeBasis`** (mandatory, enum `small`/`medium`/`large`/`overbet` → 7/13/20/30):
- bet-best rows: `stakeBasis` = the authored BEST line's sizing;
- check_back-best rows: `stakeBasis` = the sizing of the scenario's designated **temptation bet** (the bad/critical-tier bet the spot is built to punish), stated explicitly per scenario;
- mixed-best rows (sub-rule, implementer-proposed for review): `stakeBasis` = the sizing of the mix's PRIMARY bet member (the nudged-toward member, listed first in `answer.acceptable`).
QA at migration must assert per-scenario stake is constant across all player choices. This subsumes the earlier flat-13 proposal.

**Knobs ruled:** seed 24 (not 30) · mixed_nudge 4/24, and **every mixed row ships WITH its game-layer promotion whitelist entries in the same migration — never retrofitted** (planning field `mixedWhitelistChoices` per row) · overbet: 2–3 rows in seed (stake spread to 30 from day one) · chip-on-M6 default OFF, "Your line reads" copy validated before any ON · v4.5.3 curriculum wire does NOT wait for telemetry (FT debut = the telemetry channel).

**Disclosure (label map):** new choice ids (`check_back`/`bet_small`/`bet_big`/`overbet`) need one game-layer label-map entry at migration, same class as the stake-map entry — zero ENGINE rework stands (generic choices renderer + tier grader untouched).

**STOP points:** v4.5.1 planning + strategic review → owner approval → only then migration.**

**Flag rulings (owner, v4.5.1 seed review):**
1. **CHECK-BACK-NUTS joins the severe-punt taxonomy** (bettor-side mirror of the v4.4.1B list: fold-nuts / call-zero-SDV / raise-into-crush): checking back the nuts forfeits full value at zero risk → `critical` is correct. **Scope limit (machine-enforced, auditor M6.R24):** `critical` may contain `check_back` ONLY when `heroHandRole = nutted_value` AND `showdownValue = nutted`; thin-value check-backs grade `bad`, never `critical`. A4 approved as authored.
2. Big-bluff burning showdown value into an uncapped range = raise-into-crush class (active punt) → E1/D-row `critical=[bet_big|overbet]` approved; no taxonomy change.
3. Mixed stakeBasis sub-rule approved: primary member's sizing (first `acceptable` entry), enforced by M6.R14 as built.

**Seed line-review rulings (owner, v4.5.1):**
4. **F1 upgraded — check_back → critical.** Zero-combos-beaten effective nuts (unpaired board, no straight/flush possible, KK/QQ three-bet preflop in the baseline) = same offense class as A4. **Taxonomy bound (machine-enforced):** check-back grades `critical` **iff ZERO combos in villain's range beat hero**; if ≥1 combo beats hero (F4's single quads-2), check-back caps at `bad`. Schema semantics formalized: `showdownValue: 'nutted'` + `heroHandRole: 'nutted_value'` now MEAN zero-combos-beaten (F4 reclassified `strong_value`/`high` accordingly — prose keeps "effective nuts" colloquially, metadata encodes the bound). **M6.R24** (forward: critical check_back only on nutted rows) + **M6.R25** (reverse-lint: nutted rows besting a bet with check_back offered must grade it critical).
5. E4 blockerNote combo arithmetic corrected (QT 9→6 via hero's Td, not "halves"); D1 blockerNote rewritten to the true mixed profile (7/6 thin the folds AND the 7c clips part of the 97 straights; verdict stands on the uncapped-range argument); F4 riverLogic gains the self-verifying range qualifier "(AA three-bets preflop)". The three parked solver_required spots and both mirror-seat pairs passed review as authored.

**v4.5.2A expansion review rulings (owner):**
6. **F5 corrected — quad jacks impossible** (hero's Js + board Jh/Jd leave only the Jc): jacks-full-of-aces is ZERO-combos-beaten after the AA three-bet exclusion (77/33 fill smaller, JcAx chops) → `critical=[check_back]`, metadata `nutted_value`/`nutted`, prose carries the self-verifying enumeration. Same class as A4/F1/A5 — NOT F4 (whose quad deuces genuinely remain as 2d2c).
7. **Recompute lint closes the label-trust gap:** R25/R103/R104 trusted authored labels, which let the F5 mislabel through. New **M6.R29 (seed) / R107 (production)**: for any BOAT-OR-BETTER hero hand, RECOMPUTE combos-beating-hero by full 990-combo enumeration from board + hole cards, minus the AA/KK/QQ three-bet-baseline exclusions, and cross-check the authored nutted labels in BOTH directions. The F5 miss was reproduced by R29 before the fix and is clean after; F4's quad-deuces (1 combo) correctly passes as not-nutted.
8. **Check-primary mixed rows (future):** a mixed row whose nudge points to CHECK may list `check_back` as the primary (first acceptable) member; `stakeBasis` then = the sizing of the BET member (temptation-style fallback) and `heroRiverSizing = none`. Encoded in M6.R14 (seed) + R101 (production). Closes the structural gap that forced this batch's mixed candidates to be dropped; nudge direction is never forced to match a bet-side primary. No rows affected today.
