# AI Questions

Open implementation questions raised during specification extraction. Each entry
follows a fixed format. `Blocking` indicates whether the question must be
resolved before the work named in `Work blocked` can proceed; `Work that can
continue` names work that is independent of the decision.

Questions Q-002..Q-011 correspond to the ten open design items in
[SPECIFICATION.md](SPECIFICATION.md) §40. Q-001 is an additional ambiguity
surfaced during extraction.

## Q-001 — AST persistence

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-REPO-003, ASL-RUN-002
- Blocking: Yes
- Context:
  The specification requires immutable source versions but does not explicitly
  say whether the parsed AST should be persisted.

- Question:
  Should the AST be stored with each version or rebuilt from source?

- Options considered:
  1. Store the AST.
  2. Rebuild it from source.
  3. Store it only as a disposable cache.

- DeepSeek recommendation:
  Rebuild it from source and record the compiler version.

- Work that can continue:
  Token and source-location implementation.

- Work blocked:
  Version persistence schema.

## Q-002 — Numeric comparison precision

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-WRITE-007, ASL-PERF-001
- Blocking: Yes
- Context:
  §18.3 requires delta comparison "using configured numeric precision" and §40.9
  lists numeric comparison precision and rounding defaults as open. The spec does
  not state the default precision or whether it varies by model/account type.

- Question:
  What default numeric precision and rounding policy should the engine use for
  delta comparison?

- Options considered:
  1. A single engine-wide constant.
  2. A configurable comparison epsilon with a conservative default.
  3. Per-model/account-type precision resolved from BPC metadata.
  4. Fixed decimal places (e.g. two) for all models.

- DeepSeek recommendation:
  Introduce a configurable comparison epsilon with a conservative default, and
  resolve per-model/account-type precision from BPC metadata once baselined.

- Work that can continue:
  Parser, planner, and read-only preview (no value comparison).

- Work blocked:
  Write-back delta comparison correctness and unchanged-record omission.

## Q-003 — Background execution mechanism

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-RUN-016, ASL-RUN-018, ASL-OPS-004
- Blocking: Yes
- Context:
  §30 requires preview/execution to return a run ID immediately and a background
  job or controlled worker to process the run, but the exact mechanism and worker
  concurrency model are open (§40.3).

- Question:
  Which background execution mechanism and worker concurrency model should the
  runtime use on NetWeaver 7.52?

- Options considered:
  1. ABAP background jobs with DB-persisted run state.
  2. A long-running controlled worker process.
  3. Synchronous execution with asynchronous UI polling.
  4. A combination of background job plus a coordinator.

- DeepSeek recommendation:
  Use an ABAP background job with DB-persisted run state and checkpoints so the
  worker-recovery rules in §30 are implementable without WebSocket support.

- Work that can continue:
  Compiler pipeline, preview/plan generation, and run-header persistence schema.

- Work blocked:
  Run lifecycle execution, worker recovery, and cancellation/restart behavior.

## Q-004 — Spill storage technology

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-REPO-005, ASL-PERF-001, ASL-PERF-007, ASL-RUN-008
- Blocking: No
- Context:
  §20 and §27 require spilling large intermediate datasets to governed temporary
  storage, but the storage technology is open (§40.4) and the runtime must avoid
  loading an unbounded dataset into one ABAP internal table (§34).

- Question:
  Which temporary/spill storage technology should back large intermediates on the
  target system?

- Options considered:
  1. Dedicated transparent temp table scoped by run.
  2. Cluster/INDX-style content storage.
  3. Temporary BW/application tables.
  4. Keep everything in memory up to configured limits (defer spill).

- DeepSeek recommendation:
  Design the dataset interface to allow a spill-backed implementation and defer
  the concrete technology to Phase 4; keep an in-memory implementation first.

- Work that can continue:
  In-memory dataset model, executor, and plan preview.

- Work blocked:
  Multi-million-record spill support and large-volume operational controls.

## Q-005 — Bulk-replacement provider support

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-WRITE-008, ASL-WRITE-010, ASL-PERF-009
- Blocking: No
- Context:
  §18.4 allows `REGISTERED_BULK_REPLACE` but requires the bulk adapter to validate
  provider type and platform support; which provider types support it is open
  (§40.5).

- Question:
  Which provider types support a safe bulk-replacement adapter on the installed
  BPC/BW support package?

- Options considered:
  1. Enable bulk only for specific ADSO/InfoProvider types after validation.
  2. Implement only `KEY_DELTA` and `CHUNKED_WRITEBACK` initially.
  3. Allow bulk for any provider with an administrator override.
  4. Defer all bulk replacement until the platform is validated.

- DeepSeek recommendation:
  Implement `KEY_DELTA` and `CHUNKED_WRITEBACK` first and gate
  `REGISTERED_BULK_REPLACE` behind an explicit provider-type allowlist validated
  against the installed support package.

- Work that can continue:
  Standard write-back, delta comparison, and chunked writes.

- Work blocked:
  Production bulk-replacement adapter enablement.

