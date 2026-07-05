# G1 · v4.4.4 Progression Core — Design Spec (FOR REVIEW · nothing built)

**Status:** SPEC ONLY. Per program order: spec → owner review → build → QA evidence → review → approval → commit.
**Date:** 2026-07-05
**Scope:** display/meta game layer only. Data byte-identical; validator 510/0/0; no grading/teaching/timing changes; toggles + reduced-motion inherited from v4.4.3.

---

## 1. XP — one currency, already flowing

**XP ≡ Score.** The v4.4.3 Score (tier base × combo) *is* the XP stream; `rmtt_gamestats.lifetimeScore` has tracked it since v4.4.3. G1 builds the ladder on top — no new earning mechanic to balance, no second currency to explain.

- Postflop: XP accrues exactly where Score accrues (`_pfGameOnAnswer`) — zero new hooks.
- **Preflop**: flat mapping — correct answer +25 XP, incorrect +5 (participation), exam/boss completion +200. Hook = preflop answer handler (single site, identified at build). **Fallback scope-guard:** if the preflop handler proves risky to touch, G1 ships postflop-only XP and preflop lands as G1.5 — disclosed, not silent.
- **Retroactive credit:** on first G1 boot, `xp` seeds from existing `lifetimeScore` → long-time players instantly pop their earned rank ("You're already a Reg!") — the cheapest wow moment in the program.

## 2. Rank ladder — Player Level (8 ranks)

| Rank | XP | Rank | XP |
|---|---|---|---|
| 🐟 Fish | 0 | 💪 Crusher | 50k |
| 🎣 Grinder | 2.5k | 🦈 Shark | 100k |
| ♟️ Reg | 7.5k | 👑 Elite Pro | 200k |
| 🛡️ Solid Reg | 20k | 🧙 GTO Wizard | 400k |

~2.9k/perfect-session pacing → Grinder day 1, Reg in ~3 sessions, Wizard = a long honest arc. All thresholds = tuning knobs.
**Unification policy (important):** the existing *preflop mastery ranks* (`rmtt_profile`) stay **untouched** — they measure preflop mastery; Player Level measures overall grind. Profile card shows both. Build step 0 = inventory `rmtt_profile`/`rmtt_streaks` to confirm zero naming/storage collisions.

## 3. Badge engine + launch set (12)

Declarative defs `{id, icon, name, desc, target, compute(historyAgg, gamestats, daily)}` → progress/unlocked; recomputed on session-complete + profile open (aggregation over existing `rmtt_postflop_history` answers[] joined to scenarios for actionReason/street — all data already persisted since v4.3.2C).

| Badge | Unlock | Badge | Unlock |
|---|---|---|---|
| ✋ Tight is Right I–IV | saved BB 25/100/300/1000 *(live — folds into case)* | 🌊 River Rat | 100 correct river answers |
| 🛡️ MDF Defender | 25 correct on mdf/bluff_catch reasons | 🎯 Turn Guardian | 100 correct turn answers |
| 🃏 Blocker Brain | 15 correct on blocker_* reasons | 🔍 Table Reader | 100 correct Table Reads |
| 🧼 Clean Sheet | perfect session (≥10q, 0 bad/crit) | 📅 Daily Devotee / ⚔️ Iron Streak | 7 / 30-day daily streak |
| 🚫 No-Punt Grinder | 10 sessions with 0 critical | 🔥 Combo King | combo ≥ 12 |
| ♟️ Making It | reach Reg | 🧙 The Long Game | reach GTO Wizard |

Unlock moment: toast + fanfare + confetti (existing v4.4.3 FX, same toggles).

## 4. Player Card UI

Mount: top of **Progress tab** + compact strip on Academy home. Contents: rank emoji/name + XP bar to next rank (tabular-nums count-up) + badge case (grid; locked = dimmed w/ progress bar) + lifetime row (hands · sessions · saved BB · best combo · daily streak). Level-up: full-card confetti + rank-up banner. 320px verified like everything else.

## 5. Storage

`rmtt_gamestats` extends: `{ xp, rankIdx, badges: { id: {unlocked, progress} } }` (+ existing fields). One-time migration seeds `xp = lifetimeScore`. No changes to `rmtt_postflop_history` / BetaQA / preflop keys. Rides existing backup payload.

## 6. Invariant risk: **LOW**

Read-only aggregation + display; no grading, no data, no timers, no teaching changes. Only nuance: preflop XP hook touches one preflop handler (scope-guarded, §1).

## 7. Acceptance (draft)

XP accrues postflop (=score) & preflop (+fallback disclosed) · retroactive seed pops correct rank once · ranks/badges compute correctly from seeded fixture histories · badge unlock fires once (no re-fire) · Player Card renders 320px clean · toggles/reduced-motion respected · data byte-identical + 510/0/0 · 0 console errors.

## 8. Knobs for review

Rank thresholds (§2) · preflop XP values (25/5/200) · badge targets (§3) · Player Card placement (Progress-tab-first vs Home-first).

**STOP: awaiting owner review.**
