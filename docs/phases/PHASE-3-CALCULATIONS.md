# Phase 3 — Calculations

Calculation library and orchestration: functions/procedures, bounded loops,
allocations, time-series library, cross-model mappings, safe parallel
partitions, and reference calculation scenarios.

## Requirement IDs

- ASL-PROC-001..ASL-PROC-011 (conditions, loops, functions/procedures, parallel blocks, assertions)
- ASL-TIME-001..ASL-TIME-009 (time-series library)
- ASL-DATA-020, ASL-DATA-021 (allocation), ASL-DATA-012, ASL-DATA-013 (transpose/mapping)
- ASL-META-002 (cross-model mappings)
- ASL-RUN-008 (safe partitioning, no overlapping parallel writes)
- ASL-PROD-004, ASL-PROD-032..ASL-PROD-034 (allocations/time-series/multi-model acceptance)

## Scope

- Functions and procedures (side-effect-free functions; `WRITES`-gated procedures).
- Bounded loops over finite collections.
- Allocation core operation with driver policies, rounding, and reconciliation.
- Time-series library (PREVIOUS/NEXT/ADD_PERIODS, OPENING/CLOSING, YTD/QTD/ROLLING_SUM, LAG/LEAD, CUMULATIVE_SUM, depreciation functions, SMOOTH/INDEX_VALUE).
- Cross-model mappings and multi-model reads/writes.
- Safe parallel partitions with disjoint output regions.
- Reference scenarios: ALLOC_OPEX, DEMREV/DEMREVID, AGGR_PROJECT/AGGR_OPEX, FAR, RAB.

## Excluded scope

- Extension registry, bulk-replacement adapters, spill storage, multi-million-record operational controls.

## Expected objects or files

- ABAP: procedure/loop execution, allocation engine, time-series library, partition planner (proposed names in §25).
- Reference scenario scripts and expected-output fixtures.

## Acceptance criteria

- Conditions, bounded loops, functions, and procedures execute. (ASL-PROD-033)
- Scripts read from and write to more than one explicitly declared model. (ASL-PROD-034)
- Allocation reconciles to source within tolerance; time-series and depreciation scenarios match reference outputs.
- Parallel writes are permitted only for disjoint partitions.

## Required tests

- Allocations, time-series, joins/cardinality, semantic binding, and reference scenarios (see [../TEST-PLAN.md](../TEST-PLAN.md) §7, §8, §19).

## Dependencies

- Phase 0 (in-memory executor), Phase 2 (write-back for results persistence).


