# Decision Log

Records material architectural, compatibility, security, persistence, and
language-semantic decisions. ADRs seeded from SPECIFICATION.md §39 ("Decisions
recorded") plus material constraints from §3, §23, §26, and §35.

Status reflects design-level acceptance in the proposed specification; none of
these decisions is yet implemented or validated on the target system.

## ADR-001 — Primary authors and maintainers

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-PROD-002, ASL-PROD-003
- Context: Choose who writes and who maintains scripts.
- Decision: Primary authors are BPC consultants; trained business power users may maintain parameters and business rules.
- Consequences: The language and tooling must be approachable without ABAP knowledge; parameter maintenance is a first-class, low-friction path.

## ADR-002 — Scripts run from the application

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-PROD-021, ASL-RUN-016
- Context: How runs are launched.
- Decision: Scripts run initially from the application, not as a Data Manager replacement in the first release.
- Consequences: A background worker/run coordinator is required; Data Manager orchestration is explicitly out of scope for the first release.

## ADR-003 — One environment and primary model per script

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-PROD-005, ASL-META-003
- Context: Script scoping.
- Decision: A script belongs to one environment and one primary model.
- Consequences: The compiler can bind dimensions/properties against a fixed primary model; metadata signatures are model-scoped.

## ADR-004 — Explicit multi-model read/write

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-PROD-005, ASL-PROD-034, ASL-META-004
- Context: Cross-model calculations.
- Decision: Scripts may explicitly read from and write to other models via `MODEL` declarations.
- Consequences: Cross-model transfers require explicit mappings where dimensions differ (ASL-META-002).

## ADR-005 — Procedural constructs included

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-PROC-001..ASL-PROC-011
- Context: Expressiveness vs. safety.
- Decision: The language includes conditions, bounded loops, functions, procedures, and parallel blocks; unbounded `WHILE` is excluded.
- Consequences: The compiler must prove loop bounds and disjoint parallel write regions; functions must remain side-effect free.

## ADR-006 — Booked reads by default

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-DATA-002, ASL-DATA-006, ASL-DATA-007
- Context: Whether reads invent absent fact combinations.
- Decision: Reads use booked combinations by default; missing combinations are generated explicitly via `GENERATE`.
- Consequences: Zero values and missing combinations remain distinguishable; generation requires an explicit maximum.

## ADR-007 — Delta comparison is a runtime optimization

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-RUN-002, ASL-WRITE-007
- Context: Whether delta handling is a language feature.
- Decision: Delta comparison (key-level compare, omit unchanged, reverse stale) is a runtime optimization, not part of the business language.
- Consequences: Scripts express desired results and owned regions only; the engine owns the comparison strategy.

## ADR-008 — Custom tables with immutable versions

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-REPO-001..ASL-REPO-004
- Context: Where scripts and history live.
- Decision: Storage uses SAP custom tables with immutable version history; source stored as UTF-8 with a cryptographic hash; one active version per script.
- Consequences: Editing always creates a draft; publication is immutable; requires a repository service and retention jobs.

## ADR-009 — Deterministic Git export

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-REPO-006..ASL-REPO-009
- Context: Version control integration.
- Decision: Text export for Git is required and deterministic; volatile timestamps omitted; import (later phase) creates a draft.
- Consequences: Unchanged scripts produce no Git diff; a fixed export layout and metadata.json key order are mandatory.

## ADR-010 — Typed parameters

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-LANG-006, ASL-LANG-007, ASL-TYPE-012
- Context: How inputs reach a script.
- Decision: Parameters are typed, may be required, have defaults, and may restrict allowed values; values are stored with the run, not substituted into source.
- Consequences: Member parameters are validated against the bound model and user access; parameter values are auditable and non-injectable.

## ADR-011 — Dry-run, counts, timings, and diagnostics required

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-PROD-010, ASL-RUN-010, ASL-RUN-011, ASL-OPS-003
- Context: Operability and trust.
- Decision: Dry-run, row counts, timings, and debugging diagnostics are required, with an audit trail.
- Consequences: Preview must reach the write boundary without committing; every run persists structured metrics.

## ADR-012 — Controlled extension registry

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-PROD-013, ASL-EXT-001..ASL-EXT-005
- Context: Extensibility without arbitrary code execution.
- Decision: Extensions use a controlled, administrator-managed registry (scalar function, table function, source, action).
- Consequences: Only registered artifacts are invocable; actions require an explicit `ACTION` statement.

## ADR-013 — Assignment-oriented syntax

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-LANG-001..ASL-LANG-005
- Context: Language style.
- Decision: The syntax is assignment-oriented (declarative dataset transformations), not a Logic Script port.
- Consequences: The grammar is normative at the semantic level; minor refinements allowed only with mechanical migration of examples.

## ADR-014 — Standard SAP APIs only

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-PROD-012, ASL-PROD-020, ASL-META-009, ASL-META-010
- Context: Core implementation approach.
- Decision: The core uses standard SAP BPC and BW APIs and does not reuse customer-specific `ZCL_BPC*` implementations.
- Consequences: Customer-specific calculation code is an oracle at most, never linked into ASL.

## ADR-015 — ABAP 7.52 / SAPUI5 1.52 compatibility

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-PROD-024, ASL-PROD-025, ASL-PROD-026, ASL-PROD-043
- Context: Target platform.
- Decision: ABAP must compile on NetWeaver 7.52; front end runs on SAPUI5 1.52; newer syntax/APIs avoided unless adapter-guarded.
- Consequences: No post-1.52 UI controls; no newer ABAP syntax without a guarded adapter.

## ADR-016 — Adapters behind interfaces

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-META-010, ASL-META-011, ASL-PROD-022
- Context: Testability and portability.
- Decision: Standard API calls are encapsulated behind adapter interfaces so they can be substituted in tests.
- Consequences: Parser/semantics are independent of physical BW tables; no `/BIC/`, `/B28/` dependencies.

## ADR-017 — No arbitrary ABAP/SQL/OS execution

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-PROD-014, ASL-PROD-042, ASL-SEC-011
- Context: Blast-radius control.
- Decision: Scripts cannot invoke arbitrary ABAP programs, classes, methods, SQL, or OS commands; no ungoverned ABAP/SQL names through request parameters.
- Consequences: Every reachable artifact must be registered or built-in; this is a release acceptance criterion.

## ADR-018 — Initiating-user security context

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-SEC-005, ASL-SEC-006, ASL-SEC-007
- Context: Authorization model.
- Decision: Reads and writes execute in the initiating user's security context; BPC member access, task authorization, work status, and write-back checks remain effective.
- Consequences: Preview/execution cannot exceed the user's BPC rights; a service-user model requires explicit approval.

## ADR-019 — Extensions cannot name arbitrary ABAP artifacts

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-EXT-003, ASL-EXT-004, ASL-EXT-005
- Context: Extension invocation.
- Decision: Implementation classes are instantiated only after registry lookup and interface validation; script authors cannot name arbitrary ABAP artifacts.
- Consequences: Registry entries carry schemas, limits, allowed models, and validity dates enforced at invocation.

## ADR-020 — Governed large-volume replacement

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-WRITE-008, ASL-WRITE-009, ASL-WRITE-010, ASL-PERF-009
- Context: Multi-million-record writes.
- Decision: Large-volume replacement supports `KEY_DELTA`, `CHUNKED_WRITEBACK`, and `REGISTERED_BULK_REPLACE`; forced bulk mode requires an authorized run profile; bulk adapters never delete directly from generated fact tables.
- Consequences: Automatic selection is estimate-driven; bulk provider type/platform support must be validated before production writes.

## ADR-021 — Diagnostic code convention

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-OPS-001, ASL-API-005
- Context: §31 requires diagnostics to carry a stable code but does not define a
  format or namespace.
- Decision: Diagnostic codes are stable `UPPER_SNAKE_CASE` strings (start with a
  letter, 2–60 characters, at least one underscore). A category-prefix naming
  convention reserves the first segment per layer: `LEX_` (lexical), `SYN_`
  (syntax), `SEM_` (semantic/binding/type), `RUN_` (runtime/execution), and
  `SYS_` (adapter/infrastructure). New codes may be added; existing codes are
  never renamed or repurposed.
- Consequences: The lexer, parser, and runtime share one code namespace. The
  `ZCL_BPC_ASL_DIAG_CODE` validator enforces shape only, not the prefix
  allowlist, because §29's example code (`UNKNOWN_PROPERTY`) is unprefixed;
  category ownership is enforced by convention and review rather than by
  validation.

## ADR-022 — Source coordinate contract

- Date: 2026-10-02
- Status: Accepted
- Related requirements: ASL-OPS-001, ASL-UI-003, ASL-API-005, ASL-LANG-001
- Context: Q-012 asked how source positions and ranges must be computed. The
  user approved the convention below; it is authoritative for the lexer, parser,
  formatter, editor, and HTTP serializer.
- Decision:
  1. Lines and columns are 1-based (the first character of the first line is
     `(1,1)`).
  2. Source ranges are half-open `[start, end)`; the start is included and the
     end is excluded.
  3. Columns count UTF-16 code units.
  4. Tabs count as one code unit (no tab-stop expansion).
  5. CRLF and CR are normalized to LF before positions are calculated.
  6. Supplementary characters count as two code units (a surrogate pair);
     combining marks count separately.
- Consequences: `ZCL_BPC_ASL_SRC_POS` and `ZCL_BPC_ASL_SRC_RANGE` store
  coordinates as produced; the producer (lexer) applies these counting rules.
  Single-line `length` in §29's envelope is `end_column - start_column`.
- Contract examples:

  | Case | Positions | Meaning |
  | --- | --- | --- |
  | First character | `(1,1)` | 1-based origin |
  | One-character range | `[1,1) → [1,2)` | half-open; spans one code unit |
  | Insertion / EOF | `[n,c) → [n,c)` | zero-width; start = end |
  | Multiline range | `[2,5) → [4,3)` | line-major; end line ≥ start line |
  | Tab | `+1` column | one code unit; no expansion |
  | Line ending | CRLF/CR → LF | no CR column; no extra line |
  | Combining mark | `e` + combining acute = 2 columns | marks count separately |
  | Supplementary char | astral `U+1F600` = 2 columns | surrogate pair = 2 code units |

## Open Questions

Recorded from SPECIFICATION.md §40 plus items surfaced during extraction. These
are not resolved here; implementation must not silently choose behavior.

1. Final product name, BSP name, ICF path, package object names, and authorization object.
2. Whether publication requires one-person or four-eyes approval.
3. The exact background execution mechanism and worker concurrency model.
4. The temporary/spill dataset storage technology on the target system.
5. Which provider types support a safe bulk-replacement adapter on the installed BPC/BW support package.
6. Whether large derived RAB-style outputs should remain in the planning model, use a dedicated ADSO, or use versioned audit-trail partitions.
7. Git import and automated deployment workflow after deterministic export.
8. Retention durations for run details, trace samples, and temporary datasets.
9. Numeric comparison precision and rounding defaults by model/account type.
10. Initial standard-library function list and naming conventions.

Mapping note (not a contradiction): the phase breakdown in the phase documents
refines SPECIFICATION.md §38. In particular, Phase 0 additionally names the
scalar type system, the in-memory dataset model, and the test metadata adapter
as explicit deliverables; this is treated as a refinement of §38's "grammar /
AST / formatter / in-memory executor", not a change to the specification.
