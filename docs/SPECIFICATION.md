# BPC Advanced Script Language

## Product and Technical Specification

| Field | Value |
| --- | --- |
| Product | BPC Advanced Script Language (ASL) |
| Repository/package | `ZBPC_ASL` |
| Target platform | SAP BPC 10.1 Standard on SAP NetWeaver 7.52 |
| Front end | SAPUI5 1.52 BSP application |
| Status | Proposed specification |
| Primary users | BPC consultants and business power users |

## 1. Purpose

SAP BPC Standard offers two principal ways to implement model calculations:
Logic Script and custom ABAP. Logic Script is approachable but becomes difficult
to structure, validate, debug, and optimize as calculations grow. ABAP provides
full control but requires specialist expertise, exposes implementation details,
and often makes frequent business-rule changes expensive.

ASL provides a third option: a purpose-built, model-aware language for BPC
calculations. It offers dataframe-style transformations, procedural control,
strong validation, reusable functions, cross-model operations, execution
diagnostics, and controlled access to approved ABAP or BW capabilities.

ASL is not a general-purpose ABAP replacement. It is a governed calculation
language whose compiler understands BPC environments, models, dimensions,
members, properties, hierarchies, security, work status, and write-back
semantics.

## 2. Goals

ASL shall:

1. Allow a BPC consultant to write and maintain calculations without ABAP.
2. Allow trained business power users to maintain parameters and business rules.
3. Provide enough expressive power for allocations, mappings, joins,
   depreciation, roll-forwards, time-series calculations, and multi-stage jobs.
4. Associate every script with one BPC environment and primary model while
   allowing explicit reads from and writes to other models.
5. Resolve member sets from explicit members, hierarchy nodes, properties, and
   runtime parameters.
6. Detect syntax, metadata, shape, mapping, and write-scope errors before data is
   changed.
7. Support hundreds of thousands of records routinely and provide governed
   strategies for calculations involving millions of records.
8. Minimize write-back through key-level comparison and explicit output-region
   ownership.
9. Provide dry-run estimates, trace output, diagnostics, restartability, and a
   durable audit trail.
10. Store scripts and version history in SAP custom tables and allow deterministic
    text export for Git.
11. Use standard SAP BPC and BW APIs in the core implementation.
12. Allow extensions only through an administrator-managed registry.

## 3. Non-goals

The first release will not:

- Execute arbitrary ABAP source, programs, classes, SQL, or operating-system
  commands supplied by a script.
- Reproduce every Logic Script statement.
- Modify BPC metadata or dimension members.
- Provide an unrestricted HANA SQL editor.
- Guarantee atomic processing of an unlimited result set in one database LUW.
- Directly delete from generated BPC fact, shadow, or change-log tables.
- Reuse customer-specific `ZCL_BPC*` calculation implementations.
- Replace Data Manager orchestration in the first release.

## 4. Design principles

### 4.1 Desired result over physical operations

A script describes the desired calculation result and the region it owns. The
runtime chooses the safe physical read, comparison, partition, and write
strategy. Physical delta handling is not part of the business language.

### 4.2 Model-aware validation

Dimension and property names are validated against the bound model. Dataset
operations preserve a known schema, grain, and lineage. Cross-model transfers
require explicit mappings where dimensions differ.

### 4.3 Safe by default

Reads operate on booked data unless a script explicitly generates combinations.
Writes require a bounded output region. Joins that can multiply records and
generation operations that can create large Cartesian products require explicit
intent and configurable limits.

### 4.4 Explainable execution

The compiler produces a plan that users can inspect before execution. Every
stage reports row counts, timings, warnings, and the source location responsible
for an error.

### 4.5 Standard APIs and isolated adapters

Core BPC access is implemented through standard SAP APIs. Release-dependent
details are hidden behind internal adapter interfaces so the parser and language
semantics do not depend on physical BW table names.

## 5. Personas and roles

| Persona | Responsibilities |
| --- | --- |
| Script viewer | View active scripts, documentation, versions, plans, and run logs |
| Script author | Create drafts, edit code, validate, and run previews |
| Script publisher | Review and activate a validated version |
| Script runner | Execute active versions with permitted parameters and data scope |
| Extension administrator | Register and enable approved sources, functions, and actions |
| Application administrator | Configure limits, retention, Git export, and emergency controls |

A user may hold more than one role. BPC data authorization and work status remain
effective in addition to ASL roles.

## 6. Main user journeys

### 6.1 Create a script

1. Select an environment and primary model.
2. Create a script with a technical ID, description, and optional folder/tags.
3. Define typed parameters.
4. Write code in the editor using metadata-assisted completion.
5. Validate the script.
6. Preview its plan and expected data changes.
7. Save a draft version.
8. Publish the validated version if authorized.

### 6.2 Execute a script

1. Open an active script.
2. Supply or confirm parameter values.
3. Choose Preview or Execute.
4. Review resolved member counts, estimated reads and writes, partitions, and
   warnings.
5. Execute the run.
6. Follow progress by stage and partition.
7. Review messages and downloadable trace details.

### 6.3 Maintain a calculation

1. Create a draft from the active version.
2. Compare the draft with its base version.
3. validate and preview it using representative parameters.
4. Publish it as a new immutable active version.
5. Roll back by reactivating an earlier valid version when required.

### 6.4 Export to Git

An authorized user exports scripts and associated metadata into a deterministic
text layout. The application produces the files; a separate approved process or
abapGit repository operation transports them to Git.

## 7. Application structure

The BSP application name is proposed as `ZBPC_ASL`. The UI shall use a single
SAPUI5 shell with these pages:

