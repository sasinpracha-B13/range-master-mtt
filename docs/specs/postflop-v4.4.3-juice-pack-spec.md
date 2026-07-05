# v4.4.3 Juice Pack — Design Spec (FOR REVIEW · nothing built yet)

**Status:** SPEC ONLY. No code written, no data touched, no commit. Per the sprint brief: spec → owner review → build → QA evidence → review → approval → commit.
**Date:** 2026-07-04
**Scope:** runtime + UI + game layer only. `postflop_scenarios.json` byte-identical; validator stays 510/0/0; teaching blocks untouched; no timers; study-tool disclaimer untouched.

Design stance (per owner directive): **STACK = poker truth, never lies. SCORE/FX = loud game currency, owes nothing to realism.**

---

## 1. Two-Account Model

### 1.1 STACK account — "Session EV" meter (poker-honest)

Presented as a **net-EV meter starting at 0 BB each session** (e.g. `Session EV: +12.5 BB`), not a survival stack — sidesteps "starting stack" fiction entirely in drills; Tournament Mode (later sprint) is where a real survival stack + ambient drift lives.

Movement is **regret-based against the best line**, scaled by the spot's derived stake (§2):

| Answer (game-tier, §4.3) | Stack delta | On-screen label |
|---|---|---|
| best — hero **folds** | **0** | `✋ Saved {stake} BB` (folding = winning) |
| best — hero **checks** (M2 bettor node) | **0** | `✋ Pot control ✓` |
| best — hero **calls / bets / raises** | **+0.50 × stake** | `+{x} BB (est. EV)` |
| best — spot is **mixed** (either side) | **0** | `⚖️ Indifferent — 0 EV either way` |
| acceptable | **−0.25 × stake** | `−{x} BB (est. EV)` |
| bad | **−0.75 × stake** | `−{x} BB (est. EV)` |
| critical | **−1.50 × stake** | `🔥 PUNT −{x} BB (est. EV)` + shake/flash |

- All deltas are labeled **"est. EV (heuristic)"** in the UI tooltip/summary — never presented as solver numbers.
- Factors (0.50 / 0.25 / 0.75 / 1.50) are **tuning knobs** (§12) — poker rationale: a wrong call torches ≈ the bet you paid (≈1.0×stake lives between bad and critical); a critical raise-into-the-nuts torches more than the bet (hence 1.5×); an acceptable line is a small frequency error (0.25×).
- Perfect-session property (acceptance ✓): a flawless defense session full of correct folds reads `Session EV: +small` (from the few best-calls) or even `0.0 BB` **with a big Saved-BB ledger** — the Stack never lies; the fun comes from SCORE (§5), which climbs regardless.

### 1.2 SCORE account — game currency (loud by design)

`points = basePoints(tier) × comboMultiplier`, displayed big, with fire.

| game-tier | basePoints |
|---|---|
| best | 100 |
| acceptable | 40 |
| bad | 10 (participation — keeps the meter moving even on mistakes) |
| critical | 0 |

Bonuses (flat adds, after multiplier): finishing a session +150; Daily Challenge complete +300; personal-best combo +100. All numbers are tuning knobs.

---

## 2. Derived-Stake Table (from existing metadata ONLY — no new JSON fields)

### 2.1 Pot math from the canonical line (all modules share it)

SRP 100bb: BTN opens 2.5bb, BB calls, SB posts 0.5 dead →
- **Preflop pot = 5.5 BB**
- Flop: c-bet ~33% ≈ 1.8, called → **flop→turn pot ≈ 9.1 BB**
- Turn: barrel ~50–66% (midpoint ~58%) ≈ 5.3, called → **turn→river pot ≈ 20 BB**

### 2.2 Stake per scenario (`stakeBB`) — the price of THIS decision

| Module / node | Source of stake | stakeBB |
|---|---|---|
| M2 flop c-bet (hero = bettor) | representative c-bet into 5.5 pot | **3** |
| M3 flop defense (facing ~33% of 5.5) | spot line | **2** |
| M4 turn defense (facing ~50–66% of 9.1) | spot line | **5** |
| M5 river, `villainRiverSizing = small` (~33% of 20) | per-scenario field | **7** |
| M5 `medium` (~66%) | per-scenario field | **13** |
| M5 `large` (~100%) | per-scenario field | **20** |
| M5 `overbet` (~150%) | per-scenario field | **30** |

**The late-street property falls out automatically:** flop mistake −1.5…−4 BB · turn punt −7.5 BB · river overbet punt **−45 BB**. One critical on a big river erases a whole session of good work — which is exactly the MTT lesson, derived from data we already ship.

(Implementation: constants + one lookup on `scenario.module` / `board.villainRiverSizing`. M1 & reason_choice never consult this table — §4.)

---

## 3. Combo rule (single rule, no exceptions)

- **best → combo +1** (extends)
- **acceptable → combo holds** (no change, not broken)
- **bad / critical → combo breaks** (reset to 0, fire dies)
- Multiplier: `×(1 + 0.25 × combo)`, capped at **×3.0**; flame visual grows with streak (small → large → roaring at cap).

## 4. Scoping — which questions move which account

### 4.1 Frames
- **"At the Table" frame** (Stack + Score): `action_choice` scenarios from **M2–M5** (≈ M2 49 + M3/M4/M5 action subsets).
- **"Table Read" frame** (Score/combo ONLY, Stack never moves): **all M1** (251 board-typology) + **all reason_choice** from any module.

### 4.2 Visual distinction (fiction coherence)
- At the Table: felt-green header accent, Session-EV meter visible, chips fly on reveal.
- Table Read: blue "🔍 TABLE READ" ribbon, EV meter dimmed with `—`, no chip FX; score/combo FX identical (so reads still feel rewarding).

