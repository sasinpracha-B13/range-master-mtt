# Brief — v4.0.1: Post-flop Schema Loader + Audit Gate

> **Status**: planning only. Awaiting human approval before DEV Integration Agent begins implementation.
> **Owner once approved**: DEV Integration Agent.
> **Reviewer**: Orchestrator (file ownership), QA Agent (post-implementation), Audit Subagent (pre-implementation data check).
> **Builds on**: v4.0.0 commit `7849741` (postflop planning package + orchestrator workflow).

---

## 1. Goal

Make the app **aware** of the postflop data files. Load them on startup, validate the schema version, filter to approved scenarios, expose a **read-only `App.postflop` namespace** for future v4.0.2 UI consumers.

**Zero new UI.** Zero behavior changes for existing preflop functionality. The player should not notice anything different in v4.0.1 — the change is purely an internal data-readiness layer.

---

## 2. Scope (in)

The total v4.0.1 work is intentionally tiny so it can land in one DEV Integration Agent task without risk to existing features.

| Item | What | Where |
|---|---|---|
| 1 | Schema version constant | `index.html` (new const `POSTFLOP_SCHEMA_VERSION = '1.0.0'`) |
| 2 | `loadPostflopData()` async function | `index.html` (new fenced v4.0.1 block) |
| 3 | `App.postflop` namespace (frozen, read-only) | `index.html` (initialized empty, populated by loader) |
| 4 | Boot trigger (`setTimeout(loadPostflopData, 100)`) | `index.html` (one line in init section) |
| 5 | Settings flag `postflopBeta = false` (default off) | `index.html` (added to settings defaults; UI for this flag deferred to v4.0.2) |
| 6 | Service-worker cache: 3 postflop files | `service-worker.js` (`STATIC_ASSETS` array additions) |
| 7 | Version bump | `index.html` `appVersion: '4.0.1'`; `service-worker.js` `VERSION = 'v4.0.1'` |

**That is the complete in-scope list.** Nothing else changes.

---

## 3. Scope (out)

The following are **explicitly out of scope** for v4.0.1. If any of them feels tempting during implementation, stop and request Orchestrator escalation — do not silently expand.

- ❌ Any new visible UI element (no tab, no banner, no Settings panel entry, no toggle button).
- ❌ Drill engine changes — `classifyAnswer`, `getSRSKey`, `updateSRS`, drill state, render functions: untouched.
- ❌ Postflop question rendering (Module 1 / Module 2 UI) — that's v4.0.2 / v4.0.3.
- ❌ BB Defense vs C-bet (Module 3) data — v4.1.
- ❌ Turn / river — v4.2+.
- ❌ Boss / mission / overall exam / challenge integration with postflop — never until separately approved.
- ❌ Cosmetic / Reward / FX / Aura / Collection extensions for postflop.
- ❌ Service-worker cache strategy changes for non-postflop assets (the existing network-first / cache-first split stays).
- ❌ Audit rule changes (postflop_audit_rules.js untouched in v4.0.1).
- ❌ Any modification to `postflop/*.json` data files (Audit Subagent already validated; DEV must not edit data).

---

## 4. Files allowed to edit

| File | Permission | Notes |
|---|---|---|
| `index.html` | EDIT — only the new fenced v4.0.1 block + 1 line in settings defaults + 1 line in backup builder (`appVersion`) | Total ~50 added lines. No edits to preflop sections. |
| `service-worker.js` | EDIT — bump `VERSION` and add 3 paths to `STATIC_ASSETS` | Total ~5 lines diff. |
| `PROJECT_STATE.md` | EDIT — update Current Version, Latest Completed Work | Orchestrator-facing state sync after implementation. |
| `TASK_BOARD.md` | EDIT — mark v4.0.1 complete, add v4.0.2 as next | Same. |

**No other file is in scope.** In particular:

- `postflop/*.json` — read-only for DEV Integration Agent.
- `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html` — read-only.
- `tools/audit-postflop.js` — read-only.
- `ranges.json`, `manifest.json`, icons — untouched.
- `docs/decisions/*.md` — no new decision needed for v4.0.1 (it implements DEC-001 directly).

---

## 5. File ownership

