# DEC-001 — Post-flop will be a data-first auditable domain

## Status
**accepted**
Date: 2026-05-04

## Context

The Range Master MTT app trains MTT preflop GTO decisions today. Adding post-flop is the next major training surface (epic v4.0.0).

Post-flop GTO is meaningfully harder to get right than preflop:

- **Decisions are state-rich**: every post-flop spot depends on board cards, suit pattern, hero hand, action history, range adjustments, and sizing trees — far more state than a preflop spot.
- **Mixed strategies are real**: many post-flop spots have no single "correct" answer; solver outputs split frequencies across multiple actions. Binary right/wrong scoring would mis-train players.
- **Errors are expensive**: a wrong "best" answer on a popular spot teaches a real leak to thousands of player-sessions before it's noticed.
- **Truth values can shift**: as solver consensus evolves or as we extend to ICM/multi-way, individual scenario answers may need updating.
- **Authors disagree**: different reasonable poker minds will disagree on close mixed spots; without a structured way to capture confidence, we'd ship inconsistent guidance.

The natural temptation is to encode post-flop logic directly in the UI — write JS that classifies a board, picks an action recommendation, and renders a feedback screen. That approach scales fast for the author but is unauditable and hard to fix in production.

We need an architecture that:

1. Lets us write scenarios as data (not code).
2. Makes truth values explicit and reviewable.
3. Has an audit gate that blocks bad data from shipping.
4. Lets us version, deprecate, and supersede individual scenarios without code changes.
5. Lets non-developer reviewers (poker coaches, community contributors) audit without reading JS.

## Decision

**Post-flop training will be implemented as a data-first auditable domain.**

Concretely:

1. **Scenario data lives in JSON** (`postflop/postflop_scenarios.json`) with a strict schema. Every scenario is hand-authored and includes: spot context, board, hero hand (when applicable), question, multi-tier answer (best/acceptable/bad/critical), explanation (multi-section), concept tags, difficulty, source confidence, and audit status.
2. **Concept and board taxonomies live in JSON** (`postflop/postflop_concepts.json`, `postflop/postflop_taxonomy.json`). The app loads these as enums and reference; they are the single source of truth for valid tags.
3. **Audit is mandatory**. A 17-rule audit (`postflop/postflop_audit_rules.js`) runs against the data. The browser viewer (`postflop/postflop_audit.html`) and the Node CLI (`tools/audit-postflop.js`) execute the same rules.
4. **The app refuses to load any scenario** unless `auditStatus = "approved"` AND the scenario passes all error-level audit rules.
5. **The app does not classify or solve** — it only serves data. All truth values are pre-computed by the author and validated by the audit. The drill engine is a thin presenter.
6. **Versioning** lives at three levels: schema version (in the envelope), per-scenario version (allows author iteration without losing SRS history), and taxonomy version.
7. **Source confidence** is required per scenario: `consensus_gto`, `solver_verified`, `expert_judgment`, `community_consensus`, or `experimental`. The audit warns when `experimental + approved` co-occur.

## Alternatives considered

### Alternative A — In-code logic ("solver lite" in JS)

Implement post-flop classification directly in `index.html`: a function that takes board + hero hand + action and returns a recommendation.

**Rejected because**:
- Unauditable. Reviewer needs to read JS to verify a poker claim.
- Hard to fix. A wrong recommendation requires a code change + version bump + redeploy.
- Hard to extend. Adding ICM, multi-way, or new spot families means rewriting the function.
- Mixed strategies are awkward — JS conditionals can't naturally express "this is 60% bet, 40% check."
- The "logic" is really baked-in opinions; code hides that. Data exposes it.

### Alternative B — Pull from a real solver via API at runtime

Connect the app to PioSolver / Wizard / GTO+ and fetch live solver outputs on demand.

**Rejected because**:
- Solver APIs are not free; sustained tournament traffic would be costly.
- Latency would degrade UX (drill flow must feel instant).
- Solver outputs are themselves opinions of a particular configuration (rake, stack depth, range assumptions). Hiding that from the player teaches them to defer to opaque authority instead of reasoning.
- App becomes online-only; PWA offline value disappears.
- Complex ongoing dependency on a third-party we don't control.

