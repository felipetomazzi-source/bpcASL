# Test Plan

Covers the testing strategy from SPECIFICATION.md §36 plus the specific areas
required for traceability. Each area lists concrete cases and maps to requirement
IDs. Reference scenarios use the customer models `ALLOC_OPEX`, `DEMREV`,
`DEMREVID`, `AGGR_PROJECT`, `AGGR_OPEX`, `FAR`, and `RAB`.

Unit-level compiler/runtime tests use a **test metadata adapter** and in-memory
datasets so they run without a live BPC system. SAP integration tests run against
a development system using standard BPC/BW APIs. Customer-specific `ZCL_BPC*`
output may be used only as a comparison oracle, never linked into ASL (§36.4).

## 1. Lexer and parser

- Tokenization of keywords, identifiers, quoted values, numbers, dates, and comments (`//`, `/* ... */`). (ASL-LANG-001..ASL-LANG-003)
- Statement termination by semicolon; case handling of keywords vs. quoted values. (ASL-LANG-001, ASL-LANG-002)
- Source locations (line/column/length) attached to every token for diagnostics. (ASL-OPS-001)
- Error recovery: a malformed statement yields a diagnostic and does not abort the whole parse. (ASL-LANG-004)
- AST shape for the representative scripts in §8, §11, §12, §13, §15, §16, §18.

## 2. Semantic binding

- Model/dimension/property/hierarchy resolution against the test metadata adapter. (ASL-META-001, ASL-META-008)
- `CURRENT` environment and `MODEL` declarations bind to the correct model. (ASL-META-003, ASL-META-004)
- Metadata signature recorded at validation and checked before execution. (ASL-META-005, ASL-META-006)
- Member-set resolution: `MEMBERS`, `BASEMEMBERS`, `CHILDREN`, `DESCENDANTS`, `ANCESTORS`, `SIBLINGS`, `FILTERMEMBERS`, `RANGE`, `PREVIOUS`, `NEXT`, `YTD`, and `UNION`/`INTERSECT`/`EXCEPT`. (ASL-LANG-008..ASL-LANG-012)

## 3. Type checking

- Scalar and composite types; no implicit member-ID/free-text conversion. (ASL-TYPE-001..ASL-TYPE-011)
- `NULL` distinct from zero and empty string; declared null behavior. (ASL-TYPE-004, ASL-TYPE-005)
- Parameter typing, defaults, and `ALLOWED` restrictions. (ASL-LANG-006, ASL-TYPE-012)
- Dataset schema/grain/lineage preserved across transforms; write rejected when the result cannot supply exactly one value per destination key. (ASL-TYPE-013, ASL-WRITE-014)

## 4. Metadata adapters

- Test adapter returns fixture dimensions, properties, hierarchies, and members deterministically. (ASL-META-010)
- Standard adapter (later) reads via `CL_UJA_DIM` etc.; cache lifetime and refresh; per environment/model separation. (ASL-META-007, ASL-META-009)
- Metadata change detection marks a version as requiring revalidation and blocks execution. (ASL-META-006)

## 5. Dataset execution

- `READ` booked-only behavior; `FILTER`, `CALCULATE`, `MAP`, `TRANSPOSE`, `GROUP BY`, `UNION ALL`/`UNION DISTINCT`. (ASL-DATA-004, ASL-DATA-010..ASL-DATA-014, ASL-DATA-019)
- `GENERATE` requires a maximum and reports estimated Cartesian size; `LEFT JOIN ON ALL COMMON DIMENSIONS` + `COALESCE` completes missing combinations. (ASL-DATA-007, ASL-DATA-008)
- Mapping missing/duplicate behavior `ERROR`/`DROP`/default, with `ERROR` default. (ASL-DATA-013)

## 6. Joins and cardinality

- `INNER`/`LEFT`/`RIGHT`/`FULL` joins with declared cardinality. (ASL-DATA-015, ASL-DATA-016)
- `MANY_TO_MANY` requires `ALLOW MULTIPLICATION` and a row limit. (ASL-DATA-017)
- Runtime cardinality violation stops the stage before any write. (ASL-DATA-018)

## 7. Allocations

- Driver normalization by partition, fixed percentages, equal split. (ASL-DATA-021)
- Positive, negative, and zero-driver policies (`ZERO DRIVER`). (ASL-DATA-020, ASL-DATA-021)
- Rounding and deterministic residual assignment (`RESIDUAL TO LARGEST`). (ASL-DATA-021)
- Reconciliation statistics between input and output. (ASL-DATA-021)
- Reference scenario: `ALLOC_OPEX` allocation, mapping, and existing-output comparison. (§36.4)

## 8. Time-series operations

- `PREVIOUS`/`NEXT`/`ADD_PERIODS`, `OPENING`/`CLOSING`, `YTD`/`QTD`/`ROLLING_SUM`, `LAG`/`LEAD`, `CUMULATIVE_SUM`, `STRAIGHT_LINE`/`DECLINING_BALANCE`/`REMAINING_LIFE`, `SMOOTH`/`INDEX_VALUE`. (ASL-TIME-001..ASL-TIME-007)
- Stateful functions require `PARTITION BY`/`ORDER BY`; deterministic time order and independent partitions validated. (ASL-TIME-008, ASL-TIME-009)
- Reference scenarios: `DEMREV`/`DEMREVID` time logic, `RAB` depreciation and roll-forward. (§36.4)

