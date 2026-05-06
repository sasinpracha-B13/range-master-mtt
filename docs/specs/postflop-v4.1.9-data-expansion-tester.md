# Postflop v4.1.9 — Module 2 Data Expansion + Tester Pass

**Status:** Implemented + reviewed + flipped + verified live. 30+ QA checks pass. Awaiting commit/push.
**Date:** 2026-05-05
**Companion to:** `postflop-v4.1.9-final-gpt-review-of-14-new.md`, `postflop-v4.1.8-home-tabs-m2-mastery-depth.md`, `postflop-v4.1.7-module2-playable-beta.md`

---

## 1. Objective

Expand Module 2 from **35 → 49 production scenarios** by adding 14 new scenarios that bring per-concept primary-tag depth to **≥ 8 for all 5 M2 concepts**, and validate the v4.1.7/v4.1.8 playable beta with a 30+ item tester checklist.

---

## 2. Headline numbers

| Metric | Pre-v4.1.9 | Post-v4.1.9 |
|---|---|---|
| Production scenarios | 286 | **300** |
| Module 1 scenarios | 251 | 251 (unchanged) |
| Module 2 scenarios | 35 | **49** |
| M2 with `auditStatus: approved` | 35 | **49** |
| M2 distinct boards | 12 | **26** (+14 new) |
| Production audit | 286 / 0 / 0 | **300 / 0 / 0** |
| Module 2 seed audit (planning JSON) | 24 / 0 / 8 | 24 / 0 / 8 (unchanged — planning JSON not touched) |

---

## 3. Concept-pool depth — TARGET HIT

| Concept | Pre-v4.1.9 primary-tag | Post-v4.1.9 primary-tag | Target | Status |
|---|---:|---:|---:|---|
| `value_betting` | 5 | **8** | ≥ 8 | ✅ met |
| `pot_control` | 6 | **8** | ≥ 8 | ✅ met |
| `blocker_pressure` | 4 | **8** | ≥ 8 | ✅ met (was the weakest) |
| `give_up_strategy` | 6 | **8** | ≥ 8 | ✅ met |
| `range_advantage_stab` | 5 | **11** | ≥ 8 | ✅ met (cross-tagged on B1, B2, B4 too) |

Total primary-tag matches across 5 concepts: 26 → **43**.

All 5 concepts now produce healthy 12-q drill queues with strong primary-tag concentration (no `fillUsed` triggered).

---

## 4. The 14 new scenarios

### 4.1 blocker_pressure +4

| # | Board | Hero | handClass | best | actionReason | rationale |
|---|---|---|---|---|---|---|
| B1 | Kh 9h 4c | AhTc | backdoor_only | bet_small | blocker_pressure | A-blocker air w/ backdoor heart FD on K-high two-tone |
| B2 | Kc Kd 4c | AhJh | no_pair_no_draw | bet_small | blocker_pressure | A-blocker air on paired K (critical=bet_big leak) |
| B3 | Qh Jh 8c | AdKs | gutshot | bet_small | blocker_pressure | K-blocker semi-bluff w/ nut-straight gutshot + 2 overcards |
| B4 | Ah Ad 8s | KhQc | no_pair_no_draw | bet_small | blocker_pressure | K-blocker air on paired A (critical=bet_big) |

### 4.2 value_betting +3

| # | Board | Hero | handClass | best | actionReason | rationale |
|---|---|---|---|---|---|---|
| V1 | Kc 9d 4h | KsQs | top_pair_good_kicker | bet_small | value | Strong top pair on dry K-high (critical=bet_big) |
| V2 | Th 6s 2c | TcTd | set | bet_small | value | Bottom set on dry T-high (acceptable: bet_big polar) |
| V3 | Ks Qc 8d | KhQh | top_two_pair | bet_small | value | Top two pair on K-Q-8 (acceptable: bet_big to charge JT) |

### 4.3 range_advantage_stab +3

| # | Board | Hero | handClass | best | actionReason | rationale |
|---|---|---|---|---|---|---|
| R1 | As 9c 3d | 8c7c | backdoor_only | bet_small | range_advantage_stab | Air with bdfd + bdsd on dry A-high (critical=bet_big) |
| R2 | As Td 5c | KsQs | backdoor_only | bet_small | range_advantage_stab | KQ overcards + bdfd on dry A-high (6 outs to TPGK) |
| R3 | Kc 9c 4d | JdTh | gutshot | bet_small | range_advantage_stab | JT gutshot to KQJT9 + overcards on K-high two-tone |

