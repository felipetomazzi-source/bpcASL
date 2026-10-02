# Phase 2 — Write-back

Governed write-back: output regions, previewed changes, APPEND/MERGE/REPLACE,
delta comparison, standard BPC write-back, security/work status, locks, and run
lifecycle with checkpoints, cancellation, and restart.

## Requirement IDs

- ASL-WRITE-001..ASL-WRITE-014 (regions, modes, delta strategy, chunking)
- ASL-SEC-001..ASL-SEC-013 (roles, authorization, work status, HTTP/input security)
- ASL-RUN-001, ASL-RUN-004..ASL-RUN-006, ASL-RUN-013..ASL-RUN-018 (lifecycle, locks, background execution, recovery)
- ASL-OPS-001..ASL-OPS-006 (diagnostics, audit, retention)
- ASL-PROD-035..ASL-PROD-040 (write acceptance criteria)

## Scope

- Output regions and contained-result validation.
- Previewed changes (new/changed/unchanged/stale counts and write strategy).
- `APPEND`, `MERGE`, and semantic `REPLACE`.
- Delta comparison and batched standard BPC write-back.
- Security, work status, and lock enforcement.
- Run states, checkpoints, cooperative cancellation, and restart.

## Excluded scope

- Allocation/time-series libraries, cross-model scenario orchestration, extension registry, bulk-replacement adapters, spill storage, large-volume operational tooling.

## Expected objects or files

- ABAP: write adapter, run coordinator/worker, lock/checkpoint persistence, diagnostics (proposed names in §25).
- DDIC: `ZBPC_ASL_RUN`, `ZBPC_ASL_STG`, `ZBPC_ASL_MSG`, `ZBPC_ASL_MET`, `ZBPC_ASL_LOCK`.

## Acceptance criteria

- All writes target validated regions and support APPEND/MERGE/REPLACE. (ASL-PROD-035)
- Standard replacement omits unchanged records and reverses only stale keys. (ASL-PROD-036)
- Preview reports resolved scopes and estimated new/changed/stale writes. (ASL-PROD-037)
- BPC security, work status, and locking are respected. (ASL-PROD-039)
- Run progress, timings, messages, metrics, cancellation, and eligible restart are available. (ASL-PROD-040)

## Required tests

- Output-region containment, APPEND/MERGE/REPLACE, delta comparison, security/work status, locks, cancellation/restart, HTTP API (see [../TEST-PLAN.md](../TEST-PLAN.md) §9–§14, §16).

## Dependencies

- Phase 1 (repository, metadata adapter, read-only queries, plan preview).