| Page | Purpose |
| --- | --- |
| Home | Environment/model selection, recent scripts and runs |
| Script catalog | Search, filter, create, copy, archive, and open scripts |
| Editor | Code, metadata browser, parameters, validation, diff, and versions |
| Plan preview | Resolved scopes, logical plan, estimates, warnings, and write strategy |
| Run monitor | Stage/partition progress, messages, cancellation, and restart |
| Run details | Inputs, version, plan, row counts, timings, writes, and errors |
| Extension registry | Administrator management of approved extensions |
| Settings | Limits, retention, feature flags, and export configuration |

The editor should provide:

- Syntax highlighting and bracket matching.
- Line and column diagnostics.
- Completion for language keywords, declared variables, model dimensions,
  properties, hierarchies, members, and registered extensions.
- Hover information for dataset shape and function signatures.
- Formatting with deterministic whitespace.
- Metadata browser with dimension, property, hierarchy, and member search.
- Side-by-side version comparison.
- Parameter form generated from declarations.
- Explain Plan and Preview Changes commands.

SAPUI5 1.52 compatibility is mandatory. Controls and APIs introduced after 1.52
must not be used.

## 8. Language overview

The language is case-insensitive for keywords and preserves the case of quoted
values. Identifiers are case-insensitive and displayed as authored. Statements
end with a semicolon. Comments use `//` for one line and `/* ... */` for a block.

An illustrative script follows:

```asl
SCRIPT OPEX_ALLOCATION
    ENVIRONMENT CURRENT
    MODEL ALLOC_OPEX;

PARAMETER category AS MEMBER OF CATEGORY REQUIRED;
PARAMETER periods AS MEMBERS OF TIME REQUIRED;
PARAMETER simulation AS BOOLEAN DEFAULT FALSE;

LET drivers = READ ALLOC_OPEX
    WHERE CATEGORY = category
      AND TIME IN periods
      AND ACCOUNT IN BASEMEMBERS(PARENTH1, "OPEX_DRIVERS")
      AND SIGNEDDATA <> 0;

LET costs = READ ALLOC_OPEX
    WHERE CATEGORY = category
      AND TIME IN periods
      AND ACCOUNT IN BASEMEMBERS(PARENTH1, "ALLOCATABLE_OPEX")
      AND AUDITTRAIL = "INPUT";

LET weights = drivers
    GROUP BY TIME, COSTCENTRE, DRIVER_GROUP
    CALCULATE driver_total = SUM(SIGNEDDATA);

LET result = costs
    JOIN weights
      ON costs.TIME = weights.TIME
     AND PROPERTY(costs.COSTCENTRE, "DRIVER_GROUP") = weights.DRIVER_GROUP
      CARDINALITY MANY_TO_ONE
    CALCULATE SIGNEDDATA = costs.SIGNEDDATA * weights.SIGNEDDATA
                             / NULLIF(weights.driver_total, 0)
    MAP AUDITTRAIL = "ASL_OPEX_ALLOC";

OUTPUT allocation_region = REGION ALLOC_OPEX
    WHERE CATEGORY = category
      AND TIME IN periods
      AND AUDITTRAIL = "ASL_OPEX_ALLOC"
      AND ACCOUNT IN BASEMEMBERS(PARENTH1, "ALLOCATABLE_OPEX");

ASSERT SUM(result.SIGNEDDATA) ~= SUM(costs.SIGNEDDATA)
    TOLERANCE 0.01
    MESSAGE "Allocated value must reconcile with source cost";

IF NOT simulation THEN
    WRITE result TO allocation_region REPLACE;
END IF;
```

The syntax shown in this specification is normative at the semantic level. Minor
grammar refinements may be made during parser prototyping if they improve error
recovery or remove ambiguity, provided the examples can be migrated mechanically.

## 9. Lexical and type system

### 9.1 Scalar types

| Type | Meaning |
| --- | --- |
| `NUMBER` | Decimal numeric value using BPC-compatible precision |
| `INTEGER` | Whole number used for counters and bounded iteration |
| `TEXT` | Unicode text |
| `BOOLEAN` | `TRUE` or `FALSE` |
| `DATE` | Calendar date |
| `PERIOD` | Model time member with validated ordering metadata |
| `MEMBER OF <dimension>` | One valid member of a model dimension |
| `MEMBERS OF <dimension>` | Ordered, distinct member set |
| `DATASET` | Typed tabular value with dimensions, measures, and derived columns |
| `REGION` | Bounded model write scope |

There is no implicit conversion between member IDs and free text. `NULL` is
distinct from zero and an empty string. Functions declare their null behavior.

### 9.2 Parameters

Parameters may be required, have defaults, and optionally restrict allowed
values:

```asl
PARAMETER category AS MEMBER OF CATEGORY REQUIRED;
PARAMETER periods AS MEMBERS OF TIME REQUIRED;
PARAMETER threshold AS NUMBER DEFAULT 0.01;
PARAMETER mode AS TEXT DEFAULT "STANDARD"
    ALLOWED ("STANDARD", "FULL_REBUILD");
```

Member parameters are validated against the bound model and the executing
user's access. Parameter values are stored with the run, not substituted into
source text.

### 9.3 Dataset shape

Every dataset has:

- A source model or an explicitly model-independent shape.
- A set of key columns.
- Zero or more measures, normally including `SIGNEDDATA`.
- Derived scalar columns.
- Grain and uniqueness information.
- Lineage to source datasets and script locations.

The compiler rejects a write when the result cannot provide exactly one value
per complete destination-model key after mappings and defaults are applied.

## 10. Model and metadata binding

