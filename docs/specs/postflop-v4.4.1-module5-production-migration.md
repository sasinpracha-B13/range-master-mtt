# Postflop v4.4.1 — Module 5 Production Migration (477 → 501)

**Status:** SHIPPED (production data + cache bump). M5 is data-loaded + `approved` + runtime-verified, but **NOT yet routed** (no `postflop:m5` mode; the 5-card renderer + route land in v4.4.2).
**Date:** 2026-06-18
**Predecessor:** v4.4.0A (`a41a171`, M5 strategic seed review — 24/24 PROMOTE)
**Scope:** the first production-mutating Module 5 step. Migrate the 24 strategically-reviewed M5 seeds into production, add the M5 production-audit rule block, bump the cache.

---

## 1. What shipped

| Artifact | Change |
|---|---|
| `postflop/postflop_scenarios.json` | 477 → **501** scenarios (+24 M5, all `approved`). Top-level `description` refreshed (was stale "385 scenarios"). Top-level `schemaVersion` unchanged at `1.0.0`. |
| `postflop/postflop_concepts.json` | 51 → **63** concepts (+12 M5 river concepts). *(pre-fix staged in v4.4.1 working tree, ships here.)* |
| `tools/audit-postflop-ps.ps1` | NEW M5 production-rule block **R76–R93** + M5 stats block. R10/R13 flop-only rules excluded for M5. |
| `tools/migrate-module5-v4.4.1.ps1` | NEW two-phase idempotent migration tool. |
| `tools/build-m5-seeds-v4.4.0.ps1` + `docs/specs/postflop-v4.4.0-module5-seed-scenarios.json` | **Mechanical metadata-correctness fixes** (see §9). NO strategic/content change. |
| `index.html` | `appVersion` `4.3.2C` → `4.4.1`. |
| `service-worker.js` | `VERSION` `v4.3.2C` → `v4.4.1`. |
| `docs/specs/postflop-v4.4.1-module5-production-migration.md` | THIS doc. |

No runtime route, UI, renderer, taxonomy, or strategy-field change. M5 is data-only this sprint.

---

## 2. The migrated scenarios

24 M5 scenarios, transformed seed → production:

- **Added:** `version=v4.4.1`, `game=NLH_MTT`, `street=river`, `actionHistory=[]`, `scoring={best:1,acceptable:0.5,bad:0,critical:0}`, `difficulty` (from `difficultyHint`), `auditStatus=approved`, `reviewStatus=v4.4.0A_strategic_reviewed`.
- **Stripped:** `difficultyHint`, `uniquenessNote`.
- **Preserved:** `id`, `module=pf_river_barrel_oop_def`, `moduleName=Facing River Barrel OOP`, `schemaVersion=1.3.0`, `spot`, `board` (5-card river structure), `heroHand`, `handClass`, `heroHandRole`, `drawCategory`, `showdownValue`, `blockerNote`, `recommendedAction`, `actionReason`, `question`, `answer`, `explanation` (incl. `riverLogic`), `conceptTags`, `sourceConfidence`.

Production composition after migration:

| Module | Count |
|---|---|
| M1 `pf_board_texture` | 251 |
| M2 `pf_flop_cbet_ip` | 49 |
| M3 `pf_flop_cbet_oop_def` | 85 |
| M4 `pf_turn_barrel_oop_def` | 92 |
| **M5 `pf_river_barrel_oop_def`** | **24** |
| **Total** | **501** |

M5 distribution: 6 river categories × 4 (brick / overcard / flush_complete / straight_complete / board_pair / scare_card); 18 action_choice + 6 reason_choice; sizing spread small ×4 / medium ×8 / large ×8 / overbet ×4.

---

## 3. The migration tool — `tools/migrate-module5-v4.4.1.ps1`

Mirrors `migrate-module4-v4.3.0B.ps1` exactly:

- **Two-phase:** default writes `auditStatus=review_pending`; `-FlipApproved` flips to `approved` after the production audit passes. `-DryRun` previews counts.
- **Idempotent:** safe to re-run; rebuilds the M5 block from source rather than appending duplicates (accepts production M5 count of 0 *or* 24).
- **Guards:** aborts unless source has exactly 24 planning seeds (all `auditStatus=planning_only`) and production has exactly 477 non-M5 scenarios; aborts if post-merge count ≠ 501.
- **Safety:** no `Invoke-Expression`, no unsafe `Remove-Item`; UTF-8 NO-BOM read/write; atomic `tmp` + `Move-Item`.
- **Description refresh:** during reassembly, replaces the (previously stale, M4-era) top-level `description` so the data file self-describes accurately. Kept in the script so the data file stays reproducible from source rather than hand-edited.

