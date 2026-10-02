# Architecture

> Status note: this document describes the **intended** architecture. Object and
> class names shown below are **design proposals** taken from SPECIFICATION.md
> §25 and §35; none of them are implemented yet, and naming may change where the
> ABAP release imposes limits.

## 1. Overview

ASL is a layered application. The SAPUI5 BSP front end talks only to an ICF
JSON/HTTP handler. The handler delegates to an application service layer, which
orchestrates the compiler pipeline (lexer → parser → binder/type checker →
planner), the execution runtime, and a set of SAP adapters. The SAP adapters are
the only layer that calls standard SAP BPC and BW APIs, and they are hidden
behind interfaces so the language and execution layers never see physical BW
table names or release-specific details.

## 2. Layer diagram

```text
SAPUI5 BSP application (SAPUI5 1.52)
        |  JSON/HTTP + CSRF, polling (no WebSocket)
        v
ICF JSON/HTTP handler          authn, CSRF, request limits, correlation ID
        |
        v
Application service layer     use cases + ASL authorization
        |
        +-- Script repository / versioning service
        +-- Metadata service / cache
        +-- Compiler pipeline (lexer, parser, binder, planner)
        +-- Run coordinator / worker
        +-- Diagnostics and audit
        |
        v
Adapter interfaces            metadata | query | write | source | extensions
        |
        v
Standard SAP BPC / BW APIs    CL_UJ_CONTEXT, CL_UJA_*, CL_UJO_*, CL_UJO_WB_*
```

## 3. Components

### 3.1 SAPUI5 BSP application

- Single SAPUI5 shell with pages: Home, Script catalog, Editor, Plan preview,
  Run monitor, Run details, Extension registry, Settings (§7).
- Editor features: syntax highlighting, bracket matching, line/column
  diagnostics, completion, hover for dataset shape and signatures, deterministic
  formatting, metadata browser, side-by-side diff, generated parameter form,
  Explain Plan and Preview Changes (§7).
- Talks only over the JSON/HTTP contract; polls run progress with bounded
  frequency (§30). Must run on SAPUI5 1.52; no controls or APIs introduced after
  1.52 (§7, §35).

### 3.2 ICF JSON/HTTP handler

- Proposed name: `ZCL_BPC_ASL_HTTP` (proposal).
- Responsibilities: authenticated SAP session enforcement, CSRF tokens for
  state-changing requests, strict JSON request schemas and size limits, error
  envelope, and a correlation ID shared with background jobs and adapter logs
  (§23.3, §29, §33).

### 3.3 Application service layer

- Proposed name: `ZCL_BPC_ASL_APP` (proposal).
- Implements use cases (create/validate/publish/execute scripts, run monitoring,
  extension administration, settings) and enforces ASL authorization against the
  `ZBPC_ASL` authorization object (§23.1).

### 3.4 Script repository and versioning

- Proposed name: `ZCL_BPC_ASL_REPOSITORY` (proposal).
- Backed by the custom tables defined in §27 (`ZBPC_ASL_SCR`, `ZBPC_ASL_VER`,
  `ZBPC_ASL_PAR`, ...). Source is stored as UTF-8 with a cryptographic hash;
  published versions are immutable; editing creates a draft; one active version
  per script (§27). Provides deterministic text export for Git (§28).

### 3.5 Compiler pipeline

- Lexer (`ZCL_BPC_ASL_LEXER`): tokens and source locations (§9).
- Parser (`ZCL_BPC_ASL_PARSER`): abstract syntax tree and syntax recovery (§8).
- Binder / type checker (`ZCL_BPC_ASL_BINDER`): names, models, dimensions,
  properties, hierarchies, and types (§9, §10).
- Planner (`ZCL_BPC_ASL_PLANNER`): logical/physical plan, pushdown, and
  estimates (§20, §21).

### 3.6 Execution runtime

- Dataset model and in-memory executor (`ZCL_BPC_ASL_EXECUTOR`).
- Run coordinator (`ZCL_BPC_ASL_RUNNER`): run lifecycle states (§19), locks,
  checkpoints, cancellation, and restart (§18.5, §22, §30).

### 3.7 Adapters (interfaces)

- Metadata adapter (`ZCL_BPC_ASL_METADATA`): model metadata facade and cache.
- Query adapter (`ZCL_BPC_ASL_BPC_QUERY`): security-enabled fact reads.
- Write adapter (`ZCL_BPC_ASL_BPC_WRITE`): delta comparison and standard
  write-back.
- Source adapters and extension registry (`ZCL_BPC_ASL_EXTENSIONS`,
  `ZIF_BPC_ASL_SOURCE`, `ZIF_BPC_ASL_FUNCTION`, `ZIF_BPC_ASL_ACTION`).

### 3.8 Extension registry

- Administrator-managed registry of approved sources, functions, and actions
  (§24). Implementation classes are instantiated only after registry lookup and
  interface validation; script authors cannot name arbitrary ABAP artifacts
  (§24, §12.3).

## 4. Dependency direction

Dependencies point strictly downward:

1. UI → HTTP contract (no direct SAP calls).
2. HTTP handler → application service.
3. Application service → repository, metadata, compiler, planner, runner.
4. Compiler/planner/executor → adapter **interfaces**, never SAP classes or
   physical tables directly.
5. Adapter implementations → standard SAP BPC/BW APIs.
6. Extension registry → registered extension contracts.

The parser and language semantics must not depend on physical BW table names
(§4.5, §26). Release-dependent details live only inside adapters.

## 5. Platform and security constraints

- ABAP compiles on SAP NetWeaver 7.52; front end on SAPUI5 1.52 (§35).
- No dependence on generated `/BIC/`, `/B28/`, or similar physical tables (§26).
- No arbitrary ABAP, SQL, or OS execution from scripts (§3, §23.3).
- Standard APIs only; `ZBPC_IO` used as a reference, never copied wholesale
  (§26, §35).
- All repository objects belong to package `ZBPC_ASL` (§35).
