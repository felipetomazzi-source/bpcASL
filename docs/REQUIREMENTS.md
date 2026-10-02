# Requirements

Extracted from [SPECIFICATION.md](SPECIFICATION.md). Every requirement has a stable
identifier and links back to its specification section. The wording preserves the
meaning of the specification; it does not invent implementation completion.

## Identifier scheme

Each requirement ID uses a category prefix plus a zero-padded sequence number:

| Prefix | Category |
| --- | --- |
| `ASL-PROD` | Product behavior |
| `ASL-LANG` | Language and grammar |
| `ASL-TYPE` | Type system |
| `ASL-META` | BPC metadata |
| `ASL-DATA` | Dataset operations |
| `ASL-TIME` | Time-series operations |
| `ASL-PROC` | Procedural constructs |
| `ASL-WRITE` | Output regions and writes |
| `ASL-RUN` | Execution and planning |
| `ASL-SEC` | Security and authorization |
| `ASL-EXT` | Registered extensions |
| `ASL-REPO` | Scripts, versions, and Git export |
| `ASL-UI` | BSP/SAPUI5 application |
| `ASL-API` | HTTP/REST API |
| `ASL-OPS` | Logging, monitoring, and retention |
| `ASL-PERF` | Performance and limits |

Spec section references use `§` followed by the section and subsection (for
example `§18.2`). Multiple sections are separated by commas.

## ASL-PROD — Product behavior

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-PROD-001 | ASL is a governed, model-aware calculation language; it is not a general-purpose ABAP replacement. | §1 |
| ASL-PROD-002 | A BPC consultant must be able to write and maintain calculations without ABAP. | §2.1 |
| ASL-PROD-003 | Trained business power users must be able to maintain parameters and business rules. | §2.2 |
| ASL-PROD-004 | The language must support allocations, mappings, joins, depreciation, roll-forwards, time-series calculations, and multi-stage jobs. | §2.3 |
| ASL-PROD-005 | Every script must be associated with one BPC environment and one primary model while allowing explicit reads from and writes to other models. | §2.4 |
| ASL-PROD-006 | Member sets must be resolvable from explicit members, hierarchy nodes, properties, and runtime parameters. | §2.5 |
| ASL-PROD-007 | Syntax, metadata, shape, mapping, and write-scope errors must be detected before data is changed. | §2.6 |
| ASL-PROD-008 | The solution must routinely support hundreds of thousands of records and provide governed strategies for millions. | §2.7 |
| ASL-PROD-009 | Write-back must be minimized through key-level comparison and explicit output-region ownership. | §2.8 |
| ASL-PROD-010 | Dry-run estimates, trace output, diagnostics, restartability, and a durable audit trail must be provided. | §2.9 |
| ASL-PROD-011 | Scripts and version history must be stored in SAP custom tables with deterministic text export for Git. | §2.10 |
| ASL-PROD-012 | The core implementation must use standard SAP BPC and BW APIs. | §2.11 |
| ASL-PROD-013 | Extensions must be allowed only through an administrator-managed registry. | §2.12 |

