# UX Plan — v4.0.2 Board Texture Trainer

> **Owner**: UX Subagent.
> **Status**: planning. Pairs with `brief-v4.0.2-module1-board-texture-trainer.md` (Architecture).
> **Audience**: DEV Integration Agent + reviewer.
> **Mobile-first**: 375 px is the design baseline; desktop is a graceful adaptation.

---

## 1. Design principles

1. **Reading the board is a poker skill** — the UI must make board cards the visual focus before the question prompt; the player should look at the board first.
2. **Teach reasoning, not just answers** — feedback shows the *why*. Two-tier reveal (short answer first; expandable detail) prevents wall-of-text fatigue.
3. **Mobile thumbs first** — choice buttons are 56 px tall minimum, full-width, single column. No tap targets under 44 px.
4. **Visual feedback maps to scoring tier** — colors and icons distinguish best / acceptable / bad / critical. Critical gets an unmistakable amber-bordered card so players notice leaks.
5. **Quiet confidence, not animation overload** — postflop UI does NOT inherit Field FX (the v3.8.x ambient atmosphere). Postflop is an analytical surface; FX would distract from board reading.
6. **Reuse the chrome, replace the body** — top nav, bottom nav, tab labels, page padding stay identical to existing screens. Only the inner content of the postflop screen differs.
7. **Defensive UX** — every render path tolerates missing data (postflop loader failed, beta off, empty pool) and shows a polite placeholder instead of crashing.

---

## 2. Screen inventory

v4.0.2 introduces **5 surfaces**:

| # | Screen | Where it appears | Trigger |
|---|---|---|---|
| 1 | Beta toggle row | Settings tab | Always rendered (when `App.postflop.ready`) |
| 2 | Postflop entry card | Home tab (Mastery) | Rendered only when `postflopBeta=true` AND `App.postflop.ready=true` AND scenarios exist |
| 3 | Question screen | `#postflopScreen` | After `[ ▶ Start Board Texture Drill ]` tap |
| 4 | Feedback screen | `#postflopScreen` | After tapping any answer choice |
| 5 | Summary screen | `#postflopScreen` | After last question answered |

A confirmation modal is reused for the early-exit confirmation; it's not a separate "screen."

---

## 3. Surface 1 — Beta toggle (Settings)

### Position
Insert under the "FX & Animation" section in Settings. Or, if a "Beta Features" subsection doesn't exist, create it just below FX & Animation.

### Markup pattern (matches existing settings rows)

```html
<div class="settings-section">
  <div class="settings-section-title">🧪 Beta Features</div>
  <div class="settings-row postflop-beta-toggle">
    <div class="settings-row-main">
      <div class="settings-row-label">Enable post-flop beta modules</div>
      <div class="settings-row-desc">Adds Board Texture Trainer to Home tab.<br>20 scenarios · audited 2026-05-04 · alpha quality</div>
    </div>
    <div class="settings-row-control">
      <input type="checkbox" id="postflopBetaToggle" onchange="togglePostflopBeta(this.checked)">
    </div>
  </div>
</div>
```

### Visual

- Section title color: same `--text-secondary` as other section titles
- "🧪" emoji prefix communicates beta status without scary "EXPERIMENTAL" framing
- Description shows scenario count + audit date + "alpha quality" warning

---

## 4. Surface 2 — Home entry card (Mastery)

### Position
Append at the bottom of the Mastery tab content, after the existing "Mastery Path" zones list. Spacing: 16 px margin-top from the previous card.

### Layout (mobile, 375 px)

```
┌──────────────────────────────────────┐
│ 🧪  POSTFLOP BETA                     │
│                                      │
│ Module 1                              │
│ Board Texture Trainer                 │
│                                      │
│ Read the board first.                │
│ Range advantage · nut advantage ·    │
│ c-bet sizing family.                 │
│                                      │
│ ──────────────────────────────────  │
│ 20 scenarios · ~10 min                │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ ▶ Start Board Texture Drill     │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

### Visual specs

- Card background: `linear-gradient(135deg, rgba(168,85,247,0.06) 0%, var(--surface) 100%)` — subtle purple tint to distinguish from preflop modules without dominating
- Border: `1px solid rgba(168,85,247,0.30)`
- Border-radius: 12 px (matches existing card style)
- Padding: 16 px
- "POSTFLOP BETA" pill: `rgba(168,85,247,0.20)` background, `#a855f7` text, 10 px text, 1.5 px letter-spacing, uppercase
- "Module 1" label: 11 px, `--text-secondary`, uppercase
- "Board Texture Trainer" title: 18 px, `--text`, semibold
- Description: 13 px, `--text-secondary`, line-height 1.5
- Stats line ("20 scenarios · ~10 min"): 12 px, `--text-secondary`, dimmed by border-top
- Start button: existing `.btn-primary` class (already mint), full-width, 14 px font, 56 px tall

