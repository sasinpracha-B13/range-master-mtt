# Human Review Checklist — Postflop v4.0.2 Approval

> **Audience**: human reviewer (you) deciding whether to approve v4.0.2 implementation.
> **Status**: ready for use. Tick each item before saying "approve" or "request changes."
> **Estimated time to walk this checklist**: 30–45 minutes (reading) + 15–20 minutes (manual app verification).

---

## How to use

This checklist takes you through the v4.0.2 planning package in roughly 30–45 minutes of reading. It's structured so you can stop at any section and say "request changes" if something is off — you don't need to walk to the end before deciding.

Read order is **top-down**. Each item has:
- ✅ what to check
- ❓ a yes/no judgment
- 📝 a place to log a concern if any

When you're done, the bottom section asks for your overall verdict.

---

## Section 1 — Architecture (required)

**Read**: `docs/specs/brief-v4.0.2-module1-board-texture-trainer.md` (Architecture brief, ~10 min)

| ✅ | Check | ❓ Yes/No |
|---|---|---|
| 1.1 | Module 1 scope (board texture only, no hero hand) is appropriate as the first visible postflop UI | ☐ |
| 1.2 | Beta-gated entry on Home tab (`postflopBeta` flag, default off) is a good rollout pattern | ☐ |
| 1.3 | Read-only consumption of `App.postflop` (no mutation, no preflop coupling) is correctly enforced | ☐ |
| 1.4 | New session-state namespace `App.state.postflopDrill` doesn't conflict with anything existing | ☐ |
| 1.5 | The "files allowed to edit" list (§ 4) is acceptably narrow | ☐ |
| 1.6 | Rollback strategy (§ 11) is realistic — beta off + revert as fallback | ☐ |
| 1.7 | The 7 open questions in § 14 have orchestrator recommendations you agree with (or disagree-and-block) | ☐ |

📝 Concerns:
```


```

---

## Section 2 — UX (required)

**Read**: `docs/specs/postflop-v4.0.2-ux-plan.md` (UX plan, ~10 min)

| ✅ | Check | ❓ Yes/No |
|---|---|---|
| 2.1 | Mobile-first 375 px layout is the right baseline | ☐ |
| 2.2 | Two-tier feedback (short answer first, sections collapsible) is the right reveal pattern | ☐ |
| 2.3 | Result tier colors + icons (✅ best / ≈ acceptable / ❌ bad / 🚨 critical) are clear and accessible | ☐ |
| 2.4 | Critical-leak amber emphasis + auto-expand commonMistake feels right (not too punishing, not too quiet) | ☐ |
| 2.5 | Postflop screen NOT inheriting Field FX (analytical surface) is the right design call | ☐ |
| 2.6 | Concept tag pills as static text (clickable v4.0.5) is acceptable for v4.0.2 | ☐ |
| 2.7 | Summary screen (per-tier + concept mastery + critical leaks) shows the right level of detail | ☐ |
| 2.8 | Confirm-exit modal pattern matches existing app conventions | ☐ |
| 2.9 | Animation budget (no particle bursts, no field overlays) is appropriate for a study tool | ☐ |
| 2.10 | The 5 UX open questions in § 16 have answers you can live with | ☐ |

📝 Concerns:
```


```

---

## Section 3 — Scenario Review (required — read carefully)

**Read**: `docs/specs/postflop-v4.0.2-scenario-review.md` (~15 min including spot-checks)

This is the highest-value section to read carefully. The independent reviewer surfaced real concerns.

