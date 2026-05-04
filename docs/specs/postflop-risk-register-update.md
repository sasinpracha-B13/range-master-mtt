# Risk Register Update — Postflop (post v4.0.1, pre v4.0.2)

> **Owner**: Orchestrator.
> **Status**: incremental update layered onto `postflop/RISKS.md` (v4.0.0 register).
> **Trigger**: planning sprint for v4.0.2 surfaced new risks; some existing risks have evolved.
> **Date**: 2026-05-04.

---

## How this file relates to `postflop/RISKS.md`

The base risk register lives in `postflop/RISKS.md` (13 risks rated by severity). This update file:

1. **Adds new risks** discovered during the v4.0.2 planning sprint (R-14 through R-17).
2. **Updates status of existing risks** that have evolved (R-02, R-04, R-05, R-07).
3. **Resolves risks** that are no longer active (none yet).

When the next major planning round happens, the Orchestrator can either fold this update into `postflop/RISKS.md` directly or keep updates as appended files.

---

## New risks (R-14 through R-17)

### R-14 — Choice label hint inconsistency degrades test integrity

**Severity**: 🟠 High.
**Likelihood**: High (already present in shipped data).
**Impact**: Medium-High (UX confusion + reduced learning value).

**Description**: In `postflop_scenarios.json`, ~6 of the 20 Module 1 scenarios include parenthetical hints in their choice labels (e.g., `"Preflop raiser (BTN) — much more A-x"`). Other scenarios don't. A first-time player will either:
- Lean on the hints when present (gets the answer "for free")
- Feel the test is uneven when hints are absent (no apparent reason)

Either way, the trainer's pedagogical value drops because the player isn't consistently forced to reason from board to answer.

**Source**: Scenario Review B3 (`docs/specs/postflop-v4.0.2-scenario-review.md`).

**Mitigations (planned)**:
- v4.0.2 pre-step: GTO Data Subagent strips all rationale hints from choice labels in a data-only commit BEFORE v4.0.2 implementation. (Recommended path in `brief-v4.0.2-implementation-ready.md` § 16.)
- Future: document a "choice label policy" in `postflop_schema.md` — neutral labels only; rationale belongs in `explanation.short`.

---

### R-15 — `sourceConfidence: consensus_gto` overclaimed on borderline scenarios