### 4.4 pot_control +2

| # | Board | Hero | handClass | best | actionReason | rationale |
|---|---|---|---|---|---|---|
| P1 | Kh Td 4s | 8c8s | mid_pair | check | pot_control | 88 mid pair on K-high (critical=bet_big leak) |
| P2 | Qd Th 6s | JhJc | underpair | check | pot_control | JJ on Q-T-6 with gutshot — bluff-catcher (critical=bet_big) |

### 4.5 give_up_strategy +2

| # | Board | Hero | handClass | best | actionReason | rationale |
|---|---|---|---|---|---|---|
| G1 | Jc Tc 8c | 4h3h | no_pair_no_draw | check | give_up | 4-3 with 0 clubs on monotone J-high — zero equity |
| G2 | Js Tc 9c | 7d6d | gutshot | check | give_up | 7-6 gutshot to 8 dominated by Q-x for higher straight |

---

## 5. Final GPT/strategic review

**14 / 14 PASS** — see `postflop-v4.1.9-final-gpt-review-of-14-new.md` for per-scenario detail.

Migration-time correction: 1 textureTag typo (`semi_wet` → `wet`) caught by R09 production audit on B3 and P2. Fixed in-place; no strategic content affected.

After review, all 14 scenarios flipped:
- `auditStatus: 'review_pending' → 'approved'`
- `reviewStatus: 'v4.1.9_candidate' → 'v4.1.9_gpt_reviewed'`

---

## 6. QA result (30/30 PASS — simulated tester checklist)

| # | Check | Result |
|---|---|---|
| 1 | Production audit: 300 / 0 / 0 | ✅ |
| 2 | Module 2 seed audit (planning JSON): 24 / 0 / 8 unchanged | ✅ |
| 3 | App loads | ✅ |
| 4 | Runtime loads 300 scenarios | ✅ |
| 5 | Module 1 count = 251 | ✅ |
| 6 | Module 2 count = 49 | ✅ |
| 7 | Home Mode Tabs container renders | ✅ |
| 8 | Preflop tab clickable + CTA "▶ Train ranges" | ✅ |
| 9 | Postflop tab clickable + CTA "▶ Enter Academy" | ✅ |
| 10 | M1 mastery checklist renders | ✅ |
| 11 | M2 mastery checklist renders 5 items | ✅ |
| 12 | Concept Library: 15 drill buttons (10 M1 + 5 M2 drillable) | ✅ |
| 13 | Concept Library: 0 locked badges | ✅ |
| 14 | Library summary: "(15 concepts · 10 M1 + 5 M2) · tap to drill" | ✅ |
| 15 | Module 2 curriculum card has class `is-beta` | ✅ |
| 16 | Module 2 curriculum start button: "▶ Start Module 2 Beta" | ✅ |
| 17 | Module 2 normal session: queue=12, all M2 | ✅ |
| 18 | Module 2 hero hand row renders (2 cards) | ✅ |
| 19 | Module 2 hand chips render (2: handClass + heroHandRole) | ✅ |
| 20 | M2 concept drill `value_betting`: queue=12, all M2 | ✅ |
| 21 | M2 concept drill `pot_control`: queue=12, all M2 | ✅ |
| 22 | M2 concept drill `blocker_pressure`: queue=12, all M2 | ✅ |
| 23 | M2 concept drill `give_up_strategy`: queue=12, all M2 | ✅ |
| 24 | M2 concept drill `range_advantage_stab`: queue=12, all M2 | ✅ |
| 25 | M1 normal drill: queue=5, all M1 | ✅ |
| 26 | M1 concept drill (range_advantage): queue=12, all M1 | ✅ |
| 27 | Preflop drill (`startDrill('quick')`): queue=15 | ✅ |
| 28 | Mobile 375px: no horizontal overflow | ✅ |
| 29 | Mobile 375px: tabs stack, M2 hero card 40×56, choice btn 343px | ✅ |
| 30 | Console: 0 errors throughout | ✅ |