### Empty / disabled states

| State | Render |
|---|---|
| `postflopBeta === false` | Card not rendered at all |
| `App.postflop.ready === false` | Card replaced with: "🧪 Postflop beta · Loading data… (or load failed; see console)" — dim, 12 px |
| `getModule1Scenarios().length === 0` | Card replaced with: "🧪 Postflop beta · No scenarios available for this module." |
| Button disabled while session active | Should not happen — clicking Start always navigates away |

---

## 5. Surface 3 — Question screen

### URL/state
Hash-less; the screen is a `<div id="postflopScreen">` that the navigation function shows by hiding all `.tab-panel` elements and unhiding `#postflopScreen`. Browser back button triggers `exitPostflopScreen()` (with confirm modal if mid-session) — implementation may add a `popstate` listener.

### Layout (mobile, 375 px)

```
┌──────────────────────────────────────┐  ← top nav unchanged
│ ▲ Range Master MTT  ✗ Exit           │  ← contextual top: app name + exit
├──────────────────────────────────────┤
│ Q 4 / 15           ████████░░  53%   │  ← progress
├──────────────────────────────────────┤
│ 📋 SPOT                               │  ← spot context card
│ 100BB · BTN open · BB call · SRP     │
│ Hero: — (board read)                 │
├──────────────────────────────────────┤
│ 🎴 BOARD                              │  ← board card (the focal element)
│                                      │
│  ┌──┐  ┌──┐  ┌──┐                   │
│  │A♥│  │K♦│  │5♣│                   │
│  └──┘  └──┘  └──┘                   │
│                                      │
├──────────────────────────────────────┤
│ ❓ QUESTION                           │
│ Who has range advantage on this      │
│ board?                                │
├──────────────────────────────────────┤
│ ┌──────────────────────────────────┐ │  ← choices (full-width, vertical)
│ │ Preflop raiser (BTN)             │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ Caller (BB)                      │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ Neutral / split                  │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ Split — both meaningful equity   │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

### Top contextual bar

The standard top nav stays. A compact contextual sub-bar shows the session name + exit button:

```html
<div class="postflop-context-bar">
  <span class="postflop-context-label">🧪 Board Texture Trainer · Q 4/15</span>
  <button class="postflop-exit-btn" onclick="confirmExitPostflop()">✕ Exit</button>
</div>
```

### Spot card

- Title row: "📋 SPOT" — 11 px, uppercase, `--text-secondary`
- Body: a single line of badges (stack / position / pot type)
  - Stack pill: `100BB` — green (existing `.tag-stack`)
  - Action pill: `BTN open · BB call · SRP` — blue (existing `.tag-action`)
- "Hero" line: 12 px, `--text-secondary`. For Module 1: always shows `Hero: — (board read)`. (Module 2+ will show actual hand.)

### Board cards

The visual centerpiece. **Larger than preflop hand cards** because the player must read them carefully.

- Board card size (mobile): 56 × 80 px, 12 px gap, centered horizontally
- Card body: white background (matches preflop card style), 8 px border-radius
- Rank: 28 px, semibold, top-left aligned (or centered for symmetry — design choice)
- Suit symbol: 24 px, centered below rank
- Color: red for `h`/`d`, black for `s`/`c`
- Optional subtle drop shadow for depth: `0 2px 6px rgba(0,0,0,0.2)`

### Question card

- Title row: "❓ QUESTION" — same style as SPOT title
- Prompt body: 14 px, `--text`, line-height 1.5

### Choice buttons

- Vertical stack, 8 px gap
- Each: full-width, 56 px tall minimum, 14 px font, semibold, centered text
- Background: `rgba(255,255,255,0.04)` neutral
- Border: `1px solid rgba(255,255,255,0.10)` neutral
- Hover: brightness up + border accent (use mint `#4ade80` for hover/active state)
- Active (mid-tap): scale 0.98 + tactile press shadow
- Touch-only-friendly: no tooltip on hover; choices speak for themselves