| ASL-PROD-014 | The first release must not execute arbitrary ABAP source, programs, classes, SQL, or operating-system commands supplied by a script. | §3 |
| ASL-PROD-015 | The first release must not reproduce every Logic Script statement. | §3 |
| ASL-PROD-016 | The first release must not modify BPC metadata or dimension members. | §3 |
| ASL-PROD-017 | The first release must not provide an unrestricted HANA SQL editor. | §3 |
| ASL-PROD-018 | The first release must not guarantee atomic processing of an unlimited result set in one database LUW. | §3 |
| ASL-PROD-019 | The first release must not directly delete from generated BPC fact, shadow, or change-log tables. | §3 |
| ASL-PROD-020 | The first release must not reuse customer-specific `ZCL_BPC*` calculation implementations. | §3 |
| ASL-PROD-021 | The first release must not replace Data Manager orchestration. | §3 |
| ASL-PROD-022 | HTTP, repository, compiler, execution, and SAP-adapter responsibilities must be kept separate. | §25, §35 |
| ASL-PROD-023 | All repository objects for this application must belong to package `ZBPC_ASL` and this abapGit repository. | §35 |
| ASL-PROD-024 | ABAP must compile on SAP NetWeaver 7.52. | §35 |
| ASL-PROD-025 | Front-end code must run on SAPUI5 1.52. | §35 |
| ASL-PROD-026 | Newer ABAP syntax or APIs must be avoided unless guarded by a compatible adapter. | §35 |
| ASL-PROD-027 | Customer-specific `ZCL_BPC*` code must not be copied. | §35 |
| ASL-PROD-028 | `ZBPC_IO` must be used only as a reference for standard API usage and compatible BSP/ICF structure. | §35 |
| ASL-PROD-029 | An author can create, edit, validate, version, compare, and publish a script. | §37.1 |
| ASL-PROD-030 | The editor completes model dimensions, properties, hierarchies, and members. | §37.2 |
| ASL-PROD-031 | Scripts can read booked data using member, property, hierarchy, and parameter filters. | §37.3 |
| ASL-PROD-032 | Scripts can filter, calculate, map, group, join, union, and explicitly generate bounded combinations. | §37.4 |
| ASL-PROD-033 | Conditions, bounded member loops, functions, and procedures execute. | §37.5 |
| ASL-PROD-034 | A script can read from and write to more than one explicitly declared model. | §37.6 |
| ASL-PROD-035 | All writes target validated output regions and support `APPEND`, `MERGE`, and semantic `REPLACE`. | §37.7 |
| ASL-PROD-036 | Standard replacement omits unchanged records and reverses only stale keys. | §37.8 |
| ASL-PROD-037 | Preview reports resolved scopes and estimated new/changed/stale writes. | §37.9 |
| ASL-PROD-038 | The engine prevents an unapproved million-record clear/write plan. | §37.10 |
| ASL-PROD-039 | BPC security, work status, and locking are respected. | §37.11 |
| ASL-PROD-040 | Run progress, timings, messages, metrics, cancellation, and eligible restart are available in the UI. | §37.12 |
| ASL-PROD-041 | Published source and metadata export deterministically to text files. | §37.13 |
| ASL-PROD-042 | No script can invoke an unregistered ABAP class, program, SQL statement, or physical BW table. | §37.14 |
| ASL-PROD-043 | The solution runs on ABAP 7.52 and SAPUI5 1.52. | §37.15 |
| ASL-PROD-044 | The solution includes tests covering parser/semantic, execution, SAP integration, and reference scenarios. | §36 |

## ASL-LANG — Language and grammar

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-LANG-001 | Keywords are case-insensitive; quoted values preserve case; identifiers are case-insensitive and displayed as authored. | §8 |
| ASL-LANG-002 | Statements end with a semicolon. | §8 |
| ASL-LANG-003 | Comments use `//` for single line and `/* ... */` for block. | §8 |
| ASL-LANG-004 | The syntax shown in the specification is normative at the semantic level; minor grammar refinements are allowed only if they improve error recovery or remove ambiguity and examples can be migrated mechanically. | §8 |
| ASL-LANG-005 | A script is declared with `SCRIPT` plus `ENVIRONMENT` and `MODEL`, and may declare typed parameters. | §8, §9.2 |
| ASL-LANG-006 | Parameters may be required, have defaults, and restrict allowed values via `ALLOWED`. | §9.2 |
| ASL-LANG-007 | Parameter values are stored with the run and are not substituted into source text. | §9.2 |
| ASL-LANG-008 | Member sets are first-class values; union, intersection, and difference use `UNION`, `INTERSECT`, and `EXCEPT`. | §11 |
| ASL-LANG-009 | Hierarchy names are explicit because a dimension can have several hierarchies. | §11 |
| ASL-LANG-010 | `BASEMEMBERS` returns unique base members. | §11 |
| ASL-LANG-011 | Properties can be used when selecting members or when deriving values. | §11 |
| ASL-LANG-012 | Initial member-set functions are `MEMBERS`, `BASEMEMBERS`, `CHILDREN`, `DESCENDANTS`, `ANCESTORS`, `SIBLINGS`, `FILTERMEMBERS`, `RANGE`, `PREVIOUS`, `NEXT`, and `YTD`. | §11 |