### Alternative C — Fully crowd-sourced data ("wiki for postflop spots")

Open the scenarios file to community contributions; resolve disagreements via voting.

**Rejected for v4.0** (might revisit for v4.x):
- No QA gate at the start makes early data untrustworthy.
- Voting doesn't resolve real disagreements about GTO truth.
- Audit infrastructure isn't yet sophisticated enough to catch subtle reasoning errors.
- v4.0 needs a defensible foundation built by a small set of authors before opening contributions.

### Alternative D — Hybrid: embed a small solver in WASM for live computation

Use a lightweight WASM-built solver to compute frequencies in-app for any board.

**Rejected** because:
- Engineering complexity is enormous for v4.0.
- WASM solvers that fit in a PWA bundle are dramatically less accurate than desktop solvers.
- Same problem as alternative A — the truth values become hidden behind code that reviewers can't easily check.
- Solver runtime per question would add hundreds of milliseconds to drill flow.

## Consequences

### Positive

- **Auditable**: every truth value is a JSON field with a human-readable explanation. Anyone (poker coach, contributor, reviewer) can check a scenario without reading code.
- **Fixable in production**: a wrong answer is a JSON edit + audit re-run, not a code change.
- **Extensible**: new modules (BB Defense, turn, river, multi-way, ICM) are additive — same schema, new files. The drill engine doesn't change.
- **Versionable**: per-scenario versioning lets authors revise without losing player SRS history.
- **Portable**: the data files can be reused by other tools (a reviewer's spreadsheet, an export to a coaching platform, a research dataset).
- **Decoupled from code**: poker-knowledge updates do not require app releases.

### Negative / costs

- **Slower upfront**: hand-authoring scenarios is slower than writing logic. v4.0 ships only 31 scenarios; a comparable code-based approach might cover 100+ board classes.
- **Coverage gaps are visible**: the audit shows starved concepts (`ip_advantage`: 0 scenarios). With code-based logic we could pretend to cover everything; with data we admit what we don't cover.
- **Author judgment is the bottleneck**: bad authors → bad scenarios. We mitigate via `sourceConfidence` + audit, but ultimate quality depends on the people writing data.
- **Schema commitment**: changing the schema later requires migration. We accept this and lock the v1 schema before scaling data.

### Commitments this decision creates

- The audit gate is **non-negotiable**. We do not ship un-audited scenarios.
- The schema is the contract. All authors and the app must respect it.
- We will publish the audit reports alongside data versions so reviewers can inspect quality.
- Future module additions follow the same pattern (data + audit + concept tags) — no carve-outs.

## Related

- Spec: [`postflop/ARCHITECTURE.md`](../../postflop/ARCHITECTURE.md) — the full architecture proposal this decision underpins.
- Spec: [`postflop/postflop_schema.md`](../../postflop/postflop_schema.md) — the schema this decision commits us to.
- Spec: [`docs/specs/postflop-v4-foundation.md`](../specs/postflop-v4-foundation.md) — high-level spec index.
- Risk register: [`postflop/RISKS.md`](../../postflop/RISKS.md) — risks this approach surfaces (esp. R-01 GTO correctness, R-05 board class bias, R-06 author disagreement).
- Audit: [`postflop/postflop_audit_rules.js`](../../postflop/postflop_audit_rules.js) — the gate this decision requires.
- Workflow: [`AGENTS.md`](../../AGENTS.md) — file ownership model that reflects this separation.

## Revisit triggers

Reopen this decision if any of the following becomes true:

- A reliable, free, low-latency solver API becomes available (would make alternative B viable).
- WASM solver tooling matures to the point where embedded solvers fit in a PWA bundle and produce solver-equivalent output (alternative D).
- Hand-authoring proves too slow to keep up with player demand (consider C — gated community contribution).
- The audit gate fails to catch wrong data in practice (we'd need stronger validation, possibly automated solver cross-checks).