**Severity**: 🟠 High.
**Likelihood**: Medium (concentrated in 2 of 20 scenarios).
**Impact**: High (a knowledgeable user disputing the "best" answer with a defensible alternative undermines the trainer's authority).

**Description**: Scenarios #10 (`Qh9d6s_freq`) and #11 (`Th8h3h_nutadv`) carry `sourceConfidence: consensus_gto` but their answers depend on solver-mix interpretation or sim-parameter choices. A reviewer could legitimately argue the "best" answer is wrong without the dataset acknowledging the uncertainty.

**Source**: Scenario Review B1, E3 (`docs/specs/postflop-v4.0.2-scenario-review.md`).

**Mitigations (planned)**:
- v4.0.2 pre-step (recommended): downgrade #10 sourceConfidence to `expert_judgment`. #11 is already `expert_judgment` — no change needed but defer from v4.0.2 ship.
- v4.1: introduce a "solver mix" badge in the UI that visually distinguishes consensus answers from solver-mix-region answers.
- v4.2: make `sourceConfidence` visible to the player on the feedback screen (currently audit-only).

---

### R-16 — Field FX bleeding into postflop UI

**Severity**: 🟡 Medium.
**Likelihood**: Medium (depends on whether DEV remembers the suppression).
**Impact**: Medium (visual noise in an analytical surface).

**Description**: The body-level `field-fx-canvas` introduced in v3.8.2 paints across all screens via `position: fixed`. Postflop's analytical surface should NOT inherit this (per UX plan principle #5: "quiet confidence, not animation overload").

**Source**: UX Plan § 5 + § 13; QA Plan E10.

**Mitigations (planned)**:
- v4.0.2 implementation: postflop screen sets `body[data-postflop-active]` attribute on entry; CSS rule `body[data-postflop-active] .field-fx-canvas { opacity: 0.05; transition: opacity 200ms; }` (or full hide). Removed on exit.
- QA Plan E10 explicitly tests this.

---

### R-17 — Mid-session reload loses player progress (no persistence)

**Severity**: 🟡 Medium.
**Likelihood**: Medium (any browser reload, accidental swipe, OS prompt).
**Impact**: Low-Medium (no data loss because there's no SRS yet, but in-session progress is lost — ~10 minutes of work).

**Description**: v4.0.2 keeps `App.state.postflopDrill` in memory only. Mid-session refresh wipes the queue and answer history. The player lands back on Home with no way to resume.

**Source**: QA Plan D5; Architecture brief § 14 Open Question 1.

**Mitigations (planned)**:
- v4.0.2: accept this risk (deliberate — postflop SRS is v4.0.4 territory). Post-session UI shows "Drill Complete!" with summary; mid-session reload silently returns to Home.
- v4.0.3: optional `localStorage.rmtt_postflop_session` key holds the active session for resume-on-reload (separate from history).
- v4.0.4: full `rmtt_postflop_history` schema with completed sessions persisted.

---

## Updates to existing risks

### R-02 — Postflop integration breaks Preflop drill engine — STATUS UPDATE

**Original severity**: 🔴 Critical.
**New severity**: 🟡 Medium.

**Reason for downgrade**: v4.0.1 shipped without breaking preflop (verified by 9/9 live browser QA). The Object.freeze pattern + new namespace + isolated boot trigger all proved sound. v4.0.2 follows the same isolation principles.

**Remaining mitigation**: QA Plan Category B (8 preflop regression items) gates every postflop release.

---

### R-04 — Player overwhelmed by multi-section explanation — STATUS UPDATE

**Original severity**: 🟠 High.
**New severity**: 🟡 Medium (after UX Plan § 6 design decision).

**Reason for downgrade**: UX plan adopted two-tier reveal (short answer always shown, sections collapsible by default on mobile, expanded by default on desktop). This is the strongest mitigation available without per-player customization.

**Remaining mitigation**: monitor section-open rate post-launch; if mobile users open <20% of sections, surface the most-relevant section auto-expanded based on the player's answer (planned v4.1).

---

### R-05 — Sample data biased toward easy/clean board classes — STATUS UPDATE

**Original severity**: 🟠 High.
**New severity**: 🟠 High (no change), but more specific.

**New finding from Scenario Review § E2**: Module 1 difficulty distribution is heavily 1–2 (14 of 20) with only one diff-4 scenario. This is correct for v4.0.2 smoke set BUT means the module has no graduation path — a player who masters all 20 has nothing harder to chase.

**Updated mitigation**:
- v4.1 data expansion priority: add 5–8 diff-3 and 2–3 diff-4 scenarios to Module 1 to give graduation room.
- v4.1 data expansion priority: add Q-high and J-high boards (currently 2 each) per `postflop/audit-report-sample.md` recommendations.

---

### R-07 — Audit tool depends on browser/local server, not CI — STATUS UPDATE

**Original severity**: 🟡 Medium.
**New severity**: 🟡 Medium (no change).

**New finding**: PowerShell smoke audit script (used during v4.0.0 dev) is ad-hoc; not yet captured in `tools/`. The browser audit + Node CLI cover the gap, but a PowerShell pre-commit hook would catch issues at git-commit time.

**Updated mitigation timeline**:
- v4.0.5: add `tools/audit-postflop.ps1` PowerShell wrapper.
- v4.1: GitHub Action that runs the audit on every PR touching `postflop/*.json`.

---

## Risks NOT YET resolved (carryover from `postflop/RISKS.md`)

All other risks (R-01, R-03, R-06, R-08 through R-13) carry forward unchanged. See `postflop/RISKS.md` for full text.

---

## Top risks heading into v4.0.2 implementation

Ranked by Orchestrator's view of where DEV / QA attention should focus:

| Rank | Risk | Why this matters now |
|---|---|---|
| 1 | R-14 (hint inconsistency) | User-visible from first session; addressable by data fix before v4.0.2 |
| 2 | R-16 (Field FX bleed) | Easy to miss in implementation; explicit QA item E10 catches it |
| 3 | R-17 (mid-session reload) | Player frustration risk; document the limitation in v4.0.2 release notes |
| 4 | R-15 (sourceConfidence overclaim) | Trust risk if knowledgeable users surface; partial mitigation via deferring #10/#11 in v4.0.2 |
| 5 | R-02 (preflop regression) | Downgraded but not gone; QA Category B blocks |

---

## Stop condition

This update file is published as part of the v4.0.2 planning sprint. No further changes during v4.0.2 implementation. After v4.0.2 ships, the next planning round folds applicable updates back into `postflop/RISKS.md` and starts a fresh update cycle.

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | Orchestrator | Initial publication during v4.0.2 planning sprint |