Run sequence this sprint:

1. `-DryRun` → 24 src / 477 prod / 501 after. ✓
2. (no flag) → wrote 501 @ `review_pending`.
3. production audit → 501/0/0 PASS.
4. `-FlipApproved` → flipped 24 M5 to `approved` (+ description refresh).
5. production audit → 501/0/0 PASS.

---

## 4. M5 production-audit rules — `audit-postflop-ps.ps1` R76–R93

Applied only to `module='pf_river_barrel_oop_def'`. Mirror the hard-error subset of the M5 seed audit (`audit-postflop-module5-seed.ps1`, M5.R01..R58) and the M5 schema-taxonomy.

| Rule | Check |
|---|---|
| R76 | module / `street=river` / `game=NLH_MTT` / `schemaVersion=1.3.0` lock |
| R77 | BB-vs-BTN river-defense spot lock (`heroRole=turn_check_caller_oop`, `villainRole=river_barreler_ip`, BB/BTN, NLH_MTT/100BB/SRP, `street=river`) |
| R78 | 5-card board structure: `flopCards`(3) + `turnCard` + `riverCard` + `cards`(5) = flop+turn+river, no dupes |
| R79 | M5 board enums (`riverCategory`, `boardChange`, `runoutTexture`, `riverDrawCompletion`, **`villainRiverSizing`** required, `suitTextureRiver`) |
| R80 | heroHand = 2 cards, no hero/board collision |
| R81 | `handClass` / `heroHandRole` / `drawCategory` (none/busted_*) / `showdownValue` vocab |
| R82 | action_choice schema + `recommendedAction` == `answer.best` + prompt completeness (both hero cards present) |
| R83 | reason_choice schema + `actionReason` vocab + `actionReason` == `answer.best` |
| R84 | answer partition: best/acceptable/bad disjoint, critical ⊆ bad, all ids in choice universe |
| R85 | explanation completeness (short/riverLogic/rangeContext/handLogic/commonMistake/takeaway always; **sizingLogic required only for check-raises**) |
| R86 | conceptTags 1–4, no dupes, all in M5 concept vocab |
| R87 | auditStatus enum + `solver_verified` requires `solverRunRef` |
| R88 | `handClass=flush/nut_flush` invariant: ≥5 of one suit across hero+board |
| R89 | `handClass=straight` invariant: 5 consecutive (or A-2-3-4-5) across hero+board |
| **R90** | **busted-draws-never-call (HARD, the M5 signature rule):** `heroHandRole=missed_draw` OR `drawCategory=busted_*` ⇒ `call` not in recommendedAction / answer.best / acceptable, and no call-flavored `actionReason` |
| R91 | `blocker_bluff` blockerNote claiming `nut-<suit>` requires hero to hold A of that suit |
| R92 | no draw-equity-realization phrasing in river explanations (WARN) |
| R93 | text-integrity: no unresolved self-correction artifacts (HARD) |

The conditional-`sizingLogic` rule (R85) is the one deliberate divergence from M4's unconditional explanation rule: M5 seeds set `sizingLogic=null` for non-raise lines and populate it for check-raises (and some thin-value calls), so the production rule requires it only when `recommendedAction ∈ {check_raise_small, check_raise_big}`.

A matching **M5 stats block** prints riverCategory / villainRiverSizing / highCardClass / recommendedAction / auditStatus counts.

---

## 5. Verification

- **Production audit:** `501 / 0 / 0 PASS` (exit 0). M5 stats: 6 categories × 4; sizing small 4 / medium 8 / large 8 / overbet 4; status `approved: 24`. M1–M4 counts unchanged (251/49/85/92).
- **M5 seed audit:** `24 / 0 / 0 PASS` (seeds untouched by migration).
- **Runtime smoke test (local preview, `serve.ps1` @ :8766):**
  - Console: `[postflop] loaded 501/501 scenarios (schema 1.0.0)`.
  - `App.postflop.ready=true`, `error=null`, `schemaVersion=1.0.0`, `stats={total:501,approved:501,skipped:0}`.
  - Runtime module pool: M1 251 / M2 49 / M3 85 / M4 92 / **M5 24** — M1–M4 unchanged, M5 in the pool but **inert** (no router matches `pf_river_barrel_oop_def` until v4.4.2).
  - Zero console errors or warnings.