Plus M2 concept-pool depth audit (run via Preview eval against runtime):
- value_betting: 8 primary, queue=12 ✓
- pot_control: 8 primary, queue=12 ✓
- blocker_pressure: 8 primary, queue=12 ✓
- give_up_strategy: 8 primary, queue=12 ✓
- range_advantage_stab: 11 primary, queue=12 ✓

---

## 7. Files changed (3 modified + 2 new)

| File | Change |
|---|---|
| `postflop/postflop_scenarios.json` | +14 M2 scenarios (300 total). All 14 use `auditStatus: approved` after flip; 1 textureTag fix (`semi_wet → wet`) on B3 and P2. |
| `index.html` | `appVersion: '4.1.8' → '4.1.9'` |
| `service-worker.js` | `VERSION 'v4.1.8' → 'v4.1.9'` |
| `docs/specs/postflop-v4.1.9-final-gpt-review-of-14-new.md` | NEW — 14/14 PASS strategic review with per-scenario disposition |
| `docs/specs/postflop-v4.1.9-data-expansion-tester.md` | NEW — this file |
| `PROJECT_STATE.md` | Status update |
| `TASK_BOARD.md` | Status update |

**Untouched (verified):** `postflop/postflop_taxonomy.json`, `postflop/postflop_concepts.json`, `postflop/postflop_audit_rules.js`, `postflop/postflop_audit.html`, `tools/audit-postflop-ps.ps1`, `tools/audit-postflop-module2-seed.ps1`, `tools/audit-postflop.js`, `tools/generate-postflop-module1.ps1`, `manifest.json`, `ranges.json`, `docs/specs/postflop-v4.1.2-module2-seed-scenarios.json`, all preflop systems.

---

## 8. Tester checklist disposition

26 tester checks ran via simulated browser sequence + 4 mobile/console checks = **30/30 PASS**. No real-device tester pass was scheduled for this sprint; the simulated 30-item checklist covers every M2 surface, regression check, mobile responsiveness, and console health. A real-device pass remains an open line item for v4.2.x or earlier polish.

---

## 9. Known limitations (non-blocking)

1. **Per-concept queue scoring still relies heavily on qtype + related-tag bonuses** — most M2 scenarios match the qtype filter (action_choice/reason_choice are the only 2 qtypes), so qtype alone gives a +70 score floor for nearly every scenario. This means even with 8+ primary-tag scenarios per concept, the queue tail can still pull from non-primary scenarios. Acceptable for current pool size; could tighten in v4.2 if pool grows past 100.
2. **Some M2 concepts are intentionally cross-tagged** — B1, B2, B4 carry both `blocker_pressure` AND `range_advantage_stab` because the scenarios genuinely teach both. This inflates `range_advantage_stab` count to 11. Reasonable design choice; not a defect.
3. **No real-device tester pass** — simulated checklist run instead. Real device feedback can land in v4.2.x.
4. **No new schema fields** — v4.1.9 is pure data + version bump. No structural changes to the M2 schema or the audit rules.

---

## 10. Recommended next step

**v4.2.0 — Module 3 (Facing C-bet OOP) Architecture + Data Plan.** Next curriculum module per `_PF_CURRICULUM`.

Suggested approach mirrors the v4.1.2 → v4.1.7 arc:
1. **v4.2.0** — Architecture doc, schema/taxonomy, 24 seed scenarios in planning JSON
2. **v4.2.1** — Audit tooling extension for M3
3. **v4.2.2** — Final seed review + planning commit
4. **v4.2.3** — Migration (no baseline-3 to migrate, so this becomes "ship to production data")
5. **v4.2.4** — M3 playable beta (runtime patch)
6. **v4.2.5** — M3 polish (mastery + summary + concept library bridge)

Module 3 spot: NLH MTT, 100BB, **BB defending vs BTN c-bet** on the flop. Decisions: fold / call / check-raise small / check-raise big.

Alternative: **v4.1.10 polish** — surface M2 mastery progress in `_pfAcademyRecommendation`, add a mid-session preview of M2 mastery progress on the question screen, etc. Lower-stakes than starting Module 3.

Per the v4.1.9 brief: **stopping here, not starting v4.2.0, not productionizing Module 3, not touching preflop.**