### Disabled state

If user double-taps a choice (race condition): button visually disables (dimmed + cursor-not-allowed) and ignores subsequent taps until next render.

---

## 6. Surface 4 — Feedback screen

### Two-tier reveal

```
┌──────────────────────────────────────┐
│ ▲ Range Master MTT  ✗ Exit           │
├──────────────────────────────────────┤
│ Q 4 / 15           ████████░░  53%   │
├──────────────────────────────────────┤
│ ✅ BEST · 1.0 pts                     │  ← result row (color-coded)
│ Your pick: Preflop raiser (BTN)      │
│ GTO best:  Preflop raiser (BTN)      │
│ ──────────────────────────────────  │
│                                      │
│ 💡 BTN's range contains far more     │  ← short explanation (always shown)
│    A-x and K-x; BB 3-bets most       │
│    strong A-x preflop.               │
│                                      │
│ Concept tags                          │
│ • range_advantage                     │
│ • dry_high_card_strategy             │
│ • board_texture_recognition          │
│ • dry_board                           │
│                                      │
│ ▶ Range Logic                         │  ← collapsible (closed on mobile)
│ ▶ Nut Logic                           │
│ ▶ Sizing Logic                        │
│ ▶ Common Mistake                      │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │  Next →                          │ │  ← primary button
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

### Result row colors

| Tier | Icon | Label | Color |
|---|---|---|---|
| `best` | ✅ | `BEST` | mint `#4ade80` background tint, mint text |
| `acceptable` | ≈ | `ACCEPTABLE` | amber `#fbbf24` background tint, amber text |
| `bad` | ❌ | `BAD` | red `#f87171` background tint, red text |
| `critical` | 🚨 | `CRITICAL LEAK` | amber-pulse border, red text + dark amber bg |

The critical row also auto-expands the `Common Mistake` section so the player sees why immediately.

### Expandable sections

Each is a `<details>` element. On mobile, all sections start collapsed (player taps to expand). On desktop (≥ 720 px viewport), all sections start expanded by default (more vertical space available).

```html
<details class="postflop-explanation-section" id="postflop-section-rangeLogic" open>
  <summary>▶ Range Logic</summary>
  <div class="postflop-explanation-body">
    BTN open ~45% range includes A2s-AKs, A8o-AKo, K9s+, KJo+ — many cards
    that connect with A or K. BB calling range vs BTN open is roughly 30%
    (22-JJ, suited connectors, suited gappers, A2s-A9s, KTs/KJs, QJs, etc.).
    Critically, BB 3-bets AJo+, AQs, AKs, KQs, KJs at high frequency,
    removing them from the flatting range. Result: BTN's flop range is
    much more A-x-heavy and K-x-heavy.
  </div>
</details>
```

The native `<details>` widget gives smooth open/close + accessible by default + keyboard navigable.

### Sections rendered (in order)

1. **Range Logic** — only if `scenario.explanation.rangeLogic` is non-null
2. **Nut Logic** — only if `nutLogic` non-null
3. **Hand Logic** — only if `handLogic` non-null (always null for Module 1)
4. **Sizing Logic** — only if `sizingLogic` non-null
5. **Common Mistake** — only if `commonMistake` non-null; auto-expanded if `tier === 'critical'`

If a scenario has zero non-null sections (rare), only the short explanation shows — no expandable area at all.

### Concept tags

Rendered as small pills inline:

```
Concept tags
• range_advantage  • dry_high_card_strategy  • board_texture_recognition  • dry_board
```

In v4.0.2: pills are static text (not clickable). v4.0.5 polish round may make them clickable to open a concept-page modal.

### Action row

- `[ Next → ]` primary mint button, full-width, 56 px tall
- On final question: button label changes to `[ Finish ]` and goes to summary screen instead.

---

## 7. Surface 5 — Summary screen

