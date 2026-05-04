# Brief — v4.0.3: Post-flop Module 1 First-Session Hotfix + UX Reposition Polish

> **Status**: real-play feedback received from human tester; implementing now as a focused hotfix.
> **Predecessor**: v4.0.2 commit `5d21128` (first visible postflop UI, beta-gated, deployed to origin/main).
> **Sister stub**: `brief-v4.0.3-flop-cbet-ip-trainer-stub.md` — STILL DEFERRED; Module 2 work happens after polish ships.

## Real-play feedback received (2026-05-04)

The tester played the live v4.0.2 deploy and reported 4 issues:

1. **Loading feels slow** — entry card takes too long to appear; no feedback that anything is happening.
2. **Choice meanings are unclear** — labels assume postflop vocabulary the tester didn't have.
3. **Answer buttons feel unresponsive** — tapping a button doesn't visibly respond before the feedback screen swaps.
4. **Home placement is too low** — entry buried at the bottom of Mastery; requires excessive scrolling.

These supersede the smoke-test-passed status. v4.0.3 implements the smallest safe fix for all 4.

---

## 1. Goal

Fix the 4 real-play issues from the tester's first-session feedback with the smallest safe set of changes. v4.0.3 is a **hotfix + reposition pass**, not a redesign.

| Issue | v4.0.3 fix |
|---|---|
| Loading feels slow | Loader callback re-renders Home when ready; visible spinner placeholder + error state |
| Choice meanings unclear | Per-question-type "What are we choosing?" expandable guide (collapsible, mobile-friendly) |
| Buttons feel unresponsive | Immediate `pressed` class + disable all buttons + rAF before feedback render |
| Home placement too low | Card moves to TOP of Home (`afterbegin`) inside a "🧪 BETA LAB" section |

**Spirit**: don't rush to Module 2. The first impression matters; the player who hits beta-on for the first time should encounter a session that feels deliberate, readable, fair, and useful. Anything friction-causing in v4.0.2 gets fixed here. Anything genuinely working stays untouched.

---

## 2. Why we're doing this before Module 2

| Factor | Why polish first |
|---|---|
| **First impression risk** | Beta-on is the player's introduction to postflop. A clunky first session reduces the chance they enable beta again. |
| **Architecture validation** | v4.0.2 is the first time the App.postflop → render path runs in production. Real-play surfaces issues the QA matrix didn't catch. |
| **Mobile reality** | Real-device 375 px will reveal layout issues a desktop emulator misses. |
| **Module 2 leverage** | Every UX lesson learned in Module 1 transfers directly to Module 2's hand-decision UI. Better to learn cheaply on the simpler module first. |
| **Data feedback loop** | Real player choices on individual scenarios reveal which feel fair vs misleading. Module 2 needs the same data feedback before it ships. |

Module 2 is genuinely interesting work — it's not getting cancelled, just sequenced after one polish round.

---

## 3. Scope IN

| # | Item | Type | Notes |
|---|---|---|---|
| 1 | Real-device QA on Netlify deploy | Test | Open the live URL on actual mobile device + actual desktop browser (not just DevTools emulator) |
| 2 | First-session UX audit | Test/Doc | Walk through as a "first time" user; document everything that feels off |
| 3 | Board Texture Trainer readability fixes | UI | Microcopy + layout adjustments based on audit |
| 4 | Explanation clarity tweaks | Data + UI | If specific scenarios prove confusing, GTO Data Subagent fixes (separate commit) |
| 5 | Feedback pacing | UI | Are sections opening/closing at the right moments? Is "Next" in the right spot? |
| 6 | Mobile 375 px polish | UI | Card sizing, button heights, scroll behavior, board cards visible without scroll |
| 7 | Beta toggle UX polish | UI | Settings position, label wording, toast clarity |
| 8 | Scenario order / randomization tuning | JS | Currently Fisher-Yates shuffle from full pool. Consider: open with diff-1 scenarios first; cap consecutive question types; etc. |
| 9 | Score summary clarity | UI | Per-tier counts, concept mastery rows, critical leaks list — anything visually unclear |
| 10 | Microcopy fixes | UI | Result row labels, section titles, toast text, button labels |
| 11 | Layout polish | UI | Spacing, line-heights, visual hierarchy of result row vs explanation |
| 12 | Optional: progress bar + Q-counter clarity | UI | If real-session feedback shows confusion |
| 13 | Optional: critical-leak emphasis tuning | UI | Amber accent might be too loud or not loud enough |

---

## 4. Scope OUT (do not implement in v4.0.3)

