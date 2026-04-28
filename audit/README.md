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
- `audit/ranges-flat.csv` — one row per (scenario, hand). Spreadsheet-ready.

Also prints a BB-defense monotonicity check to stdout.

## CSV column reference

| Column | Meaning |
|---|---|
| `scenario` | Top-level key in ranges.json (e.g. `100BB_BB_vs_raise_btn`) |
| `stack`, `position`, `action` | Convenience copies from the scenario |
| `hand` | One of 169 starting hands (e.g. `AKs`, `77`, `QJo`) |
| `fold`, `call`, `check`, `limp`, `raise`, `threebet`, `fourbet`, `shove` | Frequency for each action (0.00 if not in scenario.valid_actions) |
| `max_freq` | The largest action frequency for this hand |
| `is_mixed` | `TRUE` if `max_freq < 0.999` — any scenario with multiple non-zero actions, including 95/5 splits |
| `is_marginal` | `TRUE` if `max_freq < 0.7` — matches the in-app Marginal Focus drill mode threshold ("no single action is strongly dominant") |

Use `is_mixed` for general "is this hand played as a mix?" queries. Use
`is_marginal` for "would this hand be weighted up by Marginal Focus?".

## Auditing workflow

Recommended order:

1. **CSV** for cross-scenario trends (e.g. "how does A5s shift across all
   stacks vs BTN?", monotonicity, outliers, marginal-hand inventory).
2. **JSON** at repo root to verify exact freqs when CSV row looks suspect.
3. **Markdown** for human spot-check on individual scenarios.

## Release workflow — REGENERATE AFTER EVERY RANGE PATCH

Whenever `ranges.json` is updated (any `fix-*.ps1` patch), the audit pack
**must** be regenerated and re-shared so external review can verify the
new state:

```powershell
# After range patch:
powershell -NoProfile -ExecutionPolicy Bypass -File .\audit\generate-audit.ps1
$h = (Get-FileHash ranges.json -Algorithm MD5).Hash
"MD5: $h" | Set-Content audit/checksum.txt
```

Then quote the MD5 + scenario count in the commit body.

The release-cycle invariant is:

> Every `fix-*.ps1` run is followed by `audit/generate-audit.ps1` run,
> and the new audit pack is shared with the reviewer before merging the
> next range patch.

## Why these aren't committed

`ranges-flat.csv` is ~1.7 MB and `ranges-summary.md` is ~100 KB. Both are
deterministic outputs of `ranges.json`. Committing them would bloat the
repo and make every range patch produce a giant diff. Source of truth is
`ranges.json` plus the `tools/range-builder.ps1` helpers used to generate
it.

For archival of a specific release, copy outputs to
`audit/releases/v1.x.y/` (manually whitelist in `.gitignore` if needed).
