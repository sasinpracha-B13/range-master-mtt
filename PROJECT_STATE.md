# Project State — Range Master MTT

> **READ THIS FIRST** before doing any work in this repo.
> Subagents: this file is your single source of truth for project context, current scope, and what is/is not allowed.
> Last updated: 2026-05-06 (v4.2.5 committed + pushed `55fa676`; reconciliation in flight).

---

## 1. Current Version

- **Latest deployed to Netlify**: `v4.0.5-data` (live at `https://range-master-mtt.netlify.app/` — postflop GTO data honesty patch).
- **Last committed + pushed**: `v4.2.5` (`55fa676`) — Module 3 Limited Beta UX Polish + Critical-Flag Review. **Reconciliation in flight** (this small post-ship doc-only commit flips PROJECT_STATE / TASK_BOARD / AUDIT_HEADLINES from "staged" to "committed + pushed at 55fa676"). Predecessors: `v4.2.4-doc` (`cc5c209`); `v4.2.4` (`81d54c5`); `v4.2.3B` (`e72eef6`); `v4.2.3A` (`14fb380`); `v4.2.3-doc` (`b4b944f`); `v4.2.3` (`e718f07`); `v4.2.2G` (`8c150ab`).
- **Last committed + pushed (MODULE 3 LIMITED BETA UX POLISH + CRITICAL-FLAG REVIEW)**: `v4.2.5` (`55fa676`) — Module 3 Limited Beta UX Polish. **Targeted data + runtime sprint.** Three axes: (1) **Strategic critical-flag rebalance** — `check_raise_big` critical rate brought from **47/85 = 55.3% → 26/85 = 30.6%** via 21 surgically-justified downgrades. Each downgrade documented with poker rationale (hand has real equity backup like BDFD/1-card FD/gutshot/OESD/A-blocker, made-hand component like TPGK/TPTK/TPWK, sizing error vs severe punt, oversizing strong value). 26 KEEPs are uniquely-worst-bad cases: 5 naked-pair calls (mid pair / underpair, no draw OOP), 4 slowplay teachings (raise nut hand folds villain's wide air bucket = severe value punt), 17 BEST=fold naked-trash spots (no pair / no draw / no blocker = uniquely-worst). **Production audit unchanged 385/0/0.** R29 = 0 warnings preserved. M2 + M3 seed audits unchanged. **Zero changes to:** answer.best, answer.acceptable, answer.bad, recommendedAction, actionReason, conceptTags, explanation text, board.cards, heroHand, M1/M2 scenarios, audit rules. Only `answer.critical` arrays edited on 21 M3 scenarios. (2) **ActionReason-keyed weak-spot review** — `_pfCurrentSessionWeakProfile` extended with `targetActionReasons` + `targetHeroHandRoles` (looked up from live scenario pool because history.answers don't store these fields). `_pfWeakScenarioScore` extended with +50 boost for matching actionReason and +35 for matching heroHandRole. Verified with simulated 2-bad-blocker_raise session: top 4 candidates all `blocker_raise` scenarios. M3 weak-spot empty-state explicit toast: "Play Module 3 sessions to unlock BB Defense weak-spot review." (3) **UX polish:** mobile chip wrapping at 320/360/380px micro-mobile breakpoints (no horizontal overflow at any tested viewport); first-time M3 explainer (`_pfM3IsFirstTime` + `_pfM3FirstTimeExplainerHtml` — collapsible "About Module 3" block on Q1 of first M3 session, hides forever after); M3 Concept Library module-aware review signals (`_pfConceptReviewSignal` extended with module-match check + 8 alias-concept actionReason mappings — value_raise/protection_raise/semi_bluff_raise/blocker_raise/slowplay_call/domination_fold/bluff_catchers/range_disadvantage); Limited Beta progression hint after 3rd M3 session ("📈 Beta progress unlocked — now review your weakest BB Defense reasons" — honest copy, not "mastery"). **Browser QA mobile 320×568 + 360×740 + 375×812 + desktop:** no horizontal overflow at any width, first-time explainer renders + collapses cleanly, 4-axis chip row wraps gracefully, M3 grading correct, 0 console errors. **Programmatic QA:** actionReason weak-spot scoring verified (top 4 = all blocker_raise scenarios), M3 weak-spot empty-state toast fires, M1 + M2 regression-tested PASS via normalizer passthrough. **5-scenario poker spot-check post-edit:** Th8h-call-downgraded ✓, AsKh-blocker_raise-reason ✓, QdJh-domination_fold (kept critical) ✓, 8h7h-trips-slowplay (kept critical) ✓, TcTd-protection_raise (kept) ✓. All 5 grade 1.0 BEST. **Forbidden files untouched:** postflop_concepts.json / postflop_taxonomy.json / tools/audit-postflop-ps.ps1 / tools/audit-postflop-module3-seed.ps1 / ranges.json / manifest.json / preflop / gamification all byte-identical. M1/M2 scenario strategy fields byte-identical. **Net diff:** index.html +210/-8 (UX polish + helpers + CSS), service-worker.js 1-line VERSION bump, postflop_scenarios.json 21 critical-array edits, 1 new tool (downgrade-crb-critical-v4.2.5.ps1), 1 new doc. appVersion + SW v4.2.4 → 4.2.5. **Module 3 still playable as Limited Beta** — the rebalance + polish improves the learner experience without weakening any strategic truth. New doc `docs/specs/postflop-v4.2.5-module3-limited-beta-ux-polish.md`. New snapshot `GPT AUDIT/v4.2.5/`.

- **Project owner notes for v4.2.5:** Discipline win — the brief said "do not weaken critical flags merely to improve a metric" and the 21 downgrades all carry concrete poker reasoning (real equity backup, made-hand component, sizing error vs severe punt). The 26 KEEPs are uniquely-worst-bad cases where big-raising IS the conceptual punt. The 30.6% landing point isn't the 25% the brief targeted, but it's the strategically-justified bottom — going further would invalidate slowplay teachings or under-punish naked trash. The actionReason-keyed weak-spot review is the most architecturally important addition: it gives M3 a per-reason learning signal that the v4.2.4 generic engine couldn't provide. Score weights tuned (+50 actionReason vs +40 conceptTag vs +35 heroHandRole vs +60 family vs +100 scenarioId) so weak buckets cluster correctly without drowning out the broader concept space. The first-time explainer is intentionally compact (~100 words) and dismissible — no onboarding-flow over-engineering. Pattern lessons for future modules: (1) per-module review signals require module-aware filtering OR alias-concept mappings — both implemented for M3; (2) weak-spot review benefits from actionReason / heroHandRole axes when the module has structured decision categories; (3) mobile chip wrapping needs micro-mobile breakpoints below 380px even when 480px breakpoint exists; (4) the canonical PowerShell builder + critical-rebalance script is more maintainable than hand-edited JSON.

- **Last committed + pushed (V4.2.4 RECONCILIATION)**: `v4.2.4-doc` (`cc5c209`) — state reconciliation. Last committed + pushed (RUNTIME WIRE): `v4.2.4` (`81d54c5`). **Runtime-only sprint. NO data changes.** Wired Module 3 (Facing C-bet OOP) into the runtime as **"Limited Beta · 85 scenarios"** with the full learning loop. **Production audit unchanged 385/0/0** (no data file edits). R29 preserved at 0 warnings. M2 + M3 seed audits unchanged. **TRAINING_MODES.postflop.actions.m3 flipped:** `kind: 'preview'` / `route: null` / `icon: '🔒'` / hint "Coming in v4.2.4 beta" → `kind: 'secondary'` / `route: 'postflop:m3'` / `icon: '🛡️'` / `badge: 'BETA'` / hint "85 OOP defense scenarios · Limited Beta". **New `postflop:m3` route** in `runTrainingModeAction` calling `startPostflopDrill('pf_flop_cbet_oop_def', 10)` (default Limited Beta queue length 10). **Schema normalization (the architectural keystone of v4.2.4):** new `_pfNormalizePostflopChoices(scenario)` + `_pfNormalizePostflopAnswer(answer)` helpers handle M3's string-form `question.choices` (e.g. `["fold","call",...]`) and string-form `answer.best` (e.g. `"call"`) uniformly with M1/M2's object/array forms. `classifyPostflopAnswer` + `_findChoiceLabel` route through normalizers — M1/M2 grading is byte-identical because passthrough preserves their shapes. **`_PF_M3_ACTION_LABELS` (5 actions)** + **`_PF_M3_REASON_LABELS` (9 reasons)** provide pretty labels. **New `getModule3Scenarios()` helper** filters to `auditStatus === 'approved'` (Limited Beta cleanliness). **M3 question rendering:** dedicated BB-defending prompt framing ("BB has X on board... BTN c-bets ~33% pot. What is BB's best action?"); 4-axis chip row (handClass / heroHandRole / drawCategory / showdownValue); BB-OOP spot tag row distinct from M1/M2 BTN-IP framing; M3-flavored choice guide (`action_choice_m3` + `reason_choice_m3`) with vocabulary explicitly distinct from M2's IP-c-bet vocabulary. **NEW `_pfM3TeachingFeedbackBlocksHtml`** — Recommended Action (BB OOP) + **🎯 Defense Logic** (M3-defining field, prominent) + Hand Logic + Sizing Logic + 🃏 Blocker note + Range Context (collapsed) + 💡 Takeaway + ⚠️ Common Mistake. Hides empty fields. **Concept Library extended +10 entries:** 7 M3-native + 3 M3-alias concepts, all `module: 'm3'`, all `previewOnly: false`. New 3rd group header "Module 3 — BB Defense OOP (10 · Limited Beta)" in `_pfConceptLibraryHtml`. **M3 concept drill** wired through `startPostflopConceptDrill` (filters M3 pool, queue 10). **M3 weak-spot review** wired through `startPostflopWeakSpotReview` (routes by previously-played module; M1/M2/M3 pools never cross-contaminate; M3 weak queue 10). **NEW `_pfM3RenderSessionAggregations`** — handClass / heroHandRole / actionReason breakdowns (parallel to M2's pattern). **NEW `_pfM3MasteryStats` + `_pfM3MasteryProgressHtml`** with **Limited Beta thresholds** (3 sessions / 75% in 2 / all 9 actionReasons / weak-review used / no critical) — scaled vs M1/M2's full-module thresholds. Title explicitly "Module 3 Limited Beta progress (display only)" — honest copy. **`_PF_CURRICULUM` m3 entry** updated: status beta, 85 scenarios, 8-line syllabus, "▶ Start Module 3 Limited Beta" primary button. **`_pfModuleStatus('m3')` → 'beta'** (was 'locked'). **Concept Library hint** "Browse 15 concept drills" → "Browse 25 concept drills" to reflect 10 M1 + 5 M2 + 10 M3. **Browser QA mobile 375×812 + desktop:** TCC M3 tile renders with BETA badge + 🛡️ icon + "85 OOP defense scenarios · Limited Beta" hint; M3 drill starts; question screen shows BB-OOP framing with hero hand row + 4-axis chips; 5 string-form choices grade correctly; feedback panel shows defenseLogic prominently with all M3 teaching blocks; concept library shows M3 group; M3 mastery checklist renders with Limited Beta thresholds; curriculum card shows Beta status + Start button; M1 + M2 regression-tested PASS (normalizer passthrough preserves their shapes); 0 console errors. **Poker learning-product QA on 10 M3 scenarios + 1 M1 + 1 M2:** all 12 PASS — every M3 best graded 1.00 BEST, every non-best graded bad/critical correctly, all 10 had defenseLogic + takeaway populated. **CRITICAL — no data file edits:** postflop_scenarios.json / postflop_concepts.json / postflop_taxonomy.json / tools/audit-postflop-ps.ps1 / tools/audit-postflop-module3-seed.ps1 all byte-identical. ranges.json / manifest.json / preflop / gamification all byte-identical. M1 / M2 scenario strategy fields all byte-identical. **Net file diff: index.html +798/-61 lines (M3 wiring across 6 batches), service-worker.js 1-line VERSION bump.** appVersion + SW bumped 4.2.3B → 4.2.4 (cache invalidation). Limited Beta is ON: M3 is now playable from the Training Command Center, Postflop Academy curriculum card, and Concept Library. New doc `docs/specs/postflop-v4.2.4-module3-limited-beta-wire.md`. New snapshot `GPT AUDIT/v4.2.4/`.

- **Project owner notes for v4.2.4:** Module 3 ships as Limited Beta with the full learning loop wired. The architectural keystone was the schema normalization layer — M3's string-form choices/best are converted to M1/M2's object/array shape at every consumer boundary, so the rest of the runtime stays module-agnostic. This pattern will be reusable for any future Postflop module that uses a different schema (Module 4 turn play, Module 5 river polarization, etc.). The honest-labeling discipline ("Limited Beta," "85 scenarios," scaled mastery thresholds, "display only") is critical: the user explicitly said don't overclaim stability, and v4.2.4 doesn't. The mastery checklist title is "Module 3 Limited Beta progress (display only)" not "mastery"; the curriculum syllabus closes with "Limited Beta · 85 approved scenarios"; the TCC tile says "85 OOP defense scenarios · Limited Beta" — every surface is consistent. Pattern lessons for future runtime sprints: (1) normalize schema at the boundary, never in the renderer; (2) extend existing renderers via `isM3` flags rather than creating parallel duplicate renderers — keeps drift low; (3) the canonical `handlePostflopChoiceById` works programmatically AND through the delegated DOM listener — both paths grade identically; (4) postflop history doesn't need M3-specific schema — sessions are keyed by `module` so M3 sessions are filterable from the same `_pfHistoryLoad()` source as M1/M2.