```
┌──────────────────────────────────────┐
│ ▲ Range Master MTT                    │
├──────────────────────────────────────┤
│ ✅ Board Texture Drill Complete       │
│                                      │
│         13.5 / 15  (90%)              │
│         ─────────                     │
│                                      │
│ Best        12  ✅                    │
│ Acceptable   1  ≈                     │
│ Bad          1  ❌                    │
│ Critical     1  🚨   ← amber pulse   │
│                                      │
│ ▶ Concept mastery (this session)      │
│ ▶ Critical leaks (1)                  │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ ▶ Drill again                    │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ ← Back to Home                   │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

### Score banner

- Big number: `13.5 / 15` (32 px, semibold, mint if ≥ 80%, amber if 50–79%, red if < 50%)
- Percentage: `(90%)` (16 px, dimmer)
- Underline rule: 80px wide, mint accent, centered

### Per-tier counts

Plain text rows with icons. No bars in v4.0.2 (defer to v4.0.5 polish).

### Concept mastery (collapsible)

```
▶ Concept mastery (this session)
   range_advantage           5/5   100%   ✅
   nut_advantage             3/3   100%   ✅
   dry_high_card_strategy    2/3    67%   ≈
   low_connected_caution     1/2    50%   ❌
```

Computed by aggregating across `state.answers[]` — each answer carries the scenario's `conceptTags`; tally per tag.

### Critical leaks (collapsible)

```
▶ Critical leaks (1)
   • Q 6 — On 5♥4♦3♣, you picked "preflop_raiser"
     GTO: caller (BB) — BB's range is dense in low pairs and made
     straights. Re-read explanation