- **DEV Integration Agent** owns the implementation step (edits `index.html` and `service-worker.js`).
- **Audit Subagent** must run audit BEFORE DEV begins; data must report `0 errors, 0 warnings`. If the audit isn't clean, work blocks until GTO Data Subagent fixes the data.
- **QA Agent** verifies the implementation against the QA checklist in this brief.
- **Orchestrator** updates `PROJECT_STATE.md` and `TASK_BOARD.md` after DEV+QA report.

---

## 6. Data loader approach

Add a single self-contained block to `index.html`. Block must be fenced with explicit v4.0.1 comments so future agents can find it instantly.

### Required code shape (DEV Integration Agent should follow this template)

```js
// =================================================================
// v4.0.1 — POSTFLOP SCHEMA LOADER + AUDIT GATE (read-only, no UI)
// Loads postflop_scenarios.json + taxonomy + concepts on app boot.
// Validates schemaVersion. Filters to auditStatus === 'approved'.
// Exposes Object.frozen App.postflop namespace for future v4.0.2 UI.
// NO UI rendering. NO drill engine integration.
// =================================================================
const POSTFLOP_SCHEMA_VERSION = '1.0.0';

// Initialize as not-ready — UI consumers in v4.0.2+ check ready before reading.
window.App = window.App || {};
App.postflop = { ready: false, error: null };

async function loadPostflopData() {
  try {
    const [scenariosRes, taxonomyRes, conceptsRes] = await Promise.all([
      fetch('postflop/postflop_scenarios.json'),
      fetch('postflop/postflop_taxonomy.json'),
      fetch('postflop/postflop_concepts.json')
    ]);
    if (!scenariosRes.ok || !taxonomyRes.ok || !conceptsRes.ok) {
      throw new Error('postflop fetch failed: ' + [scenariosRes.status, taxonomyRes.status, conceptsRes.status].join('/'));
    }
    const [data, taxonomy, concepts] = await Promise.all([
      scenariosRes.json(), taxonomyRes.json(), conceptsRes.json()
    ]);
    // Schema version gate — refuse to activate if version mismatch
    if (data.schemaVersion !== POSTFLOP_SCHEMA_VERSION) {
      throw new Error('postflop schemaVersion mismatch: app expects ' +
        POSTFLOP_SCHEMA_VERSION + ', data is ' + data.schemaVersion);
    }
    // Audit-status filter — only load scenarios marked approved by author + audit
    const approved = data.scenarios.filter(s => s.auditStatus === 'approved');
    // Build read-only API (frozen recursively at top level + sub-objects)
    App.postflop = Object.freeze({
      ready: true,
      schemaVersion: data.schemaVersion,
      scenarios: Object.freeze(approved),
      taxonomy: Object.freeze(taxonomy),
      concepts: Object.freeze(concepts),
      stats: Object.freeze({
        total: data.scenarios.length,
        approved: approved.length,
        skipped: data.scenarios.length - approved.length
      }),
      error: null
    });
    console.log('[postflop] loaded ' + approved.length + '/' + data.scenarios.length +
                ' scenarios (schema ' + data.schemaVersion + ')');
  } catch (e) {
    App.postflop = { ready: false, error: e.message };
    console.error('[postflop] load failed:', e.message);
    // Do NOT throw — failure must not break the existing preflop app.
  }
}

// Fire-and-forget on boot — does not block existing render path.
if (typeof document !== 'undefined') {
  setTimeout(loadPostflopData, 100);
}
// =================================================================
// END v4.0.1 — POSTFLOP SCHEMA LOADER
// =================================================================
```

### Settings flag (additive — does NOT remove or rename existing flags)

```js
// Inside whatever defaults object the existing settings system uses:
postflopBeta: false   // v4.0.1 — flag exists for v4.0.2 UI to read; no UI in v4.0.1
```

### Backup-builder appVersion bump

```js
appVersion: '4.0.1',  // bumped from '3.8.2'
```

### Why this shape

- **Async** so existing preflop boot is never blocked.
- **`setTimeout(_, 100)`** so it fires after initial render — keeps Time-to-Interactive identical.
- **`Object.freeze`** so accidental mutation by future v4.0.2 UI is caught early in dev.
- **Failure isolation** so a 404 on a postflop file doesn't break the app.
- **Schema version gate** so future v2.0 data simply doesn't activate on older app builds.
- **No globals beyond `App.postflop`** — minimal namespace pollution.
- **Console log** so QA can verify the load happened without opening DevTools network panel.

