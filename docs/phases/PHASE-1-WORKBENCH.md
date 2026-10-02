# Phase 1 — Workbench

Repository, BSP workbench, editor, metadata browser, standard BPC metadata
adapter, read-only BPC queries, validation/plan preview, and Git export.

## Requirement IDs

- ASL-REPO-001..ASL-REPO-010 (repository, versions, Git export)
- ASL-UI-001..ASL-UI-015 (shell, editor, metadata browser, journeys)
- ASL-API-001..ASL-API-005 (REST contract)
- ASL-META-002..ASL-META-004, ASL-META-007..ASL-META-011 (standard metadata adapter, cache)
- ASL-DATA-004, ASL-DATA-005 (read-only BPC queries, pushdown)
- ASL-RUN-003, ASL-RUN-007..ASL-RUN-011 (logical plan, validation, read-only preview)
- ASL-PROD-029..ASL-PROD-031, ASL-PROD-041 (create/validate/publish/export acceptance)

## Scope

- Script repository and immutable versions (custom tables).
- BSP shell, catalog, editor, metadata browser.
- Standard BPC metadata adapter (read-only) and metadata cache.
- Read-only BPC fact queries with security enabled.
- Validation and logical-plan preview (no writes).
- Deterministic Git export.

## Excluded scope

- Write-back, output regions, run execution, locks, cancellation, allocation/time-series libraries, extension registry, spill storage.

## Expected objects or files

- ABAP: HTTP handler, application facade, repository, metadata service/cache, BPC query adapter (proposed names in §25).
- BSP/SAPUI5: shell and pages, editor and metadata browser assets.
- DDIC: `ZBPC_ASL_SCR`, `ZBPC_ASL_VER`, `ZBPC_ASL_PAR`, plus Git export layout.

## Acceptance criteria

- An author can create, edit, validate, version, compare, and publish a script; published source and metadata export deterministically. (ASL-PROD-029, ASL-PROD-041)
- The editor completes dimensions, properties, hierarchies, and members. (ASL-PROD-030)
- Scripts read booked data with member/property/hierarchy/parameter filters. (ASL-PROD-031)
- Validation and plan preview report resolved scopes and estimates without side effects.

## Required tests

- Metadata adapters, HTTP API, SAPUI5, semantic binding, Git export determinism (see [../TEST-PLAN.md](../TEST-PLAN.md) §4, §16, §17, §2).

## Dependencies

- Phase 0 (lexer, parser, binder, in-memory executor and test adapter).


