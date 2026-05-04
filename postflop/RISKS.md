# Postflop v4.0 — Risks &amp; Mitigations

This is the active risk register for the Post-flop training domain. Each risk is rated by likelihood × impact and paired with a concrete mitigation. Add new risks to this file as they surface during implementation; do not silently retire entries — mark them `RESOLVED` with the resolution date.

| Severity legend |
|---|
| 🔴 **Critical** — could break existing app or ship wrong GTO data |
| 🟠 **High** — could degrade learning quality or block expansion |
| 🟡 **Medium** — quality-of-life or future-debt risk |
| 🟢 **Low** — cosmetic or contained |

---

## 🔴 Critical

### R-01 — Scenario data is GTO-incorrect

**Likelihood**: Medium. **Impact**: Critical (teaches wrong poker).

**Description**: Hand-authored scenarios may contain errors of judgment, especially in mixed-region spots where the "best" answer depends on solver tolerance, opponent assumptions, or stack-depth nuances we abstracted away. A wrong "best" trains the player into a real leak.

**Mitigations (in place)**:
- `sourceConfidence` field per scenario; `experimental` requires explicit reviewer approval (audit warns).
- Multi-tier scoring (best / acceptable / bad / critical) lets the author hedge when the answer isn't binary — instead of forcing a single "correct" choice, partial-credit acceptable answers absorb genuine mixed regions.
- `commonMistake` explanation forces the author to articulate WHY the wrong answers are wrong — surface-level inconsistency becomes visible.

**Mitigations (planned)**:
- v4.1: introduce community review queue. Any scenario can be re-flagged by a reviewer; flagged scenarios revert to `auditStatus: needs_review` and are removed from active drilling until re-approved.
- v4.1: side-by-side solver verification — author posts the spot to a known solver (PioSolver, Wizard, GTO+) and pastes the output URL into a new `sourceUrl` field. Audit tool checks that `sourceConfidence: solver_verified` scenarios have a populated `sourceUrl`.
- v4.2+: red-flag dashboard — track player-disagreement rate per scenario. Spots where players consistently challenge the "best" answer get auto-flagged for re-review.

---

### R-02 — Postflop integration breaks Preflop drill engine

**Likelihood**: Medium-Low. **Impact**: Critical (regression in shipped product).

**Description**: When implementation lands in `index.html`, the new `domain` field, new question item polymorphism, and new classifier could leak into preflop code paths and cause preflop drills to crash or render wrong.

**Mitigations (in place)**:
- Architecture explicitly designs the integration as **additive only** — preflop default branches require zero edits. The `domain` field defaults to `'preflop'` everywhere it's not set.
- Postflop functions are namespaced (`renderPostflopQuestion`, `classifyPostflopAnswer`) — no shared mutable state with preflop functions.
- Postflop SRS storage is a new localStorage key (`rmtt_postflop_progress`) — zero risk of preflop SRS data corruption.

**Mitigations (planned for implementation phase)**:
- QA gate: every postflop implementation PR must run a preflop regression suite before merge — drill question render, drill answer classify, summary screen, breakdown card, all 5 tabs.
- Feature flag: `App.state.settings.postflopBeta = false` by default in v4.0.1; enable via Settings → Beta Features. Players who don't opt in see no postflop UI and zero risk.
- Service worker version bump separates postflop data fetches from existing cache logic.

---

## 🟠 High

### R-03 — Schema is too rigid to accept future modules

**Likelihood**: Medium. **Impact**: High (would force a v2 schema migration with all data rewrites).

**Description**: v4.0 schema is built around BTN vs BB SRP flop. If turn/river/multiway/ICM scenarios in v4.2+ require structural changes (e.g., per-street action history, ICM context, third-player ranges), we may need a breaking change.

**Mitigations (in place)**:
- `actionHistory` field already present (empty for v4.0 flop questions, populated for turn/river later).
- `street` enum already extends to turn/river.
- `playerCount` field present (locked to 2 in v4.0; relaxes for multiway in future).
- `schemaVersion` per envelope and per scenario — additive bumps (1.x → 1.y) don't break old data; breaking bumps (1.x → 2.0) trigger a documented migration script.