---

## 7. Audit gate approach

The audit is an **author-side / build-time** gate, not a runtime check.

| Stage | Who runs | How |
|---|---|---|
| Author edits postflop data | GTO Data Subagent | Edits `postflop/*.json` |
| Pre-commit gate | Author or pre-commit hook (deferred to v4.0.5) | Open `postflop/postflop_audit.html` in browser, OR run `node tools/audit-postflop.js` |
| Required result | — | `0 errors` (warnings OK if reviewed) |
| Commit gate | Author or CI (deferred to v4.1) | Audit must pass before commit lands |
| Runtime check (in v4.0.1 app) | Loader | `schemaVersion` match + `auditStatus === 'approved'` filter only |

The runtime is intentionally light because:
- Re-running 17 audit rules at app boot adds ~22 KB of JS + ~50 ms boot time for zero player benefit.
- The audit rules already ran successfully before commit.
- The two runtime checks (schema version, audit status) are sufficient to catch corrupt or stale data.

If a future runtime-audit feature is desired (e.g., audit-on-load with a debug toggle), it would be a new task — not part of v4.0.1.

---

## 8. How postflop data will be loaded safely

Six layers of defensive design:

1. **Schema version gate**: app refuses to populate `App.postflop.scenarios` if `data.schemaVersion !== POSTFLOP_SCHEMA_VERSION`. Future-incompatible data simply never activates.
2. **Audit status filter**: `auditStatus === 'approved'` only. Drafts and `needs_review` items are silently excluded — they exist in the JSON for review but never reach the player.
3. **Object.freeze**: top-level + sub-object freeze prevents accidental mutation. Strict-mode mutation throws.
4. **Async + non-blocking**: `setTimeout(_, 100)` ensures load happens AFTER existing preflop init. Existing UI Time-to-Interactive unchanged.
5. **Failure isolation**: any error (404, JSON parse error, schema mismatch) populates `App.postflop = { ready: false, error: ... }` and logs once. Existing preflop functionality remains 100% available.
6. **Service-worker cache**: postflop files added to `STATIC_ASSETS` so they work offline and survive across sessions.

Existing preflop code paths reference `App.state.drill`, NOT `App.postflop`. There is zero risk of namespace collision.

---

## 9. How audit can be run before integration

Three identical paths (all use `postflop/postflop_audit_rules.js` as the single source of truth):

| Path | Requirement | Best for |
|---|---|---|
| **Browser viewer** | None — open in any browser | Visual review with stats tables and per-scenario detail |
| **Node CLI** | Node.js installed | CI / pre-commit hooks; exit code 0 on pass |
| **PowerShell smoke** (existing dev script) | PowerShell 5.1+ | Quick pre-commit sanity check on Windows without Node |

### Browser viewer

```
http://localhost:8765/postflop/postflop_audit.html
```

(Start the local server first: `powershell -File .claude\serve.ps1` from repo root.) Click **Auto-load & Audit**. Confirm `AUDIT PASSED — 31 scenarios, 0 warning(s), 0 errors`.

### Node CLI

```
node tools/audit-postflop.js                # human-readable summary
node tools/audit-postflop.js --markdown     # full markdown report to stdout
node tools/audit-postflop.js --json         # JSON for CI consumption
node tools/audit-postflop.js --out report.md
```

Exit code 0 = pass. Exit code 1 = errors found. Exit code 2 = could not load files.

### PowerShell smoke (current default — works without Node)

The smoke audit script developed during v4.0.0 (currently inline in chat) should be moved to `tools/audit-postflop-smoke.ps1` as part of v4.0.1 housekeeping if Node remains unavailable. For now, the inline script in the v4.0.0 commit log is sufficient.

**Required pre-commit state**: 31 scenarios, 0 errors, 0 warnings. If audit reports anything else, DEV Integration Agent must stop and request GTO Data Subagent fix the data.

---

## 10. No UI integration yet

v4.0.1 ships **zero new visible UI**. Verification of the loader happens via DevTools console:

