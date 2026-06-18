# Postflop v4.4.0 — Module 5: BB River Defense OOP — Architecture

**Status:** Planning-only. No production data. No runtime wiring. No version bump.
**Date:** 2026-06-18
**Builds on:** Module 4 (BB Turn Defense OOP, v4.3.0..v4.3.2C)
**Companion docs:** `postflop-v4.4.0-module5-schema-taxonomy.md`, `postflop-v4.4.0-module5-seed-scenarios.json`, `postflop-v4.4.0-module5-audit-plan.md`, `postflop-v4.4.0-module5-gpt-review-package.md`

---

## 1. Module purpose

Module 5 teaches Big Blind defense **on the river**, after BB has already check-called the flop AND the turn, and now faces a third barrel from BTN. It is the first river-street module in the Postflop Academy curriculum and the natural completion of the OOP-defense arc: Module 3 (flop) → Module 4 (turn) → Module 5 (river).

Where Module 4 asks "now that BB called the flop, what does the turn card change?", Module 5 asks the final-street question: "BB has called two streets; the river is here; villain fires the last barrel — **call, fold, or raise?**"

The single most important lesson Module 5 introduces is that **the river is a pure showdown decision — there is no more equity to realize, only made-hand strength versus villain's maximally polarized betting range.** Every M1-M4 instinct built around "draw equity," "outs," and "equity realization" must be switched off. The river is won by (1) calling the correct frequency against a polar range (minimum defense frequency), (2) selecting WHICH bluff-catchers to keep using blockers, and (3) knowing that busted draws are now either bluff-raises or folds — never calls.

---

## 2. Why Module 5 follows Module 4

Module 4 is BB's turn decision (defend a barrel after the flop call). Once a learner can defend the turn competently, the next and final decision in the same hand tree is: **continue defending on the river?**

Module 5 inherits the BTN-vs-BB SRP 100BB framing from Module 4 but extends one street. The flop AND turn actions are now fixed (BB check-called both), the river card is the new variable, and the question is what BB does facing BTN's third barrel.

This narrows the spot to a coherent first river module:
- Same range assumptions as Module 4 (just one street later)
- Same BB-OOP perspective (consistent learner mental model)
- Same action-menu structure (extends, not replaces — see §9)
- Different decision physics (the new lesson): showdown-only, no draw equity

Module 5 is **NOT** "BTN river betting IP" (that is Module 6), nor "BB river leading/probing," nor "river check-back showdowns." All are valuable but reserved for later modules to keep this module bounded.

---

## 3. Exact spot assumption

| Field | Value |
|---|---|
| Game | NLH MTT, chipEV (no ICM) |
| Effective stacks | 100BB |
| Format | NLH_MTT |
| Pot type | SRP |
| Preflop action | BTN open 2.5x, BB call |
| Flop action | BTN c-bets small (~33% pot), BB calls |
| Turn action | BTN barrels (~50-66% pot), BB calls |
| River action | BTN bets (sizing varies: small ~33% / medium ~66% / large ~100% / overbet ~150%) |
| Hero | BB (out of position) |
| Hero role | turn_check_caller_oop |
| Villain | BTN (in position) |
| Villain role | river_barreler_ip |
| Hero river decision | fold / call / check_raise_small / check_raise_big / mixed |

**River math is showdown math, not pot-odds-plus-equity math.** Facing a bet of size B (as fraction of pot), a bluff-catcher must be good (win at showdown) at least `B / (1 + 2B)` of the time:

| Villain river sizing | Call needs to win >= | Minimum Defense Frequency (BB defends) |
|---|---|---|
| small (~33% pot) | ~20% | ~75% |
| medium (~66% pot) | ~28% | ~60% |
| large (~100% pot) | ~33% | ~50% |
| overbet (~150% pot) | ~37.5% | ~40% |

The bigger the bet, the fewer bluff-catchers BB keeps — and the more BB must rely on blockers to pick the *right* ones.

---

## 4. What learner should master

Module 5 trains these decisions:

