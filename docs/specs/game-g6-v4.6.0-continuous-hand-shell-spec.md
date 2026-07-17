# G6 · v4.6.0 "Continuous Hand + Shell" — Playable-Slice Spec (FOR REVIEW · nothing built)

**Status:** SPEC ONLY. spec (incl. chain-scan result + tree spines) → owner review → tree-authoring paste-gate → build → QA evidence → review → approval → commit.
**Date:** 2026-07-07 · **Scope:** one sprint = Play/Learn/Profile shell + continuous-hand node player + 2–3 fully-audited authored hand-trees. **`postflop_scenarios.json` stays byte-identical (542, blob `54f134f5…`)** — trees ship in a NEW read-only data file. Inserted ahead of the M4 audit by owner intent (audit baseline banked, waiting).

## 0. The five PINs (owner, binding)

1. **No stitching of mismatched rows** — chains need SAME hero, SAME board, legitimate line at every node; scan first (§1).
2. **Every node hand-verifiable** — `clear_direction` or `mixed_nudge` (+whitelist) per node; a `solver_required` node = that tree does not ship. (The prototype's own "trap the turn with the nut flush" is the cautionary example — a slowplay-vs-raise mix; the v1 spines below deliberately avoid that shape.)
3. **Preflop node source of truth = the locked chart** — never re-derived per hand; chart row stated in tree metadata.
4. **Honest UI** — tier badges + est. EV only, zero fabricated percentages; heads-up seats, 100BB labels, pot from the stake derivation, 320×700, motion toggles + reduced-motion, tap-to-skip.
5. **Shell migration is lossless** — reorganizes existing surfaces; nothing removed; every current route ≤2 taps; deep links preserved; route map in §5.

## 1. PIN-1 first deliverable — chain-eligibility scan of all 542 (PS over production JSON, reproducible)

Method: index by (sorted heroHand | flop cards); chain = M3 flop row → M4 turn row (same key, turn extends flop) → M5 river row (same key + same turn). IP mirror: M2 → M6 (no turn-IP module exists → a 2-street skip, never a chain).

| Chain shape | Count |
|---|---|
| **FULL OOP chains (M3→M4→M5, same hero + board lineage)** | **0** |
| Partial M3→M4 (same hero + flop, turn extends) | 10 |
| Partial M4→M5 (same hero + flop + turn) | 0 |
| IP M2→M6 (same hero + flop) | 0 |

**Verdict: the expected near-zero.** The 10 partials split on the M3 row's own verdict:

- **4 legitimate partial chains** (M3 best = `call`, so the M4 node's assumed check-call line is coherent): `Th8h @ As8d3h(+2c)` · `6s5s @ Ks8s3d(+2s)` · `5h5d @ 8c8d3s(+3h)` · `8c7c @ Ts9s5d(+6h)`. Each still lacks a river → not shippable as-is; kept as an OPTIONAL "extend-with-authored-river" candidate set (knob §8).
- **6 SELF-INCONSISTENCY FINDINGS — banked for the M4 audit (item 2):** the corpus contradicts itself: the M4 row assumes hero check-called the flop, but the SAME hero on the SAME flop has an M3 row whose best is `check_raise_small` (5 pairs: `8c8h @ As8d3h` set of 8s · `9c9s @ 9d8c6h` set · `TcTd @ Ts9s5d` top set · `As6s @ Ts9s5d` · `Tc7c @ 9d8c6h`) or `fold` (1 pair: `5h4d @ QsTs6d`). These are leg-(c) (missed check-raise) and leg-(b) (should-have-folded) violations **proven by the corpus's own verdicts, zero judgment required** — they feed the audit's evidence list directly.

**Therefore v1 = AUTHOR 2–3 NEW hand-trees** through the full seed pipeline (builder → per-node auditor incl. R24–R29-class rules → chat paste-gate line review of every street verdict). Zero discount on the audit regime.

## 2. v1 tree spines — 3 proposals (every node clear_direction; no mixed, no slowplay nodes)

Per-node stake reuses the **existing street-stake derivation** (owner-locked v4.4.3 table — no new knobs): preflop 2 · flop 3 · turn 5 · river by sizing 7/13/20/30. Menus reuse each street's existing module menu + labels; preflop adds a 3-option menu (fold / call / 3-bet) with new labels.

**TREE A — "The Nut Draw Arrives" (BB defend · payoff finale)** · hero **Ah9h** · board **Kh 6h 2c / 5d / Qh** · chart row: `A9s = flat member (not in the 3-bet set {QQ+, AK, AQs, part A2s–A5s})`

| Node | Facing | Menu | Best | Acc | Bad/Crit | Why it's clear |
|---|---|---|---|---|---|---|
| P | BTN 2.5x | fold/call/3bet | call | 3bet? NO — chart: flat member → acc=[] | fold=bad | chart-sourced (PIN 3) |
| F Kh6h2c | cbet 33% | fold/call/raise_s/raise_b | call | raise_s (semi-bluff) | fold=**crit** (folding the NUT flush draw to a small bet) | NFD + overcard = mandatory continue; combo-verifiable |
| T 5d | barrel 66% | fold/call/raise_s/raise_b | call | raise_s | fold=bad | nut draw + A-over, one card from the nuts w/ nut implied odds — outs/implied argument, no frequency |
| R Qh | barrel 75% | fold/call/raise_s/raise_b | **raise_s (value)** | call | fold=**crit** | NUT FLUSH vs polar barrel = house-precedent nut-flush value-raise (B.2 v4.4.1A); zero combos beat |

**TREE B — "The Correct Fold" (BB defend · the MDF lesson as a finale — 'Saved X BB' banner moment)** · hero **QcJc** · board **Jh 8d 3s / 7c / As** · chart row: `QJs = flat member`

| Node | Facing | Menu | Best | Acc | Bad/Crit | Why it's clear |
|---|---|---|---|---|---|---|
| P | BTN 2.5x | fold/call/3bet | call | — | fold=bad, 3bet=bad (not in 3-bet set) | chart-sourced |
| F Jh8d3s | cbet 33% | fold/call/raise_s/raise_b | call | — | fold=bad, raises=bad (thin) | TPGK never folds vs small; raise isolates |
| T 7c | barrel 66% | fold/call/raise_s/raise_b | call | — | fold=bad, raises=bad | pure bluff-catch, M4 house-standard TP call (T9 turned straights live = disclosed) |
| R As | barrel 75% | fold/call/raise_s/raise_b | **fold** | — | call=bad, raises=**crit** | A-river smashes the triple range (Ax + turned T9); QJ = 2nd pair beats only air — board_change/range_disadvantage fold, M5-precedent. **Arrived correctly + folds correctly = the not-a-violation lesson made playable** |

**TREE C — "The Bettor's Line" (BTN IP · seat-flip tree, reuses M6 logic)** · hero **AdKd** · board **Ac 8s 4s / 6h / Qc** · chart row: `AKs = BTN RFI raise (100BB_BTN_RFI, exists in ranges.json)`

| Node | Facing | Menu | Best | Acc | Bad/Crit | Why it's clear |
|---|---|---|---|---|---|---|
| P | folded to BTN | fold/open2.5 | open | — | fold=**crit** | literal chart row (strongest PIN-3 case) |
| F Ac8s4s | BB checks | check_back/bet_s/bet_b | bet_s | — | check=bad, bet_b=bad | TPTK range-bet on A-high = M2 house standard |
| T 6h | BB check-calls, checks | check_back/bet_s/bet_b | bet_b | check_back (pot-control) | bet_s=bad (undersized vs draws) | top-top charges spade draws + worse Ax (75s turned straight = rare, disclosed) |
| R Qc | BB checks | check_back/bet_s/bet_b/overbet | **bet_s (thin value)** | check_back | bet_b=bad, overbet=**crit** | M6 B-row logic verbatim: dominated Ax ladder pays small; polar sizes isolate vs AQ/A8s promotions |

Every node names its reason from the street's EXISTING vocab (M3/M4/M5/M6 + 2 new preflop reasons). Paste-gate: all 12 node verdicts + prose delivered as chat text before build, per the standing convention.

## 3. Data + engine (new content, zero scenario-file churn)

- **New file `postflop/postflop_trees.json`** (read-only, SW-cached like the other data files): `{ trees: [ { id, seat, heroHand, board{flop,turn,river}, preflopChartRow, nodes:[ { street, facing, prompt, choices[], answer{best/acc/bad/crit}, verdictBasis, actionReason, stakeBasis, explanation{short, streetLogic, rangeContext, handLogic, sizingLogic, commonMistake, takeaway}, blockerNote? } ] } ] }`. Schema `tree-1.0.0`.
- **Pipeline:** `tools/build-trees-v4.6.0.ps1` (source of truth) → `tools/audit-postflop-trees.ps1` — per-node rules reusing the M6-auditor classes (partition/enums/verdictBasis hard-block/prose lints/R24-R29 analogues incl. the boat-or-better recompute where applicable) PLUS tree-level rules: same hero across nodes · board lineage integrity · card-collision across all 7 cards · `preflopChartRow` present + consistent with the banked baseline · **any `solver_required` node fails the whole tree**.
- **Node player:** new `startPostflopTree(id)` + `mode:'tree'` (strict-equality isolation, house pattern). Reuses: tier engine, two-account regret (stake per node per §2), per-street teaching renderers (M3/M4/M5 blocks + M6 river renderer for IP), SFX/FX, XP/score stream. Between-street beat: card-deal animation (flop 3-stagger, turn/river flip) with tap-to-skip + reduced-motion (PIN 4). End screen: per-node tier strip + hand P&L line + replay.
- **Storage:** new key **`rmtt_trees`** `{ perTree: { id: { runs, bestTiers[], lastResult } } }` — loader round-trip gate (standing).

## 4. What the slice deliberately does NOT do

No branching runouts (linear scripted board per tree — branch trees are a later program) · no tournament integration (trees stay a Play-tab mode; FT stays scenario-based) · no tree Boss/mastery/BetaQA yet · no Range-Reveal chip in tree mode.

## 5. PIN-5 shell — Play / Learn / Profile (lossless route map)

Bottom tab bar, 3 tabs. **All existing route ids unchanged** — the shell re-homes the launchers, not the routes.

| Today (TCC tile / surface) | After | Taps |
|---|---|---|
| Full Hand (NEW) | **Play** → Deal group, top slot (`postflop:tree`) | 2 |
| Tournament / Daily / Boss / Revenge | **Play** → Deal group (`postflop:tourney/daily/boss/revenge`) | 2 |
| M1–M6 drills | **Play** → "Practice a street" group (`postflop:m1..m6`) | 2 |
| Curriculum cards + syllabi + per-card Boss buttons | **Learn** (top) | 2 |
| Concept Library (75) + concept drills | **Learn** | 2 |
| Academy strip, mastery checklists ×6 | **Learn** | 2 |
| BetaQA dashboards ×4 + Copy Snapshot | **Learn** (collapsed, owner-view as today) | 2 |
| Player Card (XP/rank/badges), trophy shelf | **Profile** | 2 |
| Chip Shop, Cash-out Receipt, Saved-BB ledger | **Profile** | 2 |
| Settings toggles (sound/motion/personas/beta) | **Profile** (link to Settings tab unchanged) | 2 |

Boss deferral, mode isolation, Daily determinism, preflop trainer, and every standing invariant untouched. QA asserts: every pre-shell route reachable and identical post-shell.

## 6. Gates (draft)

`postflop_scenarios.json` byte-identical (blob `54f134f5…`) + validator 542/0/0 · trees file has its own auditor: **3/0/0** (per-node + tree-level) · paste-gate passed before build · in-tree deltas equal the same street-stake math as modules (in/out equality analogue) · `rmtt_trees` loader round-trip · every pre-shell route reachable ≤2 taps + deep links intact · 320×700 across tree player + all 3 tabs · 0 console errors · appVersion + SW bump.

## 7. Deliverable order

1. **This spec** (scan result §1 + spines §2) → owner review.
2. Tree authoring → **paste-gate** (all nodes, verdicts + prose verbatim, chat text).
3. Build (trees file + node player + shell) → QA evidence → review → approval → commit (standard 2-commit + snapshot).

## 8. Knobs

(a) tree count: 3 as specced (A/B/C) vs 2 (drop one — if so, keep A+B: one payoff + one fold-discipline) · (b) the 4 legitimate M3→M4 partials as "extend-with-authored-river" candidates for a later batch (not v1) · (c) preflop node included (as specced) vs postflop-only trees · (d) shell default tab = Play · (e) Full-Hand entry badge copy ("NEW").

**STOP: awaiting owner review — spines §2 and the shell map §5 are the decision surfaces. The 6 self-inconsistency findings (§1) are banked for the M4 audit regardless of G6 choices.**
