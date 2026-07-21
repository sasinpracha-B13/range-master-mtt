# v4.6.1 · M4 Full Rework Program — Authoring + Migration Plan (FOR OWNER APPROVAL)

**Date:** 2026-07-21 · Audit closed 92/92 (30 REWORK / 55 PASS / 7 SOLVER-ROUTED). One migration per knob (d). Authoring starts only after this plan is approved. Corpus untouched at blob `54f134f5…` until the approved migration runs.

## A. Authoring manifest — 30 rows (29 arrival reworks + #18 content re-derive)

All rows: new id `…_v461`, schemaVersion 1.2.0, `arrivalDerivation` (full per-street re-derive, V1 pattern), suit-honesty lint, clean exact partition, prose fully re-derived (never search-replace). Difficulty/board/turnCategory/actionReason preserved except where noted.

### A1 · 17 leg-(a) hero-swaps (b1-2 … b1-18)
Owner-approved proposals stand, EXCEPT four same-board hero collisions found at plan assembly (b1-12 distinct-hero precedent). Amendments flagged **for approval**:

| row | id (`…turn_` stripped) | approved | collision | **amended proposal** |
|---|---|---|---|---|
| b1-6 | `9s8d4c_7h_action_KsKc_v432` | JhJc (JJ) | b1-3 → JcJh (JJ) same board | **TcTh (TT)** — overpair-to-9 catch, same posture |
| b1-9 | `Ts8s4d_7c_reason_QcQd_v432` | JcJd (JJ) | existing PASS row `…action_JsJh_v430D` (JJ) same board | **9h9d (99)** — pocket-under-T catch |
| b1-11 | `Kd8s3c_8h_action_AdKh_v430C` | KhQs (KQo) | b1-8 → KhQd (KQo) same board | **KhTc (KTo)** — TP-K catch (KTo = b2-established member) |
| b1-13 | `Qs8s4d_2s_action_AsKc_v430C` | KhQd (KQo) | existing PASS row `…action_KsQc_v430D` (KQo, same reason) | **AhJc (AJo)** — A-high overs catch |

Unchanged-approved: b1-2 JhJd, b1-3 JcJh, b1-4 **KhQs (KQo, amended per ruling)**, b1-5 AhJs, b1-7 AhJc (AJo dup on JdTd5s stands per explicit ruling), b1-8 KhQd, b1-10 KhQc, b1-12 KcJd, b1-14 AhJd, b1-15 AsJs, b1-16 KsQs, b1-17 AhJd, b1-18 QsJs. WL rows b1-2/b1-3 couple to §D.

### A2 · 1 leg-(b)
b1-24 `QsTs6d_Jc_action_5h4d_v430` → **8d7d (87s)** (approved).

### A3 · 7 leg-(c) hero-swaps (new hero's flop-best = call)
Approved: b1-19 → TcTd (TT); b1-20 → JhTh (JTs); b1-22 → JsJc (JJ). New proposals (card-verified live):

| row | id | lesson (kept) | D | **proposal** | design |
|---|---|---|---|---|---|
| b2-#33 | `JdTd5s_2c_action_JhJs_v430D` | value_CR | 2 | **KhJs (KJo)** | TP-J K-kicker: flop call clearly best on the wet J-T-5; turn 2c brick → CR |
| b3-#38 | `Kd8c4s_Ah_action_8d8h_v430C` | protection_CR | 3 | **AcJd (AJo)** | A-over float arrival (A-family PASS standard); turn Ah → TP-A; CR denies QJ-gutter/float equity. Note: protection→value relabel possible at seed gate (#18 precedent) |
| b3-#49 | `Qs7d3c_3h_action_7s7c_v430C` | value_CR | 3 | **As3s (A3s)** | bottom-pair peel arrival (member per A2s–A5s ruling); turn 3h → TRIPS; clean value-CR |
| b3-#64 | `Ts8s4d_7c_action_TcTd_v432` | value_CR (big) | 4 | **8h7h (87s)** | pair+gutter peel arrival; turn 7c → two pair 8s-and-7s; big raise vs live straight draws |

