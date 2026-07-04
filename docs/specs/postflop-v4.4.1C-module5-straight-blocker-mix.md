# Postflop v4.4.1C — Module 5 Straight-Blocker Mix (+1; 509 → 510)

**Status:** SHIPPED (production data + cache bump). M5 = 33, all `approved`, still **NOT routed** (v4.4.2).
**Date:** 2026-06-18
**Predecessor:** v4.4.1B (`b2746be`, M5 correctness hotfix)
**Origin:** consultant concept-spec (adversarially cleared the T9s-on-J9842 candidate); implementer owned board/hand final say + full combinatorial pass. Closes BOTH remaining v4.4.1A/B token gaps — one by data, one by re-scope.

---

## 1. What shipped

| Artifact | Change |
|---|---|
| `postflop/postflop_scenarios.json` | 509 → **510** (+1 M5; M5 32 → 33). Description refreshed. |
| `tools/build-m5-expansion-v4.4.1C.ps1` | NEW single-seed builder (source of truth for the scenario). |
| `tools/audit-postflop-module5-expansion-v4.4.1C.ps1` | NEW per-sprint auditor (v4.4.1A layer re-issued for v4.4.1C tokens; v4.4.1A file untouched). |
| `tools/migrate-module5-expansion-v4.4.1C.ps1` | NEW add-not-replace two-phase migration (base check 509/32 → 510/33). |
| `docs/specs/postflop-v4.4.1C-module5-expansion-seeds.json` | NEW 1-seed planning JSON. |
| `index.html` / `service-worker.js` | `4.4.1B → 4.4.1C`. |

## 2. The scenario

**`pf_btn_v_bb_srp_100bb_river_Jc9d8s_2c_m5_reason_Th9h_v441c`** — reason_choice, difficulty 4.
Board **Jc 9d 8s / 4h / 2c** (brick river on a straight-possible runout — an M5-first combination), hero **Th 9h** (second pair), villain sizing **medium**.
`recommendedAction=mixed`, `actionReason=mixed_indifference_river`; answer: best=`mixed_indifference_river`, acceptable=`[bluff_catch_river]`, bad=the other 10 (including the featured trap `blocker_bluff_catch_river`), critical=`[]`.