## ASL-TYPE — Type system

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-TYPE-001 | Scalar types are `NUMBER`, `INTEGER`, `TEXT`, `BOOLEAN`, `DATE`, and `PERIOD`. | §9.1 |
| ASL-TYPE-002 | Composite types are `MEMBER OF <dimension>`, `MEMBERS OF <dimension>`, `DATASET`, and `REGION`. | §9.1 |
| ASL-TYPE-003 | There is no implicit conversion between member IDs and free text. | §9.1 |
| ASL-TYPE-004 | `NULL` is distinct from zero and from an empty string. | §9.1 |
| ASL-TYPE-005 | Functions declare their null behavior. | §9.1 |
| ASL-TYPE-006 | `NUMBER` uses BPC-compatible precision. | §9.1 |
| ASL-TYPE-007 | `INTEGER` is used for counters and bounded iteration. | §9.1 |
| ASL-TYPE-008 | `PERIOD` is a model time member with validated ordering metadata. | §9.1 |
| ASL-TYPE-009 | `MEMBER OF <dimension>` holds one valid member; `MEMBERS OF <dimension>` holds an ordered, distinct member set. | §9.1 |
| ASL-TYPE-010 | `DATASET` is a typed tabular value with dimensions, measures, and derived columns. | §9.1 |
| ASL-TYPE-011 | `REGION` is a bounded model write scope. | §9.1 |
| ASL-TYPE-012 | Member parameters are validated against the bound model and the executing user's access. | §9.2 |
| ASL-TYPE-013 | Every dataset has a source model or explicitly model-independent shape, key columns, measures (normally `SIGNEDDATA`), derived scalar columns, grain/uniqueness information, and lineage. | §9.3 |

## ASL-META — BPC metadata

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-META-001 | Dimension and property names are validated against the bound model. | §4.2 |
| ASL-META-002 | Cross-model transfers require explicit mappings where dimensions differ. | §4.2 |
| ASL-META-003 | Each script declares one environment and one primary model; the environment may be fixed or `CURRENT`. | §10 |
| ASL-META-004 | Additional models require declarations (`MODEL name = ...`). | §10 |
| ASL-META-005 | At validation or publication the compiler records a metadata signature covering the referenced models, dimensions, properties, and hierarchies. | §10 |
| ASL-META-006 | Before execution the compiler checks that required metadata still exists; a metadata change that invalidates the binding blocks execution and marks the version as requiring revalidation. | §10 |
| ASL-META-007 | The metadata cache has an administrator-configurable lifetime and an explicit refresh command; cache entries are separated by environment and model. | §10 |
| ASL-META-008 | Property and hierarchy expressions are resolved to member sets before the fact query. | §12.1 |
| ASL-META-009 | The implementation uses standard APIs: `CL_UJ_CONTEXT`, `CL_UJA_BPC_ADMIN_FACTORY`/`IF_UJA_APPLICATION_MANAGER`, `CL_UJA_DIM`, `CL_UJO_QUERY_FACTORY`/`IF_UJO_QUERY->RUN_RSDRI_QUERY` (security enabled), `CL_UJO_WB_FACTORY`/`IF_UJO_WRITE_BACK`, and standard BW APIs. | §26 |
| ASL-META-010 | Standard API calls are encapsulated so they can be substituted in tests. | §26 |
| ASL-META-011 | The implementation must not depend on generated `/BIC/`, `/B28/`, or similar physical tables. | §26 |

