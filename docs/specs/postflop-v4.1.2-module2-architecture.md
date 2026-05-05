# Postflop v4.1.2 — Module 2 Architecture (Flop C-bet IP)

**Status:** Planning draft. Not implemented. No production code or data changed.
**Date:** 2026-05-05
**Author:** Orchestrator (planning sprint).
**Companion docs:**
- `postflop-v4.1.2-module2-schema-taxonomy.md`
- `postflop-v4.1.2-module2-seed-scenarios.json`
- `postflop-v4.1.2-module2-audit-plan.md`
- `postflop-v4.1.2-module2-gpt-review-package.md`

---

## 1. Module goal

**Module 2 — Flop C-bet IP** trains the player to choose the right action with a *specific hand* on a *specific flop* in a single specific spot:

- NLH MTT, chipEV / no ICM
- 100BB effective stacks
- BTN open vs BB call (BTN is preflop raiser, in position)
- Single-raised pot
- Flop decision only (no turn / river in v4.1.2 scope)
- Hero = BTN

Module 1 taught the player to read the board (whose range hits, who has nut advantage, what sizing family the spot calls for). Module 2 takes that foundation and asks the next question: **given my hand, what should I do here?**

---

## 2. Learning objectives

When a player completes Module 2 they should be able to:

1. Choose between **bet_small / bet_big / check / mixed** for any combination of common hand class × board class in this spot.
2. Articulate the *reason* for the action: value, protection, bluff, equity realization, pot control, thin value, blocker pressure, or give-up.
3. Recognise which hands prefer **checking despite range advantage** (typically mid pairs, weak top pairs on dry boards, overpairs on dynamic boards).
4. Recognise which hands prefer **betting despite weak range advantage** (combo draws, blocker bluffs, made hands that need protection).
5. Avoid the two common leaks the module is designed to expose:
   - Over-using big sizings on dry A/K-high boards (should be small with high frequency).
   - Auto-c-betting overpairs on low connected wet boards (often a mandatory check).

---

## 3. Assumptions

- The player has at least casual familiarity with Module 1 (board texture, range/nut advantage). Module 2 references those concepts but does not re-teach them in long form.
- The training audience is MTT recreational-to-intermediate, not high-stakes solver-grinders. Decisions are framed in terms of strategic *families* (bet_small / bet_big / check / mixed) rather than exact percentages.
- Sizing families are deliberately coarse:
  - `bet_small` = ~25–33% pot
  - `bet_big`   = ~66–100% pot
  - `mixed`     = GTO mixes meaningfully between two actions; both lines are correct
  - `check`     = pure or near-pure check
- ChipEV / no ICM. ICM-aware adjustments are out of scope (flagged for v5.x or beyond).

---

## 4. Scope in / out

### In scope (v4.1.2 *planning only*)
- Architecture doc (this file)
- Additive schema design for Module 2-specific fields
- 24 hand-authored seed scenarios in a separate planning JSON file
- Audit plan covering Module 2-specific risks
- GPT review package preparing the seed for external sanity-check
- State-file updates marking the planning sprint complete

### Out of scope for v4.1.2
- Any change to production `index.html`, `service-worker.js`, or `postflop/*.json` files
- Live integration of Module 2 into the drill engine (`startPostflopDrill('pf_flop_cbet_ip', ...)` is intentionally not enabled)
- Module 2 teaching layer UI (hint row, board checklist for hand-class)
- Module 2 weak-spot review variant
- Concept-drill expansion to Module 2 concepts
- Boss exam covering Module 2
- Rewards / chips / cosmetics / aura tied to Module 2
- Turn / river decisions (Module 4 / Module 5 territory)
- BB-defense or OOP perspective (Module 3 territory)
- Multi-way / 3-bet pots / ICM-aware spots

### Out of scope deliberately, with stronger justification
- **Production scenario JSON append.** Even though the seeds are validated, appending to `postflop/postflop_scenarios.json` is gated on an explicit human "ship Module 2 data" instruction in a future patch. The seed lives in `docs/specs/` until that gate opens.
- **Schema additions to `_PF_CONCEPT_LIBRARY` / `_PF_CURRICULUM` in `index.html`.** Module 2 is already declared in `_PF_CURRICULUM` from v4.1.0 (status: preview). No edit needed yet.