1. **Bluff-catch the correct frequency (MDF)** — defend wide vs small bets, tight vs overbets; don't auto-fold "just a pair" to a big bet without checking whether you are over-folding.
2. **Select bluff-catchers by blocker, not by absolute strength** — when several bluff-catchers are equal at showdown, keep the one that blocks villain's value combos and/or unblocks his bluffs.
3. **Fold busted draws — never call with them** — a missed flush draw has zero showdown value; it is a bluff-raise candidate (with a blocker) or a fold, never a call.
4. **Recognize when the river card shifts ranges** — a flush-completing or straight-completing river that BB's range misses is a fold even with a strong pair (board_change_river_fold).
5. **Value-raise the river with strong made hands** — when BB's call-call line arrives with a hand that beats villain's value-betting range (rivered straight, set, two-pair on a blank), raise for value.
6. **Bluff-raise the river with blockers only** — pure river check-raise bluffs require nut blockers (block the nut flush / nut straight) and a credible story; low frequency, honest "(advanced; solver mixes)" copy.
7. **Make hero calls** — call a weak bluff-catcher when villain's range is bluff-heavy AND hero blocks value / unblocks bluffs, even when the hand "feels too weak."
8. **Avoid the over-fold trap** — the most common river leak is folding too much vs polar barrels; recognize spots where BB must keep marginal pairs in.
9. **Avoid the station trap** — the opposite leak: calling dominated bluff-catchers against value-heavy lines on rivers that complete obvious draws.
10. **Make thin value calls (not raises)** — call a medium made hand for showdown when raising only folds out worse and gets called by better.
11. **Fold capped-range hands to polar pressure** — when BB's line is capped (no nutted combos remain) and villain overbets, marginal made hands fold.
12. **Read villain's river sizing as a range tell** — small bets are merge/thin-value-heavy (defend wide); overbets are polar (defend tight, blocker-dependent).

---

## 5. What is intentionally out of scope

Documented for clarity so future modules can fill these:

| Out of scope | Future module |
|---|---|
| BTN river betting IP (hero as the aggressor) | **Module 6 (River Betting / Triple-Barrel IP)** |
| BB river leading / donk-betting the river | Future "River Lead OOP" module |
| BB probing river after turn check-check | Future "Probe River" module |
| River check-back showdown decisions | Future module |
| Multi-way river play | Future advanced module |
| 3-bet pots | Future "3BP Postflop" module |
| ICM-aware river adjustments | Future tournament-specific module |
| Rivered redraw / blocker bet sizing as hero | Module 6 (IP) |

---

## 6. How M5 differs from M4

| Dimension | Module 4 (Turn Defense OOP) | Module 5 (River Defense OOP) |
|---|---|---|
| Street | turn | river |
| Board cards | 4 | **5** |
| New strategic axis | Equity shift from turn card | **Showdown-only decision: MDF + blocker-driven bluff-catch + busted-draw resolution** |
| Draw equity exists? | yes (calling to realize draws) | **NO — river is final; no outs, no equity realization** |
| Action menu | fold / call / check_raise_small / check_raise_big / mixed | same (intentional consistency) |
| ActionReason vocabulary | 12 reasons (turn) | **12 reasons (river)** — MDF, blocker bluff-catch, missed-draw give-up, river value/bluff raise |
| Central dimension | turn category (brick / overcard / flush-complete / etc.) | **river category + villain river sizing** (sizing drives MDF) |
| Critical-mistake vocabulary | calling no-equity floats; folding mandatory bluff-catchers | **over-folding to polar barrels; calling busted draws; stationing dominated pairs on draw-complete rivers; folding rivered nuts** |
| Schema additions | flopCards + turnCard, turnCategory, equityShift, drawCompletion | **+ riverCard, riverCategory, runoutTexture, riverDrawCompletion, villainRiverSizing, suitTextureRiver** |

---

## 7. Core strategic concepts

### 7.1 River is showdown-only (the central concept)

On the river there are no more cards to come. Every hand is final. This collapses the decision space:
- There is no "equity" — only the probability the hand is best at showdown.
- There are no "outs" — a missed draw cannot improve.
- "Pot odds + equity" (M2-M4 framing) becomes "**am I good often enough to call at this price**," i.e., does villain bluff at least `B/(1+2B)` of his betting range.

This is the hardest mental switch in the curriculum: hands that were correct turn calls (draws, weak pairs with equity) are now folds or bluff-raises.

