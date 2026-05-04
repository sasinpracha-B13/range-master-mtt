# Data Patch Plan — v4.0.5-data

> **Status**: PROPOSED, **NOT applied**. Awaiting human approval before any data file is touched.
> **Companion document**: `postflop-v4.0.5-gto-validation-report.md` (the validation that produced these patch proposals).
> **Pattern**: same as `v4.0.2-data` — data-only commit, separate from any UI/feature commit.

---

## Patch summary

**1 proposed edit** to `postflop/postflop_scenarios.json`:

| # | Type | Scenario | Impact |
|---|---|---|---|
| 1 | DOWNGRADE confidence | `pf_btn_v_bb_srp_100bb_flop_Qd9c4h_rangeadv_001` | Honesty tag only; no player-visible change |

**0 proposed edits** to:
- `postflop/postflop_taxonomy.json` (no taxonomy changes needed)
- `postflop/postflop_concepts.json` (no concept changes needed)
- `postflop/postflop_audit_rules.js` (no rule changes needed)

**0 scenarios held from production**.
**0 scenarios revised in answer key**.
**0 scenarios added/removed**.

---

## Patch 1 — `Qd9c4h` sourceConfidence downgrade

### Identification

```
file:        postflop/postflop_scenarios.json
scenario id: pf_btn_v_bb_srp_100bb_flop_Qd9c4h_rangeadv_001
field:       sourceConfidence
```

### Change

```diff
-      "sourceConfidence": "consensus_gto",
+      "sourceConfidence": "expert_judgment",
```

### Reason

**Q-high semi-dry rainbow (Qd9c4h)** has a thinner BTN range advantage than the dry A-high / K-high / paired boards that share the `consensus_gto` tag. Concretely:

- BTN density: KQ + AQ + QJ + overpairs (TT-AA, with KK/AA partially in 3-bet range)
- BB density: 99 sets at full freq (BB always flats 99), 9-x suited connectors (98s, 97s), some Q-x (QJs/QTs)
- Net: BTN edge exists but is materially thinner than #1 (AhKd5c) where BTN holds A-x at 5x BB's frequency

Some sims show this near-neutral. The answer key already correctly hedges with `acceptable: neutral`. Only the **confidence tag** overclaims — `consensus_gto` implies wide solver agreement, but on this specific board the consensus is "BTN edge exists" rather than "BTN edge is large and clear."

### Confidence level after change

`expert_judgment` — this honestly reflects the reviewer's call: "BTN edge is real but principled judgment-based, not a high-conviction solver-consensus call."

### Player-visible impact

**None**. The answer key (`best=preflop_raiser`, `acceptable=neutral`, `bad=caller`, `bad=split`, no critical) is unchanged. The `mixing` field is unchanged. The explanation is unchanged. The `conceptTags` are unchanged. The `difficulty` is unchanged.

The only field changed is `sourceConfidence`, which is metadata used by:
- The audit tool (warns if `experimental + approved` combination — does not apply here)
- Future v4.x UI work that may surface a "solver consensus" badge (not yet built)

Score the player gets for any answer remains identical pre/post patch.

### Risk assessment

**Risk: Low.** The change is a single string in one scenario. No structural change. No answer change. Audit will pass (R17 validates `sourceConfidence` is in the enum; `expert_judgment` is in the enum).

### Rollback

If reviewers later disagree with the downgrade, revert is one line:

```
git revert <v4.0.5-data commit hash>
```

---

## Monitor-only items (no patch proposed)

These were flagged in the validation report as KEEP-with-caveat. **No edit proposed** at this time, but listed here so future validation passes can re-examine if real-play feedback disputes them.

### Monitor 1 — `Th8h3h_nutadv` (T-high monotone)

```
scenario id: pf_btn_v_bb_srp_100bb_flop_Th8h3h_nutadv_001
field:       answer.best, answer.acceptable
current:     best=["preflop_raiser"], acceptable=["neutral"]
status:      KEEP — already at expert_judgment
```

**Possible alternative** (not proposed now): flip to `best=["neutral"], acceptable=["preflop_raiser"]`. This depends on the assumed BB calling-range definition. The current answer is defensible but a reviewer assuming a wider BB defense would call this neutral. Defer until human poker reviewer weighs in.

### Monitor 2 — `7d7s3c_rangeadv` (paired low)

```
scenario id: pf_btn_v_bb_srp_100bb_flop_7d7s3c_rangeadv_001
field:       answer.best, answer.acceptable
current:     best=["split"], acceptable=["neutral", "preflop_raiser"]
status:      KEEP — already at expert_judgment, difficulty 4
```

Genuinely fuzzy paired-low spot. Wide acceptable list honestly tells the player the answer is close. No action needed; the scenario teaches that "fuzzy spots exist."

---

## Verification plan (after applying the patch)

1. Audit re-run: expected `31 scenarios · 0 errors · 0 warnings`.
2. Live browser: `App.postflop.scenarios.find(s => s.id === 'pf_btn_v_bb_srp_100bb_flop_Qd9c4h_rangeadv_001').sourceConfidence === 'expert_judgment'`.
3. Verify no other scenario was accidentally modified — `git diff postflop/postflop_scenarios.json` should show exactly **1 line changed** (the sourceConfidence field).

## Suggested commit message

```
v4.0.5-data: downgrade #14 (Qd9c4h) sourceConfidence honesty tag

Q-high semi-dry rainbow has a thinner BTN range advantage than the
A-high / K-high / paired boards that share consensus_gto. Per the
v4.0.5 GTO Validation Report, downgrade sourceConfidence:

  pf_btn_v_bb_srp_100bb_flop_Qd9c4h_rangeadv_001
    sourceConfidence: "consensus_gto" -> "expert_judgment"

Player-visible impact: NONE.
- Answer key unchanged (best=preflop_raiser, acceptable=neutral)
- Mixing unchanged
- Explanation unchanged
- Concept tags unchanged
- Difficulty unchanged

Audit re-confirmed: 31 scenarios, 0 errors, 0 warnings.

Source documents:
  docs/specs/postflop-v4.0.5-gto-validation-report.md
  docs/specs/postflop-v4.0.5-data-patch-plan.md

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
```

---

## What this patch does NOT do

- ❌ Does not change any answer key
- ❌ Does not add/remove scenarios
- ❌ Does not modify taxonomy or concepts
- ❌ Does not change the audit rules
- ❌ Does not touch UI / production code
- ❌ Does not bump appVersion or service-worker VERSION
- ❌ Does not modify SRS, scoring formulas, or any preflop system

If approved, this is the smallest possible safe data edit — a single-string change to one metadata field.

---

## Approval gate

**Do not apply** until human reviewer sees this plan and explicitly approves with "apply v4.0.5-data patch" or similar.

After approval:
1. Apply the single-line edit to `postflop_scenarios.json`
2. Re-run audit (expected 31/0/0)
3. Stage commit with the message above
4. Human reviews diff and approves the commit
5. Commit
6. Push happens only on a separate explicit "push" instruction

---

## Change log

| Date | Author | Change |
|---|---|---|
| 2026-05-04 | Orchestrator | Initial patch plan publication. 1 proposed edit (#14 sourceConfidence). 0 answer-key changes. 0 holds. |