**Mitigations (planned)**:
- v4.1 spec freeze: before adding `pf_bb_def_vs_cbet`, re-walk the schema with the v4.2 (turn) and v4.5 (multiway) needs in mind. Add any missing optional fields now, while data volume is small.
- ICM extension already designed as a future optional `icmContext: { ... }` block — won't require schema 2.0.

---

### R-04 — Player overwhelmed by multi-section explanations

**Likelihood**: Medium. **Impact**: High (engagement drops, players stop using postflop module).

**Description**: Each scenario has 6 explanation sections. On mobile, that's a lot of text. New players may bounce.

**Mitigations (in place)**:
- Two-tier reveal designed into UI plan: short answer first, sections collapsed by default.
- `short` field is required and capped at ~140 chars in author guidance — the player always sees a crisp one-liner first.
- Other sections are nullable — author drops what isn't relevant.

**Mitigations (planned)**:
- v4.0.4 dashboard: track per-player section-open rate. If `commonMistake` is opened by <20% of players, surface it as a "Did you know?" prompt after wrong answers.
- v4.1: progressive reveal — short answer always shown, ONE most-relevant other section auto-expanded based on what the player got wrong (e.g., if player chose `polar_big` when `range_small` was correct, auto-expand `sizingLogic`).

---

### R-05 — Sample data biased toward easy/clean board classes

**Likelihood**: High (already the case in seed). **Impact**: High (teaches the easy half of the game well, leaves the hard half untrained).

**Description**: v4.0 seed leans heavily on clear-cut boards (dry A-high, very wet low-connected). The genuinely hard boards — Q-high semi-connected, two-tone middle, paired low — are underrepresented. A player who masters v4.0 may believe they understand postflop strategy when they only understand the easy spots.

**Mitigations (in place)**:
- Audit reports texture distribution and high-card-class distribution; reviewer can see the bias.
- `audit-report-sample.md` explicitly lists the v4.1 expansion targets to address this.

**Mitigations (planned)**:
- v4.1 hard requirement: ≥8 distinct high-card classes covered, ≥30% of scenarios are non-rainbow, ≥15 scenarios in the difficulty-3-or-4 range.
- v4.1: introduce "tricky boards" focus mode — the SRS layer recommends scenarios from the underrepresented classes more often once the player has cleared the foundation.

---

### R-06 — Authors disagree on GTO truth values

**Likelihood**: Medium. **Impact**: High (data churn, contradictory guidance, player confusion).

**Description**: Different authors will have different opinions on close mixed spots. Without a tie-breaker, the dataset becomes inconsistent.

**Mitigations (in place)**:
- `sourceConfidence` field forces the author to declare confidence level.
- `version` per scenario allows author iteration without losing SRS history.

**Mitigations (planned)**:
- v4.1: tie-breaker policy document (`AUTHOR_GUIDE.md`): when authors disagree, defer to consensus solver output; if no solver consensus, mark `experimental` and route to community review.
- v4.1: scenarios in `experimental` state are excluded from boss tests and challenges — they only appear in normal drill mode and are tagged `[EXPERIMENTAL]` in the UI.

---

## 🟡 Medium

### R-07 — Audit tool depends on browser/local server, not CI

**Likelihood**: High (CI not currently set up). **Impact**: Medium (audit only runs when author remembers).

**Description**: The audit runs in a browser (HTML viewer). Without CI integration, a careless edit can ship without being audited if the author forgets to open the audit page.

**Mitigations (in place)**:
- Audit rules live in a pure-JS module (`postflop_audit_rules.js`) that can also run under Node.js — the same logic, no DOM dependency.
- Audit runs in seconds; very low friction.

**Mitigations (planned)**:
- v4.0.5: add a pre-commit hook (PowerShell) that runs the audit and blocks commits when errors are present. The hook reads scenarios.json + taxonomy.json + concepts.json and runs the same logic via PowerShell-equivalent checks (we already have a working PS smoke test from the v4.0.0 deliverable run).
- v4.1: GitHub Action that runs the audit on every PR touching `postflop/*.json` and posts the report as a PR comment.

---

### R-08 — SRS history pollution between preflop and postflop

**Likelihood**: Low. **Impact**: Medium (player progress disappears or is misattributed).

**Description**: If both domains share storage keys, postflop SRS could overwrite preflop entries or vice versa.

**Mitigations (in place)**:
- Architecture specifies separate localStorage keys: `rmtt_progress` (preflop) vs `rmtt_postflop_progress` (postflop).
- Scenario IDs are namespaced (`pf_*`) — even if a typo collides with a preflop key format, the namespacing prevents real collision.