Each script declares one environment and one primary model. The environment may
be fixed at design time or represented by `CURRENT`, which binds to the script's
stored environment at execution time.

Additional models require declarations:

```asl
MODEL project = AGGR_PROJECT;
MODEL opex = ALLOC_OPEX;
MODEL rab = RAB;
```

At validation or publication, the compiler records a metadata signature covering
the referenced models, dimensions, properties, and hierarchies. Before execution
it checks that required metadata still exists. A metadata change that invalidates
the binding blocks execution and marks the version as requiring revalidation.

The metadata cache shall have an administrator-configurable lifetime and an
explicit refresh command. Cache entries must be separated by environment and
model.

## 11. Member-set expressions

Member sets are first-class values. Initial functions include:

```asl
MEMBERS("A", "B", "C")
BASEMEMBERS(PARENTH1, "TOTAL_OPEX")
CHILDREN(PARENTH1, "TOTAL_OPEX")
DESCENDANTS(PARENTH1, "TOTAL_OPEX")
ANCESTORS(PARENTH1, "MEMBER_01")
SIBLINGS(PARENTH1, "MEMBER_01")
FILTERMEMBERS(COSTCENTRE, PROPERTY("REGION") = "NORTH")
RANGE(TIME, "2026.001", "2026.012")
PREVIOUS(periods, 1)
NEXT(periods, 1)
YTD(periods)
```

Hierarchy names are explicit because a dimension can have several hierarchies.
`BASEMEMBERS` returns unique base members. Member-set union, intersection, and
difference use `UNION`, `INTERSECT`, and `EXCEPT`.

Properties can be used when selecting members or when deriving values:

```asl
LET regulated = FILTERMEMBERS(ASSET,
    PROPERTY("REGULATED") = "Y" AND PROPERTY("ZONE") <> "");
```

## 12. Reading data

### 12.1 BPC model reads

`READ` returns booked records by default:

```asl
LET actuals = READ rab
    WHERE CATEGORY = "ACTUAL"
      AND TIME IN periods
      AND RAB_ACCOUNT IN accounts
      AND SIGNEDDATA <> 0;
```

Filters must be pushed to the BPC query adapter whenever the underlying API can
represent them. Property and hierarchy expressions should be resolved to member
sets before the fact query.

The compiler warns on an unbounded model read. Administrators can prohibit reads
whose estimated record count exceeds a threshold unless the script or run has an
approved large-volume flag.

### 12.2 Missing combinations

Booked reads do not invent absent fact combinations. A zero result and a missing
combination have different meanings. Scripts explicitly create combinations:

```asl
LET target_grid = GENERATE
    TIME FROM periods,
    COSTCENTRE FROM target_centres,
    ACCOUNT FROM target_accounts
    LIMIT 500000;

LET complete = target_grid
    LEFT JOIN actuals ON ALL COMMON DIMENSIONS
    CALCULATE SIGNEDDATA = COALESCE(actuals.SIGNEDDATA, 0);
```

`GENERATE` requires a declared or configured maximum. The plan displays the
estimated Cartesian-product size before execution.

### 12.3 Registered BW and external sources

Approved sources are invoked by name:

```asl
LET tax_rates = SOURCE "BW_TAX_RATES"(
    company = companies,
    periods = periods
);
```

A source has a registered parameter schema, output schema, authorization policy,
implementation class, timeout, and row limit. The script cannot supply a class,
program, table, InfoProvider, or SQL name that is absent from the registry.

## 13. Dataset transformations

### 13.1 Filter and calculate

```asl
LET active = assets FILTER SIGNEDDATA <> 0 AND useful_life > 0;

LET monthly = active
    CALCULATE depreciation = SIGNEDDATA / useful_life / 12,
              end_period = ADD_PERIODS(start_period, useful_life * 12);
```

### 13.2 Map and transpose

`MAP` changes or supplies destination columns:

```asl
LET mapped = source
    MAP ACCOUNT = PROPERTY(source.ASSET_CLASS, "DEPN_ACCOUNT"),
        AUDITTRAIL = "ASL_DEPN",
        CATEGORY = category;
```

`TRANSPOSE` moves values across a declared dimension mapping without losing
lineage:

```asl
LET moved = source TRANSPOSE RAB_ACCOUNT USING account_mapping;
```

Mappings must define behavior for missing and duplicate matches: `ERROR`, `DROP`,
or an explicit default. `ERROR` is the default.

### 13.3 Group and aggregate

```asl
LET totals = source
    GROUP BY TIME, COSTCENTRE
    CALCULATE SIGNEDDATA = SUM(SIGNEDDATA),
              row_count = COUNT();
```

Initial aggregations are `SUM`, `COUNT`, `MIN`, `MAX`, `AVG`, `FIRST`, and `LAST`.
`FIRST` and `LAST` require an explicit ordering expression.

### 13.4 Joins

```asl
LET result = costs
    LEFT JOIN rates
      ON costs.TIME = rates.TIME
     AND costs.COMPANY = rates.COMPANY
      CARDINALITY MANY_TO_ONE;
```

Supported join types are `INNER`, `LEFT`, `RIGHT`, and `FULL`. Every join declares
expected cardinality: `ONE_TO_ONE`, `ONE_TO_MANY`, `MANY_TO_ONE`, or
`MANY_TO_MANY`. `MANY_TO_MANY` also requires `ALLOW MULTIPLICATION` and a row
limit. Runtime cardinality violations stop the affected stage before writes.

### 13.5 Union

`UNION ALL` preserves all rows. `UNION DISTINCT` removes exact duplicates. Input
schemas must be compatible or explicitly mapped.

## 14. Time-series operations

The initial library shall include model-aware functions needed by the analyzed
calculation families:

