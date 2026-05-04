# v4.0.0 — Post-flop GTO Foundation Architecture

**Status**: Planning package only. No app code changes. Awaiting review/approval before implementation.

**Goal**: Add Post-flop NLH MTT training as a separate, scalable, auditable training domain. Quality and data integrity over speed and feature breadth.

---

## 1. Design philosophy

The Post-flop trainer is **not a solver embedded in the UI**. It is a **decision-system trainer** built on:

1. **Curated scenarios** — every scenario is hand-authored, tagged with reasoning, and audited before it ships. There are no generated questions.
2. **Range-first reasoning** — every explanation must teach why a board favors a range, not just "solver says X."
3. **Multi-tier scoring** — post-flop has mixed strategies; binary right/wrong is wrong. Best / Acceptable / Bad / Critical.
4. **Concept taxonomy** — every scenario is tagged with concepts (`range_advantage`, `dry_high_card_strategy`, etc.) so we can track concept-level mastery, not just hand-level.
5. **Audit before ship** — the schema is enforceable; a JSON file fails the audit if it has a missing explanation, an invalid board, or a contradictory tag. No production scenario without `auditStatus: "approved"`.
6. **Foundation first** — v4.0 covers ONE pre-flop tree (BTN open vs BB call, 100BB SRP, flop only) plus the universal Board Texture Trainer. Streets / positions / stack depths / multi-way / ICM are explicitly out of scope.

---

## 2. v4.0 scope (locked)

### In-scope

- **New training domain**: `postflop` (sibling to existing `preflop`).
- **Two modules**:
  1. **Board Texture Trainer** — universal, board-only (no hero hand). Teaches range advantage, nut advantage, dynamic vs static, c-bet frequency family.
  2. **Flop C-bet IP Trainer** — BTN open vs BB call, 100BB, single raised pot, flop only. Hero=BTN. Actions: `check`, `bet_33`, `bet_75`.
- **Scenario library**: 20–40 hand-authored seed scenarios covering both modules (this package ships **30**).
- **Schema**: strict JSON schema with explanation, scoring tiers, audit status.
- **Concept taxonomy**: 24 concepts with short + long definitions and cross-references.
- **Board taxonomy**: high-card class, texture tags, suit texture, connectedness, paired status, dynamic level, range/nut advantage, sizing family.
- **Audit tool**: 17 rules + browser-based viewer (`postflop_audit.html`) — no Node toolchain required.
- **Multi-tier scoring**: `best=1.0 / acceptable=0.5 / bad=0 / critical=0+flag`.
- **Multi-section explanations**: `short / rangeLogic / nutLogic / handLogic / sizingLogic / commonMistake` (any null when not applicable).
- **Integration map**: how the postflop drill engine plugs into the existing app without breaking preflop.

### Out of scope (explicitly NOT shipping in v4.0)

- Full solver engine.
- All streets (turn, river — flop only).
- Multiway post-flop.
- ICM-aware ranges.
- River bluff-catching trees.
- All positions (only BTN vs BB SRP for Module 2; Module 1 is universal).
- All stack depths (100BB only).
- Node locking, exact solver-frequency mimicry.
- Cosmetic rewards / Answer FX / Aura / Collection slots for postflop.
- New FX / new bosses / new chips formula tweaks.
- Modifications to existing preflop data, scoring, or rewards.

### Out of scope until later major versions

- Module 3: BB Defense vs C-bet (planned v4.1).
- Turn / river modules (planned v4.2+).
- BTN vs SB SRP, CO vs BB SRP (planned v4.3+).
- 3-bet pots flop module (planned v4.4+).
- ICM-aware adjustments at <30BB (planned v5.x).

---

## 3. Module specifications

### Module 1 — Board Texture Trainer

**Purpose**: Teach the player to *read a board* before making any action decision. This is the foundational skill — every subsequent post-flop module depends on it.

**Question types** (5):
1. **Range advantage** — "Who has range advantage on this board?" (preflop_raiser / caller / neutral / split)
2. **Nut advantage** — "Who has nut advantage on this board?" (same options)
3. **C-bet frequency family** — "What c-bet frequency family fits this board?" (`range_small` / `mixed_small_check` / `polar_big` / `check_heavy` / `low_frequency`)
4. **Sizing family** — "What sizing family is best for the preflop raiser here?" (small / big / split / check-heavy)
5. **Dynamic vs static** — "How dynamic is this board?" (static 1 / semi-static 2 / dynamic 3 / very-dynamic 4)