| ✅ | Check | ❓ Yes/No |
|---|---|---|
| 3.1 | The grade table (§ A) makes sense — most scenarios are SHIP-FIRST, three are SHIP-LATER, one HOLD | ☐ |
| 3.2 | Concern B1 (#11 GTO disagreement on T-high monotone) — you accept the reviewer's reading OR have a defensible counter-argument | ☐ |
| 3.3 | Concern B1 (#20 GTO + "wait" artifact) — you agree this is a HOLD | ☐ |
| 3.4 | Concern B2 (#20 "wait, 77 impossible" leftover) — must-fix before v4.0.2 ship | ☐ |
| 3.5 | Concern B3 (choice label hint inconsistency) — agree to strip hints in a pre-ship data fix | ☐ |
| 3.6 | Concern B4 (missing concept tags) — fine to defer to v4.0.5 (additive, not user-visible until concept-tag click is implemented) | ☐ |
| 3.7 | Concern B5 (difficulty mis-rating) — accept the slight inconsistencies for v4.0.2 | ☐ |
| 3.8 | Recommended 15-scenario smoke set (§ C) is a sensible first-session arc | ☐ |
| 3.9 | Top 3 risks (§ E) are accurately characterized | ☐ |
| 3.10 | **Spot-check 3 scenarios yourself** — pick any 3 you have strong opinions on; verify the `best` answer | ☐ |

📝 Concerns or disagreements with the reviewer:
```


```

📝 Spot-check results (which 3 scenarios? did you agree?):
```


```

---

## Section 4 — QA Plan (required)

**Read**: `docs/specs/postflop-v4.0.2-qa-plan.md` (~5 min, or skim)

| ✅ | Check | ❓ Yes/No |
|---|---|---|
| 4.1 | The 7 categories (A–G) cover the right surfaces | ☐ |
| 4.2 | 52 items is acceptable depth (not too few, not so many it becomes performative) | ☐ |
| 4.3 | Pre-implementation gates (G1–G6) are the right pre-conditions | ☐ |
| 4.4 | Pass criteria (e.g., 8/8 preflop regression as release blocker) are firm enough | ☐ |
| 4.5 | Diff scope check (§ 12) is the right discipline | ☐ |
| 4.6 | Manual play-through (§ 14) is realistic — you can do it OR delegate it | ☐ |

📝 Concerns:
```


```

---

## Section 5 — Consolidated Implementation Brief (required — final check)

**Read**: `docs/specs/brief-v4.0.2-implementation-ready.md` (~5 min — this is the actionable spec)

| ✅ | Check | ❓ Yes/No |
|---|---|---|
| 5.1 | The brief faithfully consolidates the 4 source documents (no surprises) | ☐ |
| 5.2 | Implementation sequence (§ 17) — data fix first, then v4.0.2 — is the right order | ☐ |
| 5.3 | The temp-exclude filter for #10, #11, #20 (§ 15) is the right v4.0.2 compromise | ☐ |
| 5.4 | The 10 open questions (§ 14) all have orchestrator recommendations you can either accept or override | ☐ |
| 5.5 | Hard guardrails (§ 12) and stop conditions (§ 11) are well-specified | ☐ |

📝 Concerns:
```


```

---

## Section 6 — Risk register update (recommended)

**Read**: `docs/specs/postflop-risk-register-update.md` (~5 min)

| ✅ | Check | ❓ Yes/No |
|---|---|---|
| 6.1 | The 4 new risks (R-14 through R-17) are real and the mitigations make sense | ☐ |
| 6.2 | The 4 status updates to existing risks (R-02, R-04, R-05, R-07) are accurate | ☐ |
| 6.3 | The "Top 5 risks for v4.0.2" prioritization is right | ☐ |

📝 Concerns:
```


```

---

## Section 7 — App-side manual verification (recommended, ~15 min)

If you have local server running, open: `http://localhost:8765/index.html`

| ✅ | Check | ❓ Yes/No |
|---|---|---|
| 7.1 | App boots normally — no console errors | ☐ |
| 7.2 | DevTools console: `App.postflop.ready === true` | ☐ |
| 7.3 | DevTools console: `App.postflop.scenarios.filter(s => s.module === 'pf_board_texture').length === 20` | ☐ |
| 7.4 | DevTools console: `App.postflop.concepts.concepts.length === 24` | ☐ |
| 7.5 | All 5 tabs render normally (no postflop UI yet — that's the point of v4.0.1) | ☐ |
| 7.6 | Run a 5-hand preflop drill — works as before | ☐ |
| 7.7 | (Optional) Manually browse `postflop_scenarios.json` for 1–2 of the scenarios you spot-checked in 3.10 — does the JSON match your expectation of the "best" answer? | ☐ |

📝 Anything that looked off:
```


```

---

## Section 8 — Decisions on open questions

Per `brief-v4.0.2-implementation-ready.md` § 14, ten open questions need answers (or "defer with note"). Mark each:

| # | Question | Recommendation | Your decision |
|---|---|---|---|
| 1 | Session history persistence | Session-only in v4.0.2 | ☐ accept ☐ override: ___ |
| 2 | Default session length | 15 | ☐ accept ☐ override: ___ |
| 3 | Beta toggle visibility | Show in Settings v4.0.2 | ☐ accept ☐ override: ___ |
| 4 | Pre-implementation data fix | Fix #20 + strip hints; defer #10/#11 fixes | ☐ accept ☐ override: ___ |
| 5 | Critical-flag UI | Flag-only in v4.0.2 | ☐ accept ☐ override: ___ |
| 6 | Re-read explanation in summary | Inline text v4.0.2; modal v4.0.5 | ☐ accept ☐ override: ___ |
| 7 | Reduced-motion respected | Yes (reuse existing flag) | ☐ accept ☐ override: ___ |
| 8 | Choice label hint policy | Strip all hints | ☐ accept ☐ override: ___ |
| 9 | Suppress Field FX in postflop | Yes, via body data attribute | ☐ accept ☐ override: ___ |
| 10 | Curated 15 vs random shuffle | Random shuffle from approved subset | ☐ accept ☐ override: ___ |

---

## Section 9 — Final verdict

Pick one:

```
[ ] APPROVE — proceed to data-fix commit, then v4.0.2 implementation per the consolidated brief.
[ ] APPROVE WITH CHANGES — list changes here and proceed:
       1. _______________________
       2. _______________________
[ ] REQUEST RE-PLAN — significant gaps; specify what needs revision before re-review:
       _______________________________
[ ] DEFER — not the right time; re-evaluate when:
       _______________________________
```

If APPROVE: tell Orchestrator "proceed with data fix + v4.0.2" and the workflow continues.
If APPROVE WITH CHANGES: tell Orchestrator the changes; sprint may produce a small re-plan.
If REQUEST RE-PLAN: sprint re-runs with focused scope.

---

## Time budget

- Sections 1–5 (required reading): ~45 min
- Section 6 (risk update): ~5 min
- Section 7 (manual verification): ~15 min
- Section 8 (decisions): ~5 min
- Section 9 (verdict): ~2 min

**Total**: ~70 minutes for a thorough review. Or skip Section 7 manual verification if you trust the live browser QA already passed (~50 min total).

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | Orchestrator | Initial publication during v4.0.2 planning sprint |
