# v4.6.1 · ARR.P Exact-Partition Resolution — Audit Record (owner-approved)

**Date:** 2026-07-07 · **Ruling:** exact partition = CORPUS standard (adopted from M6). M4 rows being reworked fix partition inside the rework; the remaining overlap rows get a PARTITION-FIX-ONLY batch. Mechanical resolution: a duplicated action resolves to **critical ONLY if it belongs to an enumerated punt class** (fold-nuts / call-zero-SDV / raise-into-crush / check-back-nuts), **else bad**.

## M4 resolution (mechanical, from authored metadata)

**64/92 overlap rows · 84 duplicated-action instances · 0 flagged (100% mechanical)** — resolve → bad **55** · critical **29** · by action: check_raise_big 38, fold 35, call 11. Proxies: duplicated `fold` → critical iff `heroHandRole=nutted_value` (fold-nuts), else bad (v4.4.1B) · `call` → critical iff `showdownValue=none` (call-zero-SDV), else bad · `check_raise*` → critical iff role ∈ {bluff_catcher, dominated_bluff_catcher, marginal_made_hand} (raise-into-crush), else bad (V1 precedent) · `mixed` → always bad. Full 84-instance list regenerates deterministically from `tools/analyze-partition-overlap-v4.6.1.ps1`.

**10-row sample (incl. the owner-corrected 6s5s rationale):**

| id (`…turn_` stripped) | act | role/sdv | → | rationale |
|---|---|---|---|---|
| `As8d3h_2c_action_Th8h_v430` | CR_big | dominated_marginal/low | bad | aggression error — not a punt for this role |
| `As8d3h_2c_action_AdQd_v430` | fold | bluff_catcher/high | bad | over-fold (v4.4.1B) |
| `As8d3h_2c_action_AdQd_v430` | CR_big | bluff_catcher/high | critical | raise-into-crush |
| `As8d3h_2c_action_JsTh_v430` | call | give_up/none | critical | call with zero showdown value |
| `As8d3h_2c_action_JsTh_v430` | CR_big | give_up/none | bad | not a punt for this role |
| `9d8c6h_Kc_action_9c9s_v430` | fold | nutted_value/nutted | critical | fold-nuts |
| `9d8c6h_Kc_action_9h7h_v430` | CR_big | dominated_marginal/decent | bad | aggression error |
| `9d8c6h_Kc_action_AdJs_v430` | call | give_up/none | critical | call with zero showdown value |
| `9d8c6h_Kc_action_AdJs_v430` | CR_big | give_up/none | bad | not a punt for this role |
| `Ks8s3d_2s_action_6s5s_v430` | fold | strong_value/high | bad | **made (non-nut) flush on the three-spade board; no boat possible (board unpaired); strong but not nutted → over-fold resolves bad per v4.4.1B, not fold-nuts** |

## Corpus diagnostic — BANKED as future remediation scope (no action this sprint)

M1 board_texture **168/251** (largest block) · M2 0/49 · M3 **59/85** · M4 64/92 (this sprint) · M5 **12/33** · M6 0/32 (born under the rule). **R108** (exact-partition, error-level) now lives in the production validator scoped to **M4+M6**; it fires red-by-design on the 64 pre-migration M4 rows (+R16 cascade) and goes green with the partition-fix migration. Scope extends per module as remediation lands.

**Process note (kept per owner):** the first resolver implementation under-counted rows via a PS single-element-unrolling bug; caught by cross-checking against the lint, then reconciled with a third independent implementation before any number was reported. Triple-implementation reconciliation is the standing discipline for mechanical audit counts.
