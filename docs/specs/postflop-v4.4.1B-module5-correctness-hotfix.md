# Postflop v4.4.1B — Module 5 Correctness Hotfix (count unchanged: 509)

**Status:** SHIPPED (production data + cache bump). 9 existing M5 scenarios patched; **no scenarios added/removed** (509 total, M5 = 32). M5 still data-only / not routed.
**Date:** 2026-06-18
**Predecessor:** v4.4.1A (`0240f78`, M5 expansion 24→32)
**Origin:** a consultant (advisory AI) poker review proposed FIX 1/2/3 (APPLY) + V1–V3 (VERIFY-only). The implementer (this agent) independently verified the poker, applied the three fixes, **corrected two combinatorial errors in the consultant's stated reasoning**, caught two extra in-scope scenarios, and left V1–V3 untouched as backlog.

---

## 1. What changed

Applied via NEW idempotent narrow-scope tool `tools/hotfix-module5-v4.4.1B.ps1` (UTF-8 NO-BOM, atomic tmp+Move-Item, no Invoke-Expression). All 9 patched scenarios get `version=v4.4.1B`.

### FIX 1 — `critical` reserved for severe punts only
A one-pair fold/call is an over-fold/over-call leak, **not** a severe punt (severe = fold-the-nuts / call-with-zero-SDV / raise-into-a-crushing-range). Downgraded `answer.critical → []` on **6** one-pair scenarios:

| ID (suffix) | hand | best | was critical |
|---|---|---|---|
| Ks9d4c_7s …KdQh | TPTK | call | [fold] |
| Js8d5c_Ac …KcJd | mid pair | fold | [call] |
| Qh9h4c_7h …QcJs | TPGK (no heart) | fold | [call] |
| 9d8c4h_7h …Ad8d | mid pair | fold | [call] |
| **Kd7s3c_7d …KhJc** | top pair | call | [fold] |
| **Kd7s3c_7d …QcJd** | 2nd pair | call | [fold] |

> The consultant listed only the first 4. An acceptance sweep ("no one-pair fold/call carries `critical`") found the last 2 — the identical pattern — so they were folded into the same fix. Post-fix sweep: **0** one-pair fold/call scenarios carry `critical`.

### FIX 2 — AhQc / AhJc monotonicity on `Ad 8s 5c 2h Kd`, overbet
The two top-pair aces were **non-monotonic**: the *weaker* AhJc was a clean `call` while the *stronger* AhQc was `mixed` — backwards (a strictly stronger hand cannot continue strictly less). Corrected:
- **AhQc** (action_choice): `mixed → call`; actionReason `mixed_indifference_river → bluff_catch_river`; answer best=`call`, acceptable=`[mixed]`, bad=`[fold,check_raise_small,check_raise_big]`, critical=`[]`.
- **AhJc** (reason_choice): `call → mixed`; actionReason `bluff_catch_river → mixed_indifference_river`; answer best=`mixed_indifference_river`, acceptable=`[bluff_catch_river]`. AhJc is the bottom of the defending ace class (it loses to villain AQ, which AhQc beats), sitting at the ~37.5% overbet threshold = genuine mix.

**Implementer correction (verdicts kept, reasoning fixed):** the brief's math said "hero's Ah blocks AhKx." That is **wrong** — villain's AK uses Ac/As (Ad is on the board, Ah is hero's), so the Ah blocks **none** of villain's AK. The Ah only reduces villain's **AA** (3→1 combos). AhQc's edge over AhJc is the **kicker** (it beats villain's worse-ace value and chops AQ). All explanation fields + blockerNote were rewritten to this correct logic; the "villain over-barrels in practice" exploit sentence was deleted per the brief.

### FIX 3 — Ah9c sizing `large → medium` on `Qh 9h 4c 2s 7h`
Pair-of-9 + nut-flush blocker is a cleaner call against a medium bet than a pot bet. `board.villainRiverSizing: large → medium`; explanation rewritten.

**Implementer correction:** the brief's math said villain "makes a flush with a SINGLE heart." On a **three**-heart board a flush needs **two** hearts in hand. The conclusion (Ah is a *weak* value-blocker) still holds — it blocks only the nut-flush (Ah-x) combos while villain's King-high and lower flushes remain — so the explanation was rewritten with correct combinatorics (medium ~66% → BB needs ~29%, clears it; pot → flush-dense value range, would be a fold).