- `PREVIOUS`, `NEXT`, and `ADD_PERIODS`
- `OPENING` and `CLOSING`
- `YTD`, `QTD`, and `ROLLING_SUM`
- `LAG` and `LEAD`
- `CUMULATIVE_SUM`
- `STRAIGHT_LINE`
- `DECLINING_BALANCE`
- `REMAINING_LIFE`
- `SMOOTH`
- `INDEX_VALUE`

Stateful functions require explicit `PARTITION BY` and `ORDER BY` clauses:

```asl
LET rollforward = movements
    CALCULATE closing = OPENING(opening_balance)
                      + additions - disposals - depreciation
        PARTITION BY ASSET, CATEGORY
        ORDER BY TIME;
```

The compiler validates that the time dimension has a deterministic order and
that each partition can be processed independently.

## 15. Allocation

Allocation is a core operation rather than a hidden custom program:

```asl
LET allocated = ALLOCATE costs
    TO target_centres
    BY drivers.SIGNEDDATA
    MATCH ON TIME, DRIVER_GROUP
    ZERO DRIVER ERROR
    ROUND 2
    RESIDUAL TO LARGEST;
```

Allocation shall support:

- Driver normalization by partition.
- Fixed percentages.
- Equal split.
- Positive, negative, and zero-driver policies.
- Rounding and deterministic residual assignment.
- Reconciliation statistics between input and output.
- Explicit source and destination mappings.

## 16. Procedural constructs

### 16.1 Conditions

```asl
IF mode = "FULL_REBUILD" THEN
    CALL prepare_full_rebuild();
ELSE
    CALL calculate_delta();
END IF;
```

### 16.2 Bounded loops

```asl
FOR period IN periods DO
    LET one_period = CALL calculate_period(period);
    COLLECT result FROM one_period;
END FOR;
```

Loops may iterate only over finite scalar/member collections known before the
loop starts. General unbounded `WHILE` loops are excluded from the first release.

### 16.3 Functions and procedures

```asl
FUNCTION safe_ratio(numerator AS NUMBER, denominator AS NUMBER)
    RETURNS NUMBER
BEGIN
    RETURN CASE WHEN denominator = 0 THEN 0
                ELSE numerator / denominator END;
END;

PROCEDURE calculate_period(period AS MEMBER OF TIME)
    RETURNS DATASET
BEGIN
    // statements
    RETURN result;
END;
```

Functions are side-effect free. Procedures may create datasets and invoke other
procedures but cannot write unless their declaration includes `WRITES` and the
caller is validated for the same region.

### 16.4 Parallel blocks

```asl
PARALLEL BY period IN periods MAX 6 DO
    CALL calculate_period(period);
END PARALLEL;
BARRIER;
```

The compiler permits parallel writes only when it proves that partitions have
disjoint output regions. Otherwise execution is serialized or rejected. The
configured worker maximum always overrides the script maximum.

## 17. Assertions and diagnostics

Assertions stop a stage or entire run before its next write boundary:

```asl
ASSERT COUNT(unmapped) = 0 MESSAGE "Unmapped asset classes";
ASSERT SUM(result.SIGNEDDATA) ~= SUM(source.SIGNEDDATA)
    TOLERANCE 0.01;
ASSERT UNIQUE(mapping, ASSET_CLASS);
ASSERT ROWCOUNT(result) <= 1000000;
```

Diagnostic commands include:

```asl
TRACE result SAMPLE 100;
METRIC "allocated_total" = SUM(result.SIGNEDDATA);
```

Trace samples are access-controlled and retained with the run according to
configuration. Production tracing may be restricted because samples contain
business data.

## 18. Output regions and writes

### 18.1 Region declaration

Every write targets a named `REGION`:

```asl
OUTPUT depn_region = REGION RAB
    WHERE CATEGORY = category
      AND TIME IN periods
      AND AUDITTRAIL = "ASL_DEPN"
      AND RAB_ACCOUNT IN depreciation_accounts;
```

A region must be statically bounded by enough dimensions to satisfy configured
ownership rules. The default governance rule requires at least environment,
model, category, time scope, and a dedicated audit-trail or equivalent ownership
member when those dimensions exist.

The result is checked against the region before any write. A record outside the
declared region fails the stage.

### 18.2 Write modes

| Mode | Semantics |
| --- | --- |
| `APPEND` | Add delta values to existing intersections |
| `MERGE` | Set supplied intersections; leave other records in the region unchanged |
| `REPLACE` | Make the complete owned region equal to the supplied result |

`REPLACE` is declarative. It does not mean “write zero to every existing record.”

### 18.3 Standard delta strategy

For normal `MERGE` and `REPLACE` executions, the runtime shall:

1. Read the current booked values in the owned region.
2. Normalize source and result values to the full destination key.
3. Compare values using configured numeric precision.
4. Omit unchanged intersections.
5. Write new and changed values.
6. For `REPLACE`, create reversals only for existing keys absent from the result.
7. Record new, changed, unchanged, and stale counts.

This optimization is an engine concern and is not visible as script code.

### 18.4 Large-volume replacement

When most of a region containing millions of records changes, comparison cannot
eliminate the physical work. The planner shall support these governed strategies:

| Strategy | Use |
| --- | --- |
| `KEY_DELTA` | A minority of intersections change |
| `CHUNKED_WRITEBACK` | Per-record BPC processing is required for a larger change |
| `REGISTERED_BULK_REPLACE` | An administrator-approved supported BW/BPC mechanism can replace nearly the full region |