- **Schema gate:** top-level file `schemaVersion` stays `1.0.0`, matching the app's `POSTFLOP_SCHEMA_VERSION = '1.0.0'` gate (line ~33846). Only the *per-scenario* M5 `schemaVersion` is `1.3.0`; the loader does not gate on per-scenario schema.

---

## 6. Why the cache bump

Both `postflop/postflop_scenarios.json` (477→501) and `postflop/postflop_concepts.json` (51→63) are **cache-first** assets in `service-worker.js` `STATIC_ASSETS`. Without a `VERSION` bump, returning users would keep the stale cached 477-scenario / 51-concept files. `appVersion` (backup-payload version string) bumps in lockstep per the project's cache-versioning discipline.

---

## 7. Files unchanged this sprint (inheritance)

- M5 v4.4.0 planning artifacts (architecture / schema-taxonomy / audit-plan / gpt-review docs) → `GPT AUDIT/v4.4.0/`.
- `tools/audit-postflop-module5-seed.ps1` → unchanged.
- All M1–M4 builders, seed JSONs, migration/hotfix tools; `postflop_taxonomy.json`; ranges; manifest; preflop; gamification; M1–M4 strategy fields.

> NOTE: `tools/build-m5-seeds-v4.4.0.ps1` and the 24-seed JSON were **not** byte-identical this sprint — they received mechanical metadata fixes (§9). The seeds' strategic content (verdicts, hands, runouts, explanations) is unchanged from v4.4.0A.

---

## 8. Next (auto-drive continues per owner)

1. **v4.4.1A/B** — M5 data expansion 24 → 60–90 (new builder layer, strategic review, migration), mirroring the M4 expansion/polish cadence.
2. **v4.4.2** — M5 runtime wire: `TRAINING_MODES.postflop` M5 entry + `postflop:m5` route + `getModule5Scenarios()` + M5 feedback blocks (riverLogic-prominent) + the **5-card board renderer** (the one net-new design problem: 5 cards must fit at mobile 320px).
3. **M6** — River Betting IP architecture, same plan → review → migrate → expand → wire pattern.

---

## 9. M5 seed metadata-correctness fixes (honest disclosure)

The standing discipline is "do not mutate historical builders/seed JSONs." This sprint made a **bounded exception** for three classes of mechanical metadata bug in the v4.4.0 seeds — invalid enum values that the v4.4.0 seed auditor did not check but the stricter production auditor's board-derivation rules (R02/R09-equivalents) would have rejected. The fixes were applied at the v4.4.0 builder source so the seed JSON and production stay consistent (rather than diverging via a migration-time patch).

| Field | Was | Now | Why |
|---|---|---|---|
| `board.suitTextureRiver` (×24) | `rainbow` / `flush_possible` | `two_tone` | A 5-card board can never be `rainbow` (always ≥2 of some suit); `flush_possible` is a `runoutTexture` value, not a suit-texture enum value. |
| `board.textureTags` R3 (×4) | `flush_possible` | `flushing` | `flush_possible`/`straight_possible` are `runoutTexture` enum values, not valid `textureTags`; production R09 would reject them. |
| `board.textureTags` R4 (×4) | `straight_possible` | `straightening` | same as above. |
| `board.highCardClass` R4 (×4) | `9_high` | `low` | the taxonomy's highCard derivation maps rank 9 → `low`; production R02 derives + checks this. |

**What did NOT change:** `recommendedAction`, `answer`, `actionReason`, `heroHandRole`, `handClass`, `drawCategory`, `showdownValue`, `blockerNote`, `question`, `explanation`, `conceptTags`, `heroHand`, `spot`, and the physical board cards. The diff is **42 metadata lines across 24 scenarios, all non-strategic.** Seed re-audit after the fixes: **24/0/0 PASS**.

**Lesson banked:** the v4.4.0 seed auditor lacked the board-derivation checks (suitTexture/textureTags-enum/highCardClass) that the production auditor enforces, so these mechanical bugs survived seed audit. The new production R76–R93 block now catches this class at the production gate; a future M-module seed auditor should mirror the production board-derivation rules so such bugs are caught at author time, not migration time.

---

**Status: SHIPPED · production 501/0/0 · M5 data-loaded + approved + runtime-verified · NOT routed (v4.4.2).**