**No hero hand**. The board is the question. This forces the player to think in ranges, not in "what does my AK do."

**Spot context**: All Module 1 scenarios assume **BTN vs BB SRP, 100BB**, since that is the pre-flop tree v4.0 covers. The taxonomy itself is universal and can be reused in any future tree.

**Seed count**: 20 scenarios.

### Module 2 — Flop C-bet IP Trainer

**Purpose**: Teach the player to make in-position c-bet decisions on the flop after BTN-open vs BB-call.

**Spot**: BTN open 2.5x → BB call → Flop. Hero = BTN.

**Actions**: `check`, `bet_33` (~33% pot), `bet_75` (~75% pot). Three-action menu — kept tight to surface the *category* of decision (check vs small vs polar) without overloading the player with sizing micro-choices.

**Hero hand**: present. Each scenario gives the player a specific holding so they learn how board texture × hand class → action.

**Question type**: `action_choice` — "What action does GTO recommend here?"

**Seed count**: 10 scenarios.

### Module 3 — BB Defense vs C-bet (NOT in v4.0)

Planned for v4.1 after v4.0 is approved and stable. Listed here only so the schema can already handle it (action menu: `fold`, `call`, `raise`).

---

## 4. Data architecture

### Source-of-truth files (committed)

```
postflop/
  postflop_scenarios.json     ← canonical scenario data
  postflop_taxonomy.json      ← board taxonomy enums
  postflop_concepts.json      ← concept taxonomy w/ definitions
```

These are the only files the app ever reads. Everything else (audit, docs) is derived or human reference.

### Audit toolchain (committed but not loaded by app)

```
postflop/
  postflop_audit_rules.js     ← 17 audit rules as pure functions
  postflop_audit.html         ← browser audit viewer (self-contained)
  audit-report-sample.md      ← example output
```

Audit runs in the browser by opening `postflop_audit.html` — no Node, no build step.

### Documentation (committed for review)

```
postflop/
  ARCHITECTURE.md   ← this file
  postflop_schema.md
  RISKS.md
```

---

## 5. Integration with the existing app (when v4.1 implementation lands)

The existing app uses these structures (verified by code survey, file/line references in parens):

- **Drill state**: `App.state.drill = { mode, queue[], currentIndex, currentQuestion, answers[], phase, streak, startTime }` (index.html:10835)
- **Question item shape**: `{ key, stack, pos, action, hand, freqs }` (index.html:10887)
- **SRS key format**: `"${stack}BB_${pos}_${action}_${hand}"` stored in `localStorage.rmtt_progress` (index.html:12584)
- **Module registry**: `MODULE_DISPLAY_INFO` + `MODULE_ZONES` (index.html:13885)
- **Modes**: `quick / deep / weakness / challenge / overall_exam / marginal` (index.html:10287)
- **Answer classification**: `classifyAnswer(userAction, freqs)` → `{ result, score, userFreq, isPure }` (index.html:11219)

### Integration plan (non-invasive)

1. **Add a `domain` field at the top of the drill state**: `App.state.drill.domain = 'preflop' | 'postflop'` (default `'preflop'`). All existing code paths default to preflop and require zero changes.

2. **Question item polymorphism**: a postflop question item has a richer shape:
   ```
   { id, domain: 'postflop', module, scenario }
   ```
   where `scenario` is the full object from `postflop_scenarios.json`. The drill loop branches on `domain` for render and classify.

3. **Separate SRS storage**: postflop progress lives under `localStorage.rmtt_postflop_progress` keyed by `scenario.id`. This avoids any chance of collision with the preflop SRS key format (`"100BB_BTN_open_2.5x_AKs"` vs scenario IDs like `"pf_btn_v_bb_srp_100bb_flop_AhKd5c_freq_001"`).

4. **Module registry extension**: `MODULE_DISPLAY_INFO` and `MODULE_ZONES` get two new entries — `pf_board_texture` and `pf_flop_cbet_ip`. Existing entries are untouched.