- **TCC `kind` enum clarification (added during v4.2.4 reconciliation):** the TRAINING_MODES `kind` field uses three values in the codebase: `'primary'`, `'secondary'`, `'preview'`. There is **NO `'available'` value** — that term appears in some sprint briefs colloquially to mean "clickable + non-preview," but the actual enum is `'secondary'`. Runtime treatment: `_tccBuildActionTileHtml` adds `is-primary` class for primary actions, `is-preview` class for preview actions (and renders a SOON badge + omits the click handler), and treats anything else as a clickable secondary CTA. `runTrainingModeAction` early-returns with a "coming soon" toast iff `action.kind === 'preview' || !action.route`. So `kind: 'secondary'` + `route: 'postflop:m3'` makes the M3 tile fully clickable with the BETA badge, distinguished visually from the M1 primary tile (which has the lead-CTA accent). This is **intentional and correct** — do NOT change M3 to `kind: 'available'` (the value doesn't exist in the codebase) or `kind: 'primary'` (would visually compete with M1 as the postflop lead CTA). Future modules should use `kind: 'secondary'` + a real `route` to flip from preview → live, mirroring v4.2.4's M3 pattern.

- **Last committed + pushed (MODULE 3 DATA POLISH)**: `v4.2.3B` (`e72eef6`) — Module 3 Data Polish + Thin-Bucket Completion. **Quality + sourceConfidence sprint. NO runtime wiring.** Polished Module 3 from 62 → **85 production scenarios** (+23 across 5 new board families + 1 added to existing 8c8d3s). **Production audit raised 362/0/0 → 385/0/0** (251 M1 + 49 M2 + 85 M3). R29 card-notation guard preserved at 0 warnings. M2 + M3 seed audits unchanged. **5 new boards:** Kh Qh 4s (K-high two-tone broadway dynamic), Kh Jh 4h (K-high monotone), Qd 7d 2c (Q-high two-tone dry), Ac Ad 7s (A-high paired), Ts 9s 5d (mid-connected two-tone dynamic). M3 distinct boards: 14 → **19**. **ALL 5 thin-bucket targets met:** blocker_raise 1→**4** ✓; domination_fold 2→**5** ✓; nut_flush_draw drawCategory 1→**3** ✓; slowplay_call 3→**5** ✓; protection_raise 3→**6** ✓. **15 textbook scenarios promoted from `expert_judgment` → `consensus_gto`** with documented promotion criteria (set raises on dry boards, naked overcards no equity, backdoor-only fold on broadway, no-spade overcards on monotone, nut flush on monotone raise, AA overpair value-raise on rag). M3 sourceConfidence: 70 expert + 15 consensus_gto. Difficulty spread improved (8/59/15/3 across 2/3/4/5 vs v4.2.3A's 7/45/9/1). **Anti-suit-swap discipline:** filler scan = 0 cross-bucket / 0 suit-only dupes / 0 missing uniquenessNotes / 0 card collisions. Multiple suit-similar scenarios (e.g., 4 blocker_raise on different textures monotone vs two-tone vs dry vs broadway, 3 nut_flush_draw on different boards) JUSTIFIED BY UNIQUE STRATEGIC DIMENSIONS documented per scenario. **Strategic 12-scenario poker spot-check: all 12 PASS** (blocker_raise positive + distinction, domination_fold weak Qx, nut FD call/raise, slowplay trips paired-A + overpair paired-low, protection_raise top set wet, pot odds marginal call, range disadv fold no blocker, reason_choice + consensus_gto promotion). New canonical authoring tool `tools/build-polish-v4.2.3B.ps1` (PSCustomObject definitions, ASCII-only) + migration tool `tools/migrate-polish-v4.2.3B.ps1`. **CRITICAL — Module 3 still NOT playable, NOT routable, NOT runtime-wired:** TRAINING_MODES.postflop.actions.m3 still `kind: 'preview'`, `route: null`. Runtime helpers byte-identical (only appVersion + SW VERSION lines changed in index.html / service-worker.js — 1 line each). Net runtime effect: `App.state.postflop.scenarios` 362 → 385 in memory but no UI surface routes the new 23 (or any of the 85 M3 scenarios). appVersion + SW bumped 4.2.3A → 4.2.3B (cache invalidation only). **Limited Beta readiness assessment: M3 IS NOW READY for v4.2.4 runtime wire.** All thin buckets filled; 19 distinct boards; 15 consensus_gto anchors; 9 actionReasons all ≥4. v4.2.4 should label as "Limited Beta · 85 scenarios" with scaled mastery thresholds (e.g., 3 sessions / 75%+ in 2 / all 9 reasons seen). New doc `docs/specs/postflop-v4.2.3B-module3-data-polish.md`. New planning seed file `docs/specs/postflop-v4.2.3B-module3-polish-seeds.json` (23 scenarios with uniquenessNotes). New snapshot `GPT AUDIT/v4.2.3B/`. No ranges.json / preflop / gamification / wardrobe / TRAINING_MODES logic changes.

- **Project owner notes for v4.2.3B:** Quality > count discipline maintained. The thin-bucket completion was the headline target — all 5 buckets met or exceeded. The most subtle lesson added is the BLOCKER_RAISE distinction: 4 scenarios across 4 different textures (low monotone, K-high two-tone, K-high monotone, Q-high dry two-tone) testing that hero correctly identifies the actionReason as "blocker" (not "semi-bluff") when the EV comes from removing villain combos rather than from outs. This is the kind of nuance that distinguishes a beginner module from an intermediate one and now has enough volume to support concept drills + weak-spot review reliably. The sourceConfidence promotion (15 → consensus_gto) gives the module credible authority for its most textbook lessons while keeping the close-mix and solver-uncertain spots honestly at expert_judgment. v4.2.4 runtime wire is now defensible — Limited Beta labeling is the recommended path forward. Pattern lessons: (1) the canonical PowerShell builder + migration script pattern (now 3 versions deep: v4.2.3, v4.2.3A, v4.2.3B) is the right pattern for any future expansion sprint; (2) ASCII-only authoring scripts continue to be required to avoid CP874 mojibake; (3) sourceConfidence promotion criteria should be documented per-spot, not blanket-applied.

- **Last committed + pushed (MODULE 3 DATA EXPANSION)**: `v4.2.3A` (`14fb380`) — Module 3 Data Expansion. **Data expansion sprint. NO runtime wiring.** Expanded Module 3 from 24 → **62 production scenarios** (+38 new scenarios across 8 new board families). **Production audit raised 324/0/0 → 362/0/0** (251 M1 + 49 M2 + 62 M3). R29 card-notation guard preserved at 0 warnings. M2 + M3 seed audits unchanged. **8 new board families:** As9s4d (A-high two-tone dry), Ks8s3d (K-high two-tone dry), QsTs6d (Q-high two-tone dynamic), 7s5s3s (low monotone), 8c8d3s (paired low rainbow), 9d8c6h (low semi-connected rainbow), TcTh6s (paired T rainbow), 6c3d2h (very dry rag rainbow). M3 distinct boards: 6 → **14**. **Coverage gap fixes:** `pot_odds_defense` 0→5 primary tags (was missing entirely); `blocker_raise` actionReason 0→1 (introduced via AsKh reason_choice on monotone — first M3 blocker_raise lesson); `slowplay_call` 1→3 (paired-low trips, paired-T trips); `protection_raise` 1→3 (top set on connected, TPGK on K-high two-tone, two-pair on connected); `domination_fold` 1→2 (QJ on K-high two-tone added); `bluff_catch` 2→7 (3.5x); `nut_flush_draw` drawCategory 0→1 (AsQs on Ks8s3d). **Difficulty spread improved:** all 24 v4.2.3 were diff 3; now 7 diff 2 + 45 diff 3 + 9 diff 4 + 1 diff 5. **Filler discipline:** anti-suit-swap rule enforced via filler scan (0 cross-bucket boards, 0 suit-only dupes, 0 missing uniquenessNotes — every new scenario carries a uniquenessNote explaining new strategic dimension). **Strategic spot-check on 12 scenarios across major themes (pot odds call/fold, bluff-catcher call, dominated fold, semi-bluff raise, protection raise, range disadv fold, slowplay, paired bluff-catch, monotone call/fold, blocker_raise reason): all 12 PASS.** Migration via NEW `tools/build-expansion-v4.2.3A.ps1` (canonical authoring script with PSCustomObject scenario definitions) + `tools/migrate-expansion-v4.2.3A.ps1` (idempotent, UTF-8 NO-BOM). Mid-sprint text-integrity caught: 1 Thai-mojibake byte (≈ symbol round-tripped through CP874 to U+0E42); fixed inline by replacing with ASCII `~`. Final: 0 mojibake. **CRITICAL — Module 3 still NOT playable, NOT routable, NOT runtime-wired:** TRAINING_MODES.postflop.actions.m3 still `kind: 'preview'`, `route: null`. Runtime helpers byte-identical (only appVersion + SW VERSION lines changed in index.html / service-worker.js). Net runtime effect: `App.state.postflop.scenarios` 324 → 362 in memory but no UI surface routes the new 38 (or any of the 62 M3 scenarios). appVersion + SW bumped 4.2.3 → 4.2.3A (cache invalidation only). **Training volume assessment:** 62 scenarios is in the 50-80 target range; 8 of 9 actionReasons have ≥3 representation; only `blocker_raise` (1) is still thin. v4.2.3B optional (focus on blocker_raise depth + sourceConfidence promotion); v4.2.4 (runtime wire as Limited Beta · 62 scenarios) is acceptable now if labeled honestly with scaled mastery thresholds. New doc `docs/specs/postflop-v4.2.3A-module3-data-expansion.md`. New planning seed file `docs/specs/postflop-v4.2.3A-module3-expansion-seeds.json` (38 scenarios with uniquenessNotes). New snapshot `GPT AUDIT/v4.2.3A/`. No ranges.json / preflop / gamification / wardrobe / TRAINING_MODES logic changes.

- **Project owner notes for v4.2.3A:** Discipline-led expansion. The anti-suit-swap rule was the key gate — every new scenario had to add a strategic dimension beyond cosmetic suit changes. The 38 scenarios were authored as PSCustomObjects in a canonical PowerShell builder, then migrated through the same enrichment pipeline as v4.2.3, ensuring schema parity. The biggest coverage win was `pot_odds_defense` (0→5 primary), which now anchors the threshold-defense lessons that make M3 trustworthy. The `blocker_raise` reason_choice on AsKh/7s5s3s monotone is the most advanced new lesson (difficulty 5) — it tests recognition that some OOP raises are reason="blocker" not "semi-bluff," which is the kind of subtle distinction that separates a beginner module from an intermediate one. With 62 scenarios and 14 distinct boards, M3 is now content-strong enough for v4.2.4 runtime wire IF the project owner is willing to label it as "Limited Beta · 62 scenarios" with scaled mastery (vs M1's mature 251). v4.2.3B is the more conservative path (push to ~80 first); both are defensible. Pattern lessons: (1) the canonical PowerShell builder (build-expansion-v4.2.3A.ps1) is much more maintainable than hand-edited JSON for 38 scenarios — future expansions should copy this pattern; (2) the filler scan must be done BEFORE migration, not after — caught 0 dupes here but the scan is the hard gate; (3) authoring tools must use ASCII-only chars (no `≈`) to avoid CP874 mojibake on Windows PowerShell write paths.

- **Last committed + pushed (MODULE 3 MIGRATION TO PRODUCTION)**: `v4.2.3` (`e718f07`) — Module 3 Migration to Production Data. **Data + audit hardening sprint. NO runtime wiring.** Migrated all 24 finalized v4.2.0 Module 3 (Facing C-bet OOP) planning seeds into production `postflop/postflop_scenarios.json`. **Production audit raised 300/0/0 → 324/0/0** (251 M1 + 49 M2 + 24 M3). **R29 card-notation guard preserved at 0 warnings.** M2 + M3 seed audits unchanged. Migration enriches each M3 seed with production-only fields: `version`, `game="NLH_MTT"`, `street="flop"` (top-level), `actionHistory=[]`, `scoring={best:1,acc:0.5,bad:0,crit:0}`, `difficulty=3`, plus board enrichment (`connectedness`, `pairedStatus`, `dynamicLevel`, `rangeAdvantage`, `nutAdvantage`) per the 6 board families. Strips planning-only `reviewStatus`. Migration auditStatus path: `planning_only → review_pending → approved` (via the migration script then a flip pass once production audit passed clean). **Concepts file extended +10:** 7 M3-native (`oop_defense_threshold`, `check_raise_value`, `check_raise_bluff`, `bluff_catchers`, `equity_realization_oop`, `range_disadvantage`, `pot_odds_defense`) + 3 M3-alias (`value_raise`, `protection_raise`, `semi_bluff_raise`) bringing total 15 → 25. **Taxonomy file extended:** `heroHandRole.module2[]` + `heroHandRole.module3[]` (incl. `bluff_catcher`, `dominated_marginal`); `actionReason.module2[]` + `actionReason.module3[]` (incl. `slowplay_call`); `auditStatusValues[]` += `review_pending`, `planning_only`; `textureTags[]` += `static`; new `modules.pf_flop_cbet_oop_def` entry. **Production auditor (`tools/audit-postflop-ps.ps1`) extended with R30–R41** covering M3 spot/action/reason/vocabulary/answer-consistency/explanation/conceptTags/sourceConfidence/villainAction/villainSizing/heroHand-collision/moduleId rules — applied only when `module === 'pf_flop_cbet_oop_def'`. R04/R05 generalized to handle M3's string-form `question.choices` and string-form `answer.best` (different from M1/M2 which use object-form choices and array-form best). Audit-plan doc renumbered R29-R40 → R30-R41 because R29 is owned by the v4.2.2D/E card-notation guard. **Migration tool (NEW):** `tools/migrate-module3-v4.2.3.ps1` — idempotent one-shot script (UTF-8 NO-BOM via `[System.IO.File]::WriteAllText`). **Strategic spot-check on 8 critical M3 scenarios verified by reviewer** — all 8 strategic verdicts match expert-judgment GTO intuition for BB-vs-BTN SRP 100BB OOP defense. **CRITICAL — Module 3 still NOT playable, NOT routable, NOT runtime-wired:** TRAINING_MODES.postflop.actions.m3 still `kind: 'preview'`, `route: null`, hint "Coming in v4.2.4 beta". `runHomeCommandCenterMount`, `runTrainingModeAction`, `startPostflopDrill`, postflop loaders all byte-identical. Net runtime effect: `App.state.postflop.scenarios` 300 → 324 in memory but no UI surface routes the new 24. appVersion + SW bumped 4.2.2G → 4.2.3 (cache invalidation only). **Training volume caveat documented:** 24 scenarios is acceptable for migration but too thin for a playable beta — v4.2.4/v4.2.5 must expand to ~80–120 scenarios before flipping the M3 tile from preview to available. New doc `docs/specs/postflop-v4.2.3-module3-migration.md`. New snapshot `GPT AUDIT/v4.2.3/`. No ranges.json change. No preflop / gamification / boss / mission / wardrobe / collection-book / answer-fx / field-fx / aura touched.

- **Project owner notes for v4.2.3:** Migration sprint succeeded with discipline — the 24 seeds went production with zero strategic content changes (only structural enrichment for production schema parity). The R30–R41 audit extension is reusable for any future M3 seed expansion in v4.2.3A / v4.2.4 / v4.2.5 — they enforce schema integrity without touching strategic correctness (which is the seed audit's job). The 3 alias concepts (value_raise, protection_raise, semi_bluff_raise) parallel M2's value_betting / protection_betting / semi_bluff_with_equity but in OOP-raise framing — keeping them as separate concepts (rather than tagging M3 seeds with the M2 concept names) preserves the curriculum's mode-specific framing for the eventual Concept Library M3 tab. Two architectural lessons: (1) M3's string-form choices vs M1/M2's object-form choices required generalizing R04/R05 — future modules should pick one schema and stick with it; (2) the v4.2.0 audit-plan's R29 numbering was already consumed by the v4.2.2D/E text-integrity guard, so the migration had to renumber to R30+. Future audit plans should avoid claiming hard rule numbers without checking the current guard registry.

- **Pending push (STAGED, COMMAND CENTER POLISH)**: `v4.2.2G` — (NOTE: now historical; committed at `8c150ab`.) Command Center Polish + Routing Honesty Pass. **Focused UX polish on top of v4.2.2F. No architecture change. No data/audit/preflop/gamification touched.** Six v4.2.2F preview-review findings addressed: (1) **Header copy sharper** — title `"Choose your training world"` → `"Choose Your Training Path"`; helper trimmed 22 → 12 words to `"Build ranges preflop. Sharpen decisions postflop. Pick one focus for this session."` (2) **Preflop status-pill asymmetry fixed** — added `metaPills` field to TRAINING_MODES registry; Preflop now shows `["Drills · Exams · Boss", "Ranks · Browse"]` always + dynamic rank/answer pills when available (matches Postflop's M1/M2 status pattern). (3) **Boss Tests · Missions routing honesty** — renamed to `"Training Setup"` with hint `"Choose drill, boss, or exam mode"` + icon ⚙ (was ⚔); route still `preflop:drillsetup` (Drill setup screen) — label now matches destination. (4) **Concept Library hint precision** — `"15 concept drills"` → `"Browse 15 concept drills"` (honest about scroll-to-library navigation, doesn't imply auto-start). Postflop Progress hint similarly: `"Mastery + history"` → `"View mastery + history"`. (5) **Premium visual polish** — selected-card corner indicator dot via `::after` (8×8px, accent-colored, glow); panel top-edge accent line via `::before` (gradient line, mode-colored, opacity 0.45); stronger primary CTA gradient + box-shadow + brighter hover; unselected card opacity 0.78 → 0.72 for stronger contrast. (6) **Icon consistency** — kept ♠ + 🎯 (each carries semantic meaning); CSS containers already provide visual consistency. **Architecture 100% preserved:** TRAINING_MODES registry preserved (only additive `metaPills` field), all 4 helpers unchanged, M3 still `kind: 'preview'`, `route: null`, no `onclick` attribute on M3 tile (verified via DOM inspect). **Browser QA via Preview MCP at mobile 375×812:** TCC shell 343px (no overflow), mode buttons 156.5px each (2-up), Preflop selected dot blue + Postflop selected dot orange visible at top-right corners, both panels show subtle accent line at top edge, primary CTAs visibly more saturated, status pills wrap cleanly, 0 console errors. appVersion + SW bumped 4.2.2F → 4.2.2G. Production audit unchanged 300/0/0 (R29 = 0). M2 + M3 seed audits unchanged. New doc `docs/specs/postflop-v4.2.2G-command-center-polish.md`. UI captures saved to `GPT AUDIT/screenshots/v4.2.2G/`. **Module 3 NOT productionized, NOT runtime-wired, NOT playable. v4.2.3 still paused.**

- **Project owner notes for v4.2.2G:** This sprint demonstrates the "polish without rewrite" pattern. v4.2.2F's B+ architecture was correct but had 6 honest UX gaps. All 6 fixed via additive changes (new `metaPills` field, CSS-only visual polish, label/hint rewrites) — zero breaking changes to the 4 helpers or the 12 routes. The discipline of routing honesty ("Boss Tests · Missions" → "Training Setup" because the route doesn't directly land on Boss) reinforces the §7.5 5-property rule: visual promise must match actual behavior. Future sprints adding more modes / more actions should follow the same pattern: extend the registry, don't rewrite the engine.

- **Pending push (STAGED, PRODUCT MODE SYSTEM FOUNDATION)**: `v4.2.2F` — (NOTE: now historical; committed at `159dd6f`. Detail kept for reference.) — Product Mode System Foundation + Premium Home Command Center. **UX architecture sprint.** Replaces v4.1.8 misleading home tabs (which were a fair user complaint — Preflop tile just `switchTab('drill')`, Postflop tile just smooth-scrolled) with a real foundation: (1) **`TRAINING_MODES` registry** = central metadata for both modes (id, title, accent, subtitle, description, 6 actions each with id/label/hint/icon/kind/route/badge), (2) **4 helper functions** (`getTrainingMode`, `setTrainingMode`, `getTrainingModeMeta`, `runTrainingModeAction`), (3) **Premium Home Command Center** with `.tcc-shell` (eyebrow + title + helper) + `.tcc-selector` (2-card segmented selector with strong accent-colored selected state) + `.tcc-panel` (mode-aware command panel with hero + status pills + 6-action grid), (4) **safe CTA routing through `runTrainingModeAction(mode, id)`** — no scattered onclick strings; every visible CTA is registry-driven. **Preflop panel:** Quick Drill (primary) / Deep Drill / Weakness Review / Marginal Spots / Browse Ranges / Boss Tests · Missions — all real existing routes (sets `App.state.drill.mode` then `switchTab('drill')` + `startDrill()` for the 4 mode-based drills, `switchTab('browse')` for ranges, `switchTab('drill')` to Drill setup for Boss/Mission/Exam pickers). **Postflop panel:** Module 1 · Board Texture (primary, 251 scenarios) / Module 2 · Flop C-bet IP (BETA badge, 49 scenarios) / Concept Library / Weak Spot Review / Postflop Progress / **Module 3 · BB Defense OOP (preview, SOON badge, route=null)** — M3 explicitly preview-only, no real destination, click shows "coming soon" toast. Mode persists via existing `App.state.settings.trainingMode` (saved to `localStorage.rmtt_settings`). **Mobile 375×812 verified:** TCC shell 343px (no overflow), mode buttons 2-up at 156.5px each, action grid 2-col mobile / 3-col tablet, primary CTA spans full width, bottom nav not overlapped, install-banner safe-area-inset still working from v4.2.2C. **Permanent UX principle documented** (5 mandatory properties for any future mode/tab/world UI: visual promise, actual behavior, user mental model, routing destination, fallback if route not ready). **Lessons from v4.1.8 captured as anti-patterns** to prevent recurrence (tile-as-shortcut, scroll-only navigation, collapsing complex area into one default, missing fallback for unimplemented routes, UI without state foundation). **Bottom-nav rewrite intentionally deferred** to v4.3.x once M3 + future modules validate the foundation. **No data/audit/preflop/gamification files touched.** Production audit unchanged 300/0/0 (R29 = 0 warnings). M2 + M3 seed audits unchanged. appVersion + SW v4.2.2F. New doc `docs/specs/postflop-v4.2.2F-product-mode-system-foundation.md` (~430 lines). **Module 3 NOT productionized, NOT runtime-wired, NOT playable.** v4.2.3 migration still paused.

- **Project owner notes for v4.2.2F:** This sprint is the explicit fix for a fair user criticism — the v4.1.8 home tabs looked like mode navigation but behaved like shortcut buttons. The criticism became a permanent design rule (the 5-property requirement) rather than just a one-off fix. Every future mode/tab UI must answer the 5 questions before code review. **Architecturally, the foundation built here is reusable:** when M3 productionizes in v4.2.3 + v4.2.4, the only change is `m3.kind: 'preview' → 'primary'` and `m3.route: null → 'postflop:m3'` in the registry, plus one route case in `runTrainingModeAction`. The visual / mode-button / panel-swap behavior is zero-effort. Same pattern scales to M4+ and any future training context (turn play, river polarization, multi-way, ICM, tournament-stage modes, etc.).

- **Pending push (STAGED, FINAL TEXT INTEGRITY + R29 HARDENING)**: `v4.2.2E` — (NOTE: now historical; committed at `3cc3704`. Detail kept for reference.) — Final Postflop Text Integrity Repair + Poker-Semantic Guard Hardening. **Production text-integrity correction. No strategic content changes.** v4.2.2D's Pattern 4 (`[R] — [R] —` → `[R][R]s` for combo lists) over-triggered on board references that escaped the `On [R] — [R] — [R] — ` board-rebuild — producing fake suited-hand strings like `KTs 2` (originally `Kh Td 2s`). Three other patterns also leaked through v4.2.2D: `A — X` / `K — X` flush combo residue, and `5 — /7 — /8` rank-x list residue. **14 scenarios / 18 text-field edits.** Repairs use `scenario.board.cards` to rebuild the genuine board (e.g., "on KTs 2" → "on Kh Td 2s"); flush prose `A — X` → `A-X` (canonical); rank-x list `5 — /7 — /8-holdings` → `5x / 7x / 8x holdings`. **R29 guard hardened with 3 new patterns** (`board_collapse`, `rank_dash_X`, `rank_dash_slash`) bringing total to 6 patterns. **R29 verified against 13 test cases: 6/6 positive flagged correctly, 7/7 negative not flagged** (e.g., `KTs is in BTN range` is not flagged, but `on KTs 2` is flagged). **15-field strategic integrity check: 0 changes** to id/module/auditStatus/sourceConfidence/recommendedAction/actionReason/answer.*/conceptTags/handClass/heroHandRole/drawCategory/showdownValue. **Manual poker-semantic spot-check on 5 critical scenarios:** Kh Td 2s nutadv (rebuilt board, sets/two-pair/TPGK identification preserved), Kh Td 2s set scenario TcTh (set logic preserved), Kh Td 2s OE QcJc (semi-bluff logic preserved), Th 8h 3h monotone (A-X nut flush prose clean), 8s 7s 5s low monotone (5x/7x/8x readable, BB caller-crush logic preserved) — all PASS. **Browser QA via Preview MCP at mobile 375x812: 0 console errors, all 6 defective pattern categories = 0 in runtime DOM, runtime data + sample renders all clean.** appVersion + SW bumped 4.2.2D → 4.2.2E. Production audit unchanged 300/0/0 (R29 fires 0 warnings — true negative now). M2 seed audit unchanged 24/0/8. M3 seed audit unchanged 24/0/0. Scenario count unchanged 300 = 251 M1 + 49 M2 + 0 M3. New doc `docs/specs/postflop-v4.2.2E-final-text-integrity-repair.md`. **No Module 3 productionization. No strategic content / answer-key changes. No ranges.json change. No runtime UI logic change beyond version bump.**

- **Project owner notes for v4.2.2E:** Third-order correction of the v4.2.2C cleanup chain. Lesson: when the v4.2.2D R29 guard reported 0 warnings, that was a FALSE NEGATIVE — the regex set was too narrow. v4.2.2E adds the missing pattern detectors (board_collapse, rank_dash_X, rank_dash_slash) and verifies via positive/negative test suite that the guard now matches what it claims to. Future text repair sprints should ALWAYS include positive-case tests against the guard rules — a 0-warnings result is meaningful only if the guard is verified to fire on the bug class it claims to cover. R29 now has 6 patterns and 13 verified test cases.

- **Pending push (STAGED, CARD/SUIT NOTATION REPAIR)**: `v4.2.2D` — (NOTE: now historical; committed at `f53b425`. Detail kept for reference.) — Postflop Card / Suit Notation Semantic Repair. **Production text-integrity repair after v4.2.2C. No strategic content changes.** v4.2.2C eliminated visible CP874 mojibake but blanket-replaced all mojibake-character runs with em-dashes — including the runs that were originally suit symbols inside card notation prose. This left semantically broken text like "BTN with K — K — on 6 — 5 — 4 —" (was "BTN with KhKs on 6c 5c 4s") and "A — -x" (was "Ah-x"). v4.2.2D applies a context-aware repair using `scenario.board.cards` + `scenario.heroHand` arrays to reconstruct meaning. **Two-pass repair: 263 scenarios touched, 525 text-field edits.** Pass 1 replaced 6 specific patterns (rank-dash-dash-x, BTN-with-pair, On-board, suited-combo lists, sentence residuals); Pass 2 cleaned 251 trailing em-dash residuals after the rebuilt card prompts. **All 4 suspicious card-notation patterns now 0 in the data.** 186 legitimate em-dashes preserved as sentence punctuation (e.g., "K9s+, KJo+ — many cards", "They don't — sets of 5 are rare"). **15-field strategic integrity check: 0 changes** to id/module/auditStatus/sourceConfidence/recommendedAction/actionReason/answer.best/answer.acceptable/answer.bad/answer.critical/conceptTags/handClass/heroHandRole/drawCategory/showdownValue. Added new **R29 audit guard rule** to `tools/audit-postflop-ps.ps1` (warning-only) detecting the three suspicious card-notation patterns so any future regression surfaces immediately during the regular production audit. **Browser QA via Claude Preview MCP at mobile 375x812: M1 prompt now reads "On Ah Kd 5c (BTN open vs BB call, 100BB SRP), who has range advantage?", M2 prompt reads "With AhKh on As 8d 3h ...", explanation prose preserves legitimate em-dashes ("They don't — sets of 5...").** appVersion + SW bumped 4.2.2C → 4.2.2D for cache invalidation. Production audit unchanged **300/0/0** (R29 fires 0 warnings — data is clean). M2 seed audit unchanged 24/0/8. M3 seed audit unchanged 24/0/0. Scenario count unchanged (300 = 251 M1 + 49 M2 + 0 M3). New doc `docs/specs/postflop-v4.2.2D-card-suit-notation-repair.md`. **No Module 3 productionization. No strategic content / answer-key changes. ranges.json untouched (already clean from v4.2.2C).**

- **Project owner notes for v4.2.2D:** This sprint is the second-order correction of the v4.2.2C over-aggressive cleanup. Lesson learned for future data hotfixes: when replacing mojibake, distinguish between mojibake-from-em-dash (replace with em-dash) and mojibake-from-suit-symbols (replace using structured `board.cards` / `heroHand` reconstruction). The R29 audit guard now prevents this specific class of regression silently slipping into production. Also: even legitimate punctuation em-dashes can survive — the heuristic "em-dash between lowercase letters/words/digits = keep; em-dash between/after uppercase ranks A K Q J T = repair" works well for the postflop English copy. Strategy fields verified untouched via 15-field integrity check; this should be the project-owner template for any future text-only data sprint.

- **Pending push (STAGED, RUNTIME TEXT HOTFIX)**: `v4.2.2C` — (NOTE: now historical; committed at `8896504`. Detail kept for reference.) — Runtime Text Encoding / Mojibake Hotfix. **Production UX hotfix. No strategic content changes.** Cleaned 292 of 300 production scenarios + 8 ranges.json position-description lines of CP874 mojibake (em-dash `—` U+2014 round-tripped through CP874 became long Thai-character runs like `เน€เธโฌเน€เธยเธขย...`). Source data fix is durable. Added `_pfFixMojibake` runtime safety net to the M1 expandable explanation sections (Range Logic / Nut Logic / Hand Logic / Sizing Logic / Common Mistake at index.html line ~35792-35805) — defense-in-depth for any future authoring slips. **Caught and fixed a regression** introduced by the data clean: the v4.0.10 `_pfFixMojibake` was stripping isolated clean em-dashes (em-dash maps to CP874 byte 0x97 which is invalid as a leading UTF-8 byte, so decode failed and fallback emitted U+0097 C1 control); fixed by tracking original chars in parallel to the byte buffer and restoring originals on decode failure. Verified `_pfFixMojibake('Hi — there')` now round-trips identically. Fixed PWA install banner CSS to use `margin: calc(env(safe-area-inset-top, 0px) + 8px)` so it no longer crowds the iOS status bar / clock area. **appVersion + service-worker VERSION bumped 4.1.9 → 4.2.2C** for cache invalidation. **Browser QA via Claude Preview MCP at 375x812 mobile viewport: 0 console errors; 0 mojibake / 0 replacement chars in runtime DOM across 300 scenarios; 292 scenarios contain valid em-dashes; M1 explanation sections render cleanly ("They don't — sets of 5 are rare..."); install banner sits with proper inset.** Production audit unchanged **300/0/0**. M2 seed audit unchanged **24/0/8**. M3 seed audit unchanged **24/0/0**. New doc `docs/specs/postflop-v4.2.2C-runtime-text-encoding-hotfix.md`. **No Module 3 productionization. No strategic content changes. No answer keys altered.**

- **Project owner notes for v4.2.2C:** This was a user-trust hotfix that took priority over v4.2.3 migration. Three sub-defects layered: (a) source data corruption from v4.0.0 baseline authoring, (b) v4.0.10 reverser was incomplete (M1 expandable sections never wrapped), (c) reverser regression that broke clean em-dashes after the source data fix. All three resolved. The fix preserves the v4.0.10 reverser as defense-in-depth (real mojibake sequences still get reversed) while no longer corrupting clean text. v4.2.3 migration can now resume on a clean runtime.

- **Pending push (STAGED, MODULE 3 POST-COMMIT VERIFICATION)**: `v4.2.2B` — (NOTE: now historical; committed at `1ee6cc1`. Detail kept for reference.) — Module 3 Post-Commit Raw Verification + Migration Readiness Gate. **Verification + repair sprint. No production data, no runtime wiring, no version bumps.** Independently verified all v4.2.2 claims against the raw seed JSON and against architecture/schema/audit-plan/auditor cross-refs. **Found and fixed 3 defects in-place:** (1) F6.2 conceptTags `[check_raise_value, value_raise]` were stale from v4.2.0 (best was raise) and didn't match the v4.2.2 slowplay flip — fixed to `[bluff_catchers, pot_control, value_raise]` (slowplay lesson primary; value_raise tertiary for the acceptable raise option); (2) F3.3 acceptable list had `protection_raise` which doesn't fit Td9d (a pure draw with no made hand to protect) — moved to `bad`; (3) **Top-level summary metadata block was stale** (reflected v4.2.0 distribution, never updated through v4.2.1's F6.1 reason flip or v4.2.2's F6.2 + slowplay_call addition + 24 reviewStatus flips) — full recompute applied + added `metadataRecomputedAt: 2026-05-06_v4.2.2B` freshness marker. **All v4.2.2 strategic claims verified correct after repair:** F1.3 critical=[semi_bluff_raise] justified by sizingLogic; F5.3 critical=[semi_bluff_raise] correct (semi_bluff is wrong reason for *calling*, blocker_raise is the raise reason); F6.2 best=call/reason=slowplay_call/explanation reframed; F5.4 range_disadvantage_fold correct (no RIO needed); F6.4 fold-with-call-acceptable correct; slowplay_call vocab consistent across 6 locations (auditor + 4 docs + JSON). **Training Volume Gate assessment:** 24 scenarios is ACCEPTABLE for planning lock and ACCEPTABLE for production migration (as planning data) but NOT ACCEPTABLE for stable runtime exposure. Per-concept primary-tag depth: only `equity_realization_oop` (8) at threshold; 6 of 7 native M3 concepts below 8-12 healthy target. Action reasons severely underrepresented: slowplay_call (1), protection_raise (1), domination_fold (1), bluff_catch (2). **Migration readiness decision: Path A — proceed with v4.2.3 migration** (24 → production data + 7 concepts to concepts.json + 2 heroHandRole values to taxonomy.json + R29-R40 to production auditor + appVersion/SW bump). **Recommended insertion: v4.2.3A data expansion sprint** between v4.2.3 (migration) and v4.2.4 (runtime wire) to bring M3 from 24 → 40+ scenarios. If v4.2.3A is skipped, v4.2.4 must label M3 as "Limited Beta · 24 scenarios" with scaled mastery. Final M3 seed audit (post-v4.2.2B): **24 / 0 hard / 0 warnings PASS clean**. Production audit unchanged **300/0/0**. M2 seed audit unchanged **24/0/8**. New doc `docs/specs/postflop-v4.2.2B-module3-postcommit-verification.md` documents per-claim verification + 3 defects + Training Volume gate + Path A migration decision.

- **Project owner notes for v4.2.2B:** The verification sprint was the right call — it caught a real "stale metadata" defect that would have propagated into v4.2.3 migration documentation. The summary block's `byActionReason` was missing `slowplay_call` entirely; if v4.2.3 had keyed off this stale summary for migration counts, the migration would have miscounted reasons. Conceptually, this sprint demonstrates: **don't trust your own previous-sprint reports against the raw data; always recompute.** F6.2 conceptTags fix is also a meaningful UX win — the runtime concept-library would have shown F6.2 under "check_raise_value" filter (wrong) instead of "bluff_catchers / pot_control" (right). The summary now carries a `metadataRecomputedAt` freshness marker so future sprints can see at-a-glance whether it's current.

- **Pending push (STAGED, MODULE 3 FINAL LOCK)**: `v4.2.2` — Module 3 Final Strategic Review + Planning Commit Lock. (NOTE: this entry is now historical; v4.2.2 was committed at `14bbd82`. Detail kept for reference.) **Planning-only sprint. No production data, no runtime wiring, no version bumps.** Second strategic pass over the 24 v4.2.1-reviewed M3 seeds. **Result: 22 FINAL_PASS + 2 FINAL_WARN + 0 BLOCKED.** All 24 seeds flipped from `reviewStatus: v4.2.0_seed_reviewed → v4.2.0_final`. **3 second-pass changes:** (1) F1.3 critical=[semi_bluff_raise] re-added (UN-soften — solver mix to raise is ~3-5%, near-zero, critical was justified); (2) F5.3 critical=[semi_bluff_raise] re-added (UN-soften — picking semi_bluff_raise as the reason for *calling* is genuinely confused; the raise reason here is blocker_raise); (3) F6.2 FLIPPED best=call (was check_raise_small) with reason=slowplay_call (re-introduced from pruned vocab). F6.2 flip teaches the paired-board exception: 5 of 6 board families had raise as best for nutted-value, creating an "always raise nuts OOP" anti-pattern; F6.2 now teaches "slowplay disguised nuts on paired boards because villain's c-bet range is air-heavy and raising folds out the bluffs." **Vocabulary expansion:** `slowplay_call` re-introduced to the M3 reason set (8 → 9 reasons). Updated `tools/audit-postflop-module3-seed.ps1` $validReasons; updated `postflop-v4.2.0-module3-architecture.md` §6, `postflop-v4.2.0-module3-schema-taxonomy.md` §5, and `postflop-v4.2.0-module3-audit-plan.md` rules M3-R19/M3-R20 to include slowplay_call. **6 follow-up notes from v4.2.1 resolved:** Note 1 (F5.4 RIO reason) REJECTED — 65o on monotone has no equity to be RIO against; Note 2 (F6.2 best-action) APPLIED NOW (see above); Notes 3+4+6 DEFERRED to v4.2.3/v4.2.4 migration; Note 5 (RIO reintroduction) REJECTED — duplicate of Note 1. **Re-evaluated 7 v4.2.1 refinements** with UN-soften lens: 5 held up, 2 un-softened (F1.3, F5.3 above). Other 5 (F2.3, F3.3, F5.2, F6.1, F6.4) confirmed correct. **Training Quality + Volume Principle assessment:** Accuracy strong (92% FINAL_PASS), but learning coverage BELOW depth target (6 of 7 native concepts <8 primary-tag matches; pot_odds_defense has zero seeds), question count BELOW playable-beta minimum (24 < 40-60), and expansion verdict is **C. major data sprint** required — suggested v4.3.x roadmap to bring M3 to 100+ scenarios. **Honest disclosure planning:** v4.2.4 must label M3 as "BETA · 24 scenarios" and avoid promising mastery at this depth. New doc `docs/specs/postflop-v4.2.2-module3-final-review.md` documents per-scenario sign-off + 6 follow-up resolutions + UN-soften reasoning + Training Quality assessment + v4.3.x expansion roadmap. **No production files touched.** Production audit unchanged **300/0/0**. M2 seed audit unchanged **24/0/8**. M3 seed audit (post-v4.2.2) **24/0/0 PASS clean**.

- **Project owner notes for v4.2.2:** Discipline win — UN-softened 2 of the 7 v4.2.1 refinements rather than blanket-accepting them. The seed auditor's M3-R31 `critical ⊆ bad` rule was a real find in v4.2.1; this sprint's UN-soften decisions show the author was willing to be self-critical. Vocabulary expansion (slowplay_call) was the right call for F6.2 because forcing the F6.2 lesson into bluff_catch or value_raise would have created semantic confusion. The Training Quality assessment is honest: 24 scenarios is a SEED set, not a stable module, and the v4.3.x expansion plan is concrete (path to 100+ scenarios over ~5-8 sprints).

- **Pending push (STAGED, MODULE 3 SEED AUDITOR + STRATEGIC REVIEW)**: `v4.2.1` — Module 3 Seed Auditor + Initial Strategic Review. **Planning-only sprint. No production data, no runtime wiring, no version bumps.** Implemented `tools/audit-postflop-module3-seed.ps1` (Option A: new script, ~440 LOC) instead of extending M2 auditor — M3's vocabulary differs in 4+ places (villainAction/villainSizing fields, 5-action decision set, 8-reason set, 2 new heroHandRole values). M3 seed auditor enforces all 38 hard rules + 7 soft warnings from `postflop-v4.2.0-module3-audit-plan.md`. **First run: 13 hard errors caught** — 13 scenarios had `answer.critical` values not in `answer.bad`, violating M3-R31 (`critical ⊆ bad`). The v4.2.0 author had treated `bad` and `critical` as disjoint sets; the schema rule requires critical to be a subset of bad. **Fix:** added each critical value to bad (13 batch updates). Re-audit clean. **Strategic review of 24/24 scenarios via the per-scenario prompts in `postflop-v4.2.0-module3-gpt-review-package.md`: 17 PASS / 7 WARN / 0 FAIL.** All 7 WARNs addressed in-place: F1.3 + F2.3 + F5.3 critical [`semi_bluff_raise`] removed (mixed strategy possible); F3.3 acceptable += equity_realization_call; F5.2 acceptable += call (slowplay nut flush); F6.1 actionReason equity_realization_call → bluff_catch (more specific); F6.4 acceptable += call (BDFD + overcards may have call frequency). All 24 scenarios flipped from `reviewStatus: v4.2.0_seed_candidate → v4.2.0_seed_reviewed`. Final M3 seed audit: **24 / 0 hard / 0 warnings = PASS clean**. New doc `docs/specs/postflop-v4.2.1-module3-seed-review.md` documents per-scenario verdict + applied fixes + 6 follow-up notes for v4.2.2 / v4.2.3. **No production files touched.** `postflop/postflop_scenarios.json`, `postflop/postflop_concepts.json`, `postflop/postflop_taxonomy.json`, `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`, `tools/audit-postflop-ps.ps1`, `tools/audit-postflop-module2-seed.ps1`, `index.html`, `service-worker.js`, `manifest.json`, `ranges.json`, all preflop and gamification systems all untouched. Production audit unchanged **300/0/0**. M2 seed audit unchanged **24/0/8**.

- **Project owner notes for v4.2.1:** Mechanical defect was a real find — the v4.2.0 seeds had a partition-vs-flag confusion that the auditor caught immediately. Strategic refinements stayed disciplined: only downgraded `critical` flags where the v4.2.0 author had explicitly pre-flagged solver-mix concerns. Did not blanket-soften `critical` flags on the "stubborn call" folds (F1.4 JTo on dry A-high, F3.4 AKo on low connected, F5.4 65o on monotone) because the over-bluff leak there is real. Kept the auditor focused on schema-and-vocabulary validation rather than re-implementing strategic correctness checks (which is what the strategic review pass is for).

- **Pending push (STAGED, MODULE 3 PLANNING-ONLY)**: `v4.2.0` — Module 3 (BB Defense vs BTN C-bet OOP) Architecture + Seed Plan. (NOTE: this entry is now historical; v4.2.0 was committed at `515a3c1`. Detail kept for reference.) **Planning-only sprint. No production data, no runtime wiring, no version bumps.** Five new docs in `docs/specs/postflop-v4.2.0-module3-*`: (1) `architecture.md` — module purpose, curriculum position, spot assumptions (NLH MTT, 100BB, BTN open 2.5x, BB call, flop, BTN c-bets ~33% pot), player roles, 5-action decision set (fold / call / check_raise_small / check_raise_big / mixed), 8-reason set (trimmed from 11 candidates to those actually used by 24 seeds), relationship to M1/M2, runtime implications for v4.2.4, 8 known risks, open decisions; (2) `schema-taxonomy.md` — full JSON schema (mirrors M2 v4.1.2 with 3 additions: villainAction, villainSizing, optional defenseLogic), required fields, action+reason vocabularies, reused handClass/drawCategory/showdownValue from M2, 7 planned M3 concept tags (planned only — NOT added to postflop_concepts.json in v4.2.0); (3) `seed-scenarios.json` — exactly 24 planning-only scenarios across 6 board families (Dry A-high As 8d 3h, Dry K-high Kh 9c 4s, Low connected 8s 7d 5h, Two-tone broadway Qh Jh 6c, Monotone Jh 8h 4h, Paired Kc Kd 7s) × 4 hands each, 18 action_choice + 6 reason_choice, distribution: 6 calls + 5 check_raise_small + 1 check_raise_big + 6 folds + 6 reason_choice answers. All seeds use auditStatus=planning_only, reviewStatus=v4.2.0_seed_candidate, sourceConfidence=expert_judgment. JSON parses cleanly; counts validated; no card collisions; (4) `audit-plan.md` — 38 hard rules + 7 soft warnings across 12 categories (mechanical, collision, texture, spot, action, reason, vocabulary, answer-consistency, explanation, concept tags, sourceConfidence honesty, coverage), planned for v4.2.1 implementation as either `tools/audit-postflop-module3-seed.ps1` or extension of M2 seed auditor with `-Module 3` switch; production rules R29-R40 forward-planned for v4.2.3 migration; (5) `gpt-review-package.md` — per-scenario review entries (24) with 6-dimension review prompt template and risk flags (~12 PASS expected, ~10 WARN expected, 0 FAIL expected). **No production files touched.** No scenarios added to `postflop/postflop_scenarios.json`. No runtime helpers added to `index.html`. No service-worker bump. No appVersion bump. Production audit still **300/0/0**. M2 seed audit still **24/0/8**.

- **Project owner notes for v4.2.0:** One scope decision made and documented in architecture §3 — villain c-bet sizing for v4.2.0 seeds = `bet_small` only (~33% pot). Rationale: matches M2's most common c-bet size, foundational defense skill (~25% equity / MDF ~67%), `bet_big` defense reserved for v4.3.x. Reason set was trimmed from the brief's 11 candidates to 8 actually used by the 24 seeds (omitted: pot_odds_call, reverse_implied_odds_fold, slowplay_call) — explicitly reversible if v4.2.4 player data shows they are needed.

- **Service worker `VERSION`**: `'v4.2.5'` (bumped in v4.2.5 for cache invalidation after Module 3 UX polish + critical-flag review).
- **App backup `appVersion`**: `'4.2.5'`.

- **Previous v4.1.6 detail (kept)**: Concept Library Module 2 Bridge (Path A preview-only).
- **Previous v4.1.7 detail (kept)**: Module 2 Curriculum Playable Beta.
- **Previous v4.1.8 detail (kept)**: Home Mode Tabs + Module 2 Mastery + Concept-Pool Depth Audit.
- **Previous v4.1.9 detail (kept)**: Module 2 Data Expansion (35 → 49) + Tester Pass. 14 new M2 scenarios. Per-concept primary-tag depth target hit (8/8/8/8/11). Production audit raised 286/0/0 → 300/0/0. Browser QA 30/30 PASS. appVersion + SW bumped to v4.1.9. Adds prominent **Home mode tabs** (Preflop/Postflop entry tiles) at the top of Home — Preflop tile calls `switchTab('drill')`, Postflop tile smooth-scrolls to the Postflop Beta Lab section (or routes to Settings if Postflop Beta is off). Adds **Module 2 mastery checklist** parallel to M1 (5 criteria evaluated against M2-only sessions: 5 sessions / 80%+ in 3 / no critical in latest / weak-review used / all 5 M2 concepts seen) inside the Postflop Academy panel below M1 mastery. Adds **Module 2 session summary aggregation** (`_pfM2RenderSessionAggregations`) that groups answers by `handClass` and `actionReason` to surface "weak hand classes", "weak action reasons", and an "action reason coverage" overview — injected between the existing learning summary and concept rows in `renderPostflopComplete` (M1 sessions get empty string, no regression). Documented **M2 concept-pool depth audit** showing primary-tag matches per concept (value_betting=5, pot_control=6, blocker_pressure=4, give_up_strategy=6, range_advantage_stab=5) with v4.1.9 expansion recommendation (+14 scenarios across 5 concepts). New CSS namespaced under `.home-mode-tabs*`, `.pf-mastery-section-m2`, `.pf-m2-aggr-section`. Mobile 1-column stack for tabs at ≤480px. Browser QA: 32/32 PASS (Home tabs render + click correctly, M2 mastery renders 5 items, M2 aggregation renders 3 blocks, M1/M2 normal+concept drills regression-clean, preflop unaffected, mobile 375px no overflow, console 0 errors). Production audit unchanged 286/0/0. M2 seed audit unchanged 24/0/8. **appVersion bumped 4.1.7 → 4.1.8, service-worker VERSION bumped v4.1.7 → v4.1.8.** No scenario data changes. New `docs/specs/postflop-v4.1.8-home-tabs-m2-mastery-depth.md` documents implementation, UX rationale, depth audit, v4.1.9 next step.

- **Service worker `VERSION`**: `'v4.1.8'`.
- **App backup `appVersion`**: `'4.1.8'`.

- **Previous v4.1.6 detail (kept)**: Concept Library Module 2 Bridge (Path A preview-only).
- **Previous v4.1.7 detail (kept)**: Module 2 Curriculum Playable Beta. Players can: (1) Start Module 2 from Curriculum Map (new "▶ Start Module 2 Beta" button calling `startPostflopDrill('pf_flop_cbet_ip', 12)`); (2) Drill any of the 5 M2 concepts from Concept Library (`previewOnly: true → false`); (3) Answer `action_choice` + `reason_choice` questions with hand-aware rendering (hero hand card row + handClass / heroHandRole chips, hand-aware question prompts); (4) See M2-specific feedback via new `_pfM2TeachingFeedbackBlocksHtml` (Recommended Action chip with action label + reason, Hand Logic / Sizing Logic / Action Logic / Takeaway / Common Mistake); (5) Use M2 weak-spot review (routed to M2 pool only, no M1 contamination); (6) Finish M2 sessions with M2-aware summary (`🎯 Module 2 · Flop C-bet IP · Complete` + `Module 2 Session Summary`). Final strategic seed review: 24/24 PASS (`postflop-v4.1.7-final-gpt-review-of-seeds.md`); 24 v4.1.2 seeds flipped from `auditStatus: review_pending → approved`; runtime now loads all 286 scenarios (was 262). New `getModule2Scenarios()` helper. `startPostflopDrill` routes pool by moduleId (M1=15-q default, M2=12-q default). `_pfChoiceGuide` extended for action_choice + reason_choice with all enum values. `_pfBuildQuestionPrompt` hand-aware for M2 qtypes. `renderPostflopQuestion` adds hero hand row + chips when scenario.module=='pf_flop_cbet_ip'; suppresses board-only checklist for M2. `renderPostflopAnswer` routes M2 to new teaching layer. `renderPostflopComplete` M2 module label + Drill again routes to same module. `startPostflopConceptDrill` routes pool by concept's module. `startPostflopWeakSpotReview` routes pool by previously-played module. `_PF_CURRICULUM` m2 entry: scenarioCount 11→35 + updated syllabus. New CSS (~110 lines): `.postflop-hero-card`, `.pf-m2-hand-chips`, `.pf-m2-handrole-chip`, `.pf-fb-m2-action`, `.pf-status-pill.is-beta`, `.pf-module-action-btn.is-secondary`. **Browser QA: 35/35 PASS** (M2 from curriculum + M2 concept drill + M2 weak-spot + M2 summary + M1 normal drill + M1 concept drill + preflop unaffected + mobile 375px clean + console 0 errors). Production audit unchanged 286/0/0. M2 seed audit unchanged 24/0/8. **appVersion 4.1.6 → 4.1.7, SW VERSION v4.1.6 → v4.1.7.** Two new docs: `postflop-v4.1.7-module2-playable-beta.md` (35-check QA + implementation detail), `postflop-v4.1.7-final-gpt-review-of-seeds.md` (24 PASS / 0 WARN / 0 FAIL strategic re-review).
- **Service worker `VERSION`**: `'v4.1.7'`.
- **App backup `appVersion`**: `'4.1.7'`.

- **Previous v4.1.6 detail (kept)**: Concept Library Module 2 Bridge. **Path A (preview-only) chosen.** Runtime UI patch only. `_PF_CONCEPT_LIBRARY` extended with 5 Module 2 concepts (`value_betting`, `pot_control`, `blocker_pressure`, `give_up_strategy`, `range_advantage_stab`) each carrying `module: 'm2'` + `previewOnly: true`. `_pfConceptLibraryHtml` rewritten to render Module 1 / Module 2 grouped sections with bottom-bordered headers. Module 2 cards display orange-tinted "trained in Module 2" tag + "🔒 Coming in Module 2 Beta" lock badge instead of drill button. Defense-in-depth: `startPostflopConceptDrill` now refuses any `previewOnly` concept key with a toast. New CSS namespaced under `.pf-concept-group-header*`, `.pf-concept-card-locked`, `.pf-concept-tag-m2`, `.pf-concept-locked-badge`. **Module 2 still NOT playable from curriculum** — `startPostflopDrill('pf_flop_cbet_ip', ...)` not called anywhere; M2 curriculum card stays "📖 Preview syllabus". 24 v4.1.2 seeds in production JSON remain `auditStatus: review_pending` (filtered out by runtime loader; 262 scenarios actually load = 251 M1 + 11 migrated baseline). Browser QA: 25/25 PASS — M1 concept drill works (queue=12, all M1), M2 concept drill refused, preflop drill works (queue=15), curriculum unchanged, mobile 375px clean (no overflow, locked badge 247px, M2 card 269px), console 0 errors. Production audit unchanged at 286/0/0. Module 2 seed audit unchanged at 24/0 hard errors / 8 warnings. **appVersion bumped 4.1.1 → 4.1.6, service-worker VERSION bumped v4.1.1 → v4.1.6.** No scenario data changes. New `docs/specs/postflop-v4.1.6-concept-library-module2-bridge.md` documents Path A choice, UI behavior, runtime limitations, v4.1.7 next step.

- **Service worker `VERSION`**: `'v4.1.6'`.
- **App backup `appVersion`**: `'4.1.6'`.

- **Previous v4.1.5 detail (kept)**: Production audit gate raised from 262/0/0 to 286/0/0. Six file changes: (1) `docs/specs/postflop-v4.1.2-module2-seed-scenarios.json` — 4 cleanup edits applied (3 `backdoor_only` relabels on #4/#8/#18 + #20 question prompt reworded for trap-value clarity); (2) `docs/specs/postflop-v4.1.2-module2-schema-taxonomy.md` — extended `underpair` definition with paired-board exception; documented optional `actionLogic` field for reason_choice; (3) `postflop/postflop_concepts.json` — added 5 new Module 2 concept entries: `value_betting`, `pot_control`, `blocker_pressure`, `give_up_strategy`, `range_advantage_stab` (category `module2`); (4) `postflop/postflop_scenarios.json` — 11 baseline scenarios migrated to v4.1.2 schema (renamed `bet_33→bet_small`, `bet_75→bet_big`, populated `heroHandRole`/`drawCategory`/`showdownValue`/`recommendedAction`/`actionReason`/`blockerNote`/`explanation.takeaway`) + 24 v4.1.2 seeds appended (with version bumped to 1.0.0). One real card-collision bug discovered + fixed (`_action_AhKc` → `_action_AsKc` because original baseline had `Ah` on board AND in heroHand). Plus 2 mechanical handClass corrections caught during migration: `_action_76s` (no_pair_no_draw → backdoor_only) and `_action_QJs` (gutshot → oesd). Total Module 2 production scenarios: **35** (11 migrated + 24 seeds). Distinct boards: 12 (no overlap). (5) `tools/audit-postflop-ps.ps1` — extended with R18-R28 enforcing v4.1.2 Module 2 rules on `module === 'pf_flop_cbet_ip'` scenarios (required fields, spot assumption, hero card collision, choice id sets, vocabulary, recommendedAction/actionReason consistency, explanation completeness, suit-count discipline, sourceConfidence honesty). Soft warnings deliberately excluded from production auditor (kept in seed auditor only). (6) `docs/specs/postflop-v4.1.5-baseline-migration-review.md` — NEW, documents 11 PASS / 0 WARN / 0 FAIL on migrated baseline + the 3 fixes. Plus appended **v4.1.5 Migration Addendum** in `postflop-v4.1.2-module2-gpt-review-package.md`. **Module 2 STILL NOT PLAYABLE** — runtime not wired. `index.html`, `service-worker.js`, `manifest.json`, `ranges.json`, all preflop systems, gamification systems all untouched. No appVersion bump. No service-worker VERSION bump. Module 2 seed audit reduced from 11 warnings to 8 after seed cleanup. Production audit: 286 / 0 / 0 (251 Module 1 + 35 Module 2).
- **(Pre-v4.1.8 reference, superseded above)** Pre-v4.1.6: SW `VERSION` was `'v4.1.1'`, `appVersion` was `'4.1.1'`. v4.1.6 bumped both to v4.1.6. v4.1.7 bumped to v4.1.7. v4.1.8 bumps to v4.1.8.

---

## 2. Current App Summary

The shipped app (`v3.8.2`) is a single-file PWA poker training tool focused on **MTT preflop** decisions. Capabilities:

- **Preflop drill engine** — quick / deep / weakness / challenge / overall_exam / marginal modes
- **Boss tests** + **Overall exams** + **Mission system** + **Challenges**
- **XP / Chips / Levels / Rank progression**
- **Wardrobe** cosmetic system (trainer character outfit)
- **Boss / Achievement / Rank / Source rewards** with reveal ceremonies
- **Collection Book** (long-term cosmetic progression with milestone rewards — v3.7.0)
- **Answer FX** + **Field FX** (per-pack themed atmosphere across drill flow — v3.8.0–v3.8.2)
- **Aura system** (cosmetic effect rendered around trainer character — v3.6.0)
- **SRS** (spaced repetition per hand) + **stats breakdown**
- **Settings** (FX intensity, reduced motion, exports/imports)

**Not yet built**:
- ❌ Post-flop training (in planning — see Active Epic).
- ❌ ICM-aware ranges.
- ❌ Multi-language UI.
- ❌ Cloud sync / accounts.

---

## 3. Current Active Epic

**v4.0.0 — Post-flop GTO Foundation Architecture**

A new training domain (sibling to preflop) for No Limit Hold'em MTT post-flop decisions. The first round is a **planning / data / audit package only** — no production integration in v4.0.0.

The epic is tracked in `TASK_BOARD.md`.

---

## 4. Current Execution Gate

**Round 1 (v4.0.0 planning) — what was authorized:**

1. Architecture proposal
2. Strict scenario schema
3. Board / suit / dynamic / advantage / sizing taxonomy
4. Concept taxonomy (with definitions + cross-refs)
5. 20–40 hand-authored sample scenarios
6. Audit script (17 rules) + browser audit viewer
7. Human-readable audit report
8. Risks & mitigations register

**Round 1 — what is NOT authorized:**

- ❌ Full drill engine integration in `index.html`
- ❌ Postflop boss/mission/challenge/reward integration
- ❌ Cosmetic rewards for postflop modules
- ❌ FX / Aura / Collection extensions for postflop
- ❌ Service worker version bump
- ❌ Modifying preflop ranges, scoring, SRS, or any existing reward logic

The gate stays closed until human review approves the planning package.

---

## 5. Latest Completed Work

### v4.1.0 Postflop Academy Foundation — STAGED

Evolves Postflop from a single quiz module into a structured learning academy. Per human direction: "Lay the foundation like a school. Make it robust and grow gradually."

**What was added**:
1. **Postflop Academy panel** replaces the simple Beta Lab entry card. Header with title + subtitle.
2. **Progress snapshot** — sessions completed, latest score %, latest quality pill (reuses `_pfSessionLearningLabel`), weak families from current drill state. Empty-state copy: "Start Module 1 to build your academy profile."
3. **Recommendation engine** (`_pfAcademyRecommendation`) — 6 rule-driven messages: no-history → start; latest critical → review weak; many bad → repeat Learn Mode; <5 sessions → build foundation; all 5 mastery met → Module 2 preview ready; recent strong but not all met → close to ready; default → continue.
4. **Curriculum map** (6 modules with status pills): Module 1 Active (Continue + optional Review Weak Spots buttons); Module 2 Preview (Preview syllabus toggles inline `<details>`); Module 3 Locked; Module 4-6 Future. Locked/Future cards dimmed (opacity 0.65/0.50) but still visible — "a school should show the path ahead."
5. **Module 1 mastery checklist** (5 display-only criteria): 5 sessions, 80%+ in 3 sessions, no critical leaks latest, weak-spot review engaged, foundational concepts covered. Each row shows met/not-met icon + detail string. No enforcement.
6. **Concept Library drawer** — 10 concepts (Range Advantage, Nut Advantage, Board Texture, Static vs Dynamic, C-bet Frequency, Sizing Family, Monotone, Paired, Low Connected, Two-tone). Each card has short definition + "trained in Module 1" tag.
7. **"Progress is saved locally on this device."** note pinned to the bottom. Honest copy — no implication of cloud sync.

**Helpers added** (10 + 2 declarative arrays, all `_pf*` namespaced):
`_PF_CURRICULUM`, `_PF_CONCEPT_LIBRARY`, `_pfAcademyStats`, `_pfModuleStatus`, `_pfMasteryProgress`, `_pfAcademyRecommendation`, `_pfMasteryProgressHtml`, `_pfAcademySnapshotHtml`, `_pfAcademyRecommendationHtml`, `_pfModuleCardHtml`, `_pfCurriculumMapHtml`, `_pfConceptLibraryHtml`, `_pfAcademyHomeHtml`.

All defensive against: missing localStorage, missing `App.postflop.scenarios`, malformed history JSON, missing concept tags. All output goes through `_pfEscape`.

**Live QA result** (25/25 checks pass):
- Helpers loaded; recommendation engine returns correct messages across no-history / critical / poor / mastery-met / strong-recent / default cases (6/6 paths verified)
- Beta off hides Academy; beta on shows full Academy (title, snapshot, recommendation, 6 module cards, mastery, 10 concepts, local-only note)
- Module 1 "Continue Board Texture" button starts the existing drill
- Mastery checklist updates correctly with no-history vs sample-strong-history
- Mobile 375px: academy 317px wide, no overflow, action buttons 273px tappable
- Console: 0 errors throughout
- Tab regression + preflop drill + boss UI: all working

**Files modified**: `index.html` (CSS block ~280 lines + 10 new helpers + 2 declarative arrays + edit in `renderPostflopHomeCardMount` to call new helper + appVersion 4.0.12 → 4.1.0), `service-worker.js` (VERSION v4.0.12 → v4.1.0), `PROJECT_STATE.md`, `TASK_BOARD.md`, `docs/specs/brief-v4.1.0-postflop-academy-foundation.md` (NEW).

**Untouched**: all postflop data files, audit infrastructure, generator scripts, ranges, manifest, preflop systems, scoring, cosmetics. service-worker diff is solely VERSION bump.

### v4.0.12 Postflop Drill Weak Spots Button — COMMITTED + PUSHED (`79cfc2a`)

After v4.0.11 added a "Recommended next move: replay weak spots first" line, the only available action was the existing "Drill again" button which built a fresh queue ignoring the player's mistakes. v4.0.12 closes the loop with an actual weak-spot replay flow.

**What was added**:
1. **"🎯 Drill Weak Spots" button** on the completion summary, only shown when the just-completed session has at least one bad or critical answer (`hardMisses > 0`). Amber-styled to differentiate from the standard "Drill again" button.
2. **"No weak spots detected this session."** italic note shown when no bad/critical answers — positive feedback rather than a disabled-button anti-pattern.
3. **"🎯 Review Mode · Weak Spots" badge** on the question screen during a weak-spot review session. Subcopy: "Focused on concepts and board families missed last session."
4. **Dynamic completion-screen header** when in weak-spot mode: "Board Texture Trainer · Review session complete" + "REVIEW SESSION SUMMARY".

**Helpers added** (4 pure functions, all `_pf*` namespaced):
- `_pfCurrentSessionWeakProfile(answers, scenarios)` → null OR `{mode, sourceSessionId, hardMisses, targetScenarioIds, targetConceptTags, targetFamilyKeys}`. Soft fallback when hardMisses < 2 includes acceptable answers as weak signals (weight 0.5).
- `_pfWeakScenarioScore(scenario, weakProfile, lastSessionIds)` → numeric score (+100 exact missed / +60 weak family / +40 weak concept / −30 recent repeat / +0..10 random).
- `_pfBuildWeakSpotQueue(weakProfile, allScenarios, targetLen=12)` → up to 12 scenarios, weak-prioritized then filled with general scenarios if pool too small. Always returns an array, no duplicates.
- `startPostflopWeakSpotReview()` — entry point wired to the button. Falls back to `startPostflopDrill('pf_board_texture')` when no weakness or pool empty.

**Defensive behavior**: returns null on perfect session; soft-fallback works when hardMisses=0 but acceptable answers exist; missing `conceptTags` / cleared localStorage / null `App.postflop.scenarios` all handled without crash; weak button hidden when no hard misses.

**Live QA result** (23/23 checks pass):
- Helpers loaded; weak profile derives correctly from POOR (10 hard misses → 9 target scenarios, 11 concept tags, 6 family keys), ONE-BAD (1 hard miss → 1 target + 11 fillers), ALL-ACCEPTABLE (soft fallback: 15 scenarios + 17 concepts as 0.5-weight signals)
- Queue properties verified: 12 unique scenarios; 100% family coverage on 10-bad session; 9/9 missed scenarios surfaced first
- Perfect session: weak button hidden + "No weak spots detected" note shown
- One-critical session: weak button visible
- Click weak button → `mode === 'weak_spots'`, badge appears, 12-question queue starts
- Answer → feedback → next still works; all 5 feedback blocks render in review mode
- Review summary header changes to "Review session complete" + "REVIEW SESSION SUMMARY"
- Mobile 375px: weak button 343×49px tappable; badge 343px wide, no overflow
- Console: 0 errors throughout
- Tab regression + preflop drill + boss UI + beta toggle: all working

**Files modified**: `index.html` (CSS block ~50 lines + 4 new helpers ~210 lines + Review Mode badge wire-in to `renderPostflopQuestion` + 4 edits to `renderPostflopComplete` for dynamic header/headline + weak button + empty note + appVersion 4.0.11 → 4.0.12), `service-worker.js` (VERSION v4.0.11 → v4.0.12), `PROJECT_STATE.md`, `TASK_BOARD.md`, `docs/specs/brief-v4.0.12-postflop-drill-weak-spots.md` (NEW).

**Untouched**: all postflop data files, audit infrastructure, generator scripts, ranges, manifest, preflop systems, scoring, cosmetics.

### v4.0.11 Postflop Session Learning Summary — COMMITTED + PUSHED (`a2e4fae`)

After a Module 1 session, the player should understand what they learned and what to focus on next. Prior summary screen showed score + tier counts + a flat concept-mastery list. v4.0.11 adds a learning-focused block stack between the score card and the existing details.

**New sections** (all derived from existing session data; no schema changes; no data file edits):

1. **Dynamic quality label** replaces the static "✅ Drill Complete" subtitle. Picks one of: "Clean read" / "Good pattern recognition" / "Mixed session" / "Needs review" / "High-risk leaks found" — colour-coded pill (green / blue / amber / red).
2. **Strongest concepts** green block — top 3 conceptTags by score % where seen ≥ 2 AND pct ≥ 80.
3. **Review signals** amber block — worst 3 conceptTags (lowest pct, then most bad+critical). Shows green-empty-state ("No major weak concept detected this session.") when clean.
4. **Board family pattern notes** red block — surfaces up to 3 families where misses cluster (missCount ≥ 2 OR critical ≥ 1). Each row shows the family label + miss count + one-sentence coaching lesson from an 18-entry family map (e.g., "low connected — missed 2 of 3. BB has more suited connectors and straight density.")
5. **Recommended next move** blue block — single coaching action: "Replay weak spots first..." (if critical), "Run another Learn Mode session..." (if 4+ bad/crit), "Focus on turning acceptable into best..." (if too many half-credit), "Good session..." (if 80%+ best), or "Keep going..." (default).

The existing concept-mastery details + critical-leaks details are preserved below (collapsed by default for power users).

**Helpers added** (8 pure functions, all `_pf*` namespaced):
`_pfBoardFamilyKey(board)`, `_pfBoardFamilyDisplayLabel(key)`, `_pfBoardFamilyLesson(key)`, `_pfLearnPrettyConcept(tag)`, `_pfSessionConceptSummary(answers)`, `_pfSessionBoardFamilySummary(answers, scenarios)`, `_pfSessionLearningLabel(counts, total)`, `_pfSessionNextMove(counts, total)`, `_pfRenderLearningSummary(...)`.

**Defensive fix**: legacy `conceptTally` line in `renderPostflopComplete` was crashing if an answer had no `conceptTags` (legacy localStorage). Added `(a && a.conceptTags) || []` guard. Per brief requirement #12.

**Live QA result** (20/20):
- Helpers loaded; perfect / poor / mixed session profiles all produce sensible labels + concepts + family clusters
- Mobile 375px: no horizontal overflow; summary card 343px wide
- Edge cases pass: missing conceptTags, cleared localStorage, empty answers, null `App.postflop.scenarios`
- Console: 0 errors throughout
- All 5 tabs render; preflop drill works; beta toggle hides/shows postflop

**Files modified**: `index.html` (CSS block + 8 new helper functions + 2 edits in `renderPostflopComplete` + appVersion 4.0.10 → 4.0.11), `service-worker.js` (VERSION v4.0.10 → v4.0.11), `PROJECT_STATE.md`, `TASK_BOARD.md`, `docs/specs/brief-v4.0.11-postflop-session-learning-summary.md` (NEW).

**Untouched**: all postflop data files, audit infrastructure, generator scripts, ranges, manifest, preflop systems, scoring, cosmetics.

### v4.0.10 Postflop Card Text Encoding Hotfix — COMMITTED + PUSHED (`53eae80`)

Tester reported that Postflop question text shows broken suit symbols (`Aโฅ Kโฆ 5โฃ`) while card graphics render correctly (`A♥ K♦ 5♣`). Root-cause investigation found **CP874 (Thai Windows) → UTF-8 mojibake** in the v4.0.0 baseline scenarios: original UTF-8 bytes were at some point read as CP874 then re-encoded as UTF-8, splitting each multi-byte char into 2-3 separate Thai/Latin codepoints. Affects `question.prompt` and `explanation.*` (rangeLogic / nutLogic / sizingLogic / commonMistake / short) on ~31 baseline scenarios. The 220 v4.0.7-generated scenarios are clean. `board.cards` is clean ASCII on all scenarios — that's why card graphics work.

**Fix at render time** (per instruction "do NOT change postflop data"):
1. `_pfCardText(card)` and `_pfBoardText(cards)` build clean board text from clean ASCII `board.cards` using existing `_pfSuitChar`.
2. `_pfBuildQuestionPrompt(scenario)` reconstructs the question sentence per `question.type` using `_pfBoardText`, ignoring the corrupted `question.prompt` field.
3. `_pfFixMojibake(text)` walks input char by char, mapping CP874-mojibake codepoints back to their original bytes (via reverse maps `_pfCp874ToByte` and `_pfThaiCpToByte`), then decoding accumulated bytes as UTF-8 via `TextDecoder('utf-8', {fatal:true})`. Falls back to original chars if a chunk fails to decode (so real Thai/accented text passes through unchanged).
4. `renderPostflopQuestion` now uses `_pfBuildQuestionPrompt(scenario)` instead of `scenario.question.prompt`.
5. `_pfTeachingFeedbackBlocksHtml` and `renderPostflopAnswer` wrap explanation text with `_pfFixMojibake` before `_pfEscape` (5 sites total).

**Live verification** (corrupted baseline `AhKd5c_rangeadv_001`):
- Raw data prompt: `On Aโฅ Kโฆ 5โฃ ...` (codepoints U+0E42 U+0099 U+0E05 etc.)
- Rendered prompt: `On A♥ K♦ 5♣ ...` (codepoints U+2665 U+2666 U+2663 — clean)
- Raw rangeLogic snippet: `KJo+ โ€" many cards`
- Rendered rangeLogic: `KJo+ — many cards` (em-dash U+2014)
- Card graphics still render correctly (verified `boardCardSuits = [♥, ♦, ♣]`)
- All 5 feedback blocks render
- Zero mojibake codepoints in any rendered text
- Console: 0 errors

**Audit**: 262/0/0 (data file unchanged).

**Files modified**:
- `index.html` (~80 lines new helpers + 6 render-site rewires + appVersion 4.0.9 → 4.0.10)
- `service-worker.js` (VERSION v4.0.9 → v4.0.10)
- `PROJECT_STATE.md`, `TASK_BOARD.md` (status update)
- `docs/specs/brief-v4.0.10-postflop-card-text-encoding-hotfix.md` (NEW)

**Untouched**: all postflop data files, audit infrastructure, generator scripts, ranges, manifest, preflop systems, scoring, cosmetics.

A future v4.1 cleanup pass could optionally rewrite the data file with clean UTF-8, making the render-time fix a no-op. For now the helper protects against the corruption permanently — even if the file is ever round-tripped through CP874 again.

### v4.0.9 Postflop Teaching Polish — COMMITTED + PUSHED (`c38aafc`)

Targeted polish of the v4.0.8 teaching layer based on the v4.0.8 Extended QA report (`docs/specs/postflop-v4.0.8-teaching-layer-qa-report.md`).

**Five fixes implemented**:

1. **Fix M1** (`_pfHintForBoard`): Q/J/T-high non-paired non-monotone disconnected scenarios were falling to a generic fallback hint. Added Q-high specific branch ("Ask: does BTN have more Q-x, K-x, and overpairs than BB has...") and J/T-high merged branch ("Ask: does BB have suited connectors and middle pocket pairs..."). Affects ~30 scenarios.

2. **Fix M3** (`_pfTakeawayForBoard`): Same Q/J/T-high boards had a generic takeaway. Added Q-high branch ("Q-high boards still favor BTN but the edge is smaller than A/K-high") and J/T-high branch ("J/T-high disconnected boards are closer to neutral; mixed small/check often beats range-betting"). Affects ~30-40 scenarios.

3. **Fix M4** (`_pfTakeawayForBoard`): `low_dry_two_tone` boards (e.g., 9h6h2c, 7h3h2s) were getting the rainbow takeaway "Low disconnected boards still favor BTN... small high-frequency c-bet works" — but the actual `sizing_family` answer for these boards is `mixed_small_check`. Added new branch BEFORE the rainbow rule: "Low disconnected two-tone boards can still retain BTN overpair advantage, but the flush draw makes pure range-small less automatic; mixed small/check is usually safer." Affects ~6 scenarios.

4. **Fix L1** (`_pfPatternLabel`): (a) Two-tone scenarios with `dynamicLevel >= 3` now return "X two-tone medium board" instead of misleading "X two-tone semi-dry". (b) Final fallback for rainbow non-paired non-monotone disconnected with `dyn >= 3` now returns "X semi-wet board" or "X semi-connected board" instead of the empty "X board".

5. **Fix M2 (optional, implemented)**: `_pfTeachingFeedbackBlocksHtml` rewritten to use new `_pfPickPrimaryLogic(qtype, explanation)` helper. Core Reason now shows ONLY the question-type-relevant logic strand (rangeLogic for range_advantage, nutLogic for nut_advantage, sizingLogic for frequency_strategy / sizing_family / dynamic_level). Other strands collapse into a "More logic strands" `<details>` block. Heavy multi-strand scenario went from ~200 words inline to ~80 words primary + collapsed remainder. Cuts mobile reading load roughly in half on heavy scenarios.

**Live verification results** (9 test cases):
- Q-high rainbow disconnected: now gets specific hint + specific takeaway ✓
- J-high rainbow dyn=3: pattern is "J-high semi-wet board" (was "J-high board") ✓
- T-high two-tone dyn=3: pattern is "T-high two-tone medium board" ✓
- Low two-tone disconnected: takeaway acknowledges flush draws + mixed sizing ✓
- frequency_strategy with all 3 strands: Core Reason starts "Sizing logic:" with "More logic strands" collapsed below ✓
- range_advantage scenarios: Core Reason starts "Range logic:" only ✓
- nut_advantage scenarios: Core Reason starts "Nut logic:" only ✓
- A-high dry, low connected two-tone, paired_mid: all unchanged regression ✓

**Files modified**:
- `index.html` (CSS untouched; JS edits in `_pfPatternLabel`, `_pfHintForBoard`, `_pfTakeawayForBoard`, `_pfTeachingFeedbackBlocksHtml`; new helper `_pfPickPrimaryLogic`; appVersion 4.0.8 → 4.0.9)
- `service-worker.js` (VERSION v4.0.8 → v4.0.9)
- `PROJECT_STATE.md`, `TASK_BOARD.md` (this section + status row)
- `docs/specs/brief-v4.0.9-postflop-teaching-polish.md` (planning + implementation log)
- `docs/specs/postflop-v4.0.8-teaching-layer-qa-report.md` (QA report from prior session, still untracked → staged with this commit)

**Untouched** (verified): `ranges.json`, `manifest.json`, all postflop data files, audit infrastructure, generator scripts, preflop systems, scoring, cosmetics.

**Audit**: 262 / 0 errors / 0 warnings.

### v4.0.8 Postflop Teaching Layer — COMMITTED + PUSHED (`479b775`)

Module 1 (Board Texture Trainer) UI patch. After v4.0.7 expanded the scenario pool to 251, human tester reported: *"I can play it now, but I do not understand the principles behind the answers."* The app was asking questions but not teaching the underlying board-reading framework.

**Five teaching components added** (all in `index.html`, additive in a fenced v4.0.8 CSS + JS block):

1. **Pattern Label** — short header above each board (e.g. "🎯 J-high two-tone semi-dry") with meta-line ("two_tone · disconnected · semi-static"). Derived from `board.highCardClass`, `board.suitTexture`, `board.textureTags`, `board.pairedStatus`, `board.dynamicLevel` via `_pfPatternLabel(board)`. Reads field values only — no schema changes.
2. **Board Reading Checklist** — collapsible 7-item educational framework (high card / texture / connectivity / suit / range adv / nut adv / sizing implication). Same for every scenario; teaches the reading PROCESS rather than the answer.
3. **Pre-answer Hint** — "💭 Need a hint?" button reveals a non-spoiler thinking-prompt based on board family (e.g. "Ask: does BB have BOTH straight density AND flush-draw density?"). Verified to never directly state the answer.
4. **5-block Feedback Layout** — `renderPostflopAnswer` restructured into Result / Board Pattern / Core Reason / 💡 Takeaway / ⚠️ Common Mistake. Replaces the previous separate `<details>` per logic strand — same content surfaced more readably without extra clicks.
5. **Takeaway Generator** — `_pfTakeawayForBoard(board)` produces a one-sentence generalizable lesson per board family (e.g. "Low connected two-tone boards are dangerous for BTN: BB has straight density AND flush-draw density combined.").

Plus a small "LEARN MODE · EXPLANATIONS ENABLED" mode tag pill. Full Test Mode (toggle to hide hints/explanations) deferred to v4.0.9 if needed.

**Helpers added** (8 pure functions, all `_pf*` namespaced):
`_pfPatternLabel`, `_pfBoardMetaLine`, `_pfHintForBoard`, `_pfTakeawayForBoard`, `_pfBoardChecklistHtml`, `_pfPatternLabelHtml`, `_pfHintRowHtml`, `_pfTeachingToggleHint`, `_pfTeachingFeedbackBlocksHtml`.

**Live QA result**:
- ✅ Postflop audit 262/0/0 (data unchanged)
- ✅ Module 1 loads 251 scenarios; all 8 helpers resolve to functions
- ✅ Pattern + hint + takeaway match correctly across 5 sample board families (A-high dry, low connected two-tone, low monotone, paired mid, broadway connected)
- ✅ Beta OFF: postflop screen hidden, no Beta Lab section
- ✅ Beta ON: question screen shows pattern label, checklist, hint button, mode tag
- ✅ Hint toggle open/close; verified no answer leak
- ✅ Choice click → 5-block feedback renders with correct content per scenario
- ✅ Mobile 375px: no horizontal overflow; all teaching elements render cleanly
- ✅ All 5 tabs render
- ✅ Console: 0 errors

**Files modified**: `index.html` (CSS + JS additive block + 2 render-fn modifications + appVersion 4.0.6→4.0.8), `service-worker.js` (VERSION v4.0.7→v4.0.8), `PROJECT_STATE.md`, `TASK_BOARD.md`, `docs/specs/brief-v4.0.8-postflop-teaching-layer.md` (NEW).

**Untouched**: `ranges.json`, `manifest.json`, all postflop data files, audit infrastructure, generator scripts, preflop systems, scoring, cosmetics.

### v4.0.7 Module 1 Scenario Expansion — COMMITTED + PUSHED (`1f5fe99`)

Third pass on the largest data sprint to date. Corrects GPT-flagged template overgeneralization in the generic `two_tone` family.

**Template-correction summary**:
- Split `two_tone` family into 5 sub-families based on rank-class + connectedness (`high_two_tone_dry`, `mid_two_tone_dry`, `broadway_two_tone_connected`, `low_dry_two_tone`, `low_connected_two_tone`)
- Each board re-classified into the right sub-family by `ClassifyTwoTone()` in the generator
- Fixed `paired_mid` wording: "set combos for the paired rank" → "trips combos with the paired rank" (technically correct since you can't have a "set" of an already-paired board card)
- All 9 GPT-named samples re-verified (5 fixed answers, 1 wording fix only, 3 kept with documented reasoning)
- Module 1 grew from 243 → **251 scenarios** as a side-effect of bumping plan to use more two-tone boards
- **Micro-fix pass (final)**: monotone_low nut wording corrected ("essentially zero nut combos" → acknowledges Axs nut-flush combos); paired_mid + monotone_low + similar solver-sensitive families now have `preflop_raiser`/`caller` opposite as `bad` not `critical` for nut_advantage; `neutral` added to acceptable for nut_advantage on those families
- See `docs/specs/postflop-v4.0.7-template-correction-report.md` for full reasoning

**Final canonical counts (template-correction + micro-fix)**:
- Module 1 scenarios: **251**
- Module 2 scenarios (unchanged): **11**
- Total postflop scenarios: **262**
- Audit: **0 errors / 0 warnings**
- sourceConfidence: 133 `consensus_gto` / 118 `expert_judgment` / 0 `solver_verified` / 0 `needs_review`
- suitTexture: 140 rainbow (55.8%) / 96 two_tone (38.2%) / 15 monotone (6%)
- difficulty: 30/100/43/55/23 across diff 1–5
- qtype: ra=58, na=57, fs=48, sf=39, dl=49

**Hardening pass summary** (second pass, intermediate — superseded by template-correction; numbers below are historical for the hardening pass only):

**Module 1 pool**: 20 → **243 scenarios** (+223 net). All 14 board family/suit combinations and all 5 question types covered.

**Hardening corrections** (vs initial v4.0.7 staging):

1. **sourceConfidence rebalanced.** Was 239 `consensus_gto` / 4 `expert_judgment` (98% overclaim). Now 97 `consensus_gto` (39.9%) / 146 `expert_judgment` (60.1%) / 0 `solver_verified` / 0 `needs_review` — all in target ranges. Per-family per-qtype confidence rules encoded in the generator: only universally-agreed reads (A/K-high dry rangeAdv, low-connected check-heavy, etc.) keep `consensus_gto`; everything else (sizing, monotone, two-tone, paired_mid, J/T_medium) honestly tagged `expert_judgment`.
2. **suitTexture rebalanced.** Was 200 rainbow (82%) / 25 two_tone (10%) / 18 monotone (7%) — too rainbow-heavy. Now 130 rainbow (53.5%) / 98 two_tone (40.3%) / 15 monotone (6.2%) — all in target ranges. ~75 new two-tone boards added across all families (genuine new boards, not trivial card-swap duplicates of rainbow). Rainbow plan trimmed to keep total Module 1 ~240.
3. **Generator tooling tracked.** Was `.gen-postflop.ps1` + `.audit-postflop.ps1` at repo root (gitignored). Now `tools/generate-postflop-module1.ps1` + `tools/audit-postflop-ps.ps1` (tracked, documented, deterministic, idempotent — re-runs strip + replace `*_v407` ids; baseline preserved).
4. **GPT review package expanded.** Was 20 samples, no risk breakdown. Now 30 samples (5 easy + 10 medium + 10 hard + 5 highest-risk) with coverage requirements (≥5 rainbow, ≥10 two-tone, ≥5 monotone, ≥5 paired, ≥5 very-wet/connected) and dedicated "Scenarios most likely to be disputed by strong players" section calling out 5 named risk categories.

**Audit result**: 0 errors / 0 warnings across all 254 total postflop scenarios. Zero board-card duplicates. Zero (board, qtype) duplicates.

**[HARDENING PASS HISTORICAL]** Distribution at end of hardening pass (Module 1 = 243; superseded by template-correction final = 251):
- qtype: ra=49, na=47, fs=53, sf=49, dl=45 (all 45-53)
- diff: 27/84/59/58/15 across 1-5
- suitTexture: rainbow 130 (53.5%) / two_tone 98 (40.3%) / monotone 15 (6.2%)
- sourceConfidence: consensus_gto 97 / expert_judgment 146 / solver_verified 0 / needs_review 0
- All `auditStatus="approved"`

**[HARDENING PASS HISTORICAL] Files modified at end of hardening pass** (final stage list above is canonical):
- `postflop/postflop_scenarios.json` (+223 scenarios at end of hardening; 31 → 254)
- `service-worker.js` (`v4.0.6` → `v4.0.7`)
- `tools/generate-postflop-module1.ps1` (NEW, tracked)
- `tools/audit-postflop-ps.ps1` (NEW, tracked)
- `docs/specs/postflop-v4.0.7-scenario-expansion-report.md` (NEW, hardened)
- `docs/specs/postflop-v4.0.7-gpt-review-package.md` (NEW, 30 samples)
- `PROJECT_STATE.md`, `TASK_BOARD.md` (this section + status row)

**Untouched** (verified): `index.html`, `ranges.json`, `manifest.json`, `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`, `tools/audit-postflop.js`.

**Discovered work (tracked in TASK_BOARD)**:
- `polar_big_strategy` concept tag has only 1 scenario (concept naturally surfaces on turn/river → reserved for v4.1)
- Difficulty diff-5 only 15 scenarios (target 20) — bumping more would inflate honesty
- 5 highest-risk categories enumerated for GPT review attention

### v4.0.6 Postflop Repeat Control + Local Session History — STAGED

Tester reported postflop questions felt repetitive after ~3 sessions. Module 1 has 20 scenarios; sessions use 15. Pure Fisher-Yates random meant ~75% overlap between back-to-back sessions on average.

**Implementation** (all in `index.html`, additive in a new v4.0.6 fenced block + 4 in-place edits to v4.0.2 functions):

1. **Local history schema** in `localStorage.rmtt_postflop_history`:
   - `scenarios[scenarioId]` — attempts, per-tier counts, totalScore, lastTier, lastScore, lastSeenAt, lastSessionId
   - `concepts[conceptTag]` — same shape, aggregated per tag
   - `sessions[]` — capped to most recent 50 sessions (id, date, module, scenarioIds, score, tier counts)
   - Defensive load with shape recovery; defensive save with try/catch
2. **`recordPostflopAnswer` hook** — calls `_pfHistoryRecordAnswer(scenario, cls)` after the in-memory record. Best-effort; never throws.
3. **`renderPostflopComplete` hook** — calls `_pfHistoryRecordSession({module, queue, answers, totalScore, counts})` to save the compact session summary.
4. **History-aware `buildPostflopQueue`**: scores each candidate (`+100` if never seen, `+30` if not in last session, `+10` if attempts<3, `-50` if in last session, `-attempts*3`, `+random*20`); sorts and slices. Result: back-to-back overlap reduced to **theoretical minimum** (10/15 with pool=20, sessionLength=15).
5. **`App.postflopHistorySummary()`** — dev console helper returns scenarios tracked, concepts tracked, sessions count, top 5 most-seen, last session ids.
6. **"Progress is saved locally on this device."** — honest copy on the home card; no overclaim about sync/cloud/account.

**QA verified** (live local server):
- ✅ Audit 31/0/0
- ✅ Within-session: zero duplicates (`new Set(queue.ids).size === 15`)
- ✅ Back-to-back overlap: 10/15 (67%) = theoretical minimum, ~12% better than pure-random expected ~11.25
- ✅ History persists in localStorage
- ✅ History tracking: 15 scenarios + 17 concepts + 1 session after a single completed run
- ✅ Beta toggle off→hides UI, on→UI back
- ✅ All 5 tabs render
- ✅ Preflop drill 5 hands all classified correctly + preflop SRS storage grew (independent of postflop history)
- ✅ Postflop history + preflop progress in separate localStorage keys (no collision)
- ✅ Console clean

**Files modified**: `index.html` (+218 / -10), `service-worker.js` (VERSION bump only). Postflop data files + audit infrastructure all 0-diff.

### v4.0.5 GTO Data Validation Pass — committed (`87c741e`) + pushed

Walked all 20 Module 1 Board Texture Trainer scenarios with GTO scrutiny. Findings published in `docs/specs/postflop-v4.0.5-gto-validation-report.md` and `docs/specs/postflop-v4.0.5-data-patch-plan.md`.

**Verdict tally**:
- 17 KEEP (no change)
- 2 KEEP-with-caveat (#11 Th8h3h_nutadv monotone, #20 7d7s3c_rangeadv paired-low — both already at expert_judgment + difficulty 3-4; honest hedging acceptable)
- 1 DOWNGRADE (#14 Qd9c4h_rangeadv — proposed sourceConfidence: consensus_gto → expert_judgment)
- 0 REVISE answer keys
- 0 HOLD from production

**Net production-ready**: 20 / 20 scenarios remain shippable. The proposed edit is a metadata honesty tag with zero player-visible impact.

**Audit re-confirmed**: 31 scenarios · 0 errors · 0 warnings (no data files touched in this pass).

### v4.0.4 Critical Hotfix — committed (`519df53`) + pushed

Real-play feedback after v4.0.3: tester reported answer buttons unresponsive on BOTH desktop and mobile, AND Choice Guide invisible on mobile.

**Root cause** (introduced in v4.0.2, not caught in v4.0.2 or v4.0.3 QA): the inline `onclick="handlePostflopChoice(' + JSON.stringify(ch.id) + ')"` had a quote conflict — `JSON.stringify("range_small")` returns `"range_small"` with double quotes, embedded into double-quoted onclick attribute, breaking HTML parsing. The browser truncated `onclick` to `handlePostflopChoice(` (just the partial stub) and parsed the rest as garbage attributes. **Real clicks never fired the handler.** My v4.0.2 and v4.0.3 QA passed because I called `handlePostflopChoice(bestId)` directly via JS, bypassing the broken onclick path. The bug was invisible to my automated tests and only surfaced in human real-play.

**Fixes applied**:
1. **Delegated event listener** on `#postflopScreen` (one handler for all clicks; reads `dataset.choiceId` from nearest `.postflop-choice-btn` ancestor of click target). Survives re-renders since it's attached to the persistent screen element. Idempotent re-installation via `_pfInstallDelegatedClickListener()` called on boot AND on every `showPostflopScreen()`.
2. **Renamed handler** to `handlePostflopChoiceById(choiceId, btn)` — accepts optional button reference for instant pressed state. Backward-compat alias `handlePostflopChoice(choiceId)` retained.
3. **Choice Guide v2** — always-visible 1-line summary block (`.postflop-choice-guide-v2 .pf-guide-summary-line`) above choice buttons; expandable `<details>` for per-choice breakdown below. Replaces v4.0.3's collapsed-by-default `<details>` that mobile users didn't see.
4. **Touch reliability**: `touch-action: manipulation` (eliminates iOS 300ms tap delay), `position: relative; z-index: 1` on `.postflop-choices` and `.postflop-choice-btn` (prevents decorative canvas layers from intercepting taps), `-webkit-tap-highlight-color`, `user-select: none`.
5. **Reinforced FX suppression**: `body[data-postflop-active="true"]` now hides `.field-fx-canvas`, `.answer-fx-canvas`, `.aura-canvas` AND sets `pointer-events: none` on them.
6. **Fail-safe error fallback**: try/catch around classify+record+render. If render fails, `_pfShowAnswerError()` shows inline red banner ("Could not process answer. Tap again."), re-enables buttons, restores `phase = 'question'` so user can retry.

**Files modified**: `index.html` (+225 lines / -37, all inside existing v4.0.2/v4.0.3 fenced blocks), `service-worker.js` (VERSION bump).

**Audit re-confirmed**: 31/0/0 (no data files touched).

### v4.0.3 Implementation — committed (`25fb45e`) + pushed

Real-play hotfix per human tester feedback. Fixes 4 issues:

| # | Issue | Fix |
|---|---|---|
| 1 | Loading feels slow | Loader (`loadPostflopData`) now re-renders Home if user is on it AND beta is on (success and error paths). Card has 3 states: loading (spinner) / ready / error (with reload button). |
| 2 | Choice meanings unclear | New `_pfChoiceGuide(qType)` helper renders an expandable "What are we choosing?" panel above choice buttons. 5 question types × per-type explanations. |
| 3 | Buttons feel unresponsive | `handlePostflopChoice` now disables all buttons synchronously + adds `postflop-choice-pressed` class to tapped button BEFORE classify/render. Uses `requestAnimationFrame` so the pressed visual paints before the heavy innerHTML swap. New phase `'answering'` blocks rapid re-entry. |
| 4 | Home placement too low | `renderPostflopHomeCardMount` now uses `insertAdjacentHTML('afterbegin', ...)` to prepend at TOP of Home; wraps card in `.postflop-betalab-section` with "🧪 BETA LAB" header for clear beta status. |

**Files modified**: `index.html` (~250 lines added/modified across 6 surgical edits + 1 CSS block), `service-worker.js` (VERSION bump).

**Audit re-confirmed**: 31 scenarios · 0 errors · 0 warnings (no data files touched).

### v4.0.2 Postflop Module 1 (Board Texture Trainer) UI — committed (`5d21128`) + pushed

First visible postflop UI. Beta-gated via `App.state.settings.postflopBeta` (default `false`). Implementation per `docs/specs/brief-v4.0.2-implementation-ready.md`.

**Changes**:
- `index.html` (~960 lines added in single fenced v4.0.2 block + 2 one-liner appends to renderMastery/renderSettings + `appVersion` bump):
  - New `#postflopScreen` container (sibling to `#drillScreen` inside tab-drill panel)
  - CSS block for all `.postflop-*` classes (~290 lines)
  - JS block: `getPostflopReady`, `getModule1Scenarios`, `getConceptByKey`, `App.state.postflopDrill` state, `buildPostflopQueue`, `startPostflopDrill`, `classifyPostflopAnswer` (multi-tier), `recordPostflopAnswer`, `handlePostflopChoice`, `advancePostflopDrill`, `showPostflopScreen`, `exitPostflopScreen`, `confirmExitPostflop`, `renderPostflopHomeCardMount`, `renderPostflopBetaToggleMount`, `togglePostflopBeta`, `renderPostflopQuestion`, `renderPostflopAnswer`, `renderPostflopComplete`
  - Field FX suppression: `body[data-postflop-active="true"] .field-fx-canvas { display: none !important; }`
  - Wiring: 1-line defensive append in `renderMastery` wrapper (line 29279) + 1-line defensive append in `renderSettings` (line 31484)
- `service-worker.js`: VERSION `'v4.0.1'` → `'v4.0.2'`

**Live browser QA result** (29-item subset of 52-item matrix):
- ✅ Loader: ready=true, scenarios=31, schema=1.0.0, getModule1Count=20, all functions exist
- ✅ Beta default off: no postflop UI when off
- ✅ Toggle on: home card appears + Settings shows beta section
- ✅ Drill flow: question→feedback→advance→summary all render
- ✅ All 4 scoring tiers verified (best=1.0/best, acceptable=0.5/acceptable, critical=0/critical+flag, bad path also exercised)
- ✅ Multi-section feedback renders all 4 expandable sections + short explanation + concept tag pills
- ✅ Summary screen: score banner + per-tier counts + 17-row concept mastery + critical leaks list
- ✅ Preflop drill regression: 5 hands played, all classified correctly, progress key created, App.postflop untouched
- ✅ All 5 tabs render after postflop session
- ✅ Settings panel: existing FX/Aura/etc. controls intact + beta toggle appended
- ✅ Console clean: only the expected `[postflop] loaded 31/31 scenarios (schema 1.0.0)` from v4.0.1 loader; zero new errors/warnings
- ✅ Field FX suppression rule present in CSS (verified via stylesheet inspection)

**Implementation note**: One bug surfaced and was fixed in-flight — `#postflopScreen` lives inside `tab-drill` panel which gets hidden when other tabs become active. Fix: `showPostflopScreen()` now activates `tab-drill` panel + hides all OTHER drill sub-screens; `exitPostflopScreen()` returns to Home tab cleanly.

### v4.0.2-data Postflop Seed Fix — committed (`473ce9a`) + pushed

Pre-implementation data hygiene pass per `postflop-v4.0.2-scenario-review.md` findings + `brief-v4.0.2-implementation-ready.md` § 16. Three fix categories applied to `postflop/postflop_scenarios.json` only:

1. **Scenario #20** (`pf_btn_v_bb_srp_100bb_flop_7d7s3c_rangeadv_001`) — replaced the leftover authoring artifact `"Trips-7 even (both have 77 — wait, 77 impossible; ..."` in `nutLogic` with a clean GTO-facing explanation covering trips-7 distribution, impossible 77, full-house combinatorics, and overpair density.
2. **Choice label hint stripping** — removed all 14 rationale parentheticals from Module 1 answer-choice labels (e.g., `"Preflop raiser (BTN) — overpairs dominate"` → `"Preflop raiser (BTN)"`). Choices now have neutral labels; reasoning belongs in `explanation` fields.
3. **#10 `sourceConfidence` downgrade** — `Qh9d6s_freq_001` changed from `consensus_gto` → `expert_judgment` (the answer depends on solver-mix interpretation; confidence overclaim risk per scenario review B1/E3). #11 (`Th8h3h_nutadv_001`) was already `expert_judgment` — no change needed.

**Audit result**: 31 scenarios · 0 errors · 0 warnings. All 16 fixes applied; verified spot-checks confirm targets corrected.

**Files modified**: `postflop/postflop_scenarios.json` only. No other surface touched.

### v4.0.2 Planning Sprint — committed (`377c844`) + pushed

### v4.0.1 Postflop Schema Loader + Audit Gate — committed (`2593e5c`) + pushed

| Change | File | Diff |
|---|---|---|
| Loader block (POSTFLOP_SCHEMA_VERSION + App.postflop init + loadPostflopData + boot setTimeout) | `index.html` | +63 lines (one fenced v4.0.1 block) |
| `postflopBeta: false` in settings defaults (App.state) + confirmReset | `index.html` | +4 lines / -2 modified |
| `appVersion: '3.8.2'` → `'4.0.1'` | `index.html` | 1 string |
| `VERSION` bump + 3 postflop paths in STATIC_ASSETS | `service-worker.js` | +5 lines / -1 modified |

**Total**: 2 files modified; 71 insertions / 3 deletions in `index.html`; 6 insertions / 2 deletions in `service-worker.js`. All within the v4.0.1 brief scope.

**QA result**: audit re-confirmed clean (31/0/0); loader logic simulated successfully (`[postflop] loaded 31/31 scenarios (schema 1.0.0)`); production data files unchanged; postflop_audit_rules.js unchanged; preflop code paths untouched.

**Not yet done**: actual browser load + console verification of `App.postflop.ready === true` (requires a human or QA Agent with browser access).

### v4.0.0 Postflop Planning Package — committed (`7849741`) + pushed

| File | Purpose | Status |
|---|---|---|
| `postflop/ARCHITECTURE.md` | Full architecture proposal + module plan + integration map | ✅ Done |
| `postflop/postflop_schema.md` | Strict schema spec + scoring + UI plan | ✅ Done |
| `postflop/postflop_taxonomy.json` | Board / suit / dynamic / advantage / sizing enums | ✅ Done |
| `postflop/postflop_concepts.json` | 24 concepts with short + long defs + cross-refs | ✅ Done |
| `postflop/postflop_scenarios.json` | 31 audited seed scenarios (20 Module 1 + 11 Module 2) | ✅ Done |
| `postflop/postflop_audit_rules.js` | 17 audit rules as pure JS functions | ✅ Done |
| `postflop/postflop_audit.html` | Self-contained browser audit viewer | ✅ Done |
| `postflop/audit-report-sample.md` | Example audit output | ✅ Done |
| `postflop/RISKS.md` | 13 risks rated by severity + mitigations | ✅ Done |

**Audit result on the seed dataset**: `31 scenarios · 0 errors · 0 warnings · 31 approved` (after fixing 2 misuses of textureTags as conceptTags during the run).

### Recent shipped versions (latest 5)

- `v3.8.2` — Viewport-Dominant Field FX (canvas with 5 animated layers)
- `v3.8.1` — Anime Battle Field FX (intensity surge + page shake)
- `v3.8.0` — Field FX pivot + lifecycle bug fix
- `v3.7.4` — Aura Identity + Premium Hierarchy + 3 new auras
- `v3.7.3` — Anime FX + Premium Hierarchy

---

## 6. Hard Guardrails

The following surfaces require explicit per-task approval to modify. **Subagents cannot touch them on their own initiative.**

| Surface | File / Concept | Why locked |
|---|---|---|
| Preflop ranges | `ranges.json` | Source of truth for the entire preflop trainer; any change cascades through SRS and stats |
| Scoring formula | `classifyAnswer()` in `index.html` (line ~11219) | Touches every drill answer; regression risk to thousands of stored SRS entries |
| SRS state | `getSRSKey()` + `updateSRS()` in `index.html` (line ~12584) | Player-progress data; backward compat critical |
| Cooldowns | Boss-fail cooldowns in `index.html` (line ~28405) | Anti-grind rule that gates progression |
| Rank progression | Rank/Level XP curves | Player progression curve already tuned |
| Chips formula | Chip grant logic in `index.html` (~line 12267 area) | Economy balance |
| Existing reward grant | `_grantCosmeticByKey()` and surrounding hooks | Cosmetic ownership integrity |
| Cosmetic ownership | `App.state.profile.owned*` arrays | Player inventory; corruption is irreversible |
| Production UI shell | `index.html`, `service-worker.js` | Single-file PWA; one bad edit breaks the live deploy |
| Manifest / PWA | `manifest.json`, icon files | PWA install behavior |

**Rule**: any task touching the above must explicitly cite the surface in its scope and pass through Orchestrator before a subagent edits it.

---

## 7. File Ownership Rules

- Every subagent has an explicit **allowed file pattern** (declared in `AGENTS.md`).
- A subagent that needs to edit a file outside its pattern must **stop and request Orchestrator escalation**.
- **No subagent except DEV Integration Agent may edit `index.html` or `service-worker.js`**, and only when Orchestrator has assigned a controlled implementation task with explicit scope.
- Multiple subagents may edit different files in parallel as long as their patterns don't overlap.
- Orchestrator is the only role that may edit `PROJECT_STATE.md`, `AGENTS.md`, `TASK_BOARD.md`.

---

## 7.5. GPT AUDIT Folder Convention (PERMANENT — added 2026-05-06 v4.2.2F, expanded)

**Two parallel artifact families** under `GPT AUDIT/` (folder is git-ignored — review artifacts, not source):

### A. Versioned data + audit snapshot — `GPT AUDIT/v{VERSION}/`

**Rule:** Every committed version that ships a sprint should have a snapshot folder under `GPT AUDIT/v{VERSION}/` containing the canonical 10 source files + per-sprint docs + audit outputs.

**Canonical 10 files** (always copied, with directory structure preserved to mirror repo layout):

1. `PROJECT_STATE.md`
2. `TASK_BOARD.md`
3. `index.html`
4. `service-worker.js`
5. `postflop/postflop_scenarios.json`
6. `postflop/postflop_concepts.json`
7. `postflop/postflop_taxonomy.json`
8. `tools/audit-postflop-ps.ps1`
9. `tools/audit-postflop-module2-seed.ps1`
10. `tools/audit-postflop-module3-seed.ps1`

**Plus per-version:**
- `docs/specs/postflop-v{VERSION}-*.md` — the sprint doc(s) from the most recent sprint covered by this snapshot
- `AUDIT_OUTPUT_production.txt` — full output of `tools/audit-postflop-ps.ps1`
- `AUDIT_OUTPUT_M2_seed.txt` — full output of `tools/audit-postflop-module2-seed.ps1`
- `AUDIT_OUTPUT_M3_seed.txt` — full output of `tools/audit-postflop-module3-seed.ps1`
- `AUDIT_HEADLINES.txt` — top-line summary of the three audits

**Snapshot folder structure:**

```
GPT AUDIT/v{VERSION}/
├── PROJECT_STATE.md
├── TASK_BOARD.md
├── index.html
├── service-worker.js
├── postflop/
│   ├── postflop_scenarios.json
│   ├── postflop_concepts.json
│   └── postflop_taxonomy.json
├── tools/
│   ├── audit-postflop-ps.ps1
│   ├── audit-postflop-module2-seed.ps1
│   └── audit-postflop-module3-seed.ps1
├── docs/specs/
│   └── postflop-v{VERSION}-*.md
├── AUDIT_HEADLINES.txt
├── AUDIT_OUTPUT_production.txt
├── AUDIT_OUTPUT_M2_seed.txt
└── AUDIT_OUTPUT_M3_seed.txt
```

The refresh PowerShell script is in `GPT AUDIT/README.md` ("How to refresh this snapshot at a later version" section).

### B. UI screenshot per UI sprint — `GPT AUDIT/screenshots/v{VERSION}/`

**Rule:** Any sprint that touches UI/UX (CSS, layout, navigation, mode rendering, panels, tiles, modals, screens, etc.) **MUST** also save preview captures to `GPT AUDIT/screenshots/v{VERSION}/` before commit so an external GPT reviewer can see what shipped visually.

**Per-sprint subfolder structure:**

```
GPT AUDIT/screenshots/v{VERSION}/
├── README.md                      describe what was captured + how to review
├── 01-{name}-{viewport}.html      self-contained DOM+CSS snapshot
├── 02-{name}-{viewport}.html      ...one per significant view state
├── 03-state-snapshot.json         runtime state + relevant registry summary
└── (optional) {name}.png          PNG only if a non-technical reviewer needs it
```

**Naming rules:**
- Numeric prefix `01-`, `02-`, `03-` for predictable sort order
- `{name}` describes the view: e.g., `preflop-mode`, `postflop-mode`, `drill-question`, `summary-screen`
- `{viewport}` is mobile-first: `mobile-375`, `tablet-768`, `desktop-1280`

**HTML snapshots are the default** (over PNG) because:
- Claude Preview MCP returns inline screenshots but doesn't expose `save_to_disk` — HTML capture via `preview_eval` + base64-encoded `outerHTML` + inlined computed CSS is the reliable persistence path
- ~10KB per snapshot (vs 50–100KB PNG), diff-friendly across versions
- GPT can read structure semantically (button labels, classes, ARIA attributes), not just pixels
- Renders faithfully when opened in any browser

**When to skip the screenshots folder:**
- Pure data sprints (text fixes, audit tweaks, version bumps with no UI change)
- Internal helper additions that don't change visible UI
- Document the skip explicitly in the sprint doc to avoid confusion

### General rules

- **Both folder families are git-ignored** (entry in `.gitignore`) — never commit them.
- **Reference implementation:** `GPT AUDIT/v4.2.2F/` (data + audit snapshot) and `GPT AUDIT/screenshots/v4.2.2F/` (UI captures) show the canonical patterns.
- **Top-level convention rules** live in `GPT AUDIT/README.md` — keep that file in sync with this section.

---

## 8. Open Questions (carried forward, awaiting human input)

Tagged from `postflop/postflop_schema.md` "Open questions for review":

1. **Acceptable-score granularity** — locked to `{0.25, 0.5, 0.75}`, or allow any value in `[0, 1]`?
2. **Critical-flag UI** — flag-only in stats, or block progression / force review?
3. **ICM in v4.0** — confirm out-of-scope (chipEV-only foundation)?
4. **Hand-class enum location** — separate file, or stays inside `postflop_concepts.json`?
5. **`mixing` block format** — is `{ choiceId: freq }` enough, or richer `{ freq, ev }` per choice?

Plus, before commit:

6. **Spot-check of 3–5 sample scenarios** by a human reviewer.
7. **Approval to commit** the v4.0.0 planning package.

---

## 9. Next Recommended Step

1. ✅ Workflow files created (DEC-001, etc.).
2. ✅ v4.0.0 planning package reviewed + approved + committed (`7849741`) + pushed.
3. ✅ v4.0.1 implementation (schema loader + audit gate) staged per brief.
4. ⏸️ **Human review of staged v4.0.1 diff**, then approve the commit.
5. ⏸️ On approval: stage commit message `v4.0.1: add postflop schema loader and audit gate`; commit; await separate "push" instruction.
6. ⏸️ Resolve the 5 open questions above (or defer with explicit notes).
7. ⏸️ After v4.0.1 commit: prepare `docs/specs/brief-v4.0.2-module1-board-texture-trainer.md` (planning only — actual UI work).

---

**Maintained by**: Orchestrator Agent. Update on every state change. Do not delete entries — annotate with status.