```

Each leak entry shows: Q number, board, picked-vs-correct, one-line explanation. "Re-read explanation" link opens the feedback card in modal (or scrolls back into a review mode — see Open Question 5 in Architecture brief).

### Actions

- `[ ▶ Drill again ]` — restarts a fresh session (new shuffle)
- `[ ← Back to Home ]` — clears state, navigates to Mastery tab

---

## 8. Confirm-exit modal

Triggered by `[ ✕ Exit ]` mid-session.

```
┌────────────────────────────────────┐
│         Exit Drill?                │
│                                    │
│ You're on Q 4 of 15.               │
│ Progress will be discarded.        │
│                                    │
│ [ Cancel ] [ ✕ Exit Anyway ]       │
└────────────────────────────────────┘
```

Pattern: matches existing modal style used elsewhere in the app (`.modal-overlay` + `.modal-card`). Cancel returns to current question; Exit Anyway clears state and navigates back to Home.

---

## 9. Mobile 375 px specifics

Verified breakpoints:

- Top nav stays single-row (existing chrome).
- Spot card: stacks badges if line wraps (CSS `flex-wrap: wrap; gap: 6px`).
- Board cards: 56 × 80 px each, 12 px gap = 196 px total + 12px margins each side = fits in 375 px (with 71 px to spare).
- Choice buttons: 100% width, 56 px tall — comfortable thumb target.
- Feedback card sections: collapsed by default; tap to expand.
- Summary card: per-tier counts in single column; concept-mastery list scrolls if long.
- All tap targets ≥ 44 × 44 px (WCAG AA).

### Vertical scroll

Question screen height: ~520 px (well under 812 px iPhone X height). No scroll needed for question.

Feedback screen with all sections expanded: can exceed viewport. That's expected — player scrolls to read. Action button stays visible at bottom because it's a normal block element after the content (no sticky needed in v4.0.2; v4.0.5 may sticky the Next button on tall feedback cards).

---

## 10. Desktop adaptation (≥ 720 px viewport)

Same single-column layout, max-width 680 px (matches existing `.container`). On wide screens:

- Cards are centered with horizontal padding from the side.
- Feedback sections **default to expanded** (more vertical space, players want to see everything).
- Optional: side-by-side "Your pick / GTO best" comparison for the result row.
- No multi-column layout (kept simple in v4.0.2; consider 2-column board+question in v4.0.5).

---

## 11. Accessibility (a11y)

| Item | Spec |
|---|---|
| Color contrast | All text ≥ 4.5:1 against background; result icons + colors are reinforced with text labels (not color-only) |
| Keyboard | All interactive elements reachable via Tab; Enter/Space activates choices |
| Screen reader | Choice buttons use `<button>` (not `<div>`); feedback uses `<details>` (announces expanded/collapsed state); progress uses `aria-valuenow` |
| Reduced motion | Respect `App.state.settings.fxRespectMotion`. Specifically: no transition on the result row entrance, no animated progress fill — just instant snap |
| Touch target | All ≥ 44 × 44 px |
| Focus visible | Use existing app focus-ring style (mint outline) |

---

## 12. Existing CSS reuse

Borrow from existing patterns where possible:

| Existing | Reuse for | Notes |
|---|---|---|
| `.card` | `.postflop-question-card`, `.postflop-feedback-card` | Same border, padding, shadow tokens |
| `.tag`, `.tag-stack`, `.tag-pos`, `.tag-action` | Spot card pills | Identical visual language to preflop |
| `.action-btn` | `.postflop-choice-btn` | Same height, padding, type style; differ in semantic colors (no fold-red / call-amber for board questions) |
| `.modal-overlay`, `.modal-card` | Confirm-exit modal | Existing shell |
| `--mint`, `--amber`, `--red`, `--text-secondary` | Result-tier colors | CSS vars already defined |

This keeps v4.0.2 feel native to the app rather than bolted-on.

---

## 13. Animation budget

Per design principle 5 (quiet confidence):

| Element | Animation | Duration |
|---|---|---|
| Screen transition (in) | Fade-in only (existing `.tab-panel.active` style) | 150 ms |
| Choice button tap | Scale 0.98 → 1.0 | 100 ms |
| Feedback card mount | Fade + slight slide-down (10 px) | 200 ms |
| `<details>` expand/collapse | Native browser animation | ~150 ms |
| Result row entrance | If reduced-motion: instant; else: subtle pulse (1× scale 1.02) | 240 ms total |
| Summary score reveal | Count-up animation 0 → final value | 600 ms (skip if reduced-motion) |

**Explicitly NO**:
- Particle bursts (those are preflop FX territory)
- Field/aura overlays (postflop is analytical; quiet UI)
- Page-shake or screen-flash on critical (the amber border + pulse + auto-expand commonMistake is enough)

---

## 14. Empty / error states

Every screen has a defensive render:

| State | Question screen | Feedback screen | Summary screen |
|---|---|---|---|
| `App.postflop.ready === false` | "Post-flop data not loaded. [Back to Home]" | (n/a — should never reach) | (n/a) |
| `state.queue.length === 0` | "No scenarios available. [Back to Home]" | (n/a) | (n/a) |
| Scenario missing required field | Skip + log + show next; if all skipped: same as empty queue | Skip section if `null`; render only what's present | Show "No data" placeholder for missing rows |
| User offline + cache miss | (Service worker should serve from cache; if it doesn't, fall back to "data unavailable" screen) | Same | Same |

---

## 15. Notification copy

Toasts (existing `showToast()` helper):

| Trigger | Message |
|---|---|
| Postflop loader still loading on Start tap | "Post-flop data still loading. Try again in a moment." |
| Postflop load failed | "Post-flop data failed to load. Reload the app or check console." |
| Beta toggle on | "Post-flop beta enabled. Open Home tab to see Module 1." |
| Beta toggle off | "Post-flop beta disabled." |
| Drill complete | (Use the Summary screen; no toast needed) |
| Critical leak in summary | "1 critical leak this session — review explanation below." |

---

## 16. Open UX questions

1. **Concept tag pill color** — single neutral or per-concept color (would require a color map per concept; complex for v4.0.2; recommend single neutral)?
2. **Score animation on summary** — count-up effect or instant reveal? (Recommend instant if reduced-motion, else count-up.)
3. **Per-question feedback before vs after Next button** — current proposal: feedback IS the screen after answer; Next button advances. Alternative: keep question on screen and overlay feedback inline. (Recommend current — clearer two-phase model.)
4. **Settings beta toggle position** — under "FX & Animation" or new "Beta Features" subsection? (Recommend new subsection so we have a home for future beta toggles.)
5. **Home card "Module 1" prefix** — show "Module 1" label or just "Board Texture Trainer"? (Recommend "Module 1" — communicates that more modules will exist.)

---

## 17. Stop condition

UX Subagent stops after this plan. Orchestrator consolidates with Architecture / Scenario Review / QA into the implementation-ready brief.

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | UX Subagent | Initial publication |