## ASL-DATA — Dataset operations

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-DATA-001 | Dataset operations preserve a known schema, grain, and lineage. | §4.2 |
| ASL-DATA-002 | Reads operate on booked data unless a script explicitly generates combinations. | §4.3 |
| ASL-DATA-003 | Joins that can multiply records and generation operations that can create large Cartesian products require explicit intent and configurable limits. | §4.3 |
| ASL-DATA-004 | `READ` returns booked records by default. | §12.1 |
| ASL-DATA-005 | Filters must be pushed to the BPC query adapter whenever the underlying API can represent them. | §12.1 |
| ASL-DATA-006 | Booked reads do not invent absent fact combinations; a zero result and a missing combination have different meanings. | §12.2 |
| ASL-DATA-007 | Scripts explicitly create combinations via `GENERATE`; `GENERATE` requires a declared or configured maximum, and the plan displays the estimated Cartesian-product size. | §12.2 |
| ASL-DATA-008 | Missing combinations are completed via `LEFT JOIN ON ALL COMMON DIMENSIONS` with `COALESCE`. | §12.2 |
| ASL-DATA-009 | Registered BW/external sources are invoked by name via `SOURCE "name"(...)`. | §12.3 |
| ASL-DATA-010 | `FILTER` and `CALCULATE` transform datasets. | §13.1 |
| ASL-DATA-011 | `MAP` changes or supplies destination columns. | §13.2 |
| ASL-DATA-012 | `TRANSPOSE` moves values across a declared dimension mapping without losing lineage. | §13.2 |
| ASL-DATA-013 | Mappings must define behavior for missing and duplicate matches: `ERROR`, `DROP`, or an explicit default; `ERROR` is the default. | §13.2 |
| ASL-DATA-014 | `GROUP BY` supports `SUM`, `COUNT`, `MIN`, `MAX`, `AVG`, `FIRST`, and `LAST`; `FIRST` and `LAST` require an explicit ordering expression. | §13.3 |
| ASL-DATA-015 | Supported join types are `INNER`, `LEFT`, `RIGHT`, and `FULL`. | §13.4 |
| ASL-DATA-016 | Every join declares expected cardinality: `ONE_TO_ONE`, `ONE_TO_MANY`, `MANY_TO_ONE`, or `MANY_TO_MANY`. | §13.4 |
| ASL-DATA-017 | `MANY_TO_MANY` joins require `ALLOW MULTIPLICATION` and a row limit. | §13.4 |
| ASL-DATA-018 | Runtime cardinality violations stop the affected stage before writes. | §13.4 |
| ASL-DATA-019 | `UNION ALL` preserves all rows; `UNION DISTINCT` removes exact duplicates; input schemas must be compatible or explicitly mapped. | §13.5 |
| ASL-DATA-020 | Allocation `ALLOCATE ... TO ... BY ... MATCH ON ...` with zero-driver, rounding, and residual-to-largest clauses is supported. | §15 |
| ASL-DATA-021 | Allocation supports driver normalization by partition, fixed percentages, equal split, positive/negative/zero-driver policies, rounding and deterministic residual assignment, reconciliation statistics, and explicit source/destination mappings. | §15 |

## ASL-TIME — Time-series operations

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-TIME-001 | The time-series library includes `PREVIOUS`, `NEXT`, and `ADD_PERIODS`. | §14 |
| ASL-TIME-002 | The time-series library includes `OPENING` and `CLOSING`. | §14 |
| ASL-TIME-003 | The time-series library includes `YTD`, `QTD`, and `ROLLING_SUM`. | §14 |
| ASL-TIME-004 | The time-series library includes `LAG` and `LEAD`. | §14 |
| ASL-TIME-005 | The time-series library includes `CUMULATIVE_SUM`. | §14 |
| ASL-TIME-006 | The time-series library includes `STRAIGHT_LINE`, `DECLINING_BALANCE`, and `REMAINING_LIFE`. | §14 |
| ASL-TIME-007 | The time-series library includes `SMOOTH` and `INDEX_VALUE`. | §14 |
| ASL-TIME-008 | Stateful functions require explicit `PARTITION BY` and `ORDER BY` clauses. | §14 |
| ASL-TIME-009 | The compiler validates that the time dimension has a deterministic order and that each partition can be processed independently. | §14 |