### A4 · BOARD-CHANGED family — 4 rows, one authored group, SEED strictness, full paste-gate
Per ruling #3 — new boards so each lesson stands legitimately; convert-to-fast-play fallback if an axis fails:

| row | orig | axis | design intent |
|---|---|---|---|
| b1-21 | 88 slowplay `As8d3h/2c` | **quads** | flopped quads (88 on 8-8-x): slowplay genuinely defensible — zero protection need, only line that keeps villain's bluffs in |
| b3-#52 | 88 slowplay `Qs8s4d/2s` | **boat** | flopped full house: near-zero protection need, trap line defensible per M3 logic |
| b3-#66 | TT slowplay `Ts8s4d/7c` | **monotone nut flush** | flopped nut flush on monotone flop: raise folds everything out; hero class changes (e.g. AJs) — BOARD-CHANGED permits |
| b1-23 | A6s equity_real `Ts9s5d/6h` | **modest draw** | gutter+overs/backdoor hand whose flop call is cleanly best (strong draws raise-mixed — the original defect); turn barrel → call to realize equity |

### A5 · #18 content re-derive (upgraded from "label fix" — evidence)
`9s8d4c_7h_reason_5h5d_v432`: id-hand 5h5d is a bare underpair, but the row is authored as a made monster — handClass=`set`, prose "Hero set of 5s", role `slowplay_trap`, sdv `nutted`; board 9s8d4c/7h contains **no 5**. Mechanically confirmed IMPOSSIBLE-TAG (§B). Hand/author mismatch: the entire authored frame fits a turned nut straight. **Proposal: hero → JcTd (JTo)** — flop double-gutter (7 and Q both complete, 8 outs → call-best arrival), turn 7h = J-high **nut** straight: every authored tag, the partition, the slowplay-trap lesson, and D4 become TRUE as written; prose gets the "set of 5s" sentences re-derived to straight language. (JTo preflop = chart member; the routed solver class is the flop-float threshold, not membership — this arrival is draw-based, not a float.) Same board hosts JhTh (JTs) action row — adjacent-class pair tolerated per KQs/KQo precedent, different row types.

## B. Retags — pre-check results (`tools/precheck-nutted-tags-v4.6.1.ps1`)
R107-class recompute over ALL non-rework M4 rows (wider than ordered scope, same cost). Principle applied = #62 ruling: **within-category domination demotes** (better same-category hand live); cross-category vulnerability does not.

**4 retags (1 ordered + 3 found):**
| row | computed | finding | retag | ARR.P flip |
|---|---|---|---|---|
| `Ts8s4d_7c_action_9d6d_v430C` (ordered) | straight T-high | second-nut — J9 live | nutted_value/nutted → **strong_value/high** | fold: critical → **bad** |
| `QsTs6d_Jc_action_9c8h_v430` | straight Q-high | third-nut — K9 and AK live | → **strong_value/high** | fold: critical → **bad** |
| `7s5d3h_4c_action_6h6d_v430D` | straight 7-high | second-nut — 68 makes 8-high | → **strong_value/high** | fold: critical → **bad** |
| `8c8d3s_3h_action_Ah3d_v430` | **threes-full-of-eights** | any 8x makes eights-full (within-category) | sdv nutted → **high** (role slowplay_trap stays) | none — fold rule keys on role, already bad |

CLEAN (tags stand): `8c7c` (nut straight T-high), `As9s` (nut flush), `JhTh` (nut straight J-high). `5h5d` = IMPOSSIBLE-TAG → resolved by A5, not a retag.
Secondary sdv=none sweep (8 call-dup rows): QhJh×2 compute two_pair/pair but hero cards contribute nothing (board-plays-both) — relative-sdv semantics, `none` stands; call→critical resolutions stand. No retags.
Process note: evaluator v1 missed unpaired-hero boats (false IMPOSSIBLE-TAG on Ah3d) — caught by hand-verification, fixed to full 6-card multiset eval, re-run; check-3 also corrected (fold rule keys on role, not sdv). Triple-implementation discipline held.