**Mitigations (planned)**:
- Implementation phase QA: smoke-test by exporting a preflop backup, importing it into a fresh app, and verifying postflop progress is unaffected. Repeat in reverse direction.

---

### R-09 — Backup/import compatibility across versions

**Likelihood**: Medium. **Impact**: Medium (player loses postflop progress when restoring an old backup).

**Description**: Players who export a v3.x backup, install v4.0+, and import will not have postflop data restored (it didn't exist). Reverse: player on v4.0 exports, then downgrades to v3.x and tries to import — postflop fields will be ignored.

**Mitigations (in place)**:
- Backup format already includes `appVersion` field (currently bumping per version).
- Postflop data is additive — old import paths simply skip the new keys.

**Mitigations (planned)**:
- v4.0.1: import flow surfaces a "your backup was from v3.x; postflop data is empty for this profile (this is expected)" notice when a pre-v4.0 backup is imported into v4.0+.
- v4.0.5: backup export bundles BOTH preflop and postflop progress into a single file. Player gets one backup that survives both directions.

---

### R-10 — Concept-mastery dashboard demands clean tagging

**Likelihood**: Medium. **Impact**: Medium (dashboard feature is useless if tagging is sloppy).

**Description**: The v4.0.4 dashboard depends on every scenario being tagged with the right concepts. If authors tag inconsistently (e.g., one scenario uses `dry_high_card_strategy`, another uses `dry_board` for the same idea), the per-concept stats become noisy and the dashboard misguides players.

**Mitigations (in place)**:
- `postflop_concepts.json` is the single source of truth; audit rule R07 rejects unknown tags.
- Each concept entry has explicit `relatedConcepts` to discourage near-duplicates.

**Mitigations (planned)**:
- v4.1 author guide: add a "tag taxonomy" section explaining when to use each concept vs related concepts.
- v4.1: dashboard surfaces low-coverage concepts back to authors (the "starved concepts" report) so the gap closes naturally.

---

## 🟢 Low

### R-11 — Player wants to study a specific board they hit in real play

**Likelihood**: Low. **Impact**: Low (feature gap, not a bug).

**Description**: Players may want to type in a specific board (e.g., "what's the right c-bet on Q♥9♠4♣?") and get the trainer's answer. v4.0 only serves the curated dataset.

**Mitigations (planned)**:
- v4.2+: scenario search by board cards. Returns the closest matching scenario and any related concepts. Not a solver — just a lookup with a "best match" disclaimer.

---

### R-12 — Scenario count grows unbounded; UI/loading slows

**Likelihood**: Low (slow growth). **Impact**: Low (manageable if proactively chunked).

**Description**: At ~30 scenarios v4.0, JSON load is trivial. At 1000+ scenarios, the file gets large and load times slow.

**Mitigations (planned)**:
- v4.3+: chunk scenarios by module into separate files (`postflop_scenarios_module1.json`, etc.). App lazy-loads on demand.
- v4.4+: SQLite/IndexedDB for scenario storage if file size exceeds 1 MB.

---

### R-13 — Author writes too-long explanations

**Likelihood**: Medium. **Impact**: Low (aesthetic, not functional).

**Description**: A passionate author writes a 500-word `rangeLogic` section. UI doesn't break but the player tunes out.

**Mitigations (planned)**:
- v4.1: soft length limits in the author guide (`short` ≤ 140 chars; other sections ≤ 300 chars).
- v4.1: audit tool warns (not errors) when a section exceeds the soft limit.

---

## RESOLVED

(None yet — first risk register publication.)

---

## How to maintain this register

- Add new risks **at the bottom of the appropriate severity block** with a sequential ID (`R-14`, `R-15`, …). Do not renumber existing entries.
- When a risk is resolved, MOVE it to the `RESOLVED` section with a one-line note: "Resolved [date] — see [PR / commit / file]." Do not delete entries.
- When a mitigation lands, update the entry's "Mitigations (in place)" section. Keep "Mitigations (planned)" focused on remaining work.
- Re-rate severity if the situation changes (e.g., low likelihood → high after a real-world incident). Note the rating change with date.

The risk register is part of the v4.0.0 review package; it should be re-walked at each minor version bump.