```js
// In browser DevTools console after app boots:
App.postflop.ready              // → true
App.postflop.schemaVersion      // → "1.0.0"
App.postflop.stats              // → { total: 31, approved: 31, skipped: 0 }
App.postflop.scenarios.length   // → 31
App.postflop.scenarios[0].id    // → "pf_btn_v_bb_srp_100bb_flop_AhKd5c_rangeadv_001"
App.postflop.taxonomy.version   // → "1.0.0"
App.postflop.concepts.concepts.length  // → 24

// Mutation should throw (frozen):
App.postflop.scenarios.push({})    // TypeError in strict mode
App.postflop.ready = false         // silently ignored or throws
```

Players see no UI difference. The Settings panel does not gain a new toggle. The Drill tab does not show postflop modules. The data is loaded and ready, waiting for v4.0.2 to surface it.

To manually test the (otherwise inaccessible) feature flag:

```js
// In console — sets the v4.0.2 readiness flag manually for testing:
App.state.settings.postflopBeta = true;
localStorage.setItem('rmtt_settings', JSON.stringify(App.state.settings));
```

The flag does nothing in v4.0.1. v4.0.2 will read it.

---

## 11. Minimal index.html hooks (read-only)

Per the requirement to enumerate **exactly** what production code is allowed to change, these are the only edits permitted:

| # | Hook | File | Type | Approx lines |
|---|---|---|---|---|
| 1 | `POSTFLOP_SCHEMA_VERSION` const | `index.html` | Add | 1 |
| 2 | `App.postflop = { ready: false, error: null }` initial | `index.html` | Add | 2 |
| 3 | `loadPostflopData()` async function | `index.html` | Add | ~40 |
| 4 | `setTimeout(loadPostflopData, 100)` boot trigger | `index.html` | Add | 1 |
| 5 | `postflopBeta: false` in settings defaults | `index.html` | Add (additive) | 1 |
| 6 | `appVersion: '3.8.2'` → `'4.0.1'` in backup builder | `index.html` | Modify (1 string) | 0 net (1 line edit) |
| 7 | `VERSION = 'v3.8.2'` → `'v4.0.1'` | `service-worker.js` | Modify (1 string) | 0 net |
| 8 | Add 3 paths to `STATIC_ASSETS` array | `service-worker.js` | Add | 3 |

**Totals**:
- `index.html`: ~45 lines added, all in one fenced v4.0.1 block + 2 isolated single-line edits (settings default, appVersion).
- `service-worker.js`: ~4 lines diff.

**Explicitly NOT modified**:
- Any existing render function.
- `classifyAnswer()` and the entire scoring path.
- `getSRSKey()`, `updateSRS()`, SRS storage.
- Drill state shape (`App.state.drill`).
- Settings UI render code.
- Tab navigation.
- Boss / mission / overall-exam / challenge logic.
- Cosmetic ownership / grant logic.
- Reward reveal modals.
- Wardrobe / Aura / Field FX / Collection Book.
- Mobile chrome, top nav, bottom nav.

DEV Integration Agent must run `git diff` after implementation and confirm only the lines above are touched. If anything else changed, revert and re-implement.

---

## 12. QA checklist (17 items)

QA Agent runs this list after DEV Integration Agent completes. All must pass before commit.

### Data integrity (must precede DEV work)

1. ✅ Audit re-run: `0 errors / 0 warnings` on `postflop/*.json`.

### Loader functionality

2. ✅ Open app in browser. Open DevTools console. See log: `[postflop] loaded 31/31 scenarios (schema 1.0.0)`.
3. ✅ `App.postflop.ready` evaluates to `true`.
4. ✅ `App.postflop.scenarios.length === 31`.
5. ✅ `App.postflop.taxonomy.version === '1.0.0'`.
6. ✅ `App.postflop.concepts.concepts.length === 24`.
7. ✅ Try mutation: `App.postflop.scenarios.pop()` — throws TypeError or silently fails (frozen verified).

### Existing functionality regression

8. ✅ All 5 tabs render unchanged: Home, Drill, Progress, Browse, Settings.
9. ✅ Run a preflop drill (10+ hands, mixed correct/wrong). Behavior identical to v3.8.2.
10. ✅ Boss test entry from a module — gating + cooldown unchanged.
11. ✅ Existing `rmtt_progress` localStorage entries intact (open a hand previously seen — SRS history present).
12. ✅ Console clean: no errors, no new warnings beyond the postflop INFO log.