## 9. Output-region containment

- Region must be statically bounded; default governance rule (environment, model, category, time scope, ownership member). (ASL-WRITE-002, ASL-WRITE-003)
- Result checked against the region before any write; an out-of-region record fails the stage. (ASL-WRITE-004)

## 10. APPEND, MERGE, and REPLACE

- `APPEND` adds delta to existing intersections; `MERGE` sets supplied intersections and leaves others unchanged; `REPLACE` makes the owned region equal to the result without writing zero to every record. (ASL-WRITE-005, ASL-WRITE-006)
- Procedures can write only with `WRITES` and a caller validated for the same region. (ASL-PROC-007)

## 11. Delta comparison

- Read current booked values, normalize to full key, compare with numeric precision, omit unchanged, write new/changed, reverse stale keys for `REPLACE`, record new/changed/unchanged/stale counts. (ASL-WRITE-007)
- Preview reports the same five counts plus estimated writes and strategy. (ASL-RUN-011)

## 12. Security and work status

- ASL authorization object fields (Activity, Environment, Model, Script group, Run profile). (ASL-SEC-003)
- Reads/writes in the initiating user's context; BPC member access, task authorization, work status, and write-back checks effective. (ASL-SEC-005, ASL-SEC-006)
- Preview does not reveal data the user cannot read; execution does not write what the user cannot write. (ASL-SEC-007)
- CSRF, authenticated sessions, strict JSON schemas, encoded output, no JS eval of script text, no ungoverned ABAP/SQL names, user recorded for state changes. (ASL-SEC-008..ASL-SEC-012)

## 13. Locks

- Application-level lock per run and normalized output region; overlapping regions cannot write concurrently. (ASL-RUN-013)
- Respect BPC write-back API locks; lock conflicts report blocked model and region; read-only previews take no write locks. (ASL-RUN-014)
- Parallelism bounded by configuration/run profile/model/script; not a substitute for reducing write records. (ASL-RUN-015)

## 14. Cancellation and restart

- Cooperative cancellation between stages/batches; committed partitions not auto-reversed; compensation/rerun generated when supported. (ASL-RUN-006)
- Checkpoint per committed partition; restart resumes only partitions whose input signature and version still match. (ASL-WRITE-012)
- Worker recovery detects `RUNNING` after failure and sets `RESTARTABLE`/`FAILED`. (ASL-RUN-018)
- Run lifecycle state transitions, including `RESTARTABLE`. (ASL-RUN-004)

## 15. Extension registry

- Registry entry fields and validation at invocation. (ASL-EXT-002, ASL-EXT-003)
- Scalar function, table function, source, and action contracts; actions require `ACTION` statement. (ASL-EXT-001, ASL-EXT-004)
- Sources cannot name a class/program/table/InfoProvider/SQL absent from the registry. (ASL-EXT-005)
- Extension timeouts and schema violations fail safely. (§36.2)

## 16. HTTP API

- Endpoint coverage (environments, models, metadata, scripts, runs, export, extensions). (ASL-API-002)
- CSRF on state-changing requests; optimistic concurrency via ETag/version and HTTP 409. (ASL-API-003, ASL-API-004)
- Consistent error envelope with `code`, `message`, `correlationId`, `diagnostics`. (ASL-API-005)
- Request size limits and strict JSON schemas. (ASL-SEC-009)

## 17. SAPUI5

- Pages render on SAPUI5 1.52; no post-1.52 controls/APIs. (ASL-UI-001, ASL-UI-011)
- Editor: highlighting, bracket matching, diagnostics, completion, hover, formatting, metadata browser, diff, parameter form, Explain Plan/Preview Changes. (ASL-UI-002..ASL-UI-010)
- User journeys: create, execute, maintain, export. (ASL-UI-012..ASL-UI-015)

## 18. Performance and large-volume scenarios

- Syntax validation ≤2s (excluding metadata refresh); Explain Plan ≤5s without data sampling. (ASL-PERF-004, ASL-PERF-005)
- Avoid loading an unbounded dataset into one internal table; batched, compared writes. (ASL-PERF-007, ASL-PERF-008)
- Million-record rebuild detected before write-back and gated by an approved plan. (ASL-PERF-009)
- Configurable safeguards enforced during validation, planning, and execution. (ASL-PERF-001, ASL-PERF-002)
- Large-volume strategies `KEY_DELTA`/`CHUNKED_WRITEBACK`/`REGISTERED_BULK_REPLACE` eligibility and validation. (ASL-WRITE-008..ASL-WRITE-010)

## 19. Reference scenarios

| Model(s) | Scenarios exercised |
| --- | --- |
| `ALLOC_OPEX` | Allocation, mapping, existing-output comparison. |
| `DEMREV`, `DEMREVID` | Demand/revenue calculations and time logic. |
| `AGGR_PROJECT`, `AGGR_OPEX` | Aggregation and cross-model movement. |
| `FAR` | Source loading and asset-related calculations. |
| `RAB` | Depreciation, roll-forward, indexation, smoothing, geographic splits, parallel partitions, multi-million-row replacement planning. |

Each reference scenario must validate the plan preview estimates against actual
row counts after execution and record reconciliation statistics where applicable
(§36.4).