5. **New classifier**: `classifyPostflopAnswer(userChoiceId, scenario)` → `{ result: 'best'|'acceptable'|'bad'|'critical', score, isCritical }`. Lives next to the existing `classifyAnswer` but is its own function — no shared mutable state.

6. **New render functions**: `renderPostflopQuestion(scenario)` and `renderPostflopAnswer(scenario, userChoiceId, cls)`. Reuse the existing drill chrome (header, progress bar, action buttons, breakdown card) — only the body content differs.

7. **Stats breakdown**: postflop stats logged as `{ domain: 'postflop', module, conceptTags, result, score, isCritical }` in `d.answers[]`. The summary screen aggregates them under a separate "Post-flop" section that only appears if any postflop answers were given that session. Preflop stats render exactly as today.

8. **Module gating**: postflop modules appear in the existing module picker with a `[BETA]` tag. Until the player has cleared a Module 1 unlock test, Module 2 is greyed out — same gating pattern the app already uses for boss tests.

### What does NOT change

- `ranges.json` — untouched.
- `classifyAnswer` — untouched (preflop classifier).
- `getSRSKey`, `updateSRS` — untouched.
- Existing modules in `MODULE_DISPLAY_INFO` — untouched.
- Chips formula, XP formula, Cosmetic grant hooks — untouched.
- Service worker cache list — gets `postflop_scenarios.json`, `postflop_taxonomy.json`, `postflop_concepts.json` added; otherwise unchanged.
- Boss / Mission / Challenge — not extended in v4.0. Will gain postflop variants in v4.x once foundation is solid.

---

## 6. UI / UX plan

### Question screen (postflop)

```
┌────────────────────────────────────────────┐
│ Q 4 / 20 ─────────────────────────         │
│ Module: Board Texture Trainer              │
├────────────────────────────────────────────┤
│ 📋 SPOT                                     │
│ 100BB · BTN open · BB call · SRP           │
│ Hero: — (board read)                       │
├────────────────────────────────────────────┤
│ 🎴 BOARD                                    │
│   [A♥]  [K♦]  [5♣]                          │
├────────────────────────────────────────────┤
│ ❓ QUESTION                                 │
│ Who has range advantage on this board?     │
├────────────────────────────────────────────┤
│ ▢ Preflop raiser (BTN)                     │
│ ▢ Caller (BB)                              │
│ ▢ Neutral / split                          │
└────────────────────────────────────────────┘
```

For Module 2 questions, add the hero hand row between SPOT and BOARD.

### Feedback screen (postflop)

Two-tier reveal — short answer first, expandable details below.

```
┌────────────────────────────────────────────┐
│ ✅ Best — Preflop raiser (BTN)              │
│                                            │
│ 💡 BTN's range contains way more A-x.      │
│    BB 3-bets most strong A-x preflop.      │
│                                            │
│ ▸ Range Logic                              │
│ ▸ Nut Logic                                │
│ ▸ Sizing Logic                             │
│ ▸ Common Mistake                           │
│                                            │
│ Concept tags: range_advantage,             │
│   A_high_board, dry_board                  │
│                                            │
│ [ Next Hand → ]                            │
└────────────────────────────────────────────┘
```

Acceptable answers get `≈ Acceptable` icon and `0.5 pts`. Critical mistakes get `❌ Critical leak` plus a red flag and a link to a related concept page (planned v4.1).

### Mobile (375px) constraints

- Board cards: 56×80px each, 12px gap.
- Hero hand cards: 44×64px.
- Choice buttons: full-width, min-height 56px, 14px font, all-caps action label.
- Collapsible sections: closed by default on mobile to avoid scroll fatigue.

---

## 7. Audit pipeline (run before any data ship)

The audit is **mandatory** — no scenario ships unless its `auditStatus = "approved"` AND it passes all 17 audit rules.

Workflow:

1. Author writes / edits scenario in `postflop_scenarios.json`. Sets `auditStatus = "draft"`.
2. Author runs audit: open `postflop_audit.html` in browser. Tool loads scenarios + taxonomy + concepts and runs all 17 rules. Report shows pass/fail per rule per scenario, plus aggregate stats.
3. Author fixes any rule failures, re-runs audit until all green.
4. Author marks scenario `auditStatus = "approved"`. Re-runs audit to confirm.
5. App ONLY loads scenarios where `auditStatus = "approved"`. Drafts are visible in the audit tool but invisible in the app.

