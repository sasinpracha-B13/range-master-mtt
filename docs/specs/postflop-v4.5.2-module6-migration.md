# v4.5.2 · M6 Production Migration + FT Debut (FOR OWNER REVIEW · NOT COMMITTED)

**Date:** 2026-07-05 · **Owner approval basis:** v4.5.1 line-review PASSED with 4 fixes (all landed, re-audited) → "v4.5.2 MIGRATION APPROVED — proceed 510→534". **Stop point honored: everything below is working-tree only.**

## What shipped in the working tree

| Piece | Detail |
|---|---|
| **Data 510 → 534** | `tools/migrate-module6-v4.5.2.ps1` (idempotent, atomic, UTF-8 no-BOM): flips 24 seeds `review_pending → approved`, `reviewStatus v4.5.1_strategic_reviewed`, `version v4.5.2`, appends; **pre-write verification: all 510 non-M6 rows compared compact-JSON-equal → 0 drift** (abort-on-drift); post-parse 534/24 checks; top-level description updated. Re-run = verify-only (proven). |
| **Concepts 63 → 75** | Same tool, phase 2: 12 `module6` concepts spliced as compact lines before the array tail (M5 convention) — existing bytes above the tail untouched; parse + count verified. |
| **Production validator** | `audit-postflop-ps.ps1`: **new M6 block R94–R106** (module/spot lock incl. `riverAction='BB checks river'`; board integrity; enums; partition; verdictBasis hard-block on `solver_required`; **stakeBasis PIN coherence** — bet-best match / temptation-in-bad-or-critical / mixed-primary + in-data whitelist equality; **R103/R104 = CHECK-BACK-NUTS forward + reverse bounds**; blockerNote-on-bluff; text integrity; flush-dense ban) + M6 stats block (surfaces verdictBasis/stakeBasis/betPurpose) + R10/R13 flop-only rules now exclude M6 (same as M4/M5). **Result: 534/0/0 PASS.** |
| **Game layer (index.html, cache 4.5.0 → 4.5.2)** | `_pfStakeBB` M6 branch reads **authored `stakeBasis`** → 7/13/20/30 (PIN: constant across player choices by construction); `_PF_MIXED_WHITELIST` +4 M6 entries (8 member pairs — ships WITH migration per ruling); `_PF_M3_ACTION_LABELS` +4 bettor actions; new `_PF_M6_REASON_LABELS` (12) + normalizer chain; question renderer: isM6 seat-flip (context label 🗡️ FT Drop, "Your Hand (BTN)", spot chips ending **"BB checks river · you act"**, 5-card board + pills, authored-prompt pass-through); answer renderer: M6 reuses the M5 river teaching blocks with seat-aware header "🗡️ Recommended Action (BTN IP, river)". `service-worker.js` → v4.5.2. |
| **FT debut** | **Zero engine rework confirmed**: the v4.5.0 hook (`lv≥6 → concat approved pf_river_value_ip action rows`) went live the moment approved rows existed. No curriculum surface yet (v4.5.3 per roadmap). |

## Metadata-convention lint (disclosed)

First full-validator run surfaced 27 errors on 13 M6 rows — **all metadata-class, zero strategy changes**: (a) 4 invented textureTags not in taxonomy → replaced with valid tags; (b) `highCardClass` had been authored off the FLOP top card; production convention (R02) derives from the **full 5-card runout** → 6 rows relabeled (e.g. 8d5c2h-Kc-Qh → `K_high`); (c) one B3 prose phrase ("…wait to pay…") tripped the house self-correction-artifact pattern → reworded ("are ready to pay"). Fixes applied **at the builder**, seeds regenerated, production restored from HEAD and re-migrated cleanly. **Prevention encoded: seed auditor gains R26 (full-runout hcc), R27 (tag whitelist), R28 (artifact patterns)** — this class can't reach migration again.

## QA evidence (local preview, runtime)

- Loads **534/534**, concepts **75**, appVersion **4.5.2** rendered, **0 console errors**.
- **FT pool (lv 6 / L7):** 20 rows = M5-D≥4 + **11 M6 action rows at D≥4** (difficulty ramp working; full 18 M6 action rows eligible via fallback; **0 reason rows dealt** — filter confirmed).
- **Stake PIN:** mixed AhTd → 7 (primary small) · KhJd → 30 (overbet best) · AcQc → 7 (small **temptation**); `_pfStakeBB(scenario)` takes no choice input → constant across player choices by construction; in/out identical (30/30).
- **Labels:** action row → Check back / Bet small (~33%) / Bet big (~75%) / Overbet (~150%) / Mixed · reason row → "Thick value bet (river)", "Check back — trap risk (river)".
- **Whitelist promotion:** AhTd `bet_small`→best, `check_back`→best, `bet_big` stays bad (teaching tier untouched).
- Authored prompts pass through; teaching blocks render with the BTN-IP header; game frame = `table` for action rows.

## Gates & invariants

Production validator **534/0/0** · non-M6 data-preservation **0 drift** (mechanical, abort-on-fail) · concepts splice byte-preserving above tail · seed auditor 24/0/0 (R01–R28) · loader round-trip n/a (no new stored fields) · PIN-1 tournament floor untouched (pool membership only; +15 invariant is schedule-derived) · no frequencies authored anywhere.

**STOP: awaiting owner review of this migration. Nothing committed; snapshot + state docs follow approval per the standard 2-commit routine. Next after commit: v4.5.2A/B expansion (24 → ~40–60) → v4.5.3 curriculum wire.**