## Q-006 — Large RAB-style output architecture

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-PERF-009, ASL-WRITE-008, ASL-PROD-008
- Blocking: No
- Context:
  §18.4 notes that routinely rebuilt multi-million-row derived results may
  warrant a dedicated ADSO or versioned output partition; whether to keep them in
  the planning model is open (§40.6).

- Question:
  Should large derived outputs (RAB-style) stay in the planning model, use a
  dedicated ADSO, or use versioned audit-trail partitions?

- Options considered:
  1. Keep output in the planning model with versioned audit-trail partitions.
  2. Use a dedicated ADSO for derived output.
  3. Use versioned output partitions plus planning input at the reporting layer.
  4. Leave it as an architecture option with no implicit script behavior.

- DeepSeek recommendation:
  Keep derived output in the planning model with versioned audit-trail
  partitions initially and evaluate a dedicated ADSO only if it proves unsuitable;
  never make it implicit script behavior.

- Work that can continue:
  Standard write-back and reference scenarios at normal volume.

- Work blocked:
  Multi-million-row replacement planning for RAB-style outputs.

## Q-007 — Git import and deployment workflow

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-REPO-009, ASL-REPO-006
- Blocking: No
- Context:
  §28 requires deterministic export and says import is a later phase that must
  create a draft; the import and automated deployment workflow is open (§40.7).

- Question:
  How should Git import and automated deployment work after deterministic export?

- Options considered:
  1. Export-only first; import as create-draft in a later phase.
  2. Bidirectional sync with abapGit operations.
  3. Manual import producing drafts with a review step.
  4. Automated deployment on merge.

- DeepSeek recommendation:
  Ship export first; implement import as create-draft (never silent replacement
  of an active version) in a later phase.

- Work that can continue:
  Deterministic export layout and metadata.json.

- Work blocked:
  Import and automated deployment.

## Q-008 — Retention durations

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-OPS-006, ASL-REPO-005
- Blocking: No
- Context:
  §27 requires retention jobs to remove expired run details and temporary content
  while preserving audit headers, but specific durations are open (§40.8).

- Question:
  What are the retention durations for run details, trace samples, and temporary
  datasets?

- Options considered:
  1. A single global retention period.
  2. Per-content-class retention (audit headers longest, temp shortest).
  3. Administrator-configurable per class with defaults.
  4. No retention until defaults are defined.

- DeepSeek recommendation:
  Provide administrator-configurable retention per content class with published
  defaults; keep audit headers longest, trace samples shorter, temp data shortest.

- Work that can continue:
  Run/metrics/message persistence and trace capture.

- Work blocked:
  Retention job implementation.

## Q-009 — Publication approval model

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-SEC-001, ASL-REPO-004
- Blocking: No
- Context:
  §5 defines a Script publisher role but §40.2 leaves open whether publication
  requires one-person or four-eyes approval.

- Question:
  Does publishing an active version require four-eyes approval?

- Options considered:
  1. Single-user publish via the publisher role.
  2. Mandatory four-eyes approval.
  3. Configurable approval step defaulting to single-user.

- DeepSeek recommendation:
  Default to single-user publish via the publisher role and make four-eyes a
  configurable approval step.

- Work that can continue:
  Repository, versioning, and publish endpoint design.

- Work blocked:
  Approval workflow implementation.

## Q-010 — Standard-library function list

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-TIME-001, ASL-TIME-007, ASL-DATA-014, ASL-DATA-021
- Blocking: No
- Context:
  §14, §13.3, and §15 list initial functions, but the final standard-library list
  and naming conventions are open (§40.10).

- Question:
  What is the initial standard-library function list and its naming convention?

- Options considered:
  1. Ship the full §14 time-series list plus §13.3 aggregations and §15 allocation.
  2. Ship a minimal subset first and add incrementally.
  3. Align naming with the extension registry conventions.
  4. Defer naming until parser prototyping.

- DeepSeek recommendation:
  Start with the §14 time-series list, §13.3 aggregations, and §15 allocation,
  added incrementally under a documented naming convention.

- Work that can continue:
  Parser, formatter, and in-memory executor scaffolding.

- Work blocked:
  Finalization of the standard library surface.

## Q-011 — Product and object naming

- Status: Open
- Raised by: DeepSeek
- Date: 2026-10-02
- Related requirements: ASL-PROD-023, ASL-SEC-003, ASL-API-001, ASL-PROD-022
- Blocking: Yes
- Context:
  §40.1 lists final product name, BSP name, ICF path, package object names, and
  authorization object as open; §7 and §29 propose `ZBPC_ASL` and
  `/sap/bc/zbpc_asl`.

- Question:
  What are the final product, BSP, ICF path, package object, and authorization
  object names?

- Options considered:
  1. Use the proposed names (`ZBPC_ASL`, `/sap/bc/zbpc_asl`, `ZCL_BPC_ASL_*`).
  2. Wait for customer naming/role standards.
  3. Adopt working names now and rename later.
  4. Derive names from the authorization object design.

- DeepSeek recommendation:
  Proceed with the proposed names as working names and finalize against the
  customer's naming and role standards before creating production objects.

- Work that can continue:
  Documentation, parser prototype, and in-memory executor.

- Work blocked:
  Creating production ABAP/BSP/ICF objects and the authorization object.