### 7.2 Villain's river range is maximally polarized

By the river, after three barrels, BTN's range is the most polar it ever gets:
- **Value**: hands that beat BB's bluff-catchers — top pair good kicker and up, two-pair, sets, straights, flushes, depending on runout.
- **Bluffs**: hands that barreled all three streets and missed — busted flush draws, busted straight draws, air with give-up equity that chose to fire.
- **Almost no medium hands** bet the river for value into a capped OOP caller (they check back to realize showdown).

This polarization is why river defense is a bluff-catching exercise: BB rarely has a hand that beats value but can't beat bluffs in a way that matters — the question is purely "does this beat his bluffs and is he bluffing enough."

### 7.3 Minimum Defense Frequency (MDF)

Against a bet of size B (fraction of pot), BB must continue with at least `1 - B/(1+B)` of his range to prevent villain from profitably bluffing any two cards:
- vs 33% → defend ~75%
- vs 66% → defend ~60%
- vs 100% (pot) → defend ~50%
- vs 150% overbet → defend ~40%

MDF is the *floor*, not a target — exploitatively BB can fold more vs under-bluffers and less vs over-bluffers. Module 5 teaches MDF as the anchor and then the blocker logic that selects which hands fill that frequency.

### 7.4 River bluff-catcher selection by blocker

When BB must defend (say) 60% and has many equal-strength bluff-catchers, the *correct* ones to keep are those that:
- **Block villain's value combos** (e.g., holding the A of the flush suit on a flush-complete river blocks his nut flushes), and/or
- **Unblock villain's bluffs** (don't hold the cards villain would be bluffing with — keep his bluff combos in his range).

A pair of the same nominal strength can be a call or a fold purely on blocker grounds. This is the M5-defining skill: `blocker_bluff_catch_river`.

### 7.5 Busted draws: bluff-raise or fold, never call