## ASL-PROC — Procedural constructs

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-PROC-001 | `IF`/`ELSE` conditions are supported. | §16.1 |
| ASL-PROC-002 | `FOR ... IN ...` bounded loops iterate only over finite scalar or member collections known before the loop starts. | §16.2 |
| ASL-PROC-003 | General unbounded `WHILE` loops are excluded from the first release. | §16.2 |
| ASL-PROC-004 | `COLLECT ... FROM ...` accumulates loop results. | §16.2 |
| ASL-PROC-005 | Functions are side-effect free. | §16.3 |
| ASL-PROC-006 | Procedures may create datasets and invoke other procedures. | §16.3 |
| ASL-PROC-007 | Procedures cannot write unless their declaration includes `WRITES` and the caller is validated for the same region. | §16.3 |
| ASL-PROC-008 | `PARALLEL BY ... MAX ...` parallel blocks are supported. | §16.4 |
| ASL-PROC-009 | The compiler permits parallel writes only when it proves partitions have disjoint output regions; otherwise execution is serialized or rejected. | §16.4 |
| ASL-PROC-010 | The configured worker maximum always overrides the script maximum. | §16.4 |
| ASL-PROC-011 | `ASSERT` statements stop a stage or entire run before its next write boundary; supported forms include `COUNT`, `SUM` with `TOLERANCE`, `UNIQUE`, and `ROWCOUNT`. | §17 |

## ASL-WRITE — Output regions and writes

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-WRITE-001 | Every write targets a named `REGION`. | §18.1 |
| ASL-WRITE-002 | A region must be statically bounded by enough dimensions to satisfy configured ownership rules. | §18.1 |
| ASL-WRITE-003 | The default governance rule requires at least environment, model, category, time scope, and a dedicated audit-trail or equivalent ownership member when those dimensions exist. | §18.1 |
| ASL-WRITE-004 | The result is checked against the region before any write; a record outside the declared region fails the stage. | §18.1 |
| ASL-WRITE-005 | Write modes are `APPEND` (add delta to existing intersections), `MERGE` (set supplied intersections, leave others unchanged), and `REPLACE` (make the complete owned region equal to the supplied result). | §18.2 |
| ASL-WRITE-006 | `REPLACE` is declarative and does not mean "write zero to every existing record". | §18.2 |
| ASL-WRITE-007 | Standard `MERGE`/`REPLACE` delta strategy: read current booked values, normalize to the full destination key, compare with configured numeric precision, omit unchanged intersections, write new/changed values, create reversals for stale keys (`REPLACE`), and record new/changed/unchanged/stale counts. | §18.3 |
| ASL-WRITE-008 | Large-volume replacement supports `KEY_DELTA`, `CHUNKED_WRITEBACK`, and `REGISTERED_BULK_REPLACE` strategies. | §18.4 |
| ASL-WRITE-009 | Automatic strategy selection is based on estimates and configuration; a forced bulk mode requires an authorized run profile. | §18.4 |
| ASL-WRITE-010 | The bulk adapter must validate provider type, scope, locks, authorization, and platform support, and must never directly delete from generated BPC fact tables. | §18.4 |
| ASL-WRITE-011 | Writes are divided into deterministic partitions and batches with centrally configured defaults and maximums. | §18.5 |
| ASL-WRITE-012 | Each committed partition has a checkpoint; on failure, restart resumes only partitions whose input signature and script version still match the original run. | §18.5 |
| ASL-WRITE-013 | ASL does not promise one LUW across a multi-million-record run; the run log must make partial completion explicit, and `REPLACE` partitions must be safely rerunnable. | §18.5 |
| ASL-WRITE-014 | The compiler rejects a write when the result cannot provide exactly one value per complete destination-model key after mappings and defaults are applied. | §9.3 |