## C. Partition-fix-only batch — 40 rows (corrected from ~34)
64 overlap rows − 24 rework-with-overlap = **40** (6 rework rows carry no overlap). 54 duplicated-action instances, resolved mechanically post-retag: **39 bad / 15 critical / 0 flagged**. Reconciliation: whole-M4 84 instances = 54 fix-only + 30 inside rework rows (those die with re-authoring; pre-retag fix-only was 18 critical → 3 flips → 15). Solver-routed rows in this set (AQo×2, T9s×2, JsTh…) get partitions fixed now; item-(3) outcomes may later swap heroes — no conflict.

## D. Whitelist coupling — TRUE count 7 M4 entries (plan input said 4; corrected by enumeration)
- **2 UPDATE** (rework → new `_v461` ids, arrays re-verified at authoring): `7s5d3h_4c_reason_AhAd_v432` (b1-2), `9s8d4c_7h_action_AhAd_v430C` (b1-3).
- **5 UNCHANGED-VERIFY** (migration asserts presence): `Ac7d2s_4h_action_9c9d_v430C`, `JdTd5s_2c_action_9c9d_v430C`, `Ah9d4d_7h_reason_TdTs_v430D`, `7s5d3h_4c_action_JsTs_v432`, `Qs7d3c_3h_action_8d8c_v432`.
- M2/M5/M6 entries untouched.

## E. Migration design — single script `tools/migrate-v4.6.1-m4-rework.ps1`
Order: (1) assert start blob `54f134f5…`; (2) apply 4 retags — **before** resolver consumption (ruling #2); (3) replace **31** authored rows by id from the seeds file (V1 + 26 gate-1 + 4 gate-2); (4) partition-fix the 40 rows via the mechanical resolver (post-retag roles); (5) WL updates in index.html (§D); (6) dataVersion + SW cache + version strings. Changed rows = **71** (31 replaced + 40 partition-fixed; all 4 retag rows ⊂ the 40; #18 ⊂ the 31) · untouched = 471, byte-identical (same-serializer rebuild; zero-drift proof = changed-id list == this manifest, enforced abort-level in the migration script). *(Dry-run correction 2026-07-21: the original figure 70 miscounted V1's own replacement row — 30+40; true arithmetic 31+40=71.)* Row count invariant 542. Validator: R108 goes green; R64's legacy critical-subset-of-bad clause retired → flipped to exact-partition semantics (dry-run discovery — the legacy rule encoded the old dual-listing convention and would have contradicted every clean partition); M3/M5 siblings R34/R84 untouched pending their own remediations; `quads` added to the M4 handClass vocab; `arrivalDerivation` additive (no strict-field rule exists).

## F. QA gates (all before commit approval)
1. RW auditor extended over all 30 authored rows (RW.R01–R12) + family rules: quads/boat/flush board-truth, BOARD-CHANGED rows re-checked for M3-twin absence + member arrival.
2. Lints on migrated corpus: ARR.A → 0 non-member · ARR.C1 → 0 pairs · ARR.P → 0 overlap in M4 · precheck-nutted → 0 RETAG/IMPOSSIBLE.
3. Full validator **542 / 0 errors / 0 warnings** (R108 green, R16 cascade cleared).
4. In-app: M4 drill loads; WL mixed rows promote correctly under new ids; boss end-review M4 blocks render; M4 count stays 92.
5. SWEEP ADDENDUM: 320×700 incl. longest new arrivalDerivation prose.
6. Corpus diff audit: changed-id list == manifest (70); spot byte-diff 5 untouched rows.

## G. Sequence
Plan approval (this gate) → authoring paste-gate 1: 26 standard rows (A1+A2+A3+A5) fragments + RW results → authoring paste-gate 2: BOARD-CHANGED family 4 full rows (SEED strictness) → migration dry-run report paste → MIGRATE approval → run → QA evidence paste → commit approval → standard 2-commit + snapshot routine (v4.6.1). Everything HELD uncommitted until then.
