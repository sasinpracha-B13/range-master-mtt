# Postflop v4.2.2G — Command Center Polish + Routing Honesty Pass

**Status:** Focused UX polish on top of v4.2.2F's Product Mode System Foundation. Six review findings addressed: header copy, Preflop status-pill asymmetry, Boss/Missions routing honesty, Concept Library hint precision, premium visual polish (selected indicator dot + panel top accent + stronger primary CTA), unselected-card contrast tweak. **Architecture preserved 100%** — TRAINING_MODES registry extended (added `metaPills` field), 4 helpers unchanged, M3 stays preview/null.
**Date:** 2026-05-06
**Companion to:** `postflop-v4.2.2F-product-mode-system-foundation.md`

---

## 1. Preview review findings — all addressed

| # | v4.2.2F finding | v4.2.2G fix |
|---|---|---|
| 1 | Functional but not premium | Added selected-card corner indicator dot (`::after`); panel top-edge accent line (`::before`); stronger primary CTA gradient + box-shadow; unselected opacity 0.78 → 0.72 |
| 2 | Preflop has no status pills (asymmetric vs Postflop) | Added `metaPills` field to TRAINING_MODES; Preflop renders `["Drills · Exams · Boss", "Ranks · Browse"]` + existing dynamic rank/answer pills |
| 3 | "Boss Tests · Missions" label promises specific surface, route says "Open Drill setup" | Renamed to **"Training Setup"** with hint **"Choose drill, boss, or exam mode"** — honest about the Drill setup-screen destination |
| 4 | "15 concept drills" implies tap auto-starts | Sharpened to **"Browse 15 concept drills"** — honest about scroll-to-library behavior |
| 5 | Header/helper can be sharper | Title: **"Choose Your Training Path"** (was "Choose your training world"). Helper: **"Build ranges preflop. Sharpen decisions postflop. Pick one focus for this session."** (was 22 words, now 16) |
| 6 | Icon/style consistency | Kept ♠ + 🎯 (each carries semantic meaning: suit + target/decision). CSS containers already provide visual consistency. Did not introduce new icon library |

---

## 2. Copy changes (verified in DOM)

| Location | Before | After |
|---|---|---|
| `.tcc-title` | "Choose your training world" | "Choose Your Training Path" |
| `.tcc-helper` | "Preflop builds your range foundation. Postflop teaches board reading and hand-action decisions. Pick a world to focus your session." (22 words) | "Build ranges preflop. Sharpen decisions postflop. Pick one focus for this session." (12 words) |
| `preflop.actions[mastery].label` | "Boss Tests · Missions" | "Training Setup" |
| `preflop.actions[mastery].hint` | "Open Drill setup" | "Choose drill, boss, or exam mode" |
| `postflop.actions[concepts].hint` | "15 concept drills" | "Browse 15 concept drills" |
| `postflop.actions[progress].hint` | "Mastery + history" | "View mastery + history" |

All copy changes verified by `preview_eval` reading the rendered DOM after `setTrainingMode()` calls.

---

## 3. Preflop status pills (new — fixes the v4.2.2F asymmetry)

Added `metaPills` field to the TRAINING_MODES registry. The registry now drives both static context pills and supplements the existing dynamic stats pills:

```js
TRAINING_MODES.preflop.metaPills = ['Drills · Exams · Boss', 'Ranks · Browse'];
TRAINING_MODES.postflop.metaPills = []; // dynamic builder owns this side
```

`_tccBuildPanelStatusHtml()` renders `metaPills` first (always), then appends runtime stats:
- Preflop also shows `🏅 Rank: ${rank}` and `🧮 ${totalAns} answered` if `App.state.progress` has them
- Postflop continues to show `M1: ${count} scenarios` and `M2: ${count} scenarios · BETA` when Postflop Beta is loaded

Result: every mode now has at least 2 visible context pills regardless of user state. v4.2.2F's "Preflop looks emptier than Postflop by accident" issue is resolved.

---

## 4. Routing honesty changes

### "Boss Tests · Missions" → "Training Setup"

The Drill tab's setup screen lets users pick from: Quick / Deep / Weakness / Marginal drill modes, plus Boss Tests, Missions, Challenges, and Overall Exams. The v4.2.2F label "Boss Tests · Missions" promised one specific surface but the route landed on the broader picker. Three options were considered (per brief §C):

| Option | Verdict |
|---|---|
| Option 1 — Rename label to match route | **CHOSEN** — honest, no architecture change |
| Option 2 — Keep label and route to a real Boss/Missions surface | Rejected — no direct Boss/Missions route exists; would require new helper code outside scope |
| Option 3 — Keep both label and route, lean on hint | Rejected — primary label sets stronger expectation than hint |

Project-owner principle: **honesty beats hype.** Final state:
- Label: "Training Setup"
- Hint: "Choose drill, boss, or exam mode"
- Icon: ⚙ (settings/setup, replaces the previous ⚔ which implied combat/boss)
- Route: `preflop:drillsetup` (unchanged — `switchTab('drill')`)