## ASL-RUN — Execution and planning

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-RUN-001 | A script describes the desired result and the region it owns; the runtime chooses the safe physical read, comparison, partition, and write strategy. | §4.1 |
| ASL-RUN-002 | Physical delta handling is not part of the business language. | §4.1 |
| ASL-RUN-003 | The compiler produces a plan that users can inspect before execution; every stage reports row counts, timings, warnings, and the source location responsible for an error. | §4.4 |
| ASL-RUN-004 | Run states are `CREATED`, `VALIDATING`, `PLANNING`, `READY`, `RUNNING`, `COMPLETED`, `COMPLETED_WITH_WARNINGS`, `FAILED`, `CANCEL_REQUESTED`, `CANCELLED`, plus `RESTARTABLE` for interrupted restartable runs. | §19 |
| ASL-RUN-005 | The runtime executes phases from loading the immutable script version and parameters through persisting metrics, writing, and releasing locks. | §19 |
| ASL-RUN-006 | Cancellation is cooperative between stages/batches; a committed partition is not automatically reversed; a compensation or rerun procedure is generated when the write adapter can support it. | §19 |
| ASL-RUN-007 | The planner produces a directed acyclic graph of operations. | §20 |
| ASL-RUN-008 | The planner pushes model filters, resolves property/hierarchy selections once, projects only required dimensions/measures, aggregates early, selects hash or sorted joins, avoids materializing intermediates when streaming is safe, spills large intermediates, reuses immutable datasets, partitions stateful operations along valid keys, and prevents overlapping parallel writes. | §20 |
| ASL-RUN-009 | The plan preview displays, for each node, operation and source line, input/output schema and grain, estimated and actual row count, pushdown status, partition keys, memory/spill estimate, and elapsed time. | §20 |
| ASL-RUN-010 | Validation has no data side effects; preview reads metadata and, when authorized, data needed for reliable counts, and performs all processing through the write boundary without committing writes. | §21 |
| ASL-RUN-011 | A preview reports existing booked rows, calculated rows, new/changed/unchanged/stale rows, estimated writes, strategy, and partitions. | §21 |
| ASL-RUN-012 | Thresholds may produce informational, warning, approval-required, or blocking diagnostics; the approval workflow is configurable and separate from the language. | §21 |
| ASL-RUN-013 | The runtime maintains an application-level lock for each script/version run and normalized output region; overlapping regions cannot write concurrently unless a registered adapter provides stronger safe semantics. | §22 |
| ASL-RUN-014 | The engine respects locks enforced by the BPC write-back API; lock conflicts are reported with the blocked model and region; read-only previews do not take write locks. | §22 |
| ASL-RUN-015 | Parallelism is bounded by system configuration, run profile, model, and script; increasing parallelism is never used as a substitute for reducing the number of write records. | §22 |
| ASL-RUN-016 | Preview and execution requests return a run ID immediately; a background job or controlled worker processes the run; the UI polls progress with bounded frequency. | §30 |
| ASL-RUN-017 | The run header stores the immutable script version, serialized typed parameters, metadata signature, and plan hash; a restarted partition uses the same inputs; if any signature changes, the user must start a new run. | §30 |
| ASL-RUN-018 | Worker recovery detects runs left in `RUNNING` after a job/session failure, inspects checkpoints, and sets them to `RESTARTABLE` or `FAILED` with a diagnostic. | §30 |

## ASL-SEC — Security and authorization

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-SEC-001 | Roles are Script viewer, Script author, Script publisher, Script runner, Extension administrator, and Application administrator; a user may hold more than one role. | §5 |
| ASL-SEC-002 | BPC data authorization and work status remain effective in addition to ASL roles. | §5 |
| ASL-SEC-003 | The proposed authorization object `ZBPC_ASL` has fields Activity, Environment, Model, Script group, and Run profile. | §23.1 |
| ASL-SEC-004 | Final authorization-object design must follow the customer's naming and role standards. | §23.1 |
| ASL-SEC-005 | Reads and writes execute in the initiating user's security context unless an explicitly designed background service-user model is approved. | §23.2 |
| ASL-SEC-006 | Standard BPC member access, task authorization, work status, and write-back checks remain effective. | §23.2 |
| ASL-SEC-007 | Preview must not reveal member IDs, values, or trace rows the user cannot read; execution must not write values the user could not write through the approved BPC interface. | §23.2 |
| ASL-SEC-008 | Require authenticated SAP sessions and CSRF tokens for state-changing requests. | §23.3 |
| ASL-SEC-009 | Accept only JSON with strict request schemas and size limits. | §23.3 |
| ASL-SEC-010 | Encode all rendered values and never inject script text into HTML; do not evaluate script text in JavaScript. | §23.3 |
| ASL-SEC-011 | Do not expose ABAP class, program, table, provider, or SQL names through ungoverned request parameters. | §23.3 |
| ASL-SEC-012 | Record the SAP user for every state change and run. | §23.3 |
| ASL-SEC-013 | The application must not expose call stacks, SQL, credentials, or physical table names; internal exceptions are returned as safe messages. | §31 |

