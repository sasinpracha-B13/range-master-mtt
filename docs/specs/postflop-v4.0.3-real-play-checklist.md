# Real-Play Checklist — v4.0.3 (Postflop Module 1) — Re-Test After Hotfix

> **For**: human tester (you).
> **When**: after v4.0.3 deploys to Netlify (loader fix + choice guide + button polish + Home reposition).
> **Time budget**: 10–15 minutes.
> **Output**: notes in Section F.

**Live URL**: `https://range-master-mtt.netlify.app/`

**v4.0.3 changes to verify (all 4 should be fixed):**
1. ✅ Loader: spinner placeholder appears immediately when beta is on; auto-replaces with ready card when data loads.
2. ✅ Choice meanings: expandable "What are we choosing?" guide above each question's choice buttons.
3. ✅ Button responsiveness: tapped button shows mint-pressed state instantly; all buttons disable to prevent double-tap.
4. ✅ Home placement: postflop entry now at TOP of Home inside "🧪 BETA LAB" dashed-border section.

> 💡 Use a real device if possible (mobile preferred; desktop fine as a second pass). Open DevTools console once at the start to catch any errors.

---

## A. Setup (≈ 1 min)

```
[ ] Open https://range-master-mtt.netlify.app/ in a fresh tab (or pull down to refresh on mobile PWA).
[ ] If an "Update available" banner appears: tap it; the page reloads on v4.0.2.
[ ] If first install: tap "Continue" on the disclaimer modal.
[ ] Open DevTools Console (desktop: F12 → Console; mobile: skip — verified via smoke test).
[ ] Confirm console shows: [postflop] loaded 31/31 scenarios (schema 1.0.0)
[ ] Tap Settings tab.
[ ] Scroll to bottom → 🧪 Beta Features section.
[ ] Toggle "Enable post-flop beta modules" → ON.
[ ] Toast appears: "Post-flop beta enabled — Home tab now shows Module 1."
[ ] Tap Home tab.
```

---

## B. First impression — rate 1–5 (≈ 1 min)

The Postflop Beta card appears at the bottom of the Home tab, after the existing Mastery Path zones.

```
[ ] Q1. Can I find the Post-flop Beta easily?           ___ / 5
[ ] Q2. Does the Home entry point look clear?            ___ / 5
[ ] Q3. Do I understand what "Board Texture Trainer" is
        from the card alone (without prior context)?     ___ / 5
```

**1 = totally lost · 3 = passable · 5 = obviously clear**

If any answer is ≤ 2: **note WHY in Section F**.

---

## C. Play one full session (≈ 8–10 min)

Tap **▶ Start Board Texture Drill**. Play all 15 questions.

For each question (or whenever something stands out), tick boxes that apply:

```
[ ] Board cards readable at a glance
[ ] Spot summary (100BB · BTN open · BB call · SRP) understood
[ ] Question prompt clear
[ ] Answer choices well-distinguished (no guessing which is which)
[ ] Feedback teaches reasoning (not just "correct/wrong")
[ ] Feedback length feels right (not too long, not too short)
[ ] Scoring feels FAIR (best=1.0, acceptable=0.5, bad=0, critical=0+flag)
[ ] Expandable sections (Range Logic / Nut Logic / Sizing Logic / Common Mistake) actually help
[ ] "Next" button always findable
[ ] Nothing felt confusing
```

**If any box is unticked**: write a one-line note in Section F.

**Aim for 15 questions**. If you exit early to take notes, the "✕ Exit" button shows a confirm modal — that's by design (preserves session safety).

---

## D. Summary screen (≈ 1 min)

After Q15, the summary card shows: score, per-tier counts, concept mastery, critical leaks.

```
[ ] Score (e.g., "13.5 / 15.0 (90%)") clear at a glance
[ ] Per-tier counts (Best / Acceptable / Bad / Critical) clear
[ ] Concept mastery list useful (or noisy?)
[ ] Critical leaks list helpful (if any leaks happened)
[ ] "Drill again" button findable
[ ] "Back to Home" button findable
```

---

## E. Mobile (≈ 1 min — only if testing on phone)

```
[ ] No horizontal scroll anywhere
[ ] Buttons easy to tap with thumb (target ≥ 44 px)
[ ] Text not cramped (line-height comfortable)
[ ] Summary card not overwhelming on a single phone screen
[ ] Beta toggle in Settings reachable without excessive scrolling
[ ] Postflop entry card on Home reachable without excessive scrolling
```

If any answer is unticked: **note device + browser in Section F**.

---

## F. Notes (the deliverable)

These notes feed `brief-v4.0.3-postflop-module1-polish.md` and drive the actual polish list.

```
Most confusing part:
  ____________________________________________________________
  ____________________________________________________________

Most useful part:
  ____________________________________________________________
  ____________________________________________________________

First thing to polish (highest priority):
  ____________________________________________________________
  ____________________________________________________________

Would I keep using this mode? (yes/no/why)
  ____________________________________________________________
  ____________________________________________________________

Any GTO explanation I disagree with? (which scenario, which claim)
  ____________________________________________________________
  ____________________________________________________________

Other observations:
  ____________________________________________________________
  ____________________________________________________________
  ____________________________________________________________
```

---

## G. (Optional) DevTools sanity checks (desktop only, ≈ 30 sec)

If you have DevTools open:

```
[ ] Console clean — only one postflop log line, zero errors
[ ] Run in console: App.postflop.scenarios.length  →  31
[ ] Run in console: getModule1Scenarios().length   →  20
[ ] Application → Cache Storage → range-master-v4.0.2 present
[ ] Application → Service Workers → activated, scope = origin
```

---

## What happens after this checklist

1. You hand the completed Section F notes to Orchestrator.
2. Orchestrator turns the notes into a prioritized polish list inside `brief-v4.0.3-postflop-module1-polish.md`.
3. UX Subagent drafts microcopy/layout deltas for the prioritized items.
4. DEV Integration Agent implements + tests + stages.
5. Commit + push happens only on explicit instruction.

The checklist is the **gate**. No v4.0.3 implementation begins without your real-play notes.

---

## Quick-reference live URL

```
https://range-master-mtt.netlify.app/
```

Pre-verified live state (as of 2026-05-04):
- App.postflop.ready === true
- App.postflop.scenarios.length === 31
- Module 1 count === 20
- backup appVersion === "4.0.2"
- Service worker cache: range-master-v4.0.2 active
- Beta default === OFF (toggle in Settings to enable)

If any of the above shows different on your real-play, **note it as a deploy issue first** — that takes priority over polish notes.
