# G2 · v4.4.5 Challenge Layer — Design Spec (FOR REVIEW · nothing built)

**Status:** SPEC ONLY. Per program order: spec → owner review → build → QA evidence → review → approval → commit.
**Date:** 2026-07-05
**Scope:** game layer only. Data byte-identical; validator 510/0/0; FX via the v4.4.3 pipeline; 320×700 verified at build. Three features: Boss Exams, Revenge Hands, Villain Personas.

---

## 1. Boss Exams — one per module (M1–M5, 5 trophies)

**The ONE sanctioned use of deferred feedback**, per the standing policy locked at the roadmap approval.

### Flow
1. Entry: "⚔️ Boss Exam" button on each module's curriculum card + a Boss row in the TCC (menu listing the 5 bosses + trophy status).
2. **Exam phase:** 10 questions from that module's hardest pool — `difficulty ≥ 4`; if the module has < 10 such scenarios, fall back to difficulty ≥ 3 to fill (fill counts disclosed on the intro screen, e.g. "8 × D4-5 + 2 × D3"). No hints, no choice-guide details, no per-answer feedback: answer → "🔒 Answer locked · Next hand" → next question. BOSS header frame (dark-red accent) + persona intro line (§3). Stack/Score accrue silently (no banners/FX mid-exam).
3. **Pass gate:** teaching-score ≥ 80% (Σ points / 10 ≥ 8.0 on the standard 1.0/0.5/0 scale).
4. **End-of-exam review page (policy-bound):**
   - Verdict banner: pass (trophy pop + fanfare + confetti) or fail ("Boss holds the table — 6.5/10. Retake anytime.")
   - **Per-question card list, ALL 10 questions: verdict tier + the module's FULL standard teaching block (`_pfM*TeachingFeedbackBlocksHtml` — unabridged) + board/hand recap.**
   - **Per missed hand: "↻ Re-drill this hand" button** → starts a normal 1-question drill of that scenario (full immediate feedback). Plus one "🎯 Drill all misses (N)" convenience button.
5. Retake anytime, unlimited, honest copy. Best % + attempts stored.

### Guardrails (invariant enforcement)
- Deferral is keyed to `mode === 'boss'` ONLY; normal/concept/weak-spot/daily/revenge paths are untouched (explicit QA check: every other mode still shows immediate feedback).
- The review page renders via the SAME teaching-block functions — no abridged copies to drift.

### Rewards
- Trophy per module in `rmtt_gamestats.trophies { m1..m5: { earned, bestPct, attempts } }`; trophy shelf row added to the Player Card.
- **Exam completion = the +200 XP live earner** (approved G1 mapping, scope-guarded to live play): +200 on completion, pass or fail (completion bonus; the trophy is the pass reward). *Knob: owner may prefer +200 only on pass.*
- New badge: 🏆 **Boss Slayer** — earn all 5 trophies (registry is declarative; 1-line addition).

## 2. Revenge Hands — resurface real punts

- **Source: real history only** — scan `rmtt_postflop_history.sessions[].answers[]` for `tier === 'critical'` entries (knob: include `bad`), newest-first, unique by scenarioId, minus already-cleared → the Revenge queue (cap 8/session).
- **Cleared** = answering that scenario at teaching tier `best` inside a Revenge session → `rmtt_gamestats.revenge.cleared[scenarioId] = ts` + "✅ Punt avenged!" moment (chip SFX + pop).
- Session = NORMAL drill flow (full immediate feedback — Revenge is a learning mode, not an exam) with a "⚔️ REVENGE" frame badge and per-hand context line: "You punted this hand before — make it right."
- Entry: TCC tile "⚔️ Revenge Hands" with live count ("3 punts await") + Academy row; honest empty state ("No punts on record. Keep it that way.").
- New badge: ⚔️ **Avenger** — clear 10 revenge hands.
- Re-punt behavior: hand stays in the queue (it's real history; no mercy, no re-adding duplicates).

## 3. Villain Personas — cosmetic only, zero strategic claims

| Module | Persona | Flavor |
|---|---|---|
| M2 | 🧱 "Station Sam" (BB) | calls too much — you're value-betting him |
| M3 | 🤖 "C-bet Carl" (BTN) | auto-c-bets every flop |
| M4 | 🔨 "Barrel Bob" (BTN) | loves the second barrel |
| M5 | 🎭 "Triple-Barrel Trey" (BTN) | fires all three streets |

- One intro line on the question screen ("🔨 Barrel Bob fires again…") + one short quip on the answer banner (win/lose variants, rotating 3–4 per persona). Table Read frames get none (no villain).
- **No-claims checklist (build gate):** persona copy may NOT contain frequencies, ranges, "always/never" strategy assertions, or anything contradicting scenario prose — flavor text only, reviewed line-by-line in QA evidence.
- Settings toggle "Villain personas" (default ON), rides `rmtt_settings`.

## 4. Storage & risk

- `rmtt_gamestats` extends: `trophies{}`, `revenge{cleared{}}`; badges registry +2 (Boss Slayer, Avenger). No new keys; BetaQA/history untouched.
- Risk: **Boss = MEDIUM** (the sanctioned deferral — mode-gated + QA'd); Revenge = LOW (normal flow reskin + real-data queue); Personas = LOW (copy-only + checklist).

## 5. Acceptance (draft)

Deferred feedback exists ONLY in boss mode (normal/concept/weak/daily/revenge verified unchanged) · end-review renders FULL teaching for all 10 + working per-miss re-drill links · pass ≥80% ⇒ trophy persists + Player Card shelf · boss pool difficulty rule + fill disclosure correct per module · +200 XP on completion (live-only) · Revenge queue built from real criticals only, clear-on-best persists, count accurate · persona copy passes no-claims checklist, absent in Table Reads, toggle works · data byte-identical + 510/0/0 · 0 console errors · 320×700 clean.

## 6. Knobs for review

+200 on completion vs pass-only · boss length 10 · pass gate 80% · revenge source (critical-only **[proposed]** vs critical+bad) · revenge cap 8 · persona default ON · Boss Slayer/Avenger targets.

**STOP: awaiting owner review.**