## ASL-EXT — Registered extensions

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-EXT-001 | Extensions are categorized as scalar function, table function, source, and action. | §24 |
| ASL-EXT-002 | Each registry entry contains stable public name/version, type and description, implementing ABAP class, required interface, parameter and output schema, allowed environments/models, required ASL role/activity, timeout/row/memory limits, determinism and side-effect flags, activation status and validity dates, and owner/change audit. | §24 |
| ASL-EXT-003 | Implementation classes are instantiated only after registry lookup and interface validation; script authors cannot name arbitrary ABAP artifacts. | §24 |
| ASL-EXT-004 | Actions require an explicit `ACTION` statement and cannot be invoked from scalar expressions. | §24 |
| ASL-EXT-005 | A source has a registered parameter schema, output schema, authorization policy, implementation class, timeout, and row limit; the script cannot supply a class, program, table, InfoProvider, or SQL name absent from the registry. | §12.3 |

## ASL-REPO — Scripts, versions, and Git export

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-REPO-001 | Scripts and version history are stored in SAP custom tables. | §2.10, §27 |
| ASL-REPO-002 | Logical tables required are `ZBPC_ASL_SCR`, `ZBPC_ASL_VER`, `ZBPC_ASL_PAR`, `ZBPC_ASL_RUN`, `ZBPC_ASL_STG`, `ZBPC_ASL_MSG`, `ZBPC_ASL_MET`, `ZBPC_ASL_EXT`, `ZBPC_ASL_CFG`, and `ZBPC_ASL_LOCK`. | §27 |
| ASL-REPO-003 | Source text is stored as UTF-8 content with a cryptographic hash. | §27 |
| ASL-REPO-004 | Published versions are immutable; editing always creates a draft version; one version per script may be active at a time. | §27 |
| ASL-REPO-005 | Large trace samples and temporary datasets use dedicated cluster/content storage or temporary BW/application tables, not oversized transparent table rows; retention jobs remove expired details while preserving mandatory audit headers. | §27 |
| ASL-REPO-006 | Git export is deterministic so an unchanged script produces no Git diff. | §28 |
| ASL-REPO-007 | Export layout is `scripts/<environment>/<model>/<script-id>/` containing `script.asl`, `metadata.json`, and `README.md`. | §28 |
| ASL-REPO-008 | `metadata.json` contains stable keys in a fixed order (`formatVersion`, `scriptId`, `environment`, `primaryModel`, `description`, `version`, `status`, `sourceHash`, `requiredExtensions`); volatile export timestamps are omitted. | §28 |
| ASL-REPO-009 | Import from Git is a later phase and must create a draft rather than silently replacing an active version. | §28 |
| ASL-REPO-010 | `ZBPC_ASL_SCR` stores script identity, environment, primary model, owner, folder, and status; `ZBPC_ASL_VER` stores immutable source versions with hash, metadata signature, author, and timestamps. | §27 |

## ASL-UI — BSP/SAPUI5 application

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-UI-001 | The UI uses a single SAPUI5 shell with pages: Home, Script catalog, Editor, Plan preview, Run monitor, Run details, Extension registry, and Settings. | §7 |
| ASL-UI-002 | The editor provides syntax highlighting and bracket matching. | §7 |
| ASL-UI-003 | The editor provides line and column diagnostics. | §7 |
| ASL-UI-004 | The editor provides completion for keywords, declared variables, model dimensions, properties, hierarchies, members, and registered extensions. | §7 |
| ASL-UI-005 | The editor provides hover information for dataset shape and function signatures. | §7 |
| ASL-UI-006 | The editor provides deterministic whitespace formatting. | §7 |
| ASL-UI-007 | The editor provides a metadata browser with dimension, property, hierarchy, and member search. | §7 |
| ASL-UI-008 | The editor provides side-by-side version comparison. | §7 |
| ASL-UI-009 | The editor provides a parameter form generated from declarations. | §7 |
| ASL-UI-010 | The editor provides Explain Plan and Preview Changes commands. | §7 |
| ASL-UI-011 | SAPUI5 1.52 compatibility is mandatory; controls and APIs introduced after 1.52 must not be used. | §7 |
| ASL-UI-012 | Create-a-script journey: select environment/model, create script with ID/description/folder/tags, define typed parameters, write code with metadata completion, validate, preview plan and changes, save draft, and publish. | §6.1 |
| ASL-UI-013 | Execute-a-script journey: open active script, supply/confirm parameters, choose Preview or Execute, review resolved counts/estimates/partitions/warnings, execute, follow progress, and review messages and trace. | §6.2 |
| ASL-UI-014 | Maintain-a-calculation journey: create draft from active, compare with base, validate/preview, publish as a new immutable active version, and roll back by reactivating an earlier version. | §6.3 |
| ASL-UI-015 | Export-to-Git journey: an authorized user exports scripts and metadata into a deterministic text layout. | §6.4 |