Automatic selection is based on estimates and configuration. A forced bulk mode
requires an authorized run profile. The bulk adapter must validate provider type,
scope, locks, authorization, and platform support. It must never directly delete
from generated BPC fact tables.

For derived results that are routinely rebuilt at multi-million-row scale, the
solution owner should consider a dedicated ADSO or versioned output partition,
combined with planning input at the reporting-provider layer. That is an
architecture option, not an implicit script behavior.

### 18.5 Chunking and commit behavior

Writes are divided into deterministic partitions and batches. Defaults and
maximums are configured centrally. Each committed partition has a checkpoint.
On failure, restart resumes only partitions whose input signature and script
version still match the original run.

ASL does not promise one LUW across a multi-million-record run. The run log must
make partial completion explicit. `REPLACE` partitions should be constructed so
each partition can be safely rerun.

## 19. Execution lifecycle

Each run moves through these states:

```text
CREATED -> VALIDATING -> PLANNING -> READY -> RUNNING
        -> COMPLETED
        -> COMPLETED_WITH_WARNINGS
        -> FAILED
        -> CANCEL_REQUESTED -> CANCELLED
```

An interrupted restartable run can additionally enter `RESTARTABLE`.

The runtime phases are:

1. Load immutable script version and parameters.
2. Authorize script, model, parameters, and requested run mode.
3. Revalidate metadata signature.
4. Parse and type-check.
5. Resolve members, properties, and hierarchies.
6. Build and optimize the logical plan.
7. Estimate reads, generated combinations, and writes.
8. Acquire required execution and output-region locks.
9. Execute stages and partitions.
10. Validate output scopes and assertions.
11. Write through the selected strategy.
12. Persist metrics, messages, and final status.
13. Release locks and temporary data.

Cancellation is cooperative between stages/batches. A committed partition is not
automatically reversed. A compensation or rerun procedure is generated when the
write adapter can support it.

## 20. Planning and optimization

The planner produces a directed acyclic graph of operations. It shall:

- Push model filters to the query adapter.
- Resolve property/hierarchy selections once and reuse them.
- Project only required dimensions and measures.
- Aggregate early when semantics permit.
- Select hash or sorted join strategies from estimated cardinality.
- Avoid materializing intermediate datasets when streaming is safe.
- Spill large intermediate datasets to governed temporary storage.
- Reuse an immutable dataset referenced by several stages.
- Partition stateful operations only along valid partition keys.
- Prevent parallel partitions from writing overlapping regions.

The plan preview displays, for each node:

- Operation and source line.
- Input/output schema and grain.
- Estimated and actual row count.
- Pushdown status.
- Partition keys.
- Memory/spill estimate.
- Elapsed time after execution.

## 21. Preview and dry run

Validation has no data side effects. Preview reads metadata and, when authorized,
data needed to calculate reliable counts. It performs all processing through the
write boundary without committing writes.

A preview shall report:

```text
Existing booked rows:  4,820,115
Calculated rows:       3,940,276
New rows:                 80,211
Changed rows:          1,105,419
Unchanged rows:        1,874,126
Stale rows:              960,731
Estimated writes:      2,146,361
Strategy:              REGISTERED_BULK_REPLACE
Partitions:            24 by fiscal year and asset class
```

Thresholds may produce informational, warning, approval-required, or blocking
diagnostics. The exact approval workflow is configurable and separate from the
language.

## 22. Locking and concurrency

The runtime maintains an application-level lock for each script/version run and
normalized output region. Overlapping regions cannot write concurrently unless a
registered adapter provides stronger safe semantics.

The engine must also respect locks enforced by the BPC write-back API. Lock
conflicts are reported with the blocked model and region. Read-only previews do
not take write locks.

Parallelism is bounded by system configuration, run profile, model, and script.
Increasing parallelism is never used as a substitute for reducing the number of
write records.

## 23. Security

### 23.1 Application authorization

Proposed authorization object `ZBPC_ASL` fields:

| Field | Examples |
| --- | --- |
| Activity | Display, create, change, publish, execute, administer |
| Environment | BPC environment ID |
| Model | BPC model ID or controlled wildcard |
| Script group | Folder or governance group |
| Run profile | Preview, standard, large-volume, bulk |

Final authorization-object design must follow the customer's naming and role
standards.

### 23.2 BPC authorization and work status

Reads and writes execute in the initiating user's security context unless an
explicitly designed background service-user model is approved. Standard BPC
member access, task authorization, work status, and write-back checks remain
effective.

Preview must not reveal member IDs, values, or trace rows that the user cannot
read. Execution must not write values the user could not write through the
approved BPC interface.

### 23.3 Input and HTTP security

- Require authenticated SAP sessions.
- Enforce CSRF tokens for state-changing requests.
- Accept only JSON with strict request schemas and size limits.
- Encode all rendered values and never inject script text into HTML.
- Do not evaluate script text in JavaScript.
- Do not expose ABAP class, program, table, provider, or SQL names through
  ungoverned request parameters.
- Record the SAP user for every state change and run.

## 24. Governed extension model

Extensions are categorized as:

| Type | Contract |
| --- | --- |
| Scalar function | Deterministic value calculation without side effects |
| Table function | Dataset in, dataset out, with declared schema and limits |
| Source | Reads an approved BW or application source |
| Action | Performs a governed side effect or bulk operation |

Each registry entry contains:

- Stable public name and version.
- Type and description.
- Implementing ABAP class.
- Required interface.
- Parameter and output schema.
- Allowed environments/models.
- Required ASL role/activity.
- Timeout, row, and memory limits.
- Determinism and side-effect flags.
- Activation status and validity dates.
- Owner and change audit.

