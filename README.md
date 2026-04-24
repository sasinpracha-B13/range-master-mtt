# Range Master MTT

Offline preflop range study app for MTT poker players. Focuses on short stacks (5-20BB) and deep stacks (40-100BB) using GTO-approximated ranges.

## ⚠️ Study Tool Only

**Do NOT use during live play.** Using reference tools during active hands violates the Terms of Service of all major poker platforms (PokerStars, GGPoker, WPT Global, partypoker, ACR, etc.) and may result in permanent bans.

Use this app:
- Before sessions (warm-up drill)
- After sessions (review mistakes)
- During free time (focused study)

## Features

- **3 drill modes**: Quick (15 hands), Deep Study (30 hands with GTO reasoning), Weakness Focus (SRS-driven)
- **148 scenarios**: 8 stack depths × 8 positions × 4 action types
- **13×13 hand grid**: Browse full ranges visually
- **Spaced repetition (SM-2)**: Prioritizes hands you get wrong
- **Progress tracking**: Accuracy trends, weak spot detection, daily streak
- **PWA**: Installable on iPhone and PC, works offline

## Stack Depths

Short: 5 / 10 / 15 / 20 BB  
Deep: 40 / 60 / 80 / 100 BB

## Positions (8-max & 9-max compatible)

UTG · MP · LJ · HJ · CO · BTN · SB · BB

## Tech Stack

Single-file HTML/CSS/JS · PWA · localStorage · No server

## Install on iPhone

Open in Safari → Share → Add to Home Screen

## Deploy

Hosted on Netlify via GitHub auto-deploy. Requires HTTPS for PWA/service worker (provided by Netlify).

## Data

`ranges.json` — 148 GTO-approximated scenarios generated from Nash push/fold equilibrium (short stacks) and standard opening percentage models (deep stacks). Regenerate with:

```
powershell -ExecutionPolicy Bypass -File gen-ranges.ps1
```

Ranges are approximations. For professional-level precision, verify with GTO Wizard, PioSolver, or Simple Preflop Holdem.