## ASL-API — HTTP/REST API

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-API-001 | Base path is `/sap/bc/zbpc_asl`. | §29 |
| ASL-API-002 | REST endpoints cover environments, models, metadata (dimensions and members), scripts (catalog, create, header, version, save, validate, publish, preview, execute), runs (header, stages, messages, cancel, restart), export, and extensions. | §29 |
| ASL-API-003 | State-changing operations require a CSRF token. | §29 |
| ASL-API-004 | Optimistic concurrency uses a version/hash or ETag; conflicting edits receive HTTP 409 and never overwrite a newer draft. | §29 |
| ASL-API-005 | Errors use a consistent envelope with `code`, `message`, `correlationId`, and `diagnostics` (severity, line, column, length, code, message). | §29 |

## ASL-OPS — Logging, monitoring, and retention

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-OPS-001 | Diagnostics have severity `INFO`, `WARNING`, or `ERROR`, a stable code, source location when applicable, stage/partition, and correlation ID. | §31 |
| ASL-OPS-002 | Errors are grouped as syntax/type, metadata binding, authorization/work-status, scope/cardinality, resource-limit, source/extension, lock conflicts, standard BPC/BW API, and infrastructure failures. | §31 |
| ASL-OPS-003 | Every run records script ID/version/hash, environment/model, initiating user and timestamps, typed parameter values with masking, metadata and plan hashes, resolved member counts and regions, stage/partition timings, row counts, new/changed/unchanged/stale counts, write strategy/batches/commits/retries, assertions/metrics/warnings/errors, and cancellation/restart events. | §33 |
| ASL-OPS-004 | Application logs use a correlation ID shared between HTTP requests, background jobs, and BPC/BW adapter messages; operational summaries are available in the UI and suitable for SAP application logging integration. | §33 |
| ASL-OPS-005 | `TRACE ... SAMPLE` samples are access-controlled and retained with the run according to configuration; production tracing may be restricted because samples contain business data. | §17 |
| ASL-OPS-006 | Retention jobs remove expired run details and temporary content while preserving mandatory audit headers. | §27 |

## ASL-PERF — Performance and limits

| ID | Requirement | Spec § |
| --- | --- | --- |
| ASL-PERF-001 | Configurable safeguards include maximum source size/token count, procedure call depth, loop iterations, generated combinations, join expansion factor, dataset rows in memory, spill size, preview/execution duration, parallel workers, standard write-back records per batch/run, large-volume threshold, and trace rows/retention. | §32 |
| ASL-PERF-002 | Limits are checked during validation, planning, and execution because estimates can differ from actual data. | §32 |
| ASL-PERF-003 | Editor metadata search remains interactive through paging and caching. | §34 |
| ASL-PERF-004 | Syntax validation of a normal script completes within two seconds excluding a metadata refresh. | §34 |
| ASL-PERF-005 | Explain Plan without data sampling completes within five seconds for a normal script. | §34 |
| ASL-PERF-006 | Execution overhead outside BPC/BW data access remains small relative to query and write time. | §34 |
| ASL-PERF-007 | The runtime avoids loading an unbounded model dataset into a single ABAP internal table. | §34 |
| ASL-PERF-008 | Standard writes are batched and compared with existing values. | §34 |
| ASL-PERF-009 | Million-record rebuilds are detected before write-back and require an approved plan rather than silently producing millions of zero/delta records. | §34 |
| ASL-PERF-010 | Each release publishes measured benchmarks and tested limits. | §34 |
| ASL-PERF-011 | The compiler warns on an unbounded model read; administrators can prohibit reads whose estimated record count exceeds a threshold unless the script or run has an approved large-volume flag. | §12.1 |