- ❌ Module 2 (Flop C-bet IP) — separate brief, separate epic
- ❌ Module 3 (BB Defense vs C-bet) — v4.1 territory
- ❌ Postflop SRS storage — v4.0.4
- ❌ Postflop session-history persistence — v4.0.4
- ❌ XP / Chips / cosmetics for postflop — v4.1+
- ❌ Postflop boss / mission / overall-exam integration — v4.2+
- ❌ Concept-tag click → modal — v4.0.5
- ❌ Solver-frequency mixing display — v4.0.5
- ❌ New scenarios — out of scope (data fixes only via separate `v4.0.3-data` commit if needed)
- ❌ New question types — out of scope
- ❌ Major architectural changes — must stay additive within v4.0.2 patterns

---

## 5. Files allowed to edit

| File | Permission | Notes |
|---|---|---|
| `index.html` | EDIT — only inside the existing v4.0.2 fenced block | Polish microcopy + layout tweaks; no architectural changes |
| `service-worker.js` | EDIT — VERSION bump only | `'v4.0.2'` → `'v4.0.3'` |
| `PROJECT_STATE.md` | EDIT — state sync after polish lands |  |
| `TASK_BOARD.md` | EDIT — workstream sync |  |
| `postflop/postflop_scenarios.json` | EDIT (separate commit) — only if real-play audit surfaces a specific scenario clarity issue | Ships as `v4.0.3-data` commit BEFORE the v4.0.3 UI polish |

**No other file is in scope.** In particular:
- `postflop_taxonomy.json`, `postflop_concepts.json` — read-only
- `postflop_audit_rules.js`, `postflop_audit.html` — read-only
- `tools/audit-postflop.js` — read-only
- `ranges.json`, `manifest.json`, icons — untouched
- All cosmetic / FX / aura / collection / boss / mission code — untouched

---

## 6. File ownership

- **QA Agent** owns the real-play audit (Step A below). Produces a findings report.
- **UX Subagent** translates findings into specific microcopy/layout deltas. Drafts the implementation brief delta.
- **GTO Data Subagent** owns any scenario-clarity edits (separate `v4.0.3-data` commit before UI polish).
- **DEV Integration Agent** implements the polish in `index.html` per the deltas.
- **Orchestrator** updates state files, stages commit, awaits human approval.

---

## 7. Real-play QA pass (Step A — runs first)

> 📋 **See companion document**: [`postflop-v4.0.3-real-play-checklist.md`](postflop-v4.0.3-real-play-checklist.md) — short (10–15 min) human-tester checklist with live URL, setup steps, in-session checks, and a notes section that feeds back into this brief.
>
> The checklist is the **gate**. No v4.0.3 implementation begins until the human tester completes it and hands back Section F notes.
>
> Live deploy verified 2026-05-04: `https://range-master-mtt.netlify.app/` serving v4.0.2; smoke test 10/10 PASS; SW cache `range-master-v4.0.2` active.

### A.1 — Netlify deploy verification

After v4.0.2 push lands on Netlify (typically 1–3 minutes):

1. Open the live Netlify URL on **a real desktop browser** (not localhost).
2. Verify service worker activates `range-master-v4.0.2`.
3. Verify console: `[postflop] loaded 31/31 scenarios (schema 1.0.0)`.
4. Verify backup export shows `appVersion: '4.0.2'`.
5. Open the same URL on **a real mobile device** (phone, not DevTools emulator). Expected: app installs as PWA, postflop data loads.

### A.2 — First-session UX walkthrough

Pretend you're a first-time user discovering the postflop beta. Walk through:

1. Open Settings → see "🧪 Beta Features" section at bottom → toggle on
2. Toast appears: "Post-flop beta enabled — Home tab now shows Module 1."
3. Navigate to Home → scroll to bottom → see the postflop entry card
4. Read the card text — is "Board Texture Trainer" + "Read the board first" + "20 scenarios · ~10 min" enough information to decide whether to start?
5. Tap Start → enter question screen
6. **For each of 5 questions, write down**:
   - Did the spot card communicate the situation? (100BB · BTN open · BB call · SRP)
   - Were the 3 board cards immediately readable?
   - Was the question prompt clear?
   - Were the answer choices well-distinguished?
   - On feedback: did the result row tell you what tier you scored?
   - Did the short explanation give you the principle?
   - Did you open any of the expandable sections? Which?
   - Was Next button findable?
7. After 5 questions, exit early. Confirm modal appears. Confirm exit returns to Home.
8. Restart, complete to Q15.
9. On summary: are tier counts clear? Is concept mastery understandable? Is the critical leaks list helpful or noisy?

### A.3 — Mobile 375 px walkthrough

Same A.2 walkthrough on actual mobile (or strict DevTools emulation):

1. Are board cards readable? (56×80 px target on 375 px screen)
2. Are choice buttons easy to tap with thumb? (56 px height target)
3. Does feedback card scroll cleanly? Is Next button accessible after expanding sections?
4. Does the summary screen fit reasonably?
5. Does the beta toggle in Settings scroll into view?