---

## 2. Implementer review notes (mechanical audit is not enough)

The verdicts the consultant proposed are all **defensible** and were applied. But the *stated reasoning* contained two combinatorial errors that would have shipped poker-incorrect prose:
1. **"Ah blocks AK"** on Ad8s5c2hKd — false (AK uses the other aces). Real effect: reduces AA only.
2. **"single heart makes a flush"** on a 3-heart board — false (needs two). Real effect: Ah blocks only nut-flush combos.

Both were corrected in the shipped explanations. This is the standing discipline in action: apply reviewed verdicts, but never propagate incorrect reasoning.

---

## 3. VERIFY items — left UNCHANGED in production (v4.4.1B chart/solver backlog)

These are **not** shipped on assertion; they need the studio preflop chart or a solver node:
- **V1 — AKo flat realism** (`Ks9d4c_7s …reason_AhKc_v440`): AKo cold-flat vs a 2.5x BTN open at 100bb is rare (mostly 3-bet), and the spot duplicates the K-high TP bluff-catch already in `…action_KdQh`. TODO: swap hero to a hand that genuinely flats and makes a top-pair-ace bluff-catch (e.g. AJs/ATs), or add an explicit "low-frequency mixed flat, shown for the principle" note. (Same class as the v4.4.0A AcKh→8c8h fix.)
- **V2 — offsuit-ace flats**: confirm `Ad6c` (`Ac7d4s_2c …reason_Ad6c_v441a`, A6o, low-freq) against the chart; swap only if the chart flats it pure-0.
- **V3 — M4** (`8d6c3s_Qh …action_AhQc_v430C`): verify (a) AQo is in BB's flat range and (b) the "BB value-favored on the Qh overcard turn" claim; adjust toward call or swap hero if not. Full M4 review still pending (only ~10/92 spot-checked).

---

## 4. Verification

- **Production audit** (`audit-postflop-ps.ps1`): **509 / 0 / 0 PASS**. M5 = 32; sizing large 12 / medium 11 / small 5 / overbet 4 (was 13/10/5/4 — reflects FIX 3).
- **Acceptance sweep:** 0 one-pair fold/call scenarios carry `critical`; monotonicity `continue(AhQc)=call ≥ continue(AhJc)=mixed` holds.
- **Array serialization** verified in raw JSON (`"acceptable": ["mixed"]`, `["bluff_catch_river"]` — proper arrays, not unwrapped scalars).
- **Runtime smoke test** (local preview, cache cleared): `ready=true error=null`, total 509, M5 32; AhQc `best=call acc=[mixed] crit=[] v=v4.4.1B`, AhJc `best=mixed_indifference_river rec=mixed`, Ah9c `sizing=medium`; **zero console errors**.
- **Cache bump:** appVersion `4.4.1A → 4.4.1B`; SW VERSION `v4.4.1A → v4.4.1B`. Top-level file `description` refreshed; file `schemaVersion` stays `1.0.0`.

---

## 5. Acceptance checklist (from the brief)

- [x] FIX 1,2,3 applied; validator passes (509/0/0); version bumped to v4.4.1B.
- [x] No one-pair fold/call carries `critical` (6 fixed, incl. 2 the brief missed).
- [x] `continue-strength(AhQc) ≥ continue-strength(AhJc)` on Ad8s5c2hKd (call ≥ mixed).
- [x] #12 reads `medium` (single source: `board.villainRiverSizing`) and never describes Ah9c as a made flush.
- [x] V1–V3 left UNCHANGED in production; tracked here as the v4.4.1B chart/solver TODO.

---

## 6. Backlog carried forward

- **From v4.4.1A:** `domination_river_fold` (still 0 — needs a counterfeited-two-pair-style board); a distinct `blocker_bluff_catch_river` (still 1 — needs a non-flush, e.g. straight-blocker mechanic). → v4.4.1C / v4.4.2 expansion.
- **V1–V3** above (chart/solver-gated).
- **M4 full review** (only ~10/92 spot-checked).

**Status: SHIPPED · production 509/0/0 · 9 M5 scenarios corrected · count unchanged · M5 not routed (v4.4.2).**
