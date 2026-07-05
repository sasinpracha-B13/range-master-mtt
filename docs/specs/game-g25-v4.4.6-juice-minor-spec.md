# G2.5 · v4.4.6 Juice Minor — Design Spec (FOR REVIEW · nothing built)

**Status:** SPEC ONLY. spec → owner review → build → QA evidence → review → approval → commit.
**Date:** 2026-07-05
**Scope:** game layer + one player-facing bug fix. Data byte-identical; validator 510/0/0; FX via v4.4.3 pipeline (Sound/Motion toggles + reduced-motion); 320×700 verified at build. Owner guards from the approval are restated inline as build gates.

---

## 1. 🎲 All-in Confidence

- **Where:** At-the-Table frames only (action_choice M2–M5). **Hard-disabled in Boss mode and in Table Read frames** (owner guard — table fiction stays coherent; no mid-exam meta-decisions).
- **Flow:** an "🎲 ALL-IN" button sits above the choices, **once per session**. Tap → armed state ("ALL-IN DECLARED — this hand counts ×5 or nothing") → answer that same hand:
  - game-tier **best** → **Score ×5** for that hand (banner explosion + fanfare) — *Score only; Stack/EV follows normal rules untouched (owner guard).*
  - anything else → **Score 0** for that hand (muted womp); Stack/EV normal; combo rules unchanged (all-in never touches combo/Stack/XP-rate beyond the points themselves).
- Consumed on the hand it was armed on, win or lose. State: `d.game.allInUsed / allInArmedIdx`.
- Teaches confidence calibration for free: declare only when you *know*.
- New badge: 🎲 **Stone Cold** — win 5 all-ins lifetime (`allInWins`).

## 2. 🛍️ Cosmetic Shop ("The Chip Shop")

- **Wallet guard (owner-locked):** spending uses a separate Score-wallet: `wallet = lifetimeScore − spentScore`. Purchases increment `spentScore` ONLY — **`xp`, rank, and `lifetimeScore` never decrease** (QA proof required: buy → xp/rank/lifetimeScore unchanged, wallet down).
- **Catalog v1 (all pure CSS — class/variable swaps; card FACES stay white for readability, so skins target surfaces around them):**

| Slot | Items (price in Score) |
|---|---|
| Table felt | Midnight (free/default) · Royal Blue **1,500** · Crimson Room **3,000** |
| Card frame | Classic (free) · Gold Trim **2,500** · Neon Edge **5,000** |
| Combo flame | Classic Fire (free) · Teal Blaze **2,000** · Violet Inferno **4,000** |
| App accent | Gold Rush theme **10,000** (long-term sink) |

- UI: "🛍️ Chip Shop" section on the Progress tab under the Player Card — swatch grid with Buy / Own / Equipped states + wallet readout; equip applies instantly (body-level classes / CSS vars).
- Storage: `rmtt_gamestats.spentScore`, `cosmetics { owned[], equipped{} }` — **loader round-trip includes the new fields (build gate: the recurring dropped-fields bug class, pre-empted).**

## 3. 🔥 Heater State

- Visual/audio only, **zero gameplay effect** (owner guard). Static class tiers (no continuous animation → zero perf cost):
  - combo ≥ 4 → table "warm" (subtle amber glow on the question card frame)
  - combo ≥ 8 → "heater" (stronger glow + ember tint + flame already roars from v4.4.3)
  - combo break by critical → **"breathe" beat**: 1.2s dim overlay + "Breathe. Run it back." (non-blocking, motion-gated)
- Motion toggle + `prefers-reduced-motion` respected (glow tiers render as static styles even when motion is off; the breathe overlay is skipped).

## 4. 🧾 Cash-out Receipt

- Session-complete button "🧾 Cash-out Receipt" → **canvas-rendered** receipt image (~400×640, dashed-border casino-receipt aesthetic): app name, date, mode, hands, tier counts, **Session EV (BB)**, Saved BB, Score, best combo, rank.
- **Units are BB/points only; footer prints "TRAINING SESSION · study tool — not real money"** (owner guard). Local-only: `canvas.toBlob` → download link + Web Share API *if available* (guarded; still local file share, no network).
- Available on normal/daily/revenge summaries + boss review (mode printed on the receipt).

## 5. 🔧 Curriculum-card fix (m4/m5 Locked-button bug)

- `_pfModuleCardHtml` gains explicit m4/m5 branches mirroring m3: **"▶ Start Module 4/5 Limited Beta"** → `startPostflopDrill('pf_turn_barrel_oop_def'|'pf_river_barrel_oop_def', 12)` — identical behavior/gating to the TCC route (owner requirement) + 📖 Syllabus toggle; syllabus `<details>` blocks added for m4/m5 (arrays already exist in `_PF_CURRICULUM`). Boss button (v4.4.5) stays.

## 6. Storage & risk

New gamestats fields: `spentScore`, `cosmetics`, `allInWins` (+ loader round-trip). Risk: All-in **LOW** (Score-only, frame/mode-gated) · Shop **LOW** (CSS + wallet guard) · Heater **LOW** (static classes) · Receipt **LOW** (canvas local-only; wording guard) · Card fix **LOW** (mirrors proven m3 branch).

## 7. Acceptance (draft)

All-in: once/session enforced · ×5 on best, 0 otherwise · Stack/EV unchanged by all-in in both outcomes · button absent in Boss + Table Read · Stone Cold counts wins only. Shop: wallet math exact; **xp/rank/lifetimeScore unchanged after purchase (explicit QA line)**; equip persists reload; all four slots render. Heater: tiers at 4/8; breathe beat on critical; nothing when motion off/reduced-motion. Receipt: renders all fields; BB/points units; disclaimer footer present; downloads locally. Card fix: m4/m5 cards start correct drills (matches TCC), syllabus opens. Invariants: data byte-identical + 510/0/0 · 0 console errors · 320×700 clean · toggles respected.

## 8. Knobs for review

All-in multiplier ×5 · shop prices (table above) · heater thresholds 4/8 · Stone Cold target 5 · receipt availability on boss review (include **[proposed]** / exclude).

**STOP: awaiting owner review.**