### A.4 — Regression checklist

- ✅ Preflop drill (5 hands) still works identically
- ✅ All 5 tabs render
- ✅ Boss gate from Mastery still opens correctly
- ✅ Existing FX / Aura / cosmetic settings still control their respective surfaces
- ✅ Beta off → postflop UI completely hidden
- ✅ Backup export/import still works (now with `appVersion: '4.0.2'`)
- ✅ Service worker update banner appears for users on older versions

### A.5 — Findings report

QA Agent produces `docs/specs/postflop-v4.0.3-realplay-findings.md`:
- One row per finding: severity (🔴/🟠/🟡/🟢), category (microcopy/layout/scenario/regression), description, suggested fix
- Hard requirement: each finding has either a fix proposal OR a "defer to v4.0.4+" tag with rationale
- The report is an INPUT to v4.0.3 implementation, not the implementation itself

---

## 8. Likely polish targets (anticipated; refine after audit)

These are educated guesses — actual list comes from the audit. Listed here so reviewers can vet the direction:

| Area | Possible adjustment |
|---|---|
| **Result row** | "BEST · 1.00 pts" might read as "BEST 1.00 pts" without dot separator — confirm scanning |
| **GTO best label** | When best has multiple choices, comma-joined might wrap awkwardly — consider stacking |
| **Concept tag pills** | Currently 5+ pills wrap to two rows on 375 px — consider compact mode or "+N more" |
| **Section headers** | "▶ Range Logic" — chevron rotation is subtle on mobile; maybe larger transition |
| **Common Mistake amber** | Auto-open on critical might cause scroll jump — verify or add scrollIntoView |
| **Summary score color** | 80%+ mint, 50-79% amber, <50% red. Verify thresholds feel right after real play |
| **Critical leaks list** | If 3+ leaks in one session, list could get long — consider collapse-by-default with count badge |
| **Scenario shuffle** | First question is random — consider locking a "warm-up" diff-1 question first |
| **Board card contrast** | Red/black on white — verify legibility on dim phone screens |
| **Spot card density** | All info on 2 lines might be too tight — try 3-line layout |
| **Beta toggle wording** | "Enable post-flop beta modules" — singular "module" might be clearer (only one exists) |
| **Beta toggle status line** | "20 Module 1 scenarios audited · alpha quality" — "alpha" might overcommit |
| **Drill again button** | Currently large mint at top of summary — verify it's not accidentally tappable while reviewing |

---

## 9. Score summary clarity (specific area)

The summary card has multiple scoring concepts on screen:

```
13.5 / 15.0 (90%)        ← totalScore / maxScore (percentage)
─────────
Best 13   Acceptable 1   ← per-tier counts
Bad 0     Critical 1
─────────
▶ Concept mastery        ← per-concept accuracy (17 rows possible)
▶ Critical leaks (1)     ← per-leak detail
```

Risk: cognitive overload. v4.0.3 polish should evaluate:
- Is the headline number (13.5/15.0) the right primary metric vs percentage?
- Should percentage be the headline and raw counts secondary?
- Are 4 tier cells overkill or right?
- Is concept mastery valuable or noise on first session?

These are open questions for the audit; the brief doesn't pre-decide.

---

## 10. Scenario order / randomization tuning

Current implementation: pure Fisher-Yates shuffle from the full Module 1 pool (20 scenarios) → slice first 15.

Possible tuning (subject to audit findings):

| Option | Pros | Cons |
|---|---|---|
| **Pure random** (current) | Simple; high replay variety | First scenario could be diff-3 (intimidating opener) |
| **Warm-up locked** | Always opens with diff-1; better first impression | Loses some variety on Q1 |
| **Difficulty curve** | Diff-1 → diff-2 → diff-3 progression | Predictable; loses replay variety |
| **Question-type rotation** | Cycle range_advantage → nut_advantage → dynamic → freq → sizing | Tests breadth; might feel artificial |

Defer until audit shows whether current shuffle feels right.

---

## 11. Microcopy candidates for revision

Catalog of strings that might benefit from polish:

| Source | Current | Proposed adjustment direction |
|---|---|---|
| Home card title | `Board Texture Trainer` | (likely fine) |
| Home card desc | `Read the board first. Range advantage · nut advantage · c-bet sizing family.` | Consider expanding "c-bet" if first-time players might not know |
| Home card stats | `20 scenarios · ~10 min` | Verify time estimate accurate |
| Home card button | `▶ Start Board Texture Drill` | "Drill" might feel too military; "Start Session" or "Start Practice" alternatives |
| Spot card hero line | `Hero: — (board read)` | The em-dash might confuse; consider "Board-only question" |
| Result row | `BEST · 1.00 pts` | Verify dot separator works on small screens |
| Section headers | `Range Logic`, `Nut Logic`, `Sizing Logic`, `Common Mistake` | Add icons? "📊 Range Logic"? |
| Toast on enable | `Post-flop beta enabled — Home tab now shows Module 1.` | (likely fine) |
| Critical leak label | `🚨 CRITICAL LEAK · 0.00 pts` | "LEAK" might be unclear; "Critical Mistake"? |
| Drill again | `▶ Drill again` | "Restart Session"? "New Session"? |