Implementation classes are instantiated only after registry lookup and interface
validation. Script authors cannot name arbitrary ABAP artifacts. Actions require
an explicit `ACTION` statement and cannot be invoked from scalar expressions.

## 25. Backend architecture

```text
SAPUI5 BSP ZBPC_ASL
        |
        | JSON/HTTP + CSRF
        v
ZCL_BPC_ASL_HTTP             ICF routing, request limits, JSON
        |
        v
ZCL_BPC_ASL_APP              use cases and authorization
        |
        +---------------- Script repository/version service
        +---------------- Metadata service/cache
        +---------------- Parser and semantic compiler
        +---------------- Planner and estimator
        +---------------- Run coordinator/worker
        +---------------- Diagnostics and audit
        |
        v
Adapter interfaces
        +---------------- BPC metadata adapter
        +---------------- BPC query adapter
        +---------------- BPC write adapter
        +---------------- BW/source adapters
        +---------------- Registered extensions
```

Proposed core classes and interfaces:

| Object | Responsibility |
| --- | --- |
| `ZCL_BPC_ASL_HTTP` | ICF handler and JSON protocol |
| `ZCL_BPC_ASL_APP` | Application use-case facade |
| `ZCL_BPC_ASL_REPOSITORY` | Scripts, versions, activation, export |
| `ZCL_BPC_ASL_LEXER` | Tokens and source locations |
| `ZCL_BPC_ASL_PARSER` | Abstract syntax tree and syntax recovery |
| `ZCL_BPC_ASL_BINDER` | Names, models, dimensions, properties, types |
| `ZCL_BPC_ASL_PLANNER` | Logical/physical plan and estimates |
| `ZCL_BPC_ASL_EXECUTOR` | Stage and dataset execution |
| `ZCL_BPC_ASL_RUNNER` | Run lifecycle, locks, checkpoints, cancellation |
| `ZCL_BPC_ASL_METADATA` | Model metadata facade and cache |
| `ZCL_BPC_ASL_BPC_QUERY` | Standard BPC fact-query implementation |
| `ZCL_BPC_ASL_BPC_WRITE` | Comparison and standard write-back |
| `ZCL_BPC_ASL_EXTENSIONS` | Registry lookup and invocation |
| `ZIF_BPC_ASL_SOURCE` | Registered source contract |
| `ZIF_BPC_ASL_FUNCTION` | Registered table/scalar function contract |
| `ZIF_BPC_ASL_ACTION` | Registered governed action contract |

Names are proposals and can be shortened where the ABAP release imposes naming
limits.

## 26. Standard SAP integration

The implementation shall use standard APIs demonstrated by the `ZBPC_IO`
reference application, including release-appropriate use of:

- `CL_UJ_CONTEXT` for BPC context.
- `CL_UJA_BPC_ADMIN_FACTORY` and `IF_UJA_APPLICATION_MANAGER` for application
  metadata and dynamic application records.
- `CL_UJA_DIM` for dimension members, properties, and hierarchies.
- `CL_UJO_QUERY_FACTORY` and `IF_UJO_QUERY->RUN_RSDRI_QUERY` for fact reads with
  security enabled.
- `CL_UJO_WB_FACTORY` and `IF_UJO_WRITE_BACK` for supported BPC writes.
- Standard BW APIs for approved provider reads or bulk operations where the
  provider type and installed release support them.

Standard API calls are encapsulated so they can be substituted in tests. The
implementation must not depend on generated `/BIC/`, `/B28/`, or similar physical
tables.

## 27. Persistence model

Exact DDIC field names may change during implementation, but the logical tables
are required:

| Table | Purpose |
| --- | --- |
| `ZBPC_ASL_SCR` | Script identity, environment, primary model, owner, folder, status |
| `ZBPC_ASL_VER` | Immutable source versions, hash, metadata signature, author, timestamps |
| `ZBPC_ASL_PAR` | Optional indexed parameter declarations for catalog/search |
| `ZBPC_ASL_RUN` | Run header, version, user, parameters, state, strategy, totals |
| `ZBPC_ASL_STG` | Stage and partition timing, counts, checkpoints, status |
| `ZBPC_ASL_MSG` | Structured diagnostics and runtime messages |
| `ZBPC_ASL_MET` | Named metrics and reconciliation values |
| `ZBPC_ASL_EXT` | Extension registry |
| `ZBPC_ASL_CFG` | Application configuration |
| `ZBPC_ASL_LOCK` | Optional durable ownership/lock records if enqueue keys are insufficient |

Source text is stored as UTF-8 content with a cryptographic hash. Published
versions are immutable. Editing always creates a draft version. One version per
script may be active at a time.

Large trace samples and temporary datasets should use dedicated cluster/content
storage or temporary BW/application tables rather than oversized transparent
table rows. Retention jobs remove expired run details and temporary content while
preserving mandatory audit headers.

## 28. Git export format

Export is deterministic so an unchanged script produces no Git diff:

```text
scripts/
  <environment>/
    <model>/
      <script-id>/
        script.asl
        metadata.json
        README.md
```

`metadata.json` contains stable keys in a fixed order:

```json
{
  "formatVersion": 1,
  "scriptId": "OPEX_ALLOCATION",
  "environment": "ENVIRONMENT_ID",
  "primaryModel": "ALLOC_OPEX",
  "description": "Allocate OPEX using configured drivers",
  "version": 7,
  "status": "ACTIVE",
  "sourceHash": "...",
  "requiredExtensions": []
}
```

Volatile export timestamps are omitted. Import from Git is a later phase and must
create a draft rather than silently replacing an active version.

## 29. REST API

