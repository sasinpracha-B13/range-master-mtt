# Postflop v4.4.2 — Module 5 Limited Beta Runtime Wire

**Status:** SHIPPED (runtime-only). **Module 5 IS PLAYABLE as Limited Beta.** Production data untouched (510/0/0; M5 = 33 approved).
**Date:** 2026-07-04
**Predecessor:** v4.4.1C (`5e30268`, straight-blocker mix; production 510)
**Scope:** wire the existing 33-scenario M5 corpus into the runtime, mirroring the v4.3.1 M4 Limited Beta wire exactly. The one net-new design problem — **rendering a 5-card board on a 320px phone** — is solved and verified.

---

## 1. What shipped (all in `index.html` + SW version)

Mirrors every M4 wire point, with river semantics:

**Data layer**
- `getModule5Scenarios()` — approved-only pool filter (33).
- `_PF_M5_REASON_LABELS` — 12 `_river` reason labels; added to the `_pfNormalizePostflopChoices` lookup chain (M5 checked before M4/M3).

**Routing**
- `TRAINING_MODES.postflop.actions` M5 tile: `Module 5 · Facing River Barrel OOP` · "33 river-defense scenarios · Limited Beta" · 🌊 · `postflop:m5` · BETA badge.
- `runTrainingModeAction` case `postflop:m5` → `startPostflopDrill('pf_river_barrel_oop_def', 12)` (same beta gating as M1–M4).
- `startPostflopDrill` M5 pool branch + default session length 12.
- `startPostflopConceptDrill` `m5` branch (draws from approved M5 only).
- `startPostflopWeakSpotReview` M5 module mapping + pool + cap 12 + empty-state toast ("Play Module 5 sessions to unlock River Defense weak-spot review.").

**Renderers**
- `_pfBuildQuestionPrompt` `isM5` branch — BB-defending river framing, flop/turn/river presented separately; reason_choice prefers the data prompt (which carries sizing context).
- `renderPostflopQuestion`: `isM5` hand-aware; 🌊 context label; **6-chip action history** (…· BB call / BTN bets river **(sizing)** — surfaces `villainRiverSizing`, the MDF driver); "Your Hand (BB)" title; drawCategory/showdownValue chips; `_m5` choice guides (12-reason vocabulary, river showdown-only phrasing); M5 first-time explainer (showdown-only / MDF ladder / blockers / busted-draws-never-call / honest 33-scenario copy).
- **5-card board:** index 3 keeps the amber Turn pill; index 4 gets a **teal River pill** (`.is-river-card`/`.pf-river-pill`); the row gets `.is-five-card`.
- `renderPostflopAnswer`: routes M5 through `_pfM5TeachingFeedbackBlocksHtml` — **River Logic PROMINENT** (the M5-defining field), then Hand/Sizing/Blocker note/Range/Takeaway/Common Mistake; 🌊 answer-screen context label.
- `renderPostflopComplete`: M5 headline "Module 5 Session Summary (Limited Beta)"; `_pfM5RenderSessionAggregations` ("river defense breakdown": hand classes / roles / **action reason coverage (river)**); `_pfM5BetaSessionLeakHtml` biggest-leak hint; Drill-again routes back to M5 (12).

**Academy / meta**
- `_PF_CURRICULUM` m5 entry flipped from "Future module" to Limited Beta with an 8-line syllabus (incl. the MDF ladder and the blocker-asymmetry line).
- `_pfModuleStatus('m5')` → `'beta'`.
- 12 M5 entries in `_PF_CONCEPT_LIBRARY` (drillable, `module:'m5'`) + "Module 5 — River Defense OOP" library group + count line.
  - **v4.4.1C TODO delivered:** `river_blocker_defense` runtime copy carries the flush-vs-straight **asymmetry note** (Ah = 100% one-sided lock; straight-blocker = two-sided ~25% nudge → mixes, not rules).
