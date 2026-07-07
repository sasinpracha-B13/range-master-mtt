# v4.5.3 · M6 Curriculum Wire — Design Spec (FOR REVIEW · nothing built)

**Status:** SPEC ONLY. spec → owner review → build → QA evidence → review → approval → commit.
**Date:** 2026-07-07 · **Scope:** the M6 program finale — after this ships, the curriculum is COMPLETE (M1–M6). Mirrors the v4.4.2 M5 wire precedent point-for-point, adjusted for the bettor seat. **RUNTIME-ONLY: production data byte-identical at 542 (blob `54f134f5…`); validator stays 542/0/0.**

## 1. Surfaces (M5-precedent mapping)

| Surface | v4.5.3 delivery |
|---|---|
| **TCC tile** | 🗡️ "Module 6 · River Betting IP" + BETA badge + "32 bettor-side river scenarios · Limited Beta" → route `postflop:m6` (**12-question drill**, both qtypes from the full 32 pool — reason rows incl. D6 enter here) |
| **Curriculum card m6** | Future → **Limited Beta**; syllabus (value thresholds · thin-value discipline · blocker-driven bluff selection · give-up hygiene · sizing polarity · check-back showdown); **Start button routes identical to the TCC tile** (m4/m5 card-fix precedent — no Locked state, no divergent route) |
| **Concept Library** | M6 group renders the **12 `module6` concepts already shipped in v4.5.2** (75 total); concept → drill = 12-q **M6-only** queue (M5 `river_mdf` behavior) |
| **Mastery checklist** | See §2 — masterable set declared with rationale |
| **BetaQA dashboard** | M6 aggregation rows (per-reason, per-tier, per-difficulty from real stored sessions) + **Copy M6 Snapshot** button (M5 block mirrored) |
| **Boss Exam m6** | New `_PF_BOSS_DEFS.m6` — see §3 |
| **First-time explainer** | `_pfM6FirstTimeExplainerHtml` (Q1, first session only): the seat flip in three sentences — you are now the BTN bettor; BB has check-called twice; the last decision of the hand tree is yours |
| **Module status & plumbing** | `_pfModuleStatus('m6')='beta'`; history/mastery/weak-spot review aggregate m6; complete-screen: module label 🗡️ + "Module 6 Session Summary (Limited Beta)" + M6 river-betting breakdown + Drill-again (12) |

Already live from v4.5.2 (NO new work): question/answer renderers (seat-flip), labels, stake-from-stakeBasis, mixed whitelist, FT tournament dealing, teaching blocks.

## 2. Mastery checklist — masterable set declaration (owner-requested explicit)

**All 12 M6 actionReasons are masterable** — every reason has ≥1 best-exemplar in the 32-row corpus (owner PIN: exact counts + exemplar ids, count reconciled to the list — there are **FIVE** single-exemplar reasons, not four as first drafted):

| actionReason | best-exemplars | single-exemplar row id |
|---|---|---|
| value_bet_thin_river | 5 (B1 B2 B3 B5 B6) | — |
| blocker_bluff_river | 5 (C1 C2 C3 C5 C6) | — |
| give_up_no_equity_river | 5 (D1 D2 D3 D5 D6) | — |
| value_bet_thick_river | 4 (A1 A2 A3 A5) | — |
| polar_overbet_nut_river | 3 (A4 F4 F5) | — |
| blocker_sidedness_mix_river | 3 (B4 E4 F3) | — |
| check_back_showdown_river | 2 (E1 E3) | — |
| **check_back_trap_risk_river** | **1** | `…river_Kd7s3c_7d_m6_action_AcQc_v451` (E2) |
| **sizing_merge_small_river** | **1** | `…river_Qs8h3c_9h_m6_reason_AdQd_v451` (F2) |
| **sizing_polar_big_river** | **1** | `…river_8d5c2h_Qh_m6_action_8s8h_v451` (F1) |
| **unblock_fold_region_river** | **1** | `…river_9h8h3d_2c_m6_action_7s6s_v451` (C4) |
| **story_consistency_bluff_river** | **1** | `…river_Th9d3c_7d_m6_action_KdQd_v451` (D4) |