**The lesson (both asymmetry roots, per spec):**
- **Magnitude:** the Ah blocks **100%** of the nut flush (the nut flush requires the Ah); a straight-blocker holds 1 of 4 cards of a rank → removes only **~25%** of each straight (QT, T7).
- **Sidedness:** the Ah is one-sided (flush-board bluffs don't need it); the T is **two-sided** — QT/T7 *value* and KT/AT *busted open-enders* use the same tens, so value and bluffs shrink together and the ratio barely moves.
- Therefore the blocker is a **nudge, not a rule** → honest verdict = mix. Picking `blocker_bluff_catch_river` here is the misconception, addressed head-on in `commonMistake`.

## 3. Independent verification (implementer-owned, re-derived from scratch)

1. **Straight census on J-9-8-4-2:** two-card straights only — `QT` → Q-J-T-9-8 (nut) and `T7` → J-T-9-8-7. Every other 5-run (K-Q-J-T-9, T-9-8-7-6, 5-6-7-8-9, wheel…) needs ≥3 hand cards → impossible. **No one-card straights.** Both live straights require a ten; hero's Th removes 4→3 of villain's tens = **25%** of each (QT 16→12, T7 16→12 combos). ✓
2. **Hero's hand:** Th9h + Jc9d8s4h2c = **pair of nines** (second pair under the J), kickers J-T-8. **No straight** (J-T-9-8 needs Q or 7). ✓
3. **Two-sided check:** bluff pool = busted straight draws only — KT/AT (open-enders, **use a ten** → hero blocks 25%), KQ/AQ (gutshots at the T), 76 (OESD), 65 (gutshot). Hero's T sits on **both** sides. ✓
4. **Suit lock (exceeds spec):** flop Jc 9d 8s is **rainbow** → no flush draw ever existed on the runout; hero's hearts touch only the 4h (3 hearts max across hero+board). The lesson is 100% straight-only. ✓
5. **Mix verdict:** hero beats *every* bluff and *every* underpair, loses to *all* value (Jx, TT, QQ+, two pair, sets, QT/T7) → textbook indifference-zone bluff-catcher, **below** the median defender (Jx/TT) at the ~29% medium-bet price. Not a pure fold, not a pure call. ✓ (Adversarial consultant review independently cleared the same three challenges.)
6. **Realism:** T9s is a pure BB flat vs 2.5x. Line coherence: flop = second pair + OESD (auto-peel), turn 4h keeps the OESD live (auto-peel), river 2c misses → the decision point is genuinely reached. ✓

## 4. Deviations from the brief (disclosed)

1. **`acceptable=[bluff_catch_river]`** (brief said `acceptable=[]`). Reason: the shipped mixed reason_choice precedent (AhJc, v4.4.1B) uses exactly this partition — at indifference, the call-branch reason is half-right; scoring consistency across the corpus wins. `blocker_bluff_catch_river` goes to **bad** (the featured trap), which is *stronger* than the brief's minimum.
2. **Terminology fix:** the brief called J-T-9-8 "a gutshot missing Q/7" — four consecutive ranks needing either of two cards is an **open-ended straight draw** (8 outs). All shipped prose says open-ender. (4th consultant math/terminology slip caught across these reviews; verdict unaffected.)
3. **Q9s contrast refined:** Q9s is not blocker-free — its Q still trims the QT nut straight (and KQ/AQ bluffs). The honest contrast, as shipped in `handLogic`: *both* T9s and Q9s end up mixing, proving **no single straight-card removes enough combos to flip a verdict** — which is the actual point of the lesson.

## 5. Token-gap closure (curriculum bookkeeping)

- **`domination_river_fold` → CLOSED as distractor-only, by design.** It already serves as a distractor in the `bad` list of 3 shipped reason_choice scenarios (AhJc, Ah9c, Ad6c). The "0 examples" gap was a counting artifact (counting `best` only). Target best-count = **0 by design**; do NOT author a `best=fold` for it (structural finding, v4.4.1B round: a made hand beats few bluffs only via board_change or blocker effects — a pure "domination fold" has no GTO home distinct from other tokens).
- **Straight-blocker `blocker_bluff_catch_river` → CLOSED as "taught via mixed + curriculum note."** The data home is THIS scenario (best=mixed, blocker framed as a nudge); a second `best=blocker_bluff_catch_river` would overstate a two-sided 25% effect.
- **Both removed from the open-gap list.** Remaining backlog: V1–V3 (chart/solver-gated), full M4 review (~10/92 spot-checked).

## 6. Scheduled for v4.4.2 (runtime wire) — curriculum note

Add to the **`river_blocker_defense`** concept entry (runtime copy; do not mutate historical planning docs):
> *Flush vs straight blockers are not symmetric: the Ah deletes 100% of the nut flush and blocks no bluffs (one-sided); a straight-blocker is one of four cards of a rank and sits in both the value straights and the busted open-enders (two-sided, ~25%) — a nudge that produces mixes, not a rule that produces calls.*

## 7. Verification

- Seed audit (v4.4.1C per-sprint auditor, full R76–R93-ported checks + cross-corpus dup-ID): **1/0/0 PASS**.
- Two-phase migration: dry-run → review_pending → production audit **510/0/0 PASS** → FlipApproved → **510/0/0 PASS** (M1–M4 unchanged 251/49/85/92; M5 33 approved).
- No new one-pair fold/call carries `critical` (critical=`[]`).
- Runtime smoke test (preview, caches cleared): `ready=true error=null`, **510/510 approved**, M5=33, new scenario present with `best=mixed_indifference_river / acc=[bluff_catch_river] / sizing=medium / v=v4.4.1C / approved`, **0 console errors**.
- Cache bump: appVersion `4.4.1B → 4.4.1C`; SW `v4.4.1B → v4.4.1C`. File-level schemaVersion stays `1.0.0`.

**Status: SHIPPED · production 510/0/0 · M5 = 33 · both token gaps closed · M5 not routed (v4.4.2 next).**