### "Concept Library" hint — sharpened, not changed

The route still scrolls to `.pf-concept-library` (or fallback `.postflop-betalab-section`). The library shows 15 drill buttons (10 M1 + 5 M2, all drillable since v4.1.7). The hint "15 concept drills" was technically accurate but implied auto-start. Changed to "Browse 15 concept drills" — explicit that tap navigates to a browse view where user picks one of 15.

### "Postflop Progress" hint — sharpened similarly

Route scrolls to Academy panel (mastery + history live there). Hint "Mastery + history" → "View mastery + history" — explicit "View" makes the scroll behavior expected.

---

## 5. Concept Library hint decision

Verified via repo grep: 15 concept drills are all drillable (10 M1 + 5 M2 since v4.1.7's M2 concept flip from `previewOnly: true` to drillable). No concepts are currently locked or preview-only in production.

**Decision:** keep the count "15", but prefix with "Browse" to honestly describe the scroll-to-library navigation pattern. Alternative considered: "Concepts · M1+M2 active" — rejected as less clear about what tap does.

---

## 6. Visual polish summary

All CSS-only changes. Zero new HTML. Mobile-first preserved.

| Item | Implementation |
|---|---|
| Selected mode corner indicator dot | `.tcc-mode-btn.is-selected::after` — 8×8px circle, `currentColor`, glow shadow, top-right corner |
| Panel top-edge accent line | `.tcc-panel::before` — 2px gradient line (`90deg, transparent → currentColor → transparent`), opacity 0.45, color set per `.tcc-panel.is-{mode}` |
| Stronger primary CTA | Background gradient saturation 0.16/0.04 → 0.22/0.06; border opacity 0.55 → 0.70; added `box-shadow` for slight lift; brighter hover state |
| Unselected card more dimmed | opacity 0.78 → 0.72 (more contrast vs selected) |
| Tighter panel hero spacing | margin-bottom 10 → 8 for hero block; mode-desc font-size 12 → 12.5; line-height 1.5 → 1.55 |
| Slightly stronger selected box-shadow | `0 4px 14px → 0 6px 18px` for depth |

No layout refactor. No animation additions. No risky changes.

---

## 7. CTA routing table

Identical to v4.2.2F (12 routes). All preserved:

| Route ID | Destination | M3 status |
|---|---|---|
| `preflop:quick` | `App.state.drill.mode='quick'; switchTab('drill'); startDrill()` | n/a |
| `preflop:deep` | mode='deep' + same | n/a |
| `preflop:weakness` | mode='weakness' + same | n/a |
| `preflop:marginal` | mode='marginal' + same | n/a |
| `preflop:browse` | `switchTab('browse')` | n/a |
| `preflop:drillsetup` | `switchTab('drill')` (Drill setup screen) | n/a |
| `postflop:m1` | `startPostflopDrill('pf_board_texture', 15)` (gated on `postflopBeta`) | n/a |
| `postflop:m2` | `startPostflopDrill('pf_flop_cbet_ip', 12)` (gated) | n/a |
| `postflop:concepts` | scroll to `.pf-concept-library` (gated) | n/a |
| `postflop:weakspot` | `startPostflopWeakSpotReview()` (gated) | n/a |
| `postflop:progress` | scroll to `.postflop-betalab-section` | n/a |
| `null` (M3) | toast "coming soon" | **kind: preview, route: null — verified no onclick attribute on M3 tile** |

---

## 8. Browser QA result

Verified via Claude Preview MCP at desktop (default) + mobile 375×812:

| Check | Result |
|---|---|
| App loads at v4.2.2G | ✅ |
| Console errors | ✅ 0 |
| TRAINING_MODES registry preserved | ✅ |
| All 4 helpers exist (getTrainingMode/setTrainingMode/getTrainingModeMeta/runTrainingModeAction) | ✅ |
| Header title reads "Choose Your Training Path" | ✅ |
| Helper text shorter (12 words vs 22) | ✅ |
| Preflop status pills: 2 metaPills present | ✅ |
| Postflop status pills: M1/M2 counts present | ✅ |
| Preflop "Training Setup" action label + new hint | ✅ |
| Postflop "Browse 15 concept drills" hint | ✅ |
| Postflop "View mastery + history" hint | ✅ |
| Selected mode has corner dot indicator | ✅ |
| M3 still kind: preview | ✅ |
| M3 still route: null | ✅ |
| M3 has no `onclick` attribute (cannot navigate) | ✅ |
| setTrainingMode('postflop') flips panel in ~100ms | ✅ |
| setTrainingMode('preflop') flips back | ✅ |
| Existing Drill / Browse / Settings unaffected | ✅ |
| Existing Postflop Academy panel still mounts below TCC | ✅ |

## 9. Mobile QA result

375×812 viewport:
- TCC shell width: 343px (no horizontal overflow) ✅
- Mode buttons: 156.5px each (2-up) ✅
- Action grid: 2-col mobile (143.5px each), 3-col tablet (≥720px) ✅
- Primary CTA spans full width: 291px ✅
- 2 status pills wrap cleanly under panel hero ✅
- Bottom nav not overlapped ✅
- Install banner respects safe-area-inset-top (from v4.2.2C) ✅
- M3 preview tile visually distinct (dashed border, 0.55 opacity, SOON badge) — not confusingly tappable ✅

## 10. Audit results

| Audit | Result |
|---|---|
| Production audit | **300 / 0 / 0** unchanged |
| M2 seed audit | **24 PASS / 0 hard / 8 warnings** unchanged |
| M3 seed audit | **24 / 0 hard / 0 warnings** unchanged |
| R29 (text guard) | **0 warnings** unchanged |

## 11. Text integrity result

No data files touched. Production text remains 0 mojibake / 0 R29 patterns / 0 broken card notation.

## 12. M3 not-playable confirmation

| Check | Verified |
|---|---|
| `postflop_scenarios.json` Module 3 count | **0** (still planning-only) |
| `TRAINING_MODES.postflop.actions[m3].kind` | `'preview'` |
| `TRAINING_MODES.postflop.actions[m3].route` | `null` |
| M3 tile has no `onclick` attribute (verified via DOM inspect) | ✅ true |
| `runTrainingModeAction('postflop', 'm3')` → toast, no navigation | ✅ |
| `startPostflopDrill('pf_flop_cbet_oop_def', ...)` invoked anywhere in TCC | **No** — verified by source grep |

## 13. TRAINING_MODES preserved confirmation

The architecture from v4.2.2F is **fully preserved**:
- Registry constant `TRAINING_MODES` exists with both `preflop` and `postflop` modes
- 4 helper functions unchanged in signature: `getTrainingMode()`, `setTrainingMode(mode)`, `getTrainingModeMeta(mode)`, `runTrainingModeAction(mode, actionId)`
- All 12 actions across both modes preserved with same IDs and routes
- Only additive change: new `metaPills` field on each mode (empty array on Postflop, 2 entries on Preflop)
- M3 preview/null state untouched

No regression risk to v4.2.2F's foundation.

## 14. Files modified (5)

| File | Action |
|---|---|
| `index.html` | (1) TRAINING_MODES — Preflop `mastery` action label/hint/icon, Postflop `concepts`/`progress` hints, added `metaPills` field. (2) `_tccBuildPanelStatusHtml()` reads `metaPills`. (3) Header copy. (4) CSS polish: selected dot, panel top accent, stronger primary CTA, opacity tweak, spacing. (5) appVersion 4.2.2F → 4.2.2G. |
| `service-worker.js` | VERSION bump v4.2.2F → v4.2.2G |
| `docs/specs/postflop-v4.2.2G-command-center-polish.md` | NEW — this file |
| `PROJECT_STATE.md` | v4.2.2G status block |
| `TASK_BOARD.md` | v4.2.2G staged → v4.2.2F committed |

## 15. Forbidden files untouched verification

`postflop/postflop_scenarios.json` ✅ · `postflop/postflop_concepts.json` ✅ · `postflop/postflop_taxonomy.json` ✅ · `postflop/postflop_audit_rules.js` ✅ · `postflop/postflop_audit.html` ✅ · `tools/*` (all 4 audit scripts) ✅ · `ranges.json` ✅ · `manifest.json` ✅ · all preflop / gamification / wardrobe / shop / Field FX ✅ · all M3 planning/production ✅. Empty diff.

## 16. Version bump result

```
appVersion:  4.2.2F → 4.2.2G ✅
SW VERSION:  v4.2.2F → v4.2.2G ✅
```

## 17. Sign-off

Premium polish delivered without architecture risk. Six findings addressed. v4.2.2F's B+ foundation 100% preserved. Module 3 still preview/null/coming-soon — no accidental productionization. v4.2.3 still paused.

**v4.2.2G deliberately did NOT:**
- Productionize Module 3
- Activate M3 in TRAINING_MODES (kind/route unchanged)
- Touch any data, audit script, or preflop file
- Rewrite the bottom nav (still deferred to v4.3.x)
- Add new external dependencies / icon libraries / fonts
- Change scenario data, answer keys, or any strategic content
- Break any existing flow

## 18. Recommendation for v4.2.3

**v4.2.3 — Module 3 Migration to Production Data** can now safely resume. The Command Center is polished and ready as M3's eventual front door. When M3 ships in v4.2.4: change `m3.kind: 'preview' → 'primary'` (or `secondary`), `m3.route: null → 'postflop:m3'`, and add one route case in `runTrainingModeAction`. The visual treatment + status pill behavior is zero-effort.

**Honest observation for the v4.3.x roadmap:** Postflop concept depth is currently 7 native + 4 reusable concepts at 24 seeds (v4.2.0_final). Once M3 productionizes (300 → 324 scenarios) and v4.2.3A expansion adds 16-24 more seeds, the Concept Library's "15 concept drills" hint will need recalibrating to show the actual count (probably 20+). Update is one registry-line change.