- M5 mastery checklist (`_pfM5MasteryStats/Progress/ProgressHtml`) — Limited Beta thresholds: 4 sessions / 75% in 2 / **8-of-12 reasons** (not 12: `domination_river_fold` ships 0 best-examples BY DESIGN; blocker_bluff_catch + pot_odds ship 1/33 each) / weak-review used / no critical in latest.
- M5 Beta QA dashboard (stats wrapper on the module-agnostic helper + weak-spot preview + critical monitor + **Copy M5 Beta QA Snapshot** + privacy note), mounted in the Academy next to M3/M4.

**CSS (the 320px solve)**
- Base cards are 56px + 12px gap → five cards = 334px = overflow on a 320 phone.
- `.postflop-board-row.is-five-card`: gap 6px, cards 48×70 → 268px.
- `@media (max-width:359px)`: cards 44×64, gap 5px → ~247px.
- `.is-river-card` teal outline + `.pf-river-pill` (parallel to the amber turn pill).

**Versions:** appVersion `4.4.1C → 4.4.2`; SW `v4.4.1C → v4.4.2`.

---

## 2. Runtime QA (local preview; fresh profile, caches cleared)

| Check | Result |
|---|---|
| JS parses after all edits | ✅ zero console errors on boot |
| Loader | ✅ `510/510 approved`, M5 pool = 33, `_pfModuleStatus('m5')='beta'` |
| TCC tile + route | ✅ `Module 5 · Facing River Barrel OOP · 33 river-defense scenarios · Limited Beta · BETA` |
| Question screen | ✅ 5 board cards, Turn+River pills, 6-chip history incl. `BTN bets river (medium)`, "Your Hand (BB)", hand chips, `_m5` guide, first-time explainer, 5 choices |
| **320×700** | ✅ cards 44×64, board maxRight **283 ≤ 320**, `body.scrollWidth = 320` (no horizontal overflow) — **screenshot-verified** (K♠9♦4♣ + 2♥ TURN + 7♠ RIVER all visible) |
| Grading | ✅ picked `best` on all 12 → 12.0/12.0 (100%), tier ✅ BEST each time |
| Answer screen | ✅ 🎯 River Logic prominent, Recommended Action (BB OOP, river) + reason chip, Blocker note, Takeaway, M5 reason labels ("Bluff-catch (river)") |
| Complete screen | ✅ M5 headline, "Module 5 · river defense breakdown", "Action reason coverage (river)", Drill again |
| History/mastery/QA | ✅ sessions recorded under `pf_river_barrel_oop_def` (12 answers each); mastery 2 sessions / 7 reasons seen; QA avg 100% |
| Concept drill | ✅ `startPostflopConceptDrill('river_mdf')` → 12-question M5-only queue, Concept Drill badge |
| Academy render | ✅ M5 mastery + M5 QA dashboard + Module 5 concept group (12) + Limited Beta curriculum card + asymmetry note present |
| Console | ✅ 0 errors, 0 warnings across the full flow |

Production audit unchanged: **510/0/0 PASS** (runtime-only; `postflop_scenarios.json` byte-identical this sprint).

---

## 3. Honest-copy inventory

"Limited Beta — 33 scenarios", "more scenarios coming", "display only" mastery, "structured practice, not final certification" — carried through tile hint, explainer, mastery title, and curriculum note, mirroring the M4 pattern. The mastery reason threshold is stated as 8-of-12 with the domination-is-distractor-only rationale in the code comment.

---

## 4. Unchanged this sprint

`postflop_scenarios.json` (510) · `postflop_concepts.json` (63) · `postflop_taxonomy.json` · all builders/auditors/migration/hotfix tools · `audit-postflop-ps.ps1` (R76–R93) · ranges/manifest/preflop/gamification · all M1–M4 runtime blocks (M5 branches are additive; M1–M4 paths byte-equivalent in behavior).

---

## 5. Next

**M6 — River Betting IP** (the final postflop module): v4.5.0 architecture + schema/taxonomy (hero = BTN as the *bettor*: value/bluff selection, sizing, bluff:value ratios) → seeds → strategic review → migration → expansion → runtime wire, per the established M5 pipeline. Backlog carried: V1–V3 (chart/solver-gated), full M4 review.

**Status: SHIPPED · M5 PLAYABLE (Limited Beta) · production 510/0/0 · 0 console errors · M1–M5 all live.**