These are pre-audit guesses; refine based on real-play.

---

## 12. Regression checklist (for implementation phase)

Before committing v4.0.3:

```
[ ] Audit re-confirmed 31/0/0
[ ] Live browser QA: all v4.0.2 functions still exist
[ ] Live browser QA: beta gate still works (off → no UI; on → card)
[ ] Live browser QA: full session start → 15 questions → summary
[ ] Live browser QA: all 4 tier classifications still correct
[ ] Live browser QA: feedback card renders all expandable sections
[ ] Live browser QA: summary card renders score + tiers + concepts + leaks
[ ] Preflop drill regression: 5 hands, all classified correctly
[ ] All 5 tabs render
[ ] Boss gate still opens
[ ] Mobile 375 px clean
[ ] Console clean
[ ] Diff scope: only allowed files modified
[ ] Postflop data + audit infra files unchanged
[ ] ranges.json + manifest.json unchanged
[ ] PROJECT_STATE.md + TASK_BOARD.md updated
[ ] Service worker VERSION bumped 'v4.0.2' → 'v4.0.3'
[ ] appVersion in backup builder bumped '4.0.2' → '4.0.3'
```

---

## 13. Hard guardrails

These apply regardless of any apparent exception:

- ❌ No new postflop modules (Module 2/3 in their own briefs)
- ❌ No SRS / persistence storage changes
- ❌ No cosmetic / reward / FX / aura / collection extensions
- ❌ No changes to preflop ranges / scoring / SRS / cooldowns / Chips formula
- ❌ No changes to existing tab navigation or tab labels
- ❌ No changes to App.postflop frozen API contract (still read-only)
- ❌ No new scenarios added to `postflop_scenarios.json`
- ❌ No new concepts in `postflop_concepts.json`
- ❌ No new texture tags in `postflop_taxonomy.json`
- ❌ No changes to `postflop_audit_rules.js` (audit logic stays stable)

If any guardrail must be touched, DEV Integration Agent stops and escalates to Orchestrator.

---

## 14. Stop condition

The v4.0.3 implementation phase stops after:

1. Real-play audit findings logged in `postflop-v4.0.3-realplay-findings.md`
2. Polish deltas implemented per the audit (only the prioritized items; not every microcopy whim)
3. Regression checklist passed (Section 12)
4. PROJECT_STATE.md + TASK_BOARD.md updated
5. Commit staged with message `v4.0.3: postflop Module 1 polish + first-session tuning`
6. Human reviews + approves
7. Push happens only on separate explicit instruction

DEV Integration Agent does NOT:
- Begin Module 2 work
- Add postflop SRS
- Touch cosmetic / reward / boss surfaces
- Modify preflop code paths
- Edit postflop data files (data fixes ship in their own `v4.0.3-data` commit BEFORE v4.0.3 UI polish)
- Change architectural patterns from v4.0.2

---

## 15. Human approval gate

This brief is **planning only**.

> **Do not implement v4.0.3 until human reviewer reads this brief and explicitly approves.**

Approval workflow:

1. Human reads this brief.
2. Human runs the real-play QA (Section 7) on the live Netlify v4.0.2 deploy themselves OR delegates to QA Agent.
3. Findings report (`postflop-v4.0.3-realplay-findings.md`) drafted.
4. Human reviews findings, decides which to address in v4.0.3 vs defer.
5. UX Subagent drafts implementation deltas.
6. DEV Integration Agent implements + tests + stages.
7. Commit + push happens only on explicit instructions.

---

## 16. Post-v4.0.3 outlook (preview, not authorized)

Once v4.0.3 polish lands:

- **v4.0.4** — Postflop SRS + session history persistence (`localStorage.rmtt_postflop_history` schema + per-scenario familiarity tracking)
- **v4.0.5** — Polish: concept-tag click → modal, mixing freq display, summary chart bars
- **v4.0.6** — Module 2 implementation per `brief-v4.0.3-flop-cbet-ip-trainer-stub.md` (re-numbered to whatever's appropriate)
- **v4.1** — Module 3 (BB Defense) data + UI; first XP/Chip integration for postflop
- **v4.2** — Postflop boss tests; turn module data start

The sequencing prioritizes **player experience quality first**, **content breadth second**.

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | Orchestrator | Initial publication immediately after v4.0.2 push |
