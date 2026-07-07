# v4.5.2A · M6 Expansion +8 (24→32) — Migration 534→542 (FOR OWNER REVIEW · NOT COMMITTED)

**Date:** 2026-07-06 · **Basis:** owner batch review "7 of 8 PASS" + F5 fix ruling + auditor gap-closure order + check-primary mixed clarification; migration pre-approved on F5 landing. **All work below is working-tree only; commits held.**

## F5 correction (owner-caught grading error)

Quad jacks is **impossible**: hero's Js + board Jh/Jd leave only the Jc — villain cannot hold two jacks. Full enumeration: AA (aces full) three-bets preflop in the baseline; 77/33 fill smaller; JcAx chops. **Zero combos beat jacks-full-of-aces** → same class as A4/F1/A5, not F4 (whose quad deuces genuinely remain as 2d2c). Fixed at the builder: `critical=[check_back]`, `nutted_value`/`nutted`, prose now carries the self-verifying enumeration (Js block + AA exclusion stated explicitly).

## Auditor gap closed (why R25 missed it + the fix)

R25/R103/R104 **trusted authored labels** — F5 was mislabeled `strong_value`/`high`, so the nutted-row reverse-lint never looked at it. New **M6.R29 (seed) / R107 (production)**: for any boat-or-better hero hand, recompute combos-beating-hero by full 990-combo enumeration from board + hole cards, minus the AA/KK/QQ three-bet-baseline exclusions, and cross-check the authored labels in both directions. **Evidence: R29 run on the pre-fix batch flagged exactly F5 ("ZERO combos beat … but row is not labeled nutted_value/nutted"); post-fix batch is clean; the v4.5.1 batch stays clean (F4's quad-deuces = 1 combo, correctly not-nutted).** R107 now runs inside the production R-block on every validator pass.

(Process note, disclosed: the first scripted fix pass injected raw apostrophes into the builder's single-quoted strings, fragmenting one row's arguments — caught immediately by R15/R22 on rebuild, repaired via literal file edits. The auditor's exact-partition and stray-field rules did their job.)

## Rule clarification recorded (spec §10.8)

Future check-primary mixed rows are legal: nudge may point to CHECK; `stakeBasis` = the BET member's sizing (temptation-style fallback), `heroRiverSizing = none`. Encoded in M6.R14 + R101. No rows affected today.

## Migration + QA evidence

- `tools/migrate-module6-v4.5.2A.ps1`: 534 → **542** (M6 24 → **32**), flip approved/`v4.5.2A_strategic_reviewed`/version `v4.5.2A`; **zero-drift verification on all 534 pre-existing rows (0 drift)**; idempotent re-run = verify-only ✓; description updated; no concepts phase (batch tags ⊆ the 12 shipped module6 concepts).
- Production validator (now incl. **R107**): **542/0/0 PASS** — M6 32 approved: clear 28 / mixed 4 · stakeBasis small 9 / large 18 / overbet 5.
- Cache bump **4.5.2 → 4.5.2A** (appVersion + SW).
- Runtime QA (local preview, fresh SW): 542/542 loaded, appVersion 4.5.2A rendered, **0 console errors**; F5 in-app = critical check_back + nutted metadata + stake 30; stakes A5=20 / B5=7 / D5=20 (temptation) ✓.
- **FT pool (L7): 24 rows, M6 = 15** — the 11 prior + **4 new D4 action rows** (B5 KhQs, C5 KhTs, C6 KcTc, D5 AsKd). Count note: the batch's fifth D4 row is D6, a *reason* row — reason rows never deal in Tournament by design, so the pool gains four, not five; D6 joins the v4.5.3 drill surfaces instead.

**STOP: commits held pending owner approval. On approval: standard 2-commit + snapshot (`GPT AUDIT/v4.5.2A/`), then v4.5.3 curriculum wire per queue.**