Base path is proposed as `/sap/bc/zbpc_asl`.

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/environments` | Environments available to the user |
| `GET` | `/models?environment=...` | Models in an environment |
| `GET` | `/metadata/dimensions` | Model dimensions and properties |
| `GET` | `/metadata/members` | Paged member/hierarchy lookup |
| `GET` | `/scripts` | Search script catalog |
| `POST` | `/scripts` | Create script identity and first draft |
| `GET` | `/scripts/{id}` | Script header and active/draft summary |
| `GET` | `/scripts/{id}/versions/{version}` | Source and version metadata |
| `POST` | `/scripts/{id}/versions` | Save a new immutable draft version |
| `POST` | `/scripts/{id}/validate` | Parse, bind, and validate source |
| `POST` | `/scripts/{id}/publish` | Activate a validated version |
| `POST` | `/scripts/{id}/preview` | Create an asynchronous preview run |
| `POST` | `/scripts/{id}/execute` | Create an asynchronous execution run |
| `GET` | `/runs/{id}` | Run header and progress |
| `GET` | `/runs/{id}/stages` | Stage/partition details |
| `GET` | `/runs/{id}/messages` | Paged diagnostics |
| `POST` | `/runs/{id}/cancel` | Request cooperative cancellation |
| `POST` | `/runs/{id}/restart` | Restart eligible failed partitions |
| `GET` | `/scripts/{id}/export` | Deterministic text export |
| `GET` | `/extensions` | Registered extension catalog |

State-changing operations require a CSRF token. Optimistic concurrency uses a
version/hash or ETag. Conflicting edits receive HTTP 409 and never overwrite a
newer draft.

Errors use a consistent envelope:

```json
{
  "error": {
    "code": "ASL_SEMANTIC_ERROR",
    "message": "Unknown property DEPN_ACCT on dimension ASSET_CLASS",
    "correlationId": "...",
    "diagnostics": [
      { "severity": "ERROR", "line": 18, "column": 24,
        "length": 9, "code": "UNKNOWN_PROPERTY", "message": "..." }
    ]
  }
}
```

## 30. Background execution

Preview and execution requests return a run ID immediately. A background job or
controlled worker processes the run. The UI polls progress with bounded frequency
because WebSocket support cannot be assumed on the target stack.

The run header stores the immutable script version, serialized typed parameters,
metadata signature, and plan hash. A restarted partition uses the same inputs.
If any signature changes, the user must start a new run.

Worker recovery shall detect runs left in `RUNNING` after a job/session failure,
inspect checkpoints, and set them to `RESTARTABLE` or `FAILED` with a diagnostic.

## 31. Error handling

Diagnostics have severity `INFO`, `WARNING`, or `ERROR`, a stable code, source
location when applicable, stage/partition, and correlation ID.

Errors are grouped as:

- Syntax and type errors.
- Metadata binding errors.
- Authorization and work-status errors.
- Scope and cardinality violations.
- Resource-limit violations.
- Source/extension failures.
- Lock conflicts.
- Standard BPC/BW API errors.
- Infrastructure failures.

Internal exceptions are logged with technical detail but returned to normal users
as safe messages. The application must not expose call stacks, SQL, credentials,
or physical table names.

## 32. Limits and safeguards

Initial configurable safeguards include:

- Maximum source size and token count.
- Maximum procedure call depth.
- Maximum loop iterations.
- Maximum generated combinations.
- Maximum join expansion factor.
- Maximum dataset rows in memory.
- Maximum spill size.
- Maximum preview and execution duration.
- Maximum parallel workers.
- Maximum standard write-back records per batch and run.
- Threshold requiring a large-volume run profile.
- Maximum trace rows and retention period.

Limits are checked during validation, planning, and execution because estimates
can differ from actual data.

## 33. Observability and audit

Every run records:

- Script ID/version/hash and environment/model.
- Initiating user and timestamps.
- Typed parameter values, with configurable masking.
- Metadata and plan hashes.
- Resolved member counts and regions.
- Stage and partition timings.
- Rows read, generated, joined, aggregated, calculated, and written.
- New, changed, unchanged, and stale intersection counts.
- Selected write strategy, batches, commits, and retries.
- Assertions, metrics, warnings, and errors.
- Cancellation and restart events.

Application logs use a correlation ID shared between HTTP requests, background
jobs, and BPC/BW adapter messages. Operational summaries should be available in
the UI and suitable for SAP application logging integration.

## 34. Performance requirements

Performance targets must be baselined on representative customer models. The
design targets are:

- Editor metadata search remains interactive through paging and caching.
- Syntax validation of a normal script completes within two seconds excluding a
  metadata refresh.
- Explain Plan without data sampling completes within five seconds for a normal
  script.
- Execution overhead outside BPC/BW data access remains small relative to query
  and write time.
- The runtime avoids loading an unbounded model dataset into a single ABAP
  internal table.
- Standard writes are batched and compared with existing values.
- Million-record rebuilds are detected before write-back and require an approved
  plan rather than silently producing millions of zero/delta records.

No fixed end-to-end runtime is specified because model design, HANA/BW sizing,
locks, and calculation complexity dominate it. Each release must publish measured
benchmarks and tested limits.

## 35. Compatibility and coding constraints

- ABAP must compile on SAP NetWeaver 7.52.
- Front-end code must run on SAPUI5 1.52.
- Avoid newer ABAP syntax or APIs unless guarded by a compatible adapter.
- Keep HTTP, repository, compiler, execution, and SAP-adapter responsibilities
  separate.
- Do not copy customer-specific `ZCL_BPC*` code.
- Use `ZBPC_IO` only as a reference for standard API usage and compatible BSP/ICF
  structure.
- All repository objects for this application belong to package `ZBPC_ASL` and
  this abapGit repository.

## 36. Testing strategy

### 36.1 Parser and semantic tests

- Tokenization, grammar, comments, literals, and error recovery.
- Type checking and null behavior.
- Model/dimension/property resolution using test adapters.
- Member-set operations.
- Dataset grain and join-cardinality validation.
- Region containment and write-mode semantics.
- Deterministic formatting and export.

### 36.2 Execution tests

- Filters, mappings, joins, grouping, unions, and generation.
- Allocation reconciliation and rounding residuals.
- Ordered/stateful time calculations.
- Procedures, bounded loops, and disjoint parallel partitions.
- Delta comparison: new, changed, unchanged, and stale records.
- Batch failure, checkpoint, cancellation, and restart.
- Extension timeouts and schema violations.

### 36.3 SAP integration tests

- Standard metadata and hierarchy reads.
- Security-enabled RSDRI/BPC reads.
- Dynamic full-key record creation.
- BPC write-back with member access and work-status cases.
- Cross-model mapping.
- Lock conflicts and concurrent runs.
- Large-volume preview and configured bulk-adapter eligibility.

### 36.4 Reference scenarios

Acceptance datasets should cover the patterns found in:

- `ALLOC_OPEX`: allocation, mapping, and existing-output comparison.
- `DEMREV` and `DEMREVID`: demand/revenue calculations and time logic.
- `AGGR_PROJECT` and `AGGR_OPEX`: aggregation and cross-model movement.
- `FAR`: source loading and asset-related calculations.
- `RAB`: depreciation, roll-forward, indexation, smoothing, geographic splits,
  parallel partitions, and multi-million-row replacement planning.

Customer-specific ABAP output may be used as a comparison oracle in a test
environment, but its implementation is not linked into ASL.

## 37. Acceptance criteria for the first usable release

The first usable release is accepted when:

1. An author can create, edit, validate, version, compare, and publish a script.
2. The editor completes model dimensions, properties, hierarchies, and members.
3. Scripts can read booked data using member, property, hierarchy, and parameter
   filters.
4. Scripts can filter, calculate, map, group, join, union, and explicitly generate
   bounded combinations.
5. Conditions, bounded member loops, functions, and procedures execute.
6. A script can read from and write to more than one explicitly declared model.
7. All writes target validated output regions and support `APPEND`, `MERGE`, and
   semantic `REPLACE`.
8. Standard replacement omits unchanged records and reverses only stale keys.
9. Preview reports resolved scopes and estimated new/changed/stale writes.
10. The engine prevents an unapproved million-record clear/write plan.
11. BPC security, work status, and locking are respected.
12. Run progress, timings, messages, metrics, cancellation, and eligible restart
    are available in the UI.
13. Published source and metadata export deterministically to text files.
14. No script can invoke an unregistered ABAP class, program, SQL statement, or
    physical BW table.
15. The solution runs on ABAP 7.52 and SAPUI5 1.52.

## 38. Delivery plan

### Phase 0: executable language prototype

- Finalize grammar with a parser spike.
- Build AST, formatter, diagnostics, and an in-memory dataset executor.
- Validate representative scripts from allocation, aggregation, roll-forward,
  and depreciation scenarios.

### Phase 1: repository and read-only workbench

- BSP shell, catalog, editor, metadata browser, versions, and Git export.
- Standard BPC metadata and booked-data reads.
- Validation, logical plan, and read-only previews.

### Phase 2: governed write-back

- Regions, `APPEND`, `MERGE`, and `REPLACE`.
- Existing-result comparison and batched standard write-back.
- Security, work status, locks, audit, dry run, and cancellation.

### Phase 3: calculation library and orchestration

- Allocation and time-series library.
- Procedures, bounded loops, dependencies, safe parallel partitions, and
  checkpoints.
- Cross-model scenarios from the reference models.

### Phase 4: extension and high-volume framework

- Governed source/function/action registry.
- Provider-aware bulk-replacement adapters where supported.
- Spill storage, advanced estimates, and large-volume operational tooling.

## 39. Decisions recorded

- Primary authors are BPC consultants; business power users may maintain scripts.
- Scripts run initially from the application.
- A script belongs to one environment and primary model.
- Scripts may explicitly read and write multiple models.
- The language includes procedural constructs.
- Reads use booked combinations by default; missing combinations are generated
  explicitly.
- Delta comparison is a runtime optimization, not a business-language feature.
- Storage uses custom SAP tables with immutable version history.
- Text export for Git is required.
- Parameters are typed.
- Dry-run, counts, timings, and debugging diagnostics are required.
- Extensions use a controlled registry.
- The syntax is assignment-oriented.
- The core uses standard SAP APIs and does not reuse customer-specific
  `ZCL_BPC*` implementations.

## 40. Open design items

The following require decisions or platform validation during implementation:

1. Final product name, BSP name, ICF path, package object names, and authorization
   object.
2. Whether publication requires one-person or four-eyes approval.
3. The exact background execution mechanism and worker concurrency model.
4. The temporary/spill dataset storage technology on the target system.
5. Which provider types support a safe bulk-replacement adapter on the installed
   BPC/BW support package.
6. Whether large derived RAB-style outputs should remain in the planning model,
   use a dedicated ADSO, or use versioned audit-trail partitions.
7. Git import and automated deployment workflow after deterministic export.
8. Retention durations for run details, trace samples, and temporary datasets.
9. Numeric comparison precision and rounding defaults by model/account type.
10. Initial standard-library function list and naming conventions.

These items do not block the parser prototype or read-only workbench. Bulk data
behavior must be validated before enabling production writes.
