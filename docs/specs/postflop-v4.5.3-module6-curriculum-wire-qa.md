# v4.5.3 · M6 Curriculum Wire — Build + QA Report (FOR OWNER REVIEW · NOT COMMITTED)

**Date:** 2026-07-07 · **Spec:** approved w/ 1 PIN (mastery count self-reconcile) + knobs (drill 12, boss persona NONE, threshold 8-of-12, emoji/copy as proposed). **RUNTIME-ONLY: production data byte-identical (blob `54f134f5…`), validator 542/0/0. Commits held.**

## PIN landed — corrected mastery table (count now matches the list: FIVE)

Recorded in spec §2 and encoded in the checklist UI. Single-exemplar reasons with exemplar ids:

| # | single-exemplar reason | exemplar row |
|---|---|---|
| 1 | check_back_trap_risk_river | `…river_Kd7s3c_7d_m6_action_AcQc_v451` (E2) |
| 2 | sizing_merge_small_river | `…river_Qs8h3c_9h_m6_reason_AdQd_v451` (F2) |
| 3 | sizing_polar_big_river | `…river_8d5c2h_Qh_m6_action_8s8h_v451` (F1) |
| 4 | unblock_fold_region_river | `…river_9h8h3d_2c_m6_action_7s6s_v451` (C4) |
| 5 | story_consistency_bluff_river | `…river_Th9d3c_7d_m6_action_KdQd_v451` (D4) |

Corpus reconciliation: 5+5+5 (thin/bluff/give-up) + 4 (thick) + 3+3 (overbet/sidedness) + 2 (showdown) + 1×5 = **32** ✓. **UI copy shipped verbatim in `_pfM6MasteryProgressHtml`:** "All 12 river-betting reasons are masterable — each has at least one best-play scenario. The 8-of-12 bar is a coverage allowance for the five single-scenario reasons (trap-risk check, merged small, polar big, unblock-the-folds, story-consistency), NOT a distractor carve-out like Module 5's domination token."

## Built (index.html + SW; cache 4.5.2A → 4.5.3)

`getModule6Scenarios()` · drill router + default 12 · TCC tile 🗡️ (route `postflop:m6`) + route case · curriculum entry replaced (old "Boss Exams" placeholder → real M6 w/ 9-line syllabus; Future → Limited Beta; Start routes == TCC) · `_pfModuleStatus('m6')='beta'` · 12 runtime concept entries (`module:'m6'`) + library M6 group + concept-drill m6 pool case · M6 mastery trio (stats/progress/html w/ PIN copy) · M6 BetaQA (stats/weak-preview/critical-monitor w/ overbet-spew habit metric/dashboard/Copy M6 Snapshot) · boss def m6 (NO persona per knob; menu/intro/pool/trophy engine-automatic) · first-time seat-flip explainer + Q1 hook · complete-screen (label/headline/breakdown/leak-hint/drill-again) · boss tile copy 5→6 bosses. **Out of scope honored:** Daily Challenge slot shape untouched (locked v4.4.3 knob — flagged below as a follow-up knob), Range-Reveal chip M6 stays OFF, tournament/stake layers untouched.

## QA evidence (fresh SW, real engine)

- **Data/validator:** blob `54f134f5…` byte-identical · 542/0/0 · loads 542/542, appVersion 4.5.3 in DOM.
- **Drill flow (12q end-to-end):** seat-flip chips ("BB checks river · you act"), M6 context label, Q1 explainer, "Your Hand (BTN)", 5-card board; answer screen: "BTN IP, river" header + River Logic + game banner + NO reveal chip; complete: M6 headline + river-betting breakdown + leak hint + drill-again(m6,12).
- **Concept drill:** `sizing_polarity` → mode concept, module m6, **queue 12/12 all-M6**.
- **Boss m6:** pool **10 × D4-5, no fill** (intro discloses exactly that), all D≥4/all M6, NO persona line; deferral verified mid-exam (no teaching/banner); **QA-CAUGHT BUG:** the boss END-REVIEW has its own per-module teaching router (predates the generic answer-screen router) and skipped M6 → review rendered 0 teaching blocks. **Fixed** (m6 → river renderer, seat-aware header flips inside); re-run: **10/10 River Logic blocks + 10/10 BTN-IP headers**; finalize idempotent across retake + triple re-render (attempts 1→2 exactly); trophy survives reload (loader round-trip proven — trophies map is generic, no new stored fields).
- **Isolation:** Range Reveal chip on M6 in tourney mode = '' (module gate holds); M5 chip unaffected; deferral remains boss-only.
- **320×700:** maxRight 304/320 on question, answer, and 10-hand boss review; 5 board cards render.
- **Console: 0 errors** across all flows (drill ×12, concept, boss ×2 runs, reloads).

## Post-launch sequencing proposal (owner-requested; open ledger, no work done)

1. **chip-on-M6 copy validation** — smallest unblocking item; game-layer only; "Your line reads" variant + M6-rows hit-list rerun, then ON/OFF ruling. Zero data risk.
2. **M4 full audit under ARRIVAL LEGITIMACY** (82/92 unchecked; **V1 AKo folds in** as the audit's first confirmed rework of the class). Leg (a) is mechanizable against the locked preflop baseline (R29/R107 recompute precedent); legs (b)/(c) are structured-review work. Biggest correctness debt — schedule before any new feature.
3. **V2/V3 solver-gated verifications** — batch ONE solver session with the M4 audit's needs; same session can evaluate promoting the 3 parked M6 `solver_required` spots (would enter as `consensus_gto` + solverRunRef).
4. **M3 v423a apostrophe cosmetics** — ride along with the next data-touching migration (likely M4-audit reworks); never ships alone (avoids a cache-bump for cosmetics).
5. **G5 opt-in Blitz** — the roadmap finale; after correctness debts clear.
   *(+ follow-up knob, owner call anytime: add M6 to the Daily Challenge wild-slot pool — one-line change, held because the 5-slot daily shape is a locked v4.4.3 knob.)*

**STOP: awaiting owner review. On approval: standard 2-commit + snapshot `GPT AUDIT/v4.5.3/` — and the M6 program closes: curriculum M1–M6 COMPLETE.**