Audit rules — full list in `postflop_audit_rules.js`. Summary:

| # | Rule | Severity |
|---|---|---|
| R01 | Required fields exist (id, version, module, street, board, question, answer, scoring, explanation, conceptTags, difficulty, sourceConfidence, auditStatus) | error |
| R02 | Board cards are valid (3 cards on flop, all in 52-card deck, no duplicates) | error |
| R03 | No duplicate scenario IDs | error |
| R04 | Question choices include all answer keys (best/acceptable/bad/critical referenced ids must exist in choices) | error |
| R05 | At least one `best` answer exists | error |
| R06 | Explanation `short` exists and is non-empty (other sections may be null) | error |
| R07 | All `conceptTags` exist in `postflop_concepts.json` | error |
| R08 | `difficulty` is integer 1–5 | error |
| R09 | All board texture tags exist in `postflop_taxonomy.json` | error |
| R10 | `rangeAdvantage` and `nutAdvantage` values are in taxonomy enums | error |
| R11 | Scoring tier values are valid (`best=1.0`, `acceptable in [0.25, 0.5, 0.75]`, `bad=0`, `critical=0`) | error |
| R12 | Critical mistakes carry `criticalReason` in explanation OR explicit field | warning |
| R13 | No contradictory board tags (e.g., `monotone` + `rainbow`) | error |
| R14 | Board class plausible vs recommended action — heuristic check (e.g., dry A-high BTN-favored board should not have `check_heavy` in `best`) | warning |
| R15 | Mixed/acceptable actions not falsely marked `critical` | error |
| R16 | `auditStatus = "approved"` only on scenarios passing R01–R15 with zero errors | error |
| R17 | All `sourceConfidence` values are in enum (`consensus_gto`, `solver_verified`, `expert_judgment`, `community_consensus`, `experimental`) | error |

**Aggregate stats reported**:
- Total scenarios; pass/fail count; approved vs draft.
- Concept coverage (which concepts have ≥3 scenarios; which are starved).
- Difficulty distribution (1–5).
- Board texture distribution.
- Module distribution.
- Source confidence distribution.

---

## 8. GTO accuracy guardrails

The app does NOT contain a solver. Scenario truth values come from:

- **Public solver consensus** — multiple independent solver outputs converging on the same answer (e.g., "BTN c-bets ~75% of range on A-high dry boards" is consensus across PioSolver, GTO+, and Wizard solutions in the public domain). Tag: `sourceConfidence: "consensus_gto"`.
- **Solver verified** — a specific solver output the author has independently checked. Tag: `sourceConfidence: "solver_verified"`.
- **Expert judgment** — well-known coaching consensus where solver work is impractical (e.g., "MTT chipEV vs ICM-deep adjustments"). Tag: `sourceConfidence: "expert_judgment"`.
- **Community consensus** — broad agreement from training site curricula (Run It Once, Upswing, etc.). Tag: `sourceConfidence: "community_consensus"`.
- **Experimental** — author opinion under review. Tag: `sourceConfidence: "experimental"`. Such scenarios SHOULD NOT be marked `auditStatus: "approved"`.

The audit tool counts `experimental + approved` combinations and flags them as warnings — author must justify in commit message.

### Why ranges, not hands

Every scenario explanation MUST address the question through ranges, not in-hand isolation. A scenario whose `rangeLogic` is empty or whose `short` reads "AK is strong, bet" fails audit warning R14.

Hands enter the picture only in Module 2+ (where Hero has a hand) and only as one of multiple inputs (range-driven sizing × hand class × board interaction). The `handLogic` section explains how the *hand class* fits into the *range strategy*, not as a standalone justification.

---

## 9. Progress tracking (postflop-specific)

When implemented, postflop session results are logged separately so progress dashboards stay clean:

```
localStorage.rmtt_postflop_stats = {
  schema: 'postflop-stats-v1',
  byModule: {
    pf_board_texture: { seen, best, acceptable, bad, critical, accuracyPct },
    pf_flop_cbet_ip: { ... }
  },
  byConcept: {
    range_advantage: { seen, accuracyPct, lastSeen },
    nut_advantage: { ... },
    ...
  },
  byBoardClass: {
    A_high_dry: { seen, accuracyPct },
    K_high_wet: { ... },
    ...
  },
  bySpot: {
    'BTN_v_BB_SRP_100BB': { ... }
  },
  criticalLeaks: [
    { scenarioId, conceptTag, timestamp }
  ]
}
```

Dashboard widget surfaces the player's weakest concept ("You miss `nut_advantage_shift` 60% of the time → study these 5 boards") — the SRS layer recommends scenarios tagged with the weak concept.

---

## 10. Versioning

- **Schema version** lives at the top of `postflop_scenarios.json`: `"schemaVersion": "1.0.0"`.
- **Each scenario** has its own `version` field (initially `"1.0.0"`). Bump the scenario version when reasoning changes; leave id stable so SRS history continues.
- **Taxonomy / concepts** also have `version` fields — bumped when enums change (which is rare and requires a cross-file sweep + audit re-run).
- **App reads** the schema version on load and refuses to run if it does not match the version it knows about. This is the single guardrail against shipping incompatible data.

---

## 11. Risks and mitigations

Full risk register lives in `RISKS.md`. Top risks:

| # | Risk | Mitigation |
|---|---|---|
| 1 | Scenario data is wrong or controversial | All scenarios audited; `sourceConfidence` field tracks confidence level; community review process planned for v4.1+ |
| 2 | Schema is too rigid and can't accept future modules (turn, river, ICM) | Schema designed with optional fields (`heroHand`, `actionHistory`, `street`); extension is additive, not breaking |
| 3 | Player overwhelmed by multi-section explanation | Two-tier reveal (short answer first, sections collapsed); learner-friendly defaults |
| 4 | Postflop integration breaks preflop drill engine | Domain field defaults to preflop; postflop is additive; QA gate verifies preflop regression |
| 5 | Sample data biased toward certain board classes | Audit reports texture distribution; ship requires >=8 distinct texture combos in seed |
| 6 | SRS history pollution between preflop and postflop | Separate localStorage keys; scenario IDs are namespaced (`pf_*`) |
| 7 | App can't tell whether to load v4.0 data on a player who imported a v3.x backup | `appVersion` in backup file already exists; postflop data is additive — safely ignored by older versions |

---

## 12. Approval gate

Before any code changes land in `index.html`, this planning package needs sign-off on:

1. **Schema** is sound and extensible.
2. **Taxonomy** covers all needed dimensions without redundancy.
3. **Concept taxonomy** is GTO-correct and complete enough for Module 1 + 2.
4. **Sample scenarios** are GTO-defensible and pedagogically clear.
5. **Audit rules** catch realistic mistakes.
6. **Integration plan** is genuinely non-invasive.
7. **Out-of-scope list** is acceptable (i.e., the user agrees these are NOT shipped in v4.0).

After sign-off, implementation phases:

- **v4.0.1**: schema loader + audit gate in app + render Module 1 board only (no answers yet).
- **v4.0.2**: Module 1 fully playable.
- **v4.0.3**: Module 2 fully playable.
- **v4.0.4**: postflop SRS + module-specific stats dashboard.
- **v4.0.5**: bump seed data 30 → 160 scenarios.
- **v4.0.6**: polish, mobile passes, accessibility audit.

---

## 13. Files in this planning package

| File | Purpose |
|---|---|
| `ARCHITECTURE.md` (this file) | Full architectural proposal |
| `postflop_schema.md` | Field-by-field schema spec, scoring model, UI plan |
| `postflop_taxonomy.json` | Board / suit / dynamic / advantage / sizing enums |
| `postflop_concepts.json` | 24 concepts with short + long definitions |
| `postflop_scenarios.json` | 30 audited seed scenarios (Modules 1 + 2) |
| `postflop_audit_rules.js` | 17 audit rules as pure functions |
| `postflop_audit.html` | Self-contained browser audit viewer |
| `audit-report-sample.md` | Example human-readable audit output |
| `RISKS.md` | Full risk register + mitigations |

---

**End of architecture proposal. Awaiting review.**
