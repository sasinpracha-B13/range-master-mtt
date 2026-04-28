# audit/

Tools for auditing `ranges.json` integrity. Output files are gitignored —
they're regenerated on demand from the canonical `ranges.json`.

## Generate audit pack

From repo root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\audit\generate-audit.ps1
```

Produces (all gitignored):

- `audit/ranges-summary.md` — per-scenario digest, continue% matrix, pure
  ranges grouped by action, mixed hands with frequencies. Human-readable.
- `audit/ranges-flat.csv` — one row per (scenario, hand). Columns:
  `scenario, stack, position, action, hand, fold, call, check, limp,
  raise, threebet, fourbet, shove, max_freq, is_mixed`. Spreadsheet-ready.

Also prints a BB-defense monotonicity check to stdout.

## Auditing workflow

The recommended order:

1. **CSV** for cross-scenario trends (e.g. "how does A5s shift across all
   stacks vs BTN?", monotonicity, outliers).
2. **JSON** at repo root to verify exact freqs when CSV row looks suspect.
3. **Markdown** for human spot-check on individual scenarios.

## Why these aren't committed

`ranges-flat.csv` is ~1.7 MB and `ranges-summary.md` is ~100 KB. Both are
deterministic outputs of `ranges.json`. Committing them would bloat the
repo and make every range patch produce a giant diff. Source of truth is
`ranges.json` plus the `tools/range-builder.ps1` helpers used to generate
it.

If you want to snapshot a release for archival, copy them to
`audit/releases/v1.x.y/` (manually whitelisted in .gitignore if needed).