(5×5 + 4 + 3×2 + 2 + 1×5 = 32 ✓ — table totals reconcile to the corpus.)

**Threshold: 8-of-12 — but the RATIONALE differs from M5, and the checklist UI copy must say so** (owner PIN):
- **M5 convention:** 8-of-12 because 4 tokens are distractor-only BY DESIGN → masterable set = 8.
- **M6 convention:** masterable set = **ALL 12** (every reason has ≥1 best-exemplar); 8-of-12 is a **COVERAGE allowance for the five single-exemplar reasons**, not a distractor carve-out.

**Checklist UI copy (binding):** "All 12 river-betting reasons are masterable — each has at least one best-play scenario. The 8-of-12 bar is a coverage allowance for the five single-scenario reasons (trap-risk check, merged small, polar big, unblock-the-folds, story-consistency), NOT a distractor carve-out like Module 5's domination token." An M5-trained reader must not be able to infer M6 has distractor-only tokens. The five single-exemplar reasons remain flagged as the priority axis for the next expansion batch.

## 3. Boss Exam m6 — eligibility check result (spec-level)

- **Pool: D≥4 = 19 of 32** (14 from v4.5.1 + 5 from v4.5.2A). Boss draws 10 → **no fill needed; no fallback-ratio disclosure required** (contrast m2's disclosed 5×D4-5 + 5×D3 fill). The engine's fill logic remains as safety net; the intro screen states "10 hands from a 19-deep D≥4 pool".
- Def: `{ key:'m6', name:'River Betting IP', module:'pf_river_value_ip', … }` — trophy/first-pass +200/80% gate/end-review-with-full-teaching/re-drill all engine-automatic once the def exists (strict `mode==='boss'` untouched). Trophy storage uses the existing generic `trophies[key]` map — loader round-trip verified in QA (standing gate; expect no loader change).
- **Persona: NONE for m6 in v4.5.3** *(knob)*. Personas are villain-line flavor; M6's villain line is passive check-check-check — a quip-persona adds noise to the seat-flip lesson. If the owner wants one later it is a 4-line content add.

## 4. Out of scope (unchanged invariants)

Production data (byte-identical at 542, blob `54f134f5…`) · validator 542/0/0 · derived stakes & two-account model · tournament drift/pools (FT already deals M6) · Range-Reveal chip for M6 **stays OFF** pending the "Your line reads" copy-variant validation (open ledger) · deferral remains boss-only · no timed pressure · "Study tool" disclaimer untouched.

## 5. Acceptance gates (draft)

Data hash == HEAD blob `54f134f5…` · validator 542/0/0 · TCC tile → 12-q drill end-to-end 0 console errors · curriculum card routes == TCC (no Locked remnant) · concept drill queues M6-only · reason rows (incl. D6) appear in drills, never in tournament · mastery checklist renders 12 reasons w/ 8-of-12 threshold · boss m6: 10 hands all D≥4, deferral works, end-review renders FULL M6 teaching blocks (BTN IP header), idempotent finalize, trophy + first-pass-only +200 · BetaQA M6 rows populate from a real session + Copy Snapshot works · 320×700 sweep (tile / question / answer / complete / boss intro / boss review) · loader round-trip unchanged fields · appVersion 4.5.2A→4.5.3 + SW v4.5.3.

## 6. Deliverable order & post-launch note

SPEC (this doc) → owner review → build → QA evidence → review → approval → standard 2-commit + snapshot `GPT AUDIT/v4.5.3/`. **The v4.5.3 QA report will include the owner-requested post-launch sequencing proposal** for the open ledger (M4 ARRIVAL-LEGITIMACY audit · V1 AKo swap · V2/V3 solver-gated · M3 v423a apostrophe cosmetics · G5 Blitz · chip-on-M6 copy validation) — no work on any of them in v4.5.3.

## Knobs

Drill length 12 (vs 10) · boss persona none (vs add) · mastery threshold 8-of-12 · tile emoji 🗡️ · syllabus copy · first-time explainer copy.

**STOP: awaiting owner review.**