---

## 5. Existing Module 2 baseline (read-only context)

The production data already contains **11 seed Module 2 scenarios** authored during the v4.0.0 baseline. They live in `postflop/postflop_scenarios.json` with `module: 'pf_flop_cbet_ip'` and an `action_choice` question type. v4.1.2 treats them as read-only reference material:

| Board | Existing scenario count | Hand classes covered |
|---|---|---|
| Ah Kd 5c | 5 | top_two_pair, underpair, no_pair_no_draw, backdoor_only, set |
| Kh Td 2s | 2 | gutshot, set |
| 8h 7c 6s | 1 | overpair |
| Jh Ts 9c | 1 | overpair |
| Ah Jh 3s | 1 | combo_draw |
| 6c 5c 4s | 1 | overpair |

**Observations from the baseline:**
1. Only `action_choice` qtype is used.
2. Only `bet_33` and `check` are used as best answers (sizing-specific naming, not the family-level `bet_small` / `bet_big` the brief calls for).
3. No `critical` answers are populated.
4. `handClass` already exists as a field with mechanical values: `set`, `overpair`, `top_two_pair`, `underpair`, `combo_draw`, `gutshot`, `backdoor_only`, `no_pair_no_draw`.

**Implications for v4.1.2 design:**
- The seed JSON in this planning sprint **uses `bet_small` / `bet_big` family naming**, not `bet_33`. When integration happens, the existing 11 baseline scenarios will need to be either retroactively updated or treated as legacy-compatible aliases. This is flagged as an integration risk in the audit plan.
- The seed reuses the existing `handClass` field for the mechanical layer (matches the baseline) and adds a strategic-role layer via `heroHandRole` (the brief's `heroHandClass` term, renamed to avoid collision with the existing field name).
- The seed picks **non-overlapping boards** so the eventual integration choice (replace baseline / extend baseline / both) is open.

---

## 6. Scenario model (high level)

A Module 2 scenario reuses the Module 1 schema and adds hand-specific fields. The full schema is defined in `postflop-v4.1.2-module2-schema-taxonomy.md`. Summary:

```
{
  id, version, schemaVersion, game, module: 'pf_flop_cbet_ip',
  street: 'flop',
  spot: { ... same as Module 1 ... },
  board: { ... same as Module 1 ... },

  // Hero hand specifics — additive vs Module 1
  heroHand: ['Xh','Yc'],              // REQUIRED in M2 (always two cards)
  handClass: <mechanical>,            // existing field, expanded vocabulary
  heroHandRole: <strategic>,          // NEW: strong_value / thin_value / ...
  drawCategory: <enum>,               // NEW: nut_fd / fd / oesd / gutshot / combo / backdoor_only / none
  showdownValue: <enum>,              // NEW: high / medium / low / none
  blockerNote: <string>,              // NEW: optional human note on key blockers

  // Question (one of the M2 qtypes)
  question: { type: 'action_choice' | 'reason_choice', prompt, choices: [...] },

  // Answer tiers + scoring — same shape as Module 1
  answer: { best: [...], acceptable: [...], bad: [...], critical: [...] },
  scoring: { best: 1.0, acceptable: 0.5, bad: 0, critical: 0 },

  // Explanation — extended for hand-level logic
  explanation: {
    short, rangeContext, handLogic, sizingLogic,
    commonMistake, takeaway,
    // Module 1 fields that may be null in M2: rangeLogic, nutLogic, dynamicLogic
  },

  conceptTags: [...],
  difficulty: 1-5,
  sourceConfidence: 'consensus_gto' | 'expert_judgment' | 'solver_verified',
  auditStatus: 'review_pending' (for v4.1.2 seed),
  recommendedAction: 'bet_small' | 'bet_big' | 'check' | 'mixed',  // mirror of best
  actionReason: <enum>                // mirror of reason_choice best, or primary reason if action_choice
}
```

---

## 7. Question types

v4.1.2 ships **two** question types in the seed. Two more are reserved for future expansion.

### 7.1 `action_choice` (18 of 24 seeds)

Prompt:
> "With **\<hand\>** on **\<board\>** (BTN open vs BB call, 100BB SRP), what should BTN do most often?"

Choices (always exactly four):
- `bet_small`
- `bet_big`
- `check`
- `mixed`

Pedagogical role: the bread-and-butter Module 2 question. Drives the player to make a concrete decision.

### 7.2 `reason_choice` (6 of 24 seeds)

Prompt:
> "With **\<hand\>** on **\<board\>**, the recommended action is **\<action\>**. What is the *main* reason?"

Choices (drawn from a fixed enum; each scenario presents 4 of these):
- `value`
- `thin_value`
- `protection`
- `bluff`
- `equity_realization`
- `pot_control`
- `blocker_pressure`
- `range_advantage_stab`
- `give_up`

Pedagogical role: forces the player to articulate *why* an action is correct, which prevents pattern-matching to specific spots without understanding.

### 7.3 Reserved for future expansion (NOT seeded in v4.1.2)
- `sizing_choice` — when betting, which sizing family is preferred? (small / big / mixed / do_not_bet_often)
- `hand_class` — what role does this hand play here? (value / showdown / draw / bluff_candidate / give_up)

---

## 8. Answer tiers

Same multi-tier model as Module 1:

| Tier | Score | Meaning |
|---|---|---|
| `best` | 1.0 | The GTO-recommended primary action / reason |
| `acceptable` | 0.5 | Close-enough alternative (e.g., choosing `mixed` when `bet_small` is best, or vice-versa when both are within ~1 EV unit) |
| `bad` | 0 | Suboptimal but not punished (cold-called / over-thought) |
| `critical` | 0 | A textbook leak the module is designed to flag (e.g., `bet_big` on A-high dry, or `bet_big` polar overpair on low connected) |

Module 2 seeds are encouraged to populate **at least one `critical`** answer per scenario where a real-world leak exists. Several seeds have no `critical` answer (when no answer is genuinely punishing) — that's allowed, matching Module 1 baseline behaviour.

---

## 9. Teaching layer requirements (NOT built in v4.1.2)

When Module 2 ships its teaching layer in a future patch, it should reuse Module 1's pattern (board checklist + pattern label + hint row) and add **hand-class context**:

- **Hand-class chip** below the spot card: `Top pair · Top kicker` / `Combo draw · OESD + flush draw` / `Air · Backdoors only`
- **Decision hint row** above the choices: same component as Module 1, but the hint is hand-aware ("Strong value on a dry board → bet small with high frequency to extract from worse pairs and ace-blockers")
- **Reason chip** in the answer reveal: `Value` / `Protection` / `Semi-bluff` / `Pot control`

Spec'd here so the seed scenarios can include the data the teaching layer will eventually consume (`heroHandRole`, `actionReason`).

---

## 10. Audit risks

The seed must pass:

1. **Card-collision audit** — `heroHand` cards must not appear on `board.cards`.
2. **Choice-id integrity** — every `answer.{best,acceptable,bad,critical}` id must appear in `question.choices[].id`.
3. **Tier-overlap audit** — no choice id appears in more than one of best/acceptable/bad/critical.
4. **Best-non-empty** — every scenario has at least one `best` choice.
5. **Explanation completeness** — `short`, `handLogic`, and `takeaway` are mandatory; `sizingLogic` mandatory when action is bet_small or bet_big; `commonMistake` mandatory when at least one `critical` answer exists.
6. **Concept-tag validity** — every `conceptTag` must exist in `postflop_concepts.json`, OR be flagged in `audit-plan.md` as a "planned new concept" with a definition.
7. **sourceConfidence honesty** — `solver_verified` is only allowed if the scenario can cite a solver run. Module 2 seed defaults to `expert_judgment` because no solver runs have been produced.
8. **auditStatus discipline** — every Module 2 seed scenario uses `review_pending` (the v4.1.2 default), not `approved`. The status flips to `approved` only after a GPT review pass + human ratification.
9. **action vs handClass plausibility** — heuristic check: scenarios where `handClass = overpair` and board is `low_connected` AND best is `bet_small` (without explicit protection note) trigger a manual review.
10. **Family naming consistency** — every Module 2 seed uses `bet_small` / `bet_big` (not `bet_33` / `bet_75` / etc.). Differs from existing baseline; flagged for integration sprint.

The full rule list lives in `postflop-v4.1.2-module2-audit-plan.md`.

---

## 11. Production readiness criteria

Module 2 is "production ready" only when **all** of the following are true. v4.1.2 satisfies items 1 and 2 only.

| # | Criterion | v4.1.2 status |
|---|---|---|
| 1 | Architecture + schema docs exist and are reviewed | ✅ this sprint |
| 2 | At least 20 hand-authored seed scenarios with varied board × hand-class coverage | ✅ this sprint (24) |
| 3 | GPT review pass complete with no `critical` flag | ⏸️ pending — package prepared, review not yet run |
| 4 | Audit rule extension shipped covering Module 2-specific checks (`audit-postflop-ps.ps1` + `postflop_audit_rules.js`) | ❌ |
| 5 | Seed scenarios merged into `postflop/postflop_scenarios.json` (with baseline 11 either replaced or coexisting) | ❌ |
| 6 | Live `startPostflopDrill('pf_flop_cbet_ip', ...)` enabled in `index.html` | ❌ |
| 7 | Module 2 teaching layer (hand-class chip, hand-aware hint row, reason chip) shipped | ❌ |
| 8 | Module 2 weak-spot review variant shipped | ❌ |
| 9 | Concept Library / Concept Drill expanded to cover Module 2-specific concepts (`heroHandRole`, action reasons) | ❌ |
| 10 | Tester pass on a real device | ❌ |

---

## 12. Integration with Existing Academy Systems

Module 2 is designed as an **integrated academy course** under the existing Postflop Academy umbrella, not as a sibling tab or a separate "advanced lab." See "Module 1 vs Module 2 — Clear Difference" below for how the curriculum framing keeps them distinguishable without splitting them into separate products.

**Integration model chosen: Integrated Academy Path with applied-decision distinction.**

### 12.1 Academy Home integration
- Module 2 already exists as the **second card on the Academy curriculum map** (status: `preview` in v4.1.0). When v4.1.2 → integration ships, the status flips to `active` once production scenarios are merged.
- The Academy snapshot row (sessions / latest score / quality / weak families) **continues to read from the unified `rmtt_postflop_history` localStorage key**. No second history blob.
- The Academy recommendation engine (`_pfAcademyRecommendation`) gains a new branch when Module 2 is unlocked (e.g., "Mix M1 board reading with M2 hand decisions this session"). The 6 existing recommendations are preserved.

### 12.2 Curriculum Map status
- M1 stays Active.
- M2 transitions Preview → Active once data is in production.
- M3–M6 stay Locked / Future.
- Card copy clarifies *what* M2 trains (action with a hand) so it doesn't read like "Module 1 again with extra steps".

### 12.3 Concept Library relationship
- The 10 Module 1 concepts in `_PF_CONCEPT_LIBRARY` **stay as-is**. Module 2 reuses them where the concept genuinely overlaps (`range_advantage`, `small_cbet_freq`, `polar_big_strategy`, `mixed_small_check`, `check_strategy`, `cbet_size_selection`, `dry_high_card_strategy`, `low_connected_caution`, `wet_board`, `dynamic_board`, `static_board`, `paired_board_strategy`, `monotone_board_strategy`, `two_tone_board_strategy`).
- New Module 2-specific concepts to consider for a *future* `_PF_CONCEPT_LIBRARY` extension (NOT added in v4.1.2):
  - `value_betting` — deciding when a hand is strong enough to bet for value
  - `protection_betting` (already in `postflop_concepts.json`, not yet in the UI library)
  - `semi_bluff_with_equity` (already in `postflop_concepts.json`, not yet in the UI library)
  - `thin_value_betting` (already in `postflop_concepts.json`, not yet in the UI library)
  - `equity_realization` (already in `postflop_concepts.json`, not yet in the UI library)
  - `pot_control`
  - `blocker_pressure`
  - `give_up_strategy`
  - `hand_class_recognition` — meta-concept for "knowing which class your hand is in"
- Concept Drill expands to cover M2 concepts in a *later* patch by adding entries to `_PF_CONCEPT_LIBRARY` with the same shape, and extending `_pfConceptScenarioScore` to consider `handClass` / `heroHandRole` matches as additional signals.

### 12.4 Teaching Layer reuse
- The pattern-label + board-checklist + hint-row pattern (`_pfPatternLabelHtml`, `_pfBoardChecklistHtml`, `_pfHintRowHtml`) **stays unchanged** for M2.
- A small additive layer adds a `_pfHandClassChip(scenario)` helper that renders the hand-class context above the question, plus a hand-aware version of `_pfHintForBoard` (or a new `_pfHintForHand(scenario)`). These are *additions*, not rewrites — Module 1 keeps its existing helpers untouched.

### 12.5 Session Summary reuse
- `renderPostflopComplete` already has a `mode` field (`weak_spots`, `concept`). Module 2 sessions will reuse the same component — no second summary surface. The eyebrow / context label can adapt similarly to the v4.1.1 concept-drill variant: `Module 2 · Flop C-bet IP · Complete`.
- The concept mastery breakdown already aggregates by `conceptTags` — works for M2 unchanged.
- A future enhancement: aggregate by `handClass` and by `actionReason` to surface "weak hand classes" and "weak action types". The data is already in the answers (since they reference the scenario), but the aggregation is new code. Out of scope for v4.1.2.

### 12.6 Weak Spot Review reuse
- `_pfCurrentSessionWeakProfile` + `_pfBuildWeakSpotQueue` + `startPostflopWeakSpotReview` work today on `conceptTags` + board-family + scenario-id. They will work for M2 unchanged because M2 scenarios carry the same fields.
- A future enhancement: extend the weak profile with `weakHandClasses` and `weakActionReasons`, and bias the `_pfWeakScenarioScore` toward scenarios that match those buckets. Additive change, not a rewrite. Out of scope for v4.1.2.

### 12.7 Future Boss / Exam relationship
- Boss exams are spec'd at the curriculum-map level (M6 = Postflop Boss Exams). They will mix M1 + M2 + M3 questions in a single session and apply mastery gating.
- Module 2 needs to reach production-ready and accumulate ~150–250 scenarios before Boss-exam integration is considered (mirrors Module 1's 251-scenario depth).

### 12.8 Future gamification boundaries
- Chips / XP / cosmetics / rank rewards remain **scoped to preflop only** for the duration of v4.x. Postflop intentionally does not award chips for completing sessions — quality and mastery are tracked locally only.
- This boundary is preserved through v4.1.2 and beyond. If Postflop earns its own reward currency later, it gets a new unit (e.g., "Mastery points") to keep accounting separate.

### 12.9 What stays separate, and why
- **Preflop drill state** (`App.state.drill`) and **postflop drill state** (`App.state.postflopDrill`) remain separate stores. Mixing them would create a confusing single queue that breaks both flows.
- **Preflop Boss / Mission / Challenge / Overall Exam state** stays preflop-only. Module 2's eventual Boss exam lives under a separate code path, even though both surfaces ultimately feed into a unified mastery view (TBD, post v5.0).
- **`rmtt_postflop_history` is one blob covering both modules** so the Academy snapshot reads a single source. Sessions are tagged with their `module` already; aggregations can filter as needed.

---

## 13. Module 1 vs Module 2 — Clear Difference

This framing must show up consistently in every Module 2 surface (curriculum card copy, syllabus, summary header, concept-drill labels):

|   | **Module 1 — Board Texture Foundations** | **Module 2 — Flop C-bet IP** |
|---|---|---|
| **The question** | "What does this board mean?" | "What should this hand do on this board?" |
| **The skill** | Board reading | Applying board reading to a hand-level action |
| **Unit of learning** | Board family / texture / advantage | Hand class × board family × action reason |
| **Inputs** | Board only (`heroHand` is null/optional) | Board + heroHand (always two cards) |
| **Question types** | range_advantage, nut_advantage, sizing_family, frequency_strategy, dynamic_level, action_choice (board-level) | action_choice (hand-level), reason_choice |
| **Answer space** | preflop_raiser/caller, range_small/polar_big/check_heavy, etc. | bet_small/bet_big/check/mixed, value/protection/bluff/etc. |
| **Outputs** | A label about the spot | A decision about the spot |
| **Prerequisite** | None | Module 1 mastery (display-only — not enforced) |
| **Marketing copy** | "Read the board." | "Choose the action." |

The intentional product narrative across the curriculum:
- **Module 1**: Read the board.
- **Module 2**: Choose the action with a hand.
- **Module 3**: Defend out of position.
- **Module 4–5**: Turn / river decisions.
- **Module 6 — Boss Exam**: Prove mastery under mixed pressure.

---

## 14. Risks of system clutter, and how the plan avoids them

| Risk | Mitigation in this plan |
|---|---|
| Module 2 becomes a disconnected new tab | Stays inside Postflop Academy; appears as the second card on the existing curriculum map |
| Two competing summary screens | `renderPostflopComplete` is reused with a new `mode` value; no second summary surface |
| Two competing history schemas | `rmtt_postflop_history` is the single source; sessions are tagged by `module` |
| Concept Library bloat (every M2 idea becomes a card) | Reuse existing 10 concepts where they fit; add new concepts only in a *later* patch and only after demonstrated UI demand |
| Schema explosion (new field for every nuance) | Additive only — `heroHand`, `handClass`, `heroHandRole`, `drawCategory`, `showdownValue`, `blockerNote`, `recommendedAction`, `actionReason`. No Module 1 field renamed or removed |
| Weak-spot logic forks | Reuse v4.0.12 weak-spot architecture; extend with `weakHandClasses` / `weakActionReasons` later as additive scoring signals |
| Gamification mixing (chips for postflop) | Explicit boundary: no chips / XP / cosmetics earned from postflop in v4.x |
| Premature exposure (player tries to start broken Module 2) | `_pfModuleStatus('m2', stats)` returns `'preview'` — preview action shows inline syllabus only; no `startPostflopDrill('pf_flop_cbet_ip', ...)` call exists |

---

## 15. Open questions for human review

1. **Replace vs extend the 11 baseline scenarios?** When Module 2 data ships, do we (a) drop the baseline 11 and ship the v4.1.2 24 + future expansion as the new authoritative set, (b) keep the baseline 11 *and* add the v4.1.2 24 (35 total before further expansion), or (c) refactor the baseline 11 to the v4.1.2 schema (rename `bet_33` → `bet_small`, add `heroHandRole`, etc.) and then add the 24?
2. **Sizing family naming.** Confirm `bet_small` / `bet_big` is the family-level vocabulary going forward (rather than `bet_33` / `bet_75`).
3. **Mastery gating.** Should Module 2 actually require Module 1 mastery, or stay display-only as M1 is currently? Recommendation: stay display-only — gating frustrates beta testers and we don't have the engagement data to justify it yet.
4. **Concept Library expansion.** When ready, which of the 9 candidate M2 concepts (§ 12.3) make the cut for `_PF_CONCEPT_LIBRARY`? Recommendation: pick 4 (`value_betting`, `protection_betting`, `semi_bluff_with_equity`, `pot_control`) — keeps the library scannable.
5. **Reason-choice question depth.** Is 6 / 24 (~25%) the right ratio for `reason_choice` vs `action_choice`? Tester data needed.

These are flagged here, restated in the GPT review package, and **not blockers for v4.1.2 commit** — answers can land in v4.1.3 (data-and-integration sprint).