### 4.3 game-tier mapping (game layer only; teaching display unchanged)
`gameTier = (answer.best is 'mixed' or 'mixed_indifference_*' AND gradedTier == 'acceptable') ? 'best' : gradedTier`
- This implements "either side of a mixed spot counts as best" for Stack (0 EV), combo (extends), and Score (100), **without touching the honest teaching tier** shown in the feedback card (still "≈ ACCEPTABLE · 0.50 pts" there — invariant preserved).

## 5. Daily Challenge

- **5 hands/day, deterministic**: seed = `FNV-1a(dateString "YYYY-MM-DD")` → xorshift PRNG → picks from pools **sorted by scenario id** (stable across devices on the same data version).
- **Slot composition** (guarantees frame variety + late streets daily): `[M1 Table Read, M3 action, M4 action, M5 action, wildcard action from M2–M5]`.
- **One attempt/day**: `rmtt_daily` stores `{date, completed, evTotal, score, tiers[]}`; re-entry shows the result card, not the questions.
- **Calendar heatmap**: last 12 weeks grid (GitHub-style, 4 intensity levels by score); **daily-streak counter** = consecutive completed days (yesterday-anchored).
- Entry point: TCC tile `📅 Daily Challenge` + result card on Home; offline/PWA-reload safe (pure localStorage; date from device clock).

## 6. Saved-BB ledger + "Tight is Right" badge

- Every correct fold accumulates `savedBB += stakeBB` (session + lifetime).
- **Session summary block**: `✋ EV saved by correct folds: 34 BB` listed above score.
- **Lifetime badge track** (in `rmtt_gamestats`): Bronze 25 BB → Silver 100 → Gold 300 → GTO Wizard 1000 (knobs). Badge pop w/ confetti on tier-up.

## 7. SFX + Animation inventory

**SFX — Web Audio API synthesized, zero asset files** (offline-safe; created after first user gesture per autoplay policy):
`chipClink` (best call/bet) · `cardSnap` (deal/flip) · `comboRise` (arpeggio, pitch climbs with streak) · `puntSting` (low descending saw on critical) · `fanfare` (session/daily complete) · `foldSwish` (soft — Saved-BB moment).

**Animations (CSS-only, `transform`/`opacity` exclusively):**
- chips fly to/from the EV meter + count-up numbers (`font-variant-numeric: tabular-nums` — no layout shift)
- staggered card deal ~80ms/card; **river card gets a distinct flip beat** (pause → flip) for suspense
- screen shake (2 short cycles) + red vignette flash on critical
- combo flame grows/roars with streak; dies with a puff on break
- confetti burst (≤40 particles) + trophy pop on milestones (badge tier-up, daily complete, personal best)

**Hard constraints honored:** 60fps-safe properties only · `prefers-reduced-motion` auto-disables motion set · Settings gets **two toggles: Sound FX / Motion FX** (sound default ON per owner "loud" directive; motion default ON; reduced-motion overrides) · verified at 320×700 (no horizontal overflow) at build QA.

## 8. UI surfaces touched (all additive)

1. Question screen header strip: `Session EV ±X BB · Score N · 🔥×M` (dimmed EV in Table Read frame).
2. Answer screen: chip-fly + delta labels layered ABOVE the untouched teaching card.
3. Session summary: Session EV total + Saved-BB ledger + Score + best combo + badge progress (existing tier grid/breakdowns unchanged below).
4. TCC: Daily Challenge tile; Home: daily result card + streak.
5. Settings: Sound FX / Motion FX toggles.

## 9. Storage (new keys only — existing history/BetaQA schema untouched)

- `rmtt_gamestats`: `{lifetimeScore, lifetimeSavedBB, bestCombo, badges:{tightIsRight: tier}, sfxOn, motionOn}`
- `rmtt_daily`: `{lastDate, streak, history:{ "YYYY-MM-DD": {score, evTotal, completed} }}` (history pruned to ~120 days)
- Both ride into the existing backup payload automatically at build time (verify in QA).

## 10. Explicit non-goals this sprint

Tournament Mode / ambient drift · timed modes (none anywhere) · villain personas · XP/rank ladder · revenge hands · any scenario-data or teaching-copy change.

## 11. Acceptance mapping

Every checklist line in the brief maps to §1.1 (perfect-session + no-phantom-gain + punt-hurts), §4 (M1/reason never move Stack), §4.3 (mixed = 0 EV + combo extends), §2.2 (late-street costs more), §5 (determinism/one-attempt/persistence), §7 (toggles + reduced-motion + 320×700), invariants (data byte-identical, validator 510/0/0, teaching unchanged, disclaimer untouched, version bump 4.4.2→4.4.3 at build).

## 12. Tuning knobs awaiting owner review

| Knob | Proposed | Notes |
|---|---|---|
| Stack factors (best-call / acc / bad / crit) | +0.50 / −0.25 / −0.75 / −1.50 | crit river overbet = −45 BB (intended shock) — soften to −1.0 if too brutal |
| Score base (best/acc/bad/crit) | 100/40/10/0 | bad=10 is "participation"; set 0 if it feels cheap |
| Combo multiplier / cap | +0.25/streak, cap ×3 | |
| Badge tiers (Saved BB) | 25/100/300/1000 | |
| Daily slots | [M1, M3, M4, M5, wild] | could weight M5 harder |
| Sound default | ON | per "loud" directive; toggle always available |

**STOP POINT: awaiting owner review/approval of this spec before any build.**
