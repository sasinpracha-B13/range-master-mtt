# Task Board — Range Master MTT

> Active workstream tracker. Updated by Orchestrator + subagents (each role updates their own rows).
> Last updated: 2026-05-06 (v4.2.5 committed + pushed `55fa676`; reconciliation in flight).

---

## Active Epic

**v4.0.2 — Post-flop Module 1: Board Texture Trainer UI** (parent epic v4.0.x — Postflop Foundation)

First visible postflop UI surface. Consumes `App.postflop` namespace shipped in v4.0.1. Delivers: module entry point + question card + board cards + answer choices + multi-tier scoring + multi-section feedback. Mobile-first (375px). Reuses existing drill chrome where possible.

---

## Current Status

🟢 **v4.2.5 committed + pushed** (`55fa676`). Module 3 Limited Beta UX Polish + Critical-Flag Review (UX POLISH). Three axes: (1) **Strategic critical-flag rebalance** — `check_raise_big` critical rate brought from 47/85 = 55.3% → **26/85 = 30.6%** via 21 surgical downgrades. Each downgrade carries concrete poker rationale (real equity backup, made-hand component, sizing error vs severe punt). 26 KEEPs are uniquely-worst-bad cases (5 naked-pair calls, 4 slowplay teachings, 17 BEST=fold naked-trash). **Zero changes to** answer.best/acceptable/bad, recommendedAction, actionReason, conceptTags, explanation text, board, heroHand, M1/M2 scenarios. Only `answer.critical` arrays edited on 21 M3 scenarios. (2) **ActionReason-keyed weak-spot review** — `_pfCurrentSessionWeakProfile` extended with `targetActionReasons` + `targetHeroHandRoles`; `_pfWeakScenarioScore` adds +50 actionReason boost + +35 heroHandRole boost. M3 weak-spot empty-state toast: "Play Module 3 sessions to unlock BB Defense weak-spot review." Verified: simulated 2-bad-blocker_raise session → top 4 candidates all `blocker_raise` scenarios. (3) **UX polish** — mobile chip wrapping at 320/360/380px micro-breakpoints (no horizontal overflow at any tested width); first-time M3 explainer (collapsible "About Module 3" block on Q1 of first M3 session, hides forever after); M3 Concept Library module-aware review signals (8 alias-concept actionReason mappings); Limited Beta progression hint after 3rd M3 session ("📈 Beta progress unlocked — now review your weakest BB Defense reasons"). **Browser QA mobile 320/360/375 + desktop: 0 console errors, all surfaces render correctly.** Programmatic QA: actionReason weak-spot scoring verified, M3 weak-spot empty-state fires, M1+M2 regression PASS. 5-scenario poker spot-check post-edit: all 5 PASS (3 KEEP critical + 2 downgraded grade correctly). Production audit unchanged 385/0/0. R29 = 0 warnings preserved. M2 + M3 seed audits unchanged. **Forbidden files untouched:** concepts/taxonomy/audit tools/ranges/manifest/preflop all byte-identical. Net diff: index.html +210/-8, service-worker.js 1-line VERSION, scenarios.json 21 critical-array edits only, 1 new tool, 1 new doc. appVersion + SW v4.2.5. New doc `docs/specs/postflop-v4.2.5-module3-limited-beta-ux-polish.md`. New snapshot `GPT AUDIT/v4.2.5/`. Awaiting commit.

🟢 **v4.2.4-doc committed + pushed** (`cc5c209`). State reconciliation flipping v4.2.4 from staged to committed (`81d54c5`).

