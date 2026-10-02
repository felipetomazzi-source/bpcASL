# Phase 4 — High Volume

Extension and high-volume framework: registered sources/functions/actions, spill
storage, advanced planning estimates, approved bulk-replacement adapters, and
multi-million-record operational controls.

## Requirement IDs

- ASL-EXT-001..ASL-EXT-005 (extension registry and contracts)
- ASL-DATA-009 (registered sources)
- ASL-PERF-001..ASL-PERF-011 (limits, performance, large-volume gating)
- ASL-WRITE-008..ASL-WRITE-010 (bulk-replacement strategies)
- ASL-REPO-005 (spill/temporary storage)
- ASL-PROD-038 (prevent unapproved million-record clear/write plan)

## Scope

- Administrator-managed registry of sources, functions, and actions.
- Spill storage for large intermediate datasets.
- Advanced planning estimates and governed strategy selection.
- Approved `REGISTERED_BULK_REPLACE` adapters where the provider type and platform support them.
- Operational controls for multi-million-record runs (thresholds, profiles, retention).

## Excluded scope

- Unrestricted SQL/ABAP execution; direct deletes from generated BPC fact tables; any bulk mechanism not validated for the installed provider type.

## Expected objects or files

- ABAP: extension registry, source/action invocation, spill manager, bulk-write adapter interface (proposed names in §25).
- DDIC: `ZBPC_ASL_EXT`, `ZBPC_ASL_CFG`, plus spill/temporary storage.

## Acceptance criteria

- Only registered extensions are invocable; no unregistered ABAP class, program, SQL, or physical table can be reached. (ASL-PROD-042)
- Million-record rebuilds are detected before write-back and require an approved plan. (ASL-PROD-038, ASL-PERF-009)
- Configurable safeguards are enforced during validation, planning, and execution. (ASL-PERF-001, ASL-PERF-002)
- Published benchmarks and tested limits exist for the release. (ASL-PERF-010)

## Required tests

- Extension registry, performance/large-volume scenarios, bulk-adapter eligibility and validation (see [../TEST-PLAN.md](../TEST-PLAN.md) §15, §18).

## Dependencies

- Phase 2 (write-back), Phase 3 (calculation library).