### Cross-cutting

13. ✅ Mobile 375px: tabs render, no layout shift after postflop load completes.
14. ✅ Service worker installs new VERSION cleanly. Old cache cleared on activate. Update banner appears for existing users (existing v3.8.2 SW behavior).
15. ✅ Reload offline: postflop files served from cache; loader still succeeds.
16. ✅ Settings export/import: backup file shows `appVersion: '4.0.1'`; import succeeds without error.

### Diff scope

17. ✅ `git diff index.html` shows ONLY the v4.0.1 fenced block + the `postflopBeta: false` setting + the `appVersion` string change. `git diff service-worker.js` shows ONLY VERSION bump + 3 STATIC_ASSETS additions.

If any item fails, DEV Integration Agent fixes and re-runs the checklist. If a fix requires touching out-of-scope code, escalate to Orchestrator.

---

## 13. Stop condition

DEV Integration Agent stops after:

1. Implementing exactly the scope in §2 + §6 + §11.
2. Running QA checklist (all 17 items pass).
3. Updating `PROJECT_STATE.md` (current version → v4.0.1; "Latest Completed Work" entry added; "Active Epic" remains v4.0.0 → could be re-evaluated or moved to v4.0.2 by Orchestrator).
4. Updating `TASK_BOARD.md` (v4.0.1 row → done; add v4.0.2 row → next).
5. Staging the commit (do NOT commit until human approves the diff).
6. Reporting:
   - Commit-ready diff summary (file-level changes).
   - QA checklist results (all 17 items).
   - Audit re-run result.
   - Anything unexpected (failed QA item, ambiguous spec, escalation needed).

DEV Integration Agent must NOT:

- Push to remote (commit + push is a separate explicit task).
- Begin v4.0.2 work.
- Add UI surfaces.
- Touch any preflop code.
- Add cosmetic / reward / FX / Aura / Collection extensions.
- Modify guardrail surfaces (preflop ranges, scoring, SRS, cooldowns, rank curves, Chips formula, ownership/grant logic).
- Change the audit rules.
- Edit `postflop/*.json` data files.

---

## 14. Hard guardrails (carried from project state)

These guardrails apply to every agent on every task; calling them out here so DEV Integration Agent has them in front of them during implementation:

- ❌ No changes to preflop ranges (`ranges.json`).
- ❌ No changes to scoring (`classifyAnswer()` and surrounding logic).
- ❌ No changes to SRS (`getSRSKey`, `updateSRS`, SRS storage shape).
- ❌ No changes to boss / mission / challenge cooldowns or progression curves.
- ❌ No changes to rank progression / Chips formula / XP.
- ❌ No changes to cosmetic ownership / grant / reveal logic.
- ❌ No new postflop bosses (deferred until separately approved).
- ❌ No new postflop rewards / FX / Aura / Collection items.
- ❌ No full postflop trainer UI (Module 1 / 2 rendering — those are v4.0.2 / v4.0.3).
- ❌ No service-worker cache strategy changes for non-postflop assets.

If any guardrail must be touched (rare — should be the explicit subject of a future spec), DEV Integration Agent stops and requests Orchestrator escalation via `TASK_BOARD.md` "Blockers" entry.

---

## 15. Approval gate

This brief is **planning only**.

> **Do not implement v4.0.1 until human reviewer reads this brief and explicitly approves.**

After approval, the workflow is:

1. Audit Subagent confirms 0/0 on `postflop/*.json` (idempotent — should still be clean from v4.0.0 commit).
2. DEV Integration Agent implements per this brief.
3. QA Agent runs the 17-item checklist.
4. Orchestrator updates `PROJECT_STATE.md` + `TASK_BOARD.md`.
5. DEV Integration Agent stages the commit with message `v4.0.1: postflop schema loader + audit gate (no UI)`.
6. Human reviews diff and approves the commit.
7. DEV Integration Agent commits.
8. Push happens only on a separate explicit "push" instruction.

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | Orchestrator | Initial brief publication. Awaiting approval. |