🟢 **v4.2.4 committed + pushed** (`81d54c5`). Module 3 Limited Beta Runtime Wire (RUNTIME WIRE). Wired Module 3 (Facing C-bet OOP) into the runtime as **"Limited Beta · 85 scenarios"** with the full learning loop. **TRAINING_MODES.m3 flipped:** preview/null/🔒 → secondary/postflop:m3/🛡️/BETA badge with "85 OOP defense scenarios · Limited Beta" hint. New `postflop:m3` route → `startPostflopDrill('pf_flop_cbet_oop_def', 10)`. **Schema normalization layer (architectural keystone):** new `_pfNormalizePostflopChoices` + `_pfNormalizePostflopAnswer` helpers + `_PF_M3_ACTION_LABELS` + `_PF_M3_REASON_LABELS` translate M3's string-form schema to M1/M2's object/array shape uniformly. `classifyPostflopAnswer` + `_findChoiceLabel` route through normalizers; M1/M2 grading byte-identical. **M3 question rendering:** BB-defending prompt framing; 4-axis chip row (handClass/heroHandRole/drawCategory/showdownValue); BB-OOP spot tags; M3-flavored choice guide. **NEW `_pfM3TeachingFeedbackBlocksHtml`:** Recommended Action (BB OOP) + 🎯 Defense Logic (prominent) + Hand Logic + Sizing Logic + 🃏 Blocker note + Range Context + 💡 Takeaway + ⚠️ Common Mistake. **Concept Library +10 M3 entries** (7 native + 3 alias) — new "Module 3 — BB Defense OOP (10 · Limited Beta)" group. **M3 concept drill** + **M3 weak-spot review** wired (M1/M2/M3 pools never cross-contaminate). **NEW `_pfM3RenderSessionAggregations`** by handClass/heroHandRole/actionReason. **NEW `_pfM3MasteryStats` + `_pfM3MasteryProgressHtml`** with Limited Beta thresholds (3/2/9/weak/critical) — title "Module 3 Limited Beta progress (display only)". `_PF_CURRICULUM` m3 entry → beta status + 85 scenarios + 8-line syllabus + "▶ Start Module 3 Limited Beta" button. **Browser QA mobile 375 + desktop: 0 console errors, all M3 surfaces render correctly. Poker QA 12 scenarios (10 M3 + 1 M1 + 1 M2 regression): all 12 PASS.** Production audit unchanged 385/0/0 (no data edits). R29 = 0 warnings preserved. M2 + M3 seed audits unchanged. **No data files modified:** postflop_scenarios.json / postflop_concepts.json / postflop_taxonomy.json / tools/* all byte-identical. **Net diff: index.html +798/-61 (M3 wiring across 6 batches), service-worker.js 1-line VERSION bump.** appVersion + SW v4.2.4. **Module 3 IS NOW PLAYABLE as Limited Beta** from TCC, Postflop Academy curriculum, and Concept Library. New doc `docs/specs/postflop-v4.2.4-module3-limited-beta-wire.md`. New snapshot `GPT AUDIT/v4.2.4/`. Awaiting commit.

🟢 **v4.2.3B committed + pushed** (`e72eef6`). Module 3 Data Polish + Thin-Bucket Completion (DATA POLISH). Polished M3 from 62 → **85 production scenarios** (+23 across 5 new boards + 1 added to existing). **Production audit raised 362/0/0 → 385/0/0**. R29 = 0 warnings preserved. M2 + M3 seed audits unchanged. **5 new boards:** Kh Qh 4s (K-high two-tone broadway), Kh Jh 4h (K-high monotone), Qd 7d 2c (Q-high two-tone dry), Ac Ad 7s (A-high paired), Ts 9s 5d (mid-connected two-tone). **ALL 5 thin-bucket targets MET:** blocker_raise 1→4, domination_fold 2→5, nut_flush_draw 1→3, slowplay_call 3→5, protection_raise 3→6. **15 textbook scenarios promoted to consensus_gto** (sets, naked overcards, nut flush, AA overpair) — first M3 sourceConfidence variety. Difficulty spread improved (8/59/15/3 across 2/3/4/5). Anti-suit-swap discipline maintained: 0 cross-bucket, 0 suit-only dupes, 0 missing uniquenessNotes. 12-scenario poker spot-check PASS. New tools `tools/build-polish-v4.2.3B.ps1` + `tools/migrate-polish-v4.2.3B.ps1`. **CRITICAL — Module 3 still NOT runtime-wired:** TRAINING_MODES.m3 still kind:preview/route:null. Runtime helpers byte-identical. appVersion + SW v4.2.3B. **Limited Beta readiness: M3 IS READY for v4.2.4 runtime wire** with "Limited Beta · 85 scenarios" label and scaled mastery thresholds. New doc `docs/specs/postflop-v4.2.3B-module3-data-polish.md`. New planning seed `docs/specs/postflop-v4.2.3B-module3-polish-seeds.json` (23 scenarios). New snapshot `GPT AUDIT/v4.2.3B/`. Awaiting commit.

🟢 **v4.2.3A committed + pushed** (`14fb380`). Module 3 Data Expansion (DATA EXPANSION). Expanded Module 3 from 24 → **62 production scenarios** (+38 across 8 new board families). **Production audit raised 324/0/0 → 362/0/0** (251 M1 + 49 M2 + 62 M3). R29 = 0 warnings preserved. M2 + M3 seed audits unchanged. **8 new boards:** As9s4d (A-high two-tone), Ks8s3d (K-high two-tone), QsTs6d (Q-high two-tone dynamic), 7s5s3s (low monotone), 8c8d3s (paired low), 9d8c6h (low semi-connected), TcTh6s (paired T), 6c3d2h (rag). **Coverage gap fixes:** pot_odds_defense 0→5, blocker_raise 0→1, slowplay_call 1→3, protection_raise 1→3, domination_fold 1→2, bluff_catch 2→7, nut_flush_draw 0→1. Difficulty spread improved (was all diff 3; now 7 diff 2 + 45 diff 3 + 9 diff 4 + 1 diff 5). **Anti-suit-swap discipline:** every new scenario has uniquenessNote; filler scan = 0 cross-bucket boards / 0 suit-only dupes / 0 missing notes / 0 card collisions. **Strategic 12-spot-check PASS.** New canonical authoring tool `tools/build-expansion-v4.2.3A.ps1` (PSCustomObject-based scenario definitions) + migration tool `tools/migrate-expansion-v4.2.3A.ps1`. Mid-sprint text-integrity caught 1 Thai mojibake byte (≈→U+0E42), fixed inline. **CRITICAL — Module 3 still NOT runtime-wired:** TRAINING_MODES.m3 still kind:preview/route:null. Runtime helpers untouched (only appVersion + SW VERSION lines changed). appVersion + SW v4.2.3A. Training volume assessment: 62 in 50-80 target range; 8 of 9 actionReasons ≥3 (only blocker_raise still thin at 1). v4.2.3B optional vs v4.2.4 Limited Beta runtime wire is project-owner choice. New doc `docs/specs/postflop-v4.2.3A-module3-data-expansion.md`. New planning seed `docs/specs/postflop-v4.2.3A-module3-expansion-seeds.json` (38 scenarios). New snapshot `GPT AUDIT/v4.2.3A/`. Awaiting commit.

🟢 **v4.2.3-doc committed + pushed** (`b4b944f`). State reconciliation flipping v4.2.3 from staged to committed.

🟢 **v4.2.3 committed + pushed** (`e718f07`). Module 3 Migration to Production Data (DATA + AUDIT HARDENING). Migrated all 24 finalized v4.2.0 Module 3 (Facing C-bet OOP) planning seeds into production `postflop/postflop_scenarios.json`. **Production audit raised 300/0/0 → 324/0/0** (251 M1 + 49 M2 + 24 M3). R29 card-notation guard preserved at 0 warnings. M2 + M3 seed audits unchanged. Concepts file +10 (7 M3-native + 3 M3-alias) → 25 total. Taxonomy file extended with `heroHandRole`/`actionReason` arrays + `pf_flop_cbet_oop_def` module entry + `static` textureTag + `review_pending`/`planning_only` auditStatusValues. Production auditor extended with R30-R41 for Module 3 schema (R04/R05 generalized to handle string-form choices/best). Audit-plan doc renumbered R29-R40 → R30-R41 because R29 is owned by v4.2.2D/E text-integrity guard. New migration tool `tools/migrate-module3-v4.2.3.ps1` (idempotent, UTF-8 NO-BOM). Strategic spot-check on 8 critical M3 scenarios verified PASS by reviewer. **CRITICAL — Module 3 still NOT playable, NOT routable, NOT runtime-wired:** TRAINING_MODES.postflop.actions.m3 still `kind: 'preview'`, `route: null`. Runtime helpers byte-identical. Net runtime effect: `App.state.postflop.scenarios` 300 → 324 in memory but no UI surface routes the new 24. appVersion + SW bumped 4.2.2G → 4.2.3 (cache invalidation only). Training volume caveat documented (24 too thin for beta; v4.2.4/5 must expand to ~80–120). New doc `docs/specs/postflop-v4.2.3-module3-migration.md`. New snapshot `GPT AUDIT/v4.2.3/`. v4.2.4 (runtime wire) blocked on volume expansion. Reconciliation post-ship: state docs being flipped from "staged" to "committed + pushed at e718f07" (this commit).

🟢 **v4.2.2G committed + pushed** (`8c150ab`). Command Center Polish + Routing Honesty Pass (UX POLISH). Six v4.2.2F preview-review findings addressed without architecture change. Header sharper ("Choose Your Training Path", helper trimmed 22→12 words). Added `metaPills` field to TRAINING_MODES — Preflop now has 2 status pills (fixes asymmetry vs Postflop). "Boss Tests · Missions" renamed to **"Training Setup"** with hint "Choose drill, boss, or exam mode" — label now matches destination (Drill setup screen). "15 concept drills" → "Browse 15 concept drills" (honest about scroll-to-library). "Mastery + history" → "View mastery + history". Visual polish: selected corner indicator dot, panel top-edge accent line, stronger primary CTA gradient, unselected opacity 0.72. Architecture 100% preserved (TRAINING_MODES + 4 helpers unchanged, M3 still kind:preview/route:null, no onclick on M3 tile). Mobile 375 verified clean. appVersion + SW v4.2.2G. Production audit unchanged 300/0/0. M2 + M3 seed audits unchanged. New doc `docs/specs/postflop-v4.2.2G-command-center-polish.md`. UI captures in `GPT AUDIT/screenshots/v4.2.2G/`. v4.2.3 still paused. Awaiting commit.

🟢 **v4.2.2F committed + pushed** (`7680db9` + doc `159dd6f`). Product Mode System Foundation + Premium Home Command Center. Replaces v4.1.8 misleading home tabs with real foundation: `TRAINING_MODES` registry + 4 helpers (`getTrainingMode`/`setTrainingMode`/`getTrainingModeMeta`/`runTrainingModeAction`) + premium `.tcc-shell` Command Center with segmented mode selector + mode-aware command panel + safe CTA routing. **Preflop panel:** 6 actions (Quick/Deep/Weakness/Marginal Drill + Browse + Boss·Missions). **Postflop panel:** 6 actions (M1, M2 BETA, Concepts, Weak Spot, Progress, **M3 preview SOON**). M3 explicitly route=null, click shows toast, NOT playable. Mode persists via `App.state.settings.trainingMode`. Mobile 375×812 verified clean. Permanent UX principle documented (5-property rule for any mode/tab UI). Bottom-nav rewrite deferred to v4.3.x. No data/audit/preflop touched. Production audit 300/0/0 unchanged. M2 + M3 seed audits unchanged. appVersion + SW v4.2.2F. New doc `docs/specs/postflop-v4.2.2F-product-mode-system-foundation.md`. v4.2.3 migration still paused. Awaiting commit.

🟢 **v4.2.2E committed + pushed** (`3cc3704`). Final Text Integrity Repair + R29 Hardening. Third-order correction. v4.2.2D's combo-shorthand rule over-triggered on board references that escaped the board-rebuild, producing fake suited-hand strings like `KTs 2` (was `Kh Td 2s`). Plus 3 other classes leaked: `A — X` / `K — X` flush prose, `5 — /7 — /8` rank-x list. **14 scenarios / 18 text-field edits.** Repairs use `board.cards` to rebuild boards. R29 guard hardened with 3 new patterns (board_collapse, rank_dash_X, rank_dash_slash) → 6 total, verified 6/6 positive + 7/7 negative test cases. **15-field strategic integrity verified 0 changes.** Manual poker spot-check on 5 critical scenarios PASS (Kh Td 2s, Th 8h 3h, 8s 7s 5s — all strategic intent preserved). appVersion + SW v4.2.2E. Production audit unchanged 300/0/0, R29 = 0 warnings (true negative now). M2 seed audit 24/0/8. M3 seed audit 24/0/0. New doc `docs/specs/postflop-v4.2.2E-final-text-integrity-repair.md`. Awaiting commit.

🟢 **v4.2.2D committed + pushed** (`f53b425`). Postflop Card / Suit Notation Semantic Repair. 263 scenarios / 525 text edits. R29 guard added (3 patterns). 15-field strategic integrity verified. v4.2.2C blanket-replaced mojibake runs with em-dashes — including original suit symbols, leaving semantic damage like "BTN with K — K — on 6 — 5 — 4 —" and "A — -x". v4.2.2D applies context-aware repair using `board.cards` + `heroHand` arrays to reconstruct meaning. **263 scenarios touched, 525 text-field edits across 2 passes.** All 4 suspicious card-notation patterns reduced to 0. 186 legitimate em-dashes preserved as sentence punctuation. **15-field strategic integrity check: 0 changes** (answer keys / actionReason / conceptTags / auditStatus / etc. all untouched). Added R29 audit guard rule (warning-only) to `tools/audit-postflop-ps.ps1` detecting the 3 suspicious patterns to prevent regression. Browser QA mobile screenshot confirms clean prompts ("On Ah Kd 5c", "With AhKh on As 8d 3h"). appVersion + SW bumped to v4.2.2D. Production audit unchanged 300/0/0. M2 seed audit unchanged 24/0/8. M3 seed audit unchanged 24/0/0. New doc `docs/specs/postflop-v4.2.2D-card-suit-notation-repair.md`. Awaiting commit.

🟢 **v4.2.2C committed + pushed** (`8896504`). Runtime Text Encoding / Mojibake Hotfix. Cleaned 292/300 production scenarios + 8 ranges.json lines of CP874 mojibake (em-dash + suit symbols round-tripped through CP874 → long Thai-character runs). Source data fix is durable. Added `_pfFixMojibake` safety net to M1 expandable explanation sections that v4.0.10 hotfix missed. Caught + fixed a regression where the existing reverser stripped clean em-dashes (mapped 0x2014 → byte 0x97 which is invalid UTF-8 leading byte → fallback emitted U+0097 C1 control); fix tracks original chars in parallel buffer to restore on decode failure. Fixed `.install-banner` CSS to use `env(safe-area-inset-top)` so iOS PWA standalone mode no longer crowds the status bar. **appVersion + SW bumped to v4.2.2C.** Browser QA at mobile 375x812: 0 console errors, 0 mojibake in DOM, em-dashes preserved, install banner properly inset. Production audit unchanged 300/0/0. M2 seed audit unchanged 24/0/8. M3 seed audit unchanged 24/0/0. **No M3 productionization, no strategic content / answer-key changes.** New doc `docs/specs/postflop-v4.2.2C-runtime-text-encoding-hotfix.md`. Awaiting commit.

🟢 **v4.2.2B committed + pushed** (`1ee6cc1`). Module 3 Post-Commit Raw Verification + Migration Readiness Gate. 3 defects fixed (F6.2 conceptTags, F3.3 acceptable, summary metadata stale). Migration Path A green-lit. **Found and fixed 3 defects:** (1) F6.2 stale conceptTags `[check_raise_value, value_raise]` → `[bluff_catchers, pot_control, value_raise]` (matches v4.2.2 slowplay flip); (2) F3.3 acceptable list had `protection_raise` which doesn't fit pure-draw Td9d → moved to bad; (3) Top-level summary metadata block stale from v4.2.0 (missing slowplay_call, wrong byBestAction counts, wrong byReviewStatus) → full recompute + added `metadataRecomputedAt` freshness marker. All v4.2.2 strategic claims (F1.3, F5.3, F6.2, F5.4, F6.4) verified correct. slowplay_call vocab consistent across 6 locations. **Training Volume Gate:** 24 ACCEPTABLE for planning lock + production migration; NOT for stable runtime. Per-concept depth: only equity_realization_oop (8) at threshold; 6 of 7 below. **Migration decision: Path A — proceed with v4.2.3.** Recommended v4.2.3A data expansion sprint between v4.2.3 (migration) and v4.2.4 (runtime wire) to bring M3 from 24 → 40+ before playable beta. M3 seed audit 24/0/0 PASS clean. Production audit unchanged 300/0/0. M2 seed audit unchanged 24/0/8. New doc `docs/specs/postflop-v4.2.2B-module3-postcommit-verification.md`. Awaiting commit.

🟢 **v4.2.2 committed + pushed** (`14bbd82`). Module 3 Final Strategic Review + Planning Commit Lock. 22 FINAL_PASS + 2 FINAL_WARN + 0 BLOCKED. F1.3 + F5.3 UN-softened, F6.2 flipped to slowplay_call, vocab expanded 8 → 9 reasons. All 24 → v4.2.0_final.

🟢 **v4.2.1 committed + pushed** (`70ee74d`). Module 3 Seed Auditor + Initial Strategic Review. New script (Option A). 13 mech defects caught + fixed batch. 17 PASS + 7 WARN + 0 FAIL. All 24 flipped to v4.2.0_seed_reviewed.

🟢 **v4.2.0 committed + pushed** (`515a3c1`). Module 3 Architecture + Seed Plan. 5 docs in `docs/specs/postflop-v4.2.0-module3-*`. Planning-only.

🟢 **v4.1.9 committed + pushed** (`454c470`). Module 2 Data Expansion + Tester Pass. Module 2 grows from 35 to 49 production scenarios. Per-concept primary-tag depth target hit (8/8/8/8/11). Production audit raised 286/0/0 → 300/0/0. Browser QA 30/30 PASS. appVersion + SW v4.1.9.

🟢 **v4.1.8 committed + pushed** (`5eb12ac`). Home Mode Tabs + M2 Mastery + Concept-Pool Depth Audit. Home tabs (Preflop/Postflop entry tiles), M2 mastery checklist (5 criteria parallel to M1), M2 session summary aggregation by handClass+actionReason, depth audit doc identifying v4.1.9 expansion targets. Browser QA 32/32 PASS. appVersion + SW bumped to v4.1.8. Production audit 286/0/0 unchanged.

🟢 **v4.1.7 committed + pushed** (`d48ffa9`). Module 2 Curriculum Playable Beta — Module 2 fully playable from Curriculum + Concept Library; hand-aware question/answer rendering; M2 weak-spot routes to M2 pool; runtime loads 286. Module 2 is now playable. Final seed review 24/24 PASS. 24 v4.1.2 seeds flipped to `auditStatus: approved`; runtime now loads 286 (was 262). New M2 helpers: `getModule2Scenarios`, `_pfM2TeachingFeedbackBlocksHtml`. Updated: `startPostflopDrill` / `_pfChoiceGuide` / `_pfBuildQuestionPrompt` / `renderPostflopQuestion` / `renderPostflopAnswer` / `renderPostflopComplete` / `startPostflopConceptDrill` / `startPostflopWeakSpotReview` / `_pfModuleStatus` / `_pfModuleCardHtml`. M2 weak-spot review routed to M2 pool (no contamination). 5 M2 concepts in library flipped from previewOnly to drillable. Module 2 curriculum card → "▶ Start Module 2 Beta" button calling `startPostflopDrill('pf_flop_cbet_ip', 12)`. New CSS for hero card row, M2 chips, M2 action block, beta status pill, secondary syllabus button. Browser QA 35/35 PASS (M2 from curriculum + M2 concept drill + M2 weak-spot stays in M2 pool + M2 summary + M1 normal drill + M1 concept drill + preflop unaffected + mobile + console clean). appVersion 4.1.6 → 4.1.7, SW VERSION v4.1.6 → v4.1.7. Production audit unchanged 286/0/0. M2 seed audit unchanged 24/0/8. Two new docs in `docs/specs/`. Awaiting commit.

🟢 **v4.1.6 committed + pushed** (`ca3ea31`). Concept Library Module 2 Bridge (Path A preview-only). `_PF_CONCEPT_LIBRARY` extended with 5 Module 2 concepts (each `module: 'm2'` + `previewOnly: true`). Library renders Module 1 / Module 2 grouped sections; M2 cards show orange-tinted "trained in Module 2" tag + "🔒 Coming in Module 2 Beta" lock badge instead of drill button. Defense-in-depth: `startPostflopConceptDrill` refuses preview-only keys with toast. **Module 2 still NOT playable from curriculum** — `startPostflopDrill('pf_flop_cbet_ip', ...)` never called from runtime. Browser QA 25/25 PASS (M1 drill works, M2 refused, preflop unaffected, curriculum unchanged, mobile clean, console 0 errors). appVersion bumped 4.1.1 → 4.1.6; service-worker VERSION bumped v4.1.1 → v4.1.6. Production audit unchanged 286/0/0. Module 2 seed audit unchanged 24/0/8. No scenario data changes. Awaiting commit.

🟢 **v4.1.5 committed + pushed** (`38cf34b`). Module 2 Seed Cleanup + Baseline Migration + Audit Extension. Production audit gate raised from 262/0/0 to 286/0/0. 11 baseline migrated + 24 seeds appended. 5 new concepts added. R18-R28 added to production auditor. Module 2 still not playable.

🟢 **v4.1.4 committed + pushed** (`c1df014`). Module 2 Seed Review + Baseline Migration Decision (planning) — strategic 24-seed re-review (20 PASS / 4 WARN / 0 FAIL); Option C (Refactor/Migrate) chosen for baseline 11.

🟢 **v4.1.3 committed + pushed** (`eafdf6d`). Module 2 Audit Tooling — `tools/audit-postflop-module2-seed.ps1` (~620 LOC) implements 30 hard rules + 7 soft warnings + 9 coverage axes. Production auditor untouched.

🟢 **v4.1.2 committed + pushed** (`c6a24ac`). Module 2 Architecture + Data Plan — 5 planning docs: architecture, schema/taxonomy, 24 seed scenarios (21 PASS / 3 WARN / 0 FAIL), audit plan, GPT review package. Integrated Academy Path with applied-decision distinction.

🟢 **v4.1.1 committed + pushed** (`cf088d1`). Postflop Concept Library Drill Actions — each of the 10 Concept Library cards is now a one-tap entry into a focused 12-question Module 1 drill. Concept-mode badge on question screen + dedicated summary header. Optional Review-signal pill from latest session. 45/45 QA. Audit 262/0/0.

🟢 **v4.1.0 committed + pushed** (`843fa76`). Postflop Academy Foundation — curriculum map + mastery checklist + concept library + recommendation engine.

| Metric | Value |
|---|---|
| v4.0.0 planning | ✅ committed (`7849741`) + pushed |
| v4.0.1 implementation | ✅ committed (`2593e5c`) + pushed |
| `App.postflop` runtime | ✅ live; 31/31 approved scenarios loaded; frozen API |
| Browser QA result | ✅ 9/9 PASS (live verified at `http://localhost:8765/index.html`) |
| v4.0.2 planning sprint | 🟡 in progress — Architecture / UX / Data review / QA / Consolidation |
| v4.0.2 production code | ❌ not started; planning only |

---

## Parallel Workstreams

| Workstream | Owner | Status | Notes |
|---|---|---|---|
| Architecture Package | Architecture Subagent | ✅ Done + committed | `postflop/ARCHITECTURE.md` (21.4 KB) — committed in `7849741` |
| GTO Data Package | GTO Data Subagent | ✅ Done + committed | scenarios + concepts + taxonomy clean — committed in `7849741` |
| Audit Package | Audit Subagent | ✅ Done + committed | rules + browser viewer + sample report — committed in `7849741` |
| UX / UI Plan | UX Subagent | 🟡 Partial | Plan in `postflop/postflop_schema.md` § "UI / UX plan"; deeper wireframe pass deferred to v4.0.4 |
| Orchestrator Workflow Files | Orchestrator | ✅ Done + committed | All in `7849741` |
| v4.0.0 Planning Commit + Push | Orchestrator | ✅ Done | `7849741` pushed to origin/main |
| v4.0.1 Brief | Orchestrator | ✅ Done + committed | `docs/specs/brief-v4.0.1-schema-loader.md` — staged with v4.0.1 |
| v4.0.1 Implementation | DEV Integration Agent | 🟡 Staged | per `brief-v4.0.1-schema-loader.md`, awaiting commit approval |
| v4.0.1 QA | QA Agent | 🟡 Partial | All non-browser items pass; live browser load + console verification still needed |
| v4.0.2 Brief (Module 1 UI) | Orchestrator | 🚫 Blocked | Wait for v4.0.1 commit approval |

---

## Blockers

1. **Human review of v4.0.1 staged diff** (`index.html` +71/-3, `service-worker.js` +5/-1) — confirm the diff matches the brief exactly.
2. **Live browser verification of loader** — open the app, check DevTools console for `[postflop] loaded 31/31 scenarios (schema 1.0.0)`, run `App.postflop.ready` etc. (QA items 2–7 in v4.0.1 brief).
3. **Approval to commit** the staged v4.0.1 changes with message `v4.0.1: add postflop schema loader and audit gate`.
4. **Resolution of 5 open questions** (carried in `PROJECT_STATE.md` § 8) — can be deferred until v4.0.2 if not blocking.

---

## Next Actions (in order)

1. ✅ Workflow files created.
2. ✅ v4.0.0 planning package committed (`7849741`) and pushed.
3. ✅ v4.0.1 brief written and approved.
4. ✅ v4.0.1 implementation: 4 edits in `index.html` + 2 edits in `service-worker.js`. Audit re-confirmed 31/0/0.
5. ✅ State files updated (PROJECT_STATE.md, TASK_BOARD.md).
6. ⏸️ Human reviews staged diff, then approves the v4.0.1 commit.
7. ⏸️ Orchestrator commits with message `v4.0.1: add postflop schema loader and audit gate`.
8. ⏸️ Push happens only on a separate explicit "push" instruction.
9. ⏸️ On v4.0.1 commit + push: prepare `docs/specs/brief-v4.0.2-module1-board-texture-trainer.md` (planning only — first actual UI work).

---

## Recently Completed

- 2026-05-06: v4.2.5 Module 3 Limited Beta UX Polish + Critical-Flag Review COMMITTED (`55fa676`) + pushed. crb critical rate 55.3% → 30.6% via 21 surgical downgrades (poker-justified). 26 KEEPs uniquely-worst-bad. ActionReason-keyed weak-spot review wired (top 4 = all blocker_raise verified). M3 first-time explainer + module-aware concept signals + Limited Beta progression hint. Mobile chip wrap 320/360/380px clean. **Forbidden files untouched.** Production audit unchanged 385/0/0. M1/M2 regression PASS. appVersion + SW v4.2.5. Awaiting commit.
- 2026-05-06: v4.2.4-doc reconciliation COMMITTED (`cc5c209`) + pushed. Flipped v4.2.4 docs from staged to committed (`81d54c5`).
- 2026-05-06: v4.2.4 Module 3 Limited Beta Runtime Wire COMMITTED (`81d54c5`) + pushed. Full learning loop wired: TCC tile flip (preview→available BETA), postflop:m3 route, schema normalization helpers (string-form M3 vs object/array M1/M2), `getModule3Scenarios`, M3 question rendering with BB-OOP framing + 4-axis chips, `_pfM3TeachingFeedbackBlocksHtml` with prominent defenseLogic, 10 M3 concepts in library, M3 concept drill + weak-spot review, M3 session aggregation, M3 Limited Beta mastery checklist (3/2/9/weak/critical scaled thresholds), curriculum card with Start button. **No data files touched** (postflop_scenarios.json + tools/* byte-identical). Production audit unchanged 385/0/0. Browser QA mobile 375 + desktop clean. Poker QA 12 scenarios PASS. M1/M2 regression-tested PASS. appVersion + SW v4.2.4. **Module 3 IS NOW PLAYABLE as Limited Beta.** Awaiting commit.
- 2026-05-06: v4.2.3B Module 3 Data Polish + Thin-Bucket Completion COMMITTED (`e72eef6`) + pushed. M3 grows 62 → 85 scenarios (+23 across 5 new boards + 1 added to existing 8c8d3s). Production audit raised 362/0/0 → 385/0/0 (R29 = 0 warnings preserved). ALL 5 thin-bucket targets met: blocker_raise 1→4, domination_fold 2→5, nut_flush_draw 1→3, slowplay_call 3→5, protection_raise 3→6. 15 textbook scenarios promoted to consensus_gto. Difficulty spread improved (8/59/15/3). Anti-suit-swap filler scan clean. 12-scenario poker spot-check PASS. **Module 3 still NOT runtime-wired; TRAINING_MODES.m3 still kind:preview/route:null.** appVersion + SW v4.2.3B. **Limited Beta readiness: M3 ready for v4.2.4 runtime wire.** Awaiting commit.
- 2026-05-06: v4.2.3A Module 3 Data Expansion COMMITTED (`14fb380`) + pushed. M3 grows 24 → 62 scenarios (+38 across 8 new boards). Production audit raised 324/0/0 → 362/0/0 (R29 = 0 warnings preserved). Coverage gap fixes: pot_odds_defense 0→5, blocker_raise 0→1, slowplay_call 1→3, protection_raise 1→3, domination_fold 1→2, bluff_catch 2→7, nut_flush_draw 0→1. Difficulty spread improved (was all diff 3; now 7/45/9/1 across 2/3/4/5). Anti-suit-swap discipline enforced via filler scan. 12-scenario poker spot-check PASS. New canonical authoring tool + migration tool. **Module 3 still NOT runtime-wired; TRAINING_MODES.m3 still kind:preview/route:null.** appVersion + SW v4.2.3A. Awaiting commit.
- 2026-05-06: v4.2.3-doc state reconciliation COMMITTED (`b4b944f`) + pushed. Flipped v4.2.3 docs from staged to committed (`e718f07`).
- 2026-05-06: v4.2.3 Module 3 Migration to Production Data COMMITTED (`e718f07`) + pushed. 24 M3 seeds migrated to production. Production audit raised 300/0/0 → 324/0/0 (R29 = 0 warnings preserved). Concepts +10 → 25. Taxonomy extended (heroHandRole, actionReason arrays, pf_flop_cbet_oop_def module, static textureTag, review_pending/planning_only auditStatus). Auditor extended R30-R41. Audit-plan renumbered R29-R40 → R30-R41. New `tools/migrate-module3-v4.2.3.ps1`. Strategic 8-scenario spot-check PASS. **Module 3 still NOT runtime-wired; TRAINING_MODES.m3 still kind:preview/route:null.** appVersion + SW v4.2.3. State reconciliation completed in follow-up commit.
- 2026-05-06: v4.2.2G Command Center Polish + Routing Honesty STAGED. 6 polish items (sharper header, Preflop metaPills, Training Setup rename, sharper Concept Library hint, selected dot indicator, panel top accent, stronger primary CTA). Architecture preserved 100%. Mobile QA clean. UI captures in screenshots/v4.2.2G/.
- 2026-05-06: v4.2.2F Product Mode System Foundation + Premium Home Command Center COMMITTED (`7680db9` + doc `159dd6f`) + pushed. TRAINING_MODES registry + 4 helpers + premium TCC Command Center. Preflop and Postflop panels with 6 actions each. M3 preview-only (not playable). Mode persists. Mobile 375 verified. Permanent UX 5-property principle documented. Bottom-nav deferred. No data touched. v4.2.2F versions.
- 2026-05-06: v4.2.2E Final Text Integrity Repair + R29 Hardening COMMITTED (`3cc3704`) + pushed. 14 scenarios / 18 edits fixing v4.2.2D over-trigger (KTs 2 board-collapse + A — X flush prose + 5 — / 7 — list). R29 hardened to 6 patterns verified by 13 test cases. 15-field strategic integrity 0 changes. 5-scenario poker spot-check PASS. R29 = 0 warnings (true negative). v4.2.2E versions.
- 2026-05-06: v4.2.2D Card/Suit Notation Semantic Repair COMMITTED (`f53b425`) + pushed. Context-aware repair of v4.2.2C over-normalization. 263 scenarios / 525 text-field edits. All 4 suspicious patterns now 0; 186 legitimate em-dashes preserved. 15-field strategic integrity verified 0 changes. New R29 audit guard. appVersion + SW v4.2.2D. Audits unchanged 300/0/0, 24/0/8, 24/0/0.
- 2026-05-06: v4.2.2C Runtime Text Encoding Hotfix COMMITTED (`8896504`) + pushed. Cleaned 292/300 production scenarios + ranges.json of CP874 mojibake. Added `_pfFixMojibake` safety net to M1 explanation render. Fixed reverser regression that stripped clean em-dashes. Fixed install banner safe-area-inset-top. appVersion + SW bumped to v4.2.2C. Mobile QA verified clean. No strategic changes.
- 2026-05-06: v4.2.2B Module 3 Post-Commit Verification COMMITTED (`1ee6cc1`) + pushed. 3 defects fixed (F6.2 conceptTags, F3.3 acceptable, stale summary). Migration Path A green-lit. Verified v4.2.2 claims against raw JSON; caught 3 defects (F6.2 stale conceptTags, F3.3 noisy acceptable, stale summary metadata) and fixed in-place. Training Volume Gate: 24 OK for planning + migration but not stable runtime. Migration Path A green-lit; v4.2.3A expansion recommended before v4.2.4 runtime. M3 audit 24/0/0 PASS clean. Production unchanged 300/0/0. M2 unchanged 24/0/8.
- 2026-05-06: v4.2.2 Module 3 Final Strategic Review + Planning Commit Lock COMMITTED (`14bbd82`) + pushed. 22 FINAL_PASS + 2 FINAL_WARN + 0 BLOCKED. All 24 flipped to v4.2.0_final. 3 second-pass changes (2 UN-softens of v4.2.1 + F6.2 flip + slowplay_call vocab re-introduction). Training Quality assessment: M3 needs major data sprint (v4.3.x). M3 audit unchanged 24/0/0. Production unchanged 300/0/0. M2 unchanged 24/0/8.
- 2026-05-06: v4.2.1 Module 3 Seed Auditor + Strategic Review COMMITTED (`70ee74d`) + pushed. New `tools/audit-postflop-module3-seed.ps1` (Option A). M3 audit caught 13 mechanical defects (critical ⊈ bad); fixed batch. Strategic review: 17 PASS + 7 WARN + 0 FAIL. 7 targeted JSON edits. All 24 scenarios flipped to reviewStatus=v4.2.0_seed_reviewed. Final audit: 24/0/0 PASS clean. New review doc. No production touched. No version bumps.
- 2026-05-06: v4.2.0 Module 3 Architecture + Seed Plan COMMITTED (`515a3c1`) + pushed. 5 new docs in `docs/specs/postflop-v4.2.0-module3-*`: architecture, schema-taxonomy, 24-seed JSON (6 board families × 4 hands; 18 action + 6 reason), audit plan (38 hard rules + 7 warnings), GPT review package (per-scenario risk flags). Villain sizing scoped to bet_small for v4.2.0; reason set trimmed 11 → 8. No production touched. No version bumps. Production audit unchanged 300/0/0. M2 seed audit unchanged 24/0/8.
- 2026-05-06: v4.1.9 Module 2 Data Expansion + Tester Pass COMMITTED (`454c470`) + pushed. M2 grows 35 → 49 production scenarios via 14 new scenarios on 14 new boards (blocker_pressure +4, value_betting +3, range_advantage_stab +3, pot_control +2, give_up_strategy +2). All 14 PASS final GPT/strategic review; flipped to auditStatus=approved + reviewStatus=v4.1.9_gpt_reviewed. Per-concept primary-tag depth target hit (8/8/8/8/11). Production audit raised 286/0/0 → 300/0/0. Browser QA 30/30 PASS. appVersion + SW v4.1.9. No schema/taxonomy/audit-script changes.
- 2026-05-05: v4.1.8 Home Mode Tabs + M2 Mastery + Concept-Pool Depth Audit COMMITTED (`5eb12ac`) + pushed. Home tabs (Preflop/Postflop), M2 mastery checklist parallel to M1, M2 summary aggregation by handClass+actionReason, depth audit doc. 32/32 QA. appVersion + SW v4.1.8.
- 2026-05-05: v4.1.7 Module 2 Curriculum Playable Beta COMMITTED (`d48ffa9`) + pushed.
- 2026-05-05: v4.1.7 Module 2 Curriculum Playable Beta STAGED. Module 2 is playable. 24 seeds flipped to approved (runtime loads 286). All M2 surfaces wired: curriculum start button, hand-aware question/answer rendering, all 5 M2 concept drills enabled, M2 weak-spot review (M2-only pool), M2 session summary. Browser QA 35/35 PASS. appVersion + SW bumped to v4.1.7.
- 2026-05-05: v4.1.6 Concept Library Module 2 Bridge COMMITTED (`ca3ea31`) + pushed. Path A preview-only.
- 2026-05-05: v4.1.5 Module 2 Seed Cleanup + Baseline Migration + Audit Extension COMMITTED (`38cf34b`) + pushed. Production audit gate raised to 286/0/0. 11 baseline migrated + 24 seeds appended. 5 new concepts added. R18-R28 added to production auditor.
- 2026-05-05: v4.1.4 Module 2 Seed Review + Baseline Migration Decision COMMITTED (`c1df014`) + pushed. Strategic 24-scenario re-review (20 PASS / 4 WARN / 0 FAIL). Baseline-11 migration decision: Option C (Refactor/Migrate).
- 2026-05-05: v4.1.3 Module 2 Audit Tooling COMMITTED (`eafdf6d`) + pushed. New seed auditor catches all v4.1.2 mechanical-error categories. 0 hard errors / 11 documented warnings / 15 PASS / 9 WARN / 0 FAIL. Production audit still 262/0/0.
- 2026-05-05: v4.1.2 fix-pass STAGED. Corrected 5 mechanical errors in seed scenarios (flush-vs-flush-draw mis-counts on monotone/two-tone boards: #11 made straight wrongly labelled combo_draw; #13 backdoor only wrongly labelled NFD with action over-aggression; #21 set wrongly assigned to NFD; #22 K-FD explanation claimed made flush; #24 low FD explanation claimed made 6-flush). Applied 5 labelling improvements. Schema vocabulary extended with `straight`, `flush`, `nut_flush` and a "suit-count discipline" rule. Post-fix verdict: 21 PASS / 3 WARN / 0 FAIL.
- 2026-05-05: v4.1.2 Module 2 Architecture + Data Plan STAGED (planning-only). 5 docs in `docs/specs/postflop-v4.1.2-module2-*` (architecture / schema-taxonomy / 24 seed scenarios / audit plan / GPT review package). Integration model = Integrated Academy Path with applied-decision distinction (Module 1 = "Read the board", Module 2 = "Choose the action with a hand"). Audit still 262/0/0. No production change. No commit.
- 2026-05-05: v4.1.1 Postflop Concept Library Drill Actions COMMITTED (`cf088d1`) + pushed. Each of 10 concept cards becomes an actionable 12-question focused drill entry point. New mode='concept' state + blue Concept Drill badge + dedicated summary. Optional Review-signal pill from latest session weak concepts.
- 2026-05-04: v4.1.0 Postflop Academy Foundation COMMITTED (`843fa76`) + pushed. Curriculum map + mastery + recommendation engine + concept library.
- 2026-05-04: v4.0.12 Postflop Drill Weak Spots Button COMMITTED (`79cfc2a`) + pushed. End-to-end teaching loop closed.
- 2026-05-04: v4.0.11 Postflop Session Learning Summary COMMITTED (`a2e4fae`) + pushed. Quality label + strongest/weakest concepts + family pattern notes + recommended next move.
- 2026-05-04: v4.0.10 Postflop Card Text Encoding Hotfix COMMITTED (`53eae80`) + pushed. CP874 mojibake reverser + clean prompt rebuilder.
- 2026-05-04: v4.0.9 Postflop Teaching Polish COMMITTED (`c38aafc`) + pushed. M1/M3/M4/L1/M2 fixes addressing v4.0.8 QA gaps.
- 2026-05-04: v4.0.8 Postflop Teaching Layer COMMITTED (`479b775`) + pushed.
- 2026-05-04: v4.0.8 Extended QA pass — 26/26 regression checks passed; identified 4 medium + 2 low severity issues feeding v4.0.9.
- 2026-05-04: v4.0.7 Module 1 expansion 20→251 scenarios COMMITTED (`1f5fe99`) + pushed. Audit 0/0. Template-correction + micro-fix incorporated.
- 2026-05-04: v4.0.7-template-correction STAGED (folded into v4.0.7 commit). Generic two_tone family split into 5 sub-families per rank-class + connectedness. paired_mid wording fixed.
- 2026-05-04: v4.0.7-hardened (superseded by template-correction pass). SourceConfidence rebalanced (97/146/0/0). SuitTexture rebalanced (130/98/15). Tracked tools/generate-postflop-module1.ps1 + tools/audit-postflop-ps.ps1. 30-sample GPT review package.
- 2026-05-04: v4.0.7 initial staging (superseded).
- 2026-05-04: v4.0.6 postflop repeat control + local history STAGED. Awaiting commit approval.
- 2026-05-04: v4.0.5-data committed (`87c741e`) + pushed (#14 sourceConfidence honesty downgrade).
- 2026-05-04: v4.0.5 GTO Validation Pass complete (report + patch plan committed alongside v4.0.5-data).
- 2026-05-04: v4.0.4 critical hotfix committed (`519df53`) + pushed; postflop answer interaction now works on desktop + mobile.
- 2026-05-04: v4.0.3 polish committed (`25fb45e`) + pushed.
- 2026-05-04: v4.0.2 deployed live to Netlify; tester real-play surfaced 4 UX issues feeding v4.0.3 + critical onclick bug feeding v4.0.4.
- 2026-05-04: v4.0.2 Module 1 UI committed (`5d21128`) + pushed to origin/main.
- 2026-05-04: v4.0.2-data seed fix committed (`473ce9a`) + pushed.
- 2026-05-04: v4.0.2 planning sprint committed (`377c844`) + pushed.
- 2026-05-04: v4.0.1 schema loader committed (`2593e5c`) + pushed; live browser QA 9/9 PASS.
- 2026-05-04: v4.0.0 planning package committed (`7849741`) + pushed to origin/main.
- 2026-05-04: Orchestrator workflow files created (PROJECT_STATE.md, AGENTS.md, TASK_BOARD.md, docs/, tools/audit-postflop.js).
- 2026-05-04: Postflop planning package (9 files, ~206 KB) — Audit Subagent verified 0/0.
- 2026-05-04 (prior): v3.8.2 shipped to Netlify (Viewport-Dominant Field FX).
- 2026-05-04 (prior): v3.8.1 (Anime Battle Field) shipped.
- 2026-05-04 (prior): v3.8.0 (Field FX pivot + lifecycle bug fix) shipped.

---

## Discovered Work (out-of-scope; not started)

Items found during v4.0.0 work that are **not** in scope for v4.0.0 but should be tracked:

- **(low priority)** Audit Subagent could run automatically on a pre-commit hook. Currently runs only when human opens the audit page or runs the Node script. → Tracked in `RISKS.md` R-07; deferred to v4.0.5.
- **(low priority)** GitHub Action to run audit on PRs touching `postflop/*.json`. → Tracked in `RISKS.md` R-07; deferred to v4.1.
- **(medium priority)** Concept coverage gaps: `nut_advantage_shift`, `ip_advantage`, `equity_realization` have 0 scenarios. → Tracked in `audit-report-sample.md` "v4.1 expansion targets".
- **(medium priority)** Q-high and J-high boards underrepresented (only 2 scenarios each). → Tracked in `RISKS.md` R-05; planned for v4.1 data expansion.

---

## Do Not Start Yet

These tasks are deliberately **blocked** until v4.0.0 planning is approved:

- ❌ Full postflop drill integration in `index.html`
- ❌ Postflop boss tests / missions / overall exams
- ❌ Postflop cosmetic rewards / Answer FX / Aura tie-ins
- ❌ Postflop Collection Book extensions
- ❌ Service worker version bump
- ❌ Module 3 (BB Defense vs C-bet) data — v4.1 territory
- ❌ Turn / river modules — v4.2+ territory
- ❌ ICM-aware adjustments — out of v4.0.0 scope
- ❌ Multi-way post-flop — out of v4.0.0 scope

Anyone (human or subagent) starting these tasks before approval should be redirected by Orchestrator.

---

## Update protocol

- Each subagent updates its own row when status changes (✅ done / 🟡 in progress / 🚫 blocked / ⏸️ paused).
- New blockers go under "Blockers" with clear ownership.
- Discovered work goes under "Discovered Work" — never silently fixed.
- Orchestrator does the bigger reorganizations (status sync after a session, archiving completed epics).