BB arrives at the river with many busted draws (called turn with a flush/straight draw, river bricked). These hands:
- have **zero showdown value** (cannot beat even a bluff at showdown — both miss, but villain's "bluff" is also nothing... and BB checks, so BB can only win by betting/raising or by villain checking back; facing a bet, a busted draw has 0% to be good).
- are therefore **bluff-raise candidates** (if they hold a key blocker and the story is credible) or **folds** (if no blocker).
- are **never calls.** Calling a busted draw on the river is pure spew — the M5 critical mistake `missed_draw_give_up` violation.

### 7.6 River value raise

When BB's check-call-call line arrives at a hand that beats villain's value-betting range, raising (check-raising the river) extracts value:
- rivered straight on a blank (BB's flatting range had the connectors)
- set / two-pair on a runout where villain barrels top pair / overpairs
- made flush when BB's range contains the suited combos and villain barrels non-flush value

Thin value raises are dangerous OOP (villain only continues with better), so M5 reserves `value_raise_river` for hands clearly ahead of the value-betting range.

### 7.7 River bluff raise (blocker-dependent)

Pure river check-raise bluffs are the highest-variance line in the curriculum. They require:
- a **nut blocker** (the A of the flush suit on a flush board; the nut-straight card on a straight board), and
- a **credible value story** (BB's range can have the nuts here), and
- villain's range being **capable of folding** (he has bet-folds, i.e., thin value / weak value that gives up to a raise).

Solver mixes these 5-15%. M5 exposes 1-2 with explicit "(advanced; solver mixes)" copy.

### 7.8 Hero call

A "hero call" is calling a bluff-catcher that is *below* average strength for the spot, justified by:
- villain's range being **bluff-heavy** (he over-fires rivers), and
- hero's specific cards **blocking value / unblocking bluffs**.

The lesson: river defense is not "do I have a good hand" but "is this specific holding good enough *given blockers and villain tendencies*." `blocker_bluff_catch_river` formalizes the GTO version; "hero call" is the exploit-flavored version of the same skill.

### 7.9 The over-fold trap (most common river leak)

The single biggest river leak in the player pool is **folding too much** to river bets. Players fold every "just a pair" to a big bet, which lets villain profitably bluff any two cards. Module 5 repeatedly drills spots where the disciplined play is to **call a marginal bluff-catcher** to stay above MDF. `range_disadvantage_river_fold` is reserved for *genuine* capped-range folds, NOT for "my pair is weak so I fold."

### 7.10 The station trap (opposite leak)

The mirror leak is **calling too much on rivers that complete obvious draws** against value-heavy lines. When a flush completes and BB has only a non-flush pair with no flush blocker, villain's "bluffs" largely got there — the range is value-heavy and BB should fold. `domination_river_fold` and `board_change_river_fold` cover these.

### 7.11 Thin value call vs raise

Some medium made hands (e.g., two pair on a four-straight board) are too strong to fold but too weak to raise (a raise folds out worse and is called only by better). The correct line is **call** — `thin_value_call_river`. Teaching the call-don't-raise distinction is a core river skill.

### 7.12 River sizing as a range tell

BTN's river sizing leaks his range:
- **Small (33%)**: merge / thin value heavy → BB defends wide, raises rarely.
- **Medium (66%)**: balanced polar → standard MDF.
- **Large/overbet (100-150%)**: maximally polar → BB defends tight, blocker-dependent, and his own value-raises shrink because villain's range is nutted-or-air.

Recognizing the sizing-to-range mapping is `river_polarization` + the per-scenario `villainRiverSizing` field.

---

## 8. River-card categories (6 used in seeds)

| Category | Definition | Strategic effect |
|---|---|---|
| **brick** | River completes no draw, brings no overcard, does not pair the board | Ranges stay as they were on the turn; pure MDF bluff-catch decision |
| **overcard** | River brings a card higher than the board's previous high card | Can give villain new top pair for value; BB's medium pairs slip |
| **flush_complete** | Third (or fourth) card of a suit completes a flush | Polar: A-of-suit blocker becomes the decisive defense filter |
| **straight_complete** | River fills a straight available to either range | Polar: nut-straight blocker decides bluff-catch / bluff-raise |
| **board_pair** | River pairs a board card | Counterfeits some bluff-catchers; villain's trips/boats appear; reduces flush/straight value |
| **scare_card** | A high or coordinated card that threatens BB's bluff-catchers and enables villain's representation | Tests discipline: often a fold-too-much trap or a hero-call spot |
| **blank_runout** / **double_pair** / **range_shift_card** | Reserved sub-types | Future expansion |

The seed scenarios use **6 categories** (brick, overcard, flush_complete, straight_complete, board_pair, scare_card) for v4.4.0 to keep scope bounded.

---

## 9. Action menu

Identical to Modules 3 and 4 (5 actions, intentional consistency for cross-module learning and runtime reuse):

| Action ID | Display label | River meaning |
|---|---|---|
| `fold` | Fold | Give up vs the bet |
| `call` | Call | Bluff-catch / thin value / hero call |
| `check_raise_small` | Check-raise small | River value-raise (thin) or blocker bluff-raise, small sizing |
| `check_raise_big` | Check-raise big | River value-raise (strong) or polar bluff-raise, large sizing |
| `mixed` | Mixed / close | Solver mixes call/fold or call/raise meaningfully |

**No new actions in v4.4.0.** BB is OOP and has checked the river; villain bets; BB folds / calls / check-raises. The 5-action menu maps cleanly: "check-raise" IS the river raise (BB checks, villain bets, BB raises). Keeping the menu identical leverages learner familiarity AND the runtime normalization layer (`_pfNormalizePostflopChoices` / `_pfNormalizePostflopAnswer`) with zero new normalizers.

Donk-leading the river (BB betting before villain) is documented out-of-scope (§5); if added later the ids would be `donk_small` / `donk_big`.

---

## 10. Answer partition philosophy

Same partition discipline locked since v4.2.5 (M3) and carried through M4:

- **best**: one action representing the highest-EV solver choice (or the dominant choice on close-to-pure spots).
- **acceptable**: actions within ~5% EV of best, OR that solver mixes meaningfully (15%+).
- **bad**: clearly losing-EV actions that are not severe punts.
- **critical**: uniquely worst-bad actions — folding a rivered nut hand, calling a busted draw, stationing a dominated pair on a draw-complete river, over-folding a mandatory bluff-catcher.

**Critical-flag discipline** (carried from v4.2.5 / M4):
- Do NOT mark close mixed alternatives as critical.
- Do NOT mark sizing errors as critical (an oversized value raise is bad, not a severe punt).
- DO mark concept punts as critical (folding the nuts; calling a no-showdown busted draw; over-folding well below MDF with a clean bluff-catcher).

---

## 11. Critical mistake philosophy

Module 5 critical mistakes should be ~25-35% of the 24 seeds (mirroring M3's 30.6% and M4's 69.6%-recalibrated-toward-target discipline — M5 aims for the 30-40% band given the river's stark right/wrong nature). Justified river critical flags:

| Mistake type | Example | Why critical |
|---|---|---|
| Fold the rivered nuts | Fold a made straight on a blank river facing a normal bet | Severe punt; hero beats the entire value range |
| Call a busted draw | Call with missed flush draw (no pair, no blocker) facing a bet | Pure spew; 0% to be good at showdown |
| Station a dominated pair on a draw-complete river | Call second pair (no flush) on a flush-completing river vs a large bet | Bleeds into a value-heavy range |
| Over-fold a mandatory bluff-catcher | Fold top pair good kicker on a brick river vs a small bet | Folds well below MDF; villain auto-profits bluffing |
| Bluff-raise with no blocker | Check-raise a busted draw holding no nut blocker into a polar range | No fold equity; spews stack |

---

## 12. Future migration path (v4.4.x)

Module 5 in v4.4.0 is **planning-only**. The migration path mirrors v4.3.0 → v4.3.2:

| Future sprint | What it does |
|---|---|
| **v4.4.0** (this sprint) | 5 planning docs + 24 seed scenarios + seed audit script. No production data. No runtime. |
| **v4.4.0A** (suggested next) | Strategic seed review (24 scenarios reviewed for river poker correctness — especially made-hand evaluation, blocker claims, MDF math); fix flagged seeds builder-first. |
| **v4.4.0B** (sanity repair, if needed) | Raw-content review for any defects the mechanical audit can't catch (mirrors v4.3.0-preA). |
| **v4.4.1** (production migration) | Migrate 24 seeds to `postflop/postflop_scenarios.json`. Production audit 477/0/0 → 501/0/0. Add R76+ M5-specific rules to `tools/audit-postflop-ps.ps1`. |
| **v4.4.1A/B** (data expansion + polish) | Expand 24 → ~60-90 M5 scenarios (mirroring v4.3.0C / v4.3.0D pattern). |
| **v4.4.2** (runtime wire) | TRAINING_MODES.m5 preview → secondary; postflop:m5 route; M5 question/answer rendering using the same string-form schema; `riverLogic`-prominent feedback block. |
| **v4.4.2x** (UX polish + Beta QA dashboard) | Reuse `_pfBetaQAStatsForModule('pf_river_barrel_oop_def')`; mobile QA at 320/360/375/414. |

---

## 13. Future runtime path

When M5 ships its first runtime (planned v4.4.2), the wiring is simpler than M3's was because all architectural keystones already exist from M3/M4:

1. **Schema normalization layer is reused** — `_pfNormalizePostflopChoices` + `_pfNormalizePostflopAnswer` already handle string-form choices/best. M5 uses identical choice/answer schema.
2. **Action labels are reused** — the 5-action label map covers all M5 actions. No new label map needed.
3. **Question prompt template extends M4** — BB-defending framing extends from turn to river with a small variant (mention river card + third-barrel context + the full 5-card runout).
4. **Teaching-block layout is reused** — `_pfM4TeachingFeedbackBlocksHtml` becomes `_pfM5TeachingFeedbackBlocksHtml` with `turnLogic` → `riverLogic` field rename.
5. **Concept Library is extended** — add 12 M5 concept entries with `module: 'm5'`. Pattern-identical to M4's 12 entries.
6. **Mastery checklist is reused** — `_pfM5MasteryStats` is a thin wrapper over the M4 mastery pattern with the M5 module id.
7. **5-card board renderer** — the only genuinely new runtime UI: render 5 cards (flop + turn + river) with the river card visually distinct (analogous to M4's turn-card amber pill). Mobile 320px must fit 5 cards (5×56 + 4×12 = 328px > 320 — so the river renderer needs a slightly smaller card or tighter gap at 320; flagged as the one real M5 mobile-QA risk).

The reuse pattern means M5 runtime wire is ~250-350 lines of new code, with the 5-card mobile layout being the main net-new design problem.

---

## 14. How the v4.2.6 QA dashboard pattern supports M5 later

The v4.2.6 dashboard was designed module-agnostic and v4.3.2C fixed signal persistence so multi-session aggregation works:

```js
// existing module-agnostic helper:
_pfBetaQAStatsForModule(moduleId)

// future v4.4.2x wrapper (one line):
_pfM5BetaQAStats() { return _pfBetaQAStatsForModule('pf_river_barrel_oop_def'); }
```

When M5 launches, the dashboard immediately surfaces M5 sessions, accuracy by actionReason, weak-spot review effectiveness, critical-mistake monitor, and cross-module comparisons (flop vs turn vs river defense accuracy). The v4.3.2C per-answer persistence fix means M5 multi-session aggregation works from day one.

---

## 15. Risks + mitigations

| Risk | Mitigation |
|---|---|
| River poker correctness is unforgiving — a mis-evaluated made hand (straight/flush/boat) is an outright lie | v4.4.0A strategic review pass enumerates every made-hand claim on the full 5-card runout; auditor R-rules enforce `handClass=straight` requires 5 consecutive ranks, `flush` requires 5 of a suit across hero+board, board-pair boats checked |
| "River = no equity" is a hard mental switch; seeds must never frame a call as "equity realization" | New `riverLogic` field + actionReason vocab has NO equity-realization reason; auditor R-rule bans `equity_realization` / draw-equity language in river explanations |
| Busted-draw-call is the cardinal river sin; seeds must classify it critical | Critical-flag discipline (§11) + auditor warns if a `missed_draw` / busted-draw hand has `call` in best/acceptable |
| MDF math errors (wrong defend % per sizing) | `villainRiverSizing` field + per-sizing MDF table (§3/§7.3) + per-scenario `riverLogic` states the math; reviewer checks |
| Blocker claims (nut flush blocker etc.) must match hero's actual cards | Auditor R-rule (mirror M4.R53): if blockerNote claims "nut <suit>" hero must hold A of that suit; flush board requires the suit present 3+ on board |
| 24 seeds is thin for a river module (rivers have the most board states) | v4.4.0 = planning only; v4.4.1A expansion grows to ~60-90 using the v4.3.0C/D pattern |
| 5-card mobile layout may overflow 320px | Flagged in §13; resolved at runtime-wire sprint (v4.4.2) with the iframe harness from v4.3.1B |
| Over-fold vs station — the two opposite leaks — must both be represented so the module doesn't teach one-sided | Seed distribution explicitly includes both over-fold-trap (must-call) and station-trap (must-fold) scenarios; coverage audit checks both `range_disadvantage_river_fold` and the call-side reasons are present |

---

## 16. Sign-off checklist

- [x] Module purpose stated (BB River Defense OOP)
- [x] Spot assumption locked (NLH_MTT 100BB SRP, BTN 3-barrel vs BB, river decision)
- [x] Scope intentionally narrow (BB river defense only; IP-betting = Module 6, donk/probe out of scope)
- [x] Learning goals enumerated (12 items)
- [x] Out-of-scope items documented (8 items, each with future-module promise)
- [x] Action menu identical to M3/M4 (intentional consistency)
- [x] Schema additions documented (companion schema-taxonomy doc)
- [x] Strategic concepts enumerated (12 concepts, mapped to actionReason vocabulary)
- [x] River-card categories defined (6 used in seeds)
- [x] River math = showdown/MDF math, not pot-odds+equity (the central switch)
- [x] Future migration path documented (v4.4.0A → v4.4.2x)
- [x] Reuse-from-M3/M4 pattern documented (normalization, labels, dashboard, mastery, TCC)
- [x] Risks + mitigations documented (river poker correctness front-and-center)
- [x] No production data touched
- [x] No runtime wiring touched
- [x] No version bump

**Status: PLANNING-ONLY · APPROVED FOR v4.4.0 PLANNING COMMIT.**
