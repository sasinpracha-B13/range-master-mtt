# Brief STUB — v4.0.3: Post-flop Module 2 — Flop C-bet IP Trainer

> **Status**: stub. Placeholder only — written to lock module identity and key decisions early. Full brief comes after v4.0.2 ships and we have engagement data.
> **Predecessor**: v4.0.2 (Module 1 — Board Texture Trainer UI).
> **Owner once active**: Architecture Subagent (full brief), then DEV Integration Agent (implementation).

---

## 1. Goal (working draft)

Add **Module 2 — Flop C-bet IP Trainer** as the second visible postflop module, surfacing the 11 hand-decision scenarios already in `postflop_scenarios.json` (`module === "pf_flop_cbet_ip"`).

Difference from Module 1: questions show a **hero hand** plus the board, and the player chooses an **action** (`check`, `bet_33`, `bet_75`) rather than answering a board-classification question.

---

## 2. Why this is a separate module (not just "more Module 1 questions")

| Dimension | Module 1 (Board Texture) | Module 2 (Flop C-bet IP) |
|---|---|---|
| Question type | Board-only labeling | Hero-hand action choice |
| Hero hand visible | No | Yes (2 cards) |
| Skill emphasized | Read board → infer range/nut adv | Combine board + hand class → pick action |
| Cognitive load | Lower | Higher |
| Action consequences | Conceptual ("who has range adv") | Behavioral ("check or bet 33%?") |
| Best for | First-time postflop learners | Players who passed Module 1 |

Different skill, different UX surface, different gating.

---

## 3. New UI elements vs Module 1

Most of the chrome is reusable. New elements:

- **Hero hand row** between SPOT and BOARD: 2 cards, smaller than board cards (44 × 64 px on mobile vs 56 × 80 px for board)
- **Hand class badge** above hand row (e.g., `top_pair_top_kicker`, `combo_draw`)
- **Action buttons** with semantic colors (existing `.action-btn-fold/call/raise` reusable):
  - `Check` — neutral
  - `Bet 33%` — amber/yellow (smaller bet)
  - `Bet 75%` — red/orange (bigger bet)
- **Frequency mixing display on feedback**: when scenario has `mixing` populated, show a small frequency bar (Check 5% · Bet 33% 75% · Bet 75% 20%)

---

## 4. Gating (proposed)

Module 2 only appears on Home tab if:
1. `postflopBeta === true`
2. Player has completed at least 1 Module 1 session (any score)
3. OR an explicit "Skip Module 1 gate" toggle exists in Settings (for testing)

This nudges new players through the foundation skill (board reading) before throwing hand-decision spots at them.

---

## 5. Scope considerations

**In scope (when activated)**:
- Action choice UI (3 buttons)
- Hero hand display
- Same multi-tier scoring + multi-section explanation
- Same summary screen (with `By action chosen` breakdown added)
- Same Settings beta gate

**Out of scope** (defer further):
- Solver-frequency mixing display (defer to v4.0.5)
- Per-hand SRS (defer to v4.0.4 — applies to both modules)
- Boss/exam integration (v4.2+)

---

## 6. Data readiness

11 scenarios currently exist in `pf_flop_cbet_ip` module:
- 5 on AhKd5c with various hands (AKc, QQ, 76s, Td9d, 55)
- 1 on KhTd2s with QJs (semi-bluff)
- 1 on 8h7c6s with AA (overpair on dynamic — check)
- 1 on JhTs9c with QQ (overpair on connected — mostly check)
- 1 on AhJh3s with KhQh (combo draw)
- 1 on 6c5c4s with KK (overpair on wet — check)
- 1 on KhTd2s with TT (set on dry — bet)

Concerns to address before shipping (Scenario Review may need a Module 2 pass):
- Same hint-text inconsistency risk as Module 1
- Action-choice questions have less ambiguity than freq-strategy → easier to grade
- 11 scenarios is small for a `random 10` session; recommend padding to 20–25 in v4.1 data expansion

**Recommendation**: ship v4.0.3 with all 11 scenarios in shuffle; default session length 10 (vs Module 1's 15).

---

## 7. Open questions for v4.0.3 planning

1. Does Module 2 get its own Home card, or share a "Postflop Beta" container with Module 1?
2. Should the Module 2 gate (require Module 1 completion) be soft (warning) or hard (blocked)?
3. Is the action menu fixed at `check / bet_33 / bet_75` for v4.0.3, or do we need a 4th option for `bet_50` mid-sizing?
4. Frequency mixing display — bars (richer UI) or numbers (faster build)?
5. Should `By action chosen` breakdown on summary call out the player's "fold-equity" pattern (e.g., "you check 60% of spots")?
6. What's the path from Module 1 completion to Module 2 unlock — auto-prompt, toast, or just "now visible on Home"?

---

## 8. Estimated effort

If v4.0.2 architecture (data accessors + session state + render functions + Settings gate) is reused:
- v4.0.3 implementation ≈ 60% of v4.0.2 effort
- Largely additive; new components (hand row, action buttons, mixing display)
- Same QA matrix structure with Module-2-specific adjustments

---

## 9. Stop condition

This is a **stub**. Full v4.0.3 brief will be written after:
1. v4.0.2 ships and runs in production for ≥ 1 session
2. Player engagement data shows whether Module 1 completion drives Module 2 demand
3. Any Module 1 lessons-learned are integrated (UX adjustments, scoring tweaks)

The stub locks: module identity, gating philosophy, key decisions, and 11-scenario data inventory. Don't expand it further until v4.0.2 settles.

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | Orchestrator | Initial stub publication during v4.0.2 planning sprint |
